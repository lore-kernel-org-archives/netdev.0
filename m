From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 05/13] ip_tunnels: use tos and ttl fields also for IPv6
Date: Tue, 18 Aug 2015 22:33:14 +0200
Message-ID: <f6be9fdcf759f96ff0285dfe84f5f3b05fbb914d.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42421 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbbHRUdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:47 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the ipv4_tos and ipv4_ttl fields to just 'tos' and 'ttl', as they'll
be used with IPv6 tunnels, too.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c            |  8 ++++----
 include/net/ip_tunnels.h       |  8 ++++----
 net/ipv4/ip_gre.c              |  8 ++++----
 net/ipv4/ip_tunnel_core.c      |  8 ++++----
 net/openvswitch/flow_netlink.c | 10 +++++-----
 net/openvswitch/vport-geneve.c |  4 ++--
 net/openvswitch/vport.c        |  4 ++--
 net/openvswitch/vport.h        |  2 +-
 8 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1c0733540756..41e9549e1d5e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1278,8 +1278,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		info = &tun_dst->u.tun_info;
 		info->key.u.ipv4.src = iph->saddr;
 		info->key.u.ipv4.dst = iph->daddr;
-		info->key.ipv4_tos = iph->tos;
-		info->key.ipv4_ttl = iph->ttl;
+		info->key.tos = iph->tos;
+		info->key.ttl = iph->ttl;
 		info->key.tp_src = udp_hdr(skb)->source;
 		info->key.tp_dst = udp_hdr(skb)->dest;
 
@@ -1960,8 +1960,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			else
 				flags &= ~VXLAN_F_UDP_CSUM;
 
-			ttl = info->key.ipv4_ttl;
-			tos = info->key.ipv4_tos;
+			ttl = info->key.ttl;
+			tos = info->key.tos;
 
 			if (info->options_len)
 				md = ip_tunnel_info_opts(info, sizeof(*md));
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 96b0a37af42c..f0faf8a3186b 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -43,8 +43,8 @@ struct ip_tunnel_key {
 		} ipv6;
 	} u;
 	__be16			tun_flags;
-	u8			ipv4_tos;
-	u8			ipv4_ttl;
+	u8			tos;		/* TOS for IPv4, TC for IPv6 */
+	u8			ttl;		/* TTL for IPv4, HL for IPv6 */
 	__be16			tp_src;
 	__be16			tp_dst;
 };
@@ -194,8 +194,8 @@ static inline void __ip_tunnel_info_init(struct ip_tunnel_info *tun_info,
 	tun_info->key.u.ipv4.dst = daddr;
 	memset((unsigned char *)&tun_info->key + IP_TUNNEL_KEY_IPV4_PAD,
 	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
-	tun_info->key.ipv4_tos = tos;
-	tun_info->key.ipv4_ttl = ttl;
+	tun_info->key.tos = tos;
+	tun_info->key.ttl = ttl;
 	tun_info->key.tun_flags = tun_flags;
 
 	/* For the tunnel types on the top of IPsec, the tp_src and tp_dst of
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b7bb7d6aa7a8..5193618b2600 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -409,8 +409,8 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 			info = &tun_dst->u.tun_info;
 			info->key.u.ipv4.src = iph->saddr;
 			info->key.u.ipv4.dst = iph->daddr;
-			info->key.ipv4_tos = iph->tos;
-			info->key.ipv4_ttl = iph->ttl;
+			info->key.tos = iph->tos;
+			info->key.ttl = iph->ttl;
 
 			info->mode = IP_TUNNEL_INFO_RX;
 			info->key.tun_flags = tpi->flags &
@@ -529,7 +529,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	memset(&fl, 0, sizeof(fl));
 	fl.daddr = key->u.ipv4.dst;
 	fl.saddr = key->u.ipv4.src;
-	fl.flowi4_tos = RT_TOS(key->ipv4_tos);
+	fl.flowi4_tos = RT_TOS(key->tos);
 	fl.flowi4_mark = skb->mark;
 	fl.flowi4_proto = IPPROTO_GRE;
 
@@ -565,7 +565,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
 	err = iptunnel_xmit(skb->sk, rt, skb, fl.saddr,
 			    key->u.ipv4.dst, IPPROTO_GRE,
-			    key->ipv4_tos, key->ipv4_ttl, df, false);
+			    key->tos, key->ttl, df, false);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return;
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 93907d71cda6..f0514e39e57c 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -233,10 +233,10 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 		tun_info->key.u.ipv4.src = nla_get_be32(tb[LWTUNNEL_IP_SRC]);
 
 	if (tb[LWTUNNEL_IP_TTL])
-		tun_info->key.ipv4_ttl = nla_get_u8(tb[LWTUNNEL_IP_TTL]);
+		tun_info->key.ttl = nla_get_u8(tb[LWTUNNEL_IP_TTL]);
 
 	if (tb[LWTUNNEL_IP_TOS])
-		tun_info->key.ipv4_tos = nla_get_u8(tb[LWTUNNEL_IP_TOS]);
+		tun_info->key.tos = nla_get_u8(tb[LWTUNNEL_IP_TOS]);
 
 	if (tb[LWTUNNEL_IP_SPORT])
 		tun_info->key.tp_src = nla_get_be16(tb[LWTUNNEL_IP_SPORT]);
@@ -264,8 +264,8 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 	if (nla_put_u64(skb, LWTUNNEL_IP_ID, tun_info->key.tun_id) ||
 	    nla_put_be32(skb, LWTUNNEL_IP_DST, tun_info->key.u.ipv4.dst) ||
 	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
-	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.ipv4_tos) ||
-	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ipv4_ttl) ||
+	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.tos) ||
+	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ttl) ||
 	    nla_put_u16(skb, LWTUNNEL_IP_SPORT, tun_info->key.tp_src) ||
 	    nla_put_u16(skb, LWTUNNEL_IP_DPORT, tun_info->key.tp_dst) ||
 	    nla_put_u16(skb, LWTUNNEL_IP_FLAGS, tun_info->key.tun_flags))
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index a7f866374817..4e7a3f7facc2 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -542,11 +542,11 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 					nla_get_in_addr(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TOS:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_tos,
+			SW_FLOW_KEY_PUT(match, tun_key.tos,
 					nla_get_u8(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TTL:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_ttl,
+			SW_FLOW_KEY_PUT(match, tun_key.ttl,
 					nla_get_u8(a), is_mask);
 			ttl = true;
 			break;
@@ -655,10 +655,10 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST,
 			    output->u.ipv4.dst))
 		return -EMSGSIZE;
-	if (output->ipv4_tos &&
-	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
+	if (output->tos &&
+	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->tos))
 		return -EMSGSIZE;
-	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, output->ipv4_ttl))
+	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, output->ttl))
 		return -EMSGSIZE;
 	if ((output->tun_flags & TUNNEL_DONT_FRAGMENT) &&
 	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 023813d05f88..d01bd6360970 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -203,8 +203,8 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
-			      tun_key->u.ipv4.dst, tun_key->ipv4_tos,
-			      tun_key->ipv4_ttl, df, sport, dport,
+			      tun_key->u.ipv4.dst, tun_key->tos,
+			      tun_key->ttl, df, sport, dport,
 			      tun_key->tun_flags, vni, opts_len, opts,
 			      !!(tun_key->tun_flags & TUNNEL_CSUM), false);
 	if (err < 0)
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index a06adc72a58d..d73e5a16e7ca 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -604,8 +604,8 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 	 */
 	__ip_tunnel_info_init(egress_tun_info,
 			      fl.saddr, tun_key->u.ipv4.dst,
-			      tun_key->ipv4_tos,
-			      tun_key->ipv4_ttl,
+			      tun_key->tos,
+			      tun_key->ttl,
 			      tp_src, tp_dst,
 			      tun_key->tun_id,
 			      tun_key->tun_flags,
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 43d8f5a835cb..b88b3ee86f07 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -256,7 +256,7 @@ static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
 	memset(fl, 0, sizeof(*fl));
 	fl->daddr = key->u.ipv4.dst;
 	fl->saddr = key->u.ipv4.src;
-	fl->flowi4_tos = RT_TOS(key->ipv4_tos);
+	fl->flowi4_tos = RT_TOS(key->tos);
 	fl->flowi4_mark = mark;
 	fl->flowi4_proto = protocol;
 
-- 
1.8.3.1
