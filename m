From: Junchang Wang <junchangwang@gmail.com>
Subject: [PATCH net-next v2] r8169: Add 64bit statistics
Date: Fri, 18 Nov 2011 10:15:31 +0800
Message-ID: <20111118021528.GA18674@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: nic_swsd@realtek.com, romieu@fr.zoreil.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43079 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab1KRCQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 21:16:02 -0500
Received: by ggnb2 with SMTP id b2so1923569ggn.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 18:16:01 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Switch to use ndo_get_stats64 to get 64bit statistics.
Two sync entries are used (one for Rx and one for Tx).


Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c |   61 +++++++++++++++++++++++++++++-----
 1 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cdf66d6..b9f8240 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -670,6 +670,12 @@ struct rtl8169_counters {
 	__le16	tx_underun;
 };
 
+struct rtl8169_stats {
+	struct u64_stats_sync	syncp;
+	u64			packets;
+	u64			bytes;
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;
@@ -685,6 +691,8 @@ struct rtl8169_private {
 	u32 dirty_tx;
 	struct TxDesc *TxDescArray;	/* 256-aligned Tx descriptor ring */
 	struct RxDesc *RxDescArray;	/* 256-aligned Rx descriptor ring */
+	struct rtl8169_stats rx_stats;
+	struct rtl8169_stats tx_stats;
 	dma_addr_t TxPhyAddr;
 	dma_addr_t RxPhyAddr;
 	void *Rx_databuff[NUM_RX_DESC];	/* Rx data buffers */
@@ -766,7 +774,9 @@ static void rtl_hw_start(struct net_device *dev);
 static int rtl8169_close(struct net_device *dev);
 static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
-static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
+static struct rtnl_link_stats64 *rtl8169_get_stats64(struct net_device *dev,
+						     struct rtnl_link_stats64
+						     *stats);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *, u32 budget);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
@@ -3454,7 +3464,7 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 static const struct net_device_ops rtl8169_netdev_ops = {
 	.ndo_open		= rtl8169_open,
 	.ndo_stop		= rtl8169_close,
-	.ndo_get_stats		= rtl8169_get_stats,
+	.ndo_get_stats64	= rtl8169_get_stats64,
 	.ndo_start_xmit		= rtl8169_start_xmit,
 	.ndo_tx_timeout		= rtl8169_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -5641,8 +5651,10 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_skb->skb->len;
+			u64_stats_update_begin(&tp->tx_stats.syncp);
+			tp->tx_stats.packets++;
+			tp->tx_stats.bytes += tx_skb->skb->len;
+			u64_stats_update_end(&tp->tx_stats.syncp);
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -5771,8 +5783,10 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			napi_gro_receive(&tp->napi, skb);
 
-			dev->stats.rx_bytes += pkt_size;
-			dev->stats.rx_packets++;
+			u64_stats_update_begin(&tp->rx_stats.syncp);
+			tp->rx_stats.packets++;
+			tp->rx_stats.bytes += pkt_size;
+			u64_stats_update_end(&tp->rx_stats.syncp);
 		}
 
 		/* Work around for AMD plateform. */
@@ -6034,16 +6048,19 @@ static void rtl_set_rx_mode(struct net_device *dev)
 }
 
 /**
- *  rtl8169_get_stats - Get rtl8169 read/write statistics
+ *  rtl8169_get_stats64 - Get rtl8169 read/write statistics
  *  @dev: The Ethernet Device to get statistics for
  *
  *  Get TX/RX statistics for rtl8169
  */
-static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *
+rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	u64 _packets, _bytes;
 	unsigned long flags;
+	unsigned int start;
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
@@ -6051,7 +6068,33 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
-	return &dev->stats;
+	do {
+		start = u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
+		_packets = tp->rx_stats.packets;
+		_bytes = tp->rx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));
+
+	stats->rx_packets = _packets;
+	stats->rx_bytes	= _bytes;
+
+	do {
+		start = u64_stats_fetch_begin_bh(&tp->tx_stats.syncp);
+		_packets = tp->tx_stats.packets;
+		_bytes= tp->tx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&tp->tx_stats.syncp, start));
+
+	stats->tx_packets = _packets;
+	stats->tx_bytes	= _bytes;
+
+	stats->rx_dropped	= dev->stats.rx_dropped;
+	stats->tx_dropped	= dev->stats.tx_dropped;
+	stats->rx_length_errors = dev->stats.rx_length_errors;
+	stats->rx_errors	= dev->stats.rx_errors;
+	stats->rx_crc_errors	= dev->stats.rx_crc_errors;
+	stats->rx_fifo_errors	= dev->stats.rx_fifo_errors;
+	stats->rx_missed_errors = dev->stats.rx_missed_errors;
+
+	return stats;
 }
 
 static void rtl8169_net_suspend(struct net_device *dev)
--
