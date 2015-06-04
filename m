From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 07/13] net/mlx5_core: Get vendor-id using the query adapter command
Date: Thu,  4 Jun 2015 19:30:42 +0300
Message-ID: <1433435448-4937-8-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47771 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752789AbbFDQbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:40 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Add two wrapper functions to the query adapter command:

1. mlx5_query_board_id -- replaces the old mlx5_cmd_query_adapter.

2. mlx5_core_query_vendor_id -- retrieves the vendor_id from the
   query_adapter command.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   59 +++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |    4 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    2 +-
 include/linux/mlx5/driver.h                        |    1 +
 include/linux/mlx5/mlx5_ifc.h                      |    7 ++-
 5 files changed, 53 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 801ccad..ba87442 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -35,34 +35,63 @@
 #include <linux/module.h>
 #include "mlx5_core.h"
 
-int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev)
+int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev, u32 *out, int outlen)
 {
-	struct mlx5_cmd_query_adapter_mbox_out *out;
-	struct mlx5_cmd_query_adapter_mbox_in in;
+	u32 in[MLX5_ST_SZ_DW(query_adapter_in)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_adapter_in, in, opcode, MLX5_CMD_OP_QUERY_ADAPTER);
+
+	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, outlen);
+}
+
+int mlx5_query_board_id(struct mlx5_core_dev *dev)
+{
+	u32 *out;
+	int outlen = MLX5_ST_SZ_BYTES(query_adapter_out);
 	int err;
 
-	out = kzalloc(sizeof(*out), GFP_KERNEL);
+	out = kzalloc(outlen, GFP_KERNEL);
 	if (!out)
 		return -ENOMEM;
 
-	memset(&in, 0, sizeof(in));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_QUERY_ADAPTER);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), out, sizeof(*out));
+	err = mlx5_cmd_query_adapter(dev, out, outlen);
 	if (err)
-		goto out_out;
+		goto out;
 
-	if (out->hdr.status) {
-		err = mlx5_cmd_status_to_err(&out->hdr);
-		goto out_out;
-	}
+	memcpy(dev->board_id,
+	       MLX5_ADDR_OF(query_adapter_out, out,
+			    query_adapter_struct.vsd_contd_psid),
+	       MLX5_FLD_SZ_BYTES(query_adapter_out,
+				 query_adapter_struct.vsd_contd_psid));
 
-	memcpy(dev->board_id, out->vsd_psid, sizeof(out->vsd_psid));
-
-out_out:
+out:
 	kfree(out);
+	return err;
+}
+
+int mlx5_core_query_vendor_id(struct mlx5_core_dev *mdev, u32 *vendor_id)
+{
+	u32 *out;
+	int outlen = MLX5_ST_SZ_BYTES(query_adapter_out);
+	int err;
+
+	out = kzalloc(outlen, GFP_KERNEL);
+	if (!out)
+		return -ENOMEM;
 
+	err = mlx5_cmd_query_adapter(mdev, out, outlen);
+	if (err)
+		goto out;
+
+	*vendor_id = MLX5_GET(query_adapter_out, out,
+			      query_adapter_struct.ieee_vendor_id);
+out:
+	kfree(out);
 	return err;
 }
+EXPORT_SYMBOL(mlx5_core_query_vendor_id);
 
 int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 5835412..afad529 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -768,9 +768,9 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 		goto err_stop_poll;
 	}
 
-	err = mlx5_cmd_query_adapter(dev);
+	err = mlx5_query_board_id(dev);
 	if (err) {
-		dev_err(&pdev->dev, "query adapter failed\n");
+		dev_err(&pdev->dev, "query board id failed\n");
 		goto err_stop_poll;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 6983c10..fc88eca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -78,7 +78,7 @@ static inline int mlx5_cmd_exec_check_status(struct mlx5_core_dev *dev, u32 *in,
 }
 
 int mlx5_query_hca_caps(struct mlx5_core_dev *dev);
-int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev);
+int mlx5_query_board_id(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 8ab8b8a..b90fb93 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -817,6 +817,7 @@ struct mlx5_interface {
 void *mlx5_get_protocol_dev(struct mlx5_core_dev *mdev, int protocol);
 int mlx5_register_interface(struct mlx5_interface *intf);
 void mlx5_unregister_interface(struct mlx5_interface *intf);
+int mlx5_core_query_vendor_id(struct mlx5_core_dev *mdev, u32 *vendor_id);
 
 struct mlx5_profile {
 	u64	mask;
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index f06d054..6d2f6fe 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -2470,9 +2470,12 @@ union mlx5_ifc_cong_control_roce_ecn_auto_bits {
 };
 
 struct mlx5_ifc_query_adapter_param_block_bits {
-	u8         reserved_0[0xe0];
+	u8         reserved_0[0xc0];
 
-	u8         reserved_1[0x10];
+	u8         reserved_1[0x8];
+	u8         ieee_vendor_id[0x18];
+
+	u8         reserved_2[0x10];
 	u8         vsd_vendor_id[0x10];
 
 	u8         vsd[208][0x8];
-- 
1.7.1
