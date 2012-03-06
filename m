From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next V2] 8139too: Add 64bit statistics
Date: Tue, 6 Mar 2012 11:13:05 +0800
Message-ID: <20120306031301.GA4516@Spy32>
References: <20120305113353.GA12969@Spy32>
 <1330954326.2474.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, adobriyan@gmail.com, jasowang@redhat.com,
	joe@perches.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64444 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab2CFDLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 22:11:40 -0500
Received: by iagz16 with SMTP id z16so6441297iag.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 19:11:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1330954326.2474.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Switch to use ndo_get_stats64 to get 64bit statistics.
Two sync entries are used (one for Rx and one for Tx).

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
V2: based on Eric's patch "net: export netdev_stats_to_stats64"

 drivers/net/ethernet/realtek/8139too.c |   46 ++++++++++++++++++++++++++-----
 1 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index abd6aca..df7fd8d 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -565,6 +565,12 @@ struct rtl_extra_stats {
 	unsigned long rx_lost_in_ring;
 };
 
+struct rtl8139_stats {
+	u64	packets;
+	u64	bytes;
+	struct u64_stats_sync	syncp;
+};
+
 struct rtl8139_private {
 	void __iomem		*mmio_addr;
 	int			drv_flags;
@@ -575,11 +581,13 @@ struct rtl8139_private {
 
 	unsigned char		*rx_ring;
 	unsigned int		cur_rx;	/* RX buf index of next pkt */
+	struct rtl8139_stats	rx_stats;
 	dma_addr_t		rx_ring_dma;
 
 	unsigned int		tx_flag;
 	unsigned long		cur_tx;
 	unsigned long		dirty_tx;
+	struct rtl8139_stats	tx_stats;
 	unsigned char		*tx_buf[NUM_TX_DESC];	/* Tx bounce buffers */
 	unsigned char		*tx_bufs;	/* Tx bounce buffer region. */
 	dma_addr_t		tx_bufs_dma;
@@ -641,7 +649,9 @@ static int rtl8139_poll(struct napi_struct *napi, int budget);
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance);
 static int rtl8139_close (struct net_device *dev);
 static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
-static struct net_device_stats *rtl8139_get_stats (struct net_device *dev);
+static struct rtnl_link_stats64 *rtl8139_get_stats64(struct net_device *dev,
+						    struct rtnl_link_stats64
+						    *stats);
 static void rtl8139_set_rx_mode (struct net_device *dev);
 static void __set_rx_mode (struct net_device *dev);
 static void rtl8139_hw_start (struct net_device *dev);
@@ -937,7 +947,7 @@ static int rtl8139_set_features(struct net_device *dev, netdev_features_t featur
 static const struct net_device_ops rtl8139_netdev_ops = {
 	.ndo_open		= rtl8139_open,
 	.ndo_stop		= rtl8139_close,
-	.ndo_get_stats		= rtl8139_get_stats,
+	.ndo_get_stats64	= rtl8139_get_stats64,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= rtl8139_set_mac_address,
@@ -1807,8 +1817,10 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
 				dev->stats.tx_fifo_errors++;
 			}
 			dev->stats.collisions += (txstatus >> 24) & 15;
-			dev->stats.tx_bytes += txstatus & 0x7ff;
-			dev->stats.tx_packets++;
+			u64_stats_update_begin(&tp->tx_stats.syncp);
+			tp->tx_stats.packets++;
+			tp->tx_stats.bytes += txstatus & 0x7ff;
+			u64_stats_update_end(&tp->tx_stats.syncp);
 		}
 
 		dirty_tx++;
@@ -2050,8 +2062,10 @@ keep_pkt:
 
 			skb->protocol = eth_type_trans (skb, dev);
 
-			dev->stats.rx_bytes += pkt_size;
-			dev->stats.rx_packets++;
+			u64_stats_update_begin(&tp->rx_stats.syncp);
+			tp->rx_stats.packets++;
+			tp->rx_stats.bytes += pkt_size;
+			u64_stats_update_end(&tp->rx_stats.syncp);
 
 			netif_receive_skb (skb);
 		} else {
@@ -2515,11 +2529,13 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
+static struct rtnl_link_stats64 *
+rtl8139_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long flags;
+	unsigned int start;
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave (&tp->lock, flags);
@@ -2528,7 +2544,21 @@ static struct net_device_stats *rtl8139_get_stats (struct net_device *dev)
 		spin_unlock_irqrestore (&tp->lock, flags);
 	}
 
-	return &dev->stats;
+	netdev_stats_to_stats64(stats, &dev->stats);
+
+	do {
+		start = u64_stats_fetch_begin_bh(&tp->rx_stats.syncp);
+		stats->rx_packets = tp->rx_stats.packets;
+		stats->rx_bytes = tp->rx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start));
+
+	do {
+		start = u64_stats_fetch_begin_bh(&tp->tx_stats.syncp);
+		stats->tx_packets = tp->tx_stats.packets;
+		stats->tx_bytes = tp->tx_stats.bytes;
+	} while (u64_stats_fetch_retry_bh(&tp->tx_stats.syncp, start));
+
+	return stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.
--
