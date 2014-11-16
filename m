From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/14] mlx4: use netdev_rss_key_fill() helper
Date: Sun, 16 Nov 2014 06:23:16 -0800
Message-ID: <1416147798-16561-13-git-send-email-edumazet@google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:64310 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932154AbaKPOYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:24:19 -0500
Received: by mail-oi0-f73.google.com with SMTP id a141so548505oig.4
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:24:18 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use of well known RSS key increases attack surface.
Switch to a random one, using generic helper so that all
ports share a common key.

Also provide ethtool -x support to fetch RSS key

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 9 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 6 +-----
 include/linux/mlx4/qp.h                         | 4 +++-
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 6c643230a5ed..710cf309962a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -973,6 +973,11 @@ static u32 mlx4_en_get_rxfh_indir_size(struct net_device *dev)
 	return priv->rx_ring_num;
 }
 
+static u32 mlx4_en_get_rxfh_key_size(struct net_device *netdev)
+{
+	return MLX4_EN_RSS_KEY_SIZE;
+}
+
 static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -988,7 +993,8 @@ static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key)
 		ring_index[n] = rss_map->qps[n % rss_rings].qpn -
 			rss_map->base_qpn;
 	}
-
+	if (key)
+		netdev_rss_key_fill(key, MLX4_EN_RSS_KEY_SIZE);
 	return err;
 }
 
@@ -1799,6 +1805,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_rxnfc = mlx4_en_get_rxnfc,
 	.set_rxnfc = mlx4_en_set_rxnfc,
 	.get_rxfh_indir_size = mlx4_en_get_rxfh_indir_size,
+	.get_rxfh_key_size = mlx4_en_get_rxfh_key_size,
 	.get_rxfh = mlx4_en_get_rxfh,
 	.set_rxfh = mlx4_en_set_rxfh,
 	.get_channels = mlx4_en_get_channels,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index ccd95177ea7c..b7bda8956011 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1169,9 +1169,6 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
-	static const u32 rsskey[10] = { 0xD181C62C, 0xF7F4DB5B, 0x1983A2FC,
-				0x943E1ADB, 0xD9389E6B, 0xD1039C2C, 0xA74499AD,
-				0x593D56D9, 0xF3253C06, 0x2ADC1FFC};
 
 	en_dbg(DRV, priv, "Configuring rss steering\n");
 	err = mlx4_qp_reserve_range(mdev->dev, priv->rx_ring_num,
@@ -1226,8 +1223,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
-	for (i = 0; i < 10; i++)
-		rss_context->rss_key[i] = cpu_to_be32(rsskey[i]);
+	netdev_rss_key_fill(rss_context->rss_key, MLX4_EN_RSS_KEY_SIZE);
 
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
 			       &rss_map->indir_qp, &rss_map->indir_state);
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index 5f4e36cf0091..467ccdf94c98 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -120,13 +120,15 @@ enum {
 	MLX4_RSS_QPC_FLAG_OFFSET		= 13,
 };
 
+#define MLX4_EN_RSS_KEY_SIZE 40
+
 struct mlx4_rss_context {
 	__be32			base_qpn;
 	__be32			default_qpn;
 	u16			reserved;
 	u8			hash_fn;
 	u8			flags;
-	__be32			rss_key[10];
+	__be32			rss_key[MLX4_EN_RSS_KEY_SIZE / sizeof(__be32)];
 	__be32			base_qpn_udp;
 };
 
-- 
2.1.0.rc2.206.gedb03e5
