From: sunil.kovvuri@gmail.com
Subject: [PATCH 1/4] net: thunderx: Fix IOMMU translation faults
Date: Fri,  3 Mar 2017 16:17:47 +0530
Message-ID: <1488538070-12549-2-git-send-email-sunil.kovvuri@gmail.com>
References: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

ACPI support has been added to ARM IOMMU driver in 4.10
kernel and that has resulted in VNIC interfaces throwing
translation faults when kernel is booted with ACPI as
driver was not using DMA API.

On T88 HW takes care of data coherency when performing
DMA operations hence in non-iommu case using DMA API
simply wastes CPU cycles. This patch fixes translation
faults issue by doing a buffer dma_map/dma_unmap when
the corresponding PCI device is attached to a IOMMU i.e
when iommu_domain is set.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |   1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  12 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 187 ++++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   2 +
 4 files changed, 174 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index e739c71..2269ff5 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -269,6 +269,7 @@ struct nicvf {
 #define	MAX_QUEUES_PER_QSET			8
 	struct queue_set	*qs;
 	struct nicvf_cq_poll	*napi[8];
+	void			*iommu_domain;
 	u8			vf_id;
 	u8			sqs_id;
 	bool                    sqs_mode;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 6feaa24..8d60c3b 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -16,6 +16,7 @@
 #include <linux/log2.h>
 #include <linux/prefetch.h>
 #include <linux/irq.h>
+#include <linux/iommu.h>
 
 #include "nic_reg.h"
 #include "nic.h"
@@ -525,7 +526,12 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 			/* Get actual TSO descriptors and free them */
 			tso_sqe =
 			 (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, hdr->rsvd2);
+			nicvf_unmap_sndq_buffers(nic, sq, hdr->rsvd2,
+						 tso_sqe->subdesc_cnt);
 			nicvf_put_sq_desc(sq, tso_sqe->subdesc_cnt + 1);
+		} else {
+			nicvf_unmap_sndq_buffers(nic, sq, cqe_tx->sqe_ptr,
+						 hdr->subdesc_cnt);
 		}
 		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 		prefetch(skb);
@@ -576,6 +582,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 {
 	struct sk_buff *skb;
 	struct nicvf *nic = netdev_priv(netdev);
+	struct nicvf *snic = nic;
 	int err = 0;
 	int rq_idx;
 
@@ -592,7 +599,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 	if (err && !cqe_rx->rb_cnt)
 		return;
 
-	skb = nicvf_get_rcv_skb(nic, cqe_rx);
+	skb = nicvf_get_rcv_skb(snic, cqe_rx);
 	if (!skb) {
 		netdev_dbg(nic->netdev, "Packet not received\n");
 		return;
@@ -1643,6 +1650,9 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!pass1_silicon(nic->pdev))
 		nic->hw_tso = true;
 
+	/* Check if we are attached to IOMMU */
+	nic->iommu_domain = iommu_get_domain_for_dev(dev);
+
 	pci_read_config_word(nic->pdev, PCI_SUBSYSTEM_ID, &sdevid);
 	if (sdevid == 0xA134)
 		nic->t88 = true;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index ac0390b..ee3aa16 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -10,6 +10,7 @@
 #include <linux/netdevice.h>
 #include <linux/ip.h>
 #include <linux/etherdevice.h>
+#include <linux/iommu.h>
 #include <net/ip.h>
 #include <net/tso.h>
 
@@ -18,6 +19,49 @@
 #include "q_struct.h"
 #include "nicvf_queues.h"
 
+#define NICVF_PAGE_ORDER ((PAGE_SIZE <= 4096) ?  PAGE_ALLOC_COSTLY_ORDER : 0)
+
+static inline u64 nicvf_iova_to_phys(struct nicvf *nic, dma_addr_t dma_addr)
+{
+	/* Tranlation is installed only when IOMMU is present */
+	if (nic->iommu_domain)
+		return iommu_iova_to_phys(nic->iommu_domain, dma_addr);
+	return dma_addr;
+}
+
+static inline u64 nicvf_dma_map(struct nicvf *nic, struct page *page,
+				int offset, int len, int dir)
+{
+	/* Since HW ensures data coherency, calling DMA apis when there
+	 * is no IOMMU would only result in wasting CPU cycles.
+	 */
+	if (!nic->iommu_domain)
+		return virt_to_phys(page_address(page) + offset);
+
+	/* CPU sync not required */
+	return (u64)dma_map_page_attrs(&nic->pdev->dev, page,
+				       offset, len, dir,
+				       DMA_ATTR_SKIP_CPU_SYNC);
+}
+
+static inline void nicvf_dma_unmap(struct nicvf *nic, dma_addr_t dma_addr,
+				   int len, int dir)
+{
+	if (!nic->iommu_domain)
+		return;
+
+	/* HW will ensure data coherency, CPU sync not required */
+	dma_unmap_page_attrs(&nic->pdev->dev, dma_addr, len,
+			     dir, DMA_ATTR_SKIP_CPU_SYNC);
+}
+
+static inline int nicvf_dma_map_error(struct nicvf *nic, dma_addr_t dma_addr)
+{
+	if (!nic->iommu_domain)
+		return 0;
+	return dma_mapping_error(&nic->pdev->dev, dma_addr);
+}
+
 static void nicvf_get_page(struct nicvf *nic)
 {
 	if (!nic->rb_pageref || !nic->rb_page)
@@ -87,7 +131,7 @@ static void nicvf_free_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem)
 static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
 					 u32 buf_len, u64 **rbuf)
 {
-	int order = (PAGE_SIZE <= 4096) ?  PAGE_ALLOC_COSTLY_ORDER : 0;
+	int order = NICVF_PAGE_ORDER;
 
 	/* Check if request can be accomodated in previous allocated page */
 	if (nic->rb_page &&
@@ -112,7 +156,14 @@ static inline int nicvf_alloc_rcv_buffer(struct nicvf *nic, gfp_t gfp,
 	}
 
 ret:
-	*rbuf = (u64 *)((u64)page_address(nic->rb_page) + nic->rb_page_offset);
+	*rbuf = (u64 *)nicvf_dma_map(nic, nic->rb_page, nic->rb_page_offset,
+				     buf_len, DMA_FROM_DEVICE);
+	if (nicvf_dma_map_error(nic, (dma_addr_t)*rbuf)) {
+		if (!nic->rb_page_offset)
+			__free_pages(nic->rb_page, order);
+		nic->rb_page = NULL;
+		return -ENOMEM;
+	}
 	nic->rb_page_offset += buf_len;
 
 	return 0;
@@ -158,16 +209,21 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 	rbdr->dma_size = buf_size;
 	rbdr->enable = true;
 	rbdr->thresh = RBDR_THRESH;
+	rbdr->head = 0;
+	rbdr->tail = 0;
 
 	nic->rb_page = NULL;
 	for (idx = 0; idx < ring_len; idx++) {
 		err = nicvf_alloc_rcv_buffer(nic, GFP_KERNEL, RCV_FRAG_LEN,
 					     &rbuf);
-		if (err)
+		if (err) {
+			/* To free already allocated and mapped ones */
+			rbdr->tail = idx - 1;
 			return err;
+		}
 
 		desc = GET_RBDR_DESC(rbdr, idx);
-		desc->buf_addr = virt_to_phys(rbuf) >> NICVF_RCV_BUF_ALIGN;
+		desc->buf_addr = (u64)rbuf >> NICVF_RCV_BUF_ALIGN;
 	}
 
 	nicvf_get_page(nic);
@@ -179,7 +235,7 @@ static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
 static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr)
 {
 	int head, tail;
-	u64 buf_addr;
+	u64 buf_addr, phys_addr;
 	struct rbdr_entry_t *desc;
 
 	if (!rbdr)
@@ -192,18 +248,26 @@ static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr)
 	head = rbdr->head;
 	tail = rbdr->tail;
 
-	/* Free SKBs */
+	/* Release page references */
 	while (head != tail) {
 		desc = GET_RBDR_DESC(rbdr, head);
-		buf_addr = desc->buf_addr << NICVF_RCV_BUF_ALIGN;
-		put_page(virt_to_page(phys_to_virt(buf_addr)));
+		buf_addr = ((u64)desc->buf_addr) << NICVF_RCV_BUF_ALIGN;
+		phys_addr = nicvf_iova_to_phys(nic, buf_addr);
+		nicvf_dma_unmap(nic, buf_addr,
+				RCV_FRAG_LEN, DMA_FROM_DEVICE);
+		if (phys_addr)
+			put_page(virt_to_page(phys_to_virt(phys_addr)));
 		head++;
 		head &= (rbdr->dmem.q_len - 1);
 	}
-	/* Free SKB of tail desc */
+	/* Release buffer of tail desc */
 	desc = GET_RBDR_DESC(rbdr, tail);
-	buf_addr = desc->buf_addr << NICVF_RCV_BUF_ALIGN;
-	put_page(virt_to_page(phys_to_virt(buf_addr)));
+	buf_addr = ((u64)desc->buf_addr) << NICVF_RCV_BUF_ALIGN;
+	phys_addr = nicvf_iova_to_phys(nic, buf_addr);
+	nicvf_dma_unmap(nic, buf_addr,
+			RCV_FRAG_LEN, DMA_FROM_DEVICE);
+	if (phys_addr)
+		put_page(virt_to_page(phys_to_virt(phys_addr)));
 
 	/* Free RBDR ring */
 	nicvf_free_q_desc_mem(nic, &rbdr->dmem);
@@ -250,7 +314,7 @@ static void nicvf_refill_rbdr(struct nicvf *nic, gfp_t gfp)
 			break;
 
 		desc = GET_RBDR_DESC(rbdr, tail);
-		desc->buf_addr = virt_to_phys(rbuf) >> NICVF_RCV_BUF_ALIGN;
+		desc->buf_addr = (u64)rbuf >> NICVF_RCV_BUF_ALIGN;
 		refill_rb_cnt--;
 		new_rb++;
 	}
@@ -361,9 +425,29 @@ static int nicvf_init_snd_queue(struct nicvf *nic,
 	return 0;
 }
 
+void nicvf_unmap_sndq_buffers(struct nicvf *nic, struct snd_queue *sq,
+			      int hdr_sqe, u8 subdesc_cnt)
+{
+	u8 idx;
+	struct sq_gather_subdesc *gather;
+
+	if (!nic->iommu_domain)
+		return;
+
+	/* Unmap DMA mapped skb data buffers */
+	for (idx = 0; idx < subdesc_cnt; idx++) {
+		hdr_sqe++;
+		hdr_sqe &= (sq->dmem.q_len - 1);
+		gather = (struct sq_gather_subdesc *)GET_SQ_DESC(sq, hdr_sqe);
+		nicvf_dma_unmap(nic, gather->addr, gather->size, DMA_TO_DEVICE);
+	}
+}
+
 static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 {
 	struct sk_buff *skb;
+	struct sq_hdr_subdesc *hdr;
+	struct sq_hdr_subdesc *tso_sqe;
 
 	if (!sq)
 		return;
@@ -379,8 +463,22 @@ static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 	smp_rmb();
 	while (sq->head != sq->tail) {
 		skb = (struct sk_buff *)sq->skbuff[sq->head];
-		if (skb)
-			dev_kfree_skb_any(skb);
+		if (!skb)
+			goto next;
+		hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, sq->head);
+		/* Check for dummy descriptor used for HW TSO offload on 88xx */
+		if (hdr->dont_send) {
+			/* Get actual TSO descriptors and unmap them */
+			tso_sqe =
+			 (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, hdr->rsvd2);
+			nicvf_unmap_sndq_buffers(nic, sq, hdr->rsvd2,
+						 tso_sqe->subdesc_cnt);
+		} else {
+			nicvf_unmap_sndq_buffers(nic, sq, sq->head,
+						 hdr->subdesc_cnt);
+		}
+		dev_kfree_skb_any(skb);
+next:
 		sq->head++;
 		sq->head &= (sq->dmem.q_len - 1);
 	}
@@ -882,6 +980,14 @@ static inline int nicvf_get_sq_desc(struct snd_queue *sq, int desc_cnt)
 	return qentry;
 }
 
+/* Rollback to previous tail pointer when descriptors not used */
+static inline void nicvf_rollback_sq_desc(struct snd_queue *sq,
+					  int qentry, int desc_cnt)
+{
+	sq->tail = qentry;
+	atomic_add(desc_cnt, &sq->free_cnt);
+}
+
 /* Free descriptor back to SQ for future use */
 void nicvf_put_sq_desc(struct snd_queue *sq, int desc_cnt)
 {
@@ -1207,8 +1313,9 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct snd_queue *sq,
 			struct sk_buff *skb, u8 sq_num)
 {
 	int i, size;
-	int subdesc_cnt, tso_sqe = 0;
+	int subdesc_cnt, hdr_sqe = 0;
 	int qentry;
+	u64 dma_addr;
 
 	subdesc_cnt = nicvf_sq_subdesc_required(nic, skb);
 	if (subdesc_cnt > atomic_read(&sq->free_cnt))
@@ -1223,12 +1330,20 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct snd_queue *sq,
 	/* Add SQ header subdesc */
 	nicvf_sq_add_hdr_subdesc(nic, sq, qentry, subdesc_cnt - 1,
 				 skb, skb->len);
-	tso_sqe = qentry;
+	hdr_sqe = qentry;
 
 	/* Add SQ gather subdescs */
 	qentry = nicvf_get_nxt_sqentry(sq, qentry);
 	size = skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
-	nicvf_sq_add_gather_subdesc(sq, qentry, size, virt_to_phys(skb->data));
+	dma_addr = nicvf_dma_map(nic, virt_to_page(skb->data),
+				 offset_in_page(skb->data),
+				 size, DMA_TO_DEVICE);
+	if (nicvf_dma_map_error(nic, dma_addr)) {
+		nicvf_rollback_sq_desc(sq, qentry, subdesc_cnt);
+		return 0;
+	}
+
+	nicvf_sq_add_gather_subdesc(sq, qentry, size, dma_addr);
 
 	/* Check for scattered buffer */
 	if (!skb_is_nonlinear(skb))
@@ -1241,15 +1356,24 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct snd_queue *sq,
 
 		qentry = nicvf_get_nxt_sqentry(sq, qentry);
 		size = skb_frag_size(frag);
-		nicvf_sq_add_gather_subdesc(sq, qentry, size,
-					    virt_to_phys(
-					    skb_frag_address(frag)));
+		dma_addr = nicvf_dma_map(nic, skb_frag_page(frag),
+					 frag->page_offset,
+					 size, DMA_TO_DEVICE);
+		if (nicvf_dma_map_error(nic, dma_addr)) {
+			/* Free entire chain of mapped buffers
+			 * here 'i' = frags mapped + above mapped skb->data
+			 */
+			nicvf_unmap_sndq_buffers(nic, sq, hdr_sqe, i);
+			nicvf_rollback_sq_desc(sq, qentry, subdesc_cnt);
+			return 0;
+		}
+		nicvf_sq_add_gather_subdesc(sq, qentry, size, dma_addr);
 	}
 
 doorbell:
 	if (nic->t88 && skb_shinfo(skb)->gso_size) {
 		qentry = nicvf_get_nxt_sqentry(sq, qentry);
-		nicvf_sq_add_cqe_subdesc(sq, qentry, tso_sqe, skb);
+		nicvf_sq_add_cqe_subdesc(sq, qentry, hdr_sqe, skb);
 	}
 
 	nicvf_sq_doorbell(nic, skb, sq_num, subdesc_cnt);
@@ -1282,6 +1406,7 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 	int offset;
 	u16 *rb_lens = NULL;
 	u64 *rb_ptrs = NULL;
+	u64 phys_addr;
 
 	rb_lens = (void *)cqe_rx + (3 * sizeof(u64));
 	/* Except 88xx pass1 on all other chips CQE_RX2_S is added to
@@ -1296,15 +1421,21 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 	else
 		rb_ptrs = (void *)cqe_rx + (7 * sizeof(u64));
 
-	netdev_dbg(nic->netdev, "%s rb_cnt %d rb0_ptr %llx rb0_sz %d\n",
-		   __func__, cqe_rx->rb_cnt, cqe_rx->rb0_ptr, cqe_rx->rb0_sz);
-
 	for (frag = 0; frag < cqe_rx->rb_cnt; frag++) {
 		payload_len = rb_lens[frag_num(frag)];
+		phys_addr = nicvf_iova_to_phys(nic, *rb_ptrs);
+		if (!phys_addr) {
+			if (skb)
+				dev_kfree_skb_any(skb);
+			return NULL;
+		}
+
 		if (!frag) {
 			/* First fragment */
+			nicvf_dma_unmap(nic, *rb_ptrs - cqe_rx->align_pad,
+					RCV_FRAG_LEN, DMA_FROM_DEVICE);
 			skb = nicvf_rb_ptr_to_skb(nic,
-						  *rb_ptrs - cqe_rx->align_pad,
+						  phys_addr - cqe_rx->align_pad,
 						  payload_len);
 			if (!skb)
 				return NULL;
@@ -1312,8 +1443,10 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 			skb_put(skb, payload_len);
 		} else {
 			/* Add fragments */
-			page = virt_to_page(phys_to_virt(*rb_ptrs));
-			offset = phys_to_virt(*rb_ptrs) - page_address(page);
+			nicvf_dma_unmap(nic, *rb_ptrs,
+					RCV_FRAG_LEN, DMA_FROM_DEVICE);
+			page = virt_to_page(phys_to_virt(phys_addr));
+			offset = phys_to_virt(phys_addr) - page_address(page);
 			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 					offset, payload_len, RCV_FRAG_LEN);
 		}
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index 5cb84da..6ab6bfd 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -301,6 +301,8 @@ struct queue_set {
 
 #define	CQ_ERR_MASK	(CQ_WR_FULL | CQ_WR_DISABLE | CQ_WR_FAULT)
 
+void nicvf_unmap_sndq_buffers(struct nicvf *nic, struct snd_queue *sq,
+			      int hdr_sqe, u8 subdesc_cnt);
 void nicvf_config_vlan_stripping(struct nicvf *nic,
 				 netdev_features_t features);
 int nicvf_set_qset_resources(struct nicvf *nic);
-- 
2.7.4
