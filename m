From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [4/12] pasemi_mac: Convert to new dma library
Date: Wed, 28 Nov 2007 20:56:32 -0600
Message-ID: <20071129025632.GE17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36852 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757295AbXK2CxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:53:21 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: Convert to new dma library

Convert the pasemi_mac driver to the new platform global DMA manaagement
library. This also does a couple of other minor cleanups w.r.t. channel
management.

Signed-off-by: Olof Johansson <olof@lixom.net>

---
 drivers/net/pasemi_mac.c |  480 ++++++++++++++++++++---------------------------
 drivers/net/pasemi_mac.h |   16 -
 2 files changed, 210 insertions(+), 286 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -69,9 +69,9 @@
 	 NETIF_MSG_RX_ERR	| \
 	 NETIF_MSG_TX_ERR)
 
-#define TX_DESC(tx, num)	((tx)->ring[(num) & (TX_RING_SIZE-1)])
+#define TX_DESC(tx, num)	((tx)->chan.ring_virt[(num) & (TX_RING_SIZE-1)])
 #define TX_DESC_INFO(tx, num)	((tx)->ring_info[(num) & (TX_RING_SIZE-1)])
-#define RX_DESC(rx, num)	((rx)->ring[(num) & (RX_RING_SIZE-1)])
+#define RX_DESC(rx, num)	((rx)->chan.ring_virt[(num) & (RX_RING_SIZE-1)])
 #define RX_DESC_INFO(rx, num)	((rx)->ring_info[(num) & (RX_RING_SIZE-1)])
 #define RX_BUFF(rx, num)	((rx)->buffers[(num) & (RX_RING_SIZE-1)])
 
@@ -89,8 +89,6 @@ static int debug = -1;	/* -1 == use DEFA
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "PA Semi MAC bitmapped debugging message enable value");
 
-static struct pasdma_status *dma_status;
-
 static int translation_enabled(void)
 {
 #if defined(CONFIG_PPC_PASEMI_IOMMU_DMA_FORCE)
@@ -100,32 +98,30 @@ static int translation_enabled(void)
 #endif
 }
 
-static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
-			  unsigned int val)
+static void write_iob_reg(unsigned int reg, unsigned int val)
 {
-	out_le32(mac->iob_regs+reg, val);
+	pasemi_write_iob_reg(reg, val);
 }
 
 static unsigned int read_mac_reg(struct pasemi_mac *mac, unsigned int reg)
 {
-	return in_le32(mac->regs+reg);
+	return pasemi_read_mac_reg(mac->dma_if, reg);
 }
 
 static void write_mac_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
-	out_le32(mac->regs+reg, val);
+	pasemi_write_mac_reg(mac->dma_if, reg, val);
 }
 
-static unsigned int read_dma_reg(struct pasemi_mac *mac, unsigned int reg)
+static unsigned int read_dma_reg(unsigned int reg)
 {
-	return in_le32(mac->dma_regs+reg);
+	return pasemi_read_dma_reg(reg);
 }
 
-static void write_dma_reg(struct pasemi_mac *mac, unsigned int reg,
-			  unsigned int val)
+static void write_dma_reg(unsigned int reg, unsigned int val)
 {
-	out_le32(mac->dma_regs+reg, val);
+	pasemi_write_dma_reg(reg, val);
 }
 
 static struct pasemi_mac_rxring *rx_ring(struct pasemi_mac *mac)
@@ -138,6 +134,34 @@ static struct pasemi_mac_txring *tx_ring
 	return mac->tx;
 }
 
+static int mac_to_intf(struct pasemi_mac *mac)
+{
+	struct pci_dev *pdev = mac->pdev;
+	u32 tmp;
+	int nintf, off, i, j;
+	int devfn = pdev->devfn;
+
+	tmp = read_dma_reg(PAS_DMA_CAP_IFI);
+	nintf = (tmp & PAS_DMA_CAP_IFI_NIN_M) >> PAS_DMA_CAP_IFI_NIN_S;
+	off = (tmp & PAS_DMA_CAP_IFI_IOFF_M) >> PAS_DMA_CAP_IFI_IOFF_S;
+
+	/* IOFF contains the offset to the registers containing the
+	 * DMA interface-to-MAC-pci-id mappings, and NIN contains number
+	 * of total interfaces. Each register contains 4 devfns.
+	 * Just do a linear search until we find the devfn of the MAC
+	 * we're trying to look up.
+	 */
+
+	for (i = 0; i < (nintf+3)/4; i++) {
+		tmp = read_dma_reg(off+4*i);
+		for (j = 0; j < 4; j++) {
+			if (((tmp >> (8*j)) & 0xff) == devfn)
+				return i*4 + j;
+		}
+	}
+	return -1;
+}
+
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
@@ -213,13 +237,17 @@ static int pasemi_mac_setup_rx_resources
 {
 	struct pasemi_mac_rxring *ring;
 	struct pasemi_mac *mac = netdev_priv(dev);
-	int chan_id = mac->dma_rxch;
+	int chno;
 	unsigned int cfg;
 
-	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
+	ring = pasemi_dma_alloc_chan(RXCHAN, sizeof(struct pasemi_mac_rxring),
+				     offsetof(struct pasemi_mac_rxring, chan));
 
-	if (!ring)
-		goto out_ring;
+	if (!ring) {
+		dev_err(&mac->pdev->dev, "Can't allocate RX channel\n");
+		goto out_chan;
+	}
+	chno = ring->chan.chno;
 
 	spin_lock_init(&ring->lock);
 
@@ -231,84 +259,80 @@ static int pasemi_mac_setup_rx_resources
 		goto out_ring_info;
 
 	/* Allocate descriptors */
-	ring->ring = dma_alloc_coherent(&mac->dma_pdev->dev,
-					RX_RING_SIZE * sizeof(u64),
-					&ring->dma, GFP_KERNEL);
-
-	if (!ring->ring)
+	if (pasemi_dma_alloc_ring(&ring->chan, RX_RING_SIZE))
 		goto out_ring_desc;
 
-	memset(ring->ring, 0, RX_RING_SIZE * sizeof(u64));
-
 	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
 					   RX_RING_SIZE * sizeof(u64),
 					   &ring->buf_dma, GFP_KERNEL);
 	if (!ring->buffers)
-		goto out_buffers;
+		goto out_ring_desc;
 
 	memset(ring->buffers, 0, RX_RING_SIZE * sizeof(u64));
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_BASEL(chan_id), PAS_DMA_RXCHAN_BASEL_BRBL(ring->dma));
+	write_dma_reg(PAS_DMA_RXCHAN_BASEL(chno),
+		      PAS_DMA_RXCHAN_BASEL_BRBL(ring->chan.ring_dma));
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_BASEU(chan_id),
-			   PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
-			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 3));
+	write_dma_reg(PAS_DMA_RXCHAN_BASEU(chno),
+		      PAS_DMA_RXCHAN_BASEU_BRBH(ring->chan.ring_dma >> 32) |
+		      PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	cfg = PAS_DMA_RXCHAN_CFG_HBU(2);
+	cfg = PAS_DMA_RXCHAN_CFG_HBU(1);
 
 	if (translation_enabled())
 		cfg |= PAS_DMA_RXCHAN_CFG_CTR;
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id), cfg);
+	write_dma_reg(PAS_DMA_RXCHAN_CFG(chno), cfg);
 
-	write_dma_reg(mac, PAS_DMA_RXINT_BASEL(mac->dma_if),
-			   PAS_DMA_RXINT_BASEL_BRBL(ring->buf_dma));
+	write_dma_reg(PAS_DMA_RXINT_BASEL(mac->dma_if),
+		      PAS_DMA_RXINT_BASEL_BRBL(ring->buf_dma));
 
-	write_dma_reg(mac, PAS_DMA_RXINT_BASEU(mac->dma_if),
-			   PAS_DMA_RXINT_BASEU_BRBH(ring->buf_dma >> 32) |
-			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
+	write_dma_reg(PAS_DMA_RXINT_BASEU(mac->dma_if),
+		      PAS_DMA_RXINT_BASEU_BRBH(ring->buf_dma >> 32) |
+		      PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
-	cfg = PAS_DMA_RXINT_CFG_DHL(3) | PAS_DMA_RXINT_CFG_L2 |
+	cfg = PAS_DMA_RXINT_CFG_DHL(1) | PAS_DMA_RXINT_CFG_L2 |
 	      PAS_DMA_RXINT_CFG_LW | PAS_DMA_RXINT_CFG_RBP |
 	      PAS_DMA_RXINT_CFG_HEN;
 
 	if (translation_enabled())
 		cfg |= PAS_DMA_RXINT_CFG_ITRR | PAS_DMA_RXINT_CFG_ITR;
 
-	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if), cfg);
+	write_dma_reg(PAS_DMA_RXINT_CFG(mac->dma_if), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
-
-	ring->status = &dma_status->rx_sta[mac->dma_rxch];
 	ring->mac = mac;
 	mac->rx = ring;
 
 	return 0;
 
-out_buffers:
-	dma_free_coherent(&mac->dma_pdev->dev,
-			  RX_RING_SIZE * sizeof(u64),
-			  rx_ring(mac)->ring, rx_ring(mac)->dma);
 out_ring_desc:
 	kfree(ring->ring_info);
 out_ring_info:
-	kfree(ring);
-out_ring:
+	pasemi_dma_free_chan(&ring->chan);
+out_chan:
 	return -ENOMEM;
 }
 
 static struct pasemi_mac_txring *
-pasemi_mac_setup_tx_resources(struct net_device *dev, int txch)
+pasemi_mac_setup_tx_resources(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	u32 val;
 	struct pasemi_mac_txring *ring;
 	unsigned int cfg;
+	int chno;
 
-	ring = kzalloc(sizeof(*ring), GFP_KERNEL);
-	if (!ring)
-		goto out_ring;
+	ring = pasemi_dma_alloc_chan(TXCHAN, sizeof(struct pasemi_mac_txring),
+				     offsetof(struct pasemi_mac_txring, chan));
+
+	if (!ring) {
+		dev_err(&mac->pdev->dev, "Can't allocate TX channel\n");
+		goto out_chan;
+	}
+
+	chno = ring->chan.chno;
 
 	spin_lock_init(&ring->lock);
 
@@ -319,20 +343,15 @@ pasemi_mac_setup_tx_resources(struct net
 		goto out_ring_info;
 
 	/* Allocate descriptors */
-	ring->ring = dma_alloc_coherent(&mac->dma_pdev->dev,
-					TX_RING_SIZE * sizeof(u64),
-					&ring->dma, GFP_KERNEL);
-	if (!ring->ring)
+	if (pasemi_dma_alloc_ring(&ring->chan, TX_RING_SIZE))
 		goto out_ring_desc;
 
-	memset(ring->ring, 0, TX_RING_SIZE * sizeof(u64));
-
-	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEL(txch),
-			   PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
-	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
+	write_dma_reg(PAS_DMA_TXCHAN_BASEL(chno),
+		      PAS_DMA_TXCHAN_BASEL_BRBL(ring->chan.ring_dma));
+	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->chan.ring_dma >> 32);
 	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 3);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(txch), val);
+	write_dma_reg(PAS_DMA_TXCHAN_BASEU(chno), val);
 
 	cfg = PAS_DMA_TXCHAN_CFG_TY_IFACE |
 	      PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
@@ -342,12 +361,10 @@ pasemi_mac_setup_tx_resources(struct net
 	if (translation_enabled())
 		cfg |= PAS_DMA_TXCHAN_CFG_TRD | PAS_DMA_TXCHAN_CFG_TRR;
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(txch), cfg);
+	write_dma_reg(PAS_DMA_TXCHAN_CFG(chno), cfg);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
-	ring->status = &dma_status->tx_sta[txch];
-	ring->chan = txch;
 	ring->mac = mac;
 
 	return ring;
@@ -355,8 +372,8 @@ pasemi_mac_setup_tx_resources(struct net
 out_ring_desc:
 	kfree(ring->ring_info);
 out_ring_info:
-	kfree(ring);
-out_ring:
+	pasemi_dma_free_chan(&ring->chan);
+out_chan:
 	return NULL;
 }
 
@@ -387,15 +404,9 @@ static void pasemi_mac_free_tx_resources
 			freed = 2;
 	}
 
-	for (i = 0; i < TX_RING_SIZE; i++)
-		txring->ring[i] = 0;
-
-	dma_free_coherent(&mac->dma_pdev->dev,
-			  TX_RING_SIZE * sizeof(u64),
-			  txring->ring, txring->dma);
-
 	kfree(txring->ring_info);
-	kfree(txring);
+	pasemi_dma_free_chan(&txring->chan);
+
 }
 
 static void pasemi_mac_free_rx_resources(struct pasemi_mac *mac)
@@ -420,15 +431,11 @@ static void pasemi_mac_free_rx_resources
 	for (i = 0; i < RX_RING_SIZE; i++)
 		RX_DESC(rx, i) = 0;
 
-	dma_free_coherent(&mac->dma_pdev->dev,
-			  RX_RING_SIZE * sizeof(u64),
-			  rx_ring(mac)->ring, rx_ring(mac)->dma);
-
 	dma_free_coherent(&mac->dma_pdev->dev, RX_RING_SIZE * sizeof(u64),
 			  rx_ring(mac)->buffers, rx_ring(mac)->buf_dma);
 
 	kfree(rx_ring(mac)->ring_info);
-	kfree(rx_ring(mac));
+	pasemi_dma_free_chan(&rx_ring(mac)->chan);
 	mac->rx = NULL;
 }
 
@@ -479,7 +486,7 @@ static void pasemi_mac_replenish_rx_ring
 
 	wmb();
 
-	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), count);
+	write_dma_reg(PAS_DMA_RXINT_INCR(mac->dma_if), count);
 
 	rx_ring(mac)->next_to_fill = (rx_ring(mac)->next_to_fill + count) &
 				(RX_RING_SIZE - 1);
@@ -492,11 +499,11 @@ static void pasemi_mac_restart_rx_intr(s
 	 * ack the packet count interrupt we got in rx_intr.
 	 */
 
-	pcnt = *rx_ring(mac)->status & PAS_STATUS_PCNT_M;
+	pcnt = *rx_ring(mac)->chan.status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_RXCH_RESET_PINTC;
 
-	write_iob_reg(mac, PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
+	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(mac->rx->chan.chno), reg);
 }
 
 static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
@@ -504,26 +511,27 @@ static void pasemi_mac_restart_tx_intr(s
 	unsigned int reg, pcnt;
 
 	/* Re-enable packet count interrupts */
-	pcnt = *tx_ring(mac)->status & PAS_STATUS_PCNT_M;
+	pcnt = *tx_ring(mac)->chan.status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
-	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(tx_ring(mac)->chan), reg);
+	write_iob_reg(PAS_IOB_DMA_TXCH_RESET(tx_ring(mac)->chan.chno), reg);
 }
 
 
 static inline void pasemi_mac_rx_error(struct pasemi_mac *mac, u64 macrx)
 {
 	unsigned int rcmdsta, ccmdsta;
+	struct pasemi_dmachan *chan = &rx_ring(mac)->chan;
 
 	if (!netif_msg_rx_err(mac))
 		return;
 
-	rcmdsta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
-	ccmdsta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+	rcmdsta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+	ccmdsta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(chan->chno));
 
 	printk(KERN_ERR "pasemi_mac: rx error. macrx %016lx, rx status %lx\n",
-		macrx, *rx_ring(mac)->status);
+		macrx, *chan->status);
 
 	printk(KERN_ERR "pasemi_mac: rcmdsta %08x ccmdsta %08x\n",
 		rcmdsta, ccmdsta);
@@ -532,20 +540,22 @@ static inline void pasemi_mac_rx_error(s
 static inline void pasemi_mac_tx_error(struct pasemi_mac *mac, u64 mactx)
 {
 	unsigned int cmdsta;
+	struct pasemi_dmachan *chan = &tx_ring(mac)->chan;
 
 	if (!netif_msg_tx_err(mac))
 		return;
 
-	cmdsta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+	cmdsta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(chan->chno));
 
 	printk(KERN_ERR "pasemi_mac: tx error. mactx 0x%016lx, "\
-		"tx status 0x%016lx\n", mactx, *tx_ring(mac)->status);
+		"tx status 0x%016lx\n", mactx, *chan->status);
 
 	printk(KERN_ERR "pasemi_mac: tcmdsta 0x%08x\n", cmdsta);
 }
 
 static int pasemi_mac_clean_rx(struct pasemi_mac_rxring *rx, int limit)
 {
+	struct pasemi_dmachan *chan = &rx->chan;
 	struct pasemi_mac *mac = rx->mac;
 	unsigned int n;
 	int count;
@@ -567,7 +577,7 @@ static int pasemi_mac_clean_rx(struct pa
 		macrx = RX_DESC(rx, n);
 
 		if ((macrx & XCT_MACRX_E) ||
-		    (*rx_ring(mac)->status & PAS_STATUS_ERROR))
+		    (*chan->status & PAS_STATUS_ERROR))
 			pasemi_mac_rx_error(mac, macrx);
 
 		if (!(macrx & XCT_MACRX_O))
@@ -648,7 +658,7 @@ next:
 
 	if (n > RX_RING_SIZE) {
 		/* Errata 5971 workaround: L2 target of headers */
-		write_iob_reg(mac, PAS_IOB_COM_PKTHDRCNT, 0);
+		write_iob_reg(PAS_IOB_COM_PKTHDRCNT, 0);
 		n &= (RX_RING_SIZE-1);
 	}
 
@@ -658,7 +668,7 @@ next:
 	 * with an 8BRES takes up 3x8 bytes (padded to 4x8), increase with
 	 * count*2.
 	 */
-	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count << 1);
+	write_dma_reg(PAS_DMA_RXCHAN_INCR(mac->rx->chan.chno), count << 1);
 
 	pasemi_mac_replenish_rx_ring(mac->netdev, count);
 
@@ -672,6 +682,7 @@ next:
 
 static int pasemi_mac_clean_tx(struct pasemi_mac_txring *txring)
 {
+	struct pasemi_dmachan *chan = &txring->chan;
 	struct pasemi_mac *mac = txring->mac;
 	int i, j;
 	unsigned int start, descr_count, buf_count, batch_limit;
@@ -703,7 +714,7 @@ restart:
 		struct sk_buff *skb;
 
 		if ((mactx  & XCT_MACTX_E) ||
-		    (*tx_ring(mac)->status & PAS_STATUS_ERROR))
+		    (*chan->status & PAS_STATUS_ERROR))
 			pasemi_mac_tx_error(mac, mactx);
 
 		if (unlikely(mactx & XCT_MACTX_O))
@@ -747,11 +758,13 @@ restart:
 
 static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 {
-	struct net_device *dev = data;
-	struct pasemi_mac *mac = netdev_priv(dev);
+	struct pasemi_mac_rxring *rxring = data;
+	struct pasemi_mac *mac = rxring->mac;
+	struct net_device *dev = mac->netdev;
+	struct pasemi_dmachan *chan = &rxring->chan;
 	unsigned int reg;
 
-	if (!(*rx_ring(mac)->status & PAS_STATUS_CAUSE_M))
+	if (!(*chan->status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	/* Don't reset packet count so it won't fire again but clear
@@ -759,16 +772,16 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	 */
 
 	reg = 0;
-	if (*rx_ring(mac)->status & PAS_STATUS_SOFT)
+	if (*chan->status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
-	if (*rx_ring(mac)->status & PAS_STATUS_ERROR)
+	if (*chan->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
-	if (*rx_ring(mac)->status & PAS_STATUS_TIMER)
+	if (*chan->status & PAS_STATUS_TIMER)
 		reg |= PAS_IOB_DMA_RXCH_RESET_TINTC;
 
 	netif_rx_schedule(dev, &mac->napi);
 
-	write_iob_reg(mac, PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
+	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(chan->chno), reg);
 
 	return IRQ_HANDLED;
 }
@@ -776,24 +789,24 @@ static irqreturn_t pasemi_mac_rx_intr(in
 static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 {
 	struct pasemi_mac_txring *txring = data;
-	struct pasemi_mac *mac = txring->mac;
+	struct pasemi_dmachan *chan = &txring->chan;
 	unsigned int reg, pcnt;
 
-	if (!(*txring->status & PAS_STATUS_CAUSE_M))
+	if (!(*chan->status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
 	pasemi_mac_clean_tx(txring);
 
-	pcnt = *txring->status & PAS_STATUS_PCNT_M;
+	pcnt = *chan->status & PAS_STATUS_PCNT_M;
 
 	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
-	if (*txring->status & PAS_STATUS_SOFT)
+	if (*chan->status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
-	if (*txring->status & PAS_STATUS_ERROR)
+	if (*chan->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
-	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(txring->chan), reg);
+	write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
 
 	return IRQ_HANDLED;
 }
@@ -909,15 +922,14 @@ err:
 static int pasemi_mac_open(struct net_device *dev)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	int base_irq;
 	unsigned int flags;
 	int ret;
 
 	/* enable rx section */
-	write_dma_reg(mac, PAS_DMA_COM_RXCMD, PAS_DMA_COM_RXCMD_EN);
+	write_dma_reg(PAS_DMA_COM_RXCMD, PAS_DMA_COM_RXCMD_EN);
 
 	/* enable tx section */
-	write_dma_reg(mac, PAS_DMA_COM_TXCMD, PAS_DMA_COM_TXCMD_EN);
+	write_dma_reg(PAS_DMA_COM_TXCMD, PAS_DMA_COM_TXCMD_EN);
 
 	flags = PAS_MAC_CFG_TXP_FCE | PAS_MAC_CFG_TXP_FPC(3) |
 		PAS_MAC_CFG_TXP_SL(3) | PAS_MAC_CFG_TXP_COB(0xf) |
@@ -925,56 +937,53 @@ static int pasemi_mac_open(struct net_de
 
 	write_mac_reg(mac, PAS_MAC_CFG_TXP, flags);
 
-	write_iob_reg(mac, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
-			   PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
-
-	write_iob_reg(mac, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
-			   PAS_IOB_DMA_TXCH_CFG_CNTTH(128));
-
 	/* 0xffffff is max value, about 16ms */
-	write_iob_reg(mac, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			   PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
+	write_iob_reg(PAS_IOB_DMA_COM_TIMEOUTCFG,
+		      PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
 	ret = pasemi_mac_setup_rx_resources(dev);
 	if (ret)
 		goto out_rx_resources;
 
-	mac->tx = pasemi_mac_setup_tx_resources(dev, mac->dma_txch);
+	mac->tx = pasemi_mac_setup_tx_resources(dev);
 
 	if (!mac->tx)
 		goto out_tx_ring;
 
+	write_iob_reg(PAS_IOB_DMA_RXCH_CFG(mac->rx->chan.chno),
+		      PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
+
+	write_iob_reg(PAS_IOB_DMA_TXCH_CFG(mac->tx->chan.chno),
+		      PAS_IOB_DMA_TXCH_CFG_CNTTH(128));
+
 	write_mac_reg(mac, PAS_MAC_IPC_CHNL,
-			   PAS_MAC_IPC_CHNL_DCHNO(mac->dma_rxch) |
-			   PAS_MAC_IPC_CHNL_BCH(mac->dma_rxch));
+		      PAS_MAC_IPC_CHNL_DCHNO(mac->rx->chan.chno) |
+		      PAS_MAC_IPC_CHNL_BCH(mac->rx->chan.chno));
 
 	/* enable rx if */
-	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-			   PAS_DMA_RXINT_RCMDSTA_EN |
-			   PAS_DMA_RXINT_RCMDSTA_DROPS_M |
-			   PAS_DMA_RXINT_RCMDSTA_BP |
-			   PAS_DMA_RXINT_RCMDSTA_OO |
-			   PAS_DMA_RXINT_RCMDSTA_BT);
+	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+		      PAS_DMA_RXINT_RCMDSTA_EN |
+		      PAS_DMA_RXINT_RCMDSTA_DROPS_M |
+		      PAS_DMA_RXINT_RCMDSTA_BP |
+		      PAS_DMA_RXINT_RCMDSTA_OO |
+		      PAS_DMA_RXINT_RCMDSTA_BT);
 
 	/* enable rx channel */
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
-			   PAS_DMA_RXCHAN_CCMDSTA_EN |
-			   PAS_DMA_RXCHAN_CCMDSTA_DU |
-			   PAS_DMA_RXCHAN_CCMDSTA_OD |
-			   PAS_DMA_RXCHAN_CCMDSTA_FD |
-			   PAS_DMA_RXCHAN_CCMDSTA_DT);
+	pasemi_dma_start_chan(&rx_ring(mac)->chan, PAS_DMA_RXCHAN_CCMDSTA_DU |
+						   PAS_DMA_RXCHAN_CCMDSTA_OD |
+						   PAS_DMA_RXCHAN_CCMDSTA_FD |
+						   PAS_DMA_RXCHAN_CCMDSTA_DT);
 
 	/* enable tx channel */
-	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
-			   PAS_DMA_TXCHAN_TCMDSTA_EN |
-			   PAS_DMA_TXCHAN_TCMDSTA_SZ |
-			   PAS_DMA_TXCHAN_TCMDSTA_DB |
-			   PAS_DMA_TXCHAN_TCMDSTA_DE |
-			   PAS_DMA_TXCHAN_TCMDSTA_DA);
+	pasemi_dma_start_chan(&tx_ring(mac)->chan, PAS_DMA_TXCHAN_TCMDSTA_SZ |
+						   PAS_DMA_TXCHAN_TCMDSTA_DB |
+						   PAS_DMA_TXCHAN_TCMDSTA_DE |
+						   PAS_DMA_TXCHAN_TCMDSTA_DA);
 
 	pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE);
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), RX_RING_SIZE>>1);
+	write_dma_reg(PAS_DMA_RXCHAN_INCR(rx_ring(mac)->chan.chno),
+		      RX_RING_SIZE>>1);
 
 	/* Clear out any residual packet count state from firmware */
 	pasemi_mac_restart_rx_intr(mac);
@@ -1001,37 +1010,25 @@ static int pasemi_mac_open(struct net_de
 	netif_start_queue(dev);
 	napi_enable(&mac->napi);
 
-	/* Interrupts are a bit different for our DMA controller: While
-	 * it's got one a regular PCI device header, the interrupt there
-	 * is really the base of the range it's using. Each tx and rx
-	 * channel has it's own interrupt source.
-	 */
-
-	base_irq = virq_to_hw(mac->dma_pdev->irq);
-
-	mac->tx_irq = irq_create_mapping(NULL, base_irq + mac->dma_txch);
-
 	snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
 		 dev->name);
 
-	ret = request_irq(mac->tx_irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->tx->chan.irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
 			  mac->tx_irq_name, mac->tx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-			base_irq + mac->dma_txch, ret);
+			mac->tx->chan.irq, ret);
 		goto out_tx_int;
 	}
 
-	mac->rx_irq = irq_create_mapping(NULL, base_irq + 20 + mac->dma_rxch);
-
 	snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
 		 dev->name);
 
-	ret = request_irq(mac->rx_irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
-			  mac->rx_irq_name, dev);
+	ret = request_irq(mac->rx->chan.irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
+			  mac->rx_irq_name, mac->rx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-			base_irq + 20 + mac->dma_rxch, ret);
+			mac->rx->chan.irq, ret);
 		goto out_rx_int;
 	}
 
@@ -1041,7 +1038,7 @@ static int pasemi_mac_open(struct net_de
 	return 0;
 
 out_rx_int:
-	free_irq(mac->tx_irq, mac->tx);
+	free_irq(mac->tx->chan.irq, mac->tx);
 out_tx_int:
 	napi_disable(&mac->napi);
 	netif_stop_queue(dev);
@@ -1061,6 +1058,10 @@ static int pasemi_mac_close(struct net_d
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int sta;
 	int retries;
+	int rxch, txch;
+
+	rxch = rx_ring(mac)->chan.chno;
+	txch = tx_ring(mac)->chan.chno;
 
 	if (mac->phydev) {
 		phy_stop(mac->phydev);
@@ -1070,20 +1071,20 @@ static int pasemi_mac_close(struct net_d
 	netif_stop_queue(dev);
 	napi_disable(&mac->napi);
 
-	sta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+	sta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
 	if (sta & (PAS_DMA_RXINT_RCMDSTA_BP |
 		      PAS_DMA_RXINT_RCMDSTA_OO |
 		      PAS_DMA_RXINT_RCMDSTA_BT))
 		printk(KERN_DEBUG "pasemi_mac: rcmdsta error: 0x%08x\n", sta);
 
-	sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+	sta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch));
 	if (sta & (PAS_DMA_RXCHAN_CCMDSTA_DU |
 		     PAS_DMA_RXCHAN_CCMDSTA_OD |
 		     PAS_DMA_RXCHAN_CCMDSTA_FD |
 		     PAS_DMA_RXCHAN_CCMDSTA_DT))
 		printk(KERN_DEBUG "pasemi_mac: ccmdsta error: 0x%08x\n", sta);
 
-	sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+	sta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch));
 	if (sta & (PAS_DMA_TXCHAN_TCMDSTA_SZ | PAS_DMA_TXCHAN_TCMDSTA_DB |
 		      PAS_DMA_TXCHAN_TCMDSTA_DE | PAS_DMA_TXCHAN_TCMDSTA_DA))
 		printk(KERN_DEBUG "pasemi_mac: tcmdsta error: 0x%08x\n", sta);
@@ -1093,26 +1094,25 @@ static int pasemi_mac_close(struct net_d
 	pasemi_mac_clean_rx(rx_ring(mac), RX_RING_SIZE);
 
 	/* Disable interface */
-	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
+	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch),
 		      PAS_DMA_TXCHAN_TCMDSTA_ST);
-	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+	write_dma_reg( PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
 		      PAS_DMA_RXINT_RCMDSTA_ST);
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
+	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch),
 		      PAS_DMA_RXCHAN_CCMDSTA_ST);
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
+		sta = read_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(rxch));
 		if (!(sta & PAS_DMA_TXCHAN_TCMDSTA_ACT))
 			break;
 		cond_resched();
 	}
 
 	if (sta & PAS_DMA_TXCHAN_TCMDSTA_ACT)
-		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel %d\n",
-			mac->dma_txch);
+		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
+		sta = read_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch));
 		if (!(sta & PAS_DMA_RXCHAN_CCMDSTA_ACT))
 			break;
 		cond_resched();
@@ -1122,7 +1122,7 @@ static int pasemi_mac_close(struct net_d
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		sta = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
+		sta = read_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
 		if (!(sta & PAS_DMA_RXINT_RCMDSTA_ACT))
 			break;
 		cond_resched();
@@ -1135,12 +1135,12 @@ static int pasemi_mac_close(struct net_d
 	 * stopping, since you can't disable when active.
 	 */
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), 0);
-	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
-	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+	write_dma_reg(PAS_DMA_TXCHAN_TCMDSTA(txch), 0);
+	write_dma_reg(PAS_DMA_RXCHAN_CCMDSTA(rxch), 0);
+	write_dma_reg(PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
 
-	free_irq(mac->tx_irq, mac->tx);
-	free_irq(mac->rx_irq, mac->rx);
+	free_irq(mac->tx->chan.irq, mac->tx);
+	free_irq(mac->rx->chan.irq, mac->rx);
 
 	/* Free resources */
 	pasemi_mac_free_rx_resources(mac);
@@ -1239,7 +1239,7 @@ static int pasemi_mac_start_tx(struct sk
 
 	spin_unlock_irqrestore(&txring->lock, flags);
 
-	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(txring->chan), (nfrags+2) >> 1);
+	write_dma_reg(PAS_DMA_TXCHAN_INCR(txring->chan.chno), (nfrags+2) >> 1);
 
 	return NETDEV_TX_OK;
 
@@ -1287,77 +1287,9 @@ static int pasemi_mac_poll(struct napi_s
 	return pkts;
 }
 
-static void __iomem * __devinit map_onedev(struct pci_dev *p, int index)
-{
-	struct device_node *dn;
-	void __iomem *ret;
-
-	dn = pci_device_to_OF_node(p);
-	if (!dn)
-		goto fallback;
-
-	ret = of_iomap(dn, index);
-	if (!ret)
-		goto fallback;
-
-	return ret;
-fallback:
-	/* This is hardcoded and ugly, but we have some firmware versions
-	 * that don't provide the register space in the device tree. Luckily
-	 * they are at well-known locations so we can just do the math here.
-	 */
-	return ioremap(0xe0000000 + (p->devfn << 12), 0x2000);
-}
-
-static int __devinit pasemi_mac_map_regs(struct pasemi_mac *mac)
-{
-	struct resource res;
-	struct device_node *dn;
-	int err;
-
-	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
-	if (!mac->dma_pdev) {
-		dev_err(&mac->pdev->dev, "Can't find DMA Controller\n");
-		return -ENODEV;
-	}
-
-	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
-	if (!mac->iob_pdev) {
-		dev_err(&mac->pdev->dev, "Can't find I/O Bridge\n");
-		return -ENODEV;
-	}
-
-	mac->regs = map_onedev(mac->pdev, 0);
-	mac->dma_regs = map_onedev(mac->dma_pdev, 0);
-	mac->iob_regs = map_onedev(mac->iob_pdev, 0);
-
-	if (!mac->regs || !mac->dma_regs || !mac->iob_regs) {
-		dev_err(&mac->pdev->dev, "Can't map registers\n");
-		return -ENODEV;
-	}
-
-	/* The dma status structure is located in the I/O bridge, and
-	 * is cache coherent.
-	 */
-	if (!dma_status) {
-		dn = pci_device_to_OF_node(mac->iob_pdev);
-		if (dn)
-			err = of_address_to_resource(dn, 1, &res);
-		if (!dn || err) {
-			/* Fallback for old firmware */
-			res.start = 0xfd800000;
-			res.end = res.start + 0x1000;
-		}
-		dma_status = __ioremap(res.start, res.end-res.start, 0);
-	}
-
-	return 0;
-}
-
 static int __devinit
 pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
-	static int index = 0;
 	struct net_device *dev;
 	struct pasemi_mac *mac;
 	int err;
@@ -1387,18 +1319,33 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 
 	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
 
-	/* These should come out of the device tree eventually */
-	mac->dma_txch = index;
-	mac->dma_rxch = index;
+	mac->dma_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
+	if (!mac->dma_pdev) {
+		dev_err(&mac->pdev->dev, "Can't find DMA Controller\n");
+		err = -ENODEV;
+		goto out;
+	}
 
-	/* We probe GMAC before XAUI, but the DMA interfaces are
-	 * in XAUI, GMAC order.
-	 */
-	if (index < 4)
-		mac->dma_if = index + 2;
-	else
-		mac->dma_if = index - 4;
-	index++;
+	mac->iob_pdev = pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa001, NULL);
+	if (!mac->iob_pdev) {
+		dev_err(&mac->pdev->dev, "Can't find I/O Bridge\n");
+		err = -ENODEV;
+		goto out;
+	}
+
+	/* get mac addr from device tree */
+	if (pasemi_get_mac_addr(mac) || !is_valid_ether_addr(mac->mac_addr)) {
+		err = -ENODEV;
+		goto out;
+	}
+	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
+
+	mac->dma_if = mac_to_intf(mac);
+	if (mac->dma_if < 0) {
+		dev_err(&mac->pdev->dev, "Can't map DMA interface\n");
+		err = -ENODEV;
+		goto out;
+	}
 
 	switch (pdev->device) {
 	case 0xa005:
@@ -1412,19 +1359,11 @@ pasemi_mac_probe(struct pci_dev *pdev, c
 		goto out;
 	}
 
-	/* get mac addr from device tree */
-	if (pasemi_get_mac_addr(mac) || !is_valid_ether_addr(mac->mac_addr)) {
-		err = -ENODEV;
-		goto out;
-	}
-	memcpy(dev->dev_addr, mac->mac_addr, sizeof(mac->mac_addr));
-
 	dev->open = pasemi_mac_open;
 	dev->stop = pasemi_mac_close;
 	dev->hard_start_xmit = pasemi_mac_start_tx;
 	dev->set_multicast_list = pasemi_mac_set_rx_mode;
 
-	err = pasemi_mac_map_regs(mac);
 	if (err)
 		goto out;
 
@@ -1451,12 +1390,6 @@ out:
 		pci_dev_put(mac->iob_pdev);
 	if (mac->dma_pdev)
 		pci_dev_put(mac->dma_pdev);
-	if (mac->dma_regs)
-		iounmap(mac->dma_regs);
-	if (mac->iob_regs)
-		iounmap(mac->iob_regs);
-	if (mac->regs)
-		iounmap(mac->regs);
 
 	free_netdev(dev);
 out_disable_device:
@@ -1481,9 +1414,8 @@ static void __devexit pasemi_mac_remove(
 	pci_dev_put(mac->dma_pdev);
 	pci_dev_put(mac->iob_pdev);
 
-	iounmap(mac->regs);
-	iounmap(mac->dma_regs);
-	iounmap(mac->iob_regs);
+	pasemi_dma_free_chan(&mac->tx->chan);
+	pasemi_dma_free_chan(&mac->rx->chan);
 
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
@@ -1507,12 +1439,16 @@ static struct pci_driver pasemi_mac_driv
 static void __exit pasemi_mac_cleanup_module(void)
 {
 	pci_unregister_driver(&pasemi_mac_driver);
-	__iounmap(dma_status);
-	dma_status = NULL;
 }
 
 int pasemi_mac_init_module(void)
 {
+	int err;
+
+	err = pasemi_dma_init();
+	if (err)
+		return err;
+
 	return pci_register_driver(&pasemi_mac_driver);
 }
 
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -27,23 +27,18 @@
 #include <linux/phy.h>
 
 struct pasemi_mac_txring {
+	struct pasemi_dmachan chan; /* Must be first */
 	spinlock_t	 lock;
-	u64		*status; /* Ptr to cacheable status area */
-	u64		*ring;
-	dma_addr_t	 dma;
 	unsigned int	 size;
 	unsigned int	 next_to_fill;
 	unsigned int	 next_to_clean;
 	struct pasemi_mac_buffer *ring_info;
-	int		 chan;
 	struct pasemi_mac *mac;	/* Needed in intr handler */
 };
 
 struct pasemi_mac_rxring {
+	struct pasemi_dmachan chan; /* Must be first */
 	spinlock_t	 lock;
-	u64		*status; /* Ptr to cacheable status area */
-	u64		*ring;	/* RX channel descriptor ring */
-	dma_addr_t	 dma;
 	u64		*buffers;	/* RX interface buffer ring */
 	dma_addr_t	 buf_dma;
 	unsigned int	 size;
@@ -55,9 +50,6 @@ struct pasemi_mac_rxring {
 
 struct pasemi_mac {
 	struct net_device *netdev;
-	void __iomem *regs;
-	void __iomem *dma_regs;
-	void __iomem *iob_regs;
 	struct pci_dev *pdev;
 	struct pci_dev *dma_pdev;
 	struct pci_dev *iob_pdev;
@@ -67,8 +59,6 @@ struct pasemi_mac {
 	u8		type;
 #define MAC_TYPE_GMAC	1
 #define MAC_TYPE_XAUI	2
-	u32	dma_txch;
-	u32	dma_rxch;
 	u32	dma_if;
 
 	u8		mac_addr[6];
@@ -77,8 +67,6 @@ struct pasemi_mac {
 
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
-	unsigned int	tx_irq;
-	unsigned int	rx_irq;
 	char		tx_irq_name[10];		/* "eth%d tx" */
 	char		rx_irq_name[10];		/* "eth%d rx" */
 	int	link;
