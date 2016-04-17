From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/5] qede: Add support for ethtool private flags
Date: Sun, 17 Apr 2016 22:26:32 +0300
Message-ID: <1460921195-23352-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10014 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750970AbcDQT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 15:26:49 -0400
In-Reply-To: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds a getter for the interfaces private flags.
The only parameter currently supported is whether the interface is a
coupled function [required for supporting 100g].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 27 +++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index f87e83b..5ba6b2a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -116,6 +116,15 @@ static const struct {
 
 #define QEDE_NUM_STATS	ARRAY_SIZE(qede_stats_arr)
 
+enum {
+	QEDE_PRI_FLAG_CMT,
+	QEDE_PRI_FLAG_LEN,
+};
+
+static const char qede_private_arr[QEDE_PRI_FLAG_LEN][ETH_GSTRING_LEN] = {
+	"Coupled-Function",
+};
+
 static void qede_get_strings_stats(struct qede_dev *edev, u8 *buf)
 {
 	int i, j, k;
@@ -139,6 +148,10 @@ static void qede_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 	case ETH_SS_STATS:
 		qede_get_strings_stats(edev, buf);
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		memcpy(buf, qede_private_arr,
+		       ETH_GSTRING_LEN * QEDE_PRI_FLAG_LEN);
+		break;
 	default:
 		DP_VERBOSE(edev, QED_MSG_DEBUG,
 			   "Unsupported stringset 0x%08x\n", stringset);
@@ -177,6 +190,8 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 	switch (stringset) {
 	case ETH_SS_STATS:
 		return num_stats + QEDE_NUM_RQSTATS;
+	case ETH_SS_PRIV_FLAGS:
+		return QEDE_PRI_FLAG_LEN;
 
 	default:
 		DP_VERBOSE(edev, QED_MSG_DEBUG,
@@ -185,6 +200,17 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 	}
 }
 
+static u32 qede_get_priv_flags(struct net_device *dev)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u32 flags = 0;
+
+	flags |= (!!(edev->dev_info.common.num_hwfns > 1)) <<
+		 QEDE_PRI_FLAG_CMT;
+
+	return flags;
+}
+
 static int qede_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct qede_dev *edev = netdev_priv(dev);
@@ -814,6 +840,7 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_strings = qede_get_strings,
 	.set_phys_id = qede_set_phys_id,
 	.get_ethtool_stats = qede_get_ethtool_stats,
+	.get_priv_flags = qede_get_priv_flags,
 	.get_sset_count = qede_get_sset_count,
 	.get_rxnfc = qede_get_rxnfc,
 	.set_rxnfc = qede_set_rxnfc,
-- 
1.9.3
