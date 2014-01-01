From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number of default RSS queues"
Date: Wed,  1 Jan 2014 15:05:37 +0200
Message-ID: <1388581537-4810-3-git-send-email-amirv@mellanox.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38249 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753751AbaAANGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 08:06:09 -0500
In-Reply-To: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

This reverts commit 90b1ebe "mlx4: set maximal number of default RSS
queues".
Limiting the number of receive rings to default (8) reduces overall
packet rate by 15% in multiple TCP streams application:

          Packet rate
8  rings  967691
16 rings  1142070

Results were obtained using netperf:

S=200 ; ( for i in $(seq 1 $S) ; do ( \
  netperf -H 11.7.13.55 -t TCP_RR -l 30 &) ; \
  wait ; done | grep "1        1" | awk '{SUM+=$6} END {print SUM}' )


CC: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 417a595..31ff812 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -41,7 +41,6 @@
 #include <linux/slab.h>
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
-#include <linux/netdevice.h>
 #include <linux/kmod.h>
 
 #include <linux/mlx4/device.h>
@@ -1974,8 +1973,8 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
 	int nreq = min_t(int, dev->caps.num_ports *
-			 min_t(int, netif_get_num_default_rss_queues() + 1,
-			       MAX_MSIX_P_PORT) + MSIX_LEGACY_SZ, MAX_MSIX);
+			 min_t(int, num_online_cpus() + 1, MAX_MSIX_P_PORT)
+				+ MSIX_LEGACY_SZ, MAX_MSIX);
 	int err;
 	int i;
 
-- 
1.8.3.4
