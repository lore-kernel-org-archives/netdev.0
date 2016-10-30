From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 07/15] net/mlx5: Introduce E-switch QoS management
Date: Sun, 30 Oct 2016 23:22:00 +0200
Message-ID: <1477862528-4328-8-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60304 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756707AbcJ3VXo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:23:44 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Add TSAR to the eswitch which will act as the vports rate limiter.
Create/Destroy TSAR on Enable/Dsiable SRIOV.
Attach/Detach vport to eswitch TSAR on Enable/Disable vport.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 113 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  12 +++
 2 files changed, 124 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index abbf2c3..2e11a94 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1351,6 +1351,106 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 	return err;
 }
 
+/* Vport QoS management */
+static int esw_create_tsar(struct mlx5_eswitch *esw)
+{
+	u32 tsar_ctx[MLX5_ST_SZ_DW(scheduling_context)] = {0};
+	struct mlx5_core_dev *dev = esw->dev;
+	int err;
+
+	if (!MLX5_CAP_GEN(dev, qos) || !MLX5_CAP_QOS(dev, esw_scheduling))
+		return 0;
+
+	if (esw->qos.enabled)
+		return -EEXIST;
+
+	err = mlx5_create_scheduling_element_cmd(dev,
+						 SCHEDULING_HIERARCHY_E_SWITCH,
+						 &tsar_ctx,
+						 &esw->qos.root_tsar_id);
+	if (err) {
+		esw_warn(esw->dev, "E-Switch create TSAR failed (%d)\n", err);
+		return err;
+	}
+
+	esw->qos.enabled = true;
+	return 0;
+}
+
+static void esw_destroy_tsar(struct mlx5_eswitch *esw)
+{
+	int err;
+
+	if (!esw->qos.enabled)
+		return;
+
+	err = mlx5_destroy_scheduling_element_cmd(esw->dev,
+						  SCHEDULING_HIERARCHY_E_SWITCH,
+						  esw->qos.root_tsar_id);
+	if (err)
+		esw_warn(esw->dev, "E-Switch destroy TSAR failed (%d)\n", err);
+
+	esw->qos.enabled = false;
+}
+
+static int esw_vport_enable_qos(struct mlx5_eswitch *esw, int vport_num,
+				u32 initial_max_rate)
+{
+	u32 sched_ctx[MLX5_ST_SZ_DW(scheduling_context)] = {0};
+	struct mlx5_vport *vport = &esw->vports[vport_num];
+	struct mlx5_core_dev *dev = esw->dev;
+	void *vport_elem;
+	int err = 0;
+
+	if (!esw->qos.enabled || !MLX5_CAP_GEN(dev, qos) ||
+	    !MLX5_CAP_QOS(dev, esw_scheduling))
+		return 0;
+
+	if (vport->qos.enabled)
+		return -EEXIST;
+
+	MLX5_SET(scheduling_context, &sched_ctx, element_type,
+		 SCHEDULING_CONTEXT_ELEMENT_TYPE_VPORT);
+	vport_elem = MLX5_ADDR_OF(scheduling_context, &sched_ctx,
+				  element_attributes);
+	MLX5_SET(vport_element, vport_elem, vport_number, vport_num);
+	MLX5_SET(scheduling_context, &sched_ctx, parent_element_id,
+		 esw->qos.root_tsar_id);
+	MLX5_SET(scheduling_context, &sched_ctx, max_average_bw,
+		 initial_max_rate);
+
+	err = mlx5_create_scheduling_element_cmd(dev,
+						 SCHEDULING_HIERARCHY_E_SWITCH,
+						 &sched_ctx,
+						 &vport->qos.esw_tsar_ix);
+	if (err) {
+		esw_warn(esw->dev, "E-Switch create TSAR vport element failed (vport=%d,err=%d)\n",
+			 vport_num, err);
+		return err;
+	}
+
+	vport->qos.enabled = true;
+	return 0;
+}
+
+static void esw_vport_disable_qos(struct mlx5_eswitch *esw, int vport_num)
+{
+	struct mlx5_vport *vport = &esw->vports[vport_num];
+	int err = 0;
+
+	if (!vport->qos.enabled)
+		return;
+
+	err = mlx5_destroy_scheduling_element_cmd(esw->dev,
+						  SCHEDULING_HIERARCHY_E_SWITCH,
+						  vport->qos.esw_tsar_ix);
+	if (err)
+		esw_warn(esw->dev, "E-Switch destroy TSAR vport element failed (vport=%d,err=%d)\n",
+			 vport_num, err);
+
+	vport->qos.enabled = false;
+}
+
 static void node_guid_gen_from_mac(u64 *node_guid, u8 mac[ETH_ALEN])
 {
 	((u8 *)node_guid)[7] = mac[0];
@@ -1386,6 +1486,7 @@ static void esw_apply_vport_conf(struct mlx5_eswitch *esw,
 		esw_vport_egress_config(esw, vport);
 	}
 }
+
 static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 			     int enable_events)
 {
@@ -1399,6 +1500,10 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 	/* Restore old vport configuration */
 	esw_apply_vport_conf(esw, vport);
 
+	/* Attach vport to the eswitch rate limiter */
+	if (esw_vport_enable_qos(esw, vport_num, vport->info.max_rate))
+		esw_warn(esw->dev, "Failed to attach vport %d to eswitch rate limiter", vport_num);
+
 	/* Sync with current vport context */
 	vport->enabled_events = enable_events;
 	vport->enabled = true;
@@ -1437,7 +1542,7 @@ static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 	 */
 	esw_vport_change_handle_locked(vport);
 	vport->enabled_events = 0;
-
+	esw_vport_disable_qos(esw, vport_num);
 	if (vport_num && esw->mode == SRIOV_LEGACY) {
 		mlx5_modify_vport_admin_state(esw->dev,
 					      MLX5_QUERY_VPORT_STATE_IN_OP_MOD_ESW_VPORT,
@@ -1483,6 +1588,10 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 	if (err)
 		goto abort;
 
+	err = esw_create_tsar(esw);
+	if (err)
+		esw_warn(esw->dev, "Failed to create eswitch TSAR");
+
 	enabled_events = (mode == SRIOV_LEGACY) ? SRIOV_VPORT_EVENTS : UC_ADDR_CHANGE;
 	for (i = 0; i <= nvfs; i++)
 		esw_enable_vport(esw, i, enabled_events);
@@ -1519,6 +1628,8 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 	if (mc_promisc && mc_promisc->uplink_rule)
 		mlx5_del_flow_rule(mc_promisc->uplink_rule);
 
+	esw_destroy_tsar(esw);
+
 	if (esw->mode == SRIOV_LEGACY)
 		esw_destroy_legacy_fdb_table(esw);
 	else if (esw->mode == SRIOV_OFFLOADS)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 2e2938e..fb8de34 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -115,6 +115,7 @@ struct mlx5_vport_info {
 	u8                      qos;
 	u64                     node_guid;
 	int                     link_state;
+	u32                     max_rate;
 	bool                    spoofchk;
 	bool                    trusted;
 };
@@ -133,6 +134,11 @@ struct mlx5_vport {
 
 	struct mlx5_vport_info  info;
 
+	struct {
+		bool            enabled;
+		u32             esw_tsar_ix;
+	} qos;
+
 	bool                    enabled;
 	u16                     enabled_events;
 };
@@ -209,6 +215,12 @@ struct mlx5_eswitch {
 	 */
 	struct mutex            state_lock;
 	struct esw_mc_addr      *mc_promisc;
+
+	struct {
+		bool            enabled;
+		u32             root_tsar_id;
+	} qos;
+
 	struct mlx5_esw_offload offloads;
 	int                     mode;
 };
-- 
2.7.4
