From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 2/3] net/mlx5e: Support TSO and TX checksum offloads for GRE tunnels
Date: Thu, 31 Aug 2017 02:04:08 +0300
Message-ID: <20170830230409.15176-3-saeedm@mellanox.com>
References: <20170830230409.15176-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34552 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751301AbdH3XEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:04:21 -0400
In-Reply-To: <20170830230409.15176-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add TX offloads support for GRE tunneled packets by reporting the needed
netdev features.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 51 +++++++++++++++--------
 include/linux/mlx5/mlx5_ifc.h                     |  2 +-
 2 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index fdc2b92f020b..9475fb89a744 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3499,13 +3499,13 @@ static void mlx5e_del_vxlan_port(struct net_device *netdev,
 	mlx5e_vxlan_queue_work(priv, ti->sa_family, be16_to_cpu(ti->port), 0);
 }
 
-static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
-						    struct sk_buff *skb,
-						    netdev_features_t features)
+static netdev_features_t mlx5e_tunnel_features_check(struct mlx5e_priv *priv,
+						     struct sk_buff *skb,
+						     netdev_features_t features)
 {
 	struct udphdr *udph;
-	u16 proto;
-	u16 port = 0;
+	u8 proto;
+	u16 port;
 
 	switch (vlan_get_protocol(skb)) {
 	case htons(ETH_P_IP):
@@ -3518,14 +3518,17 @@ static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
 		goto out;
 	}
 
-	if (proto == IPPROTO_UDP) {
+	switch (proto) {
+	case IPPROTO_GRE:
+		return features;
+	case IPPROTO_UDP:
 		udph = udp_hdr(skb);
 		port = be16_to_cpu(udph->dest);
-	}
 
-	/* Verify if UDP port is being offloaded by HW */
-	if (port && mlx5e_vxlan_lookup_port(priv, port))
-		return features;
+		/* Verify if UDP port is being offloaded by HW */
+		if (mlx5e_vxlan_lookup_port(priv, port))
+			return features;
+	}
 
 out:
 	/* Disable CSUM and GSO if the udp dport is not offloaded by HW */
@@ -3549,7 +3552,7 @@ static netdev_features_t mlx5e_features_check(struct sk_buff *skb,
 	/* Validate if the tunneled packet is being offloaded by HW */
 	if (skb->encapsulation &&
 	    (features & NETIF_F_CSUM_MASK || features & NETIF_F_GSO_MASK))
-		return mlx5e_vxlan_features_check(priv, skb, features);
+		return mlx5e_tunnel_features_check(priv, skb, features);
 
 	return features;
 }
@@ -4014,20 +4017,32 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	if (mlx5e_vxlan_allowed(mdev)) {
-		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
-					   NETIF_F_GSO_UDP_TUNNEL_CSUM |
-					   NETIF_F_GSO_PARTIAL;
+	if (mlx5e_vxlan_allowed(mdev) || MLX5_CAP_ETH(mdev, tunnel_stateless_gre)) {
+		netdev->hw_features     |= NETIF_F_GSO_PARTIAL;
 		netdev->hw_enc_features |= NETIF_F_IP_CSUM;
 		netdev->hw_enc_features |= NETIF_F_IPV6_CSUM;
 		netdev->hw_enc_features |= NETIF_F_TSO;
 		netdev->hw_enc_features |= NETIF_F_TSO6;
-		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
-		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM |
-					   NETIF_F_GSO_PARTIAL;
+		netdev->hw_enc_features |= NETIF_F_GSO_PARTIAL;
+	}
+
+	if (mlx5e_vxlan_allowed(mdev)) {
+		netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
+					   NETIF_F_GSO_UDP_TUNNEL_CSUM;
+		netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL |
+					   NETIF_F_GSO_UDP_TUNNEL_CSUM;
 		netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
 	}
 
+	if (MLX5_CAP_ETH(mdev, tunnel_stateless_gre)) {
+		netdev->hw_features     |= NETIF_F_GSO_GRE |
+					   NETIF_F_GSO_GRE_CSUM;
+		netdev->hw_enc_features |= NETIF_F_GSO_GRE |
+					   NETIF_F_GSO_GRE_CSUM;
+		netdev->gso_partial_features |= NETIF_F_GSO_GRE |
+						NETIF_F_GSO_GRE_CSUM;
+	}
+
 	mlx5_query_port_fcs(mdev, &fcs_supported, &fcs_enabled);
 
 	if (fcs_supported)
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index ae7d09b9c52f..3d5d32e5446c 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -602,7 +602,7 @@ struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
 	u8         reserved_at_1a[0x1];
 	u8         tunnel_lso_const_out_ip_id[0x1];
 	u8         reserved_at_1c[0x2];
-	u8         tunnel_statless_gre[0x1];
+	u8         tunnel_stateless_gre[0x1];
 	u8         tunnel_stateless_vxlan[0x1];
 
 	u8         swp[0x1];
-- 
2.13.0
