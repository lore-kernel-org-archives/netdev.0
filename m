From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5e: Introduce create/destroy RSS indir table access functions
Date: Wed, 29 Jul 2015 15:05:45 +0300
Message-ID: <1438171546-17021-8-git-send-email-amirv@mellanox.com>
References: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53876 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752300AbbG2MHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 08:07:00 -0400
In-Reply-To: <1438171546-17021-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Introduce access functions to create/destroy RSS indrection table
and use it in the Ethernet driver.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 19 ++------------
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c | 29 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |  4 +++
 3 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6581f58..8ddb2a0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1188,7 +1188,6 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 *in;
-	u32 out[MLX5_ST_SZ_DW(create_rqt_out)];
 	void *rqtc;
 	int inlen;
 	int err;
@@ -1216,12 +1215,7 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 		MLX5_SET(rqtc, rqtc, rq_num[i], priv->channel[ix]->rq.rqn);
 	}
 
-	MLX5_SET(create_rqt_in, in, opcode, MLX5_CMD_OP_CREATE_RQT);
-
-	memset(out, 0, sizeof(out));
-	err = mlx5_cmd_exec_check_status(mdev, in, inlen, out, sizeof(out));
-	if (!err)
-		priv->rqtn = MLX5_GET(create_rqt_out, out, rqtn);
+	err = mlx5_core_create_rqt(mdev, in, inlen, &priv->rqtn);
 
 	kvfree(in);
 
@@ -1230,16 +1224,7 @@ static int mlx5e_open_rqt(struct mlx5e_priv *priv)
 
 static void mlx5e_close_rqt(struct mlx5e_priv *priv)
 {
-	u32 in[MLX5_ST_SZ_DW(destroy_rqt_in)];
-	u32 out[MLX5_ST_SZ_DW(destroy_rqt_out)];
-
-	memset(in, 0, sizeof(in));
-
-	MLX5_SET(destroy_rqt_in, in, opcode, MLX5_CMD_OP_DESTROY_RQT);
-	MLX5_SET(destroy_rqt_in, in, rqtn, priv->rqtn);
-
-	mlx5_cmd_exec_check_status(priv->mdev, in, sizeof(in), out,
-				   sizeof(out));
+	mlx5_core_destroy_rqt(priv->mdev, priv->rqtn);
 }
 
 static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index 8d98b03..c4f3f74 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -358,3 +358,32 @@ int mlx5_core_arm_xsrq(struct mlx5_core_dev *dev, u32 xsrqn, u16 lwm)
 	return  mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
 					   sizeof(out));
 }
+
+int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			 u32 *rqtn)
+{
+	u32 out[MLX5_ST_SZ_DW(create_rqt_out)];
+	int err;
+
+	MLX5_SET(create_rqt_in, in, opcode, MLX5_CMD_OP_CREATE_RQT);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec_check_status(dev, in, inlen, out, sizeof(out));
+	if (!err)
+		*rqtn = MLX5_GET(create_rqt_out, out, rqtn);
+
+	return err;
+}
+
+void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_rqt_in)];
+	u32 out[MLX5_ST_SZ_DW(destroy_rqt_out)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(destroy_rqt_in, in, opcode, MLX5_CMD_OP_DESTROY_RQT);
+	MLX5_SET(destroy_rqt_in, in, rqtn, rqtn);
+
+	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
index f9ef244..10bd75e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
@@ -61,4 +61,8 @@ int mlx5_core_destroy_xsrq(struct mlx5_core_dev *dev, u32 rmpn);
 int mlx5_core_query_xsrq(struct mlx5_core_dev *dev, u32 rmpn, u32 *out);
 int mlx5_core_arm_xsrq(struct mlx5_core_dev *dev, u32 rmpn, u16 lwm);
 
+int mlx5_core_create_rqt(struct mlx5_core_dev *dev, u32 *in, int inlen,
+			 u32 *rqtn);
+void mlx5_core_destroy_rqt(struct mlx5_core_dev *dev, u32 rqtn);
+
 #endif /* __TRANSOBJ_H__ */
-- 
2.4.3.413.ga5fe668
