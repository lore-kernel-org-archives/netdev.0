From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/30] net/mlx5: Improve driver log messages
Date: Sat, 20 Aug 2016 23:11:55 +0300
Message-ID: <1471723933-5894-13-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Parvi Kaustubhi <parvik@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34162 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751830AbcHTUMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:44 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicate pci dev name printing in mlx5_core_err.
Use mlx5_core_{warn,info,err} where possible to have the pci info in the
driver log messages.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Parvi Kaustubhi <parvik@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 26 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 18 ++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 11 ++++-----
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |  7 +++---
 6 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 1c7d8b8..681c12c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -416,8 +416,8 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 {
 	rep->priv_data = mlx5e_create_netdev(esw->dev, &mlx5e_rep_profile, rep);
 	if (!rep->priv_data) {
-		pr_warn("Failed to create representor for vport %d\n",
-			rep->vport);
+		mlx5_core_warn(esw->dev, "Failed to create representor for vport %d\n",
+			       rep->vport);
 		return -EINVAL;
 	}
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 0a364bf..7c493599 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -306,7 +306,7 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 
 	spec = mlx5_vzalloc(sizeof(*spec));
 	if (!spec) {
-		pr_warn("FDB: Failed to alloc match parameters\n");
+		esw_warn(esw->dev, "FDB: Failed to alloc match parameters\n");
 		return NULL;
 	}
 	dmac_v = MLX5_ADDR_OF(fte_match_param, spec->match_value,
@@ -340,8 +340,8 @@ __esw_fdb_set_vport_rule(struct mlx5_eswitch *esw, u32 vport, bool rx_rule,
 				   MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,
 				   0, &dest);
 	if (IS_ERR(flow_rule)) {
-		pr_warn(
-			"FDB: Failed to add flow rule: dmac_v(%pM) dmac_c(%pM) -> vport(%d), err(%ld)\n",
+		esw_warn(esw->dev,
+			 "FDB: Failed to add flow rule: dmac_v(%pM) dmac_c(%pM) -> vport(%d), err(%ld)\n",
 			 dmac_v, dmac_c, vport, PTR_ERR(flow_rule));
 		flow_rule = NULL;
 	}
@@ -1318,8 +1318,9 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				   0, NULL);
 	if (IS_ERR(vport->ingress.allow_rule)) {
 		err = PTR_ERR(vport->ingress.allow_rule);
-		pr_warn("vport[%d] configure ingress allow rule, err(%d)\n",
-			vport->vport, err);
+		esw_warn(esw->dev,
+			 "vport[%d] configure ingress allow rule, err(%d)\n",
+			 vport->vport, err);
 		vport->ingress.allow_rule = NULL;
 		goto out;
 	}
@@ -1331,8 +1332,9 @@ static int esw_vport_ingress_config(struct mlx5_eswitch *esw,
 				   0, NULL);
 	if (IS_ERR(vport->ingress.drop_rule)) {
 		err = PTR_ERR(vport->ingress.drop_rule);
-		pr_warn("vport[%d] configure ingress drop rule, err(%d)\n",
-			vport->vport, err);
+		esw_warn(esw->dev,
+			 "vport[%d] configure ingress drop rule, err(%d)\n",
+			 vport->vport, err);
 		vport->ingress.drop_rule = NULL;
 		goto out;
 	}
@@ -1384,8 +1386,9 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   0, NULL);
 	if (IS_ERR(vport->egress.allowed_vlan)) {
 		err = PTR_ERR(vport->egress.allowed_vlan);
-		pr_warn("vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
-			vport->vport, err);
+		esw_warn(esw->dev,
+			 "vport[%d] configure egress allowed vlan rule failed, err(%d)\n",
+			 vport->vport, err);
 		vport->egress.allowed_vlan = NULL;
 		goto out;
 	}
@@ -1398,8 +1401,9 @@ static int esw_vport_egress_config(struct mlx5_eswitch *esw,
 				   0, NULL);
 	if (IS_ERR(vport->egress.drop_rule)) {
 		err = PTR_ERR(vport->egress.drop_rule);
-		pr_warn("vport[%d] configure egress drop rule failed, err(%d)\n",
-			vport->vport, err);
+		esw_warn(esw->dev,
+			 "vport[%d] configure egress drop rule failed, err(%d)\n",
+			 vport->vport, err);
 		vport->egress.drop_rule = NULL;
 	}
 out:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 75bb8c8..243efc5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -345,7 +345,7 @@ static void del_flow_table(struct fs_node *node)
 
 	err = mlx5_cmd_destroy_flow_table(dev, ft);
 	if (err)
-		pr_warn("flow steering can't destroy ft\n");
+		mlx5_core_warn(dev, "flow steering can't destroy ft\n");
 	fs_get_obj(prio, ft->node.parent);
 	prio->num_ft--;
 }
@@ -364,7 +364,7 @@ static void del_rule(struct fs_node *node)
 
 	match_value = mlx5_vzalloc(match_len);
 	if (!match_value) {
-		pr_warn("failed to allocate inbox\n");
+		mlx5_core_warn(dev, "failed to allocate inbox\n");
 		return;
 	}
 
@@ -387,8 +387,9 @@ static void del_rule(struct fs_node *node)
 					  modify_mask,
 					  fte);
 		if (err)
-			pr_warn("%s can't del rule fg id=%d fte_index=%d\n",
-				__func__, fg->id, fte->index);
+			mlx5_core_warn(dev,
+				       "%s can't del rule fg id=%d fte_index=%d\n",
+				       __func__, fg->id, fte->index);
 	}
 	kvfree(match_value);
 }
@@ -409,8 +410,9 @@ static void del_fte(struct fs_node *node)
 	err = mlx5_cmd_delete_fte(dev, ft,
 				  fte->index);
 	if (err)
-		pr_warn("flow steering can't delete fte in index %d of flow group id %d\n",
-			fte->index, fg->id);
+		mlx5_core_warn(dev,
+			       "flow steering can't delete fte in index %d of flow group id %d\n",
+			       fte->index, fg->id);
 
 	fte->status = 0;
 	fg->num_ftes--;
@@ -427,8 +429,8 @@ static void del_flow_group(struct fs_node *node)
 	dev = get_dev(&ft->node);
 
 	if (mlx5_cmd_destroy_flow_group(dev, ft, fg->id))
-		pr_warn("flow steering can't destroy fg %d of ft %d\n",
-			fg->id, ft->id);
+		mlx5_core_warn(dev, "flow steering can't destroy fg %d of ft %d\n",
+			       fg->id, ft->id);
 }
 
 static struct fs_fte *alloc_fte(u8 action,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 7fd6622..d6446a3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -324,7 +324,7 @@ enum {
 				MLX5_DEV_CAP_FLAG_DCT,
 };
 
-static u16 to_fw_pkey_sz(u32 size)
+static u16 to_fw_pkey_sz(struct mlx5_core_dev *dev, u32 size)
 {
 	switch (size) {
 	case 128:
@@ -340,7 +340,7 @@ static u16 to_fw_pkey_sz(u32 size)
 	case 4096:
 		return 5;
 	default:
-		pr_warn("invalid pkey table size %d\n", size);
+		mlx5_core_warn(dev, "invalid pkey table size %d\n", size);
 		return 0;
 	}
 }
@@ -477,7 +477,7 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 		      128);
 	/* we limit the size of the pkey table to 128 entries for now */
 	MLX5_SET(cmd_hca_cap, set_hca_cap, pkey_table_size,
-		 to_fw_pkey_sz(128));
+		 to_fw_pkey_sz(dev, 128));
 
 	if (prof->mask & MLX5_PROF_MASK_QP_SIZE)
 		MLX5_SET(cmd_hca_cap, set_hca_cap, log_max_qp,
@@ -1312,8 +1312,9 @@ static int init_one(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, dev);
 
 	if (prof_sel < 0 || prof_sel >= ARRAY_SIZE(profile)) {
-		pr_warn("selected profile out of range, selecting default (%d)\n",
-			MLX5_DEFAULT_PROF);
+		mlx5_core_warn(dev,
+			       "selected profile out of range, selecting default (%d)\n",
+			       MLX5_DEFAULT_PROF);
 		prof_sel = MLX5_DEFAULT_PROF;
 	}
 	dev->profile = &profile[prof_sel];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 14242f1..ef0eeed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -58,8 +58,8 @@ do {									\
 } while (0)
 
 #define mlx5_core_err(__dev, format, ...)				\
-	dev_err(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
-	       (__dev)->priv.name, __func__, __LINE__, current->pid,	\
+	dev_err(&(__dev)->pdev->dev, "%s:%d:(pid %d): " format,	\
+		__func__, __LINE__, current->pid,	\
 	       ##__VA_ARGS__)
 
 #define mlx5_core_warn(__dev, format, ...)				\
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
index b380a6b..0680dfb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/sriov.c
@@ -155,13 +155,13 @@ int mlx5_core_sriov_configure(struct pci_dev *pdev, int num_vfs)
 		if (!pci_vfs_assigned(pdev))
 			pci_disable_sriov(pdev);
 		else
-			pr_info("unloading PF driver while leaving orphan VFs\n");
+			mlx5_core_info(dev, "unloading PF driver while leaving orphan VFs\n");
 		return 0;
 	}
 
 	err = mlx5_core_sriov_enable(pdev, num_vfs);
 	if (err) {
-		dev_warn(&pdev->dev, "mlx5_core_sriov_enable failed %d\n", err);
+		mlx5_core_warn(dev, "mlx5_core_sriov_enable failed %d\n", err);
 		return err;
 	}
 
@@ -180,7 +180,8 @@ static int sync_required(struct pci_dev *pdev)
 	int cur_vfs = pci_num_vf(pdev);
 
 	if (cur_vfs != sriov->num_vfs) {
-		pr_info("current VFs %d, registered %d - sync needed\n", cur_vfs, sriov->num_vfs);
+		mlx5_core_warn(dev, "current VFs %d, registered %d - sync needed\n",
+			       cur_vfs, sriov->num_vfs);
 		return 1;
 	}
 
-- 
2.7.4
