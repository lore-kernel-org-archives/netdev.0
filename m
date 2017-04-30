From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 15/15] net/mlx5: E-Switch, Avoid redundant memory allocation
Date: Sun, 30 Apr 2017 16:20:16 +0300
Message-ID: <20170430132016.27012-16-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Eli Cohen <eli@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46820 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756886AbdD3NUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:38 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

struct esw_mc_addr is a small struct that can be part of struct
mlx5_eswitch. Define it as a field and not as a pointer and save the
kzalloc call and then error flow handling.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 20 ++------------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  9 ++++++++-
 2 files changed, 10 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 21bed3c3334d..2e34d95ea776 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -53,13 +53,6 @@ struct esw_uc_addr {
 	u32                vport;
 };
 
-/* E-Switch MC FDB table hash node */
-struct esw_mc_addr { /* SRIOV only */
-	struct l2addr_node     node;
-	struct mlx5_flow_handle *uplink_rule; /* Forward to uplink rule */
-	u32                    refcnt;
-};
-
 /* Vport UC/MC hash node */
 struct vport_addr {
 	struct l2addr_node     node;
@@ -817,7 +810,7 @@ static void esw_update_vport_mc_promisc(struct mlx5_eswitch *esw, u32 vport_num)
 static void esw_apply_vport_rx_mode(struct mlx5_eswitch *esw, u32 vport_num,
 				    bool promisc, bool mc_promisc)
 {
-	struct esw_mc_addr *allmulti_addr = esw->mc_promisc;
+	struct esw_mc_addr *allmulti_addr = &esw->mc_promisc;
 	struct mlx5_vport *vport = &esw->vports[vport_num];
 
 	if (IS_ERR_OR_NULL(vport->allmulti_rule) != mc_promisc)
@@ -1688,7 +1681,7 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 	esw_info(esw->dev, "disable SRIOV: active vports(%d) mode(%d)\n",
 		 esw->enabled_vports, esw->mode);
 
-	mc_promisc = esw->mc_promisc;
+	mc_promisc = &esw->mc_promisc;
 	nvports = esw->enabled_vports;
 
 	for (i = 0; i < esw->total_vports; i++)
@@ -1732,7 +1725,6 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 {
 	int l2_table_size = 1 << MLX5_CAP_GEN(dev, log_max_l2_table);
 	int total_vports = MLX5_TOTAL_VPORTS(dev);
-	struct esw_mc_addr *mc_promisc;
 	struct mlx5_eswitch *esw;
 	int vport_num;
 	int err;
@@ -1761,13 +1753,6 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	}
 	esw->l2_table.size = l2_table_size;
 
-	mc_promisc = kzalloc(sizeof(*mc_promisc), GFP_KERNEL);
-	if (!mc_promisc) {
-		err = -ENOMEM;
-		goto abort;
-	}
-	esw->mc_promisc = mc_promisc;
-
 	esw->work_queue = create_singlethread_workqueue("mlx5_esw_wq");
 	if (!esw->work_queue) {
 		err = -ENOMEM;
@@ -1835,7 +1820,6 @@ void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw)
 	esw->dev->priv.eswitch = NULL;
 	destroy_workqueue(esw->work_queue);
 	kfree(esw->l2_table.bitmap);
-	kfree(esw->mc_promisc);
 	kfree(esw->offloads.vport_reps);
 	kfree(esw->vports);
 	kfree(esw);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 55beda6bf134..b746f62c8c79 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -212,6 +212,13 @@ struct mlx5_esw_offload {
 	u8 encap;
 };
 
+/* E-Switch MC FDB table hash node */
+struct esw_mc_addr { /* SRIOV only */
+	struct l2addr_node     node;
+	struct mlx5_flow_handle *uplink_rule; /* Forward to uplink rule */
+	u32                    refcnt;
+};
+
 struct mlx5_eswitch {
 	struct mlx5_core_dev    *dev;
 	struct mlx5_l2_table    l2_table;
@@ -225,7 +232,7 @@ struct mlx5_eswitch {
 	 * and async SRIOV admin state changes
 	 */
 	struct mutex            state_lock;
-	struct esw_mc_addr      *mc_promisc;
+	struct esw_mc_addr	mc_promisc;
 
 	struct {
 		bool            enabled;
-- 
2.11.0
