From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [UPDATED PATCH] SGISEEQ: use cached memory access to make driver work on IP28
Date: Wed, 19 Dec 2007 13:42:36 +0100
Message-ID: <20071219124235.GA7550@alpha.franken.de>
References: <20071202103312.75E51C2EB5@solo.franken.de> <47671FEE.90103@pobox.com> <20071218103006.GA18598@alpha.franken.de> <476867F5.3070006@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:46608 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752703AbXLSMm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 07:42:56 -0500
Content-Disposition: inline
In-Reply-To: <476867F5.3070006@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use inline functions for dma_sync_* instead of macros 
- added Kconfig change to make selection for similair SGI boxes easier

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 drivers/net/Kconfig   |    2 +-
 drivers/net/sgiseeq.c |   64 ++++++++++++++++++++++++++-----------------------
 2 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 84df799..f816798 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1807,7 +1807,7 @@ config DE620
 
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
-	depends on SGI_IP22
+	depends on SGI_HAS_SEEQ
 	help
 	  Say Y here if you have an Seeq based Ethernet network card. This is
 	  used in many Silicon Graphics machines.
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 3145ca1..c69bb8b 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -56,14 +56,6 @@ static char *sgiseeqstr = "SGI Seeq8003";
 				  (dma_addr_t)((unsigned long)(v) -            \
 					       (unsigned long)((sp)->rx_desc)))
 
-#define DMA_SYNC_DESC_CPU(dev, addr) \
-	do { dma_cache_sync((dev)->dev.parent, (void *)addr, \
-	     sizeof(struct sgiseeq_rx_desc), DMA_FROM_DEVICE); } while (0)
-
-#define DMA_SYNC_DESC_DEV(dev, addr) \
-	do { dma_cache_sync((dev)->dev.parent, (void *)addr, \
-	     sizeof(struct sgiseeq_rx_desc), DMA_TO_DEVICE); } while (0)
-
 /* Copy frames shorter than rx_copybreak, otherwise pass on up in
  * a full sized sk_buff.  Value of 100 stolen from tulip.c (!alpha).
  */
@@ -116,6 +108,18 @@ struct sgiseeq_private {
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
@@ -184,7 +188,7 @@ static int seeq_init_ring(struct net_device *dev)
 	/* Setup tx ring. */
 	for(i = 0; i < SEEQ_TX_BUFFERS; i++) {
 		sp->tx_desc[i].tdma.cntinfo = TCNTINFO_INIT;
-		DMA_SYNC_DESC_DEV(dev, &sp->tx_desc[i]);
+		dma_sync_desc_dev(dev, &sp->tx_desc[i]);
 	}
 
 	/* And now the rx ring. */
@@ -203,10 +207,10 @@ static int seeq_init_ring(struct net_device *dev)
 			sp->rx_desc[i].rdma.pbuf = dma_addr;
 		}
 		sp->rx_desc[i].rdma.cntinfo = RCNTINFO_INIT;
-		DMA_SYNC_DESC_DEV(dev, &sp->rx_desc[i]);
+		dma_sync_desc_dev(dev, &sp->rx_desc[i]);
 	}
 	sp->rx_desc[i - 1].rdma.cntinfo |= HPCDMA_EOR;
-	DMA_SYNC_DESC_DEV(dev, &sp->rx_desc[i - 1]);
+	dma_sync_desc_dev(dev, &sp->rx_desc[i - 1]);
 	return 0;
 }
 
@@ -341,7 +345,7 @@ static inline void sgiseeq_rx(struct net_device *dev, struct sgiseeq_private *sp
 
 	/* Service every received packet. */
 	rd = &sp->rx_desc[sp->rx_new];
-	DMA_SYNC_DESC_CPU(dev, rd);
+	dma_sync_desc_cpu(dev, rd);
 	while (!(rd->rdma.cntinfo & HPCDMA_OWN)) {
 		len = PKT_BUF_SZ - (rd->rdma.cntinfo & HPCDMA_BCNT) - 3;
 		dma_unmap_single(dev->dev.parent, rd->rdma.pbuf,
@@ -397,16 +401,16 @@ memory_squeeze:
 		/* Return the entry to the ring pool. */
 		rd->rdma.cntinfo = RCNTINFO_INIT;
 		sp->rx_new = NEXT_RX(sp->rx_new);
-		DMA_SYNC_DESC_DEV(dev, rd);
+		dma_sync_desc_dev(dev, rd);
 		rd = &sp->rx_desc[sp->rx_new];
-		DMA_SYNC_DESC_CPU(dev, rd);
+		dma_sync_desc_cpu(dev, rd);
 	}
-	DMA_SYNC_DESC_CPU(dev, &sp->rx_desc[orig_end]);
+	dma_sync_desc_cpu(dev, &sp->rx_desc[orig_end]);
 	sp->rx_desc[orig_end].rdma.cntinfo &= ~(HPCDMA_EOR);
-	DMA_SYNC_DESC_DEV(dev, &sp->rx_desc[orig_end]);
-	DMA_SYNC_DESC_CPU(dev, &sp->rx_desc[PREV_RX(sp->rx_new)]);
+	dma_sync_desc_dev(dev, &sp->rx_desc[orig_end]);
+	dma_sync_desc_cpu(dev, &sp->rx_desc[PREV_RX(sp->rx_new)]);
 	sp->rx_desc[PREV_RX(sp->rx_new)].rdma.cntinfo |= HPCDMA_EOR;
-	DMA_SYNC_DESC_DEV(dev, &sp->rx_desc[PREV_RX(sp->rx_new)]);
+	dma_sync_desc_dev(dev, &sp->rx_desc[PREV_RX(sp->rx_new)]);
 	rx_maybe_restart(sp, hregs, sregs);
 }
 
@@ -433,12 +437,12 @@ static inline void kick_tx(struct net_device *dev,
 	 * is not active!
 	 */
 	td = &sp->tx_desc[i];
-	DMA_SYNC_DESC_CPU(dev, td);
+	dma_sync_desc_cpu(dev, td);
 	while ((td->tdma.cntinfo & (HPCDMA_XIU | HPCDMA_ETXD)) ==
 	      (HPCDMA_XIU | HPCDMA_ETXD)) {
 		i = NEXT_TX(i);
 		td = &sp->tx_desc[i];
-		DMA_SYNC_DESC_CPU(dev, td);
+		dma_sync_desc_cpu(dev, td);
 	}
 	if (td->tdma.cntinfo & HPCDMA_XIU) {
 		hregs->tx_ndptr = VIRT_TO_DMA(sp, td);
@@ -470,7 +474,7 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 	for (j = sp->tx_old; j != sp->tx_new; j = NEXT_TX(j)) {
 		td = &sp->tx_desc[j];
 
-		DMA_SYNC_DESC_CPU(dev, td);
+		dma_sync_desc_cpu(dev, td);
 		if (!(td->tdma.cntinfo & (HPCDMA_XIU)))
 			break;
 		if (!(td->tdma.cntinfo & (HPCDMA_ETXD))) {
@@ -488,7 +492,7 @@ static inline void sgiseeq_tx(struct net_device *dev, struct sgiseeq_private *sp
 			dev_kfree_skb_any(td->skb);
 			td->skb = NULL;
 		}
-		DMA_SYNC_DESC_DEV(dev, td);
+		dma_sync_desc_dev(dev, td);
 	}
 }
 
@@ -598,7 +602,7 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += len;
 	entry = sp->tx_new;
 	td = &sp->tx_desc[entry];
-	DMA_SYNC_DESC_CPU(dev, td);
+	dma_sync_desc_cpu(dev, td);
 
 	/* Create entry.  There are so many races with adding a new
 	 * descriptor to the chain:
@@ -618,14 +622,14 @@ static int sgiseeq_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				       len, DMA_TO_DEVICE);
 	td->tdma.cntinfo = (len & HPCDMA_BCNT) |
 	                   HPCDMA_XIU | HPCDMA_EOXP | HPCDMA_XIE | HPCDMA_EOX;
-	DMA_SYNC_DESC_DEV(dev, td);
+	dma_sync_desc_dev(dev, td);
 	if (sp->tx_old != sp->tx_new) {
 		struct sgiseeq_tx_desc *backend;
 
 		backend = &sp->tx_desc[PREV_TX(sp->tx_new)];
-		DMA_SYNC_DESC_CPU(dev, backend);
+		dma_sync_desc_cpu(dev, backend);
 		backend->tdma.cntinfo &= ~HPCDMA_EOX;
-		DMA_SYNC_DESC_DEV(dev, backend);
+		dma_sync_desc_dev(dev, backend);
 	}
 	sp->tx_new = NEXT_TX(sp->tx_new); /* Advance. */
 
@@ -681,11 +685,11 @@ static inline void setup_tx_ring(struct net_device *dev,
 	while (i < (nbufs - 1)) {
 		buf[i].tdma.pnext = VIRT_TO_DMA(sp, buf + i + 1);
 		buf[i].tdma.pbuf = 0;
-		DMA_SYNC_DESC_DEV(dev, &buf[i]);
+		dma_sync_desc_dev(dev, &buf[i]);
 		i++;
 	}
 	buf[i].tdma.pnext = VIRT_TO_DMA(sp, buf);
-	DMA_SYNC_DESC_DEV(dev, &buf[i]);
+	dma_sync_desc_dev(dev, &buf[i]);
 }
 
 static inline void setup_rx_ring(struct net_device *dev,
@@ -698,12 +702,12 @@ static inline void setup_rx_ring(struct net_device *dev,
 	while (i < (nbufs - 1)) {
 		buf[i].rdma.pnext = VIRT_TO_DMA(sp, buf + i + 1);
 		buf[i].rdma.pbuf = 0;
-		DMA_SYNC_DESC_DEV(dev, &buf[i]);
+		dma_sync_desc_dev(dev, &buf[i]);
 		i++;
 	}
 	buf[i].rdma.pbuf = 0;
 	buf[i].rdma.pnext = VIRT_TO_DMA(sp, buf);
-	DMA_SYNC_DESC_DEV(dev, &buf[i]);
+	dma_sync_desc_dev(dev, &buf[i]);
 }
 
 static int __init sgiseeq_probe(struct platform_device *pdev)

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
