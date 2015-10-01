From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 4/4] openvswitch: IPv6 support for ovs_tunnel_get_egress_info
Date: Thu,  1 Oct 2015 16:44:42 +0200
Message-ID: <8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
References: <cover.1443710454.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55259 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753170AbbJAOpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 10:45:17 -0400
In-Reply-To: <cover.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For compat tunnel interfaces, reject IPv6 keys.

Also fixes a related thinko in vport-vxlan: upcall->egress_tun_info is not
yet set at the point where it is used, thus the obtained family is
incorrect. As this is IPv4 anyway, just use AF_INET.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
New patch in v2 of the set.
---
 net/openvswitch/vport-geneve.c |  4 ++-
 net/openvswitch/vport-gre.c    |  4 ++-
 net/openvswitch/vport-vxlan.c  |  6 ++--
 net/openvswitch/vport.c        | 62 ++++++++++++++++++++++++++++--------------
 net/openvswitch/vport.h        | 26 ++++++++++++++++++
 5 files changed, 77 insertions(+), 25 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 2735e9c4a3b8..601fa3fbb19a 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -60,7 +60,9 @@ static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 	__be16 dport = htons(geneve_port->port_no);
 	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
 
-	return ovs_tunnel_get_egress_info(upcall, ovs_dp_get_net(vport->dp),
+	/* Only IPv4 supported in the compat layer. Pass NULL ipv6 socket. */
+	return ovs_tunnel_get_egress_info(upcall,
+					  ovs_dp_get_net(vport->dp), NULL,
 					  skb, IPPROTO_UDP, sport, dport);
 }
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 4d24481669c9..a3cf5695031d 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -87,7 +87,9 @@ static struct vport *gre_create(const struct vport_parms *parms)
 static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 				   struct dp_upcall_info *upcall)
 {
-	return ovs_tunnel_get_egress_info(upcall, ovs_dp_get_net(vport->dp),
+	/* Only IPv4 supported. Pass NULL ipv6 socket. */
+	return ovs_tunnel_get_egress_info(upcall,
+					  ovs_dp_get_net(vport->dp), NULL,
 					  skb, IPPROTO_GRE, 0, 0);
 }
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index fb3cdb85905d..0973acb5432c 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -151,8 +151,7 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 {
 	struct vxlan_dev *vxlan = netdev_priv(vport->dev);
 	struct net *net = ovs_dp_get_net(vport->dp);
-	unsigned short family = ip_tunnel_info_af(upcall->egress_tun_info);
-	__be16 dst_port = vxlan_dev_dst_port(vxlan, family);
+	__be16 dst_port = vxlan_dev_dst_port(vxlan, AF_INET);
 	__be16 src_port;
 	int port_min;
 	int port_max;
@@ -160,7 +159,8 @@ static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 	inet_get_local_port_range(net, &port_min, &port_max);
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 
-	return ovs_tunnel_get_egress_info(upcall, net,
+	/* Only IPv4 supported in the compat layer. Pass NULL ipv6 socket. */
+	return ovs_tunnel_get_egress_info(upcall, net, NULL,
 					  skb, IPPROTO_UDP,
 					  src_port, dst_port);
 }
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index dc81dc619aa2..c58d95eed5fd 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -489,6 +489,7 @@ EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
 
 int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
 			       struct net *net,
+			       struct sock *ipv6_sk,
 			       struct sk_buff *skb,
 			       u8 ipproto,
 			       __be16 tp_src,
@@ -498,13 +499,9 @@ int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
 	const struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 	const struct ip_tunnel_key *tun_key;
 	u32 skb_mark = skb->mark;
-	struct rtable *rt;
-	struct flowi4 fl;
 
 	if (unlikely(!tun_info))
 		return -EINVAL;
-	if (ip_tunnel_info_af(tun_info) != AF_INET)
-		return -EINVAL;
 
 	tun_key = &tun_info->key;
 
@@ -512,22 +509,47 @@ int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
 	 * The process may need to be changed if the corresponding process
 	 * in vports ops changed.
 	 */
-	rt = ovs_tunnel_route_lookup(net, tun_key, skb_mark, &fl, ipproto);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
-
-	ip_rt_put(rt);
-
-	/* Generate egress_tun_info based on tun_info,
-	 * saddr, tp_src and tp_dst
-	 */
-	ip_tunnel_key_init(&egress_tun_info->key,
-			   fl.saddr, tun_key->u.ipv4.dst,
-			   tun_key->tos,
-			   tun_key->ttl,
-			   tp_src, tp_dst,
-			   tun_key->tun_id,
-			   tun_key->tun_flags);
+	if (ip_tunnel_info_af(tun_info) == AF_INET) {
+		struct rtable *rt;
+		struct flowi4 fl;
+
+		rt = ovs_tunnel_route_lookup(net, tun_key, skb_mark, &fl, ipproto);
+		if (IS_ERR(rt))
+			return PTR_ERR(rt);
+
+		ip_rt_put(rt);
+
+		/* Generate egress_tun_info based on tun_info,
+		* saddr, tp_src and tp_dst
+		*/
+		ip_tunnel_key_init(&egress_tun_info->key,
+				   fl.saddr, tun_key->u.ipv4.dst,
+				   tun_key->tos,
+				   tun_key->ttl,
+				   tp_src, tp_dst,
+				   tun_key->tun_id,
+				   tun_key->tun_flags);
+	} else {
+		struct dst_entry *ndst;
+		struct flowi6 fl6;
+
+		if (!ipv6_sk)
+			return -EPFNOSUPPORT;
+
+		ndst = ovs_tunnel6_route_lookup(net, ipv6_sk, tun_key,
+						skb_mark, &fl6, ipproto);
+		if (IS_ERR(ndst))
+			return PTR_ERR(ndst);
+		dst_release(ndst);
+
+		ip6_tunnel_key_init(&egress_tun_info->key,
+				    &fl6.saddr, &tun_key->u.ipv6.dst,
+				    tun_key->tos,
+				    tun_key->ttl,
+				    tp_src, tp_dst,
+				    tun_key->tun_id,
+				    tun_key->tun_flags);
+	}
 	egress_tun_info->options_len = tun_info->options_len;
 	egress_tun_info->mode = tun_info->mode;
 	upcall->egress_tun_opts = ip_tunnel_info_opts(egress_tun_info);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index a413f3ae6a7b..8445d931e863 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -27,6 +27,8 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/u64_stats_sync.h>
+#include <net/addrconf.h>
+#include <net/ipv6.h>
 #include <net/route.h>
 
 #include "datapath.h"
@@ -55,6 +57,7 @@ u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
 int ovs_tunnel_get_egress_info(struct dp_upcall_info *upcall,
 			       struct net *net,
+			       struct sock *ipv6_sk,
 			       struct sk_buff *,
 			       u8 ipproto,
 			       __be16 tp_src,
@@ -234,6 +237,29 @@ static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
 	return rt;
 }
 
+static inline struct dst_entry *ovs_tunnel6_route_lookup(struct net *net,
+							 struct sock *sk,
+							 const struct ip_tunnel_key *key,
+							 u32 mark,
+							 struct flowi6 *fl6,
+							 u8 protocol)
+{
+	struct dst_entry *dst;
+	int err;
+
+	memset(fl6, 0, sizeof(*fl6));
+	fl6->daddr = key->u.ipv6.dst;
+	fl6->saddr = key->u.ipv6.src;
+	fl6->flowi6_tos = RT_TOS(key->tos);
+	fl6->flowi6_mark = mark;
+	fl6->flowi6_proto = protocol;
+
+	err = ipv6_stub->ipv6_dst_lookup(net, sk, &dst, fl6);
+	if (err)
+		return ERR_PTR(err);
+	return dst;
+}
+
 static inline void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 {
 	vport->ops->send(vport, skb);
-- 
1.8.3.1
