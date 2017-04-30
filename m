From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/15] net/mlx5e: Extendable vport representor netdev private data
Date: Sun, 30 Apr 2017 16:20:02 +0300
Message-ID: <20170430132016.27012-2-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46717 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755511AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make representor netdev private data extendable by adding new struct
"mlx5e_rep_priv" and use it as the rep netdev private data struct
instead of directly pointing to mlx5_eswitch_rep.

Added new en_rep.h header file to contain all representor related
definitions and prototypes, and moved all representor specific logic
into en_rep.c.

Needed for downstream patches to extend representor functionality to
support neighbour update.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  20 ---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  77 +++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 176 ++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |  55 +++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  22 ++-
 6 files changed, 224 insertions(+), 130 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 632a04b0ecaf..0099a3e397bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -991,20 +991,6 @@ int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev);
 void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev);
 int mlx5e_refresh_tirs(struct mlx5e_priv *priv, bool enable_uc_lb);
 
-struct mlx5_eswitch_rep;
-int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
-			 struct mlx5_eswitch_rep *rep);
-void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
-			    struct mlx5_eswitch_rep *rep);
-int mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep);
-void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
-			  struct mlx5_eswitch_rep *rep);
-int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv);
-void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv);
-int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
-void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
-void mlx5e_update_hw_rep_counters(struct mlx5e_priv *priv);
-
 /* common netdev helpers */
 int mlx5e_create_indirect_rqt(struct mlx5e_priv *priv);
 
@@ -1031,12 +1017,6 @@ int mlx5e_open(struct net_device *netdev);
 void mlx5e_update_stats_work(struct work_struct *work);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
 
-int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
-			    void *sp);
-bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id);
-
-bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
-
 /* mlx5e generic netdev management API */
 struct net_device*
 mlx5e_create_netdev(struct mlx5_core_dev *mdev, const struct mlx5e_profile *profile,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e43411d232ee..1afaca96a30d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -35,9 +35,10 @@
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
 #include <linux/bpf.h>
+#include "eswitch.h"
 #include "en.h"
 #include "en_tc.h"
-#include "eswitch.h"
+#include "en_rep.h"
 #include "vxlan.h"
 
 struct mlx5e_rq_param {
@@ -4123,48 +4124,10 @@ static int mlx5e_init_nic_tx(struct mlx5e_priv *priv)
 	return 0;
 }
 
-static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
-{
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
-	int vport;
-	u8 mac[ETH_ALEN];
-
-	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
-		return;
-
-	mlx5_query_nic_vport_mac_address(mdev, 0, mac);
-
-	for (vport = 1; vport < total_vfs; vport++) {
-		struct mlx5_eswitch_rep rep;
-
-		rep.load = mlx5e_vport_rep_load;
-		rep.unload = mlx5e_vport_rep_unload;
-		rep.vport = vport;
-		ether_addr_copy(rep.hw_id, mac);
-		mlx5_eswitch_register_vport_rep(esw, vport, &rep);
-	}
-}
-
-static void mlx5e_unregister_vport_rep(struct mlx5_core_dev *mdev)
-{
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
-	int vport;
-
-	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
-		return;
-
-	for (vport = 1; vport < total_vfs; vport++)
-		mlx5_eswitch_unregister_vport_rep(esw, vport);
-}
-
 static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 {
 	struct net_device *netdev = priv->netdev;
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-	struct mlx5_eswitch_rep rep;
 	u16 max_mtu;
 
 	mlx5e_init_l2_addr(priv);
@@ -4179,16 +4142,8 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 
 	mlx5e_enable_async_events(priv);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		mlx5_query_nic_vport_mac_address(mdev, 0, rep.hw_id);
-		rep.load = mlx5e_nic_rep_load;
-		rep.unload = mlx5e_nic_rep_unload;
-		rep.vport = FDB_UPLINK_VPORT;
-		rep.netdev = netdev;
-		mlx5_eswitch_register_vport_rep(esw, 0, &rep);
-	}
-
-	mlx5e_register_vport_rep(mdev);
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		mlx5e_register_vport_reps(priv);
 
 	if (netdev->reg_state != NETREG_REGISTERED)
 		return;
@@ -4212,7 +4167,6 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 static void mlx5e_nic_disable(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
 
 	rtnl_lock();
 	if (netif_running(priv->netdev))
@@ -4221,9 +4175,10 @@ static void mlx5e_nic_disable(struct mlx5e_priv *priv)
 	rtnl_unlock();
 
 	queue_work(priv->wq, &priv->set_rx_mode_work);
-	mlx5e_unregister_vport_rep(mdev);
+
 	if (MLX5_CAP_GEN(mdev, vport_group_manager))
-		mlx5_eswitch_unregister_vport_rep(esw, 0);
+		mlx5e_unregister_vport_reps(priv);
+
 	mlx5e_disable_async_events(priv);
 	mlx5_lag_remove(mdev);
 }
@@ -4394,7 +4349,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 {
 	struct mlx5_eswitch *esw = mdev->priv.eswitch;
 	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
-	void *ppriv = NULL;
+	struct mlx5e_rep_priv *rpriv = NULL;
 	void *priv;
 	int vport;
 	int err;
@@ -4404,10 +4359,17 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	if (err)
 		return NULL;
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
-		ppriv = &esw->offloads.vport_reps[0];
+	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+		rpriv = kzalloc(sizeof(*rpriv), GFP_KERNEL);
+		if (!rpriv) {
+			mlx5_core_warn(mdev,
+				       "Not creating net device, Failed to alloc rep priv data\n");
+			return NULL;
+		}
+		rpriv->rep = &esw->offloads.vport_reps[0];
+	}
 
-	netdev = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, ppriv);
+	netdev = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, rpriv);
 	if (!netdev) {
 		mlx5_core_err(mdev, "mlx5e_create_netdev failed\n");
 		goto err_unregister_reps;
@@ -4439,16 +4401,19 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	for (vport = 1; vport < total_vfs; vport++)
 		mlx5_eswitch_unregister_vport_rep(esw, vport);
 
+	kfree(rpriv);
 	return NULL;
 }
 
 static void mlx5e_remove(struct mlx5_core_dev *mdev, void *vpriv)
 {
 	struct mlx5e_priv *priv = vpriv;
+	void *ppriv = priv->ppriv;
 
 	unregister_netdev(priv->netdev);
 	mlx5e_detach(mdev, vpriv);
 	mlx5e_destroy_netdev(priv);
+	kfree(ppriv);
 }
 
 static void *mlx5e_get_netdev(void *vpriv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 16b683e8226d..8e82b11afd99 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -37,6 +37,7 @@
 
 #include "eswitch.h"
 #include "en.h"
+#include "en_rep.h"
 #include "en_tc.h"
 
 static const char mlx5e_rep_driver_name[] = "mlx5e_rep";
@@ -75,7 +76,8 @@ static void mlx5e_rep_get_strings(struct net_device *dev,
 static void mlx5e_rep_update_hw_counters(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct rtnl_link_stats64 *vport_stats;
 	struct ifla_vf_stats vf_stats;
 	int err;
@@ -165,7 +167,8 @@ static const struct ethtool_ops mlx5e_rep_ethtool_ops = {
 int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
 	if (esw->mode == SRIOV_NONE)
@@ -184,10 +187,10 @@ int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr)
 }
 
 int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
-
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5e_channel *c;
 	int n, tc, num_sqs = 0;
 	int err = -ENOMEM;
@@ -212,42 +215,20 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
 	return err;
 }
 
-int mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
-{
-	struct net_device *netdev = rep->netdev;
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		return mlx5e_add_sqs_fwd_rules(priv);
-	return 0;
-}
-
 void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 
 	mlx5_eswitch_sqs2vport_stop(esw, rep);
 }
 
-void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
-			  struct mlx5_eswitch_rep *rep)
-{
-	struct net_device *netdev = rep->netdev;
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		mlx5e_remove_sqs_fwd_rules(priv);
-
-	/* clean (and re-init) existing uplink offloaded TC rules */
-	mlx5e_tc_cleanup(priv);
-	mlx5e_tc_init(priv);
-}
-
 static int mlx5e_rep_open(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	int err;
 
@@ -265,7 +246,8 @@ static int mlx5e_rep_open(struct net_device *dev)
 static int mlx5e_rep_close(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
 	(void)mlx5_eswitch_set_vport_state(esw, rep->vport, MLX5_ESW_VPORT_ADMIN_STATE_DOWN);
@@ -277,7 +259,8 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 					char *buf, size_t len)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	int ret;
 
 	ret = snprintf(buf, len, "%d", rep->vport - 1);
@@ -320,10 +303,16 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
 
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
 {
-	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep;
+
+	if (!MLX5_CAP_GEN(priv->mdev, vport_group_manager))
+		return false;
 
-	if (rep && rep->vport == FDB_UPLINK_VPORT && esw->mode == SRIOV_OFFLOADS)
+	rep = rpriv->rep;
+	if (esw->mode == SRIOV_OFFLOADS &&
+	    rep && rep->vport == FDB_UPLINK_VPORT)
 		return true;
 
 	return false;
@@ -331,7 +320,8 @@ bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
 
 static bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
 {
-	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 
 	if (rep && rep->vport != FDB_UPLINK_VPORT)
 		return true;
@@ -464,7 +454,8 @@ static void mlx5e_init_rep(struct mlx5_core_dev *mdev,
 static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5_flow_handle *flow_rule;
 	int err;
 
@@ -504,7 +495,8 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 
 static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
 {
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 
 	mlx5e_tc_cleanup(priv);
 	mlx5_del_flow_rules(rep->vport_rx_rule);
@@ -543,20 +535,54 @@ static struct mlx5e_profile mlx5e_rep_profile = {
 	.max_tc			= 1,
 };
 
-int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
-			 struct mlx5_eswitch_rep *rep)
+/* e-Switch vport representors */
+
+static int
+mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
+{
+	struct net_device *netdev = rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		return mlx5e_add_sqs_fwd_rules(priv);
+	return 0;
+}
+
+static void
+mlx5e_nic_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
+	struct net_device *netdev = rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
+		mlx5e_remove_sqs_fwd_rules(priv);
+
+	/* clean (and re-init) existing uplink offloaded TC rules */
+	mlx5e_tc_cleanup(priv);
+	mlx5e_tc_init(priv);
+}
+
+static int
+mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
+{
+	struct mlx5e_rep_priv *rpriv;
 	struct net_device *netdev;
 	int err;
 
-	netdev = mlx5e_create_netdev(esw->dev, &mlx5e_rep_profile, rep);
+	rpriv = kzalloc(sizeof(*rpriv), GFP_KERNEL);
+	if (!rpriv)
+		return -ENOMEM;
+
+	netdev = mlx5e_create_netdev(esw->dev, &mlx5e_rep_profile, rpriv);
 	if (!netdev) {
 		pr_warn("Failed to create representor netdev for vport %d\n",
 			rep->vport);
+		kfree(rpriv);
 		return -EINVAL;
 	}
 
 	rep->netdev = netdev;
+	rpriv->rep = rep;
 
 	err = mlx5e_attach_netdev(netdev_priv(netdev));
 	if (err) {
@@ -579,17 +605,77 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 
 err_destroy_netdev:
 	mlx5e_destroy_netdev(netdev_priv(netdev));
-
+	kfree(rpriv);
 	return err;
 
 }
 
-void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
-			    struct mlx5_eswitch_rep *rep)
+static void
+mlx5e_vport_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
 	struct net_device *netdev = rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	void *ppriv = priv->ppriv;
 
 	unregister_netdev(netdev);
-	mlx5e_detach_netdev(netdev_priv(netdev));
-	mlx5e_destroy_netdev(netdev_priv(netdev));
+	mlx5e_detach_netdev(priv);
+	mlx5e_destroy_netdev(priv);
+	kfree(ppriv); /* mlx5e_rep_priv */
+}
+
+static void mlx5e_rep_register_vf_vports(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw   = mdev->priv.eswitch;
+	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
+	int vport;
+	u8 mac[ETH_ALEN];
+
+	mlx5_query_nic_vport_mac_address(mdev, 0, mac);
+
+	for (vport = 1; vport < total_vfs; vport++) {
+		struct mlx5_eswitch_rep rep;
+
+		rep.load = mlx5e_vport_rep_load;
+		rep.unload = mlx5e_vport_rep_unload;
+		rep.vport = vport;
+		ether_addr_copy(rep.hw_id, mac);
+		mlx5_eswitch_register_vport_rep(esw, vport, &rep);
+	}
+}
+
+static void mlx5e_rep_unregister_vf_vports(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
+	int vport;
+
+	for (vport = 1; vport < total_vfs; vport++)
+		mlx5_eswitch_unregister_vport_rep(esw, vport);
+}
+
+void mlx5e_register_vport_reps(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw   = mdev->priv.eswitch;
+	struct mlx5_eswitch_rep rep;
+
+	mlx5_query_nic_vport_mac_address(mdev, 0, rep.hw_id);
+	rep.load = mlx5e_nic_rep_load;
+	rep.unload = mlx5e_nic_rep_unload;
+	rep.vport = FDB_UPLINK_VPORT;
+	rep.netdev = priv->netdev;
+	mlx5_eswitch_register_vport_rep(esw, 0, &rep); /* UPLINK PF vport*/
+
+	mlx5e_rep_register_vf_vports(priv); /* VFs vports */
+}
+
+void mlx5e_unregister_vport_reps(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw   = mdev->priv.eswitch;
+
+	mlx5e_rep_unregister_vf_vports(priv); /* VFs vports */
+	mlx5_eswitch_unregister_vport_rep(esw, 0); /* UPLINK PF*/
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
new file mode 100644
index 000000000000..b6595a699dc1
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -0,0 +1,55 @@
+/*
+ * Copyright (c) 2017, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __MLX5E_REP_H__
+#define __MLX5E_REP_H__
+
+#include "eswitch.h"
+#include "en.h"
+
+struct mlx5e_rep_priv {
+	struct mlx5_eswitch_rep *rep;
+};
+
+void mlx5e_register_vport_reps(struct mlx5e_priv *priv);
+void mlx5e_unregister_vport_reps(struct mlx5e_priv *priv);
+bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
+int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv);
+void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv);
+
+int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev, void *sp);
+bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id);
+
+int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
+void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
+
+#endif /* __MLX5E_REP_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index ae66fad98244..d717573b73da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -39,6 +39,7 @@
 #include "en.h"
 #include "en_tc.h"
 #include "eswitch.h"
+#include "en_rep.h"
 #include "ipoib.h"
 
 static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
@@ -809,7 +810,8 @@ void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 {
 	struct net_device *netdev = rq->netdev;
 	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv  = priv->ppriv;
+	struct mlx5_eswitch_rep *rep = rpriv->rep;
 	struct mlx5e_rx_wqe *wqe;
 	struct sk_buff *skb;
 	__be16 wqe_counter_be;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 21b5bcaf4bc0..7d379a189b63 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -46,6 +46,7 @@
 #include <net/vxlan.h>
 #include "en.h"
 #include "en_tc.h"
+#include "en_rep.h"
 #include "eswitch.h"
 #include "vxlan.h"
 
@@ -702,16 +703,18 @@ static int parse_cls_flower(struct mlx5e_priv *priv,
 {
 	struct mlx5_core_dev *dev = priv->mdev;
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5_eswitch_rep *rep;
 	u8 min_inline;
 	int err;
 
 	err = __parse_cls_flower(priv, spec, f, &min_inline);
 
-	if (!err && (flow->flags & MLX5E_TC_FLOW_ESWITCH) &&
-	    rep->vport != FDB_UPLINK_VPORT) {
-		if (esw->offloads.inline_mode != MLX5_INLINE_MODE_NONE &&
-		    esw->offloads.inline_mode < min_inline) {
+	if (!err && (flow->flags & MLX5E_TC_FLOW_ESWITCH)) {
+		rep = rpriv->rep;
+		if (rep->vport != FDB_UPLINK_VPORT &&
+		    (esw->offloads.inline_mode != MLX5_INLINE_MODE_NONE &&
+		    esw->offloads.inline_mode < min_inline)) {
 			netdev_warn(priv->netdev,
 				    "Flow is not offloaded due to min inline setting, required %d actual %d\n",
 				    min_inline, esw->offloads.inline_mode);
@@ -1439,6 +1442,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 	struct ip_tunnel_info *info = NULL;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
@@ -1449,7 +1453,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 		return -EINVAL;
 
 	memset(attr, 0, sizeof(*attr));
-	attr->in_rep = priv->ppriv;
+	attr->in_rep = rpriv->rep;
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
@@ -1481,7 +1485,8 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				attr->action |= MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
 					MLX5_FLOW_CONTEXT_ACTION_COUNT;
 				out_priv = netdev_priv(out_dev);
-				attr->out_rep = out_priv->ppriv;
+				rpriv = out_priv->ppriv;
+				attr->out_rep = rpriv->rep;
 			} else if (encap) {
 				err = mlx5e_attach_encap(priv, info,
 							 out_dev, attr);
@@ -1492,7 +1497,8 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 					MLX5_FLOW_CONTEXT_ACTION_FWD_DEST |
 					MLX5_FLOW_CONTEXT_ACTION_COUNT;
 				out_priv = netdev_priv(attr->encap->out_dev);
-				attr->out_rep = out_priv->ppriv;
+				rpriv = out_priv->ppriv;
+				attr->out_rep = rpriv->rep;
 			} else {
 				pr_err("devices %s %s not on same switch HW, can't offload forwarding\n",
 				       priv->netdev->name, out_dev->name);
-- 
2.11.0
