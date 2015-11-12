From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/6] net/mlx5e: Added self loopback prevention
Date: Thu, 12 Nov 2015 19:35:26 +0200
Message-ID: <1447349730-19832-3-git-send-email-ogerlitz@mellanox.com>
References: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:46722 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752946AbbKLRfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 12:35:55 -0500
In-Reply-To: <1447349730-19832-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Prevent outgoing multicast frames from looping back to the RX queue.

By introducing new HW capability self_lb_en_modifiable, which indicates
the support to modify self_lb_en bit in modify_tir command.

When this capability is set we can prevent TIRs from sending back
loopback multicast traffic to their own RQs, by "refreshing TIRs" with
modify_tir command, on every time new channels (SQs/RQs) are created at
device open.
This is needed since TIRs are static and only allocated once on driver
load, and the loopback decision is under their responsibility.

Fixes issues of the kind:
"IPv6: eth2: IPv6 duplicate address fe80::e61d:2dff:fe5c:f2e9 detected!"
The issue is seen since the IPv6 solicitations multicast messages are
loopedback and the network stack thinks they are coming from another host.

Fixes: 5c50368f3831 ("net/mlx5e: Light-weight netdev open/stop")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 48 +++++++++++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                     | 24 +++++++-----
 2 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5fc4d2d..df00175 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1332,6 +1332,42 @@ static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
 	return err;
 }
 
+static int mlx5e_refresh_tir_self_loopback_enable(struct mlx5_core_dev *mdev,
+						  u32 tirn)
+{
+	void *in;
+	int inlen;
+	int err;
+
+	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	MLX5_SET(modify_tir_in, in, bitmask.self_lb_en, 1);
+
+	err = mlx5_core_modify_tir(mdev, tirn, in, inlen);
+
+	kvfree(in);
+
+	return err;
+}
+
+static int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5e_priv *priv)
+{
+	int err;
+	int i;
+
+	for (i = 0; i < MLX5E_NUM_TT; i++) {
+		err = mlx5e_refresh_tir_self_loopback_enable(priv->mdev,
+							     priv->tirn[i]);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -1376,6 +1412,13 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_clear_state_opened_flag;
 	}
 
+	err = mlx5e_refresh_tirs_self_loopback_enable(priv);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5e_refresh_tirs_self_loopback_enable failed, %d\n",
+			   __func__, err);
+		goto err_close_channels;
+	}
+
 	mlx5e_update_carrier(priv);
 	mlx5e_redirect_rqts(priv);
 
@@ -1383,6 +1426,8 @@ int mlx5e_open_locked(struct net_device *netdev)
 
 	return 0;
 
+err_close_channels:
+	mlx5e_close_channels(priv);
 err_clear_state_opened_flag:
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 	return err;
@@ -1909,6 +1954,9 @@ static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 			       "Not creating net device, some required device capabilities are missing\n");
 		return -ENOTSUPP;
 	}
+	if (!MLX5_CAP_ETH(mdev, self_lb_en_modifiable))
+		mlx5_core_warn(mdev, "Self loop back prevention is not supported\n");
+
 	return 0;
 }
 
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index dd20974..1565324 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -453,26 +453,28 @@ struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         lro_cap[0x1];
 	u8         lro_psh_flag[0x1];
 	u8         lro_time_stamp[0x1];
-	u8         reserved_0[0x6];
+	u8         reserved_0[0x3];
+	u8         self_lb_en_modifiable[0x1];
+	u8         reserved_1[0x2];
 	u8         max_lso_cap[0x5];
-	u8         reserved_1[0x4];
+	u8         reserved_2[0x4];
 	u8         rss_ind_tbl_cap[0x4];
-	u8         reserved_2[0x3];
+	u8         reserved_3[0x3];
 	u8         tunnel_lso_const_out_ip_id[0x1];
-	u8         reserved_3[0x2];
+	u8         reserved_4[0x2];
 	u8         tunnel_statless_gre[0x1];
 	u8         tunnel_stateless_vxlan[0x1];
 
-	u8         reserved_4[0x20];
+	u8         reserved_5[0x20];
 
-	u8         reserved_5[0x10];
+	u8         reserved_6[0x10];
 	u8         lro_min_mss_size[0x10];
 
-	u8         reserved_6[0x120];
+	u8         reserved_7[0x120];
 
 	u8         lro_timer_supported_periods[4][0x20];
 
-	u8         reserved_7[0x600];
+	u8         reserved_8[0x600];
 };
 
 struct mlx5_ifc_roce_cap_bits {
@@ -4051,9 +4053,11 @@ struct mlx5_ifc_modify_tis_in_bits {
 };
 
 struct mlx5_ifc_modify_tir_bitmask_bits {
-	u8	   reserved[0x20];
+	u8	   reserved_0[0x20];
 
-	u8         reserved1[0x1f];
+	u8         reserved_1[0x1b];
+	u8         self_lb_en[0x1];
+	u8         reserved_2[0x3];
 	u8         lro[0x1];
 };
 
-- 
2.3.7
