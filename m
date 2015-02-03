From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 09/10] IB/mlx4: Create mirror flows in port aggregation mode
Date: Tue,  3 Feb 2015 16:48:38 +0200
Message-ID: <1422974919-28084-11-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60129 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965526AbbBCOuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:50:21 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

In port aggregation mode flows for port #1 (the only port) should be mirrored
on port #2. This is because packets can arrive from either physical ports.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c    |   84 +++++++++++++++++++++++++++++-----
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    9 +++-
 2 files changed, 80 insertions(+), 13 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index ed21ae6..ca52238 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -851,7 +851,7 @@ int mlx4_ib_add_mc(struct mlx4_ib_dev *mdev, struct mlx4_ib_qp *mqp,
 
 struct mlx4_ib_steering {
 	struct list_head list;
-	u64 reg_id;
+	struct mlx4_flow_reg_id reg_id;
 	union ib_gid gid;
 };
 
@@ -1142,9 +1142,11 @@ static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
 				    struct ib_flow_attr *flow_attr,
 				    int domain)
 {
-	int err = 0, i = 0;
+	int err = 0, i = 0, j = 0;
 	struct mlx4_ib_flow *mflow;
 	enum mlx4_net_trans_promisc_mode type[2];
+	struct mlx4_dev *dev = (to_mdev(qp->device))->dev;
+	int is_bonded = mlx4_is_bonded(dev);
 
 	memset(type, 0, sizeof(type));
 
@@ -1179,26 +1181,55 @@ static struct ib_flow *mlx4_ib_create_flow(struct ib_qp *qp,
 
 	while (i < ARRAY_SIZE(type) && type[i]) {
 		err = __mlx4_ib_create_flow(qp, flow_attr, domain, type[i],
-					    &mflow->reg_id[i]);
+					    &mflow->reg_id[i].id);
 		if (err)
 			goto err_create_flow;
 		i++;
+		if (is_bonded) {
+			flow_attr->port = 2;
+			err = __mlx4_ib_create_flow(qp, flow_attr,
+						    domain, type[j],
+						    &mflow->reg_id[j].mirror);
+			flow_attr->port = 1;
+			if (err)
+				goto err_create_flow;
+			j++;
+		}
+
 	}
 
 	if (i < ARRAY_SIZE(type) && flow_attr->type == IB_FLOW_ATTR_NORMAL) {
-		err = mlx4_ib_tunnel_steer_add(qp, flow_attr, &mflow->reg_id[i]);
+		err = mlx4_ib_tunnel_steer_add(qp, flow_attr,
+					       &mflow->reg_id[i].id);
 		if (err)
 			goto err_create_flow;
 		i++;
+		if (is_bonded) {
+			flow_attr->port = 2;
+			err = mlx4_ib_tunnel_steer_add(qp, flow_attr,
+						       &mflow->reg_id[j].mirror);
+			flow_attr->port = 1;
+			if (err)
+				goto err_create_flow;
+			j++;
+		}
+		/* function to create mirror rule */
 	}
 
 	return &mflow->ibflow;
 
 err_create_flow:
 	while (i) {
-		(void)__mlx4_ib_destroy_flow(to_mdev(qp->device)->dev, mflow->reg_id[i]);
+		(void)__mlx4_ib_destroy_flow(to_mdev(qp->device)->dev,
+					     mflow->reg_id[i].id);
 		i--;
 	}
+
+	while (j) {
+		(void)__mlx4_ib_destroy_flow(to_mdev(qp->device)->dev,
+					     mflow->reg_id[j].mirror);
+		j--;
+	}
 err_free:
 	kfree(mflow);
 	return ERR_PTR(err);
@@ -1211,10 +1242,16 @@ static int mlx4_ib_destroy_flow(struct ib_flow *flow_id)
 	struct mlx4_ib_dev *mdev = to_mdev(flow_id->qp->device);
 	struct mlx4_ib_flow *mflow = to_mflow(flow_id);
 
-	while (i < ARRAY_SIZE(mflow->reg_id) && mflow->reg_id[i]) {
-		err = __mlx4_ib_destroy_flow(mdev->dev, mflow->reg_id[i]);
+	while (i < ARRAY_SIZE(mflow->reg_id) && mflow->reg_id[i].id) {
+		err = __mlx4_ib_destroy_flow(mdev->dev, mflow->reg_id[i].id);
 		if (err)
 			ret = err;
+		if (mflow->reg_id[i].mirror) {
+			err = __mlx4_ib_destroy_flow(mdev->dev,
+						     mflow->reg_id[i].mirror);
+			if (err)
+				ret = err;
+		}
 		i++;
 	}
 
@@ -1226,11 +1263,12 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	int err;
 	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
+	struct mlx4_dev	*dev = mdev->dev;
 	struct mlx4_ib_qp *mqp = to_mqp(ibqp);
-	u64 reg_id;
 	struct mlx4_ib_steering *ib_steering = NULL;
 	enum mlx4_protocol prot = (gid->raw[1] == 0x0e) ?
 		MLX4_PROT_IB_IPV4 : MLX4_PROT_IB_IPV6;
+	struct mlx4_flow_reg_id	reg_id;
 
 	if (mdev->dev->caps.steering_mode ==
 	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
@@ -1242,10 +1280,20 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw, mqp->port,
 				    !!(mqp->flags &
 				       MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
-				    prot, &reg_id);
+				    prot, &reg_id.id);
 	if (err)
 		goto err_malloc;
 
+	reg_id.mirror = 0;
+	if (mlx4_is_bonded(dev)) {
+		err = mlx4_multicast_attach(mdev->dev, &mqp->mqp, gid->raw, 2,
+					    !!(mqp->flags &
+					    MLX4_IB_QP_BLOCK_MULTICAST_LOOPBACK),
+					    prot, &reg_id.mirror);
+		if (err)
+			goto err_add;
+	}
+
 	err = add_gid_entry(ibqp, gid);
 	if (err)
 		goto err_add;
@@ -1261,7 +1309,10 @@ static int mlx4_ib_mcg_attach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 
 err_add:
 	mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw,
-			      prot, reg_id);
+			      prot, reg_id.id);
+	if (reg_id.mirror)
+		mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw,
+				      prot, reg_id.mirror);
 err_malloc:
 	kfree(ib_steering);
 
@@ -1288,10 +1339,12 @@ static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 {
 	int err;
 	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
+	struct mlx4_dev *dev = mdev->dev;
 	struct mlx4_ib_qp *mqp = to_mqp(ibqp);
 	struct net_device *ndev;
 	struct mlx4_ib_gid_entry *ge;
-	u64 reg_id = 0;
+	struct mlx4_flow_reg_id reg_id = {0, 0};
+
 	enum mlx4_protocol prot = (gid->raw[1] == 0x0e) ?
 		MLX4_PROT_IB_IPV4 : MLX4_PROT_IB_IPV6;
 
@@ -1316,10 +1369,17 @@ static int mlx4_ib_mcg_detach(struct ib_qp *ibqp, union ib_gid *gid, u16 lid)
 	}
 
 	err = mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw,
-				    prot, reg_id);
+				    prot, reg_id.id);
 	if (err)
 		return err;
 
+	if (mlx4_is_bonded(dev)) {
+		err = mlx4_multicast_detach(mdev->dev, &mqp->mqp, gid->raw,
+					    prot, reg_id.mirror);
+		if (err)
+			return err;
+	}
+
 	mutex_lock(&mqp->mutex);
 	ge = find_gid_entry(mqp, gid->raw);
 	if (ge) {
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 6eb743f..2b49f9d 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -134,10 +134,17 @@ struct mlx4_ib_fmr {
 	struct mlx4_fmr         mfmr;
 };
 
+#define MAX_REGS_PER_FLOW 2
+
+struct mlx4_flow_reg_id {
+	u64 id;
+	u64 mirror;
+};
+
 struct mlx4_ib_flow {
 	struct ib_flow ibflow;
 	/* translating DMFS verbs sniffer rule to FW API requires two reg IDs */
-	u64 reg_id[2];
+	struct mlx4_flow_reg_id reg_id[MAX_REGS_PER_FLOW];
 };
 
 struct mlx4_ib_wq {
-- 
1.7.1
