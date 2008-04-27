From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [RFT 0/6] sis190 branch info
Date: Sun, 27 Apr 2008 19:00:23 +0200
Message-ID: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52337 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755318AbYD0RUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:20:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'sis190' branch in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git sis190

contains the changes below.

Tested by myself on an Asrock 945G-DVI (SiS 760/965 + SiS 190) with
various packet sizes.

Distance from 'upstream-davem' (f946dffed6334f08da065a89ed65026ebf8b33b4)
-------------------------------------------------------------------------

697c269610179051cf19e45566fee3dcebbb1e93
c34ebbae01e3d1f6a5cced6a40dc0ed792590d22
47e4781544aaf2916170ef5516786fbb19447600
35aeb7809345e0362772a75368a3e62ecd931481
e3eccad9f6e84656b45bfa07738934145b09e11e
4709aa59ede5ff9902d60088d93d1c0e2e9d2247

Diffstat
--------

 drivers/net/sis190.c |  136 ++++++++++++++++++++++++++++++--------------------
 1 files changed, 81 insertions(+), 55 deletions(-)

Shortlog
--------

Francois Romieu (3):
      sis190: Rx path update
      sis190: remove needless MII reset
      sis190: account for Tx errors

Stephen Hemminger (3):
      sis190: use the allocated buffer as a status code in sis190_alloc_rx_skb
      sis190: hard-code the alignment of tiny packets
      sis190: use netdev_alloc_skb

Patch
-----

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 20745fd..abc63b0 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -212,6 +212,12 @@ enum _DescStatusBit {
 	THOL2		= 0x20000000,
 	THOL1		= 0x10000000,
 	THOL0		= 0x00000000,
+
+	WND		= 0x00080000,
+	TABRT		= 0x00040000,
+	FIFO		= 0x00020000,
+	LINK		= 0x00010000,
+	ColCountMask	= 0x0000ffff,
 	/* RxDesc.status */
 	IPON		= 0x20000000,
 	TCPON		= 0x10000000,
@@ -480,30 +486,23 @@ static inline void sis190_make_unusable_by_asic(struct RxDesc *desc)
 	desc->status = 0x0;
 }
 
-static int sis190_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
-			       struct RxDesc *desc, u32 rx_buf_sz)
+static struct sk_buff *sis190_alloc_rx_skb(struct sis190_private *tp,
+					   struct RxDesc *desc)
 {
+	u32 rx_buf_sz = tp->rx_buf_sz;
 	struct sk_buff *skb;
-	dma_addr_t mapping;
-	int ret = 0;
-
-	skb = dev_alloc_skb(rx_buf_sz);
-	if (!skb)
-		goto err_out;
-
-	*sk_buff = skb;
 
-	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
-				 PCI_DMA_FROMDEVICE);
+	skb = netdev_alloc_skb(tp->dev, rx_buf_sz);
+	if (likely(skb)) {
+		dma_addr_t mapping;
 
-	sis190_map_to_asic(desc, mapping, rx_buf_sz);
-out:
-	return ret;
+		mapping = pci_map_single(tp->pci_dev, skb->data, tp->rx_buf_sz,
+					 PCI_DMA_FROMDEVICE);
+		sis190_map_to_asic(desc, mapping, rx_buf_sz);
+	} else
+		sis190_make_unusable_by_asic(desc);
 
-err_out:
-	ret = -ENOMEM;
-	sis190_make_unusable_by_asic(desc);
-	goto out;
+	return skb;
 }
 
 static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
@@ -512,37 +511,41 @@ static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
 	u32 cur;
 
 	for (cur = start; cur < end; cur++) {
-		int ret, i = cur % NUM_RX_DESC;
+		unsigned int i = cur % NUM_RX_DESC;
 
 		if (tp->Rx_skbuff[i])
 			continue;
 
-		ret = sis190_alloc_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
-					  tp->RxDescRing + i, tp->rx_buf_sz);
-		if (ret < 0)
+		tp->Rx_skbuff[i] = sis190_alloc_rx_skb(tp, tp->RxDescRing + i);
+
+		if (!tp->Rx_skbuff[i])
 			break;
 	}
 	return cur - start;
 }
 
-static inline int sis190_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				     struct RxDesc *desc, int rx_buf_sz)
+static bool sis190_try_rx_copy(struct sis190_private *tp,
+			       struct sk_buff **sk_buff, int pkt_size,
+			       dma_addr_t addr)
 {
-	int ret = -1;
+	struct sk_buff *skb;
+	bool done = false;
 
-	if (pkt_size < rx_copybreak) {
-		struct sk_buff *skb;
+	if (pkt_size >= rx_copybreak)
+		goto out;
 
-		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
-		if (skb) {
-			skb_reserve(skb, NET_IP_ALIGN);
-			skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
-			*sk_buff = skb;
-			sis190_give_to_asic(desc, rx_buf_sz);
-			ret = 0;
-		}
-	}
-	return ret;
+	skb = netdev_alloc_skb(tp->dev, pkt_size + 2);
+	if (!skb)
+		goto out;
+
+	pci_dma_sync_single_for_device(tp->pci_dev, addr, pkt_size,
+				       PCI_DMA_FROMDEVICE);
+	skb_reserve(skb, 2);
+	skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
+	*sk_buff = skb;
+	done = true;
+out:
+	return done;
 }
 
 static inline int sis190_rx_pkt_err(u32 status, struct net_device_stats *stats)
@@ -592,9 +595,9 @@ static int sis190_rx_interrupt(struct net_device *dev,
 			sis190_give_to_asic(desc, tp->rx_buf_sz);
 		else {
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
+			dma_addr_t addr = le32_to_cpu(desc->addr);
 			int pkt_size = (status & RxSizeMask) - 4;
-			void (*pci_action)(struct pci_dev *, dma_addr_t,
-				size_t, int) = pci_dma_sync_single_for_device;
+			struct pci_dev *pdev = tp->pci_dev;
 
 			if (unlikely(pkt_size > tp->rx_buf_sz)) {
 				net_intr(tp, KERN_INFO
@@ -606,20 +609,18 @@ static int sis190_rx_interrupt(struct net_device *dev,
 				continue;
 			}
 
-			pci_dma_sync_single_for_cpu(tp->pci_dev,
-				le32_to_cpu(desc->addr), tp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
 
-			if (sis190_try_rx_copy(&skb, pkt_size, desc,
-					       tp->rx_buf_sz)) {
-				pci_action = pci_unmap_single;
+			if (sis190_try_rx_copy(tp, &skb, pkt_size, addr)) {
+				pci_dma_sync_single_for_device(pdev, addr,
+					tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+				sis190_give_to_asic(desc, tp->rx_buf_sz);
+			} else {
+				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
+						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 				sis190_make_unusable_by_asic(desc);
 			}
 
-			pci_action(tp->pci_dev, le32_to_cpu(desc->addr),
-				   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 
@@ -658,9 +659,31 @@ static void sis190_unmap_tx_skb(struct pci_dev *pdev, struct sk_buff *skb,
 	memset(desc, 0x00, sizeof(*desc));
 }
 
+static inline int sis190_tx_pkt_err(u32 status, struct net_device_stats *stats)
+{
+#define TxErrMask	(WND | TABRT | FIFO | LINK)
+
+	if (!unlikely(status & TxErrMask))
+		return 0;
+
+	if (status & WND)
+		stats->tx_window_errors++;
+	if (status & TABRT)
+		stats->tx_aborted_errors++;
+	if (status & FIFO)
+		stats->tx_fifo_errors++;
+	if (status & LINK)
+		stats->tx_carrier_errors++;
+
+	stats->tx_errors++;
+
+	return -1;
+}
+
 static void sis190_tx_interrupt(struct net_device *dev,
 				struct sis190_private *tp, void __iomem *ioaddr)
 {
+	struct net_device_stats *stats = &dev->stats;
 	u32 pending, dirty_tx = tp->dirty_tx;
 	/*
 	 * It would not be needed if queueing was allowed to be enabled
@@ -675,15 +698,19 @@ static void sis190_tx_interrupt(struct net_device *dev,
 	for (; pending; pending--, dirty_tx++) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct TxDesc *txd = tp->TxDescRing + entry;
+		u32 status = le32_to_cpu(txd->status);
 		struct sk_buff *skb;
 
-		if (le32_to_cpu(txd->status) & OWNbit)
+		if (status & OWNbit)
 			break;
 
 		skb = tp->Tx_skbuff[entry];
 
-		dev->stats.tx_packets++;
-		dev->stats.tx_bytes += skb->len;
+		if (likely(sis190_tx_pkt_err(status, stats) == 0)) {
+			stats->tx_packets++;
+			stats->tx_bytes += skb->len;
+			stats->collisions += ((status & ColCountMask) - 1);
+		}
 
 		sis190_unmap_tx_skb(tp->pci_dev, skb, txd);
 		tp->Tx_skbuff[entry] = NULL;
@@ -904,10 +931,9 @@ static void sis190_phy_task(struct work_struct *work)
 		mod_timer(&tp->timer, jiffies + HZ/10);
 	} else if (!(mdio_read_latched(ioaddr, phy_id, MII_BMSR) &
 		     BMSR_ANEGCOMPLETE)) {
-		net_link(tp, KERN_WARNING "%s: PHY reset until link up.\n",
-			 dev->name);
 		netif_carrier_off(dev);
-		mdio_write(ioaddr, phy_id, MII_BMCR, val | BMCR_RESET);
+		net_link(tp, KERN_WARNING "%s: auto-negotiating...\n",
+			 dev->name);
 		mod_timer(&tp->timer, jiffies + SIS190_PHY_TIMEOUT);
 	} else {
 		/* Rejoice ! */
-- 
Ueimor
