From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 4/8] net/mlx4_en: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Mon, 02 May 2016 09:38:30 -0700
Message-ID: <20160502163830.11809.26978.stgit@ahduyck-xeon-server>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	davem@davemloft.net, galp@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36698 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbcEBQie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:38:34 -0400
Received: by mail-pa0-f44.google.com with SMTP id bt5so75646215pac.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:38:33 -0700 (PDT)
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch assumes that the mlx4 hardware will ignore existing IPv4/v6
header fields for length and checksum as well as the length and checksum
fields for outer UDP headers.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 8bd143dda95d..bce37cbfde24 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2358,7 +2358,9 @@ out:
 
 	/* set offloads */
 	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
+				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+				      NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				      NETIF_F_GSO_PARTIAL;
 }
 
 static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
@@ -2368,7 +2370,9 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 						 vxlan_del_task);
 	/* unset offloads */
 	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
+					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+					NETIF_F_GSO_UDP_TUNNEL_CSUM |
+					NETIF_F_GSO_PARTIAL);
 
 	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
 				  VXLAN_STEER_BY_OUTER_MAC, 0);
@@ -2992,8 +2996,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
-		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
-		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
+		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL |
+				    NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				    NETIF_F_GSO_PARTIAL;
+		dev->features    |= NETIF_F_GSO_UDP_TUNNEL |
+				    NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				    NETIF_F_GSO_PARTIAL;
+		dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
 	}
 
 	mdev->pndev[port] = dev;
