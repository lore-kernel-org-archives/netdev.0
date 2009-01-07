From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 27/42] xircom: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:43 -0800
Message-ID: <20090107003348.412679318@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52737 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756601AbZAGA7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:59:16 -0500
Content-Disposition: inline; filename=tulip-xircom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and internal net_device_stats

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/xircom_cb.c	2009-01-06 16:22:21.996610716 -0800
+++ b/drivers/net/tulip/xircom_cb.c	2009-01-06 16:26:51.124360713 -0800
@@ -104,10 +104,8 @@ struct xircom_private {
 	 */
 	spinlock_t lock;
 
-
 	struct pci_dev *pdev;
 	struct net_device *dev;
-	struct net_device_stats stats;
 };
 
 
@@ -119,7 +117,6 @@ static int xircom_start_xmit(struct sk_b
 static int xircom_open(struct net_device *dev);
 static int xircom_close(struct net_device *dev);
 static void xircom_up(struct xircom_private *card);
-static struct net_device_stats *xircom_get_stats(struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xircom_poll_controller(struct net_device *dev);
 #endif
@@ -194,6 +191,18 @@ static const struct ethtool_ops netdev_e
 	.get_drvinfo		= netdev_get_drvinfo,
 };
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= xircom_open,
+	.ndo_stop		= xircom_close,
+	.ndo_start_xmit		= xircom_start_xmit,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= xircom_poll_controller,
+#endif
+};
+
 /* xircom_probe is the code that gets called on device insertion.
    it sets up the hardware and registers the device to the networklayer.
 
@@ -266,13 +275,7 @@ static int __devinit xircom_probe(struct
 	read_mac_address(private);
 	setup_descriptors(private);
 
-	dev->open = &xircom_open;
-	dev->hard_start_xmit = &xircom_start_xmit;
-	dev->stop = &xircom_close;
-	dev->get_stats = &xircom_get_stats;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = &xircom_poll_controller;
-#endif
+	dev->netdev_ops = &netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	pci_set_drvdata(pdev, dev);
 
@@ -497,14 +500,6 @@ static int xircom_close(struct net_devic
 }
 
 
-
-static struct net_device_stats *xircom_get_stats(struct net_device *dev)
-{
-        struct xircom_private *card = netdev_priv(dev);
-        return &card->stats;
-}
-
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xircom_poll_controller(struct net_device *dev)
 {
@@ -1193,7 +1188,7 @@ static void investigate_read_descriptor(
 
 			skb = dev_alloc_skb(pkt_len + 2);
 			if (skb == NULL) {
-				card->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				goto out;
 			}
 			skb_reserve(skb, 2);
@@ -1201,8 +1196,8 @@ static void investigate_read_descriptor(
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
-			card->stats.rx_packets++;
-			card->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 
 		      out:
 			/* give the buffer back to the card */
@@ -1232,16 +1227,16 @@ static void investigate_write_descriptor
 #endif
 		if (status > 0) {	/* bit 31 is 0 when done */
 			if (card->tx_skb[descnr]!=NULL) {
-				card->stats.tx_bytes += card->tx_skb[descnr]->len;
+				dev->stats.tx_bytes += card->tx_skb[descnr]->len;
 				dev_kfree_skb_irq(card->tx_skb[descnr]);
 			}
 			card->tx_skb[descnr] = NULL;
 			/* Bit 8 in the status field is 1 if there was a collision */
 			if (status&(1<<8))
-				card->stats.collisions++;
+				dev->stats.collisions++;
 			card->tx_buffer[4*descnr] = 0; /* descriptor is free again */
 			netif_wake_queue (dev);
-			card->stats.tx_packets++;
+			dev->stats.tx_packets++;
 		}
 
 		leave("investigate_write_descriptor");

-- 

