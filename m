From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 6/8] net/mlx4_en: allow setting number of rx rings for, RSS/TCP
Date: Mon, 21 Nov 2011 10:43:48 +0200
Message-ID: <4ECA0F44.1080004@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aob106.obsmtp.com ([207.126.144.120]:33460 "HELO
	eu1sys200aob106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752572Ab1KULwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:52:25 -0500
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
index 3c24e16..044123a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -834,6 +834,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
 	struct mlx4_qp_context context;
 	struct mlx4_rss_context *rss_context;
+	int tcp_rss_table_size;
 	void *ptr;
 	u8 rss_mask = (MLX4_RSS_IPV4 | MLX4_RSS_TCP_IPV4 | MLX4_RSS_IPV6 |
 			MLX4_RSS_TCP_IPV6);
@@ -874,10 +875,16 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
 				priv->rx_ring[0].cqn, &context);
 
+	if (priv->mdev->profile.tcp_rss == -1 ||
+	    priv->mdev->profile.tcp_rss > priv->rx_ring_num)
+		tcp_rss_table_size = priv->rx_ring_num;
+	else
+		tcp_rss_table_size = max(1, priv->mdev->profile.tcp_rss);
+
 	ptr = ((void *) &context) + offsetof(struct mlx4_qp_context, pri_path)
 					+ MLX4_RSS_OFFSET_IN_QPC_PRI_PATH;
 	rss_context = ptr;
-	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
+	rss_context->base_qpn = cpu_to_be32(ilog2(tcp_rss_table_size) << 24 |
 					    (rss_map->base_qpn));
 	if (priv->mdev->profile.udp_rss) {
 		rss_mask |=  MLX4_RSS_UDP_IPV4 | MLX4_RSS_UDP_IPV6;
-- 
1.7.7
