From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/7] net/mlx5e: Make sure the FW max encap size is enough for ipv4 tunnels
Date: Sun, 23 Apr 2017 13:07:58 +0300
Message-ID: <20170423100802.27630-4-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48687 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044743AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Otherwise the code that fills the ipv4 encapsulation headers could be writing
beyond the allocated headers buffer.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 42 ++++++++++++++-----------
 1 file changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index b7c99c38a7c4..fc7c1d30461c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -786,16 +786,15 @@ static int mlx5e_route_lookup_ipv6(struct mlx5e_priv *priv,
 	return 0;
 }
 
-static int gen_vxlan_header_ipv4(struct net_device *out_dev,
-				 char buf[],
-				 unsigned char h_dest[ETH_ALEN],
-				 int ttl,
-				 __be32 daddr,
-				 __be32 saddr,
-				 __be16 udp_dst_port,
-				 __be32 vx_vni)
+static void gen_vxlan_header_ipv4(struct net_device *out_dev,
+				  char buf[], int encap_size,
+				  unsigned char h_dest[ETH_ALEN],
+				  int ttl,
+				  __be32 daddr,
+				  __be32 saddr,
+				  __be16 udp_dst_port,
+				  __be32 vx_vni)
 {
-	int encap_size = VXLAN_HLEN + sizeof(struct iphdr) + ETH_HLEN;
 	struct ethhdr *eth = (struct ethhdr *)buf;
 	struct iphdr  *ip = (struct iphdr *)((char *)eth + sizeof(struct ethhdr));
 	struct udphdr *udp = (struct udphdr *)((char *)ip + sizeof(struct iphdr));
@@ -818,8 +817,6 @@ static int gen_vxlan_header_ipv4(struct net_device *out_dev,
 	udp->dest = udp_dst_port;
 	vxh->vx_flags = VXLAN_HF_VNI;
 	vxh->vx_vni = vxlan_vni_field(vx_vni);
-
-	return encap_size;
 }
 
 static int gen_vxlan_header_ipv6(struct net_device *out_dev,
@@ -863,13 +860,20 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 					  struct net_device **out_dev)
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
+	int ipv4_encap_size = ETH_HLEN + sizeof(struct iphdr) + VXLAN_HLEN;
 	struct ip_tunnel_key *tun_key = &e->tun_info.key;
-	int encap_size, ttl, err;
 	struct neighbour *n = NULL;
 	struct flowi4 fl4 = {};
 	char *encap_header;
+	int ttl, err;
 
-	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
+	if (max_encap_size < ipv4_encap_size) {
+		mlx5_core_warn(priv->mdev, "encap size %d too big, max supported is %d\n",
+			       ipv4_encap_size, max_encap_size);
+		return -EOPNOTSUPP;
+	}
+
+	encap_header = kzalloc(ipv4_encap_size, GFP_KERNEL);
 	if (!encap_header)
 		return -ENOMEM;
 
@@ -904,11 +908,11 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
-		encap_size = gen_vxlan_header_ipv4(*out_dev, encap_header,
-						   e->h_dest, ttl,
-						   fl4.daddr,
-						   fl4.saddr, tun_key->tp_dst,
-						   tunnel_id_to_key32(tun_key->tun_id));
+		gen_vxlan_header_ipv4(*out_dev, encap_header,
+				      ipv4_encap_size, e->h_dest, ttl,
+				      fl4.daddr,
+				      fl4.saddr, tun_key->tp_dst,
+				      tunnel_id_to_key32(tun_key->tun_id));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -916,7 +920,7 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	}
 
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
-			       encap_size, encap_header, &e->encap_id);
+			       ipv4_encap_size, encap_header, &e->encap_id);
 out:
 	if (err && n)
 		neigh_release(n);
-- 
2.11.0
