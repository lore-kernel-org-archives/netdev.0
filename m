From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v3 6/6] vxlan: allow multiple VXLANs with same VNI for IPv6 link-local addresses
Date: Mon, 19 Jun 2017 10:04:00 +0200
Message-ID: <bf92a10551d3e216aa70668d4f220e3fcc54db29.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:55212 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753580AbdFSIEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 04:04:11 -0400
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As link-local addresses are only valid for a single interface, we can allow
to use the same VNI for multiple independent VXLANs, as long as the used
interfaces are distinct. This way, VXLANs can always be used as a drop-in
replacement for VLANs with greater ID space.

This also extends VNI lookup to respect the ifindex when link-local IPv6
addresses are used, so using the same VNI on multiple interfaces can
actually work.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

Notes:
    v2: use VXLAN_F_IPV6_LINKLOCAL in vxlan_vs_find_vni; rebase
    v3: rebase

 drivers/net/vxlan.c | 68 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 45a8a5475f3d..653b2bb32be1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -226,7 +226,8 @@ static struct vxlan_sock *vxlan_find_sock(struct net *net, sa_family_t family,
 	return NULL;
 }
 
-static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, __be32 vni)
+static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, int ifindex,
+					   __be32 vni)
 {
 	struct vxlan_dev *vxlan;
 
@@ -235,17 +236,27 @@ static struct vxlan_dev *vxlan_vs_find_vni(struct vxlan_sock *vs, __be32 vni)
 		vni = 0;
 
 	hlist_for_each_entry_rcu(vxlan, vni_head(vs, vni), hlist) {
-		if (vxlan->default_dst.remote_vni == vni)
-			return vxlan;
+		if (vxlan->default_dst.remote_vni != vni)
+			continue;
+
+		if (IS_ENABLED(CONFIG_IPV6)) {
+			const struct vxlan_config *cfg = &vxlan->cfg;
+
+			if ((cfg->flags & VXLAN_F_IPV6_LINKLOCAL) &&
+			    cfg->remote_ifindex != ifindex)
+				continue;
+		}
+
+		return vxlan;
 	}
 
 	return NULL;
 }
 
 /* Look up VNI in a per net namespace table */
-static struct vxlan_dev *vxlan_find_vni(struct net *net, __be32 vni,
-					sa_family_t family, __be16 port,
-					u32 flags)
+static struct vxlan_dev *vxlan_find_vni(struct net *net, int ifindex,
+					__be32 vni, sa_family_t family,
+					__be16 port, u32 flags)
 {
 	struct vxlan_sock *vs;
 
@@ -253,7 +264,7 @@ static struct vxlan_dev *vxlan_find_vni(struct net *net, __be32 vni,
 	if (!vs)
 		return NULL;
 
-	return vxlan_vs_find_vni(vs, vni);
+	return vxlan_vs_find_vni(vs, ifindex, vni);
 }
 
 /* Fill in neighbour message in skbuff. */
@@ -1360,7 +1371,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 
 	vni = vxlan_vni(vxlan_hdr(skb)->vx_vni);
 
-	vxlan = vxlan_vs_find_vni(vs, vni);
+	vxlan = vxlan_vs_find_vni(vs, skb->dev->ifindex, vni);
 	if (!vxlan)
 		goto drop;
 
@@ -2022,8 +2033,10 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 }
 
 static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
-				 struct vxlan_dev *vxlan, union vxlan_addr *daddr,
-				 __be16 dst_port, __be32 vni, struct dst_entry *dst,
+				 struct vxlan_dev *vxlan,
+				 union vxlan_addr *daddr,
+				 __be16 dst_port, int dst_ifindex, __be32 vni,
+				 struct dst_entry *dst,
 				 u32 rt_flags)
 {
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2039,7 +2052,7 @@ static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
 		struct vxlan_dev *dst_vxlan;
 
 		dst_release(dst);
-		dst_vxlan = vxlan_find_vni(vxlan->net, vni,
+		dst_vxlan = vxlan_find_vni(vxlan->net, dst_ifindex, vni,
 					   daddr->sa.sa_family, dst_port,
 					   vxlan->cfg.flags);
 		if (!dst_vxlan) {
@@ -2071,6 +2084,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct dst_entry *ndst = NULL;
 	__be32 vni, label;
 	__u8 tos, ttl;
+	int ifindex;
 	int err;
 	u32 flags = vxlan->cfg.flags;
 	bool udp_sum = false;
@@ -2091,6 +2105,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
 		vni = (rdst->remote_vni) ? : default_vni;
+		ifindex = rdst->remote_ifindex;
 		local_ip = vxlan->cfg.saddr;
 		dst_cache = &rdst->dst_cache;
 		md->gbp = skb->mark;
@@ -2124,6 +2139,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst = &remote_ip;
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = tunnel_id_to_key32(info->key.tun_id);
+		ifindex = 0;
 		dst_cache = &info->dst_cache;
 		if (info->options_len)
 			md = ip_tunnel_info_opts(info);
@@ -2141,8 +2157,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		struct rtable *rt;
 		__be16 df = 0;
 
-		rt = vxlan_get_route(vxlan, dev, sock4, skb,
-				     rdst ? rdst->remote_ifindex : 0, tos,
+		rt = vxlan_get_route(vxlan, dev, sock4, skb, ifindex, tos,
 				     dst->sin.sin_addr.s_addr,
 				     &local_ip.sin.sin_addr.s_addr,
 				     dst_port, src_port,
@@ -2155,8 +2170,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		/* Bypass encapsulation if the destination is local */
 		if (!info) {
 			err = encap_bypass_if_local(skb, dev, vxlan, dst,
-						    dst_port, vni, &rt->dst,
-						    rt->rt_flags);
+						    dst_port, ifindex, vni,
+						    &rt->dst, rt->rt_flags);
 			if (err)
 				goto out_unlock;
 		} else if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT) {
@@ -2178,8 +2193,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		struct vxlan_sock *sock6 = rcu_dereference(vxlan->vn6_sock);
 
-		ndst = vxlan6_get_route(vxlan, dev, sock6, skb,
-					rdst ? rdst->remote_ifindex : 0, tos,
+		ndst = vxlan6_get_route(vxlan, dev, sock6, skb, ifindex, tos,
 					label, &dst->sin6.sin6_addr,
 					&local_ip.sin6.sin6_addr,
 					dst_port, src_port,
@@ -2194,8 +2208,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			u32 rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
 
 			err = encap_bypass_if_local(skb, dev, vxlan, dst,
-						    dst_port, vni, ndst,
-						    rt6i_flags);
+						    dst_port, ifindex, vni,
+						    ndst, rt6i_flags);
 			if (err)
 				goto out_unlock;
 		}
@@ -2993,11 +3007,19 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		if (tmp == old)
 			continue;
 
-		if (tmp->cfg.vni == conf->vni &&
-		    tmp->cfg.dst_port == conf->dst_port &&
-		    (tmp->cfg.flags & (VXLAN_F_RCV_FLAGS | VXLAN_F_IPV6)) ==
+		if (tmp->cfg.vni != conf->vni)
+			continue;
+		if (tmp->cfg.dst_port != conf->dst_port)
+			continue;
+		if ((tmp->cfg.flags & (VXLAN_F_RCV_FLAGS | VXLAN_F_IPV6)) !=
 		    (conf->flags & (VXLAN_F_RCV_FLAGS | VXLAN_F_IPV6)))
-			return -EEXIST;
+			continue;
+
+		if ((conf->flags & VXLAN_F_IPV6_LINKLOCAL) &&
+		    tmp->cfg.remote_ifindex != conf->remote_ifindex)
+			continue;
+
+		return -EEXIST;
 	}
 
 	return 0;
-- 
2.13.1
