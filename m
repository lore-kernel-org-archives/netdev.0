From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 43/45] mkiss: convert to internal network device stats
Date: Fri, 09 Jan 2009 15:01:40 -0800
Message-ID: <20090109230139.928206029@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42281 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754386AbZAIXSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:12 -0500
Content-Disposition: inline; filename=mkiss-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamradio/mkiss.c	2009-01-09 10:16:50.000000000 -0800
+++ b/drivers/net/hamradio/mkiss.c	2009-01-09 12:57:32.000000000 -0800
@@ -59,8 +59,6 @@ struct mkiss {
 	unsigned char		*xhead;	/* pointer to next byte to XMIT */
 	int			xleft;	/* bytes left in XMIT queue     */
 
-	struct net_device_stats	stats;
-
 	/* Detailed SLIP statistics. */
 	int		mtu;		/* Our mtu (to spot changes!)   */
 	int		buffsize;	/* Max buffers sizes            */
@@ -253,7 +251,7 @@ static void ax_bump(struct mkiss *ax)
 	if (ax->rbuff[0] > 0x0f) {
 		if (ax->rbuff[0] & 0x80) {
 			if (check_crc_16(ax->rbuff, ax->rcount) < 0) {
-				ax->stats.rx_errors++;
+				ax->dev->stats.rx_errors++;
 				spin_unlock_bh(&ax->buflock);
 
 				return;
@@ -268,7 +266,7 @@ static void ax_bump(struct mkiss *ax)
 			*ax->rbuff &= ~0x80;
 		} else if (ax->rbuff[0] & 0x20)  {
 			if (check_crc_flex(ax->rbuff, ax->rcount) < 0) {
-				ax->stats.rx_errors++;
+				ax->dev->stats.rx_errors++;
 				spin_unlock_bh(&ax->buflock);
 				return;
 			}
@@ -295,7 +293,7 @@ static void ax_bump(struct mkiss *ax)
 	if ((skb = dev_alloc_skb(count)) == NULL) {
 		printk(KERN_ERR "mkiss: %s: memory squeeze, dropping packet.\n",
 		       ax->dev->name);
-		ax->stats.rx_dropped++;
+		ax->dev->stats.rx_dropped++;
 		spin_unlock_bh(&ax->buflock);
 		return;
 	}
@@ -303,8 +301,8 @@ static void ax_bump(struct mkiss *ax)
 	memcpy(skb_put(skb,count), ax->rbuff, count);
 	skb->protocol = ax25_type_trans(skb, ax->dev);
 	netif_rx(skb);
-	ax->stats.rx_packets++;
-	ax->stats.rx_bytes += count;
+	ax->dev->stats.rx_packets++;
+	ax->dev->stats.rx_bytes += count;
 	spin_unlock_bh(&ax->buflock);
 }
 
@@ -344,7 +342,7 @@ static void kiss_unesc(struct mkiss *ax,
 			return;
 		}
 
-		ax->stats.rx_over_errors++;
+		ax->dev->stats.rx_over_errors++;
 		set_bit(AXF_ERROR, &ax->flags);
 	}
 	spin_unlock_bh(&ax->buflock);
@@ -406,7 +404,7 @@ static void ax_changedmtu(struct mkiss *
 			memcpy(ax->xbuff, ax->xhead, ax->xleft);
 		} else  {
 			ax->xleft = 0;
-			ax->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		}
 	}
 
@@ -417,7 +415,7 @@ static void ax_changedmtu(struct mkiss *
 			memcpy(ax->rbuff, orbuff, ax->rcount);
 		} else  {
 			ax->rcount = 0;
-			ax->stats.rx_over_errors++;
+			dev->stats.rx_over_errors++;
 			set_bit(AXF_ERROR, &ax->flags);
 		}
 	}
@@ -444,7 +442,7 @@ static void ax_encaps(struct net_device 
 	if (len > ax->mtu) {		/* Sigh, shouldn't occur BUT ... */
 		len = ax->mtu;
 		printk(KERN_ERR "mkiss: %s: truncating oversized transmit packet!\n", ax->dev->name);
-		ax->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		netif_start_queue(dev);
 		return;
 	}
@@ -518,8 +516,8 @@ static void ax_encaps(struct net_device 
 
 	set_bit(TTY_DO_WRITE_WAKEUP, &ax->tty->flags);
 	actual = ax->tty->ops->write(ax->tty, ax->xbuff, count);
-	ax->stats.tx_packets++;
-	ax->stats.tx_bytes += actual;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += actual;
 
 	ax->dev->trans_start = jiffies;
 	ax->xleft = count - actual;
@@ -664,13 +662,6 @@ static int ax_close(struct net_device *d
 	return 0;
 }
 
-static struct net_device_stats *ax_get_stats(struct net_device *dev)
-{
-	struct mkiss *ax = netdev_priv(dev);
-
-	return &ax->stats;
-}
-
 static const struct header_ops ax_header_ops = {
 	.create    = ax_header,
 	.rebuild   = ax_rebuild_header,
@@ -683,7 +674,6 @@ static void ax_setup(struct net_device *
 	dev->hard_start_xmit = ax_xmit;
 	dev->open            = ax_open_dev;
 	dev->stop            = ax_close;
-	dev->get_stats	     = ax_get_stats;
 	dev->set_mac_address = ax_set_mac_address;
 	dev->hard_header_len = 0;
 	dev->addr_len        = 0;
@@ -929,7 +919,7 @@ static void mkiss_receive_buf(struct tty
 	while (count--) {
 		if (fp != NULL && *fp++) {
 			if (!test_and_set_bit(AXF_ERROR, &ax->flags))
-				ax->stats.rx_errors++;
+				ax->dev->stats.rx_errors++;
 			cp++;
 			continue;
 		}


