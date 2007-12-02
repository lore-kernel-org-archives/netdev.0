From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [UPDATED PATCH] SGISEEQ: use cached memory access to make driver work on IP28
Date: Sun,  2 Dec 2007 11:33:12 +0100 (CET)
Message-ID: <20071202103312.75E51C2EB5@solo.franken.de>
Cc: ralf@linux-mips.org, jgarzik@pobox.com
To: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:57565 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493AbXLBLKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 06:10:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGI IP28 machines would need special treatment (enable adding addtional
wait states) when accessing memory uncached. To avoid this pain I changed
the driver to use only cached access to memory.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

Changes to last version:
- Use inline functions for dma_sync_* instead of macros (suggested by Ralf)
- added Kconfig change to make selection for similair SGI boxes easier


 drivers/net/Kconfig   |    2 +-
 drivers/net/sgiseeq.c |  243 ++++++++++++++++++++++++++++++++++---------------
 2 files changed, 171 insertions(+), 74 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7a55bc1..9cbd5de 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1795,7 +1795,7 @@ config DE620
 
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
-	depends on SGI_IP22
+	depends on SGI_HAS_SEEQ
 	help
 	  Say Y here if you have an Seeq based Ethernet network card. This is
 	  used in many Silicon Graphics machines.
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index ff40563..c69bb8b 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -12,7 +12,6 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
-#include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
@@ -53,14 +52,27 @@ static char *sgiseeqstr = "SGI Seeq8003";
 			    sp->tx_old + (SEEQ_TX_BUFFERS - 1) - sp->tx_new : \
 			    sp->tx_old - sp->tx_new - 1)
 
+#define VIRT_TO_DMA(sp, v) ((sp)->srings_dma +                                 \
+				  (dma_addr_t)((unsigned long)(v) -            \
+					       (unsigned long)((sp)->rx_desc)))
+
+/* Copy frames shorter than rx_copybreak, otherwise pass on up in
+ * a full sized sk_buff.  Value of 100 stolen from tulip.c (!alpha).
+ */
+static int rx_copybreak = 100;
+
+#define PAD_SIZE    (128 - sizeof(struct hpc_dma_desc) - sizeof(void *))
+
 struct sgiseeq_rx_desc {
 	volatile struct hpc_dma_desc rdma;
-	volatile signed int buf_vaddr;
+	u8 padding[PAD_SIZE];
+	struct sk_buff *skb;
 };
 
 struct sgiseeq_tx_desc {
 	volatile struct hpc_dma_desc tdma;
-	volatile signed int buf_vaddr;
+	u8 padding[PAD_SIZE];
+	struct sk_buff *skb;
 };
 
 /*
@@ -96,6 +108,18 @@ struct sgiseeq_private {
 	spinlock_t tx_lock;
 };
 
+static inline void dma_sync_desc_cpu(struct net_device *dev, void *addr)
+{
+	dma_cache_sync(dev->dev.parent, addr, sizeof(struct sgiseeq_rx_desc),
+		       DMA_FROM_DEVICE);
+}
+
+static inline void dma_sync_desc_dev(struct net_device *dev, void *addr)
+{
+	dma_cache_sync(dev->dev.parent, addr, sizeof(struct sgiseeq_rx_desc),
+		       DMA_TO_DEVICE);
+}
+
 static inline void hpc3_eth_reset(struct hpc3_ethregs *hregs)
 {
 	hregs->reset = HPC3_ERST_CRESET | HPC3_ERST_CLRIRQ;
@@ -163,35 +187,55 @@ static int seeq_init_ring(struct net_device *dev)
 
 	/* Setup tx ring. */
 	for(i = 0; i < SEEQ_TX_BUFFERS; i++) {
-		if (!sp->tx_desc[i].tdma.pbuf) {
-			unsigned long buffer;
-
-			buffer = (unsigned long) kmalloc(PKT_BUF_SZ, GFP_KERNEL);
-			if (!buffer)
-				return -ENOMEM;
-			sp->tx_desc[i].buf_vaddr = CKSEG1ADDR(buffer);
-			sp->tx_desc[i].tdma.pbuf = CPHYSADDR(buffer);
-		}
 		sp->tx_desc[i].tdma.cntinfo = TCNTINFO_INIT;
+		dma_sync_desc_dev(dev, &sp->tx_desc[i]);
 	}
 
 	/* And now the rx ring. */
 	for (i = 0; i < SEEQ_RX_BUFFERS; i++) {
 		if (!sp->rx_desc[i].rdma.pbuf) {
-			unsigned long buffer;
+			dma_addr_t dma_addr;
+			struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 
-			buffer = (unsigned long) kmalloc(PKT_BUF_SZ, GFP_KERNEL);
-			if (!buffer)
+			if (skb == NULL)
 				return -ENOMEM;
-			sp->rx_desc[i].buf_vaddr = CKSEG1ADDR(buffer);
-			sp->rx_desc[i].rdma.pbuf = CPHYSADDR(buffer);
+			skb_reserve(skb, 2);
+			dma_addr = dma_map_single(dev->dev.parent,
+						  skb->data - 2,
+						  PKT_BUF_SZ, DMA_FROM_DEVICE);
+			sp->rx_desc[i].skb = skb;
+			sp->rx_desc[i].rdma.pbuf = dma_addr;
 		}
 		sp->rx_desc[i].rdma.cntinfo = RCNTINFO_INIT;
+		dma_sync_desc_dev(dev, &sp->rx_desc[i]);
 	}
 	sp->rx_desc[i - 1].rdma.cntinfo |= HPCDMA_EOR;
+	dma_sync_desc_dev(dev, &sp->rx_desc[i - 1]);
 	return 0;
 }
 
+static void seeq_purge_ring(struct net_device *dev)
+{
+	struct sgiseeq_private *sp = netdev_priv(dev);
+	int i;
+
+	/* clear tx ring. */
+	for (i = 0; i < SEEQ_TX_BUFFERS; i++) {
+		if (sp->tx_desc[i].skb) {
+			dev_kfree_skb(sp->tx_desc[i].skb);
+			sp->tx_desc[i].skb = NULL;
+		}
+	}
+
+	/* And now the rx ring. */
+	for (i = 0; i < SEEQ_RX_BUFFERS; i++) {
+		if (sp->rx_desc[i].skb) {
+			dev_kfree_skb(sp->rx_desc[i].skb);
+			sp->rx_desc[i].skb = NULL;
+		}
+	}
+}
+
 #ifdef DEBUG
 static struct sgiseeq_private *gpriv;
 static struct net_device *gdev;
@@ -258,8 +302,8 @@ static int init_seeq(struct net_device *dev, struct sgiseeq_private *sp,
 		sregs->tstat = TSTAT_INIT_SEEQ;
 	}
 
-	hregs->rx_ndptr = CPHYSADDR(sp->rx_desc);
-	hregs->tx_ndptr = CPHYSADDR(sp->tx_desc);
+	hregs->rx_ndptr = VIRT_TO_DMA(sp, sp->rx_desc);
+	hregs->tx_ndptr = VIRT_TO_DMA(sp, sp->tx_desc);
 
 	seeq_go(sp, hregs, sregs);
 	return 0;
@@ -283,69 +327,90 @@ static inline void rx_maybe_restart(struct sgiseeq_private *sp,
 				    struct sgiseeq_regs *sregs)
 {
 	if (!(hregs->rx_ctrl & HPC3_ERXCTRL_ACTIVE)) {
-		hregs->rx_ndptr = CPHYSADDR(sp->rx_desc + sp->rx_new);
+		hregs->rx_ndptr = VIRT_TO_DMA(sp, sp->rx_desc + sp->rx_new);
 		seeq_go(sp, hregs, sregs);
 	}
 }
 
-#define for_each_rx(rd, sp) for((rd) = &(sp)->rx_desc[(sp)->rx_new]; \
-				!((rd)->rdma.cntinfo & HPCDMA_OWN); \
-				(rd) = &(sp)->rx_desc[(sp)->rx_new])
-
 static inline void sgiseeq_rx(struct net_device *dev, struct sgiseeq_private *sp,
 			      struct hpc3_ethregs *hregs,
 			      struct sgiseeq_regs *sregs)
 {
 	struct sgiseeq_rx_desc *rd;
 	struct sk_buff *skb = NULL;
+	struct sk_buff *newskb;
 	unsigned char pkt_status;
-	unsigned char *pkt_pointer = NULL;
 	int len = 0;
 	unsigned int orig_end = PREV_RX(sp->rx_new);
 
 	/* Service every received packet. */
-	for_each_rx(rd, sp) {
+	rd = &sp->rx_desc[sp->rx_new];
+	dma_sync_desc_cpu(dev, rd);
+	while (!(rd->rdma.cntinfo & HPCDMA_OWN)) {
 		len = PKT_BUF_SZ - (rd->rdma.cntinfo & HPCDMA_BCNT) - 3;
-		pkt_pointer = (unsigned char *)(long)rd->buf_vaddr;
-		pkt_status = pkt_pointer[len + 2];
-
+		dma_unmap_single(dev->dev.parent, rd->rdma.pbuf,
+				 PKT_BUF_SZ, DMA_FROM_DEVICE);
+		pkt_status = rd->skb->data[len];
 		if (pkt_status & SEEQ_RSTAT_FIG) {
 			/* Packet is OK. */
-			skb = dev_alloc_skb(len + 2);
-
-			if (skb) {
-				skb_reserve(skb, 2);
-				skb_put(skb, len);
-
-				/* Copy out of kseg1 to avoid silly cache flush. */
-				skb_copy_to_linear_data(skb, pkt_pointer + 2, len);
-				skb->protocol = eth_type_trans(skb, dev);
-
-				/* We don't want to receive our own packets */
-				if (memcmp(eth_hdr(skb)->h_source, dev->dev_addr, ETH_ALEN)) {
+			/* We don't want to receive our own packets */
+			if (memcmp(rd->skb->data + 6, dev->dev_addr, ETH_ALEN)) {
+				if (len > rx_copybreak) {
+					skb = rd->skb;
+					newskb = netdev_alloc_skb(dev, PKT_BUF_SZ);
+					if (!newskb) {
+						newskb = skb;
+						skb = NULL;
+						goto memory_squeeze;
+					}
+					skb_reserve(newskb, 2);
+				} else {
+					skb = netdev_alloc_skb(dev, len + 2);
+					if (skb) {
+						skb_reserve(skb, 2);
+						skb_copy_to_linear_data(skb, rd->skb->data, len);
+					}
+					newskb = rd->skb;
+				}
+memory_squeeze:
+				if (skb) {
+					skb_put(skb, len);
+					skb->protocol = eth_type_trans(skb, dev);
 					netif_rx(skb);
 					dev->last_rx = jiffies;
 					dev->stats.rx_packets++;
 					dev->stats.rx_bytes += len;
 				} else {
-					/* Silently drop my own packets */
-					dev_kfree_skb_irq(skb);
+					printk(KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
+						dev->name);
+					dev->stats.rx_dropped++;
 				}
 			} else {
-				printk (KERN_NOTICE "%s: Memory squeeze, deferring packet.\n",
-					dev->name);
-				dev->stats.rx_dropped++;
+				/* Silently drop my own packets */
+				newskb = rd->skb;
 			}
 		} else {
 			record_rx_errors(dev, pkt_status);
+			newskb = rd->skb;
 		}
+		rd->skb = newskb;
+		rd->rdma.pbuf = dma_map_single(dev->dev.parent,
+					       newskb->data - 2,
+					       PKT_BUF_SZ, DMA_FROM_DEVICE);
 
 		/* Return the entry to the ring pool. */
 		rd->rdma.cntinfo = RCNTINFO_INIT;
 		sp->rx_new = NEXT_RX(sp->rx_new);
+		dma_sync_desc_dev(dev, rd);
+		rd = &sp->rx_desc[sp->rx_new];
+		dma_sync_desc_cpu(dev, rd);
 	}
+	dma_sync_desc_cpu(dev, &sp->rx_desc[orig_end]);
 	sp->rx_desc[orig_end].rdma.cntinfo &= ~(HPCDMA_EOR);
+	dma_sync_desc_dev(dev, &sp->rx_desc[orig_end]);
+	dma_sync_desc_cpu(dev, &sp->rx_desc[PREV_RX(sp->rx_new)]);
 	sp->rx_desc[PREV_RX(sp->rx_new)].rdma.cntinfo |= HPCDMA_EOR;
+	dma_sync_desc_dev(dev, &sp->rx_desc[PREV_RX(sp->rx_new)]);
 	rx_maybe_restart(sp, hregs, sregs);
 }
 
@@ -358,20 +423,29 @@ static inline void tx_maybe_reset_collisions(struct sgiseeq_private *sp,
 	}
 }
 
-static inline void kick_tx(struct sgiseeq_tx_desc *td,
+static inline void kick_tx(struct net_device *dev,
+			   struct sgiseeq_private *sp,
 			   struct hpc3_ethregs *hregs)
 {
+	struct sgiseeq_tx_desc *td;
+	int i = sp->tx_old;
+
 	/* If the HPC aint doin nothin, and there are more packets
 	 * with ETXD cleared and XIU set we must make very certain
 	 * that we restart the HPC else we risk locking up the
 	 * adapter.  The following code is only safe iff the HPCDMA
 	 * is not active!
 	 */
+	td = &sp->tx_desc[i];
+	dma_sync_desc_cpu(dev, td);
 	while ((td->tdma.cntinfo & (HPCDMA_XIU | HPCDMA_ETXD)) ==
-	      (HPCDMA_XIU | HPCDMA_ETXD))
-		td = (struct sgiseeq_tx_desc *)(long) CKSEG1ADDR(td->tdma.pnext);
+	      (HPCDMA_XIU | HPCDMA_ETXD)) {
+		i = NEXT_TX(i);
+		td = &sp->tx_desc[i];
+		dma_sync_desc_cpu(dev, td);
+	}
 	if (td->tdma.cntinfo & HPCDMA_XIU) {
-		hregs->tx_ndptr = CPHYSADDR(td);
+		hregs->tx_ndptr = VIRT_TO_DMA(sp, td);
 		hregs->tx_ctrl = HPC3_ETXCTRL_ACTIVE;
 	}
 }
@@ -400,11 +474,12 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 	for (j = sp->tx_old; j != sp->tx_new; j = NEXT_TX(j)) {
 		td = &sp->tx_desc[j];
 
+		dma_sync_desc_cpu(dev, td);
 		if (!(td->tdma.cntinfo & (HPCDMA_XIU)))
 			break;
 		if (!(td->tdma.cntinfo & (HPCDMA_ETXD))) {
 			if (!(status & HPC3_ETXCTRL_ACTIVE)) {
-				hregs->tx_ndptr = CPHYSADDR(td);
+				hregs->tx_ndptr = VIRT_TO_DMA(sp, td);
 				hregs->tx_ctrl = HPC3_ETXCTRL_ACTIVE;
 			}
 			break;
@@ -413,6 +488,11 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 		sp->tx_old = NEXT_TX(sp->tx_old);
 		td->tdma.cntinfo &= ~(HPCDMA_XIU | HPCDMA_XIE);
 		td->tdma.cntinfo |= HPCDMA_EOX;
+		if (td->skb) {
+			dev_kfree_skb_any(td->skb);
+			td->skb = NULL;
+		}
+		dma_sync_desc_dev(dev, td);
 	}
 }
 
@@ -480,6 +560,7 @@ static int sgiseeq_close(struct net_device *dev)
 	/* Shutdown the Seeq. */
 	reset_hpc3_and_seeq(sp->hregs, sregs);
 	free_irq(irq, dev);
+	seeq_purge_ring(dev);
 
 	return 0;
 }
@@ -506,16 +587,22 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct hpc3_ethregs *hregs = sp->hregs;
 	unsigned long flags;
 	struct sgiseeq_tx_desc *td;
-	int skblen, len, entry;
+	int len, entry;
 
 	spin_lock_irqsave(&sp->tx_lock, flags);
 
 	/* Setup... */
-	skblen = skb->len;
-	len = (skblen <= ETH_ZLEN) ? ETH_ZLEN : skblen;
+	len = skb->len;
+	if (len < ETH_ZLEN) {
+		if (skb_padto(skb, ETH_ZLEN))
+			return 0;
+		len = ETH_ZLEN;
+	}
+
 	dev->stats.tx_bytes += len;
 	entry = sp->tx_new;
 	td = &sp->tx_desc[entry];
+	dma_sync_desc_cpu(dev, td);
 
 	/* Create entry.  There are so many races with adding a new
 	 * descriptor to the chain:
@@ -530,25 +617,27 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 *    entry and the HPC got to the end of the chain before we
 	 *    added this new entry and restarted it.
 	 */
-	skb_copy_from_linear_data(skb, (char *)(long)td->buf_vaddr, skblen);
-	if (len != skblen)
-		memset((char *)(long)td->buf_vaddr + skb->len, 0, len-skblen);
+	td->skb = skb;
+	td->tdma.pbuf = dma_map_single(dev->dev.parent, skb->data,
+				       len, DMA_TO_DEVICE);
 	td->tdma.cntinfo = (len & HPCDMA_BCNT) |
 	                   HPCDMA_XIU | HPCDMA_EOXP | HPCDMA_XIE | HPCDMA_EOX;
+	dma_sync_desc_dev(dev, td);
 	if (sp->tx_old != sp->tx_new) {
 		struct sgiseeq_tx_desc *backend;
 
 		backend = &sp->tx_desc[PREV_TX(sp->tx_new)];
+		dma_sync_desc_cpu(dev, backend);
 		backend->tdma.cntinfo &= ~HPCDMA_EOX;
+		dma_sync_desc_dev(dev, backend);
 	}
 	sp->tx_new = NEXT_TX(sp->tx_new); /* Advance. */
 
 	/* Maybe kick the HPC back into motion. */
 	if (!(hregs->tx_ctrl & HPC3_ETXCTRL_ACTIVE))
-		kick_tx(&sp->tx_desc[sp->tx_old], hregs);
+		kick_tx(dev, sp, hregs);
 
 	dev->trans_start = jiffies;
-	dev_kfree_skb(skb);
 
 	if (!TX_BUFFS_AVAIL(sp))
 		netif_stop_queue(dev);
@@ -586,33 +675,41 @@ static void sgiseeq_set_multicast(struct net_device *dev)
 		sgiseeq_reset(dev);
 }
 
-static inline void setup_tx_ring(struct sgiseeq_tx_desc *buf, int nbufs)
+static inline void setup_tx_ring(struct net_device *dev,
+				 struct sgiseeq_tx_desc *buf,
+				 int nbufs)
 {
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	int i = 0;
 
 	while (i < (nbufs - 1)) {
-		buf[i].tdma.pnext = CPHYSADDR(buf + i + 1);
+		buf[i].tdma.pnext = VIRT_TO_DMA(sp, buf + i + 1);
 		buf[i].tdma.pbuf = 0;
+		dma_sync_desc_dev(dev, &buf[i]);
 		i++;
 	}
-	buf[i].tdma.pnext = CPHYSADDR(buf);
+	buf[i].tdma.pnext = VIRT_TO_DMA(sp, buf);
+	dma_sync_desc_dev(dev, &buf[i]);
 }
 
-static inline void setup_rx_ring(struct sgiseeq_rx_desc *buf, int nbufs)
+static inline void setup_rx_ring(struct net_device *dev,
+				 struct sgiseeq_rx_desc *buf,
+				 int nbufs)
 {
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	int i = 0;
 
 	while (i < (nbufs - 1)) {
-		buf[i].rdma.pnext = CPHYSADDR(buf + i + 1);
+		buf[i].rdma.pnext = VIRT_TO_DMA(sp, buf + i + 1);
 		buf[i].rdma.pbuf = 0;
+		dma_sync_desc_dev(dev, &buf[i]);
 		i++;
 	}
 	buf[i].rdma.pbuf = 0;
-	buf[i].rdma.pnext = CPHYSADDR(buf);
+	buf[i].rdma.pnext = VIRT_TO_DMA(sp, buf);
+	dma_sync_desc_dev(dev, &buf[i]);
 }
 
-#define ALIGNED(x)  ((((unsigned long)(x)) + 0xf) & ~(0xf))
-
 static int __init sgiseeq_probe(struct platform_device *pdev)
 {
 	struct sgiseeq_platform_data *pd = pdev->dev.platform_data;
@@ -621,7 +718,7 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 	unsigned int irq = pd->irq;
 	struct sgiseeq_private *sp;
 	struct net_device *dev;
-	int err, i;
+	int err;
 	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(sizeof (struct sgiseeq_private));
@@ -635,7 +732,7 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 	sp = netdev_priv(dev);
 
 	/* Make private data page aligned */
-	sr = dma_alloc_coherent(&pdev->dev, sizeof(*sp->srings),
+	sr = dma_alloc_noncoherent(&pdev->dev, sizeof(*sp->srings),
 				&sp->srings_dma, GFP_KERNEL);
 	if (!sr) {
 		printk(KERN_ERR "Sgiseeq: Page alloc failed, aborting.\n");
@@ -647,8 +744,8 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 	sp->tx_desc = sp->srings->txvector;
 
 	/* A couple calculations now, saves many cycles later. */
-	setup_rx_ring(sp->rx_desc, SEEQ_RX_BUFFERS);
-	setup_tx_ring(sp->tx_desc, SEEQ_TX_BUFFERS);
+	setup_rx_ring(dev, sp->rx_desc, SEEQ_RX_BUFFERS);
+	setup_tx_ring(dev, sp->tx_desc, SEEQ_TX_BUFFERS);
 
 	memcpy(dev->dev_addr, pd->mac, ETH_ALEN);
 
@@ -716,8 +813,8 @@ static int __exit sgiseeq_remove(struct platform_device *pdev)
 	struct sgiseeq_private *sp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	dma_free_coherent(&pdev->dev, sizeof(*sp->srings), sp->srings,
-	                  sp->srings_dma);
+	dma_free_noncoherent(&pdev->dev, sizeof(*sp->srings), sp->srings,
+			     sp->srings_dma);
 	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
 

