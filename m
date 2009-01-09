From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 24/45] lanstreamer: convert to internal network stats
Date: Fri, 09 Jan 2009 15:01:21 -0800
Message-ID: <20090109230138.483767420@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42216 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754235AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=tr-lanstream-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use internal network_device_stats to keep track of statistics.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/tokenring/lanstreamer.c |   17 +++++------------
 drivers/net/tokenring/lanstreamer.h |    1 -
 2 files changed, 5 insertions(+), 13 deletions(-)

--- a/drivers/net/tokenring/lanstreamer.c	2009-01-09 10:03:58.000000000 -0800
+++ b/drivers/net/tokenring/lanstreamer.c	2009-01-09 10:06:09.000000000 -0800
@@ -207,7 +207,6 @@ static int streamer_xmit(struct sk_buff 
 static int streamer_close(struct net_device *dev);
 static void streamer_set_rx_mode(struct net_device *dev);
 static irqreturn_t streamer_interrupt(int irq, void *dev_id);
-static struct net_device_stats *streamer_get_stats(struct net_device *dev);
 static int streamer_set_mac_address(struct net_device *dev, void *addr);
 static void streamer_arb_cmd(struct net_device *dev);
 static int streamer_change_mtu(struct net_device *dev, int mtu);
@@ -331,7 +330,6 @@ static int __devinit streamer_init_one(s
 	dev->do_ioctl = NULL;
 #endif
 	dev->set_multicast_list = &streamer_set_rx_mode;
-	dev->get_stats = &streamer_get_stats;
 	dev->set_mac_address = &streamer_set_mac_address;
 	dev->irq = pdev->irq;
 	dev->base_addr=pio_start;
@@ -937,7 +935,7 @@ static void streamer_rx(struct net_devic
 			if (skb == NULL) 
 			{
 				printk(KERN_WARNING "%s: Not enough memory to copy packet to upper layers. \n",	dev->name);
-				streamer_priv->streamer_stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			} else {	/* we allocated an skb OK */
 				if (buffer_cnt == 1) {
 					/* release the DMA mapping */
@@ -1009,8 +1007,8 @@ static void streamer_rx(struct net_devic
 					/* send up to the protocol */
 					netif_rx(skb);
 				}
-				streamer_priv->streamer_stats.rx_packets++;
-				streamer_priv->streamer_stats.rx_bytes += length;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += length;
 			}	/* if skb == null */
 		}		/* end received without errors */
 
@@ -1053,8 +1051,8 @@ static irqreturn_t streamer_interrupt(in
 				while(streamer_priv->streamer_tx_ring[(streamer_priv->tx_ring_last_status + 1) & (STREAMER_TX_RING_SIZE - 1)].status) {
 				streamer_priv->tx_ring_last_status = (streamer_priv->tx_ring_last_status + 1) & (STREAMER_TX_RING_SIZE - 1);
 				streamer_priv->free_tx_ring_entries++;
-				streamer_priv->streamer_stats.tx_bytes += streamer_priv->tx_ring_skb[streamer_priv->tx_ring_last_status]->len;
-				streamer_priv->streamer_stats.tx_packets++;
+				dev->stats.tx_bytes += streamer_priv->tx_ring_skb[streamer_priv->tx_ring_last_status]->len;
+				dev->stats.tx_packets++;
 				dev_kfree_skb_irq(streamer_priv->tx_ring_skb[streamer_priv->tx_ring_last_status]);
 				streamer_priv->streamer_tx_ring[streamer_priv->tx_ring_last_status].buffer = 0xdeadbeef;
 				streamer_priv->streamer_tx_ring[streamer_priv->tx_ring_last_status].status = 0;
@@ -1484,13 +1482,6 @@ static void streamer_srb_bh(struct net_d
 	}			/* switch srb[0] */
 }
 
-static struct net_device_stats *streamer_get_stats(struct net_device *dev)
-{
-	struct streamer_private *streamer_priv;
-	streamer_priv = netdev_priv(dev);
-	return (struct net_device_stats *) &streamer_priv->streamer_stats;
-}
-
 static int streamer_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *saddr = addr;
--- a/drivers/net/tokenring/lanstreamer.h	2009-01-09 10:03:58.000000000 -0800
+++ b/drivers/net/tokenring/lanstreamer.h	2009-01-09 10:04:58.000000000 -0800
@@ -299,7 +299,6 @@ struct streamer_private {
 	int tx_ring_free, tx_ring_last_status, rx_ring_last_received,
 	    free_tx_ring_entries;
 
-	struct net_device_stats streamer_stats;
 	__u16 streamer_lan_status;
 	__u8 streamer_ring_speed;
 	__u16 pkt_buf_sz;


