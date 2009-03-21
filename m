From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 23/77] usbnet: convert to internal net_device stats
Date: Fri, 20 Mar 2009 22:35:50 -0700
Message-ID: <20090321053714.283096585@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36580 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760888AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usb-rtl-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/usb/rtl8150.c	2009-03-20 12:11:35.825901868 -0700
+++ b/drivers/net/usb/rtl8150.c	2009-03-20 12:12:47.085715442 -0700
@@ -155,7 +155,6 @@ struct rtl8150 {
 	unsigned long flags;
 	struct usb_device *udev;
 	struct tasklet_struct tl;
-	struct net_device_stats stats;
 	struct net_device *netdev;
 	struct urb *rx_urb, *tx_urb, *intr_urb, *ctrl_urb;
 	struct sk_buff *tx_skb, *rx_skb;
@@ -463,8 +462,8 @@ static void read_bulk_callback(struct ur
 	skb_put(dev->rx_skb, pkt_len);
 	dev->rx_skb->protocol = eth_type_trans(dev->rx_skb, netdev);
 	netif_rx(dev->rx_skb);
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += pkt_len;
+	netdev->stats.rx_packets++;
+	netdev->stats.rx_bytes += pkt_len;
 
 	spin_lock(&dev->rx_pool_lock);
 	skb = pull_skb(dev);
@@ -573,13 +572,13 @@ static void intr_callback(struct urb *ur
 
 	d = urb->transfer_buffer;
 	if (d[0] & TSR_ERRORS) {
-		dev->stats.tx_errors++;
+		dev->netdev->stats.tx_errors++;
 		if (d[INT_TSR] & (TSR_ECOL | TSR_JBR))
-			dev->stats.tx_aborted_errors++;
+			dev->netdev->stats.tx_aborted_errors++;
 		if (d[INT_TSR] & TSR_LCOL)
-			dev->stats.tx_window_errors++;
+			dev->netdev->stats.tx_window_errors++;
 		if (d[INT_TSR] & TSR_LOSS_CRS)
-			dev->stats.tx_carrier_errors++;
+			dev->netdev->stats.tx_carrier_errors++;
 	}
 	/* Report link status changes to the network stack */
 	if ((d[INT_MSR] & MSR_LINK) == 0) {
@@ -697,17 +696,12 @@ static void disable_net_traffic(rtl8150_
 	set_registers(dev, CR, 1, &cr);
 }
 
-static struct net_device_stats *rtl8150_netdev_stats(struct net_device *dev)
-{
-	return &((rtl8150_t *)netdev_priv(dev))->stats;
-}
-
 static void rtl8150_tx_timeout(struct net_device *netdev)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
 	dev_warn(&netdev->dev, "Tx timeout.\n");
 	usb_unlink_urb(dev->tx_urb);
-	dev->stats.tx_errors++;
+	netdev->stats.tx_errors++;
 }
 
 static void rtl8150_set_multicast(struct net_device *netdev)
@@ -747,12 +741,12 @@ static int rtl8150_start_xmit(struct sk_
 			netif_device_detach(dev->netdev);
 		else {
 			dev_warn(&netdev->dev, "failed tx_urb %d\n", res);
-			dev->stats.tx_errors++;
+			netdev->stats.tx_errors++;
 			netif_start_queue(netdev);
 		}
 	} else {
-		dev->stats.tx_packets++;
-		dev->stats.tx_bytes += skb->len;
+		netdev->stats.tx_packets++;
+		netdev->stats.tx_bytes += skb->len;
 		netdev->trans_start = jiffies;
 	}
 
@@ -931,7 +925,7 @@ static int rtl8150_probe(struct usb_inte
 	netdev->hard_start_xmit = rtl8150_start_xmit;
 	netdev->set_multicast_list = rtl8150_set_multicast;
 	netdev->set_mac_address = rtl8150_set_mac_address;
-	netdev->get_stats = rtl8150_netdev_stats;
+
 	SET_ETHTOOL_OPS(netdev, &ops);
 	dev->intr_interval = 100;	/* 100ms */
 

-- 

