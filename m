From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] net/mlx5: IPSec, fix 64-bit division correctly
Date: Mon, 10 Jul 2017 11:37:51 +0200
Message-ID: <20170710093842.2921914-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yossi Kuperman <yossiku-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yevgeny Kliteynik <kliteyn-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The new IPSec offload code introduced a build error:

drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.o: In function `mlx5e_ipsec_build_inverse_table':
ipsec_rxtx.c:(.text+0x556): undefined reference

Another patch was added on top to fix the build error, but
that introduced a new bug, as we now use the remainder of
the division rather than the result.

This makes it use the correct helper function instead.

Fixes: 5dfd87b67cd9 ("net/mlx5: IPSec, Fix 64-bit division on 32-bit builds")
Fixes: 2ac9cfe78223 ("net/mlx5e: IPSec, Add Innova IPSec offload TX data path")
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
index 7d06c673851a..4614ddfa91eb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
@@ -363,7 +363,6 @@ void mlx5e_ipsec_build_inverse_table(void)
 {
 	u16 mss_inv;
 	u32 mss;
-	u64 n;
 
 	/* Calculate 1/x inverse table for use in GSO data path.
 	 * Using this table, we provide the IPSec accelerator with the value of
@@ -373,8 +372,7 @@ void mlx5e_ipsec_build_inverse_table(void)
 	 */
 	mlx5e_ipsec_inverse_table[1] = htons(0xFFFF);
 	for (mss = 2; mss < MAX_LSO_MSS; mss++) {
-		n = 1ULL << 32;
-		mss_inv = do_div(n, mss) >> 16;
+		mss_inv = div_u64(1ULL << 32, mss) >> 16;
 		mlx5e_ipsec_inverse_table[mss] = htons(mss_inv);
 	}
 }
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
