From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH 03/03] tulip: Support for byte queue limits
Date: Mon, 14 Oct 2013 20:26:19 +0200
Message-ID: <1381775183-24866-4-git-send-email-milky-kernel@mcmilk.de>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35487 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757036Ab3JNSfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:53 -0400
In-Reply-To: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to tulip to use byte queue limits.

Nearly the same patch which was already sent by George Spelvin to the netdev
list, see here: http://thread.gmane.org/gmane.linux.network/276166

Maybe George could re-test it and give it an ACK/NACK?

This patch _was not_ tested on real hardware by me. But I have such card in
an ADSL Linux Router, which may be updated some time and then I would like
to use codel with it :)


Original-Patch-By: George Spelvin <linux@horizon.com>
Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/dec/tulip/interrupt.c  | 3 +++
 drivers/net/ethernet/dec/tulip/tulip_core.c | 2 ++
 2 files changed, 5 insertions(+)

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
index 4e8cfa2..69cdcff 100644
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
-- 
1.8.4
