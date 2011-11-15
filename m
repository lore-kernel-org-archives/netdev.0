From: Amir Vadai <amirv@dev.mellanox.co.il>
Subject: [PATCH 1/3] net/mlx4_en: allow setting number of rx rings for RSS/TCP
Date: Tue, 15 Nov 2011 11:14:04 +0200
Message-ID: <1321348446-29605-2-git-send-email-amirv@mellanox.com>
References: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Oren Duer <oren@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33813 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab1KOJOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 04:14:34 -0500
Received: by bke11 with SMTP id 11so6906640bke.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 01:14:33 -0800 (PST)
In-Reply-To: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Make RSS TCP divert packets only to part of the rx rings, other could be
accessed by using flow steering or RFS acceleration

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c |    7 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    9 ++++++++-
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a06096f..f70bafb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -63,9 +63,10 @@ static const char mlx4_en_version[] =
  */
 
 
-/* Enable RSS TCP traffic */
-MLX4_EN_PARM_INT(tcp_rss, 1,
-		 "Enable RSS for incomming TCP traffic or disabled (0)");
+/* RSS TCP usage */
+MLX4_EN_PARM_INT(tcp_rss, -1,
+		 "0 to disable RSS TCP, if n > 0, use n rx rings by RSS TCP. -1 "
+		 "for all rx rings");
 /* Enable RSS UDP traffic */
 MLX4_EN_PARM_INT(udp_rss, 1,
 		 "Enable RSS for incomming UDP traffic or disabled (0)");
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b89c36d..17c7062 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -834,6 +834,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
 	struct mlx4_qp_context context;
 	struct mlx4_en_rss_context *rss_context;
+	int tcp_rss_table_size;
 	void *ptr;
 	u8 rss_mask = 0x3f;
 	int i, qpn;
@@ -873,9 +874,15 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
 				priv->rx_ring[0].cqn, &context);
 
+	if (priv->mdev->profile.tcp_rss == -1 ||
+			priv->mdev->profile.tcp_rss > priv->rx_ring_num)
+		tcp_rss_table_size = priv->rx_ring_num;
+	else
+		tcp_rss_table_size = max(1, priv->mdev->profile.tcp_rss);
+
 	ptr = ((void *) &context) + 0x3c;
 	rss_context = ptr;
-	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
+	rss_context->base_qpn = cpu_to_be32(ilog2(tcp_rss_table_size) << 24 |
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->flags = rss_mask;
-- 
1.7.5.4
