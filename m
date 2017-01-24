From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/12] net/mlx5e: Support SRIOV TC encapsulation offloads for IPv6 tunnels
Date: Tue, 24 Jan 2017 22:16:46 +0200
Message-ID: <20170124201652.2920-7-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54281 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750927AbdAXURZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:25 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add the missing parts for offloading IPv6 tunnels. This includes
route and neigh lookups and construnction of the IPv6 tunnel headers.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 159 ++++++++++++++++++++++--
 1 file changed, 151 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3d0dbfb018ca..640f10f2e994 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -718,6 +718,47 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
 	return 0;
 }
 
+static int mlx5e_route_lookup_ipv6(struct mlx5e_priv *priv,
+				   struct net_device *mirred_dev,
+				   struct net_device **out_dev,
+				   struct flowi6 *fl6,
+				   struct neighbour **out_n,
+				   int *out_ttl)
+{
+	struct neighbour *n = NULL;
+	struct dst_entry *dst;
+
+#if IS_ENABLED(CONFIG_INET) && IS_ENABLED(CONFIG_IPV6)
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+	int ret;
+
+	dst = ip6_route_output(dev_net(mirred_dev), NULL, fl6);
+	if (dst->error) {
+		ret = dst->error;
+		dst_release(dst);
+		return ret;
+	}
+
+	*out_ttl = ip6_dst_hoplimit(dst);
+
+	/* if the egress device isn't on the same HW e-switch, we use the uplink */
+	if (!switchdev_port_same_parent_id(priv->netdev, dst->dev))
+		*out_dev = mlx5_eswitch_get_uplink_netdev(esw);
+	else
+		*out_dev = dst->dev;
+#else
+	return -EOPNOTSUPP;
+#endif
+
+	n = dst_neigh_lookup(dst, &fl6->daddr);
+	dst_release(dst);
+	if (!n)
+		return -ENOMEM;
+
+	*out_n = n;
+	return 0;
+}
+
 static int gen_vxlan_header_ipv4(struct net_device *out_dev,
 				 char buf[],
 				 unsigned char h_dest[ETH_ALEN],
@@ -754,6 +795,41 @@ static int gen_vxlan_header_ipv4(struct net_device *out_dev,
 	return encap_size;
 }
 
+static int gen_vxlan_header_ipv6(struct net_device *out_dev,
+				 char buf[],
+				 unsigned char h_dest[ETH_ALEN],
+				 int ttl,
+				 struct in6_addr *daddr,
+				 struct in6_addr *saddr,
+				 __be16 udp_dst_port,
+				 __be32 vx_vni)
+{
+	int encap_size = VXLAN_HLEN + sizeof(struct ipv6hdr) + ETH_HLEN;
+	struct ethhdr *eth = (struct ethhdr *)buf;
+	struct ipv6hdr *ip6h = (struct ipv6hdr *)((char *)eth + sizeof(struct ethhdr));
+	struct udphdr *udp = (struct udphdr *)((char *)ip6h + sizeof(struct ipv6hdr));
+	struct vxlanhdr *vxh = (struct vxlanhdr *)((char *)udp + sizeof(struct udphdr));
+
+	memset(buf, 0, encap_size);
+
+	ether_addr_copy(eth->h_dest, h_dest);
+	ether_addr_copy(eth->h_source, out_dev->dev_addr);
+	eth->h_proto = htons(ETH_P_IPV6);
+
+	ip6_flow_hdr(ip6h, 0, 0);
+	/* the HW fills up ipv6 payload len */
+	ip6h->nexthdr     = IPPROTO_UDP;
+	ip6h->hop_limit   = ttl;
+	ip6h->daddr	  = *daddr;
+	ip6h->saddr	  = *saddr;
+
+	udp->dest = udp_dst_port;
+	vxh->vx_flags = VXLAN_HF_VNI;
+	vxh->vx_vni = vxlan_vni_field(vx_vni);
+
+	return encap_size;
+}
+
 static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 					  struct net_device *mirred_dev,
 					  struct mlx5_encap_entry *e,
@@ -821,6 +897,75 @@ static int mlx5e_create_encap_header_ipv4(struct mlx5e_priv *priv,
 	return err;
 }
 
+static int mlx5e_create_encap_header_ipv6(struct mlx5e_priv *priv,
+					  struct net_device *mirred_dev,
+					  struct mlx5_encap_entry *e,
+					  struct net_device **out_dev)
+
+{
+	int max_encap_size = MLX5_CAP_ESW(priv->mdev, max_encap_header_size);
+	struct ip_tunnel_key *tun_key = &e->tun_info.key;
+	int encap_size, err, ttl = 0;
+	struct neighbour *n = NULL;
+	struct flowi6 fl6 = {};
+	char *encap_header;
+
+	encap_header = kzalloc(max_encap_size, GFP_KERNEL);
+	if (!encap_header)
+		return -ENOMEM;
+
+	switch (e->tunnel_type) {
+	case MLX5_HEADER_TYPE_VXLAN:
+		fl6.flowi6_proto = IPPROTO_UDP;
+		fl6.fl6_dport = tun_key->tp_dst;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tun_key->tos), tun_key->label);
+	fl6.daddr = tun_key->u.ipv6.dst;
+	fl6.saddr = tun_key->u.ipv6.src;
+
+	err = mlx5e_route_lookup_ipv6(priv, mirred_dev, out_dev,
+				      &fl6, &n, &ttl);
+	if (err)
+		goto out;
+
+	if (!(n->nud_state & NUD_VALID)) {
+		pr_warn("%s: can't offload, neighbour to %pI6 invalid\n", __func__, &fl6.daddr);
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	e->n = n;
+	e->out_dev = *out_dev;
+
+	neigh_ha_snapshot(e->h_dest, n, *out_dev);
+
+	switch (e->tunnel_type) {
+	case MLX5_HEADER_TYPE_VXLAN:
+		encap_size = gen_vxlan_header_ipv6(*out_dev, encap_header,
+						   e->h_dest, ttl,
+						   &fl6.daddr,
+						   &fl6.saddr, tun_key->tp_dst,
+						   tunnel_id_to_key32(tun_key->tun_id));
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	err = mlx5_encap_alloc(priv->mdev, e->tunnel_type,
+			       encap_size, encap_header, &e->encap_id);
+out:
+	if (err && n)
+		neigh_release(n);
+	kfree(encap_header);
+	return err;
+}
+
 static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 			      struct ip_tunnel_info *tun_info,
 			      struct net_device *mirred_dev,
@@ -831,7 +976,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	struct ip_tunnel_key *key = &tun_info->key;
 	struct mlx5_encap_entry *e;
 	struct net_device *out_dev;
-	int tunnel_type, err;
+	int tunnel_type, err = -EOPNOTSUPP;
 	uintptr_t hash_key;
 	bool found = false;
 
@@ -856,12 +1001,6 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 		return -EOPNOTSUPP;
 	}
 
-	if (family == AF_INET6) {
-		netdev_warn(priv->netdev,
-			    "IPv6 tunnel encap offload isn't supported\n");
-		return -EOPNOTSUPP;
-	}
-
 	hash_key = hash_encap_info(key);
 
 	hash_for_each_possible_rcu(esw->offloads.encap_tbl, e,
@@ -885,7 +1024,11 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 	e->tunnel_type = tunnel_type;
 	INIT_LIST_HEAD(&e->flows);
 
-	err = mlx5e_create_encap_header_ipv4(priv, mirred_dev, e, &out_dev);
+	if (family == AF_INET)
+		err = mlx5e_create_encap_header_ipv4(priv, mirred_dev, e, &out_dev);
+	else if (family == AF_INET6)
+		err = mlx5e_create_encap_header_ipv6(priv, mirred_dev, e, &out_dev);
+
 	if (err)
 		goto out_err;
 
-- 
2.11.0
