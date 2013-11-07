From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/6] net/mlx4_core: Initialize all mailbox buffers to zero before use
Date: Thu,  7 Nov 2013 12:19:50 +0200
Message-ID: <1383819594-24070-3-git-send-email-amirv@mellanox.com>
References: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Majd Dibbiny <majd@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44691 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754200Ab3KGKUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:20:19 -0500
In-Reply-To: <1383819594-24070-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

To guarantee that all unused fields in all FW commands for both inboxes
and outboxes are zeroed out, initialize the mailbox buffer to all zeroes.

This is especially important for SRIOV comm-channel virtual commands
(such as QUERY_FUNC_CAP), where if new fields are added to support new
features, the driver can depend on older kernels passing zeroes in these
fields.

In addition to zeroing out the mailbox buffer at allocation time, all
(now unnecessary) calls to memset by the callers of
mlx4_alloc_cmd_mailbox() are removed.


Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c            |  6 ------
 drivers/net/ethernet/mellanox/mlx4/cmd.c     |  2 ++
 drivers/net/ethernet/mellanox/mlx4/cq.c      |  6 ------
 drivers/net/ethernet/mellanox/mlx4/en_port.c |  3 ---
 drivers/net/ethernet/mellanox/mlx4/eq.c      |  1 -
 drivers/net/ethernet/mellanox/mlx4/fw.c      |  7 -------
 drivers/net/ethernet/mellanox/mlx4/mcg.c     |  2 --
 drivers/net/ethernet/mellanox/mlx4/mr.c      |  5 -----
 drivers/net/ethernet/mellanox/mlx4/port.c    | 11 -----------
 drivers/net/ethernet/mellanox/mlx4/srq.c     |  2 --
 10 files changed, 2 insertions(+), 43 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 7567437..6a0a0d2 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -526,7 +526,6 @@ static int mlx4_ib_modify_device(struct ib_device *ibdev, int mask,
 	if (IS_ERR(mailbox))
 		return 0;
 
-	memset(mailbox->buf, 0, 256);
 	memcpy(mailbox->buf, props->node_desc, 64);
 	mlx4_cmd(to_mdev(ibdev)->dev, mailbox->dma, 1, 0,
 		 MLX4_CMD_SET_NODE, MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
@@ -547,8 +546,6 @@ static int mlx4_SET_PORT(struct mlx4_ib_dev *dev, u8 port, int reset_qkey_viols,
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 
-	memset(mailbox->buf, 0, 256);
-
 	if (dev->dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
 		*(u8 *) mailbox->buf	     = !!reset_qkey_viols << 6;
 		((__be32 *) mailbox->buf)[2] = cpu_to_be32(cap_mask);
@@ -879,8 +876,6 @@ static int __mlx4_ib_create_flow(struct ib_qp *qp, struct ib_flow_attr *flow_att
 	struct mlx4_ib_dev *mdev = to_mdev(qp->device);
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_net_trans_rule_hw_ctrl *ctrl;
-	size_t rule_size = sizeof(struct mlx4_net_trans_rule_hw_ctrl) +
-			   (sizeof(struct _rule_hw) * flow_attr->num_of_specs);
 
 	static const u16 __mlx4_domain[] = {
 		[IB_FLOW_DOMAIN_USER] = MLX4_DOMAIN_UVERBS,
@@ -905,7 +900,6 @@ static int __mlx4_ib_create_flow(struct ib_qp *qp, struct ib_flow_attr *flow_att
 	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
-	memset(mailbox->buf, 0, rule_size);
 	ctrl = mailbox->buf;
 
 	ctrl->prio = cpu_to_be16(__mlx4_domain[domain] |
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 65d41b76..7207dcd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2199,6 +2199,8 @@ struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
 		return ERR_PTR(-ENOMEM);
 	}
 
+	memset(mailbox->buf, 0, MLX4_MAILBOX_SIZE);
+
 	return mailbox;
 }
 EXPORT_SYMBOL_GPL(mlx4_alloc_cmd_mailbox);
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 004e423..22fcbe7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -128,8 +128,6 @@ int mlx4_cq_modify(struct mlx4_dev *dev, struct mlx4_cq *cq,
 		return PTR_ERR(mailbox);
 
 	cq_context = mailbox->buf;
-	memset(cq_context, 0, sizeof *cq_context);
-
 	cq_context->cq_max_count = cpu_to_be16(count);
 	cq_context->cq_period    = cpu_to_be16(period);
 
@@ -153,8 +151,6 @@ int mlx4_cq_resize(struct mlx4_dev *dev, struct mlx4_cq *cq,
 		return PTR_ERR(mailbox);
 
 	cq_context = mailbox->buf;
-	memset(cq_context, 0, sizeof *cq_context);
-
 	cq_context->logsize_usrpage = cpu_to_be32(ilog2(entries) << 24);
 	cq_context->log_page_size   = mtt->page_shift - 12;
 	mtt_addr = mlx4_mtt_addr(dev, mtt);
@@ -274,8 +270,6 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	}
 
 	cq_context = mailbox->buf;
-	memset(cq_context, 0, sizeof *cq_context);
-
 	cq_context->flags	    = cpu_to_be32(!!collapsed << 18);
 	if (timestamp_en)
 		cq_context->flags  |= cpu_to_be32(1 << 19);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 3317914..5f8535e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -56,7 +56,6 @@ int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv)
 		return PTR_ERR(mailbox);
 
 	filter = mailbox->buf;
-	memset(filter, 0, sizeof(*filter));
 	for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
 		entry = 0;
 		for (j = 0; j < 32; j++)
@@ -81,7 +80,6 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port)
 	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
-	memset(mailbox->buf, 0, sizeof(*qport_context));
 	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, port, 0,
 			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B,
 			   MLX4_CMD_WRAPPED);
@@ -127,7 +125,6 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
-	memset(mailbox->buf, 0, sizeof(*mlx4_en_stats));
 	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, in_mod, 0,
 			   MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B,
 			   MLX4_CMD_WRAPPED);
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 0416c5b..c9cdb2a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -936,7 +936,6 @@ static int mlx4_create_eq(struct mlx4_dev *dev, int nent,
 	if (err)
 		goto err_out_free_mtt;
 
-	memset(eq_context, 0, sizeof *eq_context);
 	eq_context->flags	  = cpu_to_be32(MLX4_EQ_STATUS_OK   |
 						MLX4_EQ_STATE_ARMED);
 	eq_context->log_eq_size	  = ilog2(eq->nent);
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index c3e70bc..fda2667 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -159,8 +159,6 @@ int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg)
 		return PTR_ERR(mailbox);
 	inbox = mailbox->buf;
 
-	memset(inbox, 0, MOD_STAT_CFG_IN_SIZE);
-
 	MLX4_PUT(inbox, cfg->log_pg_sz, MOD_STAT_CFG_PG_SZ_OFFSET);
 	MLX4_PUT(inbox, cfg->log_pg_sz_m, MOD_STAT_CFG_PG_SZ_M_OFFSET);
 
@@ -967,7 +965,6 @@ int mlx4_map_cmd(struct mlx4_dev *dev, u16 op, struct mlx4_icm *icm, u64 virt)
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
-	memset(mailbox->buf, 0, MLX4_MAILBOX_SIZE);
 	pages = mailbox->buf;
 
 	for (mlx4_icm_first(icm, &iter);
@@ -1316,8 +1313,6 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 		return PTR_ERR(mailbox);
 	inbox = mailbox->buf;
 
-	memset(inbox, 0, INIT_HCA_IN_SIZE);
-
 	*((u8 *) mailbox->buf + INIT_HCA_VERSION_OFFSET) = INIT_HCA_VERSION;
 
 	*((u8 *) mailbox->buf + INIT_HCA_CACHELINE_SZ_OFFSET) =
@@ -1616,8 +1611,6 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 			return PTR_ERR(mailbox);
 		inbox = mailbox->buf;
 
-		memset(inbox, 0, INIT_PORT_IN_SIZE);
-
 		flags = 0;
 		flags |= (dev->caps.vl_cap[port] & 0xf) << INIT_PORT_VL_SHIFT;
 		flags |= (dev->caps.port_width_cap[port] & 0xf) << INIT_PORT_PORT_WIDTH_SHIFT;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 70f0213..acf9d5f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -506,7 +506,6 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 		goto out_list;
 	}
 	mgm = mailbox->buf;
-	memset(mgm, 0, sizeof *mgm);
 	members_count = 0;
 	list_for_each_entry(dqp, &s_steer->promisc_qps[steer], list)
 		mgm->qp[members_count++] = cpu_to_be32(dqp->qpn & MGM_QPN_MASK);
@@ -857,7 +856,6 @@ int mlx4_flow_attach(struct mlx4_dev *dev,
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 
-	memset(mailbox->buf, 0, sizeof(struct mlx4_net_trans_rule_hw_ctrl));
 	trans_rule_ctrl_to_hw(rule, mailbox->buf);
 
 	size += sizeof(struct mlx4_net_trans_rule_hw_ctrl);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 63391a1..b3ee9ba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -480,9 +480,6 @@ int mlx4_mr_enable(struct mlx4_dev *dev, struct mlx4_mr *mr)
 		goto err_table;
 	}
 	mpt_entry = mailbox->buf;
-
-	memset(mpt_entry, 0, sizeof *mpt_entry);
-
 	mpt_entry->flags = cpu_to_be32(MLX4_MPT_FLAG_MIO	 |
 				       MLX4_MPT_FLAG_REGION	 |
 				       mr->access);
@@ -695,8 +692,6 @@ int mlx4_mw_enable(struct mlx4_dev *dev, struct mlx4_mw *mw)
 	}
 	mpt_entry = mailbox->buf;
 
-	memset(mpt_entry, 0, sizeof(*mpt_entry));
-
 	/* Note that the MLX4_MPT_FLAG_REGION bit in mpt_entry->flags is turned
 	 * off, thus creating a memory window and not a memory region.
 	 */
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index caaa154..97d342f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -469,8 +469,6 @@ int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 
 	inbuf = inmailbox->buf;
 	outbuf = outmailbox->buf;
-	memset(inbuf, 0, 256);
-	memset(outbuf, 0, 256);
 	inbuf[0] = 1;
 	inbuf[1] = 1;
 	inbuf[2] = 1;
@@ -653,8 +651,6 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port, int pkey_tbl_sz)
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 
-	memset(mailbox->buf, 0, 256);
-
 	((__be32 *) mailbox->buf)[1] = dev->caps.ib_port_def_cap[port];
 
 	if (pkey_tbl_sz >= 0 && mlx4_is_master(dev)) {
@@ -692,8 +688,6 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
-
 	context->flags = SET_PORT_GEN_ALL_VALID;
 	context->mtu = cpu_to_be16(mtu);
 	context->pptx = (pptx * (!pfctx)) << 7;
@@ -727,8 +721,6 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
-
 	context->base_qpn = cpu_to_be32(base_qpn);
 	context->n_mac = dev->caps.log_num_macs;
 	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
@@ -761,8 +753,6 @@ int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc)
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
-
 	for (i = 0; i < MLX4_NUM_UP; i += 2)
 		context->prio2tc[i >> 1] = prio2tc[i] << 4 | prio2tc[i + 1];
 
@@ -788,7 +778,6 @@ int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
 
 	for (i = 0; i < MLX4_NUM_TC; i++) {
 		struct mlx4_port_scheduler_tc_cfg_be *tc = &context->tc[i];
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index 9e08e35..8fdf237 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -189,8 +189,6 @@ int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, u32 cqn, u16 xrcd,
 	}
 
 	srq_context = mailbox->buf;
-	memset(srq_context, 0, sizeof *srq_context);
-
 	srq_context->state_logsize_srqn = cpu_to_be32((ilog2(srq->max) << 24) |
 						      srq->srqn);
 	srq_context->logstride          = srq->wqe_shift - 4;
-- 
1.8.3.4
