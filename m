From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/6] mlx4_en: Separating default QP in RSS context
Date: Thu, 26 Mar 2009 15:49:31 +0200
Message-ID: <49CB87EB.8060404@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43404 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756626AbZCZNuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 09:50:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default QP number in RSS is no longer part of the RSS table.
We want to separate TCP streams from other streams because we
want to handle them differently. Changed the RSS mask to perform
the hashing on TCP packets only and to send all the others to the
default ring.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c   |    2 +-
 drivers/net/mlx4/en_params.c |    2 +-
 drivers/net/mlx4/en_rx.c     |    4 ++--
 drivers/net/mlx4/mlx4_en.h   |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index eda72dd..ca6f7dc 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -170,7 +170,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
 			  mdev->profile.prof[i].tx_ring_num, i);
 		mdev->profile.prof[i].rx_ring_num =
-			min_t(int, dev->caps.num_comp_vectors, MAX_RX_RINGS);
+			min_t(int, dev->caps.num_comp_vectors + 1, MAX_RX_RINGS);
 		mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
 			  mdev->profile.prof[i].rx_ring_num, i);
 	}
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index c1bd040..7f44fcb 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -53,7 +53,7 @@
 MLX4_EN_PARM_INT(rss_xor, 0, "Use XOR hash function for RSS");

 /* RSS hash type mask - default to <saddr, daddr, sport, dport> */
-MLX4_EN_PARM_INT(rss_mask, 0xf, "RSS hash type bitmask");
+MLX4_EN_PARM_INT(rss_mask, 0x5, "RSS hash type bitmask");

 /* Number of LRO sessions per Rx ring (rounded up to a power of two) */
 MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index a4130e7..b8c7182 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -1022,8 +1022,8 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)

 	ptr = ((void *) &context) + 0x3c;
 	rss_context = (struct mlx4_en_rss_context *) ptr;
-	rss_context->base_qpn = cpu_to_be32(ilog2(rss_map->size) << 24 |
-					    (rss_map->base_qpn));
+	rss_context->base_qpn = cpu_to_be32(ilog2(rss_map->size - 1) << 24 |
+					    (rss_map->base_qpn + 1));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->hash_fn = rss_xor & 0x3;
 	rss_context->flags = rss_mask << 2;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index e9af32d..8fe1d39 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -78,9 +78,9 @@
 #define MLX4_EN_PAGE_SHIFT	12
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
 #define MAX_TX_RINGS		16
-#define MAX_RX_RINGS		16
+#define MAX_RX_RINGS		17
 #define MAX_RSS_MAP_SIZE	64
-#define RSS_FACTOR		2
+#define RSS_FACTOR		1
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
 #define MAX_LSO_HDR_SIZE	92
-- 
1.6.1.3



