From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/14] mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops
Date: Mon,  4 Jul 2016 08:23:11 +0200
Message-ID: <1467613397-17140-9-git-send-email-jiri@resnulli.us>
References: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34643 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbcGDGXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id 187so19172451wmz.1
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:31 -0700 (PDT)
In-Reply-To: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement ipv4 FIB entries addition and removal. Initially, we support
local and broadcast routes using "ip2me" trap action.
Also, unicast routes without nexthop are supported using "local" action.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   5 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 245 +++++++++++++++++++++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 +
 3 files changed, 259 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5b40dfc..877a879 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -476,5 +476,10 @@ static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
+int mlxsw_sp_router_fib4_add(struct mlxsw_sp_port *mlxsw_sp_port,
+			     const struct switchdev_obj_ipv4_fib *fib4,
+			     struct switchdev_trans *trans);
+int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
+			     const struct switchdev_obj_ipv4_fib *fib4);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 11dab74..7e3992a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -106,9 +106,19 @@ struct mlxsw_sp_fib_key {
 	unsigned char prefix_len;
 };
 
+enum mlxsw_sp_fib_entry_type {
+	MLXSW_SP_FIB_ENTRY_TYPE_REMOTE,
+	MLXSW_SP_FIB_ENTRY_TYPE_LOCAL,
+	MLXSW_SP_FIB_ENTRY_TYPE_TRAP,
+};
+
 struct mlxsw_sp_fib_entry {
 	struct rhash_head ht_node;
 	struct mlxsw_sp_fib_key key;
+	enum mlxsw_sp_fib_entry_type type;
+	u8 added:1;
+	u16 rif; /* used for action local */
+	struct mlxsw_sp_vr *vr;
 };
 
 struct mlxsw_sp_fib {
@@ -567,3 +577,238 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	__mlxsw_sp_router_fini(mlxsw_sp);
 }
+
+static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry,
+					enum mlxsw_reg_ralue_op op)
+{
+	char ralue_pl[MLXSW_REG_RALUE_LEN];
+	u32 *p_dip = (u32 *) fib_entry->key.addr;
+	struct mlxsw_sp_vr *vr = fib_entry->vr;
+
+	mlxsw_reg_ralue_pack4(ralue_pl, vr->proto, op, vr->id,
+			      fib_entry->key.prefix_len, *p_dip);
+	mlxsw_reg_ralue_act_local_pack(ralue_pl,
+				       MLXSW_REG_RALUE_TRAP_ACTION_NOP, 0,
+				       fib_entry->rif);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
+}
+
+static int mlxsw_sp_fib_entry_op4_trap(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_fib_entry *fib_entry,
+				       enum mlxsw_reg_ralue_op op)
+{
+	char ralue_pl[MLXSW_REG_RALUE_LEN];
+	u32 *p_dip = (u32 *) fib_entry->key.addr;
+	struct mlxsw_sp_vr *vr = fib_entry->vr;
+
+	mlxsw_reg_ralue_pack4(ralue_pl, vr->proto, op, vr->id,
+			      fib_entry->key.prefix_len, *p_dip);
+	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
+}
+
+static int mlxsw_sp_fib_entry_op4(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_fib_entry *fib_entry,
+				  enum mlxsw_reg_ralue_op op)
+{
+	switch (fib_entry->type) {
+	case MLXSW_SP_FIB_ENTRY_TYPE_REMOTE:
+		return -EINVAL;
+	case MLXSW_SP_FIB_ENTRY_TYPE_LOCAL:
+		return mlxsw_sp_fib_entry_op4_local(mlxsw_sp, fib_entry, op);
+	case MLXSW_SP_FIB_ENTRY_TYPE_TRAP:
+		return mlxsw_sp_fib_entry_op4_trap(mlxsw_sp, fib_entry, op);
+	}
+	return -EINVAL;
+}
+
+static int mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
+				 struct mlxsw_sp_fib_entry *fib_entry,
+				 enum mlxsw_reg_ralue_op op)
+{
+	switch (fib_entry->vr->proto) {
+	case MLXSW_SP_L3_PROTO_IPV4:
+		return mlxsw_sp_fib_entry_op4(mlxsw_sp, fib_entry, op);
+	case MLXSW_SP_L3_PROTO_IPV6:
+		return -EINVAL;
+	}
+	return -EINVAL;
+}
+
+static int mlxsw_sp_fib_entry_update(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_fib_entry *fib_entry)
+{
+	enum mlxsw_reg_ralue_op op;
+
+	op = !fib_entry->added ? MLXSW_REG_RALUE_OP_WRITE_WRITE :
+				 MLXSW_REG_RALUE_OP_WRITE_UPDATE;
+	return mlxsw_sp_fib_entry_op(mlxsw_sp, fib_entry, op);
+}
+
+static int mlxsw_sp_fib_entry_del(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_fib_entry *fib_entry)
+{
+	return mlxsw_sp_fib_entry_op(mlxsw_sp, fib_entry,
+				     MLXSW_REG_RALUE_OP_WRITE_DELETE);
+}
+
+struct mlxsw_sp_router_fib4_add_info {
+	struct switchdev_trans_item tritem;
+	struct mlxsw_sp *mlxsw_sp;
+	struct mlxsw_sp_fib_entry *fib_entry;
+};
+
+static void mlxsw_sp_router_fib4_add_info_destroy(void const *data)
+{
+	const struct mlxsw_sp_router_fib4_add_info *info = data;
+	struct mlxsw_sp_fib_entry *fib_entry = info->fib_entry;
+	struct mlxsw_sp *mlxsw_sp = info->mlxsw_sp;
+
+	mlxsw_sp_fib_entry_destroy(fib_entry);
+	mlxsw_sp_vr_put(mlxsw_sp, fib_entry->vr);
+	kfree(info);
+}
+
+static int
+mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
+				const struct switchdev_obj_ipv4_fib *fib4,
+				struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct fib_info *fi = fib4->fi;
+
+	if (fib4->type == RTN_LOCAL || fib4->type == RTN_BROADCAST) {
+		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
+		return 0;
+	}
+	if (fib4->type != RTN_UNICAST)
+		return -EINVAL;
+
+	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
+		struct mlxsw_sp_rif *r;
+
+		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
+		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fi->fib_dev);
+		if (!r)
+			return -EINVAL;
+		fib_entry->rif = r->rif;
+		return 0;
+	}
+	return -EINVAL;
+}
+
+static int
+mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
+				 const struct switchdev_obj_ipv4_fib *fib4,
+				 struct switchdev_trans *trans)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_router_fib4_add_info *info;
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_vr *vr;
+	int err;
+
+	vr = mlxsw_sp_vr_get(mlxsw_sp, fib4->dst_len, fib4->tb_id,
+			     MLXSW_SP_L3_PROTO_IPV4);
+	if (IS_ERR(vr))
+		return PTR_ERR(vr);
+
+	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fib4->dst,
+					      sizeof(fib4->dst), fib4->dst_len);
+	if (!fib_entry) {
+		err = -ENOMEM;
+		goto err_fib_entry_create;
+	}
+	fib_entry->vr = vr;
+
+	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fib4, fib_entry);
+	if (err)
+		goto err_fib4_entry_init;
+
+	info = kmalloc(sizeof(*info), GFP_KERNEL);
+	if (!info) {
+		err = -ENOMEM;
+		goto err_alloc_info;
+	}
+	info->mlxsw_sp = mlxsw_sp;
+	info->fib_entry = fib_entry;
+	switchdev_trans_item_enqueue(trans, info,
+				     mlxsw_sp_router_fib4_add_info_destroy,
+				     &info->tritem);
+	return 0;
+
+err_alloc_info:
+err_fib4_entry_init:
+	mlxsw_sp_fib_entry_destroy(fib_entry);
+err_fib_entry_create:
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	return err;
+}
+
+static int
+mlxsw_sp_router_fib4_add_commit(struct mlxsw_sp_port *mlxsw_sp_port,
+				const struct switchdev_obj_ipv4_fib *fib4,
+				struct switchdev_trans *trans)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_router_fib4_add_info *info;
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_vr *vr;
+	int err;
+
+	info = switchdev_trans_item_dequeue(trans);
+	fib_entry = info->fib_entry;
+	kfree(info);
+
+	vr = fib_entry->vr;
+	err = mlxsw_sp_fib_entry_insert(fib_entry->vr->fib, fib_entry);
+	if (err)
+		goto err_fib_entry_insert;
+	err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
+	if (err)
+		goto err_fib_entry_add;
+	return 0;
+
+err_fib_entry_add:
+	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
+err_fib_entry_insert:
+	mlxsw_sp_fib_entry_destroy(fib_entry);
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	return err;
+}
+
+int mlxsw_sp_router_fib4_add(struct mlxsw_sp_port *mlxsw_sp_port,
+			     const struct switchdev_obj_ipv4_fib *fib4,
+			     struct switchdev_trans *trans)
+{
+	if (switchdev_trans_ph_prepare(trans))
+		return mlxsw_sp_router_fib4_add_prepare(mlxsw_sp_port,
+							fib4, trans);
+	return mlxsw_sp_router_fib4_add_commit(mlxsw_sp_port,
+					       fib4, trans);
+}
+
+int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
+			     const struct switchdev_obj_ipv4_fib *fib4)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_vr *vr;
+
+	vr = mlxsw_sp_vr_find(mlxsw_sp, fib4->tb_id, MLXSW_SP_L3_PROTO_IPV4);
+	if (!vr) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find virtual router for FIB4 entry being removed.\n");
+		return -ENOENT;
+	}
+	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
+					      sizeof(fib4->dst), fib4->dst_len);
+	if (!fib_entry) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find FIB4 entry being removed.\n");
+		return PTR_ERR(vr);
+	}
+	mlxsw_sp_fib_entry_del(mlxsw_sp_port->mlxsw_sp, fib_entry);
+	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
+	mlxsw_sp_fib_entry_destroy(fib_entry);
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	return 0;
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 927117e..4decc30 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -978,6 +978,11 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
 					      trans);
 		break;
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
+		err = mlxsw_sp_router_fib4_add(mlxsw_sp_port,
+					       SWITCHDEV_OBJ_IPV4_FIB(obj),
+					       trans);
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = mlxsw_sp_port_fdb_static_add(mlxsw_sp_port,
 						   SWITCHDEV_OBJ_PORT_FDB(obj),
@@ -1123,6 +1128,10 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 		err = mlxsw_sp_port_vlans_del(mlxsw_sp_port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
+	case SWITCHDEV_OBJ_ID_IPV4_FIB:
+		err = mlxsw_sp_router_fib4_del(mlxsw_sp_port,
+					       SWITCHDEV_OBJ_IPV4_FIB(obj));
+		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = mlxsw_sp_port_fdb_static_del(mlxsw_sp_port,
 						   SWITCHDEV_OBJ_PORT_FDB(obj));
-- 
2.5.5
