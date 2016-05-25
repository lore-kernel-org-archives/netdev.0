From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 3/4] net/mlx4_en: get rid of ret_stats
Date: Wed, 25 May 2016 09:50:38 -0700
Message-ID: <1464195039-5098-4-git-send-email-edumazet@google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34234 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbcEYQux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 12:50:53 -0400
Received: by mail-pf0-f181.google.com with SMTP id y69so20114232pfb.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 09:50:52 -0700 (PDT)
In-Reply-To: <1464195039-5098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4 uses a private struct net_device_stats in a vain attempt
to avoid races.

This is buggy because multiple cpus could call mlx4_en_get_stats()
at the same time, so ret_stats can not guarantee stable results.

To fix this, we need to switch to ndo_get_stats64() as this
method provides per-thread storage.

This allows to reduce mlx4_en_priv bloat.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 11 ++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 -
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bd637c4eff13..a4fc6e966505 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1296,15 +1296,16 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 }
 
 
-static struct net_device_stats *mlx4_en_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *
+mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	spin_lock_bh(&priv->stats_lock);
-	memcpy(&priv->ret_stats, &priv->stats, sizeof(priv->stats));
+	netdev_stats_to_stats64(stats, &priv->stats);
 	spin_unlock_bh(&priv->stats_lock);
 
-	return &priv->ret_stats;
+	return stats;
 }
 
 static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
@@ -2487,7 +2488,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_stop		= mlx4_en_close,
 	.ndo_start_xmit		= mlx4_en_xmit,
 	.ndo_select_queue	= mlx4_en_select_queue,
-	.ndo_get_stats		= mlx4_en_get_stats,
+	.ndo_get_stats64	= mlx4_en_get_stats64,
 	.ndo_set_rx_mode	= mlx4_en_set_rx_mode,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -2519,7 +2520,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_stop		= mlx4_en_close,
 	.ndo_start_xmit		= mlx4_en_xmit,
 	.ndo_select_queue	= mlx4_en_select_queue,
-	.ndo_get_stats		= mlx4_en_get_stats,
+	.ndo_get_stats64	= mlx4_en_get_stats64,
 	.ndo_set_rx_mode	= mlx4_en_set_rx_mode,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
 	.ndo_validate_addr	= eth_validate_addr,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 9a9124031fc7..bfda84df8aae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -484,7 +484,6 @@ struct mlx4_en_priv {
 	struct net_device *dev;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device_stats stats;
-	struct net_device_stats ret_stats;
 	struct mlx4_en_port_state port_state;
 	spinlock_t stats_lock;
 	struct ethtool_flow_id ethtool_rules[MAX_NUM_OF_FS_RULES];
-- 
2.8.0.rc3.226.g39d4020
