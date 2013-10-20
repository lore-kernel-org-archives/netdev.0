From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCH net-next v2 03/07] tulip: Support for byte queue limits
Date: Sun, 20 Oct 2013 20:13:19 +0200
Message-ID: <1382292803-18875-4-git-send-email-milky-kernel@mcmilk.de>
References: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:45384 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350Ab3JTSNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 14:13:34 -0400
In-Reply-To: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to tulip driver to use byte queue limits.


Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>

---
 drivers/net/ethernet/dec/tulip/interrupt.c  | 4 ++++
 drivers/net/ethernet/dec/tulip/tulip.h      | 1 +
 drivers/net/ethernet/dec/tulip/tulip_core.c | 9 ++++++++-
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 92306b3..7084267 100644
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
@@ -802,6 +804,8 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 	}
 #endif /* CONFIG_TULIP_NAPI */
 
+	if (likely(tulip_bql_disable == false))
+		netdev_completed_queue(dev, tx, bytes_compl);
 	if ((missed = ioread32(ioaddr + CSR8) & 0x1ffff)) {
 		dev->stats.rx_dropped += missed & 0x10000 ? 0x10000 : missed;
 	}
diff --git a/drivers/net/ethernet/dec/tulip/tulip.h b/drivers/net/ethernet/dec/tulip/tulip.h
index 38431a1..3c62870 100644
--- a/drivers/net/ethernet/dec/tulip/tulip.h
+++ b/drivers/net/ethernet/dec/tulip/tulip.h
@@ -513,6 +513,7 @@ void comet_timer(unsigned long data);
 
 /* tulip_core.c */
 extern int tulip_debug;
+extern bool tulip_bql_disable;
 extern const char * const medianame[];
 extern const char tulip_media_cap[];
 extern struct tulip_chip_table tulip_tbl[];
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 4e8cfa2..d02eaa1 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -106,11 +106,13 @@ static int csr0 = 0x00A00000 | 0x4800;
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (4*HZ)
 
-
 MODULE_AUTHOR("The Linux Kernel Team");
 MODULE_DESCRIPTION("Digital 21*4* Tulip ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
+module_param(tulip_bql_disable, bool, 0);
+MODULE_PARM_DESC(tulip_bql_disable,
+	"Disable Byte Queue Limits functionality (default: false)");
 module_param(tulip_debug, int, 0);
 module_param(max_interrupt_work, int, 0);
 module_param(rx_copybreak, int, 0);
@@ -123,6 +125,7 @@ int tulip_debug = TULIP_DEBUG;
 #else
 int tulip_debug = 1;
 #endif
+bool tulip_bql_disable;
 
 static void tulip_timer(unsigned long data)
 {
@@ -703,6 +706,8 @@ tulip_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	wmb();
 
 	tp->cur_tx++;
+	if (likely(tulip_bql_disable == false))
+		netdev_sent_queue(dev, skb->len);
 
 	/* Trigger an immediate transmit demand. */
 	iowrite32(0, tp->base_addr + CSR1);
@@ -746,6 +751,8 @@ static void tulip_clean_tx_ring(struct tulip_private *tp)
 		tp->tx_buffers[entry].skb = NULL;
 		tp->tx_buffers[entry].mapping = 0;
 	}
+	if (likely(tulip_bql_disable == false))
+		netdev_reset_queue(tp->dev);
 }
 
 static void tulip_down (struct net_device *dev)
-- 
1.8.4.1
