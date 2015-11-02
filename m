From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [net-next v4 3/8] dpaa_eth: add support for S/G frames
Date: Mon, 2 Nov 2015 19:31:35 +0200
Message-ID: <1446485500-9782-4-git-send-email-madalin.bucur@freescale.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <scottwood@freescale.com>,
	<igal.liberman@freescale.com>, <roy.pledge@freescale.com>,
	<ppc@mindchasers.com>, <joe@perches.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>, <gregkh@linuxfoundation.org>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0131.outbound.protection.outlook.com ([207.46.100.131]:40455
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753877AbbKBQsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2015 11:48:13 -0500
In-Reply-To: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for Scater/Gather (S/G) frames. The FMan can place
the frame content into multiple buffers and provide a S/G Table
(SGT) into one first buffer with references to the others.

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |   6 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.h     |   2 +-
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.c  |  50 ++-
 .../net/ethernet/freescale/dpaa/dpaa_eth_common.h  |   2 +
 drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c  | 335 +++++++++++++++++++--
 5 files changed, 374 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 8381616..31d55b4 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -463,6 +463,12 @@ static int dpa_private_netdev_init(struct net_device *net_dev)
 	net_dev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				 NETIF_F_LLTX);
 
+	/* Advertise S/G and HIGHDMA support for private interfaces */
+	net_dev->hw_features |= NETIF_F_SG | NETIF_F_HIGHDMA;
+	/* Recent kernels enable GSO automatically, if
+	 * we declare NETIF_F_SG. For conformity, we'll
+	 * still declare GSO explicitly.
+	 */
 	net_dev->features |= NETIF_F_GSO;
 
 	return dpa_netdev_init(net_dev, mac_addr, tx_timeout);
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
index 1cc8682..1ba6617 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
@@ -347,7 +347,7 @@ static inline void clear_fd(struct qm_fd *fd)
 }
 
 static inline int _dpa_tx_fq_to_id(const struct dpa_priv_s *priv,
-				   struct qman_fq *tx_fq)
+		struct qman_fq *tx_fq)
 {
 	int i;
 
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
index 963be4d8..b36cbca 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c
@@ -1177,10 +1177,42 @@ void dpaa_eth_init_ports(struct mac_device *mac_dev,
 			      port_fqs->rx_defq, &buf_layout[RX]);
 }
 
+void dpa_release_sgt(struct qm_sg_entry *sgt)
+{
+	struct dpa_bp *dpa_bp;
+	struct bm_buffer bmb[DPA_BUFF_RELEASE_MAX];
+	u8 i = 0, j;
+
+	memset(bmb, 0, sizeof(bmb));
+
+	do {
+		dpa_bp = dpa_bpid2pool(sgt[i].bpid);
+		DPA_ERR_ON(!dpa_bp);
+
+		j = 0;
+		do {
+			DPA_ERR_ON(sgt[i].extension);
+
+			bmb[j].hi = sgt[i].addr_hi;
+			bmb[j].lo = be32_to_cpu(sgt[i].addr_lo);
+
+			j++; i++;
+		} while (j < ARRAY_SIZE(bmb) &&
+				!sgt[i - 1].final &&
+				sgt[i - 1].bpid == sgt[i].bpid);
+
+		while (bman_release(dpa_bp->pool, bmb, j, 0))
+			cpu_relax();
+	} while (!sgt[i - 1].final);
+}
+
 void dpa_fd_release(const struct net_device *net_dev, const struct qm_fd *fd)
 {
+	struct qm_sg_entry *sgt;
 	struct dpa_bp *dpa_bp;
 	struct bm_buffer bmb;
+	dma_addr_t addr;
+	void *vaddr;
 
 	memset(&bmb, 0, sizeof(bmb));
 	bm_buffer_set64(&bmb, fd->addr);
@@ -1188,7 +1220,23 @@ void dpa_fd_release(const struct net_device *net_dev, const struct qm_fd *fd)
 	dpa_bp = dpa_bpid2pool(fd->bpid);
 	DPA_ERR_ON(!dpa_bp);
 
-	DPA_ERR_ON(fd->format == qm_fd_sg);
+	if (fd->format == qm_fd_sg) {
+		vaddr = phys_to_virt(fd->addr);
+		sgt = vaddr + dpa_fd_offset(fd);
+
+		dma_unmap_single(dpa_bp->dev, qm_fd_addr(fd), dpa_bp->size,
+				 DMA_BIDIRECTIONAL);
+
+		dpa_release_sgt(sgt);
+
+		addr = dma_map_single(dpa_bp->dev, vaddr, dpa_bp->size,
+				      DMA_BIDIRECTIONAL);
+		if (dma_mapping_error(dpa_bp->dev, addr)) {
+			dev_err(dpa_bp->dev, "DMA mapping failed");
+			return;
+		}
+		bm_buffer_set64(&bmb, addr);
+	}
 
 	while (bman_release(dpa_bp->pool, &bmb, 1, 0))
 		cpu_relax();
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
index 68843c0..9df8f14 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h
@@ -37,6 +37,7 @@
 
 #include "dpaa_eth.h"
 
+#define DPA_SGT_MAX_ENTRIES 16 /* maximum number of entries in SG Table */
 #define DPA_BUFF_RELEASE_MAX 8 /* maximum number of buffers released at once */
 
 /* used in napi related functions */
@@ -90,6 +91,7 @@ void dpaa_eth_init_ports(struct mac_device *mac_dev,
 			 struct fm_port_fqs *port_fqs,
 			 struct dpa_buffer_layout_s *buf_layout,
 			 struct device *dev);
+void dpa_release_sgt(struct qm_sg_entry *sgt);
 void dpa_fd_release(const struct net_device *net_dev, const struct qm_fd *fd);
 int dpa_enable_tx_csum(struct dpa_priv_s *priv,
 		       struct sk_buff *skb,
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
index 115798b..af83ac2c 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth_sg.c
@@ -53,6 +53,31 @@
 		skb = *(skbh + (off)); \
 	}
 
+/* DMA map and add a page frag back into the bpool.
+ * @vaddr fragment must have been allocated with netdev_alloc_frag(),
+ * specifically for fitting into @dpa_bp.
+ */
+static void dpa_bp_recycle_frag(struct dpa_bp *dpa_bp, unsigned long vaddr,
+				int *count_ptr)
+{
+	struct bm_buffer bmb;
+	dma_addr_t addr;
+
+	addr = dma_map_single(dpa_bp->dev, (void *)vaddr, dpa_bp->size,
+			      DMA_BIDIRECTIONAL);
+	if (unlikely(dma_mapping_error(dpa_bp->dev, addr))) {
+		dev_err(dpa_bp->dev, "DMA mapping failed");
+		return;
+	}
+
+	bm_buffer_set64(&bmb, addr);
+
+	while (bman_release(dpa_bp->pool, &bmb, 1, 0))
+		cpu_relax();
+
+	(*count_ptr)++;
+}
+
 static int _dpa_bp_add_8_bufs(const struct dpa_bp *dpa_bp)
 {
 	struct bm_buffer bmb[8];
@@ -187,16 +212,49 @@ int dpaa_eth_refill_bpools(struct dpa_bp *dpa_bp, int *countptr)
 struct sk_buff *_dpa_cleanup_tx_fd(const struct dpa_priv_s *priv,
 				   const struct qm_fd *fd)
 {
+	const struct qm_sg_entry *sgt;
+	int i;
 	struct dpa_bp *dpa_bp = priv->dpa_bp;
 	dma_addr_t addr = qm_fd_addr(fd);
 	struct sk_buff **skbh;
 	struct sk_buff *skb = NULL;
 	const enum dma_data_direction dma_dir = DMA_TO_DEVICE;
+	int nr_frags;
+
 
 	/* retrieve skb back pointer */
 	DPA_READ_SKB_PTR(skb, skbh, phys_to_virt(addr), 0);
-	dma_unmap_single(dpa_bp->dev, addr,
-			 skb_tail_pointer(skb) - (u8 *)skbh, dma_dir);
+
+	if (unlikely(fd->format == qm_fd_sg)) {
+		nr_frags = skb_shinfo(skb)->nr_frags;
+		dma_unmap_single(dpa_bp->dev, addr, dpa_fd_offset(fd) +
+				 sizeof(struct qm_sg_entry) * (1 + nr_frags),
+				 dma_dir);
+
+		/* The sgt buffer has been allocated with netdev_alloc_frag(),
+		 * it's from lowmem.
+		 */
+		sgt = phys_to_virt(addr + dpa_fd_offset(fd));
+
+		/* sgt[0] is from lowmem, was dma_map_single()-ed */
+		dma_unmap_single(dpa_bp->dev, (dma_addr_t)sgt[0].addr,
+				 sgt[0].length, dma_dir);
+
+		/* remaining pages were mapped with dma_map_page() */
+		for (i = 1; i < nr_frags; i++) {
+			DPA_ERR_ON(sgt[i].extension);
+
+			dma_unmap_page(dpa_bp->dev, (dma_addr_t)sgt[i].addr,
+				       sgt[i].length, dma_dir);
+		}
+
+		/* Free the page frag that we allocated on Tx */
+		put_page(virt_to_head_page(sgt));
+	} else {
+		dma_unmap_single(dpa_bp->dev, addr,
+				 skb_tail_pointer(skb) - (u8 *)skbh, dma_dir);
+	}
+
 	return skb;
 }
 
@@ -230,6 +288,107 @@ static struct sk_buff *contig_fd_to_skb(const struct dpa_priv_s *priv,
 	return skb;
 }
 
+/* Build an skb with the data of the first S/G entry in the linear portion and
+ * the rest of the frame as skb fragments.
+ *
+ * The page fragment holding the S/G Table is recycled here.
+ */
+static struct sk_buff *sg_fd_to_skb(const struct dpa_priv_s *priv,
+				    const struct qm_fd *fd,
+				    int *count_ptr)
+{
+	const struct qm_sg_entry *sgt;
+	dma_addr_t addr = qm_fd_addr(fd);
+	ssize_t fd_off = dpa_fd_offset(fd);
+	dma_addr_t sg_addr;
+	void *vaddr, *sg_vaddr;
+	struct dpa_bp *dpa_bp;
+	struct page *page, *head_page;
+	int frag_offset, frag_len;
+	int page_offset;
+	int i;
+	struct sk_buff *skb = NULL, *skb_tmp, **skbh;
+
+	vaddr = phys_to_virt(addr);
+	DPA_ERR_ON(!IS_ALIGNED((unsigned long)vaddr, SMP_CACHE_BYTES));
+
+	dpa_bp = priv->dpa_bp;
+	/* Iterate through the SGT entries and add data buffers to the skb */
+	sgt = vaddr + fd_off;
+	for (i = 0; i < DPA_SGT_MAX_ENTRIES; i++) {
+		/* Extension bit is not supported */
+		DPA_ERR_ON(sgt[i].extension);
+
+		/* We use a single global Rx pool */
+		DPA_ERR_ON(dpa_bp != dpa_bpid2pool(sgt[i].bpid));
+
+		sg_addr = qm_sg_addr(&sgt[i]);
+		sg_vaddr = phys_to_virt(sg_addr);
+		DPA_ERR_ON(!IS_ALIGNED((unsigned long)sg_vaddr,
+				       SMP_CACHE_BYTES));
+
+		dma_unmap_single(dpa_bp->dev, sg_addr, dpa_bp->size,
+				 DMA_BIDIRECTIONAL);
+		if (i == 0) {
+			DPA_READ_SKB_PTR(skb, skbh, sg_vaddr, -1);
+			DPA_ERR_ON(skb->head != sg_vaddr);
+
+			skb->ip_summed = CHECKSUM_NONE;
+
+			/* Make sure forwarded skbs will have enough space
+			 * on Tx, if extra headers are added.
+			 */
+			DPA_ERR_ON(fd_off != priv->rx_headroom);
+			skb_reserve(skb, fd_off);
+			skb_put(skb, sgt[i].length);
+		} else {
+			/* Not the first S/G entry; all data from buffer will
+			 * be added in an skb fragment; fragment index is offset
+			 * by one since first S/G entry was incorporated in the
+			 * linear part of the skb.
+			 *
+			 * Caution: 'page' may be a tail page.
+			 */
+			DPA_READ_SKB_PTR(skb_tmp, skbh, sg_vaddr, -1);
+			page = virt_to_page(sg_vaddr);
+			head_page = virt_to_head_page(sg_vaddr);
+
+			/* Free (only) the skbuff shell because its data buffer
+			 * is already a frag in the main skb.
+			 */
+			get_page(head_page);
+			dev_kfree_skb(skb_tmp);
+
+			/* Compute offset in (possibly tail) page */
+			page_offset = ((unsigned long)sg_vaddr &
+					(PAGE_SIZE - 1)) +
+				(page_address(page) - page_address(head_page));
+			/* page_offset only refers to the beginning of sgt[i];
+			 * but the buffer itself may have an internal offset.
+			 */
+			frag_offset = sgt[i].offset + page_offset;
+			frag_len = sgt[i].length;
+			/* skb_add_rx_frag() does no checking on the page; if
+			 * we pass it a tail page, we'll end up with
+			 * bad page accounting and eventually with segafults.
+			 */
+			skb_add_rx_frag(skb, i - 1, head_page, frag_offset,
+					frag_len, dpa_bp->size);
+		}
+		/* Update the pool count for the current {cpu x bpool} */
+		(*count_ptr)--;
+
+		if (sgt[i].final)
+			break;
+	}
+	WARN_ONCE(i == DPA_SGT_MAX_ENTRIES, "No final bit on SGT\n");
+
+	/* recycle the SGT fragment */
+	DPA_ERR_ON(dpa_bp != dpa_bpid2pool(fd->bpid));
+	dpa_bp_recycle_frag(dpa_bp, (unsigned long)vaddr, count_ptr);
+	return skb;
+}
+
 void _dpa_rx(struct net_device *net_dev,
 	     struct qman_portal *portal,
 	     const struct dpa_priv_s *priv,
@@ -257,17 +416,20 @@ void _dpa_rx(struct net_device *net_dev,
 	dpa_bp = priv->dpa_bp;
 	DPA_ERR_ON(dpa_bp != dpa_bpid2pool(fd->bpid));
 
-	/* prefetch the first 64 bytes of the frame */
+	/* prefetch the first 64 bytes of the frame or the SGT start */
 	dma_unmap_single(dpa_bp->dev, addr, dpa_bp->size, DMA_BIDIRECTIONAL);
 	prefetch(phys_to_virt(addr) + dpa_fd_offset(fd));
 
-	/* The only FD type that we may receive is contig */
-	DPA_ERR_ON((fd->format != qm_fd_contig));
+	/* The only FD types that we may receive are contig and S/G */
+	DPA_ERR_ON((fd->format != qm_fd_contig) && (fd->format != qm_fd_sg));
 
-	skb = contig_fd_to_skb(priv, fd);
+	if (likely(fd->format == qm_fd_contig))
+		skb = contig_fd_to_skb(priv, fd);
+	else
+		skb = sg_fd_to_skb(priv, fd, count_ptr);
 
-	/* Account for the contig buffer
-	 * having been removed from the pool.
+	/* Account for either the contig buffer or the SGT buffer (depending on
+	 * which case we were in) having been removed from the pool.
 	 */
 	(*count_ptr)--;
 	skb->protocol = eth_type_trans(skb, net_dev);
@@ -355,6 +517,121 @@ static int skb_to_contig_fd(struct dpa_priv_s *priv,
 	return 0;
 }
 
+static int skb_to_sg_fd(struct dpa_priv_s *priv,
+			struct sk_buff *skb, struct qm_fd *fd)
+{
+	struct dpa_bp *dpa_bp = priv->dpa_bp;
+	dma_addr_t addr;
+	struct sk_buff **skbh;
+	struct net_device *net_dev = priv->net_dev;
+	int err;
+
+	struct qm_sg_entry *sgt;
+	void *sgt_buf;
+	void *buffer_start;
+	skb_frag_t *frag;
+	int i, j;
+	const enum dma_data_direction dma_dir = DMA_TO_DEVICE;
+	const int nr_frags = skb_shinfo(skb)->nr_frags;
+
+	fd->format = qm_fd_sg;
+
+	/* get a page frag to store the SGTable */
+	sgt_buf = netdev_alloc_frag(priv->tx_headroom +
+		sizeof(struct qm_sg_entry) * (1 + nr_frags));
+	if (unlikely(!sgt_buf)) {
+		netdev_err(net_dev, "netdev_alloc_frag() failed\n");
+		return -ENOMEM;
+	}
+
+	/* Enable L3/L4 hardware checksum computation.
+	 *
+	 * We must do this before dma_map_single(DMA_TO_DEVICE), because we may
+	 * need to write into the skb.
+	 */
+	err = dpa_enable_tx_csum(priv, skb, fd,
+				 sgt_buf + DPA_TX_PRIV_DATA_SIZE);
+	if (unlikely(err < 0)) {
+		if (net_ratelimit())
+			netif_err(priv, tx_err, net_dev, "HW csum error: %d\n",
+				  err);
+		goto csum_failed;
+	}
+
+	sgt = (struct qm_sg_entry *)(sgt_buf + priv->tx_headroom);
+	sgt[0].bpid = 0xff;
+	sgt[0].offset = 0;
+	sgt[0].length = cpu_to_be32(skb_headlen(skb));
+	sgt[0].extension = 0;
+	sgt[0].final = 0;
+	addr = dma_map_single(dpa_bp->dev, skb->data, sgt[0].length, dma_dir);
+	if (unlikely(dma_mapping_error(dpa_bp->dev, addr))) {
+		dev_err(dpa_bp->dev, "DMA mapping failed");
+		err = -EINVAL;
+		goto sg0_map_failed;
+	}
+	sgt[0].addr_hi = (u8)upper_32_bits(addr);
+	sgt[0].addr_lo = cpu_to_be32(lower_32_bits(addr));
+
+	/* populate the rest of SGT entries */
+	for (i = 1; i <= nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i - 1];
+		sgt[i].bpid = 0xff;
+		sgt[i].offset = 0;
+		sgt[i].length = cpu_to_be32(frag->size);
+		sgt[i].extension = 0;
+		sgt[i].final = 0;
+
+		DPA_ERR_ON(!skb_frag_page(frag));
+		addr = skb_frag_dma_map(dpa_bp->dev, frag, 0, sgt[i].length,
+					dma_dir);
+		if (unlikely(dma_mapping_error(dpa_bp->dev, addr))) {
+			dev_err(dpa_bp->dev, "DMA mapping failed");
+			err = -EINVAL;
+			goto sg_map_failed;
+		}
+
+		/* keep the offset in the address */
+		sgt[i].addr_hi = (u8)upper_32_bits(addr);
+		sgt[i].addr_lo = cpu_to_be32(lower_32_bits(addr));
+	}
+	sgt[i - 1].final = 1;
+
+	fd->length20 = skb->len;
+	fd->offset = priv->tx_headroom;
+
+	/* DMA map the SGT page */
+	buffer_start = (void *)sgt - priv->tx_headroom;
+	DPA_WRITE_SKB_PTR(skb, skbh, buffer_start, 0);
+
+	addr = dma_map_single(dpa_bp->dev, buffer_start, priv->tx_headroom +
+			      sizeof(struct qm_sg_entry) * (1 + nr_frags),
+			      dma_dir);
+	if (unlikely(dma_mapping_error(dpa_bp->dev, addr))) {
+		dev_err(dpa_bp->dev, "DMA mapping failed");
+		err = -EINVAL;
+		goto sgt_map_failed;
+	}
+
+	fd->bpid = 0xff;
+	fd->cmd |= FM_FD_CMD_FCO;
+	fd->addr_hi = (u8)upper_32_bits(addr);
+	fd->addr_lo = lower_32_bits(addr);
+
+	return 0;
+
+sgt_map_failed:
+sg_map_failed:
+	for (j = 0; j < i; j++)
+		dma_unmap_page(dpa_bp->dev, qm_sg_addr(&sgt[j]),
+			       cpu_to_be32(sgt[j].length), dma_dir);
+sg0_map_failed:
+csum_failed:
+	put_page(virt_to_head_page(sgt_buf));
+
+	return err;
+}
+
 int dpa_tx(struct sk_buff *skb, struct net_device *net_dev)
 {
 	struct dpa_priv_s *priv;
@@ -363,6 +640,7 @@ int dpa_tx(struct sk_buff *skb, struct net_device *net_dev)
 	struct rtnl_link_stats64 *percpu_stats;
 	int err = 0;
 	const int queue_mapping = dpa_get_queue_mapping(skb);
+	bool nonlinear = skb_is_nonlinear(skb);
 	int *countptr, offset = 0;
 
 	priv = netdev_priv(net_dev);
@@ -373,19 +651,38 @@ int dpa_tx(struct sk_buff *skb, struct net_device *net_dev)
 
 	clear_fd(&fd);
 
-	/* We're going to store the skb backpointer at the beginning
-	 * of the data buffer, so we need a privately owned skb
-	 *
-	 * We've made sure skb is not shared in dev->priv_flags,
-	 * we need to verify the skb head is not cloned
-	 */
-	if (skb_cow_head(skb, priv->tx_headroom))
-		goto enomem;
+	if (!nonlinear) {
+		/* We're going to store the skb backpointer at the beginning
+		 * of the data buffer, so we need a privately owned skb
+		 *
+		 * We've made sure skb is not shared in dev->priv_flags,
+		 * we need to verify the skb head is not cloned
+		 */
+		if (skb_cow_head(skb, priv->tx_headroom))
+			goto enomem;
+
+		WARN_ON(skb_is_nonlinear(skb));
+	}
 
-	DPA_ERR_ON(skb_is_nonlinear(skb));
+	/* MAX_SKB_FRAGS is equal or larger than our DPA_SGT_MAX_ENTRIES;
+	 * make sure we don't feed FMan with more fragments than it supports.
+	 * Btw, we're using the first sgt entry to store the linear part of
+	 * the skb, so we're one extra frag short.
+	 */
+	if (nonlinear &&
+	    likely(skb_shinfo(skb)->nr_frags < DPA_SGT_MAX_ENTRIES)) {
+		/* Just create a S/G fd based on the skb */
+		err = skb_to_sg_fd(priv, skb, &fd);
+	} else {
+		/* If the egress skb contains more fragments than we support
+		 * we have no choice but to linearize it ourselves.
+		 */
+		if (unlikely(nonlinear) && __skb_linearize(skb))
+			goto enomem;
 
-	/* Finally, create a contig FD from this skb */
-	err = skb_to_contig_fd(priv, skb, &fd, countptr, &offset);
+		/* Finally, create a contig FD from this skb */
+		err = skb_to_contig_fd(priv, skb, &fd, countptr, &offset);
+	}
 	if (unlikely(err < 0))
 		goto skb_to_fd_failed;
 
-- 
1.7.11.7
