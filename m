From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/12] net/mlx5: Add support for setting VF min rate
Date: Tue, 24 Jan 2017 22:16:48 +0200
Message-ID: <20170124201652.2920-9-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54294 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751047AbdAXURa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:30 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Add support for SRIOV VF min rate guarantee by using the TSAR BW share
weights mechanism.

The TSAR BW share vport attribute represents the weight of that vport
among the other vports weights which means that the actual vport BW
percentage is the same vport weight percentage among the total vports
weights sum.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 97 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h | 11 ++-
 include/linux/mlx5/mlx5_ifc.h                     |  4 +-
 4 files changed, 104 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 3a06c81ef85e..c819d07fbdb3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3021,11 +3021,8 @@ static int mlx5e_set_vf_rate(struct net_device *dev, int vf, int min_tx_rate,
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
-	if (min_tx_rate)
-		return -EOPNOTSUPP;
-
 	return mlx5_eswitch_set_vport_rate(mdev->priv.eswitch, vf + 1,
-					   max_tx_rate);
+					   max_tx_rate, min_tx_rate);
 }
 
 static int mlx5_vport_link2ifla(u8 esw_link)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 4b3b60be319d..efa1a7a76d8a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1415,7 +1415,7 @@ static void esw_destroy_tsar(struct mlx5_eswitch *esw)
 }
 
 static int esw_vport_enable_qos(struct mlx5_eswitch *esw, int vport_num,
-				u32 initial_max_rate)
+				u32 initial_max_rate, u32 initial_bw_share)
 {
 	u32 sched_ctx[MLX5_ST_SZ_DW(scheduling_context)] = {0};
 	struct mlx5_vport *vport = &esw->vports[vport_num];
@@ -1439,6 +1439,7 @@ static int esw_vport_enable_qos(struct mlx5_eswitch *esw, int vport_num,
 		 esw->qos.root_tsar_id);
 	MLX5_SET(scheduling_context, &sched_ctx, max_average_bw,
 		 initial_max_rate);
+	MLX5_SET(scheduling_context, &sched_ctx, bw_share, initial_bw_share);
 
 	err = mlx5_create_scheduling_element_cmd(dev,
 						 SCHEDULING_HIERARCHY_E_SWITCH,
@@ -1473,7 +1474,7 @@ static void esw_vport_disable_qos(struct mlx5_eswitch *esw, int vport_num)
 }
 
 static int esw_vport_qos_config(struct mlx5_eswitch *esw, int vport_num,
-				u32 max_rate)
+				u32 max_rate, u32 bw_share)
 {
 	u32 sched_ctx[MLX5_ST_SZ_DW(scheduling_context)] = {0};
 	struct mlx5_vport *vport = &esw->vports[vport_num];
@@ -1497,7 +1498,9 @@ static int esw_vport_qos_config(struct mlx5_eswitch *esw, int vport_num,
 		 esw->qos.root_tsar_id);
 	MLX5_SET(scheduling_context, &sched_ctx, max_average_bw,
 		 max_rate);
+	MLX5_SET(scheduling_context, &sched_ctx, bw_share, bw_share);
 	bitmask |= MODIFY_SCHEDULING_ELEMENT_IN_MODIFY_BITMASK_MAX_AVERAGE_BW;
+	bitmask |= MODIFY_SCHEDULING_ELEMENT_IN_MODIFY_BITMASK_BW_SHARE;
 
 	err = mlx5_modify_scheduling_element_cmd(dev,
 						 SCHEDULING_HIERARCHY_E_SWITCH,
@@ -1563,7 +1566,8 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 	esw_apply_vport_conf(esw, vport);
 
 	/* Attach vport to the eswitch rate limiter */
-	if (esw_vport_enable_qos(esw, vport_num, vport->info.max_rate))
+	if (esw_vport_enable_qos(esw, vport_num, vport->info.max_rate,
+				 vport->qos.bw_share))
 		esw_warn(esw->dev, "Failed to attach vport %d to eswitch rate limiter", vport_num);
 
 	/* Sync with current vport context */
@@ -1952,6 +1956,7 @@ int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 	ivi->qos = evport->info.qos;
 	ivi->spoofchk = evport->info.spoofchk;
 	ivi->trusted = evport->info.trusted;
+	ivi->min_tx_rate = evport->info.min_rate;
 	ivi->max_tx_rate = evport->info.max_rate;
 	mutex_unlock(&esw->state_lock);
 
@@ -2046,23 +2051,103 @@ int mlx5_eswitch_set_vport_trust(struct mlx5_eswitch *esw,
 	return 0;
 }
 
-int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw,
-				int vport, u32 max_rate)
+static u32 calculate_vports_min_rate_divider(struct mlx5_eswitch *esw)
 {
+	u32 fw_max_bw_share = MLX5_CAP_QOS(esw->dev, max_tsar_bw_share);
 	struct mlx5_vport *evport;
+	u32 max_guarantee = 0;
+	int i;
+
+	for (i = 0; i <= esw->total_vports; i++) {
+		evport = &esw->vports[i];
+		if (!evport->enabled || evport->info.min_rate < max_guarantee)
+			continue;
+		max_guarantee = evport->info.min_rate;
+	}
+
+	return max_t(u32, max_guarantee / fw_max_bw_share, 1);
+}
+
+static int normalize_vports_min_rate(struct mlx5_eswitch *esw, u32 divider)
+{
+	u32 fw_max_bw_share = MLX5_CAP_QOS(esw->dev, max_tsar_bw_share);
+	struct mlx5_vport *evport;
+	u32 vport_max_rate;
+	u32 vport_min_rate;
+	u32 bw_share;
+	int err;
+	int i;
+
+	for (i = 0; i <= esw->total_vports; i++) {
+		evport = &esw->vports[i];
+		if (!evport->enabled)
+			continue;
+		vport_min_rate = evport->info.min_rate;
+		vport_max_rate = evport->info.max_rate;
+		bw_share = MLX5_MIN_BW_SHARE;
+
+		if (vport_min_rate)
+			bw_share = MLX5_RATE_TO_BW_SHARE(vport_min_rate,
+							 divider,
+							 fw_max_bw_share);
+
+		if (bw_share == evport->qos.bw_share)
+			continue;
+
+		err = esw_vport_qos_config(esw, i, vport_max_rate,
+					   bw_share);
+		if (!err)
+			evport->qos.bw_share = bw_share;
+		else
+			return err;
+	}
+
+	return 0;
+}
+
+int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw, int vport,
+				u32 max_rate, u32 min_rate)
+{
+	u32 fw_max_bw_share = MLX5_CAP_QOS(esw->dev, max_tsar_bw_share);
+	bool min_rate_supported = MLX5_CAP_QOS(esw->dev, esw_bw_share) &&
+					fw_max_bw_share >= MLX5_MIN_BW_SHARE;
+	bool max_rate_supported = MLX5_CAP_QOS(esw->dev, esw_rate_limit);
+	struct mlx5_vport *evport;
+	u32 previous_min_rate;
+	u32 divider;
 	int err = 0;
 
 	if (!ESW_ALLOWED(esw))
 		return -EPERM;
 	if (!LEGAL_VPORT(esw, vport))
 		return -EINVAL;
+	if ((min_rate && !min_rate_supported) || (max_rate && !max_rate_supported))
+		return -EOPNOTSUPP;
 
 	mutex_lock(&esw->state_lock);
 	evport = &esw->vports[vport];
-	err = esw_vport_qos_config(esw, vport, max_rate);
+
+	if (min_rate == evport->info.min_rate)
+		goto set_max_rate;
+
+	previous_min_rate = evport->info.min_rate;
+	evport->info.min_rate = min_rate;
+	divider = calculate_vports_min_rate_divider(esw);
+	err = normalize_vports_min_rate(esw, divider);
+	if (err) {
+		evport->info.min_rate = previous_min_rate;
+		goto unlock;
+	}
+
+set_max_rate:
+	if (max_rate == evport->info.max_rate)
+		goto unlock;
+
+	err = esw_vport_qos_config(esw, vport, max_rate, evport->qos.bw_share);
 	if (!err)
 		evport->info.max_rate = max_rate;
 
+unlock:
 	mutex_unlock(&esw->state_lock);
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index cea1660d59ac..5b78883d5654 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -50,6 +50,11 @@
 
 #define FDB_UPLINK_VPORT 0xffff
 
+#define MLX5_MIN_BW_SHARE 1
+
+#define MLX5_RATE_TO_BW_SHARE(rate, divider, limit) \
+	min_t(u32, max_t(u32, (rate) / (divider), MLX5_MIN_BW_SHARE), limit)
+
 /* L2 -mac address based- hash helpers */
 struct l2addr_node {
 	struct hlist_node hlist;
@@ -116,6 +121,7 @@ struct mlx5_vport_info {
 	u8                      qos;
 	u64                     node_guid;
 	int                     link_state;
+	u32                     min_rate;
 	u32                     max_rate;
 	bool                    spoofchk;
 	bool                    trusted;
@@ -138,6 +144,7 @@ struct mlx5_vport {
 	struct {
 		bool            enabled;
 		u32             esw_tsar_ix;
+		u32             bw_share;
 	} qos;
 
 	bool                    enabled;
@@ -249,8 +256,8 @@ int mlx5_eswitch_set_vport_spoofchk(struct mlx5_eswitch *esw,
 				    int vport, bool spoofchk);
 int mlx5_eswitch_set_vport_trust(struct mlx5_eswitch *esw,
 				 int vport_num, bool setting);
-int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw,
-				int vport, u32 max_rate);
+int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw, int vport,
+				u32 max_rate, u32 min_rate);
 int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 				  int vport, struct ifla_vf_info *ivi);
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index d96ebc319d63..a919dfb920ae 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -547,7 +547,9 @@ struct mlx5_ifc_e_switch_cap_bits {
 struct mlx5_ifc_qos_cap_bits {
 	u8         packet_pacing[0x1];
 	u8         esw_scheduling[0x1];
-	u8         reserved_at_2[0x1e];
+	u8         esw_bw_share[0x1];
+	u8         esw_rate_limit[0x1];
+	u8         reserved_at_4[0x1c];
 
 	u8         reserved_at_20[0x20];
 
-- 
2.11.0
