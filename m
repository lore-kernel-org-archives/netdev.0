From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 1/2] mlx5: only register devlink when ethernet is available
Date: Wed, 15 Jun 2016 17:27:51 +0200
Message-ID: <20160615152816.2800830-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We get a build error with the mlx5 driver when the ethernet
support (CONFIG_MLX5_CORE_EN) is disabled:

drivers/net/ethernet/mellanox/mlx5/core/main.c:1320:22: error: 'mlx5_devlink_eswitch_mode_set' undeclared here (not in a function)
drivers/net/ethernet/mellanox/mlx5/core/main.c:1321:22: error: 'mlx5_devlink_eswitch_mode_get' undeclared here (not in a function)
drivers/net/built-in.o:(.rodata+0x25a68): undefined reference to `mlx5_devlink_eswitch_mode_get'
drivers/net/built-in.o:(.rodata+0x25a6c): undefined reference to `mlx5_devlink_eswitch_mode_set'

There are actually two problems here, but they are closely related,
so I'm addressing them both:

- The header is included under an #ifdef, which is usually a bad idea
  as it hides the function declarations, so we fail to compile even
  if we don't actually use the functions in the end.
- The references to the functions are kept in the object file because
  we don't check whether they are built-in or not.

As we don't want to add any useless #ifdef here, this uses an
IS_ENABLED() check to drop the mlx5_devlink_ops structure when we don't
need it, and to skip the register/unregister step.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Fixes: f7856daf57b9 ("net/mlx5: Add devlink interface")
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index dc568096b87c..d238e312b123 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -54,9 +54,7 @@
 #include <net/devlink.h>
 #include "mlx5_core.h"
 #include "fs_core.h"
-#ifdef CONFIG_MLX5_CORE_EN
 #include "eswitch.h"
-#endif
 
 MODULE_AUTHOR("Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>");
 MODULE_DESCRIPTION("Mellanox Connect-IB, ConnectX-4 core driver");
@@ -1329,7 +1327,8 @@ static int init_one(struct pci_dev *pdev,
 	struct mlx5_priv *priv;
 	int err;
 
-	devlink = devlink_alloc(&mlx5_devlink_ops, sizeof(*dev));
+	devlink = devlink_alloc(IS_ENABLED(CONFIG_MLX5_CORE_EN) ?
+				&mlx5_devlink_ops : NULL, sizeof(*dev));
 	if (!devlink) {
 		dev_err(&pdev->dev, "kzalloc failed\n");
 		return -ENOMEM;
@@ -1372,7 +1371,8 @@ static int init_one(struct pci_dev *pdev,
 		goto clean_health;
 	}
 
-	err = devlink_register(devlink, &pdev->dev);
+	if (IS_ENABLED(CONFIG_MLX5_CORE_EN))
+		err = devlink_register(devlink, &pdev->dev);
 	if (err)
 		goto clean_load;
 
@@ -1397,7 +1397,8 @@ static void remove_one(struct pci_dev *pdev)
 	struct devlink *devlink = priv_to_devlink(dev);
 	struct mlx5_priv *priv = &dev->priv;
 
-	devlink_unregister(devlink);
+	if (IS_ENABLED(CONFIG_MLX5_CORE_EN))
+		devlink_unregister(devlink);
 	if (mlx5_unload_one(dev, priv)) {
 		dev_err(&dev->pdev->dev, "mlx5_unload_one failed\n");
 		mlx5_health_cleanup(dev);
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
