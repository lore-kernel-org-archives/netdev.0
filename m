From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/6] qede: Add support for {get, set}_channels
Date: Mon, 30 Nov 2015 12:25:01 +0200
Message-ID: <1448879106-12321-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:1410 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752481AbbK3K0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:11 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  1 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 53 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  7 +++-
 3 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index ea00d5f..a65a9b2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -116,6 +116,7 @@ struct qede_dev {
 				 (edev)->dev_info.num_tc)
 
 	struct qede_fastpath		*fp_array;
+	u16				req_rss;
 	u16				num_rss;
 	u8				num_tc;
 #define QEDE_RSS_CNT(edev)		((edev)->num_rss)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 3a36247..ea2fda8 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -366,6 +366,57 @@ int qede_change_mtu(struct net_device *ndev, int new_mtu)
 	return 0;
 }
 
+static void qede_get_channels(struct net_device *dev,
+			      struct ethtool_channels *channels)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	channels->max_combined = QEDE_MAX_RSS_CNT(edev);
+	channels->combined_count = QEDE_RSS_CNT(edev);
+}
+
+static int qede_set_channels(struct net_device *dev,
+			     struct ethtool_channels *channels)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+		   "set-channels command parameters: rx = %d, tx = %d, other = %d, combined = %d\n",
+		   channels->rx_count, channels->tx_count,
+		   channels->other_count, channels->combined_count);
+
+	/* We don't support separate rx / tx, nor `other' channels. */
+	if (channels->rx_count || channels->tx_count ||
+	    channels->other_count || (channels->combined_count == 0) ||
+	    (channels->combined_count > QEDE_MAX_RSS_CNT(edev))) {
+		DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+			   "command parameters not supported\n");
+		return -EINVAL;
+	}
+
+	/* Check if there was a change in the active parameters */
+	if (channels->combined_count == QEDE_RSS_CNT(edev)) {
+		DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+			   "No change in active parameters\n");
+		return 0;
+	}
+
+	/* We need the number of queues to be divisible between the hwfns */
+	if (channels->combined_count % edev->dev_info.common.num_hwfns) {
+		DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+			   "Number of channels must be divisable by %04x\n",
+			   edev->dev_info.common.num_hwfns);
+		return -EINVAL;
+	}
+
+	/* Set number of queues and reload if necessary */
+	edev->req_rss = channels->combined_count;
+	if (netif_running(dev))
+		qede_reload(edev, NULL, NULL);
+
+	return 0;
+}
+
 static const struct ethtool_ops qede_ethtool_ops = {
 	.get_settings = qede_get_settings,
 	.set_settings = qede_set_settings,
@@ -377,6 +428,8 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_ethtool_stats = qede_get_ethtool_stats,
 	.get_sset_count = qede_get_sset_count,
 
+	.get_channels = qede_get_channels,
+	.set_channels = qede_set_channels,
 };
 
 void qede_set_ethtool_ops(struct net_device *dev)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f4657a2..6237f10 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1502,8 +1502,11 @@ static int qede_set_num_queues(struct qede_dev *edev)
 	u16 rss_num;
 
 	/* Setup queues according to possible resources*/
-	rss_num = netif_get_num_default_rss_queues() *
-		  edev->dev_info.common.num_hwfns;
+	if (edev->req_rss)
+		rss_num = edev->req_rss;
+	else
+		rss_num = netif_get_num_default_rss_queues() *
+			  edev->dev_info.common.num_hwfns;
 
 	rss_num = min_t(u16, QEDE_MAX_RSS_CNT(edev), rss_num);
 
-- 
1.9.3
