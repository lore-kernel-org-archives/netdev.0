From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 04/13] ip_tunnels: add IPv6 addresses to ip_tunnel_key
Date: Tue, 18 Aug 2015 22:33:13 +0200
Message-ID: <199ae8362eabd65661ab145e9bfc281c5f5470ad.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555AbbHRUdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:46 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c            |  6 +++---
 include/net/ip_tunnels.h       | 23 +++++++++++++++++++----
 net/core/filter.c              |  4 ++--
 net/ipv4/ip_gre.c              | 10 +++++-----
 net/ipv4/ip_tunnel_core.c      |  8 ++++----
 net/openvswitch/flow_netlink.c | 18 +++++++++---------
 net/openvswitch/flow_table.c   |  2 +-
 net/openvswitch/vport-geneve.c |  2 +-
 net/openvswitch/vport.c        |  2 +-
 net/openvswitch/vport.h        |  4 ++--
 10 files changed, 47 insertions(+), 32 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 06c0731ae619..1c0733540756 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1276,8 +1276,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			goto drop;
 
 		info = &tun_dst->u.tun_info;
-		info->key.ipv4_src = iph->saddr;
-		info->key.ipv4_dst = iph->daddr;
+		info->key.u.ipv4.src = iph->saddr;
+		info->key.u.ipv4.dst = iph->daddr;
 		info->key.ipv4_tos = iph->tos;
 		info->key.ipv4_ttl = iph->ttl;
 		info->key.tp_src = udp_hdr(skb)->source;
@@ -1925,7 +1925,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
 		vni = be64_to_cpu(info->key.tun_id);
 		remote_ip.sin.sin_family = AF_INET;
-		remote_ip.sin.sin_addr.s_addr = info->key.ipv4_dst;
+		remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
 		dst = &remote_ip;
 	}
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index cc3b39e9010b..96b0a37af42c 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -25,10 +25,23 @@
 /* Used to memset ip_tunnel padding. */
 #define IP_TUNNEL_KEY_SIZE	offsetofend(struct ip_tunnel_key, tp_dst)
 
+/* Used to memset ipv4 address padding. */
+#define IP_TUNNEL_KEY_IPV4_PAD	offsetofend(struct ip_tunnel_key, u.ipv4.dst)
+#define IP_TUNNEL_KEY_IPV4_PAD_LEN				\
+	(FIELD_SIZEOF(struct ip_tunnel_key, u) - IP_TUNNEL_KEY_IPV4_PAD)
+
 struct ip_tunnel_key {
 	__be64			tun_id;
-	__be32			ipv4_src;
-	__be32			ipv4_dst;
+	union {
+		struct {
+			__be32	src;
+			__be32	dst;
+		} ipv4;
+		struct {
+			struct in6_addr src;
+			struct in6_addr dst;
+		} ipv6;
+	} u;
 	__be16			tun_flags;
 	u8			ipv4_tos;
 	u8			ipv4_ttl;
@@ -177,8 +190,10 @@ static inline void __ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
 					 const void *opts, u8 opts_len)
 {
 	tun_info->key.tun_id = tun_id;
-	tun_info->key.ipv4_src = saddr;
-	tun_info->key.ipv4_dst = daddr;
+	tun_info->key.u.ipv4.src = saddr;
+	tun_info->key.u.ipv4.dst = daddr;
+	memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_IPV4_PAD,
+	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
 	tun_info->key.ipv4_tos = tos;
 	tun_info->key.ipv4_ttl = ttl;
 	tun_info->key.tun_flags = tun_flags;
diff --git a/net/core/filter.c b/net/core/filter.c
index 83f08cefeab7..379568562ffb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1495,7 +1495,7 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 		return -EINVAL;
 
 	to->tunnel_id = be64_to_cpu(info->key.tun_id);
-	to->remote_ipv4 = be32_to_cpu(info->key.ipv4_src);
+	to->remote_ipv4 = be32_to_cpu(info->key.u.ipv4.src);
 
 	return 0;
 }
@@ -1529,7 +1529,7 @@ static u64 bpf_skb_set_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	info = &md->u.tun_info;
 	info->mode = IP_TUNNEL_INFO_TX;
 	info->key.tun_id = cpu_to_be64(from->tunnel_id);
-	info->key.ipv4_dst = cpu_to_be32(from->remote_ipv4);
+	info->key.u.ipv4.dst = cpu_to_be32(from->remote_ipv4);
 
 	return 0;
 }
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fb44d693796e..b7bb7d6aa7a8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -407,8 +407,8 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 				return PACKET_REJECT;
 
 			info = &tun_dst->u.tun_info;
-			info->key.ipv4_src = iph->saddr;
-			info->key.ipv4_dst = iph->daddr;
+			info->key.u.ipv4.src = iph->saddr;
+			info->key.u.ipv4.dst = iph->daddr;
 			info->key.ipv4_tos = iph->tos;
 			info->key.ipv4_ttl = iph->ttl;
 
@@ -527,8 +527,8 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	key = &tun_info->key;
 	memset(&fl, 0, sizeof(fl));
-	fl.daddr = key->ipv4_dst;
-	fl.saddr = key->ipv4_src;
+	fl.daddr = key->u.ipv4.dst;
+	fl.saddr = key->u.ipv4.src;
 	fl.flowi4_tos = RT_TOS(key->ipv4_tos);
 	fl.flowi4_mark = skb->mark;
 	fl.flowi4_proto = IPPROTO_GRE;
@@ -564,7 +564,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
 	err = iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
-			    key->ipv4_dst, IPPROTO_GRE,
+			    key->u.ipv4.dst, IPPROTO_GRE,
 			    key->ipv4_tos, key->ipv4_ttl, df, false);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 1c2389d582a6..93907d71cda6 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -227,10 +227,10 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.tun_id = nla_get_u64(tb[LWTUNNEL_IP_ID]);
 
 	if (tb[LWTUNNEL_IP_DST])
-		tun_info->key.ipv4_dst = nla_get_be32(tb[LWTUNNEL_IP_DST]);
+		tun_info->key.u.ipv4.dst = nla_get_be32(tb[LWTUNNEL_IP_DST]);
 
 	if (tb[LWTUNNEL_IP_SRC])
-		tun_info->key.ipv4_src = nla_get_be32(tb[LWTUNNEL_IP_SRC]);
+		tun_info->key.u.ipv4.src = nla_get_be32(tb[LWTUNNEL_IP_SRC]);
 
 	if (tb[LWTUNNEL_IP_TTL])
 		tun_info->key.ipv4_ttl = nla_get_u8(tb[LWTUNNEL_IP_TTL]);
@@ -262,8 +262,8 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
 
 	if (nla_put_u64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
-	    nla_put_be32(skb, LWTUNNEL_IP_DST, tun_info->key.ipv4_dst) ||
-	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.ipv4_src) ||
+	    nla_put_be32(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
+	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.ipv4_tos) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ipv4_ttl) ||
 	    nla_put_u16(skb, LWTUNNEL_IP_SPORT, tun_info->key.tp_src) ||
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index a6eb77ab1a64..a7f866374817 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -534,11 +534,11 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			tun_flags |= TUNNEL_KEY;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_src,
+			SW_FLOW_KEY_PUT(match, tun_key.u.ipv4.src,
 					nla_get_in_addr(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_dst,
+			SW_FLOW_KEY_PUT(match, tun_key.u.ipv4.dst,
 					nla_get_in_addr(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TOS:
@@ -609,7 +609,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	}
 
 	if (!is_mask) {
-		if (!match->key->tun_key.ipv4_dst) {
+		if (!match->key->tun_key.u.ipv4.dst) {
 			OVS_NLERR(log, "IPv4 tunnel dst address is zero");
 			return -EINVAL;
 		}
@@ -647,13 +647,13 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if (output->tun_flags & TUNNEL_KEY &&
 	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
 		return -EMSGSIZE;
-	if (output->ipv4_src &&
+	if (output->u.ipv4.src &&
 	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC,
-			    output->ipv4_src))
+			    output->u.ipv4.src))
 		return -EMSGSIZE;
-	if (output->ipv4_dst &&
+	if (output->u.ipv4.dst &&
 	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST,
-			    output->ipv4_dst))
+			    output->u.ipv4.dst))
 		return -EMSGSIZE;
 	if (output->ipv4_tos &&
 	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
@@ -1116,7 +1116,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 			/* The userspace does not send tunnel attributes that
 			 * are 0, but we should not wildcard them nonetheless.
 			 */
-			if (match->key->tun_key.ipv4_dst)
+			if (match->key->tun_key.u.ipv4.dst)
 				SW_FLOW_KEY_MEMSET_FIELD(match, tun_key,
 							 0xff, true);
 
@@ -1287,7 +1287,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
-	if ((swkey->tun_key.ipv4_dst || is_mask)) {
+	if ((swkey->tun_key.u.ipv4.dst || is_mask)) {
 		const void *opts = NULL;
 
 		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 3a9d1dde76ed..d22d8e948d0f 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -426,7 +426,7 @@ static u32 flow_hash(const struct sw_flow_key *key,
 
 static int flow_key_start(const struct sw_flow_key *key)
 {
-	if (key->tun_key.ipv4_dst)
+	if (key->tun_key.u.ipv4.dst)
 		return 0;
 	else
 		return rounddown(offsetof(struct sw_flow_key, phy),
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 1da3a14d1010..023813d05f88 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -203,7 +203,7 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
-			      tun_key->ipv4_dst, tun_key->ipv4_tos,
+			      tun_key->u.ipv4.dst, tun_key->ipv4_tos,
 			      tun_key->ipv4_ttl, df, sport, dport,
 			      tun_key->tun_flags, vni, opts_len, opts,
 			      !!(tun_key->tun_flags & TUNNEL_CSUM), false);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index d14f59403c5e..a06adc72a58d 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -603,7 +603,7 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 	 * saddr, tp_src and tp_dst
 	 */
 	__ip_tunnel_info_init(egress_tun_info,
-			      fl.saddr, tun_key->ipv4_dst,
+			      fl.saddr, tun_key->u.ipv4.dst,
 			      tun_key->ipv4_tos,
 			      tun_key->ipv4_ttl,
 			      tp_src, tp_dst,
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1a689c28b5a6..43d8f5a835cb 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -254,8 +254,8 @@ static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
 	struct rtable *rt;
 
 	memset(fl, 0, sizeof(*fl));
-	fl->daddr = key->ipv4_dst;
-	fl->saddr = key->ipv4_src;
+	fl->daddr = key->u.ipv4.dst;
+	fl->saddr = key->u.ipv4.src;
 	fl->flowi4_tos = RT_TOS(key->ipv4_tos);
 	fl->flowi4_mark = mark;
 	fl->flowi4_proto = protocol;
-- 
1.8.3.1
