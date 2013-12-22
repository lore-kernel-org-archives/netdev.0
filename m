From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 22/31] staging: r8188eu: Simplify code related to SupportICType
Date: Sun, 22 Dec 2013 17:36:53 -0600
Message-ID: <1387755422-11443-23-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:58199 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756895Ab3LVXii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:38 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so4707232pab.20
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:38 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This member of struct odm_dm_struct is always set to ODM_RTL8188E for this
driver. Accordingly, the code can be simplified. A number of routines
now are no longer needed and are deleted.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 .../staging/rtl8188eu/hal/Hal8188ERateAdaptive.c   |   4 +-
 drivers/staging/rtl8188eu/hal/odm.c                | 615 ++++-----------------
 drivers/staging/rtl8188eu/hal/odm_HWConfig.c       | 218 +++-----
 drivers/staging/rtl8188eu/hal/odm_RTL8188E.c       |   5 +-
 drivers/staging/rtl8188eu/include/odm.h            |   2 -
 drivers/staging/rtl8188eu/include/odm_debug.h      |  13 +-
 6 files changed, 191 insertions(+), 666 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c b/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
index aaa2617..3df33bc 100644
--- a/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
+++ b/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
@@ -529,9 +529,7 @@ ODM_RASupport_Init(
 {
 	ODM_RT_TRACE(dm_odm, ODM_COMP_RATE_ADAPTIVE, ODM_DBG_LOUD, ("=====>ODM_RASupport_Init()\n"));
 
-	/*  2012/02/14 MH Be noticed, the init must be after IC type is recognized!!!!! */
-	if (dm_odm->SupportICType == ODM_RTL8188E)
-		dm_odm->RaSupport88E = true;
+	dm_odm->RaSupport88E = true;
 }
 
 int ODM_RAInfo_Init(struct odm_dm_struct *dm_odm, u8 macid)
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 9606db5..3ce881d 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -182,20 +182,16 @@ void ODM_DMInit(struct odm_dm_struct *pDM_Odm)
 	odm_DIGInit(pDM_Odm);
 	odm_RateAdaptiveMaskInit(pDM_Odm);
 
-	if (pDM_Odm->SupportICType & ODM_IC_11AC_SERIES) {
-		;
-	} else if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
-		odm_PrimaryCCA_Init(pDM_Odm);    /*  Gary */
-		odm_DynamicBBPowerSavingInit(pDM_Odm);
-		odm_DynamicTxPowerInit(pDM_Odm);
-		odm_TXPowerTrackingInit(pDM_Odm);
-		ODM_EdcaTurboInit(pDM_Odm);
-		ODM_RAInfo_Init_all(pDM_Odm);
-		if ((pDM_Odm->AntDivType == CG_TRX_HW_ANTDIV)	||
-		    (pDM_Odm->AntDivType == CGCS_RX_HW_ANTDIV) ||
-		    (pDM_Odm->AntDivType == CG_TRX_SMART_ANTDIV))
-			odm_InitHybridAntDiv(pDM_Odm);
-	}
+	odm_PrimaryCCA_Init(pDM_Odm);    /*  Gary */
+	odm_DynamicBBPowerSavingInit(pDM_Odm);
+	odm_DynamicTxPowerInit(pDM_Odm);
+	odm_TXPowerTrackingInit(pDM_Odm);
+	ODM_EdcaTurboInit(pDM_Odm);
+	ODM_RAInfo_Init_all(pDM_Odm);
+	if ((pDM_Odm->AntDivType == CG_TRX_HW_ANTDIV)	||
+	    (pDM_Odm->AntDivType == CGCS_RX_HW_ANTDIV) ||
+	    (pDM_Odm->AntDivType == CG_TRX_SMART_ANTDIV))
+		odm_InitHybridAntDiv(pDM_Odm);
 }
 
 /*  2011/09/20 MH This is the entry pointer for all team to execute HW out source DM. */
@@ -215,9 +211,7 @@ void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm)
 	/* NeilChen--2012--08--24-- */
 	/* Fix Leave LPS issue */
 	if ((pDM_Odm->Adapter->pwrctrlpriv.pwr_mode != PS_MODE_ACTIVE) &&/*  in LPS mode */
-	    ((pDM_Odm->SupportICType & (ODM_RTL8723A)) ||
-	    (pDM_Odm->SupportICType & (ODM_RTL8188E) &&
-	    ((pDM_Odm->SupportInterface  == ODM_ITRF_SDIO))))) {
+	    (pDM_Odm->SupportInterface  == ODM_ITRF_SDIO)) {
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("----Step1: odm_DIG is in LPS mode\n"));
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("---Step2: 8723AS is in LPS mode\n"));
 		odm_DIGbyRSSI_LPS(pDM_Odm);
@@ -238,13 +232,9 @@ void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm)
 	    (pDM_Odm->AntDivType == CG_TRX_SMART_ANTDIV))
 		odm_HwAntDiv(pDM_Odm);
 
-	if (pDM_Odm->SupportICType & ODM_IC_11AC_SERIES) {
-		;
-	} else if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
-		ODM_TXPowerTrackingCheck(pDM_Odm);
-	      odm_EdcaTurboCheck(pDM_Odm);
-		odm_DynamicTxPower(pDM_Odm);
-	}
+	ODM_TXPowerTrackingCheck(pDM_Odm);
+	odm_EdcaTurboCheck(pDM_Odm);
+	odm_DynamicTxPower(pDM_Odm);
 }
 
 /*  Init /.. Fixed HW value. Only init time. */
@@ -455,10 +445,6 @@ void odm_CommonInfoSelfInit(struct odm_dm_struct *pDM_Odm)
 
 	pDM_Odm->bCckHighPower = (bool) PHY_QueryBBReg(adapter, 0x824, BIT9);
 	pDM_Odm->RFPathRxEnable = (u8) PHY_QueryBBReg(adapter, 0xc04, 0x0F);
-	if (pDM_Odm->SupportICType & (ODM_RTL8192C|ODM_RTL8192D))
-		pDM_Odm->AntDivType = CG_TRX_HW_ANTDIV;
-	if (pDM_Odm->SupportICType & (ODM_RTL8723A))
-		pDM_Odm->AntDivType = CGCS_RX_SW_ANTDIV;
 
 	ODM_InitDebugSetting(pDM_Odm);
 }
@@ -544,8 +530,6 @@ void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI)
 
 	if (pDM_DigTable->CurIGValue != CurrentIGI) {
 		PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-		if (pDM_Odm->SupportICType != ODM_RTL8188E)
-			PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("CurrentIGI(0x%02x).\n", CurrentIGI));
 		/* pDM_DigTable->PreIGValue = pDM_DigTable->CurIGValue; */
 		pDM_DigTable->CurIGValue = CurrentIGI;
@@ -566,9 +550,6 @@ void odm_DIGbyRSSI_LPS(struct odm_dm_struct *pDM_Odm)
 	u8 bFwCurrentInPSMode = false;
 	u8 CurrentIGI = pDM_Odm->RSSI_Min;
 
-	if (!(pDM_Odm->SupportICType & (ODM_RTL8723A | ODM_RTL8188E)))
-		return;
-
 	CurrentIGI = CurrentIGI + RSSI_OFFSET_DIG;
 	bFwCurrentInPSMode = pAdapter->pwrctrlpriv.bFwCurrentInPSMode;
 
@@ -665,91 +646,47 @@ void odm_DIG(struct odm_dm_struct *pDM_Odm)
 		return;
 	}
 
-	if (pDM_Odm->SupportICType == ODM_RTL8192D) {
-		if (*(pDM_Odm->pMacPhyMode) == ODM_DMSP) {
-			if (*(pDM_Odm->pbMasterOfDMSP)) {
-				DIG_Dynamic_MIN = pDM_DigTable->DIG_Dynamic_MIN_0;
-				FirstConnect = (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_0);
-				FirstDisConnect = (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConnect_0);
-			} else {
-				DIG_Dynamic_MIN = pDM_DigTable->DIG_Dynamic_MIN_1;
-				FirstConnect = (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_1);
-				FirstDisConnect = (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConnect_1);
-			}
-		} else {
-			if (*(pDM_Odm->pBandType) == ODM_BAND_5G) {
-				DIG_Dynamic_MIN = pDM_DigTable->DIG_Dynamic_MIN_0;
-				FirstConnect = (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_0);
-				FirstDisConnect = (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConnect_0);
-			} else {
-				DIG_Dynamic_MIN = pDM_DigTable->DIG_Dynamic_MIN_1;
-				FirstConnect = (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_1);
-				FirstDisConnect = (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConnect_1);
-			}
-		}
-	} else {
-		DIG_Dynamic_MIN = pDM_DigTable->DIG_Dynamic_MIN_0;
-		FirstConnect = (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_0);
-		FirstDisConnect = (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConnect_0);
-	}
+	DIG_Dynamic_MIN = pDM_DigTable->DIG_Dynamic_MIN_0;
+	FirstConnect = (pDM_Odm->bLinked) && (!pDM_DigTable->bMediaConnect_0);
+	FirstDisConnect = (!pDM_Odm->bLinked) && (pDM_DigTable->bMediaConnect_0);
 
 	/* 1 Boundary Decision */
-	if ((pDM_Odm->SupportICType & (ODM_RTL8192C|ODM_RTL8723A)) &&
-	    ((pDM_Odm->BoardType == ODM_BOARD_HIGHPWR) || pDM_Odm->ExtLNA)) {
-		dm_dig_max = DM_DIG_MAX_NIC_HP;
-		dm_dig_min = DM_DIG_MIN_NIC_HP;
-		DIG_MaxOfMin = DM_DIG_MAX_AP_HP;
-	} else {
-		dm_dig_max = DM_DIG_MAX_NIC;
-		dm_dig_min = DM_DIG_MIN_NIC;
-		DIG_MaxOfMin = DM_DIG_MAX_AP;
-	}
+	dm_dig_max = DM_DIG_MAX_NIC;
+	dm_dig_min = DM_DIG_MIN_NIC;
+	DIG_MaxOfMin = DM_DIG_MAX_AP;
+
 	if (pDM_Odm->bLinked) {
-	      /* 2 8723A Series, offset need to be 10 */
-		if (pDM_Odm->SupportICType == (ODM_RTL8723A)) {
-			/* 2 Upper Bound */
-			if ((pDM_Odm->RSSI_Min + 10) > DM_DIG_MAX_NIC)
-				pDM_DigTable->rx_gain_range_max = DM_DIG_MAX_NIC;
-			else if ((pDM_Odm->RSSI_Min + 10) < DM_DIG_MIN_NIC)
-				pDM_DigTable->rx_gain_range_max = DM_DIG_MIN_NIC;
-			else
-				pDM_DigTable->rx_gain_range_max = pDM_Odm->RSSI_Min + 10;
-			/* 2 If BT is Concurrent, need to set Lower Bound */
-			DIG_Dynamic_MIN = DM_DIG_MIN_NIC;
-		} else {
-			/* 2 Modify DIG upper bound */
-			if ((pDM_Odm->RSSI_Min + 20) > dm_dig_max)
-				pDM_DigTable->rx_gain_range_max = dm_dig_max;
-			else if ((pDM_Odm->RSSI_Min + 20) < dm_dig_min)
-				pDM_DigTable->rx_gain_range_max = dm_dig_min;
-			else
-				pDM_DigTable->rx_gain_range_max = pDM_Odm->RSSI_Min + 20;
-			/* 2 Modify DIG lower bound */
-			if (pDM_Odm->bOneEntryOnly) {
-				if (pDM_Odm->RSSI_Min < dm_dig_min)
-					DIG_Dynamic_MIN = dm_dig_min;
-				else if (pDM_Odm->RSSI_Min > DIG_MaxOfMin)
-					DIG_Dynamic_MIN = DIG_MaxOfMin;
-				else
-					DIG_Dynamic_MIN = pDM_Odm->RSSI_Min;
-				ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
-					     ("odm_DIG() : bOneEntryOnly=true,  DIG_Dynamic_MIN=0x%x\n",
-					     DIG_Dynamic_MIN));
-				ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
-					     ("odm_DIG() : pDM_Odm->RSSI_Min=%d\n",
-					     pDM_Odm->RSSI_Min));
-			} else if ((pDM_Odm->SupportICType == ODM_RTL8188E) &&
-				   (pDM_Odm->SupportAbility & ODM_BB_ANT_DIV)) {
-				/* 1 Lower Bound for 88E AntDiv */
-				if (pDM_Odm->AntDivType == CG_TRX_HW_ANTDIV) {
-					DIG_Dynamic_MIN = (u8) pDM_DigTable->AntDiv_RSSI_max;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD,
-						     ("odm_DIG(): pDM_DigTable->AntDiv_RSSI_max=%d\n",
-						     pDM_DigTable->AntDiv_RSSI_max));
-				}
-			} else {
+		/* 2 Modify DIG upper bound */
+		if ((pDM_Odm->RSSI_Min + 20) > dm_dig_max)
+			pDM_DigTable->rx_gain_range_max = dm_dig_max;
+		else if ((pDM_Odm->RSSI_Min + 20) < dm_dig_min)
+			pDM_DigTable->rx_gain_range_max = dm_dig_min;
+		else
+			pDM_DigTable->rx_gain_range_max = pDM_Odm->RSSI_Min + 20;
+		/* 2 Modify DIG lower bound */
+		if (pDM_Odm->bOneEntryOnly) {
+			if (pDM_Odm->RSSI_Min < dm_dig_min)
 				DIG_Dynamic_MIN = dm_dig_min;
+			else if (pDM_Odm->RSSI_Min > DIG_MaxOfMin)
+				DIG_Dynamic_MIN = DIG_MaxOfMin;
+			else
+				DIG_Dynamic_MIN = pDM_Odm->RSSI_Min;
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+				     ("odm_DIG() : bOneEntryOnly=true,  DIG_Dynamic_MIN=0x%x\n",
+				     DIG_Dynamic_MIN));
+			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD,
+				     ("odm_DIG() : pDM_Odm->RSSI_Min=%d\n",
+				     pDM_Odm->RSSI_Min));
+		} else if (pDM_Odm->SupportAbility & ODM_BB_ANT_DIV) {
+			/* 1 Lower Bound for 88E AntDiv */
+			if (pDM_Odm->AntDivType == CG_TRX_HW_ANTDIV) {
+				DIG_Dynamic_MIN = (u8) pDM_DigTable->AntDiv_RSSI_max;
+				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD,
+					     ("odm_DIG(): pDM_DigTable->AntDiv_RSSI_max=%d\n",
+					     pDM_DigTable->AntDiv_RSSI_max));
 			}
+		} else {
+			DIG_Dynamic_MIN = dm_dig_min;
 		}
 	} else {
 		pDM_DigTable->rx_gain_range_max = dm_dig_max;
@@ -807,21 +744,12 @@ void odm_DIG(struct odm_dm_struct *pDM_Odm)
 			CurrentIGI = pDM_Odm->RSSI_Min;
 			ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("DIG: First Connect\n"));
 		} else {
-			if (pDM_Odm->SupportICType == ODM_RTL8192D) {
-				if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH2_92D)
-					CurrentIGI = CurrentIGI + 2;/* pDM_DigTable->CurIGValue = pDM_DigTable->PreIGValue+2; */
-				else if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH1_92D)
-					CurrentIGI = CurrentIGI + 1; /* pDM_DigTable->CurIGValue = pDM_DigTable->PreIGValue+1; */
-				else if (pFalseAlmCnt->Cnt_all < DM_DIG_FA_TH0_92D)
-					CurrentIGI = CurrentIGI - 1;/* pDM_DigTable->CurIGValue =pDM_DigTable->PreIGValue-1; */
-			} else {
-				if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH2)
-						CurrentIGI = CurrentIGI + 4;/* pDM_DigTable->CurIGValue = pDM_DigTable->PreIGValue+2; */
-				else if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH1)
-						CurrentIGI = CurrentIGI + 2;/* pDM_DigTable->CurIGValue = pDM_DigTable->PreIGValue+1; */
-				else if (pFalseAlmCnt->Cnt_all < DM_DIG_FA_TH0)
-						CurrentIGI = CurrentIGI - 2;/* pDM_DigTable->CurIGValue =pDM_DigTable->PreIGValue-1; */
-			}
+			if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH2)
+				CurrentIGI = CurrentIGI + 4;/* pDM_DigTable->CurIGValue = pDM_DigTable->PreIGValue+2; */
+			else if (pFalseAlmCnt->Cnt_all > DM_DIG_FA_TH1)
+				CurrentIGI = CurrentIGI + 2;/* pDM_DigTable->CurIGValue = pDM_DigTable->PreIGValue+1; */
+			else if (pFalseAlmCnt->Cnt_all < DM_DIG_FA_TH0)
+				CurrentIGI = CurrentIGI - 2;/* pDM_DigTable->CurIGValue =pDM_DigTable->PreIGValue-1; */
 		}
 	} else {
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("odm_DIG(): DIG BeforeLink\n"));
@@ -872,96 +800,62 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 	if (!(pDM_Odm->SupportAbility & ODM_BB_FA_CNT))
 		return;
 
-	if (pDM_Odm->SupportICType & ODM_IC_11N_SERIES) {
-		/* hold ofdm counter */
-		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 1); /* hold page C counter */
-		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 1); /* hold page D counter */
-
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE1_11N, bMaskDWord);
-		FalseAlmCnt->Cnt_Fast_Fsync = (ret_value&0xffff);
-		FalseAlmCnt->Cnt_SB_Search_fail = ((ret_value&0xffff0000)>>16);
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE2_11N, bMaskDWord);
-		FalseAlmCnt->Cnt_OFDM_CCA = (ret_value&0xffff);
-		FalseAlmCnt->Cnt_Parity_Fail = ((ret_value&0xffff0000)>>16);
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE3_11N, bMaskDWord);
-		FalseAlmCnt->Cnt_Rate_Illegal = (ret_value&0xffff);
-		FalseAlmCnt->Cnt_Crc8_fail = ((ret_value&0xffff0000)>>16);
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE4_11N, bMaskDWord);
-		FalseAlmCnt->Cnt_Mcs_fail = (ret_value&0xffff);
-
-		FalseAlmCnt->Cnt_Ofdm_fail = FalseAlmCnt->Cnt_Parity_Fail + FalseAlmCnt->Cnt_Rate_Illegal +
-					     FalseAlmCnt->Cnt_Crc8_fail + FalseAlmCnt->Cnt_Mcs_fail +
-					     FalseAlmCnt->Cnt_Fast_Fsync + FalseAlmCnt->Cnt_SB_Search_fail;
-
-		if (pDM_Odm->SupportICType == ODM_RTL8188E) {
-			ret_value = PHY_QueryBBReg(adapter, ODM_REG_SC_CNT_11N, bMaskDWord);
-			FalseAlmCnt->Cnt_BW_LSC = (ret_value&0xffff);
-			FalseAlmCnt->Cnt_BW_USC = ((ret_value&0xffff0000)>>16);
-		}
-
-		/* hold cck counter */
-		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT12, 1);
-		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT14, 1);
-
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_LSB_11N, bMaskByte0);
-		FalseAlmCnt->Cnt_Cck_fail = ret_value;
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_MSB_11N, bMaskByte3);
-		FalseAlmCnt->Cnt_Cck_fail +=  (ret_value & 0xff)<<8;
-
-		ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_CCA_CNT_11N, bMaskDWord);
-		FalseAlmCnt->Cnt_CCK_CCA = ((ret_value&0xFF)<<8) | ((ret_value&0xFF00)>>8);
-
-		FalseAlmCnt->Cnt_all = (FalseAlmCnt->Cnt_Fast_Fsync +
-					FalseAlmCnt->Cnt_SB_Search_fail +
-					FalseAlmCnt->Cnt_Parity_Fail +
-					FalseAlmCnt->Cnt_Rate_Illegal +
-					FalseAlmCnt->Cnt_Crc8_fail +
-					FalseAlmCnt->Cnt_Mcs_fail +
-					FalseAlmCnt->Cnt_Cck_fail);
-
-		FalseAlmCnt->Cnt_CCA_all = FalseAlmCnt->Cnt_OFDM_CCA + FalseAlmCnt->Cnt_CCK_CCA;
-
-		if (pDM_Odm->SupportICType >= ODM_RTL8723A) {
-			/* reset false alarm counter registers */
-			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 1);
-			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTC_11N, BIT31, 0);
-			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 1);
-			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT27, 0);
-			/* update ofdm counter */
-			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 0); /* update page C counter */
-			PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 0); /* update page D counter */
-
-			/* reset CCK CCA counter */
-			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 0);
-			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT13|BIT12, 2);
-			/* reset CCK FA counter */
-			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 0);
-			PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT15|BIT14, 2);
-		}
-
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Enter odm_FalseAlarmCounterStatistics\n"));
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD,
-			     ("Cnt_Fast_Fsync=%d, Cnt_SB_Search_fail=%d\n",
-			     FalseAlmCnt->Cnt_Fast_Fsync, FalseAlmCnt->Cnt_SB_Search_fail));
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD,
-			     ("Cnt_Parity_Fail=%d, Cnt_Rate_Illegal=%d\n",
-			     FalseAlmCnt->Cnt_Parity_Fail, FalseAlmCnt->Cnt_Rate_Illegal));
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD,
-			     ("Cnt_Crc8_fail=%d, Cnt_Mcs_fail=%d\n",
-			     FalseAlmCnt->Cnt_Crc8_fail, FalseAlmCnt->Cnt_Mcs_fail));
-	} else { /* FOR ODM_IC_11AC_SERIES */
-		/* read OFDM FA counter */
-		FalseAlmCnt->Cnt_Ofdm_fail = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_11AC, bMaskLWord);
-		FalseAlmCnt->Cnt_Cck_fail = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_11AC, bMaskLWord);
-		FalseAlmCnt->Cnt_all = FalseAlmCnt->Cnt_Ofdm_fail + FalseAlmCnt->Cnt_Cck_fail;
-
-		/*  reset OFDM FA coutner */
-		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RST_11AC, BIT17, 1);
-		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RST_11AC, BIT17, 0);
-		/*  reset CCK FA counter */
-		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11AC, BIT15, 0);
-		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11AC, BIT15, 1);
-	}
+	/* hold ofdm counter */
+	PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 1); /* hold page C counter */
+	PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 1); /* hold page D counter */
+
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE1_11N, bMaskDWord);
+	FalseAlmCnt->Cnt_Fast_Fsync = (ret_value&0xffff);
+	FalseAlmCnt->Cnt_SB_Search_fail = ((ret_value&0xffff0000)>>16);
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE2_11N, bMaskDWord);
+	FalseAlmCnt->Cnt_OFDM_CCA = (ret_value&0xffff);
+	FalseAlmCnt->Cnt_Parity_Fail = ((ret_value&0xffff0000)>>16);
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE3_11N, bMaskDWord);
+	FalseAlmCnt->Cnt_Rate_Illegal = (ret_value&0xffff);
+	FalseAlmCnt->Cnt_Crc8_fail = ((ret_value&0xffff0000)>>16);
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE4_11N, bMaskDWord);
+	FalseAlmCnt->Cnt_Mcs_fail = (ret_value&0xffff);
+
+	FalseAlmCnt->Cnt_Ofdm_fail = FalseAlmCnt->Cnt_Parity_Fail + FalseAlmCnt->Cnt_Rate_Illegal +
+				     FalseAlmCnt->Cnt_Crc8_fail + FalseAlmCnt->Cnt_Mcs_fail +
+				     FalseAlmCnt->Cnt_Fast_Fsync + FalseAlmCnt->Cnt_SB_Search_fail;
+
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_SC_CNT_11N, bMaskDWord);
+	FalseAlmCnt->Cnt_BW_LSC = (ret_value&0xffff);
+	FalseAlmCnt->Cnt_BW_USC = ((ret_value&0xffff0000)>>16);
+
+	/* hold cck counter */
+	PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT12, 1);
+	PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT14, 1);
+
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_LSB_11N, bMaskByte0);
+	FalseAlmCnt->Cnt_Cck_fail = ret_value;
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_MSB_11N, bMaskByte3);
+	FalseAlmCnt->Cnt_Cck_fail +=  (ret_value & 0xff)<<8;
+
+	ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_CCA_CNT_11N, bMaskDWord);
+	FalseAlmCnt->Cnt_CCK_CCA = ((ret_value&0xFF)<<8) | ((ret_value&0xFF00)>>8);
+
+	FalseAlmCnt->Cnt_all = (FalseAlmCnt->Cnt_Fast_Fsync +
+				FalseAlmCnt->Cnt_SB_Search_fail +
+				FalseAlmCnt->Cnt_Parity_Fail +
+				FalseAlmCnt->Cnt_Rate_Illegal +
+				FalseAlmCnt->Cnt_Crc8_fail +
+				FalseAlmCnt->Cnt_Mcs_fail +
+				FalseAlmCnt->Cnt_Cck_fail);
+
+	FalseAlmCnt->Cnt_CCA_all = FalseAlmCnt->Cnt_OFDM_CCA + FalseAlmCnt->Cnt_CCK_CCA;
+
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Enter odm_FalseAlarmCounterStatistics\n"));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD,
+		     ("Cnt_Fast_Fsync=%d, Cnt_SB_Search_fail=%d\n",
+		     FalseAlmCnt->Cnt_Fast_Fsync, FalseAlmCnt->Cnt_SB_Search_fail));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD,
+		     ("Cnt_Parity_Fail=%d, Cnt_Rate_Illegal=%d\n",
+		     FalseAlmCnt->Cnt_Parity_Fail, FalseAlmCnt->Cnt_Rate_Illegal));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD,
+		     ("Cnt_Crc8_fail=%d, Cnt_Mcs_fail=%d\n",
+		     FalseAlmCnt->Cnt_Crc8_fail, FalseAlmCnt->Cnt_Mcs_fail));
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Cck_fail=%d\n", FalseAlmCnt->Cnt_Cck_fail));
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Cnt_Ofdm_fail=%d\n", FalseAlmCnt->Cnt_Ofdm_fail));
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_FA_CNT, ODM_DBG_LOUD, ("Total False Alarm=%d\n", FalseAlmCnt->Cnt_all));
@@ -1027,20 +921,6 @@ void odm_DynamicBBPowerSavingInit(struct odm_dm_struct *pDM_Odm)
 
 void odm_DynamicBBPowerSaving(struct odm_dm_struct *pDM_Odm)
 {
-	if ((pDM_Odm->SupportICType != ODM_RTL8192C) && (pDM_Odm->SupportICType != ODM_RTL8723A))
-		return;
-	if (!(pDM_Odm->SupportAbility & ODM_BB_PWR_SAVE))
-		return;
-
-	/* 1 2.Power Saving for 92C */
-	if ((pDM_Odm->SupportICType == ODM_RTL8192C) && (pDM_Odm->RFType == ODM_2T2R)) {
-		odm_1R_CCA(pDM_Odm);
-	} else {
-	/*  20100628 Joseph: Turn off BB power save for 88CE because it makesthroughput unstable. */
-	/*  20100831 Joseph: Turn ON BB power save again after modifying AGC delay from 900ns ot 600ns. */
-	/* 1 3.Power Saving for 88C */
-		ODM_RF_Saving(pDM_Odm, false);
-	}
 }
 
 void odm_1R_CCA(struct odm_dm_struct *pDM_Odm)
@@ -1118,10 +998,6 @@ void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal)
 
 	if (pDM_PSTable->PreRFState != pDM_PSTable->CurRFState) {
 		if (pDM_PSTable->CurRFState == RF_Save) {
-			/*  <tynli_note> 8723 RSSI report will be wrong. Set 0x874[5]=1 when enter BB power saving mode. */
-			/*  Suggested by SD3 Yu-Nan. 2011.01.20. */
-			if (pDM_Odm->SupportICType == ODM_RTL8723A)
-				PHY_SetBBReg(adapter, 0x874  , BIT5, 0x1); /* Reg874[5]=1b'1 */
 			PHY_SetBBReg(adapter, 0x874  , 0x1C0000, 0x2); /* Reg874[20:18]=3'b010 */
 			PHY_SetBBReg(adapter, 0xc70, BIT3, 0); /* RegC70[3]=1'b0 */
 			PHY_SetBBReg(adapter, 0x85c, 0xFF000000, 0x63); /* Reg85C[31:24]=0x63 */
@@ -1135,9 +1011,6 @@ void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal)
 			PHY_SetBBReg(adapter, 0x85c, 0xFF000000, pDM_PSTable->Reg85C);
 			PHY_SetBBReg(adapter, 0xa74, 0xF000, pDM_PSTable->RegA74);
 			PHY_SetBBReg(adapter, 0x818, BIT28, 0x0);
-
-			if (pDM_Odm->SupportICType == ODM_RTL8723A)
-				PHY_SetBBReg(adapter, 0x874, BIT5, 0x0); /* Reg874[5]=1b'0 */
 		}
 		pDM_PSTable->PreRFState = pDM_PSTable->CurRFState;
 	}
@@ -1384,13 +1257,6 @@ void odm_DynamicTxPower(struct odm_dm_struct *pDM_Odm)
 
 void odm_DynamicTxPowerNIC(struct odm_dm_struct *pDM_Odm)
 {
-	if (!(pDM_Odm->SupportAbility & ODM_BB_DYNAMIC_TXPWR))
-		return;
-
-	if (pDM_Odm->SupportICType == ODM_RTL8188E) {
-		/*  ??? */
-		/*  This part need to be redefined. */
-	}
 }
 
 /* 3============================================================ */
@@ -1567,10 +1433,7 @@ void odm_InitHybridAntDiv(struct odm_dm_struct *pDM_Odm)
 		return;
 	}
 
-	if (pDM_Odm->SupportICType & (ODM_RTL8192C | ODM_RTL8192D))
-		;
-	else if (pDM_Odm->SupportICType == ODM_RTL8188E)
-		ODM_AntennaDiversityInit_88E(pDM_Odm);
+	ODM_AntennaDiversityInit_88E(pDM_Odm);
 }
 
 void ODM_AntselStatistics_88C(struct odm_dm_struct *pDM_Odm, u8 MacId, u32 PWDBAll, bool isCCKrate)
@@ -1601,8 +1464,7 @@ void odm_HwAntDiv(struct odm_dm_struct *pDM_Odm)
 		return;
 	}
 
-	if (pDM_Odm->SupportICType == ODM_RTL8188E)
-		ODM_AntennaDiversity_88E(pDM_Odm);
+	ODM_AntennaDiversity_88E(pDM_Odm);
 }
 
 /* EDCA Turbo */
@@ -1766,252 +1628,3 @@ void ODM_SingleDualAntennaDefaultSetting(struct odm_dm_struct *pDM_Odm)
 	pDM_SWAT_Table->ANTA_ON = true;
 	pDM_SWAT_Table->ANTB_ON = true;
 }
-
-
-/* 2 8723A ANT DETECT */
-
-static void odm_PHY_SaveAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg, u32 *AFEBackup, u32 RegisterNum)
-{
-	struct adapter *adapter = pDM_Odm->Adapter;
-	u32 i;
-
-	/* RTPRINT(FINIT, INIT_IQK, ("Save ADDA parameters.\n")); */
-	for (i = 0; i < RegisterNum; i++)
-		AFEBackup[i] = PHY_QueryBBReg(adapter, AFEReg[i], bMaskDWord);
-}
-
-static void odm_PHY_ReloadAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg, u32 *AFEBackup, u32 RegiesterNum)
-{
-	struct adapter *adapter = pDM_Odm->Adapter;
-	u32 i;
-
-	for (i = 0; i < RegiesterNum; i++)
-		PHY_SetBBReg(adapter, AFEReg[i], bMaskDWord, AFEBackup[i]);
-}
-
-/* 2 8723A ANT DETECT */
-/*  Description: */
-/* 	Implement IQK single tone for RF DPK loopback and BB PSD scanning. */
-/* 	This function is cooperated with BB team Neil. */
-bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
-{
-	struct adapter *adapter = pDM_Odm->Adapter;
-	struct sw_ant_switch *pDM_SWAT_Table = &pDM_Odm->DM_SWAT_Table;
-	u32 CurrentChannel, RfLoopReg;
-	u8 n;
-	u32 Reg88c, Regc08, Reg874, Regc50;
-	u8 initial_gain = 0x5a;
-	u32 PSD_report_tmp;
-	u32 AntA_report = 0x0, AntB_report = 0x0, AntO_report = 0x0;
-	bool bResult = true;
-	u32 AFE_Backup[16];
-	u32 AFE_REG_8723A[16] = {
-		rRx_Wait_CCA, rTx_CCK_RFON,
-		rTx_CCK_BBON, rTx_OFDM_RFON,
-		rTx_OFDM_BBON, rTx_To_Rx,
-		rTx_To_Tx, rRx_CCK,
-		rRx_OFDM, rRx_Wait_RIFS,
-		rRx_TO_Rx, rStandby,
-		rSleep, rPMPD_ANAEN,
-		rFPGA0_XCD_SwitchControl, rBlue_Tooth};
-
-	if (!(pDM_Odm->SupportICType & (ODM_RTL8723A|ODM_RTL8192C)))
-		return bResult;
-
-	if (!(pDM_Odm->SupportAbility&ODM_BB_ANT_DIV))
-		return bResult;
-
-	if (pDM_Odm->SupportICType == ODM_RTL8192C) {
-		/* Which path in ADC/DAC is turnned on for PSD: both I/Q */
-		PHY_SetBBReg(adapter, 0x808, BIT10|BIT11, 0x3);
-		/* Ageraged number: 8 */
-		PHY_SetBBReg(adapter, 0x808, BIT12|BIT13, 0x1);
-		/* pts = 128; */
-		PHY_SetBBReg(adapter, 0x808, BIT14|BIT15, 0x0);
-	}
-
-	/* 1 Backup Current RF/BB Settings */
-
-	CurrentChannel = PHY_QueryRFReg(adapter, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask);
-	RfLoopReg = PHY_QueryRFReg(adapter, RF_PATH_A, 0x00, bRFRegOffsetMask);
-	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, ODM_DPDT, Antenna_A);  /*  change to Antenna A */
-	/*  Step 1: USE IQK to transmitter single tone */
-
-	udelay(10);
-
-	/* Store A Path Register 88c, c08, 874, c50 */
-	Reg88c = PHY_QueryBBReg(adapter, rFPGA0_AnalogParameter4, bMaskDWord);
-	Regc08 = PHY_QueryBBReg(adapter, rOFDM0_TRMuxPar, bMaskDWord);
-	Reg874 = PHY_QueryBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord);
-	Regc50 = PHY_QueryBBReg(adapter, rOFDM0_XAAGCCore1, bMaskDWord);
-
-	/*  Store AFE Registers */
-	odm_PHY_SaveAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
-
-	/* Set PSD 128 pts */
-	PHY_SetBBReg(adapter, rFPGA0_PSDFunction, BIT14|BIT15, 0x0);  /* 128 pts */
-
-	/*  To SET CH1 to do */
-	PHY_SetRFReg(adapter, RF_PATH_A, ODM_CHANNEL, bRFRegOffsetMask, 0x01);     /* Channel 1 */
-
-	/*  AFE all on step */
-	PHY_SetBBReg(adapter, rRx_Wait_CCA, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rTx_CCK_RFON, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rTx_CCK_BBON, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rTx_OFDM_RFON, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rTx_OFDM_BBON, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rTx_To_Rx, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rTx_To_Tx, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rRx_CCK, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rRx_OFDM, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rRx_Wait_RIFS, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rRx_TO_Rx, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rStandby, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rSleep, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rPMPD_ANAEN, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rFPGA0_XCD_SwitchControl, bMaskDWord, 0x6FDB25A4);
-	PHY_SetBBReg(adapter, rBlue_Tooth, bMaskDWord, 0x6FDB25A4);
-
-	/*  3 wire Disable */
-	PHY_SetBBReg(adapter, rFPGA0_AnalogParameter4, bMaskDWord, 0xCCF000C0);
-
-	/* BB IQK Setting */
-	PHY_SetBBReg(adapter, rOFDM0_TRMuxPar, bMaskDWord, 0x000800E4);
-	PHY_SetBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, 0x22208000);
-
-	/* IQK setting tone@ 4.34Mhz */
-	PHY_SetBBReg(adapter, rTx_IQK_Tone_A, bMaskDWord, 0x10008C1C);
-	PHY_SetBBReg(adapter, rTx_IQK, bMaskDWord, 0x01007c00);
-
-
-	/* Page B init */
-	PHY_SetBBReg(adapter, rConfig_AntA, bMaskDWord, 0x00080000);
-	PHY_SetBBReg(adapter, rConfig_AntA, bMaskDWord, 0x0f600000);
-	PHY_SetBBReg(adapter, rRx_IQK, bMaskDWord, 0x01004800);
-	PHY_SetBBReg(adapter, rRx_IQK_Tone_A, bMaskDWord, 0x10008c1f);
-	PHY_SetBBReg(adapter, rTx_IQK_PI_A, bMaskDWord, 0x82150008);
-	PHY_SetBBReg(adapter, rRx_IQK_PI_A, bMaskDWord, 0x28150008);
-	PHY_SetBBReg(adapter, rIQK_AGC_Rsp, bMaskDWord, 0x001028d0);
-
-	/* RF loop Setting */
-	PHY_SetRFReg(adapter, RF_PATH_A, 0x0, 0xFFFFF, 0x50008);
-
-	/* IQK Single tone start */
-	PHY_SetBBReg(adapter, rFPGA0_IQK, bMaskDWord, 0x80800000);
-	PHY_SetBBReg(adapter, rIQK_AGC_Pts, bMaskDWord, 0xf8000000);
-	udelay(1000);
-	PSD_report_tmp = 0x0;
-
-	for (n = 0; n < 2; n++) {
-		PSD_report_tmp =  GetPSDData(pDM_Odm, 14, initial_gain);
-		if (PSD_report_tmp > AntA_report)
-			AntA_report = PSD_report_tmp;
-	}
-
-	PSD_report_tmp = 0x0;
-
-	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);  /*  change to Antenna B */
-	udelay(10);
-
-
-	for (n = 0; n < 2; n++) {
-		PSD_report_tmp =  GetPSDData(pDM_Odm, 14, initial_gain);
-		if (PSD_report_tmp > AntB_report)
-			AntB_report = PSD_report_tmp;
-	}
-
-	/*  change to open case */
-	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, 0x300, 0);  /*  change to Ant A and B all open case */
-	udelay(10);
-
-	for (n = 0; n < 2; n++) {
-		PSD_report_tmp =  GetPSDData(pDM_Odm, 14, initial_gain);
-		if (PSD_report_tmp > AntO_report)
-			AntO_report = PSD_report_tmp;
-	}
-
-	/* Close IQK Single Tone function */
-	PHY_SetBBReg(adapter, rFPGA0_IQK, bMaskDWord, 0x00000000);
-	PSD_report_tmp = 0x0;
-
-	/* 1 Return to antanna A */
-	PHY_SetBBReg(adapter, rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
-	PHY_SetBBReg(adapter, rFPGA0_AnalogParameter4, bMaskDWord, Reg88c);
-	PHY_SetBBReg(adapter, rOFDM0_TRMuxPar, bMaskDWord, Regc08);
-	PHY_SetBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord, Reg874);
-	PHY_SetBBReg(adapter, rOFDM0_XAAGCCore1, 0x7F, 0x40);
-	PHY_SetBBReg(adapter, rOFDM0_XAAGCCore1, bMaskDWord, Regc50);
-	PHY_SetRFReg(adapter, RF_PATH_A, RF_CHNLBW, bRFRegOffsetMask, CurrentChannel);
-	PHY_SetRFReg(adapter, RF_PATH_A, 0x00, bRFRegOffsetMask, RfLoopReg);
-
-	/* Reload AFE Registers */
-	odm_PHY_ReloadAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
-
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("psd_report_A[%d]= %d\n", 2416, AntA_report));
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("psd_report_B[%d]= %d\n", 2416, AntB_report));
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("psd_report_O[%d]= %d\n", 2416, AntO_report));
-
-
-	if (pDM_Odm->SupportICType == ODM_RTL8723A) {
-	/* 2 Test Ant B based on Ant A is ON */
-		if (mode == ANTTESTB) {
-			if (AntA_report >= 100) {
-				if (AntB_report > (AntA_report+1)) {
-					pDM_SWAT_Table->ANTB_ON = false;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Single Antenna A\n"));
-				} else {
-					pDM_SWAT_Table->ANTB_ON = true;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Dual Antenna is A and B\n"));
-				}
-			} else {
-				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Need to check again\n"));
-				pDM_SWAT_Table->ANTB_ON = false; /*  Set Antenna B off as default */
-				bResult = false;
-			}
-		} else if (mode == ANTTESTALL) {
-			/* 2 Test Ant A and B based on DPDT Open */
-			if ((AntO_report >= 100)&(AntO_report < 118)) {
-				if (AntA_report > (AntO_report+1)) {
-					pDM_SWAT_Table->ANTA_ON = false;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant A is OFF"));
-				} else {
-					pDM_SWAT_Table->ANTA_ON = true;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant A is ON"));
-				}
-
-				if (AntB_report > (AntO_report+2)) {
-					pDM_SWAT_Table->ANTB_ON = false;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant B is OFF"));
-				} else {
-					pDM_SWAT_Table->ANTB_ON = true;
-					ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("Ant B is ON"));
-				}
-			}
-		}
-	} else if (pDM_Odm->SupportICType == ODM_RTL8192C) {
-		if (AntA_report >= 100) {
-			if (AntB_report > (AntA_report+2)) {
-				pDM_SWAT_Table->ANTA_ON = false;
-				pDM_SWAT_Table->ANTB_ON = true;
-				PHY_SetBBReg(adapter,  rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_B);
-				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Single Antenna B\n"));
-			} else if (AntA_report > (AntB_report+2)) {
-				pDM_SWAT_Table->ANTA_ON = true;
-				pDM_SWAT_Table->ANTB_ON = false;
-				PHY_SetBBReg(adapter,  rFPGA0_XA_RFInterfaceOE, 0x300, Antenna_A);
-				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Single Antenna A\n"));
-			} else {
-				pDM_SWAT_Table->ANTA_ON = true;
-				pDM_SWAT_Table->ANTB_ON = true;
-				ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD,
-					     ("ODM_SingleDualAntennaDetection(): Dual Antenna\n"));
-			}
-		} else {
-			ODM_RT_TRACE(pDM_Odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_SingleDualAntennaDetection(): Need to check again\n"));
-			pDM_SWAT_Table->ANTA_ON = true; /*  Set Antenna A on as default */
-			pDM_SWAT_Table->ANTB_ON = false; /*  Set Antenna B off as default */
-			bResult = false;
-		}
-	}
-	return bResult;
-}
diff --git a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
index f4820ba..42f07ce 100644
--- a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
+++ b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
@@ -113,7 +113,6 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 	pPhyInfo->RxMIMOSignalQuality[ODM_RF_PATH_B] = -1;
 
 	if (isCCKrate) {
-		u8 report;
 		u8 cck_agc_rpt;
 
 		dm_odm->PhyDbgInfo.NumQryPhyStatusCCK++;
@@ -127,113 +126,51 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 		/* 2011.11.28 LukeLee: 88E use different LNA & VGA gain table */
 		/* The RSSI formula should be modified according to the gain table */
 		/* In 88E, cck_highpwr is always set to 1 */
-		if (dm_odm->SupportICType & (ODM_RTL8188E|ODM_RTL8812)) {
-			LNA_idx = ((cck_agc_rpt & 0xE0) >> 5);
-			VGA_idx = (cck_agc_rpt & 0x1F);
-			switch (LNA_idx) {
-			case 7:
-				if (VGA_idx <= 27)
-					rx_pwr_all = -100 + 2*(27-VGA_idx); /* VGA_idx = 27~2 */
-				else
-					rx_pwr_all = -100;
-				break;
-			case 6:
-				rx_pwr_all = -48 + 2*(2-VGA_idx); /* VGA_idx = 2~0 */
-				break;
-			case 5:
-				rx_pwr_all = -42 + 2*(7-VGA_idx); /* VGA_idx = 7~5 */
-				break;
-			case 4:
-				rx_pwr_all = -36 + 2*(7-VGA_idx); /* VGA_idx = 7~4 */
-				break;
-			case 3:
-				rx_pwr_all = -24 + 2*(7-VGA_idx); /* VGA_idx = 7~0 */
-				break;
-			case 2:
-				if (cck_highpwr)
-					rx_pwr_all = -12 + 2*(5-VGA_idx); /* VGA_idx = 5~0 */
-				else
-					rx_pwr_all = -6 + 2*(5-VGA_idx);
-				break;
-			case 1:
-					rx_pwr_all = 8-2*VGA_idx;
-				break;
-			case 0:
-					rx_pwr_all = 14-2*VGA_idx;
-				break;
-			default:
-				break;
-			}
-			rx_pwr_all += 6;
-			PWDB_ALL = odm_QueryRxPwrPercentage(rx_pwr_all);
-			if (!cck_highpwr) {
-				if (PWDB_ALL >= 80)
-					PWDB_ALL = ((PWDB_ALL-80)<<1)+((PWDB_ALL-80)>>1)+80;
-				else if ((PWDB_ALL <= 78) && (PWDB_ALL >= 20))
-					PWDB_ALL += 3;
-				if (PWDB_ALL > 100)
-					PWDB_ALL = 100;
-			}
-		} else {
-			if (!cck_highpwr) {
-				report = (cck_agc_rpt & 0xc0)>>6;
-				switch (report) {
-				/*  03312009 modified by cosa */
-				/*  Modify the RF RNA gain value to -40, -20, -2, 14 by Jenyu's suggestion */
-				/*  Note: different RF with the different RNA gain. */
-				case 0x3:
-					rx_pwr_all = -46 - (cck_agc_rpt & 0x3e);
-					break;
-				case 0x2:
-					rx_pwr_all = -26 - (cck_agc_rpt & 0x3e);
-					break;
-				case 0x1:
-					rx_pwr_all = -12 - (cck_agc_rpt & 0x3e);
-					break;
-				case 0x0:
-					rx_pwr_all = 16 - (cck_agc_rpt & 0x3e);
-					break;
-				}
-			} else {
-				report = (cck_agc_rpt & 0x60)>>5;
-				switch (report) {
-				case 0x3:
-					rx_pwr_all = -46 - ((cck_agc_rpt & 0x1f)<<1) ;
-					break;
-				case 0x2:
-					rx_pwr_all = -26 - ((cck_agc_rpt & 0x1f)<<1);
-					break;
-				case 0x1:
-					rx_pwr_all = -12 - ((cck_agc_rpt & 0x1f)<<1);
-					break;
-				case 0x0:
-					rx_pwr_all = 16 - ((cck_agc_rpt & 0x1f)<<1);
-					break;
-				}
-			}
-
-			PWDB_ALL = odm_QueryRxPwrPercentage(rx_pwr_all);
-
-			/* Modification for ext-LNA board */
-			if (dm_odm->BoardType == ODM_BOARD_HIGHPWR) {
-				if ((cck_agc_rpt>>7) == 0) {
-					PWDB_ALL = (PWDB_ALL > 94) ? 100 : (PWDB_ALL+6);
-				} else {
-					if (PWDB_ALL > 38)
-						PWDB_ALL -= 16;
-					else
-						PWDB_ALL = (PWDB_ALL <= 16) ? (PWDB_ALL>>2) : (PWDB_ALL-12);
-				}
-
-				/* CCK modification */
-				if (PWDB_ALL > 25 && PWDB_ALL <= 60)
-					PWDB_ALL += 6;
-			} else {/* Modification for int-LNA board */
-				if (PWDB_ALL > 99)
-					PWDB_ALL -= 8;
-				else if (PWDB_ALL > 50 && PWDB_ALL <= 68)
-					PWDB_ALL += 4;
-			}
+		LNA_idx = ((cck_agc_rpt & 0xE0) >> 5);
+		VGA_idx = (cck_agc_rpt & 0x1F);
+		switch (LNA_idx) {
+		case 7:
+			if (VGA_idx <= 27)
+				rx_pwr_all = -100 + 2*(27-VGA_idx); /* VGA_idx = 27~2 */
+			else
+				rx_pwr_all = -100;
+			break;
+		case 6:
+			rx_pwr_all = -48 + 2*(2-VGA_idx); /* VGA_idx = 2~0 */
+			break;
+		case 5:
+			rx_pwr_all = -42 + 2*(7-VGA_idx); /* VGA_idx = 7~5 */
+			break;
+		case 4:
+			rx_pwr_all = -36 + 2*(7-VGA_idx); /* VGA_idx = 7~4 */
+			break;
+		case 3:
+			rx_pwr_all = -24 + 2*(7-VGA_idx); /* VGA_idx = 7~0 */
+			break;
+		case 2:
+			if (cck_highpwr)
+				rx_pwr_all = -12 + 2*(5-VGA_idx); /* VGA_idx = 5~0 */
+			else
+				rx_pwr_all = -6 + 2*(5-VGA_idx);
+			break;
+		case 1:
+			rx_pwr_all = 8-2*VGA_idx;
+			break;
+		case 0:
+			rx_pwr_all = 14-2*VGA_idx;
+			break;
+		default:
+			break;
+		}
+		rx_pwr_all += 6;
+		PWDB_ALL = odm_QueryRxPwrPercentage(rx_pwr_all);
+		if (!cck_highpwr) {
+			if (PWDB_ALL >= 80)
+				PWDB_ALL = ((PWDB_ALL-80)<<1)+((PWDB_ALL-80)>>1)+80;
+			else if ((PWDB_ALL <= 78) && (PWDB_ALL >= 20))
+				PWDB_ALL += 3;
+			if (PWDB_ALL > 100)
+				PWDB_ALL = 100;
 		}
 
 		pPhyInfo->RxPWDBAll = PWDB_ALL;
@@ -356,6 +293,8 @@ static void odm_Process_RSSIForDM(struct odm_dm_struct *dm_odm,
 	u32 OFDM_pkt = 0;
 	u32 Weighting = 0;
 	struct sta_info *pEntry;
+	u8 antsel_tr_mux;
+	struct fast_ant_train *pDM_FatTable = &dm_odm->DM_FatTable;
 
 	if (pPktinfo->StationID == 0xFF)
 		return;
@@ -368,27 +307,23 @@ static void odm_Process_RSSIForDM(struct odm_dm_struct *dm_odm,
 	isCCKrate = ((pPktinfo->Rate >= DESC92C_RATE1M) && (pPktinfo->Rate <= DESC92C_RATE11M)) ? true : false;
 
 	/* Smart Antenna Debug Message------------------  */
-	if (dm_odm->SupportICType == ODM_RTL8188E) {
-		u8 antsel_tr_mux;
-		struct fast_ant_train *pDM_FatTable = &dm_odm->DM_FatTable;
-
-		if (dm_odm->AntDivType == CG_TRX_SMART_ANTDIV) {
-			if (pDM_FatTable->FAT_State == FAT_TRAINING_STATE) {
-				if (pPktinfo->bPacketToSelf) {
-					antsel_tr_mux = (pDM_FatTable->antsel_rx_keep_2<<2) |
-							(pDM_FatTable->antsel_rx_keep_1<<1) |
-							pDM_FatTable->antsel_rx_keep_0;
-					pDM_FatTable->antSumRSSI[antsel_tr_mux] += pPhyInfo->RxPWDBAll;
-					pDM_FatTable->antRSSIcnt[antsel_tr_mux]++;
-				}
-			}
-		} else if ((dm_odm->AntDivType == CG_TRX_HW_ANTDIV) || (dm_odm->AntDivType == CGCS_RX_HW_ANTDIV)) {
-			if (pPktinfo->bPacketToSelf || pPktinfo->bPacketBeacon) {
+
+	if (dm_odm->AntDivType == CG_TRX_SMART_ANTDIV) {
+		if (pDM_FatTable->FAT_State == FAT_TRAINING_STATE) {
+			if (pPktinfo->bPacketToSelf) {
 				antsel_tr_mux = (pDM_FatTable->antsel_rx_keep_2<<2) |
-						(pDM_FatTable->antsel_rx_keep_1<<1) | pDM_FatTable->antsel_rx_keep_0;
-				ODM_AntselStatistics_88E(dm_odm, antsel_tr_mux, pPktinfo->StationID, pPhyInfo->RxPWDBAll);
+						(pDM_FatTable->antsel_rx_keep_1<<1) |
+						pDM_FatTable->antsel_rx_keep_0;
+				pDM_FatTable->antSumRSSI[antsel_tr_mux] += pPhyInfo->RxPWDBAll;
+				pDM_FatTable->antRSSIcnt[antsel_tr_mux]++;
 			}
 		}
+	} else if ((dm_odm->AntDivType == CG_TRX_HW_ANTDIV) || (dm_odm->AntDivType == CGCS_RX_HW_ANTDIV)) {
+		if (pPktinfo->bPacketToSelf || pPktinfo->bPacketBeacon) {
+			antsel_tr_mux = (pDM_FatTable->antsel_rx_keep_2<<2) |
+					(pDM_FatTable->antsel_rx_keep_1<<1) | pDM_FatTable->antsel_rx_keep_0;
+			ODM_AntselStatistics_88E(dm_odm, antsel_tr_mux, pPktinfo->StationID, pPhyInfo->RxPWDBAll);
+		}
 	}
 	/* Smart Antenna Debug Message------------------ */
 
@@ -517,12 +452,10 @@ enum HAL_STATUS ODM_ConfigRFWithHeaderFile(struct odm_dm_struct *dm_odm,
 					   enum ODM_RF_RADIO_PATH rfpath)
 {
 	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, ("===>ODM_ConfigRFWithHeaderFile\n"));
-	if (dm_odm->SupportICType == ODM_RTL8188E) {
-		if (rfpath == ODM_RF_PATH_A)
-			READ_AND_CONFIG(8188E, _RadioA_1T_);
-		ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, (" ===> ODM_ConfigRFWithHeaderFile() Radio_A:Rtl8188ERadioA_1TArray\n"));
-		ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, (" ===> ODM_ConfigRFWithHeaderFile() Radio_B:Rtl8188ERadioB_1TArray\n"));
-	}
+	if (rfpath == ODM_RF_PATH_A)
+		READ_AND_CONFIG(8188E, _RadioA_1T_);
+	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, (" ===> ODM_ConfigRFWithHeaderFile() Radio_A:Rtl8188ERadioA_1TArray\n"));
+	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, (" ===> ODM_ConfigRFWithHeaderFile() Radio_B:Rtl8188ERadioB_1TArray\n"));
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_TRACE, ("ODM_ConfigRFWithHeaderFile: Radio No %x\n", rfpath));
 	return HAL_STATUS_SUCCESS;
@@ -531,16 +464,14 @@ enum HAL_STATUS ODM_ConfigRFWithHeaderFile(struct odm_dm_struct *dm_odm,
 enum HAL_STATUS ODM_ConfigBBWithHeaderFile(struct odm_dm_struct *dm_odm,
 					   enum odm_bb_config_type config_tp)
 {
-	if (dm_odm->SupportICType == ODM_RTL8188E) {
-		if (config_tp == CONFIG_BB_PHY_REG) {
-			READ_AND_CONFIG(8188E, _PHY_REG_1T_);
-		} else if (config_tp == CONFIG_BB_AGC_TAB) {
-			READ_AND_CONFIG(8188E, _AGC_TAB_1T_);
-		} else if (config_tp == CONFIG_BB_PHY_REG_PG) {
-			READ_AND_CONFIG(8188E, _PHY_REG_PG_);
-			ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD,
-				     (" ===> phy_ConfigBBWithHeaderFile() agc:Rtl8188EPHY_REG_PGArray\n"));
-		}
+	if (config_tp == CONFIG_BB_PHY_REG) {
+		READ_AND_CONFIG(8188E, _PHY_REG_1T_);
+	} else if (config_tp == CONFIG_BB_AGC_TAB) {
+		READ_AND_CONFIG(8188E, _AGC_TAB_1T_);
+	} else if (config_tp == CONFIG_BB_PHY_REG_PG) {
+		READ_AND_CONFIG(8188E, _PHY_REG_PG_);
+		ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD,
+			     (" ===> phy_ConfigBBWithHeaderFile() agc:Rtl8188EPHY_REG_PGArray\n"));
 	}
 	return HAL_STATUS_SUCCESS;
 }
@@ -548,7 +479,6 @@ enum HAL_STATUS ODM_ConfigBBWithHeaderFile(struct odm_dm_struct *dm_odm,
 enum HAL_STATUS ODM_ConfigMACWithHeaderFile(struct odm_dm_struct *dm_odm)
 {
 	u8 result = HAL_STATUS_SUCCESS;
-	if (dm_odm->SupportICType == ODM_RTL8188E)
-		result = READ_AND_CONFIG(8188E, _MAC_REG_);
+	result = READ_AND_CONFIG(8188E, _MAC_REG_);
 	return result;
 }
diff --git a/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c b/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
index fb80afe..323eb93 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RTL8188E.c
@@ -184,9 +184,6 @@ static void odm_FastAntTrainingInit(struct odm_dm_struct *dm_odm)
 
 void ODM_AntennaDiversityInit_88E(struct odm_dm_struct *dm_odm)
 {
-	if (dm_odm->SupportICType != ODM_RTL8188E)
-		return;
-
 	ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("dm_odm->AntDivType=%d\n", dm_odm->AntDivType));
 	ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("dm_odm->bIsMPChip=%s\n", (dm_odm->bIsMPChip ? "true" : "false")));
 
@@ -349,7 +346,7 @@ void ODM_AntennaDiversity_88E(struct odm_dm_struct *dm_odm)
 	struct fast_ant_train *dm_fat_tbl = &dm_odm->DM_FatTable;
 	struct adapter *adapter = dm_odm->Adapter;
 
-	if ((dm_odm->SupportICType != ODM_RTL8188E) || (!(dm_odm->SupportAbility & ODM_BB_ANT_DIV)))
+	if (!(dm_odm->SupportAbility & ODM_BB_ANT_DIV))
 		return;
 	if (!dm_odm->bLinked) {
 		ODM_RT_TRACE(dm_odm, ODM_COMP_ANT_DIV, ODM_DBG_LOUD, ("ODM_AntennaDiversity_88E(): No Link.\n"));
diff --git a/drivers/staging/rtl8188eu/include/odm.h b/drivers/staging/rtl8188eu/include/odm.h
index f3d2773..db1d593 100644
--- a/drivers/staging/rtl8188eu/include/odm.h
+++ b/drivers/staging/rtl8188eu/include/odm.h
@@ -1183,8 +1183,6 @@ void ODM_AntselStatistics_88C(struct odm_dm_struct *pDM_Odm, u8 MacId,
 
 void ODM_SingleDualAntennaDefaultSetting(struct odm_dm_struct *pDM_Odm);
 
-bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode);
-
 void odm_dtc(struct odm_dm_struct *pDM_Odm);
 
 #endif
diff --git a/drivers/staging/rtl8188eu/include/odm_debug.h b/drivers/staging/rtl8188eu/include/odm_debug.h
index 622f4c1..c512a4e 100644
--- a/drivers/staging/rtl8188eu/include/odm_debug.h
+++ b/drivers/staging/rtl8188eu/include/odm_debug.h
@@ -94,18 +94,7 @@
 #define ODM_RT_TRACE(pDM_Odm, comp, level, fmt)				\
 	if (((comp) & pDM_Odm->DebugComponents) &&			\
 	    (level <= pDM_Odm->DebugLevel)) {				\
-		if (pDM_Odm->SupportICType == ODM_RTL8192C)		\
-			DbgPrint("[ODM-92C] ");				\
-		else if (pDM_Odm->SupportICType == ODM_RTL8192D)	\
-			DbgPrint("[ODM-92D] ");				\
-		else if (pDM_Odm->SupportICType == ODM_RTL8723A)	\
-			DbgPrint("[ODM-8723A] ");			\
-		else if (pDM_Odm->SupportICType == ODM_RTL8188E)	\
-			DbgPrint("[ODM-8188E] ");			\
-		else if (pDM_Odm->SupportICType == ODM_RTL8812)		\
-			DbgPrint("[ODM-8812] ");			\
-		else if (pDM_Odm->SupportICType == ODM_RTL8821)		\
-			DbgPrint("[ODM-8821] ");			\
+		DbgPrint("[ODM-8188E] ");				\
 		RT_PRINTK fmt;						\
 	}
 
-- 
1.8.4
