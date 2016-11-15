From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx5: Set driver version into firmware
Date: Tue, 15 Nov 2016 23:30:05 +0200
Message-ID: <1479245407-6884-7-git-send-email-saeedm@mellanox.com>
References: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54815 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753186AbcKOVae (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 16:30:34 -0500
In-Reply-To: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

If driver_version capability bit is enabled, set driver version
to firmware after the init HCA command, for display purposes.

Example of driver version: "Linux,mlx5_core,3.0-1"

Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 37 ++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index a3a0887..e9e5803 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -175,6 +175,41 @@ static int wait_fw_init(struct mlx5_core_dev *dev, u32 max_wait_mili)
 	return err;
 }
 
+static void mlx5_set_driver_version(struct mlx5_core_dev *dev)
+{
+	int driver_ver_sz = MLX5_FLD_SZ_BYTES(set_driver_version_in,
+					      driver_version);
+	u8 in[MLX5_ST_SZ_BYTES(set_driver_version_in)] = {0};
+	u8 out[MLX5_ST_SZ_BYTES(set_driver_version_out)] = {0};
+	int remaining_size = driver_ver_sz;
+	char *string;
+
+	if (!MLX5_CAP_GEN(dev, driver_version))
+		return;
+
+	string = MLX5_ADDR_OF(set_driver_version_in, in, driver_version);
+
+	strncpy(string, "Linux", remaining_size);
+
+	remaining_size = max_t(int, 0, driver_ver_sz - strlen(string));
+	strncat(string, ",", remaining_size);
+
+	remaining_size = max_t(int, 0, driver_ver_sz - strlen(string));
+	strncat(string, DRIVER_NAME, remaining_size);
+
+	remaining_size = max_t(int, 0, driver_ver_sz - strlen(string));
+	strncat(string, ",", remaining_size);
+
+	remaining_size = max_t(int, 0, driver_ver_sz - strlen(string));
+	strncat(string, DRIVER_VERSION, remaining_size);
+
+	/*Send the command*/
+	MLX5_SET(set_driver_version_in, in, opcode,
+		 MLX5_CMD_OP_SET_DRIVER_VERSION);
+
+	mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+
 static int set_dma_caps(struct pci_dev *pdev)
 {
 	int err;
@@ -1015,6 +1050,8 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto err_pagealloc_stop;
 	}
 
+	mlx5_set_driver_version(dev);
+
 	mlx5_start_health_poll(dev);
 
 	err = mlx5_query_hca_caps(dev);
-- 
2.7.4
