From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] drivers/net: mellanox: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:55:20 -0700
Message-ID: <20171027055520.GA118469@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index a89a68ce53ad..185dcac0abe7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -285,9 +285,9 @@ void mlx5_trigger_health_work(struct mlx5_core_dev *dev)
 	spin_unlock_irqrestore(&health->wq_lock, flags);
 }
 
-static void poll_health(unsigned long data)
+static void poll_health(struct timer_list *t)
 {
-	struct mlx5_core_dev *dev = (struct mlx5_core_dev *)data;
+	struct mlx5_core_dev *dev = from_timer(dev, t, priv.health.timer);
 	struct mlx5_core_health *health = &dev->priv.health;
 	u32 count;
 
@@ -320,7 +320,7 @@ void mlx5_start_health_poll(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
 
-	setup_timer(&health->timer, poll_health, (unsigned long)dev);
+	timer_setup(&health->timer, poll_health, 0);
 	health->sick = 0;
 	clear_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags);
 	clear_bit(MLX5_DROP_NEW_RECOVERY_WORK, &health->flags);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
