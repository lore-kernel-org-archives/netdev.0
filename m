From: Fan Du <fan.du@intel.com>
Subject: [PATCHv3 net-next] openvswitch: Introduce ovs_tunnel_route_lookup
Date: Wed, 14 Jan 2015 13:10:35 +0800
Message-ID: <1421212235-29447-1-git-send-email-fan.du@intel.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	fengyuleidian0615@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49353 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbbANFOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 00:14:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce ovs_tunnel_route_lookup to consolidate route lookup
shared by vxlan, gre, and geneve ports.

Signed-off-by: Fan Du <fan.du@intel.com>
---
Change log:
v3:
  - Use ovs_tunnel_route_lookup for ovs_tunnel_get_egress_info
  - Constantify tun_key structure for gre, vxlan, geneve ports
    to surpress warnings.
v2:
  - Use inline instead of function call
  - Rename vport_route_lookup to ovs_tunnel_route_lookup

---
 net/openvswitch/vport-geneve.c |   13 ++-----------
 net/openvswitch/vport-gre.c    |   12 ++----------
 net/openvswitch/vport-vxlan.c  |   12 ++----------
 net/openvswitch/vport.c        |    9 +--------
 net/openvswitch/vport.h        |   18 ++++++++++++++++++
 5 files changed, 25 insertions(+), 39 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 484864d..eabe564 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -172,7 +172,7 @@ error:
 
 static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
-	struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ovs_key_ipv4_tunnel *tun_key;
 	struct ovs_tunnel_info *tun_info;
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct geneve_port *geneve_port = geneve_vport(vport);
@@ -191,16 +191,7 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	tun_key = &tun_info->tunnel;
-
-	/* Route lookup */
-	memset(&fl, 0, sizeof(fl));
-	fl.daddr = tun_key->ipv4_dst;
-	fl.saddr = tun_key->ipv4_src;
-	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
-	fl.flowi4_mark = skb->mark;
-	fl.flowi4_proto = IPPROTO_UDP;
-
-	rt = ip_route_output_key(net, &fl);
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto error;
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index d4168c4..1aa4921 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -134,7 +134,7 @@ static int gre_err(struct sk_buff *skb, u32 info,
 static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
-	struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ovs_key_ipv4_tunnel *tun_key;
 	struct flowi4 fl;
 	struct rtable *rt;
 	int min_headroom;
@@ -148,15 +148,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
-	/* Route lookup */
-	memset(&fl, 0, sizeof(fl));
-	fl.daddr = tun_key->ipv4_dst;
-	fl.saddr = tun_key->ipv4_src;
-	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
-	fl.flowi4_mark = skb->mark;
-	fl.flowi4_proto = IPPROTO_GRE;
-
-	rt = ip_route_output_key(net, &fl);
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_GRE);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto err_free_skb;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d7c46b3..1435a05 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -145,7 +145,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	struct net *net = ovs_dp_get_net(vport->dp);
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
 	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
-	struct ovs_key_ipv4_tunnel *tun_key;
+	const struct ovs_key_ipv4_tunnel *tun_key;
 	struct rtable *rt;
 	struct flowi4 fl;
 	__be16 src_port;
@@ -158,15 +158,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	tun_key = &OVS_CB(skb)->egress_tun_info->tunnel;
-	/* Route lookup */
-	memset(&fl, 0, sizeof(fl));
-	fl.daddr = tun_key->ipv4_dst;
-	fl.saddr = tun_key->ipv4_src;
-	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
-	fl.flowi4_mark = skb->mark;
-	fl.flowi4_proto = IPPROTO_UDP;
-
-	rt = ip_route_output_key(net, &fl);
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb->mark, &fl, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto error;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 2034c6d..fb9d5fb 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -594,14 +594,7 @@ int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
 	 * The process may need to be changed if the corresponding process
 	 * in vports ops changed.
 	 */
-	memset(&fl, 0, sizeof(fl));
-	fl.daddr = tun_key->ipv4_dst;
-	fl.saddr = tun_key->ipv4_src;
-	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
-	fl.flowi4_mark = skb_mark;
-	fl.flowi4_proto = ipproto;
-
-	rt = ip_route_output_key(net, &fl);
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb_mark, &fl, ipproto);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 99c8e71..f8ae295 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -236,4 +236,22 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 int ovs_vport_ops_register(struct vport_ops *ops);
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 
+static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
+						     const struct ovs_key_ipv4_tunnel *key,
+						     u32 mark,
+						     struct flowi4 *fl,
+						     u8 protocol)
+{
+	struct rtable *rt;
+
+	memset(fl, 0, sizeof(*fl));
+	fl->daddr = key->ipv4_dst;
+	fl->saddr = key->ipv4_src;
+	fl->flowi4_tos = RT_TOS(key->ipv4_tos);
+	fl->flowi4_mark = mark;
+	fl->flowi4_proto = protocol;
+
+	rt = ip_route_output_key(net, fl);
+	return rt;
+}
 #endif /* vport.h */
-- 
1.7.1
