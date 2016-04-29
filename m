From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 6/9] mlx4: Add support for inner IPv6 checksum
 offloads and TSO
Date: Fri, 29 Apr 2016 15:43:39 -0700
Message-ID: <20160429224339.12418.53462.stgit@ahduyck-xeon-server>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36374 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbcD2Wnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:43:41 -0400
Received: by mail-pf0-f178.google.com with SMTP id c189so54622852pfb.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:43:41 -0700 (PDT)
In-Reply-To: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From what I can tell the ConnectX-3 will support an inner IPv6 checksum and
segmentation offload, however it cannot support outer IPv6 headers.  This
assumption is based on the fact that I could see the checksum being
offloaded for inner header on IPv4 tunnels, but not on IPv6 tunnels.

For this reason I am adding the feature to the hw_enc_features and adding
an extra check to the features_check call that will disable GSO and
checksum offload in the case that the encapsulated frame has an outer IP
version of that is not 4.  The check in mlx4_en_features_check could be
removed if at some point in the future a fix is found that allows the
hardware to offload segmentation/checksum on tunnels with an outer IPv6
header.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   25 +++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   15 ++++++++++++--
 2 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bce37cbfde24..6f28ac58251c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2357,8 +2357,10 @@ out:
 	}
 
 	/* set offloads */
-	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-				      NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+	priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+				      NETIF_F_RXCSUM |
+				      NETIF_F_TSO | NETIF_F_TSO6 |
+				      NETIF_F_GSO_UDP_TUNNEL |
 				      NETIF_F_GSO_UDP_TUNNEL_CSUM |
 				      NETIF_F_GSO_PARTIAL;
 }
@@ -2369,8 +2371,10 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
 						 vxlan_del_task);
 	/* unset offloads */
-	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+	priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+					NETIF_F_RXCSUM |
+					NETIF_F_TSO | NETIF_F_TSO6 |
+					NETIF_F_GSO_UDP_TUNNEL |
 					NETIF_F_GSO_UDP_TUNNEL_CSUM |
 					NETIF_F_GSO_PARTIAL);
 
@@ -2431,7 +2435,18 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 						netdev_features_t features)
 {
 	features = vlan_features_check(skb, features);
-	return vxlan_features_check(skb, features);
+	features = vxlan_features_check(skb, features);
+
+	/* The ConnectX-3 doesn't support outer IPv6 checksums but it does
+	 * support inner IPv6 checksums and segmentation so  we need to
+	 * strip that feature if this is an IPv6 encapsulated frame.
+	 */
+	if (skb->encapsulation &&
+	    (skb->ip_summed == CHECKSUM_PARTIAL) &&
+	    (ip_hdr(skb)->version != 4))
+		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+
+	return features;
 }
 #endif
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index a386f047c1af..0f206a95429c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -41,6 +41,7 @@
 #include <linux/vmalloc.h>
 #include <linux/tcp.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/moduleparam.h>
 
 #include "mlx4_en.h"
@@ -920,8 +921,18 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 				 tx_ind, fragptr);
 
 	if (skb->encapsulation) {
-		struct iphdr *ipv4 = (struct iphdr *)skb_inner_network_header(skb);
-		if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol == IPPROTO_UDP)
+		union {
+			struct iphdr *v4;
+			struct ipv6hdr *v6;
+			unsigned char *hdr;
+		} ip;
+		u8 proto;
+
+		ip.hdr = skb_inner_network_header(skb);
+		proto = (ip.v4->version == 4) ? ip.v4->protocol :
+						ip.v6->nexthdr;
+
+		if (proto == IPPROTO_TCP || proto == IPPROTO_UDP)
 			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP | MLX4_WQE_CTRL_ILP);
 		else
 			op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
