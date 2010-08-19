From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] slip: Use net_device_stats from struct net_device
Date: Thu, 19 Aug 2010 10:25:13 +0200
Message-ID: <1282206313-10667-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:43254 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715Ab0HSIZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 04:25:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use net_device->stats for stats instead of private variable copies in
struct slip.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/slip.c |   64 ++++++++++++++++++++++------------------------------
 drivers/net/slip.h |    9 -------
 2 files changed, 27 insertions(+), 46 deletions(-)

diff --git a/drivers/net/slip.c b/drivers/net/slip.c
index fa434fb..721de9d 100644
--- a/drivers/net/slip.c
+++ b/drivers/net/slip.c
@@ -271,7 +271,7 @@ static int sl_realloc_bufs(struct slip *sl, int mtu)
 			memcpy(sl->xbuff, sl->xhead, sl->xleft);
 		} else  {
 			sl->xleft = 0;
-			sl->tx_dropped++;
+			dev->stats.tx_dropped++;
 		}
 	}
 	sl->xhead = sl->xbuff;
@@ -281,7 +281,7 @@ static int sl_realloc_bufs(struct slip *sl, int mtu)
 			memcpy(sl->rbuff, rbuff, sl->rcount);
 		} else  {
 			sl->rcount = 0;
-			sl->rx_over_errors++;
+			dev->stats.rx_over_errors++;
 			set_bit(SLF_ERROR, &sl->flags);
 		}
 	}
@@ -319,6 +319,7 @@ static inline void sl_unlock(struct slip *sl)
 /* Send one completely decapsulated IP datagram to the IP layer. */
 static void sl_bump(struct slip *sl)
 {
+	struct net_device *dev = sl->dev;
 	struct sk_buff *skb;
 	int count;
 
@@ -329,13 +330,13 @@ static void sl_bump(struct slip *sl)
 		if (c & SL_TYPE_COMPRESSED_TCP) {
 			/* ignore compressed packets when CSLIP is off */
 			if (!(sl->mode & SL_MODE_CSLIP)) {
-				printk(KERN_WARNING "%s: compressed packet ignored\n", sl->dev->name);
+				printk(KERN_WARNING "%s: compressed packet ignored\n", dev->name);
 				return;
 			}
 			/* make sure we've reserved enough space for uncompress
 			   to use */
 			if (count + 80 > sl->buffsize) {
-				sl->rx_over_errors++;
+				dev->stats.rx_over_errors++;
 				return;
 			}
 			count = slhc_uncompress(sl->slcomp, sl->rbuff, count);
@@ -346,7 +347,7 @@ static void sl_bump(struct slip *sl)
 				/* turn on header compression */
 				sl->mode |= SL_MODE_CSLIP;
 				sl->mode &= ~SL_MODE_ADAPTIVE;
-				printk(KERN_INFO "%s: header compression turned on\n", sl->dev->name);
+				printk(KERN_INFO "%s: header compression turned on\n", dev->name);
 			}
 			sl->rbuff[0] &= 0x4f;
 			if (slhc_remember(sl->slcomp, sl->rbuff, count) <= 0)
@@ -355,20 +356,20 @@ static void sl_bump(struct slip *sl)
 	}
 #endif  /* SL_INCLUDE_CSLIP */
 
-	sl->rx_bytes += count;
+	dev->stats.rx_bytes += count;
 
 	skb = dev_alloc_skb(count);
 	if (skb == NULL) {
-		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n", sl->dev->name);
-		sl->rx_dropped++;
+		printk(KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev->name);
+		dev->stats.rx_dropped++;
 		return;
 	}
-	skb->dev = sl->dev;
+	skb->dev = dev;
 	memcpy(skb_put(skb, count), sl->rbuff, count);
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IP);
 	netif_rx(skb);
-	sl->rx_packets++;
+	dev->stats.rx_packets++;
 }
 
 /* Encapsulate one IP datagram and stuff into a TTY queue. */
@@ -379,7 +380,7 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 
 	if (len > sl->mtu) {		/* Sigh, shouldn't occur BUT ... */
 		printk(KERN_WARNING "%s: truncating oversized transmit packet!\n", sl->dev->name);
-		sl->tx_dropped++;
+		sl->dev->stats.tx_dropped++;
 		sl_unlock(sl);
 		return;
 	}
@@ -433,7 +434,7 @@ static void slip_write_wakeup(struct tty_struct *tty)
 	if (sl->xleft <= 0)  {
 		/* Now serial buffer is almost free & we can start
 		 * transmission of another packet */
-		sl->tx_packets++;
+		sl->dev->stats.tx_packets++;
 		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
 		sl_unlock(sl);
 		return;
@@ -496,7 +497,7 @@ sl_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	sl_lock(sl);
-	sl->tx_bytes += skb->len;
+	dev->stats.tx_bytes += skb->len;
 	sl_encaps(sl, skb->data, skb->len);
 	spin_unlock(&sl->lock);
 
@@ -561,36 +562,25 @@ static int sl_change_mtu(struct net_device *dev, int new_mtu)
 static struct net_device_stats *
 sl_get_stats(struct net_device *dev)
 {
-	static struct net_device_stats stats;
+	struct net_device_stats *stats = &dev->stats;
 	struct slip *sl = netdev_priv(dev);
 #ifdef SL_INCLUDE_CSLIP
 	struct slcompress *comp;
 #endif
 
-	memset(&stats, 0, sizeof(struct net_device_stats));
-
-	stats.rx_packets     = sl->rx_packets;
-	stats.tx_packets     = sl->tx_packets;
-	stats.rx_bytes	     = sl->rx_bytes;
-	stats.tx_bytes	     = sl->tx_bytes;
-	stats.rx_dropped     = sl->rx_dropped;
-	stats.tx_dropped     = sl->tx_dropped;
-	stats.tx_errors      = sl->tx_errors;
-	stats.rx_errors      = sl->rx_errors;
-	stats.rx_over_errors = sl->rx_over_errors;
 #ifdef SL_INCLUDE_CSLIP
-	stats.rx_fifo_errors = sl->rx_compressed;
-	stats.tx_fifo_errors = sl->tx_compressed;
-	stats.collisions     = sl->tx_misses;
+	stats->rx_fifo_errors = sl->rx_compressed;
+	stats->tx_fifo_errors = sl->tx_compressed;
+	stats->collisions     = sl->tx_misses;
 	comp = sl->slcomp;
 	if (comp) {
-		stats.rx_fifo_errors += comp->sls_i_compressed;
-		stats.rx_dropped     += comp->sls_i_tossed;
-		stats.tx_fifo_errors += comp->sls_o_compressed;
-		stats.collisions     += comp->sls_o_misses;
+		stats->rx_fifo_errors += comp->sls_i_compressed;
+		stats->rx_dropped     += comp->sls_i_tossed;
+		stats->tx_fifo_errors += comp->sls_o_compressed;
+		stats->collisions     += comp->sls_o_misses;
 	}
-#endif /* CONFIG_INET */
-	return (&stats);
+#endif
+	return stats;
 }
 
 /* Netdevice register callback */
@@ -681,7 +671,7 @@ static void slip_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 	while (count--) {
 		if (fp && *fp++) {
 			if (!test_and_set_bit(SLF_ERROR, &sl->flags))
-				sl->rx_errors++;
+				sl->dev->stats.rx_errors++;
 			cp++;
 			continue;
 		}
@@ -981,7 +971,7 @@ static void slip_unesc(struct slip *sl, unsigned char s)
 			sl->rbuff[sl->rcount++] = s;
 			return;
 		}
-		sl->rx_over_errors++;
+		sl->dev->stats.rx_over_errors++;
 		set_bit(SLF_ERROR, &sl->flags);
 	}
 }
@@ -1057,7 +1047,7 @@ static void slip_unesc6(struct slip *sl, unsigned char s)
 					sl->rbuff[sl->rcount++] = c;
 					return;
 				}
-				sl->rx_over_errors++;
+				sl->dev->stats.rx_over_errors++;
 				set_bit(SLF_ERROR, &sl->flags);
 			}
 		}
diff --git a/drivers/net/slip.h b/drivers/net/slip.h
index 9ea5c11..914e958 100644
--- a/drivers/net/slip.h
+++ b/drivers/net/slip.h
@@ -67,15 +67,6 @@ struct slip {
   int                   xleft;          /* bytes left in XMIT queue     */
 
   /* SLIP interface statistics. */
-  unsigned long		rx_packets;	/* inbound frames counter	*/
-  unsigned long         tx_packets;     /* outbound frames counter      */
-  unsigned long		rx_bytes;	/* inbound byte counte		*/
-  unsigned long         tx_bytes;       /* outbound byte counter	*/
-  unsigned long         rx_errors;      /* Parity, etc. errors          */
-  unsigned long         tx_errors;      /* Planned stuff                */
-  unsigned long         rx_dropped;     /* No memory for skb            */
-  unsigned long         tx_dropped;     /* When MTU change              */
-  unsigned long         rx_over_errors; /* Frame bigger than SLIP buf.  */
 #ifdef SL_INCLUDE_CSLIP
   unsigned long		tx_compressed;
   unsigned long		rx_compressed;
-- 
1.7.0.4

