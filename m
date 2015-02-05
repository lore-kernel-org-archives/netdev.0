From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 21/29] net: vrf: Add vrf context to genid's
Date: Wed,  4 Feb 2015 18:34:22 -0700
Message-ID: <1423100070-31848-22-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:48053 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278AbbBEBgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:11 -0500
Received: by mail-ie0-f180.google.com with SMTP id rl12so6706889iec.11
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:11 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bottom 12 bits (VRF_BITS) are the VRF id.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip_fib.h        |  2 +-
 include/net/net_namespace.h | 12 ++++++++----
 net/ipv4/devinet.c          | 12 ++++++++----
 net/ipv4/fib_frontend.c     |  8 +++++---
 net/ipv4/fib_semantics.c    |  2 +-
 net/ipv4/route.c            | 13 +++++++++++--
 6 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 577479d7f268..e6b823c0305e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -180,7 +180,7 @@ __be32 fib_info_update_nh_saddr(struct net_ctx *ctx, struct fib_nh *nh);
 
 #define FIB_RES_SADDR(ctx, res)				\
 	((FIB_RES_NH(res).nh_saddr_genid ==		\
-	  atomic_read(&(ctx)->net->ipv4.dev_addr_genid)) ? \
+	  (atomic_read(&(ctx)->net->ipv4.dev_addr_genid) + (ctx)->vrf)) ? \
 	 FIB_RES_NH(res).nh_saddr :			\
 	 fib_info_update_nh_saddr((ctx), &FIB_RES_NH(res)))
 #define FIB_RES_GW(res)			(FIB_RES_NH(res).nh_gw)
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 7cc7b0a1a20b..d0a3414758f8 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -372,12 +372,14 @@ static inline void unregister_net_sysctl_table(struct ctl_table_header *header)
 
 static inline int rt_genid_ipv4(struct net_ctx *ctx)
 {
-	return atomic_read(&ctx->net->ipv4.rt_genid);
+	return atomic_read(&ctx->net->ipv4.rt_genid) + ctx->vrf;
 }
 
 static inline void rt_genid_bump_ipv4(struct net *net)
 {
-	atomic_inc(&net->ipv4.rt_genid);
+	int inc = 1 << VRF_BITS;
+
+	atomic_add(inc, &net->ipv4.rt_genid);
 }
 
 extern void (*__fib6_flush_trees)(struct net *net);
@@ -404,12 +406,14 @@ static inline void rt_genid_bump_all(struct net *net)
 
 static inline int fnhe_genid(struct net_ctx *ctx)
 {
-	return atomic_read(&ctx->net->fnhe_genid);
+	return atomic_read(&ctx->net->fnhe_genid) + ctx->vrf;
 }
 
 static inline void fnhe_genid_bump(struct net *net)
 {
-	atomic_inc(&net->fnhe_genid);
+	int inc = 1 << VRF_BITS;
+
+	atomic_add(inc, &net->fnhe_genid);
 }
 
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 02ffbfb8bfee..7c0c3bc17599 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1536,6 +1536,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net_ctx sk_ctx = SOCK_NET_CTX(skb->sk);
 	struct net *net = sk_ctx.net;
+	__u32 vrf = sk_ctx.vrf;
 	int h, s_h;
 	int idx, s_idx;
 	int ip_idx, s_ip_idx;
@@ -1549,11 +1550,12 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	s_ip_idx = ip_idx = cb->args[2];
 
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		int genid;
 		idx = 0;
 		head = &net->dev_index_head[h];
 		rcu_read_lock();
-		cb->seq = atomic_read(&net->ipv4.dev_addr_genid) ^
-			  net->dev_base_seq;
+		genid = atomic_read(&net->ipv4.dev_addr_genid) + vrf;
+		cb->seq = genid ^ net->dev_base_seq;
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
@@ -1861,6 +1863,7 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 {
 	struct net_ctx sk_ctx = SOCK_NET_CTX(skb->sk);
 	struct net *net = sk_ctx.net;
+	__u32 vrf = sk_ctx.vrf;
 	int h, s_h;
 	int idx, s_idx;
 	struct net_device *dev;
@@ -1871,11 +1874,12 @@ static int inet_netconf_dump_devconf(struct sk_buff *skb,
 	s_idx = idx = cb->args[1];
 
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		int genid;
 		idx = 0;
 		head = &net->dev_index_head[h];
 		rcu_read_lock();
-		cb->seq = atomic_read(&net->ipv4.dev_addr_genid) ^
-			  net->dev_base_seq;
+		genid = atomic_read(&net->ipv4.dev_addr_genid) + vrf;
+		cb->seq = genid ^ net->dev_base_seq;
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index f2a8a557a3d8..cba1e2c9c2ec 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1021,6 +1021,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct net_device *dev = ifa->ifa_dev->dev;
 	struct net *net = dev_net(dev);
+	int inc = 1 << VRF_BITS;
 
 	switch (event) {
 	case NETDEV_UP:
@@ -1028,12 +1029,12 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		fib_sync_up(dev);
 #endif
-		atomic_inc(&net->ipv4.dev_addr_genid);
+		atomic_add(inc, &net->ipv4.dev_addr_genid);
 		rt_cache_flush(dev_net(dev));
 		break;
 	case NETDEV_DOWN:
 		fib_del_ifaddr(ifa, NULL);
-		atomic_inc(&net->ipv4.dev_addr_genid);
+		atomic_add(inc, &net->ipv4.dev_addr_genid);
 		if (ifa->ifa_dev->ifa_list == NULL) {
 			/* Last address was deleted from this interface.
 			 * Disable IP.
@@ -1052,6 +1053,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct in_device *in_dev;
 	struct net *net = dev_net(dev);
+	int inc = 1 << VRF_BITS;
 
 	if (event == NETDEV_UNREGISTER) {
 		fib_disable_ip(dev, 2);
@@ -1071,7 +1073,7 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		fib_sync_up(dev);
 #endif
-		atomic_inc(&net->ipv4.dev_addr_genid);
+		atomic_add(inc, &net->ipv4.dev_addr_genid);
 		rt_cache_flush(net);
 		break;
 	case NETDEV_DOWN:
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 9fc5487e66fe..a7d810cafada 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -756,7 +756,7 @@ __be32 fib_info_update_nh_saddr(struct net_ctx *net_ctx, struct fib_nh *nh)
 	nh->nh_saddr = inet_select_addr(nh->nh_dev,
 					nh->nh_gw,
 					nh->nh_parent->fib_scope);
-	nh->nh_saddr_genid = atomic_read(&net->ipv4.dev_addr_genid);
+	nh->nh_saddr_genid = atomic_read(&net->ipv4.dev_addr_genid) + net_ctx->vrf;
 
 	return nh->nh_saddr;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8271c5b30322..f980a42a995f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2706,10 +2706,19 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 
 static __net_init int rt_genid_init(struct net *net)
 {
+	int genid;
+
 	atomic_set(&net->ipv4.rt_genid, 0);
 	atomic_set(&net->fnhe_genid, 0);
-	get_random_bytes(&net->ipv4.dev_addr_genid,
-			 sizeof(net->ipv4.dev_addr_genid));
+
+again:
+	get_random_bytes(&genid, sizeof(genid));
+	genid &= ~VRF_MASK;
+	if (genid == 0)
+		goto again;
+
+	atomic_set(&net->ipv4.dev_addr_genid, genid);
+
 	return 0;
 }
 
-- 
1.9.3 (Apple Git-50)
