From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V3 06/15] net/mlx5: EQ commands via mlx5 ifc
Date: Tue, 23 Aug 2016 11:49:08 +0300
Message-ID: <1471942157-9131-7-git-send-email-saeedm@mellanox.com>
References: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37697 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757508AbcHWI45 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 04:56:57 -0400
In-Reply-To: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old representation of manually created EQ commands layout,
and use mlx5_ifc canonical structures and defines.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c | 18 +++---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c      | 78 ++++++++++-------------
 include/linux/mlx5/device.h                       | 74 ---------------------
 include/linux/mlx5/driver.h                       |  2 +-
 4 files changed, 44 insertions(+), 128 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
index 5210d92..58e5518 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
@@ -358,32 +358,32 @@ out:
 static u64 eq_read_field(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
 			 int index)
 {
-	struct mlx5_query_eq_mbox_out *out;
-	struct mlx5_eq_context *ctx;
+	int outlen = MLX5_ST_SZ_BYTES(query_eq_out);
 	u64 param = 0;
+	void *ctx;
+	u32 *out;
 	int err;
 
-	out = kzalloc(sizeof(*out), GFP_KERNEL);
+	out = kzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return param;
 
-	ctx = &out->ctx;
-
-	err = mlx5_core_eq_query(dev, eq, out, sizeof(*out));
+	err = mlx5_core_eq_query(dev, eq, out, outlen);
 	if (err) {
 		mlx5_core_warn(dev, "failed to query eq\n");
 		goto out;
 	}
+	ctx = MLX5_ADDR_OF(query_eq_out, out, eq_context_entry);
 
 	switch (index) {
 	case EQ_NUM_EQES:
-		param = 1 << ((be32_to_cpu(ctx->log_sz_usr_page) >> 24) & 0x1f);
+		param = 1 << MLX5_GET(eqc, ctx, log_eq_size);
 		break;
 	case EQ_INTR:
-		param = ctx->intr;
+		param = MLX5_GET(eqc, ctx, intr);
 		break;
 	case EQ_LOG_PG_SZ:
-		param = (ctx->log_page_size & 0x1f) + 12;
+		param = MLX5_GET(eqc, ctx, log_page_size) + 12;
 		break;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 0e30602..7141197 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -86,23 +86,16 @@ struct cre_des_eq {
 
 static int mlx5_cmd_destroy_eq(struct mlx5_core_dev *dev, u8 eqn)
 {
-	struct mlx5_destroy_eq_mbox_in in;
-	struct mlx5_destroy_eq_mbox_out out;
+	u32 out[MLX5_ST_SZ_DW(destroy_eq_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(destroy_eq_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_EQ);
-	in.eqn = eqn;
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (!err)
-		goto ex;
+	MLX5_SET(destroy_eq_in, in, opcode, MLX5_CMD_OP_DESTROY_EQ);
+	MLX5_SET(destroy_eq_in, in, eq_number, eqn);
 
-	if (out.hdr.status)
-		err = mlx5_cmd_status_to_err(&out.hdr);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 
-ex:
-	return err;
 }
 
 static struct mlx5_eqe *get_eqe(struct mlx5_eq *eq, u32 entry)
@@ -351,11 +344,13 @@ static void init_eq_buf(struct mlx5_eq *eq)
 int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 		       int nent, u64 mask, const char *name, struct mlx5_uar *uar)
 {
+	u32 out[MLX5_ST_SZ_DW(create_eq_out)] = {0};
 	struct mlx5_priv *priv = &dev->priv;
-	struct mlx5_create_eq_mbox_in *in;
-	struct mlx5_create_eq_mbox_out out;
-	int err;
+	__be64 *pas;
+	void *eqc;
 	int inlen;
+	u32 *in;
+	int err;
 
 	eq->nent = roundup_pow_of_two(nent + MLX5_NUM_SPARE_EQE);
 	eq->cons_index = 0;
@@ -365,35 +360,37 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 
 	init_eq_buf(eq);
 
-	inlen = sizeof(*in) + sizeof(in->pas[0]) * eq->buf.npages;
+	inlen = MLX5_ST_SZ_BYTES(create_eq_in) +
+		MLX5_FLD_SZ_BYTES(create_eq_in, pas[0]) * eq->buf.npages;
+
 	in = mlx5_vzalloc(inlen);
 	if (!in) {
 		err = -ENOMEM;
 		goto err_buf;
 	}
-	memset(&out, 0, sizeof(out));
 
-	mlx5_fill_page_array(&eq->buf, in->pas);
+	pas = (__be64 *)MLX5_ADDR_OF(create_eq_in, in, pas);
+	mlx5_fill_page_array(&eq->buf, pas);
 
-	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_CREATE_EQ);
-	in->ctx.log_sz_usr_page = cpu_to_be32(ilog2(eq->nent) << 24 | uar->index);
-	in->ctx.intr = vecidx;
-	in->ctx.log_page_size = eq->buf.page_shift - MLX5_ADAPTER_PAGE_SHIFT;
-	in->events_mask = cpu_to_be64(mask);
+	MLX5_SET(create_eq_in, in, opcode, MLX5_CMD_OP_CREATE_EQ);
+	MLX5_SET64(create_eq_in, in, event_bitmask, mask);
 
-	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
-	if (err)
-		goto err_in;
+	eqc = MLX5_ADDR_OF(create_eq_in, in, eq_context_entry);
+	MLX5_SET(eqc, eqc, log_eq_size, ilog2(eq->nent));
+	MLX5_SET(eqc, eqc, uar_page, uar->index);
+	MLX5_SET(eqc, eqc, intr, vecidx);
+	MLX5_SET(eqc, eqc, log_page_size,
+		 eq->buf.page_shift - MLX5_ADAPTER_PAGE_SHIFT);
 
-	if (out.hdr.status) {
-		err = mlx5_cmd_status_to_err(&out.hdr);
+	err = mlx5_cmd_exec(dev, in, inlen, out, sizeof(out));
+	err = err ? : mlx5_cmd_status_to_err_v2(out);
+	if (err)
 		goto err_in;
-	}
 
 	snprintf(priv->irq_info[vecidx].name, MLX5_MAX_IRQ_NAME, "%s@pci:%s",
 		 name, pci_name(dev->pdev));
 
-	eq->eqn = out.eq_number;
+	eq->eqn = MLX5_GET(create_eq_out, out, eq_number);
 	eq->irqn = priv->msix_arr[vecidx].vector;
 	eq->dev = dev;
 	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
@@ -547,22 +544,15 @@ int mlx5_stop_eqs(struct mlx5_core_dev *dev)
 }
 
 int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
-		       struct mlx5_query_eq_mbox_out *out, int outlen)
+		       u32 *out, int outlen)
 {
-	struct mlx5_query_eq_mbox_in in;
+	u32 in[MLX5_ST_SZ_DW(query_eq_in)] = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(out, 0, outlen);
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_EQ);
-	in.eqn = eq->eqn;
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, outlen);
-	if (err)
-		return err;
-
-	if (out->hdr.status)
-		err = mlx5_cmd_status_to_err(&out->hdr);
+	MLX5_SET(query_eq_in, in, opcode, MLX5_CMD_OP_QUERY_EQ);
+	MLX5_SET(query_eq_in, in, eq_number, eq->eqn);
 
-	return err;
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, outlen);
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
 EXPORT_SYMBOL_GPL(mlx5_core_eq_query);
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 9570c49..c84e0ba 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -995,80 +995,6 @@ struct mlx5_disable_hca_mbox_out {
 	u8			rsvd[8];
 };
 
-struct mlx5_eq_context {
-	u8			status;
-	u8			ec_oi;
-	u8			st;
-	u8			rsvd2[7];
-	__be16			page_pffset;
-	__be32			log_sz_usr_page;
-	u8			rsvd3[7];
-	u8			intr;
-	u8			log_page_size;
-	u8			rsvd4[15];
-	__be32			consumer_counter;
-	__be32			produser_counter;
-	u8			rsvd5[16];
-};
-
-struct mlx5_create_eq_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd0[3];
-	u8			input_eqn;
-	u8			rsvd1[4];
-	struct mlx5_eq_context	ctx;
-	u8			rsvd2[8];
-	__be64			events_mask;
-	u8			rsvd3[176];
-	__be64			pas[0];
-};
-
-struct mlx5_create_eq_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd0[3];
-	u8			eq_number;
-	u8			rsvd1[4];
-};
-
-struct mlx5_destroy_eq_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd0[3];
-	u8			eqn;
-	u8			rsvd1[4];
-};
-
-struct mlx5_destroy_eq_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
-struct mlx5_map_eq_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	__be64			mask;
-	u8			mu;
-	u8			rsvd0[2];
-	u8			eqn;
-	u8			rsvd1[24];
-};
-
-struct mlx5_map_eq_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
-struct mlx5_query_eq_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd0[3];
-	u8			eqn;
-	u8			rsvd1[4];
-};
-
-struct mlx5_query_eq_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-	struct mlx5_eq_context	ctx;
-};
-
 enum {
 	MLX5_MKEY_STATUS_FREE = 1 << 6,
 };
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index ccea6fb..eed4b61 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -865,7 +865,7 @@ int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 int mlx5_debug_eq_add(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 void mlx5_debug_eq_remove(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
 int mlx5_core_eq_query(struct mlx5_core_dev *dev, struct mlx5_eq *eq,
-		       struct mlx5_query_eq_mbox_out *out, int outlen);
+		       u32 *out, int outlen);
 int mlx5_eq_debugfs_init(struct mlx5_core_dev *dev);
 void mlx5_eq_debugfs_cleanup(struct mlx5_core_dev *dev);
 int mlx5_cq_debugfs_init(struct mlx5_core_dev *dev);
-- 
2.7.4
