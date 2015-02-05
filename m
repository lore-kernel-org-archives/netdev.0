From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 23/29] net: vrf: Enable vrf checks
Date: Wed,  4 Feb 2015 18:34:24 -0700
Message-ID: <1423100070-31848-24-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:58535 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756371AbbBEBgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:13 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so35416246iga.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:13 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add vrf comparison to all of the net_ctx_eq functions and a few other
places needed to enable vrf awareness.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h     |  3 ++-
 include/net/inet_hashtables.h |  3 ++-
 include/net/ip_fib.h          |  3 ++-
 include/net/ipv6.h            |  2 +-
 include/net/neighbour.h       |  6 ++++--
 include/net/net_namespace.h   |  2 +-
 include/net/sock.h            |  2 +-
 net/core/dev.c                |  9 +++++++++
 net/core/fib_rules.c          |  4 ++--
 net/core/neighbour.c          |  6 ++++--
 net/ipv4/arp.c                |  4 +++-
 net/ipv4/devinet.c            | 11 ++++++++++-
 net/ipv4/fib_frontend.c       |  2 +-
 net/ipv4/fib_semantics.c      |  5 +++++
 net/ipv4/igmp.c               |  7 +++++++
 net/ipv4/inet_hashtables.c    |  2 ++
 net/ipv4/ip_sockglue.c        |  4 ++++
 17 files changed, 60 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b6de06eda683..f4a707263446 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1857,7 +1857,8 @@ __u32 dev_vrf(const struct net_device *dev)
 static inline
 int dev_net_ctx_eq(const struct net_device *dev, struct net_ctx *ctx)
 {
-	if (net_eq(dev_net(dev), ctx->net))
+	if (net_eq(dev_net(dev), ctx->net) &&
+	    vrf_eq(dev_vrf(dev), ctx->vrf))
 		return 1;
 
 	return 0;
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index eec177ef0798..199809e46133 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -101,7 +101,8 @@ void ib_net_ctx_set(struct inet_bind_bucket *ib, struct net_ctx *ctx)
 static inline
 int ib_net_ctx_eq(struct inet_bind_bucket *ib, struct net_ctx *ctx)
 {
-	if (net_eq(ib_net(ib), ctx->net))
+	if (net_eq(ib_net(ib), ctx->net) &&
+	    vrf_eq(ib->ib_net_ctx.vrf, ctx->vrf))
 		return 1;
 
 	return 0;
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e6b823c0305e..d49358bc342c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -127,7 +127,8 @@ struct fib_info {
 static inline
 int fib_net_ctx_eq(const struct fib_info *fi, const struct net_ctx *ctx)
 {
-	if (net_eq(fi->fib_net_ctx.net, ctx->net))
+	if (net_eq(fi->fib_net_ctx.net, ctx->net) &&
+	    vrf_eq(fi->fib_net_ctx.vrf, ctx->vrf))
 		return 1;
 
 	return 0;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 61f8b6df8bb9..ba1d145d67fd 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -247,7 +247,7 @@ static inline
 int fl_net_ctx_eq(struct ip6_flowlabel *fl, struct net_ctx *ctx)
 {
 #ifdef CONFIG_NET_NS
-	return net_eq(fl->fl_net, ctx->net);
+	return net_eq(fl->fl_net, ctx->net) && vrf_eq(fl->fl_vrf, ctx->vrf);
 #else
 	return 1;
 #endif
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index d9e2328ad60a..f3527b25d612 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -294,7 +294,8 @@ int neigh_parms_net_ctx_eq(const struct neigh_parms *parms,
 			   const struct net_ctx *net_ctx)
 {
 #ifdef CONFIG_NET_NS
-	if (net_eq(neigh_parms_net(parms), net_ctx->net))
+	if (net_eq(neigh_parms_net(parms), net_ctx->net) &&
+	    vrf_eq(neigh_parms_vrf(parms), net_ctx->vrf))
 		return 1;
 
 	return 0;
@@ -330,7 +331,8 @@ int pneigh_net_ctx_eq(const struct pneigh_entry *pneigh,
 		      const struct net_ctx *net_ctx)
 {
 #ifdef CONFIG_NET_NS
-	if (net_eq(pneigh_net(pneigh), net_ctx->net))
+	if (net_eq(pneigh_net(pneigh), net_ctx->net) &&
+	    vrf_eq(pneigh->net_ctx.vrf, net_ctx->vrf))
 		return 1;
 
 	return 0;
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index d0a3414758f8..7ae98b85cd21 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -215,7 +215,7 @@ int net_eq(const struct net *net1, const struct net *net2)
 static inline
 int net_ctx_eq(struct net_ctx *ctx1, struct net_ctx *ctx2)
 {
-	return net_eq(ctx1->net, ctx2->net);
+	return net_eq(ctx1->net, ctx2->net) && vrf_eq(ctx1->vrf, ctx2->vrf);
 }
 
 
diff --git a/include/net/sock.h b/include/net/sock.h
index d3668b691f82..a9b45fca4605 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2205,7 +2205,7 @@ void sock_net_set(struct sock *sk, struct net *net)
 static inline
 int sock_net_ctx_eq(struct sock *sk, struct net_ctx *ctx)
 {
-	return net_eq(sock_net(sk), ctx->net);
+	return net_eq(sock_net(sk), ctx->net) && vrf_eq(sk->sk_vrf, ctx->vrf);
 }
 
 /*
diff --git a/net/core/dev.c b/net/core/dev.c
index d64f5b107dba..adf575d6d267 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -688,6 +688,9 @@ struct net_device *__dev_get_by_name_ctx(struct net_ctx *ctx, const char *name)
 {
 	struct net_device *dev = __dev_get_by_name(ctx->net, name);
 
+	if (dev && !vrf_eq(dev_vrf(dev), ctx->vrf))
+		dev = NULL;
+
 	return dev;
 }
 EXPORT_SYMBOL(__dev_get_by_name_ctx);
@@ -771,6 +774,9 @@ struct net_device *__dev_get_by_index_ctx(struct net_ctx *ctx, int ifindex)
 {
 	struct net_device *dev = __dev_get_by_index(ctx->net, ifindex);
 
+	if (dev && !vrf_eq(dev_vrf(dev), ctx->vrf))
+		dev = NULL;
+
 	return dev;
 }
 EXPORT_SYMBOL(__dev_get_by_index_ctx);
@@ -814,6 +820,9 @@ struct net_device *dev_get_by_index_rcu_ctx(struct net_ctx *ctx, int ifindex)
 {
 	struct net_device *dev = dev_get_by_index_rcu(ctx->net, ifindex);
 
+	if (dev && !vrf_eq(dev_vrf(dev), ctx->vrf))
+		dev = NULL;
+
 	return dev;
 }
 EXPORT_SYMBOL(dev_get_by_index_rcu_ctx);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 223a4004bdd0..aea74e16360c 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -317,7 +317,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 
 		rule->iifindex = -1;
 		nla_strlcpy(rule->iifname, tb[FRA_IIFNAME], IFNAMSIZ);
-		dev = __dev_get_by_name(net, rule->iifname);
+		dev = __dev_get_by_name_ctx(&sk_ctx, rule->iifname);
 		if (dev)
 			rule->iifindex = dev->ifindex;
 	}
@@ -327,7 +327,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 
 		rule->oifindex = -1;
 		nla_strlcpy(rule->oifname, tb[FRA_OIFNAME], IFNAMSIZ);
-		dev = __dev_get_by_name(net, rule->oifname);
+		dev = __dev_get_by_name_ctx(&sk_ctx, rule->oifname);
 		if (dev)
 			rule->oifindex = dev->ifindex;
 	}
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e6c03d367f56..46b7e8cc7c70 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2846,9 +2846,11 @@ static void neigh_copy_dflt_parms(struct net_ctx *ctx, struct neigh_parms *p,
 
 	rcu_read_lock();
 	for_each_netdev_rcu(ctx->net, dev) {
-		struct neigh_parms *dst_p =
-				neigh_get_dev_parms_rcu(dev, family);
+		struct neigh_parms *dst_p;
 
+		if (!vrf_eq(dev_vrf(dev), ctx->vrf))
+			continue;
+		dst_p = neigh_get_dev_parms_rcu(dev, family);
 		if (dst_p && !test_bit(index, dst_p->data_state))
 			dst_p->data[index] = p->data[index];
 	}
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index b24773b275a9..ed1453b9eeab 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1021,6 +1021,8 @@ static int arp_req_set_public(struct net_ctx *ctx, struct arpreq *r,
 	if (!dev && (r->arp_flags & ATF_COM)) {
 		dev = dev_getbyhwaddr_rcu(net, r->arp_ha.sa_family,
 				      r->arp_ha.sa_data);
+		if (dev && !vrf_eq(dev_vrf(dev), ctx->vrf))
+			dev = NULL;
 		if (!dev)
 			return -ENODEV;
 	}
@@ -1214,7 +1216,7 @@ int arp_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg)
 	rtnl_lock();
 	if (r.arp_dev[0]) {
 		err = -ENODEV;
-		dev = __dev_get_by_name(net, r.arp_dev);
+		dev = __dev_get_by_name_ctx(ctx, r.arp_dev);
 		if (dev == NULL)
 			goto out;
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7c0c3bc17599..54afa816ff66 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -951,7 +951,7 @@ int devinet_ioctl(struct net_ctx *net_ctx, unsigned int cmd, void __user *arg)
 	rtnl_lock();
 
 	ret = -ENODEV;
-	dev = __dev_get_by_name(net, ifr.ifr_name);
+	dev = __dev_get_by_name_ctx(net_ctx, ifr.ifr_name);
 	if (!dev)
 		goto done;
 
@@ -1166,6 +1166,7 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	__be32 addr = 0;
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
+	__u32 vrf = dev_vrf(dev);
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -1192,6 +1193,8 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 	   in dev_base list.
 	 */
 	for_each_netdev_rcu(net, dev) {
+		if (!vrf_eq(dev_vrf(dev), vrf))
+			continue;
 		in_dev = __in_dev_get_rcu(dev);
 		if (!in_dev)
 			continue;
@@ -1266,6 +1269,8 @@ __be32 inet_confirm_addr(struct net_ctx *ctx, struct in_device *in_dev,
 
 	rcu_read_lock();
 	for_each_netdev_rcu(ctx->net, dev) {
+		if (!vrf_eq(dev_vrf(dev), ctx->vrf))
+			continue;
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev) {
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
@@ -1561,6 +1566,8 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 				goto cont;
 			if (h > s_h || idx > s_idx)
 				s_ip_idx = 0;
+			if (!vrf_eq(dev_vrf(dev), vrf))
+				goto cont;
 			in_dev = __in_dev_get_rcu(dev);
 			if (!in_dev)
 				goto cont;
@@ -1883,6 +1890,8 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
+			if (!vrf_eq(dev_vrf(dev), vrf))
+				goto cont;
 			in_dev = __in_dev_get_rcu(dev);
 			if (!in_dev)
 				goto cont;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2f06b71bed53..8713618e2835 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -418,7 +418,7 @@ static int rtentry_to_fib_config(struct net_ctx *ctx, int cmd,
 		colon = strchr(devname, ':');
 		if (colon)
 			*colon = 0;
-		dev = __dev_get_by_name(net, devname);
+		dev = __dev_get_by_name_ctx(ctx, devname);
 		if (!dev)
 			return -ENODEV;
 		cfg->fc_oif = dev->ifindex;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 65d01c5b747e..0aa5990b1c02 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -929,6 +929,11 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		err = -ENODEV;
 		if (nh->nh_dev == NULL)
 			goto failure;
+		if (!vrf_eq(dev_vrf(nh->nh_dev), net_ctx->vrf)) {
+			dev_put(nh->nh_dev);
+			nh->nh_dev = NULL;
+			goto failure;
+		}
 	} else {
 		change_nexthops(fi) {
 			err = fib_check_nh(cfg, fi, nexthop_nh);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 86aa303a1cf7..fddc3bbf6b8b 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2451,6 +2451,9 @@ static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *in_dev;
 
+		if (!vrf_eq(dev_vrf(state->dev), ctx->vrf))
+			continue;
+
 		in_dev = __in_dev_get_rcu(state->dev);
 		if (!in_dev)
 			continue;
@@ -2596,6 +2599,10 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 	state->im = NULL;
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *idev;
+
+		if (!vrf_eq(dev_vrf(state->dev), ctx->vrf))
+			continue;
+
 		idev = __in_dev_get_rcu(state->dev);
 		if (unlikely(idev == NULL))
 			continue;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 71c31c81aea1..0dcde9839d66 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -220,6 +220,8 @@ struct sock *__inet_lookup_listener(struct net_ctx *ctx,
 	result = NULL;
 	hiscore = 0;
 	sk_nulls_for_each_rcu(sk, node, &ilb->head) {
+		if (!vrf_eq(sk->sk_vrf, ctx->vrf) && !vrf_is_any(sk->sk_vrf))
+			continue;
 		score = compute_score(sk, ctx, hnum, daddr, dif);
 		if (score > hiscore) {
 			result = sk;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index eeb51e935379..b5521f7b36b1 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -728,6 +728,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	{
 		struct net_device *dev = NULL;
 		int ifindex;
+		__u32 vrf;
 
 		if (optlen != sizeof(int))
 			goto e_inval;
@@ -743,7 +744,10 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		err = -EADDRNOTAVAIL;
 		if (!dev)
 			break;
+		vrf = dev_vrf(dev);
 		dev_put(dev);
+		if (!vrf_eq(vrf, sk_ctx.vrf))
+			break;
 
 		err = -EINVAL;
 		if (sk->sk_bound_dev_if)
-- 
1.9.3 (Apple Git-50)
