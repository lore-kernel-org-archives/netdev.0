From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] hp100: Use the instance of net_device_stats from net_device.
Date: Mon,  5 Jul 2010 16:13:46 +0400
Message-ID: <1278332028-16769-1-git-send-email-segooon@gmail.com>
Cc: Jaroslav Kysela <perex@perex.cz>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since net_device has an instance of net_device_stats,
we can remove the instance of this from the adapter structure.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/hp100.c |   47 ++++++++++++++++++++++-------------------------
 1 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index dfc787f..78acdba 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -168,7 +168,6 @@ struct hp100_private {
 	u_char mac1_mode;
 	u_char mac2_mode;
 	u_char hash_bytes[8];
-	struct net_device_stats stats;
 
 	/* Rings for busmaster mode: */
 	hp100_ring_t *rxrhead;	/* Head (oldest) index into rxring */
@@ -1582,8 +1581,8 @@ static netdev_tx_t hp100_start_xmit_bm(struct sk_buff *skb,
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	/* Update statistics */
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 
 	return NETDEV_TX_OK;
 
@@ -1740,8 +1739,8 @@ static netdev_tx_t hp100_start_xmit(struct sk_buff *skb,
 
 	hp100_outb(HP100_TX_CMD | HP100_SET_LB, OPTION_MSW);	/* send packet */
 
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 	hp100_ints_on();
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -1822,7 +1821,7 @@ static void hp100_rx(struct net_device *dev)
 			printk("hp100: %s: rx: couldn't allocate a sk_buff of size %d\n",
 					     dev->name, pkt_len);
 #endif
-			lp->stats.rx_dropped++;
+			dev->stats.rx_dropped++;
 		} else {	/* skb successfully allocated */
 
 			u_char *ptr;
@@ -1848,8 +1847,8 @@ static void hp100_rx(struct net_device *dev)
 					ptr[9], ptr[10], ptr[11]);
 #endif
 			netif_rx(skb);
-			lp->stats.rx_packets++;
-			lp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 
 		/* Indicate the card that we have got the packet */
@@ -1858,7 +1857,7 @@ static void hp100_rx(struct net_device *dev)
 		switch (header & 0x00070000) {
 		case (HP100_MULTI_ADDR_HASH << 16):
 		case (HP100_MULTI_ADDR_NO_HASH << 16):
-			lp->stats.multicast++;
+			dev->stats.multicast++;
 			break;
 		}
 	}			/* end of while(there are packets) loop */
@@ -1930,7 +1929,7 @@ static void hp100_rx_bm(struct net_device *dev)
 			if (ptr->skb == NULL) {
 				printk("hp100: %s: rx_bm: skb null\n", dev->name);
 				/* can happen if we only allocated room for the pdh due to memory shortage. */
-				lp->stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 			} else {
 				skb_trim(ptr->skb, pkt_len);	/* Shorten it */
 				ptr->skb->protocol =
@@ -1938,14 +1937,14 @@ static void hp100_rx_bm(struct net_device *dev)
 
 				netif_rx(ptr->skb);	/* Up and away... */
 
-				lp->stats.rx_packets++;
-				lp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 			}
 
 			switch (header & 0x00070000) {
 			case (HP100_MULTI_ADDR_HASH << 16):
 			case (HP100_MULTI_ADDR_NO_HASH << 16):
-				lp->stats.multicast++;
+				dev->stats.multicast++;
 				break;
 			}
 		} else {
@@ -1954,7 +1953,7 @@ static void hp100_rx_bm(struct net_device *dev)
 #endif
 			if (ptr->skb != NULL)
 				dev_kfree_skb_any(ptr->skb);
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 		}
 
 		lp->rxrhead = lp->rxrhead->next;
@@ -1992,14 +1991,13 @@ static struct net_device_stats *hp100_get_stats(struct net_device *dev)
 	hp100_update_stats(dev);
 	hp100_ints_on();
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return &(lp->stats);
+	return &(dev->stats);
 }
 
 static void hp100_update_stats(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 	u_short val;
-	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	hp100_outw(0x4216, TRACE);
@@ -2009,14 +2007,14 @@ static void hp100_update_stats(struct net_device *dev)
 	/* Note: Statistics counters clear when read. */
 	hp100_page(MAC_CTRL);
 	val = hp100_inw(DROPPED) & 0x0fff;
-	lp->stats.rx_errors += val;
-	lp->stats.rx_over_errors += val;
+	dev->stats.rx_errors += val;
+	dev->stats.rx_over_errors += val;
 	val = hp100_inb(CRC);
-	lp->stats.rx_errors += val;
-	lp->stats.rx_crc_errors += val;
+	dev->stats.rx_errors += val;
+	dev->stats.rx_crc_errors += val;
 	val = hp100_inb(ABORT);
-	lp->stats.tx_errors += val;
-	lp->stats.tx_aborted_errors += val;
+	dev->stats.tx_errors += val;
+	dev->stats.tx_aborted_errors += val;
 	hp100_page(PERFORMANCE);
 }
 
@@ -2025,7 +2023,6 @@ static void hp100_misc_interrupt(struct net_device *dev)
 #ifdef HP100_DEBUG_B
 	int ioaddr = dev->base_addr;
 #endif
-	struct hp100_private *lp = netdev_priv(dev);
 
 #ifdef HP100_DEBUG_B
 	int ioaddr = dev->base_addr;
@@ -2034,8 +2031,8 @@ static void hp100_misc_interrupt(struct net_device *dev)
 #endif
 
 	/* Note: Statistics counters clear when read. */
-	lp->stats.rx_errors++;
-	lp->stats.tx_errors++;
+	dev->stats.rx_errors++;
+	dev->stats.tx_errors++;
 }
 
 static void hp100_clear_stats(struct hp100_private *lp, int ioaddr)
-- 
1.7.0.4
