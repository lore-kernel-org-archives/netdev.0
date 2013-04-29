From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCHv2 2/3] net: velocity: Convert to generic dma functions
Date: Mon, 29 Apr 2013 19:50:40 +1200
Message-ID: <1367221841-14563-3-git-send-email-linux@prisktech.co.nz>
References: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz>
Cc: netdev@vger.kernel.org,
	vt8500-wm8505-linux-kernel@googlegroups.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Tony Prisk <linux@prisktech.co.nz>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.prisktech.co.nz ([115.188.14.127]:50669 "EHLO
	server.prisktech.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3D2Huk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 03:50:40 -0400
In-Reply-To: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the pci_* dma functions and replace with the more generic
versions.

In preparation of adding platform support, a new struct device *dev
is added to struct velocity_info which can be used by both the pci
and platform code.

Signed-off-by: Tony Prisk <linux@prisktech.co.nz>
---
 drivers/net/ethernet/via/via-velocity.c |   51 +++++++++++++++----------------
 drivers/net/ethernet/via/via-velocity.h |    1 +
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 9a408b1..e2c4887 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -46,6 +46,7 @@
 #include <linux/types.h>
 #include <linux/bitops.h>
 #include <linux/init.h>
+#include <linux/dma-mapping.h>
 #include <linux/mm.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
@@ -1457,7 +1458,6 @@ static int velocity_init_dma_rings(struct velocity_info *vptr)
 	struct velocity_opt *opt = &vptr->options;
 	const unsigned int rx_ring_size = opt->numrx * sizeof(struct rx_desc);
 	const unsigned int tx_ring_size = opt->numtx * sizeof(struct tx_desc);
-	struct pci_dev *pdev = vptr->pdev;
 	dma_addr_t pool_dma;
 	void *pool;
 	unsigned int i;
@@ -1465,13 +1465,13 @@ static int velocity_init_dma_rings(struct velocity_info *vptr)
 	/*
 	 * Allocate all RD/TD rings a single pool.
 	 *
-	 * pci_alloc_consistent() fulfills the requirement for 64 bytes
+	 * dma_alloc_coherent() fulfills the requirement for 64 bytes
 	 * alignment
 	 */
-	pool = pci_alloc_consistent(pdev, tx_ring_size * vptr->tx.numq +
-				    rx_ring_size, &pool_dma);
+	pool = dma_alloc_coherent(vptr->dev, tx_ring_size * vptr->tx.numq +
+				    rx_ring_size, &pool_dma, GFP_ATOMIC);
 	if (!pool) {
-		dev_err(&pdev->dev, "%s : DMA memory allocation failed.\n",
+		dev_err(vptr->dev, "%s : DMA memory allocation failed.\n",
 			vptr->netdev->name);
 		return -ENOMEM;
 	}
@@ -1522,8 +1522,8 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	 */
 	skb_reserve(rd_info->skb,
 			64 - ((unsigned long) rd_info->skb->data & 63));
-	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data,
-					vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
+	rd_info->skb_dma = dma_map_single(vptr->dev, rd_info->skb->data,
+					vptr->rx.buf_sz, DMA_FROM_DEVICE);
 
 	/*
 	 *	Fill in the descriptor to match
@@ -1586,8 +1586,8 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 
 		if (!rd_info->skb)
 			continue;
-		pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
-				 PCI_DMA_FROMDEVICE);
+		dma_unmap_single(vptr->dev, rd_info->skb_dma, vptr->rx.buf_sz,
+				 DMA_FROM_DEVICE);
 		rd_info->skb_dma = 0;
 
 		dev_kfree_skb(rd_info->skb);
@@ -1668,7 +1668,7 @@ static void velocity_free_dma_rings(struct velocity_info *vptr)
 	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
 		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
 
-	pci_free_consistent(vptr->pdev, size, vptr->rx.ring, vptr->rx.pool_dma);
+	dma_free_coherent(vptr->dev, size, vptr->rx.ring, vptr->rx.pool_dma);
 }
 
 static int velocity_init_rings(struct velocity_info *vptr, int mtu)
@@ -1725,8 +1725,8 @@ static void velocity_free_tx_buf(struct velocity_info *vptr,
 				pktlen = max_t(size_t, pktlen,
 						td->td_buf[i].size & ~TD_QUEUE);
 
-			pci_unmap_single(vptr->pdev, tdinfo->skb_dma[i],
-					le16_to_cpu(pktlen), PCI_DMA_TODEVICE);
+			dma_unmap_single(vptr->dev, tdinfo->skb_dma[i],
+					le16_to_cpu(pktlen), DMA_TO_DEVICE);
 		}
 	}
 	dev_kfree_skb_irq(skb);
@@ -1748,8 +1748,8 @@ static void velocity_free_td_ring_entry(struct velocity_info *vptr,
 	if (td_info->skb) {
 		for (i = 0; i < td_info->nskb_dma; i++) {
 			if (td_info->skb_dma[i]) {
-				pci_unmap_single(vptr->pdev, td_info->skb_dma[i],
-					td_info->skb->len, PCI_DMA_TODEVICE);
+				dma_unmap_single(vptr->dev, td_info->skb_dma[i],
+					td_info->skb->len, DMA_TO_DEVICE);
 				td_info->skb_dma[i] = 0;
 			}
 		}
@@ -2027,7 +2027,6 @@ static inline void velocity_iph_realign(struct velocity_info *vptr,
  */
 static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 {
-	void (*pci_action)(struct pci_dev *, dma_addr_t, size_t, int);
 	struct net_device_stats *stats = &vptr->netdev->stats;
 	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 	struct rx_desc *rd = &(vptr->rx.ring[idx]);
@@ -2045,8 +2044,8 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 
 	skb = rd_info->skb;
 
-	pci_dma_sync_single_for_cpu(vptr->pdev, rd_info->skb_dma,
-				    vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_cpu(vptr->dev, rd_info->skb_dma,
+				    vptr->rx.buf_sz, DMA_FROM_DEVICE);
 
 	/*
 	 *	Drop frame not meeting IEEE 802.3
@@ -2059,19 +2058,18 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 		}
 	}
 
-	pci_action = pci_dma_sync_single_for_device;
-
 	velocity_rx_csum(rd, skb);
 
 	if (velocity_rx_copy(&skb, pkt_len, vptr) < 0) {
 		velocity_iph_realign(vptr, skb, pkt_len);
-		pci_action = pci_unmap_single;
 		rd_info->skb = NULL;
+		dma_unmap_single(vptr->dev, rd_info->skb_dma, vptr->rx.buf_sz,
+				 DMA_FROM_DEVICE);
+	} else {
+		dma_sync_single_for_device(vptr->dev, rd_info->skb_dma,
+					   vptr->rx.buf_sz, DMA_FROM_DEVICE);
 	}
 
-	pci_action(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
-		   PCI_DMA_FROMDEVICE);
-
 	skb_put(skb, pkt_len - 4);
 	skb->protocol = eth_type_trans(skb, vptr->netdev);
 
@@ -2548,7 +2546,8 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	 *	add it to the transmit ring.
 	 */
 	tdinfo->skb = skb;
-	tdinfo->skb_dma[0] = pci_map_single(vptr->pdev, skb->data, pktlen, PCI_DMA_TODEVICE);
+	tdinfo->skb_dma[0] = dma_map_single(vptr->dev, skb->data, pktlen,
+								DMA_TO_DEVICE);
 	td_ptr->tdesc0.len = cpu_to_le16(pktlen);
 	td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
 	td_ptr->td_buf[0].pa_high = 0;
@@ -2558,7 +2557,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *skb,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		tdinfo->skb_dma[i + 1] = skb_frag_dma_map(&vptr->pdev->dev,
+		tdinfo->skb_dma[i + 1] = skb_frag_dma_map(vptr->dev,
 							  frag, 0,
 							  skb_frag_size(frag),
 							  DMA_TO_DEVICE);
@@ -2635,6 +2634,7 @@ static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
 {
 	memset(vptr, 0, sizeof(struct velocity_info));
 
+	vptr->dev = &pdev->dev;
 	vptr->pdev = pdev;
 	vptr->chip_id = info->chip_id;
 	vptr->tx.numq = info->txqueue;
@@ -2742,7 +2742,6 @@ static int velocity_found1(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	vptr = netdev_priv(dev);
 
-
 	if (first) {
 		printk(KERN_INFO "%s Ver. %s\n",
 			VELOCITY_FULL_DRV_NAM, VELOCITY_VERSION);
diff --git a/drivers/net/ethernet/via/via-velocity.h b/drivers/net/ethernet/via/via-velocity.h
index ff8d7828..c38bbae 100644
--- a/drivers/net/ethernet/via/via-velocity.h
+++ b/drivers/net/ethernet/via/via-velocity.h
@@ -1434,6 +1434,7 @@ struct velocity_opt {
 #define GET_RD_BY_IDX(vptr, idx)   (vptr->rd_ring[idx])
 
 struct velocity_info {
+	struct device *dev;
 	struct pci_dev *pdev;
 	struct net_device *netdev;
 
-- 
1.7.9.5
