From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Advertize encapsulation offloads features only when VXLAN tunnel is set
Date: Sun,  9 Nov 2014 14:25:39 +0200
Message-ID: <1415535939-30681-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33082 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751568AbaKIMZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2014 07:25:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currenly we only support Large-Send and TX checksum offloads for
encapsulated traffic of type VXLAN. We must make sure to advertize
these offloads up to the stack only when VXLAN tunnel is set.

Failing to do so, would mislead the the networking stack to assume
that the driver can offload the internal TX checksum for GRE packets
and other buggy schemes.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   22 ++++++++++++++--------
 1 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f3032fe..02266e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2281,8 +2281,16 @@ static void mlx4_en_add_vxlan_offloads(struct work_struct *work)
 	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
 				  VXLAN_STEER_BY_OUTER_MAC, 1);
 out:
-	if (ret)
+	if (ret) {
 		en_err(priv, "failed setting L2 tunnel configuration ret %d\n", ret);
+		return;
+	}
+
+	/* set offloads */
+	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
+	priv->dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+	priv->dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
 }
 
 static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
@@ -2290,6 +2298,11 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 	int ret;
 	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
 						 vxlan_del_task);
+	/* unset offloads */
+	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
+	priv->dev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
+	priv->dev->features    &= ~NETIF_F_GSO_UDP_TUNNEL;
 
 	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
 				  VXLAN_STEER_BY_OUTER_MAC, 0);
@@ -2568,13 +2581,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
 		dev->priv_flags |= IFF_UNICAST_FLT;
 
-	if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
-		dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
-		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
-		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
-	}
-
 	mdev->pndev[port] = dev;
 
 	netif_carrier_off(dev);
-- 
1.7.1
