From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 5/8] net/mlx5: Add CONFIG_MLX5_ESWITCH Kconfig
Date: Mon,  7 Aug 2017 13:18:05 +0300
Message-ID: <20170807101808.22924-6-saeedm@mellanox.com>
References: <20170807101808.22924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jes Sorensen <jsorensen@fb.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53299 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752993AbdHGKSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 06:18:35 -0400
In-Reply-To: <20170807101808.22924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to selectively build the driver with or without sriov eswitch, VF
representors and TC offloads.

Also remove the need of two ndo ops structures (sriov & basic)
and keep only one unified ndo ops, compile out VF SRIOV ndos when not
needed (MLX5_ESWITCH=n), and for VF netdev calling those ndos will result
in returning -EPERM.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Jes Sorensen <jsorensen@fb.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   | 11 +++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  9 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 53 +++++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |  8 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |  7 +++
 drivers/net/ethernet/mellanox/mlx5/core/eq.c      |  4 --
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 23 +++++++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c    | 10 +----
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c   | 14 +-----
 10 files changed, 69 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index d7174295b6ef..fdaef00465d7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -44,6 +44,17 @@ config MLX5_MPFS
           is enabled to allow passing user configured unicast MAC addresses to the
           requesting PF.
 
+config MLX5_ESWITCH
+	bool "Mellanox Technologies MLX5 SRIOV E-Switch support"
+	depends on MLX5_CORE_EN
+	default y
+	---help---
+	  Mellanox Technologies Ethernet SRIOV E-Switch support in ConnectX NIC.
+          E-Switch provides internal SRIOV packet steering and switching for the
+          enabled VFs and PF in two available modes:
+                Legacy SRIOV mode (L2 mac vlan steering based).
+                Switchdev mode (eswitch offloads).
+
 config MLX5_CORE_EN_DCB
 	bool "Data Center Bridging (DCB) Support"
 	default y
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index c867e48f8a4c..22ed657d263a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -11,13 +11,14 @@ mlx5_core-$(CONFIG_MLX5_ACCEL) += accel/ipsec.o
 mlx5_core-$(CONFIG_MLX5_FPGA) += fpga/cmd.o fpga/core.o fpga/conn.o fpga/sdk.o \
 		fpga/ipsec.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_EN) += eswitch.o eswitch_offloads.o \
-		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
-		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += en_main.o en_common.o en_fs.o en_ethtool.o \
+		en_tx.o en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
+		en_arfs.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_MPFS) += lib/mpfs.o
 
+mlx5_core-$(CONFIG_MLX5_ESWITCH) += eswitch.o eswitch_offloads.o en_rep.o en_tc.o
+
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o ipoib/ethtool.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e3c858c44532..b19e9d235008 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3025,6 +3025,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 			      u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
+#ifdef CONFIG_MLX5_ESWITCH
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
@@ -3048,6 +3049,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	}
 
 mqprio:
+#endif
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
@@ -3350,6 +3352,7 @@ static int mlx5e_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
+#ifdef CONFIG_MLX5_ESWITCH
 static int mlx5e_set_vf_mac(struct net_device *dev, int vf, u8 *mac)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -3452,6 +3455,7 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 	return mlx5_eswitch_get_vport_stats(mdev->priv.eswitch, vf + 1,
 					    vf_stats);
 }
+#endif
 
 static void mlx5e_add_vxlan_port(struct net_device *netdev,
 				 struct udp_tunnel_info *ti)
@@ -3685,7 +3689,7 @@ static void mlx5e_netpoll(struct net_device *dev)
 }
 #endif
 
-static const struct net_device_ops mlx5e_netdev_ops_basic = {
+static const struct net_device_ops mlx5e_netdev_ops = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
@@ -3711,34 +3715,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller     = mlx5e_netpoll,
 #endif
-};
-
-static const struct net_device_ops mlx5e_netdev_ops_sriov = {
-	.ndo_open                = mlx5e_open,
-	.ndo_stop                = mlx5e_close,
-	.ndo_start_xmit          = mlx5e_xmit,
-	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
-	.ndo_select_queue        = mlx5e_select_queue,
-	.ndo_get_stats64         = mlx5e_get_stats,
-	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
-	.ndo_set_mac_address     = mlx5e_set_mac,
-	.ndo_vlan_rx_add_vid     = mlx5e_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid    = mlx5e_vlan_rx_kill_vid,
-	.ndo_set_features        = mlx5e_set_features,
-	.ndo_change_mtu          = mlx5e_change_mtu,
-	.ndo_do_ioctl            = mlx5e_ioctl,
-	.ndo_set_tx_maxrate      = mlx5e_set_tx_maxrate,
-	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
-	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
-	.ndo_features_check      = mlx5e_features_check,
-#ifdef CONFIG_RFS_ACCEL
-	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
-#endif
-	.ndo_tx_timeout          = mlx5e_tx_timeout,
-	.ndo_xdp		 = mlx5e_xdp,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller     = mlx5e_netpoll,
-#endif
+#ifdef CONFIG_MLX5_ESWITCH
 	/* SRIOV E-Switch NDOs */
 	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
@@ -3750,6 +3727,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
 	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
+#endif
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
@@ -3979,9 +3957,11 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 	}
 }
 
+#if IS_ENABLED(CONFIG_NET_SWITCHDEV) && IS_ENABLED(CONFIG_MLX5_ESWITCH)
 static const struct switchdev_ops mlx5e_switchdev_ops = {
 	.switchdev_port_attr_get	= mlx5e_attr_get,
 };
+#endif
 
 static void mlx5e_build_nic_netdev(struct net_device *netdev)
 {
@@ -3992,15 +3972,12 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
+	netdev->netdev_ops = &mlx5e_netdev_ops;
+
 #ifdef CONFIG_MLX5_CORE_EN_DCB
-		if (MLX5_CAP_GEN(mdev, qos))
-			netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
+	if (MLX5_CAP_GEN(mdev, vport_group_manager) && MLX5_CAP_GEN(mdev, qos))
+		netdev->dcbnl_ops = &mlx5e_dcbnl_ops;
 #endif
-	} else {
-		netdev->netdev_ops = &mlx5e_netdev_ops_basic;
-	}
 
 	netdev->watchdog_timeo    = 15 * HZ;
 
@@ -4072,7 +4049,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 
 	mlx5e_set_netdev_dev_addr(netdev);
 
-#ifdef CONFIG_NET_SWITCHDEV
+#if IS_ENABLED(CONFIG_NET_SWITCHDEV) && IS_ENABLED(CONFIG_MLX5_ESWITCH)
 	if (MLX5_VPORT_MANAGER(mdev))
 		netdev->switchdev_ops = &mlx5e_switchdev_ops;
 #endif
@@ -4431,6 +4408,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	if (err)
 		return NULL;
 
+#ifdef CONFIG_MLX5_ESWITCH
 	if (MLX5_VPORT_MANAGER(mdev)) {
 		rpriv = mlx5e_alloc_nic_rep_priv(mdev);
 		if (!rpriv) {
@@ -4438,6 +4416,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
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
index 325b2c8c1c6d..8e224bcbc6a6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -857,6 +857,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		       &wqe->next.next_wqe_index);
 }
 
+#ifdef CONFIG_MLX5_ESWITCH
 void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
 	struct net_device *netdev = rq->netdev;
@@ -901,6 +902,7 @@ void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
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
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 24d2f707fdfc..de704ff5619a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -36,9 +36,7 @@
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 #include "fpga/core.h"
-#ifdef CONFIG_MLX5_CORE_EN
 #include "eswitch.h"
-#endif
 
 enum {
 	MLX5_EQE_SIZE		= sizeof(struct mlx5_eqe),
@@ -467,11 +465,9 @@ static irqreturn_t mlx5_eq_int(int irq, void *eq_ptr)
 			}
 			break;
 
-#ifdef CONFIG_MLX5_CORE_EN
 		case MLX5_EVENT_TYPE_NIC_VPORT_CHANGE:
 			mlx5_eswitch_vport_event(dev->priv.eswitch, eqe);
 			break;
-#endif
 
 		case MLX5_EVENT_TYPE_PORT_MODULE_EVENT:
 			mlx5_port_module_event(dev, eqe);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 701d228de4ad..565c8b7a399a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -39,6 +39,14 @@
 #include <linux/mlx5/device.h>
 #include "lib/mpfs.h"
 
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
@@ -292,4 +294,13 @@ int __mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 
 #define esw_debug(dev, format, ...)				\
 	mlx5_core_dbg_mask(dev, MLX5_DEBUG_ESWITCH_MASK, format, ##__VA_ARGS__)
+#else  /* CONFIG_MLX5_ESWITCH */
+/* eswitch API stubs */
+static inline int  mlx5_eswitch_init(struct mlx5_core_dev *dev) { return 0; }
+static inline void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw) {}
+static inline void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe) {}
+static inline int  mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode) { return 0; }
+static inline void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw) {}
+#endif /* CONFIG_MLX5_ESWITCH */
+
 #endif /* __MLX5_ESWITCH_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index d4a9c9b7b6a2..124c7c3c3a00 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -54,9 +54,7 @@
 #include "mlx5_core.h"
 #include "fs_core.h"
 #include "lib/mpfs.h"
-#ifdef CONFIG_MLX5_CORE_EN
 #include "eswitch.h"
-#endif
 #include "lib/mlx5.h"
 #include "fpga/core.h"
 #include "accel/ipsec.h"
@@ -953,13 +951,11 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
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
@@ -978,10 +974,8 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 err_sriov_cleanup:
 	mlx5_sriov_cleanup(dev);
 err_eswitch_cleanup:
-#ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
 err_mpfs_cleanup:
-#endif
 	mlx5_mpfs_cleanup(dev);
 err_rl_cleanup:
 	mlx5_cleanup_rl_table(dev);
@@ -1002,9 +996,7 @@ static void mlx5_cleanup_once(struct mlx5_core_dev *dev)
 {
 	mlx5_fpga_cleanup(dev);
 	mlx5_sriov_cleanup(dev);
-#ifdef CONFIG_MLX5_CORE_EN
 	mlx5_eswitch_cleanup(dev->priv.eswitch);
-#endif
 	mlx5_mpfs_cleanup(dev);
 	mlx5_cleanup_rl_table(dev);
 	mlx5_cleanup_reserved_gids(dev);
@@ -1311,7 +1303,7 @@ struct mlx5_core_event_handler {
 };
 
 static const struct devlink_ops mlx5_devlink_ops = {
-#ifdef CONFIG_MLX5_CORE_EN
+#ifdef CONFIG_MLX5_ESWITCH
 	.eswitch_mode_set = mlx5_devlink_eswitch_mode_set,
 	.eswitch_mode_get = mlx5_devlink_eswitch_mode_get,
 	.eswitch_inline_mode_set = mlx5_devlink_eswitch_inline_mode_set,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index bf99d40e30b4..5e7ffc9fad78 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -33,9 +33,7 @@
 #include <linux/pci.h>
 #include <linux/mlx5/driver.h>
 #include "mlx5_core.h"
-#ifdef CONFIG_MLX5_CORE_EN
 #include "eswitch.h"
-#endif
 
 bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev)
 {
@@ -57,14 +55,12 @@ static int mlx5_device_enable_sriov(struct mlx5_core_dev *dev, int num_vfs)
 		return -EBUSY;
 	}
 
-#ifdef CONFIG_MLX5_CORE_EN
 	err = mlx5_eswitch_enable_sriov(dev->priv.eswitch, num_vfs, SRIOV_LEGACY);
 	if (err) {
 		mlx5_core_warn(dev,
 			       "failed to enable eswitch SRIOV (%d)\n", err);
 		return err;
 	}
-#endif
 
 	for (vf = 0; vf < num_vfs; vf++) {
 		err = mlx5_core_enable_hca(dev, vf + 1);
@@ -88,11 +84,7 @@ static void mlx5_device_disable_sriov(struct mlx5_core_dev *dev)
 	int vf;
 
 	if (!sriov->enabled_vfs)
-#ifdef CONFIG_MLX5_CORE_EN
-		goto disable_sriov_resources;
-#else
-		return;
-#endif
+		goto out;
 
 	for (vf = 0; vf < sriov->num_vfs; vf++) {
 		if (!sriov->vfs_ctx[vf].enabled)
@@ -106,10 +98,8 @@ static void mlx5_device_disable_sriov(struct mlx5_core_dev *dev)
 		sriov->enabled_vfs--;
 	}
 
-#ifdef CONFIG_MLX5_CORE_EN
-disable_sriov_resources:
+out:
 	mlx5_eswitch_disable_sriov(dev->priv.eswitch);
-#endif
 
 	if (mlx5_wait_for_vf_pages(dev))
 		mlx5_core_warn(dev, "timeout reclaiming VFs pages\n");
-- 
2.13.0
