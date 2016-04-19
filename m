From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 1/5] mlx4: Add support for UDP tunnel segmentation with
 outer checksum offload
Date: Tue, 19 Apr 2016 15:05:56 -0400
Message-ID: <20160419190556.11723.95089.stgit@ahduyck-xeon-server>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eugenia@mellanox.com, bruce.w.allan@intel.com, saeedm@mellanox.com,
	netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	ariel.elior@qlogic.com, mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32938 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbcDSTGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 15:06:07 -0400
Received: by mail-pf0-f174.google.com with SMTP id 184so9651305pff.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 12:06:06 -0700 (PDT)
In-Reply-To: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch assumes that the mlx4 hardware will ignore existing IPv4/v6
header fields for length and checksum as well as the length and checksum
fields for outer UDP headers.

I have no means of testing this as I do not have any mlx4 hardware but
thought I would submit it as an RFC to see if anyone out there wants to
test this and see if this does in fact enable this functionality allowing
us to to segment UDP tunneled frames that have an outer checksum.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b4b258c8ca47..cb6a8a522857 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2356,7 +2356,9 @@ out:
 
 	/* set offloads */
 	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
+				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+				      NETIF_F_GSO_UDP_TUNNEL_CSUM |
+				      NETIF_F_GSO_PARTIAL;
 }
 
 static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
@@ -2366,7 +2368,9 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 						 vxlan_del_task);
 	/* unset offloads */
 	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL);
+					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+					NETIF_F_GSO_UDP_TUNNEL_CSUM |
+					NETIF_F_GSO_PARTIAL);
 
 	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
 				  VXLAN_STEER_BY_OUTER_MAC, 0);
@@ -2990,8 +2994,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
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
