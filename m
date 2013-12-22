From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 21/31] staging: r8188eu: Simplify code concerning SupportPlatform
Date: Sun, 22 Dec 2013 17:36:52 -0600
Message-ID: <1387755422-11443-22-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33998 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756887Ab3LVXid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:33 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so4488251pdj.5
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:32 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This member of struct odm_dm_struct is always set to ODM_CE in this driver.
As a result, a number of switch and if statements can be simplified. In
addition, a number of routines are no longer used and can be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm.c          | 128 +++------------------------
 drivers/staging/rtl8188eu/hal/odm_HWConfig.c |  76 ++++------------
 2 files changed, 31 insertions(+), 173 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index f73f3af..9606db5 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -522,9 +522,6 @@ void odm_CmnInfoHook_Debug(struct odm_dm_struct *pDM_Odm)
 
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pbScanInProcess=%d\n", *(pDM_Odm->pbScanInProcess)));
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pbPowerSaving=%d\n", *(pDM_Odm->pbPowerSaving)));
-
-	if (pDM_Odm->SupportPlatform & (ODM_AP|ODM_ADSL))
-		ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("pOnePathCCA=%d\n", *(pDM_Odm->pOnePathCCA)));
 }
 
 void odm_CmnInfoUpdate_Debug(struct odm_dm_struct *pDM_Odm)
@@ -536,21 +533,6 @@ void odm_CmnInfoUpdate_Debug(struct odm_dm_struct *pDM_Odm)
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_COMMON, ODM_DBG_LOUD, ("RSSI_Min=%d\n", pDM_Odm->RSSI_Min));
 }
 
-static int getIGIForDiff(int value_IGI)
-{
-	#define ONERCCA_LOW_TH		0x30
-	#define ONERCCA_LOW_DIFF	8
-
-	if (value_IGI < ONERCCA_LOW_TH) {
-		if ((ONERCCA_LOW_TH - value_IGI) < ONERCCA_LOW_DIFF)
-			return ONERCCA_LOW_TH;
-		else
-			return value_IGI + ONERCCA_LOW_DIFF;
-	} else {
-		return value_IGI;
-	}
-}
-
 void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI)
 {
 	struct rtw_dig *pDM_DigTable = &pDM_Odm->DM_DigTable;
@@ -561,29 +543,9 @@ void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI)
 		     ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm)));
 
 	if (pDM_DigTable->CurIGValue != CurrentIGI) {
-		if (pDM_Odm->SupportPlatform & (ODM_CE|ODM_MP)) {
-			PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-				if (pDM_Odm->SupportICType != ODM_RTL8188E)
-				PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-		} else if (pDM_Odm->SupportPlatform & (ODM_AP|ODM_ADSL)) {
-			switch (*(pDM_Odm->pOnePathCCA)) {
-			case ODM_CCA_2R:
-				PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-					if (pDM_Odm->SupportICType != ODM_RTL8188E)
-					PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-				break;
-			case ODM_CCA_1R_A:
-				PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-					if (pDM_Odm->SupportICType != ODM_RTL8188E)
-					PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), getIGIForDiff(CurrentIGI));
-				break;
-			case ODM_CCA_1R_B:
-				PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), getIGIForDiff(CurrentIGI));
-					if (pDM_Odm->SupportICType != ODM_RTL8188E)
-					PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
-					break;
-				}
-		}
+		PHY_SetBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
+		if (pDM_Odm->SupportICType != ODM_RTL8188E)
+			PHY_SetBBReg(adapter, ODM_REG(IGI_B, pDM_Odm), ODM_BIT(IGI, pDM_Odm), CurrentIGI);
 		ODM_RT_TRACE(pDM_Odm, ODM_COMP_DIG, ODM_DBG_LOUD, ("CurrentIGI(0x%02x).\n", CurrentIGI));
 		/* pDM_DigTable->PreIGValue = pDM_DigTable->CurIGValue; */
 		pDM_DigTable->CurIGValue = CurrentIGI;
@@ -734,24 +696,13 @@ void odm_DIG(struct odm_dm_struct *pDM_Odm)
 	/* 1 Boundary Decision */
 	if ((pDM_Odm->SupportICType & (ODM_RTL8192C|ODM_RTL8723A)) &&
 	    ((pDM_Odm->BoardType == ODM_BOARD_HIGHPWR) || pDM_Odm->ExtLNA)) {
-		if (pDM_Odm->SupportPlatform & (ODM_AP|ODM_ADSL)) {
-			dm_dig_max = DM_DIG_MAX_AP_HP;
-			dm_dig_min = DM_DIG_MIN_AP_HP;
-		} else {
-			dm_dig_max = DM_DIG_MAX_NIC_HP;
-			dm_dig_min = DM_DIG_MIN_NIC_HP;
-		}
+		dm_dig_max = DM_DIG_MAX_NIC_HP;
+		dm_dig_min = DM_DIG_MIN_NIC_HP;
 		DIG_MaxOfMin = DM_DIG_MAX_AP_HP;
 	} else {
-		if (pDM_Odm->SupportPlatform & (ODM_AP|ODM_ADSL)) {
-			dm_dig_max = DM_DIG_MAX_AP;
-			dm_dig_min = DM_DIG_MIN_AP;
-			DIG_MaxOfMin = dm_dig_max;
-		} else {
-			dm_dig_max = DM_DIG_MAX_NIC;
-			dm_dig_min = DM_DIG_MIN_NIC;
-			DIG_MaxOfMin = DM_DIG_MAX_AP;
-		}
+		dm_dig_max = DM_DIG_MAX_NIC;
+		dm_dig_min = DM_DIG_MIN_NIC;
+		DIG_MaxOfMin = DM_DIG_MAX_AP;
 	}
 	if (pDM_Odm->bLinked) {
 	      /* 2 8723A Series, offset need to be 10 */
@@ -1080,8 +1031,6 @@ void odm_DynamicBBPowerSaving(struct odm_dm_struct *pDM_Odm)
 		return;
 	if (!(pDM_Odm->SupportAbility & ODM_BB_PWR_SAVE))
 		return;
-	if (!(pDM_Odm->SupportPlatform & (ODM_MP|ODM_CE)))
-		return;
 
 	/* 1 2.Power Saving for 92C */
 	if ((pDM_Odm->SupportICType == ODM_RTL8192C) && (pDM_Odm->RFType == ODM_2T2R)) {
@@ -1317,18 +1266,7 @@ void odm_RefreshRateAdaptiveMask(struct odm_dm_struct *pDM_Odm)
 	/*  at the same time. In the stage2/3, we need to prive universal interface and merge all */
 	/*  HW dynamic mechanism. */
 	/*  */
-	switch	(pDM_Odm->SupportPlatform) {
-	case	ODM_MP:
-		odm_RefreshRateAdaptiveMaskMP(pDM_Odm);
-		break;
-	case	ODM_CE:
-		odm_RefreshRateAdaptiveMaskCE(pDM_Odm);
-		break;
-	case	ODM_AP:
-	case	ODM_ADSL:
-		odm_RefreshRateAdaptiveMaskAPADSL(pDM_Odm);
-		break;
-	}
+	odm_RefreshRateAdaptiveMaskCE(pDM_Odm);
 }
 
 void odm_RefreshRateAdaptiveMaskMP(struct odm_dm_struct *pDM_Odm)
@@ -1441,16 +1379,7 @@ void odm_DynamicTxPower(struct odm_dm_struct *pDM_Odm)
 	/*  2011/09/29 MH In HW integration first stage, we provide 4 different handle to operate */
 	/*  at the same time. In the stage2/3, we need to prive universal interface and merge all */
 	/*  HW dynamic mechanism. */
-	switch	(pDM_Odm->SupportPlatform) {
-	case	ODM_MP:
-	case	ODM_CE:
-		odm_DynamicTxPowerNIC(pDM_Odm);
-		break;
-	case	ODM_AP:
-		break;
-	case	ODM_ADSL:
-		break;
-	}
+	odm_DynamicTxPowerNIC(pDM_Odm);
 }
 
 void odm_DynamicTxPowerNIC(struct odm_dm_struct *pDM_Odm)
@@ -1478,19 +1407,7 @@ void odm_RSSIMonitorCheck(struct odm_dm_struct *pDM_Odm)
 	/*  at the same time. In the stage2/3, we need to prive universal interface and merge all */
 	/*  HW dynamic mechanism. */
 	/*  */
-	switch	(pDM_Odm->SupportPlatform) {
-	case	ODM_MP:
-		break;
-	case	ODM_CE:
-		odm_RSSIMonitorCheckCE(pDM_Odm);
-		break;
-	case	ODM_AP:
-		break;
-	case	ODM_ADSL:
-		/* odm_DIGAP(pDM_Odm); */
-		break;
-	}
-
+	odm_RSSIMonitorCheckCE(pDM_Odm);
 }	/*  odm_RSSIMonitorCheck */
 
 static void FindMinimumRSSI(struct adapter *pAdapter)
@@ -1602,17 +1519,7 @@ void ODM_TXPowerTrackingCheck(struct odm_dm_struct *pDM_Odm)
 	/*  2011/09/29 MH In HW integration first stage, we provide 4 different handle to operate */
 	/*  at the same time. In the stage2/3, we need to prive universal interface and merge all */
 	/*  HW dynamic mechanism. */
-	switch	(pDM_Odm->SupportPlatform) {
-	case	ODM_MP:
-		break;
-	case	ODM_CE:
-		odm_TXPowerTrackingCheckCE(pDM_Odm);
-		break;
-	case	ODM_AP:
-		break;
-	case	ODM_ADSL:
-		break;
-	}
+	odm_TXPowerTrackingCheckCE(pDM_Odm);
 }
 
 void odm_TXPowerTrackingCheckCE(struct odm_dm_struct *pDM_Odm)
@@ -1722,16 +1629,7 @@ void odm_EdcaTurboCheck(struct odm_dm_struct *pDM_Odm)
 	if (!(pDM_Odm->SupportAbility & ODM_MAC_EDCA_TURBO))
 		return;
 
-	switch	(pDM_Odm->SupportPlatform) {
-	case	ODM_MP:
-		break;
-	case	ODM_CE:
-		odm_EdcaTurboCheckCE(pDM_Odm);
-		break;
-	case	ODM_AP:
-	case	ODM_ADSL:
-		break;
-	}
+	odm_EdcaTurboCheckCE(pDM_Odm);
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("<========================odm_EdcaTurboCheck\n"));
 }	/*  odm_CheckEdcaTurbo */
 
diff --git a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
index 286d262..f4820ba 100644
--- a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
+++ b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
@@ -39,16 +39,6 @@ static u8 odm_QueryRxPwrPercentage(s8 AntPower)
 
 /*  2012/01/12 MH MOve some signal strength smooth method to MP HAL layer. */
 /*  IF other SW team do not support the feature, remove this section.?? */
-static s32 odm_sig_patch_lenove(struct odm_dm_struct *dm_odm, s32 CurrSig)
-{
-	return 0;
-}
-
-static s32 odm_sig_patch_netcore(struct odm_dm_struct *dm_odm, s32 CurrSig)
-{
-	return 0;
-}
-
 static s32 odm_SignalScaleMapping_92CSeries(struct odm_dm_struct *dm_odm, s32 CurrSig)
 {
 	s32 RetSig = 0;
@@ -77,23 +67,7 @@ static s32 odm_SignalScaleMapping_92CSeries(struct odm_dm_struct *dm_odm, s32 Cu
 
 static s32 odm_SignalScaleMapping(struct odm_dm_struct *dm_odm, s32 CurrSig)
 {
-	if ((dm_odm->SupportPlatform == ODM_MP) &&
-	    (dm_odm->SupportInterface != ODM_ITRF_PCIE) && /* USB & SDIO */
-	    (dm_odm->PatchID == 10))
-		return odm_sig_patch_netcore(dm_odm, CurrSig);
-	else if ((dm_odm->SupportPlatform == ODM_MP) &&
-		 (dm_odm->SupportInterface == ODM_ITRF_PCIE) &&
-		 (dm_odm->PatchID == 19))
-		return odm_sig_patch_lenove(dm_odm, CurrSig);
-	else
-		return odm_SignalScaleMapping_92CSeries(dm_odm, CurrSig);
-}
-
-/* pMgntInfo->CustomerID == RT_CID_819x_Lenovo */
-static u8 odm_SQ_process_patch_RT_CID_819x_Lenovo(struct odm_dm_struct *dm_odm,
-	u8 isCCKrate, u8 PWDB_ALL, u8 path, u8 RSSI)
-{
-	return 0;
+	return odm_SignalScaleMapping_92CSeries(dm_odm, CurrSig);
 }
 
 static u8 odm_EVMdbToPercentage(s8 Value)
@@ -269,9 +243,7 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 		if (pPktinfo->bPacketMatchBSSID) {
 			u8 SQ, SQ_rpt;
 
-			if ((dm_odm->SupportPlatform == ODM_MP) && (dm_odm->PatchID == 19)) {
-				SQ = odm_SQ_process_patch_RT_CID_819x_Lenovo(dm_odm, isCCKrate, PWDB_ALL, 0, 0);
-			} else if (pPhyInfo->RxPWDBAll > 40 && !dm_odm->bInHctTest) {
+			if (pPhyInfo->RxPWDBAll > 40 && !dm_odm->bInHctTest) {
 				SQ = 100;
 			} else {
 				SQ_rpt = pPhyStaRpt->cck_sig_qual_ofdm_pwdb_all;
@@ -321,14 +293,6 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 			/* Get Rx snr value in DB */
 			pPhyInfo->RxSNR[i] = (s32)(pPhyStaRpt->path_rxsnr[i]/2);
 			dm_odm->PhyDbgInfo.RxSNRdB[i] = (s32)(pPhyStaRpt->path_rxsnr[i]/2);
-
-			/* Record Signal Strength for next packet */
-			if (pPktinfo->bPacketMatchBSSID) {
-				if ((dm_odm->SupportPlatform == ODM_MP) && (dm_odm->PatchID == 19)) {
-					if (i == ODM_RF_PATH_A)
-						pPhyInfo->SignalQuality = odm_SQ_process_patch_RT_CID_819x_Lenovo(dm_odm, isCCKrate, PWDB_ALL, i, RSSI);
-				}
-			}
 		}
 		/*  (2)PWDB, Average PWDB cacluated by hardware (for rate adaptive) */
 		rx_pwr_all = (((pPhyStaRpt->cck_sig_qual_ofdm_pwdb_all) >> 1) & 0x7f) - 110;
@@ -341,26 +305,22 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 		pPhyInfo->RxPower = rx_pwr_all;
 		pPhyInfo->RecvSignalPower = rx_pwr_all;
 
-		if ((dm_odm->SupportPlatform == ODM_MP) && (dm_odm->PatchID == 19)) {
-			/* do nothing */
-		} else {
-			/*  (3)EVM of HT rate */
-			if (pPktinfo->Rate >= DESC92C_RATEMCS8 && pPktinfo->Rate <= DESC92C_RATEMCS15)
-				Max_spatial_stream = 2; /* both spatial stream make sense */
-			else
-				Max_spatial_stream = 1; /* only spatial stream 1 makes sense */
-
-			for (i = 0; i < Max_spatial_stream; i++) {
-				/*  Do not use shift operation like "rx_evmX >>= 1" because the compilor of free build environment */
-				/*  fill most significant bit to "zero" when doing shifting operation which may change a negative */
-				/*  value to positive one, then the dbm value (which is supposed to be negative)  is not correct anymore. */
-				EVM = odm_EVMdbToPercentage((pPhyStaRpt->stream_rxevm[i]));	/* dbm */
-
-				if (pPktinfo->bPacketMatchBSSID) {
-					if (i == ODM_RF_PATH_A) /*  Fill value in RFD, Get the first spatial stream only */
-						pPhyInfo->SignalQuality = (u8)(EVM & 0xff);
-					pPhyInfo->RxMIMOSignalQuality[i] = (u8)(EVM & 0xff);
-				}
+		/*  (3)EVM of HT rate */
+		if (pPktinfo->Rate >= DESC92C_RATEMCS8 && pPktinfo->Rate <= DESC92C_RATEMCS15)
+			Max_spatial_stream = 2; /* both spatial stream make sense */
+		else
+			Max_spatial_stream = 1; /* only spatial stream 1 makes sense */
+
+		for (i = 0; i < Max_spatial_stream; i++) {
+			/*  Do not use shift operation like "rx_evmX >>= 1" because the compilor of free build environment */
+			/*  fill most significant bit to "zero" when doing shifting operation which may change a negative */
+			/*  value to positive one, then the dbm value (which is supposed to be negative)  is not correct anymore. */
+			EVM = odm_EVMdbToPercentage((pPhyStaRpt->stream_rxevm[i]));	/* dbm */
+
+			if (pPktinfo->bPacketMatchBSSID) {
+				if (i == ODM_RF_PATH_A) /*  Fill value in RFD, Get the first spatial stream only */
+					pPhyInfo->SignalQuality = (u8)(EVM & 0xff);
+				pPhyInfo->RxMIMOSignalQuality[i] = (u8)(EVM & 0xff);
 			}
 		}
 	}
-- 
1.8.4
