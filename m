From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH] mlx4_core: Fix fallback from MSI-X to INTx
Date: Fri, 22 May 2015 16:12:26 -0700
Message-ID: <1432336346-20290-1-git-send-email-bpoirier@suse.de>
Cc: Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amir Vadai <amirv@mellanox.com>, Ido Shamay <idos@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The test in mlx4_load_one() to remove MLX4_FLAG_MSI_X expects mlx4_NOP() to
fail with -EBUSY. It is also necessary to avoid the reset since the device
is not fully reinitialized before calling mlx4_start_hca() a second time.

Note that this will also affect mlx4_test_interrupts(), the only other user
of MLX4_CMD_NOP.

Fixes: f5aef5a ("net/mlx4_core: Activate reset flow upon fatal command cases")
Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 4f7dc04..529ef05 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -714,8 +714,13 @@ static int mlx4_cmd_wait(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 					 msecs_to_jiffies(timeout))) {
 		mlx4_warn(dev, "command 0x%x timed out (go bit not cleared)\n",
 			  op);
-		err = -EIO;
-		goto out_reset;
+		if (op == MLX4_CMD_NOP) {
+			err = -EBUSY;
+			goto out;
+		} else {
+			err = -EIO;
+			goto out_reset;
+		}
 	}
 
 	err = context->result;
-- 
2.3.5
