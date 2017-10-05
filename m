From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] net/mlx4_core: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:54 -0700
Message-ID: <20171005005154.GA23500@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/mellanox/mlx4/catas.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 53daa6ca5d83..e2b6b0cac1ac 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -231,10 +231,10 @@ static void dump_err_buf(struct mlx4_dev *dev)
 			 i, swab32(readl(priv->catas_err.map + i)));
 }
 
-static void poll_catas(unsigned long dev_ptr)
+static void poll_catas(struct timer_list *t)
 {
-	struct mlx4_dev *dev = (struct mlx4_dev *) dev_ptr;
-	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_priv *priv = from_timer(priv, t, catas_err.timer);
+	struct mlx4_dev *dev = &priv->dev;
 	u32 slave_read;
 
 	if (mlx4_is_slave(dev)) {
@@ -277,7 +277,7 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
 	phys_addr_t addr;
 
 	INIT_LIST_HEAD(&priv->catas_err.list);
-	init_timer(&priv->catas_err.timer);
+	timer_setup(&priv->catas_err.timer, poll_catas, 0);
 	priv->catas_err.map = NULL;
 
 	if (!mlx4_is_slave(dev)) {
@@ -293,8 +293,6 @@ void mlx4_start_catas_poll(struct mlx4_dev *dev)
 		}
 	}
 
-	priv->catas_err.timer.data     = (unsigned long) dev;
-	priv->catas_err.timer.function = poll_catas;
 	priv->catas_err.timer.expires  =
 		round_jiffies(jiffies + MLX4_CATAS_POLL_INTERVAL);
 	add_timer(&priv->catas_err.timer);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
