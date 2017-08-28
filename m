From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/4] net/mlx4_core: Dynamically allocate structs at mlx4_slave_cap
Date: Mon, 28 Aug 2017 16:38:20 +0300
Message-ID: <1503927503-29065-2-git-send-email-tariqt@mellanox.com>
References: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38608 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751209AbdH1NjM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 09:39:12 -0400
In-Reply-To: <1503927503-29065-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

In order to avoid temporary large structs on the stack,
allocate them dynamically.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Tal Alon <talal@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx4/qp.c           |  26 ++--
 drivers/net/ethernet/mellanox/mlx4/fw.c   |  12 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h   |   6 +-
 drivers/net/ethernet/mellanox/mlx4/main.c | 235 ++++++++++++++++--------------
 drivers/net/ethernet/mellanox/mlx4/qp.c   |  24 +--
 include/linux/mlx4/device.h               |  14 +-
 6 files changed, 159 insertions(+), 158 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 75c0e6c5dd56..83e5c72f19b8 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -145,8 +145,8 @@ static int is_sqp(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp)
 	/* VF or PF -- proxy SQP */
 	if (mlx4_is_mfunc(dev->dev)) {
 		for (i = 0; i < dev->dev->caps.num_ports; i++) {
-			if (qp->mqp.qpn == dev->dev->caps.qp0_proxy[i] ||
-			    qp->mqp.qpn == dev->dev->caps.qp1_proxy[i]) {
+			if (qp->mqp.qpn == dev->dev->caps.spec_qps[i].qp0_proxy ||
+			    qp->mqp.qpn == dev->dev->caps.spec_qps[i].qp1_proxy) {
 				proxy_sqp = 1;
 				break;
 			}
@@ -173,7 +173,7 @@ static int is_qp0(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp)
 	/* VF or PF -- proxy QP0 */
 	if (mlx4_is_mfunc(dev->dev)) {
 		for (i = 0; i < dev->dev->caps.num_ports; i++) {
-			if (qp->mqp.qpn == dev->dev->caps.qp0_proxy[i]) {
+			if (qp->mqp.qpn == dev->dev->caps.spec_qps[i].qp0_proxy) {
 				proxy_qp0 = 1;
 				break;
 			}
@@ -614,8 +614,8 @@ static int qp0_enabled_vf(struct mlx4_dev *dev, int qpn)
 {
 	int i;
 	for (i = 0; i < dev->caps.num_ports; i++) {
-		if (qpn == dev->caps.qp0_proxy[i])
-			return !!dev->caps.qp0_qkey[i];
+		if (qpn == dev->caps.spec_qps[i].qp0_proxy)
+			return !!dev->caps.spec_qps[i].qp0_qkey;
 	}
 	return 0;
 }
@@ -1114,9 +1114,9 @@ static u32 get_sqp_num(struct mlx4_ib_dev *dev, struct ib_qp_init_attr *attr)
 	}
 	/* PF or VF -- creating proxies */
 	if (attr->qp_type == IB_QPT_SMI)
-		return dev->dev->caps.qp0_proxy[attr->port_num - 1];
+		return dev->dev->caps.spec_qps[attr->port_num - 1].qp0_proxy;
 	else
-		return dev->dev->caps.qp1_proxy[attr->port_num - 1];
+		return dev->dev->caps.spec_qps[attr->port_num - 1].qp1_proxy;
 }
 
 static struct ib_qp *_mlx4_ib_create_qp(struct ib_pd *pd,
@@ -2277,9 +2277,9 @@ static int vf_get_qp0_qkey(struct mlx4_dev *dev, int qpn, u32 *qkey)
 {
 	int i;
 	for (i = 0; i < dev->caps.num_ports; i++) {
-		if (qpn == dev->caps.qp0_proxy[i] ||
-		    qpn == dev->caps.qp0_tunnel[i]) {
-			*qkey = dev->caps.qp0_qkey[i];
+		if (qpn == dev->caps.spec_qps[i].qp0_proxy ||
+		    qpn == dev->caps.spec_qps[i].qp0_tunnel) {
+			*qkey = dev->caps.spec_qps[i].qp0_qkey;
 			return 0;
 		}
 	}
@@ -2340,7 +2340,7 @@ static int build_sriov_qp0_header(struct mlx4_ib_sqp *sqp,
 		sqp->ud_header.bth.destination_qpn = cpu_to_be32(wr->remote_qpn);
 	else
 		sqp->ud_header.bth.destination_qpn =
-			cpu_to_be32(mdev->dev->caps.qp0_tunnel[sqp->qp.port - 1]);
+			cpu_to_be32(mdev->dev->caps.spec_qps[sqp->qp.port - 1].qp0_tunnel);
 
 	sqp->ud_header.bth.psn = cpu_to_be32((sqp->send_psn++) & ((1 << 24) - 1));
 	if (mlx4_is_master(mdev->dev)) {
@@ -2800,9 +2800,9 @@ static void set_tunnel_datagram_seg(struct mlx4_ib_dev *dev,
 
 	memcpy(dseg->av, &sqp_av, sizeof (struct mlx4_av));
 	if (qpt == MLX4_IB_QPT_PROXY_GSI)
-		dseg->dqpn = cpu_to_be32(dev->dev->caps.qp1_tunnel[port - 1]);
+		dseg->dqpn = cpu_to_be32(dev->dev->caps.spec_qps[port - 1].qp1_tunnel);
 	else
-		dseg->dqpn = cpu_to_be32(dev->dev->caps.qp0_tunnel[port - 1]);
+		dseg->dqpn = cpu_to_be32(dev->dev->caps.spec_qps[port - 1].qp0_tunnel);
 	/* Use QKEY from the QP context, which is set by master */
 	dseg->qkey = cpu_to_be32(IB_QP_SET_QKEY);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 042707623922..f76cac01d564 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -679,22 +679,22 @@ int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 
 	if (func_cap->flags1 & QUERY_FUNC_CAP_VF_ENABLE_QP0) {
 		MLX4_GET(qkey, outbox, QUERY_FUNC_CAP_PRIV_VF_QKEY_OFFSET);
-		func_cap->qp0_qkey = qkey;
+		func_cap->spec_qps.qp0_qkey = qkey;
 	} else {
-		func_cap->qp0_qkey = 0;
+		func_cap->spec_qps.qp0_qkey = 0;
 	}
 
 	MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP0_TUNNEL);
-	func_cap->qp0_tunnel_qpn = size & 0xFFFFFF;
+	func_cap->spec_qps.qp0_tunnel = size & 0xFFFFFF;
 
 	MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP0_PROXY);
-	func_cap->qp0_proxy_qpn = size & 0xFFFFFF;
+	func_cap->spec_qps.qp0_proxy = size & 0xFFFFFF;
 
 	MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP1_TUNNEL);
-	func_cap->qp1_tunnel_qpn = size & 0xFFFFFF;
+	func_cap->spec_qps.qp1_tunnel = size & 0xFFFFFF;
 
 	MLX4_GET(size, outbox, QUERY_FUNC_CAP_QP1_PROXY);
-	func_cap->qp1_proxy_qpn = size & 0xFFFFFF;
+	func_cap->spec_qps.qp1_proxy = size & 0xFFFFFF;
 
 	if (func_cap->flags1 & QUERY_FUNC_CAP_FLAGS1_NIC_INFO)
 		MLX4_GET(func_cap->phys_port_id, outbox,
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index b52ba01aa486..cd6399c76bfd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -144,11 +144,7 @@ struct mlx4_func_cap {
 	int	max_eq;
 	int	reserved_eq;
 	int	mcg_quota;
-	u32	qp0_qkey;
-	u32	qp0_tunnel_qpn;
-	u32	qp0_proxy_qpn;
-	u32	qp1_tunnel_qpn;
-	u32	qp1_proxy_qpn;
+	struct mlx4_spec_qps spec_qps;
 	u32	reserved_lkey;
 	u8	physical_port;
 	u8	flags0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 8404e165eca4..e6413a8a5f07 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -819,38 +819,93 @@ static void slave_adjust_steering_mode(struct mlx4_dev *dev,
 		 mlx4_steering_mode_str(dev->caps.steering_mode));
 }
 
+static void mlx4_slave_destroy_special_qp_cap(struct mlx4_dev *dev)
+{
+	kfree(dev->caps.spec_qps);
+	dev->caps.spec_qps = NULL;
+}
+
+static int mlx4_slave_special_qp_cap(struct mlx4_dev *dev)
+{
+	struct mlx4_func_cap *func_cap = NULL;
+	struct mlx4_caps *caps = &dev->caps;
+	int i, err = 0;
+
+	func_cap = kzalloc(sizeof(*func_cap), GFP_KERNEL);
+	caps->spec_qps = kcalloc(caps->num_ports, sizeof(*caps->spec_qps), GFP_KERNEL);
+
+	if (!func_cap || !caps->spec_qps) {
+		mlx4_err(dev, "Failed to allocate memory for special qps cap\n");
+		err = -ENOMEM;
+		goto err_mem;
+	}
+
+	for (i = 1; i <= caps->num_ports; ++i) {
+		err = mlx4_QUERY_FUNC_CAP(dev, i, func_cap);
+		if (err) {
+			mlx4_err(dev, "QUERY_FUNC_CAP port command failed for port %d, aborting (%d)\n",
+				 i, err);
+			goto err_mem;
+		}
+		caps->spec_qps[i - 1] = func_cap->spec_qps;
+		caps->port_mask[i] = caps->port_type[i];
+		caps->phys_port_id[i] = func_cap->phys_port_id;
+		err = mlx4_get_slave_pkey_gid_tbl_len(dev, i,
+						      &caps->gid_table_len[i],
+						      &caps->pkey_table_len[i]);
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
@@ -862,21 +917,23 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
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
@@ -884,34 +941,35 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
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
@@ -924,38 +982,10 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 
 	mlx4_replace_zero_macs(dev);
 
-	dev->caps.qp0_qkey = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-	dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-	dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-	dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-	dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
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
@@ -970,7 +1000,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		goto err_mem;
 	}
 
-	if (hca_param.dev_cap_enabled & MLX4_DEV_CAP_64B_EQE_ENABLED) {
+	if (hca_param->dev_cap_enabled & MLX4_DEV_CAP_64B_EQE_ENABLED) {
 		dev->caps.eqe_size   = 64;
 		dev->caps.eqe_factor = 1;
 	} else {
@@ -978,20 +1008,20 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
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
@@ -999,31 +1029,24 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
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
 
@@ -2407,13 +2430,8 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
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
@@ -3596,13 +3614,8 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 		mlx4_multi_func_cleanup(dev);
 	}
 
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
 	mlx4_close_hca(dev);
@@ -3942,11 +3955,7 @@ static void mlx4_unload_one(struct pci_dev *pdev)
 	if (!mlx4_is_slave(dev))
 		mlx4_free_ownership(dev);
 
-	kfree(dev->caps.qp0_qkey);
-	kfree(dev->caps.qp0_tunnel);
-	kfree(dev->caps.qp0_proxy);
-	kfree(dev->caps.qp1_tunnel);
-	kfree(dev->caps.qp1_proxy);
+	mlx4_slave_destroy_special_qp_cap(dev);
 	kfree(dev->dev_vfs);
 
 	mlx4_clean_dev(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 2b067763a6bc..28c441c0d31f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -844,24 +844,20 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 
 		/* In mfunc, calculate proxy and tunnel qp offsets for the PF here,
 		 * since the PF does not call mlx4_slave_caps */
-		dev->caps.qp0_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-		dev->caps.qp0_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-		dev->caps.qp1_tunnel = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
-		dev->caps.qp1_proxy = kcalloc(dev->caps.num_ports, sizeof(u32), GFP_KERNEL);
+		dev->caps.spec_qps = kcalloc(dev->caps.num_ports, sizeof(dev->caps.spec_qps), GFP_KERNEL);
 
-		if (!dev->caps.qp0_tunnel || !dev->caps.qp0_proxy ||
-		    !dev->caps.qp1_tunnel || !dev->caps.qp1_proxy) {
+		if (!dev->caps.spec_qps) {
 			err = -ENOMEM;
 			goto err_mem;
 		}
 
 		for (k = 0; k < dev->caps.num_ports; k++) {
-			dev->caps.qp0_proxy[k] = dev->phys_caps.base_proxy_sqpn +
+			dev->caps.spec_qps[k].qp0_proxy = dev->phys_caps.base_proxy_sqpn +
 				8 * mlx4_master_func_num(dev) + k;
-			dev->caps.qp0_tunnel[k] = dev->caps.qp0_proxy[k] + 8 * MLX4_MFUNC_MAX;
-			dev->caps.qp1_proxy[k] = dev->phys_caps.base_proxy_sqpn +
+			dev->caps.spec_qps[k].qp0_tunnel = dev->caps.spec_qps[k].qp0_proxy + 8 * MLX4_MFUNC_MAX;
+			dev->caps.spec_qps[k].qp1_proxy = dev->phys_caps.base_proxy_sqpn +
 				8 * mlx4_master_func_num(dev) + MLX4_MAX_PORTS + k;
-			dev->caps.qp1_tunnel[k] = dev->caps.qp1_proxy[k] + 8 * MLX4_MFUNC_MAX;
+			dev->caps.spec_qps[k].qp1_tunnel = dev->caps.spec_qps[k].qp1_proxy + 8 * MLX4_MFUNC_MAX;
 		}
 	}
 
@@ -873,12 +869,8 @@ int mlx4_init_qp_table(struct mlx4_dev *dev)
 	return err;
 
 err_mem:
-	kfree(dev->caps.qp0_tunnel);
-	kfree(dev->caps.qp0_proxy);
-	kfree(dev->caps.qp1_tunnel);
-	kfree(dev->caps.qp1_proxy);
-	dev->caps.qp0_tunnel = dev->caps.qp0_proxy =
-		dev->caps.qp1_tunnel = dev->caps.qp1_proxy = NULL;
+	kfree(dev->caps.spec_qps);
+	dev->caps.spec_qps = NULL;
 	mlx4_cleanup_qp_zones(dev);
 	return err;
 }
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index b54517c05e9a..9844606f9491 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -518,6 +518,14 @@ struct mlx4_phys_caps {
 	u32			base_tunnel_sqpn;
 };
 
+struct mlx4_spec_qps {
+	u32 qp0_qkey;
+	u32 qp0_proxy;
+	u32 qp0_tunnel;
+	u32 qp1_proxy;
+	u32 qp1_tunnel;
+};
+
 struct mlx4_caps {
 	u64			fw_ver;
 	u32			function;
@@ -547,11 +555,7 @@ struct mlx4_caps {
 	int			max_qp_init_rdma;
 	int			max_qp_dest_rdma;
 	int			max_tc_eth;
-	u32			*qp0_qkey;
-	u32			*qp0_proxy;
-	u32			*qp1_proxy;
-	u32			*qp0_tunnel;
-	u32			*qp1_tunnel;
+	struct mlx4_spec_qps   *spec_qps;
 	int			num_srqs;
 	int			max_srq_wqes;
 	int			max_srq_sge;
-- 
1.8.3.1
