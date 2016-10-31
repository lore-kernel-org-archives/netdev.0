From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 07/14] nfp: use alloc_frag() and build_skb()
Date: Mon, 31 Oct 2016 20:43:15 +0000
Message-ID: <1477946602-19644-8-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35320 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034009AbcJaUoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:05 -0400
Received: by mail-wm0-f47.google.com with SMTP id a197so43036029wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:04 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speed up RX processing by moving to the alloc_frag()/build_skb()
paradigm.  Since we're no longer mapping the entire buffer for
DMA add helpers which take care of calculating offsets and
lengths.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   8 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 115 +++++++++++++--------
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   9 +-
 3 files changed, 82 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 9b90fab8a6df..9ca066b29f07 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -101,6 +101,10 @@
 /* Offload definitions */
 #define NFP_NET_N_VXLAN_PORTS	(NFP_NET_CFG_VXLAN_SZ / sizeof(__be16))
 
+#define NFP_NET_RX_BUF_HEADROOM	(NET_SKB_PAD + NET_IP_ALIGN)
+#define NFP_NET_RX_BUF_NON_DATA	(NFP_NET_RX_BUF_HEADROOM +		\
+				 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+
 /* Forward declarations */
 struct nfp_net;
 struct nfp_net_r_vector;
@@ -277,11 +281,11 @@ struct nfp_net_rx_hash {
 
 /**
  * struct nfp_net_rx_buf - software RX buffer descriptor
- * @skb:	sk_buff associated with this buffer
+ * @frag:	page fragment buffer
  * @dma_addr:	DMA mapping address of the buffer
  */
 struct nfp_net_rx_buf {
-	struct sk_buff *skb;
+	void *frag;
 	dma_addr_t dma_addr;
 };
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index abd4f17e89c7..449ec798a9b7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -50,6 +50,7 @@
 #include <linux/interrupt.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/page_ref.h>
 #include <linux/pci.h>
 #include <linux/pci_regs.h>
 #include <linux/msi.h>
@@ -80,6 +81,22 @@ void nfp_net_get_fw_version(struct nfp_net_fw_version *fw_ver,
 	put_unaligned_le32(reg, fw_ver);
 }
 
+static dma_addr_t
+nfp_net_dma_map_rx(struct nfp_net *nn, void *frag, unsigned int bufsz,
+		   int direction)
+{
+	return dma_map_single(&nn->pdev->dev, frag + NFP_NET_RX_BUF_HEADROOM,
+			      bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
+}
+
+static void
+nfp_net_dma_unmap_rx(struct nfp_net *nn, dma_addr_t dma_addr,
+		     unsigned int bufsz, int direction)
+{
+	dma_unmap_single(&nn->pdev->dev, dma_addr,
+			 bufsz - NFP_NET_RX_BUF_NON_DATA, direction);
+}
+
 /* Firmware reconfig
  *
  * Firmware reconfig may take a while so we have two versions of it -
@@ -1035,64 +1052,67 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 {
 	unsigned int fl_bufsz;
 
+	fl_bufsz = NFP_NET_RX_BUF_HEADROOM;
 	if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
-		fl_bufsz = NFP_NET_MAX_PREPEND;
+		fl_bufsz += NFP_NET_MAX_PREPEND;
 	else
-		fl_bufsz = nn->rx_offset;
+		fl_bufsz += nn->rx_offset;
 	fl_bufsz += ETH_HLEN + VLAN_HLEN * 2 + mtu;
 
+	fl_bufsz = SKB_DATA_ALIGN(fl_bufsz);
+	fl_bufsz += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
 	return fl_bufsz;
 }
 
 /**
- * nfp_net_rx_alloc_one() - Allocate and map skb for RX
+ * nfp_net_rx_alloc_one() - Allocate and map page frag for RX
  * @rx_ring:	RX ring structure of the skb
  * @dma_addr:	Pointer to storage for DMA address (output param)
  * @fl_bufsz:	size of freelist buffers
  *
- * This function will allcate a new skb, map it for DMA.
+ * This function will allcate a new page frag, map it for DMA.
  *
- * Return: allocated skb or NULL on failure.
+ * Return: allocated page frag or NULL on failure.
  */
-static struct sk_buff *
+static void *
 nfp_net_rx_alloc_one(struct nfp_net_rx_ring *rx_ring, dma_addr_t *dma_addr,
 		     unsigned int fl_bufsz)
 {
 	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
-	struct sk_buff *skb;
+	void *frag;
 
-	skb = netdev_alloc_skb(nn->netdev, fl_bufsz);
-	if (!skb) {
-		nn_warn_ratelimit(nn, "Failed to alloc receive SKB\n");
+	frag = netdev_alloc_frag(fl_bufsz);
+	if (!frag) {
+		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
 		return NULL;
 	}
 
-	*dma_addr = dma_map_single(&nn->pdev->dev, skb->data,
-				   fl_bufsz, DMA_FROM_DEVICE);
+	*dma_addr = nfp_net_dma_map_rx(nn, frag, fl_bufsz, DMA_FROM_DEVICE);
 	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
-		dev_kfree_skb_any(skb);
+		skb_free_frag(frag);
 		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
 		return NULL;
 	}
 
-	return skb;
+	return frag;
 }
 
 /**
  * nfp_net_rx_give_one() - Put mapped skb on the software and hardware rings
  * @rx_ring:	RX ring structure
- * @skb:	Skb to put on rings
+ * @frag:	page fragment buffer
  * @dma_addr:	DMA address of skb mapping
  */
 static void nfp_net_rx_give_one(struct nfp_net_rx_ring *rx_ring,
-				struct sk_buff *skb, dma_addr_t dma_addr)
+				void *frag, dma_addr_t dma_addr)
 {
 	unsigned int wr_idx;
 
 	wr_idx = rx_ring->wr_p % rx_ring->cnt;
 
 	/* Stash SKB and DMA address away */
-	rx_ring->rxbufs[wr_idx].skb = skb;
+	rx_ring->rxbufs[wr_idx].frag = frag;
 	rx_ring->rxbufs[wr_idx].dma_addr = dma_addr;
 
 	/* Fill freelist descriptor */
@@ -1127,9 +1147,9 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 	wr_idx = rx_ring->wr_p % rx_ring->cnt;
 	last_idx = rx_ring->cnt - 1;
 	rx_ring->rxbufs[wr_idx].dma_addr = rx_ring->rxbufs[last_idx].dma_addr;
-	rx_ring->rxbufs[wr_idx].skb = rx_ring->rxbufs[last_idx].skb;
+	rx_ring->rxbufs[wr_idx].frag = rx_ring->rxbufs[last_idx].frag;
 	rx_ring->rxbufs[last_idx].dma_addr = 0;
-	rx_ring->rxbufs[last_idx].skb = NULL;
+	rx_ring->rxbufs[last_idx].frag = NULL;
 
 	memset(rx_ring->rxds, 0, sizeof(*rx_ring->rxds) * rx_ring->cnt);
 	rx_ring->wr_p = 0;
@@ -1149,7 +1169,6 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 static void
 nfp_net_rx_ring_bufs_free(struct nfp_net *nn, struct nfp_net_rx_ring *rx_ring)
 {
-	struct pci_dev *pdev = nn->pdev;
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
@@ -1157,14 +1176,14 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 		 * fails to allocate enough buffers and calls here to free
 		 * already allocated ones.
 		 */
-		if (!rx_ring->rxbufs[i].skb)
+		if (!rx_ring->rxbufs[i].frag)
 			continue;
 
-		dma_unmap_single(&pdev->dev, rx_ring->rxbufs[i].dma_addr,
-				 rx_ring->bufsz, DMA_FROM_DEVICE);
-		dev_kfree_skb_any(rx_ring->rxbufs[i].skb);
+		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[i].dma_addr,
+				     rx_ring->bufsz, DMA_FROM_DEVICE);
+		skb_free_frag(rx_ring->rxbufs[i].frag);
 		rx_ring->rxbufs[i].dma_addr = 0;
-		rx_ring->rxbufs[i].skb = NULL;
+		rx_ring->rxbufs[i].frag = NULL;
 	}
 }
 
@@ -1182,10 +1201,10 @@ static void nfp_net_rx_ring_reset(struct nfp_net_rx_ring *rx_ring)
 	rxbufs = rx_ring->rxbufs;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++) {
-		rxbufs[i].skb =
+		rxbufs[i].frag =
 			nfp_net_rx_alloc_one(rx_ring, &rxbufs[i].dma_addr,
 					     rx_ring->bufsz);
-		if (!rxbufs[i].skb) {
+		if (!rxbufs[i].frag) {
 			nfp_net_rx_ring_bufs_free(nn, rx_ring);
 			return -ENOMEM;
 		}
@@ -1203,7 +1222,7 @@ static void nfp_net_rx_ring_fill_freelist(struct nfp_net_rx_ring *rx_ring)
 	unsigned int i;
 
 	for (i = 0; i < rx_ring->cnt - 1; i++)
-		nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[i].skb,
+		nfp_net_rx_give_one(rx_ring, rx_ring->rxbufs[i].frag,
 				    rx_ring->rxbufs[i].dma_addr);
 }
 
@@ -1338,8 +1357,13 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
 	r_vec->rx_drops++;
 	u64_stats_update_end(&r_vec->rx_sync);
 
+	/* skb is build based on the frag, free_skb() would free the frag
+	 * so to be able to reuse it we need an extra ref.
+	 */
+	if (skb && rxbuf && skb->head == rxbuf->frag)
+		page_ref_inc(virt_to_head_page(rxbuf->frag));
 	if (rxbuf)
-		nfp_net_rx_give_one(rx_ring, rxbuf->skb, rxbuf->dma_addr);
+		nfp_net_rx_give_one(rx_ring, rxbuf->frag, rxbuf->dma_addr);
 	if (skb)
 		dev_kfree_skb_any(skb);
 }
@@ -1360,10 +1384,12 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 	unsigned int data_len, meta_len;
-	struct sk_buff *skb, *new_skb;
+	struct nfp_net_rx_buf *rxbuf;
 	struct nfp_net_rx_desc *rxd;
 	dma_addr_t new_dma_addr;
+	struct sk_buff *skb;
 	int pkts_polled = 0;
+	void *new_frag;
 	int idx;
 
 	while (pkts_polled < budget) {
@@ -1381,21 +1407,23 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		rx_ring->rd_p++;
 		pkts_polled++;
 
-		skb = rx_ring->rxbufs[idx].skb;
-
-		new_skb = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr,
-					       nn->fl_bufsz);
-		if (!new_skb) {
-			nfp_net_rx_drop(r_vec, rx_ring, &rx_ring->rxbufs[idx],
-					NULL);
+		rxbuf =	&rx_ring->rxbufs[idx];
+		skb = build_skb(rxbuf->frag, nn->fl_bufsz);
+		if (unlikely(!skb)) {
+			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
+			continue;
+		}
+		new_frag = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr,
+						nn->fl_bufsz);
+		if (unlikely(!new_frag)) {
+			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
 			continue;
 		}
 
-		dma_unmap_single(&nn->pdev->dev,
-				 rx_ring->rxbufs[idx].dma_addr,
-				 nn->fl_bufsz, DMA_FROM_DEVICE);
+		nfp_net_dma_unmap_rx(nn, rx_ring->rxbufs[idx].dma_addr,
+				     nn->fl_bufsz, DMA_FROM_DEVICE);
 
-		nfp_net_rx_give_one(rx_ring, new_skb, new_dma_addr);
+		nfp_net_rx_give_one(rx_ring, new_frag, new_dma_addr);
 
 		/*         < meta_len >
 		 *  <-- [rx_offset] -->
@@ -1413,9 +1441,10 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		data_len = le16_to_cpu(rxd->rxd.data_len);
 
 		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC)
-			skb_reserve(skb, meta_len);
+			skb_reserve(skb, NFP_NET_RX_BUF_HEADROOM + meta_len);
 		else
-			skb_reserve(skb, nn->rx_offset);
+			skb_reserve(skb,
+				    NFP_NET_RX_BUF_HEADROOM + nn->rx_offset);
 		skb_put(skb, data_len - meta_len);
 
 		/* Stats update */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index f7c9a5bc4aa3..180cf70f0093 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -44,8 +44,8 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 	struct nfp_net_r_vector *r_vec = file->private;
 	struct nfp_net_rx_ring *rx_ring;
 	struct nfp_net_rx_desc *rxd;
-	struct sk_buff *skb;
 	struct nfp_net *nn;
+	void *frag;
 	int i;
 
 	rtnl_lock();
@@ -73,10 +73,9 @@ static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
 		seq_printf(file, "%04d: 0x%08x 0x%08x", i,
 			   rxd->vals[0], rxd->vals[1]);
 
-		skb = READ_ONCE(rx_ring->rxbufs[i].skb);
-		if (skb)
-			seq_printf(file, " skb->head=%p skb->data=%p",
-				   skb->head, skb->data);
+		frag = READ_ONCE(rx_ring->rxbufs[i].frag);
+		if (frag)
+			seq_printf(file, " frag=%p", frag);
 
 		if (rx_ring->rxbufs[i].dma_addr)
 			seq_printf(file, " dma_addr=%pad",
-- 
1.9.1
