From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/6] net/mlx5: Wait for FW readiness before initializing command interface
Date: Thu, 15 Jun 2017 23:55:25 +0300
Message-ID: <20170615205530.26674-2-saeedm@mellanox.com>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52484 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751598AbdFOU4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:33 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Before attempting to initialize the command interface we must wait till
the fw_initializing bit is clear.

If we fail to meet this condition the hardware will drop our
configuration, specifically the descriptors page address.  This scenario
can happen when the firmware is still executing an FLR flow and did not
finish yet so the driver needs to wait for that to finish.

Fixes: e3297246c2c8 ('net/mlx5_core: Wait for FW readiness on startup')
Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 4f577a5abf88..13be264587f1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -175,8 +175,9 @@ static struct mlx5_profile profile[] = {
 	},
 };
 
-#define FW_INIT_TIMEOUT_MILI	2000
-#define FW_INIT_WAIT_MS		2
+#define FW_INIT_TIMEOUT_MILI		2000
+#define FW_INIT_WAIT_MS			2
+#define FW_PRE_INIT_TIMEOUT_MILI	10000
 
 static int wait_fw_init(struct mlx5_core_dev *dev, u32 max_wait_mili)
 {
@@ -1013,6 +1014,15 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	 */
 	dev->state = MLX5_DEVICE_STATE_UP;
 
+	/* wait for firmware to accept initialization segments configurations
+	 */
+	err = wait_fw_init(dev, FW_PRE_INIT_TIMEOUT_MILI);
+	if (err) {
+		dev_err(&dev->pdev->dev, "Firmware over %d MS in pre-initializing state, aborting\n",
+			FW_PRE_INIT_TIMEOUT_MILI);
+		goto out;
+	}
+
 	err = mlx5_cmd_init(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed initializing command interface, aborting\n");
-- 
2.11.0
