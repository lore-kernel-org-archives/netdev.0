From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 5/5] [NET] NETNS: Omit namespace comparision without
 CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 08:44:42 +0900 (JST)
Message-ID: <20080326.084442.89010823.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55068 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757439AbYCYXnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:43:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce an inline net_eq() to compare two namespaces.
Without CONFIG_NET_NS, since no namespace other than &init_net
exists, it is always 1.

We do not need to convert 1) inline vs inline and
2) inline vs &init_net comparisons.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/net_namespace.h |   12 ++++++++++++
 net/core/dev.c              |    2 +-
 net/core/neighbour.c        |   18 +++++++++---------
 net/ipv4/inet_hashtables.c  |    4 ++--
 net/ipv4/raw.c              |    2 +-
 net/ipv4/route.c            |   10 +++++-----
 net/ipv4/tcp_ipv4.c         |   12 ++++++------
 net/ipv4/udp.c              |   10 +++++-----
 net/ipv6/addrconf.c         |   12 ++++++------
 net/ipv6/inet6_hashtables.c |    2 +-
 net/ipv6/raw.c              |    2 +-
 net/ipv6/udp.c              |    2 +-
 net/netlink/af_netlink.c    |    8 ++++----
 net/unix/af_unix.c          |    4 ++--
 14 files changed, 56 insertions(+), 44 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 923f2b8..f8f3d1a 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -118,6 +118,12 @@ static inline void release_net(struct net *net)
 {
 	atomic_dec(&net->use_count);
 }
+
+static inline
+int net_eq(const struct net *net1, const struct net *net2)
+{
+	return net1 == net2;
+}
 #else
 static inline struct net *get_net(struct net *net)
 {
@@ -141,6 +147,12 @@ static inline struct net *maybe_get_net(struct net *net)
 {
 	return net;
 }
+
+static inline
+int net_eq(const struct net *net1, const struct net *net2)
+{
+	return 1;
+}
 #endif
 
 #define for_each_net(VAR)				\
diff --git a/net/core/dev.c b/net/core/dev.c
index 8125348..75c3f7f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4136,7 +4136,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 
 	/* Get out if there is nothing todo */
 	err = 0;
-	if (dev_net(dev) == net)
+	if (net_eq(dev_net(dev), net))
 		goto out;
 
 	/* Pick the destination device name, and ensure
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index de654ea..857915a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -388,7 +388,7 @@ struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
 	hash_val = tbl->hash(pkey, NULL);
 	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
 		if (!memcmp(n->primary_key, pkey, key_len) &&
-		    dev_net(n->dev) == net) {
+		    net_eq(dev_net(n->dev), net)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
@@ -483,7 +483,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 
 	for (n = tbl->phash_buckets[hash_val]; n; n = n->next) {
 		if (!memcmp(n->key, pkey, key_len) &&
-		    (pneigh_net(n) == net) &&
+		    net_eq(pneigh_net(n), net) &&
 		    (n->dev == dev || !n->dev)) {
 			read_unlock_bh(&tbl->lock);
 			goto out;
@@ -542,7 +542,7 @@ int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *pkey,
 	for (np = &tbl->phash_buckets[hash_val]; (n = *np) != NULL;
 	     np = &n->next) {
 		if (!memcmp(n->key, pkey, key_len) && n->dev == dev &&
-		    (pneigh_net(n) == net)) {
+		    net_eq(pneigh_net(n), net)) {
 			*np = n->next;
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
@@ -1286,7 +1286,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
 	struct neigh_parms *p;
 
 	for (p = &tbl->parms; p; p = p->next) {
-		if ((p->dev && p->dev->ifindex == ifindex && neigh_parms_net(p) == net) ||
+		if ((p->dev && p->dev->ifindex == ifindex && net_eq(neigh_parms_net(p), net)) ||
 		    (!p->dev && !ifindex))
 			return p;
 	}
@@ -1964,7 +1964,7 @@ static int neightbl_dump_info(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 
 		for (nidx = 0, p = tbl->parms.next; p; p = p->next) {
-			if (net != neigh_parms_net(p))
+			if (!net_eq(neigh_parms_net(p), net))
 				continue;
 
 			if (nidx++ < neigh_skip)
@@ -2161,7 +2161,7 @@ static struct neighbour *neigh_get_first(struct seq_file *seq)
 		n = tbl->hash_buckets[bucket];
 
 		while (n) {
-			if (dev_net(n->dev) != net)
+			if (!net_eq(dev_net(n->dev), net))
 				goto next;
 			if (state->neigh_sub_iter) {
 				loff_t fakep = 0;
@@ -2204,7 +2204,7 @@ static struct neighbour *neigh_get_next(struct seq_file *seq,
 
 	while (1) {
 		while (n) {
-			if (dev_net(n->dev) != net)
+			if (!net_eq(dev_net(n->dev), net))
 				goto next;
 			if (state->neigh_sub_iter) {
 				void *v = state->neigh_sub_iter(state, n, pos);
@@ -2260,7 +2260,7 @@ static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
 	state->flags |= NEIGH_SEQ_IS_PNEIGH;
 	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
 		pn = tbl->phash_buckets[bucket];
-		while (pn && (pneigh_net(pn) != net))
+		while (pn && !net_eq(pneigh_net(pn), net))
 			pn = pn->next;
 		if (pn)
 			break;
@@ -2283,7 +2283,7 @@ static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
 		if (++state->bucket > PNEIGH_HASHMASK)
 			break;
 		pn = tbl->phash_buckets[state->bucket];
-		while (pn && (pneigh_net(pn) != net))
+		while (pn && !net_eq(pneigh_net(pn), net))
 			pn = pn->next;
 		if (pn)
 			break;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 1064111..1b6ff51 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -139,7 +139,7 @@ static struct sock *inet_lookup_listener_slow(struct net *net,
 	sk_for_each(sk, node, head) {
 		const struct inet_sock *inet = inet_sk(sk);
 
-		if (sock_net(sk) == net && inet->num == hnum &&
+		if (net_eq(sock_net(sk), net) && inet->num == hnum &&
 				!ipv6_only_sock(sk)) {
 			const __be32 rcv_saddr = inet->rcv_saddr;
 			int score = sk->sk_family == PF_INET ? 1 : 0;
@@ -182,7 +182,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 		if (inet->num == hnum && !sk->sk_node.next &&
 		    (!inet->rcv_saddr || inet->rcv_saddr == daddr) &&
 		    (sk->sk_family == PF_INET || !ipv6_only_sock(sk)) &&
-		    !sk->sk_bound_dev_if && sock_net(sk) == net)
+		    !sk->sk_bound_dev_if && net_eq(sock_net(sk), net))
 			goto sherry_cache;
 		sk = inet_lookup_listener_slow(net, head, daddr, hnum, dif);
 	}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 25dc8b3..d965f0a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -117,7 +117,7 @@ static struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 	sk_for_each_from(sk, node) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sock_net(sk) == net && inet->num == num 		&&
+		if (net_eq(sock_net(sk), net) && inet->num == num	&&
 		    !(inet->daddr && inet->daddr != raddr) 		&&
 		    !(inet->rcv_saddr && inet->rcv_saddr != laddr)	&&
 		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eab8d75..230716c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1196,7 +1196,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rth->fl.oif != ikeys[k] ||
 				    rth->fl.iif != 0 ||
 				    rth->rt_genid != atomic_read(&rt_genid) ||
-				    dev_net(rth->u.dst.dev) != net) {
+				    !net_eq(dev_net(rth->u.dst.dev), net)) {
 					rthp = &rth->u.dst.rt_next;
 					continue;
 				}
@@ -1455,7 +1455,7 @@ unsigned short ip_rt_frag_needed(struct net *net, struct iphdr *iph,
 			    rth->rt_src  == iph->saddr &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU)) &&
-			    dev_net(rth->u.dst.dev) == net &&
+			    net_eq(dev_net(rth->u.dst.dev), net) &&
 			    rth->rt_genid == atomic_read(&rt_genid)) {
 				unsigned short mtu = new_mtu;
 
@@ -2085,7 +2085,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->fl.oif == 0 &&
 		    rth->fl.mark == skb->mark &&
 		    rth->fl.fl4_tos == tos &&
-		    dev_net(rth->u.dst.dev) == net &&
+		    net_eq(dev_net(rth->u.dst.dev), net) &&
 		    rth->rt_genid == atomic_read(&rt_genid)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(in_hit);
@@ -2487,7 +2487,7 @@ int __ip_route_output_key(struct net *net, struct rtable **rp,
 		    rth->fl.mark == flp->mark &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
-		    dev_net(rth->u.dst.dev) == net &&
+		    net_eq(dev_net(rth->u.dst.dev), net) &&
 		    rth->rt_genid == atomic_read(&rt_genid)) {
 			dst_use(&rth->u.dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
@@ -2796,7 +2796,7 @@ int ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb)
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.dst.rt_next), idx++) {
-			if (dev_net(rt->u.dst.dev) != net || idx < s_idx)
+			if (!net_eq(dev_net(rt->u.dst.dev), net) || idx < s_idx)
 				continue;
 			if (rt->rt_genid != atomic_read(&rt_genid))
 				continue;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 46847e6..2a5881c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1974,7 +1974,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 		while (1) {
 			while (req) {
 				if (req->rsk_ops->family == st->family &&
-				    sock_net(req->sk) == net) {
+				    net_eq(sock_net(req->sk), net)) {
 					cur = req;
 					goto out;
 				}
@@ -1998,7 +1998,7 @@ get_req:
 	}
 get_sk:
 	sk_for_each_from(sk, node) {
-		if (sk->sk_family == st->family && sock_net(sk) == net) {
+		if (sk->sk_family == st->family && net_eq(sock_net(sk), net)) {
 			cur = sk;
 			goto out;
 		}
@@ -2049,7 +2049,7 @@ static void *established_get_first(struct seq_file *seq)
 		read_lock_bh(lock);
 		sk_for_each(sk, node, &tcp_hashinfo.ehash[st->bucket].chain) {
 			if (sk->sk_family != st->family ||
-			    sock_net(sk) != net) {
+			    !net_eq(sock_net(sk), net)) {
 				continue;
 			}
 			rc = sk;
@@ -2059,7 +2059,7 @@ static void *established_get_first(struct seq_file *seq)
 		inet_twsk_for_each(tw, node,
 				   &tcp_hashinfo.ehash[st->bucket].twchain) {
 			if (tw->tw_family != st->family ||
-			    twsk_net(tw) != net) {
+			    !net_eq(twsk_net(tw), net)) {
 				continue;
 			}
 			rc = tw;
@@ -2086,7 +2086,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 		tw = cur;
 		tw = tw_next(tw);
 get_tw:
-		while (tw && (tw->tw_family != st->family || twsk_net(tw) != net)) {
+		while (tw && (tw->tw_family != st->family || !net_eq(twsk_net(tw), net))) {
 			tw = tw_next(tw);
 		}
 		if (tw) {
@@ -2107,7 +2107,7 @@ get_tw:
 		sk = sk_next(sk);
 
 	sk_for_each_from(sk, node) {
-		if (sk->sk_family == st->family && sock_net(sk) == net)
+		if (sk->sk_family == st->family && net_eq(sock_net(sk), net))
 			goto found;
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 76d52d3..80007c7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -137,7 +137,7 @@ static inline int __udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct hlist_node *node;
 
 	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
-		if (sock_net(sk) == net && sk->sk_hash == num)
+		if (net_eq(sock_net(sk), net) && sk->sk_hash == num)
 			return 1;
 	return 0;
 }
@@ -218,7 +218,7 @@ gotit:
 		sk_for_each(sk2, node, head)
 			if (sk2->sk_hash == snum                             &&
 			    sk2 != sk                                        &&
-			    sock_net(sk2) == net				     &&
+			    net_eq(sock_net(sk2), net)			     &&
 			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
 			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
 			     || sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
@@ -269,7 +269,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sock_net(sk) == net && sk->sk_hash == hnum &&
+		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
 				!ipv6_only_sock(sk)) {
 			int score = (sk->sk_family == PF_INET ? 1 : 0);
 			if (inet->rcv_saddr) {
@@ -1511,7 +1511,7 @@ static struct sock *udp_get_first(struct seq_file *seq)
 	for (state->bucket = 0; state->bucket < UDP_HTABLE_SIZE; ++state->bucket) {
 		struct hlist_node *node;
 		sk_for_each(sk, node, state->hashtable + state->bucket) {
-			if (sock_net(sk) != net)
+			if (!net_eq(sock_net(sk), net))
 				continue;
 			if (sk->sk_family == state->family)
 				goto found;
@@ -1531,7 +1531,7 @@ static struct sock *udp_get_next(struct seq_file *seq, struct sock *sk)
 		sk = sk_next(sk);
 try_again:
 		;
-	} while (sk && (sock_net(sk) != net || sk->sk_family != state->family));
+	} while (sk && (!net_eq(sock_net(sk), net) || sk->sk_family != state->family));
 
 	if (!sk && ++state->bucket < UDP_HTABLE_SIZE) {
 		sk = sk_head(state->hashtable + state->bucket);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ac5d4f4..5ab9973 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1217,7 +1217,7 @@ int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (dev_net(ifp->idev->dev) != net)
+		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
 		    !(ifp->flags&IFA_F_TENTATIVE)) {
@@ -1239,7 +1239,7 @@ int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	u8 hash = ipv6_addr_hash(addr);
 
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (dev_net(ifp->idev->dev) != net)
+		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev)
@@ -1257,7 +1257,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
-		if (dev_net(ifp->idev->dev) != net)
+		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
@@ -2771,7 +2771,7 @@ static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
 	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
 		ifa = inet6_addr_lst[state->bucket];
 
-		while (ifa && dev_net(ifa->idev->dev) != net)
+		while (ifa && !net_eq(dev_net(ifa->idev->dev), net))
 			ifa = ifa->lst_next;
 		if (ifa)
 			break;
@@ -2787,7 +2787,7 @@ static struct inet6_ifaddr *if6_get_next(struct seq_file *seq, struct inet6_ifad
 	ifa = ifa->lst_next;
 try_again:
 	if (ifa) {
-		if (dev_net(ifa->idev->dev) != net) {
+		if (!net_eq(dev_net(ifa->idev->dev), net)) {
 			ifa = ifa->lst_next;
 			goto try_again;
 		}
@@ -2905,7 +2905,7 @@ int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 	u8 hash = ipv6_addr_hash(addr);
 	read_lock_bh(&addrconf_hash_lock);
 	for (ifp = inet6_addr_lst[hash]; ifp; ifp = ifp->lst_next) {
-		if (dev_net(ifp->idev->dev) != net)
+		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_cmp(&ifp->addr, addr) == 0 &&
 		    (ifp->flags & IFA_F_HOMEADDRESS)) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 21c4676..340c7d4 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -105,7 +105,7 @@ struct sock *inet6_lookup_listener(struct net *net,
 
 	read_lock(&hashinfo->lhash_lock);
 	sk_for_each(sk, node, &hashinfo->listening_hash[inet_lhashfn(hnum)]) {
-		if (sock_net(sk) == net && inet_sk(sk)->num == hnum &&
+		if (net_eq(sock_net(sk), net) && inet_sk(sk)->num == hnum &&
 				sk->sk_family == PF_INET6) {
 			const struct ipv6_pinfo *np = inet6_sk(sk);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 12c7a15..830da46 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -76,7 +76,7 @@ static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 		if (inet_sk(sk)->num == num) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 
-			if (sock_net(sk) != net)
+			if (!net_eq(sock_net(sk), net))
 				continue;
 
 			if (!ipv6_addr_any(&np->daddr) &&
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index db266ff..aacbc82 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -70,7 +70,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (sock_net(sk) == net && sk->sk_hash == hnum &&
+		if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
 				sk->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			int score = 0;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1d16d95..36f75d8 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -228,7 +228,7 @@ static inline struct sock *netlink_lookup(struct net *net, int protocol,
 	read_lock(&nl_table_lock);
 	head = nl_pid_hashfn(hash, pid);
 	sk_for_each(sk, node, head) {
-		if (sock_net(sk) == net && (nlk_sk(sk)->pid == pid)) {
+		if (net_eq(sock_net(sk), net) && (nlk_sk(sk)->pid == pid)) {
 			sock_hold(sk);
 			goto found;
 		}
@@ -348,7 +348,7 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 pid)
 	head = nl_pid_hashfn(hash, pid);
 	len = 0;
 	sk_for_each(osk, node, head) {
-		if (sock_net(osk) == net && (nlk_sk(osk)->pid == pid))
+		if (net_eq(sock_net(osk), net) && (nlk_sk(osk)->pid == pid))
 			break;
 		len++;
 	}
@@ -532,7 +532,7 @@ retry:
 	netlink_table_grab();
 	head = nl_pid_hashfn(hash, pid);
 	sk_for_each(osk, node, head) {
-		if (sock_net(osk) != net)
+		if (!net_eq(sock_net(osk), net))
 			continue;
 		if (nlk_sk(osk)->pid == pid) {
 			/* Bind collision, search negative pid values. */
@@ -962,7 +962,7 @@ static inline int do_one_broadcast(struct sock *sk,
 	    !test_bit(p->group - 1, nlk->groups))
 		goto out;
 
-	if (sock_net(sk) != p->net)
+	if (!net_eq(sock_net(sk), p->net))
 		goto out;
 
 	if (p->failure) {
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4a47930..50bbf6b 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -252,7 +252,7 @@ static struct sock *__unix_find_socket_byname(struct net *net,
 	sk_for_each(s, node, &unix_socket_table[hash ^ type]) {
 		struct unix_sock *u = unix_sk(s);
 
-		if (sock_net(s) != net)
+		if (!net_eq(sock_net(s), net))
 			continue;
 
 		if (u->addr->len == len &&
@@ -289,7 +289,7 @@ static struct sock *unix_find_socket_byinode(struct net *net, struct inode *i)
 		    &unix_socket_table[i->i_ino & (UNIX_HASH_SIZE - 1)]) {
 		struct dentry *dentry = unix_sk(s)->dentry;
 
-		if (sock_net(s) != net)
+		if (!net_eq(sock_net(s), net))
 			continue;
 
 		if(dentry && dentry->d_inode == i)
-- 
1.4.4.4

