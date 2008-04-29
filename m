From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 6pack: use netstats in net_device structure
Date: Wed, 30 Apr 2008 01:49:15 +0300
Message-ID: <4817A5EB.6030405@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020100050206000708010609"
Cc: davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:35252 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbYD2Wt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 18:49:27 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqydY-0002rn-28
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 22:49:24 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 22:49:24 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 22:49:24 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020100050206000708010609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill sp_get_stats function, because by default it is used identical
internal_stats function from net/core/dev.c

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>




--------------020100050206000708010609
Content-Type: text/x-patch;
 name="6pack_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="6pack_netstats.patch"

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 1da55dd..a78e037 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -99,9 +99,6 @@ struct sixpack {
 	unsigned int		rx_count;
 	unsigned int		rx_count_cooked;
 
-	/* 6pack interface statistics. */
-	struct net_device_stats stats;
-
 	int			mtu;		/* Our mtu (to spot changes!) */
 	int			buffsize;       /* Max buffers sizes */
 
@@ -237,7 +234,7 @@ static void sp_encaps(struct sixpack *sp, unsigned char *icp, int len)
 	return;
 
 out_drop:
-	sp->stats.tx_dropped++;
+	sp->dev->stats.tx_dropped++;
 	netif_start_queue(sp->dev);
 	if (net_ratelimit())
 		printk(KERN_DEBUG "%s: %s - dropped.\n", sp->dev->name, msg);
@@ -252,7 +249,7 @@ static int sp_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_lock_bh(&sp->lock);
 	/* We were not busy, so we are now... :-) */
 	netif_stop_queue(dev);
-	sp->stats.tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	sp_encaps(sp, skb->data, skb->len);
 	spin_unlock_bh(&sp->lock);
 
@@ -298,12 +295,6 @@ static int sp_header(struct sk_buff *skb, struct net_device *dev,
 	return 0;
 }
 
-static struct net_device_stats *sp_get_stats(struct net_device *dev)
-{
-	struct sixpack *sp = netdev_priv(dev);
-	return &sp->stats;
-}
-
 static int sp_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr_ax25 *sa = addr;
@@ -338,7 +329,6 @@ static void sp_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 	dev->stop		= sp_close;
 
-	dev->get_stats	        = sp_get_stats;
 	dev->set_mac_address    = sp_set_mac_address;
 	dev->hard_header_len	= AX25_MAX_HEADER_LEN;
 	dev->header_ops 	= &sp_header_ops;
@@ -370,7 +360,7 @@ static void sp_bump(struct sixpack *sp, char cmd)
 
 	count = sp->rcount + 1;
 
-	sp->stats.rx_bytes += count;
+	sp->dev->stats.rx_bytes += count;
 
 	if ((skb = dev_alloc_skb(count)) == NULL)
 		goto out_mem;
@@ -382,12 +372,12 @@ static void sp_bump(struct sixpack *sp, char cmd)
 	skb->protocol = ax25_type_trans(skb, sp->dev);
 	netif_rx(skb);
 	sp->dev->last_rx = jiffies;
-	sp->stats.rx_packets++;
+	sp->dev->stats.rx_packets++;
 
 	return;
 
 out_mem:
-	sp->stats.rx_dropped++;
+	sp->dev->stats.rx_dropped++;
 }
 
 
@@ -436,7 +426,7 @@ static void sixpack_write_wakeup(struct tty_struct *tty)
 	if (sp->xleft <= 0)  {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
-		sp->stats.tx_packets++;
+		sp->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		sp->tx_enable = 0;
 		netif_wake_queue(sp->dev);
@@ -484,7 +474,7 @@ static void sixpack_receive_buf(struct tty_struct *tty,
 		count--;
 		if (fp && *fp++) {
 			if (!test_and_set_bit(SIXPF_ERROR, &sp->flags))
-				sp->stats.rx_errors++;
+				sp->dev->stats.rx_errors++;
 			continue;
 		}
 	}

--------------020100050206000708010609--

