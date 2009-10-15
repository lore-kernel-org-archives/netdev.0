From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 2/8] bnx2x: Allowing 0 as initial fairness value
Date: Thu, 15 Oct 2009 08:48:13 +0200
Message-ID: <1255589293.25030.72.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3075 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbZJOGtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:49:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Value of zero was used to disable the fairness mechanism. Though the code
(driver and FW) allowed changing the value at run time, it did not allow to do
that if the mechanism was disabled to begin with.
Fixed the FW to allow turning on and off the mechanism at run time. Fixed the
code to read the value from the chip at the right sequence.
Without this fix, if the initial value was set to zero, traffic could not run on
the interface.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h  |    4 +-
 drivers/net/bnx2x_main.c |   56 +++++++++++++++++++++++-----------------------
 firmware/Makefile        |    2 +-
 firmware/WHENCE          |    4 +-
 4 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 994743d..dc2f8ed 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1259,8 +1259,8 @@ struct host_func_stats {
 
 
 #define BCM_5710_FW_MAJOR_VERSION			5
-#define BCM_5710_FW_MINOR_VERSION			0
-#define BCM_5710_FW_REVISION_VERSION			21
+#define BCM_5710_FW_MINOR_VERSION			2
+#define BCM_5710_FW_REVISION_VERSION			7
 #define BCM_5710_FW_ENGINEERING_VERSION 		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b4e9c6e..691cf15 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2333,8 +2333,14 @@ static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
 	}
 
 	/* ... only if all min rates are zeros - disable fairness */
-	if (all_zero)
-		bp->vn_weight_sum = 0;
+	if (all_zero) {
+		bp->cmng.flags.cmng_enables &=
+					~CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
+		DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
+		   "  fairness will be disabled\n");
+	} else
+		bp->cmng.flags.cmng_enables |=
+					CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
 }
 
 static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
@@ -2353,17 +2359,14 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 	} else {
 		vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
-		/* If fairness is enabled (not all min rates are zeroes) and
-		   if current min rate is zero - set it to 1.
-		   This is a requirement of the algorithm. */
-		if (bp->vn_weight_sum && (vn_min_rate == 0))
+		/* If min rate is zero - set it to 1 */
+		if (!vn_min_rate)
 			vn_min_rate = DEF_MIN_RATE;
 		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
 				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
 	}
-
 	DP(NETIF_MSG_IFUP,
-	   "func %d: vn_min_rate=%d  vn_max_rate=%d  vn_weight_sum=%d\n",
+	   "func %d: vn_min_rate %d  vn_max_rate %d  vn_weight_sum %d\n",
 	   func, vn_min_rate, vn_max_rate, bp->vn_weight_sum);
 
 	memset(&m_rs_vn, 0, sizeof(struct rate_shaping_vars_per_vn));
@@ -2490,7 +2493,6 @@ static void bnx2x__link_status_update(struct bnx2x *bp)
 	else
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	bp->mf_config = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 	bnx2x_calc_vn_weight_sum(bp);
 
 	/* indicate link status */
@@ -2634,10 +2636,7 @@ static void bnx2x_update_min_max(struct bnx2x *bp)
 
 static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 {
-	int func = BP_FUNC(bp);
-
 	DP(BNX2X_MSG_MCP, "dcc_event 0x%x\n", dcc_event);
-	bp->mf_config = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 
 	if (dcc_event & DRV_STATUS_DCC_DISABLE_ENABLE_PF) {
 
@@ -3067,6 +3066,8 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			int func = BP_FUNC(bp);
 
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
+			bp->mf_config = SHMEM_RD(bp,
+					   mf_cfg.func_mf_config[func].config);
 			val = SHMEM_RD(bp, func_mb[func].drv_status);
 			if (val & DRV_STATUS_DCC_EVENT_MASK)
 				bnx2x_dcc_event(bp,
@@ -5559,20 +5560,18 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		bp->link_vars.line_speed = SPEED_10000;
 		bnx2x_init_port_minmax(bp);
 
+		if (!BP_NOMCP(bp))
+			bp->mf_config =
+			      SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 		bnx2x_calc_vn_weight_sum(bp);
 
 		for (vn = VN_0; vn < E1HVN_MAX; vn++)
 			bnx2x_init_vn_minmax(bp, 2*vn + port);
 
 		/* Enable rate shaping and fairness */
-		bp->cmng.flags.cmng_enables =
+		bp->cmng.flags.cmng_enables |=
 					CMNG_FLAGS_PER_PORT_RATE_SHAPING_VN;
-		if (bp->vn_weight_sum)
-			bp->cmng.flags.cmng_enables |=
-					CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
-		else
-			DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
-			   "  fairness will be disabled\n");
+
 	} else {
 		/* rate shaping and fairness are disabled */
 		DP(NETIF_MSG_IFUP,
@@ -9038,17 +9037,18 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (netif_carrier_ok(dev)) {
 		cmd->speed = bp->link_vars.line_speed;
 		cmd->duplex = bp->link_vars.duplex;
-	} else {
-		cmd->speed = bp->link_params.req_line_speed;
-		cmd->duplex = bp->link_params.req_duplex;
-	}
-	if (IS_E1HMF(bp)) {
-		u16 vn_max_rate;
+		if (IS_E1HMF(bp)) {
+			u16 vn_max_rate;
 
-		vn_max_rate = ((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
+			vn_max_rate =
+				((bp->mf_config & FUNC_MF_CFG_MAX_BW_MASK) >>
 				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
-		if (vn_max_rate < cmd->speed)
-			cmd->speed = vn_max_rate;
+			if (vn_max_rate < cmd->speed)
+				cmd->speed = vn_max_rate;
+		}
+	} else {
+		cmd->speed = -1;
+		cmd->duplex = -1;
 	}
 
 	if (bp->link_params.switch_cfg == SWITCH_CFG_10G) {
diff --git a/firmware/Makefile b/firmware/Makefile
index a6c7c3e..45c0466 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -32,7 +32,7 @@ fw-shipped-$(CONFIG_ADAPTEC_STARFIRE) += adaptec/starfire_rx.bin \
 					 adaptec/starfire_tx.bin
 fw-shipped-$(CONFIG_ATARI_DSP56K) += dsp56k/bootstrap.bin
 fw-shipped-$(CONFIG_ATM_AMBASSADOR) += atmsar11.fw
-fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-5.0.21.0.fw bnx2x-e1h-5.0.21.0.fw
+fw-shipped-$(CONFIG_BNX2X) += bnx2x-e1-5.2.7.0.fw bnx2x-e1h-5.2.7.0.fw
 fw-shipped-$(CONFIG_BNX2) += bnx2/bnx2-mips-09-5.0.0.j3.fw \
 			     bnx2/bnx2-rv2p-09-5.0.0.j3.fw \
 			     bnx2/bnx2-rv2p-09ax-5.0.0.j3.fw \
diff --git a/firmware/WHENCE b/firmware/WHENCE
index c437e14..a07aede 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -674,8 +674,8 @@ Found in hex form in kernel source.
 
 Driver: bnx2x: Broadcom Everest
 
-File: bnx2x-e1-4.8.53.0.fw.ihex
-File: bnx2x-e1h-4.8.53.0.fw.ihex
+File: bnx2x-e1-5.2.7.0.fw.ihex
+File: bnx2x-e1h-5.2.7.0.fw.ihex
 
 License:
   Copyright (c) 2007-2009 Broadcom Corporation
-- 
1.5.4.3




