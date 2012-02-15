From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 3/3] mlx4: add unicast steering entries to resource_tracker
Date: Wed, 15 Feb 2012 18:23:16 +0200
Message-ID: <4F3BDBF4.2070308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:43809 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751648Ab2BOQZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 11:25:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.co.il>

Add unicast steering entries to resource tracker.
Do qp_detach also for these entries when VF doesn't shut down gracefully.
Otherwise there is leakage of these resources, since they are not tracked.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 629cc30..bfdb7af 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -73,6 +73,7 @@ struct res_gid {
 	struct list_head	list;
 	u8			gid[16];
 	enum mlx4_protocol	prot;
+	enum mlx4_steer_type	steer;
 };
 
 enum res_qp_states {
@@ -2480,7 +2481,8 @@ static struct res_gid *find_gid(struct mlx4_dev *dev, int slave,
 }
 
 static int add_mcg_res(struct mlx4_dev *dev, int slave, struct res_qp *rqp,
-		       u8 *gid, enum mlx4_protocol prot)
+		       u8 *gid, enum mlx4_protocol prot,
+		       enum mlx4_steer_type steer)
 {
 	struct res_gid *res;
 	int err;
@@ -2496,6 +2498,7 @@ static int add_mcg_res(struct mlx4_dev *dev, int slave, struct res_qp *rqp,
 	} else {
 		memcpy(res->gid, gid, 16);
 		res->prot = prot;
+		res->steer = steer;
 		list_add_tail(&res->list, &rqp->mcg_list);
 		err = 0;
 	}
@@ -2505,14 +2508,15 @@ static int add_mcg_res(struct mlx4_dev *dev, int slave, struct res_qp *rqp,
 }
 
 static int rem_mcg_res(struct mlx4_dev *dev, int slave, struct res_qp *rqp,
-		       u8 *gid, enum mlx4_protocol prot)
+		       u8 *gid, enum mlx4_protocol prot,
+		       enum mlx4_steer_type steer)
 {
 	struct res_gid *res;
 	int err;
 
 	spin_lock_irq(&rqp->mcg_spl);
 	res = find_gid(dev, slave, rqp, gid);
-	if (!res || res->prot != prot)
+	if (!res || res->prot != prot || res->steer != steer)
 		err = -EINVAL;
 	else {
 		list_del(&res->list);
@@ -2548,7 +2552,7 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 
 	qp.qpn = qpn;
 	if (attach) {
-		err = add_mcg_res(dev, slave, rqp, gid, prot);
+		err = add_mcg_res(dev, slave, rqp, gid, prot, type);
 		if (err)
 			goto ex_put;
 
@@ -2557,7 +2561,7 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 		if (err)
 			goto ex_rem;
 	} else {
-		err = rem_mcg_res(dev, slave, rqp, gid, prot);
+		err = rem_mcg_res(dev, slave, rqp, gid, prot, type);
 		if (err)
 			goto ex_put;
 		err = mlx4_qp_detach_common(dev, &qp, gid, prot, type);
@@ -2568,7 +2572,7 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 
 ex_rem:
 	/* ignore error return below, already in error */
-	err1 = rem_mcg_res(dev, slave, rqp, gid, prot);
+	err1 = rem_mcg_res(dev, slave, rqp, gid, prot, type);
 ex_put:
 	put_res(dev, slave, qpn, RES_QP);
 
@@ -2607,7 +2611,7 @@ static void detach_qp(struct mlx4_dev *dev, int slave, struct res_qp *rqp)
 	list_for_each_entry_safe(rgid, tmp, &rqp->mcg_list, list) {
 		qp.qpn = rqp->local_qpn;
 		err = mlx4_qp_detach_common(dev, &qp, rgid->gid, rgid->prot,
-					    MLX4_MC_STEER);
+					    rgid->steer);
 		list_del(&rgid->list);
 		kfree(rgid);
 	}
-- 
1.5.4.3
