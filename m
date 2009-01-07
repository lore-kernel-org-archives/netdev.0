From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/2] mlx4_en: Consider inline packets on completion
Date: Wed, 07 Jan 2009 17:04:18 +0200
Message-ID: <4964C472.2060906@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rdreier@cisco.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:57466 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759172AbZAGPFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 10:05:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Was trying to unmap work queue entries that had inline packets,
so naturally weren't mapped.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_tx.c   |   59 ++++++++++++++++++++++++-------------------
 drivers/net/mlx4/mlx4_en.h |    1 +
 2 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index ff4d752..4afd599 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -203,19 +203,21 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,

 	/* Optimize the common case when there are no wraparounds */
 	if (likely((void *) tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
-		if (tx_info->linear) {
-			pci_unmap_single(mdev->pdev,
-					 (dma_addr_t) be64_to_cpu(data->addr),
+		if (!tx_info->inl) {
+			if (tx_info->linear) {
+				pci_unmap_single(mdev->pdev,
+					(dma_addr_t) be64_to_cpu(data->addr),
 					 be32_to_cpu(data->byte_count),
 					 PCI_DMA_TODEVICE);
-			++data;
-		}
+				++data;
+			}

-		for (i = 0; i < frags; i++) {
-			frag = &skb_shinfo(skb)->frags[i];
-			pci_unmap_page(mdev->pdev,
-				       (dma_addr_t) be64_to_cpu(data[i].addr),
-				       frag->size, PCI_DMA_TODEVICE);
+			for (i = 0; i < frags; i++) {
+				frag = &skb_shinfo(skb)->frags[i];
+				pci_unmap_page(mdev->pdev,
+					(dma_addr_t) be64_to_cpu(data[i].addr),
+					frag->size, PCI_DMA_TODEVICE);
+			}
 		}
 		/* Stamp the freed descriptor */
 		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE; i += STAMP_STRIDE) {
@@ -224,27 +226,29 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 		}

 	} else {
-		if ((void *) data >= end) {
-			data = (struct mlx4_wqe_data_seg *)
-					(ring->buf + ((void *) data - end));
-		}
+		if (!tx_info->inl) {
+			if ((void *) data >= end) {
+				data = (struct mlx4_wqe_data_seg *)
+						(ring->buf + ((void *) data - end));
+			}

-		if (tx_info->linear) {
-			pci_unmap_single(mdev->pdev,
-					 (dma_addr_t) be64_to_cpu(data->addr),
+			if (tx_info->linear) {
+				pci_unmap_single(mdev->pdev,
+					(dma_addr_t) be64_to_cpu(data->addr),
 					 be32_to_cpu(data->byte_count),
 					 PCI_DMA_TODEVICE);
-			++data;
-		}
+				++data;
+			}

-		for (i = 0; i < frags; i++) {
-			/* Check for wraparound before unmapping */
-			if ((void *) data >= end)
-				data = (struct mlx4_wqe_data_seg *) ring->buf;
-			frag = &skb_shinfo(skb)->frags[i];
-			pci_unmap_page(mdev->pdev,
+			for (i = 0; i < frags; i++) {
+				/* Check for wraparound before unmapping */
+				if ((void *) data >= end)
+					data = (struct mlx4_wqe_data_seg *) ring->buf;
+				frag = &skb_shinfo(skb)->frags[i];
+				pci_unmap_page(mdev->pdev,
 					(dma_addr_t) be64_to_cpu(data->addr),
 					 frag->size, PCI_DMA_TODEVICE);
+			}
 		}
 		/* Stamp the freed descriptor */
 		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE; i += STAMP_STRIDE) {
@@ -790,8 +794,11 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 			wmb();
 			data->byte_count = cpu_to_be32(skb_headlen(skb) - lso_header_size);
 		}
-	} else
+		tx_info->inl = 0;
+	} else {
 		build_inline_wqe(tx_desc, skb, real_size, &vlan_tag, tx_ind, fragptr);
+		tx_info->inl = 1;
+	}

 	ring->prod += nr_txbb;

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 2e96c7b..08bf321 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -202,6 +202,7 @@ struct mlx4_en_tx_info {
 	u32 nr_txbb;
 	u8 linear;
 	u8 data_offset;
+	u8 inl;
 };


-- 
1.5.4

