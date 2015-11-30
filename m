From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/6] qede: Add support for {get, set}_ringparam
Date: Mon, 30 Nov 2015 12:25:02 +0200
Message-ID: <1448879106-12321-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37922 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613AbbK3K0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:14 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  4 +--
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 44 +++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index a65a9b2..7c6caf7 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -270,13 +270,13 @@ int qede_change_mtu(struct net_device *dev, int new_mtu);
 void qede_fill_by_demand_stats(struct qede_dev *edev);
 
 #define RX_RING_SIZE_POW	13
-#define RX_RING_SIZE		BIT(RX_RING_SIZE_POW)
+#define RX_RING_SIZE		((u16)BIT(RX_RING_SIZE_POW))
 #define NUM_RX_BDS_MAX		(RX_RING_SIZE - 1)
 #define NUM_RX_BDS_MIN		128
 #define NUM_RX_BDS_DEF		NUM_RX_BDS_MAX
 
 #define TX_RING_SIZE_POW	13
-#define TX_RING_SIZE		BIT(TX_RING_SIZE_POW)
+#define TX_RING_SIZE		((u16)BIT(TX_RING_SIZE_POW))
 #define NUM_TX_BDS_MAX		(TX_RING_SIZE - 1)
 #define NUM_TX_BDS_MIN		128
 #define NUM_TX_BDS_DEF		NUM_TX_BDS_MAX
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index ea2fda8..10d80ba 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -333,6 +333,48 @@ static u32 qede_get_link(struct net_device *dev)
 	return current_link.link_up;
 }
 
+static void qede_get_ringparam(struct net_device *dev,
+			       struct ethtool_ringparam *ering)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	ering->rx_max_pending = NUM_RX_BDS_MAX;
+	ering->rx_pending = edev->q_num_rx_buffers;
+	ering->tx_max_pending = NUM_TX_BDS_MAX;
+	ering->tx_pending = edev->q_num_tx_buffers;
+}
+
+static int qede_set_ringparam(struct net_device *dev,
+			      struct ethtool_ringparam *ering)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+		   "Set ring params command parameters: rx_pending = %d, tx_pending = %d\n",
+		   ering->rx_pending, ering->tx_pending);
+
+	/* Validate legality of configuration */
+	if (ering->rx_pending > NUM_RX_BDS_MAX ||
+	    ering->rx_pending < NUM_RX_BDS_MIN ||
+	    ering->tx_pending > NUM_TX_BDS_MAX ||
+	    ering->tx_pending < NUM_TX_BDS_MIN) {
+		DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+			   "Can only support Rx Buffer size [0%08x,...,0x%08x] and Tx Buffer size [0x%08x,...,0x%08x]\n",
+			   NUM_RX_BDS_MIN, NUM_RX_BDS_MAX,
+			   NUM_TX_BDS_MIN, NUM_TX_BDS_MAX);
+		return -EINVAL;
+	}
+
+	/* Change ring size and re-load */
+	edev->q_num_rx_buffers = ering->rx_pending;
+	edev->q_num_tx_buffers = ering->tx_pending;
+
+	if (netif_running(edev->ndev))
+		qede_reload(edev, NULL, NULL);
+
+	return 0;
+}
+
 static void qede_update_mtu(struct qede_dev *edev, union qede_reload_args *args)
 {
 	edev->ndev->mtu = args->mtu;
@@ -424,6 +466,8 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_msglevel = qede_get_msglevel,
 	.set_msglevel = qede_set_msglevel,
 	.get_link = qede_get_link,
+	.get_ringparam = qede_get_ringparam,
+	.set_ringparam = qede_set_ringparam,
 	.get_strings = qede_get_strings,
 	.get_ethtool_stats = qede_get_ethtool_stats,
 	.get_sset_count = qede_get_sset_count,
-- 
1.9.3
