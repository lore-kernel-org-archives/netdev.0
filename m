From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 21/25] net/mlx5e: Export send function for IB link type
Date: Mon, 13 Mar 2017 20:31:32 +0200
Message-ID: <1489429896-10781-22-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49835 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750846AbdCMScH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:07 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The function will be used in IB link in order to send packets.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 55 +++++++++++++++++++++++++
 include/linux/mlx5/driver.h                     |  5 ++-
 2 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 22443ce778ff..fea06be30393 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -435,6 +435,61 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 	return mlx5e_sq_xmit(sq, skb);
 }
 
+static int s_ctrl_seg = sizeof(struct mlx5_wqe_ctrl_seg);
+static int s_datagram_seg = sizeof(struct mlx5_wqe_datagram_seg);
+static int s_pad = sizeof(struct mlx5_wqe_eth_pad);
+static int s_eth_seg = sizeof(struct mlx5_wqe_eth_seg);
+static netdev_tx_t mlx5i_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb,
+				 struct mlx5_av *av, u32 dqpn, u32 dqkey)
+{
+	struct mlx5_wq_cyc       *wq   = &sq->wq;
+	u16                      pi    = sq->pc & wq->sz_m1;
+	void                     *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+	struct mlx5e_tx_wqe_info *wi   = &sq->db.txq.wqe_info[pi];
+
+	struct mlx5_wqe_ctrl_seg *ctrl_seg = wqe;
+	struct mlx5_wqe_datagram_seg *datagram_seg =
+			wqe + s_ctrl_seg;
+	struct mlx5_wqe_eth_pad *pad =
+			(void *)datagram_seg + s_datagram_seg;
+	struct mlx5_wqe_eth_seg  *ether_seg =
+			(void *)pad + s_pad;
+	struct mlx5_wqe_data_seg *data_seg;
+
+	int tot = s_ctrl_seg + s_datagram_seg + s_pad + s_eth_seg;
+
+	memset(wqe, 0, tot);
+
+	mlx5n_sq_build_datagram_seg(sq, datagram_seg, av, dqpn, dqkey, skb);
+
+	mlx5n_sq_build_ether_seg(sq, wi, ether_seg, skb);
+
+	wi->ds_cnt  = tot / MLX5_SEND_WQE_DS;
+	wi->ds_cnt += DIV_ROUND_UP(wi->ihs - sizeof(ether_seg->inline_hdr_start),
+			MLX5_SEND_WQE_DS);
+	data_seg = (struct mlx5_wqe_data_seg *)ctrl_seg + wi->ds_cnt;
+
+	if (mlx5n_sq_build_data_seg(sq, wi, data_seg, skb) < 0)
+		goto out;
+
+	mlx5n_sq_fill_ctrl_seg_and_send(sq, wi, ctrl_seg, skb, pi);
+
+out:
+	return NETDEV_TX_OK;
+}
+
+netdev_tx_t mlx5i_xmit(struct sk_buff *skb, void *p,
+		       struct mlx5_av *av, u32 dqpn, u32 dqkey)
+{
+	struct mlx5e_priv *priv = p;
+	struct mlx5e_sq *sq;
+
+	sq = priv->txq_to_sq_map[skb_get_queue_mapping(skb)];
+
+	return mlx5i_sq_xmit(sq, skb, av, dqpn, dqkey);
+}
+EXPORT_SYMBOL(mlx5i_xmit);
+
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 {
 	struct mlx5e_sq *sq;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index c18be51287e7..6d2ac932d321 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -1133,6 +1133,8 @@ struct mlx5i_create_ext_param {
 	u32	qpn;
 };
 
+struct mlx5_av;
+
 struct net_device *mlx5i_create_netdev(struct mlx5_core_dev *mdev,
 				       const char *name,
 				       void (*setup)(struct net_device *dev),
@@ -1141,5 +1143,6 @@ struct net_device *mlx5i_create_netdev(struct mlx5_core_dev *mdev,
 void mlx5i_detach(struct mlx5_core_dev *mdev, void *vpriv);
 int mlx5i_close(void *vpriv);
 int mlx5i_open(void *vpriv);
-
+netdev_tx_t mlx5i_xmit(struct sk_buff *skb, void *p, struct mlx5_av *av,
+		       u32 dqpn, u32 dqkey);
 #endif /* MLX5_DRIVER_H */
-- 
1.8.3.1
