From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 1/11 v2] bnx2x: Add support for external LB
Date: Tue, 19 Jun 2012 20:48:22 +0300
Message-ID: <1340128112-22935-2-git-send-email-meravs@broadcom.com>
References: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3481 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754445Ab2FSOlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 10:41:09 -0400
In-Reply-To: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enables to do self-test with external loopback via ethtool.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   76 ++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    5 ++
 4 files changed, 81 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7de8241..4335f9f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1817,6 +1817,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define LOAD_NORMAL			0
 #define LOAD_OPEN			1
 #define LOAD_DIAG			2
+#define LOAD_LOOPBACK_EXT		3
 #define UNLOAD_NORMAL			0
 #define UNLOAD_CLOSE			1
 #define UNLOAD_RECOVERY			2
@@ -1900,12 +1901,14 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PCICFG_LINK_SPEED_SHIFT		16
 
 
-#define BNX2X_NUM_TESTS			7
+#define BNX2X_NUM_TESTS			8
 
 #define BNX2X_PHY_LOOPBACK		0
 #define BNX2X_MAC_LOOPBACK		1
+#define BNX2X_EXT_LOOPBACK		2
 #define BNX2X_PHY_LOOPBACK_FAILED	1
 #define BNX2X_MAC_LOOPBACK_FAILED	2
+#define BNX2X_EXT_LOOPBACK_FAILED	3
 #define BNX2X_LOOPBACK_FAILED		(BNX2X_MAC_LOOPBACK_FAILED | \
 					 BNX2X_PHY_LOOPBACK_FAILED)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8098eea..9370f5f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2176,6 +2176,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		break;
 
 	case LOAD_DIAG:
+	case LOAD_LOOPBACK_EXT:
 		bp->state = BNX2X_STATE_DIAG;
 		break;
 
@@ -2215,7 +2216,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		return -EBUSY;
 	}
 
-	bnx2x_dcbx_init(bp);
+	if (bp->state != BNX2X_STATE_DIAG)
+		bnx2x_dcbx_init(bp);
 	return 0;
 
 #ifndef BNX2X_STOP_ON_ERROR
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index bf30e28..68fa902 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1538,7 +1538,8 @@ static const struct {
 } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] = {
 	{ "register_test (offline)" },
 	{ "memory_test (offline)" },
-	{ "loopback_test (offline)" },
+	{ "int_loopback_test (offline)" },
+	{ "ext_loopback_test (offline)" },
 	{ "nvram_test (online)" },
 	{ "interrupt_test (online)" },
 	{ "link_test (online)" },
@@ -1943,6 +1944,14 @@ static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up, u8 is_serdes)
 
 		if (cnt <= 0 && bnx2x_link_test(bp, is_serdes))
 			DP(BNX2X_MSG_ETHTOOL, "Timeout waiting for link up\n");
+
+		cnt = 1400;
+		while (!bp->link_vars.link_up && cnt--)
+			msleep(20);
+
+		if (cnt <= 0 && !bp->link_vars.link_up)
+			DP(BNX2X_MSG_ETHTOOL,
+			   "Timeout waiting for link init\n");
 	}
 }
 
@@ -1968,13 +1977,16 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	u16 len;
 	int rc = -ENODEV;
 	u8 *data;
-	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev, txdata->txq_index);
+	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev,
+						       txdata->txq_index);
 
 	/* check the loopback mode */
 	switch (loopback_mode) {
 	case BNX2X_PHY_LOOPBACK:
-		if (bp->link_params.loopback_mode != LOOPBACK_XGXS)
+		if (bp->link_params.loopback_mode != LOOPBACK_XGXS) {
+			DP(BNX2X_MSG_ETHTOOL, "PHY loopback not supported\n");
 			return -EINVAL;
+		}
 		break;
 	case BNX2X_MAC_LOOPBACK:
 		if (CHIP_IS_E3(bp)) {
@@ -1991,6 +2003,13 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 		break;
+	case BNX2X_EXT_LOOPBACK:
+		if (bp->link_params.loopback_mode != LOOPBACK_EXT) {
+			DP(BNX2X_MSG_ETHTOOL,
+			   "Can't configure external loopback\n");
+			return -EINVAL;
+		}
+		break;
 	default:
 		DP(BNX2X_MSG_ETHTOOL, "Command parameters not supported\n");
 		return -EINVAL;
@@ -2162,6 +2181,38 @@ static int bnx2x_test_loopback(struct bnx2x *bp)
 	return rc;
 }
 
+static int bnx2x_test_ext_loopback(struct bnx2x *bp)
+{
+	int rc;
+	u8 is_serdes =
+		(bp->link_vars.link_status & LINK_STATUS_SERDES_LINK) > 0;
+
+	if (BP_NOMCP(bp))
+		return -ENODEV;
+
+	if (!netif_running(bp->dev))
+		return BNX2X_EXT_LOOPBACK_FAILED;
+
+	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+	rc = bnx2x_nic_load(bp, LOAD_LOOPBACK_EXT);
+	if (rc) {
+		DP(BNX2X_MSG_ETHTOOL,
+		   "Can't perform self-test, nic_load (for external lb) failed\n");
+		return -ENODEV;
+	}
+	bnx2x_wait_for_link(bp, 1, is_serdes);
+
+	bnx2x_netif_stop(bp, 1);
+
+	rc = bnx2x_run_loopback(bp, BNX2X_EXT_LOOPBACK);
+	if (rc)
+		DP(BNX2X_MSG_ETHTOOL, "EXT loopback failed  (res %d)\n", rc);
+
+	bnx2x_netif_start(bp);
+
+	return rc;
+}
+
 #define CRC32_RESIDUAL			0xdebb20e3
 
 static int bnx2x_test_nvram(struct bnx2x *bp)
@@ -2263,6 +2314,10 @@ static void bnx2x_self_test(struct net_device *dev,
 		etest->flags |= ETH_TEST_FL_FAILED;
 		return;
 	}
+	DP(BNX2X_MSG_ETHTOOL,
+	   "Self-test command parameters: offline = %d, external_lb = %d\n",
+	   (etest->flags & ETH_TEST_FL_OFFLINE),
+	   (etest->flags & ETH_TEST_FL_EXTERNAL_LB)>>2);
 
 	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS);
 
@@ -2300,10 +2355,17 @@ static void bnx2x_self_test(struct net_device *dev,
 			etest->flags |= ETH_TEST_FL_FAILED;
 		}
 
-		buf[2] = bnx2x_test_loopback(bp);
+		buf[2] = bnx2x_test_loopback(bp); /* internal LB */
 		if (buf[2] != 0)
 			etest->flags |= ETH_TEST_FL_FAILED;
 
+		if (etest->flags & ETH_TEST_FL_EXTERNAL_LB) {
+			buf[3] = bnx2x_test_ext_loopback(bp); /* external LB */
+			if (buf[3] != 0)
+				etest->flags |= ETH_TEST_FL_FAILED;
+			etest->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
+		}
+
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
 
 		/* restore input for TX port IF */
@@ -2314,16 +2376,16 @@ static void bnx2x_self_test(struct net_device *dev,
 		bnx2x_wait_for_link(bp, link_up, is_serdes);
 	}
 	if (bnx2x_test_nvram(bp) != 0) {
-		buf[3] = 1;
+		buf[4] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 	if (bnx2x_test_intr(bp) != 0) {
-		buf[4] = 1;
+		buf[5] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 
 	if (bnx2x_link_test(bp, is_serdes) != 0) {
-		buf[5] = 1;
+		buf[6] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a622bb7..aecbf02 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2124,6 +2124,11 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 			}
 		}
 
+		if (load_mode == LOAD_LOOPBACK_EXT) {
+			struct link_params *lp = &bp->link_params;
+			lp->loopback_mode = LOOPBACK_EXT;
+		}
+
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 
 		bnx2x_release_phy_lock(bp);
-- 
1.7.10
