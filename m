From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net] net/mlx5e: Race between mlx5e_update_stats() and getting the stats
Date: Wed, 19 Apr 2017 11:29:36 -0700
Message-ID: <20170419182936.788220-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@mellanox.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55982 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S968910AbdDSS3j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 14:29:39 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JITHiE031971
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 11:29:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29xd4hr0xh-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 11:29:38 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 245c25f0252e11e79a380002c9521c9e-877eb9a0 for <netdev@vger.kernel.org>;        Wed,
 19 Apr 2017 11:29:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have observed a sudden spike in rx/tx_packets and rx/tx_bytes
reported under /proc/net/dev.  It seems there is a race in
mlx5e_update_stats() and some of the get-stats functions (the
one that we hit is the mlx5e_get_stats() which is called
by ndo_get_stats64()).

In particular, the very first thing mlx5e_update_sw_counters()
does is 'memset(s, 0, sizeof(*s))'.  For example, if mlx5e_get_stats()
is unlucky at one point, rx_bytes and rx_packets could be 0.  One second
later, a normal (and much bigger than 0) value will be reported.

This patch is not meant to be a proper fix.  It merely tries
to show what I have suspected and start the discussion.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 7 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 3 +++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index a004a5a1a4c2..d24916f720bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -313,7 +313,6 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	mutex_lock(&priv->state_lock);
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		mlx5e_update_stats(priv);
-	mutex_unlock(&priv->state_lock);
 
 	for (i = 0; i < NUM_SW_COUNTERS; i++)
 		data[idx++] = MLX5E_READ_CTR64_CPU(&priv->stats.sw,
@@ -378,8 +377,10 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.error_counters,
 						   mlx5e_pme_error_desc, i);
 
-	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		mutex_unlock(&priv->state_lock);
 		return;
+	}
 
 	/* per channel counters */
 	for (i = 0; i < priv->params.num_channels; i++)
@@ -393,6 +394,8 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 			for (j = 0; j < NUM_SQ_STATS; j++)
 				data[idx++] = MLX5E_READ_CTR64_CPU(&priv->channel[i]->sq[tc].stats,
 								   sq_stats_desc, j);
+
+	mutex_unlock(&priv->state_lock);
 }
 
 static u32 mlx5e_rx_wqes_to_packets(struct mlx5e_priv *priv, int rq_wq_type,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 66c133757a5e..a4c100bea541 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2748,6 +2748,8 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	struct mlx5e_vport_stats *vstats = &priv->stats.vport;
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 
+	mutex_lock(&priv->state_lock);
+
 	if (mlx5e_is_uplink_rep(priv)) {
 		stats->rx_packets = PPORT_802_3_GET(pstats, a_frames_received_ok);
 		stats->rx_bytes   = PPORT_802_3_GET(pstats, a_octets_received_ok);
@@ -2783,6 +2785,7 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->multicast =
 		VPORT_COUNTER_GET(vstats, received_eth_multicast.packets);
 
+	mutex_unlock(&priv->state_lock);
 }
 
 static void mlx5e_set_rx_mode(struct net_device *dev)
-- 
2.9.3
