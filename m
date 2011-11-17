From: Junchang Wang <junchangwang@gmail.com>
Subject: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 14:48:30 +0800
Message-ID: <20111117064826.GA4429@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com, nic_swsd@realtek.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64948 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab1KQGtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 01:49:22 -0500
Received: by ywt32 with SMTP id 32so657503ywt.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 22:49:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Switch to use ndo_get_stats64 to get 64bit statistics.
Per cpu data is used to avoid lock operations.


Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c |  113 ++++++++++++++++++++++++++++------
 1 files changed, 93 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cdf66d6..0165646 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -670,11 +670,31 @@ struct rtl8169_counters {
 	__le16	tx_underun;
 };
 
+struct rtl8169_pcpu_stats {
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+	/*
+	 * The following variables are updated
+	 * without syncp protection.
+	 */
+	unsigned long		rx_dropped;
+	unsigned long		tx_dropped;
+	unsigned long		rx_length_errors;
+	unsigned long		rx_errors;
+	unsigned long		rx_crc_errors;
+	unsigned long		rx_fifo_errors;
+	unsigned long		rx_missed_errors;
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;
 	struct net_device *dev;
 	struct napi_struct napi;
+	struct rtl8169_pcpu_stats __percpu *pcpu_stats;
 	spinlock_t lock;
 	u32 msg_enable;
 	u16 txd_version;
@@ -766,7 +786,9 @@ static void rtl_hw_start(struct net_device *dev);
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
@@ -3454,7 +3476,7 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 static const struct net_device_ops rtl8169_netdev_ops = {
 	.ndo_open		= rtl8169_open,
 	.ndo_stop		= rtl8169_close,
-	.ndo_get_stats		= rtl8169_get_stats,
+	.ndo_get_stats64	= rtl8169_get_stats64,
 	.ndo_start_xmit		= rtl8169_start_xmit,
 	.ndo_tx_timeout		= rtl8169_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -4138,6 +4160,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
+	tp->pcpu_stats = alloc_percpu(struct rtl8169_pcpu_stats);
 	rc = register_netdev(dev);
 	if (rc < 0)
 		goto err_out_msi_4;
@@ -4196,6 +4219,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 
 	cancel_delayed_work_sync(&tp->task);
 
+	free_percpu(tp->pcpu_stats);
 	unregister_netdev(dev);
 
 	rtl_release_firmware(tp);
@@ -5310,7 +5334,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
 			rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 					     tp->TxDescArray + entry);
 			if (skb) {
-				tp->dev->stats.tx_dropped++;
+				this_cpu_inc(tp->pcpu_stats->tx_dropped);
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
 			}
@@ -5562,12 +5586,12 @@ err_dma_1:
 	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
 err_dma_0:
 	dev_kfree_skb(skb);
-	dev->stats.tx_dropped++;
+	this_cpu_inc(tp->pcpu_stats->tx_dropped);
 	return NETDEV_TX_OK;
 
 err_stop_0:
 	netif_stop_queue(dev);
-	dev->stats.tx_dropped++;
+	this_cpu_inc(tp->pcpu_stats->tx_dropped);
 	return NETDEV_TX_BUSY;
 }
 
@@ -5641,8 +5665,13 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_skb->skb->len;
+			struct rtl8169_pcpu_stats *pcpu_stats;
+
+			pcpu_stats = this_cpu_ptr(tp->pcpu_stats);
+			u64_stats_update_begin(&pcpu_stats->syncp);
+			pcpu_stats->tx_packets++;
+			pcpu_stats->tx_bytes += tx_skb->skb->len;
+			u64_stats_update_end(&pcpu_stats->syncp);
 			dev_kfree_skb(tx_skb->skb);
 			tx_skb->skb = NULL;
 		}
@@ -5728,20 +5757,21 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 		if (unlikely(status & RxRES)) {
 			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
 				   status);
-			dev->stats.rx_errors++;
+			this_cpu_inc(tp->pcpu_stats->rx_errors);
 			if (status & (RxRWT | RxRUNT))
-				dev->stats.rx_length_errors++;
+				this_cpu_inc(tp->pcpu_stats->rx_length_errors);
 			if (status & RxCRC)
-				dev->stats.rx_crc_errors++;
+				this_cpu_inc(tp->pcpu_stats->rx_crc_errors);
 			if (status & RxFOVF) {
 				rtl8169_schedule_work(dev, rtl8169_reset_task);
-				dev->stats.rx_fifo_errors++;
+				this_cpu_inc(tp->pcpu_stats->rx_fifo_errors);
 			}
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
 		} else {
 			struct sk_buff *skb;
 			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00003fff) - 4;
+			struct rtl8169_pcpu_stats *pcpu_stats;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -5749,8 +5779,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			 * sized frames.
 			 */
 			if (unlikely(rtl8169_fragmented_frame(status))) {
-				dev->stats.rx_dropped++;
-				dev->stats.rx_length_errors++;
+				this_cpu_inc(tp->pcpu_stats->rx_dropped);
+				this_cpu_inc(tp->pcpu_stats->rx_length_errors);
 				rtl8169_mark_to_asic(desc, rx_buf_sz);
 				continue;
 			}
@@ -5759,7 +5789,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 						  tp, pkt_size, addr);
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
 			if (!skb) {
-				dev->stats.rx_dropped++;
+				this_cpu_inc(tp->pcpu_stats->rx_dropped);
 				continue;
 			}
 
@@ -5771,8 +5801,11 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			napi_gro_receive(&tp->napi, skb);
 
-			dev->stats.rx_bytes += pkt_size;
-			dev->stats.rx_packets++;
+			pcpu_stats = this_cpu_ptr(tp->pcpu_stats);
+			u64_stats_update_begin(&pcpu_stats->syncp);
+			pcpu_stats->rx_bytes += pkt_size;
+			pcpu_stats->rx_packets++;
+			u64_stats_update_end(&pcpu_stats->syncp);
 		}
 
 		/* Work around for AMD plateform. */
@@ -5916,7 +5949,8 @@ static void rtl8169_rx_missed(struct net_device *dev, void __iomem *ioaddr)
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06)
 		return;
 
-	dev->stats.rx_missed_errors += (RTL_R32(RxMissed) & 0xffffff);
+	this_cpu_add(tp->pcpu_stats->rx_missed_errors,
+		     (RTL_R32(RxMissed) & 0xffffff));
 	RTL_W32(RxMissed, 0);
 }
 
@@ -6034,16 +6068,24 @@ static void rtl_set_rx_mode(struct net_device *dev)
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
+	struct rtl8169_pcpu_stats *pcpu_stats;
+	u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+	unsigned long rx_dropped = 0, tx_dropped = 0, rx_length_errors = 0;
+	unsigned long rx_errors = 0, rx_crc_errors = 0, rx_fifo_errors = 0;
+	unsigned long rx_missed_errors = 0;
 	unsigned long flags;
+	unsigned int start;
+	int i;
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
@@ -6051,7 +6093,38 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
-	return &dev->stats;
+	for_each_possible_cpu(i) {
+		pcpu_stats = per_cpu_ptr(tp->pcpu_stats, i);
+		do {
+			start = u64_stats_fetch_begin_bh(&pcpu_stats->syncp);
+			rx_packets	= pcpu_stats->rx_packets;
+			rx_bytes	= pcpu_stats->rx_bytes;
+			tx_packets	= pcpu_stats->tx_packets;
+			tx_bytes	= pcpu_stats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&pcpu_stats->syncp, start));
+
+		stats->rx_packets	+= rx_packets;
+		stats->rx_bytes		+= rx_bytes;
+		stats->tx_packets	+= tx_packets;
+		stats->tx_bytes		+= tx_bytes;
+
+		rx_dropped		+= pcpu_stats->rx_dropped;
+		tx_dropped		+= pcpu_stats->tx_dropped;
+		rx_length_errors	+= pcpu_stats->rx_length_errors;
+		rx_errors		+= pcpu_stats->rx_errors;
+		rx_crc_errors		+= pcpu_stats->rx_crc_errors;
+		rx_fifo_errors		+= pcpu_stats->rx_fifo_errors;
+		rx_missed_errors	+= pcpu_stats->rx_missed_errors;
+	}
+	stats->rx_dropped	= rx_dropped;
+	stats->tx_dropped	= tx_dropped;
+	stats->rx_length_errors = rx_length_errors;
+	stats->rx_errors	= rx_errors;
+	stats->rx_crc_errors	= rx_crc_errors;
+	stats->rx_fifo_errors	= rx_fifo_errors;
+	stats->rx_missed_errors = rx_missed_errors;
+
+	return stats;
 }
 
 static void rtl8169_net_suspend(struct net_device *dev)
