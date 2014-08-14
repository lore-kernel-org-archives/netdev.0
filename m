From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 1/3] enic: implement rx_copybreak
Date: Thu, 14 Aug 2014 14:59:18 +0530
Message-ID: <1408008560-1067-2-git-send-email-_govind@gmx.com>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Cc: ben@decadent.org.uk, stephen@networkplumber.org, ssujith@cisco.com,
	benve@cisco.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53984 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947AbaHNJaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 05:30:01 -0400
In-Reply-To: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling dma_map_single()/dma_unmap_single() is quite expensive compared
to copying a small packet. So let's copy short frames and keep the buffers
mapped.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  1 +
 drivers/net/ethernet/cisco/enic/enic_main.c | 50 +++++++++++++++++++++++++++--
 2 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 962510f..5ba5ad0 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -186,6 +186,7 @@ struct enic {
 	____cacheline_aligned struct vnic_cq cq[ENIC_CQ_MAX];
 	unsigned int cq_count;
 	struct enic_rfs_flw_tbl rfs_h;
+	u32 rx_copybreak;
 };
 
 static inline struct device *enic_get_dev(struct enic *enic)
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9348feb..b7e69fd 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -66,6 +66,8 @@
 #define PCI_DEVICE_ID_CISCO_VIC_ENET_DYN     0x0044  /* enet dynamic vnic */
 #define PCI_DEVICE_ID_CISCO_VIC_ENET_VF      0x0071  /* enet SRIOV VF */
 
+#define RX_COPYBREAK_DEFAULT		256
+
 /* Supported devices */
 static DEFINE_PCI_DEVICE_TABLE(enic_id_table) = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
@@ -924,6 +926,7 @@ static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
 	pci_unmap_single(enic->pdev, buf->dma_addr,
 		buf->len, PCI_DMA_FROMDEVICE);
 	dev_kfree_skb_any(buf->os_buf);
+	buf->os_buf = NULL;
 }
 
 static int enic_rq_alloc_buf(struct vnic_rq *rq)
@@ -934,7 +937,24 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	unsigned int len = netdev->mtu + VLAN_ETH_HLEN;
 	unsigned int os_buf_index = 0;
 	dma_addr_t dma_addr;
+	struct vnic_rq_buf *buf = rq->to_use;
+
+	if (buf->os_buf) {
+		buf = buf->next;
+		rq->to_use = buf;
+		rq->ring.desc_avail--;
+		if ((buf->index & VNIC_RQ_RETURN_RATE) == 0) {
+			/* Adding write memory barrier prevents compiler and/or
+			 * CPU reordering, thus avoiding descriptor posting
+			 * before descriptor is initialized. Otherwise, hardware
+			 * can read stale descriptor fields.
+			 */
+			wmb();
+			iowrite32(buf->index, &rq->ctrl->posted_index);
+		}
 
+		return 0;
+	}
 	skb = netdev_alloc_skb_ip_align(netdev, len);
 	if (!skb)
 		return -ENOMEM;
@@ -957,6 +977,25 @@ static void enic_intr_update_pkt_size(struct vnic_rx_bytes_counter *pkt_size,
 		pkt_size->small_pkt_bytes_cnt += pkt_len;
 }
 
+static bool enic_rxcopybreak(struct net_device *netdev, struct sk_buff **skb,
+			     struct vnic_rq_buf *buf, u16 len)
+{
+	struct enic *enic = netdev_priv(netdev);
+	struct sk_buff *new_skb;
+
+	if (len > enic->rx_copybreak)
+		return false;
+	new_skb = netdev_alloc_skb_ip_align(netdev, len);
+	if (!new_skb)
+		return false;
+	pci_dma_sync_single_for_cpu(enic->pdev, buf->dma_addr, len,
+				    DMA_FROM_DEVICE);
+	memcpy(new_skb->data, (*skb)->data, len);
+	*skb = new_skb;
+
+	return true;
+}
+
 static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
 	int skipped, void *opaque)
@@ -978,9 +1017,6 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		return;
 
 	skb = buf->os_buf;
-	prefetch(skb->data - NET_IP_ALIGN);
-	pci_unmap_single(enic->pdev, buf->dma_addr,
-		buf->len, PCI_DMA_FROMDEVICE);
 
 	cq_enet_rq_desc_dec((struct cq_enet_rq_desc *)cq_desc,
 		&type, &color, &q_number, &completed_index,
@@ -1011,6 +1047,13 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		/* Good receive
 		 */
 
+		if (!enic_rxcopybreak(netdev, &skb, buf, bytes_written)) {
+			buf->os_buf = NULL;
+			pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
+					 PCI_DMA_FROMDEVICE);
+		}
+		prefetch(skb->data - NET_IP_ALIGN);
+
 		skb_put(skb, bytes_written);
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, q_number);
@@ -2531,6 +2574,7 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(dev, "Cannot register net device, aborting\n");
 		goto err_out_dev_deinit;
 	}
+	enic->rx_copybreak = RX_COPYBREAK_DEFAULT;
 
 	return 0;
 
-- 
2.0.4
