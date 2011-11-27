From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V2 2/7] net/mlx4: fix UDP RSS related settings
Date: Sun, 27 Nov 2011 07:55:02 +0200
Message-ID: <4ED1D0B6.3000103@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:48172 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752574Ab1K0ITq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 03:19:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Using RSS which takes into account UDP headers is controlled by
a module param, fix the setting of the HW RSS context to align
with that scheme. So far it was uncoditionally allowing hashing
on the UDP headers.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 86cb300..3c24e16 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -836,7 +836,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_rss_context *rss_context;
 	void *ptr;
 	u8 rss_mask = (MLX4_RSS_IPV4 | MLX4_RSS_TCP_IPV4 | MLX4_RSS_IPV6 |
-		MLX4_RSS_TCP_IPV6 | MLX4_RSS_UDP_IPV4 | MLX4_RSS_UDP_IPV6);
+			MLX4_RSS_TCP_IPV6);
 	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
@@ -879,14 +879,16 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	rss_context = ptr;
 	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
 					    (rss_map->base_qpn));
+	if (priv->mdev->profile.udp_rss) {
+		rss_mask |=  MLX4_RSS_UDP_IPV4 | MLX4_RSS_UDP_IPV6;
+		rss_context->base_qpn_udp = rss_context->default_qpn;
+	}
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
 	for (i = 0; i < 10; i++)
 		rss_context->rss_key[i] = rsskey[i];
 
-	if (priv->mdev->profile.udp_rss)
-		rss_context->base_qpn_udp = rss_context->default_qpn;
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
 			       &rss_map->indir_qp, &rss_map->indir_state);
 	if (err)
-- 
1.7.7
