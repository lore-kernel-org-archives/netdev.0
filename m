From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: [PATCH 1/1] mlx5: Allow TC support to be disabled in the build
Date: Mon,  5 Jun 2017 16:53:58 -0400
Message-ID: <20170605205358.20211-2-jsorensen@fb.com>
References: <20170605205358.20211-1-jsorensen@fb.com>
Cc: kernel-team@fb.com, saeedm@mellanox.com, ilant@mellanox.com,
        Jes Sorensen <jsorensen@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35159 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdFEUyJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 16:54:09 -0400
Received: by mail-yw0-f194.google.com with SMTP id p144so8774347ywp.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 13:54:09 -0700 (PDT)
In-Reply-To: <20170605205358.20211-1-jsorensen@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides the option for TC offload support to be disabled in the
driver.

Signed-off-by: Jes Sorensen <jsorensen@fb.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   | 10 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  4 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 39 ++++++-----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 12 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   | 29 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  1 +
 6 files changed, 65 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index d91272d437bf..6c2607e2866d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -52,6 +52,16 @@ config MLX5_CORE_EN_ESWITCH_OFFLOADS
 
 	  If unsure, set to Y
 
+config MLX5_CORE_EN_TC
+	bool "Enable support for TC Filtering Offload Support"
+	default y
+	depends on MLX5_CORE_EN && MLX5_CORE_EN_ESWITCH_OFFLOADS
+	---help---
+	  Say Y here if you want to use Mellanox TC offload support.
+	  If set to N, the driver will use the kernel's software implementation.
+
+	  If unsure, set to Y
+
 config MLX5_CORE_IPOIB
 	bool "Mellanox Technologies ConnectX-4 IPoIB offloads support"
 	depends on MLX5_CORE_EN
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 615b33693cc2..72d7d58e9823 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -11,10 +11,12 @@ mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
+		en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
+mlx5_core-$(CONFIG_MLX5_CORE_EN_TC) +=  en_tc.o
+
 mlx5_core-$(CONFIG_MLX5_EN_ESWITCH_OFFLOADS) +=  en_eswitch_offloads.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cdff04b2aea1..9abdd4189edf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2961,38 +2961,10 @@ static int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 	return 0;
 }
 
-static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
-{
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct mlx5e_channels new_channels = {};
-	int err = 0;
-
-	if (tc && tc != MLX5E_MAX_NUM_TC)
-		return -EINVAL;
-
-	mutex_lock(&priv->state_lock);
-
-	new_channels.params = priv->channels.params;
-	new_channels.params.num_tc = tc ? tc : 1;
-
-	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
-		priv->channels.params = new_channels.params;
-		goto out;
-	}
-
-	err = mlx5e_open_channels(priv, &new_channels);
-	if (err)
-		goto out;
-
-	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
-out:
-	mutex_unlock(&priv->state_lock);
-	return err;
-}
-
 static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 			      __be16 proto, struct tc_to_netdev *tc)
 {
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
@@ -3019,6 +2991,9 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
 	return mlx5e_setup_tc(dev, tc->mqprio->num_tc);
+#else
+	return -EOPNOTSUPP;
+#endif
 }
 
 static void
@@ -4085,14 +4060,18 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 		goto err_destroy_direct_tirs;
 	}
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	err = mlx5e_tc_init(priv);
 	if (err)
 		goto err_destroy_flow_steering;
+#endif
 
 	return 0;
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 err_destroy_flow_steering:
 	mlx5e_destroy_flow_steering(priv);
+#endif
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_indirect_tirs:
@@ -4106,7 +4085,9 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 
 static void mlx5e_cleanup_nic_rx(struct mlx5e_priv *priv)
 {
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	mlx5e_tc_cleanup(priv);
+#endif
 	mlx5e_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 79462c0368a0..514f190b3f3f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -256,6 +256,7 @@ void mlx5e_rep_queue_neigh_stats_work(struct mlx5e_priv *priv)
 
 static void mlx5e_rep_neigh_stats_work(struct work_struct *work)
 {
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	struct mlx5e_rep_priv *rpriv = container_of(work, struct mlx5e_rep_priv,
 						    neigh_update.neigh_stats_work.work);
 	struct net_device *netdev = rpriv->rep->netdev;
@@ -270,6 +271,7 @@ static void mlx5e_rep_neigh_stats_work(struct work_struct *work)
 		mlx5e_tc_update_neigh_used_value(nhe);
 
 	rtnl_unlock();
+#endif
 }
 
 static void mlx5e_rep_neigh_entry_hold(struct mlx5e_neigh_hash_entry *nhe)
@@ -288,6 +290,7 @@ static void mlx5e_rep_update_flows(struct mlx5e_priv *priv,
 				   bool neigh_connected,
 				   unsigned char ha[ETH_ALEN])
 {
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	struct ethhdr *eth = (struct ethhdr *)e->encap_header;
 
 	ASSERT_RTNL();
@@ -302,6 +305,7 @@ static void mlx5e_rep_update_flows(struct mlx5e_priv *priv,
 
 		mlx5e_tc_encap_flows_add(priv, e);
 	}
+#endif
 }
 
 static void mlx5e_rep_neigh_update(struct work_struct *work)
@@ -859,14 +863,18 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 	}
 	rep->vport_rx_rule = flow_rule;
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	err = mlx5e_tc_init(priv);
 	if (err)
 		goto err_del_flow_rule;
+#endif
 
 	return 0;
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 err_del_flow_rule:
 	mlx5_del_flow_rules(rep->vport_rx_rule);
+#endif
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_direct_rqts:
@@ -879,7 +887,9 @@ static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 	struct mlx5_eswitch_rep *rep = rpriv->rep;
 
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	mlx5e_tc_cleanup(priv);
+#endif
 	mlx5_del_flow_rules(rep->vport_rx_rule);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_direct_rqts(priv);
@@ -953,8 +963,10 @@ mlx5e_nic_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 		mlx5e_remove_sqs_fwd_rules(priv);
 
 	/* clean (and re-init) existing uplink offloaded TC rules */
+#ifdef CONFIG_MLX5_CORE_EN_TC
 	mlx5e_tc_cleanup(priv);
 	mlx5e_tc_init(priv);
+#endif
 
 	mlx5e_rep_neigh_cleanup(rpriv);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 8ec13f9be660..2eba4c74ed97 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1966,3 +1966,32 @@ void mlx5e_tc_cleanup(struct mlx5e_priv *priv)
 		tc->t = NULL;
 	}
 }
+
+int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_channels new_channels = {};
+	int err = 0;
+
+	if (tc && tc != MLX5E_MAX_NUM_TC)
+		return -EINVAL;
+
+	mutex_lock(&priv->state_lock);
+
+	new_channels.params = priv->channels.params;
+	new_channels.params.num_tc = tc ? tc : 1;
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		priv->channels.params = new_channels.params;
+		goto out;
+	}
+
+	err = mlx5e_open_channels(priv, &new_channels);
+	if (err)
+		goto out;
+
+	mlx5e_switch_priv_channels(priv, &new_channels, NULL);
+out:
+	mutex_unlock(&priv->state_lock);
+	return err;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index ecbe30d808ae..c1562fa77f35 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -37,6 +37,7 @@
 
 int mlx5e_tc_init(struct mlx5e_priv *priv);
 void mlx5e_tc_cleanup(struct mlx5e_priv *priv);
+int mlx5e_setup_tc(struct net_device *netdev, u8 tc);
 
 int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 			   struct tc_cls_flower_offload *f);
-- 
2.13.0
