From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 3/4] bnx2x: (NPAR) prevent HW access in D3 state
Date: Sun, 6 Mar 2011 22:50:44 +0200
Message-ID: <1299444644.13442.6.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4085 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403Ab1CFU6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 15:58:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changing speed setting in NPAR requires HW access, this patch
delays the access to D0 state when performed in D3.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |    1 +
 drivers/net/bnx2x/bnx2x_cmn.c     |   22 ++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_cmn.h     |    9 +++++++++
 drivers/net/bnx2x/bnx2x_ethtool.c |   18 ++++++++----------
 4 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 7897d11..2ac4e3c 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1211,6 +1211,7 @@ struct bnx2x {
 	/* DCBX Negotation results */
 	struct dcbx_features			dcbx_local_feat;
 	u32					dcbx_error;
+	u32					pending_max;
 };
 
 /**
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 9379812..a71b329 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -996,6 +996,23 @@ void bnx2x_free_skbs(struct bnx2x *bp)
 	bnx2x_free_rx_skbs(bp);
 }
 
+void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value)
+{
+	/* load old values */
+	u32 mf_cfg = bp->mf_config[BP_VN(bp)];
+
+	if (value != bnx2x_extract_max_cfg(bp, mf_cfg)) {
+		/* leave all but MAX value */
+		mf_cfg &= ~FUNC_MF_CFG_MAX_BW_MASK;
+
+		/* set new MAX value */
+		mf_cfg |= (value << FUNC_MF_CFG_MAX_BW_SHIFT)
+				& FUNC_MF_CFG_MAX_BW_MASK;
+
+		bnx2x_fw_command(bp, DRV_MSG_CODE_SET_MF_BW, mf_cfg);
+	}
+}
+
 static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 {
 	int i, offset = 1;
@@ -1464,6 +1481,11 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bnx2x_set_eth_mac(bp, 1);
 
+	if (bp->pending_max) {
+		bnx2x_update_max_mf_config(bp, bp->pending_max);
+		bp->pending_max = 0;
+	}
+
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 326ba44..85ea7f2 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -341,6 +341,15 @@ void bnx2x_dcbx_init(struct bnx2x *bp);
  */
 int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
 
+/**
+ * Updates MAX part of MF configuration in HW
+ * (if required)
+ *
+ * @param bp
+ * @param value
+ */
+void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value);
+
 /* dev_close main block */
 int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
 
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index ef29199..7e92f9d 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -238,7 +238,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	speed |= (cmd->speed_hi << 16);
 
 	if (IS_MF_SI(bp)) {
-		u32 param = 0, part;
+		u32 part;
 		u32 line_speed = bp->link_vars.line_speed;
 
 		/* use 10G if no link detected */
@@ -251,24 +251,22 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				       REQ_BC_VER_4_SET_MF_BW);
 			return -EINVAL;
 		}
+
 		part = (speed * 100) / line_speed;
+
 		if (line_speed < speed || !part) {
 			BNX2X_DEV_INFO("Speed setting should be in a range "
 				       "from 1%% to 100%% "
 				       "of actual line speed\n");
 			return -EINVAL;
 		}
-		/* load old values */
-		param = bp->mf_config[BP_VN(bp)];
 
-		/* leave only MIN value */
-		param &= FUNC_MF_CFG_MIN_BW_MASK;
-
-		/* set new MAX value */
-		param |= (part << FUNC_MF_CFG_MAX_BW_SHIFT)
-				  & FUNC_MF_CFG_MAX_BW_MASK;
+		if (bp->state != BNX2X_STATE_OPEN)
+			/* store value for following "load" */
+			bp->pending_max = part;
+		else
+			bnx2x_update_max_mf_config(bp, part);
 
-		bnx2x_fw_command(bp, DRV_MSG_CODE_SET_MF_BW, param);
 		return 0;
 	}
 
-- 
1.7.2.2




