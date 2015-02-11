From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 1/2] enic: implement frag allocator
Date: Wed, 11 Feb 2015 18:29:17 +0530
Message-ID: <1423659558-32523-2-git-send-email-_govind@gmx.com>
References: <1423659558-32523-1-git-send-email-_govind@gmx.com>
Cc: benve@cisco.com, ssujith@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:59870 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbbBKM7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 07:59:53 -0500
In-Reply-To: <1423659558-32523-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements frag allocator for rq buffer. This is based on
__alloc_page_frag & __page_frag_refill implementation in net/core/skbuff.c

In addition to frag allocation from order(3) page in __alloc_page_frag,
we also maintain dma address of the page. While allocating a frag for rx buffer
we return va + offset for virtual address of the frag, and pa + offset for
dma address of the frag. This reduces the number of calls to dma_map()
by 1/3 for 9k mtu and by 1/20 for 1500 mtu.

__alloc_page_frag is limited to max buffer size of PAGE_SIZE, i.e 4096 in most
of the cases. So 9k buffer allocation goes through kmalloc which return
page of order 2, 16k. We waste 7k bytes for every 9k buffer.

we maintain dma_count variable which is incremented when we allocate a frag.
enic_unmap_dma will decrement the dma_count and unmap it when there is no user
of that page in rx ring.

This reduces the memory utilization for 9k mtu by 33%.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  15 +++
 drivers/net/ethernet/cisco/enic/enic_main.c | 155 +++++++++++++++++++++++-----
 drivers/net/ethernet/cisco/enic/vnic_rq.c   |  13 +++
 drivers/net/ethernet/cisco/enic/vnic_rq.h   |   2 +
 4 files changed, 161 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 84b6a2b..0f3b6327 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -20,6 +20,11 @@
 #ifndef _ENIC_H_
 #define _ENIC_H_
 
+#include <linux/if.h>
+#include <linux/if_link.h>
+#include <linux/if_ether.h>
+#include <linux/netdevice.h>
+
 #include "vnic_enet.h"
 #include "vnic_dev.h"
 #include "vnic_wq.h"
@@ -191,6 +196,16 @@ struct enic {
 	struct vnic_gen_stats gen_stats;
 };
 
+#define ENIC_ALLOC_ORDER	PAGE_ALLOC_COSTLY_ORDER
+
+struct enic_alloc_cache {
+	struct page_frag	frag;
+	unsigned int		pagecnt_bias;
+	int			dma_count;
+	void			*va;
+	dma_addr_t		pa;
+};
+
 static inline struct device *enic_get_dev(struct enic *enic)
 {
 	return &(enic->pdev->dev);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9cbe038..841571f 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -950,6 +950,105 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+struct enic_alloc_cache *enic_page_refill(struct enic *enic, size_t sz,
+					  gfp_t gfp)
+{
+	struct enic_alloc_cache *ec;
+	gfp_t gfp_comp = gfp | __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
+	u8 order = ENIC_ALLOC_ORDER;
+
+	ec = kzalloc(sizeof(*ec), GFP_ATOMIC);
+	if (unlikely(!ec))
+		goto no_ec;
+	ec->frag.page = alloc_pages_node(NUMA_NO_NODE, gfp_comp, order);
+	if (unlikely(!ec->frag.page)) {
+		order = get_order(sz);
+		ec->frag.page = alloc_pages_node(NUMA_NO_NODE, gfp, order);
+		if (!ec->frag.page)
+			goto free_ec;
+	}
+
+	ec->frag.size = (PAGE_SIZE << order);
+	ec->va = page_address(ec->frag.page);
+	ec->pa = pci_map_single(enic->pdev, ec->va, ec->frag.size,
+				PCI_DMA_FROMDEVICE);
+	if (unlikely(enic_dma_map_check(enic, ec->pa)))
+		goto free_page;
+	atomic_add(ec->frag.size - 1, &ec->frag.page->_count);
+	ec->pagecnt_bias = ec->frag.size;
+	ec->frag.offset = ec->frag.size;
+
+	return ec;
+
+free_page:
+	__free_pages(ec->frag.page, order);
+free_ec:
+	kfree(ec);
+no_ec:
+	return NULL;
+}
+
+struct enic_alloc_cache *enic_alloc_frag(struct vnic_rq *rq, size_t sz)
+{
+	struct enic *enic = vnic_dev_priv(rq->vdev);
+	struct enic_alloc_cache *ec = rq->ec;
+	int offset;
+
+	if (unlikely(!ec)) {
+refill:
+		ec = enic_page_refill(enic, sz, GFP_ATOMIC);
+		rq->ec = ec;
+
+		if (unlikely(!ec))
+			return NULL;
+	}
+
+	offset = ec->frag.offset - sz;
+	if (offset < 0) {
+		if (!atomic_sub_and_test(ec->pagecnt_bias,
+					 &ec->frag.page->_count)) {
+			/* rq cleanup service has processed all the frags
+			 * belonging to this page. Since page->_count is not 0
+			 * and ec->dma_count is 0 these frags should be in
+			 * stack. We should unmap the page here.
+			 */
+			if (!ec->dma_count) {
+				pci_unmap_single(enic->pdev, ec->pa,
+						 ec->frag.size,
+						 PCI_DMA_FROMDEVICE);
+				kfree(ec);
+			} else {
+			/* frags from this page are still in rx queue. Let the
+			 * rx cleanup service unmap the page in enic_unmap_dma.
+			 */
+				ec->pagecnt_bias = 0;
+			}
+			goto refill;
+		}
+		WARN_ON(ec->dma_count);
+		atomic_set(&ec->frag.page->_count, ec->frag.size);
+		ec->pagecnt_bias = ec->frag.size;
+		offset = ec->frag.size - sz;
+	}
+	ec->pagecnt_bias--;
+	ec->dma_count++;
+	ec->frag.offset = offset;
+
+	return ec;
+}
+
+void enic_unmap_dma(struct enic *enic, struct enic_alloc_cache *ec)
+{
+	/* enic_alloc_frag is done using this page. We should be free to unmap
+	 * the page if there are no pending frags in the queue.
+	 */
+	if (!--ec->dma_count && !ec->pagecnt_bias) {
+		pci_unmap_single(enic->pdev, ec->pa, ec->frag.size,
+				 PCI_DMA_FROMDEVICE);
+		kfree(ec);
+	}
+}
+
 static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
 {
 	struct enic *enic = vnic_dev_priv(rq->vdev);
@@ -957,8 +1056,7 @@ static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
 	if (!buf->os_buf)
 		return;
 
-	pci_unmap_single(enic->pdev, buf->dma_addr,
-		buf->len, PCI_DMA_FROMDEVICE);
+	enic_unmap_dma(enic, buf->ec);
 	dev_kfree_skb_any(buf->os_buf);
 	buf->os_buf = NULL;
 }
@@ -968,10 +1066,12 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	struct enic *enic = vnic_dev_priv(rq->vdev);
 	struct net_device *netdev = enic->netdev;
 	struct sk_buff *skb;
-	unsigned int len = netdev->mtu + VLAN_ETH_HLEN;
+	unsigned int len;
 	unsigned int os_buf_index = 0;
 	dma_addr_t dma_addr;
 	struct vnic_rq_buf *buf = rq->to_use;
+	struct enic_alloc_cache *ec;
+	void *va;
 
 	if (buf->os_buf) {
 		enic_queue_rq_desc(rq, buf->os_buf, os_buf_index, buf->dma_addr,
@@ -979,21 +1079,33 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 
 		return 0;
 	}
-	skb = netdev_alloc_skb_ip_align(netdev, len);
-	if (!skb)
-		return -ENOMEM;
 
-	dma_addr = pci_map_single(enic->pdev, skb->data, len,
-				  PCI_DMA_FROMDEVICE);
-	if (unlikely(enic_dma_map_check(enic, dma_addr))) {
-		dev_kfree_skb(skb);
-		return -ENOMEM;
-	}
+	len = netdev->mtu + VLAN_ETH_HLEN + NET_IP_ALIGN + NET_SKB_PAD;
+	len = SKB_DATA_ALIGN(len) +
+	      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
-	enic_queue_rq_desc(rq, skb, os_buf_index,
-		dma_addr, len);
+	ec = enic_alloc_frag(rq, len);
+	if (unlikely(!ec))
+		goto alloc_fail;
+	va = ec->va + ec->frag.offset;
+	skb = build_skb(va, len);
+	if (unlikely(!skb)) {
+		ec->pagecnt_bias++;
+		ec->frag.offset += len;
+		ec->dma_count--;
+
+		goto alloc_fail;
+	}
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+	dma_addr = ec->pa + ec->frag.offset + NET_SKB_PAD + NET_IP_ALIGN;
+	buf->ec = ec;
+	enic_queue_rq_desc(rq, skb, os_buf_index, dma_addr,
+			   netdev->mtu + VLAN_ETH_HLEN);
 
 	return 0;
+
+alloc_fail:
+	return -ENOMEM;
 }
 
 static void enic_intr_update_pkt_size(struct vnic_rx_bytes_counter *pkt_size,
@@ -1016,8 +1128,6 @@ static bool enic_rxcopybreak(struct net_device *netdev, struct sk_buff **skb,
 	new_skb = netdev_alloc_skb_ip_align(netdev, len);
 	if (!new_skb)
 		return false;
-	pci_dma_sync_single_for_cpu(enic->pdev, buf->dma_addr, len,
-				    DMA_FROM_DEVICE);
 	memcpy(new_skb->data, (*skb)->data, len);
 	*skb = new_skb;
 
@@ -1065,8 +1175,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 				enic->rq_truncated_pkts++;
 		}
 
-		pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
-				 PCI_DMA_FROMDEVICE);
+		enic_unmap_dma(enic, buf->ec);
 		dev_kfree_skb_any(skb);
 		buf->os_buf = NULL;
 
@@ -1077,11 +1186,11 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		/* Good receive
 		 */
-
+		pci_dma_sync_single_for_cpu(enic->pdev, buf->dma_addr,
+					    bytes_written, DMA_FROM_DEVICE);
 		if (!enic_rxcopybreak(netdev, &skb, buf, bytes_written)) {
 			buf->os_buf = NULL;
-			pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
-					 PCI_DMA_FROMDEVICE);
+			enic_unmap_dma(enic, buf->ec);
 		}
 		prefetch(skb->data - NET_IP_ALIGN);
 
@@ -1122,9 +1231,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		/* Buffer overflow
 		 */
-
-		pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
-				 PCI_DMA_FROMDEVICE);
+		enic_unmap_dma(enic, buf->ec);
 		dev_kfree_skb_any(skb);
 		buf->os_buf = NULL;
 	}
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index 36a2ed6..c31669f 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -26,6 +26,7 @@
 
 #include "vnic_dev.h"
 #include "vnic_rq.h"
+#include "enic.h"
 
 static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 {
@@ -199,6 +200,18 @@ void vnic_rq_clean(struct vnic_rq *rq,
 		rq->ring.desc_avail++;
 	}
 
+	if (rq->ec) {
+		struct enic *enic = vnic_dev_priv(rq->vdev);
+		struct enic_alloc_cache *ec = rq->ec;
+
+		WARN_ON(ec->dma_count);
+		pci_unmap_single(enic->pdev, ec->pa, ec->frag.size,
+				 PCI_DMA_FROMDEVICE);
+		atomic_sub(ec->pagecnt_bias - 1, &ec->frag.page->_count);
+		__free_pages(ec->frag.page, get_order(ec->frag.size));
+		kfree(ec);
+		rq->ec = NULL;
+	}
 	/* Use current fetch_index as the ring starting point */
 	fetch_index = ioread32(&rq->ctrl->fetch_index);
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
index 8111d52..2e4815a 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.h
@@ -73,6 +73,7 @@ struct vnic_rq_buf {
 	unsigned int index;
 	void *desc;
 	uint64_t wr_id;
+	struct enic_alloc_cache	*ec;
 };
 
 struct vnic_rq {
@@ -100,6 +101,7 @@ struct vnic_rq {
 	unsigned int bpoll_state;
 	spinlock_t bpoll_lock;
 #endif /* CONFIG_NET_RX_BUSY_POLL */
+	struct enic_alloc_cache	*ec;
 };
 
 static inline unsigned int vnic_rq_desc_avail(struct vnic_rq *rq)
-- 
2.3.0
