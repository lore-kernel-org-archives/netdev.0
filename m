From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 4/5] qede: Add get/set rx copy break tunable support
Date: Thu, 30 Jun 2016 02:35:21 -0400
Message-ID: <1467268522-24589-5-git-send-email-manish.chopra@qlogic.com>
References: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34725 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751383AbcF3HTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 03:19:51 -0400
In-Reply-To: <1467268522-24589-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  3 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 46 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  3 +-
 3 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 677213e..4e3f1a0 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -143,6 +143,8 @@ struct qede_dev {
 	struct mutex			qede_lock;
 	u32				state; /* Protected by qede_lock */
 	u16				rx_buf_size;
+	u32				rx_copybreak;
+
 	/* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
 #define ETH_OVERHEAD			(ETH_HLEN + 8 + 8)
 	/* Max supported alignment is 256 (8 shift)
@@ -333,6 +335,7 @@ void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, struct qede_dev *edev,
 #define NUM_TX_BDS_MIN		128
 #define NUM_TX_BDS_DEF		NUM_TX_BDS_MAX
 
+#define QEDE_MIN_PKT_LEN	64
 #define QEDE_RX_HDR_SIZE	256
 #define	for_each_rss(i) for (i = 0; i < edev->num_rss; i++)
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index f59322c..a4ba4fd 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1183,6 +1183,48 @@ static void qede_self_test(struct net_device *dev,
 	}
 }
 
+static int qede_set_tunable(struct net_device *dev,
+			    const struct ethtool_tunable *tuna,
+			    const void *data)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	u32 val;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		val = *(u32 *)data;
+		if (val < QEDE_MIN_PKT_LEN || val > QEDE_RX_HDR_SIZE) {
+			DP_VERBOSE(edev, QED_MSG_DEBUG,
+				   "Invalid rx copy break value, range is [%u, %u]",
+				   QEDE_MIN_PKT_LEN, QEDE_RX_HDR_SIZE);
+			return -EINVAL;
+		}
+
+		edev->rx_copybreak = *(u32 *)data;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int qede_get_tunable(struct net_device *dev,
+			    const struct ethtool_tunable *tuna, void *data)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		*(u32 *)data = edev->rx_copybreak;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops qede_ethtool_ops = {
 	.get_settings = qede_get_settings,
 	.set_settings = qede_set_settings,
@@ -1211,6 +1253,8 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_channels = qede_get_channels,
 	.set_channels = qede_set_channels,
 	.self_test = qede_self_test,
+	.get_tunable = qede_get_tunable,
+	.set_tunable = qede_set_tunable,
 };
 
 static const struct ethtool_ops qede_vf_ethtool_ops = {
@@ -1233,6 +1277,8 @@ static const struct ethtool_ops qede_vf_ethtool_ops = {
 	.set_rxfh = qede_set_rxfh,
 	.get_channels = qede_get_channels,
 	.set_channels = qede_set_channels,
+	.get_tunable = qede_get_tunable,
+	.set_tunable = qede_set_tunable,
 };
 
 void qede_set_ethtool_ops(struct net_device *dev)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 2c27b3b..482eaba 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1474,7 +1474,7 @@ alloc_skb:
 		}
 
 		/* Copy data into SKB */
-		if (len + pad <= QEDE_RX_HDR_SIZE) {
+		if (len + pad <= edev->rx_copybreak) {
 			memcpy(skb_put(skb, len),
 			       page_address(data) + pad +
 				sw_rx_data->page_offset, len);
@@ -2519,6 +2519,7 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	INIT_DELAYED_WORK(&edev->sp_task, qede_sp_task);
 	mutex_init(&edev->qede_lock);
+	edev->rx_copybreak = QEDE_RX_HDR_SIZE;
 
 	DP_INFO(edev, "Ending successfully qede probe\n");
 
-- 
2.7.2
