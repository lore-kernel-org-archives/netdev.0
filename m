From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/3] sungem, sunhme,
 sunvnet: Update drivers to use dma_wmb/rmb
Date: Tue, 07 Apr 2015 16:55:14 -0700
Message-ID: <20150407235514.1574.75817.stgit@ahduyck-vm-fedora22>
References: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752871AbbDGXzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 19:55:16 -0400
In-Reply-To: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes through and replaces wmb/rmb with dma_wmb/dma_rmb in cases
where the barrier is being used to order writes or reads to just memory and
doesn't involve any programmed I/O.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/sun/sungem.c  |   14 +++++++-------
 drivers/net/ethernet/sun/sunhme.c  |   16 ++++++++--------
 drivers/net/ethernet/sun/sunvnet.c |    6 +++---
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 74e9b148378c..e23a642357e7 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -718,7 +718,7 @@ static __inline__ void gem_post_rxds(struct gem *gp, int limit)
 	cluster_start = curr = (gp->rx_new & ~(4 - 1));
 	count = 0;
 	kick = -1;
-	wmb();
+	dma_wmb();
 	while (curr != limit) {
 		curr = NEXT_RX(curr);
 		if (++count == 4) {
@@ -1038,7 +1038,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 		if (gem_intme(entry))
 			ctrl |= TXDCTRL_INTME;
 		txd->buffer = cpu_to_le64(mapping);
-		wmb();
+		dma_wmb();
 		txd->control_word = cpu_to_le64(ctrl);
 		entry = NEXT_TX(entry);
 	} else {
@@ -1076,7 +1076,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 
 			txd = &gp->init_block->txd[entry];
 			txd->buffer = cpu_to_le64(mapping);
-			wmb();
+			dma_wmb();
 			txd->control_word = cpu_to_le64(this_ctrl | len);
 
 			if (gem_intme(entry))
@@ -1086,7 +1086,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 		}
 		txd = &gp->init_block->txd[first_entry];
 		txd->buffer = cpu_to_le64(first_mapping);
-		wmb();
+		dma_wmb();
 		txd->control_word =
 			cpu_to_le64(ctrl | TXDCTRL_SOF | intme | first_len);
 	}
@@ -1585,7 +1585,7 @@ static void gem_clean_rings(struct gem *gp)
 			gp->rx_skbs[i] = NULL;
 		}
 		rxd->status_word = 0;
-		wmb();
+		dma_wmb();
 		rxd->buffer = 0;
 	}
 
@@ -1647,7 +1647,7 @@ static void gem_init_rings(struct gem *gp)
 					RX_BUF_ALLOC_SIZE(gp),
 					PCI_DMA_FROMDEVICE);
 		rxd->buffer = cpu_to_le64(dma_addr);
-		wmb();
+		dma_wmb();
 		rxd->status_word = cpu_to_le64(RXDCTRL_FRESH(gp));
 		skb_reserve(skb, RX_OFFSET);
 	}
@@ -1656,7 +1656,7 @@ static void gem_init_rings(struct gem *gp)
 		struct gem_txd *txd = &gb->txd[i];
 
 		txd->control_word = 0;
-		wmb();
+		dma_wmb();
 		txd->buffer = 0;
 	}
 	wmb();
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 7a8ca2c7b7df..cf4dcff051d5 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -196,14 +196,14 @@ static u32 sbus_hme_read32(void __iomem *reg)
 static void sbus_hme_write_rxd(struct happy_meal_rxd *rxd, u32 flags, u32 addr)
 {
 	rxd->rx_addr = (__force hme32)addr;
-	wmb();
+	dma_wmb();
 	rxd->rx_flags = (__force hme32)flags;
 }
 
 static void sbus_hme_write_txd(struct happy_meal_txd *txd, u32 flags, u32 addr)
 {
 	txd->tx_addr = (__force hme32)addr;
-	wmb();
+	dma_wmb();
 	txd->tx_flags = (__force hme32)flags;
 }
 
@@ -225,14 +225,14 @@ static u32 pci_hme_read32(void __iomem *reg)
 static void pci_hme_write_rxd(struct happy_meal_rxd *rxd, u32 flags, u32 addr)
 {
 	rxd->rx_addr = (__force hme32)cpu_to_le32(addr);
-	wmb();
+	dma_wmb();
 	rxd->rx_flags = (__force hme32)cpu_to_le32(flags);
 }
 
 static void pci_hme_write_txd(struct happy_meal_txd *txd, u32 flags, u32 addr)
 {
 	txd->tx_addr = (__force hme32)cpu_to_le32(addr);
-	wmb();
+	dma_wmb();
 	txd->tx_flags = (__force hme32)cpu_to_le32(flags);
 }
 
@@ -268,12 +268,12 @@ static u32 pci_hme_read_desc32(hme32 *p)
 	sbus_readl(__reg)
 #define hme_write_rxd(__hp, __rxd, __flags, __addr) \
 do {	(__rxd)->rx_addr = (__force hme32)(u32)(__addr); \
-	wmb(); \
+	dma_wmb(); \
 	(__rxd)->rx_flags = (__force hme32)(u32)(__flags); \
 } while(0)
 #define hme_write_txd(__hp, __txd, __flags, __addr) \
 do {	(__txd)->tx_addr = (__force hme32)(u32)(__addr); \
-	wmb(); \
+	dma_wmb(); \
 	(__txd)->tx_flags = (__force hme32)(u32)(__flags); \
 } while(0)
 #define hme_read_desc32(__hp, __p)	((__force u32)(hme32)*(__p))
@@ -293,12 +293,12 @@ do {	(__txd)->tx_addr = (__force hme32)(u32)(__addr); \
 	readl(__reg)
 #define hme_write_rxd(__hp, __rxd, __flags, __addr) \
 do {	(__rxd)->rx_addr = (__force hme32)cpu_to_le32(__addr); \
-	wmb(); \
+	dma_wmb(); \
 	(__rxd)->rx_flags = (__force hme32)cpu_to_le32(__flags); \
 } while(0)
 #define hme_write_txd(__hp, __txd, __flags, __addr) \
 do {	(__txd)->tx_addr = (__force hme32)cpu_to_le32(__addr); \
-	wmb(); \
+	dma_wmb(); \
 	(__txd)->tx_flags = (__force hme32)cpu_to_le32(__flags); \
 } while(0)
 static inline u32 hme_read_desc32(struct happy_meal *hp, hme32 *p)
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 401abf7254d3..53fe200e0b79 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -519,7 +519,7 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	if (desc->hdr.state != VIO_DESC_READY)
 		return 1;
 
-	rmb();
+	dma_rmb();
 
 	viodbg(DATA, "vio_walk_rx_one desc[%02x:%02x:%08x:%08x:%llx:%llx]\n",
 	       desc->hdr.state, desc->hdr.ack,
@@ -1380,7 +1380,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* This has to be a non-SMP write barrier because we are writing
 	 * to memory which is shared with the peer LDOM.
 	 */
-	wmb();
+	dma_wmb();
 
 	d->hdr.state = VIO_DESC_READY;
 
@@ -1395,7 +1395,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * is marked READY, but start_cons was false.
 	 * If so, vnet_ack() should send out the missed "start" trigger.
 	 *
-	 * Note that the wmb() above makes sure the cookies et al. are
+	 * Note that the dma_wmb() above makes sure the cookies et al. are
 	 * not globally visible before the VIO_DESC_READY, and that the
 	 * stores are ordered correctly by the compiler. The consumer will
 	 * not proceed until the VIO_DESC_READY is visible assuring that
