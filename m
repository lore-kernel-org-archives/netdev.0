From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 25/29] net: vrf: Handle VRF any context
Date: Wed,  4 Feb 2015 18:34:26 -0700
Message-ID: <1423100070-31848-26-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:49250 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756377AbbBEBgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:15 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so6775741iec.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:14 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRF any context applies only to tasks to and sockets. Devices are
associated with a single VRF, and skb's by extension are connected to
a single VRF.

Listen sockets and unconnected sockets can be opened in a "VRF any"
context allowing a single daemon to provide service across all VRFs
in a namespace. Connected sockets must be in a specific vrf context.
Accepted sockets acquire the VRF context from the device the packet
enters (via the skb).

"VRF any" context is also useful for tasks wanting to view L3/L4
data for all VRFs.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h     | 15 +++++++++++++++
 include/net/inet_hashtables.h |  4 +++-
 include/net/neighbour.h       | 29 +++++++++++++++++++++++++++++
 include/net/sock.h            |  2 +-
 net/core/dev.c                |  2 +-
 net/core/fib_rules.c          |  4 ++++
 net/core/neighbour.c          | 18 +++++++++---------
 net/ipv4/af_inet.c            |  4 ++++
 net/ipv4/arp.c                |  6 ++++++
 net/ipv4/datagram.c           |  3 +++
 net/ipv4/devinet.c            |  7 +++++--
 net/ipv4/fib_frontend.c       |  4 ++++
 net/ipv4/igmp.c               |  4 ++--
 net/ipv4/raw.c                |  9 +++++++++
 net/ipv4/udp.c                |  4 ++++
 15 files changed, 99 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7d983f005622..a1de460b1b7c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1864,6 +1864,21 @@ int dev_net_ctx_eq(const struct net_device *dev, struct net_ctx *ctx)
 	return 0;
 }
 
+/*
+ * same as above except if ctx has 'any' vrf that it counts as a match
+ * (devices are not assigned to 'any' vrf)
+ */
+static inline
+int dev_net_ctx_eq_any(const struct net_device *dev, struct net_ctx *ctx)
+{
+	if (net_eq(dev_net(dev), ctx->net) &&
+	   (vrf_eq(dev->nd_vrf, ctx->vrf) || vrf_is_any(ctx->vrf))) {
+		return 1;
+	}
+
+	return 0;
+}
+
 static inline bool netdev_uses_dsa(struct net_device *dev)
 {
 #if IS_ENABLED(CONFIG_NET_DSA)
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 199809e46133..e4ba898af422 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -101,8 +101,10 @@ void ib_net_ctx_set(struct inet_bind_bucket *ib, struct net_ctx *ctx)
 static inline
 int ib_net_ctx_eq(struct inet_bind_bucket *ib, struct net_ctx *ctx)
 {
+	__u32 vrf = ib->ib_net_ctx.vrf;
+
 	if (net_eq(ib_net(ib), ctx->net) &&
-	    vrf_eq(ib->ib_net_ctx.vrf, ctx->vrf))
+	    (vrf_eq_or_any(vrf, ctx->vrf)))
 		return 1;
 
 	return 0;
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index f3527b25d612..122a3acda83e 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -303,6 +303,21 @@ int neigh_parms_net_ctx_eq(const struct neigh_parms *parms,
 	return 1;
 #endif
 }
+static inline int neigh_parms_net_ctx_eq_any(const struct neigh_parms *parms,
+					     const struct net_ctx *net_ctx)
+{
+#ifdef CONFIG_NET_NS
+	if (net_eq(neigh_parms_net(parms), net_ctx->net) &&
+	    (vrf_eq(neigh_parms_vrf(parms), net_ctx->vrf) ||
+	     vrf_is_any(net_ctx->vrf))) {
+		return 1;
+	}
+
+	return 0;
+#else
+	return 1;
+#endif
+}
 unsigned long neigh_rand_reach_time(unsigned long base);
 
 void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
@@ -340,6 +355,20 @@ int pneigh_net_ctx_eq(const struct pneigh_entry *pneigh,
 	return 1;
 #endif
 }
+static inline
+int pneigh_net_ctx_eq_any(const struct pneigh_entry *pneigh,
+		      const struct net_ctx *net_ctx)
+{
+#ifdef CONFIG_NET_NS
+	if (net_eq(pneigh_net(pneigh), net_ctx->net) &&
+	    vrf_eq_or_any(pneigh->net_ctx.vrf, net_ctx->vrf))
+		return 1;
+
+	return 0;
+#else
+	return 1;
+#endif
+}
 
 void neigh_app_ns(struct neighbour *n);
 void neigh_for_each(struct neigh_table *tbl,
diff --git a/include/net/sock.h b/include/net/sock.h
index a9b45fca4605..6a880d04361e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2205,7 +2205,7 @@ void sock_net_set(struct sock *sk, struct net *net)
 static inline
 int sock_net_ctx_eq(struct sock *sk, struct net_ctx *ctx)
 {
-	return net_eq(sock_net(sk), ctx->net) && vrf_eq(sk->sk_vrf, ctx->vrf);
+	return net_eq(sock_net(sk), ctx->net) && vrf_eq_or_any(sk->sk_vrf, ctx->vrf);
 }
 
 /*
diff --git a/net/core/dev.c b/net/core/dev.c
index d96d0d46dc6e..0dae3cfd2890 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -688,7 +688,7 @@ struct net_device *__dev_get_by_name_ctx(struct net_ctx *ctx, const char *name)
 {
 	struct net_device *dev = __dev_get_by_name(ctx->net, name);
 
-	if (dev && !vrf_eq(dev_vrf(dev), ctx->vrf))
+	if (dev && !vrf_eq_or_any(dev_vrf(dev), ctx->vrf))
 		dev = NULL;
 
 	return dev;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index aea74e16360c..637a6738165e 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -301,6 +301,10 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (err < 0)
 		goto errout;
 
+	/* cannot create new rule for any vrf context */
+	if (vrf_is_any(sk_ctx.vrf))
+		goto errout;
+
 	rule = kzalloc(ops->rule_size, GFP_KERNEL);
 	if (rule == NULL) {
 		err = -ENOMEM;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 46b7e8cc7c70..d15f84de860d 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -442,7 +442,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl,
 	     n != NULL;
 	     n = rcu_dereference_bh(n->next)) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
-		    dev_net_ctx_eq(n->dev, ctx)) {
+		    dev_net_ctx_eq_any(n->dev, ctx)) {
 			if (!atomic_inc_not_zero(&n->refcnt))
 				n = NULL;
 			NEIGH_CACHE_STAT_INC(tbl, hits);
@@ -2138,7 +2138,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 		nidx = 0;
 		p = list_next_entry(&tbl->parms, list);
 		list_for_each_entry_from(p, &tbl->parms_list, list) {
-			if (!neigh_parms_net_ctx_eq(p, &ctx))
+			if (!neigh_parms_net_ctx_eq_any(p, &ctx))
 				continue;
 
 			if (nidx < neigh_skip)
@@ -2271,7 +2271,7 @@ static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		for (n = rcu_dereference_bh(nht->hash_buckets[h]), idx = 0;
 		     n != NULL;
 		     n = rcu_dereference_bh(n->next)) {
-			if (!dev_net_ctx_eq(n->dev, &ctx))
+			if (!dev_net_ctx_eq_any(n->dev, &ctx))
 				continue;
 			if (idx < s_idx)
 				goto next;
@@ -2308,7 +2308,7 @@ static int pneigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->phash_buckets[h], idx = 0; n; n = n->next) {
-			if (!dev_net_ctx_eq(n->dev, &ctx))
+			if (!dev_net_ctx_eq_any(n->dev, &ctx))
 				continue;
 			if (idx < s_idx)
 				goto next;
@@ -2446,7 +2446,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 		n = rcu_dereference_bh(nht->hash_buckets[bucket]);
 
 		while (n) {
-			if (!dev_net_ctx_eq(n->dev, ctx))
+			if (!dev_net_ctx_eq_any(n->dev, ctx))
 				goto next;
 			if (state->neigh_sub_iter) {
 				loff_t fakep = 0;
@@ -2489,7 +2489,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 
 	while (1) {
 		while (n) {
-			if (!dev_net_ctx_eq(n->dev, ctx))
+			if (!dev_net_ctx_eq_any(n->dev, ctx))
 				goto next;
 			if (state->neigh_sub_iter) {
 				void *v = state->neigh_sub_iter(state, n, pos);
@@ -2546,7 +2546,7 @@ static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
 		pn = tbl->phash_buckets[bucket];
-		while (pn && !pneigh_net_ctx_eq(pn, ctx))
+		while (pn && !pneigh_net_ctx_eq_any(pn, ctx))
 			pn = pn->next;
 		if (pn)
 			break;
@@ -2566,13 +2566,13 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 
 	do {
 		pn = pn->next;
-	} while (pn && !pneigh_net_ctx_eq(pn, ctx));
+	} while (pn && !pneigh_net_ctx_eq_any(pn, ctx));
 
 	while (!pn) {
 		if (++state->bucket > PNEIGH_HASHMASK)
 			break;
 		pn = tbl->phash_buckets[state->bucket];
-		while (pn && !pneigh_net_ctx_eq(pn, ctx))
+		while (pn && !pneigh_net_ctx_eq_any(pn, ctx))
 			pn = pn->next;
 		if (pn)
 			break;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 2627fff2b2d0..a2b9a8ad0f76 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -565,6 +565,10 @@ int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 	int err;
 	long timeo;
 
+	/* sockets must be set into a vrf context to connect */
+	if (vrf_is_any(sk->sk_vrf))
+		return -EINVAL;
+
 	if (addr_len < sizeof(uaddr->sa_family))
 		return -EINVAL;
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ed1453b9eeab..4f52a5bce975 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1195,6 +1195,9 @@ int arp_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg)
 	case SIOCSARP:
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
+		/* must set vrf context to modify arp cache */
+		if (vrf_is_any(ctx->vrf))
+			return -EINVAL;
 	case SIOCGARP:
 		err = copy_from_user(&r, arg, sizeof(struct arpreq));
 		if (err)
@@ -1215,6 +1218,9 @@ int arp_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg)
 							   htonl(0xFFFFFFFFUL);
 	rtnl_lock();
 	if (r.arp_dev[0]) {
+		err = -EINVAL;
+		if (vrf_is_any(ctx->vrf))
+			goto out;
 		err = -ENODEV;
 		dev = __dev_get_by_name_ctx(ctx, r.arp_dev);
 		if (dev == NULL)
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 7f93d6b92d0b..40b3602bfc78 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -30,6 +30,9 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	int oif;
 	int err;
 
+	/* connected sockets must have a specific vrf context */
+	if (vrf_is_any(sk->sk_vrf))
+		return -EINVAL;
 
 	if (addr_len < sizeof(*usin))
 		return -EINVAL;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 54afa816ff66..d9e7140df915 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -942,6 +942,9 @@ int devinet_ioctl(struct net_ctx *net_ctx, unsigned int cmd, void __user *arg)
 		ret = -EINVAL;
 		if (sin->sin_family != AF_INET)
 			goto out;
+		/* cannot use vrf any for set */
+		if (vrf_is_any(net_ctx->vrf))
+			goto out;
 		break;
 	default:
 		ret = -EINVAL;
@@ -1566,7 +1569,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 				goto cont;
 			if (h > s_h || idx > s_idx)
 				s_ip_idx = 0;
-			if (!vrf_eq(dev_vrf(dev), vrf))
+			if (!vrf_eq_or_any(dev_vrf(dev), vrf))
 				goto cont;
 			in_dev = __in_dev_get_rcu(dev);
 			if (!in_dev)
@@ -1890,7 +1893,7 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
-			if (!vrf_eq(dev_vrf(dev), vrf))
+			if (!vrf_eq_or_any(dev_vrf(dev), vrf))
 				goto cont;
 			in_dev = __in_dev_get_rcu(dev);
 			if (!in_dev)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8713618e2835..b024afcbf0b9 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -495,6 +495,10 @@ int ip_rt_ioctl(struct net_ctx *ctx, unsigned int cmd, void __user *arg)
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			return -EPERM;
 
+		/* route table can only be manipulated in a vrf context */
+		if (vrf_is_any(ctx->vrf))
+			return -EINVAL;
+
 		if (copy_from_user(&rt, arg, sizeof(rt)))
 			return -EFAULT;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index fddc3bbf6b8b..ba66840688c2 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2451,7 +2451,7 @@ static inline struct ip_mc_list *igmp_mc_get_first(struct seq_file *seq)
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *in_dev;
 
-		if (!vrf_eq(dev_vrf(state->dev), ctx->vrf))
+		if (!vrf_eq_or_any(dev_vrf(state->dev), ctx->vrf))
 			continue;
 
 		in_dev = __in_dev_get_rcu(state->dev);
@@ -2600,7 +2600,7 @@ static inline struct ip_sf_list *igmp_mcf_get_first(struct seq_file *seq)
 	for_each_netdev_rcu(net, state->dev) {
 		struct in_device *idev;
 
-		if (!vrf_eq(dev_vrf(state->dev), ctx->vrf))
+		if (!vrf_eq_or_any(dev_vrf(state->dev), ctx->vrf))
 			continue;
 
 		idev = __in_dev_get_rcu(state->dev);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f3a349ea3dd8..6d4be3fd2d01 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -591,6 +591,11 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else if (!ipc.oif)
 		ipc.oif = inet->uc_index;
 
+	/* out vrf cannot be set to VRF_ANY */
+	err = -EINVAL;
+	if (vrf_is_any(sk_ctx.vrf))
+		goto done;
+
 	flowi4_init_output(&fl4, sk_ctx.vrf, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
@@ -690,6 +695,10 @@ static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	int chk_addr_ret;
 	struct net_ctx sk_ctx = SOCK_NET_CTX(sk);
 
+	/* any vrf socket cannot bind to an address or device */
+	if (vrf_is_any(sk->sk_vrf))
+		goto out;
+
 	if (sk->sk_state != TCP_CLOSE || addr_len < sizeof(struct sockaddr_in))
 		goto out;
 	chk_addr_ret = inet_addr_type(&sk_ctx, addr->sin_addr.s_addr);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1446c84428d8..2d7e2748a138 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -904,6 +904,10 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (len > 0xFFFF)
 		return -EMSGSIZE;
 
+	/* out vrf cannot be set to VRF_ANY */
+	if (vrf_is_any(sk_ctx.vrf))
+		return -EINVAL;
+
 	/*
 	 *	Check the flags.
 	 */
-- 
1.9.3 (Apple Git-50)
