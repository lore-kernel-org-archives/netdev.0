From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 4/4] net/mlx4_en: Reduce memory consumption on kdump kernel
Date: Tue, 22 Jul 2014 15:44:12 +0300
Message-ID: <1406033052-16550-5-git-send-email-amirv@mellanox.com>
References: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47451 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753375AbaGVMpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 08:45:01 -0400
In-Reply-To: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When memory is limited, reduce number of rx and tx rings.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c | 6 ++++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 5 +++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h | 1 +
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index f953c1d..3626fdf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -129,8 +129,10 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	int i;
 
 	params->udp_rss = udp_rss;
-	params->num_tx_rings_p_up = min_t(int, num_online_cpus(),
-			MLX4_EN_MAX_TX_RING_P_UP);
+	params->num_tx_rings_p_up = mlx4_low_memory_profile() ?
+		MLX4_EN_MIN_TX_RING_P_UP :
+		min_t(int, num_online_cpus(), MLX4_EN_MAX_TX_RING_P_UP);
+
 	if (params->udp_rss && !(mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UDP_RSS)) {
 		mlx4_warn(mdev, "UDP RSS is not supported on this device\n");
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 7765a08..9c909d2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -335,8 +335,9 @@ void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
 					   dev->caps.comp_pool/
 					   dev->caps.num_ports) - 1;
 
-		num_rx_rings = min_t(int, num_of_eqs,
-				     netif_get_num_default_rss_queues());
+		num_rx_rings = mlx4_low_memory_profile() ? MIN_RX_RINGS :
+			min_t(int, num_of_eqs,
+			      netif_get_num_default_rss_queues());
 		mdev->profile.prof[i].rx_ring_num =
 			rounddown_pow_of_two(num_rx_rings);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 54c2774..3de41be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -121,6 +121,7 @@ enum {
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
 
 #define MLX4_EN_SMALL_PKT_SIZE		64
+#define MLX4_EN_MIN_TX_RING_P_UP	1
 #define MLX4_EN_MAX_TX_RING_P_UP	32
 #define MLX4_EN_NUM_UP			8
 #define MLX4_EN_DEF_TX_RING_SIZE	512
-- 
1.8.3.4
