From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/23] mlxsw: spectrum: Use only one function to create vFIDs
Date: Mon, 20 Jun 2016 23:04:09 +0200
Message-ID: <1466456661-5260-12-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33528 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbcFTV7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:59:49 -0400
Received: by mail-lf0-f65.google.com with SMTP id l188so7013763lfe.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:59:43 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Simplify the code and use only one function for vFID creation /
destruction.

Unlike before, the function receives a FID index as its argument and not
a vFID index. Instead of passing 0, now one would need to pass 4K, which
is the first vFID.

This is the first step in creating a generic FID struct that will be
used for all three types of FIDs.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 79 ++++++++++++--------------
 1 file changed, 37 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 90cf6c5..4f53dd2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -652,68 +652,61 @@ static u16 mlxsw_sp_avail_vfid_get(const struct mlxsw_sp *mlxsw_sp)
 				   MLXSW_SP_VFID_PORT_MAX);
 }
 
-static int __mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp, u16 vfid)
+static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 {
-	u16 fid = mlxsw_sp_vfid_to_fid(vfid);
 	char sfmr_pl[MLXSW_REG_SFMR_LEN];
 
-	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_CREATE_FID, fid, 0);
+	mlxsw_reg_sfmr_pack(sfmr_pl, !create, fid, 0);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
 }
 
-static void __mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp, u16 vfid)
-{
-	u16 fid = mlxsw_sp_vfid_to_fid(vfid);
-	char sfmr_pl[MLXSW_REG_SFMR_LEN];
-
-	mlxsw_reg_sfmr_pack(sfmr_pl, MLXSW_REG_SFMR_OP_DESTROY_FID, fid, 0);
-	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
-}
-
 static struct mlxsw_sp_vfid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
 						  u16 vid)
 {
 	struct device *dev = mlxsw_sp->bus_info->dev;
-	struct mlxsw_sp_vfid *vfid;
-	u16 n_vfid;
+	struct mlxsw_sp_vfid *f;
+	u16 vfid, fid;
 	int err;
 
-	n_vfid = mlxsw_sp_avail_vfid_get(mlxsw_sp);
-	if (n_vfid == MLXSW_SP_VFID_PORT_MAX) {
+	vfid = mlxsw_sp_avail_vfid_get(mlxsw_sp);
+	if (vfid == MLXSW_SP_VFID_PORT_MAX) {
 		dev_err(dev, "No available vFIDs\n");
 		return ERR_PTR(-ERANGE);
 	}
 
-	err = __mlxsw_sp_vfid_create(mlxsw_sp, n_vfid);
+	fid = mlxsw_sp_vfid_to_fid(vfid);
+	err = mlxsw_sp_vfid_op(mlxsw_sp, fid, true);
 	if (err) {
-		dev_err(dev, "Failed to create vFID=%d\n", n_vfid);
+		dev_err(dev, "Failed to create FID=%d\n", fid);
 		return ERR_PTR(err);
 	}
 
-	vfid = kzalloc(sizeof(*vfid), GFP_KERNEL);
-	if (!vfid)
+	f = kzalloc(sizeof(*f), GFP_KERNEL);
+	if (!f)
 		goto err_allocate_vfid;
 
-	vfid->vfid = n_vfid;
-	vfid->vid = vid;
+	f->vfid = vfid;
+	f->vid = vid;
 
-	list_add(&vfid->list, &mlxsw_sp->port_vfids.list);
-	set_bit(n_vfid, mlxsw_sp->port_vfids.mapped);
+	list_add(&f->list, &mlxsw_sp->port_vfids.list);
+	set_bit(vfid, mlxsw_sp->port_vfids.mapped);
 
-	return vfid;
+	return f;
 
 err_allocate_vfid:
-	__mlxsw_sp_vfid_destroy(mlxsw_sp, n_vfid);
+	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
 	return ERR_PTR(-ENOMEM);
 }
 
 static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 				  struct mlxsw_sp_vfid *vfid)
 {
+	u16 fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+
 	clear_bit(vfid->vfid, mlxsw_sp->port_vfids.mapped);
 	list_del(&vfid->list);
 
-	__mlxsw_sp_vfid_destroy(mlxsw_sp, vfid->vfid);
+	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
 
 	kfree(vfid);
 }
@@ -3164,36 +3157,37 @@ static struct mlxsw_sp_vfid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 						     struct net_device *br_dev)
 {
 	struct device *dev = mlxsw_sp->bus_info->dev;
-	struct mlxsw_sp_vfid *vfid;
-	u16 n_vfid;
+	struct mlxsw_sp_vfid *f;
+	u16 vfid, fid;
 	int err;
 
-	n_vfid = mlxsw_sp_br_vfid_to_vfid(mlxsw_sp_avail_br_vfid_get(mlxsw_sp));
-	if (n_vfid == MLXSW_SP_VFID_MAX) {
+	vfid = mlxsw_sp_br_vfid_to_vfid(mlxsw_sp_avail_br_vfid_get(mlxsw_sp));
+	if (vfid == MLXSW_SP_VFID_MAX) {
 		dev_err(dev, "No available vFIDs\n");
 		return ERR_PTR(-ERANGE);
 	}
 
-	err = __mlxsw_sp_vfid_create(mlxsw_sp, n_vfid);
+	fid = mlxsw_sp_vfid_to_fid(vfid);
+	err = mlxsw_sp_vfid_op(mlxsw_sp, fid, true);
 	if (err) {
-		dev_err(dev, "Failed to create vFID=%d\n", n_vfid);
+		dev_err(dev, "Failed to create FID=%d\n", fid);
 		return ERR_PTR(err);
 	}
 
-	vfid = kzalloc(sizeof(*vfid), GFP_KERNEL);
-	if (!vfid)
+	f = kzalloc(sizeof(*f), GFP_KERNEL);
+	if (!f)
 		goto err_allocate_vfid;
 
-	vfid->vfid = n_vfid;
-	vfid->br_dev = br_dev;
+	f->vfid = vfid;
+	f->br_dev = br_dev;
 
-	list_add(&vfid->list, &mlxsw_sp->br_vfids.list);
-	set_bit(mlxsw_sp_vfid_to_br_vfid(n_vfid), mlxsw_sp->br_vfids.mapped);
+	list_add(&f->list, &mlxsw_sp->br_vfids.list);
+	set_bit(mlxsw_sp_vfid_to_br_vfid(vfid), mlxsw_sp->br_vfids.mapped);
 
-	return vfid;
+	return f;
 
 err_allocate_vfid:
-	__mlxsw_sp_vfid_destroy(mlxsw_sp, n_vfid);
+	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
 	return ERR_PTR(-ENOMEM);
 }
 
@@ -3201,11 +3195,12 @@ static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 				     struct mlxsw_sp_vfid *vfid)
 {
 	u16 br_vfid = mlxsw_sp_vfid_to_br_vfid(vfid->vfid);
+	u16 fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
 
 	clear_bit(br_vfid, mlxsw_sp->br_vfids.mapped);
 	list_del(&vfid->list);
 
-	__mlxsw_sp_vfid_destroy(mlxsw_sp, vfid->vfid);
+	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
 
 	kfree(vfid);
 }
-- 
2.5.5
