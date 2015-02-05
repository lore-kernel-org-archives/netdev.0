From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 20/29] net: vrf: Add vrf context to flow struct
Date: Wed,  4 Feb 2015 18:34:21 -0700
Message-ID: <1423100070-31848-21-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36129 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966880AbbBEBgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:10 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so6713691ier.10
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:10 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/flow.h              |  7 ++++++-
 include/net/route.h             |  4 ++--
 net/ipv4/devinet.c              |  2 +-
 net/ipv4/fib_frontend.c         |  5 ++++-
 net/ipv4/fib_rules.c            |  2 ++
 net/ipv4/fib_semantics.c        |  1 +
 net/ipv4/icmp.c                 |  3 +++
 net/ipv4/inet_connection_sock.c |  4 ++--
 net/ipv4/ip_output.c            |  2 +-
 net/ipv4/ipmr.c                 |  2 ++
 net/ipv4/netfilter.c            |  1 +
 net/ipv4/ping.c                 |  2 +-
 net/ipv4/raw.c                  |  2 +-
 net/ipv4/route.c                | 23 +++++++++++++----------
 net/ipv4/syncookies.c           |  2 +-
 net/ipv4/udp.c                  |  3 ++-
 net/ipv4/xfrm4_policy.c         |  2 ++
 net/sctp/protocol.c             |  1 +
 18 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 07e7a58b9aac..6d35a8bfbe72 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -30,6 +30,7 @@ struct flowi_common {
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
 	__u32	flowic_secid;
+	__u32	flowic_vrf;
 };
 
 union flowi_uli {
@@ -66,6 +67,7 @@ struct flowi4 {
 #define flowi4_proto		__fl_common.flowic_proto
 #define flowi4_flags		__fl_common.flowic_flags
 #define flowi4_secid		__fl_common.flowic_secid
+#define flowi4_vrf		__fl_common.flowic_vrf
 
 	/* (saddr,daddr) must be grouped, same order as in IP header */
 	__be32			saddr;
@@ -81,7 +83,7 @@ struct flowi4 {
 #define fl4_gre_key		uli.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
-static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
+static inline void flowi4_init_output(struct flowi4 *fl4, __u32 vrf, int oif,
 				      __u32 mark, __u8 tos, __u8 scope,
 				      __u8 proto, __u8 flags,
 				      __be32 daddr, __be32 saddr,
@@ -95,6 +97,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->flowi4_proto = proto;
 	fl4->flowi4_flags = flags;
 	fl4->flowi4_secid = 0;
+	fl4->flowi4_vrf = vrf;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
 	fl4->fl4_dport = dport;
@@ -122,6 +125,7 @@ struct flowi6 {
 #define flowi6_proto		__fl_common.flowic_proto
 #define flowi6_flags		__fl_common.flowic_flags
 #define flowi6_secid		__fl_common.flowic_secid
+#define flowi6_vrf		__fl_common.flowic_vrf
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
 	__be32			flowlabel;
@@ -165,6 +169,7 @@ struct flowi {
 #define flowi_proto	u.__fl_common.flowic_proto
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
+#define flowi_vrf	u.__fl_common.flowic_vrf
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/include/net/route.h b/include/net/route.h
index 5f0b770225d7..a062df826c67 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -139,7 +139,7 @@ static inline struct rtable *ip_route_output_ports(struct net_ctx *ctx, struct f
 						   __be16 dport, __be16 sport,
 						   __u8 proto, __u8 tos, int oif)
 {
-	flowi4_init_output(fl4, oif, sk ? sk->sk_mark : 0, tos,
+	flowi4_init_output(fl4, ctx->vrf, oif, sk ? sk->sk_mark : 0, tos,
 			   RT_SCOPE_UNIVERSE, proto,
 			   sk ? inet_sk_flowi_flags(sk) : 0,
 			   daddr, saddr, dport, sport);
@@ -250,7 +250,7 @@ static inline void ip_route_connect_init(struct flowi4 *fl4, __be32 dst, __be32
 	if (inet_sk(sk)->transparent)
 		flow_flags |= FLOWI_FLAG_ANYSRC;
 
-	flowi4_init_output(fl4, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
+	flowi4_init_output(fl4, sk->sk_vrf, oif, sk->sk_mark, tos, RT_SCOPE_UNIVERSE,
 			   protocol, flow_flags, dst, src, dport, sport);
 }
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 59de98a44508..02ffbfb8bfee 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -155,7 +155,7 @@ struct net_device *__ip_dev_find(struct net_ctx *ctx, __be32 addr, bool devref)
 		}
 	}
 	if (!result) {
-		struct flowi4 fl4 = { .daddr = addr };
+		struct flowi4 fl4 = { .daddr = addr, .flowi4_vrf = ctx->vrf };
 		struct fib_result res = { 0 };
 		struct fib_table *local;
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b068ab996cc3..f2a8a557a3d8 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -155,7 +155,7 @@ static inline unsigned int __inet_dev_addr_type(struct net_ctx *ctx,
 						__be32 addr)
 {
 	struct net *net = ctx->net;
-	struct flowi4		fl4 = { .daddr = addr };
+	struct flowi4		fl4 = { .daddr = addr, .flowi4_vrf = ctx->vrf };
 	struct fib_result	res;
 	unsigned int ret = RTN_BROADCAST;
 	struct fib_table *local_table;
@@ -221,6 +221,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 		fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 		fl4.flowi4_scope = scope;
 		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
+		fl4.flowi4_vrf = dev_ctx.vrf;
 		if (!fib_lookup(&dev_ctx, &fl4, &res))
 			return FIB_RES_PREFSRC(&dev_ctx, res);
 	} else {
@@ -258,6 +259,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	no_addr = idev->ifa_list == NULL;
 
 	fl4.flowi4_mark = IN_DEV_SRC_VMARK(idev) ? skb->mark : 0;
+	fl4.flowi4_vrf = dev_ctx.vrf;
 
 	if (fib_lookup(&dev_ctx, &fl4, &res))
 		goto last_resort;
@@ -292,6 +294,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	if (rpf == 1)
 		goto e_rpf;
 	fl4.flowi4_oif = dev->ifindex;
+	fl4.flowi4_vrf = dev_vrf(dev);
 
 	ret = 0;
 	if (fib_lookup(&dev_ctx, &fl4, &res) == 0) {
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index bb9399e2c1cb..0dc8adf7b767 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -55,6 +55,8 @@ int __fib_lookup(struct net_ctx *ctx, struct flowi4 *flp, struct fib_result *res
 	};
 	int err;
 
+	flp->flowi4_vrf = ctx->vrf;
+
 	err = fib_rules_lookup(ctx->net->ipv4.rules_ops, flowi4_to_flowi(flp),
 			       0, &arg);
 #ifdef CONFIG_IP_ROUTE_CLASSID
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 99af28c2fb6d..9fc5487e66fe 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -617,6 +617,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 				.flowi4_scope = cfg->fc_scope + 1,
 				.flowi4_oif = nh->nh_oif,
 				.flowi4_iif = LOOPBACK_IFINDEX,
+				.flowi4_vrf = net_ctx->vrf,
 			};
 
 			/* It is not necessary, but requires a bit of thinking */
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 2d1e98e6ad14..9d4c38292fee 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -426,6 +426,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.flowi4_mark = mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
+	fl4.flowi4_vrf = skb->vrf;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(&dev_ctx, &fl4);
 	if (IS_ERR(rt))
@@ -457,6 +458,7 @@ static struct rtable *icmp_route_lookup(struct net_ctx *ctx,
 	fl4->flowi4_mark = mark;
 	fl4->flowi4_tos = RT_TOS(tos);
 	fl4->flowi4_proto = IPPROTO_ICMP;
+	fl4->flowi4_vrf = skb_in->vrf;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
@@ -490,6 +492,7 @@ static struct rtable *icmp_route_lookup(struct net_ctx *ctx,
 		unsigned long orefdst;
 
 		fl4_2.daddr = fl4_dec.saddr;
+		fl4_2.flowi4_vrf = skb_in->vrf;
 		rt2 = ip_route_output_key(ctx, &fl4_2);
 		if (IS_ERR(rt2)) {
 			err = PTR_ERR(rt2);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3b8df03c69db..ace32910667e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -407,7 +407,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	struct net_ctx ctx = { .net = net, .vrf = ireq->ir_vrf };
 	int flags = inet_sk_flowi_flags(sk);
 
-	flowi4_init_output(fl4, sk->sk_bound_dev_if, ireq->ir_mark,
+	flowi4_init_output(fl4, ctx.vrf, sk->sk_bound_dev_if, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol,
 			   flags,
@@ -445,7 +445,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 
 	rcu_read_lock();
 	opt = rcu_dereference(newinet->inet_opt);
-	flowi4_init_output(fl4, sk->sk_bound_dev_if, inet_rsk(req)->ir_mark,
+	flowi4_init_output(fl4, ctx.vrf, sk->sk_bound_dev_if, inet_rsk(req)->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
 			   (opt && opt->opt.srr) ? opt->opt.faddr : ireq->ir_rmt_addr,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 383bac145bf4..9b2d8d7ff6cb 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1556,7 +1556,7 @@ void ip_send_unicast_reply(struct net_ctx *ctx, struct sk_buff *skb,
 			daddr = replyopts.opt.opt.faddr;
 	}
 
-	flowi4_init_output(&fl4, arg->bound_dev_if,
+	flowi4_init_output(&fl4, skb->vrf, arg->bound_dev_if,
 			   IP4_REPLY_MARK(ctx->net, skb->mark),
 			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 84d6efeeb072..a9e438c7aaa4 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -458,6 +458,7 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 		.flowi4_oif	= dev->ifindex,
 		.flowi4_iif	= skb->skb_iif ? : LOOPBACK_IFINDEX,
 		.flowi4_mark	= skb->mark,
+		.flowi4_vrf	= skb->vrf,
 	};
 	int err;
 
@@ -1934,6 +1935,7 @@ static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 			       LOOPBACK_IFINDEX :
 			       skb->dev->ifindex),
 		.flowi4_mark = skb->mark,
+		.flowi4_vrf = skb->vrf,
 	};
 	struct mr_table *mrt;
 	int err;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index a10ab84b69d8..c00ea581839a 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -43,6 +43,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
 	fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_flags = flags;
+	fl4.flowi4_vrf = skb->vrf;
 	rt = ip_route_output_key(&ctx, &fl4);
 	if (IS_ERR(rt))
 		return PTR_ERR(rt);
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index bca4f27502b0..e08f7ae8d8fe 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -779,7 +779,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;
 
-	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+	flowi4_init_output(&fl4, sk_ctx.vrf, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0);
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index c06dd58e538b..f3a349ea3dd8 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -591,7 +591,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;
 
-	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+	flowi4_init_output(&fl4, sk_ctx.vrf, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk) |
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 018e292ff145..8271c5b30322 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -503,7 +503,7 @@ EXPORT_SYMBOL(__ip_select_ident);
 
 static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 			     const struct iphdr *iph,
-			     int oif, u8 tos,
+			     __u32 vrf, int oif, u8 tos,
 			     u8 prot, u32 mark, int flow_flags)
 {
 	if (sk) {
@@ -511,10 +511,11 @@ static void __build_flow_key(struct flowi4 *fl4, const struct sock *sk,
 
 		oif = sk->sk_bound_dev_if;
 		mark = sk->sk_mark;
+		vrf = sk->sk_vrf;
 		tos = RT_CONN_FLAGS(sk);
 		prot = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
 	}
-	flowi4_init_output(fl4, oif, mark, tos,
+	flowi4_init_output(fl4, vrf, oif, mark, tos,
 			   RT_SCOPE_UNIVERSE, prot,
 			   flow_flags,
 			   iph->daddr, iph->saddr, 0, 0);
@@ -529,7 +530,7 @@ static void build_skb_flow_key(struct flowi4 *fl4, const struct sk_buff *skb,
 	u8 prot = iph->protocol;
 	u32 mark = skb->mark;
 
-	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
+	__build_flow_key(fl4, sk, iph, skb->vrf, oif, tos, prot, mark, 0);
 }
 
 static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
@@ -542,7 +543,7 @@ static void build_sk_flow_key(struct flowi4 *fl4, const struct sock *sk)
 	inet_opt = rcu_dereference(inet->inet_opt);
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
-	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
+	flowi4_init_output(fl4, sk->sk_vrf, sk->sk_bound_dev_if, sk->sk_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
 			   inet_sk_flowi_flags(sk),
@@ -794,7 +795,7 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 
 	rt = (struct rtable *) dst;
 
-	__build_flow_key(&fl4, sk, iph, oif, tos, prot, mark, 0);
+	__build_flow_key(&fl4, sk, iph, skb->vrf, oif, tos, prot, mark, 0);
 	__ip_do_redirect(rt, skb, &fl4, true);
 }
 
@@ -1006,7 +1007,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net_ctx *ctx, u32 mtu,
 	if (!mark)
 		mark = IP4_REPLY_MARK(ctx->net, skb->mark);
 
-	__build_flow_key(&fl4, NULL, iph, oif,
+	__build_flow_key(&fl4, NULL, iph, skb->vrf, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(ctx, &fl4);
 	if (!IS_ERR(rt)) {
@@ -1023,7 +1024,7 @@ static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	struct rtable *rt;
 	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
-	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	__build_flow_key(&fl4, sk, iph, skb->vrf, 0, 0, 0, 0, 0);
 
 	if (!fl4.flowi4_mark)
 		fl4.flowi4_mark = IP4_REPLY_MARK(sk_ctx.net, skb->mark);
@@ -1056,7 +1057,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 		goto out;
 	}
 
-	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	__build_flow_key(&fl4, sk, iph, skb->vrf, 0, 0, 0, 0, 0);
 
 	rt = (struct rtable *)odst;
 	if (odst->obsolete && odst->ops->check(odst, 0) == NULL) {
@@ -1096,7 +1097,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net_ctx *ctx,
 	struct flowi4 fl4;
 	struct rtable *rt;
 
-	__build_flow_key(&fl4, NULL, iph, oif,
+	__build_flow_key(&fl4, NULL, iph, skb->vrf, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(ctx, &fl4);
 	if (!IS_ERR(rt)) {
@@ -1113,7 +1114,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 	struct rtable *rt;
 	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
-	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	__build_flow_key(&fl4, sk, iph, skb->vrf, 0, 0, 0, 0, 0);
 	rt = __ip_route_output_key(&sk_ctx, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_do_redirect(rt, skb, &fl4, false);
@@ -1190,6 +1191,7 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 		fl4.flowi4_oif = rt->dst.dev->ifindex;
 		fl4.flowi4_iif = skb->dev->ifindex;
 		fl4.flowi4_mark = skb->mark;
+		fl4.flowi4_vrf = skb->vrf;
 
 		rcu_read_lock();
 		if (fib_lookup(&dev_ctx, &fl4, &res) == 0)
@@ -1724,6 +1726,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.flowi4_iif = dev->ifindex;
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
+	fl4.flowi4_vrf  = skb->vrf;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 7702e1f94174..916994d21f17 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -368,7 +368,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this.
 	 */
-	flowi4_init_output(&fl4, sk->sk_bound_dev_if, ireq->ir_mark,
+	flowi4_init_output(&fl4, skb->vrf, sk->sk_bound_dev_if, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
 			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1787dc8e5db3..1446c84428d8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1023,7 +1023,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		struct net *net = sk_ctx.net;
 
 		fl4 = &fl4_stack;
-		flowi4_init_output(fl4, ipc.oif, sk->sk_mark, tos,
+		flowi4_init_output(fl4, sk_ctx.vrf, ipc.oif, sk->sk_mark, tos,
 				   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 				   inet_sk_flowi_flags(sk),
 				   faddr, saddr, dport, inet->inet_sport);
@@ -1083,6 +1083,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	fl4->saddr = saddr;
 	fl4->fl4_dport = dport;
 	fl4->fl4_sport = inet->inet_sport;
+	fl4->flowi4_vrf = sk_ctx.vrf;
 	up->pending = AF_INET;
 
 do_append_data:
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c892b6bb0383..660059d09872 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -28,6 +28,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net_ctx *ctx, struct flowi4 *
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->daddr = daddr->a4;
 	fl4->flowi4_tos = tos;
+	fl4->flowi4_vrf = ctx->vrf;
 	if (saddr)
 		fl4->saddr = saddr->a4;
 
@@ -112,6 +113,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
 	fl4->flowi4_oif = reverse ? skb->skb_iif : oif;
+	fl4->flowi4_vrf = skb->vrf;
 
 	if (!ip_is_fragment(iph)) {
 		switch (iph->protocol) {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d59affad3f01..11c1a58296d8 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -435,6 +435,7 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	fl4->daddr  = daddr->v4.sin_addr.s_addr;
 	fl4->fl4_dport = daddr->v4.sin_port;
 	fl4->flowi4_proto = IPPROTO_SCTP;
+	fl4->flowi4_vrf = sk_ctx.vrf;
 	if (asoc) {
 		fl4->flowi4_tos = RT_CONN_FLAGS(asoc->base.sk);
 		fl4->flowi4_oif = asoc->base.sk->sk_bound_dev_if;
-- 
1.9.3 (Apple Git-50)
