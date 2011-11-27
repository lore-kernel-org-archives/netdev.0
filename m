From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH V2 1/7] net/mlx4: move RSS related definitions to be global
Date: Sun, 27 Nov 2011 07:54:58 +0200
Message-ID: <4ED1D0B2.1080703@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:49681 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752433Ab1K0ITq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 03:19:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Towards adding RSS support for IB drivers/application who use
the mlx4 HW, make the RSS related definitions global and change
the mlx4_en driver to use them.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   10 ++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   10 -------
 include/linux/mlx4/qp.h                           |   27 +++++++++++++++++++++
 4 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 0dfb4ec..bcbc54c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -44,7 +44,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	struct mlx4_en_dev *mdev = priv->mdev;
 
 	memset(context, 0, sizeof *context);
-	context->flags = cpu_to_be32(7 << 16 | rss << 13);
+	context->flags = cpu_to_be32(7 << 16 | rss << MLX4_RSS_QPC_FLAG_OFFSET);
 	context->pd = cpu_to_be32(mdev->priv_pdn);
 	context->mtu_msgmax = 0xff;
 	if (!is_tx && !rss)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b89c36d..86cb300 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -833,9 +833,10 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
 	struct mlx4_qp_context context;
-	struct mlx4_en_rss_context *rss_context;
+	struct mlx4_rss_context *rss_context;
 	void *ptr;
-	u8 rss_mask = 0x3f;
+	u8 rss_mask = (MLX4_RSS_IPV4 | MLX4_RSS_TCP_IPV4 | MLX4_RSS_IPV6 |
+		MLX4_RSS_TCP_IPV6 | MLX4_RSS_UDP_IPV4 | MLX4_RSS_UDP_IPV6);
 	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
@@ -873,13 +874,14 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
 				priv->rx_ring[0].cqn, &context);
 
-	ptr = ((void *) &context) + 0x3c;
+	ptr = ((void *) &context) + offsetof(struct mlx4_qp_context, pri_path)
+					+ MLX4_RSS_OFFSET_IN_QPC_PRI_PATH;
 	rss_context = ptr;
 	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->flags = rss_mask;
-	rss_context->hash_fn = 1;
+	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
 	for (i = 0; i < 10; i++)
 		rss_context->rss_key[i] = rsskey[i];
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8fda331c..6e2657d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -365,16 +365,6 @@ struct mlx4_en_rss_map {
 	enum mlx4_qp_state indir_state;
 };
 
-struct mlx4_en_rss_context {
-	__be32 base_qpn;
-	__be32 default_qpn;
-	u16 reserved;
-	u8 hash_fn;
-	u8 flags;
-	__be32 rss_key[10];
-	__be32 base_qpn_udp;
-};
-
 struct mlx4_en_port_state {
 	int link_state;
 	int link_speed;
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 48cc4cb..6562ff6 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -97,6 +97,33 @@ enum {
 	MLX4_QP_BIT_RIC				= 1 <<	4,
 };
 
+enum {
+	MLX4_RSS_HASH_XOR			= 0,
+	MLX4_RSS_HASH_TOP			= 1,
+
+	MLX4_RSS_UDP_IPV6			= 1 << 0,
+	MLX4_RSS_UDP_IPV4			= 1 << 1,
+	MLX4_RSS_TCP_IPV6			= 1 << 2,
+	MLX4_RSS_IPV6				= 1 << 3,
+	MLX4_RSS_TCP_IPV4			= 1 << 4,
+	MLX4_RSS_IPV4				= 1 << 5,
+
+	/* offset of mlx4_rss_context within mlx4_qp_context.pri_path */
+	MLX4_RSS_OFFSET_IN_QPC_PRI_PATH		= 0x24,
+	/* offset of being RSS indirection QP within mlx4_qp_context.flags */
+	MLX4_RSS_QPC_FLAG_OFFSET		= 13,
+};
+
+struct mlx4_rss_context {
+	__be32			base_qpn;
+	__be32			default_qpn;
+	u16			reserved;
+	u8			hash_fn;
+	u8			flags;
+	__be32			rss_key[10];
+	__be32			base_qpn_udp;
+};
+
 struct mlx4_qp_path {
 	u8			fl;
 	u8			reserved1[2];
-- 
1.7.7
