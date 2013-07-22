From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] mlx5: use after free in mlx5_cmd_comp_handler()
Date: Mon, 22 Jul 2013 11:02:01 +0300
Message-ID: <20130722080201.GG14617@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We can't dereference "ent" after passing it to free_cmd().

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 205753a..4037406 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1113,7 +1113,13 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
 
 	for (i = 0; i < (1 << cmd->log_sz); i++) {
 		if (test_bit(i, &vector)) {
+			struct semaphore *sem;
+
 			ent = cmd->ent_arr[i];
+			if (ent->page_queue)
+				sem = &cmd->pages_sem;
+			else
+				sem = &cmd->sem;
 			ktime_get_ts(&ent->ts2);
 			memcpy(ent->out->first.data, ent->lay->out, sizeof(ent->lay->out));
 			dump_command(dev, ent, 0);
@@ -1136,10 +1142,7 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
 			} else {
 				complete(&ent->done);
 			}
-			if (ent->page_queue)
-				up(&cmd->pages_sem);
-			else
-				up(&cmd->sem);
+			up(sem);
 		}
 	}
 }
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
