From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 4/7] net/mlx5e: Make sure the FW max encap size is enough for ipv6 tunnels
Date: Sun, 23 Apr 2017 13:07:59 +0300
Message-ID: <20170423100802.27630-5-saeedm@mellanox.com>
References: <20170423100802.27630-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48685 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1044741AbdDWKIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 06:08:12 -0400
In-Reply-To: <20170423100802.27630-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Otherwise the code that fills the ipv6 encapsulation headers could be writing
beyond the allocated headers buffer.

Fixes: ce99f6b97fcd ('net/mlx5e: Support SRIOV TC encapsulation offloads for IPv6 tunnels')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 42 ++++++++++++++-----------
 1 file changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index fc7c1d30461c..5436866798f4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -819,16 +819,15 @@ static void gen_vxlan_header_ipv4(struct net_device *out_dev,
 	vxh->vx_vni = vxlan_vni_field(vx_vni);
 }
 
-static int gen_vxlan_header_ipv6(struct net_device *out_dev,
-				 char buf[],
-				 unsigned char h_dest[ETH_ALEN],
-				 int ttl,
-				 struct in6_addr *daddr,
-				 struct in6_addr *saddr,
-				 __be16 udp_dst_port,
-				 __be32 vx_vni)
+static void gen_vxlan_header_ipv6(struct net_device *out_dev,
+				  char buf[], int encap_size,
+				  unsigned char h_dest[ETH_ALEN],
+				  int ttl,
+				  struct in6_addr *daddr,
+				  struct in6_addr *saddr,
+				  __be16 udp_dst_port,
+				  __be32 vx_vni)
 {
-	int encap_size = VXLAN_HLEN + sizeof(struct ipv6hdr) + ETH_HLEN;
 	struct ethhdr *eth = (struct ethhdr *)buf;
 	struct ipv6hdr *ip6h = (struct ipv6hdr *)((char *)eth + sizeof(struct ethhdr));
 	struct udphdr *udp = (struct udphdr *)((char *)ip6h + sizeof(struct ipv6hdr));
@@ -850,8 +849,6 @@ static int gen_vxlan_header_ipv6(struct net_device *out_dev,
 	udp->dest = udp_dst_port;
 	vxh->vx_flags = VXLAN_HF_VNI;
 	vxh->vx_vni = vxlan_vni_field(vx_vni);
-
-	return encap_size;
 }
 
 static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
@@ -935,13 +932,20 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 
 {
 	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
+	int ipv6_encap_size = ETH_HLEN + sizeof(struct ipv6hdr) + VXLAN_HLEN;
 	struct ip_tunnel_key *tun_key = &e->tun_info.key;
-	int encap_size, err, ttl = 0;
 	struct neighbour *n = NULL;
 	struct flowi6 fl6 = {};
 	char *encap_header;
+	int err, ttl = 0;
 
-	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
+	if (max_encap_size < ipv6_encap_size) {
+		mlx5_core_warn(priv->mdev, "encap size %d too big, max supported is %d\n",
+			       ipv6_encap_size, max_encap_size);
+		return -EOPNOTSUPP;
+	}
+
+	encap_header = kzalloc(ipv6_encap_size, GFP_KERNEL);
 	if (!encap_header)
 		return -ENOMEM;
 
@@ -977,11 +981,11 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 
 	switch (e->tunnel_type) {
 	case MLX5_HEADER_TYPE_VXLAN:
-		encap_size = gen_vxlan_header_ipv6(*out_dev, encap_header,
-						   e->h_dest, ttl,
-						   &fl6.daddr,
-						   &fl6.saddr, tun_key->tp_dst,
-						   tunnel_id_to_key32(tun_key->tun_id));
+		gen_vxlan_header_ipv6(*out_dev, encap_header,
+				      ipv6_encap_size, e->h_dest, ttl,
+				      &fl6.daddr,
+				      &fl6.saddr, tun_key->tp_dst,
+				      tunnel_id_to_key32(tun_key->tun_id));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -989,7 +993,7 @@ static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
 	}
 
 	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
-			       encap_size, encap_header, &e->encap_id);
+			       ipv6_encap_size, encap_header, &e->encap_id);
 out:
 	if (err && n)
 		neigh_release(n);
-- 
2.11.0
