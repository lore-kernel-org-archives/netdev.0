From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/16] net/mlx5e: IPoIB, Xmit flow
Date: Thu, 13 Apr 2017 06:37:02 +0300
Message-ID: <20170413033706.19016-13-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41815 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756083AbdDMDhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:37:54 -0400
In-Reply-To: <20170413033706.19016-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement mlx5e's IPoIB SKB transmit using the helper functions provided
by mlx5e ethernet tx flow, the only difference in the code between
mlx5e_xmit and mlx5i_xmit is that IPoIB has some extra fields to fill
(UD datagram segment) in the TX descriptor (WQE) and it doesn't need to
have any vlan handling.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/hw/mlx5/mlx5_ib.h            | 10 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 87 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 10 +++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.h |  3 +
 include/linux/mlx5/qp.h                         | 10 +++
 5 files changed, 110 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 3cd064b5f0bf..ce8ba617d46e 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -729,16 +729,6 @@ static inline struct mlx5_ib_mw *to_mmw(struct ib_mw *ibmw)
 	return container_of(ibmw, struct mlx5_ib_mw, ibmw);
 }
 
-struct mlx5_ib_ah {
-	struct ib_ah		ibah;
-	struct mlx5_av		av;
-};
-
-static inline struct mlx5_ib_ah *to_mah(struct ib_ah *ibah)
-{
-	return container_of(ibah, struct mlx5_ib_ah, ibah);
-}
-
 int mlx5_ib_db_map_user(struct mlx5_ib_ucontext *context, unsigned long virt,
 			struct mlx5_db *db);
 void mlx5_ib_db_unmap_user(struct mlx5_ib_ucontext *context, struct mlx5_db *db);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index ba664a1126cf..dda7db503043 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -503,3 +503,90 @@ void mlx5e_free_txqsq_descs(struct mlx5e_txqsq *sq)
 		sq->cc += wi->num_wqebbs;
 	}
 }
+
+#ifdef CONFIG_MLX5_CORE_IPOIB
+
+struct mlx5_wqe_eth_pad {
+	u8 rsvd0[16];
+};
+
+struct mlx5i_tx_wqe {
+	struct mlx5_wqe_ctrl_seg     ctrl;
+	struct mlx5_wqe_datagram_seg datagram;
+	struct mlx5_wqe_eth_pad      pad;
+	struct mlx5_wqe_eth_seg      eth;
+};
+
+static inline void
+mlx5i_txwqe_build_datagram(struct mlx5_av *av, u32 dqpn, u32 dqkey,
+			   struct mlx5_wqe_datagram_seg *dseg)
+{
+	memcpy(&dseg->av, av, sizeof(struct mlx5_av));
+	dseg->av.dqp_dct = cpu_to_be32(dqpn | MLX5_EXTENDED_UD_AV);
+	dseg->av.key.qkey.qkey = cpu_to_be32(dqkey);
+}
+
+netdev_tx_t mlx5i_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb,
+			  struct mlx5_av *av, u32 dqpn, u32 dqkey)
+{
+	struct mlx5_wq_cyc       *wq   = &sq->wq;
+	u16                       pi   = sq->pc & wq->sz_m1;
+	struct mlx5i_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+	struct mlx5e_tx_wqe_info *wi   = &sq->db.wqe_info[pi];
+
+	struct mlx5_wqe_ctrl_seg     *cseg = &wqe->ctrl;
+	struct mlx5_wqe_datagram_seg *datagram = &wqe->datagram;
+	struct mlx5_wqe_eth_seg      *eseg = &wqe->eth;
+
+	unsigned char *skb_data = skb->data;
+	unsigned int skb_len = skb->len;
+	u8  opcode = MLX5_OPCODE_SEND;
+	unsigned int num_bytes;
+	int num_dma;
+	u16 headlen;
+	u16 ds_cnt;
+	u16 ihs;
+
+	memset(wqe, 0, sizeof(*wqe));
+
+	mlx5i_txwqe_build_datagram(av, dqpn, dqkey, datagram);
+
+	mlx5e_txwqe_build_eseg_csum(sq, skb, eseg);
+
+	if (skb_is_gso(skb)) {
+		opcode = MLX5_OPCODE_LSO;
+		ihs = mlx5e_txwqe_build_eseg_gso(sq, skb, eseg, &num_bytes);
+	} else {
+		ihs = mlx5e_calc_min_inline(sq->min_inline_mode, skb);
+		num_bytes = max_t(unsigned int, skb->len, ETH_ZLEN);
+	}
+
+	ds_cnt = sizeof(*wqe) / MLX5_SEND_WQE_DS;
+	if (ihs) {
+		memcpy(eseg->inline_hdr.start, skb_data, ihs);
+		mlx5e_tx_skb_pull_inline(&skb_data, &skb_len, ihs);
+		eseg->inline_hdr.sz = cpu_to_be16(ihs);
+		ds_cnt += DIV_ROUND_UP(ihs - sizeof(eseg->inline_hdr.start), MLX5_SEND_WQE_DS);
+	}
+
+	headlen = skb_len - skb->data_len;
+	num_dma = mlx5e_txwqe_build_dsegs(sq, skb, skb_data, headlen,
+					  (struct mlx5_wqe_data_seg *)cseg + ds_cnt);
+	if (unlikely(num_dma < 0))
+		goto dma_unmap_wqe_err;
+
+	mlx5e_txwqe_complete(sq, skb, opcode, ds_cnt + num_dma,
+			     num_bytes, num_dma, wi, cseg);
+
+	return NETDEV_TX_OK;
+
+dma_unmap_wqe_err:
+	sq->stats.dropped++;
+	mlx5e_dma_unmap_wqe_err(sq, wi->num_dma);
+
+	dev_kfree_skb_any(skb);
+
+	return NETDEV_TX_OK;
+}
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index bd56f36066b3..c468aaedf0a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -393,6 +393,16 @@ int mlx5i_detach_mcast(struct net_device *netdev, struct ib_device *hca,
 	return err;
 }
 
+int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
+	       struct ib_ah *address, u32 dqpn, u32 dqkey)
+{
+	struct mlx5e_priv *epriv = mlx5i_epriv(dev);
+	struct mlx5e_txqsq *sq   = epriv->txq2sq[skb_get_queue_mapping(skb)];
+	struct mlx5_ib_ah *mah   = to_mah(address);
+
+	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, dqkey);
+}
+
 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
 	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_IB)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
index 25b8b8a33e24..89bca182464c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
@@ -47,4 +47,7 @@ struct mlx5i_priv {
 /* Extract mlx5e_priv from IPoIB netdev */
 #define mlx5i_epriv(netdev) ((void *)(((struct mlx5i_priv *)netdev_priv(netdev))->mlx5e_priv))
 
+netdev_tx_t mlx5i_sq_xmit(struct mlx5e_txqsq *sq, struct sk_buff *skb,
+			  struct mlx5_av *av, u32 dqpn, u32 dqkey);
+
 #endif /* __MLX5E_IPOB_H__ */
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 3096370fe831..bef80d0a0e30 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -295,6 +295,16 @@ struct mlx5_av {
 	u8	rgid[16];
 };
 
+struct mlx5_ib_ah {
+	struct ib_ah		ibah;
+	struct mlx5_av		av;
+};
+
+static inline struct mlx5_ib_ah *to_mah(struct ib_ah *ibah)
+{
+	return container_of(ibah, struct mlx5_ib_ah, ibah);
+}
+
 struct mlx5_wqe_datagram_seg {
 	struct mlx5_av	av;
 };
-- 
2.11.0
