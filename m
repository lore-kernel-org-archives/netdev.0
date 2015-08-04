From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/8] net/mlx5e: Light-weight netdev open/stop
Date: Tue,  4 Aug 2015 14:05:43 +0300
Message-ID: <1438686347-17370-5-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36438 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933411AbbHDLGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:21 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Create/destroy TIRs, TISs and flow tables upon PCI probe/remove rather
than upon the netdev ndo_open/stop.

Upon ndo_stop(), redirect all RX traffic to the (lately introduced)
"Drop RQ" and then close only the RX/TX rings, leaving the TIRs,
TISs and flow tables alive.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 237 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |  12 ++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |   2 +
 include/linux/mlx5/mlx5_ifc.h                      |   9 +-
 4 files changed, 184 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index baa7a69..33d08bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1301,14 +1301,18 @@ static void mlx5e_fill_rqt_rqns(struct mlx5e_priv *priv, void *rqtc,
 
 			ix = ix % priv->params.num_channels;
 			MLX5_SET(rqtc, rqtc, rq_num[i],
-				 priv->channel[ix]->rq.rqn);
+				 test_bit(MLX5E_STATE_OPENED, &priv->state) ?
+				 priv->channel[ix]->rq.rqn :
+				 priv->drop_rq.rqn);
 		}
 
 		break;
 
 	default: /* MLX5E_SINGLE_RQ_RQT */
 		MLX5_SET(rqtc, rqtc, rq_num[0],
-			 priv->channel[0]->rq.rqn);
+			 test_bit(MLX5E_STATE_OPENED, &priv->state) ?
+			 priv->channel[0]->rq.rqn :
+			 priv->drop_rq.rqn);
 
 		break;
 	}
@@ -1347,19 +1351,95 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 	return err;
 }
 
+static int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u32 *in;
+	void *rqtc;
+	int inlen;
+	int log_sz;
+	int sz;
+	int err;
+
+	log_sz = (rqt_ix == MLX5E_SINGLE_RQ_RQT) ? 0 :
+		  priv->params.rx_hash_log_tbl_sz;
+	sz = 1 << log_sz;
+
+	inlen = MLX5_ST_SZ_BYTES(modify_rqt_in) + sizeof(u32) * sz;
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	rqtc = MLX5_ADDR_OF(modify_rqt_in, in, ctx);
+
+	MLX5_SET(rqtc, rqtc, rqt_actual_size, sz);
+
+	mlx5e_fill_rqt_rqns(priv, rqtc, rqt_ix);
+
+	MLX5_SET(modify_rqt_in, in, bitmask.rqn_list, 1);
+
+	err = mlx5_core_modify_rqt(mdev, priv->rqtn[rqt_ix], in, inlen);
+
+	kvfree(in);
+
+	return err;
+}
+
 static void mlx5e_close_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 {
 	mlx5_core_destroy_rqt(priv->mdev, priv->rqtn[rqt_ix]);
 }
 
+static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
+{
+	if (!priv->params.lro_en)
+		return;
+
+#define ROUGH_MAX_L2_L3_HDR_SZ 256
+
+	MLX5_SET(tirc, tirc, lro_enable_mask,
+		 MLX5_TIRC_LRO_ENABLE_MASK_IPV4_LRO |
+		 MLX5_TIRC_LRO_ENABLE_MASK_IPV6_LRO);
+	MLX5_SET(tirc, tirc, lro_max_ip_payload_size,
+		 (priv->params.lro_wqe_sz -
+		  ROUGH_MAX_L2_L3_HDR_SZ) >> 8);
+	MLX5_SET(tirc, tirc, lro_timeout_period_usecs,
+		 MLX5_CAP_ETH(priv->mdev,
+			      lro_timer_supported_periods[3]));
+}
+
+static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	void *in;
+	void *tirc;
+	int inlen;
+	int err;
+
+	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	MLX5_SET(modify_tir_in, in, bitmask.lro, 1);
+	tirc = MLX5_ADDR_OF(modify_tir_in, in, ctx);
+
+	mlx5e_build_tir_ctx_lro(tirc, priv);
+
+	err = mlx5_core_modify_tir(mdev, priv->tirn[tt], in, inlen);
+
+	kvfree(in);
+
+	return err;
+}
+
 static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 {
 	void *hfso = MLX5_ADDR_OF(tirc, tirc, rx_hash_field_selector_outer);
 
 	MLX5_SET(tirc, tirc, transport_domain, priv->tdn);
 
-#define ROUGH_MAX_L2_L3_HDR_SZ 256
-
 #define MLX5_HASH_IP            (MLX5_HASH_FIELD_SEL_SRC_IP   |\
 				 MLX5_HASH_FIELD_SEL_DST_IP)
 
@@ -1372,17 +1452,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 				 MLX5_HASH_FIELD_SEL_DST_IP   |\
 				 MLX5_HASH_FIELD_SEL_IPSEC_SPI)
 
-	if (priv->params.lro_en) {
-		MLX5_SET(tirc, tirc, lro_enable_mask,
-			 MLX5_TIRC_LRO_ENABLE_MASK_IPV4_LRO |
-			 MLX5_TIRC_LRO_ENABLE_MASK_IPV6_LRO);
-		MLX5_SET(tirc, tirc, lro_max_ip_payload_size,
-			 (priv->params.lro_wqe_sz -
-			  ROUGH_MAX_L2_L3_HDR_SZ) >> 8);
-		MLX5_SET(tirc, tirc, lro_timeout_period_usecs,
-			 MLX5_CAP_ETH(priv->mdev,
-				      lro_timer_supported_periods[3]));
-	}
+	mlx5e_build_tir_ctx_lro(tirc, priv);
 
 	MLX5_SET(tirc, tirc, disp_type, MLX5_TIRC_DISP_TYPE_INDIRECT);
 
@@ -1568,12 +1638,20 @@ static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
 	return 0;
 }
 
+static void mlx5e_redirect_rqts(struct mlx5e_priv *priv)
+{
+	mlx5e_redirect_rqt(priv, MLX5E_INDIRECTION_RQT);
+	mlx5e_redirect_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+}
+
 int mlx5e_open_locked(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	int num_txqs;
 	int err;
 
+	set_bit(MLX5E_STATE_OPENED, &priv->state);
+
 	num_txqs = priv->params.num_channels * priv->params.num_tc;
 	netif_set_real_num_tx_queues(netdev, num_txqs);
 	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
@@ -1582,83 +1660,32 @@ int mlx5e_open_locked(struct net_device *netdev)
 	if (err)
 		return err;
 
-	err = mlx5e_open_tises(priv);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_tises failed, %d\n",
-			   __func__, err);
-		return err;
-	}
-
 	err = mlx5e_open_channels(priv);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
 			   __func__, err);
-		goto err_close_tises;
-	}
-
-	err = mlx5e_open_rqt(priv, MLX5E_INDIRECTION_RQT);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_rqt(INDIR) failed, %d\n",
-			   __func__, err);
-		goto err_close_channels;
-	}
-
-	err = mlx5e_open_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_rqt(SINGLE) failed, %d\n",
-			   __func__, err);
-		goto err_close_rqt_indir;
-	}
-
-	err = mlx5e_open_tirs(priv);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_tir failed, %d\n",
-			   __func__, err);
-		goto err_close_rqt_single;
-	}
-
-	err = mlx5e_open_flow_table(priv);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_flow_table failed, %d\n",
-			   __func__, err);
-		goto err_close_tirs;
+		return err;
 	}
 
 	err = mlx5e_add_all_vlan_rules(priv);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_add_all_vlan_rules failed, %d\n",
 			   __func__, err);
-		goto err_close_flow_table;
+		goto err_close_channels;
 	}
 
 	mlx5e_init_eth_addr(priv);
 
-	set_bit(MLX5E_STATE_OPENED, &priv->state);
-
 	mlx5e_update_carrier(priv);
+	mlx5e_redirect_rqts(priv);
 	mlx5e_set_rx_mode_core(priv);
 
 	schedule_delayed_work(&priv->update_stats_work, 0);
 	return 0;
 
-err_close_flow_table:
-	mlx5e_close_flow_table(priv);
-
-err_close_tirs:
-	mlx5e_close_tirs(priv);
-
-err_close_rqt_single:
-	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-
-err_close_rqt_indir:
-	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
-
 err_close_channels:
 	mlx5e_close_channels(priv);
 
-err_close_tises:
-	mlx5e_close_tises(priv);
-
 	return err;
 }
 
@@ -1682,13 +1709,9 @@ int mlx5e_close_locked(struct net_device *netdev)
 
 	mlx5e_set_rx_mode_core(priv);
 	mlx5e_del_all_vlan_rules(priv);
+	mlx5e_redirect_rqts(priv);
 	netif_carrier_off(priv->netdev);
-	mlx5e_close_flow_table(priv);
-	mlx5e_close_tirs(priv);
-	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
 	mlx5e_close_channels(priv);
-	mlx5e_close_tises(priv);
 
 	return 0;
 }
@@ -1766,6 +1789,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 			mlx5e_close_locked(priv->netdev);
 
 		priv->params.lro_en = !!(features & NETIF_F_LRO);
+		mlx5e_modify_tir_lro(priv, MLX5E_TT_IPV4_TCP);
+		mlx5e_modify_tir_lro(priv, MLX5E_TT_IPV6_TCP);
 
 		if (was_opened)
 			err = mlx5e_open_locked(priv->netdev);
@@ -2026,16 +2051,72 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_dealloc_transport_domain;
 	}
 
+	err = mlx5e_open_tises(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "open tises failed, %d\n", err);
+		goto err_destroy_mkey;
+	}
+
+	err = mlx5e_open_drop_rq(priv);
+	if (err) {
+		mlx5_core_err(mdev, "open drop rq failed, %d\n", err);
+		goto err_close_tises;
+	}
+
+	err = mlx5e_open_rqt(priv, MLX5E_INDIRECTION_RQT);
+	if (err) {
+		mlx5_core_warn(mdev, "open rqt(INDIR) failed, %d\n", err);
+		goto err_close_drop_rq;
+	}
+
+	err = mlx5e_open_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+	if (err) {
+		mlx5_core_warn(mdev, "open rqt(SINGLE) failed, %d\n", err);
+		goto err_close_rqt_indir;
+	}
+
+	err = mlx5e_open_tirs(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "open tirs failed, %d\n", err);
+		goto err_close_rqt_single;
+	}
+
+	err = mlx5e_open_flow_table(priv);
+	if (err) {
+		mlx5_core_warn(mdev, "open flow table failed, %d\n", err);
+		goto err_close_tirs;
+	}
+
+	mlx5e_init_eth_addr(priv);
+
 	err = register_netdev(netdev);
 	if (err) {
 		mlx5_core_err(mdev, "register_netdev failed, %d\n", err);
-		goto err_destroy_mkey;
+		goto err_close_flow_table;
 	}
 
 	mlx5e_enable_async_events(priv);
 
 	return priv;
 
+err_close_flow_table:
+	mlx5e_close_flow_table(priv);
+
+err_close_tirs:
+	mlx5e_close_tirs(priv);
+
+err_close_rqt_single:
+	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+
+err_close_rqt_indir:
+	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
+
+err_close_drop_rq:
+	mlx5e_close_drop_rq(priv);
+
+err_close_tises:
+	mlx5e_close_tises(priv);
+
 err_destroy_mkey:
 	mlx5_core_destroy_mkey(mdev, &priv->mr);
 
@@ -2060,6 +2141,12 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	struct net_device *netdev = priv->netdev;
 
 	unregister_netdev(netdev);
+	mlx5e_close_flow_table(priv);
+	mlx5e_close_tirs(priv);
+	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
+	mlx5e_close_drop_rq(priv);
+	mlx5e_close_tises(priv);
 	mlx5_core_destroy_mkey(priv->mdev, &priv->mr);
 	mlx5_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index e6453f6..b4c87c7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -387,6 +387,18 @@ int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
 	return err;
 }
 
+int mlx5_core_modify_rqt(struct mlx5_core_dev *dev, u32 rqtn, u32 *in,
+			 int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(modify_rqt_out)];
+
+	MLX5_SET(modify_rqt_in, in, rqtn, rqtn);
+	MLX5_SET(modify_rqt_in, in, opcode, MLX5_CMD_OP_MODIFY_RQT);
+
+	memset(out, 0, sizeof(out));
+	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+}
+
 void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_rqt_in)];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
index d436c2d..74cae51 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
@@ -65,6 +65,8 @@ int mlx5_core_arm_xsrq(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm);
 
 int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *rqtn);
+int mlx5_core_modify_rqt(struct mlx5_core_dev *dev, u32 rqtn, u32 *in,
+			 int inlen);
 void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn);
 
 #endif /* __TRANSOBJ_H__ */
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 469b7bd..dd20974 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -4123,6 +4123,13 @@ struct mlx5_ifc_modify_rqt_out_bits {
 	u8         reserved_1[0x40];
 };
 
+struct mlx5_ifc_rqt_bitmask_bits {
+	u8	   reserved[0x20];
+
+	u8         reserved1[0x1f];
+	u8         rqn_list[0x1];
+};
+
 struct mlx5_ifc_modify_rqt_in_bits {
 	u8         opcode[0x10];
 	u8         reserved_0[0x10];
@@ -4135,7 +4142,7 @@ struct mlx5_ifc_modify_rqt_in_bits {
 
 	u8         reserved_3[0x20];
 
-	u8         modify_bitmask[0x40];
+	struct mlx5_ifc_rqt_bitmask_bits bitmask;
 
 	u8         reserved_4[0x40];
 
-- 
2.4.3.413.ga5fe668
