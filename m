From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 22/29] net: vrf: Set VRF id in various network structs
Date: Wed,  4 Feb 2015 18:34:23 -0700
Message-ID: <1423100070-31848-23-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:40161 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756348AbbBEBgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:12 -0500
Received: by mail-ie0-f181.google.com with SMTP id rd18so6678101iec.12
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:12 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRF id comes from passed in network context similar to namespace.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/inet_hashtables.h | 1 +
 include/net/neighbour.h       | 1 +
 net/core/fib_rules.c          | 3 +++
 net/core/neighbour.c          | 1 +
 net/ipv4/fib_frontend.c       | 3 +++
 net/ipv4/fib_semantics.c      | 1 +
 net/ipv4/icmp.c               | 1 +
 net/ipv4/ipmr.c               | 1 +
 net/ipv4/route.c              | 1 +
 9 files changed, 13 insertions(+)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 9ddc1b2309ce..eec177ef0798 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -95,6 +95,7 @@ static inline
 void ib_net_ctx_set(struct inet_bind_bucket *ib, struct net_ctx *ctx)
 {
 	write_pnet(&ib->ib_net_ctx.net, hold_net(ctx->net));
+	ib->ib_net_ctx.vrf = ctx->vrf;
 }
 
 static inline
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 73d0938b085c..d9e2328ad60a 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -323,6 +323,7 @@ void pneigh_net_ctx_set(struct pneigh_entry *pneigh,
 			const struct net_ctx *net_ctx)
 {
 	write_pnet(&pneigh->net_ctx.net, hold_net(net_ctx->net));
+	pneigh->net_ctx.vrf = net_ctx->vrf;
 }
 static inline
 int pneigh_net_ctx_eq(const struct pneigh_entry *pneigh,
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a1a4a23b6f6..223a4004bdd0 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -32,6 +32,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->table = table;
 	r->flags = flags;
 	r->fr_net = hold_net(ops->fro_net);
+	r->fr_vrf = ops->fro_vrf;
 
 	r->suppress_prefixlen = -1;
 	r->suppress_ifgroup = -1;
@@ -137,6 +138,7 @@ fib_rules_register(const struct fib_rules_ops *tmpl, struct net_ctx *ctx)
 
 	INIT_LIST_HEAD(&ops->rules_list);
 	ops->fro_net = ctx->net;
+	ops->fro_vrf = ctx->vrf;
 
 	err = __fib_rules_register(ops);
 	if (err) {
@@ -305,6 +307,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		goto errout;
 	}
 	rule->fr_net = hold_net(net);
+	rule->fr_vrf = sk_ctx.vrf;
 
 	if (tb[FRA_PRIORITY])
 		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 0fbbe70be170..e6c03d367f56 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1467,6 +1467,7 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 		dev_hold(dev);
 		p->dev = dev;
 		write_pnet(&p->net_ctx.net, hold_net(dev_ctx.net));
+		p->net_ctx.vrf = dev_ctx.vrf;
 		p->sysctl_table = NULL;
 
 		if (ops->ndo_neigh_setup && ops->ndo_neigh_setup(dev, p)) {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index cba1e2c9c2ec..2f06b71bed53 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -357,6 +357,7 @@ static int rtentry_to_fib_config(struct net_ctx *ctx, int cmd,
 
 	memset(cfg, 0, sizeof(*cfg));
 	cfg->fc_nlinfo.nl_net = net;
+	cfg->fc_nlinfo.nl_vrf = ctx->vrf;
 
 	if (rt->rt_dst.sa_family != AF_INET)
 		return -EAFNOSUPPORT;
@@ -564,6 +565,7 @@ static int rtm_to_fib_config(struct net_ctx *ctx, struct sk_buff *skb,
 	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
 	cfg->fc_nlinfo.nl_net = ctx->net;
+	cfg->fc_nlinfo.nl_vrf = ctx->vrf;
 
 	if (cfg->fc_type > RTN_MAX) {
 		err = -EINVAL;
@@ -714,6 +716,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		.fc_nlflags = NLM_F_CREATE | NLM_F_APPEND,
 		.fc_nlinfo = {
 			.nl_net = net,
+			.nl_vrf = dev_vrf(ifa->ifa_dev->dev),
 		},
 	};
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index a7d810cafada..65d01c5b747e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -819,6 +819,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		fi->fib_metrics = (u32 *) dst_default_metrics;
 
 	fi->fib_net = hold_net(net);
+	fi->fib_vrf = net_ctx->vrf;
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_scope = cfg->fc_scope;
 	fi->fib_flags = cfg->fc_flags;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 9d4c38292fee..b7766a73e46d 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -564,6 +564,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		goto out;
 	net = dev_net(rt->dst.dev);
 	dev_ctx.net = net;
+	dev_ctx.vrf = dev_vrf(rt->dst.dev);
 
 	/*
 	 *	Find the original header. It is expected to be valid, of course.
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a9e438c7aaa4..d00ba199a012 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2081,6 +2081,7 @@ static int __pim_rcv(struct mr_table *mrt, struct sk_buff *skb,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	dev_ctx.net = dev_net(reg_dev);
+	dev_ctx.vrf = dev_vrf(reg_dev);
 	skb_tunnel_rx(skb, reg_dev, &dev_ctx);
 
 	netif_rx(skb);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f980a42a995f..d6c5f0a8ab17 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1621,6 +1621,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 	dev_ctx.net = dev_net(rth->dst.dev);
+	dev_ctx.vrf = dev_vrf(rth->dst.dev);
 	rth->rt_genid = rt_genid_ipv4(&dev_ctx);
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
-- 
1.9.3 (Apple Git-50)
