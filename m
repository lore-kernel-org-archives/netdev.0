From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/3] bnx2x: Add a fallback multi-function mode NPAR1.5
Date: Wed, 17 Sep 2014 16:24:38 +0300
Message-ID: <1410960278-32064-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1410960278-32064-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:29539 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755402AbaIQNZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 09:25:03 -0400
In-Reply-To: <1410960278-32064-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using new Multi-function modes it's possible that due to incompatible
configuration management FW will fallback into an existing mode.

Notice that at the moment this fallback is exactly the same as the already
existing switch-independent multi-function mode, but we still use existing
infrastructure to hold this information [in case some small differences will
arise in the future].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  | 17 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 45 ++++++++++++++++++------
 3 files changed, 42 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 10291df..c3a6072 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1451,6 +1451,7 @@ struct bnx2x_fp_stats {
 enum {
 	SUB_MF_MODE_UNKNOWN = 0,
 	SUB_MF_MODE_UFP,
+	SUB_MF_MODE_NPAR1_DOT_5,
 };
 
 struct bnx2x {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 3295863..583591d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -280,17 +280,11 @@ struct shared_hw_cfg {			 /* NVRAM Offset */
 		#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_BOTH          0x60000000
 		#define SHARED_HW_CFG_MDC_MDIO_ACCESS2_SWAPPED       0x80000000
 
-
-	u32 power_dissipated;			/* 0x11c */
-	#define SHARED_HW_CFG_POWER_MGNT_SCALE_MASK         0x00ff0000
-		#define SHARED_HW_CFG_POWER_MGNT_SCALE_SHIFT         16
-		#define SHARED_HW_CFG_POWER_MGNT_UNKNOWN_SCALE       0x00000000
-		#define SHARED_HW_CFG_POWER_MGNT_DOT_1_WATT          0x00010000
-		#define SHARED_HW_CFG_POWER_MGNT_DOT_01_WATT         0x00020000
-		#define SHARED_HW_CFG_POWER_MGNT_DOT_001_WATT        0x00030000
-
-	#define SHARED_HW_CFG_POWER_DIS_CMN_MASK            0xff000000
-	#define SHARED_HW_CFG_POWER_DIS_CMN_SHIFT                    24
+	u32 config_3;				/* 0x11C */
+	#define SHARED_HW_CFG_EXTENDED_MF_MODE_MASK         0x00000F00
+		#define SHARED_HW_CFG_EXTENDED_MF_MODE_SHIFT              8
+		#define SHARED_HW_CFG_EXTENDED_MF_MODE_NPAR1_DOT_5        0x00000000
+		#define SHARED_HW_CFG_EXTENDED_MF_MODE_NPAR2_DOT_0        0x00000100
 
 	u32 ump_nc_si_config;			/* 0x120 */
 	#define SHARED_HW_CFG_UMP_NC_SI_MII_MODE_MASK       0x00000003
@@ -860,6 +854,7 @@ struct shared_feat_cfg {		 /* NVRAM Offset */
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT  0x00000300
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_AFEX_MODE      0x00000400
 		#define SHARED_FEAT_CFG_FORCE_SF_MODE_UFP_MODE       0x00000600
+		#define SHARED_FEAT_CFG_FORCE_SF_MODE_EXTENDED_MODE  0x00000700
 
 	/* The interval in seconds between sending LLDP packets. Set to zero
 	   to disable the feature */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index da6c5bb..74fbf9e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11624,11 +11624,27 @@ static bool bnx2x_get_dropless_info(struct bnx2x *bp)
 	return cfg;
 }
 
+static void validate_set_si_mode(struct bnx2x *bp)
+{
+	u8 func = BP_ABS_FUNC(bp);
+	u32 val;
+
+	val = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
+
+	/* check for legal mac (upper bytes) */
+	if (val != 0xffff) {
+		bp->mf_mode = MULTI_FUNCTION_SI;
+		bp->mf_config[BP_VN(bp)] =
+			MF_CFG_RD(bp, func_mf_config[func].config);
+	} else
+		BNX2X_DEV_INFO("illegal MAC address for SI\n");
+}
+
 static int bnx2x_get_hwinfo(struct bnx2x *bp)
 {
 	int /*abs*/func = BP_ABS_FUNC(bp);
 	int vn;
-	u32 val = 0;
+	u32 val = 0, val2 = 0;
 	int rc = 0;
 
 	bnx2x_get_common_hwinfo(bp);
@@ -11738,15 +11754,7 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 
 			switch (val) {
 			case SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT:
-				val = MF_CFG_RD(bp, func_mf_config[func].
-						mac_upper);
-				/* check for legal mac (upper bytes)*/
-				if (val != 0xffff) {
-					bp->mf_mode = MULTI_FUNCTION_SI;
-					bp->mf_config[vn] = MF_CFG_RD(bp,
-						   func_mf_config[func].config);
-				} else
-					BNX2X_DEV_INFO("illegal MAC address for SI\n");
+				validate_set_si_mode(bp);
 				break;
 			case SHARED_FEAT_CFG_FORCE_SF_MODE_AFEX_MODE:
 				if ((!CHIP_IS_E1x(bp)) &&
@@ -11784,6 +11792,23 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 			case SHARED_FEAT_CFG_FORCE_SF_MODE_FORCED_SF:
 				bp->mf_config[vn] = 0;
 				break;
+			case SHARED_FEAT_CFG_FORCE_SF_MODE_EXTENDED_MODE:
+				val2 = SHMEM_RD(bp,
+					dev_info.shared_hw_config.config_3);
+				val2 &= SHARED_HW_CFG_EXTENDED_MF_MODE_MASK;
+				switch (val2) {
+				case SHARED_HW_CFG_EXTENDED_MF_MODE_NPAR1_DOT_5:
+					validate_set_si_mode(bp);
+					bp->mf_sub_mode =
+							SUB_MF_MODE_NPAR1_DOT_5;
+					break;
+				default:
+					/* Unknown configuration */
+					bp->mf_config[vn] = 0;
+					BNX2X_DEV_INFO("unknown extended MF mode 0x%x\n",
+						       val);
+				}
+				break;
 			default:
 				/* Unknown configuration: reset mf_config */
 				bp->mf_config[vn] = 0;
-- 
1.8.3.1
