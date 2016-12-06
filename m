From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 3/6] net/mlx5: Fix query ISSI flow
Date: Tue,  6 Dec 2016 17:32:45 +0200
Message-ID: <1481038368-29677-4-git-send-email-saeedm@mellanox.com>
References: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55471 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752911AbcLFPdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:33:40 -0500
In-Reply-To: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

In old FWs query ISSI command is not supported and for some of those FWs
it might fail with status other than "MLX5_CMD_STAT_BAD_OP_ERR".

In such case instead of failing the driver load, we will treat any FW
status other than 0 for Query ISSI FW command as ISSI not supported and
assume ISSI=0 (most basic driver/FW interface).

In case of driver syndrom (query ISSI failure by driver) we will fail
driver load.

Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4
Ethernet functionality')
Signed-off-by: Kamal Heib <kamalh@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c       |  5 -----
 drivers/net/ethernet/mellanox/mlx5/core/main.c      | 15 +++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h |  5 +++++
 3 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 1e639f8..bfe410e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -268,11 +268,6 @@ static void dump_buf(void *buf, int size, int data_only, int offset)
 		pr_debug("\n");
 }
 
-enum {
-	MLX5_DRIVER_STATUS_ABORTED = 0xfe,
-	MLX5_DRIVER_SYND = 0xbadd00de,
-};
-
 static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 				       u32 *synd, u8 *status)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 22eb3be..ada24e1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -732,13 +732,15 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 		u8 status;
 
 		mlx5_cmd_mbox_status(query_out, &status, &syndrome);
-		if (status == MLX5_CMD_STAT_BAD_OP_ERR) {
-			pr_debug("Only ISSI 0 is supported\n");
-			return 0;
+		if (!status || syndrome == MLX5_DRIVER_SYND) {
+			mlx5_core_err(dev, "Failed to query ISSI err(%d) status(%d) synd(%d)\n",
+				      err, status, syndrome);
+			return err;
 		}
 
-		pr_err("failed to query ISSI err(%d)\n", err);
-		return err;
+		mlx5_core_warn(dev, "Query ISSI is not supported by FW, ISSI is 0\n");
+		dev->issi = 0;
+		return 0;
 	}
 
 	sup_issi = MLX5_GET(query_issi_out, query_out, supported_issi_dw0);
@@ -752,7 +754,8 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 		err = mlx5_cmd_exec(dev, set_in, sizeof(set_in),
 				    set_out, sizeof(set_out));
 		if (err) {
-			pr_err("failed to set ISSI=1 err(%d)\n", err);
+			mlx5_core_err(dev, "Failed to set ISSI to 1 err(%d)\n",
+				      err);
 			return err;
 		}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 2ce0346..63b9a0d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -75,6 +75,11 @@ enum {
 	MLX5_CMD_TIME, /* print command execution time */
 };
 
+enum {
+	MLX5_DRIVER_STATUS_ABORTED = 0xfe,
+	MLX5_DRIVER_SYND = 0xbadd00de,
+};
+
 int mlx5_query_hca_caps(struct mlx5_core_dev *dev);
 int mlx5_query_board_id(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
-- 
2.7.4
