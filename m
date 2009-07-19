From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/4] inet: in_route.h redefined macro
Date: Sun, 19 Jul 2009 20:23:39 +0200
Message-ID: <1248027819-23959-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <inet6_minor_cleanups>
 <1248027819-23959-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1248027819-23959-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1248027819-23959-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1248027819-23959-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55013 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751470AbZGSSjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2009 14:39:24 -0400
In-Reply-To: <1248027819-23959-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux/in_route.h declares RT_TOS(), which is the same as IPTOS_TOS() from
linux/ip.h. The files that use RT_TOS() all also include linux/ip.h.

The patch removes duplication, all it does is s/RT_TOS/IPTOS_TOS/g.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/in_route.h        |    2 --
 include/net/ip_vs.h             |    2 +-
 include/net/route.h             |    2 +-
 net/bridge/br_netfilter.c       |    2 +-
 net/ipv4/icmp.c                 |    6 +++---
 net/ipv4/ip_gre.c               |    6 +++---
 net/ipv4/ip_output.c            |    2 +-
 net/ipv4/ipip.c                 |    4 ++--
 net/ipv4/ipmr.c                 |    4 ++--
 net/ipv4/netfilter.c            |    4 ++--
 net/ipv4/udp.c                  |    2 +-
 net/ipv6/ip6_tunnel.c           |    2 +-
 net/ipv6/sit.c                  |    4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c |   10 +++++-----
 14 files changed, 25 insertions(+), 27 deletions(-)

--- a/include/linux/in_route.h
+++ b/include/linux/in_route.h
@@ -27,6 +27,4 @@
 
 #define RTCF_NAT	(RTCF_DNAT|RTCF_SNAT)
 
-#define RT_TOS(tos)	((tos)&IPTOS_TOS_MASK)
-
 #endif /* _LINUX_IN_ROUTE_H */
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -45,7 +45,7 @@
 /* RTO_CONN is not used (being alias for 0), but preserved not to break
  * some modules referring to it. */
 
-#define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
+#define RT_CONN_FLAGS(sk)   (IPTOS_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
 
 struct fib_nh;
 struct inet_peer;
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -484,7 +484,7 @@ struct ip_vs_dest {
 	/* for destination cache */
 	spinlock_t		dst_lock;	/* lock of dst_cache */
 	struct dst_entry	*dst_cache;	/* destination cache entry */
-	u32			dst_rtos;	/* RT_TOS(tos) for dst */
+	u32			dst_rtos;	/* IPTOS_TOS(tos) for dst */
 
 	/* for virtual service */
 	struct ip_vs_service	*svc;		/* service it belongs to */
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -355,7 +355,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 					.ip4_u = {
 						 .daddr = iph->daddr,
 						 .saddr = 0,
-						 .tos = RT_TOS(iph->tos) },
+						 .tos = IPTOS_TOS(iph->tos) },
 				},
 				.proto = 0,
 			};
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -385,7 +385,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 		struct flowi fl = { .nl_u = { .ip4_u =
 					      { .daddr = daddr,
 						.saddr = rt->rt_spec_dst,
-						.tos = RT_TOS(ip_hdr(skb)->tos) } },
+						.tos = IPTOS_TOS(ip_hdr(skb)->tos) } },
 				    .proto = IPPROTO_ICMP };
 		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(net, &rt, &fl))
@@ -543,7 +543,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 						icmp_param.replyopts.faddr :
 						iph->saddr,
 					.saddr = saddr,
-					.tos = RT_TOS(tos)
+					.tos = IPTOS_TOS(tos)
 				}
 			},
 			.proto = IPPROTO_ICMP,
@@ -593,7 +593,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 			/* Ugh! */
 			odst = skb_dst(skb_in);
 			err = ip_route_input(skb_in, fl.fl4_dst, fl.fl4_src,
-					     RT_TOS(tos), rt2->u.dst.dev);
+					     IPTOS_TOS(tos), rt2->u.dst.dev);
 
 			dst_release(&rt2->u.dst);
 			rt2 = skb_rtable(skb_in);
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -746,7 +746,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 				    .nl_u = { .ip4_u =
 					      { .daddr = dst,
 						.saddr = tiph->saddr,
-						.tos = RT_TOS(tos) } },
+						.tos = IPTOS_TOS(tos) } },
 				    .proto = IPPROTO_GRE };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			stats->tx_carrier_errors++;
@@ -920,7 +920,7 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 				    .nl_u = { .ip4_u =
 					      { .daddr = iph->daddr,
 						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
+						.tos = IPTOS_TOS(iph->tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
@@ -1181,7 +1181,7 @@ static int ipgre_open(struct net_device *dev)
 				    .nl_u = { .ip4_u =
 					      { .daddr = t->parms.iph.daddr,
 						.saddr = t->parms.iph.saddr,
-						.tos = RT_TOS(t->parms.iph.tos) } },
+						.tos = IPTOS_TOS(t->parms.iph.tos) } },
 				    .proto = IPPROTO_GRE };
 		struct rtable *rt;
 		if (ip_route_output_key(dev_net(dev), &rt, &fl))
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1381,7 +1381,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 				    .nl_u = { .ip4_u =
 					      { .daddr = daddr,
 						.saddr = rt->rt_spec_dst,
-						.tos = RT_TOS(ip_hdr(skb)->tos) } },
+						.tos = IPTOS_TOS(ip_hdr(skb)->tos) } },
 				    /* Not quite clean, but right. */
 				    .uli_u = { .ports =
 					       { .sport = tcp_hdr(skb)->dest,
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -428,7 +428,7 @@ static int ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 				    .nl_u = { .ip4_u =
 					      { .daddr = dst,
 						.saddr = tiph->saddr,
-						.tos = RT_TOS(tos) } },
+						.tos = IPTOS_TOS(tos) } },
 				    .proto = IPPROTO_IPIP };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			stats->tx_carrier_errors++;
@@ -549,7 +549,7 @@ static void ipip_tunnel_bind_dev(struct net_device *dev)
 				    .nl_u = { .ip4_u =
 					      { .daddr = iph->daddr,
 						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
+						.tos = IPTOS_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
 		struct rtable *rt;
 		if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1245,7 +1245,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 				    .nl_u = { .ip4_u =
 					      { .daddr = vif->remote,
 						.saddr = vif->local,
-						.tos = RT_TOS(iph->tos) } },
+						.tos = IPTOS_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
 		if (ip_route_output_key(net, &rt, &fl))
 			goto out_free;
@@ -1254,7 +1254,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 		struct flowi fl = { .oif = vif->link,
 				    .nl_u = { .ip4_u =
 					      { .daddr = iph->daddr,
-						.tos = RT_TOS(iph->tos) } },
+						.tos = IPTOS_TOS(iph->tos) } },
 				    .proto = IPPROTO_IPIP };
 		if (ip_route_output_key(net, &rt, &fl))
 			goto out_free;
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -33,7 +33,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		fl.nl_u.ip4_u.daddr = iph->daddr;
 		if (type == RTN_LOCAL)
 			fl.nl_u.ip4_u.saddr = iph->saddr;
-		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
+		fl.nl_u.ip4_u.tos = IPTOS_TOS(iph->tos);
 		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 		fl.mark = skb->mark;
 		fl.flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
@@ -52,7 +52,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 
 		odst = skb_dst(skb);
 		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   RT_TOS(iph->tos), rt->u.dst.dev) != 0) {
+				   IPTOS_TOS(iph->tos), rt->u.dst.dev) != 0) {
 			dst_release(&rt->u.dst);
 			return -1;
 		}
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -667,7 +667,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		faddr = ipc.opt->faddr;
 		connected = 0;
 	}
-	tos = RT_TOS(inet->tos);
+	tos = IPTOS_TOS(inet->tos);
 	if (sock_flag(sk, SOCK_LOCALROUTE) ||
 	    (msg->msg_flags & MSG_DONTROUTE) ||
 	    (ipc.opt && ipc.opt->is_strictroute)) {
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -541,7 +541,7 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	/* Try to guess incoming interface */
 	memset(&fl, 0, sizeof(fl));
 	fl.fl4_dst = eiph->saddr;
-	fl.fl4_tos = RT_TOS(eiph->tos);
+	fl.fl4_tos = IPTOS_TOS(eiph->tos);
 	fl.proto = IPPROTO_IPIP;
 	if (ip_route_output_key(dev_net(skb->dev), &rt, &fl))
 		goto out;
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -689,7 +689,7 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct flowi fl = { .nl_u = { .ip4_u =
 					      { .daddr = dst,
 						.saddr = tiph->saddr,
-						.tos = RT_TOS(tos) } },
+						.tos = IPTOS_TOS(tos) } },
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
@@ -818,7 +818,7 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 		struct flowi fl = { .nl_u = { .ip4_u =
 					      { .daddr = iph->daddr,
 						.saddr = iph->saddr,
-						.tos = RT_TOS(iph->tos) } },
+						.tos = IPTOS_TOS(iph->tos) } },
 				    .oif = tunnel->parms.link,
 				    .proto = IPPROTO_IPV6 };
 		struct rtable *rt;
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -229,7 +229,7 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			.ip4_u = {
 				.daddr = iph->daddr,
 				.saddr = 0,
-				.tos = RT_TOS(tos), } },
+				.tos = IPTOS_TOS(tos), } },
 	};
 
 	EnterFunction(10);
@@ -368,7 +368,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		IP_VS_DBG(10, "filled cport=%d\n", ntohs(*p));
 	}
 
-	if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(iph->tos))))
+	if (!(rt = __ip_vs_get_out_rt(cp, IPTOS_TOS(iph->tos))))
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -542,7 +542,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		goto tx_error;
 	}
 
-	if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(tos))))
+	if (!(rt = __ip_vs_get_out_rt(cp, IPTOS_TOS(tos))))
 		goto tx_error_icmp;
 
 	tdev = rt->u.dst.dev;
@@ -752,7 +752,7 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	EnterFunction(10);
 
-	if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(iph->tos))))
+	if (!(rt = __ip_vs_get_out_rt(cp, IPTOS_TOS(iph->tos))))
 		goto tx_error_icmp;
 
 	/* MTU checking */
@@ -880,7 +880,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	 * mangle and send the packet here (only for VS/NAT)
 	 */
 
-	if (!(rt = __ip_vs_get_out_rt(cp, RT_TOS(ip_hdr(skb)->tos))))
+	if (!(rt = __ip_vs_get_out_rt(cp, IPTOS_TOS(ip_hdr(skb)->tos))))
 		goto tx_error_icmp;
 
 	/* MTU checking */
