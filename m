From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 03/14] net/mlx4_en: Avoid calling bswap in tx fast path
Date: Mon,  6 Oct 2014 09:15:52 +0300
Message-ID: <1412576163-7224-4-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:57145 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751252AbaJFGQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:16:32 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

- doorbell_qpn is stored in the cpu_to_be32() way to avoid bswap() in fast
  path.
- mdev->mr.key stored in ring->mr_key to also avoid bswap() and access to
  cold cache line.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 17 ++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 ++-
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d2f06a7..3ea17f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -195,7 +195,8 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	memset(ring->buf, 0, ring->buf_size);
 
 	ring->qp_state = MLX4_QP_STATE_RST;
-	ring->doorbell_qpn = ring->qp.qpn << 8;
+	ring->doorbell_qpn = cpu_to_be32(ring->qp.qpn << 8);
+	ring->mr_key = cpu_to_be32(mdev->mr.key);
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
 				ring->cqn, user_prio, &ring->context);
@@ -654,7 +655,6 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
 	struct device *ddev = priv->ddev;
 	struct mlx4_en_tx_ring *ring;
 	struct mlx4_en_tx_desc *tx_desc;
@@ -769,7 +769,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto tx_drop_unmap;
 
 			data->addr = cpu_to_be64(dma);
-			data->lkey = cpu_to_be32(mdev->mr.key);
+			data->lkey = ring->mr_key;
 			wmb();
 			data->byte_count = cpu_to_be32(skb_frag_size(frag));
 			--data;
@@ -787,7 +787,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 				goto tx_drop_unmap;
 
 			data->addr = cpu_to_be64(dma);
-			data->lkey = cpu_to_be32(mdev->mr.key);
+			data->lkey = ring->mr_key;
 			wmb();
 			data->byte_count = cpu_to_be32(byte_count);
 		}
@@ -879,9 +879,12 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
 
+	real_size = (real_size / 16) & 0x3f;
+
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
 	    !vlan_tx_tag_present(skb) && send_doorbell) {
-		tx_desc->ctrl.bf_qpn |= cpu_to_be32(ring->doorbell_qpn);
+		tx_desc->ctrl.bf_qpn = ring->doorbell_qpn |
+				       cpu_to_be32(real_size);
 
 		op_own |= htonl((bf_index & 0xffff) << 8);
 		/* Ensure new descriptor hits memory
@@ -911,8 +914,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_desc->ctrl.owner_opcode = op_own;
 		if (send_doorbell) {
 			wmb();
-			iowrite32be(ring->doorbell_qpn,
-				    ring->bf.uar->map + MLX4_SEND_DOORBELL);
+			iowrite32(ring->doorbell_qpn,
+				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
 		} else {
 			ring->xmit_more++;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index b7bde95..ab34461 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -279,7 +279,8 @@ struct mlx4_en_tx_ring {
 	u16			stride;
 	u16			cqn;	/* index of port CQ associated with this ring */
 	u32			buf_size;
-	u32			doorbell_qpn;
+	__be32			doorbell_qpn;
+	__be32			mr_key;
 	void			*buf;
 	struct mlx4_en_tx_info	*tx_info;
 	u8			*bounce_buf;
-- 
1.8.3.1
