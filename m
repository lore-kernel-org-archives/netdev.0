From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 05/11] net/mlx5_core/ib: New device capabilities handling.
Date: Wed,  8 Apr 2015 17:51:19 +0300
Message-ID: <1428504685-8945-6-git-send-email-amirv@mellanox.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:36624 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932370AbbDHOwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 10:52:14 -0400
In-Reply-To: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

- Query all supported types of dev caps on driver load.
- Store the Cap data outbox per cap type into driver private data.
- Introduce new Macros to access/dump stored caps (using eat.me auto generated data types).
- obsolete SW representation of dev caps (no need for SW copy for each cap).
- modify ib driver to use new Macros for checking Caps.
- modify linux EN driver to use new Macros for checking Caps.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/infiniband/hw/mlx5/cq.c                    |   8 +-
 drivers/infiniband/hw/mlx5/mad.c                   |   2 +-
 drivers/infiniband/hw/mlx5/main.c                  | 113 ++++++++-------
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |   6 +-
 drivers/infiniband/hw/mlx5/mr.c                    |   3 +-
 drivers/infiniband/hw/mlx5/odp.c                   |  47 +++----
 drivers/infiniband/hw/mlx5/qp.c                    |  84 +++++------
 drivers/infiniband/hw/mlx5/srq.c                   |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  90 +++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 154 +++++++--------------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   7 +-
 include/linux/mlx5/device.h                        |  66 ++++++++-
 include/linux/mlx5/driver.h                        |  58 +-------
 15 files changed, 310 insertions(+), 349 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 2ee6b10..d9814df 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -754,7 +754,7 @@ struct ib_cq *mlx5_ib_create_cq(struct ib_device *ibdev, int entries,
 		return ERR_PTR(-EINVAL);
 
 	entries = roundup_pow_of_two(entries + 1);
-	if (entries > dev->mdev->caps.gen.max_cqes)
+	if (entries > (1 << MLX5_CAP_GEN(dev->mdev, log_max_cq_sz)))
 		return ERR_PTR(-EINVAL);
 
 	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
@@ -921,7 +921,7 @@ int mlx5_ib_modify_cq(struct ib_cq *cq, u16 cq_count, u16 cq_period)
 	int err;
 	u32 fsel;
 
-	if (!(dev->mdev->caps.gen.flags & MLX5_DEV_CAP_FLAG_CQ_MODER))
+	if (!MLX5_CAP_GEN(dev->mdev, cq_moderation))
 		return -ENOSYS;
 
 	in = kzalloc(sizeof(*in), GFP_KERNEL);
@@ -1076,7 +1076,7 @@ int mlx5_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata)
 	int uninitialized_var(cqe_size);
 	unsigned long flags;
 
-	if (!(dev->mdev->caps.gen.flags & MLX5_DEV_CAP_FLAG_RESIZE_CQ)) {
+	if (!MLX5_CAP_GEN(dev->mdev, cq_resize)) {
 		pr_info("Firmware does not support resize CQ\n");
 		return -ENOSYS;
 	}
@@ -1085,7 +1085,7 @@ int mlx5_ib_resize_cq(struct ib_cq *ibcq, int entries, struct ib_udata *udata)
 		return -EINVAL;
 
 	entries = roundup_pow_of_two(entries + 1);
-	if (entries > dev->mdev->caps.gen.max_cqes + 1)
+	if (entries >  (1 << MLX5_CAP_GEN(dev->mdev, log_max_cq_sz)) + 1)
 		return -EINVAL;
 
 	if (entries == ibcq->cqe + 1)
diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
index 9cf9a37..f2d9e70 100644
--- a/drivers/infiniband/hw/mlx5/mad.c
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -129,7 +129,7 @@ int mlx5_query_ext_port_caps(struct mlx5_ib_dev *dev, u8 port)
 
 	packet_error = be16_to_cpu(out_mad->status);
 
-	dev->mdev->caps.gen.ext_port_cap[port - 1] = (!err && !packet_error) ?
+	dev->mdev->port_caps[port - 1].ext_port_cap = (!err && !packet_error) ?
 		MLX_EXT_PORT_CAP_FLAG_EXTENDED_PORT_INFO : 0;
 
 out:
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 57c9809..9075649 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -66,15 +66,13 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 				struct ib_device_attr *props)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
 	struct ib_smp *in_mad  = NULL;
 	struct ib_smp *out_mad = NULL;
-	struct mlx5_general_caps *gen;
 	int err = -ENOMEM;
 	int max_rq_sg;
 	int max_sq_sg;
-	u64 flags;
 
-	gen = &dev->mdev->caps.gen;
 	in_mad  = kzalloc(sizeof(*in_mad), GFP_KERNEL);
 	out_mad = kmalloc(sizeof(*out_mad), GFP_KERNEL);
 	if (!in_mad || !out_mad)
@@ -96,18 +94,18 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 		IB_DEVICE_PORT_ACTIVE_EVENT		|
 		IB_DEVICE_SYS_IMAGE_GUID		|
 		IB_DEVICE_RC_RNR_NAK_GEN;
-	flags = gen->flags;
-	if (flags & MLX5_DEV_CAP_FLAG_BAD_PKEY_CNTR)
+
+	if (MLX5_CAP_GEN(mdev, pkv))
 		props->device_cap_flags |= IB_DEVICE_BAD_PKEY_CNTR;
-	if (flags & MLX5_DEV_CAP_FLAG_BAD_QKEY_CNTR)
+	if (MLX5_CAP_GEN(mdev, qkv))
 		props->device_cap_flags |= IB_DEVICE_BAD_QKEY_CNTR;
-	if (flags & MLX5_DEV_CAP_FLAG_APM)
+	if (MLX5_CAP_GEN(mdev, apm))
 		props->device_cap_flags |= IB_DEVICE_AUTO_PATH_MIG;
 	props->device_cap_flags |= IB_DEVICE_LOCAL_DMA_LKEY;
-	if (flags & MLX5_DEV_CAP_FLAG_XRC)
+	if (MLX5_CAP_GEN(mdev, xrc))
 		props->device_cap_flags |= IB_DEVICE_XRC;
 	props->device_cap_flags |= IB_DEVICE_MEM_MGT_EXTENSIONS;
-	if (flags & MLX5_DEV_CAP_FLAG_SIG_HAND_OVER) {
+	if (MLX5_CAP_GEN(mdev, sho)) {
 		props->device_cap_flags |= IB_DEVICE_SIGNATURE_HANDOVER;
 		/* At this stage no support for signature handover */
 		props->sig_prot_cap = IB_PROT_T10DIF_TYPE_1 |
@@ -116,7 +114,7 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 		props->sig_guard_cap = IB_GUARD_T10DIF_CRC |
 				       IB_GUARD_T10DIF_CSUM;
 	}
-	if (flags & MLX5_DEV_CAP_FLAG_BLOCK_MCAST)
+	if (MLX5_CAP_GEN(mdev, block_lb_mc))
 		props->device_cap_flags |= IB_DEVICE_BLOCK_MULTICAST_LOOPBACK;
 
 	props->vendor_id	   = be32_to_cpup((__be32 *)(out_mad->data + 36)) &
@@ -126,37 +124,38 @@ static int mlx5_ib_query_device(struct ib_device *ibdev,
 	memcpy(&props->sys_image_guid, out_mad->data +	4, 8);
 
 	props->max_mr_size	   = ~0ull;
-	props->page_size_cap	   = gen->min_page_sz;
-	props->max_qp		   = 1 << gen->log_max_qp;
-	props->max_qp_wr	   = gen->max_wqes;
-	max_rq_sg = gen->max_rq_desc_sz / sizeof(struct mlx5_wqe_data_seg);
-	max_sq_sg = (gen->max_sq_desc_sz - sizeof(struct mlx5_wqe_ctrl_seg)) /
-		sizeof(struct mlx5_wqe_data_seg);
+	props->page_size_cap	   = 1ull << MLX5_CAP_GEN(mdev, log_pg_sz);
+	props->max_qp		   = 1 << MLX5_CAP_GEN(mdev, log_max_qp);
+	props->max_qp_wr	   = 1 << MLX5_CAP_GEN(mdev, log_max_qp_sz);
+	max_rq_sg =  MLX5_CAP_GEN(mdev, max_wqe_sz_rq) /
+		     sizeof(struct mlx5_wqe_data_seg);
+	max_sq_sg = (MLX5_CAP_GEN(mdev, max_wqe_sz_sq) -
+		     sizeof(struct mlx5_wqe_ctrl_seg)) /
+		     sizeof(struct mlx5_wqe_data_seg);
 	props->max_sge = min(max_rq_sg, max_sq_sg);
-	props->max_cq		   = 1 << gen->log_max_cq;
-	props->max_cqe		   = gen->max_cqes - 1;
-	props->max_mr		   = 1 << gen->log_max_mkey;
-	props->max_pd		   = 1 << gen->log_max_pd;
-	props->max_qp_rd_atom	   = 1 << gen->log_max_ra_req_qp;
-	props->max_qp_init_rd_atom = 1 << gen->log_max_ra_res_qp;
-	props->max_srq		   = 1 << gen->log_max_srq;
-	props->max_srq_wr	   = gen->max_srq_wqes - 1;
-	props->local_ca_ack_delay  = gen->local_ca_ack_delay;
+	props->max_cq		   = 1 << MLX5_CAP_GEN(mdev, log_max_cq);
+	props->max_cqe = (1 << MLX5_CAP_GEN(mdev, log_max_eq_sz)) - 1;
+	props->max_mr		   = 1 << MLX5_CAP_GEN(mdev, log_max_mkey);
+	props->max_pd		   = 1 << MLX5_CAP_GEN(mdev, log_max_pd);
+	props->max_qp_rd_atom	   = 1 << MLX5_CAP_GEN(mdev, log_max_ra_req_qp);
+	props->max_qp_init_rd_atom = 1 << MLX5_CAP_GEN(mdev, log_max_ra_res_qp);
+	props->max_srq		   = 1 << MLX5_CAP_GEN(mdev, log_max_srq);
+	props->max_srq_wr = (1 << MLX5_CAP_GEN(mdev, log_max_srq_sz)) - 1;
+	props->local_ca_ack_delay  = MLX5_CAP_GEN(mdev, local_ca_ack_delay);
 	props->max_res_rd_atom	   = props->max_qp_rd_atom * props->max_qp;
 	props->max_srq_sge	   = max_rq_sg - 1;
 	props->max_fast_reg_page_list_len = (unsigned int)-1;
-	props->local_ca_ack_delay  = gen->local_ca_ack_delay;
 	props->atomic_cap	   = IB_ATOMIC_NONE;
 	props->masked_atomic_cap   = IB_ATOMIC_NONE;
 	props->max_pkeys	   = be16_to_cpup((__be16 *)(out_mad->data + 28));
-	props->max_mcast_grp	   = 1 << gen->log_max_mcg;
-	props->max_mcast_qp_attach = gen->max_qp_mcg;
+	props->max_mcast_grp	   = 1 << MLX5_CAP_GEN(mdev, log_max_mcg);
+	props->max_mcast_qp_attach = MLX5_CAP_GEN(mdev, max_qp_mcg);
 	props->max_total_mcast_qp_attach = props->max_mcast_qp_attach *
 					   props->max_mcast_grp;
 	props->max_map_per_fmr = INT_MAX; /* no limit in ConnectIB */
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
-	if (dev->mdev->caps.gen.flags & MLX5_DEV_CAP_FLAG_ON_DMND_PG)
+	if (MLX5_CAP_GEN(mdev, pg))
 		props->device_cap_flags |= IB_DEVICE_ON_DEMAND_PAGING;
 	props->odp_caps = dev->odp_caps;
 #endif
@@ -172,14 +171,13 @@ int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
 		       struct ib_port_attr *props)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibdev);
+	struct mlx5_core_dev *mdev = dev->mdev;
 	struct ib_smp *in_mad  = NULL;
 	struct ib_smp *out_mad = NULL;
-	struct mlx5_general_caps *gen;
 	int ext_active_speed;
 	int err = -ENOMEM;
 
-	gen = &dev->mdev->caps.gen;
-	if (port < 1 || port > gen->num_ports) {
+	if (port < 1 || port > MLX5_CAP_GEN(mdev, num_ports)) {
 		mlx5_ib_warn(dev, "invalid port number %d\n", port);
 		return -EINVAL;
 	}
@@ -210,8 +208,8 @@ int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
 	props->phys_state	= out_mad->data[33] >> 4;
 	props->port_cap_flags	= be32_to_cpup((__be32 *)(out_mad->data + 20));
 	props->gid_tbl_len	= out_mad->data[50];
-	props->max_msg_sz	= 1 << gen->log_max_msg;
-	props->pkey_tbl_len	= gen->port[port - 1].pkey_table_len;
+	props->max_msg_sz	= 1 << MLX5_CAP_GEN(mdev, log_max_msg);
+	props->pkey_tbl_len	= mdev->port_caps[port - 1].pkey_table_len;
 	props->bad_pkey_cntr	= be16_to_cpup((__be16 *)(out_mad->data + 46));
 	props->qkey_viol_cntr	= be16_to_cpup((__be16 *)(out_mad->data + 48));
 	props->active_width	= out_mad->data[31] & 0xf;
@@ -238,7 +236,7 @@ int mlx5_ib_query_port(struct ib_device *ibdev, u8 port,
 
 	/* If reported active speed is QDR, check if is FDR-10 */
 	if (props->active_speed == 4) {
-		if (gen->ext_port_cap[port - 1] &
+		if (mdev->port_caps[port - 1].ext_port_cap &
 		    MLX_EXT_PORT_CAP_FLAG_EXTENDED_PORT_INFO) {
 			init_query_mad(in_mad);
 			in_mad->attr_id = MLX5_ATTR_EXTENDED_PORT_INFO;
@@ -392,7 +390,6 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	struct mlx5_ib_alloc_ucontext_req_v2 req;
 	struct mlx5_ib_alloc_ucontext_resp resp;
 	struct mlx5_ib_ucontext *context;
-	struct mlx5_general_caps *gen;
 	struct mlx5_uuar_info *uuari;
 	struct mlx5_uar *uars;
 	int gross_uuars;
@@ -403,7 +400,6 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	int i;
 	size_t reqlen;
 
-	gen = &dev->mdev->caps.gen;
 	if (!dev->ib_active)
 		return ERR_PTR(-EAGAIN);
 
@@ -436,14 +432,14 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 
 	num_uars = req.total_num_uuars / MLX5_NON_FP_BF_REGS_PER_PAGE;
 	gross_uuars = num_uars * MLX5_BF_REGS_PER_PAGE;
-	resp.qp_tab_size      = 1 << gen->log_max_qp;
-	resp.bf_reg_size      = gen->bf_reg_size;
-	resp.cache_line_size  = L1_CACHE_BYTES;
-	resp.max_sq_desc_sz = gen->max_sq_desc_sz;
-	resp.max_rq_desc_sz = gen->max_rq_desc_sz;
-	resp.max_send_wqebb = gen->max_wqes;
-	resp.max_recv_wr = gen->max_wqes;
-	resp.max_srq_recv_wr = gen->max_srq_wqes;
+	resp.qp_tab_size = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp);
+	resp.bf_reg_size = 1 << MLX5_CAP_GEN(dev->mdev, log_bf_reg_size);
+	resp.cache_line_size = L1_CACHE_BYTES;
+	resp.max_sq_desc_sz = MLX5_CAP_GEN(dev->mdev, max_wqe_sz_sq);
+	resp.max_rq_desc_sz = MLX5_CAP_GEN(dev->mdev, max_wqe_sz_rq);
+	resp.max_send_wqebb = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz);
+	resp.max_recv_wr = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz);
+	resp.max_srq_recv_wr = 1 << MLX5_CAP_GEN(dev->mdev, log_max_srq_sz);
 
 	context = kzalloc(sizeof(*context), GFP_KERNEL);
 	if (!context)
@@ -493,7 +489,7 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	mutex_init(&context->db_page_mutex);
 
 	resp.tot_uuars = req.total_num_uuars;
-	resp.num_ports = gen->num_ports;
+	resp.num_ports = MLX5_CAP_GEN(dev->mdev, num_ports);
 	err = ib_copy_to_udata(udata, &resp,
 			       sizeof(resp) - sizeof(resp.reserved));
 	if (err)
@@ -895,11 +891,9 @@ static void mlx5_ib_event(struct mlx5_core_dev *dev, void *context,
 
 static void get_ext_port_caps(struct mlx5_ib_dev *dev)
 {
-	struct mlx5_general_caps *gen;
 	int port;
 
-	gen = &dev->mdev->caps.gen;
-	for (port = 1; port <= gen->num_ports; port++)
+	for (port = 1; port <= MLX5_CAP_GEN(dev->mdev, num_ports); port++)
 		mlx5_query_ext_port_caps(dev, port);
 }
 
@@ -907,11 +901,9 @@ static int get_port_caps(struct mlx5_ib_dev *dev)
 {
 	struct ib_device_attr *dprops = NULL;
 	struct ib_port_attr *pprops = NULL;
-	struct mlx5_general_caps *gen;
 	int err = -ENOMEM;
 	int port;
 
-	gen = &dev->mdev->caps.gen;
 	pprops = kmalloc(sizeof(*pprops), GFP_KERNEL);
 	if (!pprops)
 		goto out;
@@ -926,14 +918,17 @@ static int get_port_caps(struct mlx5_ib_dev *dev)
 		goto out;
 	}
 
-	for (port = 1; port <= gen->num_ports; port++) {
+	for (port = 1; port <= MLX5_CAP_GEN(dev->mdev, num_ports); port++) {
 		err = mlx5_ib_query_port(&dev->ib_dev, port, pprops);
 		if (err) {
-			mlx5_ib_warn(dev, "query_port %d failed %d\n", port, err);
+			mlx5_ib_warn(dev, "query_port %d failed %d\n",
+				     port, err);
 			break;
 		}
-		gen->port[port - 1].pkey_table_len = dprops->max_pkeys;
-		gen->port[port - 1].gid_table_len = pprops->gid_tbl_len;
+		dev->mdev->port_caps[port - 1].pkey_table_len =
+						dprops->max_pkeys;
+		dev->mdev->port_caps[port - 1].gid_table_len =
+						pprops->gid_tbl_len;
 		mlx5_ib_dbg(dev, "pkey_table_len %d, gid_table_len %d\n",
 			    dprops->max_pkeys, pprops->gid_tbl_len);
 	}
@@ -1207,8 +1202,8 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	strlcpy(dev->ib_dev.name, "mlx5_%d", IB_DEVICE_NAME_MAX);
 	dev->ib_dev.owner		= THIS_MODULE;
 	dev->ib_dev.node_type		= RDMA_NODE_IB_CA;
-	dev->ib_dev.local_dma_lkey	= mdev->caps.gen.reserved_lkey;
-	dev->num_ports		= mdev->caps.gen.num_ports;
+	dev->ib_dev.local_dma_lkey	= 0 /* not supported for now */;
+	dev->num_ports		= MLX5_CAP_GEN(mdev, num_ports);
 	dev->ib_dev.phys_port_cnt     = dev->num_ports;
 	dev->ib_dev.num_comp_vectors    =
 		dev->mdev->priv.eq_table.num_comp_vectors;
@@ -1286,9 +1281,9 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.free_fast_reg_page_list  = mlx5_ib_free_fast_reg_page_list;
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
 
-	mlx5_ib_internal_query_odp_caps(dev);
+	mlx5_ib_internal_fill_odp_caps(dev);
 
-	if (mdev->caps.gen.flags & MLX5_DEV_CAP_FLAG_XRC) {
+	if (MLX5_CAP_GEN(mdev, xrc)) {
 		dev->ib_dev.alloc_xrcd = mlx5_ib_alloc_xrcd;
 		dev->ib_dev.dealloc_xrcd = mlx5_ib_dealloc_xrcd;
 		dev->ib_dev.uverbs_cmd_mask |=
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index dff1cfc..0c441ad 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -617,7 +617,7 @@ int mlx5_ib_check_mr_status(struct ib_mr *ibmr, u32 check_mask,
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 extern struct workqueue_struct *mlx5_ib_page_fault_wq;
 
-int mlx5_ib_internal_query_odp_caps(struct mlx5_ib_dev *dev);
+void mlx5_ib_internal_fill_odp_caps(struct mlx5_ib_dev *dev);
 void mlx5_ib_mr_pfault_handler(struct mlx5_ib_qp *qp,
 			       struct mlx5_ib_pfault *pfault);
 void mlx5_ib_odp_create_qp(struct mlx5_ib_qp *qp);
@@ -631,9 +631,9 @@ void mlx5_ib_invalidate_range(struct ib_umem *umem, unsigned long start,
 			      unsigned long end);
 
 #else /* CONFIG_INFINIBAND_ON_DEMAND_PAGING */
-static inline int mlx5_ib_internal_query_odp_caps(struct mlx5_ib_dev *dev)
+static inline void mlx5_ib_internal_fill_odp_caps(struct mlx5_ib_dev *dev)
 {
-	return 0;
+	return;
 }
 
 static inline void mlx5_ib_odp_create_qp(struct mlx5_ib_qp *qp)		{}
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 71c5935..bc9a0de 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -975,8 +975,7 @@ static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
 	struct mlx5_ib_mr *mr;
 	int inlen;
 	int err;
-	bool pg_cap = !!(dev->mdev->caps.gen.flags &
-			 MLX5_DEV_CAP_FLAG_ON_DMND_PG);
+	bool pg_cap = !!(MLX5_CAP_GEN(dev->mdev, pg));
 
 	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
 	if (!mr)
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 5099db0..aa8391e 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -109,40 +109,33 @@ void mlx5_ib_invalidate_range(struct ib_umem *umem, unsigned long start,
 	ib_umem_odp_unmap_dma_pages(umem, start, end);
 }
 
-#define COPY_ODP_BIT_MLX_TO_IB(reg, ib_caps, field_name, bit_name) do {	\
-	if (be32_to_cpu(reg.field_name) & MLX5_ODP_SUPPORT_##bit_name)	\
-		ib_caps->field_name |= IB_ODP_SUPPORT_##bit_name;	\
-} while (0)
-
-int mlx5_ib_internal_query_odp_caps(struct mlx5_ib_dev *dev)
+void mlx5_ib_internal_fill_odp_caps(struct mlx5_ib_dev *dev)
 {
-	int err;
-	struct mlx5_odp_caps hw_caps;
 	struct ib_odp_caps *caps = &dev->odp_caps;
 
 	memset(caps, 0, sizeof(*caps));
 
-	if (!(dev->mdev->caps.gen.flags & MLX5_DEV_CAP_FLAG_ON_DMND_PG))
-		return 0;
-
-	err = mlx5_query_odp_caps(dev->mdev, &hw_caps);
-	if (err)
-		goto out;
+	if (!MLX5_CAP_GEN(dev->mdev, pg))
+		return;
 
 	caps->general_caps = IB_ODP_SUPPORT;
-	COPY_ODP_BIT_MLX_TO_IB(hw_caps, caps, per_transport_caps.ud_odp_caps,
-			       SEND);
-	COPY_ODP_BIT_MLX_TO_IB(hw_caps, caps, per_transport_caps.rc_odp_caps,
-			       SEND);
-	COPY_ODP_BIT_MLX_TO_IB(hw_caps, caps, per_transport_caps.rc_odp_caps,
-			       RECV);
-	COPY_ODP_BIT_MLX_TO_IB(hw_caps, caps, per_transport_caps.rc_odp_caps,
-			       WRITE);
-	COPY_ODP_BIT_MLX_TO_IB(hw_caps, caps, per_transport_caps.rc_odp_caps,
-			       READ);
-
-out:
-	return err;
+
+	if (MLX5_CAP_ODP(dev->mdev, ud_odp_caps.send))
+		caps->per_transport_caps.ud_odp_caps |= IB_ODP_SUPPORT_SEND;
+
+	if (MLX5_CAP_ODP(dev->mdev, rc_odp_caps.send))
+		caps->per_transport_caps.rc_odp_caps |= IB_ODP_SUPPORT_SEND;
+
+	if (MLX5_CAP_ODP(dev->mdev, rc_odp_caps.receive))
+		caps->per_transport_caps.rc_odp_caps |= IB_ODP_SUPPORT_RECV;
+
+	if (MLX5_CAP_ODP(dev->mdev, rc_odp_caps.write))
+		caps->per_transport_caps.rc_odp_caps |= IB_ODP_SUPPORT_WRITE;
+
+	if (MLX5_CAP_ODP(dev->mdev, rc_odp_caps.read))
+		caps->per_transport_caps.rc_odp_caps |= IB_ODP_SUPPORT_READ;
+
+	return;
 }
 
 static struct mlx5_ib_mr *mlx5_ib_odp_find_mr_lkey(struct mlx5_ib_dev *dev,
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 4d7024b..75efe1c 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -220,13 +220,11 @@ static void mlx5_ib_qp_event(struct mlx5_core_qp *qp, int type)
 static int set_rq_size(struct mlx5_ib_dev *dev, struct ib_qp_cap *cap,
 		       int has_rq, struct mlx5_ib_qp *qp, struct mlx5_ib_create_qp *ucmd)
 {
-	struct mlx5_general_caps *gen;
 	int wqe_size;
 	int wq_size;
 
-	gen = &dev->mdev->caps.gen;
 	/* Sanity check RQ size before proceeding */
-	if (cap->max_recv_wr  > gen->max_wqes)
+	if (cap->max_recv_wr > (1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz)))
 		return -EINVAL;
 
 	if (!has_rq) {
@@ -246,10 +244,11 @@ static int set_rq_size(struct mlx5_ib_dev *dev, struct ib_qp_cap *cap,
 			wq_size = roundup_pow_of_two(cap->max_recv_wr) * wqe_size;
 			wq_size = max_t(int, wq_size, MLX5_SEND_WQE_BB);
 			qp->rq.wqe_cnt = wq_size / wqe_size;
-			if (wqe_size > gen->max_rq_desc_sz) {
+			if (wqe_size > MLX5_CAP_GEN(dev->mdev, max_wqe_sz_rq)) {
 				mlx5_ib_dbg(dev, "wqe_size %d, max %d\n",
 					    wqe_size,
-					    gen->max_rq_desc_sz);
+					    MLX5_CAP_GEN(dev->mdev,
+							 max_wqe_sz_rq));
 				return -EINVAL;
 			}
 			qp->rq.wqe_shift = ilog2(wqe_size);
@@ -330,11 +329,9 @@ static int calc_send_wqe(struct ib_qp_init_attr *attr)
 static int calc_sq_size(struct mlx5_ib_dev *dev, struct ib_qp_init_attr *attr,
 			struct mlx5_ib_qp *qp)
 {
-	struct mlx5_general_caps *gen;
 	int wqe_size;
 	int wq_size;
 
-	gen = &dev->mdev->caps.gen;
 	if (!attr->cap.max_send_wr)
 		return 0;
 
@@ -343,9 +340,9 @@ static int calc_sq_size(struct mlx5_ib_dev *dev, struct ib_qp_init_attr *attr,
 	if (wqe_size < 0)
 		return wqe_size;
 
-	if (wqe_size > gen->max_sq_desc_sz) {
+	if (wqe_size > MLX5_CAP_GEN(dev->mdev, max_wqe_sz_sq)) {
 		mlx5_ib_dbg(dev, "wqe_size(%d) > max_sq_desc_sz(%d)\n",
-			    wqe_size, gen->max_sq_desc_sz);
+			    wqe_size, MLX5_CAP_GEN(dev->mdev, max_wqe_sz_sq));
 		return -EINVAL;
 	}
 
@@ -358,9 +355,10 @@ static int calc_sq_size(struct mlx5_ib_dev *dev, struct ib_qp_init_attr *attr,
 
 	wq_size = roundup_pow_of_two(attr->cap.max_send_wr * wqe_size);
 	qp->sq.wqe_cnt = wq_size / MLX5_SEND_WQE_BB;
-	if (qp->sq.wqe_cnt > gen->max_wqes) {
+	if (qp->sq.wqe_cnt > (1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz))) {
 		mlx5_ib_dbg(dev, "wqe count(%d) exceeds limits(%d)\n",
-			    qp->sq.wqe_cnt, gen->max_wqes);
+			    qp->sq.wqe_cnt,
+			    1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz));
 		return -ENOMEM;
 	}
 	qp->sq.wqe_shift = ilog2(MLX5_SEND_WQE_BB);
@@ -375,13 +373,11 @@ static int set_user_buf_size(struct mlx5_ib_dev *dev,
 			    struct mlx5_ib_qp *qp,
 			    struct mlx5_ib_create_qp *ucmd)
 {
-	struct mlx5_general_caps *gen;
 	int desc_sz = 1 << qp->sq.wqe_shift;
 
-	gen = &dev->mdev->caps.gen;
-	if (desc_sz > gen->max_sq_desc_sz) {
+	if (desc_sz > MLX5_CAP_GEN(dev->mdev, max_wqe_sz_sq)) {
 		mlx5_ib_warn(dev, "desc_sz %d, max_sq_desc_sz %d\n",
-			     desc_sz, gen->max_sq_desc_sz);
+			     desc_sz, MLX5_CAP_GEN(dev->mdev, max_wqe_sz_sq));
 		return -EINVAL;
 	}
 
@@ -393,9 +389,10 @@ static int set_user_buf_size(struct mlx5_ib_dev *dev,
 
 	qp->sq.wqe_cnt = ucmd->sq_wqe_count;
 
-	if (qp->sq.wqe_cnt > gen->max_wqes) {
+	if (qp->sq.wqe_cnt > (1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz))) {
 		mlx5_ib_warn(dev, "wqe_cnt %d, max_wqes %d\n",
-			     qp->sq.wqe_cnt, gen->max_wqes);
+			     qp->sq.wqe_cnt,
+			     1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz));
 		return -EINVAL;
 	}
 
@@ -866,22 +863,21 @@ static int create_qp_common(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 			    struct ib_udata *udata, struct mlx5_ib_qp *qp)
 {
 	struct mlx5_ib_resources *devr = &dev->devr;
+	struct mlx5_core_dev *mdev = dev->mdev;
 	struct mlx5_ib_create_qp_resp resp;
 	struct mlx5_create_qp_mbox_in *in;
-	struct mlx5_general_caps *gen;
 	struct mlx5_ib_create_qp ucmd;
 	int inlen = sizeof(*in);
 	int err;
 
 	mlx5_ib_odp_create_qp(qp);
 
-	gen = &dev->mdev->caps.gen;
 	mutex_init(&qp->mutex);
 	spin_lock_init(&qp->sq.lock);
 	spin_lock_init(&qp->rq.lock);
 
 	if (init_attr->create_flags & IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK) {
-		if (!(gen->flags & MLX5_DEV_CAP_FLAG_BLOCK_MCAST)) {
+		if (!MLX5_CAP_GEN(mdev, block_lb_mc)) {
 			mlx5_ib_dbg(dev, "block multicast loopback isn't supported\n");
 			return -EINVAL;
 		} else {
@@ -914,15 +910,17 @@ static int create_qp_common(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 
 	if (pd) {
 		if (pd->uobject) {
+			__u32 max_wqes =
+				1 << MLX5_CAP_GEN(mdev, log_max_qp_sz);
 			mlx5_ib_dbg(dev, "requested sq_wqe_count (%d)\n", ucmd.sq_wqe_count);
 			if (ucmd.rq_wqe_shift != qp->rq.wqe_shift ||
 			    ucmd.rq_wqe_count != qp->rq.wqe_cnt) {
 				mlx5_ib_dbg(dev, "invalid rq params\n");
 				return -EINVAL;
 			}
-			if (ucmd.sq_wqe_count > gen->max_wqes) {
+			if (ucmd.sq_wqe_count > max_wqes) {
 				mlx5_ib_dbg(dev, "requested sq_wqe_count (%d) > max allowed (%d)\n",
-					    ucmd.sq_wqe_count, gen->max_wqes);
+					    ucmd.sq_wqe_count, max_wqes);
 				return -EINVAL;
 			}
 			err = create_user_qp(dev, pd, qp, udata, &in, &resp, &inlen);
@@ -1226,7 +1224,6 @@ struct ib_qp *mlx5_ib_create_qp(struct ib_pd *pd,
 				struct ib_qp_init_attr *init_attr,
 				struct ib_udata *udata)
 {
-	struct mlx5_general_caps *gen;
 	struct mlx5_ib_dev *dev;
 	struct mlx5_ib_qp *qp;
 	u16 xrcdn = 0;
@@ -1244,12 +1241,11 @@ struct ib_qp *mlx5_ib_create_qp(struct ib_pd *pd,
 		}
 		dev = to_mdev(to_mxrcd(init_attr->xrcd)->ibxrcd.device);
 	}
-	gen = &dev->mdev->caps.gen;
 
 	switch (init_attr->qp_type) {
 	case IB_QPT_XRC_TGT:
 	case IB_QPT_XRC_INI:
-		if (!(gen->flags & MLX5_DEV_CAP_FLAG_XRC)) {
+		if (!MLX5_CAP_GEN(dev->mdev, xrc)) {
 			mlx5_ib_dbg(dev, "XRC not supported\n");
 			return ERR_PTR(-ENOSYS);
 		}
@@ -1356,9 +1352,6 @@ enum {
 
 static int ib_rate_to_mlx5(struct mlx5_ib_dev *dev, u8 rate)
 {
-	struct mlx5_general_caps *gen;
-
-	gen = &dev->mdev->caps.gen;
 	if (rate == IB_RATE_PORT_CURRENT) {
 		return 0;
 	} else if (rate < IB_RATE_2_5_GBPS || rate > IB_RATE_300_GBPS) {
@@ -1366,7 +1359,7 @@ static int ib_rate_to_mlx5(struct mlx5_ib_dev *dev, u8 rate)
 	} else {
 		while (rate != IB_RATE_2_5_GBPS &&
 		       !(1 << (rate + MLX5_STAT_RATE_OFFSET) &
-			 gen->stat_rate_support))
+			 MLX5_CAP_GEN(dev->mdev, stat_rate_support)))
 			--rate;
 	}
 
@@ -1377,10 +1370,8 @@ static int mlx5_set_path(struct mlx5_ib_dev *dev, const struct ib_ah_attr *ah,
 			 struct mlx5_qp_path *path, u8 port, int attr_mask,
 			 u32 path_flags, const struct ib_qp_attr *attr)
 {
-	struct mlx5_general_caps *gen;
 	int err;
 
-	gen = &dev->mdev->caps.gen;
 	path->fl = (path_flags & MLX5_PATH_FLAG_FL) ? 0x80 : 0;
 	path->free_ar = (path_flags & MLX5_PATH_FLAG_FREE_AR) ? 0x80 : 0;
 
@@ -1391,9 +1382,11 @@ static int mlx5_set_path(struct mlx5_ib_dev *dev, const struct ib_ah_attr *ah,
 	path->rlid	= cpu_to_be16(ah->dlid);
 
 	if (ah->ah_flags & IB_AH_GRH) {
-		if (ah->grh.sgid_index >= gen->port[port - 1].gid_table_len) {
+		if (ah->grh.sgid_index >=
+		    dev->mdev->port_caps[port - 1].gid_table_len) {
 			pr_err(KERN_ERR "sgid_index (%u) too large. max is %d\n",
-			       ah->grh.sgid_index, gen->port[port - 1].gid_table_len);
+			       ah->grh.sgid_index,
+			       dev->mdev->port_caps[port - 1].gid_table_len);
 			return -EINVAL;
 		}
 		path->grh_mlid |= 1 << 7;
@@ -1570,7 +1563,6 @@ static int __mlx5_ib_modify_qp(struct ib_qp *ibqp,
 	struct mlx5_ib_qp *qp = to_mqp(ibqp);
 	struct mlx5_ib_cq *send_cq, *recv_cq;
 	struct mlx5_qp_context *context;
-	struct mlx5_general_caps *gen;
 	struct mlx5_modify_qp_mbox_in *in;
 	struct mlx5_ib_pd *pd;
 	enum mlx5_qp_state mlx5_cur, mlx5_new;
@@ -1579,7 +1571,6 @@ static int __mlx5_ib_modify_qp(struct ib_qp *ibqp,
 	int mlx5_st;
 	int err;
 
-	gen = &dev->mdev->caps.gen;
 	in = kzalloc(sizeof(*in), GFP_KERNEL);
 	if (!in)
 		return -ENOMEM;
@@ -1619,7 +1610,8 @@ static int __mlx5_ib_modify_qp(struct ib_qp *ibqp,
 			err = -EINVAL;
 			goto out;
 		}
-		context->mtu_msgmax = (attr->path_mtu << 5) | gen->log_max_msg;
+		context->mtu_msgmax = (attr->path_mtu << 5) |
+				      (u8)MLX5_CAP_GEN(dev->mdev, log_max_msg);
 	}
 
 	if (attr_mask & IB_QP_DEST_QPN)
@@ -1777,11 +1769,9 @@ int mlx5_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 	struct mlx5_ib_dev *dev = to_mdev(ibqp->device);
 	struct mlx5_ib_qp *qp = to_mqp(ibqp);
 	enum ib_qp_state cur_state, new_state;
-	struct mlx5_general_caps *gen;
 	int err = -EINVAL;
 	int port;
 
-	gen = &dev->mdev->caps.gen;
 	mutex_lock(&qp->mutex);
 
 	cur_state = attr_mask & IB_QP_CUR_STATE ? attr->cur_qp_state : qp->state;
@@ -1793,21 +1783,25 @@ int mlx5_ib_modify_qp(struct ib_qp *ibqp, struct ib_qp_attr *attr,
 		goto out;
 
 	if ((attr_mask & IB_QP_PORT) &&
-	    (attr->port_num == 0 || attr->port_num > gen->num_ports))
+	    (attr->port_num == 0 ||
+	     attr->port_num > MLX5_CAP_GEN(dev->mdev, num_ports)))
 		goto out;
 
 	if (attr_mask & IB_QP_PKEY_INDEX) {
 		port = attr_mask & IB_QP_PORT ? attr->port_num : qp->port;
-		if (attr->pkey_index >= gen->port[port - 1].pkey_table_len)
+		if (attr->pkey_index >=
+		    dev->mdev->port_caps[port - 1].pkey_table_len)
 			goto out;
 	}
 
 	if (attr_mask & IB_QP_MAX_QP_RD_ATOMIC &&
-	    attr->max_rd_atomic > (1 << gen->log_max_ra_res_qp))
+	    attr->max_rd_atomic >
+	    (1 << MLX5_CAP_GEN(dev->mdev, log_max_ra_res_qp)))
 		goto out;
 
 	if (attr_mask & IB_QP_MAX_DEST_RD_ATOMIC &&
-	    attr->max_dest_rd_atomic > (1 << gen->log_max_ra_req_qp))
+	    attr->max_dest_rd_atomic >
+	    (1 << MLX5_CAP_GEN(dev->mdev, log_max_ra_req_qp)))
 		goto out;
 
 	if (cur_state == new_state && cur_state == IB_QPS_RESET) {
@@ -3009,7 +3003,7 @@ static void to_ib_ah_attr(struct mlx5_ib_dev *ibdev, struct ib_ah_attr *ib_ah_at
 	ib_ah_attr->port_num	  = path->port;
 
 	if (ib_ah_attr->port_num == 0 ||
-	    ib_ah_attr->port_num > dev->caps.gen.num_ports)
+	    ib_ah_attr->port_num > MLX5_CAP_GEN(dev, num_ports))
 		return;
 
 	ib_ah_attr->sl = path->sl & 0xf;
@@ -3135,12 +3129,10 @@ struct ib_xrcd *mlx5_ib_alloc_xrcd(struct ib_device *ibdev,
 					  struct ib_udata *udata)
 {
 	struct mlx5_ib_dev *dev = to_mdev(ibdev);
-	struct mlx5_general_caps *gen;
 	struct mlx5_ib_xrcd *xrcd;
 	int err;
 
-	gen = &dev->mdev->caps.gen;
-	if (!(gen->flags & MLX5_DEV_CAP_FLAG_XRC))
+	if (!MLX5_CAP_GEN(dev->mdev, xrc))
 		return ERR_PTR(-ENOSYS);
 
 	xrcd = kmalloc(sizeof(*xrcd), GFP_KERNEL);
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 02d77a2..c11e9f6 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -236,7 +236,6 @@ struct ib_srq *mlx5_ib_create_srq(struct ib_pd *pd,
 				  struct ib_udata *udata)
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
-	struct mlx5_general_caps *gen;
 	struct mlx5_ib_srq *srq;
 	int desc_size;
 	int buf_size;
@@ -245,13 +244,13 @@ struct ib_srq *mlx5_ib_create_srq(struct ib_pd *pd,
 	int uninitialized_var(inlen);
 	int is_xrc;
 	u32 flgs, xrcdn;
+	__u32 max_srq_wqes = 1 << MLX5_CAP_GEN(dev->mdev, log_max_srq_sz);
 
-	gen = &dev->mdev->caps.gen;
 	/* Sanity check SRQ size before proceeding */
-	if (init_attr->attr.max_wr >= gen->max_srq_wqes) {
+	if (init_attr->attr.max_wr >= max_srq_wqes) {
 		mlx5_ib_dbg(dev, "max_wr %d, cap %d\n",
 			    init_attr->attr.max_wr,
-			    gen->max_srq_wqes);
+			    max_srq_wqes);
 		return ERR_PTR(-EINVAL);
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index d0a40ca..e03cd1a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -456,7 +456,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 	u32 async_event_mask = MLX5_ASYNC_EVENT_MASK;
 	int err;
 
-	if (dev->caps.gen.flags & MLX5_DEV_CAP_FLAG_ON_DMND_PG)
+	if (MLX5_CAP_GEN(dev, pg))
 		async_event_mask |= (1ull << MLX5_EVENT_TYPE_PAGE_FAULT);
 
 	err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
@@ -479,7 +479,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 
 	err = mlx5_create_map_eq(dev, &table->pages_eq,
 				 MLX5_EQ_VEC_PAGES,
-				 dev->caps.gen.max_vf + 1,
+				 /* TODO: sriov max_vf + */ 1,
 				 1 << MLX5_EVENT_TYPE_PAGE_REQUEST, "mlx5_pages_eq",
 				 &dev->priv.uuari.uars[0]);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index ef9b769..801ccad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -64,50 +64,74 @@ out_out:
 	return err;
 }
 
-int mlx5_cmd_query_hca_cap(struct mlx5_core_dev *dev, struct mlx5_caps *caps)
+int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 {
-	return mlx5_core_get_caps(dev, caps, HCA_CAP_OPMOD_GET_CUR);
-}
-
-int mlx5_query_odp_caps(struct mlx5_core_dev *dev, struct mlx5_odp_caps *caps)
-{
-	u8 in[MLX5_ST_SZ_BYTES(query_hca_cap_in)];
-	int out_sz = MLX5_ST_SZ_BYTES(query_hca_cap_out);
-	void *out;
 	int err;
 
-	if (!(dev->caps.gen.flags & MLX5_DEV_CAP_FLAG_ON_DMND_PG))
-		return -ENOTSUPP;
+	err = mlx5_core_get_caps(dev, MLX5_CAP_GENERAL, HCA_CAP_OPMOD_GET_CUR);
+	if (err)
+		return err;
 
-	memset(in, 0, sizeof(in));
-	out = kzalloc(out_sz, GFP_KERNEL);
-	if (!out)
-		return -ENOMEM;
-	MLX5_SET(query_hca_cap_in, in, opcode, MLX5_CMD_OP_QUERY_HCA_CAP);
-	MLX5_SET(query_hca_cap_in, in, op_mod, HCA_CAP_OPMOD_GET_ODP_CUR);
-	err = mlx5_cmd_exec(dev, in, sizeof(in), out, out_sz);
+	err = mlx5_core_get_caps(dev, MLX5_CAP_GENERAL, HCA_CAP_OPMOD_GET_MAX);
 	if (err)
-		goto out;
+		return err;
 
-	err = mlx5_cmd_status_to_err_v2(out);
-	if (err) {
-		mlx5_core_warn(dev, "query cur hca ODP caps failed, %d\n", err);
-		goto out;
+	if (MLX5_CAP_GEN(dev, eth_net_offloads)) {
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ETHERNET_OFFLOADS,
+					 HCA_CAP_OPMOD_GET_CUR);
+		if (err)
+			return err;
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ETHERNET_OFFLOADS,
+					 HCA_CAP_OPMOD_GET_MAX);
+		if (err)
+			return err;
 	}
 
-	memcpy(caps, MLX5_ADDR_OF(query_hca_cap_out, out, capability),
-	       sizeof(*caps));
+	if (MLX5_CAP_GEN(dev, pg)) {
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ODP,
+					 HCA_CAP_OPMOD_GET_CUR);
+		if (err)
+			return err;
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ODP,
+					 HCA_CAP_OPMOD_GET_MAX);
+		if (err)
+			return err;
+	}
 
-	mlx5_core_dbg(dev, "on-demand paging capabilities:\nrc: %08x\nuc: %08x\nud: %08x\n",
-		be32_to_cpu(caps->per_transport_caps.rc_odp_caps),
-		be32_to_cpu(caps->per_transport_caps.uc_odp_caps),
-		be32_to_cpu(caps->per_transport_caps.ud_odp_caps));
+	if (MLX5_CAP_GEN(dev, atomic)) {
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ATOMIC,
+					 HCA_CAP_OPMOD_GET_CUR);
+		if (err)
+			return err;
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ATOMIC,
+					 HCA_CAP_OPMOD_GET_MAX);
+		if (err)
+			return err;
+	}
 
-out:
-	kfree(out);
-	return err;
+	if (MLX5_CAP_GEN(dev, roce)) {
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ROCE,
+					 HCA_CAP_OPMOD_GET_CUR);
+		if (err)
+			return err;
+		err = mlx5_core_get_caps(dev, MLX5_CAP_ROCE,
+					 HCA_CAP_OPMOD_GET_MAX);
+		if (err)
+			return err;
+	}
+
+	if (MLX5_CAP_GEN(dev, nic_flow_table)) {
+		err = mlx5_core_get_caps(dev, MLX5_CAP_FLOW_TABLE,
+					 HCA_CAP_OPMOD_GET_CUR);
+		if (err)
+			return err;
+		err = mlx5_core_get_caps(dev, MLX5_CAP_FLOW_TABLE,
+					 HCA_CAP_OPMOD_GET_MAX);
+		if (err)
+			return err;
+	}
+	return 0;
 }
-EXPORT_SYMBOL(mlx5_query_odp_caps);
 
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 2ab4115..9de121e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -211,11 +211,12 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 {
 	struct mlx5_priv *priv = &dev->priv;
 	struct mlx5_eq_table *table = &priv->eq_table;
-	int num_eqs = 1 << dev->caps.gen.log_max_eq;
+	int num_eqs = 1 << MLX5_CAP_GEN(dev, log_max_eq);
 	int nvec;
 	int i;
 
-	nvec = dev->caps.gen.num_ports * num_online_cpus() + MLX5_EQ_VEC_COMP_BASE;
+	nvec = MLX5_CAP_GEN(dev, num_ports) * num_online_cpus() +
+	       MLX5_EQ_VEC_COMP_BASE;
 	nvec = min_t(int, nvec, num_eqs);
 	if (nvec <= MLX5_EQ_VEC_COMP_BASE)
 		return -ENOMEM;
@@ -287,97 +288,28 @@ static u16 to_fw_pkey_sz(u32 size)
 	}
 }
 
-/* selectively copy writable fields clearing any reserved area
- */
-static void copy_rw_fields(void *to, struct mlx5_caps *from)
-{
-	__be64 *flags_off = (__be64 *)MLX5_ADDR_OF(cmd_hca_cap, to, reserved_22);
-	u64 v64;
-
-	MLX5_SET(cmd_hca_cap, to, log_max_qp, from->gen.log_max_qp);
-	MLX5_SET(cmd_hca_cap, to, log_max_ra_req_qp, from->gen.log_max_ra_req_qp);
-	MLX5_SET(cmd_hca_cap, to, log_max_ra_res_qp, from->gen.log_max_ra_res_qp);
-	MLX5_SET(cmd_hca_cap, to, pkey_table_size, from->gen.pkey_table_size);
-	MLX5_SET(cmd_hca_cap, to, pkey_table_size, to_fw_pkey_sz(from->gen.pkey_table_size));
-	MLX5_SET(cmd_hca_cap, to, log_uar_page_sz, PAGE_SHIFT - 12);
-	v64 = from->gen.flags & MLX5_CAP_BITS_RW_MASK;
-	*flags_off = cpu_to_be64(v64);
-}
-
-static u16 get_pkey_table_size(int pkey)
+static u16 to_sw_pkey_sz(int pkey_sz)
 {
-	if (pkey > MLX5_MAX_LOG_PKEY_TABLE)
+	if (pkey_sz > MLX5_MAX_LOG_PKEY_TABLE)
 		return 0;
 
-	return MLX5_MIN_PKEY_TABLE_SIZE << pkey;
-}
-
-static void fw2drv_caps(struct mlx5_caps *caps, void *out)
-{
-	struct mlx5_general_caps *gen = &caps->gen;
-
-	gen->max_srq_wqes = 1 << MLX5_GET_PR(cmd_hca_cap, out, log_max_srq_sz);
-	gen->max_wqes = 1 << MLX5_GET_PR(cmd_hca_cap, out, log_max_qp_sz);
-	gen->log_max_qp = MLX5_GET_PR(cmd_hca_cap, out, log_max_qp);
-	gen->log_max_srq = MLX5_GET_PR(cmd_hca_cap, out, log_max_srq);
-	gen->max_cqes = 1 << MLX5_GET_PR(cmd_hca_cap, out, log_max_cq_sz);
-	gen->log_max_cq = MLX5_GET_PR(cmd_hca_cap, out, log_max_cq);
-	gen->max_eqes = 1 << MLX5_GET_PR(cmd_hca_cap, out, log_max_eq_sz);
-	gen->log_max_mkey = MLX5_GET_PR(cmd_hca_cap, out, log_max_mkey);
-	gen->log_max_eq = MLX5_GET_PR(cmd_hca_cap, out, log_max_eq);
-	gen->max_indirection = MLX5_GET_PR(cmd_hca_cap, out, max_indirection);
-	gen->log_max_mrw_sz = MLX5_GET_PR(cmd_hca_cap, out, log_max_mrw_sz);
-	gen->log_max_bsf_list_size = MLX5_GET_PR(cmd_hca_cap, out, log_max_bsf_list_size);
-	gen->log_max_klm_list_size = MLX5_GET_PR(cmd_hca_cap, out, log_max_klm_list_size);
-	gen->log_max_ra_req_dc = MLX5_GET_PR(cmd_hca_cap, out, log_max_ra_req_dc);
-	gen->log_max_ra_res_dc = MLX5_GET_PR(cmd_hca_cap, out, log_max_ra_res_dc);
-	gen->log_max_ra_req_qp = MLX5_GET_PR(cmd_hca_cap, out, log_max_ra_req_qp);
-	gen->log_max_ra_res_qp = MLX5_GET_PR(cmd_hca_cap, out, log_max_ra_res_qp);
-	gen->max_qp_counters = MLX5_GET_PR(cmd_hca_cap, out, max_qp_cnt);
-	gen->pkey_table_size = get_pkey_table_size(MLX5_GET_PR(cmd_hca_cap, out, pkey_table_size));
-	gen->local_ca_ack_delay = MLX5_GET_PR(cmd_hca_cap, out, local_ca_ack_delay);
-	gen->num_ports = MLX5_GET_PR(cmd_hca_cap, out, num_ports);
-	gen->log_max_msg = MLX5_GET_PR(cmd_hca_cap, out, log_max_msg);
-	gen->stat_rate_support = MLX5_GET_PR(cmd_hca_cap, out, stat_rate_support);
-	gen->flags = be64_to_cpu(*(__be64 *)MLX5_ADDR_OF(cmd_hca_cap, out, reserved_22));
-	pr_debug("flags = 0x%llx\n", gen->flags);
-	gen->uar_sz = MLX5_GET_PR(cmd_hca_cap, out, uar_sz);
-	gen->min_log_pg_sz = MLX5_GET_PR(cmd_hca_cap, out, log_pg_sz);
-	gen->bf_reg_size = MLX5_GET_PR(cmd_hca_cap, out, bf);
-	gen->bf_reg_size = 1 << MLX5_GET_PR(cmd_hca_cap, out, log_bf_reg_size);
-	gen->max_sq_desc_sz = MLX5_GET_PR(cmd_hca_cap, out, max_wqe_sz_sq);
-	gen->max_rq_desc_sz = MLX5_GET_PR(cmd_hca_cap, out, max_wqe_sz_rq);
-	gen->max_dc_sq_desc_sz = MLX5_GET_PR(cmd_hca_cap, out, max_wqe_sz_sq_dc);
-	gen->max_qp_mcg = MLX5_GET_PR(cmd_hca_cap, out, max_qp_mcg);
-	gen->log_max_pd = MLX5_GET_PR(cmd_hca_cap, out, log_max_pd);
-	gen->log_max_xrcd = MLX5_GET_PR(cmd_hca_cap, out, log_max_xrcd);
-	gen->log_uar_page_sz = MLX5_GET_PR(cmd_hca_cap, out, log_uar_page_sz);
-}
-
-static const char *caps_opmod_str(u16 opmod)
-{
-	switch (opmod) {
-	case HCA_CAP_OPMOD_GET_MAX:
-		return "GET_MAX";
-	case HCA_CAP_OPMOD_GET_CUR:
-		return "GET_CUR";
-	default:
-		return "Invalid";
-	}
+	return MLX5_MIN_PKEY_TABLE_SIZE << pkey_sz;
 }
 
-int mlx5_core_get_caps(struct mlx5_core_dev *dev, struct mlx5_caps *caps,
-		       u16 opmod)
+int mlx5_core_get_caps(struct mlx5_core_dev *dev, enum mlx5_cap_type cap_type,
+		       enum mlx5_cap_mode cap_mode)
 {
 	u8 in[MLX5_ST_SZ_BYTES(query_hca_cap_in)];
 	int out_sz = MLX5_ST_SZ_BYTES(query_hca_cap_out);
-	void *out;
+	void *out, *hca_caps;
+	u16 opmod = (cap_type << 1) | (cap_mode & 0x01);
 	int err;
 
 	memset(in, 0, sizeof(in));
 	out = kzalloc(out_sz, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
+
 	MLX5_SET(query_hca_cap_in, in, opcode, MLX5_CMD_OP_QUERY_HCA_CAP);
 	MLX5_SET(query_hca_cap_in, in, op_mod, opmod);
 	err = mlx5_cmd_exec(dev, in, sizeof(in), out, out_sz);
@@ -386,12 +318,30 @@ int mlx5_core_get_caps(struct mlx5_core_dev *dev, struct mlx5_caps *caps,
 
 	err = mlx5_cmd_status_to_err_v2(out);
 	if (err) {
-		mlx5_core_warn(dev, "query max hca cap failed, %d\n", err);
+		mlx5_core_warn(dev,
+			       "QUERY_HCA_CAP : type(%x) opmode(%x) Failed(%d)\n",
+			       cap_type, cap_mode, err);
 		goto query_ex;
 	}
-	mlx5_core_dbg(dev, "%s\n", caps_opmod_str(opmod));
-	fw2drv_caps(caps, MLX5_ADDR_OF(query_hca_cap_out, out, capability));
 
+	hca_caps =  MLX5_ADDR_OF(query_hca_cap_out, out, capability);
+
+	switch (cap_mode) {
+	case HCA_CAP_OPMOD_GET_MAX:
+		memcpy(dev->hca_caps_max[cap_type], hca_caps,
+		       MLX5_UN_SZ_BYTES(hca_cap_union));
+		break;
+	case HCA_CAP_OPMOD_GET_CUR:
+		memcpy(dev->hca_caps_cur[cap_type], hca_caps,
+		       MLX5_UN_SZ_BYTES(hca_cap_union));
+		break;
+	default:
+		mlx5_core_warn(dev,
+			       "Tried to query dev cap type(%x) with wrong opmode(%x)\n",
+			       cap_type, cap_mode);
+		err = -EINVAL;
+		break;
+	}
 query_ex:
 	kfree(out);
 	return err;
@@ -418,49 +368,45 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 {
 	void *set_ctx = NULL;
 	struct mlx5_profile *prof = dev->profile;
-	struct mlx5_caps *cur_caps = NULL;
-	struct mlx5_caps *max_caps = NULL;
 	int err = -ENOMEM;
 	int set_sz = MLX5_ST_SZ_BYTES(set_hca_cap_in);
+	void *set_hca_cap;
 
 	set_ctx = kzalloc(set_sz, GFP_KERNEL);
 	if (!set_ctx)
 		goto query_ex;
 
-	max_caps = kzalloc(sizeof(*max_caps), GFP_KERNEL);
-	if (!max_caps)
-		goto query_ex;
-
-	cur_caps = kzalloc(sizeof(*cur_caps), GFP_KERNEL);
-	if (!cur_caps)
-		goto query_ex;
-
-	err = mlx5_core_get_caps(dev, max_caps, HCA_CAP_OPMOD_GET_MAX);
+	err = mlx5_core_get_caps(dev, MLX5_CAP_GENERAL, HCA_CAP_OPMOD_GET_MAX);
 	if (err)
 		goto query_ex;
 
-	err = mlx5_core_get_caps(dev, cur_caps, HCA_CAP_OPMOD_GET_CUR);
+	err = mlx5_core_get_caps(dev, MLX5_CAP_GENERAL, HCA_CAP_OPMOD_GET_CUR);
 	if (err)
 		goto query_ex;
 
+	set_hca_cap = MLX5_ADDR_OF(set_hca_cap_in, set_ctx,
+				   capability);
+	memcpy(set_hca_cap, dev->hca_caps_cur[MLX5_CAP_GENERAL],
+	       MLX5_ST_SZ_BYTES(cmd_hca_cap));
+
+	mlx5_core_dbg(dev, "Current Pkey table size %d Setting new size %d\n",
+		      to_sw_pkey_sz(MLX5_CAP_GEN(dev, pkey_table_size)),
+		      128);
 	/* we limit the size of the pkey table to 128 entries for now */
-	cur_caps->gen.pkey_table_size = 128;
+	MLX5_SET(cmd_hca_cap, set_hca_cap, pkey_table_size,
+		 to_fw_pkey_sz(128));
 
 	if (prof->mask & MLX5_PROF_MASK_QP_SIZE)
-		cur_caps->gen.log_max_qp = prof->log_max_qp;
+		MLX5_SET(cmd_hca_cap, set_hca_cap, log_max_qp,
+			 prof->log_max_qp);
 
-	/* disable checksum */
-	cur_caps->gen.flags &= ~MLX5_DEV_CAP_FLAG_CMDIF_CSUM;
+	/* disable cmdif checksum */
+	MLX5_SET(cmd_hca_cap, set_hca_cap, cmdif_checksum, 0);
 
-	copy_rw_fields(MLX5_ADDR_OF(set_hca_cap_in, set_ctx, capability),
-		       cur_caps);
 	err = set_caps(dev, set_ctx, set_sz);
 
 query_ex:
-	kfree(cur_caps);
-	kfree(max_caps);
 	kfree(set_ctx);
-
 	return err;
 }
 
@@ -783,7 +729,7 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 
 	mlx5_start_health_poll(dev);
 
-	err = mlx5_cmd_query_hca_cap(dev, &dev->caps);
+	err = mlx5_query_hca_caps(dev);
 	if (err) {
 		dev_err(&pdev->dev, "query hca failed\n");
 		goto err_stop_poll;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 230855a..f353836 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -65,9 +65,15 @@ enum {
 	MLX5_CMD_TIME, /* print command execution time */
 };
 
+static inline int mlx5_cmd_exec_check_status(struct mlx5_core_dev *dev, u32 *in,
+					     int in_size, u32 *out,
+					     int out_size)
+{
+	mlx5_cmd_exec(dev, in, in_size, out, out_size);
+	return mlx5_cmd_status_to_err((struct mlx5_outbox_hdr *)out);
+}
 
-int mlx5_cmd_query_hca_cap(struct mlx5_core_dev *dev,
-			   struct mlx5_caps *caps);
+int mlx5_query_hca_caps(struct mlx5_core_dev *dev);
 int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index ba58f6d..9ef8587 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -175,12 +175,13 @@ int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari)
 	for (i = 0; i < tot_uuars; i++) {
 		bf = &uuari->bfs[i];
 
-		bf->buf_size = dev->caps.gen.bf_reg_size / 2;
+		bf->buf_size = (1 << MLX5_CAP_GEN(dev, log_bf_reg_size)) / 2;
 		bf->uar = &uuari->uars[i / MLX5_BF_REGS_PER_PAGE];
 		bf->regreg = uuari->uars[i / MLX5_BF_REGS_PER_PAGE].map;
 		bf->reg = NULL; /* Add WC support */
-		bf->offset = (i % MLX5_BF_REGS_PER_PAGE) * dev->caps.gen.bf_reg_size +
-			MLX5_BF_OFFSET;
+		bf->offset = (i % MLX5_BF_REGS_PER_PAGE) *
+			     (1 << MLX5_CAP_GEN(dev, log_bf_reg_size)) +
+			     MLX5_BF_OFFSET;
 		bf->need_lock = need_uuar_lock(i);
 		spin_lock_init(&bf->lock);
 		spin_lock_init(&bf->lock32);
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index feebed7..4ee52bf 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -59,6 +59,8 @@
 #define MLX5_FLD_SZ_BYTES(typ, fld) (__mlx5_bit_sz(typ, fld) / 8)
 #define MLX5_ST_SZ_BYTES(typ) (sizeof(struct mlx5_ifc_##typ##_bits) / 8)
 #define MLX5_ST_SZ_DW(typ) (sizeof(struct mlx5_ifc_##typ##_bits) / 32)
+#define MLX5_UN_SZ_BYTES(typ) (sizeof(union mlx5_ifc_##typ##_bits) / 8)
+#define MLX5_UN_SZ_DW(typ) (sizeof(union mlx5_ifc_##typ##_bits) / 32)
 #define MLX5_BYTE_OFF(typ, fld) (__mlx5_bit_off(typ, fld) / 8)
 #define MLX5_ADDR_OF(typ, p, fld) ((char *)(p) + MLX5_BYTE_OFF(typ, fld))
 
@@ -322,13 +324,6 @@ enum {
 	MLX5_CAP_OFF_CMDIF_CSUM		= 46,
 };
 
-enum {
-	HCA_CAP_OPMOD_GET_MAX	= 0,
-	HCA_CAP_OPMOD_GET_CUR	= 1,
-	HCA_CAP_OPMOD_GET_ODP_MAX = 4,
-	HCA_CAP_OPMOD_GET_ODP_CUR = 5
-};
-
 struct mlx5_inbox_hdr {
 	__be16		opcode;
 	u8		rsvd[4];
@@ -1101,4 +1096,61 @@ enum {
 	MLX5_RQC_RQ_TYPE_MEMORY_RQ_RPM    = 0x1,
 };
 
+/* MLX5 DEV CAPs */
+
+/* TODO: EAT.ME */
+enum mlx5_cap_mode {
+	HCA_CAP_OPMOD_GET_MAX	= 0,
+	HCA_CAP_OPMOD_GET_CUR	= 1,
+};
+
+enum mlx5_cap_type {
+	MLX5_CAP_GENERAL = 0,
+	MLX5_CAP_ETHERNET_OFFLOADS,
+	MLX5_CAP_ODP,
+	MLX5_CAP_ATOMIC,
+	MLX5_CAP_ROCE,
+	MLX5_CAP_IPOIB_OFFLOADS,
+	MLX5_CAP_EOIB_OFFLOADS,
+	MLX5_CAP_FLOW_TABLE,
+	/* NUM OF CAP Types */
+	MLX5_CAP_NUM
+};
+
+/* GET Dev Caps macros */
+#define MLX5_CAP_GEN(mdev, cap) \
+	MLX5_GET(cmd_hca_cap, mdev->hca_caps_cur[MLX5_CAP_GENERAL], cap)
+
+#define MLX5_CAP_GEN_MAX(mdev, cap) \
+	MLX5_GET(cmd_hca_cap, mdev->hca_caps_max[MLX5_CAP_GENERAL], cap)
+
+#define MLX5_CAP_ETH(mdev, cap) \
+	MLX5_GET(per_protocol_networking_offload_caps,\
+		 mdev->hca_caps_cur[MLX5_CAP_ETHERNET_OFFLOADS], cap)
+
+#define MLX5_CAP_ETH_MAX(mdev, cap) \
+	MLX5_GET(per_protocol_networking_offload_caps,\
+		 mdev->hca_caps_max[MLX5_CAP_ETHERNET_OFFLOADS], cap)
+
+#define MLX5_CAP_ROCE(mdev, cap) \
+	MLX5_GET(roce_cap, mdev->hca_caps_cur[MLX5_CAP_ROCE], cap)
+
+#define MLX5_CAP_ROCE_MAX(mdev, cap) \
+	MLX5_GET(roce_cap, mdev->hca_caps_max[MLX5_CAP_ROCE], cap)
+
+#define MLX5_CAP_ATOMIC(mdev, cap) \
+	MLX5_GET(atomic_caps, mdev->hca_caps_cur[MLX5_CAP_ATOMIC], cap)
+
+#define MLX5_CAP_ATOMIC_MAX(mdev, cap) \
+	MLX5_GET(atomic_caps, mdev->hca_caps_max[MLX5_CAP_ATOMIC], cap)
+
+#define MLX5_CAP_FLOWTABLE(mdev, cap) \
+	MLX5_GET(flow_table_nic_cap, mdev->hca_caps_cur[MLX5_CAP_FLOW_TABLE], cap)
+
+#define MLX5_CAP_FLOWTABLE_MAX(mdev, cap) \
+	MLX5_GET(flow_table_nic_cap, mdev->hca_caps_max[MLX5_CAP_FLOW_TABLE], cap)
+
+#define MLX5_CAP_ODP(mdev, cap)\
+	MLX5_GET(odp_cap, mdev->hca_caps_cur[MLX5_CAP_ODP], cap)
+
 #endif /* MLX5_DEVICE_H */
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 9741946..48cd0a2 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -268,55 +268,7 @@ struct mlx5_cmd {
 struct mlx5_port_caps {
 	int	gid_table_len;
 	int	pkey_table_len;
-};
-
-struct mlx5_general_caps {
-	u8	log_max_eq;
-	u8	log_max_cq;
-	u8	log_max_qp;
-	u8	log_max_mkey;
-	u8	log_max_pd;
-	u8	log_max_srq;
-	u8	log_max_mrw_sz;
-	u8	log_max_bsf_list_size;
-	u8	log_max_klm_list_size;
-	u32	max_cqes;
-	int	max_wqes;
-	u32	max_eqes;
-	u32	max_indirection;
-	int	max_sq_desc_sz;
-	int	max_rq_desc_sz;
-	int	max_dc_sq_desc_sz;
-	u64	flags;
-	u16	stat_rate_support;
-	int	log_max_msg;
-	int	num_ports;
-	u8	log_max_ra_res_qp;
-	u8	log_max_ra_req_qp;
-	int	max_srq_wqes;
-	int	bf_reg_size;
-	int	bf_regs_per_page;
-	struct mlx5_port_caps	port[MLX5_MAX_PORTS];
-	u8			ext_port_cap[MLX5_MAX_PORTS];
-	int	max_vf;
-	u32	reserved_lkey;
-	u8	local_ca_ack_delay;
-	u8	log_max_mcg;
-	u32	max_qp_mcg;
-	int	min_page_sz;
-	int	pd_cap;
-	u32	max_qp_counters;
-	u32	pkey_table_size;
-	u8	log_max_ra_req_dc;
-	u8	log_max_ra_res_dc;
-	u32	uar_sz;
-	u8	min_log_pg_sz;
-	u8	log_max_xrcd;
-	u16	log_uar_page_sz;
-};
-
-struct mlx5_caps {
-	struct mlx5_general_caps gen;
+	u8	ext_port_cap;
 };
 
 struct mlx5_cmd_mailbox {
@@ -523,7 +475,9 @@ struct mlx5_core_dev {
 	u8			rev_id;
 	char			board_id[MLX5_BOARD_ID_LEN];
 	struct mlx5_cmd		cmd;
-	struct mlx5_caps	caps;
+	struct mlx5_port_caps	port_caps[MLX5_MAX_PORTS];
+	u32 hca_caps_cur[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
+	u32 hca_caps_max[MLX5_CAP_NUM][MLX5_UN_SZ_DW(hca_cap_union)];
 	phys_addr_t		iseg_base;
 	struct mlx5_init_seg __iomem *iseg;
 	void			(*event) (struct mlx5_core_dev *dev,
@@ -657,8 +611,8 @@ void mlx5_cmd_use_events(struct mlx5_core_dev *dev);
 void mlx5_cmd_use_polling(struct mlx5_core_dev *dev);
 int mlx5_cmd_status_to_err(struct mlx5_outbox_hdr *hdr);
 int mlx5_cmd_status_to_err_v2(void *ptr);
-int mlx5_core_get_caps(struct mlx5_core_dev *dev, struct mlx5_caps *caps,
-		       u16 opmod);
+int mlx5_core_get_caps(struct mlx5_core_dev *dev, enum mlx5_cap_type cap_type,
+		       enum mlx5_cap_mode cap_mode);
 int mlx5_cmd_exec(struct mlx5_core_dev *dev, void *in, int in_size, void *out,
 		  int out_size);
 int mlx5_cmd_exec_cb(struct mlx5_core_dev *dev, void *in, int in_size,
-- 
1.9.3
