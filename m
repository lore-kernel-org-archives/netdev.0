From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] mlx5/core: Use memdup_user() rather than duplicating its
 implementation
Date: Sat, 20 Aug 2016 08:01:22 +0200
Message-ID: <ceb39933-438d-920d-f294-ea0ce32fd171@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 07:50:09 +0200

* Reuse existing functionality from memdup_user() instead of keeping
  duplicate source code.

  This issue was detected by using the Coccinelle software.

* Return directly if this copy operation failed.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 6388bc0..bb89f04 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1132,7 +1132,6 @@ static ssize_t data_write(struct file *filp, const char __user *buf,
 	struct mlx5_core_dev *dev = filp->private_data;
 	struct mlx5_cmd_debug *dbg = &dev->cmd.dbg;
 	void *ptr;
-	int err;
 
 	if (*pos != 0)
 		return -EINVAL;
@@ -1140,25 +1139,15 @@ static ssize_t data_write(struct file *filp, const char __user *buf,
 	kfree(dbg->in_msg);
 	dbg->in_msg = NULL;
 	dbg->inlen = 0;
-
-	ptr = kzalloc(count, GFP_KERNEL);
-	if (!ptr)
-		return -ENOMEM;
-
-	if (copy_from_user(ptr, buf, count)) {
-		err = -EFAULT;
-		goto out;
-	}
+	ptr = memdup_user(buf, count);
+	if (IS_ERR(ptr))
+		return PTR_ERR(ptr);
 	dbg->in_msg = ptr;
 	dbg->inlen = count;
 
 	*pos = count;
 
 	return count;
-
-out:
-	kfree(ptr);
-	return err;
 }
 
 static ssize_t data_read(struct file *filp, char __user *buf, size_t count,
-- 
2.9.3
