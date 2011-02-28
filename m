From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 1/7] bnx2x: (NPAR mode) Fix FW initialization
Date: Mon, 28 Feb 2011 15:37:20 +0200
Message-ID: <1298900240.28024.121.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4080 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142Ab1B1NjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:39:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Fix FW initialization according to max BW stored in percents
 for NPAR mode. Protect HW from being configured to speed 0.


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c     |   17 +++++++++--------
 drivers/net/bnx2x/bnx2x_cmn.h     |   20 ++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_ethtool.c |   13 +++++++------
 drivers/net/bnx2x/bnx2x_main.c    |   15 ++++++++++++---
 4 files changed, 48 insertions(+), 17 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 710ce5d..a58baf3 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -703,19 +703,20 @@ u16 bnx2x_get_mf_speed(struct bnx2x *bp)
 {
 	u16 line_speed = bp->link_vars.line_speed;
 	if (IS_MF(bp)) {
-		u16 maxCfg = (bp->mf_config[BP_VN(bp)] &
-						FUNC_MF_CFG_MAX_BW_MASK) >>
-						FUNC_MF_CFG_MAX_BW_SHIFT;
-		/* Calculate the current MAX line speed limit for the DCC
-		 * capable devices
+		u16 maxCfg = bnx2x_extract_max_cfg(bp,
+						   bp->mf_config[BP_VN(bp)]);
+
+		/* Calculate the current MAX line speed limit for the MF
+		 * devices
 		 */
-		if (IS_MF_SD(bp)) {
+		if (IS_MF_SI(bp))
+			line_speed = (line_speed * maxCfg) / 100;
+		else { /* SD mode */
 			u16 vn_max_rate = maxCfg * 100;
 
 			if (vn_max_rate < line_speed)
 				line_speed = vn_max_rate;
-		} else /* IS_MF_SI(bp)) */
-			line_speed = (line_speed * maxCfg) / 100;
+		}
 	}
 
 	return line_speed;
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 03eb4d6..326ba44 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -1044,4 +1044,24 @@ static inline void storm_memset_cmng(struct bnx2x *bp,
 void bnx2x_acquire_phy_lock(struct bnx2x *bp);
 void bnx2x_release_phy_lock(struct bnx2x *bp);
 
+/**
+ * Extracts MAX BW part from MF configuration.
+ *
+ * @param bp
+ * @param mf_cfg
+ *
+ * @return u16
+ */
+static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
+{
+	u16 max_cfg = (mf_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
+			      FUNC_MF_CFG_MAX_BW_SHIFT;
+	if (!max_cfg) {
+		BNX2X_ERR("Illegal configuration detected for Max BW - "
+			  "using 100 instead\n");
+		max_cfg = 100;
+	}
+	return max_cfg;
+}
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 5b44a8b..b3da295 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -238,7 +238,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	speed |= (cmd->speed_hi << 16);
 
 	if (IS_MF_SI(bp)) {
-		u32 param = 0;
+		u32 param = 0, part;
 		u32 line_speed = bp->link_vars.line_speed;
 
 		/* use 10G if no link detected */
@@ -251,9 +251,11 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				       REQ_BC_VER_4_SET_MF_BW);
 			return -EINVAL;
 		}
-		if (line_speed < speed) {
-			BNX2X_DEV_INFO("New speed should be less or equal "
-				       "to actual line speed\n");
+		part = (speed * 100) / line_speed;
+		if (line_speed < speed || !part) {
+			BNX2X_DEV_INFO("Speed setting should be in a range "
+				       "from 1%% to 100%% "
+				       "of actual line speed\n");
 			return -EINVAL;
 		}
 		/* load old values */
@@ -263,8 +265,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		param &= FUNC_MF_CFG_MIN_BW_MASK;
 
 		/* set new MAX value */
-		param |= (((speed * 100) / line_speed)
-				 << FUNC_MF_CFG_MAX_BW_SHIFT)
+		param |= (part << FUNC_MF_CFG_MAX_BW_SHIFT)
 				  & FUNC_MF_CFG_MAX_BW_MASK;
 
 		bnx2x_fw_command(bp, DRV_MSG_CODE_SET_MF_BW, param);
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index d584d32..203e9bf 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1974,13 +1974,22 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 		vn_max_rate = 0;
 
 	} else {
+		u32 maxCfg = bnx2x_extract_max_cfg(bp, vn_cfg);
+
 		vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
-		/* If min rate is zero - set it to 1 */
+		/* If fairness is enabled (not all min rates are zeroes) and
+		   if current min rate is zero - set it to 1.
+		   This is a requirement of the algorithm. */
 		if (bp->vn_weight_sum && (vn_min_rate == 0))
 			vn_min_rate = DEF_MIN_RATE;
-		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
-				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
+
+		if (IS_MF_SI(bp))
+			/* maxCfg in percents of linkspeed */
+			vn_max_rate = (bp->link_vars.line_speed * maxCfg) / 100;
+		else
+			/* maxCfg is absolute in 100Mb units */
+			vn_max_rate = maxCfg * 100;
 	}
 
 	DP(NETIF_MSG_IFUP,
-- 
1.7.2.2




