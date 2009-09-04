From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 03/11] enic: bug fix: split TSO fragments larger than
	16K into multiple descs
Date: Thu, 03 Sep 2009 20:02:03 -0700
Message-ID: <20090904030203.5047.55882.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:32043 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932558AbZIDDLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:11:40 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: bug fix: split TSO fragments larger than 16K into multiple descs

enic WQ desc supports a maximum 16K buf size, so split any send fragments
larger than 16K into several descs.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   87 +++++++++++++++++++++++++++++++++---------
 1 files changed, 69 insertions(+), 18 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 3d7838d..a9e9be1 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -44,10 +44,15 @@
 #include "enic.h"
 
 #define ENIC_NOTIFY_TIMER_PERIOD	(2 * HZ)
+#define WQ_ENET_MAX_DESC_LEN		(1 << WQ_ENET_LEN_BITS)
+#define MAX_TSO				(1 << 16)
+#define ENIC_DESC_MAX_SPLITS		(MAX_TSO / WQ_ENET_MAX_DESC_LEN + 1)
+
+#define PCI_DEVICE_ID_CISCO_VIC_ENET         0x0043  /* ethernet vnic */
 
 /* Supported devices */
 static struct pci_device_id enic_id_table[] = {
-	{ PCI_VDEVICE(CISCO, 0x0043) },
+	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
 	{ 0, }	/* end of table */
 };
 
@@ -310,7 +315,8 @@ static int enic_wq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 		opaque);
 
 	if (netif_queue_stopped(enic->netdev) &&
-	    vnic_wq_desc_avail(&enic->wq[q_number]) >= MAX_SKB_FRAGS + 1)
+	    vnic_wq_desc_avail(&enic->wq[q_number]) >=
+	    (MAX_SKB_FRAGS + ENIC_DESC_MAX_SPLITS))
 		netif_wake_queue(enic->netdev);
 
 	spin_unlock(&enic->wq_lock[q_number]);
@@ -525,7 +531,11 @@ static inline void enic_queue_wq_skb_vlan(struct enic *enic,
 	unsigned int len_left = skb->len - head_len;
 	int eop = (len_left == 0);
 
-	/* Queue the main skb fragment */
+	/* Queue the main skb fragment. The fragments are no larger
+	 * than max MTU(9000)+ETH_HDR_LEN(14) bytes, which is less
+	 * than WQ_ENET_MAX_DESC_LEN length. So only one descriptor
+	 * per fragment is queued.
+	 */
 	enic_queue_wq_desc(wq, skb,
 		pci_map_single(enic->pdev, skb->data,
 			head_len, PCI_DMA_TODEVICE),
@@ -547,7 +557,11 @@ static inline void enic_queue_wq_skb_csum_l4(struct enic *enic,
 	unsigned int csum_offset = hdr_len + skb->csum_offset;
 	int eop = (len_left == 0);
 
-	/* Queue the main skb fragment */
+	/* Queue the main skb fragment. The fragments are no larger
+	 * than max MTU(9000)+ETH_HDR_LEN(14) bytes, which is less
+	 * than WQ_ENET_MAX_DESC_LEN length. So only one descriptor
+	 * per fragment is queued.
+	 */
 	enic_queue_wq_desc_csum_l4(wq, skb,
 		pci_map_single(enic->pdev, skb->data,
 			head_len, PCI_DMA_TODEVICE),
@@ -565,10 +579,14 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 	struct vnic_wq *wq, struct sk_buff *skb, unsigned int mss,
 	int vlan_tag_insert, unsigned int vlan_tag)
 {
-	unsigned int head_len = skb_headlen(skb);
-	unsigned int len_left = skb->len - head_len;
+	unsigned int frag_len_left = skb_headlen(skb);
+	unsigned int len_left = skb->len - frag_len_left;
 	unsigned int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	int eop = (len_left == 0);
+	unsigned int len;
+	dma_addr_t dma_addr;
+	unsigned int offset = 0;
+	skb_frag_t *frag;
 
 	/* Preload TCP csum field with IP pseudo hdr calculated
 	 * with IP length set to zero.  HW will later add in length
@@ -584,17 +602,49 @@ static inline void enic_queue_wq_skb_tso(struct enic *enic,
 			&ipv6_hdr(skb)->daddr, 0, IPPROTO_TCP, 0);
 	}
 
-	/* Queue the main skb fragment */
-	enic_queue_wq_desc_tso(wq, skb,
-		pci_map_single(enic->pdev, skb->data,
-			head_len, PCI_DMA_TODEVICE),
-		head_len,
-		mss, hdr_len,
-		vlan_tag_insert, vlan_tag,
-		eop);
+	/* Queue WQ_ENET_MAX_DESC_LEN length descriptors
+	 * for the main skb fragment
+	 */
+	while (frag_len_left) {
+		len = min(frag_len_left, (unsigned int)WQ_ENET_MAX_DESC_LEN);
+		dma_addr = pci_map_single(enic->pdev, skb->data + offset,
+				len, PCI_DMA_TODEVICE);
+		enic_queue_wq_desc_tso(wq, skb,
+			dma_addr,
+			len,
+			mss, hdr_len,
+			vlan_tag_insert, vlan_tag,
+			eop && (len == frag_len_left));
+		frag_len_left -= len;
+		offset += len;
+	}
 
-	if (!eop)
-		enic_queue_wq_skb_cont(enic, wq, skb, len_left);
+	if (eop)
+		return;
+
+	/* Queue WQ_ENET_MAX_DESC_LEN length descriptors
+	 * for additional data fragments
+	 */
+	for (frag = skb_shinfo(skb)->frags; len_left; frag++) {
+		len_left -= frag->size;
+		frag_len_left = frag->size;
+		offset = frag->page_offset;
+
+		while (frag_len_left) {
+			len = min(frag_len_left,
+				(unsigned int)WQ_ENET_MAX_DESC_LEN);
+			dma_addr = pci_map_page(enic->pdev, frag->page,
+				offset, len,
+				PCI_DMA_TODEVICE);
+			enic_queue_wq_desc_cont(wq, skb,
+				dma_addr,
+				len,
+				(len_left == 0) &&
+				(len == frag_len_left));	/* EOP? */
+			frag_len_left -= len;
+			offset += len;
+		}
+	}
 }
 
 static inline void enic_queue_wq_skb(struct enic *enic,
@@ -647,7 +697,8 @@ static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	spin_lock_irqsave(&enic->wq_lock[0], flags);
 
-	if (vnic_wq_desc_avail(wq) < skb_shinfo(skb)->nr_frags + 1) {
+	if (vnic_wq_desc_avail(wq) <
+	    skb_shinfo(skb)->nr_frags + ENIC_DESC_MAX_SPLITS) {
 		netif_stop_queue(netdev);
 		/* This is a hard error, log it */
 		printk(KERN_ERR PFX "%s: BUG! Tx ring full when "
@@ -658,7 +709,7 @@ static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	enic_queue_wq_skb(enic, wq, skb);
 
-	if (vnic_wq_desc_avail(wq) < MAX_SKB_FRAGS + 1)
+	if (vnic_wq_desc_avail(wq) < MAX_SKB_FRAGS + ENIC_DESC_MAX_SPLITS)
 		netif_stop_queue(netdev);
 
 	spin_unlock_irqrestore(&enic->wq_lock[0], flags);

