From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH net] net/mlx5: avoid build warning for uniprocessor
Date: Mon, 29 May 2017 15:00:17 +0200
Message-ID: <20170529130030.244337-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Daniel Jurgens <danielj-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Huy Nguyen <huyn-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Building the driver with CONFIG_SMP disabled results in a harmless
warning:

ethernet/mellanox/mlx5/core/main.c: In function 'mlx5_irq_set_affinity_hint':
ethernet/mellanox/mlx5/core/main.c:615:6: error: unused variable 'irq' [-Werror=unused-variable]

It's better to express the conditional compilation using IS_ENABLED()
here, as that lets the compiler see what the intented use for the variable
is, and that it can be silently discarded.

Fixes: b665d98edc9a ("net/mlx5: Tolerate irq_set_affinity_hint() failures")
igned-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 361cd112bb5b..9274d93d3183 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -622,10 +622,9 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 	cpumask_set_cpu(cpumask_local_spread(i, priv->numa_node),
 			priv->irq_info[i].mask);
 
-#ifdef CONFIG_SMP
-	if (irq_set_affinity_hint(irq, priv->irq_info[i].mask))
+	if (IS_ENABLED(CONFIG_SMP) &&
+	    irq_set_affinity_hint(irq, priv->irq_info[i].mask))
 		mlx5_core_warn(mdev, "irq_set_affinity_hint failed, irq 0x%.4x", irq);
-#endif
 
 	return 0;
 }
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
