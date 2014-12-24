From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/3] enic: check dma_mapping_error
Date: Wed, 24 Dec 2014 15:59:37 +0530
Message-ID: <1419416978-1008-3-git-send-email-_govind@gmx.com>
References: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:51130 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbaLXKah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:30:37 -0500
In-Reply-To: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch checks for pci_dma_mapping_error() after dma mapping the data.
If the dma mapping fails we remove the previously queued frags and return
NETDEV_TX_OK.

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  12 +++
 drivers/net/ethernet/cisco/enic/enic_main.c | 152 +++++++++++++++++-----------
 2 files changed, 106 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 25c4d88..b2ea35a 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -242,6 +242,18 @@ static inline unsigned int enic_msix_notify_intr(struct enic *enic)
 	return enic->rq_count + enic->wq_count + 1;
 }
 
+static inline int enic_dma_map_check(struct enic *enic, dma_addr_t dma_addr)
+{
+	if (unlikely(pci_dma_mapping_error(enic->pdev, dma_addr))) {
+		net_warn_ratelimited("%s: PCI dma mapping failed!\n",
+				     enic->netdev->name);
+
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
 void enic_reset_addr_lists(struct enic *enic);
 int enic_sriov_enabled(struct enic *enic);
 int enic_is_valid_vf(struct enic *enic, int vf);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 868d0f6..95c4804 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -351,80 +351,94 @@ static irqreturn_t enic_isr_msix_notify(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static inline void enic_queue_wq_skb_cont(struct enic *enic,
-	struct vnic_wq *wq, struct sk_buff *skb,
-	unsigned int len_left, int loopback)
+static int enic_queue_wq_skb_cont(struct enic *enic, struct vnic_wq *wq,
+				  struct sk_buff *skb, unsigned int len_left,
+				  int loopback)
 {
 	const skb_frag_t *frag;
+	dma_addr_t dma_addr;
 
 	/* Queue additional data fragments */
 	for (frag = skb_shinfo(skb)->frags; len_left; frag++) {
 		len_left -= skb_frag_size(frag);
-		enic_queue_wq_desc_cont(wq, skb,
-			skb_frag_dma_map(&enic->pdev->dev,
-					 frag, 0, skb_frag_size(frag),
-					 DMA_TO_DEVICE),
-			skb_frag_size(frag),
-			(len_left == 0),	/* EOP? */
-			loopback);
+		dma_addr = skb_frag_dma_map(&enic->pdev->dev, frag, 0,
+					    skb_frag_size(frag),
+					    DMA_TO_DEVICE);
+		if (unlikely(enic_dma_map_check(enic, dma_addr)))
+			return -ENOMEM;
+		enic_queue_wq_desc_cont(wq, skb, dma_addr, skb_frag_size(frag),
+					(len_left == 0),	/* EOP? */
+					loopback);
 	}
+
+	return 0;
 }
 
-static inline void enic_queue_wq_skb_vlan(struct enic *enic,
-	struct vnic_wq *wq, struct sk_buff *skb,
-	int vlan_tag_insert, unsigned int vlan_tag, int loopback)
+static int enic_queue_wq_skb_vlan(struct enic *enic, struct vnic_wq *wq,
+				  struct sk_buff *skb, int vlan_tag_insert,
+				  unsigned int vlan_tag, int loopback)
 {
 	unsigned int head_len = skb_headlen(skb);
 	unsigned int len_left = skb->len - head_len;
 	int eop = (len_left == 0);
+	dma_addr_t dma_addr;
+	int err = 0;
+
+	dma_addr = pci_map_single(enic->pdev, skb->data, head_len,
+				  PCI_DMA_TODEVICE);
+	if (unlikely(enic_dma_map_check(enic, dma_addr)))
+		return -ENOMEM;
 
 	/* Queue the main skb fragment. The fragments are no larger
 	 * than max MTU(9000)+ETH_HDR_LEN(14) bytes, which is less
 	 * than WQ_ENET_MAX_DESC_LEN length. So only one descriptor
 	 * per fragment is queued.
 	 */
-	enic_queue_wq_desc(wq, skb,
-		pci_map_single(enic->pdev, skb->data,
-			head_len, PCI_DMA_TODEVICE),
-		head_len,
-		vlan_tag_insert, vlan_tag,
-		eop, loopback);
+	enic_queue_wq_desc(wq, skb, dma_addr, head_len,	vlan_tag_insert,
+			   vlan_tag, eop, loopback);
 
 	if (!eop)
-		enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
+		err = enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
+
+	return err;
 }
 
-static inline void enic_queue_wq_skb_csum_l4(struct enic *enic,
-	struct vnic_wq *wq, struct sk_buff *skb,
-	int vlan_tag_insert, unsigned int vlan_tag, int loopback)
+static int enic_queue_wq_skb_csum_l4(struct enic *enic, struct vnic_wq *wq,
+				     struct sk_buff *skb, int vlan_tag_insert,
+				     unsigned int vlan_tag, int loopback)
 {
 	unsigned int head_len = skb_headlen(skb);
 	unsigned int len_left = skb->len - head_len;
 	unsigned int hdr_len = skb_checksum_start_offset(skb);
 	unsigned int csum_offset = hdr_len + skb->csum_offset;
 	int eop = (len_left == 0);
+	dma_addr_t dma_addr;
+	int err = 0;
+
+	dma_addr = pci_map_single(enic->pdev, skb->data, head_len,
+				  PCI_DMA_TODEVICE);
+	if (unlikely(enic_dma_map_check(enic, dma_addr)))
+		return -ENOMEM;
 
 	/* Queue the main skb fragment. The fragments are no larger
 	 * than max MTU(9000)+ETH_HDR_LEN(14) bytes, which is less
 	 * than WQ_ENET_MAX_DESC_LEN length. So only one descriptor
 	 * per fragment is queued.
 	 */
-	enic_queue_wq_desc_csum_l4(wq, skb,
-		pci_map_single(enic->pdev, skb->data,
-			head_len, PCI_DMA_TODEVICE),
-		head_len,
-		csum_offset,
-		hdr_len,
-		vlan_tag_insert, vlan_tag,
-		eop, loopback);
+	enic_queue_wq_desc_csum_l4(wq, skb, dma_addr, head_len,	csum_offset,
+				   hdr_len, vlan_tag_insert, vlan_tag, eop,
+				   loopback);
 
 	if (!eop)
-		enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
+		err = enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
+
+	return err;
 }
 
-static inline void enic_queue_wq_skb_tso(struct enic *enic,
-	struct vnic_wq *wq, struct sk_buff *skb, unsigned int mss,
-	int vlan_tag_insert, unsigned int vlan_tag, int loopback)
+static int enic_queue_wq_skb_tso(struct enic *enic, struct vnic_wq *wq,
+				 struct sk_buff *skb, unsigned int mss,
+				 int vlan_tag_insert, unsigned int vlan_tag,
+				 int loopback)
 {
 	unsigned int frag_len_left = skb_headlen(skb);
 	unsigned int len_left = skb->len - frag_len_left;
@@ -454,20 +468,19 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 	 */
 	while (frag_len_left) {
 		len = min(frag_len_left, (unsigned int)WQ_ENET_MAX_DESC_LEN);
-		dma_addr = pci_map_single(enic->pdev, skb->data + offset,
-				len, PCI_DMA_TODEVICE);
-		enic_queue_wq_desc_tso(wq, skb,
-			dma_addr,
-			len,
-			mss, hdr_len,
-			vlan_tag_insert, vlan_tag,
-			eop && (len == frag_len_left), loopback);
+		dma_addr = pci_map_single(enic->pdev, skb->data + offset, len,
+					  PCI_DMA_TODEVICE);
+		if (unlikely(enic_dma_map_check(enic, dma_addr)))
+			return -ENOMEM;
+		enic_queue_wq_desc_tso(wq, skb, dma_addr, len, mss, hdr_len,
+				       vlan_tag_insert, vlan_tag,
+				       eop && (len == frag_len_left), loopback);
 		frag_len_left -= len;
 		offset += len;
 	}
 
 	if (eop)
-		return;
+		return 0;
 
 	/* Queue WQ_ENET_MAX_DESC_LEN length descriptors
 	 * for additional data fragments
@@ -483,16 +496,18 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 			dma_addr = skb_frag_dma_map(&enic->pdev->dev, frag,
 						    offset, len,
 						    DMA_TO_DEVICE);
-			enic_queue_wq_desc_cont(wq, skb,
-				dma_addr,
-				len,
-				(len_left == 0) &&
-				(len == frag_len_left),		/* EOP? */
-				loopback);
+			if (unlikely(enic_dma_map_check(enic, dma_addr)))
+				return -ENOMEM;
+			enic_queue_wq_desc_cont(wq, skb, dma_addr, len,
+						(len_left == 0) &&
+						 (len == frag_len_left),/*EOP*/
+						loopback);
 			frag_len_left -= len;
 			offset += len;
 		}
 	}
+
+	return 0;
 }
 
 static inline void enic_queue_wq_skb(struct enic *enic,
@@ -502,6 +517,7 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 	unsigned int vlan_tag = 0;
 	int vlan_tag_insert = 0;
 	int loopback = 0;
+	int err;
 
 	if (vlan_tx_tag_present(skb)) {
 		/* VLAN tag from trunking driver */
@@ -513,14 +529,30 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 	}
 
 	if (mss)
-		enic_queue_wq_skb_tso(enic, wq, skb, mss,
-			vlan_tag_insert, vlan_tag, loopback);
+		err = enic_queue_wq_skb_tso(enic, wq, skb, mss,
+					    vlan_tag_insert, vlan_tag,
+					    loopback);
 	else if	(skb->ip_summed == CHECKSUM_PARTIAL)
-		enic_queue_wq_skb_csum_l4(enic, wq, skb,
-			vlan_tag_insert, vlan_tag, loopback);
+		err = enic_queue_wq_skb_csum_l4(enic, wq, skb, vlan_tag_insert,
+						vlan_tag, loopback);
 	else
-		enic_queue_wq_skb_vlan(enic, wq, skb,
-			vlan_tag_insert, vlan_tag, loopback);
+		err = enic_queue_wq_skb_vlan(enic, wq, skb, vlan_tag_insert,
+					     vlan_tag, loopback);
+	if (unlikely(err)) {
+		struct vnic_wq_buf *buf;
+
+		buf = wq->to_use->prev;
+		/* while not EOP of previous pkt && queue not empty.
+		 * For all non EOP bufs, os_buf is NULL.
+		 */
+		while (!buf->os_buf && (buf->next != wq->to_clean)) {
+			enic_free_wq_buf(wq, buf);
+			wq->ring.desc_avail++;
+			buf = buf->prev;
+		}
+		wq->to_use = buf->next;
+		dev_kfree_skb(skb);
+	}
 }
 
 /* netif_tx_lock held, process context with BHs disabled, or BH */
@@ -950,8 +982,12 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	if (!skb)
 		return -ENOMEM;
 
-	dma_addr = pci_map_single(enic->pdev, skb->data,
-		len, PCI_DMA_FROMDEVICE);
+	dma_addr = pci_map_single(enic->pdev, skb->data, len,
+				  PCI_DMA_FROMDEVICE);
+	if (unlikely(enic_dma_map_check(enic, dma_addr))) {
+		dev_kfree_skb(skb);
+		return -ENOMEM;
+	}
 
 	enic_queue_rq_desc(rq, skb, os_buf_index,
 		dma_addr, len);
-- 
2.2.1
