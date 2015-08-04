From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx5_core: Introduce access function to modify RSS/LRO params
Date: Tue,  4 Aug 2015 14:05:42 +0300
Message-ID: <1438686347-17370-4-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36453 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932776AbbHDLGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:22 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

To be used by the mlx5 Eth driver in following commit.

This is in preparation for netdev "light-weight" open/stop flow
change described in previous commit.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 12 ++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |  2 ++
 include/linux/mlx5/mlx5_ifc.h                      |  9 ++++++++-
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index c4f3f74..e6453f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -163,6 +163,18 @@ int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
 	return err;
 }
 
+int mlx5_core_modify_tir(struct mlx5_core_dev *dev, u32 tirn, u32 *in,
+			 int inlen)
+{
+	u32 out[MLX5_ST_SZ_DW(modify_tir_out)];
+
+	MLX5_SET(modify_tir_in, in, tirn, tirn);
+	MLX5_SET(modify_tir_in, in, opcode, MLX5_CMD_OP_MODIFY_TIR);
+
+	memset(out, 0, sizeof(out));
+	return mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+}
+
 void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_tir_out)];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
index 10bd75e..d436c2d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
@@ -45,6 +45,8 @@ int mlx5_core_modify_sq(struct mlx5_core_dev *dev, u32 sqn, u32 *in, int inlen);
 void mlx5_core_destroy_sq(struct mlx5_core_dev *dev, u32 sqn);
 int mlx5_core_create_tir(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *tirn);
+int mlx5_core_modify_tir(struct mlx5_core_dev *dev, u32 tirn, u32 *in,
+			 int inlen);
 void mlx5_core_destroy_tir(struct mlx5_core_dev *dev, u32 tirn);
 int mlx5_core_create_tis(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			 u32 *tisn);
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index c60a62b..469b7bd 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -4050,6 +4050,13 @@ struct mlx5_ifc_modify_tis_in_bits {
 	struct mlx5_ifc_tisc_bits ctx;
 };
 
+struct mlx5_ifc_modify_tir_bitmask_bits {
+	u8	   reserved[0x20];
+
+	u8         reserved1[0x1f];
+	u8         lro[0x1];
+};
+
 struct mlx5_ifc_modify_tir_out_bits {
 	u8         status[0x8];
 	u8         reserved_0[0x18];
@@ -4071,7 +4078,7 @@ struct mlx5_ifc_modify_tir_in_bits {
 
 	u8         reserved_3[0x20];
 
-	u8         modify_bitmask[0x40];
+	struct mlx5_ifc_modify_tir_bitmask_bits bitmask;
 
 	u8         reserved_4[0x40];
 
-- 
2.4.3.413.ga5fe668
