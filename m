From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx5_core: Add transport domain alloc/dealloc support
Date: Thu, 11 Jun 2015 14:47:32 +0300
Message-ID: <1434023253-24362-7-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47304 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752991AbbFKLsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:48:06 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Each transport object, namely TIR and TIS, must have a transport domain
number (TDN) identifier.

The driver wrongly assumed that it is OK to use TDN=0 without explicit
TDN allocation from the device.

The TDN will also be used for isolating different processes once user
mode Ethernet will be supported.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/transobj.c |   35 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/transobj.h |    2 +
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
index 7a12028..8d98b03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.c
@@ -34,6 +34,41 @@
 #include "mlx5_core.h"
 #include "transobj.h"
 
+int mlx5_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn)
+{
+	u32 in[MLX5_ST_SZ_DW(alloc_transport_domain_in)];
+	u32 out[MLX5_ST_SZ_DW(alloc_transport_domain_out)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(alloc_transport_domain_in, in, opcode,
+		 MLX5_CMD_OP_ALLOC_TRANSPORT_DOMAIN);
+
+	err = mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+	if (!err)
+		*tdn = MLX5_GET(alloc_transport_domain_out, out,
+				transport_domain);
+
+	return err;
+}
+
+void mlx5_dealloc_transport_domain(struct mlx5_core_dev *dev, u32 tdn)
+{
+	u32 in[MLX5_ST_SZ_DW(dealloc_transport_domain_in)];
+	u32 out[MLX5_ST_SZ_DW(dealloc_transport_domain_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(dealloc_transport_domain_in, in, opcode,
+		 MLX5_CMD_OP_DEALLOC_TRANSPORT_DOMAIN);
+	MLX5_SET(dealloc_transport_domain_in, in, transport_domain, tdn);
+
+	mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+}
+
 int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen, u32 *rqn)
 {
 	u32 out[MLX5_ST_SZ_DW(create_rq_out)];
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
index 90322c1..f9ef244 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/transobj.h
@@ -33,6 +33,8 @@
 #ifndef __TRANSOBJ_H__
 #define __TRANSOBJ_H__
 
+int mlx5_alloc_transport_domain(struct mlx5_core_dev *dev, u32 *tdn);
+void mlx5_dealloc_transport_domain(struct mlx5_core_dev *dev, u32 tdn);
 int mlx5_core_create_rq(struct mlx5_core_dev *dev, u32 *in, int inlen,
 			u32 *rqn);
 int mlx5_core_modify_rq(struct mlx5_core_dev *dev, u32 rqn, u32 *in, int inlen);
-- 
1.7.1
