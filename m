From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 06/10] net/mlx4_core: Dynamically allocate structs at mlx4_slave_cap
Date: Sun, 27 Nov 2016 17:51:13 +0200
Message-ID: <1480261877-19720-7-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50467 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753164AbcK0Pvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:39 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

In order to avoid temporary large structs on the stack,
allocate them dynamically.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Tal Alon <talal@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 244 +++++++++++++++++-------------
 1 file changed, 142 insertions(+), 102 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 4a9497e9778d..65502df9fd96 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -799,40 +799,117 @@ static void slave_adjust_steering_mode(struct mlx4_dev *dev,
 		 mlx4_steering_mode_str(dev->caps.steering_mode));
 }
 
+static void mlx4_slave_destroy_special_qp_cap(struct mlx4_dev *dev)
+{
+	kfree(dev->caps.qp0_qkey);
+	kfree(dev->caps.qp0_tunnel);
+	kfree(dev->caps.qp0_proxy);
+	kfree(dev->caps.qp1_tunnel);
+	kfree(dev->caps.qp1_proxy);
+	dev->caps.qp0_qkey = NULL;
+	dev->caps.qp0_tunnel = NULL;
+	dev->caps.qp0_proxy = NULL;
+	dev->caps.qp1_tunnel = NULL;
+	dev->caps.qp1_proxy = NULL;
+}
+
+static int mlx4_slave_special_qp_cap(struct mlx4_dev *dev)
+{
+	struct mlx4_func_cap *func_cap = NULL;
+	int i, err = 0;
+
+	func_cap = kzalloc(sizeof(*func_cap), GFP_KERNEL);
+	dev->caps.qp0_qkey = kcalloc(dev->caps.num_ports,
+				     sizeof(u32), GFP_KERNEL);
+	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports,
+				       sizeof(u32), GFP_KERNEL);
+	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports,
+				      sizeof(u32), GFP_KERNEL);
+	dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports,
+				       sizeof(u32), GFP_KERNEL);
+	dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports,
+				      sizeof(u32), GFP_KERNEL);
+
+	if (!dev->caps.qp0_tunnel || !dev->caps.qp0_proxy ||
+	    !dev->caps.qp1_tunnel || !dev->caps.qp1_proxy ||
+	    !dev->caps.qp0_qkey || !func_cap) {
+		mlx4_err(dev, "Failed to allocate memory for special qps cap\n");
+		err = -ENOMEM;
+		goto err_mem;
+	}
+
+	for (i = 1; i <= dev->caps.num_ports; ++i) {
+		err = mlx4_QUERY_FUNC_CAP(dev, i, func_cap);
+		if (err) {
+			mlx4_err(dev, "QUERY_FUNC_CAP port command failed for port %d, aborting (%d)\n",
+				 i, err);
+			goto err_mem;
+		}
+		dev->caps.qp0_qkey[i - 1] = func_cap->qp0_qkey;
+		dev->caps.qp0_tunnel[i - 1] = func_cap->qp0_tunnel_qpn;
+		dev->caps.qp0_proxy[i - 1] = func_cap->qp0_proxy_qpn;
+		dev->caps.qp1_tunnel[i - 1] = func_cap->qp1_tunnel_qpn;
+		dev->caps.qp1_proxy[i - 1] = func_cap->qp1_proxy_qpn;
+		dev->caps.port_mask[i] = dev->caps.port_type[i];
+		dev->caps.phys_port_id[i] = func_cap->phys_port_id;
+		err = mlx4_get_slave_pkey_gid_tbl_len(dev, i,
+				    &dev->caps.gid_table_len[i],
+				    &dev->caps.pkey_table_len[i]);
+		if (err) {
+			mlx4_err(dev, "QUERY_PORT command failed for port %d, aborting (%d)\n",
+				 i, err);
+			goto err_mem;
+		}
+	}
+
+err_mem:
+	if (err)
+		mlx4_slave_destroy_special_qp_cap(dev);
+	kfree(func_cap);
+	return err;
+}
+
 static int mlx4_slave_cap(struct mlx4_dev *dev)
 {
 	int			   err;
 	u32			   page_size;
-	struct mlx4_dev_cap	   dev_cap;
-	struct mlx4_func_cap	   func_cap;
-	struct mlx4_init_hca_param hca_param;
-	u8			   i;
+	struct mlx4_dev_cap	   *dev_cap = NULL;
+	struct mlx4_func_cap	   *func_cap = NULL;
+	struct mlx4_init_hca_param *hca_param = NULL;
+
+	hca_param = kzalloc(sizeof(*hca_param), GFP_KERNEL);
+	func_cap = kzalloc(sizeof(*func_cap), GFP_KERNEL);
+	dev_cap = kzalloc(sizeof(*dev_cap), GFP_KERNEL);
+	if (!hca_param || !func_cap || !dev_cap) {
+		mlx4_err(dev, "Failed to allocate memory for slave_cap\n");
+		err = -ENOMEM;
+		goto free_mem;
+	}
 
-	memset(&hca_param, 0, sizeof(hca_param));
-	err = mlx4_QUERY_HCA(dev, &hca_param);
+	err = mlx4_QUERY_HCA(dev, hca_param);
 	if (err) {
 		mlx4_err(dev, "QUERY_HCA command failed, aborting\n");
-		return err;
+		goto free_mem;
 	}
 
 	/* fail if the hca has an unknown global capability
 	 * at this time global_caps should be always zeroed
 	 */
-	if (hca_param.global_caps) {
+	if (hca_param->global_caps) {
 		mlx4_err(dev, "Unknown hca global capabilities\n");
-		return -EINVAL;
+		err = -EINVAL;
+		goto free_mem;
 	}
 
-	mlx4_log_num_mgm_entry_size = hca_param.log_mc_entry_sz;
+	mlx4_log_num_mgm_entry_size = hca_param->log_mc_entry_sz;
 
-	dev->caps.hca_core_clock = hca_param.hca_core_clock;
+	dev->caps.hca_core_clock = hca_param->hca_core_clock;
 
-	memset(&dev_cap, 0, sizeof(dev_cap));
-	dev->caps.max_qp_dest_rdma = 1 << hca_param.log_rd_per_qp;
-	err = mlx4_dev_cap(dev, &dev_cap);
+	dev->caps.max_qp_dest_rdma = 1 << hca_param->log_rd_per_qp;
+	err = mlx4_dev_cap(dev, dev_cap);
 	if (err) {
 		mlx4_err(dev, "QUERY_DEV_CAP command failed, aborting\n");
-		return err;
+		goto free_mem;
 	}
 
 	err = mlx4_QUERY_FW(dev);
@@ -844,21 +921,23 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	if (page_size > PAGE_SIZE) {
 		mlx4_err(dev, "HCA minimum page size of %d bigger than kernel PAGE_SIZE of %ld, aborting\n",
 			 page_size, PAGE_SIZE);
-		return -ENODEV;
+		err = -ENODEV;
+		goto free_mem;
 	}
 
 	/* Set uar_page_shift for VF */
-	dev->uar_page_shift = hca_param.uar_page_sz + 12;
+	dev->uar_page_shift = hca_param->uar_page_sz + 12;
 
 	/* Make sure the master uar page size is valid */
 	if (dev->uar_page_shift > PAGE_SHIFT) {
 		mlx4_err(dev,
 			 "Invalid configuration: uar page size is larger than system page size\n");
-		return  -ENODEV;
+		err = -ENODEV;
+		goto free_mem;
 	}
 
 	/* Set reserved_uars based on the uar_page_shift */
-	mlx4_set_num_reserved_uars(dev, &dev_cap);
+	mlx4_set_num_reserved_uars(dev, dev_cap);
 
 	/* Although uar page size in FW differs from system page size,
 	 * upper software layers (mlx4_ib, mlx4_en and part of mlx4_core)
@@ -866,34 +945,35 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	 */
 	dev->caps.uar_page_size = PAGE_SIZE;
 
-	memset(&func_cap, 0, sizeof(func_cap));
-	err = mlx4_QUERY_FUNC_CAP(dev, 0, &func_cap);
+	err = mlx4_QUERY_FUNC_CAP(dev, 0, func_cap);
 	if (err) {
 		mlx4_err(dev, "QUERY_FUNC_CAP general command failed, aborting (%d)\n",
 			 err);
-		return err;
+		goto free_mem;
 	}
 
-	if ((func_cap.pf_context_behaviour | PF_CONTEXT_BEHAVIOUR_MASK) !=
+	if ((func_cap->pf_context_behaviour | PF_CONTEXT_BEHAVIOUR_MASK) !=
 	    PF_CONTEXT_BEHAVIOUR_MASK) {
 		mlx4_err(dev, "Unknown pf context behaviour %x known flags %x\n",
-			 func_cap.pf_context_behaviour, PF_CONTEXT_BEHAVIOUR_MASK);
-		return -EINVAL;
-	}
-
-	dev->caps.num_ports		= func_cap.num_ports;
-	dev->quotas.qp			= func_cap.qp_quota;
-	dev->quotas.srq			= func_cap.srq_quota;
-	dev->quotas.cq			= func_cap.cq_quota;
-	dev->quotas.mpt			= func_cap.mpt_quota;
-	dev->quotas.mtt			= func_cap.mtt_quota;
-	dev->caps.num_qps		= 1 << hca_param.log_num_qps;
-	dev->caps.num_srqs		= 1 << hca_param.log_num_srqs;
-	dev->caps.num_cqs		= 1 << hca_param.log_num_cqs;
-	dev->caps.num_mpts		= 1 << hca_param.log_mpt_sz;
-	dev->caps.num_eqs		= func_cap.max_eq;
-	dev->caps.reserved_eqs		= func_cap.reserved_eq;
-	dev->caps.reserved_lkey		= func_cap.reserved_lkey;
+			 func_cap->pf_context_behaviour,
+			 PF_CONTEXT_BEHAVIOUR_MASK);
+		err = -EINVAL;
+		goto free_mem;
+	}
+
+	dev->caps.num_ports		= func_cap->num_ports;
+	dev->quotas.qp			= func_cap->qp_quota;
+	dev->quotas.srq			= func_cap->srq_quota;
+	dev->quotas.cq			= func_cap->cq_quota;
+	dev->quotas.mpt			= func_cap->mpt_quota;
+	dev->quotas.mtt			= func_cap->mtt_quota;
+	dev->caps.num_qps		= 1 << hca_param->log_num_qps;
+	dev->caps.num_srqs		= 1 << hca_param->log_num_srqs;
+	dev->caps.num_cqs		= 1 << hca_param->log_num_cqs;
+	dev->caps.num_mpts		= 1 << hca_param->log_mpt_sz;
+	dev->caps.num_eqs		= func_cap->max_eq;
+	dev->caps.reserved_eqs		= func_cap->reserved_eq;
+	dev->caps.reserved_lkey		= func_cap->reserved_lkey;
 	dev->caps.num_pds               = MLX4_NUM_PDS;
 	dev->caps.num_mgms              = 0;
 	dev->caps.num_amgms             = 0;
@@ -906,38 +986,10 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 
 	mlx4_replace_zero_macs(dev);
 
-	dev->caps.qp0_qkey = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-	dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-	dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof (u32), GFP_KERNEL);
-
-	if (!dev->caps.qp0_tunnel || !dev->caps.qp0_proxy ||
-	    !dev->caps.qp1_tunnel || !dev->caps.qp1_proxy ||
-	    !dev->caps.qp0_qkey) {
-		err = -ENOMEM;
-		goto err_mem;
-	}
-
-	for (i = 1; i <= dev->caps.num_ports; ++i) {
-		err = mlx4_QUERY_FUNC_CAP(dev, i, &func_cap);
-		if (err) {
-			mlx4_err(dev, "QUERY_FUNC_CAP port command failed for port %d, aborting (%d)\n",
-				 i, err);
-			goto err_mem;
-		}
-		dev->caps.qp0_qkey[i - 1] = func_cap.qp0_qkey;
-		dev->caps.qp0_tunnel[i - 1] = func_cap.qp0_tunnel_qpn;
-		dev->caps.qp0_proxy[i - 1] = func_cap.qp0_proxy_qpn;
-		dev->caps.qp1_tunnel[i - 1] = func_cap.qp1_tunnel_qpn;
-		dev->caps.qp1_proxy[i - 1] = func_cap.qp1_proxy_qpn;
-		dev->caps.port_mask[i] = dev->caps.port_type[i];
-		dev->caps.phys_port_id[i] = func_cap.phys_port_id;
-		err = mlx4_get_slave_pkey_gid_tbl_len(dev, i,
-						      &dev->caps.gid_table_len[i],
-						      &dev->caps.pkey_table_len[i]);
-		if (err)
-			goto err_mem;
+	err = mlx4_slave_special_qp_cap(dev);
+	if (err) {
+		mlx4_err(dev, "Set special QP caps failed. aborting\n");
+		goto free_mem;
 	}
 
 	if (dev->caps.uar_page_size * (dev->caps.num_uars -
@@ -952,7 +1004,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		goto err_mem;
 	}
 
-	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_64B_EQE_ENABLED) {
+	if (hca_param->dev_cap_enabled & MLX4_DEV_CAP_64B_EQE_ENABLED) {
 		dev->caps.eqe_size   = 64;
 		dev->caps.eqe_factor = 1;
 	} else {
@@ -960,20 +1012,20 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		dev->caps.eqe_factor = 0;
 	}
 
-	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_64B_CQE_ENABLED) {
+	if (hca_param->dev_cap_enabled & MLX4_DEV_CAP_64B_CQE_ENABLED) {
 		dev->caps.cqe_size   = 64;
 		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
 	} else {
 		dev->caps.cqe_size   = 32;
 	}
 
-	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_EQE_STRIDE_ENABLED) {
-		dev->caps.eqe_size = hca_param.eqe_size;
+	if (hca_param->dev_cap_enabled & MLX4_DEV_CAP_EQE_STRIDE_ENABLED) {
+		dev->caps.eqe_size = hca_param->eqe_size;
 		dev->caps.eqe_factor = 0;
 	}
 
-	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_CQE_STRIDE_ENABLED) {
-		dev->caps.cqe_size = hca_param.cqe_size;
+	if (hca_param->dev_cap_enabled & MLX4_DEV_CAP_CQE_STRIDE_ENABLED) {
+		dev->caps.cqe_size = hca_param->cqe_size;
 		/* User still need to know when CQE > 32B */
 		dev->caps.userspace_caps |= MLX4_USER_DEV_CAP_LARGE_CQE;
 	}
@@ -981,31 +1033,24 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
 	mlx4_warn(dev, "Timestamping is not supported in slave mode\n");
 
-	slave_adjust_steering_mode(dev, &dev_cap, &hca_param);
+	slave_adjust_steering_mode(dev, dev_cap, hca_param);
 	mlx4_dbg(dev, "RSS support for IP fragments is %s\n",
-		 hca_param.rss_ip_frags ? "on" : "off");
+		 hca_param->rss_ip_frags ? "on" : "off");
 
-	if (func_cap.extra_flags & MLX4_QUERY_FUNC_FLAGS_BF_RES_QP &&
+	if (func_cap->extra_flags & MLX4_QUERY_FUNC_FLAGS_BF_RES_QP &&
 	    dev->caps.bf_reg_size)
 		dev->caps.alloc_res_qp_mask |= MLX4_RESERVE_ETH_BF_QP;
 
-	if (func_cap.extra_flags & MLX4_QUERY_FUNC_FLAGS_A0_RES_QP)
+	if (func_cap->extra_flags & MLX4_QUERY_FUNC_FLAGS_A0_RES_QP)
 		dev->caps.alloc_res_qp_mask |= MLX4_RESERVE_A0_QP;
 
-	return 0;
-
 err_mem:
-	kfree(dev->caps.qp0_qkey);
-	kfree(dev->caps.qp0_tunnel);
-	kfree(dev->caps.qp0_proxy);
-	kfree(dev->caps.qp1_tunnel);
-	kfree(dev->caps.qp1_proxy);
-	dev->caps.qp0_qkey = NULL;
-	dev->caps.qp0_tunnel = NULL;
-	dev->caps.qp0_proxy = NULL;
-	dev->caps.qp1_tunnel = NULL;
-	dev->caps.qp1_proxy = NULL;
-
+	if (err)
+		mlx4_slave_destroy_special_qp_cap(dev);
+free_mem:
+	kfree(hca_param);
+	kfree(func_cap);
+	kfree(dev_cap);
 	return err;
 }
 
@@ -2381,13 +2426,8 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 	unmap_internal_clock(dev);
 	unmap_bf_area(dev);
 
-	if (mlx4_is_slave(dev)) {
-		kfree(dev->caps.qp0_qkey);
-		kfree(dev->caps.qp0_tunnel);
-		kfree(dev->caps.qp0_proxy);
-		kfree(dev->caps.qp1_tunnel);
-		kfree(dev->caps.qp1_proxy);
-	}
+	if (mlx4_is_slave(dev))
+		mlx4_slave_destroy_special_qp_cap(dev);
 
 err_close:
 	if (mlx4_is_slave(dev))
-- 
1.8.3.1
