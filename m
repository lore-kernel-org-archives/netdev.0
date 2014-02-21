From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 2/2] net/mlx4: Fix limiting number of IRQ's instead of RSS queues
Date: Fri, 21 Feb 2014 12:39:18 +0200
Message-ID: <1392979158-18093-3-git-send-email-amirv@mellanox.com>
References: <1392979158-18093-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Ido Shamay <idos@mellanox.com>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58708 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754208AbaBUKjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Feb 2014 05:39:36 -0500
In-Reply-To: <1392979158-18093-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This fix a performance bug introduced by commit 90b1ebe "mlx4: set
maximal number of default RSS queues", which limits the numbers of IRQs
opened by core module.
The limit should be on the number of queues in the indirection table -
rx_rings, and not on the number of IRQ's. Also, limiting on mlx4_core
initialization instead of in mlx4_en, prevented using "ethtool -L" to
utilize all the CPU's, when performance mode is prefered, since limiting
this number to 8 reduces overall packet rate by 15%-50% in multiple TCP
streams applications.

For example, after running ethtool -L <ethx> rx 16

          Packet rate
Before the fix  897799
After the fix   1142070

Results were obtained using netperf:

S=200 ; ( for i in $(seq 1 $S) ; do ( \
  netperf -H 11.7.13.55 -t TCP_RR -l 30 &) ; \
  wait ; done | grep "1        1" | awk '{SUM+=$6} END {print SUM}' )


CC: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 5 ++++-
 drivers/net/ethernet/mellanox/mlx4/main.c  | 3 +--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 61e44ae..630ec03 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -322,6 +322,7 @@ void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
 {
 	int i;
 	int num_of_eqs;
+	int num_rx_rings;
 	struct mlx4_dev *dev = mdev->dev;
 
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
@@ -335,8 +336,10 @@ void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
 					   dev->caps.comp_pool/
 					   dev->caps.num_ports) - 1;
 
+		num_rx_rings = min_t(int, num_of_eqs,
+				     netif_get_num_default_rss_queues());
 		mdev->profile.prof[i].rx_ring_num =
-			rounddown_pow_of_two(num_of_eqs);
+			rounddown_pow_of_two(num_rx_rings);
 	}
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d711158..8c82a6b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -41,7 +41,6 @@
 #include <linux/slab.h>
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
-#include <linux/netdevice.h>
 #include <linux/kmod.h>
 
 #include <linux/mlx4/device.h>
@@ -1974,7 +1973,7 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
 	int nreq = min_t(int, dev->caps.num_ports *
-			 min_t(int, netif_get_num_default_rss_queues() + 1,
+			 min_t(int, num_online_cpus() + 1,
 			       MAX_MSIX_P_PORT) + MSIX_LEGACY_SZ, MAX_MSIX);
 	int err;
 	int i;
-- 
1.8.3.4
