From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 4/6] net/mlx4_core: Return proper error code when __mlx4_add_one fails
Date: Thu, 17 Jan 2013 13:47:19 +0200
Message-ID: <1358423241-2452-5-git-send-email-amirv@mellanox.com>
References: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:46194 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755143Ab3AQLrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 06:47:35 -0500
In-Reply-To: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Returning 0 (success) when in fact we are aborting the load, leads to kernel
panic when unloading the module. Fix that by returning the actual error code.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index e1bafff..983fd3d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2169,7 +2169,8 @@ slave_start:
 			dev->num_slaves = MLX4_MAX_NUM_SLAVES;
 		else {
 			dev->num_slaves = 0;
-			if (mlx4_multi_func_init(dev)) {
+			err = mlx4_multi_func_init(dev);
+			if (err) {
 				mlx4_err(dev, "Failed to init slave mfunc"
 					 " interface, aborting.\n");
 				goto err_cmd;
@@ -2193,7 +2194,8 @@ slave_start:
 	/* In master functions, the communication channel must be initialized
 	 * after obtaining its address from fw */
 	if (mlx4_is_master(dev)) {
-		if (mlx4_multi_func_init(dev)) {
+		err = mlx4_multi_func_init(dev);
+		if (err) {
 			mlx4_err(dev, "Failed to init master mfunc"
 				 "interface, aborting.\n");
 			goto err_close;
@@ -2210,6 +2212,7 @@ slave_start:
 	mlx4_enable_msi_x(dev);
 	if ((mlx4_is_mfunc(dev)) &&
 	    !(dev->flags & MLX4_FLAG_MSI_X)) {
+		err = -ENOSYS;
 		mlx4_err(dev, "INTx is not supported in multi-function mode."
 			 " aborting.\n");
 		goto err_free_eq;
-- 
1.7.8.2
