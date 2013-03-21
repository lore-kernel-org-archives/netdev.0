From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 5/5] net/mlx4_core: Disallow releasing VF QPs which have steering rules
Date: Thu, 21 Mar 2013 17:55:55 +0200
Message-ID: <1363881355-21137-6-git-send-email-ogerlitz@mellanox.com>
References: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:41348 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755976Ab3CUP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:56:05 -0400
In-Reply-To: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

VF QPs must not be released when they have steering rules attached to them.

For that end, introduce a reference count field to the QP object in the
SRIOV resource tracker which is incremented/decremented when steering rules
are attached/detached to it. QPs can be released by VF only when their
ref count is zero.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   41 ++++++++++++++++----
 1 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index b0ccdb5..1391b52 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -99,6 +99,7 @@ struct res_qp {
 	struct list_head	mcg_list;
 	spinlock_t		mcg_spl;
 	int			local_qpn;
+	atomic_t		ref_count;
 };
 
 enum res_mtt_states {
@@ -197,6 +198,7 @@ enum res_fs_rule_states {
 
 struct res_fs_rule {
 	struct res_common	com;
+	int			qpn;
 };
 
 static void *res_tracker_lookup(struct rb_root *root, u64 res_id)
@@ -447,6 +449,7 @@ static struct res_common *alloc_qp_tr(int id)
 	ret->local_qpn = id;
 	INIT_LIST_HEAD(&ret->mcg_list);
 	spin_lock_init(&ret->mcg_spl);
+	atomic_set(&ret->ref_count, 0);
 
 	return &ret->com;
 }
@@ -554,7 +557,7 @@ static struct res_common *alloc_xrcdn_tr(int id)
 	return &ret->com;
 }
 
-static struct res_common *alloc_fs_rule_tr(u64 id)
+static struct res_common *alloc_fs_rule_tr(u64 id, int qpn)
 {
 	struct res_fs_rule *ret;
 
@@ -564,7 +567,7 @@ static struct res_common *alloc_fs_rule_tr(u64 id)
 
 	ret->com.res_id = id;
 	ret->com.state = RES_FS_RULE_ALLOCATED;
-
+	ret->qpn = qpn;
 	return &ret->com;
 }
 
@@ -602,7 +605,7 @@ static struct res_common *alloc_tr(u64 id, enum mlx4_resource type, int slave,
 		ret = alloc_xrcdn_tr(id);
 		break;
 	case RES_FS_RULE:
-		ret = alloc_fs_rule_tr(id);
+		ret = alloc_fs_rule_tr(id, extra);
 		break;
 	default:
 		return NULL;
@@ -671,10 +674,14 @@ undo:
 
 static int remove_qp_ok(struct res_qp *res)
 {
-	if (res->com.state == RES_QP_BUSY)
+	if (res->com.state == RES_QP_BUSY || atomic_read(&res->ref_count) ||
+	    !list_empty(&res->mcg_list)) {
+		pr_err("resource tracker: fail to remove qp, state %d, ref_count %d\n",
+		       res->com.state, atomic_read(&res->ref_count));
 		return -EBUSY;
-	else if (res->com.state != RES_QP_RESERVED)
+	} else if (res->com.state != RES_QP_RESERVED) {
 		return -EPERM;
+	}
 
 	return 0;
 }
@@ -3124,6 +3131,7 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	struct list_head *rlist = &tracker->slave_list[slave].res_list[RES_MAC];
 	int err;
 	int qpn;
+	struct res_qp *rqp;
 	struct mlx4_net_trans_rule_hw_ctrl *ctrl;
 	struct _rule_hw  *rule_header;
 	int header_id;
@@ -3134,7 +3142,7 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 
 	ctrl = (struct mlx4_net_trans_rule_hw_ctrl *)inbox->buf;
 	qpn = be32_to_cpu(ctrl->qpn) & 0xffffff;
-	err = get_res(dev, slave, qpn, RES_QP, NULL);
+	err = get_res(dev, slave, qpn, RES_QP, &rqp);
 	if (err) {
 		pr_err("Steering rule with qpn 0x%x rejected.\n", qpn);
 		return err;
@@ -3175,14 +3183,16 @@ int mlx4_QP_FLOW_STEERING_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	if (err)
 		goto err_put;
 
-	err = add_res_range(dev, slave, vhcr->out_param, 1, RES_FS_RULE, 0);
+	err = add_res_range(dev, slave, vhcr->out_param, 1, RES_FS_RULE, qpn);
 	if (err) {
 		mlx4_err(dev, "Fail to add flow steering resources.\n ");
 		/* detach rule*/
 		mlx4_cmd(dev, vhcr->out_param, 0, 0,
 			 MLX4_QP_FLOW_STEERING_DETACH, MLX4_CMD_TIME_CLASS_A,
 			 MLX4_CMD_NATIVE);
+		goto err_put;
 	}
+	atomic_inc(&rqp->ref_count);
 err_put:
 	put_res(dev, slave, qpn, RES_QP);
 	return err;
@@ -3195,20 +3205,35 @@ int mlx4_QP_FLOW_STEERING_DETACH_wrapper(struct mlx4_dev *dev, int slave,
 					 struct mlx4_cmd_info *cmd)
 {
 	int err;
+	struct res_qp *rqp;
+	struct res_fs_rule *rrule;
 
 	if (dev->caps.steering_mode !=
 	    MLX4_STEERING_MODE_DEVICE_MANAGED)
 		return -EOPNOTSUPP;
 
+	err = get_res(dev, slave, vhcr->in_param, RES_FS_RULE, &rrule);
+	if (err)
+		return err;
+	/* Release the rule form busy state before removal */
+	put_res(dev, slave, vhcr->in_param, RES_FS_RULE);
+	err = get_res(dev, slave, rrule->qpn, RES_QP, &rqp);
+	if (err)
+		return err;
+
 	err = rem_res_range(dev, slave, vhcr->in_param, 1, RES_FS_RULE, 0);
 	if (err) {
 		mlx4_err(dev, "Fail to remove flow steering resources.\n ");
-		return err;
+		goto out;
 	}
 
 	err = mlx4_cmd(dev, vhcr->in_param, 0, 0,
 		       MLX4_QP_FLOW_STEERING_DETACH, MLX4_CMD_TIME_CLASS_A,
 		       MLX4_CMD_NATIVE);
+	if (!err)
+		atomic_dec(&rqp->ref_count);
+out:
+	put_res(dev, slave, rrule->qpn, RES_QP);
 	return err;
 }
 
-- 
1.7.1
