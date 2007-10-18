From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 05/13] r8169: remove private net_device_stats structure
Date: Thu, 18 Oct 2007 23:01:25 +0200
Message-ID: <20071018210125.GF31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36935 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751106AbXJRVGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:06:36 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use net_device_stats in the net_device structure.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ee1c274..951c56e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -392,7 +392,6 @@ struct rtl8169_private {
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
 	struct napi_struct napi;
-	struct net_device_stats stats;	/* statistics of net device */
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -2305,7 +2304,7 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 				dev_kfree_skb(skb);
 				tx_skb->skb = NULL;
 			}
-			tp->stats.tx_dropped++;
+			tp->dev->stats.tx_dropped++;
 		}
 	}
 	tp->cur_tx = tp->dirty_tx = 0;
@@ -2386,6 +2385,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 		rtl8169_init_ring_indexes(tp);
 		rtl_hw_start(dev);
 		netif_wake_queue(dev);
+		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 	} else {
 		if (net_ratelimit() && netif_msg_intr(tp)) {
 			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
@@ -2542,7 +2542,7 @@ err_stop:
 	netif_stop_queue(dev);
 	ret = NETDEV_TX_BUSY;
 err_update_stats:
-	tp->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	goto out;
 }
 
@@ -2617,8 +2617,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		if (status & DescOwn)
 			break;
 
-		tp->stats.tx_bytes += len;
-		tp->stats.tx_packets++;
+		dev->stats.tx_bytes += len;
+		dev->stats.tx_packets++;
 
 		rtl8169_unmap_tx_skb(tp->pci_dev, tx_skb, tp->TxDescArray + entry);
 
@@ -2718,14 +2718,14 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				       "%s: Rx ERROR. status = %08x\n",
 				       dev->name, status);
 			}
-			tp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			if (status & (RxRWT | RxRUNT))
-				tp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 			if (status & RxCRC)
-				tp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
 				rtl8169_schedule_work(dev, rtl8169_reset_task);
-				tp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
@@ -2740,8 +2740,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			 * sized frames.
 			 */
 			if (unlikely(rtl8169_fragmented_frame(status))) {
-				tp->stats.rx_dropped++;
-				tp->stats.rx_length_errors++;
+				dev->stats.rx_dropped++;
+				dev->stats.rx_length_errors++;
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 				continue;
 			}
@@ -2765,8 +2765,8 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				rtl8169_rx_skb(skb);
 
 			dev->last_rx = jiffies;
-			tp->stats.rx_bytes += pkt_size;
-			tp->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_size;
+			dev->stats.rx_packets++;
 		}
 
 		/* Work around for AMD plateform. */
@@ -2927,7 +2927,7 @@ core_down:
 	rtl8169_asic_down(ioaddr);
 
 	/* Update the error counts. */
-	tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 	RTL_W32(RxMissed, 0);
 
 	spin_unlock_irq(&tp->lock);
@@ -3057,12 +3057,12 @@ static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
-		tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+		dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 		RTL_W32(RxMissed, 0);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
-	return &tp->stats;
+	return &dev->stats;
 }
 
 #ifdef CONFIG_PM
@@ -3083,7 +3083,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	rtl8169_asic_down(ioaddr);
 
-	tp->stats.rx_missed_errors += RTL_R32(RxMissed);
+	dev->stats.rx_missed_errors += RTL_R32(RxMissed);
 	RTL_W32(RxMissed, 0);
 
 	spin_unlock_irq(&tp->lock);
-- 
1.5.2.4

