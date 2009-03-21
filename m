From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 45/77] x25_asy: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:12 -0700
Message-ID: <20090321053715.954790725@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36642 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760985AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=x25_asy-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/x25_asy.c	2009-03-20 16:27:33.651651895 -0700
+++ b/drivers/net/wan/x25_asy.c	2009-03-20 16:28:38.732839627 -0700
@@ -142,7 +142,7 @@ static int x25_asy_change_mtu(struct net
 			memcpy(sl->xbuff, sl->xhead, sl->xleft);
 		} else  {
 			sl->xleft = 0;
-			sl->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		}
 	}
 	sl->xhead = sl->xbuff;
@@ -153,7 +153,7 @@ static int x25_asy_change_mtu(struct net
 			memcpy(sl->rbuff, rbuff, sl->rcount);
 		} else  {
 			sl->rcount = 0;
-			sl->stats.rx_over_errors++;
+			dev->stats.rx_over_errors++;
 			set_bit(SLF_ERROR, &sl->flags);
 		}
 	}
@@ -188,18 +188,19 @@ static inline void x25_asy_unlock(struct
 
 static void x25_asy_bump(struct x25_asy *sl)
 {
+	struct net_device *dev = sl->dev;
 	struct sk_buff *skb;
 	int count;
 	int err;
 
 	count = sl->rcount;
-	sl->stats.rx_bytes += count;
+	dev->stats.rx_bytes += count;
 
 	skb = dev_alloc_skb(count+1);
 	if (skb == NULL) {
 		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n",
 			sl->dev->name);
-		sl->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 	skb_push(skb, 1);	/* LAPB internal control */
@@ -211,7 +212,7 @@ static void x25_asy_bump(struct x25_asy 
 		printk(KERN_DEBUG "x25_asy: data received err - %d\n", err);
 	} else {
 		netif_rx(skb);
-		sl->stats.rx_packets++;
+		dev->stats.rx_packets++;
 	}
 }
 
@@ -226,7 +227,7 @@ static void x25_asy_encaps(struct x25_as
 		len = mtu;
 		printk(KERN_DEBUG "%s: truncating oversized transmit packet!\n",
 					sl->dev->name);
-		sl->stats.tx_dropped++;
+		sl->dev->stats.tx_dropped++;
 		x25_asy_unlock(sl);
 		return;
 	}
@@ -266,7 +267,7 @@ static void x25_asy_write_wakeup(struct 
 	if (sl->xleft <= 0) {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
-		sl->stats.tx_packets++;
+		sl->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		x25_asy_unlock(sl);
 		return;
@@ -383,7 +384,7 @@ static void x25_asy_data_transmit(struct
 	/* We were not busy, so we are now... :-) */
 	if (skb != NULL) {
 		x25_asy_lock(sl);
-		sl->stats.tx_bytes += skb->len;
+		dev->stats.tx_bytes += skb->len;
 		x25_asy_encaps(sl, skb->data, skb->len);
 		dev_kfree_skb(skb);
 	}
@@ -533,7 +534,7 @@ static void x25_asy_receive_buf(struct t
 	while (count--) {
 		if (fp && *fp++) {
 			if (!test_and_set_bit(SLF_ERROR, &sl->flags))
-				sl->stats.rx_errors++;
+				sl->dev->stats.rx_errors++;
 			cp++;
 			continue;
 		}
@@ -608,14 +609,6 @@ static void x25_asy_close_tty(struct tty
 	x25_asy_free(sl);
 }
 
-
-static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
-{
-	struct x25_asy *sl = netdev_priv(dev);
-	return &sl->stats;
-}
-
-
  /************************************************************************
   *			STANDARD X.25 ENCAPSULATION		  	 *
   ************************************************************************/
@@ -682,7 +675,7 @@ static void x25_asy_unesc(struct x25_asy
 			sl->rbuff[sl->rcount++] = s;
 			return;
 		}
-		sl->stats.rx_over_errors++;
+		sl->dev->stats.rx_over_errors++;
 		set_bit(SLF_ERROR, &sl->flags);
 	}
 }
@@ -739,7 +732,6 @@ static void x25_asy_setup(struct net_dev
 	dev->watchdog_timeo	= HZ*20;
 	dev->open		= x25_asy_open_dev;
 	dev->stop		= x25_asy_close;
-	dev->get_stats	        = x25_asy_get_stats;
 	dev->change_mtu		= x25_asy_change_mtu;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
--- a/drivers/net/wan/x25_asy.h	2009-03-20 16:27:33.644652790 -0700
+++ b/drivers/net/wan/x25_asy.h	2009-03-20 16:27:44.598964747 -0700
@@ -28,10 +28,6 @@ struct x25_asy {
   unsigned char		*xbuff;		/* transmitter buffer		*/
   unsigned char         *xhead;         /* pointer to next byte to XMIT */
   int                   xleft;          /* bytes left in XMIT queue     */
-
-  /* X.25 interface statistics. */
-  struct net_device_stats stats;
-
   int                   buffsize;       /* Max buffers sizes            */
 
   unsigned long		flags;		/* Flag values/ mode etc	*/

-- 

