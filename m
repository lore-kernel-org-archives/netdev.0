From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Wed, 3 Oct 2007 14:39:16 -0400
Message-ID: <20071003183916.GA28437@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49901 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbXJCSjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 14:39:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Normally I wait a day or two between pushes, to queue up patches and
also to avoid annoying my upstream :)  But this includes a couple fixes
I felt should be upstreamed sooner rather than later.


Please pull from 'upstream' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream

to receive the following updates:

Jeff Garzik (1):
      drivers/net/qla3xxx: trim trailing whitespace

Olof Johansson (11):
      pasemi_mac: basic error checking
      pasemi_mac: fix bug in receive buffer dma mapping
      pasemi_mac: rework ring management
      pasemi_mac: implement sg support
      pasemi_mac: workaround for erratum 5971
      pasemi_mac: add local skb alignment
      pasemi_mac: further performance tweaks
      pasemi_mac: update todo list
      pasemi_mac: clear out old errors on interface open
      pasemi_mac: use buffer index pointer in clean_rx()
      pasemi_mac: enable iommu support

trem (1):
      ipg.c doesn't compile with with CONFIG_HIGHMEM64G

vbarshak@ru.mvista.com (1):
      Fix typo in new EMAC driver.

 arch/powerpc/platforms/pasemi/Kconfig |   10 
 arch/powerpc/platforms/pasemi/iommu.c |   15 
 drivers/net/ibm_newemac/core.c        |    4 
 drivers/net/ipg.c                     |   10 
 drivers/net/pasemi_mac.c              |  595 ++++++++++++++++++++++------------
 drivers/net/pasemi_mac.h              |   67 ++-
 drivers/net/qla3xxx.c                 |  128 +++----
 drivers/net/qla3xxx.h                 |    6 
 8 files changed, 527 insertions(+), 308 deletions(-)

diff --git a/arch/powerpc/platforms/pasemi/Kconfig b/arch/powerpc/platforms/pasemi/Kconfig
index 95cd90f..e95261e 100644
--- a/arch/powerpc/platforms/pasemi/Kconfig
+++ b/arch/powerpc/platforms/pasemi/Kconfig
@@ -18,6 +18,16 @@ config PPC_PASEMI_IOMMU
 	help
 	  IOMMU support for PA6T-1682M
 
+config PPC_PASEMI_IOMMU_DMA_FORCE
+	bool "Force DMA engine to use IOMMU"
+	depends on PPC_PASEMI_IOMMU
+	help
+	  This option forces the use of the IOMMU also for the
+	  DMA engine. Otherwise the kernel will use it only when
+	  running under a hypervisor.
+
+	  If in doubt, say "N".
+
 config PPC_PASEMI_MDIO
 	depends on PHYLIB
 	tristate "MDIO support via GPIO"
diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
index 9014d55..a1111b5 100644
--- a/arch/powerpc/platforms/pasemi/iommu.c
+++ b/arch/powerpc/platforms/pasemi/iommu.c
@@ -25,6 +25,7 @@
 #include <asm/iommu.h>
 #include <asm/machdep.h>
 #include <asm/abs_addr.h>
+#include <asm/firmware.h>
 
 
 #define IOBMAP_PAGE_SHIFT	12
@@ -175,13 +176,17 @@ static void pci_dma_dev_setup_pasemi(struct pci_dev *dev)
 {
 	pr_debug("pci_dma_dev_setup, dev %p (%s)\n", dev, pci_name(dev));
 
-	/* DMA device is untranslated, but all other PCI-e goes through
-	 * the IOMMU
+#if !defined(CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE)
+	/* For non-LPAR environment, don't translate anything for the DMA
+	 * engine. The exception to this is if the user has enabled
+	 * CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE at build time.
 	 */
-	if (dev->vendor == 0x1959 && dev->device == 0xa007)
+	if (dev->vendor == 0x1959 && dev->device == 0xa007 &&
+	    !firmware_has_feature(FW_FEATURE_LPAR))
 		dev->dev.archdata.dma_ops = &dma_direct_ops;
-	else
-		dev->dev.archdata.dma_data = &iommu_table_iobmap;
+#endif
+
+	dev->dev.archdata.dma_data = &iommu_table_iobmap;
 }
 
 static void pci_dma_bus_setup_null(struct pci_bus *b) { }
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 653bfdc..ce127b9 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1232,9 +1232,9 @@ static inline int emac_xmit_finish(struct emac_instance *dev, int len)
 	 * instead
 	 */
 	if (emac_has_feature(dev, EMAC_FTR_EMAC4))
-		out_be32(&p->tmr0, EMAC_TMR0_XMIT);
-	else
 		out_be32(&p->tmr0, EMAC4_TMR0_XMIT);
+	else
+		out_be32(&p->tmr0, EMAC_TMR0_XMIT);
 
 	if (unlikely(++dev->tx_cnt == NUM_TX_BUFF)) {
 		netif_stop_queue(ndev);
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dfdc96f..59898ce 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -25,6 +25,8 @@
 #include <linux/mii.h>
 #include <linux/mutex.h>
 
+#include <asm/div64.h>
+
 #define IPG_RX_RING_BYTES	(sizeof(struct ipg_rx) * IPG_RFDLIST_LENGTH)
 #define IPG_TX_RING_BYTES	(sizeof(struct ipg_tx) * IPG_TFDLIST_LENGTH)
 #define IPG_RESET_MASK \
@@ -836,10 +838,14 @@ static void ipg_nic_txfree(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
-	const unsigned int curr = ipg_r32(TFD_LIST_PTR_0) -
-		(sp->txd_map / sizeof(struct ipg_tx)) - 1;
+	unsigned int curr;
+	u64 txd_map;
 	unsigned int released, pending;
 
+	txd_map = (u64)sp->txd_map;
+	curr = ipg_r32(TFD_LIST_PTR_0) -
+		do_div(txd_map, sizeof(struct ipg_tx)) - 1;
+
 	IPG_DEBUG_MSG("_nic_txfree\n");
 
 	pending = sp->tx_current - sp->tx_dirty;
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index c2d34a8..9f9a421 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -34,24 +34,29 @@
 #include <net/checksum.h>
 
 #include <asm/irq.h>
+#include <asm/firmware.h>
 
 #include "pasemi_mac.h"
 
+/* We have our own align, since ppc64 in general has it at 0 because
+ * of design flaws in some of the server bridge chips. However, for
+ * PWRficient doing the unaligned copies is more expensive than doing
+ * unaligned DMA, so make sure the data is aligned instead.
+ */
+#define LOCAL_SKB_ALIGN	2
 
 /* TODO list
  *
- * - Get rid of pci_{read,write}_config(), map registers with ioremap
- *   for performance
- * - PHY support
  * - Multicast support
  * - Large MTU support
- * - Other performance improvements
+ * - SW LRO
+ * - Multiqueue RX/TX
  */
 
 
 /* Must be a power of two */
-#define RX_RING_SIZE 512
-#define TX_RING_SIZE 512
+#define RX_RING_SIZE 4096
+#define TX_RING_SIZE 4096
 
 #define DEFAULT_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -63,10 +68,10 @@
 	 NETIF_MSG_RX_ERR	| \
 	 NETIF_MSG_TX_ERR)
 
-#define TX_DESC(mac, num)	((mac)->tx->desc[(num) & (TX_RING_SIZE-1)])
-#define TX_DESC_INFO(mac, num)	((mac)->tx->desc_info[(num) & (TX_RING_SIZE-1)])
-#define RX_DESC(mac, num)	((mac)->rx->desc[(num) & (RX_RING_SIZE-1)])
-#define RX_DESC_INFO(mac, num)	((mac)->rx->desc_info[(num) & (RX_RING_SIZE-1)])
+#define TX_RING(mac, num)	((mac)->tx->ring[(num) & (TX_RING_SIZE-1)])
+#define TX_RING_INFO(mac, num)	((mac)->tx->ring_info[(num) & (TX_RING_SIZE-1)])
+#define RX_RING(mac, num)	((mac)->rx->ring[(num) & (RX_RING_SIZE-1)])
+#define RX_RING_INFO(mac, num)	((mac)->rx->ring_info[(num) & (RX_RING_SIZE-1)])
 #define RX_BUFF(mac, num)	((mac)->rx->buffers[(num) & (RX_RING_SIZE-1)])
 
 #define RING_USED(ring)		(((ring)->next_to_fill - (ring)->next_to_clean) \
@@ -85,6 +90,15 @@ MODULE_PARM_DESC(debug, "PA Semi MAC bitmapped debugging message enable value");
 
 static struct pasdma_status *dma_status;
 
+static int translation_enabled(void)
+{
+#if defined(CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE)
+	return 1;
+#else
+	return firmware_has_feature(FW_FEATURE_LPAR);
+#endif
+}
+
 static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
@@ -160,11 +174,36 @@ static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 	return 0;
 }
 
+static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
+				    struct sk_buff *skb,
+				    dma_addr_t *dmas)
+{
+	int f;
+	int nfrags = skb_shinfo(skb)->nr_frags;
+
+	pci_unmap_single(mac->dma_pdev, dmas[0], skb_headlen(skb),
+			 PCI_DMA_TODEVICE);
+
+	for (f = 0; f < nfrags; f++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
+
+		pci_unmap_page(mac->dma_pdev, dmas[f+1], frag->size,
+			       PCI_DMA_TODEVICE);
+	}
+	dev_kfree_skb_irq(skb);
+
+	/* Freed descriptor slot + main SKB ptr + nfrags additional ptrs,
+	 * aligned up to a power of 2
+	 */
+	return (nfrags + 3) & ~1;
+}
+
 static int pasemi_mac_setup_rx_resources(struct net_device *dev)
 {
 	struct pasemi_mac_rxring *ring;
 	struct pasemi_mac *mac = netdev_priv(dev);
 	int chan_id = mac->dma_rxch;
+	unsigned int cfg;
 
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 
@@ -174,22 +213,21 @@ static int pasemi_mac_setup_rx_resources(struct net_device *dev)
 	spin_lock_init(&ring->lock);
 
 	ring->size = RX_RING_SIZE;
-	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
+	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
 				  RX_RING_SIZE, GFP_KERNEL);
 
-	if (!ring->desc_info)
-		goto out_desc_info;
+	if (!ring->ring_info)
+		goto out_ring_info;
 
 	/* Allocate descriptors */
-	ring->desc = dma_alloc_coherent(&mac->dma_pdev->dev,
-					RX_RING_SIZE *
-					sizeof(struct pas_dma_xct_descr),
+	ring->ring = dma_alloc_coherent(&mac->dma_pdev->dev,
+					RX_RING_SIZE * sizeof(u64),
 					&ring->dma, GFP_KERNEL);
 
-	if (!ring->desc)
-		goto out_desc;
+	if (!ring->ring)
+		goto out_ring_desc;
 
-	memset(ring->desc, 0, RX_RING_SIZE * sizeof(struct pas_dma_xct_descr));
+	memset(ring->ring, 0, RX_RING_SIZE * sizeof(u64));
 
 	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
 					   RX_RING_SIZE * sizeof(u64),
@@ -203,20 +241,30 @@ static int pasemi_mac_setup_rx_resources(struct net_device *dev)
 
 	write_dma_reg(mac, PAS_DMA_RXCHAN_BASEU(chan_id),
 			   PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
-			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 2));
+			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id),
-			   PAS_DMA_RXCHAN_CFG_HBU(2));
+	cfg = PAS_DMA_RXCHAN_CFG_HBU(2);
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_RXCHAN_CFG_CTR;
+
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id), cfg);
 
 	write_dma_reg(mac, PAS_DMA_RXINT_BASEL(mac->dma_if),
-			   PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
+			   PAS_DMA_RXINT_BASEL_BRBL(ring->buf_dma));
 
 	write_dma_reg(mac, PAS_DMA_RXINT_BASEU(mac->dma_if),
-			   PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
+			   PAS_DMA_RXINT_BASEU_BRBH(ring->buf_dma >> 32) |
 			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if),
-			   PAS_DMA_RXINT_CFG_DHL(2));
+	cfg = PAS_DMA_RXINT_CFG_DHL(3) | PAS_DMA_RXINT_CFG_L2 |
+	      PAS_DMA_RXINT_CFG_LW | PAS_DMA_RXINT_CFG_RBP |
+	      PAS_DMA_RXINT_CFG_HEN;
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_RXINT_CFG_ITRR | PAS_DMA_RXINT_CFG_ITR;
+
+	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
@@ -229,11 +277,11 @@ static int pasemi_mac_setup_rx_resources(struct net_device *dev)
 
 out_buffers:
 	dma_free_coherent(&mac->dma_pdev->dev,
-			  RX_RING_SIZE * sizeof(struct pas_dma_xct_descr),
-			  mac->rx->desc, mac->rx->dma);
-out_desc:
-	kfree(ring->desc_info);
-out_desc_info:
+			  RX_RING_SIZE * sizeof(u64),
+			  mac->rx->ring, mac->rx->dma);
+out_ring_desc:
+	kfree(ring->ring_info);
+out_ring_info:
 	kfree(ring);
 out_ring:
 	return -ENOMEM;
@@ -246,6 +294,7 @@ static int pasemi_mac_setup_tx_resources(struct net_device *dev)
 	u32 val;
 	int chan_id = mac->dma_txch;
 	struct pasemi_mac_txring *ring;
+	unsigned int cfg;
 
 	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 	if (!ring)
@@ -254,33 +303,36 @@ static int pasemi_mac_setup_tx_resources(struct net_device *dev)
 	spin_lock_init(&ring->lock);
 
 	ring->size = TX_RING_SIZE;
-	ring->desc_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
+	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
 				  TX_RING_SIZE, GFP_KERNEL);
-	if (!ring->desc_info)
-		goto out_desc_info;
+	if (!ring->ring_info)
+		goto out_ring_info;
 
 	/* Allocate descriptors */
-	ring->desc = dma_alloc_coherent(&mac->dma_pdev->dev,
-					TX_RING_SIZE *
-					sizeof(struct pas_dma_xct_descr),
+	ring->ring = dma_alloc_coherent(&mac->dma_pdev->dev,
+					TX_RING_SIZE * sizeof(u64),
 					&ring->dma, GFP_KERNEL);
-	if (!ring->desc)
-		goto out_desc;
+	if (!ring->ring)
+		goto out_ring_desc;
 
-	memset(ring->desc, 0, TX_RING_SIZE * sizeof(struct pas_dma_xct_descr));
+	memset(ring->ring, 0, TX_RING_SIZE * sizeof(u64));
 
 	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEL(chan_id),
 			   PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
 	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
-	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 2);
+	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 3);
 
 	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(chan_id), val);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(chan_id),
-			   PAS_DMA_TXCHAN_CFG_TY_IFACE |
-			   PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
-			   PAS_DMA_TXCHAN_CFG_UP |
-			   PAS_DMA_TXCHAN_CFG_WT(2));
+	cfg = PAS_DMA_TXCHAN_CFG_TY_IFACE |
+	      PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
+	      PAS_DMA_TXCHAN_CFG_UP |
+	      PAS_DMA_TXCHAN_CFG_WT(2);
+
+	if (translation_enabled())
+		cfg |= PAS_DMA_TXCHAN_CFG_TRD | PAS_DMA_TXCHAN_CFG_TRR;
+
+	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(chan_id), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
@@ -291,9 +343,9 @@ static int pasemi_mac_setup_tx_resources(struct net_device *dev)
 
 	return 0;
 
-out_desc:
-	kfree(ring->desc_info);
-out_desc_info:
+out_ring_desc:
+	kfree(ring->ring_info);
+out_ring_info:
 	kfree(ring);
 out_ring:
 	return -ENOMEM;
@@ -302,33 +354,37 @@ out_ring:
 static void pasemi_mac_free_tx_resources(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int i;
+	unsigned int i, j;
 	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
-
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		info = &TX_DESC_INFO(mac, i);
-		dp = &TX_DESC(mac, i);
-		if (info->dma) {
-			if (info->skb) {
-				pci_unmap_single(mac->dma_pdev,
-						 info->dma,
-						 info->skb->len,
-						 PCI_DMA_TODEVICE);
-				dev_kfree_skb_any(info->skb);
-			}
-			info->dma = 0;
-			info->skb = NULL;
-			dp->mactx = 0;
-			dp->ptr = 0;
-		}
+	dma_addr_t dmas[MAX_SKB_FRAGS+1];
+	int freed;
+	int start, limit;
+
+	start = mac->tx->next_to_clean;
+	limit = mac->tx->next_to_fill;
+
+	/* Compensate for when fill has wrapped and clean has not */
+	if (start > limit)
+		limit += TX_RING_SIZE;
+
+	for (i = start; i < limit; i += freed) {
+		info = &TX_RING_INFO(mac, i+1);
+		if (info->dma && info->skb) {
+			for (j = 0; j <= skb_shinfo(info->skb)->nr_frags; j++)
+				dmas[j] = TX_RING_INFO(mac, i+1+j).dma;
+			freed = pasemi_mac_unmap_tx_skb(mac, info->skb, dmas);
+		} else
+			freed = 2;
 	}
 
+	for (i = 0; i < TX_RING_SIZE; i++)
+		TX_RING(mac, i) = 0;
+
 	dma_free_coherent(&mac->dma_pdev->dev,
-			  TX_RING_SIZE * sizeof(struct pas_dma_xct_descr),
-			  mac->tx->desc, mac->tx->dma);
+			  TX_RING_SIZE * sizeof(u64),
+			  mac->tx->ring, mac->tx->dma);
 
-	kfree(mac->tx->desc_info);
+	kfree(mac->tx->ring_info);
 	kfree(mac->tx);
 	mac->tx = NULL;
 }
@@ -338,34 +394,31 @@ static void pasemi_mac_free_rx_resources(struct net_device *dev)
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		info = &RX_DESC_INFO(mac, i);
-		dp = &RX_DESC(mac, i);
-		if (info->skb) {
-			if (info->dma) {
-				pci_unmap_single(mac->dma_pdev,
-						 info->dma,
-						 info->skb->len,
-						 PCI_DMA_FROMDEVICE);
-				dev_kfree_skb_any(info->skb);
-			}
-			info->dma = 0;
-			info->skb = NULL;
-			dp->macrx = 0;
-			dp->ptr = 0;
+		info = &RX_RING_INFO(mac, i);
+		if (info->skb && info->dma) {
+			pci_unmap_single(mac->dma_pdev,
+					 info->dma,
+					 info->skb->len,
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb_any(info->skb);
 		}
+		info->dma = 0;
+		info->skb = NULL;
 	}
 
+	for (i = 0; i < RX_RING_SIZE; i++)
+		RX_RING(mac, i) = 0;
+
 	dma_free_coherent(&mac->dma_pdev->dev,
-			  RX_RING_SIZE * sizeof(struct pas_dma_xct_descr),
-			  mac->rx->desc, mac->rx->dma);
+			  RX_RING_SIZE * sizeof(u64),
+			  mac->rx->ring, mac->rx->dma);
 
 	dma_free_coherent(&mac->dma_pdev->dev, RX_RING_SIZE * sizeof(u64),
 			  mac->rx->buffers, mac->rx->buf_dma);
 
-	kfree(mac->rx->desc_info);
+	kfree(mac->rx->ring_info);
 	kfree(mac->rx);
 	mac->rx = NULL;
 }
@@ -373,30 +426,34 @@ static void pasemi_mac_free_rx_resources(struct net_device *dev)
 static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int i;
-	int start = mac->rx->next_to_fill;
-	int count;
+	int fill, count;
 
 	if (limit <= 0)
 		return;
 
-	i = start;
+	fill = mac->rx->next_to_fill;
 	for (count = 0; count < limit; count++) {
-		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
-		u64 *buff = &RX_BUFF(mac, i);
+		struct pasemi_mac_buffer *info = &RX_RING_INFO(mac, fill);
+		u64 *buff = &RX_BUFF(mac, fill);
 		struct sk_buff *skb;
 		dma_addr_t dma;
 
+		/* Entry in use? */
+		WARN_ON(*buff);
+
 		/* skb might still be in there for recycle on short receives */
 		if (info->skb)
 			skb = info->skb;
-		else
+		else {
 			skb = dev_alloc_skb(BUF_SIZE);
+			skb_reserve(skb, LOCAL_SKB_ALIGN);
+		}
 
 		if (unlikely(!skb))
 			break;
 
-		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
+		dma = pci_map_single(mac->dma_pdev, skb->data,
+				     BUF_SIZE - LOCAL_SKB_ALIGN,
 				     PCI_DMA_FROMDEVICE);
 
 		if (unlikely(dma_mapping_error(dma))) {
@@ -407,15 +464,15 @@ static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 		info->skb = skb;
 		info->dma = dma;
 		*buff = XCT_RXB_LEN(BUF_SIZE) | XCT_RXB_ADDR(dma);
-		i++;
+		fill++;
 	}
 
 	wmb();
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count);
 	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), count);
 
-	mac->rx->next_to_fill += count;
+	mac->rx->next_to_fill = (mac->rx->next_to_fill + count) &
+				(RX_RING_SIZE - 1);
 }
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
@@ -445,64 +502,91 @@ static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
 }
 
 
+static inline void pasemi_mac_rx_error(struct pasemi_mac *mac, u64 macrx)
+{
+	unsigned int rcmdsta, ccmdsta;
+
+	if (!netif_msg_rx_err(mac))
+		return;
+
+	rcmdsta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+	ccmdsta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+
+	printk(KERN_ERR "pasemi_mac: rx error. macrx %016lx, rx status %lx\n",
+		macrx, *mac->rx_status);
+
+	printk(KERN_ERR "pasemi_mac: rcmdsta %08x ccmdsta %08x\n",
+		rcmdsta, ccmdsta);
+}
+
+static inline void pasemi_mac_tx_error(struct pasemi_mac *mac, u64 mactx)
+{
+	unsigned int cmdsta;
+
+	if (!netif_msg_tx_err(mac))
+		return;
+
+	cmdsta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+
+	printk(KERN_ERR "pasemi_mac: tx error. mactx 0x%016lx, "\
+		"tx status 0x%016lx\n", mactx, *mac->tx_status);
+
+	printk(KERN_ERR "pasemi_mac: tcmdsta 0x%08x\n", cmdsta);
+}
+
 static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 {
 	unsigned int n;
 	int count;
-	struct pas_dma_xct_descr *dp;
 	struct pasemi_mac_buffer *info;
 	struct sk_buff *skb;
-	unsigned int i, len;
+	unsigned int len;
 	u64 macrx;
 	dma_addr_t dma;
+	int buf_index;
+	u64 eval;
 
 	spin_lock(&mac->rx->lock);
 
 	n = mac->rx->next_to_clean;
 
-	for (count = limit; count; count--) {
+	prefetch(RX_RING(mac, n));
 
-		rmb();
+	for (count = 0; count < limit; count++) {
+		macrx = RX_RING(mac, n);
 
-		dp = &RX_DESC(mac, n);
-		prefetchw(dp);
-		macrx = dp->macrx;
+		if ((macrx & XCT_MACRX_E) ||
+		    (*mac->rx_status & PAS_STATUS_ERROR))
+			pasemi_mac_rx_error(mac, macrx);
 
 		if (!(macrx & XCT_MACRX_O))
 			break;
 
-
 		info = NULL;
 
-		/* We have to scan for our skb since there's no way
-		 * to back-map them from the descriptor, and if we
-		 * have several receive channels then they might not
-		 * show up in the same order as they were put on the
-		 * interface ring.
-		 */
+		BUG_ON(!(macrx & XCT_MACRX_RR_8BRES));
 
-		dma = (dp->ptr & XCT_PTR_ADDR_M);
-		for (i = n; i < (n + RX_RING_SIZE); i++) {
-			info = &RX_DESC_INFO(mac, i);
-			if (info->dma == dma)
-				break;
-		}
-		prefetchw(info);
+		eval = (RX_RING(mac, n+1) & XCT_RXRES_8B_EVAL_M) >>
+			XCT_RXRES_8B_EVAL_S;
+		buf_index = eval-1;
+
+		dma = (RX_RING(mac, n+2) & XCT_PTR_ADDR_M);
+		info = &RX_RING_INFO(mac, buf_index);
 
 		skb = info->skb;
-		prefetchw(skb);
-		info->dma = 0;
 
-		pci_unmap_single(mac->dma_pdev, dma, skb->len,
-				 PCI_DMA_FROMDEVICE);
+		prefetch(skb);
+		prefetch(&skb->data_len);
 
 		len = (macrx & XCT_MACRX_LLEN_M) >> XCT_MACRX_LLEN_S;
 
 		if (len < 256) {
-			struct sk_buff *new_skb =
-			    netdev_alloc_skb(mac->netdev, len + NET_IP_ALIGN);
+			struct sk_buff *new_skb;
+
+			new_skb = netdev_alloc_skb(mac->netdev,
+						   len + LOCAL_SKB_ALIGN);
 			if (new_skb) {
-				skb_reserve(new_skb, NET_IP_ALIGN);
+				skb_reserve(new_skb, LOCAL_SKB_ALIGN);
 				memcpy(new_skb->data, skb->data, len);
 				/* save the skb in buffer_info as good */
 				skb = new_skb;
@@ -511,6 +595,10 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 		} else
 			info->skb = NULL;
 
+		pci_unmap_single(mac->dma_pdev, dma, len, PCI_DMA_FROMDEVICE);
+
+		info->dma = 0;
+
 		skb_put(skb, len);
 
 		if (likely((macrx & XCT_MACRX_HTY_M) == XCT_MACRX_HTY_IPV4_OK)) {
@@ -526,72 +614,109 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
 
-		dp->ptr = 0;
-		dp->macrx = 0;
+		RX_RING(mac, n) = 0;
+		RX_RING(mac, n+1) = 0;
 
-		n++;
+		/* Need to zero it out since hardware doesn't, since the
+		 * replenish loop uses it to tell when it's done.
+		 */
+		RX_BUFF(mac, buf_index) = 0;
+
+		n += 4;
+	}
+
+	if (n > RX_RING_SIZE) {
+		/* Errata 5971 workaround: L2 target of headers */
+		write_iob_reg(mac, PAS_IOB_COM_PKTHDRCNT, 0);
+		n &= (RX_RING_SIZE-1);
 	}
 
-	mac->rx->next_to_clean += limit - count;
-	pasemi_mac_replenish_rx_ring(mac->netdev, limit-count);
+	mac->rx->next_to_clean = n;
+
+	/* Increase is in number of 16-byte entries, and since each descriptor
+	 * with an 8BRES takes up 3x8 bytes (padded to 4x8), increase with
+	 * count*2.
+	 */
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count << 1);
+
+	pasemi_mac_replenish_rx_ring(mac->netdev, count);
 
 	spin_unlock(&mac->rx->lock);
 
 	return count;
 }
 
+/* Can't make this too large or we blow the kernel stack limits */
+#define TX_CLEAN_BATCHSIZE (128/MAX_SKB_FRAGS)
+
 static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
 {
-	int i;
-	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
-	unsigned int start, count, limit;
+	int i, j;
+	unsigned int start, descr_count, buf_count, batch_limit;
+	unsigned int ring_limit;
 	unsigned int total_count;
 	unsigned long flags;
-	struct sk_buff *skbs[32];
-	dma_addr_t dmas[32];
+	struct sk_buff *skbs[TX_CLEAN_BATCHSIZE];
+	dma_addr_t dmas[TX_CLEAN_BATCHSIZE][MAX_SKB_FRAGS+1];
 
 	total_count = 0;
+	batch_limit = TX_CLEAN_BATCHSIZE;
 restart:
 	spin_lock_irqsave(&mac->tx->lock, flags);
 
 	start = mac->tx->next_to_clean;
-	limit = min(mac->tx->next_to_fill, start+32);
+	ring_limit = mac->tx->next_to_fill;
 
-	count = 0;
+	/* Compensate for when fill has wrapped but clean has not */
+	if (start > ring_limit)
+		ring_limit += TX_RING_SIZE;
+
+	buf_count = 0;
+	descr_count = 0;
+
+	for (i = start;
+	     descr_count < batch_limit && i < ring_limit;
+	     i += buf_count) {
+		u64 mactx = TX_RING(mac, i);
+		struct sk_buff *skb;
 
-	for (i = start; i < limit; i++) {
-		dp = &TX_DESC(mac, i);
+		if ((mactx  & XCT_MACTX_E) ||
+		    (*mac->tx_status & PAS_STATUS_ERROR))
+			pasemi_mac_tx_error(mac, mactx);
 
-		if (unlikely(dp->mactx & XCT_MACTX_O))
+		if (unlikely(mactx & XCT_MACTX_O))
 			/* Not yet transmitted */
 			break;
 
-		info = &TX_DESC_INFO(mac, i);
-		skbs[count] = info->skb;
-		dmas[count] = info->dma;
+		skb = TX_RING_INFO(mac, i+1).skb;
+		skbs[descr_count] = skb;
 
-		info->skb = NULL;
-		info->dma = 0;
-		dp->mactx = 0;
-		dp->ptr = 0;
+		buf_count = 2 + skb_shinfo(skb)->nr_frags;
+		for (j = 0; j <= skb_shinfo(skb)->nr_frags; j++)
+			dmas[descr_count][j] = TX_RING_INFO(mac, i+1+j).dma;
+
+		TX_RING(mac, i) = 0;
+		TX_RING(mac, i+1) = 0;
 
-		count++;
+		/* Since we always fill with an even number of entries, make
+		 * sure we skip any unused one at the end as well.
+		 */
+		if (buf_count & 1)
+			buf_count++;
+		descr_count++;
 	}
-	mac->tx->next_to_clean += count;
+	mac->tx->next_to_clean = i & (TX_RING_SIZE-1);
+
 	spin_unlock_irqrestore(&mac->tx->lock, flags);
 	netif_wake_queue(mac->netdev);
 
-	for (i = 0; i < count; i++) {
-		pci_unmap_single(mac->dma_pdev, dmas[i],
-				 skbs[i]->len, PCI_DMA_TODEVICE);
-		dev_kfree_skb_irq(skbs[i]);
-	}
+	for (i = 0; i < descr_count; i++)
+		pasemi_mac_unmap_tx_skb(mac, skbs[i], dmas[i]);
 
-	total_count += count;
+	total_count += descr_count;
 
 	/* If the batch was full, try to clean more */
-	if (count == 32)
+	if (descr_count == batch_limit)
 		goto restart;
 
 	return total_count;
@@ -607,9 +732,6 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 	if (!(*mac->rx_status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	if (*mac->rx_status & PAS_STATUS_ERROR)
-		printk("rx_status reported error\n");
-
 	/* Don't reset packet count so it won't fire again but clear
 	 * all others.
 	 */
@@ -809,19 +931,32 @@ static int pasemi_mac_open(struct net_device *dev)
 
 	/* enable rx if */
 	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-			   PAS_DMA_RXINT_RCMDSTA_EN);
+			   PAS_DMA_RXINT_RCMDSTA_EN |
+			   PAS_DMA_RXINT_RCMDSTA_DROPS_M |
+			   PAS_DMA_RXINT_RCMDSTA_BP |
+			   PAS_DMA_RXINT_RCMDSTA_OO |
+			   PAS_DMA_RXINT_RCMDSTA_BT);
 
 	/* enable rx channel */
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
 			   PAS_DMA_RXCHAN_CCMDSTA_EN |
-			   PAS_DMA_RXCHAN_CCMDSTA_DU);
+			   PAS_DMA_RXCHAN_CCMDSTA_DU |
+			   PAS_DMA_RXCHAN_CCMDSTA_OD |
+			   PAS_DMA_RXCHAN_CCMDSTA_FD |
+			   PAS_DMA_RXCHAN_CCMDSTA_DT);
 
 	/* enable tx channel */
 	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
-			   PAS_DMA_TXCHAN_TCMDSTA_EN);
+			   PAS_DMA_TXCHAN_TCMDSTA_EN |
+			   PAS_DMA_TXCHAN_TCMDSTA_SZ |
+			   PAS_DMA_TXCHAN_TCMDSTA_DB |
+			   PAS_DMA_TXCHAN_TCMDSTA_DE |
+			   PAS_DMA_TXCHAN_TCMDSTA_DA);
 
 	pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE);
 
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), RX_RING_SIZE>>1);
+
 	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
 		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
 
@@ -893,7 +1028,7 @@ out_rx_resources:
 static int pasemi_mac_close(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	unsigned int stat;
+	unsigned int sta;
 	int retries;
 
 	if (mac->phydev) {
@@ -904,6 +1039,26 @@ static int pasemi_mac_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	napi_disable(&mac->napi);
 
+	sta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+	if (sta & (PAS_DMA_RXINT_RCMDSTA_BP |
+		      PAS_DMA_RXINT_RCMDSTA_OO |
+		      PAS_DMA_RXINT_RCMDSTA_BT))
+		printk(KERN_DEBUG "pasemi_mac: rcmdsta error: 0x%08x\n", sta);
+
+	sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+	if (sta & (PAS_DMA_RXCHAN_CCMDSTA_DU |
+		     PAS_DMA_RXCHAN_CCMDSTA_OD |
+		     PAS_DMA_RXCHAN_CCMDSTA_FD |
+		     PAS_DMA_RXCHAN_CCMDSTA_DT))
+		printk(KERN_DEBUG "pasemi_mac: ccmdsta error: 0x%08x\n", sta);
+
+	sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+	if (sta & (PAS_DMA_TXCHAN_TCMDSTA_SZ |
+		      PAS_DMA_TXCHAN_TCMDSTA_DB |
+		      PAS_DMA_TXCHAN_TCMDSTA_DE |
+		      PAS_DMA_TXCHAN_TCMDSTA_DA))
+		printk(KERN_DEBUG "pasemi_mac: tcmdsta error: 0x%08x\n", sta);
+
 	/* Clean out any pending buffers */
 	pasemi_mac_clean_tx(mac);
 	pasemi_mac_clean_rx(mac, RX_RING_SIZE);
@@ -914,33 +1069,33 @@ static int pasemi_mac_close(struct net_device *dev)
 	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), PAS_DMA_RXCHAN_CCMDSTA_ST);
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		stat = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
-		if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT))
+		sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (stat & PAS_DMA_TXCHAN_TCMDSTA_ACT)
+	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		stat = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
-		if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT))
+		sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (stat & PAS_DMA_RXCHAN_CCMDSTA_ACT)
+	if (sta & PAS_DMA_RXCHAN_CCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		stat = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
-		if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT))
+		sta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
-	if (stat & PAS_DMA_RXINT_RCMDSTA_ACT)
+	if (sta & PAS_DMA_RXINT_RCMDSTA_ACT)
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx interface\n");
 
 	/* Then, disable the channel. This must be done separately from
@@ -965,11 +1120,11 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	struct pasemi_mac_txring *txring;
-	struct pasemi_mac_buffer *info;
-	struct pas_dma_xct_descr *dp;
-	u64 dflags, mactx, ptr;
-	dma_addr_t map;
+	u64 dflags, mactx;
+	dma_addr_t map[MAX_SKB_FRAGS+1];
+	unsigned int map_size[MAX_SKB_FRAGS+1];
 	unsigned long flags;
+	int i, nfrags;
 
 	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
 
@@ -990,54 +1145,78 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	map = pci_map_single(mac->dma_pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
+	nfrags = skb_shinfo(skb)->nr_frags;
+
+	map[0] = pci_map_single(mac->dma_pdev, skb->data, skb_headlen(skb),
+				PCI_DMA_TODEVICE);
+	map_size[0] = skb_headlen(skb);
+	if (dma_mapping_error(map[0]))
+		goto out_err_nolock;
 
-	if (dma_mapping_error(map))
-		return NETDEV_TX_BUSY;
+	for (i = 0; i < nfrags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		map[i+1] = pci_map_page(mac->dma_pdev, frag->page,
+					frag->page_offset, frag->size,
+					PCI_DMA_TODEVICE);
+		map_size[i+1] = frag->size;
+		if (dma_mapping_error(map[i+1])) {
+			nfrags = i;
+			goto out_err_nolock;
+		}
+	}
 
 	mactx = dflags | XCT_MACTX_LLEN(skb->len);
-	ptr   = XCT_PTR_LEN(skb->len) | XCT_PTR_ADDR(map);
 
 	txring = mac->tx;
 
 	spin_lock_irqsave(&txring->lock, flags);
 
-	if (RING_AVAIL(txring) <= 1) {
-		spin_unlock_irqrestore(&txring->lock, flags);
-		pasemi_mac_clean_tx(mac);
-		pasemi_mac_restart_tx_intr(mac);
-		spin_lock_irqsave(&txring->lock, flags);
-
-		if (RING_AVAIL(txring) <= 1) {
-			/* Still no room -- stop the queue and wait for tx
-			 * intr when there's room.
-			 */
-			netif_stop_queue(dev);
-			goto out_err;
-		}
+	/* Avoid stepping on the same cache line that the DMA controller
+	 * is currently about to send, so leave at least 8 words available.
+	 * Total free space needed is mactx + fragments + 8
+	 */
+	if (RING_AVAIL(txring) < nfrags + 10) {
+		/* no room -- stop the queue and wait for tx intr */
+		netif_stop_queue(dev);
+		goto out_err;
+	}
+
+	TX_RING(mac, txring->next_to_fill) = mactx;
+	txring->next_to_fill++;
+	TX_RING_INFO(mac, txring->next_to_fill).skb = skb;
+	for (i = 0; i <= nfrags; i++) {
+		TX_RING(mac, txring->next_to_fill+i) =
+		XCT_PTR_LEN(map_size[i]) | XCT_PTR_ADDR(map[i]);
+		TX_RING_INFO(mac, txring->next_to_fill+i).dma = map[i];
 	}
 
-	dp = &TX_DESC(mac, txring->next_to_fill);
-	info = &TX_DESC_INFO(mac, txring->next_to_fill);
+	/* We have to add an even number of 8-byte entries to the ring
+	 * even if the last one is unused. That means always an odd number
+	 * of pointers + one mactx descriptor.
+	 */
+	if (nfrags & 1)
+		nfrags++;
 
-	dp->mactx = mactx;
-	dp->ptr   = ptr;
-	info->dma = map;
-	info->skb = skb;
+	txring->next_to_fill = (txring->next_to_fill + nfrags + 1) &
+				(TX_RING_SIZE-1);
 
-	txring->next_to_fill++;
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
 	spin_unlock_irqrestore(&txring->lock, flags);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(mac->dma_txch), (nfrags+2) >> 1);
 
 	return NETDEV_TX_OK;
 
 out_err:
 	spin_unlock_irqrestore(&txring->lock, flags);
-	pci_unmap_single(mac->dma_pdev, map, skb->len, PCI_DMA_TODEVICE);
+out_err_nolock:
+	while (nfrags--)
+		pci_unmap_single(mac->dma_pdev, map[nfrags], map_size[nfrags],
+				 PCI_DMA_TODEVICE);
+
 	return NETDEV_TX_BUSY;
 }
 
@@ -1173,7 +1352,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
-	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
 
 	/* These should come out of the device tree eventually */
 	mac->dma_txch = index;
@@ -1230,7 +1409,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
 			err);
 		goto out;
-	} else
+	} else if netif_msg_probe(mac)
 		printk(KERN_INFO "%s: PA Semi %s: intf %d, txch %d, rxch %d, "
 		       "hw addr %s\n",
 		       dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
diff --git a/drivers/net/pasemi_mac.h b/drivers/net/pasemi_mac.h
index c52cfcb..60368df 100644
--- a/drivers/net/pasemi_mac.h
+++ b/drivers/net/pasemi_mac.h
@@ -28,25 +28,25 @@
 
 struct pasemi_mac_txring {
 	spinlock_t	 lock;
-	struct pas_dma_xct_descr	*desc;
+	u64		*ring;
 	dma_addr_t	 dma;
 	unsigned int	 size;
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
-	struct pasemi_mac_buffer *desc_info;
+	struct pasemi_mac_buffer *ring_info;
 	char		 irq_name[10];  /* "eth%d tx" */
 };
 
 struct pasemi_mac_rxring {
 	spinlock_t	 lock;
-	struct pas_dma_xct_descr	*desc;	/* RX channel descriptor ring */
+	u64		*ring;	/* RX channel descriptor ring */
 	dma_addr_t	 dma;
 	u64		*buffers;	/* RX interface buffer ring */
 	dma_addr_t	 buf_dma;
 	unsigned int	 size;
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
-	struct pasemi_mac_buffer *desc_info;
+	struct pasemi_mac_buffer *ring_info;
 	char		 irq_name[10];  /* "eth%d rx" */
 };
 
@@ -88,7 +88,7 @@ struct pasemi_mac {
 	char	phy_id[BUS_ID_SIZE];
 };
 
-/* Software status descriptor (desc_info) */
+/* Software status descriptor (ring_info) */
 struct pasemi_mac_buffer {
 	struct sk_buff *skb;
 	dma_addr_t	dma;
@@ -101,20 +101,7 @@ struct pasdma_status {
 	u64 tx_sta[20];
 };
 
-/* descriptor structure */
-struct pas_dma_xct_descr {
-	union {
-		u64	mactx;
-		u64	macrx;
-	};
-	union {
-		u64	ptr;
-		u64	rxb;
-	};
-};
-
 /* MAC CFG register offsets */
-
 enum {
 	PAS_MAC_CFG_PCFG = 0x80,
 	PAS_MAC_CFG_TXP = 0x98,
@@ -219,10 +206,16 @@ enum {
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
 #define PAS_DMA_RXINT_CFG(i)		(0x204+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_CFG_RBP	0x80000000
+#define    PAS_DMA_RXINT_CFG_ITRR	0x40000000
 #define    PAS_DMA_RXINT_CFG_DHL_M	0x07000000
 #define    PAS_DMA_RXINT_CFG_DHL_S	24
 #define    PAS_DMA_RXINT_CFG_DHL(x)	(((x) << PAS_DMA_RXINT_CFG_DHL_S) & \
 					 PAS_DMA_RXINT_CFG_DHL_M)
+#define    PAS_DMA_RXINT_CFG_ITR	0x00400000
+#define    PAS_DMA_RXINT_CFG_LW		0x00200000
+#define    PAS_DMA_RXINT_CFG_L2		0x00100000
+#define    PAS_DMA_RXINT_CFG_HEN	0x00080000
 #define    PAS_DMA_RXINT_CFG_WIF	0x00000002
 #define    PAS_DMA_RXINT_CFG_WIL	0x00000001
 
@@ -252,6 +245,10 @@ enum {
 #define    PAS_DMA_TXCHAN_TCMDSTA_EN	0x00000001	/* Enabled */
 #define    PAS_DMA_TXCHAN_TCMDSTA_ST	0x00000002	/* Stop interface */
 #define    PAS_DMA_TXCHAN_TCMDSTA_ACT	0x00010000	/* Active */
+#define    PAS_DMA_TXCHAN_TCMDSTA_SZ	0x00000800
+#define    PAS_DMA_TXCHAN_TCMDSTA_DB	0x00000400
+#define    PAS_DMA_TXCHAN_TCMDSTA_DE	0x00000200
+#define    PAS_DMA_TXCHAN_TCMDSTA_DA	0x00000100
 #define PAS_DMA_TXCHAN_CFG(c)     (0x304+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define    PAS_DMA_TXCHAN_CFG_TY_IFACE	0x00000000	/* Type = interface */
 #define    PAS_DMA_TXCHAN_CFG_TATTR_M	0x0000003c
@@ -262,9 +259,11 @@ enum {
 #define    PAS_DMA_TXCHAN_CFG_WT_S	6
 #define    PAS_DMA_TXCHAN_CFG_WT(x)	(((x) << PAS_DMA_TXCHAN_CFG_WT_S) & \
 					 PAS_DMA_TXCHAN_CFG_WT_M)
-#define    PAS_DMA_TXCHAN_CFG_CF	0x00001000	/* Clean first line */
-#define    PAS_DMA_TXCHAN_CFG_CL	0x00002000	/* Clean last line */
+#define    PAS_DMA_TXCHAN_CFG_TRD	0x00010000	/* translate data */
+#define    PAS_DMA_TXCHAN_CFG_TRR	0x00008000	/* translate rings */
 #define    PAS_DMA_TXCHAN_CFG_UP	0x00004000	/* update tx descr when sent */
+#define    PAS_DMA_TXCHAN_CFG_CL	0x00002000	/* Clean last line */
+#define    PAS_DMA_TXCHAN_CFG_CF	0x00001000	/* Clean first line */
 #define PAS_DMA_TXCHAN_INCR(c)    (0x310+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define PAS_DMA_TXCHAN_BASEL(c)   (0x318+(c)*_PAS_DMA_TXCHAN_STRIDE)
 #define    PAS_DMA_TXCHAN_BASEL_BRBL_M	0xffffffc0
@@ -294,7 +293,11 @@ enum {
 #define    PAS_DMA_RXCHAN_CCMDSTA_ST	0x00000002	/* Stop interface */
 #define    PAS_DMA_RXCHAN_CCMDSTA_ACT	0x00010000	/* Active */
 #define    PAS_DMA_RXCHAN_CCMDSTA_DU	0x00020000
+#define    PAS_DMA_RXCHAN_CCMDSTA_OD	0x00002000
+#define    PAS_DMA_RXCHAN_CCMDSTA_FD	0x00001000
+#define    PAS_DMA_RXCHAN_CCMDSTA_DT	0x00000800
 #define PAS_DMA_RXCHAN_CFG(c)     (0x804+(c)*_PAS_DMA_RXCHAN_STRIDE)
+#define    PAS_DMA_RXCHAN_CFG_CTR	0x00000400
 #define    PAS_DMA_RXCHAN_CFG_HBU_M	0x00000380
 #define    PAS_DMA_RXCHAN_CFG_HBU_S	7
 #define    PAS_DMA_RXCHAN_CFG_HBU(x)	(((x) << PAS_DMA_RXCHAN_CFG_HBU_S) & \
@@ -328,6 +331,12 @@ enum {
 #define    PAS_STATUS_SOFT		0x4000000000000000ull
 #define    PAS_STATUS_INT		0x8000000000000000ull
 
+#define PAS_IOB_COM_PKTHDRCNT		0x120
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR1_M	0x0fff0000
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR1_S	16
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR0_M	0x00000fff
+#define    PAS_IOB_COM_PKTHDRCNT_PKTHDR0_S	0
+
 #define PAS_IOB_DMA_RXCH_CFG(i)		(0x1100 + (i)*4)
 #define    PAS_IOB_DMA_RXCH_CFG_CNTTH_M		0x00000fff
 #define    PAS_IOB_DMA_RXCH_CFG_CNTTH_S		0
@@ -423,10 +432,9 @@ enum {
 /* Receive descriptor fields */
 #define	XCT_MACRX_T		0x8000000000000000ull
 #define	XCT_MACRX_ST		0x4000000000000000ull
-#define XCT_MACRX_NORES		0x0000000000000000ull
-#define XCT_MACRX_8BRES		0x1000000000000000ull
-#define XCT_MACRX_24BRES	0x2000000000000000ull
-#define XCT_MACRX_40BRES	0x3000000000000000ull
+#define XCT_MACRX_RR_M		0x3000000000000000ull
+#define XCT_MACRX_RR_NORES	0x0000000000000000ull
+#define XCT_MACRX_RR_8BRES	0x1000000000000000ull
 #define XCT_MACRX_O		0x0400000000000000ull
 #define XCT_MACRX_E		0x0200000000000000ull
 #define XCT_MACRX_FF		0x0100000000000000ull
@@ -474,6 +482,17 @@ enum {
 #define XCT_PTR_ADDR(x)		((((long)(x)) << XCT_PTR_ADDR_S) & \
 				 XCT_PTR_ADDR_M)
 
+/* Receive interface 8byte result fields */
+#define XCT_RXRES_8B_L4O_M	0xff00000000000000ull
+#define XCT_RXRES_8B_L4O_S	56
+#define XCT_RXRES_8B_RULE_M	0x00ffff0000000000ull
+#define XCT_RXRES_8B_RULE_S	40
+#define XCT_RXRES_8B_EVAL_M	0x000000ffff000000ull
+#define XCT_RXRES_8B_EVAL_S	24
+#define XCT_RXRES_8B_HTYPE_M	0x0000000000f00000ull
+#define XCT_RXRES_8B_HASH_M	0x00000000000fffffull
+#define XCT_RXRES_8B_HASH_S	0
+
 /* Receive interface buffer fields */
 #define XCT_RXB_LEN_M		0x0ffff00000000000ull
 #define XCT_RXB_LEN_S		44
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
old mode 100755
new mode 100644
index 7907da1..6dad20e
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -81,7 +81,7 @@ typedef enum {
 } PHY_DEVICE_et;
 
 typedef struct {
-	PHY_DEVICE_et phyDevice; 
+	PHY_DEVICE_et phyDevice;
 	u32		phyIdOUI;
 	u16		phyIdModel;
 	char 		*name;
@@ -330,7 +330,7 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 					     PCI_DMA_FROMDEVICE);
 			err = pci_dma_mapping_error(map);
 			if(err) {
-				printk(KERN_ERR "%s: PCI mapping failed with error: %d\n", 
+				printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
 				       qdev->ndev->name, err);
 				dev_kfree_skb(lrg_buf_cb->skb);
 				lrg_buf_cb->skb = NULL;
@@ -884,14 +884,14 @@ static void ql_petbi_start_neg_ex(struct ql3_adapter *qdev)
 	u16 reg;
 
 	/* Enable Auto-negotiation sense */
-	ql_mii_read_reg_ex(qdev, PETBI_TBI_CTRL, &reg, 
+	ql_mii_read_reg_ex(qdev, PETBI_TBI_CTRL, &reg,
 			   PHYAddr[qdev->mac_index]);
 	reg |= PETBI_TBI_AUTO_SENSE;
-	ql_mii_write_reg_ex(qdev, PETBI_TBI_CTRL, reg, 
+	ql_mii_write_reg_ex(qdev, PETBI_TBI_CTRL, reg,
 			    PHYAddr[qdev->mac_index]);
 
 	ql_mii_write_reg_ex(qdev, PETBI_NEG_ADVER,
-			    PETBI_NEG_PAUSE | PETBI_NEG_DUPLEX, 
+			    PETBI_NEG_PAUSE | PETBI_NEG_DUPLEX,
 			    PHYAddr[qdev->mac_index]);
 
 	ql_mii_write_reg_ex(qdev, PETBI_CONTROL_REG,
@@ -945,7 +945,7 @@ static void phyAgereSpecificInit(struct ql3_adapter *qdev, u32 miiAddr)
 	ql_mii_write_reg_ex(qdev, 0x10, 0x2806, miiAddr);
 	/* Write new PHYAD w/bit 5 set */
 	ql_mii_write_reg_ex(qdev, 0x11, 0x0020 | (PHYAddr[qdev->mac_index] >> 8), miiAddr);
-	/* 
+	/*
 	 * Disable diagnostic mode bit 2 = 0
 	 * Power up device bit 11 = 0
 	 * Link up (on) and activity (blink)
@@ -955,18 +955,18 @@ static void phyAgereSpecificInit(struct ql3_adapter *qdev, u32 miiAddr)
 	ql_mii_write_reg(qdev, 0x1c, 0xfaf0);
 }
 
-static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev, 
+static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev,
 				 u16 phyIdReg0, u16 phyIdReg1)
 {
 	PHY_DEVICE_et result = PHY_TYPE_UNKNOWN;
-	u32   oui;     
+	u32   oui;
 	u16   model;
-	int i;   
+	int i;
 
 	if (phyIdReg0 == 0xffff) {
 		return result;
 	}
-   
+
 	if (phyIdReg1 == 0xffff) {
 		return result;
 	}
@@ -984,7 +984,7 @@ static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev,
 
 			printk(KERN_INFO "%s: Phy: %s\n",
 				qdev->ndev->name, PHY_DEVICES[i].name);
-			
+
 		        break;
 		}
 	}
@@ -1033,7 +1033,7 @@ static int ql_is_full_dup(struct ql3_adapter *qdev)
 	{
 		if (ql_mii_read_reg(qdev, 0x1A, &reg))
 			return 0;
-			
+
 		return ((reg & 0x0080) && (reg & 0x1000)) != 0;
 	}
 	case PHY_VITESSE_VSC8211:
@@ -1082,19 +1082,19 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 	/*  Check if we have a Agere PHY */
 	if ((reg1 == 0xffff) || (reg2 == 0xffff)) {
 
-		/* Determine which MII address we should be using 
+		/* Determine which MII address we should be using
 		   determined by the index of the card */
 		if (qdev->mac_index == 0) {
 			miiAddr = MII_AGERE_ADDR_1;
 		} else {
 			miiAddr = MII_AGERE_ADDR_2;
 		}
-      
+
 		err =ql_mii_read_reg_ex(qdev, PHY_ID_0_REG, &reg1, miiAddr);
 		if(err != 0) {
 			printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG after Agere detected\n",
 		       	       qdev->ndev->name);
-                	return err; 
+                	return err;
 		}
 
 		err = ql_mii_read_reg_ex(qdev, PHY_ID_1_REG, &reg2, miiAddr);
@@ -1103,9 +1103,9 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 			       qdev->ndev->name);
         	        return err;
 		}
-   
+
 		/*  We need to remember to initialize the Agere PHY */
-         	agereAddrChangeNeeded = true; 
+         	agereAddrChangeNeeded = true;
 	}
 
 	/*  Determine the particular PHY we have on board to apply
@@ -1114,7 +1114,7 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 
 	if ((qdev->phyType == PHY_AGERE_ET1011C) && agereAddrChangeNeeded) {
 		/* need this here so address gets changed */
-		phyAgereSpecificInit(qdev, miiAddr);  
+		phyAgereSpecificInit(qdev, miiAddr);
 	} else if (qdev->phyType == PHY_TYPE_UNKNOWN) {
 		printk(KERN_ERR "%s: PHY is unknown\n", qdev->ndev->name);
 		return -EIO;
@@ -1427,7 +1427,7 @@ static int ql_this_adapter_controls_port(struct ql3_adapter *qdev)
 
 static void ql_phy_reset_ex(struct ql3_adapter *qdev)
 {
-	ql_mii_write_reg_ex(qdev, CONTROL_REG, PHY_CTRL_SOFT_RESET, 
+	ql_mii_write_reg_ex(qdev, CONTROL_REG, PHY_CTRL_SOFT_RESET,
 			    PHYAddr[qdev->mac_index]);
 }
 
@@ -1438,7 +1438,7 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 
 	if(qdev->phyType == PHY_AGERE_ET1011C) {
 		/* turn off external loopback */
-		ql_mii_write_reg(qdev, 0x13, 0x0000); 
+		ql_mii_write_reg(qdev, 0x13, 0x0000);
 	}
 
 	if(qdev->mac_index == 0)
@@ -1452,23 +1452,23 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 		portConfiguration = PORT_CONFIG_DEFAULT;
 
 	/* Set the 1000 advertisements */
-	ql_mii_read_reg_ex(qdev, PHY_GIG_CONTROL, &reg, 
+	ql_mii_read_reg_ex(qdev, PHY_GIG_CONTROL, &reg,
 			   PHYAddr[qdev->mac_index]);
 	reg &= ~PHY_GIG_ALL_PARAMS;
 
-	if(portConfiguration & 
+	if(portConfiguration &
 	   PORT_CONFIG_FULL_DUPLEX_ENABLED &
 	   PORT_CONFIG_1000MB_SPEED) {
 		reg |= PHY_GIG_ADV_1000F;
 	}
-	 
-	if(portConfiguration & 
+
+	if(portConfiguration &
 	   PORT_CONFIG_HALF_DUPLEX_ENABLED &
 	   PORT_CONFIG_1000MB_SPEED) {
 		reg |= PHY_GIG_ADV_1000H;
 	}
 
-	ql_mii_write_reg_ex(qdev, PHY_GIG_CONTROL, reg, 
+	ql_mii_write_reg_ex(qdev, PHY_GIG_CONTROL, reg,
 			    PHYAddr[qdev->mac_index]);
 
 	/* Set the 10/100 & pause negotiation advertisements */
@@ -1482,7 +1482,7 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 	if(portConfiguration & PORT_CONFIG_FULL_DUPLEX_ENABLED) {
 		if(portConfiguration & PORT_CONFIG_100MB_SPEED)
 			reg |= PHY_NEG_ADV_100F;
-		
+
 		if(portConfiguration & PORT_CONFIG_10MB_SPEED)
 			reg |= PHY_NEG_ADV_10F;
 	}
@@ -1490,22 +1490,22 @@ static void ql_phy_start_neg_ex(struct ql3_adapter *qdev)
 	if(portConfiguration & PORT_CONFIG_HALF_DUPLEX_ENABLED) {
 		if(portConfiguration & PORT_CONFIG_100MB_SPEED)
 			reg |= PHY_NEG_ADV_100H;
-		
+
 		if(portConfiguration & PORT_CONFIG_10MB_SPEED)
 			reg |= PHY_NEG_ADV_10H;
 	}
 
 	if(portConfiguration &
 	   PORT_CONFIG_1000MB_SPEED) {
-		reg |= 1;	
+		reg |= 1;
 	}
 
-	ql_mii_write_reg_ex(qdev, PHY_NEG_ADVER, reg, 
+	ql_mii_write_reg_ex(qdev, PHY_NEG_ADVER, reg,
 			    PHYAddr[qdev->mac_index]);
 
 	ql_mii_read_reg_ex(qdev, CONTROL_REG, &reg, PHYAddr[qdev->mac_index]);
-	
-	ql_mii_write_reg_ex(qdev, CONTROL_REG, 
+
+	ql_mii_write_reg_ex(qdev, CONTROL_REG,
 			    reg | PHY_CTRL_RESTART_NEG | PHY_CTRL_AUTO_NEG,
 			    PHYAddr[qdev->mac_index]);
 }
@@ -1660,7 +1660,7 @@ static void ql_link_state_machine(struct ql3_adapter *qdev)
 			       "%s: Reset in progress, skip processing link "
 			       "state.\n", qdev->ndev->name);
 
-		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);		
+		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return;
 	}
 
@@ -1752,7 +1752,7 @@ static int ql_mii_setup(struct ql3_adapter *qdev)
 		return -1;
 
 	if (qdev->device_id == QL3032_DEVICE_ID)
-		ql_write_page0_reg(qdev, 
+		ql_write_page0_reg(qdev,
 			&port_regs->macMIIMgmtControlReg, 0x0f00000);
 
 	/* Divide 125MHz clock by 28 to meet PHY timing requirements */
@@ -1936,7 +1936,7 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 
 				err = pci_dma_mapping_error(map);
 				if(err) {
-					printk(KERN_ERR "%s: PCI mapping failed with error: %d\n", 
+					printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
 					       qdev->ndev->name, err);
 					dev_kfree_skb(lrg_buf_cb->skb);
 					lrg_buf_cb->skb = NULL;
@@ -2044,7 +2044,7 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
 		printk(KERN_WARNING "Frame short but, frame was padded and sent.\n");
 	}
-	
+
 	tx_cb = &qdev->tx_buf[mac_rsp->transaction_id];
 
 	/*  Check the transmit response flags for any errors */
@@ -2108,13 +2108,13 @@ static struct ql_rcv_buf_cb *ql_get_lbuf(struct ql3_adapter *qdev)
 
 /*
  * The difference between 3022 and 3032 for inbound completions:
- * 3022 uses two buffers per completion.  The first buffer contains 
- * (some) header info, the second the remainder of the headers plus 
- * the data.  For this chip we reserve some space at the top of the 
- * receive buffer so that the header info in buffer one can be 
- * prepended to the buffer two.  Buffer two is the sent up while 
+ * 3022 uses two buffers per completion.  The first buffer contains
+ * (some) header info, the second the remainder of the headers plus
+ * the data.  For this chip we reserve some space at the top of the
+ * receive buffer so that the header info in buffer one can be
+ * prepended to the buffer two.  Buffer two is the sent up while
  * buffer one is returned to the hardware to be reused.
- * 3032 receives all of it's data and headers in one buffer for a 
+ * 3032 receives all of it's data and headers in one buffer for a
  * simpler process.  3032 also supports checksum verification as
  * can be seen in ql_process_macip_rx_intr().
  */
@@ -2205,13 +2205,13 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 						 skb_push(skb2, size), size);
 	} else {
 		u16 checksum = le16_to_cpu(ib_ip_rsp_ptr->checksum);
-		if (checksum & 
-			(IB_IP_IOCB_RSP_3032_ICE | 
-			 IB_IP_IOCB_RSP_3032_CE)) { 
+		if (checksum &
+			(IB_IP_IOCB_RSP_3032_ICE |
+			 IB_IP_IOCB_RSP_3032_CE)) {
 			printk(KERN_ERR
 			       "%s: Bad checksum for this %s packet, checksum = %x.\n",
 			       __func__,
-			       ((checksum & 
+			       ((checksum &
 				IB_IP_IOCB_RSP_3032_TCP) ? "TCP" :
 				"UDP"),checksum);
 		} else if ((checksum & IB_IP_IOCB_RSP_3032_TCP) ||
@@ -2387,12 +2387,12 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 }
 
 /*
- * Get the total number of segments needed for the 
+ * Get the total number of segments needed for the
  * given number of fragments.  This is necessary because
  * outbound address lists (OAL) will be used when more than
- * two frags are given.  Each address list has 5 addr/len 
+ * two frags are given.  Each address list has 5 addr/len
  * pairs.  The 5th pair in each AOL is used to  point to
- * the next AOL if more frags are coming.  
+ * the next AOL if more frags are coming.
  * That is why the frags:segment count  ratio is not linear.
  */
 static int ql_get_seg_count(struct ql3_adapter *qdev,
@@ -2469,12 +2469,12 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 	err = pci_dma_mapping_error(map);
 	if(err) {
-		printk(KERN_ERR "%s: PCI mapping failed with error: %d\n", 
+		printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
 		       qdev->ndev->name, err);
 
 		return NETDEV_TX_BUSY;
 	}
-	
+
 	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
 	oal_entry->dma_lo = cpu_to_le32(LS_64BITS(map));
 	oal_entry->dma_hi = cpu_to_le32(MS_64BITS(map));
@@ -2504,7 +2504,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 				err = pci_dma_mapping_error(map);
 				if(err) {
 
-					printk(KERN_ERR "%s: PCI mapping outbound address list with error: %d\n", 
+					printk(KERN_ERR "%s: PCI mapping outbound address list with error: %d\n",
 					       qdev->ndev->name, err);
 					goto map_error;
 				}
@@ -2530,7 +2530,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 			err = pci_dma_mapping_error(map);
 			if(err) {
-				printk(KERN_ERR "%s: PCI mapping frags failed with error: %d\n", 
+				printk(KERN_ERR "%s: PCI mapping frags failed with error: %d\n",
 				       qdev->ndev->name, err);
 				goto map_error;
 			}
@@ -2551,10 +2551,10 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 map_error:
 	/* A PCI mapping failed and now we will need to back out
-	 * We need to traverse through the oal's and associated pages which 
+	 * We need to traverse through the oal's and associated pages which
 	 * have been mapped and now we must unmap them to clean up properly
 	 */
-	
+
 	seg = 1;
 	oal_entry = (struct oal_entry *)&mac_iocb_ptr->buf_addr0_low;
 	oal = tx_cb->oal;
@@ -2592,11 +2592,11 @@ map_error:
  * The difference between 3022 and 3032 sends:
  * 3022 only supports a simple single segment transmission.
  * 3032 supports checksumming and scatter/gather lists (fragments).
- * The 3032 supports sglists by using the 3 addr/len pairs (ALP) 
- * in the IOCB plus a chain of outbound address lists (OAL) that 
- * each contain 5 ALPs.  The last ALP of the IOCB (3rd) or OAL (5th) 
- * will used to point to an OAL when more ALP entries are required.  
- * The IOCB is always the top of the chain followed by one or more 
+ * The 3032 supports sglists by using the 3 addr/len pairs (ALP)
+ * in the IOCB plus a chain of outbound address lists (OAL) that
+ * each contain 5 ALPs.  The last ALP of the IOCB (3rd) or OAL (5th)
+ * will used to point to an OAL when more ALP entries are required.
+ * The IOCB is always the top of the chain followed by one or more
  * OALs (when necessary).
  */
 static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
@@ -2610,14 +2610,14 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
 		return NETDEV_TX_BUSY;
 	}
-	
+
 	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
 	if((tx_cb->seg_count = ql_get_seg_count(qdev,
 						(skb_shinfo(skb)->nr_frags))) == -1) {
 		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
 		return NETDEV_TX_OK;
 	}
-	
+
 	mac_iocb_ptr = tx_cb->queue_entry;
 	memset((void *)mac_iocb_ptr, 0, sizeof(struct ob_mac_iocb_req));
 	mac_iocb_ptr->opcode = qdev->mac_ob_opcode;
@@ -2629,12 +2629,12 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 	if (qdev->device_id == QL3032_DEVICE_ID &&
 	    skb->ip_summed == CHECKSUM_PARTIAL)
 		ql_hw_csum_setup(skb, mac_iocb_ptr);
-	
+
 	if(ql_send_map(qdev,mac_iocb_ptr,tx_cb,skb) != NETDEV_TX_OK) {
 		printk(KERN_ERR PFX"%s: Could not map the segments!\n",__func__);
 		return NETDEV_TX_BUSY;
 	}
-	
+
 	wmb();
 	qdev->req_producer_index++;
 	if (qdev->req_producer_index == NUM_REQ_Q_ENTRIES)
@@ -2732,7 +2732,7 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 		       "%s: qdev->lrg_buf alloc failed.\n", qdev->ndev->name);
 		return -ENOMEM;
 	}
-	
+
 	qdev->lrg_buf_q_alloc_virt_addr =
 	    pci_alloc_consistent(qdev->pdev,
 				 qdev->lrg_buf_q_alloc_size,
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
old mode 100755
new mode 100644
index 483840f..fbcb0b9
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -556,7 +556,7 @@ enum {
 	IP_ADDR_INDEX_REG_FUNC_3_SEC = 0x0007,
 	IP_ADDR_INDEX_REG_6 = 0x0008,
 	IP_ADDR_INDEX_REG_OFFSET_MASK = 0x0030,
-	IP_ADDR_INDEX_REG_E = 0x0040, 
+	IP_ADDR_INDEX_REG_E = 0x0040,
 };
 enum {
 	QL3032_PORT_CONTROL_DS = 0x0001,
@@ -1112,7 +1112,7 @@ struct ql_rcv_buf_cb {
  * OAL has 5 entries:
  * 1 thru 4 point to frags
  * fifth points to next oal.
- */ 
+ */
 #define MAX_OAL_CNT ((MAX_SKB_FRAGS-1)/4 + 1)
 
 struct oal_entry {
@@ -1137,7 +1137,7 @@ struct ql_tx_buf_cb {
 	struct ob_mac_iocb_req *queue_entry ;
 	int seg_count;
 	struct oal *oal;
-	struct map_list map[MAX_SKB_FRAGS+1]; 
+	struct map_list map[MAX_SKB_FRAGS+1];
 };
 
 /* definitions for type field */
