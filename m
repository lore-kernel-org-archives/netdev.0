From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 08/10] enic: Feature Add: Add loopback capability
	to enic devices
Date: Thu, 24 Jun 2010 13:51:59 -0700
Message-ID: <20100624205156.22595.88328.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:23746 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab0FXUv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:51:59 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Hardware has the loopback capability to queue the packets transmitted from
a device to the receive queue of the same device. enic now supports the
loopback capability.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/enic.h      |    2 ++
 drivers/net/enic/enic_main.c |   42 +++++++++++++++++++++++++++---------------
 drivers/net/enic/enic_res.c  |    1 +
 drivers/net/enic/enic_res.h  |   25 +++++++++++++------------
 drivers/net/enic/vnic_enet.h |    2 ++
 5 files changed, 45 insertions(+), 27 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 3588ef5..7280314 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -110,6 +110,8 @@ struct enic {
 	spinlock_t wq_lock[ENIC_WQ_MAX];
 	unsigned int wq_count;
 	struct vlan_group *vlan_group;
+	u16 loop_enable;
+	u16 loop_tag;
 
 	/* receive queue cache line section */
 	____cacheline_aligned struct vnic_rq rq[ENIC_RQ_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 413e362..eda5530 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -594,7 +594,7 @@ static irqreturn_t enic_isr_msix_notify(int irq, void *data)
 
 static inline void enic_queue_wq_skb_cont(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb,
-	unsigned int len_left)
+	unsigned int len_left, int loopback)
 {
 	skb_frag_t *frag;
 
@@ -606,13 +606,14 @@ static inline void enic_queue_wq_skb_cont(struct enic *enic,
 				frag->page_offset, frag->size,
 				PCI_DMA_TODEVICE),
 			frag->size,
-			(len_left == 0));	/* EOP? */
+			(len_left == 0),	/* EOP? */
+			loopback);
 	}
 }
 
 static inline void enic_queue_wq_skb_vlan(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb,
-	int vlan_tag_insert, unsigned int vlan_tag)
+	int vlan_tag_insert, unsigned int vlan_tag, int loopback)
 {
 	unsigned int head_len = skb_headlen(skb);
 	unsigned int len_left = skb->len - head_len;
@@ -628,15 +629,15 @@ static inline void enic_queue_wq_skb_vlan(struct enic *enic,
 			head_len, PCI_DMA_TODEVICE),
 		head_len,
 		vlan_tag_insert, vlan_tag,
-		eop);
+		eop, loopback);
 
 	if (!eop)
-		enic_queue_wq_skb_cont(enic, wq, skb, len_left);
+		enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
 }
 
 static inline void enic_queue_wq_skb_csum_l4(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb,
-	int vlan_tag_insert, unsigned int vlan_tag)
+	int vlan_tag_insert, unsigned int vlan_tag, int loopback)
 {
 	unsigned int head_len = skb_headlen(skb);
 	unsigned int len_left = skb->len - head_len;
@@ -656,15 +657,15 @@ static inline void enic_queue_wq_skb_csum_l4(struct enic *enic,
 		csum_offset,
 		hdr_len,
 		vlan_tag_insert, vlan_tag,
-		eop);
+		eop, loopback);
 
 	if (!eop)
-		enic_queue_wq_skb_cont(enic, wq, skb, len_left);
+		enic_queue_wq_skb_cont(enic, wq, skb, len_left, loopback);
 }
 
 static inline void enic_queue_wq_skb_tso(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb, unsigned int mss,
-	int vlan_tag_insert, unsigned int vlan_tag)
+	int vlan_tag_insert, unsigned int vlan_tag, int loopback)
 {
 	unsigned int frag_len_left = skb_headlen(skb);
 	unsigned int len_left = skb->len - frag_len_left;
@@ -701,7 +702,7 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 			len,
 			mss, hdr_len,
 			vlan_tag_insert, vlan_tag,
-			eop && (len == frag_len_left));
+			eop && (len == frag_len_left), loopback);
 		frag_len_left -= len;
 		offset += len;
 	}
@@ -727,7 +728,8 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 				dma_addr,
 				len,
 				(len_left == 0) &&
-				(len == frag_len_left));	/* EOP? */
+				(len == frag_len_left),		/* EOP? */
+				loopback);
 			frag_len_left -= len;
 			offset += len;
 		}
@@ -740,22 +742,26 @@ static inline void enic_queue_wq_skb(struct enic *enic,
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 	unsigned int vlan_tag = 0;
 	int vlan_tag_insert = 0;
+	int loopback = 0;
 
 	if (enic->vlan_group && vlan_tx_tag_present(skb)) {
 		/* VLAN tag from trunking driver */
 		vlan_tag_insert = 1;
 		vlan_tag = vlan_tx_tag_get(skb);
+	} else if (enic->loop_enable) {
+		vlan_tag = enic->loop_tag;
+		loopback = 1;
 	}
 
 	if (mss)
 		enic_queue_wq_skb_tso(enic, wq, skb, mss,
-			vlan_tag_insert, vlan_tag);
+			vlan_tag_insert, vlan_tag, loopback);
 	else if	(skb->ip_summed == CHECKSUM_PARTIAL)
 		enic_queue_wq_skb_csum_l4(enic, wq, skb,
-			vlan_tag_insert, vlan_tag);
+			vlan_tag_insert, vlan_tag, loopback);
 	else
 		enic_queue_wq_skb_vlan(enic, wq, skb,
-			vlan_tag_insert, vlan_tag);
+			vlan_tag_insert, vlan_tag, loopback);
 }
 
 /* netif_tx_lock held, process context with BHs disabled, or BH */
@@ -1275,7 +1281,7 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	struct enic *enic = vnic_dev_priv(rq->vdev);
 	struct net_device *netdev = enic->netdev;
 	struct sk_buff *skb;
-	unsigned int len = netdev->mtu + ETH_HLEN;
+	unsigned int len = netdev->mtu + VLAN_ETH_HLEN;
 	unsigned int os_buf_index = 0;
 	dma_addr_t dma_addr;
 
@@ -2441,6 +2447,12 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	netdev->ethtool_ops = &enic_ethtool_ops;
 
 	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	if (ENIC_SETTING(enic, LOOP)) {
+		netdev->features &= ~NETIF_F_HW_VLAN_TX;
+		enic->loop_enable = 1;
+		enic->loop_tag = enic->config.loop_tag;
+		dev_info(dev, "loopback tag=0x%04x\n", enic->loop_tag);
+	}
 	if (ENIC_SETTING(enic, TXCSUM))
 		netdev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (ENIC_SETTING(enic, TSO))
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 478928b..2cc7e27 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -70,6 +70,7 @@ int enic_get_vnic_config(struct enic *enic)
 	GET_CONFIG(intr_timer_type);
 	GET_CONFIG(intr_mode);
 	GET_CONFIG(intr_timer_usec);
+	GET_CONFIG(loop_tag);
 
 	c->wq_desc_count =
 		min_t(u32, ENIC_MAX_WQ_DESCS,
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 3f6e039..8b25a07 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -43,7 +43,7 @@ static inline void enic_queue_wq_desc_ex(struct vnic_wq *wq,
 	void *os_buf, dma_addr_t dma_addr, unsigned int len,
 	unsigned int mss_or_csum_offset, unsigned int hdr_len,
 	int vlan_tag_insert, unsigned int vlan_tag,
-	int offload_mode, int cq_entry, int sop, int eop)
+	int offload_mode, int cq_entry, int sop, int eop, int loopback)
 {
 	struct wq_enet_desc *desc = vnic_wq_next_desc(wq);
 
@@ -56,61 +56,62 @@ static inline void enic_queue_wq_desc_ex(struct vnic_wq *wq,
 		0, /* fcoe_encap */
 		(u8)vlan_tag_insert,
 		(u16)vlan_tag,
-		0 /* loopback */);
+		(u8)loopback);
 
 	vnic_wq_post(wq, os_buf, dma_addr, len, sop, eop);
 }
 
 static inline void enic_queue_wq_desc_cont(struct vnic_wq *wq,
-	void *os_buf, dma_addr_t dma_addr, unsigned int len, int eop)
+	void *os_buf, dma_addr_t dma_addr, unsigned int len,
+	int eop, int loopback)
 {
 	enic_queue_wq_desc_ex(wq, os_buf, dma_addr, len,
 		0, 0, 0, 0, 0,
-		eop, 0 /* !SOP */, eop);
+		eop, 0 /* !SOP */, eop, loopback);
 }
 
 static inline void enic_queue_wq_desc(struct vnic_wq *wq, void *os_buf,
 	dma_addr_t dma_addr, unsigned int len, int vlan_tag_insert,
-	unsigned int vlan_tag, int eop)
+	unsigned int vlan_tag, int eop, int loopback)
 {
 	enic_queue_wq_desc_ex(wq, os_buf, dma_addr, len,
 		0, 0, vlan_tag_insert, vlan_tag,
 		WQ_ENET_OFFLOAD_MODE_CSUM,
-		eop, 1 /* SOP */, eop);
+		eop, 1 /* SOP */, eop, loopback);
 }
 
 static inline void enic_queue_wq_desc_csum(struct vnic_wq *wq,
 	void *os_buf, dma_addr_t dma_addr, unsigned int len,
 	int ip_csum, int tcpudp_csum, int vlan_tag_insert,
-	unsigned int vlan_tag, int eop)
+	unsigned int vlan_tag, int eop, int loopback)
 {
 	enic_queue_wq_desc_ex(wq, os_buf, dma_addr, len,
 		(ip_csum ? 1 : 0) + (tcpudp_csum ? 2 : 0),
 		0, vlan_tag_insert, vlan_tag,
 		WQ_ENET_OFFLOAD_MODE_CSUM,
-		eop, 1 /* SOP */, eop);
+		eop, 1 /* SOP */, eop, loopback);
 }
 
 static inline void enic_queue_wq_desc_csum_l4(struct vnic_wq *wq,
 	void *os_buf, dma_addr_t dma_addr, unsigned int len,
 	unsigned int csum_offset, unsigned int hdr_len,
-	int vlan_tag_insert, unsigned int vlan_tag, int eop)
+	int vlan_tag_insert, unsigned int vlan_tag, int eop, int loopback)
 {
 	enic_queue_wq_desc_ex(wq, os_buf, dma_addr, len,
 		csum_offset, hdr_len, vlan_tag_insert, vlan_tag,
 		WQ_ENET_OFFLOAD_MODE_CSUM_L4,
-		eop, 1 /* SOP */, eop);
+		eop, 1 /* SOP */, eop, loopback);
 }
 
 static inline void enic_queue_wq_desc_tso(struct vnic_wq *wq,
 	void *os_buf, dma_addr_t dma_addr, unsigned int len,
 	unsigned int mss, unsigned int hdr_len, int vlan_tag_insert,
-	unsigned int vlan_tag, int eop)
+	unsigned int vlan_tag, int eop, int loopback)
 {
 	enic_queue_wq_desc_ex(wq, os_buf, dma_addr, len,
 		mss, hdr_len, vlan_tag_insert, vlan_tag,
 		WQ_ENET_OFFLOAD_MODE_TSO,
-		eop, 1 /* SOP */, eop);
+		eop, 1 /* SOP */, eop, loopback);
 }
 
 static inline void enic_queue_rq_desc(struct vnic_rq *rq,
diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/enic/vnic_enet.h
index 8eeb675..42baaa1 100644
--- a/drivers/net/enic/vnic_enet.h
+++ b/drivers/net/enic/vnic_enet.h
@@ -35,6 +35,7 @@ struct vnic_enet_config {
 	u8 intr_mode;
 	char devname[16];
 	u32 intr_timer_usec;
+	u16 loop_tag;
 };
 
 #define VENETF_TSO		0x1	/* TSO enabled */
@@ -48,5 +49,6 @@ struct vnic_enet_config {
 #define VENETF_RSSHASH_TCPIPV6	0x100	/* Hash on TCP + IPv6 fields */
 #define VENETF_RSSHASH_IPV6_EX	0x200	/* Hash on IPv6 extended fields */
 #define VENETF_RSSHASH_TCPIPV6_EX 0x400	/* Hash on TCP + IPv6 ext. fields */
+#define VENETF_LOOP		0x800	/* Loopback enabled */
 
 #endif /* _VNIC_ENIC_H_ */

