From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 06/13] net/mlx5_core: Add new query HCA vport commands
Date: Thu,  4 Jun 2015 19:30:41 +0300
Message-ID: <1433435448-4937-7-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47763 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753238AbbFDQbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:40 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Added the implementation for the following commands:

1. QUERY_HCA_VPORT_GID
2. QUERY_HCA_VPORT_PKEY
3. QUERY_HCA_VPORT_CONTEXT

They will be needed when we move to work with ISSI > 0 in the IB driver too.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile |    4 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c   |   10 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c  |  259 ++++++++++++++++++++++
 include/linux/mlx5/device.h                      |   13 +
 include/linux/mlx5/driver.h                      |   45 ++++
 include/linux/mlx5/mlx5_ifc.h                    |   23 ++-
 include/linux/mlx5/vport.h                       |   14 ++
 7 files changed, 349 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 07540f7..26a68b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -2,7 +2,7 @@ obj-$(CONFIG_MLX5_CORE)		+= mlx5_core.o
 
 mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 		health.o mcg.o cq.o srq.o alloc.o qp.o port.o mr.o pd.o   \
-		mad.o transobj.o
-mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o flow_table.o vport.o \
+		mad.o transobj.o vport.o
+mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o flow_table.o \
 		en_main.o en_flow_table.o en_ethtool.o en_tx.o en_rx.o \
 		en_txrx.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 11c7216..5835412 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -284,14 +284,6 @@ static u16 to_fw_pkey_sz(u32 size)
 	}
 }
 
-static u16 to_sw_pkey_sz(int pkey_sz)
-{
-	if (pkey_sz > MLX5_MAX_LOG_PKEY_TABLE)
-		return 0;
-
-	return MLX5_MIN_PKEY_TABLE_SIZE << pkey_sz;
-}
-
 int mlx5_core_get_caps(struct mlx5_core_dev *dev, enum mlx5_cap_type cap_type,
 		       enum mlx5_cap_mode cap_mode)
 {
@@ -386,7 +378,7 @@ static int handle_hca_cap(struct mlx5_core_dev *dev)
 	       MLX5_ST_SZ_BYTES(cmd_hca_cap));
 
 	mlx5_core_dbg(dev, "Current Pkey table size %d Setting new size %d\n",
-		      to_sw_pkey_sz(MLX5_CAP_GEN(dev, pkey_table_size)),
+		      mlx5_to_sw_pkey_sz(MLX5_CAP_GEN(dev, pkey_table_size)),
 		      128);
 	/* we limit the size of the pkey table to 128 entries for now */
 	MLX5_SET(cmd_hca_cap, set_hca_cap, pkey_table_size,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 32c4e03..20150ff 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -84,3 +84,262 @@ void mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr)
 	kvfree(out);
 }
 EXPORT_SYMBOL(mlx5_query_nic_vport_mac_address);
+
+int mlx5_query_hca_vport_gid(struct mlx5_core_dev *dev, u8 other_vport,
+			     u8 port_num, u16  vf_num, u16 gid_index,
+			     union ib_gid *gid)
+{
+	int in_sz = MLX5_ST_SZ_BYTES(query_hca_vport_gid_in);
+	int out_sz = MLX5_ST_SZ_BYTES(query_hca_vport_gid_out);
+	int is_group_manager;
+	void *out = NULL;
+	void *in = NULL;
+	union ib_gid *tmp;
+	int tbsz;
+	int nout;
+	int err;
+
+	is_group_manager = MLX5_CAP_GEN(dev, vport_group_manager);
+	tbsz = mlx5_get_gid_table_len(MLX5_CAP_GEN(dev, gid_table_size));
+	mlx5_core_dbg(dev, "vf_num %d, index %d, gid_table_size %d\n",
+		      vf_num, gid_index, tbsz);
+
+	if (gid_index > tbsz && gid_index != 0xffff)
+		return -EINVAL;
+
+	if (gid_index == 0xffff)
+		nout = tbsz;
+	else
+		nout = 1;
+
+	out_sz += nout * sizeof(*gid);
+
+	in = kzalloc(in_sz, GFP_KERNEL);
+	out = kzalloc(out_sz, GFP_KERNEL);
+	if (!in || !out) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	MLX5_SET(query_hca_vport_gid_in, in, opcode, MLX5_CMD_OP_QUERY_HCA_VPORT_GID);
+	if (other_vport) {
+		if (is_group_manager) {
+			MLX5_SET(query_hca_vport_gid_in, in, vport_number, vf_num);
+			MLX5_SET(query_hca_vport_gid_in, in, other_vport, 1);
+		} else {
+			err = -EPERM;
+			goto out;
+		}
+	}
+	MLX5_SET(query_hca_vport_gid_in, in, gid_index, gid_index);
+
+	if (MLX5_CAP_GEN(dev, num_ports) == 2)
+		MLX5_SET(query_hca_vport_gid_in, in, port_num, port_num);
+
+	err = mlx5_cmd_exec(dev, in, in_sz, out, out_sz);
+	if (err)
+		goto out;
+
+	err = mlx5_cmd_status_to_err_v2(out);
+	if (err)
+		goto out;
+
+	tmp = out + MLX5_ST_SZ_BYTES(query_hca_vport_gid_out);
+	gid->global.subnet_prefix = tmp->global.subnet_prefix;
+	gid->global.interface_id = tmp->global.interface_id;
+
+out:
+	kfree(in);
+	kfree(out);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_gid);
+
+int mlx5_query_hca_vport_pkey(struct mlx5_core_dev *dev, u8 other_vport,
+			      u8 port_num, u16 vf_num, u16 pkey_index,
+			      u16 *pkey)
+{
+	int in_sz = MLX5_ST_SZ_BYTES(query_hca_vport_pkey_in);
+	int out_sz = MLX5_ST_SZ_BYTES(query_hca_vport_pkey_out);
+	int is_group_manager;
+	void *out = NULL;
+	void *in = NULL;
+	void *pkarr;
+	int nout;
+	int tbsz;
+	int err;
+	int i;
+
+	is_group_manager = MLX5_CAP_GEN(dev, vport_group_manager);
+
+	tbsz = mlx5_to_sw_pkey_sz(MLX5_CAP_GEN(dev, pkey_table_size));
+	if (pkey_index > tbsz && pkey_index != 0xffff)
+		return -EINVAL;
+
+	if (pkey_index == 0xffff)
+		nout = tbsz;
+	else
+		nout = 1;
+
+	out_sz += nout * MLX5_ST_SZ_BYTES(pkey);
+
+	in = kzalloc(in_sz, GFP_KERNEL);
+	out = kzalloc(out_sz, GFP_KERNEL);
+	if (!in || !out) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	MLX5_SET(query_hca_vport_pkey_in, in, opcode, MLX5_CMD_OP_QUERY_HCA_VPORT_PKEY);
+	if (other_vport) {
+		if (is_group_manager) {
+			MLX5_SET(query_hca_vport_pkey_in, in, vport_number, vf_num);
+			MLX5_SET(query_hca_vport_pkey_in, in, other_vport, 1);
+		} else {
+			err = -EPERM;
+			goto out;
+		}
+	}
+	MLX5_SET(query_hca_vport_pkey_in, in, pkey_index, pkey_index);
+
+	if (MLX5_CAP_GEN(dev, num_ports) == 2)
+		MLX5_SET(query_hca_vport_pkey_in, in, port_num, port_num);
+
+	err = mlx5_cmd_exec(dev, in, in_sz, out, out_sz);
+	if (err)
+		goto out;
+
+	err = mlx5_cmd_status_to_err_v2(out);
+	if (err)
+		goto out;
+
+	pkarr = MLX5_ADDR_OF(query_hca_vport_pkey_out, out, pkey);
+	for (i = 0; i < nout; i++, pkey++, pkarr += MLX5_ST_SZ_BYTES(pkey))
+		*pkey = MLX5_GET_PR(pkey, pkarr, pkey);
+
+out:
+	kfree(in);
+	kfree(out);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_pkey);
+
+int mlx5_query_hca_vport_context(struct mlx5_core_dev *dev,
+				 u8 other_vport, u8 port_num,
+				 u16 vf_num,
+				 struct mlx5_hca_vport_context *rep)
+{
+	int out_sz = MLX5_ST_SZ_BYTES(query_hca_vport_context_out);
+	int in[MLX5_ST_SZ_DW(query_hca_vport_context_in)];
+	int is_group_manager;
+	void *out;
+	void *ctx;
+	int err;
+
+	is_group_manager = MLX5_CAP_GEN(dev, vport_group_manager);
+
+	memset(in, 0, sizeof(in));
+	out = kzalloc(out_sz, GFP_KERNEL);
+	if (!out)
+		return -ENOMEM;
+
+	MLX5_SET(query_hca_vport_context_in, in, opcode, MLX5_CMD_OP_QUERY_HCA_VPORT_CONTEXT);
+
+	if (other_vport) {
+		if (is_group_manager) {
+			MLX5_SET(query_hca_vport_context_in, in, other_vport, 1);
+			MLX5_SET(query_hca_vport_context_in, in, vport_number, vf_num);
+		} else {
+			err = -EPERM;
+			goto ex;
+		}
+	}
+
+	if (MLX5_CAP_GEN(dev, num_ports) == 2)
+		MLX5_SET(query_hca_vport_context_in, in, port_num, port_num);
+
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out,  out_sz);
+	if (err)
+		goto ex;
+	err = mlx5_cmd_status_to_err_v2(out);
+	if (err)
+		goto ex;
+
+	ctx = MLX5_ADDR_OF(query_hca_vport_context_out, out, hca_vport_context);
+	rep->field_select = MLX5_GET_PR(hca_vport_context, ctx, field_select);
+	rep->sm_virt_aware = MLX5_GET_PR(hca_vport_context, ctx, sm_virt_aware);
+	rep->has_smi = MLX5_GET_PR(hca_vport_context, ctx, has_smi);
+	rep->has_raw = MLX5_GET_PR(hca_vport_context, ctx, has_raw);
+	rep->policy = MLX5_GET_PR(hca_vport_context, ctx, vport_state_policy);
+	rep->phys_state = MLX5_GET_PR(hca_vport_context, ctx,
+				      port_physical_state);
+	rep->vport_state = MLX5_GET_PR(hca_vport_context, ctx, vport_state);
+	rep->port_physical_state = MLX5_GET_PR(hca_vport_context, ctx,
+					       port_physical_state);
+	rep->port_guid = MLX5_GET64_PR(hca_vport_context, ctx, port_guid);
+	rep->node_guid = MLX5_GET64_PR(hca_vport_context, ctx, node_guid);
+	rep->cap_mask1 = MLX5_GET_PR(hca_vport_context, ctx, cap_mask1);
+	rep->cap_mask1_perm = MLX5_GET_PR(hca_vport_context, ctx,
+					  cap_mask1_field_select);
+	rep->cap_mask2 = MLX5_GET_PR(hca_vport_context, ctx, cap_mask2);
+	rep->cap_mask2_perm = MLX5_GET_PR(hca_vport_context, ctx,
+					  cap_mask2_field_select);
+	rep->lid = MLX5_GET_PR(hca_vport_context, ctx, lid);
+	rep->init_type_reply = MLX5_GET_PR(hca_vport_context, ctx,
+					   init_type_reply);
+	rep->lmc = MLX5_GET_PR(hca_vport_context, ctx, lmc);
+	rep->subnet_timeout = MLX5_GET_PR(hca_vport_context, ctx,
+					  subnet_timeout);
+	rep->sm_lid = MLX5_GET_PR(hca_vport_context, ctx, sm_lid);
+	rep->sm_sl = MLX5_GET_PR(hca_vport_context, ctx, sm_sl);
+	rep->qkey_violation_counter = MLX5_GET_PR(hca_vport_context, ctx,
+						  qkey_violation_counter);
+	rep->pkey_violation_counter = MLX5_GET_PR(hca_vport_context, ctx,
+						  pkey_violation_counter);
+	rep->grh_required = MLX5_GET_PR(hca_vport_context, ctx, grh_required);
+	rep->sys_image_guid = MLX5_GET64_PR(hca_vport_context, ctx,
+					    system_image_guid);
+
+ex:
+	kfree(out);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_context);
+
+int mlx5_query_hca_vport_system_image_guid(struct mlx5_core_dev *dev,
+					   __be64 *sys_image_guid)
+{
+	struct mlx5_hca_vport_context *rep;
+	int err;
+
+	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
+	if (!rep)
+		return -ENOMEM;
+
+	err = mlx5_query_hca_vport_context(dev, 0, 1, 0, rep);
+	if (!err)
+		*sys_image_guid = rep->sys_image_guid;
+
+	kfree(rep);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_system_image_guid);
+
+int mlx5_query_hca_vport_node_guid(struct mlx5_core_dev *dev,
+				   u64 *node_guid)
+{
+	struct mlx5_hca_vport_context *rep;
+	int err;
+
+	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
+	if (!rep)
+		return -ENOMEM;
+
+	err = mlx5_query_hca_vport_context(dev, 0, 1, 0, rep);
+	if (!err)
+		*node_guid = rep->node_guid;
+
+	kfree(rep);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_hca_vport_node_guid);
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index b288c53..b2c4350 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -99,6 +99,12 @@ __mlx5_mask(typ, fld))
 
 #define MLX5_GET64(typ, p, fld) be64_to_cpu(*((__be64 *)(p) + __mlx5_64_off(typ, fld)))
 
+#define MLX5_GET64_PR(typ, p, fld) ({ \
+	u64 ___t = MLX5_GET64(typ, p, fld); \
+	pr_debug(#fld " = 0x%llx\n", ___t); \
+	___t; \
+})
+
 enum {
 	MLX5_MAX_COMMANDS		= 32,
 	MLX5_CMD_DATA_BLOCK_SIZE	= 512,
@@ -1172,4 +1178,11 @@ enum {
 	MLX5_CMD_STAT_BAD_SIZE_OUTS_CQES_ERR	= 0x40,
 };
 
+static inline u16 mlx5_to_sw_pkey_sz(int pkey_sz)
+{
+	if (pkey_sz > MLX5_MAX_LOG_PKEY_TABLE)
+		return 0;
+	return MLX5_MIN_PKEY_TABLE_SIZE << pkey_sz;
+}
+
 #endif /* MLX5_DEVICE_H */
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ba9f212..8ab8b8a 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -553,6 +553,41 @@ struct mlx5_pas {
 	u8	log_sz;
 };
 
+enum port_state_policy {
+	MLX5_AAA_000
+};
+
+enum phy_port_state {
+	MLX5_AAA_111
+};
+
+struct mlx5_hca_vport_context {
+	u32			field_select;
+	bool			sm_virt_aware;
+	bool			has_smi;
+	bool			has_raw;
+	enum port_state_policy	policy;
+	enum phy_port_state	phys_state;
+	enum ib_port_state	vport_state;
+	u8			port_physical_state;
+	u64			sys_image_guid;
+	u64			port_guid;
+	u64			node_guid;
+	u32			cap_mask1;
+	u32			cap_mask1_perm;
+	u32			cap_mask2;
+	u32			cap_mask2_perm;
+	u16			lid;
+	u8			init_type_reply; /* bitmask: see ib spec 14.2.5.6 InitTypeReply */
+	u8			lmc;
+	u8			subnet_timeout;
+	u16			sm_lid;
+	u8			sm_sl;
+	u16			qkey_violation_counter;
+	u16			pkey_violation_counter;
+	bool			grh_required;
+};
+
 static inline void *mlx5_buf_offset(struct mlx5_buf *buf, int offset)
 {
 		return buf->direct.buf + offset;
@@ -792,4 +827,14 @@ struct mlx5_profile {
 	} mr_cache[MAX_MR_CACHE_ENTRIES];
 };
 
+static inline int mlx5_get_gid_table_len(u16 param)
+{
+	if (param > 4) {
+		pr_warn("gid table length is zero\n");
+		return 0;
+	}
+
+	return 8 * (1 << param);
+}
+
 #endif /* MLX5_DRIVER_H */
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index dbe2b32..f06d054 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -2221,12 +2221,15 @@ struct mlx5_ifc_hca_vport_context_bits {
 	u8         has_smi[0x1];
 	u8         has_raw[0x1];
 	u8         grh_required[0x1];
-	u8         reserved_1[0x10];
-	u8         port_state_policy[0x4];
-	u8         phy_port_state[0x4];
+	u8         reserved_1[0xc];
+	u8         port_physical_state[0x4];
+	u8         vport_state_policy[0x4];
+	u8         port_state[0x4];
 	u8         vport_state[0x4];
 
-	u8         reserved_2[0x60];
+	u8         reserved_2[0x20];
+
+	u8         system_image_guid[0x40];
 
 	u8         port_guid[0x40];
 
@@ -3490,7 +3493,8 @@ struct mlx5_ifc_query_hca_vport_pkey_in_bits {
 	u8         op_mod[0x10];
 
 	u8         other_vport[0x1];
-	u8         reserved_2[0xf];
+	u8         reserved_2[0xb];
+	u8         port_num[0x4];
 	u8         vport_number[0x10];
 
 	u8         reserved_3[0x10];
@@ -3519,7 +3523,8 @@ struct mlx5_ifc_query_hca_vport_gid_in_bits {
 	u8         op_mod[0x10];
 
 	u8         other_vport[0x1];
-	u8         reserved_2[0xf];
+	u8         reserved_2[0xb];
+	u8         port_num[0x4];
 	u8         vport_number[0x10];
 
 	u8         reserved_3[0x10];
@@ -3545,7 +3550,8 @@ struct mlx5_ifc_query_hca_vport_context_in_bits {
 	u8         op_mod[0x10];
 
 	u8         other_vport[0x1];
-	u8         reserved_2[0xf];
+	u8         reserved_2[0xb];
+	u8         port_num[0x4];
 	u8         vport_number[0x10];
 
 	u8         reserved_3[0x20];
@@ -4243,7 +4249,8 @@ struct mlx5_ifc_modify_hca_vport_context_in_bits {
 	u8         op_mod[0x10];
 
 	u8         other_vport[0x1];
-	u8         reserved_2[0xf];
+	u8         reserved_2[0xb];
+	u8         port_num[0x4];
 	u8         vport_number[0x10];
 
 	u8         reserved_3[0x20];
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 99d0e9f..67882a8 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -37,5 +37,19 @@
 
 u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod);
 void mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr);
+int mlx5_query_hca_vport_gid(struct mlx5_core_dev *dev, u8 other_vport,
+			     u8 port_num, u16  vf_num, u16 gid_index,
+			     union ib_gid *gid);
+int mlx5_query_hca_vport_pkey(struct mlx5_core_dev *dev, u8 other_vport,
+			      u8 port_num, u16 vf_num, u16 pkey_index,
+			      u16 *pkey);
+int mlx5_query_hca_vport_context(struct mlx5_core_dev *dev,
+				 u8 other_vport, u8 port_num,
+				 u16 vf_num,
+				 struct mlx5_hca_vport_context *rep);
+int mlx5_query_hca_vport_system_image_guid(struct mlx5_core_dev *dev,
+					   __be64 *sys_image_guid);
+int mlx5_query_hca_vport_node_guid(struct mlx5_core_dev *dev,
+				   u64 *node_guid);
 
 #endif /* __MLX5_VPORT_H__ */
-- 
1.7.1
