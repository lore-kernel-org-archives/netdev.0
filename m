From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC net-next 4/4] net/mlx5: Add CONFIG_MLX5_ESWITCH Kconfig
Date: Thu,  8 Jun 2017 02:42:14 +0300
Message-ID: <20170607234214.24723-5-saeedm@mellanox.com>
References: <20170607234214.24723-1-saeedm@mellanox.com>
Cc: kernel-team@fb.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: netdev@vger.kernel.org, Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35131 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752985AbdFGXt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:49:29 -0400
In-Reply-To: <20170607234214.24723-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch gives the option to chose whether to compile the driver with or
without eswitch/eswitch_offloads(switchdev mode)/en_rep(VF representors)
and en_tc offloads.

It also removes most of the above modules headers declarations and stubs
out the API functions which are used outside these modules.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  7 +++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  6 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 33 +++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |  8 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  7 +++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 23 +++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c    | 10 +------
 8 files changed, 68 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 49559e11af86..4024069139a2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -38,6 +38,13 @@ config MLX5_MPFS
 	  Mellanox Technologies Ethernet Multi-Physical Function Switch (MPFS)
           support in ConnectX NIC.
 
+config MLX5_ESWITCH
+	bool "Mellanox Technologies MLX5 SRIOV E-Switch support"
+	depends on MLX5_CORE_EN
+	default y
+	---help---
+	  Mellanox Technologies Ethernet SRIOV E-Switch support in ConnectX NIC.
+
 config MLX5_CORE_EN_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default y
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 8c493aeec392..2ca2dc1b1147 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -8,13 +8,15 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 
 mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
+		en_arfs.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_MPFS) += mpfs.o
 
+mlx5_core-$(CONFIG_MLX5_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o en_tc.o
+
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1514027a5c51..1f0a1b78f609 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2961,9 +2961,8 @@ static int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 	return 0;
 }
 
-static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
+static int mlx5e_setup_tc(struct mlx5e_priv *priv, u8 tc)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_channels new_channels = {};
 	int err = 0;
 
@@ -2995,6 +2994,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
+#ifdef CONFIG_MLX5_ESWITCH
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
 		goto mqprio;
 
@@ -3013,12 +3013,13 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	}
 
 mqprio:
+#endif
 	if (tc->type != TC_SETUP_MQPRIO)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return mlx5e_setup_tc(dev, tc->mqprio->num_tc);
+	return mlx5e_setup_tc(priv, tc->mqprio->num_tc);
 }
 
 static void
@@ -3316,6 +3317,7 @@ static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
+#ifdef CONFIG_MLX5_ESWITCH
 static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -3418,6 +3420,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 	return mlx5_eswitch_get_vport_stats(mdev->priv.eswitch, vf + 1,
 					    vf_stats);
 }
+#endif
 
 static void mlx5e_add_vxlan_port(struct net_device *netdev,
 				 struct udp_tunnel_info *ti)
@@ -3659,6 +3662,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 #endif
 };
 
+#ifdef CONFIG_MLX5_ESWITCH
 static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
@@ -3697,6 +3701,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
 };
+#endif
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
@@ -3923,9 +3928,11 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 	}
 }
 
+#if IS_ENABLED(CONFIG_NET_SWITCHDEV) && IS_ENABLED(CONFIG_MLX5_ESWITCH)
 static const struct switchdev_ops mlx5e_switchdev_ops = {
 	.switchdev_port_attr_get	= mlx5e_attr_get,
 };
+#endif
 
 static void mlx5e_build_nic_netdev(struct net_device *netdev)
 {
@@ -3936,15 +3943,17 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
-		if (MLX5_CAP_GEN(mdev, qos))
-			netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
+	if (MLX5_CAP_GEN(mdev, vport_group_manager) && MLX5_CAP_GEN(mdev, qos))
+		netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
+#endif
+
+#ifdef CONFIG_MLX5_ESWITCH
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
+	else
 #endif
-	} else {
 		netdev->netdev_ops = &mlx5e_netdev_ops_basic;
-	}
 
 	netdev->watchdog_timeo    = 15 * HZ;
 
@@ -4016,7 +4025,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 
 	mlx5e_set_netdev_dev_addr(netdev);
 
-#ifdef CONFIG_NET_SWITCHDEV
+#if IS_ENABLED(CONFIG_NET_SWITCHDEV) && IS_ENABLED(CONFIG_MLX5_ESWITCH)
 	if (MLX5_CAP_GEN(mdev, vport_group_manager))
 		netdev->switchdev_ops = &mlx5e_switchdev_ops;
 #endif
@@ -4366,6 +4375,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	if (err)
 		return NULL;
 
+#ifdef CONFIG_MLX5_ESWITCH
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		rpriv = mlx5e_alloc_nic_rep_priv(mdev);
 		if (!rpriv) {
@@ -4373,6 +4383,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 			return NULL;
 		}
 	}
+#endif
 
 	netdev = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, rpriv);
 	if (!netdev) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
index 23e43bbf928d..5659ed9f51e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -38,6 +38,7 @@
 #include "eswitch.h"
 #include "en.h"
 
+#ifdef CONFIG_MLX5_ESWITCH
 struct mlx5e_neigh_update_table {
 	struct rhashtable       neigh_ht;
 	/* Save the neigh hash entries in a list in addition to the hash table
@@ -142,5 +143,12 @@ void mlx5e_rep_encap_entry_detach(struct mlx5e_priv *priv,
 				  struct mlx5e_encap_entry *e);
 
 void mlx5e_rep_queue_neigh_stats_work(struct mlx5e_priv *priv);
+#else /* CONFIG_MLX5_ESWITCH */
+static inline void mlx5e_register_vport_reps(struct mlx5e_priv *priv) {}
+static inline void mlx5e_unregister_vport_reps(struct mlx5e_priv *priv) {}
+static inline bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv) { return false; }
+static inline int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv) { return 0; }
+static inline void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv) {}
+#endif
 
 #endif /* __MLX5E_REP_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 66b5fec15313..7d2860252dce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -806,6 +806,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		       &wqe->next.next_wqe_index);
 }
 
+#ifdef CONFIG_MLX5_ESWITCH
 void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
 	struct net_device *netdev = rq->netdev;
@@ -838,6 +839,7 @@ void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
 		       &wqe->next.next_wqe_index);
 }
+#endif
 
 static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
 					   struct mlx5_cqe64 *cqe,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index ecbe30d808ae..36473ec65ce8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -35,6 +35,7 @@
 
 #define MLX5E_TC_FLOW_ID_MASK 0x0000ffff
 
+#ifdef CONFIG_MLX5_ESWITCH
 int mlx5e_tc_init(struct mlx5e_priv *priv);
 void mlx5e_tc_cleanup(struct mlx5e_priv *priv);
 
@@ -60,4 +61,10 @@ static inline int mlx5e_tc_num_filters(struct mlx5e_priv *priv)
 	return atomic_read(&priv->fs.tc.ht.nelems);
 }
 
+#else /* CONFIG_MLX5_ESWITCH */
+static inline int  mlx5e_tc_init(struct mlx5e_priv *priv) { return 0; }
+static inline void mlx5e_tc_cleanup(struct mlx5e_priv *priv) {}
+static inline int  mlx5e_tc_num_filters(struct mlx5e_priv *priv) { return 0; }
+#endif
+
 #endif /* __MLX5_EN_TC_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index a0203c7f6cf6..4806e81dec03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -39,6 +39,14 @@
 #include <linux/mlx5/device.h>
 #include "mpfs.h"
 
+enum {
+	SRIOV_NONE,
+	SRIOV_LEGACY,
+	SRIOV_OFFLOADS
+};
+
+#ifdef CONFIG_MLX5_ESWITCH
+
 #define MLX5_MAX_UC_PER_VPORT(dev) \
 	(1 << MLX5_CAP_GEN(dev, log_max_current_uc_list))
 
@@ -125,12 +133,6 @@ struct mlx5_eswitch_fdb {
 	};
 };
 
-enum {
-	SRIOV_NONE,
-	SRIOV_LEGACY,
-	SRIOV_OFFLOADS
-};
-
 struct mlx5_esw_sq {
 	struct mlx5_flow_handle	*send_to_vport_rule;
 	struct list_head	 list;
@@ -291,4 +293,13 @@ int __mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 
 #define esw_debug(dev, format, ...)				\
 	mlx5_core_dbg_mask(dev, MLX5_DEBUG_ESWITCH_MASK, format, ##__VA_ARGS__)
+#else  /* CONFIG_MLX5_ESWITCH */
+/* eswitch API stubs */
+static inline int  mlx5_eswitch_init(struct mlx5_core_dev *dev) { return 0; }
+static inline void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw) {}
+static inline void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe) {}
+static inline int  mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode) { return -EOPNOTSUPP; }
+static inline void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw) {}
+#endif /* CONFIG_MLX5_ESWITCH */
+
 #endif /* __MLX5_ESWITCH_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 70db4257930e..8b78925f8850 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -54,9 +54,7 @@
 #include "mlx5_core.h"
 #include "fs_core.h"
 #include "mpfs.h"
-#ifdef CONFIG_MLX5_CORE_EN
 #include "eswitch.h"
-#endif
 #include "fpga/core.h"
 
 MODULE_AUTHOR("Eli Cohen <eli@mellanox.com>");
@@ -948,13 +946,11 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto err_rl_cleanup;
 	}
 
-#ifdef CONFIG_MLX5_CORE_EN
 	err = mlx5_eswitch_init(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to init eswitch %d\n", err);
 		goto err_mpfs_cleanup;
 	}
-#endif
 
 	err = mlx5_sriov_init(dev);
 	if (err) {
@@ -965,10 +961,8 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	return 0;
 
 err_eswitch_cleanup:
-#ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
 err_mpfs_cleanup:
-#endif
 	mlx5_mpfs_cleanup(dev);
 err_rl_cleanup:
 	mlx5_cleanup_rl_table(dev);
@@ -988,9 +982,7 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
 {
 	mlx5_sriov_cleanup(dev);
-#ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
-#endif
 	mlx5_mpfs_cleanup(dev);
 	mlx5_cleanup_rl_table(dev);
 	mlx5_cleanup_mkey_table(dev);
@@ -1283,7 +1275,7 @@ struct mlx5_core_event_handler {
 };
 
 static const struct devlink_ops mlx5_devlink_ops = {
-#ifdef CONFIG_MLX5_CORE_EN
+#ifdef CONFIG_MLX5_ESWITCH
 	.eswitch_mode_set = mlx5_devlink_eswitch_mode_set,
 	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
 	.eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
-- 
2.11.0
