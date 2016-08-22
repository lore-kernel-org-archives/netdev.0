From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 02/17] net/mlx5: Access register and MAD IFC commands via mlx5 ifc
Date: Mon, 22 Aug 2016 19:50:59 +0300
Message-ID: <1471884674-22709-3-git-send-email-saeedm@mellanox.com>
References: <1471884674-22709-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60230 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755215AbcHVQvc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 12:51:32 -0400
In-Reply-To: <1471884674-22709-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old representation of manually created ACCESS_REG/MAD_IFC
commands layout and use mlx5_ifc canonical structures and defines.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/mad.c  | 42 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/port.c | 52 +++++++++++++-------------
 include/linux/mlx5/device.h                    | 29 --------------
 3 files changed, 45 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mad.c b/drivers/net/ethernet/mellanox/mlx5/core/mad.c
index 1368dac..13e6afd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mad.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mad.c
@@ -39,36 +39,34 @@
 int mlx5_core_mad_ifc(struct mlx5_core_dev *dev, const void *inb, void *outb,
 		      u16 opmod, u8 port)
 {
-	struct mlx5_mad_ifc_mbox_in *in = NULL;
-	struct mlx5_mad_ifc_mbox_out *out = NULL;
-	int err;
+	int outlen = MLX5_ST_SZ_BYTES(mad_ifc_out);
+	int inlen = MLX5_ST_SZ_BYTES(mad_ifc_in);
+	int err = -ENOMEM;
+	void *data;
+	void *resp;
+	u32 *out;
+	u32 *in;
 
-	in = kzalloc(sizeof(*in), GFP_KERNEL);
-	if (!in)
-		return -ENOMEM;
-
-	out = kzalloc(sizeof(*out), GFP_KERNEL);
-	if (!out) {
-		err = -ENOMEM;
+	in = kzalloc(inlen, GFP_KERNEL);
+	out = kzalloc(outlen, GFP_KERNEL);
+	if (!in || !out)
 		goto out;
-	}
 
-	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_MAD_IFC);
-	in->hdr.opmod = cpu_to_be16(opmod);
-	in->port = port;
+	MLX5_SET(mad_ifc_in, in, opcode, MLX5_CMD_OP_MAD_IFC);
+	MLX5_SET(mad_ifc_in, in, op_mod, opmod);
+	MLX5_SET(mad_ifc_in, in, port, port);
 
-	memcpy(in->data, inb, sizeof(in->data));
+	data = MLX5_ADDR_OF(mad_ifc_in, in, mad);
+	memcpy(data, inb, MLX5_FLD_SZ_BYTES(mad_ifc_in, mad));
 
-	err = mlx5_cmd_exec(dev, in, sizeof(*in), out, sizeof(*out));
+	err = mlx5_cmd_exec(dev, in, inlen, out, outlen);
+	err = err ? : mlx5_cmd_status_to_err_v2(out);
 	if (err)
 		goto out;
 
-	if (out->hdr.status) {
-		err = mlx5_cmd_status_to_err(&out->hdr);
-		goto out;
-	}
-
-	memcpy(outb, out->data, sizeof(out->data));
+	resp = MLX5_ADDR_OF(mad_ifc_out, out, response_mad_packet);
+	memcpy(outb, resp,
+	       MLX5_FLD_SZ_BYTES(mad_ifc_out, response_mad_packet));
 
 out:
 	kfree(out);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 752c081..e8324c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -38,45 +38,43 @@
 
 int mlx5_core_access_reg(struct mlx5_core_dev *dev, void *data_in,
 			 int size_in, void *data_out, int size_out,
-			 u16 reg_num, int arg, int write)
+			 u16 reg_id, int arg, int write)
 {
-	struct mlx5_access_reg_mbox_in *in = NULL;
-	struct mlx5_access_reg_mbox_out *out = NULL;
+	int outlen = MLX5_ST_SZ_BYTES(access_register_out) + size_out;
+	int inlen = MLX5_ST_SZ_BYTES(access_register_in) + size_in;
 	int err = -ENOMEM;
+	u32 *out = NULL;
+	u32 *in = NULL;
+	void *data;
 
-	in = mlx5_vzalloc(sizeof(*in) + size_in);
-	if (!in)
-		return -ENOMEM;
-
-	out = mlx5_vzalloc(sizeof(*out) + size_out);
-	if (!out)
-		goto ex1;
-
-	memcpy(in->data, data_in, size_in);
-	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ACCESS_REG);
-	in->hdr.opmod = cpu_to_be16(!write);
-	in->arg = cpu_to_be32(arg);
-	in->register_id = cpu_to_be16(reg_num);
-	err = mlx5_cmd_exec(dev, in, sizeof(*in) + size_in, out,
-			    sizeof(*out) + size_out);
-	if (err)
-		goto ex2;
+	in = mlx5_vzalloc(inlen);
+	out = mlx5_vzalloc(outlen);
+	if (!in || !out)
+		goto out;
 
-	if (out->hdr.status)
-		err = mlx5_cmd_status_to_err(&out->hdr);
+	data = MLX5_ADDR_OF(access_register_in, in, register_data);
+	memcpy(data, data_in, size_in);
 
-	if (!err)
-		memcpy(data_out, out->data, size_out);
+	MLX5_SET(access_register_in, in, opcode, MLX5_CMD_OP_ACCESS_REG);
+	MLX5_SET(access_register_in, in, op_mod, !write);
+	MLX5_SET(access_register_in, in, argument, arg);
+	MLX5_SET(access_register_in, in, register_id, reg_id);
+
+	err = mlx5_cmd_exec(dev, in, inlen, out, outlen);
+	err = err ? : mlx5_cmd_status_to_err_v2(out);
+	if (err)
+		goto out;
+
+	data = MLX5_ADDR_OF(access_register_out, out, register_data);
+	memcpy(data_out, data, size_out);
 
-ex2:
+out:
 	kvfree(out);
-ex1:
 	kvfree(in);
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx5_core_access_reg);
 
-
 struct mlx5_reg_pcap {
 	u8			rsvd0;
 	u8			port_num;
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 6c343c0..9570c49 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1165,35 +1165,6 @@ struct mlx5_dump_mkey_mbox_out {
 	__be32			mkey;
 };
 
-struct mlx5_mad_ifc_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	__be16			remote_lid;
-	u8			rsvd0;
-	u8			port;
-	u8			rsvd1[4];
-	u8			data[256];
-};
-
-struct mlx5_mad_ifc_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-	u8			data[256];
-};
-
-struct mlx5_access_reg_mbox_in {
-	struct mlx5_inbox_hdr		hdr;
-	u8				rsvd0[2];
-	__be16				register_id;
-	__be32				arg;
-	__be32				data[0];
-};
-
-struct mlx5_access_reg_mbox_out {
-	struct mlx5_outbox_hdr		hdr;
-	u8				rsvd[8];
-	__be32				data[0];
-};
-
 #define MLX5_ATTR_EXTENDED_PORT_INFO	cpu_to_be16(0xff90)
 
 enum {
-- 
2.7.4
