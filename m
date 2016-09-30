From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 1/2] net/mlx5e: shut up maybe-uninitialized warning
Date: Fri, 30 Sep 2016 18:17:09 +0200
Message-ID: <20160930161734.70928-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Amir Vadai <amirva-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Build-testing this driver with -Wmaybe-uninitialized gives a new false-positive
warning that I can't really explain:

drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'mlx5e_configure_flower':
drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:509:3: error: 'old_attr' may be used uninitialized in this function [-Werror=maybe-uninitialized]

It's obvious from the code that 'old_attr' is initialized whenever 'old'
is non-NULL here. The warning appears with all versions I tested from gcc-4.7
through gcc-6.1, and I could not come up with a way to rewrite the function
in a more readable way that avoids the warning, so I'm adding another
initialization to shut it up.

Fixes: 8b32580df1cb ("net/mlx5e: Add TC vlan action for SRIOV offloads")
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index a350b7171e3d..ce8c54d18906 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -451,7 +451,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	struct mlx5e_tc_flow *flow;
 	struct mlx5_flow_spec *spec;
 	struct mlx5_flow_rule *old = NULL;
-	struct mlx5_esw_flow_attr *old_attr;
+	struct mlx5_esw_flow_attr *old_attr = NULL;
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
 	if (esw && esw->mode == SRIOV_OFFLOADS)
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
