From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'davem-next.r8169' branch
Date: Tue, 6 Mar 2012 00:33:58 +0100
Message-ID: <20120305233358.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Igor Maravic <igorm@etf.rs>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56095 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757788Ab2CEXew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 18:34:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Same content as yesterday; Eric's Ack is included.

Distance from 'davem-next' (18f973af3e7028620186d1c1ace044506bb6229e)
---------------------------------------------------------------------

036dafa28da1e2565a8529de2ae663c37b7a0060
8027aa245bbd125350f6a78c5a78771d143aba55

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |   78 +++++++++++++++++++++++++++-------
 1 files changed, 63 insertions(+), 15 deletions(-)

Shortlog
--------

Igor Maravic (1):
      r8169: add byte queue limit support.

Junchang Wang (1):
      r8169: add 64bit statistics.

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index fbd855b..515a7ed 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -675,6 +675,12 @@ enum rtl_flag {
 	RTL_FLAG_MAX
 };
 
+struct rtl8169_stats {
+	u64			packets;
+	u64			bytes;
+	struct u64_stats_sync	syncp;
+};
+
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;
@@ -687,6 +693,8 @@ struct rtl8169_private {
 	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
 	u32 dirty_rx;
 	u32 dirty_tx;
+	struct rtl8169_stats rx_stats;
+	struct rtl8169_stats tx_stats;
 	struct TxDesc *TxDescArray;	/* 256-aligned Tx descriptor ring */
 	struct RxDesc *RxDescArray;	/* 256-aligned Rx descriptor ring */
 	dma_addr_t TxPhyAddr;
@@ -775,7 +783,9 @@ static void rtl_hw_start(struct net_device *dev);
 static int rtl8169_close(struct net_device *dev);
 static void rtl_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
-static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
+static struct rtnl_link_stats64 *rtl8169_get_stats64(struct net_device *dev,
+						    struct rtnl_link_stats64
+						    *stats);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_rx_clear(struct rtl8169_private *tp);
 static int rtl8169_poll(struct napi_struct *napi, int budget);
@@ -3521,7 +3531,7 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 static const struct net_device_ops rtl8169_netdev_ops = {
 	.ndo_open		= rtl8169_open,
 	.ndo_stop		= rtl8169_close,
-	.ndo_get_stats		= rtl8169_get_stats,
+	.ndo_get_stats64	= rtl8169_get_stats64,
 	.ndo_start_xmit		= rtl8169_start_xmit,
 	.ndo_tx_timeout		= rtl8169_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -5389,6 +5399,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 {
 	rtl8169_tx_clear_range(tp, tp->dirty_tx, NUM_TX_DESC);
 	tp->cur_tx = tp->dirty_tx = 0;
+	netdev_reset_queue(tp->dev);
 }
 
 static void rtl_reset_work(struct rtl8169_private *tp)
@@ -5543,6 +5554,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	txd->opts2 = cpu_to_le32(opts[1]);
 
+	netdev_sent_queue(dev, skb->len);
+
 	wmb();
 
 	/* Anti gcc 2.95.3 bugware (sic) */
@@ -5637,9 +5650,16 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
+struct rtl_txc {
+	int packets;
+	int bytes;
+};
+
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
+	struct rtl8169_stats *tx_stats = &tp->tx_stats;
 	unsigned int dirty_tx, tx_left;
+	struct rtl_txc txc = { 0, 0 };
 
 	dirty_tx = tp->dirty_tx;
 	smp_rmb();
@@ -5658,15 +5678,24 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
 		if (status & LastFrag) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_skb->skb->len;
-			dev_kfree_skb(tx_skb->skb);
+			struct sk_buff *skb = tx_skb->skb;
+
+			txc.packets++;
+			txc.bytes += skb->len;
+			dev_kfree_skb(skb);
 			tx_skb->skb = NULL;
 		}
 		dirty_tx++;
 		tx_left--;
 	}
 
+	u64_stats_update_begin(&tx_stats->syncp);
+	tx_stats->packets += txc.packets;
+	tx_stats->bytes += txc.bytes;
+	u64_stats_update_end(&tx_stats->syncp);
+
+	netdev_completed_queue(dev, txc.packets, txc.bytes);
+
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		/* Sync with rtl8169_start_xmit:
@@ -5807,8 +5836,10 @@ process_pkt:
 
 			napi_gro_receive(&tp->napi, skb);
 
-			dev->stats.rx_bytes += pkt_size;
-			dev->stats.rx_packets++;
+			u64_stats_update_begin(&tp->rx_stats.syncp);
+			tp->rx_stats.packets++;
+			tp->rx_stats.bytes += pkt_size;
+			u64_stats_update_end(&tp->rx_stats.syncp);
 		}
 
 		/* Work around for AMD plateform. */
@@ -6069,21 +6100,38 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	RTL_W32(RxConfig, tmp);
 }
 
-/**
- *  rtl8169_get_stats - Get rtl8169 read/write statistics
- *  @dev: The Ethernet Device to get statistics for
- *
- *  Get TX/RX statistics for rtl8169
- */
-static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *
+rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	unsigned int start;
 
 	if (netif_running(dev))
 		rtl8169_rx_missed(dev, ioaddr);
 
-	return &dev->stats;
+	do {
+		start = u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
+		stats->rx_packets = tp->rx_stats.packets;
+		stats->rx_bytes	= tp->rx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));
+
+
+	do {
+		start = u64_stats_fetch_begin_bh(&tp->tx_stats.syncp);
+		stats->tx_packets = tp->tx_stats.packets;
+		stats->tx_bytes	= tp->tx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&tp->tx_stats.syncp, start));
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
Ueimor
