From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 12/12] net/mlx5: E-Switch, Implement trust vf ndo
Date: Tue,  3 May 2016 17:14:04 +0300
Message-ID: <1462284844-16926-13-git-send-email-saeedm@mellanox.com>
References: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48794 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcECOPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 10:15:09 -0400
In-Reply-To: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

- Add support to configure trusted vf attribute through trust_vf_ndo.

- Upon VF trust setting change we update vport context to refresh
 allmulti/promisc or any trusted vf attributes that we didn't trust the
 VF for before.

- Lock the eswitch state lock on vport event in order to synchronise the
 vport context updates , this will prevent contention with vport trust
 setting change which will trigger vport mac list update.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  8 +++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 40 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  2 ++
 3 files changed, 45 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2587369..bf2dd87 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2447,6 +2447,13 @@ static int mlx5e_set_vf_spoofchk(struct net_device *dev, int vf, bool setting)
 	return mlx5_eswitch_set_vport_spoofchk(mdev->priv.eswitch, vf + 1, setting);
 }
 
+static int mlx5e_set_vf_trust(struct net_device *dev, int vf, bool setting)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	return mlx5_eswitch_set_vport_trust(mdev->priv.eswitch, vf + 1, setting);
+}
 static int mlx5_vport_link2ifla(u8 esw_link)
 {
 	switch (esw_link) {
@@ -2617,6 +2624,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
 	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
 	.ndo_set_vf_spoofchk     = mlx5e_set_vf_spoofchk,
+	.ndo_set_vf_trust        = mlx5e_set_vf_trust,
 	.ndo_get_vf_config       = mlx5e_get_vf_config,
 	.ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
 	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index ad4bc98..b84a691 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -974,10 +974,8 @@ static void esw_update_vport_rx_mode(struct mlx5_eswitch *esw, u32 vport_num)
 				(promisc_all || promisc_mc));
 }
 
-static void esw_vport_change_handler(struct work_struct *work)
+static void esw_vport_change_handle_locked(struct mlx5_vport *vport)
 {
-	struct mlx5_vport *vport =
-		container_of(work, struct mlx5_vport, vport_change_handler);
 	struct mlx5_core_dev *dev = vport->dev;
 	struct mlx5_eswitch *esw = dev->priv.eswitch;
 	u8 mac[ETH_ALEN];
@@ -1015,6 +1013,17 @@ static void esw_vport_change_handler(struct work_struct *work)
 					     vport->enabled_events);
 }
 
+static void esw_vport_change_handler(struct work_struct *work)
+{
+	struct mlx5_vport *vport =
+		container_of(work, struct mlx5_vport, vport_change_handler);
+	struct mlx5_eswitch *esw = vport->dev->priv.eswitch;
+
+	mutex_lock(&esw->state_lock);
+	esw_vport_change_handle_locked(vport);
+	mutex_unlock(&esw->state_lock);
+}
+
 static void esw_vport_enable_egress_acl(struct mlx5_eswitch *esw,
 					struct mlx5_vport *vport)
 {
@@ -1482,7 +1491,7 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 
 	/* Sync with current vport context */
 	vport->enabled_events = enable_events;
-	esw_vport_change_handler(&vport->vport_change_handler);
+	esw_vport_change_handle_locked(vport);
 
 	vport->enabled = true;
 
@@ -1522,7 +1531,7 @@ static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 	 * Calling vport change handler while vport is disabled will cleanup
 	 * the vport resources.
 	 */
-	esw_vport_change_handler(&vport->vport_change_handler);
+	esw_vport_change_handle_locked(vport);
 	vport->enabled_events = 0;
 	if (vport_num) {
 		esw_vport_disable_egress_acl(esw, vport);
@@ -1859,6 +1868,27 @@ int mlx5_eswitch_set_vport_spoofchk(struct mlx5_eswitch *esw,
 	return err;
 }
 
+int mlx5_eswitch_set_vport_trust(struct mlx5_eswitch *esw,
+				 int vport, bool setting)
+{
+	struct mlx5_vport *evport;
+
+	if (!ESW_ALLOWED(esw))
+		return -EPERM;
+	if (!LEGAL_VPORT(esw, vport))
+		return -EINVAL;
+
+	evport = &esw->vports[vport];
+
+	mutex_lock(&esw->state_lock);
+	evport->trusted = setting;
+	if (evport->enabled)
+		esw_vport_change_handle_locked(evport);
+	mutex_unlock(&esw->state_lock);
+
+	return 0;
+}
+
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
 				 int vport,
 				 struct ifla_vf_stats *vf_stats)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index a39f18e..fd68002 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -169,6 +169,8 @@ int mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
 				int vport, u16 vlan, u8 qos);
 int mlx5_eswitch_set_vport_spoofchk(struct mlx5_eswitch *esw,
 				    int vport, bool spoofchk);
+int mlx5_eswitch_set_vport_trust(struct mlx5_eswitch *esw,
+				 int vport_num, bool setting);
 int mlx5_eswitch_get_vport_config(struct mlx5_eswitch *esw,
 				  int vport, struct ifla_vf_info *ivi);
 int mlx5_eswitch_get_vport_stats(struct mlx5_eswitch *esw,
-- 
2.8.0
