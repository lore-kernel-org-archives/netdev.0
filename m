From: Fan Du <fan.du@intel.com>
Subject: [PATCHv2 net-next] openvswitch: Introduce ovs_tunnel_route_lookup
Date: Tue, 13 Jan 2015 10:41:23 +0800
Message-ID: <1421116883-26839-1-git-send-email-fan.du@intel.com>
References: <1421054087-25632-1-git-send-email-fan.du@intel.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58140 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405AbbAMCpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 21:45:01 -0500
In-Reply-To: <1421054087-25632-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce ovs_tunnel_route_lookup to consolidate route lookup
shared by vxlan, gre, and geneve ports.

Signed-off-by: Fan Du <fan.du@intel.com>
---
Chnage log:
v2:
  - Use inline instead of function call
  - Rename vport_route_lookup to ovs_tunnel_route_lookup
---
 net/openvswitch/vport-geneve.c |   11 +----------
 net/openvswitch/vport-gre.c    |   10 +---------
 net/openvswitch/vport-vxlan.c  |   10 +---------
 net/openvswitch/vport.h        |   18 ++++++++++++++++++
 4 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 484864d..0953c9f 100644
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
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb, &fl, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto error;
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index d4168c4..3171e03 100644
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
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb, &fl, IPPROTO_GRE);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto err_free_skb;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index d7c46b3..1528090 100644
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
+	rt = ovs_tunnel_route_lookup(net, tun_key, skb, &fl, IPPROTO_UDP);
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		goto error;
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 99c8e71..7b97661 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -236,4 +236,22 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 int ovs_vport_ops_register(struct vport_ops *ops);
 void ovs_vport_ops_unregister(struct vport_ops *ops);
 
+static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
+						     struct ovs_key_ipv4_tunnel *key,
+						     struct sk_buff *skb,
+						     struct flowi4 *fl,
+						     u8 protocol)
+{
+	struct rtable *rt;
+
+	memset(fl, 0, sizeof(*fl));
+	fl->daddr = key->ipv4_dst;
+	fl->saddr = key->ipv4_src;
+	fl->flowi4_tos = RT_TOS(key->ipv4_tos);
+	fl->flowi4_mark = skb->mark;
+	fl->flowi4_proto = protocol;
+
+	rt = ip_route_output_key(net, fl);
+	return rt;
+}
 #endif /* vport.h */
-- 
1.7.1
