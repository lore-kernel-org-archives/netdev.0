From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/10] net/mlx4_en: Use vlan id instead of vlan index for unregistration
Date: Thu, 31 Oct 2013 14:29:23 +0200
Message-ID: <1383222569-10930-5-git-send-email-ogerlitz@mellanox.com>
References: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41710 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753826Ab3JaM3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 08:29:50 -0400
In-Reply-To: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Use of vlan_index created problems unregistering vlans on guests.

In addition, tools delete vlan by tag, not by index, lets follow that.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    6 +---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    2 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |   27 +++++++++++---------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 include/linux/mlx4/device.h                        |    2 +-
 6 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index ae8eb4c..887d625 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1687,7 +1687,7 @@ static void mlx4_master_deactivate_admin_state(struct mlx4_priv *priv, int slave
 		vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 		if (NO_INDX != vp_oper->vlan_idx) {
 			__mlx4_unregister_vlan(&priv->dev,
-					       port, vp_oper->vlan_idx);
+					       port, vp_oper->state.default_vlan);
 			vp_oper->vlan_idx = NO_INDX;
 		}
 		if (NO_INDX != vp_oper->mac_idx) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 85d9166..b555412 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -417,7 +417,6 @@ static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;
-	int idx;
 
 	en_dbg(HW, priv, "Killing VID:%d\n", vid);
 
@@ -425,10 +424,7 @@ static int mlx4_en_vlan_rx_kill_vid(struct net_device *dev,
 
 	/* Remove VID from port VLAN filter */
 	mutex_lock(&mdev->state_lock);
-	if (!mlx4_find_cached_vlan(mdev->dev, priv->port, vid, &idx))
-		mlx4_unregister_vlan(mdev->dev, priv->port, idx);
-	else
-		en_dbg(HW, priv, "could not find vid %d in cache\n", vid);
+	mlx4_unregister_vlan(mdev->dev, priv->port, vid);
 
 	if (mdev->device_up && priv->port_up) {
 		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 348bb8c..f2ad4f6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1111,7 +1111,7 @@ int mlx4_change_port_types(struct mlx4_dev *dev,
 
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table);
 void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table);
-void __mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
+void __mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan);
 int __mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
 
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port, int pkey_tbl_sz);
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 9433c1f..caaa154 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -406,23 +406,26 @@ int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
 }
 EXPORT_SYMBOL_GPL(mlx4_register_vlan);
 
-void __mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
+void __mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan)
 {
 	struct mlx4_vlan_table *table = &mlx4_priv(dev)->port[port].vlan_table;
+	int index;
 
-	if (index < MLX4_VLAN_REGULAR) {
-		mlx4_warn(dev, "Trying to free special vlan index %d\n", index);
-		return;
+	mutex_lock(&table->mutex);
+	if (mlx4_find_cached_vlan(dev, port, vlan, &index)) {
+		mlx4_warn(dev, "vlan 0x%x is not in the vlan table\n", vlan);
+		goto out;
 	}
 
-	mutex_lock(&table->mutex);
-	if (!table->refs[index]) {
-		mlx4_warn(dev, "No vlan entry for index %d\n", index);
+	if (index < MLX4_VLAN_REGULAR) {
+		mlx4_warn(dev, "Trying to free special vlan index %d\n", index);
 		goto out;
 	}
+
 	if (--table->refs[index]) {
-		mlx4_dbg(dev, "Have more references for index %d,"
-			 "no need to modify vlan table\n", index);
+		mlx4_dbg(dev, "Have %d more references for index %d,"
+			 "no need to modify vlan table\n", table->refs[index],
+			 index);
 		goto out;
 	}
 	table->entries[index] = 0;
@@ -432,19 +435,19 @@ out:
 	mutex_unlock(&table->mutex);
 }
 
-void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
+void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan)
 {
 	u64 out_param = 0;
 
 	if (mlx4_is_mfunc(dev)) {
-		(void) mlx4_cmd_imm(dev, index, &out_param,
+		(void) mlx4_cmd_imm(dev, vlan, &out_param,
 				    ((u32) port) << 8 | (u32) RES_VLAN,
 				    RES_OP_RESERVE_AND_MAP,
 				    MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
 				    MLX4_CMD_WRAPPED);
 		return;
 	}
-	__mlx4_unregister_vlan(dev, port, index);
+	__mlx4_unregister_vlan(dev, port, vlan);
 }
 EXPORT_SYMBOL_GPL(mlx4_unregister_vlan);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index a5aa3be..993a2ef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -4085,7 +4085,7 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 	if (work->flags & MLX4_VF_IMMED_VLAN_FLAG_VLAN && !errors &&
 	    NO_INDX != work->orig_vlan_ix)
 		__mlx4_unregister_vlan(&work->priv->dev, work->port,
-				       work->orig_vlan_ix);
+				       work->orig_vlan_id);
 out:
 	kfree(work);
 	return;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 297a163..e2e9288 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1079,7 +1079,7 @@ int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 		u8 *pg, u16 *ratelimit);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
+void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, u16 vlan);
 
 int mlx4_map_phys_fmr(struct mlx4_dev *dev, struct mlx4_fmr *fmr, u64 *page_list,
 		      int npages, u64 iova, u32 *lkey, u32 *rkey);
-- 
1.7.1
