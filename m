From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 6/6] net/mlx4_en: Avoid changing dev->features directly in run-time
Date: Wed, 17 Feb 2016 17:24:27 +0200
Message-ID: <1455722667-23179-7-git-send-email-ogerlitz@mellanox.com>
References: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:44335 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S964960AbcBQPY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 10:24:58 -0500
In-Reply-To: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

It's forbidden to manually change dev->features in run-time. Currently, this is
done in the driver to make sure that GSO_UDP_TUNNEL is advertized only when
VXLAN tunnel is set. However, since the stack actually does features intersection
with hw_enc_features, we can safely revert to advertizing features early when
registering the netdevice.

Fixes: f4a1edd56120 ('net/mlx4_en: Advertize encapsulation offloads [...]')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0c7e3f6..f191a16 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2344,8 +2344,6 @@ out:
 	/* set offloads */
 	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
-	priv->dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
-	priv->dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
 }
 
 static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
@@ -2356,8 +2354,6 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 	/* unset offloads */
 	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
-	priv->dev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
-	priv->dev->features    &= ~NETIF_F_GSO_UDP_TUNNEL;
 
 	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
 				  VXLAN_STEER_BY_OUTER_MAC, 0);
@@ -2980,6 +2976,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		priv->rss_hash_fn = ETH_RSS_HASH_TOP;
 	}
 
+	if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
+		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
+	}
+
 	mdev->pndev[port] = dev;
 	mdev->upper[port] = NULL;
 
-- 
2.3.7
