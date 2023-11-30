BEGIN
    

    DECLARE FechaInicial  DATE;
    DECLARE FechaFinal  DATE;
    DECLARE FechaPlanilla  DATE;
    DECLARE IntAcumulado  FLOAT; 
    DECLARE IntDia  FLOAT;
    DECLARE IntPendiente  FLOAT;
    DECLARE tasaInt  FLOAT;
    DECLARE Saldo  FLOAT;
    DECLARE Dias  INTEGER;
    DECLARE credito INTEGER;



    SET credito = 100036252;
    SET FechaPlanilla = '2023-03-30';
    SET IntAcumulado = 0;
    SET IntDia = 0;
    SET Saldo = 0;
    SET Dias = 0;
    SET tasaInt = 0;
    SET IntPendiente = 0;


    SELECT DAY(FechaPlanilla) INTO Dias;
    
    SET Dias = Dias - 1;

    SELECT dateformat(FechaPlanilla - Dias, 'yyyy-MM-dd') INTO FechaInicial;

    //SELECT FechaInicial;


    SET  FechaFinal = FechaPlanilla;
    /*FROM DBA.CREDITOS, DBA.Plan_de_Pago
    WHERE CRE_CODIGO_CTA = PLP_CUENTA AND CRE_CODIGO_CTA = credito AND PLP_FECHA_PAGO > FechaPlanilla;*/


    //SELECT FechaFinal;

    SELECT CRE_PORC_INTERES/100 INTO tasaInt
    FROM DBA.CREDITOS
    WHERE CRE_CODIGO_CTA = credito;        


    lbl:
    LOOP
        
        SELECT SUM(TRC_MTO_OTORGADO-TRC_MTO_CAPITAL) INTO Saldo
        FROM DBA.TRANS_CREDITO
        WHERE TRC_CODIGO_CTA = credito AND TRC_FECHA_TRANS <= (FechaInicial-1);


       
        //SET IntDia =  
        SELECT CAST(Saldo*(tasaInt/360) AS DECIMAL(12,6)) INTO IntDia;
        
        SET IntAcumulado = IntAcumulado + IntDia;
        
        /*IF (FechaInicial='2023-04-01')THEN 
            SELECT IntAcumulado,  IntDia;
        END IF;*/


                        
        IF FechaInicial >= FechaFinal THEN
            LEAVE lbl;
        END IF;

        SELECT dateformat(FechaInicial + 1, 'yyyy-MM-dd') INTO FechaInicial;

    END LOOP lbl;


    SELECT SUM(TRC_PROVISION - TRC_MTO_INTERES) INTO IntPendiente
    FROM DBA.TRANS_CREDITO
    WHERE TRC_CODIGO_CTA = credito AND TRC_FECHA_TRANS <= FechaPlanilla;

    SET IntAcumulado = IntAcumulado + IntPendiente;

    SELECT CAST(IntAcumulado AS DECIMAL(12,2));


            
END 