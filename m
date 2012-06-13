From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 2/12] bnx2x: Return only online tests for MF
Date: Wed, 13 Jun 2012 15:44:14 +0300
Message-ID: <1339591464-10554-3-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2760 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671Ab2FMJmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:42:39 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. In multi-function device, show only the online tests in self-test results as
   only these test are performed (offline tests cannot be performed as they may
   corrupt the traffic of other functions on the same physical port). Note that
   multi-function mode cannot change while the driver is up.
2. Check result code in NIC load and act accordingly.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    6 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   85 +++++++++++++-------
 2 files changed, 62 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index fb6de4a..568c3c7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1915,8 +1915,10 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PCICFG_LINK_SPEED		0xf0000
 #define PCICFG_LINK_SPEED_SHIFT		16
 
-
-#define BNX2X_NUM_TESTS			8
+#define BNX2X_NUM_TESTS_SF		7
+#define BNX2X_NUM_TESTS_MF		3
+#define BNX2X_NUM_TESTS(bp)		(IS_MF(bp) ? BNX2X_NUM_TESTS_MF : \
+						     BNX2X_NUM_TESTS_SF)
 
 #define BNX2X_PHY_LOOPBACK		0
 #define BNX2X_MAC_LOOPBACK		1
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 116ac25..d7ffc74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -826,7 +826,7 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 		 ((phy_fw_ver[0] != '\0') ? " phy " : ""), phy_fw_ver);
 	strlcpy(info->bus_info, pci_name(bp->pdev), sizeof(info->bus_info));
 	info->n_stats = BNX2X_NUM_STATS;
-	info->testinfo_len = BNX2X_NUM_TESTS;
+	info->testinfo_len = BNX2X_NUM_TESTS(bp);
 	info->eedump_len = bp->common.flash_size;
 	info->regdump_len = bnx2x_get_regs_len(dev);
 }
@@ -1533,17 +1533,14 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	return 0;
 }
 
-static const struct {
-	char string[ETH_GSTRING_LEN];
-} bnx2x_tests_str_arr[BNX2X_NUM_TESTS] = {
-	{ "register_test (offline)" },
-	{ "memory_test (offline)" },
-	{ "int_loopback_test (offline)" },
-	{ "ext_loopback_test (offline)" },
-	{ "nvram_test (online)" },
-	{ "interrupt_test (online)" },
-	{ "link_test (online)" },
-	{ "idle check (online)" }
+char *bnx2x_tests_str_arr[BNX2X_NUM_TESTS_SF] = {
+	"register_test (offline)    ",
+	"memory_test (offline)      ",
+	"int_loopback_test (offline)",
+	"ext_loopback_test (offline)",
+	"nvram_test (online)        ",
+	"interrupt_test (online)    ",
+	"link_test (online)         "
 };
 
 static u32 bnx2x_eee_to_adv(u32 eee_adv)
@@ -2308,6 +2305,8 @@ static void bnx2x_self_test(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u8 is_serdes;
+	int rc;
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		netdev_err(bp->dev,
 			   "Handling parity error recovery. Try again later\n");
@@ -2319,17 +2318,18 @@ static void bnx2x_self_test(struct net_device *dev,
 	   (etest->flags & ETH_TEST_FL_OFFLINE),
 	   (etest->flags & ETH_TEST_FL_EXTERNAL_LB)>>2);
 
-	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS);
+	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS(bp));
 
-	if (!netif_running(dev))
+	if (!netif_running(dev)) {
+		DP(BNX2X_MSG_ETHTOOL,
+		   "Can't perform self-test when interface is down\n");
 		return;
+	}
 
-	/* offline tests are not supported in MF mode */
-	if (IS_MF(bp))
-		etest->flags &= ~ETH_TEST_FL_OFFLINE;
 	is_serdes = (bp->link_vars.link_status & LINK_STATUS_SERDES_LINK) > 0;
 
-	if (etest->flags & ETH_TEST_FL_OFFLINE) {
+	/* offline tests are not supported in MF mode */
+	if ((etest->flags & ETH_TEST_FL_OFFLINE) && !IS_MF(bp)) {
 		int port = BP_PORT(bp);
 		u32 val;
 		u8 link_up;
@@ -2342,7 +2342,14 @@ static void bnx2x_self_test(struct net_device *dev,
 		link_up = bp->link_vars.link_up;
 
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		bnx2x_nic_load(bp, LOAD_DIAG);
+		rc = bnx2x_nic_load(bp, LOAD_DIAG);
+		if (rc != 0) {
+			etest->flags |= ETH_TEST_FL_FAILED;
+			DP(BNX2X_MSG_ETHTOOL,
+			   "Can't perform self-test, nic_load (for offline) failed\n");
+			return;
+		}
+
 		/* wait until link state is restored */
 		bnx2x_wait_for_link(bp, 1, is_serdes);
 
@@ -2370,22 +2377,36 @@ static void bnx2x_self_test(struct net_device *dev,
 
 		/* restore input for TX port IF */
 		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, val);
-
-		bnx2x_nic_load(bp, LOAD_NORMAL);
+		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
+		if (rc != 0) {
+			etest->flags |= ETH_TEST_FL_FAILED;
+			DP(BNX2X_MSG_ETHTOOL,
+			   "Can't perform self-test, nic_load (for online) failed\n");
+			return;
+		}
 		/* wait until link state is restored */
 		bnx2x_wait_for_link(bp, link_up, is_serdes);
 	}
 	if (bnx2x_test_nvram(bp) != 0) {
-		buf[4] = 1;
+		if (!IS_MF(bp))
+			buf[4] = 1;
+		else
+			buf[0] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 	if (bnx2x_test_intr(bp) != 0) {
-		buf[5] = 1;
+		if (!IS_MF(bp))
+			buf[5] = 1;
+		else
+			buf[1] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 
 	if (bnx2x_link_test(bp, is_serdes) != 0) {
-		buf[6] = 1;
+		if (!IS_MF(bp))
+			buf[6] = 1;
+		else
+			buf[2] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 
@@ -2430,7 +2451,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 		return num_stats;
 
 	case ETH_SS_TEST:
-		return BNX2X_NUM_TESTS;
+		return BNX2X_NUM_TESTS(bp);
 
 	default:
 		return -EINVAL;
@@ -2440,7 +2461,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int i, j, k;
+	int i, j, k, offset, start;
 	char queue_name[MAX_QUEUE_NAME_LEN+1];
 
 	switch (stringset) {
@@ -2471,7 +2492,17 @@ static void bnx2x_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 		break;
 
 	case ETH_SS_TEST:
-		memcpy(buf, bnx2x_tests_str_arr, sizeof(bnx2x_tests_str_arr));
+		/* First 4 tests cannot be done in MF mode */
+		if (!IS_MF(bp))
+			start = 0;
+		else
+			start = 4;
+		for (i = 0, j = start; j < (start + BNX2X_NUM_TESTS(bp));
+		     i++, j++) {
+			offset = sprintf(buf+32*i, "%s",
+					 bnx2x_tests_str_arr[j]);
+			*(buf+offset) = '\0';
+		}
 		break;
 	}
 }
-- 
1.7.10
