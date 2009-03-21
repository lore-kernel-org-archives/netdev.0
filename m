From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 62/77] wl3501: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:29 -0700
Message-ID: <20090321053717.285938709@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36741 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761255AbZCUFse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:34 -0400
Content-Disposition: inline; filename=wl3501-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wireless/wl3501.h	2009-03-20 21:45:40.918964050 -0700
+++ b/drivers/net/wireless/wl3501.h	2009-03-20 22:25:57.380964659 -0700
@@ -606,7 +606,7 @@ struct wl3501_card {
 	u8				reg_domain;
 	u8				version[2];
 	struct wl3501_scan_confirm	bss_set[20];
-	struct net_device_stats 	stats;
+
 	struct iw_statistics		wstats;
 	struct iw_spy_data		spy_data;
 	struct iw_public_data		wireless_data;
--- a/drivers/net/wireless/wl3501_cs.c	2009-03-20 21:45:40.925964138 -0700
+++ b/drivers/net/wireless/wl3501_cs.c	2009-03-20 22:25:57.381964610 -0700
@@ -1000,7 +1000,7 @@ static inline void wl3501_md_ind_interru
 	if (!skb) {
 		printk(KERN_WARNING "%s: Can't alloc a sk_buff of size %d.\n",
 		       dev->name, pkt_len);
-		this->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	} else {
 		skb->dev = dev;
 		skb_reserve(skb, 2); /* IP headers on 16 bytes boundaries */
@@ -1008,8 +1008,8 @@ static inline void wl3501_md_ind_interru
 		wl3501_receive(this, skb->data, pkt_len);
 		skb_put(skb, pkt_len);
 		skb->protocol	= eth_type_trans(skb, dev);
-		this->stats.rx_packets++;
-		this->stats.rx_bytes += skb->len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
 		netif_rx(skb);
 	}
 }
@@ -1311,7 +1311,7 @@ out:
 static void wl3501_tx_timeout(struct net_device *dev)
 {
 	struct wl3501_card *this = netdev_priv(dev);
-	struct net_device_stats *stats = &this->stats;
+	struct net_device_stats *stats = &dev->stats;
 	unsigned long flags;
 	int rc;
 
@@ -1346,11 +1346,11 @@ static int wl3501_hard_start_xmit(struct
 	if (enabled)
 		wl3501_unblock_interrupt(this);
 	if (rc) {
-		++this->stats.tx_dropped;
+		++dev->stats.tx_dropped;
 		netif_stop_queue(dev);
 	} else {
-		++this->stats.tx_packets;
-		this->stats.tx_bytes += skb->len;
+		++dev->stats.tx_packets;
+		dev->stats.tx_bytes += skb->len;
 		kfree_skb(skb);
 
 		if (this->tx_buffer_cnt < 2)
@@ -1400,13 +1400,6 @@ fail:
 	goto out;
 }
 
-static struct net_device_stats *wl3501_get_stats(struct net_device *dev)
-{
-	struct wl3501_card *this = netdev_priv(dev);
-
-	return &this->stats;
-}
-
 static struct iw_statistics *wl3501_get_wireless_stats(struct net_device *dev)
 {
 	struct wl3501_card *this = netdev_priv(dev);
@@ -1922,12 +1915,14 @@ static int wl3501_probe(struct pcmcia_de
 	dev = alloc_etherdev(sizeof(struct wl3501_card));
 	if (!dev)
 		goto out_link;
+
+
 	dev->open		= wl3501_open;
 	dev->stop		= wl3501_close;
 	dev->hard_start_xmit	= wl3501_hard_start_xmit;
 	dev->tx_timeout		= wl3501_tx_timeout;
 	dev->watchdog_timeo	= 5 * HZ;
-	dev->get_stats		= wl3501_get_stats;
+
 	this = netdev_priv(dev);
 	this->wireless_data.spy_data = &this->spy_data;
 	this->p_dev = p_dev;

-- 

