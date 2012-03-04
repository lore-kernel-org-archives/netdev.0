From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Mon, 5 Mar 2012 00:24:53 +0100
Message-ID: <20120304232453.GA32314@electric-eye.fr.zoreil.com>
References: <20120304093727.GA5115@Spy32> <1330875881.2730.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Junchang Wang <junchangwang@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53288 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753965Ab2CDXZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 18:25:34 -0500
Content-Disposition: inline
In-Reply-To: <1330875881.2730.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> small point : Using this means you have a 32bit hole here (on 32bit
> build). Its minor, you dont need to change.

Ok.

[...]
> 	You could try to put these somewhere else, to try to keep this portion
> as read only memory, to be more SMP friendly.
> (Some loaded server could have one CPU serving RX stuff, and other cpus
> doing TX stuff) 

Point taken. It could make sense to rework the rtl8169_private struct a bit
more.

[...]
> > @@ -6070,20 +6084,49 @@ static void rtl_set_rx_mode(struct net_device *dev)
> >  }
> >  
> >  /**
> > - *  rtl8169_get_stats - Get rtl8169 read/write statistics
> > + *  rtl8169_get_stats64 - Get rtl8169 read/write statistics
> >   *  @dev: The Ethernet Device to get statistics for
> 
> missing @stats

This documentation is almost useless anyway. I removed it.

[...]
> You dont need _bytes and _packets temp variables, as @stats points to a
> private memory, we can use it as working storage, just do :
> 
>        do {
>                start = u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
>                stats->rx_packets = tp->rx_stats.packets;
>                stats->rx_bytes = tp->rx_stats.bytes;
>        } while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));

It should give something like the patch below.

If I understand correctly we do not care much about the error counters,
right ?

From: Junchang Wang <junchangwang@gmail.com>
Date: Sun, 4 Mar 2012 23:30:32 +0100
Subject: [PATCH 1/2] r8169: add 64bit statistics.

Switch to use ndo_get_stats64 to get 64bit statistics.
Two sync entries are used (one for Rx and one for Tx).

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   59 ++++++++++++++++++++++++++--------
 1 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index fbd855b..a4d7674 100644
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
@@ -5658,8 +5668,10 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
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
@@ -5807,8 +5819,10 @@ process_pkt:
 
 			napi_gro_receive(&tp->napi, skb);
 
-			dev->stats.rx_bytes += pkt_size;
-			dev->stats.rx_packets++;
+			u64_stats_update_begin(&tp->rx_stats.syncp);
+			tp->rx_stats.packets++;
+			tp->rx_stats.bytes += pkt_size;
+			u64_stats_update_end(&tp->rx_stats.syncp);
 		}
 
 		/* Work around for AMD plateform. */
@@ -6069,21 +6083,38 @@ static void rtl_set_rx_mode(struct net_device *dev)
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
1.7.7.6
