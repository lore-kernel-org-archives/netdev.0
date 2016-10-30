From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 08/15] net/mlx5: Add SRIOV VF max rate configuration support
Date: Sun, 30 Oct 2016 23:22:01 +0200
Message-ID: <1477862528-4328-9-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60344 "EHLO
        mellanox.co.il" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756539AbcJ3VXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:23:43 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Implement the vf set rate ndo by modifying the TSAR vport rate limit.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 15 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 63 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  2 +
 3 files changed, 80 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 7eaf380..7f763d2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2945,6 +2945,20 @@ static int mlx5e_set_vf_trust(struct net_device *dev, int vf, bool setting)
 
 	return mlx5_eswitch_set_vport_trust(mdev->priv.eswitch, vf + 1, setting);
 }
+
+static int mlx5e_set_vf_rate(struct net_device *dev, int vf, int min_tx_rate,
+			     int max_tx_rate)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	if (min_tx_rate)
+		return -EOPNOTSUPP;
+
+	return mlx5_eswitch_set_vport_rate(mdev->priv.eswitch, vf + 1,
+					   max_tx_rate);
+}
+
 static int mlx5_vport_link2ifla(u8 esw_link)
 {
 	switch (esw_link) {
@@ -3252,6 +3266,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
 	.ndo_set_vf_spoofchk     = mlx5e_set_vf_spoofchk,
 	.ndo_set_vf_trust        = mlx5e_set_vf_trust,
+	.ndo_set_vf_rate         = mlx5e_set_vf_rate,
 	.ndo_get_vf_config       = mlx5e_get_vf_config,
 	.ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 2e11a94..9ef01d1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1451,6 +1451,47 @@ static void esw_vport_disable_qos(struct mlx5_eswitch *esw, int vport_num)
 	vport->qos.enabled = false;
 }
 
+static int esw_vport_qos_config(struct mlx5_eswitch *esw, int vport_num,
+				u32 max_rate)
+{
+	u32 sched_ctx[MLX5_ST_SZ_DW(scheduling_context)] = {0};
+	struct mlx5_vport *vport = &esw->vports[vport_num];
+	struct mlx5_core_dev *dev = esw->dev;
+	void *vport_elem;
+	u32 bitmask = 0;
+	int err = 0;
+
+	if (!MLX5_CAP_GEN(dev, qos) || !MLX5_CAP_QOS(dev, esw_scheduling))
+		return -EOPNOTSUPP;
+
+	if (!vport->qos.enabled)
+		return -EIO;
+
+	MLX5_SET(scheduling_context, &sched_ctx, element_type,
+		 SCHEDULING_CONTEXT_ELEMENT_TYPE_VPORT);
+	vport_elem = MLX5_ADDR_OF(scheduling_context, &sched_ctx,
+				  element_attributes);
+	MLX5_SET(vport_element, vport_elem, vport_number, vport_num);
+	MLX5_SET(scheduling_context, &sched_ctx, parent_element_id,
+		 esw->qos.root_tsar_id);
+	MLX5_SET(scheduling_context, &sched_ctx, max_average_bw,
+		 max_rate);
+	bitmask |= MODIFY_SCHEDULING_ELEMENT_IN_MODIFY_BITMASK_MAX_AVERAGE_BW;
+
+	err = mlx5_modify_scheduling_element_cmd(dev,
+						 SCHEDULING_HIERARCHY_E_SWITCH,
+						 &sched_ctx,
+						 vport->qos.esw_tsar_ix,
+						 bitmask);
+	if (err) {
+		esw_warn(esw->dev, "E-Switch modify TSAR vport element failed (vport=%d,err=%d)\n",
+			 vport_num, err);
+		return err;
+	}
+
+	return 0;
+}
+
 static void node_guid_gen_from_mac(u64 *node_guid, u8 mac[ETH_ALEN])
 {
 	((u8 *)node_guid)[7] = mac[0];
@@ -1888,6 +1929,7 @@ int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 	ivi->qos = evport->info.qos;
 	ivi->spoofchk = evport->info.spoofchk;
 	ivi->trusted = evport->info.trusted;
+	ivi->max_tx_rate = evport->info.max_rate;
 	mutex_unlock(&esw->state_lock);
 
 	return 0;
@@ -1981,6 +2023,27 @@ int mlx5_eswitch_set_vport_trust(struct mlx5_eswitch *esw,
 	return 0;
 }
 
+int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw,
+				int vport, u32 max_rate)
+{
+	struct mlx5_vport *evport;
+	int err = 0;
+
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport))
+		return -EINVAL;
+
+	mutex_lock(&esw->state_lock);
+	evport = &esw->vports[vport];
+	err = esw_vport_qos_config(esw, vport, max_rate);
+	if (!err)
+		evport->info.max_rate = max_rate;
+
+	mutex_unlock(&esw->state_lock);
+	return err;
+}
+
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index fb8de34..ddae90c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -246,6 +246,8 @@ int mlx5_eswitch_set_vport_spoofchk(struct mlx5_eswitch *esw,
 				    int vport, bool spoofchk);
 int mlx5_eswitch_set_vport_trust(struct mlx5_eswitch *esw,
 				 int vport_num, bool setting);
+int mlx5_eswitch_set_vport_rate(struct mlx5_eswitch *esw,
+				int vport, u32 max_rate);
 int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 				  int vport, struct ifla_vf_info *ivi);
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
-- 
2.7.4
