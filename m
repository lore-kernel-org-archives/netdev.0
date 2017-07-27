From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 03/14] net/mlx5: Fix command completion after timeout access invalid structure
Date: Thu, 27 Jul 2017 13:25:21 +0300
Message-ID: <20170727102532.2317-4-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Moshe Shemesh <moshe@mellanox.com>,
        kernel-team@fb.com, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44935 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750981AbdG0K1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:13 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

Completion on timeout should not free the driver command entry structure
as it will need to access it again once real completion event from FW
will occur.

Fixes: 73dd3a4839c1 ('net/mlx5: Avoid using pending command interface slots')
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Cc: kernel-team@fb.com
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index f5a2c605749f..25fd32fcdf79 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -967,7 +967,7 @@ static int mlx5_cmd_invoke(struct mlx5_core_dev *dev, struct mlx5_cmd_msg *in,
 
 	err = wait_func(dev, ent);
 	if (err == -ETIMEDOUT)
-		goto out_free;
+		goto out;
 
 	ds = ent->ts2 - ent->ts1;
 	op = MLX5_GET(mbox_in, in->first.data, opcode);
@@ -1430,6 +1430,7 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec, bool forced)
 					mlx5_core_err(dev, "Command completion arrived after timeout (entry idx = %d).\n",
 						      ent->idx);
 					free_ent(cmd, ent->idx);
+					free_cmd(ent);
 				}
 				continue;
 			}
@@ -1488,7 +1489,8 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec, bool forced)
 				free_msg(dev, ent->in);
 
 				err = err ? err : ent->status;
-				free_cmd(ent);
+				if (!forced)
+					free_cmd(ent);
 				callback(err, context);
 			} else {
 				complete(&ent->done);
-- 
2.13.0
