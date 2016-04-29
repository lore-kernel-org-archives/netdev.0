From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 2/3] qede: add support for selftests.
Date: Thu, 28 Apr 2016 20:20:53 -0400
Message-ID: <1461889254-10534-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>, <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60847 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752918AbcD2BDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 21:03:39 -0400
In-Reply-To: <1461889254-10534-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the qede ethtool support for the following tests:
- interrupt test
- memory test
- register test
- clock test

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 56 ++++++++++++++++++++++++-
 1 file changed, 55 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index f1dd25a..e25a05b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -125,6 +125,21 @@ static const char qede_private_arr[QEDE_PRI_FLAG_LEN][ETH_GSTRING_LEN] = {
 	"Coupled-Function",
 };
 
+enum qede_ethtool_tests {
+	QEDE_ETHTOOL_INTERRUPT_TEST,
+	QEDE_ETHTOOL_MEMORY_TEST,
+	QEDE_ETHTOOL_REGISTER_TEST,
+	QEDE_ETHTOOL_CLOCK_TEST,
+	QEDE_ETHTOOL_TEST_MAX
+};
+
+static const char qede_tests_str_arr[QEDE_ETHTOOL_TEST_MAX][ETH_GSTRING_LEN] = {
+	"Interrupt (online)\t",
+	"Memory (online)\t\t",
+	"Register (online)\t",
+	"Clock (online)\t\t",
+};
+
 static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
 {
 	int i, j, k;
@@ -152,6 +167,10 @@ static void qede_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 		memcpy(buf, qede_private_arr,
 		       ETH_GSTRING_LEN * QEDE_PRI_FLAG_LEN);
 		break;
+	case ETH_SS_TEST:
+		memcpy(buf, qede_tests_str_arr,
+		       ETH_GSTRING_LEN * QEDE_ETHTOOL_TEST_MAX);
+		break;
 	default:
 		DP_VERBOSE(edev, QED_MSG_DEBUG,
 			   "Unsupported stringset 0x%08x\n", stringset);
@@ -192,7 +211,8 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 		return num_stats + QEDE_NUM_RQSTATS;
 	case ETH_SS_PRIV_FLAGS:
 		return QEDE_PRI_FLAG_LEN;
-
+	case ETH_SS_TEST:
+		return QEDE_ETHTOOL_TEST_MAX;
 	default:
 		DP_VERBOSE(edev, QED_MSG_DEBUG,
 			   "Unsupported stringset 0x%08x\n", stringset);
@@ -827,6 +847,39 @@ static int qede_set_rxfh(struct net_device *dev, const u32 *indir,
 	return 0;
 }
 
+static void qede_self_test(struct net_device *dev,
+			   struct ethtool_test *etest, u64 *buf)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG,
+		   "Self-test command parameters: offline = %d, external_lb = %d\n",
+		   (etest->flags & ETH_TEST_FL_OFFLINE),
+		   (etest->flags & ETH_TEST_FL_EXTERNAL_LB) >> 2);
+
+	memset(buf, 0, sizeof(u64) * QEDE_ETHTOOL_TEST_MAX);
+
+	if (edev->ops->common->selftest->selftest_interrupt(edev->cdev)) {
+		buf[QEDE_ETHTOOL_INTERRUPT_TEST] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
+
+	if (edev->ops->common->selftest->selftest_memory(edev->cdev)) {
+		buf[QEDE_ETHTOOL_MEMORY_TEST] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
+
+	if (edev->ops->common->selftest->selftest_register(edev->cdev)) {
+		buf[QEDE_ETHTOOL_REGISTER_TEST] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
+
+	if (edev->ops->common->selftest->selftest_clock(edev->cdev)) {
+		buf[QEDE_ETHTOOL_CLOCK_TEST] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
+}
+
 static const struct ethtool_ops qede_ethtool_ops = {
 	.get_settings = qede_get_settings,
 	.set_settings = qede_set_settings,
@@ -852,6 +905,7 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.set_rxfh = qede_set_rxfh,
 	.get_channels = qede_get_channels,
 	.set_channels = qede_set_channels,
+	.self_test = qede_self_test,
 };
 
 void qede_set_ethtool_ops(struct net_device *dev)
-- 
1.8.3.1
