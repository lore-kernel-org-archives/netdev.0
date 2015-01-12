From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next] openvswitch: Introduce vport_route_lookup
Date: Mon, 12 Jan 2015 17:14:47 +0800
Message-ID: <1421054087-25632-1-git-send-email-fan.du@intel.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33445 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbbALJSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 04:18:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce vport_route_lookup to consolidate route lookup
shared by vxlan, gre, and geneve ports.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/openvswitch/vport-geneve.c |   11 +----------
 net/openvswitch/vport-gre.c    |   10 +---------
 net/openvswitch/vport-vxlan.c  |   10 +---------
 net/openvswitch/vport.c        |   20 ++++++++++++++++++++
 net/openvswitch/vport.h        |    6 ++++++
 5 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 484864d..8eef7f6 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
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
+	rt = vport_route_lookup(tun_key, skb, &fl, net, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto error;
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index d4168c4..2f8fdbe 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
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
+	rt = vport_route_lookup(tun_key, skb, &fl, net, IPPROTO_GRE);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto err_free_skb;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d7c46b3..13a64ae 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
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
+	rt = vport_route_lookup(tun_key, skb, &fl, net, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto error;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 2034c6d..32b0edf 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -633,3 +633,23 @@ int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 
 	return vport->ops->get_egress_tun_info(vport, skb, info);
 }
+
+struct rtable *vport_route_lookup(struct ovs_key_ipv4_tunnel *tun_key,
+				  struct sk_buff *skb,
+				  struct flowi4 *fl,
+				  struct net *net,
+				  u8 protocol)
+{
+	struct rtable *rt;
+
+	memset(fl, 0, sizeof(*fl));
+	fl->daddr = tun_key->ipv4_dst;
+	fl->saddr = tun_key->ipv4_src;
+	fl->flowi4_tos = RT_TOS(tun_key->ipv4_tos);
+	fl->flowi4_mark = skb->mark;
+	fl->flowi4_proto = protocol;
+
+	rt = ip_route_output_key(net, fl);
+	return rt;
+}
+EXPORT_SYMBOL_GPL(vport_route_lookup);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 99c8e71..4487a97 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -68,6 +68,12 @@ int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 				  struct ovs_tunnel_info *info);
 
+struct rtable *vport_route_lookup(struct ovs_key_ipv4_tunnel *tun_key,
+				  struct sk_buff *skb,
+				  struct flowi4 *fl,
+				  struct net *net,
+				  u8 protocol);
+
 /* The following definitions are for implementers of vport devices: */
 
 struct vport_err_stats {
-- 
1.7.1
