From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: use the macros defined for the members of flowi
Date: Sat, 13 Nov 2010 12:43:55 +0800
Message-ID: <1289623435-22713-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:40897 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093Ab0KMEo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 23:44:27 -0500
Received: by yxn35 with SMTP id 35so403571yxn.19
        for <netdev@vger.kernel.org>; Fri, 12 Nov 2010 20:44:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the macros defined for the members of flowi to clean the code up.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/route.h             |   12 ++++-------
 net/atm/clip.c                  |    3 +-
 net/bridge/br_netfilter.c       |    9 +-------
 net/dccp/ipv4.c                 |   13 ++++--------
 net/decnet/dn_route.c           |   22 ++++++++------------
 net/decnet/dn_rules.c           |    2 -
 net/ipv4/af_inet.c              |   18 ++++------------
 net/ipv4/arp.c                  |   12 +++++------
 net/ipv4/fib_frontend.c         |   28 +++++++-------------------
 net/ipv4/fib_semantics.c        |    8 +------
 net/ipv4/icmp.c                 |   28 ++++++++------------------
 net/ipv4/igmp.c                 |    8 ++-----
 net/ipv4/inet_connection_sock.c |   15 +++++--------
 net/ipv4/ip_gre.c               |   30 ++++++++-------------------
 net/ipv4/ip_output.c            |   25 +++++++++--------------
 net/ipv4/ipip.c                 |   20 +++++-------------
 net/ipv4/ipmr.c                 |   18 ++++------------
 net/ipv4/netfilter.c            |    8 +++----
 net/ipv4/raw.c                  |    7 ++----
 net/ipv4/route.c                |   43 +++++++++++++++-------------------------
 net/ipv4/syncookies.c           |   15 +++++--------
 net/ipv4/udp.c                  |   12 ++++-------
 net/ipv4/xfrm4_policy.c         |    8 +------
 net/ipv6/ip6mr.c                |    4 ---
 net/ipv6/netfilter.c            |    6 +----
 net/ipv6/route.c                |   24 +++++-----------------
 net/ipv6/sit.c                  |   14 +++++--------
 net/l2tp/l2tp_ip.c              |   12 ++++-------
 net/netfilter/ipvs/ip_vs_ctl.c  |    6 +----
 net/netfilter/ipvs/ip_vs_xmit.c |   34 +++++++------------------------
 net/netfilter/xt_TEE.c          |   12 +++++------
 net/rxrpc/ar-peer.c             |   10 ++++-----
 32 files changed, 171 insertions(+), 315 deletions(-)
diff --git a/include/net/route.h b/include/net/route.h
index 5cd46d1..b8c1f77 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -169,14 +169,12 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 {
 	struct flowi fl = { .oif = oif,
 			    .mark = sk->sk_mark,
-			    .nl_u = { .ip4_u = { .daddr = dst,
-						 .saddr = src,
-						 .tos   = tos } },
+			    .fl4_dst = dst,
+			    .fl4_src = src,
+			    .fl4_tos = tos,
 			    .proto = protocol,
-			    .uli_u = { .ports =
-				       { .sport = sport,
-					 .dport = dport } } };
-
+			    .fl_ip_sport = sport,
+			    .fl_ip_dport = dport };
 	int err;
 	struct net *net = sock_net(sk);
 
diff --git a/net/atm/clip.c b/net/atm/clip.c
index ff956d1..d257da5 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -502,7 +502,8 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	struct atmarp_entry *entry;
 	int error;
 	struct clip_vcc *clip_vcc;
-	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip, .tos = 1}} };
+	struct flowi fl = { .fl4_dst = ip,
+			    .fl4_tos = 1 };
 	struct rtable *rt;
 
 	if (vcc->push != clip_push) {
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 865fd76..36cd0b7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -412,13 +412,8 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	if (dnat_took_place(skb)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct flowi fl = {
-				.nl_u = {
-					.ip4_u = {
-						 .daddr = iph->daddr,
-						 .saddr = 0,
-						 .tos = RT_TOS(iph->tos) },
-				},
-				.proto = 0,
+				.fl4_dst = iph->daddr,
+				.fl4_tos = RT_TOS(iph->tos),
 			};
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3f69ea1..45a434f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -462,15 +462,12 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 {
 	struct rtable *rt;
 	struct flowi fl = { .oif = skb_rtable(skb)->rt_iif,
-			    .nl_u = { .ip4_u =
-				      { .daddr = ip_hdr(skb)->saddr,
-					.saddr = ip_hdr(skb)->daddr,
-					.tos = RT_CONN_FLAGS(sk) } },
+			    .fl4_dst = ip_hdr(skb)->saddr,
+			    .fl4_src = ip_hdr(skb)->daddr,
+			    .fl4_tos = RT_CONN_FLAGS(sk),
 			    .proto = sk->sk_protocol,
-			    .uli_u = { .ports =
-				       { .sport = dccp_hdr(skb)->dccph_dport,
-					 .dport = dccp_hdr(skb)->dccph_sport }
-				     }
+			    .fl_ip_sport = dccp_hdr(skb)->dccph_dport,
+			    .fl_ip_dport = dccp_hdr(skb)->dccph_sport
 			  };
 
 	security_skb_classify_flow(skb, &fl);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 474d54d..8280e43 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -271,10 +271,10 @@ static void dn_dst_link_failure(struct sk_buff *skb)
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
-	return ((fl1->nl_u.dn_u.daddr ^ fl2->nl_u.dn_u.daddr) |
-		(fl1->nl_u.dn_u.saddr ^ fl2->nl_u.dn_u.saddr) |
+	return ((fl1->fld_dst ^ fl2->fld_dst) |
+		(fl1->fld_src ^ fl2->fld_src) |
 		(fl1->mark ^ fl2->mark) |
-		(fl1->nl_u.dn_u.scope ^ fl2->nl_u.dn_u.scope) |
+		(fl1->fld_scope ^ fl2->fld_scope) |
 		(fl1->oif ^ fl2->oif) |
 		(fl1->iif ^ fl2->iif)) == 0;
 }
@@ -882,11 +882,9 @@ static inline __le16 dn_fib_rules_map_destination(__le16 daddr, struct dn_fib_re
 
 static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *oldflp, int try_hard)
 {
-	struct flowi fl = { .nl_u = { .dn_u =
-				      { .daddr = oldflp->fld_dst,
-					.saddr = oldflp->fld_src,
-					.scope = RT_SCOPE_UNIVERSE,
-				     } },
+	struct flowi fl = { .fld_dst = oldflp->fld_dst,
+			    .fld_src = oldflp->fld_src,
+			    .fld_scope = RT_SCOPE_UNIVERSE,
 			    .mark = oldflp->mark,
 			    .iif = init_net.loopback_dev->ifindex,
 			    .oif = oldflp->oif };
@@ -1230,11 +1228,9 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	int flags = 0;
 	__le16 gateway = 0;
 	__le16 local_src = 0;
-	struct flowi fl = { .nl_u = { .dn_u =
-				     { .daddr = cb->dst,
-				       .saddr = cb->src,
-				       .scope = RT_SCOPE_UNIVERSE,
-				    } },
+	struct flowi fl = { .fld_dst = cb->dst,
+			    .fld_src = cb->src,
+			    .fld_scope = RT_SCOPE_UNIVERSE,
 			    .mark = skb->mark,
 			    .iif = skb->dev->ifindex };
 	struct dn_fib_res res = { .fi = NULL, .type = RTN_UNREACHABLE };
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 48fdf10..6eb91df 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -175,7 +175,7 @@ static int dn_fib_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
 
 unsigned dnet_addr_type(__le16 addr)
 {
-	struct flowi fl = { .nl_u = { .dn_u = { .daddr = addr } } };
+	struct flowi fl = { .fld_dst = addr };
 	struct dn_fib_res res;
 	unsigned ret = RTN_UNICAST;
 	struct dn_fib_table *tb = dn_fib_get_table(RT_TABLE_LOCAL, 0);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f581f77..f2b6110 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1148,21 +1148,13 @@ int inet_sk_rebuild_header(struct sock *sk)
 	struct flowi fl = {
 		.oif = sk->sk_bound_dev_if,
 		.mark = sk->sk_mark,
-		.nl_u = {
-			.ip4_u = {
-				.daddr	= daddr,
-				.saddr	= inet->inet_saddr,
-				.tos	= RT_CONN_FLAGS(sk),
-			},
-		},
+		.fl4_dst = daddr,
+		.fl4_src = inet->inet_saddr,
+		.fl4_tos = RT_CONN_FLAGS(sk),
 		.proto = sk->sk_protocol,
 		.flags = inet_sk_flowi_flags(sk),
-		.uli_u = {
-			.ports = {
-				.sport = inet->inet_sport,
-				.dport = inet->inet_dport,
-			},
-		},
+		.fl_ip_sport = inet->inet_sport,
+		.fl_ip_dport = inet->inet_dport,
 	};
 
 	security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d8e540c..b564b76 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -433,8 +433,8 @@ static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
 
 static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 {
-	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = sip,
-						 .saddr = tip } } };
+	struct flowi fl = { .fl4_dst = sip,
+			    .fl4_src = tip };
 	struct rtable *rt;
 	int flag = 0;
 	/*unsigned long now; */
@@ -1061,8 +1061,8 @@ static int arp_req_set(struct net *net, struct arpreq *r,
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (dev == NULL) {
-		struct flowi fl = { .nl_u.ip4_u = { .daddr = ip,
-						    .tos = RTO_ONLINK } };
+		struct flowi fl = { .fl4_dst = ip,
+				    .fl4_tos = RTO_ONLINK };
 		struct rtable *rt;
 		err = ip_route_output_key(net, &rt, &fl);
 		if (err != 0)
@@ -1169,8 +1169,8 @@ static int arp_req_delete(struct net *net, struct arpreq *r,
 
 	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (dev == NULL) {
-		struct flowi fl = { .nl_u.ip4_u = { .daddr = ip,
-						    .tos = RTO_ONLINK } };
+		struct flowi fl = { .fl4_dst = ip,
+				    .fl4_tos = RTO_ONLINK };
 		struct rtable *rt;
 		err = ip_route_output_key(net, &rt, &fl);
 		if (err != 0)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index eb6f69a..d3a1112 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -158,11 +158,7 @@ static void fib_flush(struct net *net)
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
 	struct flowi fl = {
-		.nl_u = {
-			.ip4_u = {
-				.daddr = addr
-			}
-		},
+		.fl4_dst = addr,
 		.flags = FLOWI_FLAG_MATCH_ANY_IIF
 	};
 	struct fib_result res = { 0 };
@@ -193,7 +189,7 @@ static inline unsigned __inet_dev_addr_type(struct net *net,
 					    const struct net_device *dev,
 					    __be32 addr)
 {
-	struct flowi		fl = { .nl_u = { .ip4_u = { .daddr = addr } } };
+	struct flowi		fl = { .fl4_dst = addr };
 	struct fib_result	res;
 	unsigned ret = RTN_BROADCAST;
 	struct fib_table *local_table;
@@ -247,13 +243,9 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 {
 	struct in_device *in_dev;
 	struct flowi fl = {
-		.nl_u = {
-			.ip4_u = {
-				.daddr = src,
-				.saddr = dst,
-				.tos = tos
-			}
-		},
+		.fl4_dst = src,
+		.fl4_src = dst,
+		.fl4_tos = tos,
 		.mark = mark,
 		.iif = oif
 	};
@@ -853,13 +845,9 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 	struct fib_result       res;
 	struct flowi            fl = {
 		.mark = frn->fl_mark,
-		.nl_u = {
-			.ip4_u = {
-				.daddr = frn->fl_addr,
-				.tos = frn->fl_tos,
-				.scope = frn->fl_scope
-			}
-		}
+		.fl4_dst = frn->fl_addr,
+		.fl4_tos = frn->fl_tos,
+		.fl4_scope = frn->fl_scope,
 	};
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3e0da3e..12d3dc3 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -563,12 +563,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		rcu_read_lock();
 		{
 			struct flowi fl = {
-				.nl_u = {
-					.ip4_u = {
-						.daddr = nh->nh_gw,
-						.scope = cfg->fc_scope + 1,
-					},
-				},
+				.fl4_dst = nh->nh_gw,
+				.fl4_scope = cfg->fc_scope + 1,
 				.oif = nh->nh_oif,
 			};
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c6e2aff..4daebd1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -386,10 +386,9 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 			daddr = icmp_param->replyopts.faddr;
 	}
 	{
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = daddr,
-						.saddr = rt->rt_spec_dst,
-						.tos = RT_TOS(ip_hdr(skb)->tos) } },
+		struct flowi fl = { .fl4_dst= daddr,
+				    .fl4_src = rt->rt_spec_dst,
+				    .fl4_tos = RT_TOS(ip_hdr(skb)->tos),
 				    .proto = IPPROTO_ICMP };
 		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(net, &rt, &fl))
@@ -542,22 +541,13 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 	{
 		struct flowi fl = {
-			.nl_u = {
-				.ip4_u = {
-					.daddr = icmp_param.replyopts.srr ?
-						icmp_param.replyopts.faddr :
-						iph->saddr,
-					.saddr = saddr,
-					.tos = RT_TOS(tos)
-				}
-			},
+			.fl4_dst = icmp_param.replyopts.srr ?
+				   icmp_param.replyopts.faddr : iph->saddr,
+			.fl4_src = saddr,
+			.fl4_tos = RT_TOS(tos),
 			.proto = IPPROTO_ICMP,
-			.uli_u = {
-				.icmpt = {
-					.type = type,
-					.code = code
-				}
-			}
+			.fl_icmp_type = type,
+			.fl_icmp_code = code,
 		};
 		int err;
 		struct rtable *rt2;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 08d0d81..606f92c 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -298,8 +298,7 @@ static struct sk_buff *igmpv3_newpack(struct net_device *dev, int size)
 
 	{
 		struct flowi fl = { .oif = dev->ifindex,
-				    .nl_u = { .ip4_u = {
-				    .daddr = IGMPV3_ALL_MCR } },
+				    .fl4_dst = IGMPV3_ALL_MCR,
 				    .proto = IPPROTO_IGMP };
 		if (ip_route_output_key(net, &rt, &fl)) {
 			kfree_skb(skb);
@@ -644,7 +643,7 @@ static int igmp_send_report(struct in_device *in_dev, struct ip_mc_list *pmc,
 
 	{
 		struct flowi fl = { .oif = dev->ifindex,
-				    .nl_u = { .ip4_u = { .daddr = dst } },
+				    .fl4_dst = dst,
 				    .proto = IPPROTO_IGMP };
 		if (ip_route_output_key(net, &rt, &fl))
 			return -1;
@@ -1421,8 +1420,7 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 /* RTNL is locked */
 static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 {
-	struct flowi fl = { .nl_u = { .ip4_u =
-				      { .daddr = imr->imr_multiaddr.s_addr } } };
+	struct flowi fl = { .fl4_dst = imr->imr_multiaddr.s_addr };
 	struct rtable *rt;
 	struct net_device *dev = NULL;
 	struct in_device *idev = NULL;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7174370..06f5f8f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -358,17 +358,14 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct ip_options *opt = inet_rsk(req)->opt;
 	struct flowi fl = { .oif = sk->sk_bound_dev_if,
 			    .mark = sk->sk_mark,
-			    .nl_u = { .ip4_u =
-				      { .daddr = ((opt && opt->srr) ?
-						  opt->faddr :
-						  ireq->rmt_addr),
-					.saddr = ireq->loc_addr,
-					.tos = RT_CONN_FLAGS(sk) } },
+			    .fl4_dst = ((opt && opt->srr) ?
+					  opt->faddr : ireq->rmt_addr),
+			    .fl4_src = ireq->loc_addr,
+			    .fl4_tos = RT_CONN_FLAGS(sk),
 			    .proto = sk->sk_protocol,
 			    .flags = inet_sk_flowi_flags(sk),
-			    .uli_u = { .ports =
-				       { .sport = inet_sk(sk)->inet_sport,
-					 .dport = ireq->rmt_port } } };
+			    .fl_ip_sport = inet_sk(sk)->inet_sport,
+			    .fl_ip_dport = ireq->rmt_port };
 	struct net *net = sock_net(sk);
 
 	security_req_classify_flow(req, &fl);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index cab2057..a2e9cfd 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -772,13 +772,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	{
 		struct flowi fl = {
 			.oif = tunnel->parms.link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = dst,
-					.saddr = tiph->saddr,
-					.tos = RT_TOS(tos)
-				}
-			},
+			.fl4_dst = dst,
+			.fl4_src = tiph->saddr,
+			.fl4_tos = RT_TOS(tos),
 			.proto = IPPROTO_GRE
 		}
 ;
@@ -951,13 +947,9 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 	if (iph->daddr) {
 		struct flowi fl = {
 			.oif = tunnel->parms.link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = iph->daddr,
-					.saddr = iph->saddr,
-					.tos = RT_TOS(iph->tos)
-				}
-			},
+			.fl4_dst = iph->daddr,
+			.fl4_src = iph->saddr,
+			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_GRE
 		};
 		struct rtable *rt;
@@ -1216,13 +1208,9 @@ static int ipgre_open(struct net_device *dev)
 	if (ipv4_is_multicast(t->parms.iph.daddr)) {
 		struct flowi fl = {
 			.oif = t->parms.link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = t->parms.iph.daddr,
-					.saddr = t->parms.iph.saddr,
-					.tos = RT_TOS(t->parms.iph.tos)
-				}
-			},
+			.fl4_dst = t->parms.iph.daddr,
+			.fl4_src = t->parms.iph.saddr,
+			.fl4_tos = RT_TOS(t->parms.iph.tos),
 			.proto = IPPROTO_GRE
 		};
 		struct rtable *rt;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 439d2a3..5090c7f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -341,15 +341,13 @@ int ip_queue_xmit(struct sk_buff *skb)
 		{
 			struct flowi fl = { .oif = sk->sk_bound_dev_if,
 					    .mark = sk->sk_mark,
-					    .nl_u = { .ip4_u =
-						      { .daddr = daddr,
-							.saddr = inet->inet_saddr,
-							.tos = RT_CONN_FLAGS(sk) } },
+					    .fl4_dst = daddr,
+					    .fl4_src = inet->inet_saddr,
+					    .fl4_tos = RT_CONN_FLAGS(sk),
 					    .proto = sk->sk_protocol,
 					    .flags = inet_sk_flowi_flags(sk),
-					    .uli_u = { .ports =
-						       { .sport = inet->inet_sport,
-							 .dport = inet->inet_dport } } };
+					    .fl_ip_sport = inet->inet_sport,
+					    .fl_ip_dport = inet->inet_dport };
 
 			/* If this fails, retransmit mechanism of transport layer will
 			 * keep trying until route appears or the connection times
@@ -1404,14 +1402,11 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	{
 		struct flowi fl = { .oif = arg->bound_dev_if,
-				    .nl_u = { .ip4_u =
-					      { .daddr = daddr,
-						.saddr = rt->rt_spec_dst,
-						.tos = RT_TOS(ip_hdr(skb)->tos) } },
-				    /* Not quite clean, but right. */
-				    .uli_u = { .ports =
-					       { .sport = tcp_hdr(skb)->dest,
-						 .dport = tcp_hdr(skb)->source } },
+				    .fl4_dst = daddr,
+				    .fl4_src = rt->rt_spec_dst,
+				    .fl4_tos = RT_TOS(ip_hdr(skb)->tos),
+				    .fl_ip_sport = tcp_hdr(skb)->dest,
+				    .fl_ip_dport = tcp_hdr(skb)->source,
 				    .proto = sk->sk_protocol,
 				    .flags = ip_reply_arg_flowi_flags(arg) };
 		security_skb_classify_flow(skb, &fl);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index cd300aa..e70ad58 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -463,13 +463,9 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	{
 		struct flowi fl = {
 			.oif = tunnel->parms.link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = dst,
-					.saddr = tiph->saddr,
-					.tos = RT_TOS(tos)
-				}
-			},
+			.fl4_dst = dst,
+			.fl4_src= tiph->saddr,
+			.fl4_tos = RT_TOS(tos),
 			.proto = IPPROTO_IPIP
 		};
 
@@ -589,13 +585,9 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 	if (iph->daddr) {
 		struct flowi fl = {
 			.oif = tunnel->parms.link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = iph->daddr,
-					.saddr = iph->saddr,
-					.tos = RT_TOS(iph->tos)
-				}
-			},
+			.fl4_dst = iph->daddr,
+			.fl4_src = iph->saddr,
+			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_IPIP
 		};
 		struct rtable *rt;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index ef2b008..92aaa3d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1537,13 +1537,9 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	if (vif->flags & VIFF_TUNNEL) {
 		struct flowi fl = {
 			.oif = vif->link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = vif->remote,
-					.saddr = vif->local,
-					.tos = RT_TOS(iph->tos)
-				}
-			},
+			.fl4_dst = vif->remote,
+			.fl4_src = vif->local,
+			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_IPIP
 		};
 
@@ -1553,12 +1549,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	} else {
 		struct flowi fl = {
 			.oif = vif->link,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = iph->daddr,
-					.tos = RT_TOS(iph->tos)
-				}
-			},
+			.fl4_dst = iph->daddr,
+			.fl4_tos = RT_TOS(iph->tos),
 			.proto = IPPROTO_IPIP
 		};
 
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index d88a46c..994a1f2 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -31,10 +31,10 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	 * packets with foreign saddr to appear on the NF_INET_LOCAL_OUT hook.
 	 */
 	if (addr_type == RTN_LOCAL) {
-		fl.nl_u.ip4_u.daddr = iph->daddr;
+		fl.fl4_dst = iph->daddr;
 		if (type == RTN_LOCAL)
-			fl.nl_u.ip4_u.saddr = iph->saddr;
-		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
+			fl.fl4_src = iph->saddr;
+		fl.fl4_tos = RT_TOS(iph->tos);
 		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 		fl.mark = skb->mark;
 		fl.flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
@@ -47,7 +47,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	} else {
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
-		fl.nl_u.ip4_u.daddr = iph->saddr;
+		fl.fl4_dst = iph->saddr;
 		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1f85ef2..a3d5ab7 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -549,10 +549,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	{
 		struct flowi fl = { .oif = ipc.oif,
 				    .mark = sk->sk_mark,
-				    .nl_u = { .ip4_u =
-					      { .daddr = daddr,
-						.saddr = saddr,
-						.tos = tos } },
+				    .fl4_dst = daddr,
+				    .fl4_src = saddr,
+				    .fl4_tos = tos,
 				    .proto = inet->hdrincl ? IPPROTO_RAW :
 							     sk->sk_protocol,
 				  };
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 66610ea..ec2333f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -684,17 +684,17 @@ static inline bool rt_caching(const struct net *net)
 static inline bool compare_hash_inputs(const struct flowi *fl1,
 					const struct flowi *fl2)
 {
-	return ((((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_u.ip4_u.daddr) |
-		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u.saddr) |
+	return ((((__force u32)fl1->fl4_dst ^ (__force u32)fl2->fl4_dst) |
+		((__force u32)fl1->fl4_src ^ (__force u32)fl2->fl4_src) |
 		(fl1->iif ^ fl2->iif)) == 0);
 }
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
-	return (((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_u.ip4_u.daddr) |
-		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u.saddr) |
+	return (((__force u32)fl1->fl4_dst ^ (__force u32)fl2->fl4_dst) |
+		((__force u32)fl1->fl4_src ^ (__force u32)fl2->fl4_src) |
 		(fl1->mark ^ fl2->mark) |
-		(*(u16 *)&fl1->nl_u.ip4_u.tos ^ *(u16 *)&fl2->nl_u.ip4_u.tos) |
+		(*(u16 *)&fl1->fl4_tos ^ *(u16 *)&fl2->fl4_tos) |
 		(fl1->oif ^ fl2->oif) |
 		(fl1->iif ^ fl2->iif)) == 0;
 }
@@ -2089,12 +2089,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct flowi fl = { .nl_u = { .ip4_u =
-				      { .daddr = daddr,
-					.saddr = saddr,
-					.tos = tos,
-					.scope = RT_SCOPE_UNIVERSE,
-				      } },
+	struct flowi fl = { .fl4_dst	= daddr,
+			    .fl4_src	= saddr,
+			    .fl4_tos	= tos,
+			    .fl4_scope	= RT_SCOPE_UNIVERSE,
 			    .mark = skb->mark,
 			    .iif = dev->ifindex };
 	unsigned	flags = 0;
@@ -2480,14 +2478,11 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 				const struct flowi *oldflp)
 {
 	u32 tos	= RT_FL_TOS(oldflp);
-	struct flowi fl = { .nl_u = { .ip4_u =
-				      { .daddr = oldflp->fl4_dst,
-					.saddr = oldflp->fl4_src,
-					.tos = tos & IPTOS_RT_MASK,
-					.scope = ((tos & RTO_ONLINK) ?
-						  RT_SCOPE_LINK :
-						  RT_SCOPE_UNIVERSE),
-				      } },
+	struct flowi fl = { .fl4_dst = oldflp->fl4_dst,
+			    .fl4_src = oldflp->fl4_src,
+			    .fl4_tos = tos & IPTOS_RT_MASK,
+			    .fl4_scope = ((tos & RTO_ONLINK) ?
+					  RT_SCOPE_LINK : RT_SCOPE_UNIVERSE),
 			    .mark = oldflp->mark,
 			    .iif = net->loopback_dev->ifindex,
 			    .oif = oldflp->oif };
@@ -2944,13 +2939,9 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 			err = -rt->dst.error;
 	} else {
 		struct flowi fl = {
-			.nl_u = {
-				.ip4_u = {
-					.daddr = dst,
-					.saddr = src,
-					.tos = rtm->rtm_tos,
-				},
-			},
+			.fl4_dst = dst,
+			.fl4_src = src,
+			.fl4_tos = rtm->rtm_tos,
 			.oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
 			.mark = mark,
 		};
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 650cace..4751920 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -346,17 +346,14 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 */
 	{
 		struct flowi fl = { .mark = sk->sk_mark,
-				    .nl_u = { .ip4_u =
-					      { .daddr = ((opt && opt->srr) ?
-							  opt->faddr :
-							  ireq->rmt_addr),
-						.saddr = ireq->loc_addr,
-						.tos = RT_CONN_FLAGS(sk) } },
+				    .fl4_dst = ((opt && opt->srr) ?
+						opt->faddr : ireq->rmt_addr),
+				    .fl4_src = ireq->loc_addr,
+				    .fl4_tos = RT_CONN_FLAGS(sk),
 				    .proto = IPPROTO_TCP,
 				    .flags = inet_sk_flowi_flags(sk),
-				    .uli_u = { .ports =
-					       { .sport = th->dest,
-						 .dport = th->source } } };
+				    .fl_ip_sport = th->dest,
+				    .fl_ip_dport = th->source };
 		security_req_classify_flow(req, &fl);
 		if (ip_route_output_key(sock_net(sk), &rt, &fl)) {
 			reqsk_free(req);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 28cb2d7..803887f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -890,15 +890,13 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (rt == NULL) {
 		struct flowi fl = { .oif = ipc.oif,
 				    .mark = sk->sk_mark,
-				    .nl_u = { .ip4_u =
-					      { .daddr = faddr,
-						.saddr = saddr,
-						.tos = tos } },
+				    .fl4_dst = faddr,
+				    .fl4_src = saddr,
+				    .fl4_tos = tos,
 				    .proto = sk->sk_protocol,
 				    .flags = inet_sk_flowi_flags(sk),
-				    .uli_u = { .ports =
-					       { .sport = inet->inet_sport,
-						 .dport = dport } } };
+				    .fl_ip_sport = inet->inet_sport,
+				    .fl_ip_dport = dport };
 		struct net *net = sock_net(sk);
 
 		security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index dd1fd8c..b9e28b9 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -22,12 +22,8 @@ static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
 					  xfrm_address_t *daddr)
 {
 	struct flowi fl = {
-		.nl_u = {
-			.ip4_u = {
-				.tos = tos,
-				.daddr = daddr->a4,
-			},
-		},
+		.fl4_dst = daddr->a4,
+		.fl4_tos = tos,
 	};
 	struct dst_entry *dst;
 	struct rtable *rt;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6f32ffc..9fab274 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1843,9 +1843,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 
 	fl = (struct flowi) {
 		.oif = vif->link,
-		.nl_u = { .ip6_u =
-				{ .daddr = ipv6h->daddr, }
-		}
+		.fl6_dst = ipv6h->daddr,
 	};
 
 	dst = ip6_route_output(net, NULL, &fl);
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 7155b24..35915e8 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -18,10 +18,8 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	struct flowi fl = {
 		.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
 		.mark = skb->mark,
-		.nl_u =
-		{ .ip6_u =
-		  { .daddr = iph->daddr,
-		    .saddr = iph->saddr, } },
+		.fl6_dst = iph->daddr,
+		.fl6_src = iph->saddr,
 	};
 
 	dst = ip6_route_output(net, skb->sk, &fl);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fc32833..7763663 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -558,11 +558,7 @@ struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 {
 	struct flowi fl = {
 		.oif = oif,
-		.nl_u = {
-			.ip6_u = {
-				.daddr = *daddr,
-			},
-		},
+		.fl6_dst = *daddr,
 	};
 	struct dst_entry *dst;
 	int flags = strict ? RT6_LOOKUP_F_IFACE : 0;
@@ -778,13 +774,9 @@ void ip6_route_input(struct sk_buff *skb)
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct flowi fl = {
 		.iif = skb->dev->ifindex,
-		.nl_u = {
-			.ip6_u = {
-				.daddr = iph->daddr,
-				.saddr = iph->saddr,
-				.flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
-			},
-		},
+		.fl6_dst = iph->daddr,
+		.fl6_src = iph->saddr,
+		.fl6_flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
 		.mark = skb->mark,
 		.proto = iph->nexthdr,
 	};
@@ -1463,12 +1455,8 @@ static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
 	struct ip6rd_flowi rdfl = {
 		.fl = {
 			.oif = dev->ifindex,
-			.nl_u = {
-				.ip6_u = {
-					.daddr = *dest,
-					.saddr = *src,
-				},
-			},
+			.fl6_dst = *dest,
+			.fl6_src = *src,
 		},
 	};
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d6bfaec..6e48a80 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -730,10 +730,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 
 	{
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = dst,
-						.saddr = tiph->saddr,
-						.tos = RT_TOS(tos) } },
+		struct flowi fl = { .fl4_dst = dst,
+				    .fl4_src = tiph->saddr,
+				    .fl4_tos = RT_TOS(tos),
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
@@ -855,10 +854,9 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	iph = &tunnel->parms.iph;
 
 	if (iph->daddr) {
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = iph->daddr,
-						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
+		struct flowi fl = { .fl4_dst = iph->daddr,
+				    .fl4_src = iph->saddr,
+				    .fl4_tos = RT_TOS(iph->tos),
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		struct rtable *rt;
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 0bf6a59..04635e8 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -476,15 +476,13 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 		{
 			struct flowi fl = { .oif = sk->sk_bound_dev_if,
-					    .nl_u = { .ip4_u = {
-							.daddr = daddr,
-							.saddr = inet->inet_saddr,
-							.tos = RT_CONN_FLAGS(sk) } },
+					    .fl4_dst = daddr,
+					    .fl4_src = inet->inet_saddr,
+					    .fl4_tos = RT_CONN_FLAGS(sk),
 					    .proto = sk->sk_protocol,
 					    .flags = inet_sk_flowi_flags(sk),
-					    .uli_u = { .ports = {
-							 .sport = inet->inet_sport,
-							 .dport = inet->inet_dport } } };
+					    .fl_ip_sport = inet->inet_sport,
+					    .fl_ip_dport = inet->inet_dport };
 
 			/* If this fails, retransmit mechanism of transport layer will
 			 * keep trying until route appears or the connection times
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5f5daa3..c6f2936 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -110,10 +110,8 @@ static int __ip_vs_addr_is_local_v6(const struct in6_addr *addr)
 	struct rt6_info *rt;
 	struct flowi fl = {
 		.oif = 0,
-		.nl_u = {
-			.ip6_u = {
-				.daddr = *addr,
-				.saddr = { .s6_addr32 = {0, 0, 0, 0} }, } },
+		.fl6_dst = *addr,
+		.fl6_src = { .s6_addr32 = {0, 0, 0, 0} },
 	};
 
 	rt = (struct rt6_info *)ip6_route_output(&init_net, NULL, &fl);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 10bd39c..5325a3f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -96,12 +96,8 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		if (!(rt = (struct rtable *)
 		      __ip_vs_dst_check(dest, rtos))) {
 			struct flowi fl = {
-				.oif = 0,
-				.nl_u = {
-					.ip4_u = {
-						.daddr = dest->addr.ip,
-						.saddr = 0,
-						.tos = rtos, } },
+				.fl4_dst = dest->addr.ip,
+				.fl4_tos = rtos,
 			};
 
 			if (ip_route_output_key(net, &rt, &fl)) {
@@ -118,12 +114,8 @@ __ip_vs_get_out_rt(struct sk_buff *skb, struct ip_vs_dest *dest,
 		spin_unlock(&dest->dst_lock);
 	} else {
 		struct flowi fl = {
-			.oif = 0,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = daddr,
-					.saddr = 0,
-					.tos = rtos, } },
+			.fl4_dst = daddr,
+			.fl4_tos = rtos,
 		};
 
 		if (ip_route_output_key(net, &rt, &fl)) {
@@ -178,14 +170,9 @@ __ip_vs_reroute_locally(struct sk_buff *skb)
 		refdst_drop(orefdst);
 	} else {
 		struct flowi fl = {
-			.oif = 0,
-			.nl_u = {
-				.ip4_u = {
-					.daddr = iph->daddr,
-					.saddr = iph->saddr,
-					.tos = RT_TOS(iph->tos),
-				}
-			},
+			.fl4_dst = iph->daddr,
+			.fl4_src = iph->saddr,
+			.fl4_tos = RT_TOS(iph->tos),
 			.mark = skb->mark,
 		};
 		struct rtable *rt;
@@ -216,12 +203,7 @@ __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
 {
 	struct dst_entry *dst;
 	struct flowi fl = {
-		.oif = 0,
-		.nl_u = {
-			.ip6_u = {
-				.daddr = *daddr,
-			},
-		},
+		.fl6_dst = *daddr,
 	};
 
 	dst = ip6_route_output(net, NULL, &fl);
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 22a2d42..231867d 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -70,9 +70,9 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 			return false;
 		fl.oif = info->priv->oif;
 	}
-	fl.nl_u.ip4_u.daddr = info->gw.ip;
-	fl.nl_u.ip4_u.tos   = RT_TOS(iph->tos);
-	fl.nl_u.ip4_u.scope = RT_SCOPE_UNIVERSE;
+	fl.fl4_dst = info->gw.ip;
+	fl.fl4_tos = RT_TOS(iph->tos);
+	fl.fl4_scope = RT_SCOPE_UNIVERSE;
 	if (ip_route_output_key(net, &rt, &fl) != 0)
 		return false;
 
@@ -150,9 +150,9 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 			return false;
 		fl.oif = info->priv->oif;
 	}
-	fl.nl_u.ip6_u.daddr = info->gw.in6;
-	fl.nl_u.ip6_u.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
-				  (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
+	fl.fl6_dst = info->gw.in6;
+	fl.fl6_flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
+			   (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
 	dst = ip6_route_output(net, NULL, &fl);
 	if (dst == NULL)
 		return false;
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index 9f1729b..a53fb25 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -47,12 +47,12 @@ static void rxrpc_assess_MTU_size(struct rxrpc_peer *peer)
 	case AF_INET:
 		fl.oif = 0;
 		fl.proto = IPPROTO_UDP,
-		fl.nl_u.ip4_u.saddr = 0;
-		fl.nl_u.ip4_u.daddr = peer->srx.transport.sin.sin_addr.s_addr;
-		fl.nl_u.ip4_u.tos = 0;
+		fl.fl4_dst = peer->srx.transport.sin.sin_addr.s_addr;
+		fl.fl4_src = 0;
+		fl.fl4_tos = 0;
 		/* assume AFS.CM talking to AFS.FS */
-		fl.uli_u.ports.sport = htons(7001);
-		fl.uli_u.ports.dport = htons(7000);
+		fl.fl_ip_sport = htons(7001);
+		fl.fl_ip_dport = htons(7000);
 		break;
 	default:
 		BUG();
