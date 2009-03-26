From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/6] mlx4_en: Linear skb support for RX side.
Date: Thu, 26 Mar 2009 15:56:26 +0200
Message-ID: <49CB898A.60209@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53255 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752816AbZCZN5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 09:57:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allowing using linear skbs instead skb frags for certain rings.
Working with linear skbs shows better performance when working with
non TCP traffic (LRO shows better performance with skb frags).
Rss allows us to separate TCP from non TCP traffic and send the packets
to different rings.
Then, every ring that receives TCP traffic is assigned to work with skb frags,
while the ring that receives non TCP traffic works with linear skbs.
This change improves RX Bandwidth for small UDP messages (under mtu size)
in ~20%.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   16 ++-
 drivers/net/mlx4/en_rx.c     |  295 ++++++++++++++++++++++++++++++++++++------
 drivers/net/mlx4/mlx4_en.h   |    8 +-
 3 files changed, 268 insertions(+), 51 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 9f6644a..f52e897 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -334,7 +334,10 @@ static void mlx4_en_netpoll(struct net_device *dev)
 		cq = &priv->rx_cq[i];
 		spin_lock_irqsave(&cq->lock, flags);
 		napi_synchronize(&cq->napi);
-		mlx4_en_process_rx_cq(dev, cq, 0);
+		if (priv->rx_ring[i].use_frags)
+			mlx4_en_process_rx_cq(dev, cq, 0);
+		else
+			mlx4_en_process_rx_cq_skb(dev, cq, 0);
 		spin_unlock_irqrestore(&cq->lock, flags);
 	}
 }
@@ -561,7 +564,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	struct mlx4_en_rx_ring *rx_ring;
 	int rx_index = 0;
 	int tx_index = 0;
-	u16 stride;
 	int err = 0;
 	int i;
 	int j;
@@ -575,8 +577,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	dev->mtu = min(dev->mtu, priv->max_mtu);
 	mlx4_en_calc_rx_buf(dev);
 	mlx4_dbg(DRV, priv, "Rx buf size:%d\n", priv->rx_skb_size);
-	stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
-				    DS_SIZE * priv->num_frags);
 	/* Configure rx cq's and rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		cq = &priv->rx_cq[i];
@@ -868,8 +868,12 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 				      prof->rx_ring_size, i, RX))
 			goto err;

+		if (i > 0)
+			priv->rx_ring[i].use_frags = 1;
+		else
+			priv->rx_ring[i].use_frags = 0;
 		if (mlx4_en_create_rx_ring(priv, &priv->rx_ring[i],
-					   prof->rx_ring_size, priv->stride))
+					   prof->rx_ring_size))
 			goto err;
 	}

@@ -1015,8 +1019,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		goto out;
 	}

-	priv->stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
-					  DS_SIZE * MLX4_EN_MAX_RX_FRAGS);
 	err = mlx4_en_alloc_resources(priv);
 	if (err)
 		goto out;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index b8c7182..89f94a6 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -144,6 +144,17 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
 	}
 }

+static void
+mlx4_en_init_rx_desc_skb(struct mlx4_en_priv *priv,
+			 struct mlx4_en_rx_ring *ring, int index)
+{
+	struct mlx4_en_rx_desc *rx_desc = ring->buf + ring->stride * index;
+
+	/* Pre-link descriptor */
+	rx_desc->next.next_wqe_index = cpu_to_be16((index + 1) & ring->size_mask);
+	rx_desc->data->byte_count = cpu_to_be32(priv->rx_skb_size);
+	rx_desc->data->lkey = cpu_to_be32(priv->mdev->mr.key);
+}

 static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
 				 struct mlx4_en_rx_ring *ring, int index)
@@ -176,6 +187,35 @@ static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
 	}
 }

+static int
+mlx4_en_alloc_rx_skb(struct mlx4_en_priv *priv,
+		     struct mlx4_en_rx_desc *rx_desc,
+		     struct sk_buff **pskb)
+{
+	dma_addr_t dma;
+	int size = priv->rx_skb_size + NET_IP_ALIGN;
+	struct sk_buff *new_skb = alloc_skb(size, GFP_ATOMIC);
+
+	if (unlikely(new_skb == NULL))
+		return -ENOMEM;
+
+	new_skb->dev = priv->dev;
+	skb_reserve(new_skb, NET_IP_ALIGN);
+	dma = pci_map_single(priv->mdev->pdev, new_skb->data, size, DMA_FROM_DEVICE);
+	*pskb = new_skb;
+	rx_desc->data->addr = cpu_to_be64(dma);
+	return 0;
+}
+
+static int
+mlx4_en_prepare_rx_desc_skb(struct mlx4_en_priv *priv,
+			    struct mlx4_en_rx_ring *ring, int index)
+{
+	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
+	struct sk_buff **pskb = (struct sk_buff **) ring->rx_info + index;
+
+	return mlx4_en_alloc_rx_skb(priv, rx_desc, pskb);
+}

 static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 				   struct mlx4_en_rx_ring *ring, int index)
@@ -208,16 +248,22 @@ static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 	struct mlx4_en_rx_ring *ring;
 	int ring_ind;
 	int buf_ind;
+	int err;;

 	for (buf_ind = 0; buf_ind < priv->prof->rx_ring_size; buf_ind++) {
 		for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
 			ring = &priv->rx_ring[ring_ind];

-			if (mlx4_en_prepare_rx_desc(priv, ring,
-						    ring->actual_size)) {
+			if (ring->use_frags)
+				err = mlx4_en_prepare_rx_desc(priv, ring,
+							      ring->actual_size);
+			else
+				err = mlx4_en_prepare_rx_desc_skb(priv, ring,
+								  ring->actual_size);
+			if (err) {
 				if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
 					mlx4_err(mdev, "Failed to allocate "
-						       "enough rx buffers\n");
+						 "enough rx buffers\n");
 					return -ENOMEM;
 				} else {
 					if (netif_msg_rx_err(priv))
@@ -243,8 +289,12 @@ static int mlx4_en_fill_rx_buf(struct net_device *dev,
 	int err;

 	while ((u32) (ring->prod - ring->cons) < ring->actual_size) {
-		err = mlx4_en_prepare_rx_desc(priv, ring, ring->prod &
-					      ring->size_mask);
+		if (ring->use_frags)
+			err = mlx4_en_prepare_rx_desc(priv, ring, ring->prod &
+						      ring->size_mask);
+		else
+			err = mlx4_en_prepare_rx_desc_skb(priv, ring, ring->prod &
+							  ring->size_mask);
 		if (err) {
 			if (netif_msg_rx_err(priv))
 				mlx4_warn(priv->mdev,
@@ -266,6 +316,7 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct skb_frag_struct *skb_frags;
+	struct sk_buff *skb;
 	struct mlx4_en_rx_desc *rx_desc;
 	dma_addr_t dma;
 	int index;
@@ -279,17 +330,26 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
 	while (ring->cons != ring->prod) {
 		index = ring->cons & ring->size_mask;
 		rx_desc = ring->buf + (index << ring->log_stride);
-		skb_frags = ring->rx_info + (index << priv->log_rx_info);
 		mlx4_dbg(DRV, priv, "Processing descriptor:%d\n", index);

-		for (nr = 0; nr < priv->num_frags; nr++) {
-			mlx4_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
-			dma = be64_to_cpu(rx_desc->data[nr].addr);
+		if (ring->use_frags) {
+			skb_frags = ring->rx_info + (index << priv->log_rx_info);
+			for (nr = 0; nr < priv->num_frags; nr++) {
+				mlx4_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
+				dma = be64_to_cpu(rx_desc->data[nr].addr);

-			mlx4_dbg(DRV, priv, "Unmaping buffer at dma:0x%llx\n", (u64) dma);
-			pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
+				mlx4_dbg(DRV, priv, "Unmaping buffer at dma:0x%llx\n", (u64) dma);
+				pci_unmap_single(mdev->pdev, dma, skb_frags[nr].size,
+						 PCI_DMA_FROMDEVICE);
+				put_page(skb_frags[nr].page);
+			}
+		} else {
+			skb = *((struct sk_buff **) ring->rx_info + index);
+			dma = be64_to_cpu(rx_desc->data->addr);
+			pci_unmap_single(mdev->pdev, dma,
+					 priv->rx_skb_size + NET_IP_ALIGN,
 					 PCI_DMA_FROMDEVICE);
-			put_page(skb_frags[nr].page);
+			kfree_skb(skb);
 		}
 		++ring->cons;
 	}
@@ -332,7 +392,7 @@ out:


 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_rx_ring *ring, u32 size, u16 stride)
+			   struct mlx4_en_rx_ring *ring, u32 size)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
@@ -346,12 +406,18 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	ring->cons = 0;
 	ring->size = size;
 	ring->size_mask = size - 1;
-	ring->stride = stride;
+	ring->stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
+					  DS_SIZE * (ring->use_frags ?
+						     MLX4_EN_MAX_RX_FRAGS : 1));
 	ring->log_stride = ffs(ring->stride) - 1;
 	ring->buf_size = ring->size * ring->stride;

-	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
-					sizeof(struct skb_frag_struct));
+	if (ring->use_frags)
+		tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
+						sizeof(struct skb_frag_struct));
+	else
+		tmp = size * sizeof(struct sk_buff *);
+
 	ring->rx_info = vmalloc(tmp);
 	if (!ring->rx_info) {
 		mlx4_err(mdev, "Failed allocating rx_info ring\n");
@@ -422,22 +488,28 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		ring->actual_size = 0;
 		ring->cqn = priv->rx_cq[ring_ind].mcq.cqn;

-		ring->stride = stride;
+		if (ring->use_frags)
+			ring->stride = stride;
 		ring->log_stride = ffs(ring->stride) - 1;
 		ring->buf_size = ring->size * ring->stride;

 		memset(ring->buf, 0, ring->buf_size);
 		mlx4_en_update_rx_prod_db(ring);

-		/* Initailize all descriptors */
-		for (i = 0; i < ring->size; i++)
-			mlx4_en_init_rx_desc(priv, ring, i);
+		if (ring->use_frags) {
+			/* Initailize all descriptors */
+			for (i = 0; i < ring->size; i++)
+				mlx4_en_init_rx_desc(priv, ring, i);

-		/* Initialize page allocators */
-		err = mlx4_en_init_allocator(priv, ring);
-		if (err) {
-			 mlx4_err(mdev, "Failed initializing ring allocator\n");
-			 goto err_allocator;
+			/* Initialize page allocators */
+			err = mlx4_en_init_allocator(priv, ring);
+			if (err) {
+				mlx4_err(mdev, "Failed initializing ring allocator\n");
+				goto err_allocator;
+			}
+		} else {
+			for (i = 0; i < ring->size; i++)
+				mlx4_en_init_rx_desc_skb(priv, ring, i);
 		}

 		/* Fill Rx buffers */
@@ -487,7 +559,7 @@ err_buffers:

 	ring_ind = priv->rx_ring_num - 1;
 err_allocator:
-	while (ring_ind >= 0) {
+	while (ring_ind >= 1) {
 		mlx4_en_destroy_allocator(priv, &priv->rx_ring[ring_ind]);
 		ring_ind--;
 	}
@@ -513,7 +585,8 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,

 	mlx4_srq_free(mdev->dev, &ring->srq);
 	mlx4_en_free_rx_buf(priv, ring);
-	mlx4_en_destroy_allocator(priv, ring);
+	if (ring->use_frags)
+		mlx4_en_destroy_allocator(priv, ring);
 }


@@ -651,11 +724,159 @@ static void mlx4_en_copy_desc(struct mlx4_en_priv *priv,
 	}
 }

+static inline int invalid_cqe(struct mlx4_en_priv *priv,
+			      struct mlx4_cqe *cqe)
+{
+	/* Drop packet on bad receive or bad checksum */
+	if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
+		     MLX4_CQE_OPCODE_ERROR)) {
+		mlx4_err(priv->mdev, "CQE completed in error - vendor "
+			 "syndrom:%d syndrom:%d\n",
+			 ((struct mlx4_err_cqe *) cqe)->vendor_err_syndrome,
+			 ((struct mlx4_err_cqe *) cqe)->syndrome);
+		return 1;
+	}
+	if (unlikely(cqe->badfcs_enc & MLX4_CQE_BAD_FCS)) {
+		mlx4_dbg(RX_ERR, priv, "Accepted frame with bad FCS\n");
+		return 1;;
+	}
+
+	return 0;
+}
+
+static struct sk_buff *
+mlx4_en_get_rx_skb(struct mlx4_en_priv *priv,
+		   struct mlx4_en_rx_desc *rx_desc,
+		   struct sk_buff **pskb,
+		   unsigned int length)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct sk_buff *skb;
+	dma_addr_t dma;
+
+	if (length <= SMALL_PACKET_SIZE) {
+		skb = dev_alloc_skb(length + NET_IP_ALIGN);
+		if (unlikely(!skb))
+			return NULL;
+
+		skb_reserve(skb, NET_IP_ALIGN);
+		/* We are copying all relevant data to the skb - temporarily
+		 * synch buffers for the copy */
+		dma = be64_to_cpu(rx_desc->data->addr);
+		dma_sync_single_range_for_cpu(&mdev->pdev->dev, dma, 0,
+					      length, DMA_FROM_DEVICE);
+		skb_copy_to_linear_data(skb, (*pskb)->data, length);
+		dma_sync_single_range_for_device(&mdev->pdev->dev, dma, 0,
+						 length, DMA_FROM_DEVICE);
+
+	} else {
+		skb = *pskb;
+		if (unlikely(mlx4_en_alloc_rx_skb(priv, rx_desc, pskb)))
+			return NULL;
+
+		pci_unmap_single(mdev->pdev, be64_to_cpu(rx_desc->data->addr),
+				 be32_to_cpu(rx_desc->data->byte_count),
+				 PCI_DMA_FROMDEVICE);
+	}
+
+	skb->tail += length;
+	skb->len = length;
+	skb->truesize = length + sizeof(struct sk_buff);
+	return skb;
+}
+
+int mlx4_en_process_rx_cq_skb(struct net_device *dev,
+			      struct mlx4_en_cq *cq, int budget)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_cqe *cqe;
+	struct mlx4_en_rx_ring *ring = &priv->rx_ring[cq->ring];
+	struct mlx4_en_rx_desc *rx_desc;
+	struct sk_buff **pskb;
+	struct sk_buff *skb;
+	int index;
+	unsigned int length;
+	int polled = 0;
+	int ip_summed;
+
+	if (!priv->port_up)
+		return 0;
+
+	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
+	 * descriptor offset can be deduced from the CQE index instead of
+	 * reading 'cqe->index' */
+	index = cq->mcq.cons_index & ring->size_mask;
+	cqe = &cq->buf[index];
+
+	/* Process all completed CQEs */
+	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
+		    cq->mcq.cons_index & cq->size)) {
+
+		pskb = (struct sk_buff **) ring->rx_info + index;
+		rx_desc = ring->buf + (index << ring->log_stride);
+
+		/*
+		 * make sure we read the CQE after we read the ownership bit
+		 */
+		rmb();
+
+		if (invalid_cqe(priv, cqe))
+			goto next;
+
+		/*
+		 * Packet is OK - process it.
+		 */
+		length = be32_to_cpu(cqe->byte_cnt);
+		ring->bytes += length;
+		ring->packets++;
+
+		skb = mlx4_en_get_rx_skb(priv, rx_desc, pskb, length);
+		if (unlikely(!skb))
+			goto next;
+		skb->protocol = eth_type_trans(skb, dev);
+
+		if (likely(priv->rx_csum && cqe->checksum == 0xffff)) {
+			priv->port_stats.rx_chksum_good++;
+			ip_summed = CHECKSUM_UNNECESSARY;
+		} else {
+			priv->port_stats.rx_chksum_none++;
+			ip_summed = CHECKSUM_NONE;
+		}
+		skb->ip_summed = ip_summed;
+
+		/* Push it up the stack */
+		if (priv->vlgrp && (be32_to_cpu(cqe->vlan_my_qpn) &
+				    MLX4_CQE_VLAN_PRESENT_MASK)) {
+			vlan_hwaccel_receive_skb(skb, priv->vlgrp,
+						be16_to_cpu(cqe->sl_vid));
+		} else
+			netif_receive_skb(skb);
+
+		dev->last_rx = jiffies;
+
+next:
+		++cq->mcq.cons_index;
+		index = (cq->mcq.cons_index) & ring->size_mask;
+		cqe = &cq->buf[index];
+		if (++polled == budget)
+			goto out;
+	}
+
+out:
+	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
+	mlx4_cq_set_ci(&cq->mcq);
+	wmb(); /* ensure HW sees CQ consumer before we post new buffers */
+	ring->cons = cq->mcq.cons_index;
+	ring->prod += polled; /* Polled descriptors were realocated in place */
+	if (unlikely(!ring->full))
+		mlx4_en_fill_rx_buf(dev, ring);
+	mlx4_en_update_rx_prod_db(ring);
+	return polled;
+}

 int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int budget)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_cqe *cqe;
 	struct mlx4_en_rx_ring *ring = &priv->rx_ring[cq->ring];
 	struct skb_frag_struct *skb_frags;
@@ -689,19 +910,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 */
 		rmb();

-		/* Drop packet on bad receive or bad checksum */
-		if (unlikely((cqe->owner_sr_opcode & MLX4_CQE_OPCODE_MASK) ==
-						MLX4_CQE_OPCODE_ERROR)) {
-			mlx4_err(mdev, "CQE completed in error - vendor "
-				  "syndrom:%d syndrom:%d\n",
-				  ((struct mlx4_err_cqe *) cqe)->vendor_err_syndrome,
-				  ((struct mlx4_err_cqe *) cqe)->syndrome);
+		if (invalid_cqe(priv, cqe))
 			goto next;
-		}
-		if (unlikely(cqe->badfcs_enc & MLX4_CQE_BAD_FCS)) {
-			mlx4_dbg(RX_ERR, priv, "Accepted frame with bad FCS\n");
-			goto next;
-		}

 		/*
 		 * Packet is OK - process it.
@@ -828,7 +1038,10 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int done;

-	done = mlx4_en_process_rx_cq(dev, cq, budget);
+	if (priv->rx_ring[cq->ring].use_frags)
+		done = mlx4_en_process_rx_cq(dev, cq, budget);
+	else
+		done = mlx4_en_process_rx_cq_skb(dev, cq, budget);

 	/* If we used up all the quota - we're probably not done yet... */
 	if (done == budget)
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 8fe1d39..ed5229f 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -284,6 +284,7 @@ struct mlx4_en_rx_ring {
 	void *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
+	unsigned int use_frags;
 };


@@ -454,7 +455,6 @@ struct mlx4_en_priv {
 	int port;
 	int registered;
 	int allocated;
-	int stride;
 	int rx_csum;
 	u64 mac;
 	int mac_index;
@@ -524,8 +524,7 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring);

 int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_rx_ring *ring,
-			   u32 size, u16 stride);
+			   struct mlx4_en_rx_ring *ring, u32 size);
 void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_rx_ring *ring);
 int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv);
@@ -534,6 +533,9 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 int mlx4_en_process_rx_cq(struct net_device *dev,
 			  struct mlx4_en_cq *cq,
 			  int budget);
+int mlx4_en_process_rx_cq_skb(struct net_device *dev,
+			      struct mlx4_en_cq *cq,
+			      int budget);
 int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget);
 void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 			     int is_tx, int rss, int qpn, int cqn, int srqn,
-- 
1.6.1.3

