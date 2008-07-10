From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/6] via-velocity: give a structure to the rx / tx fields
Date: Fri, 11 Jul 2008 00:06:34 +0200
Message-ID: <20080710220634.GF29764@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	=?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33954 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752627AbYGJWHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:07:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separated struct allow wholesale copy during MTU changes.

It should help people fix the bugs in my code :o)

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |  172 ++++++++++++++++++++++----------------------
 drivers/net/via-velocity.h |   50 +++++++------
 2 files changed, 113 insertions(+), 109 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 52d4a5b..66b32b5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -677,16 +677,16 @@ static void velocity_rx_reset(struct velocity_info *vptr)
 	struct mac_regs __iomem * regs = vptr->mac_regs;
 	int i;
 
-	vptr->rd_dirty = vptr->rd_filled = vptr->rd_curr = 0;
+	vptr->rx.dirty = vptr->rx.filled = vptr->rx.curr = 0;
 
 	/*
 	 *	Init state, all RD entries belong to the NIC
 	 */
 	for (i = 0; i < vptr->options.numrx; ++i)
-		vptr->rd_ring[i].rdesc0.len |= OWNED_BY_NIC;
+		vptr->rx.ring[i].rdesc0.len |= OWNED_BY_NIC;
 
 	writew(vptr->options.numrx, &regs->RBRDU);
-	writel(vptr->rd_pool_dma, &regs->RDBaseLo);
+	writel(vptr->rx.pool_dma, &regs->RDBaseLo);
 	writew(0, &regs->RDIdx);
 	writew(vptr->options.numrx - 1, &regs->RDCSize);
 }
@@ -779,15 +779,15 @@ static void velocity_init_registers(struct velocity_info *vptr,
 
 		vptr->int_mask = INT_MASK_DEF;
 
-		writel(vptr->rd_pool_dma, &regs->RDBaseLo);
+		writel(vptr->rx.pool_dma, &regs->RDBaseLo);
 		writew(vptr->options.numrx - 1, &regs->RDCSize);
 		mac_rx_queue_run(regs);
 		mac_rx_queue_wake(regs);
 
 		writew(vptr->options.numtx - 1, &regs->TDCSize);
 
-		for (i = 0; i < vptr->num_txq; i++) {
-			writel(vptr->td_pool_dma[i], &regs->TDBaseLo[i]);
+		for (i = 0; i < vptr->tx.numq; i++) {
+			writel(vptr->tx.pool_dma[i], &regs->TDBaseLo[i]);
 			mac_tx_queue_run(regs, i);
 		}
 
@@ -1047,7 +1047,7 @@ static void __devinit velocity_init_info(struct pci_dev *pdev,
 
 	vptr->pdev = pdev;
 	vptr->chip_id = info->chip_id;
-	vptr->num_txq = info->txqueue;
+	vptr->tx.numq = info->txqueue;
 	vptr->multicast_limit = MCAM_SIZE;
 	spin_lock_init(&vptr->lock);
 	INIT_LIST_HEAD(&vptr->list);
@@ -1116,7 +1116,7 @@ static int velocity_init_rings(struct velocity_info *vptr)
 	 * pci_alloc_consistent() fulfills the requirement for 64 bytes
 	 * alignment
 	 */
-	pool = pci_alloc_consistent(pdev, tx_ring_size * vptr->num_txq +
+	pool = pci_alloc_consistent(pdev, tx_ring_size * vptr->tx.numq +
 				    rx_ring_size, &pool_dma);
 	if (!pool) {
 		dev_err(&pdev->dev, "%s : DMA memory allocation failed.\n",
@@ -1124,15 +1124,15 @@ static int velocity_init_rings(struct velocity_info *vptr)
 		return -ENOMEM;
 	}
 
-	vptr->rd_ring = pool;
-	vptr->rd_pool_dma = pool_dma;
+	vptr->rx.ring = pool;
+	vptr->rx.pool_dma = pool_dma;
 
 	pool += rx_ring_size;
 	pool_dma += rx_ring_size;
 
-	for (i = 0; i < vptr->num_txq; i++) {
-		vptr->td_rings[i] = pool;
-		vptr->td_pool_dma[i] = pool_dma;
+	for (i = 0; i < vptr->tx.numq; i++) {
+		vptr->tx.rings[i] = pool;
+		vptr->tx.pool_dma[i] = pool_dma;
 		pool += tx_ring_size;
 		pool_dma += tx_ring_size;
 	}
@@ -1150,9 +1150,9 @@ static int velocity_init_rings(struct velocity_info *vptr)
 static void velocity_free_rings(struct velocity_info *vptr)
 {
 	const int size = vptr->options.numrx * sizeof(struct rx_desc) +
-		vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
+		vptr->options.numtx * sizeof(struct tx_desc) * vptr->tx.numq;
 
-	pci_free_consistent(vptr->pdev, size, vptr->rd_ring, vptr->rd_pool_dma);
+	pci_free_consistent(vptr->pdev, size, vptr->rx.ring, vptr->rx.pool_dma);
 }
 
 static void velocity_give_many_rx_descs(struct velocity_info *vptr)
@@ -1164,44 +1164,44 @@ static void velocity_give_many_rx_descs(struct velocity_info *vptr)
 	 * RD number must be equal to 4X per hardware spec
 	 * (programming guide rev 1.20, p.13)
 	 */
-	if (vptr->rd_filled < 4)
+	if (vptr->rx.filled < 4)
 		return;
 
 	wmb();
 
-	unusable = vptr->rd_filled & 0x0003;
-	dirty = vptr->rd_dirty - unusable;
-	for (avail = vptr->rd_filled & 0xfffc; avail; avail--) {
+	unusable = vptr->rx.filled & 0x0003;
+	dirty = vptr->rx.dirty - unusable;
+	for (avail = vptr->rx.filled & 0xfffc; avail; avail--) {
 		dirty = (dirty > 0) ? dirty - 1 : vptr->options.numrx - 1;
-		vptr->rd_ring[dirty].rdesc0.len |= OWNED_BY_NIC;
+		vptr->rx.ring[dirty].rdesc0.len |= OWNED_BY_NIC;
 	}
 
-	writew(vptr->rd_filled & 0xfffc, &regs->RBRDU);
-	vptr->rd_filled = unusable;
+	writew(vptr->rx.filled & 0xfffc, &regs->RBRDU);
+	vptr->rx.filled = unusable;
 }
 
 static int velocity_rx_refill(struct velocity_info *vptr)
 {
-	int dirty = vptr->rd_dirty, done = 0;
+	int dirty = vptr->rx.dirty, done = 0;
 
 	do {
-		struct rx_desc *rd = vptr->rd_ring + dirty;
+		struct rx_desc *rd = vptr->rx.ring + dirty;
 
 		/* Fine for an all zero Rx desc at init time as well */
 		if (rd->rdesc0.len & OWNED_BY_NIC)
 			break;
 
-		if (!vptr->rd_info[dirty].skb) {
+		if (!vptr->rx.info[dirty].skb) {
 			if (velocity_alloc_rx_buf(vptr, dirty) < 0)
 				break;
 		}
 		done++;
 		dirty = (dirty < vptr->options.numrx - 1) ? dirty + 1 : 0;
-	} while (dirty != vptr->rd_curr);
+	} while (dirty != vptr->rx.curr);
 
 	if (done) {
-		vptr->rd_dirty = dirty;
-		vptr->rd_filled += done;
+		vptr->rx.dirty = dirty;
+		vptr->rx.filled += done;
 	}
 
 	return done;
@@ -1209,7 +1209,7 @@ static int velocity_rx_refill(struct velocity_info *vptr)
 
 static void velocity_set_rxbufsize(struct velocity_info *vptr, int mtu)
 {
-	vptr->rx_buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
+	vptr->rx.buf_sz = (mtu <= ETH_DATA_LEN) ? PKT_BUF_SZ : mtu + 32;
 }
 
 /**
@@ -1224,12 +1224,12 @@ static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
 	int ret = -ENOMEM;
 
-	vptr->rd_info = kcalloc(vptr->options.numrx,
+	vptr->rx.info = kcalloc(vptr->options.numrx,
 				sizeof(struct velocity_rd_info), GFP_KERNEL);
-	if (!vptr->rd_info)
+	if (!vptr->rx.info)
 		goto out;
 
-	vptr->rd_filled = vptr->rd_dirty = vptr->rd_curr = 0;
+	vptr->rx.filled = vptr->rx.dirty = vptr->rx.curr = 0;
 
 	if (velocity_rx_refill(vptr) != vptr->options.numrx) {
 		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_ERR
@@ -1255,18 +1255,18 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 {
 	int i;
 
-	if (vptr->rd_info == NULL)
+	if (vptr->rx.info == NULL)
 		return;
 
 	for (i = 0; i < vptr->options.numrx; i++) {
-		struct velocity_rd_info *rd_info = &(vptr->rd_info[i]);
-		struct rx_desc *rd = vptr->rd_ring + i;
+		struct velocity_rd_info *rd_info = &(vptr->rx.info[i]);
+		struct rx_desc *rd = vptr->rx.ring + i;
 
 		memset(rd, 0, sizeof(*rd));
 
 		if (!rd_info->skb)
 			continue;
-		pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx_buf_sz,
+		pci_unmap_single(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
 				 PCI_DMA_FROMDEVICE);
 		rd_info->skb_dma = (dma_addr_t) NULL;
 
@@ -1274,8 +1274,8 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 		rd_info->skb = NULL;
 	}
 
-	kfree(vptr->rd_info);
-	vptr->rd_info = NULL;
+	kfree(vptr->rx.info);
+	vptr->rx.info = NULL;
 }
 
 /**
@@ -1293,19 +1293,19 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 	unsigned int j;
 
 	/* Init the TD ring entries */
-	for (j = 0; j < vptr->num_txq; j++) {
-		curr = vptr->td_pool_dma[j];
+	for (j = 0; j < vptr->tx.numq; j++) {
+		curr = vptr->tx.pool_dma[j];
 
-		vptr->td_infos[j] = kcalloc(vptr->options.numtx,
+		vptr->tx.infos[j] = kcalloc(vptr->options.numtx,
 					    sizeof(struct velocity_td_info),
 					    GFP_KERNEL);
-		if (!vptr->td_infos[j])	{
+		if (!vptr->tx.infos[j])	{
 			while(--j >= 0)
-				kfree(vptr->td_infos[j]);
+				kfree(vptr->tx.infos[j]);
 			return -ENOMEM;
 		}
 
-		vptr->td_tail[j] = vptr->td_curr[j] = vptr->td_used[j] = 0;
+		vptr->tx.tail[j] = vptr->tx.curr[j] = vptr->tx.used[j] = 0;
 	}
 	return 0;
 }
@@ -1317,7 +1317,7 @@ static int velocity_init_td_ring(struct velocity_info *vptr)
 static void velocity_free_td_ring_entry(struct velocity_info *vptr,
 							 int q, int n)
 {
-	struct velocity_td_info * td_info = &(vptr->td_infos[q][n]);
+	struct velocity_td_info * td_info = &(vptr->tx.infos[q][n]);
 	int i;
 
 	if (td_info == NULL)
@@ -1349,15 +1349,15 @@ static void velocity_free_td_ring(struct velocity_info *vptr)
 {
 	int i, j;
 
-	for (j = 0; j < vptr->num_txq; j++) {
-		if (vptr->td_infos[j] == NULL)
+	for (j = 0; j < vptr->tx.numq; j++) {
+		if (vptr->tx.infos[j] == NULL)
 			continue;
 		for (i = 0; i < vptr->options.numtx; i++) {
 			velocity_free_td_ring_entry(vptr, j, i);
 
 		}
-		kfree(vptr->td_infos[j]);
-		vptr->td_infos[j] = NULL;
+		kfree(vptr->tx.infos[j]);
+		vptr->tx.infos[j] = NULL;
 	}
 }
 
@@ -1374,13 +1374,13 @@ static void velocity_free_td_ring(struct velocity_info *vptr)
 static int velocity_rx_srv(struct velocity_info *vptr, int status)
 {
 	struct net_device_stats *stats = &vptr->stats;
-	int rd_curr = vptr->rd_curr;
+	int rd_curr = vptr->rx.curr;
 	int works = 0;
 
 	do {
-		struct rx_desc *rd = vptr->rd_ring + rd_curr;
+		struct rx_desc *rd = vptr->rx.ring + rd_curr;
 
-		if (!vptr->rd_info[rd_curr].skb)
+		if (!vptr->rx.info[rd_curr].skb)
 			break;
 
 		if (rd->rdesc0.len & OWNED_BY_NIC)
@@ -1412,7 +1412,7 @@ static int velocity_rx_srv(struct velocity_info *vptr, int status)
 			rd_curr = 0;
 	} while (++works <= 15);
 
-	vptr->rd_curr = rd_curr;
+	vptr->rx.curr = rd_curr;
 
 	if ((works > 0) && (velocity_rx_refill(vptr) > 0))
 		velocity_give_many_rx_descs(vptr);
@@ -1520,8 +1520,8 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 {
 	void (*pci_action)(struct pci_dev *, dma_addr_t, size_t, int);
 	struct net_device_stats *stats = &vptr->stats;
-	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
-	struct rx_desc *rd = &(vptr->rd_ring[idx]);
+	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
+	struct rx_desc *rd = &(vptr->rx.ring[idx]);
 	int pkt_len = le16_to_cpu(rd->rdesc0.len) & 0x3fff;
 	struct sk_buff *skb;
 
@@ -1537,7 +1537,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	skb = rd_info->skb;
 
 	pci_dma_sync_single_for_cpu(vptr->pdev, rd_info->skb_dma,
-				    vptr->rx_buf_sz, PCI_DMA_FROMDEVICE);
+				    vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
 
 	/*
 	 *	Drop frame not meeting IEEE 802.3
@@ -1560,7 +1560,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 		rd_info->skb = NULL;
 	}
 
-	pci_action(vptr->pdev, rd_info->skb_dma, vptr->rx_buf_sz,
+	pci_action(vptr->pdev, rd_info->skb_dma, vptr->rx.buf_sz,
 		   PCI_DMA_FROMDEVICE);
 
 	skb_put(skb, pkt_len - 4);
@@ -1590,10 +1590,10 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 
 static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 {
-	struct rx_desc *rd = &(vptr->rd_ring[idx]);
-	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
+	struct rx_desc *rd = &(vptr->rx.ring[idx]);
+	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 
-	rd_info->skb = dev_alloc_skb(vptr->rx_buf_sz + 64);
+	rd_info->skb = dev_alloc_skb(vptr->rx.buf_sz + 64);
 	if (rd_info->skb == NULL)
 		return -ENOMEM;
 
@@ -1603,14 +1603,14 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	 */
 	skb_reserve(rd_info->skb, (unsigned long) rd_info->skb->data & 63);
 	rd_info->skb->dev = vptr->dev;
-	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data, vptr->rx_buf_sz, PCI_DMA_FROMDEVICE);
+	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data, vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);
 
 	/*
 	 *	Fill in the descriptor to match
- 	 */
+	 */
 
 	*((u32 *) & (rd->rdesc0)) = 0;
-	rd->size = cpu_to_le16(vptr->rx_buf_sz) | RX_INTEN;
+	rd->size = cpu_to_le16(vptr->rx.buf_sz) | RX_INTEN;
 	rd->pa_low = cpu_to_le32(rd_info->skb_dma);
 	rd->pa_high = 0;
 	return 0;
@@ -1636,15 +1636,15 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 	struct velocity_td_info *tdinfo;
 	struct net_device_stats *stats = &vptr->stats;
 
-	for (qnum = 0; qnum < vptr->num_txq; qnum++) {
-		for (idx = vptr->td_tail[qnum]; vptr->td_used[qnum] > 0;
+	for (qnum = 0; qnum < vptr->tx.numq; qnum++) {
+		for (idx = vptr->tx.tail[qnum]; vptr->tx.used[qnum] > 0;
 			idx = (idx + 1) % vptr->options.numtx) {
 
 			/*
 			 *	Get Tx Descriptor
 			 */
-			td = &(vptr->td_rings[qnum][idx]);
-			tdinfo = &(vptr->td_infos[qnum][idx]);
+			td = &(vptr->tx.rings[qnum][idx]);
+			tdinfo = &(vptr->tx.infos[qnum][idx]);
 
 			if (td->tdesc0.len & OWNED_BY_NIC)
 				break;
@@ -1668,9 +1668,9 @@ static int velocity_tx_srv(struct velocity_info *vptr, u32 status)
 				stats->tx_bytes += tdinfo->skb->len;
 			}
 			velocity_free_tx_buf(vptr, tdinfo);
-			vptr->td_used[qnum]--;
+			vptr->tx.used[qnum]--;
 		}
-		vptr->td_tail[qnum] = idx;
+		vptr->tx.tail[qnum] = idx;
 
 		if (AVAIL_TD(vptr, qnum) < 1) {
 			full = 1;
@@ -2067,9 +2067,9 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&vptr->lock, flags);
 
-	index = vptr->td_curr[qnum];
-	td_ptr = &(vptr->td_rings[qnum][index]);
-	tdinfo = &(vptr->td_infos[qnum][index]);
+	index = vptr->tx.curr[qnum];
+	td_ptr = &(vptr->tx.rings[qnum][index]);
+	tdinfo = &(vptr->tx.infos[qnum][index]);
 
 	td_ptr->tdesc1.TCR = TCR0_TIC;
 	td_ptr->td_buf[0].size &= ~TD_QUEUE;
@@ -2082,9 +2082,9 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_copy_from_linear_data(skb, tdinfo->buf, skb->len);
 			tdinfo->skb_dma[0] = tdinfo->buf_dma;
 			td_ptr->tdesc0.len = len;
-			td_ptr->td_buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
-			td_ptr->td_buf[0].pa_high = 0;
-			td_ptr->td_buf[0].size = len;	/* queue is 0 anyway */
+			td_ptr->tx.buf[0].pa_low = cpu_to_le32(tdinfo->skb_dma[0]);
+			td_ptr->tx.buf[0].pa_high = 0;
+			td_ptr->tx.buf[0].size = len;	/* queue is 0 anyway */
 			tdinfo->nskb_dma = 1;
 		} else {
 			int i = 0;
@@ -2095,9 +2095,9 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 			td_ptr->tdesc0.len = len;
 
 			/* FIXME: support 48bit DMA later */
-			td_ptr->td_buf[i].pa_low = cpu_to_le32(tdinfo->skb_dma);
-			td_ptr->td_buf[i].pa_high = 0;
-			td_ptr->td_buf[i].size = cpu_to_le16(skb_headlen(skb));
+			td_ptr->tx.buf[i].pa_low = cpu_to_le32(tdinfo->skb_dma);
+			td_ptr->tx.buf[i].pa_high = 0;
+			td_ptr->tx.buf[i].size = cpu_to_le16(skb_headlen(skb));
 
 			for (i = 0; i < nfrags; i++) {
 				skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -2105,9 +2105,9 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 
 				tdinfo->skb_dma[i + 1] = pci_map_single(vptr->pdev, addr, frag->size, PCI_DMA_TODEVICE);
 
-				td_ptr->td_buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
-				td_ptr->td_buf[i + 1].pa_high = 0;
-				td_ptr->td_buf[i + 1].size = cpu_to_le16(frag->size);
+				td_ptr->tx.buf[i + 1].pa_low = cpu_to_le32(tdinfo->skb_dma[i + 1]);
+				td_ptr->tx.buf[i + 1].pa_high = 0;
+				td_ptr->tx.buf[i + 1].size = cpu_to_le16(frag->size);
 			}
 			tdinfo->nskb_dma = i - 1;
 		}
@@ -2153,13 +2153,13 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (prev < 0)
 			prev = vptr->options.numtx - 1;
 		td_ptr->tdesc0.len |= OWNED_BY_NIC;
-		vptr->td_used[qnum]++;
-		vptr->td_curr[qnum] = (index + 1) % vptr->options.numtx;
+		vptr->tx.used[qnum]++;
+		vptr->tx.curr[qnum] = (index + 1) % vptr->options.numtx;
 
 		if (AVAIL_TD(vptr, qnum) < 1)
 			netif_stop_queue(dev);
 
-		td_ptr = &(vptr->td_rings[qnum][prev]);
+		td_ptr = &(vptr->tx.rings[qnum][prev]);
 		td_ptr->td_buf[0].size |= TD_QUEUE;
 		mac_tx_queue_wake(vptr->mac_regs, qnum);
 	}
@@ -3416,8 +3416,8 @@ static int velocity_resume(struct pci_dev *pdev)
 
 	velocity_tx_srv(vptr, 0);
 
-	for (i = 0; i < vptr->num_txq; i++) {
-		if (vptr->td_used[i]) {
+	for (i = 0; i < vptr->tx.numq; i++) {
+		if (vptr->tx.used[i]) {
 			mac_tx_queue_wake(vptr->mac_regs, i);
 		}
 	}
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 8644614..1b95b04 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1494,6 +1494,10 @@ struct velocity_opt {
 	u32 flags;
 };
 
+#define AVAIL_TD(p,q)   ((p)->options.numtx-((p)->tx.used[(q)]))
+
+#define GET_RD_BY_IDX(vptr, idx)   (vptr->rd_ring[idx])
+
 struct velocity_info {
 	struct list_head list;
 
@@ -1501,9 +1505,6 @@ struct velocity_info {
 	struct net_device *dev;
 	struct net_device_stats stats;
 
-	dma_addr_t rd_pool_dma;
-	dma_addr_t td_pool_dma[TX_QUEUE_NO];
-
 	struct vlan_group    *vlgrp;
 	u8 ip_addr[4];
 	enum chip_type chip_id;
@@ -1512,25 +1513,29 @@ struct velocity_info {
 	unsigned long memaddr;
 	unsigned long ioaddr;
 
-	u8 rev_id;
-
-#define AVAIL_TD(p,q)   ((p)->options.numtx-((p)->td_used[(q)]))
+	struct tx_info {
+		int numq;
+
+		/* FIXME: the locality of the data seems rather poor. */
+		int used[TX_QUEUE_NO];
+		int curr[TX_QUEUE_NO];
+		int tail[TX_QUEUE_NO];
+		struct tx_desc *rings[TX_QUEUE_NO];
+		struct velocity_td_info *infos[TX_QUEUE_NO];
+		dma_addr_t pool_dma[TX_QUEUE_NO];
+	} tx;
+
+	struct rx_info {
+		int buf_sz;
+
+		int dirty;
+		int curr;
+		u32 filled;
+		struct rx_desc *ring;
+		struct velocity_rd_info *info;	/* It's an array */
+		dma_addr_t pool_dma;
+	} rx;
 
-	int num_txq;
-
-	volatile int td_used[TX_QUEUE_NO];
-	int td_curr[TX_QUEUE_NO];
-	int td_tail[TX_QUEUE_NO];
-	struct tx_desc *td_rings[TX_QUEUE_NO];
-	struct velocity_td_info *td_infos[TX_QUEUE_NO];
-
-	int rd_curr;
-	int rd_dirty;
-	u32 rd_filled;
-	struct rx_desc *rd_ring;
-	struct velocity_rd_info *rd_info;	/* It's an array */
-
-#define GET_RD_BY_IDX(vptr, idx)   (vptr->rd_ring[idx])
 	u32 mib_counter[MAX_HW_MIB_COUNTER];
 	struct velocity_opt options;
 
@@ -1538,7 +1543,6 @@ struct velocity_info {
 
 	u32 flags;
 
-	int rx_buf_sz;
 	u32 mii_status;
 	u32 phy_id;
 	int multicast_limit;
@@ -1554,8 +1558,8 @@ struct velocity_info {
 	struct velocity_context context;
 
 	u32 ticks;
-	u32 rx_bytes;
 
+	u8 rev_id;
 };
 
 /**
-- 
1.5.3.3

