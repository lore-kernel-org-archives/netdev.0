From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 3/3] bnx2x: Utilize Link Flap Avoidance
Date: Thu, 13 Sep 2012 15:56:21 +0300
Message-ID: <1347540981-16198-4-git-send-email-yuvalmin@broadcom.com>
References: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4286 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607Ab2IMNVM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 09:21:12 -0400
In-Reply-To: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change various flows in the bnx2x driver which up until now flapped
the link - these flows now benefit from the link flap avoidance mechanism.

This includes the removal of the link reset made upon nic init, as it is
possible the link is already active at that time.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   12 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |   16 +++++++--
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   10 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |    3 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   34 +++++++++++++-------
 6 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index af20c6e..ca80487 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2283,7 +2283,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Wait for all pending SP commands to complete */
 	if (!bnx2x_wait_sp_comp(bp, ~0x0UL)) {
 		BNX2X_ERR("Timeout waiting for SP elements to complete\n");
-		bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+		bnx2x_nic_unload(bp, UNLOAD_CLOSE, false);
 		return -EBUSY;
 	}
 
@@ -2331,7 +2331,7 @@ load_error0:
 }
 
 /* must be called with rtnl_lock */
-int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
+int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 {
 	int i;
 	bool global = false;
@@ -2393,7 +2393,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	/* Cleanup the chip if needed */
 	if (unload_mode != UNLOAD_RECOVERY)
-		bnx2x_chip_cleanup(bp, unload_mode);
+		bnx2x_chip_cleanup(bp, unload_mode, keep_link);
 	else {
 		/* Send the UNLOAD_REQUEST to the MCP */
 		bnx2x_send_unload_req(bp, unload_mode);
@@ -2417,7 +2417,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		bnx2x_free_irq(bp);
 
 		/* Report UNLOAD_DONE to MCP */
-		bnx2x_send_unload_done(bp);
+		bnx2x_send_unload_done(bp, false);
 	}
 
 	/*
@@ -3768,7 +3768,7 @@ int bnx2x_reload_if_running(struct net_device *dev)
 	if (unlikely(!netif_running(dev)))
 		return 0;
 
-	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL, true);
 	return bnx2x_nic_load(bp, LOAD_NORMAL);
 }
 
@@ -3965,7 +3965,7 @@ int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	netif_device_detach(dev);
 
-	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+	bnx2x_nic_unload(bp, UNLOAD_CLOSE, false);
 
 	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 21b5532..96e998c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -83,8 +83,9 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode);
  * bnx2x_send_unload_done - send UNLOAD_DONE command to the MCP.
  *
  * @bp:		driver handle
+ * @keep_link:		true iff link should be kept up
  */
-void bnx2x_send_unload_done(struct bnx2x *bp);
+void bnx2x_send_unload_done(struct bnx2x *bp, bool keep_link);
 
 /**
  * bnx2x_config_rss_pf - configure RSS parameters in a PF.
@@ -153,6 +154,14 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode);
 void bnx2x_link_set(struct bnx2x *bp);
 
 /**
+ * bnx2x_force_link_reset - Forces link reset, and put the PHY
+ * in reset as well.
+ *
+ * @bp:		driver handle
+ */
+void bnx2x_force_link_reset(struct bnx2x *bp);
+
+/**
  * bnx2x_link_test - query link status.
  *
  * @bp:		driver handle
@@ -312,12 +321,13 @@ void bnx2x_set_num_queues(struct bnx2x *bp);
  *
  * @bp:			driver handle
  * @unload_mode:	COMMON, PORT, FUNCTION
+ * @keep_link:		true iff link should be kept up.
  *
  * - Cleanup MAC configuration.
  * - Closes clients.
  * - etc.
  */
-void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode);
+void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode, bool keep_link);
 
 /**
  * bnx2x_acquire_hw_lock - acquire HW lock.
@@ -446,7 +456,7 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl);
 bool bnx2x_test_firmware_version(struct bnx2x *bp, bool is_err);
 
 /* dev_close main block */
-int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
+int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link);
 
 /* dev_open main block */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c37a68d..19d2fc5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -905,6 +905,7 @@ static int bnx2x_nway_reset(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+		bnx2x_force_link_reset(bp);
 		bnx2x_link_set(bp);
 	}
 
@@ -1733,6 +1734,7 @@ static int bnx2x_set_eee(struct net_device *dev, struct ethtool_eee *edata)
 	/* Restart link to propogate changes */
 	if (netif_running(dev)) {
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+		bnx2x_force_link_reset(bp);
 		bnx2x_link_set(bp);
 	}
 
@@ -2257,7 +2259,7 @@ static int bnx2x_test_ext_loopback(struct bnx2x *bp)
 	if (!netif_running(bp->dev))
 		return BNX2X_EXT_LOOPBACK_FAILED;
 
-	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL, false);
 	rc = bnx2x_nic_load(bp, LOAD_LOOPBACK_EXT);
 	if (rc) {
 		DP(BNX2X_MSG_ETHTOOL,
@@ -2408,7 +2410,7 @@ static void bnx2x_self_test(struct net_device *dev,
 
 		link_up = bp->link_vars.link_up;
 
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL, false);
 		rc = bnx2x_nic_load(bp, LOAD_DIAG);
 		if (rc) {
 			etest->flags |= ETH_TEST_FL_FAILED;
@@ -2440,7 +2442,7 @@ static void bnx2x_self_test(struct net_device *dev,
 			etest->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
 		}
 
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL, false);
 
 		/* restore input for TX port IF */
 		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, val);
@@ -2934,7 +2936,7 @@ static int bnx2x_set_channels(struct net_device *dev,
 		bnx2x_change_num_queues(bp, channels->combined_count);
 		return 0;
 	}
-	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL, true);
 	bnx2x_change_num_queues(bp, channels->combined_count);
 	return bnx2x_nic_load(bp, LOAD_NORMAL);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index df14006..c795cfc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1286,6 +1286,9 @@ struct drv_func_mb {
 	#define DRV_MSG_CODE_SET_MF_BW_MIN_MASK         0x00ff0000
 	#define DRV_MSG_CODE_SET_MF_BW_MAX_MASK         0xff000000
 
+	#define DRV_MSG_CODE_UNLOAD_SKIP_LINK_RESET     0x00000002
+
+	#define DRV_MSG_CODE_LOAD_REQ_WITH_LFA          0x0000100a
 	u32 fw_mb_header;
 	#define FW_MSG_CODE_MASK                        0xffff0000
 	#define FW_MSG_CODE_DRV_LOAD_COMMON             0x10100000
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 5b64d3d..3cd2391 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -359,7 +359,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars);
    to 0 */
 int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		     u8 reset_ext_phy);
-
+int bnx2x_lfa_reset(struct link_params *params, struct link_vars *vars);
 /* bnx2x_link_update should be called upon link interrupt */
 int bnx2x_link_update(struct link_params *params, struct link_vars *vars);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2105498..dfc5b60 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2171,7 +2171,6 @@ void bnx2x_link_set(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
-		bnx2x_link_reset(&bp->link_params, &bp->link_vars, 1);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 		bnx2x_release_phy_lock(bp);
 
@@ -2184,12 +2183,19 @@ static void bnx2x__link_reset(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
-		bnx2x_link_reset(&bp->link_params, &bp->link_vars, 1);
+		bnx2x_lfa_reset(&bp->link_params, &bp->link_vars);
 		bnx2x_release_phy_lock(bp);
 	} else
 		BNX2X_ERR("Bootcode is missing - can not reset link\n");
 }
 
+void bnx2x_force_link_reset(struct bnx2x *bp)
+{
+	bnx2x_acquire_phy_lock(bp);
+	bnx2x_link_reset(&bp->link_params, &bp->link_vars, 1);
+	bnx2x_release_phy_lock(bp);
+}
+
 u8 bnx2x_link_test(struct bnx2x *bp, u8 is_serdes)
 {
 	u8 rc = 0;
@@ -6757,7 +6763,6 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	u32 low, high;
 	u32 val;
 
-	bnx2x__link_reset(bp);
 
 	DP(NETIF_MSG_HW, "starting port init  port %d\n", port);
 
@@ -8244,12 +8249,15 @@ u32 bnx2x_send_unload_req(struct bnx2x *bp, int unload_mode)
  * bnx2x_send_unload_done - send UNLOAD_DONE command to the MCP.
  *
  * @bp:		driver handle
+ * @keep_link:		true iff link should be kept up
  */
-void bnx2x_send_unload_done(struct bnx2x *bp)
+void bnx2x_send_unload_done(struct bnx2x *bp, bool keep_link)
 {
+	u32 reset_param = keep_link ? DRV_MSG_CODE_UNLOAD_SKIP_LINK_RESET : 0;
+
 	/* Report UNLOAD_DONE to MCP */
 	if (!BP_NOMCP(bp))
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, reset_param);
 }
 
 static int bnx2x_func_wait_started(struct bnx2x *bp)
@@ -8318,7 +8326,7 @@ static int bnx2x_func_wait_started(struct bnx2x *bp)
 	return 0;
 }
 
-void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
+void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode, bool keep_link)
 {
 	int port = BP_PORT(bp);
 	int i, rc = 0;
@@ -8440,7 +8448,7 @@ unload_error:
 
 
 	/* Report UNLOAD_DONE to MCP */
-	bnx2x_send_unload_done(bp);
+	bnx2x_send_unload_done(bp, keep_link);
 }
 
 void bnx2x_disable_close_the_gate(struct bnx2x *bp)
@@ -8852,7 +8860,8 @@ int bnx2x_leader_reset(struct bnx2x *bp)
 	 * driver is owner of the HW
 	 */
 	if (!global && !BP_NOMCP(bp)) {
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ,
+					     DRV_MSG_CODE_LOAD_REQ_WITH_LFA);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EAGAIN;
@@ -8958,7 +8967,7 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 
 			/* Stop the driver */
 			/* If interface has been removed - break */
-			if (bnx2x_nic_unload(bp, UNLOAD_RECOVERY))
+			if (bnx2x_nic_unload(bp, UNLOAD_RECOVERY, false))
 				return;
 
 			bp->recovery_state = BNX2X_RECOVERY_WAIT;
@@ -9124,7 +9133,7 @@ static void bnx2x_sp_rtnl_task(struct work_struct *work)
 		bp->sp_rtnl_state = 0;
 		smp_mb();
 
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL, true);
 		bnx2x_nic_load(bp, LOAD_NORMAL);
 
 		goto sp_rtnl_exit;
@@ -9310,7 +9319,8 @@ static void __devinit bnx2x_prev_unload_undi_inc(struct bnx2x *bp, u8 port,
 
 static int __devinit bnx2x_prev_mcp_done(struct bnx2x *bp)
 {
-	u32 rc = bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
+	u32 rc = bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE,
+				  DRV_MSG_CODE_UNLOAD_SKIP_LINK_RESET);
 	if (!rc) {
 		BNX2X_ERR("MCP response failure, aborting\n");
 		return -EBUSY;
@@ -11005,7 +11015,7 @@ static int bnx2x_close(struct net_device *dev)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	/* Unload the driver, release IRQs */
-	bnx2x_nic_unload(bp, UNLOAD_CLOSE);
+	bnx2x_nic_unload(bp, UNLOAD_CLOSE, false);
 
 	/* Power off */
 	bnx2x_set_power_state(bp, PCI_D3hot);
-- 
1.7.9.rc2
