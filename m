From: "George Spelvin" <linux@horizon.com>
Subject: [RFC] tulip: Support for byte queue limits
Date: 12 Jul 2013 09:20:54 -0400
Message-ID: <20130712132054.16269.qmail@science.horizon.com>
Cc: linux@horizon.com
To: grundler@parisc-linux.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:15169 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932950Ab3GLNUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jul 2013 09:20:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The New Hotness of fq_codel wants bql support, but my WAN link is on my
Old And Busted tulip card, which lacks it.

It's just a few lines, but the important thing is knowing where to
put them, and I've sort of guessed.  In particular, it seems like the
netdev_sent_queue call could be almost anywhere in tulip_start_xmit and
I'm not sure if there are reasons to prefer any particular position.

(You may have my S-o-b on copyright grounds, but I'd like to test it
some more before declaring this patch ready to be merged.)


diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 92306b3..d74426e 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -532,6 +532,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 #endif
 	unsigned int work_count = tulip_max_interrupt_work;
 	unsigned int handled = 0;
+	unsigned int bytes_compl = 0;
 
 	/* Let's see whether the interrupt really is for us */
 	csr5 = ioread32(ioaddr + CSR5);
@@ -634,6 +635,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 						 PCI_DMA_TODEVICE);
 
 				/* Free the original skb. */
+				bytes_compl += tp->tx_buffers[entry].skb->len;
 				dev_kfree_skb_irq(tp->tx_buffers[entry].skb);
 				tp->tx_buffers[entry].skb = NULL;
 				tp->tx_buffers[entry].mapping = 0;
@@ -802,6 +804,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 	}
 #endif /* CONFIG_TULIP_NAPI */
 
+	netdev_completed_queue(dev, tx, bytes_compl);
 	if ((missed = ioread32(ioaddr + CSR8) & 0x1ffff)) {
 		dev->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;
 	}
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 1e9443d..b4249f3 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -703,6 +703,7 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 
 	tp->cur_tx++;
+	netdev_sent_queue(dev, skb->len);
 
 	/* Trigger an immediate transmit demand. */
 	iowrite32(0, tp->base_addr + CSR1);
@@ -746,6 +747,7 @@ static void tulip_clean_tx_ring(struct tulip_private *tp)
 		tp->tx_buffers[entry].skb = NULL;
 		tp->tx_buffers[entry].mapping = 0;
 	}
+	netdev_reset_queue(tp->dev);
 }
 
 static void tulip_down (struct net_device *dev)
