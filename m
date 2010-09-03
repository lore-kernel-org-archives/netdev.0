From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tulip: use integrated netdev stats
Date: Fri, 03 Sep 2010 15:52:43 +0200
Message-ID: <1283521963.2453.848.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42471 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756030Ab0ICNws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 09:52:48 -0400
Received: by wwj40 with SMTP id 40so2607485wwj.1
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 06:52:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct tulip_private is a bit large (order-1 allocation even on 32bit
arch), try to shrink it, remove its net_device_stats field.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tulip/interrupt.c  |   77 +++++++++++++++++--------------
 drivers/net/tulip/tulip.h      |    3 -
 drivers/net/tulip/tulip_core.c |   10 ++--
 3 files changed, 50 insertions(+), 40 deletions(-)

diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index 1faf7a4..0013642 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -180,21 +180,24 @@ int tulip_poll(struct napi_struct *napi, int budget)
                                                        dev_warn(&dev->dev,
 								"Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
 								status);
-                                               tp->stats.rx_length_errors++;
-                                       }
+						dev->stats.rx_length_errors++;
+					}
 			       } else {
                                 /* There was a fatal error. */
                                        if (tulip_debug > 2)
                                                printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
                                                       dev->name, status);
-                                       tp->stats.rx_errors++; /* end of a packet.*/
-				       if (pkt_len > 1518 ||
-					   (status & RxDescRunt))
-					       tp->stats.rx_length_errors++;
-
-                                       if (status & 0x0004) tp->stats.rx_frame_errors++;
-                                       if (status & 0x0002) tp->stats.rx_crc_errors++;
-                                       if (status & 0x0001) tp->stats.rx_fifo_errors++;
+					dev->stats.rx_errors++; /* end of a packet.*/
+					if (pkt_len > 1518 ||
+					    (status & RxDescRunt))
+						dev->stats.rx_length_errors++;
+
+					if (status & 0x0004)
+						dev->stats.rx_frame_errors++;
+					if (status & 0x0002)
+						dev->stats.rx_crc_errors++;
+					if (status & 0x0001)
+						dev->stats.rx_fifo_errors++;
                                }
                        } else {
                                struct sk_buff *skb;
@@ -244,8 +247,8 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
                                netif_receive_skb(skb);
 
-                               tp->stats.rx_packets++;
-                               tp->stats.rx_bytes += pkt_len;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
                        }
 #ifdef CONFIG_TULIP_NAPI_HW_MITIGATION
 		       received++;
@@ -404,20 +407,23 @@ static int tulip_rx(struct net_device *dev)
 						dev_warn(&dev->dev,
 							 "Oversized Ethernet frame spanned multiple buffers, status %08x!\n",
 							 status);
-					tp->stats.rx_length_errors++;
+					dev->stats.rx_length_errors++;
 				}
 			} else {
 				/* There was a fatal error. */
 				if (tulip_debug > 2)
 					printk(KERN_DEBUG "%s: Receive error, Rx status %08x\n",
 					       dev->name, status);
-				tp->stats.rx_errors++; /* end of a packet.*/
+				dev->stats.rx_errors++; /* end of a packet.*/
 				if (pkt_len > 1518 ||
 				    (status & RxDescRunt))
-					tp->stats.rx_length_errors++;
-				if (status & 0x0004) tp->stats.rx_frame_errors++;
-				if (status & 0x0002) tp->stats.rx_crc_errors++;
-				if (status & 0x0001) tp->stats.rx_fifo_errors++;
+					dev->stats.rx_length_errors++;
+				if (status & 0x0004)
+					dev->stats.rx_frame_errors++;
+				if (status & 0x0002)
+					dev->stats.rx_crc_errors++;
+				if (status & 0x0001)
+					dev->stats.rx_fifo_errors++;
 			}
 		} else {
 			struct sk_buff *skb;
@@ -467,8 +473,8 @@ static int tulip_rx(struct net_device *dev)
 
 			netif_rx(skb);
 
-			tp->stats.rx_packets++;
-			tp->stats.rx_bytes += pkt_len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += pkt_len;
 		}
 		received++;
 		entry = (++tp->cur_rx) % RX_RING_SIZE;
@@ -602,18 +608,22 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 						printk(KERN_DEBUG "%s: Transmit error, Tx status %08x\n",
 						       dev->name, status);
 #endif
-					tp->stats.tx_errors++;
-					if (status & 0x4104) tp->stats.tx_aborted_errors++;
-					if (status & 0x0C00) tp->stats.tx_carrier_errors++;
-					if (status & 0x0200) tp->stats.tx_window_errors++;
-					if (status & 0x0002) tp->stats.tx_fifo_errors++;
+					dev->stats.tx_errors++;
+					if (status & 0x4104)
+						dev->stats.tx_aborted_errors++;
+					if (status & 0x0C00)
+						dev->stats.tx_carrier_errors++;
+					if (status & 0x0200)
+						dev->stats.tx_window_errors++;
+					if (status & 0x0002)
+						dev->stats.tx_fifo_errors++;
 					if ((status & 0x0080) && tp->full_duplex == 0)
-						tp->stats.tx_heartbeat_errors++;
+						dev->stats.tx_heartbeat_errors++;
 				} else {
-					tp->stats.tx_bytes +=
+					dev->stats.tx_bytes +=
 						tp->tx_buffers[entry].skb->len;
-					tp->stats.collisions += (status >> 3) & 15;
-					tp->stats.tx_packets++;
+					dev->stats.collisions += (status >> 3) & 15;
+					dev->stats.tx_packets++;
 				}
 
 				pci_unmap_single(tp->pdev, tp->tx_buffers[entry].mapping,
@@ -655,7 +665,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 		if (csr5 & AbnormalIntr) {	/* Abnormal error summary bit. */
 			if (csr5 == 0xffffffff)
 				break;
-			if (csr5 & TxJabber) tp->stats.tx_errors++;
+			if (csr5 & TxJabber)
+				dev->stats.tx_errors++;
 			if (csr5 & TxFIFOUnderflow) {
 				if ((tp->csr6 & 0xC000) != 0xC000)
 					tp->csr6 += 0x4000;	/* Bump up the Tx threshold */
@@ -672,8 +683,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 				}
 			}
 			if (csr5 & RxDied) {		/* Missed a Rx frame. */
-                                tp->stats.rx_missed_errors += ioread32(ioaddr + CSR8) & 0xffff;
-				tp->stats.rx_errors++;
+				dev->stats.rx_missed_errors += ioread32(ioaddr + CSR8) & 0xffff;
+				dev->stats.rx_errors++;
 				tulip_start_rxtx(tp);
 			}
 			/*
@@ -789,7 +800,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 #endif /* CONFIG_TULIP_NAPI */
 
 	if ((missed = ioread32(ioaddr + CSR8) & 0x1ffff)) {
-		tp->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;
+		dev->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;
 	}
 
 	if (tulip_debug > 4)
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
index e525875..ed66a16 100644
--- a/drivers/net/tulip/tulip.h
+++ b/drivers/net/tulip/tulip.h
@@ -417,7 +417,6 @@ struct tulip_private {
 	int revision;
 	int flags;
 	struct napi_struct napi;
-	struct net_device_stats stats;
 	struct timer_list timer;	/* Media selection timer. */
 	struct timer_list oom_timer;    /* Out of memory timer. */
 	u32 mc_filter[2];
@@ -570,7 +569,7 @@ static inline void tulip_tx_timeout_complete(struct tulip_private *tp, void __io
 	/* Trigger an immediate transmit demand. */
 	iowrite32(0, ioaddr + CSR1);
 
-	tp->stats.tx_errors++;
+	tp->dev->stats.tx_errors++;
 }
 
 #endif /* __NET_TULIP_H__ */
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 3a8d7ef..2c39f25 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -725,7 +725,7 @@ static void tulip_clean_tx_ring(struct tulip_private *tp)
 		int status = le32_to_cpu(tp->tx_ring[entry].status);
 
 		if (status < 0) {
-			tp->stats.tx_errors++;	/* It wasn't Txed */
+			tp->dev->stats.tx_errors++;	/* It wasn't Txed */
 			tp->tx_ring[entry].status = 0;
 		}
 
@@ -781,8 +781,8 @@ static void tulip_down (struct net_device *dev)
 	/* release any unconsumed transmit buffers */
 	tulip_clean_tx_ring(tp);
 
-	if (ioread32 (ioaddr + CSR6) != 0xffffffff)
-		tp->stats.rx_missed_errors += ioread32 (ioaddr + CSR8) & 0xffff;
+	if (ioread32(ioaddr + CSR6) != 0xffffffff)
+		dev->stats.rx_missed_errors += ioread32(ioaddr + CSR8) & 0xffff;
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
@@ -864,12 +864,12 @@ static struct net_device_stats *tulip_get_stats(struct net_device *dev)
 
 		spin_lock_irqsave (&tp->lock, flags);
 
-		tp->stats.rx_missed_errors += ioread32(ioaddr + CSR8) & 0xffff;
+		dev->stats.rx_missed_errors += ioread32(ioaddr + CSR8) & 0xffff;
 
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 
-	return &tp->stats;
+	return &dev->stats;
 }
 
 


