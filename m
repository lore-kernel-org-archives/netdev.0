From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 17/21] datapath: Always use tun_key addresses for route lookup
Date: Thu, 24 May 2012 18:09:10 +0900
Message-ID: <1337850554-10339-18-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46661 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561Ab2EXJJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:29 -0400
In-Reply-To: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tun_key should always be present and correct.
Mutable no longer stores correct address information
and the saddr and daddr fields will be removed.

Cc: Kyle Mestery <kmestery@cisco.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 datapath/tunnel.c | 42 +++++++++++++++++-------------------------
 1 file changed, 17 insertions(+), 25 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index b997cb8..ba18055 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -690,46 +690,44 @@ static inline int rt_genid(struct net *net)
 }
 #endif
 
-static struct rtable *__find_route(const struct tnl_mutable_config *mutable,
-				   u8 ipproto, __be32 daddr, __be32 saddr,
-				   u8 tos)
+static struct rtable *__find_route(struct net *net, u8 ipproto,
+				   struct ovs_key_ipv4_tunnel *tun_key, u8 tos)
 {
 	/* Tunnel configuration keeps DSCP part of TOS bits, But Linux
 	 * router expect RT_TOS bits only. */
 
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,39)
 	struct flowi fl = { .nl_u = { .ip4_u = {
-					.daddr = daddr,
-					.saddr = saddr,
+					.daddr = tun_key->ipv4_dst,
+					.saddr = tun_key->ipv4_src,
 					.tos   = RT_TOS(tos) } },
 					.proto = ipproto };
 	struct rtable *rt;
 
-	if (unlikely(ip_route_output_key(port_key_get_net(&mutable->key), &rt, &fl)))
+	if (unlikely(ip_route_output_key(net, &rt, &fl)))
 		return ERR_PTR(-EADDRNOTAVAIL);
 
 	return rt;
 #else
-	struct flowi4 fl = { .daddr = daddr,
-			     .saddr = saddr,
+	struct flowi4 fl = { .daddr = tun_key->ipv4_dst,
+			     .saddr = tun_key->ipv4_src,
 			     .flowi4_tos = RT_TOS(tos),
 			     .flowi4_proto = ipproto };
 
-	return ip_route_output_key(port_key_get_net(&mutable->key), &fl);
+	return ip_route_output_key(net, &fl);
 #endif
 }
 
-static struct rtable *find_route(struct vport *vport,
-				 const struct tnl_mutable_config *mutable,
-				 u8 tos, __be32 daddr, __be32 saddr)
+static struct rtable *find_route(struct vport *vport, struct net *net,
+				 struct ovs_key_ipv4_tunnel *tun_key, u8 tos)
 {
 	struct tnl_vport *tnl_vport = tnl_vport_priv(vport);
 	struct rtable *rt;
 
 	tos = RT_TOS(tos);
 
-	rt = __find_route(mutable, tnl_vport->tnl_ops->ipproto,
-			  daddr, saddr, tos);
+	rt = __find_route(net, tnl_vport->tnl_ops->ipproto,
+			  tun_key, tos);
 	if (IS_ERR(rt))
 		return NULL;
 
@@ -860,12 +858,13 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct dst_entry *unattached_dst = NULL;
 	int sent_len = 0;
 	__be16 frag_off = 0;
-	__be32 daddr;
-	__be32 saddr;
 	u8 ttl;
 	u8 inner_tos;
 	u8 tos;
 
+	if (!OVS_CB(skb)->tun_key)
+		goto error_free;
+
 	/* Validate the protocol headers before we try to use them. */
 	if (skb->protocol == htons(ETH_P_8021Q) &&
 	    !vlan_tx_tag_present(skb)) {
@@ -906,16 +905,9 @@ int ovs_tnl_send(struct vport *vport, struct sk_buff *skb)
 	else
 		tos = mutable->tos;
 
-	if (OVS_CB(skb)->tun_key) {
-		daddr = OVS_CB(skb)->tun_key->ipv4_dst;
-		saddr = OVS_CB(skb)->tun_key->ipv4_src;
-	} else {
-		daddr = mutable->key.daddr;
-		saddr = mutable->key.saddr;
-	}
-
 	/* Route lookup */
-	rt = find_route(vport, mutable, tos, daddr, saddr);
+	rt = find_route(vport, port_key_get_net(&mutable->key),
+			OVS_CB(skb)->tun_key, tos);
 	if (unlikely(!rt))
 		goto error_free;
 	unattached_dst = &rt_dst(rt);
-- 
1.7.10.2.484.gcd07cc5
