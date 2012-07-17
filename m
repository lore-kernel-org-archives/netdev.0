From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5 v2] ipv4: Add FIB nexthop exceptions.
Date: Tue, 17 Jul 2012 08:58:03 -0700 (PDT)
Message-ID: <20120717.085803.1895534004244751687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755636Ab2GQP6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 11:58:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In a regime where we have subnetted route entries, we need a way to
store persistent storage about destination specific learned values
such as redirects and PMTU values.

This is implemented here via nexthop exceptions.

The initial implementation is a 2048 entry hash table with relaiming
starting at chain length 5.  A more sophisticated scheme can be
devised if that proves necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Eric, just for you :-)

 include/net/ip_fib.h     |   18 ++++
 net/ipv4/fib_semantics.c |   23 +++++
 net/ipv4/route.c         |  256 ++++++++++++++++++++++++++++++++++++++++------
 3 files changed, 266 insertions(+), 31 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 5697ace..e9ee1ca 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -18,6 +18,7 @@
 
 #include <net/flow.h>
 #include <linux/seq_file.h>
+#include <linux/rcupdate.h>
 #include <net/fib_rules.h>
 #include <net/inetpeer.h>
 
@@ -46,6 +47,22 @@ struct fib_config {
 
 struct fib_info;
 
+struct fib_nh_exception {
+	struct fib_nh_exception __rcu	*fnhe_next;
+	__be32				fnhe_daddr;
+	u32				fnhe_pmtu;
+	u32				fnhe_gw;
+	unsigned long			fnhe_expires;
+	unsigned long			fnhe_stamp;
+};
+
+struct fnhe_hash_bucket {
+	struct fib_nh_exception __rcu	*chain;
+};
+
+#define FNHE_HASH_SIZE		2048
+#define FNHE_RECLAIM_DEPTH	5
+
 struct fib_nh {
 	struct net_device	*nh_dev;
 	struct hlist_node	nh_hash;
@@ -63,6 +80,7 @@ struct fib_nh {
 	__be32			nh_gw;
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
+	struct fnhe_hash_bucket	*nh_exceptions;
 };
 
 /*
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d71bfbd..1e09852 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -140,6 +140,27 @@ const struct fib_prop fib_props[RTN_MAX + 1] = {
 	},
 };
 
+static void free_nh_exceptions(struct fib_nh *nh)
+{
+	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
+	int i;
+
+	for (i = 0; i < FNHE_HASH_SIZE; i++) {
+		struct fib_nh_exception *fnhe;
+
+		fnhe = rcu_dereference(hash[i].chain);
+		while (fnhe) {
+			struct fib_nh_exception *next;
+			
+			next = rcu_dereference(fnhe->fnhe_next);
+			kfree(fnhe);
+
+			fnhe = next;
+		}
+	}
+	kfree(hash);
+}
+
 /* Release a nexthop info record */
 static void free_fib_info_rcu(struct rcu_head *head)
 {
@@ -148,6 +169,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
+		if (nexthop_nh->nh_exceptions)
+			free_nh_exceptions(nexthop_nh);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b35d3bf..a5bd0b4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1275,14 +1275,130 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
+static void __build_flow_key(struct flowi4 *fl4, struct sock *sk,
+			     const struct iphdr *iph,
+			     int oif, u8 tos,
+			     u8 prot, u32 mark, int flow_flags)
+{
+	if (sk) {
+		const struct inet_sock *inet = inet_sk(sk);
+
+		oif = sk->sk_bound_dev_if;
+		mark = sk->sk_mark;
+		tos = RT_CONN_FLAGS(sk);
+		prot = inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol;
+	}
+	flowi4_init_output(fl4, oif, mark, tos,
+			   RT_SCOPE_UNIVERSE, prot,
+			   flow_flags,
+			   iph->daddr, iph->saddr, 0, 0);
+}
+
+static void build_skb_flow_key(struct flowi4 *fl4, struct sk_buff *skb, struct sock *sk)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	int oif = skb->dev->ifindex;
+	u8 tos = RT_TOS(iph->tos);
+	u8 prot = iph->protocol;
+	u32 mark = skb->mark;
+
+	__build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
+}
+
+static void build_sk_flow_key(struct flowi4 *fl4, struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+	struct ip_options_rcu *inet_opt;
+	__be32 daddr = inet->inet_daddr;
+
+	rcu_read_lock();
+	inet_opt = rcu_dereference(inet->inet_opt);
+	if (inet_opt && inet_opt->opt.srr)
+		daddr = inet_opt->opt.faddr;
+	flowi4_init_output(fl4, sk->sk_bound_dev_if, sk->sk_mark,
+			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
+			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
+			   inet_sk_flowi_flags(sk),
+			   daddr, inet->inet_saddr, 0, 0);
+	rcu_read_unlock();
+}
+
+static void ip_rt_build_flow_key(struct flowi4 *fl4, struct sock *sk,
+				 struct sk_buff *skb)
+{
+	if (skb)
+		build_skb_flow_key(fl4, skb, sk);
+	else
+		build_sk_flow_key(fl4, sk);
+}
+
+static DEFINE_SPINLOCK(fnhe_lock);
+
+static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash, __be32 daddr)
+{
+	struct fib_nh_exception *fnhe, *oldest;
+
+	oldest = rcu_dereference(hash->chain);
+	for (fnhe = rcu_dereference(oldest->fnhe_next); fnhe;
+	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
+		if (time_before(fnhe->fnhe_stamp, oldest->fnhe_stamp))
+			oldest = fnhe;
+	}
+	return oldest;
+}
+
+static struct fib_nh_exception *find_or_create_fnhe(struct fib_nh *nh, __be32 daddr)
+{
+	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
+	struct fib_nh_exception *fnhe;
+	int depth;
+	u32 hval;
+
+	if (!hash) {
+		hash = nh->nh_exceptions = kzalloc(FNHE_HASH_SIZE * sizeof(*hash),
+						   GFP_ATOMIC);
+		if (!hash)
+			return NULL;
+	}
+
+	hval = (__force u32) daddr;
+	hval ^= (hval >> 11) ^ (hval >> 22);
+	hash += hval;
+
+	depth = 0;
+	for (fnhe = rcu_dereference(hash->chain); fnhe;
+	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
+		if (fnhe->fnhe_daddr == daddr)
+			goto out;
+		depth++;
+	}
+
+	if (depth > FNHE_RECLAIM_DEPTH) {
+		fnhe = fnhe_oldest(hash + hval, daddr);
+		goto out_daddr;
+	}
+	fnhe = kzalloc(sizeof(*fnhe), GFP_ATOMIC);
+	if (!fnhe)
+		return NULL;
+
+	fnhe->fnhe_next = hash->chain;
+	rcu_assign_pointer(hash->chain, fnhe);
+
+out_daddr:
+	fnhe->fnhe_daddr = daddr;
+out:
+	fnhe->fnhe_stamp = jiffies;
+	return fnhe;
+}
+
+static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4)
 {
 	__be32 new_gw = icmp_hdr(skb)->un.gateway;
 	__be32 old_gw = ip_hdr(skb)->saddr;
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev;
+	struct fib_result res;
 	struct neighbour *n;
-	struct rtable *rt;
 	struct net *net;
 
 	switch (icmp_hdr(skb)->code & 7) {
@@ -1296,7 +1412,6 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 		return;
 	}
 
-	rt = (struct rtable *) dst;
 	if (rt->rt_gateway != old_gw)
 		return;
 
@@ -1320,11 +1435,21 @@ static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buf
 			goto reject_redirect;
 	}
 
-	n = ipv4_neigh_lookup(dst, NULL, &new_gw);
+	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
 	if (n) {
 		if (!(n->nud_state & NUD_VALID)) {
 			neigh_event_send(n, NULL);
 		} else {
+			if (fib_lookup(net, fl4, &res) == 0) {
+				struct fib_nh *nh = &FIB_RES_NH(res);
+				struct fib_nh_exception *fnhe;
+
+				spin_lock_bh(&fnhe_lock);
+				fnhe = find_or_create_fnhe(nh, fl4->daddr);
+				if (fnhe)
+					fnhe->fnhe_gw = new_gw;
+				spin_unlock_bh(&fnhe_lock);
+			}
 			rt->rt_gateway = new_gw;
 			rt->rt_flags |= RTCF_REDIRECTED;
 			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
@@ -1349,6 +1474,17 @@ reject_redirect:
 	;
 }
 
+static void ip_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_buff *skb)
+{
+	struct rtable *rt;
+	struct flowi4 fl4;
+
+	rt = (struct rtable *) dst;
+
+	ip_rt_build_flow_key(&fl4, sk, skb);
+	__ip_do_redirect(rt, skb, &fl4);
+}
+
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *)dst;
@@ -1508,33 +1644,51 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
-			      struct sk_buff *skb, u32 mtu)
+static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 {
-	struct rtable *rt = (struct rtable *) dst;
-
-	dst_confirm(dst);
+	struct fib_result res;
 
 	if (mtu < ip_rt_min_pmtu)
 		mtu = ip_rt_min_pmtu;
 
+	if (fib_lookup(dev_net(rt->dst.dev), fl4, &res) == 0) {
+		struct fib_nh *nh = &FIB_RES_NH(res);
+		struct fib_nh_exception *fnhe;
+
+		spin_lock_bh(&fnhe_lock);
+		fnhe = find_or_create_fnhe(nh, fl4->daddr);
+		if (fnhe) {
+			fnhe->fnhe_pmtu = mtu;
+			fnhe->fnhe_expires = jiffies + ip_rt_mtu_expires;
+		}
+		spin_unlock_bh(&fnhe_lock);
+	}
 	rt->rt_pmtu = mtu;
 	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
 }
 
+static void ip_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			      struct sk_buff *skb, u32 mtu)
+{
+	struct rtable *rt = (struct rtable *) dst;
+	struct flowi4 fl4;
+
+	ip_rt_build_flow_key(&fl4, sk, skb);
+	__ip_rt_update_pmtu(rt, &fl4, mtu);
+}
+
 void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 		      int oif, u32 mark, u8 protocol, int flow_flags)
 {
-	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
 
-	flowi4_init_output(&fl4, oif, mark, RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
-			   protocol, flow_flags,
-			   iph->daddr, iph->saddr, 0, 0);
+	__build_flow_key(&fl4, NULL, iph, oif,
+			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
-		ip_rt_update_pmtu(&rt->dst, NULL, skb, mtu);
+		__ip_rt_update_pmtu(rt, &fl4, mtu);
 		ip_rt_put(rt);
 	}
 }
@@ -1542,27 +1696,31 @@ EXPORT_SYMBOL_GPL(ipv4_update_pmtu);
 
 void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 {
-	const struct inet_sock *inet = inet_sk(sk);
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	struct flowi4 fl4;
+	struct rtable *rt;
 
-	return ipv4_update_pmtu(skb, sock_net(sk), mtu,
-				sk->sk_bound_dev_if, sk->sk_mark,
-				inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-				inet_sk_flowi_flags(sk));
+	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	rt = __ip_route_output_key(sock_net(sk), &fl4);
+	if (!IS_ERR(rt)) {
+		__ip_rt_update_pmtu(rt, &fl4, mtu);
+		ip_rt_put(rt);
+	}
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
 void ipv4_redirect(struct sk_buff *skb, struct net *net,
 		   int oif, u32 mark, u8 protocol, int flow_flags)
 {
-	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
 	struct flowi4 fl4;
 	struct rtable *rt;
 
-	flowi4_init_output(&fl4, oif, mark, RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
-			   protocol, flow_flags, iph->daddr, iph->saddr, 0, 0);
+	__build_flow_key(&fl4, NULL, iph, oif,
+			 RT_TOS(iph->tos), protocol, mark, flow_flags);
 	rt = __ip_route_output_key(net, &fl4);
 	if (!IS_ERR(rt)) {
-		ip_do_redirect(&rt->dst, NULL, skb);
+		__ip_do_redirect(rt, skb, &fl4);
 		ip_rt_put(rt);
 	}
 }
@@ -1570,12 +1728,16 @@ EXPORT_SYMBOL_GPL(ipv4_redirect);
 
 void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 {
-	const struct inet_sock *inet = inet_sk(sk);
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	struct flowi4 fl4;
+	struct rtable *rt;
 
-	return ipv4_redirect(skb, sock_net(sk), sk->sk_bound_dev_if,
-			     sk->sk_mark,
-			     inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-			     inet_sk_flowi_flags(sk));
+	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
+	rt = __ip_route_output_key(sock_net(sk), &fl4);
+	if (!IS_ERR(rt)) {
+		__ip_do_redirect(rt, skb, &fl4);
+		ip_rt_put(rt);
+	}
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_redirect);
 
@@ -1722,14 +1884,46 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 	dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 }
 
+static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr)
+{
+	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
+	struct fib_nh_exception *fnhe;
+	u32 hval;
+
+	hval = (__force u32) daddr;
+	hval ^= (hval >> 11) ^ (hval >> 22);
+
+	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
+	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
+		if (fnhe->fnhe_daddr == daddr) {
+			if (fnhe->fnhe_pmtu) {
+				unsigned long expires = fnhe->fnhe_expires;
+				unsigned long diff = jiffies - expires;
+
+				if (time_before(jiffies, expires)) {
+					rt->rt_pmtu = fnhe->fnhe_pmtu;
+					dst_set_expires(&rt->dst, diff);
+				}
+			}
+			if (fnhe->fnhe_gw)
+				rt->rt_gateway = fnhe->fnhe_gw;
+			fnhe->fnhe_stamp = jiffies;
+			break;
+		}
+	}
+}
+
 static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
 	if (fi) {
-		if (FIB_RES_GW(*res) &&
-		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
-			rt->rt_gateway = FIB_RES_GW(*res);
+		struct fib_nh *nh = &FIB_RES_NH(*res);
+
+		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK)
+			rt->rt_gateway = nh->nh_gw;
+		if (unlikely(nh->nh_exceptions))
+			rt_bind_exception(rt, nh, fl4->daddr);
 		rt_init_metrics(rt, fl4, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
-- 
1.7.10.4
