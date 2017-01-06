From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next v1 3/8] net: netcp: store network statistics in 64 bits
Date: Fri, 6 Jan 2017 15:37:41 -0500
Message-ID: <1483735066-14632-4-git-send-email-m-karicheri2@ti.com>
References: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>,
        <linux-omap@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:59639 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938841AbdAFUhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:37:52 -0500
In-Reply-To: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Scherban <m-scherban@ti.com>

Previously the network statistics were stored in 32 bit variable
which can cause some stats to roll over after several minutes of
high traffic. This implements 64 bit storage so larger numbers
can be stored.

Signed-off-by: Michael Scherban <m-scherban@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/netcp.h      | 18 ++++++++++
 drivers/net/ethernet/ti/netcp_core.c | 68 +++++++++++++++++++++++++++++-------
 2 files changed, 74 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
index a92abd6..d243c5d 100644
--- a/drivers/net/ethernet/ti/netcp.h
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -23,6 +23,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/soc/ti/knav_dma.h>
+#include <linux/u64_stats_sync.h>
 
 /* Maximum Ethernet frame size supported by Keystone switch */
 #define NETCP_MAX_FRAME_SIZE		9504
@@ -68,6 +69,20 @@ struct netcp_addr {
 	struct list_head	node;
 };
 
+struct netcp_stats {
+	struct u64_stats_sync   syncp_rx ____cacheline_aligned_in_smp;
+	u64                     rx_packets;
+	u64                     rx_bytes;
+	u32                     rx_errors;
+	u32                     rx_dropped;
+
+	struct u64_stats_sync   syncp_tx ____cacheline_aligned_in_smp;
+	u64                     tx_packets;
+	u64                     tx_bytes;
+	u32                     tx_errors;
+	u32                     tx_dropped;
+};
+
 struct netcp_intf {
 	struct device		*dev;
 	struct device		*ndev_dev;
@@ -88,6 +103,9 @@ struct netcp_intf {
 	struct napi_struct	rx_napi;
 	struct napi_struct	tx_napi;
 
+	/* 64-bit netcp stats */
+	struct netcp_stats	stats;
+
 	void			*rx_channel;
 	const char		*dma_chan_name;
 	u32			rx_pool_size;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 286fd8d..b077ed4 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -629,6 +629,7 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
 
 static void netcp_empty_rx_queue(struct netcp_intf *netcp)
 {
+	struct netcp_stats *rx_stats = &netcp->stats;
 	struct knav_dma_desc *desc;
 	unsigned int dma_sz;
 	dma_addr_t dma;
@@ -642,16 +643,17 @@ static void netcp_empty_rx_queue(struct netcp_intf *netcp)
 		if (unlikely(!desc)) {
 			dev_err(netcp->ndev_dev, "%s: failed to unmap Rx desc\n",
 				__func__);
-			netcp->ndev->stats.rx_errors++;
+			rx_stats->rx_errors++;
 			continue;
 		}
 		netcp_free_rx_desc_chain(netcp, desc);
-		netcp->ndev->stats.rx_dropped++;
+		rx_stats->rx_dropped++;
 	}
 }
 
 static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 {
+	struct netcp_stats *rx_stats = &netcp->stats;
 	unsigned int dma_sz, buf_len, org_buf_len;
 	struct knav_dma_desc *desc, *ndesc;
 	unsigned int pkt_sz = 0, accum_sz;
@@ -757,8 +759,8 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 		if (unlikely(ret)) {
 			dev_err(netcp->ndev_dev, "RX hook %d failed: %d\n",
 				rx_hook->order, ret);
-			netcp->ndev->stats.rx_errors++;
 			/* Free the primary descriptor */
+			rx_stats->rx_dropped++;
 			knav_pool_desc_put(netcp->rx_pool, desc);
 			dev_kfree_skb(skb);
 			return 0;
@@ -767,8 +769,10 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 	/* Free the primary descriptor */
 	knav_pool_desc_put(netcp->rx_pool, desc);
 
-	netcp->ndev->stats.rx_packets++;
-	netcp->ndev->stats.rx_bytes += skb->len;
+	u64_stats_update_begin(&rx_stats->syncp_rx);
+	rx_stats->rx_packets++;
+	rx_stats->rx_bytes += skb->len;
+	u64_stats_update_end(&rx_stats->syncp_rx);
 
 	/* push skb up the stack */
 	skb->protocol = eth_type_trans(skb, netcp->ndev);
@@ -777,7 +781,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
 
 free_desc:
 	netcp_free_rx_desc_chain(netcp, desc);
-	netcp->ndev->stats.rx_errors++;
+	rx_stats->rx_errors++;
 	return 0;
 }
 
@@ -1008,6 +1012,7 @@ static void netcp_free_tx_desc_chain(struct netcp_intf *netcp,
 static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 					  unsigned int budget)
 {
+	struct netcp_stats *tx_stats = &netcp->stats;
 	struct knav_dma_desc *desc;
 	struct netcp_tx_cb *tx_cb;
 	struct sk_buff *skb;
@@ -1022,7 +1027,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 		desc = knav_pool_desc_unmap(netcp->tx_pool, dma, dma_sz);
 		if (unlikely(!desc)) {
 			dev_err(netcp->ndev_dev, "failed to unmap Tx desc\n");
-			netcp->ndev->stats.tx_errors++;
+			tx_stats->tx_errors++;
 			continue;
 		}
 
@@ -1033,7 +1038,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
 		if (!skb) {
 			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
-			netcp->ndev->stats.tx_errors++;
+			tx_stats->tx_errors++;
 			continue;
 		}
 
@@ -1050,8 +1055,10 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
 			netif_wake_subqueue(netcp->ndev, subqueue);
 		}
 
-		netcp->ndev->stats.tx_packets++;
-		netcp->ndev->stats.tx_bytes += skb->len;
+		u64_stats_update_begin(&tx_stats->syncp_tx);
+		tx_stats->tx_packets++;
+		tx_stats->tx_bytes += skb->len;
+		u64_stats_update_end(&tx_stats->syncp_tx);
 		dev_kfree_skb(skb);
 		pkts++;
 	}
@@ -1272,6 +1279,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_stats *tx_stats = &netcp->stats;
 	int subqueue = skb_get_queue_mapping(skb);
 	struct knav_dma_desc *desc;
 	int desc_count, ret = 0;
@@ -1287,7 +1295,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 			/* If we get here, the skb has already been dropped */
 			dev_warn(netcp->ndev_dev, "padding failed (%d), packet dropped\n",
 				 ret);
-			ndev->stats.tx_dropped++;
+			tx_stats->tx_dropped++;
 			return ret;
 		}
 		skb->len = NETCP_MIN_PACKET_SIZE;
@@ -1315,7 +1323,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	return NETDEV_TX_OK;
 
 drop:
-	ndev->stats.tx_dropped++;
+	tx_stats->tx_dropped++;
 	if (desc)
 		netcp_free_tx_desc_chain(netcp, desc, sizeof(*desc));
 	dev_kfree_skb(skb);
@@ -1897,12 +1905,46 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	return 0;
 }
 
+static struct rtnl_link_stats64 *
+netcp_get_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
+{
+	struct netcp_intf *netcp = netdev_priv(ndev);
+	struct netcp_stats *p = &netcp->stats;
+	u64 rxpackets, rxbytes, txpackets, txbytes;
+	unsigned int start;
+
+	do {
+		start = u64_stats_fetch_begin_irq(&p->syncp_rx);
+		rxpackets       = p->rx_packets;
+		rxbytes         = p->rx_bytes;
+	} while (u64_stats_fetch_retry_irq(&p->syncp_rx, start));
+
+	do {
+		start = u64_stats_fetch_begin_irq(&p->syncp_tx);
+		txpackets       = p->tx_packets;
+		txbytes         = p->tx_bytes;
+	} while (u64_stats_fetch_retry_irq(&p->syncp_tx, start));
+
+	stats->rx_packets = rxpackets;
+	stats->rx_bytes = rxbytes;
+	stats->tx_packets = txpackets;
+	stats->tx_bytes = txbytes;
+
+	/* The following are stored as 32 bit */
+	stats->rx_errors = p->rx_errors;
+	stats->rx_dropped = p->rx_dropped;
+	stats->tx_dropped = p->tx_dropped;
+
+	return stats;
+}
+
 static const struct net_device_ops netcp_netdev_ops = {
 	.ndo_open		= netcp_ndo_open,
 	.ndo_stop		= netcp_ndo_stop,
 	.ndo_start_xmit		= netcp_ndo_start_xmit,
 	.ndo_set_rx_mode	= netcp_set_rx_mode,
 	.ndo_do_ioctl           = netcp_ndo_ioctl,
+	.ndo_get_stats64        = netcp_get_stats,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_add_vid	= netcp_rx_add_vid,
@@ -1949,6 +1991,8 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	INIT_LIST_HEAD(&netcp->txhook_list_head);
 	INIT_LIST_HEAD(&netcp->rxhook_list_head);
 	INIT_LIST_HEAD(&netcp->addr_list);
+	u64_stats_init(&netcp->stats.syncp_rx);
+	u64_stats_init(&netcp->stats.syncp_tx);
 	netcp->netcp_device = netcp_device;
 	netcp->dev = netcp_device->device;
 	netcp->ndev = ndev;
-- 
1.9.1
