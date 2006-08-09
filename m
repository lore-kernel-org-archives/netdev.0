From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC] [GIT PATCH] IPv6 Routing / Ndisc Fixes
Date: Wed, 09 Aug 2006 19:56:27 +0900 (JST)
Message-ID: <20060809.195627.59155708.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:28687 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1030675AbWHIKyx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 06:54:53 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Here's a set of changesets (on top of net-2.6.19 tree) to fix routing / ndisc.
Changesets are available at:
	git://git.skbuff.net/gitroot/yoshfuji/net-2.6.19-20060809-polroute-fixes/

Thank you.

HEADLINES
---------

    [IPV6] NDISC: Take source address into account for redirects.
    [IPV6] NDISC: Search over all possible rules on receipt of redirect.
    [IPV6] NDISC: Allow redirects from other interfaces if it is not strict.
    [IPV6] NDISC: Initialize fl with outbound interface to lookup rules properly.
    [IPV6] ROUTE: Introduce a helper to check route validity.
    [IPV6]: Cache source address as well in ipv6_pinfo{}.
    [IPV6] ROUTE: Make sure we have fn->leaf when adding a node on subtree.
    [IPV6] ROUTE: Prune clones from main tree as well.
    [IPV6] ROUTE: Fix looking up a route on subtree.
    [IPV6] ROUTE: Make sure we do not exceed args in fib6_lookup_1().
    [IPV6] ROUTE: Allow searching subtree only.
    [IPV6] ROUTE: Put SUBTREE() as FIB6_SUBTREE() into ip6_fib.h for future use.
    [IPV6] ROUTE: Search subtree when backtracking.
    [IPV6] ROUTE: Purge clones on other trees when deleting a route.
    [IPV6] NDISC: Search subtrees when backtracking on receipt of redirects.
    [IPV6] ROUTE: Add credits about subtree fixes.
    [IPV6] KCONFIG: Add subtrees support.
    [IPV6] ROUTE: Unify RT6_F_xxx and RT6_SELECT_F_xxx flags

DIFFSTAT
--------

 include/linux/ipv6.h             |    3 +
 include/net/ip6_fib.h            |    8 +-
 include/net/ip6_route.h          |   14 +++-
 net/dccp/ipv6.c                  |    4 +
 net/ipv6/Kconfig                 |   14 ++++
 net/ipv6/af_inet6.c              |    2 -
 net/ipv6/datagram.c              |    7 ++
 net/ipv6/fib6_rules.c            |    2 -
 net/ipv6/inet6_connection_sock.c |    2 -
 net/ipv6/ip6_fib.c               |  131 +++++++++++++++++++++--------------
 net/ipv6/ip6_output.c            |   22 ++++--
 net/ipv6/ndisc.c                 |   19 +++--
 net/ipv6/route.c                 |  144 +++++++++++++++++++++++---------------
 net/ipv6/tcp_ipv6.c              |    4 +
 net/ipv6/udp.c                   |    7 ++
 15 files changed, 248 insertions(+), 135 deletions(-)

CHANGESETS
----------

commit 4f2956c43d77e1efbf044db305455493276fc6f2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 16:53:52 2006 +0900

    [IPV6] NDISC: Take source address into account for redirects.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 9bfa3cc..1e4ed63 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -120,6 +120,7 @@ extern int			rt6_route_rcv(struct net_de
 					      struct in6_addr *gwaddr);
 
 extern void			rt6_redirect(struct in6_addr *dest,
+					     struct in6_addr *src,
 					     struct in6_addr *saddr,
 					     struct neighbour *neigh,
 					     u8 *lladdr,
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5743e8b..86ac671 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1346,7 +1346,8 @@ static void ndisc_redirect_rcv(struct sk
 
 	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
 	if (neigh) {
-		rt6_redirect(dest, &skb->nh.ipv6h->saddr, neigh, lladdr, 
+		rt6_redirect(dest, &skb->nh.ipv6h->daddr,
+			     &skb->nh.ipv6h->saddr, neigh, lladdr, 
 			     on_link);
 		neigh_release(neigh);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8913260..91c9461 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1282,7 +1282,8 @@ static int ip6_route_del(struct in6_rtms
 /*
  *	Handle redirects
  */
-void rt6_redirect(struct in6_addr *dest, struct in6_addr *saddr,
+void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
+		  struct in6_addr *saddr,
 		  struct neighbour *neigh, u8 *lladdr, int on_link)
 {
 	struct rt6_info *rt, *nrt = NULL;
@@ -1307,7 +1308,7 @@ void rt6_redirect(struct in6_addr *dest,
 	 */
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_lookup(&table->tb6_root, dest, NULL);
+	fn = fib6_lookup(&table->tb6_root, dest, src);
 restart:
 	for (rt = fn->leaf; rt; rt = rt->u.next) {
 		/*

---
commit 40ff54178bd3c5dbd80f9422e88f7539727cc4e7
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 16:53:53 2006 +0900

    [IPV6] NDISC: Search over all possible rules on receipt of redirect.
    
    Split up function for finding routes for redirects.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 91c9461..4650787 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1282,19 +1282,18 @@ static int ip6_route_del(struct in6_rtms
 /*
  *	Handle redirects
  */
-void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
-		  struct in6_addr *saddr,
-		  struct neighbour *neigh, u8 *lladdr, int on_link)
+struct ip6rd_flowi {
+	struct flowi fl;
+	struct in6_addr gateway;
+};
+
+static struct rt6_info *__ip6_route_redirect(struct fib6_table *table,
+					     struct flowi *fl,
+					     int flags)
 {
-	struct rt6_info *rt, *nrt = NULL;
+	struct ip6rd_flowi *rdfl = (struct ip6rd_flowi *)fl;
+	struct rt6_info *rt;
 	struct fib6_node *fn;
-	struct fib6_table *table;
-	struct netevent_redirect netevent;
-
-	/* TODO: Very lazy, might need to check all tables */
-	table = fib6_get_table(RT6_TABLE_MAIN);
-	if (table == NULL)
-		return;
 
 	/*
 	 * Get the "current" route for this destination and
@@ -1308,7 +1307,7 @@ void rt6_redirect(struct in6_addr *dest,
 	 */
 
 	read_lock_bh(&table->tb6_lock);
-	fn = fib6_lookup(&table->tb6_root, dest, src);
+	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	for (rt = fn->leaf; rt; rt = rt->u.next) {
 		/*
@@ -1323,29 +1322,67 @@ restart:
 			continue;
 		if (!(rt->rt6i_flags & RTF_GATEWAY))
 			continue;
-		if (neigh->dev != rt->rt6i_dev)
+		if (fl->oif != rt->rt6i_dev->ifindex)
 			continue;
-		if (!ipv6_addr_equal(saddr, &rt->rt6i_gateway))
+		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
 			continue;
 		break;
 	}
-	if (rt)
-		dst_hold(&rt->u.dst);
-	else if (rt6_need_strict(dest)) {
-		while ((fn = fn->parent) != NULL) {
-			if (fn->fn_flags & RTN_ROOT)
-				break;
-			if (fn->fn_flags & RTN_RTINFO)
-				goto restart;
+
+	if (!rt) {
+		if (rt6_need_strict(&fl->fl6_dst)) {
+			while ((fn = fn->parent) != NULL) {
+				if (fn->fn_flags & RTN_ROOT)
+					break;
+				if (fn->fn_flags & RTN_RTINFO)
+					goto restart;
+			}
 		}
+		rt = &ip6_null_entry;
 	}
+	dst_hold(&rt->u.dst);
+
 	read_unlock_bh(&table->tb6_lock);
 
-	if (!rt) {
+	return rt;
+};
+
+static struct rt6_info *ip6_route_redirect(struct in6_addr *dest,
+					   struct in6_addr *src,
+					   struct in6_addr *gateway,
+					   struct net_device *dev)
+{
+	struct ip6rd_flowi rdfl = {
+		.fl = {
+			.oif = dev->ifindex,
+			.nl_u = {
+				.ip6_u = {
+					.daddr = *dest,
+					.saddr = *src,
+				},
+			},
+		},
+		.gateway = *gateway,
+	};
+	int flags = rt6_need_strict(dest) ? RT6_F_STRICT : 0;
+
+	return (struct rt6_info *)fib6_rule_lookup((struct flowi *)&rdfl, flags, __ip6_route_redirect);
+}
+
+void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
+		  struct in6_addr *saddr,
+		  struct neighbour *neigh, u8 *lladdr, int on_link)
+{
+	struct rt6_info *rt, *nrt = NULL;
+	struct netevent_redirect netevent;
+
+	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
+
+	if (rt == &ip6_null_entry) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "rt6_redirect: source isn't a valid nexthop "
 			       "for redirect target\n");
-		return;
+		goto out;
 	}
 
 	/*

---
commit e0ad64d5b44179ea1296d737dec23279c72c9636
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:08:33 2006 +0900

    [IPV6] NDISC: Allow redirects from other interfaces if it is not strict.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4650787..1698fec 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1322,7 +1322,7 @@ restart:
 			continue;
 		if (!(rt->rt6i_flags & RTF_GATEWAY))
 			continue;
-		if (fl->oif != rt->rt6i_dev->ifindex)
+		if ((flags & RT6_F_STRICT) && fl->oif != rt->rt6i_dev->ifindex)
 			continue;
 		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
 			continue;

---
commit 67539e5824106359507ea462035fa8bb57c20d4c
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:08:41 2006 +0900

    [IPV6] NDISC: Initialize fl with outbound interface to lookup rules properly.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 86ac671..714dd2d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -412,7 +412,8 @@ static void pndisc_destructor(struct pne
  */
 
 static inline void ndisc_flow_init(struct flowi *fl, u8 type,
-			    struct in6_addr *saddr, struct in6_addr *daddr)
+			    struct in6_addr *saddr, struct in6_addr *daddr,
+			    int oif)
 {
 	memset(fl, 0, sizeof(*fl));
 	ipv6_addr_copy(&fl->fl6_src, saddr);
@@ -420,6 +421,7 @@ static inline void ndisc_flow_init(struc
 	fl->proto	 	= IPPROTO_ICMPV6;
 	fl->fl_icmp_type	= type;
 	fl->fl_icmp_code	= 0;
+	fl->oif			= oif;
 	security_sk_classify_flow(ndisc_socket->sk, fl);
 }
 
@@ -452,7 +454,8 @@ static void ndisc_send_na(struct net_dev
 		src_addr = &tmpaddr;
 	}
 
-	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_ADVERTISEMENT, src_addr, daddr);
+	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_ADVERTISEMENT, src_addr, daddr,
+			dev->ifindex);
 
 	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
 	if (!dst)
@@ -542,7 +545,8 @@ void ndisc_send_ns(struct net_device *de
 		saddr = &addr_buf;
 	}
 
-	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr);
+	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr,
+			dev->ifindex);
 
 	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
 	if (!dst)
@@ -617,7 +621,8 @@ void ndisc_send_rs(struct net_device *de
         int len;
 	int err;
 
-	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr);
+	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
+			dev->ifindex);
 
 	dst = ndisc_dst_alloc(dev, NULL, daddr, ip6_output);
 	if (!dst)
@@ -1383,7 +1388,8 @@ void ndisc_send_redirect(struct sk_buff 
  		return;
  	}
 
-	ndisc_flow_init(&fl, NDISC_REDIRECT, &saddr_buf, &skb->nh.ipv6h->saddr);
+	ndisc_flow_init(&fl, NDISC_REDIRECT, &saddr_buf, &skb->nh.ipv6h->saddr,
+			dev->ifindex);
 
 	dst = ip6_route_output(NULL, &fl);
 	if (dst == NULL)

---
commit 8fc359533dbc3962f32ef2cf39f1e0bf1f5be33b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:09:13 2006 +0900

    [IPV6] ROUTE: Introduce a helper to check route validity.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 686c07a..1102d0d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -726,6 +726,14 @@ fail:
 	return err;
 }
 
+static inline int ip6_rt_check(struct rt6key *rt_key,
+			       struct in6_addr *fl_addr,
+			       struct in6_addr *addr_cache)
+{
+	return ((rt_key->plen != 128 || !ipv6_addr_equal(fl_addr, &rt_key->addr)) &&
+		(addr_cache == NULL || !ipv6_addr_equal(fl_addr, addr_cache)));
+}
+
 static struct dst_entry *ip6_sk_dst_check(struct sock *sk,
 					  struct dst_entry *dst,
 					  struct flowi *fl)
@@ -741,8 +749,8 @@ static struct dst_entry *ip6_sk_dst_chec
 	 * that we do not support routing by source, TOS,
 	 * and MSG_DONTROUTE 		--ANK (980726)
 	 *
-	 * 1. If route was host route, check that
-	 *    cached destination is current.
+	 * 1. ip6_rt_check(): If route was host route,
+	 *    check that cached destination is current.
 	 *    If it is network route, we still may
 	 *    check its validity using saved pointer
 	 *    to the last used address: daddr_cache.
@@ -753,11 +761,8 @@ static struct dst_entry *ip6_sk_dst_chec
 	 *    sockets.
 	 * 2. oif also should be the same.
 	 */
-	if (((rt->rt6i_dst.plen != 128 ||
-	      !ipv6_addr_equal(&fl->fl6_dst, &rt->rt6i_dst.addr))
-	     && (np->daddr_cache == NULL ||
-		 !ipv6_addr_equal(&fl->fl6_dst, np->daddr_cache)))
-	    || (fl->oif && fl->oif != dst->dev->ifindex)) {
+	if (ip6_rt_check(&rt->rt6i_dst, &fl->fl6_dst, np->daddr_cache) ||
+	    (fl->oif && fl->oif != dst->dev->ifindex)) {
 		dst_release(dst);
 		dst = NULL;
 	}

---
commit 25ee62e8a25adfbb2d64c4b54a759d4fbf5be9d8
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:14:39 2006 +0900

    [IPV6]: Cache source address as well in ipv6_pinfo{}.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 297853c..02d14a3 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -242,6 +242,9 @@ struct ipv6_pinfo {
 	struct in6_addr 	rcv_saddr;
 	struct in6_addr		daddr;
 	struct in6_addr		*daddr_cache;
+#ifdef CONFIG_IPV6_SUBTREES
+	struct in6_addr		*saddr_cache;
+#endif
 
 	__u32			flow_label;
 	__u32			frag_size;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 1e4ed63..85b320c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -147,21 +147,24 @@ extern rwlock_t rt6_lock;
  *	Store a destination cache entry in a socket
  */
 static inline void __ip6_dst_store(struct sock *sk, struct dst_entry *dst,
-				   struct in6_addr *daddr)
+				   struct in6_addr *daddr, struct in6_addr *saddr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct rt6_info *rt = (struct rt6_info *) dst;
 
 	sk_setup_caps(sk, dst);
 	np->daddr_cache = daddr;
+#ifdef CONFIG_IPV6_SUBTREES
+	np->saddr_cache = saddr;
+#endif
 	np->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 }
 
 static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
-				 struct in6_addr *daddr)
+				 struct in6_addr *daddr, struct in6_addr *saddr)
 {
 	write_lock(&sk->sk_dst_lock);
-	__ip6_dst_store(sk, dst, daddr);
+	__ip6_dst_store(sk, dst, daddr, saddr);
 	write_unlock(&sk->sk_dst_lock);
 }
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 231bc7c..f9c5e12 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -231,7 +231,7 @@ static int dccp_v6_connect(struct sock *
 	ipv6_addr_copy(&np->saddr, saddr);
 	inet->rcv_saddr = LOOPBACK4_IPV6;
 
-	__ip6_dst_store(sk, dst, NULL);
+	__ip6_dst_store(sk, dst, NULL, NULL);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt != NULL)
@@ -872,7 +872,7 @@ static struct sock *dccp_v6_request_recv
 	 * comment in that function for the gory details. -acme
 	 */
 
-	__ip6_dst_store(newsk, dst, NULL);
+	__ip6_dst_store(newsk, dst, NULL, NULL);
 	newsk->sk_route_caps = dst->dev->features & ~(NETIF_F_IP_CSUM |
 						      NETIF_F_TSO);
 	newdp6 = (struct dccp6_sock *)newsk;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 82a1b1a..6c7c646 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -659,7 +659,7 @@ int inet6_sk_rebuild_header(struct sock 
 			return err;
 		}
 
-		__ip6_dst_store(sk, dst, NULL);
+		__ip6_dst_store(sk, dst, NULL, NULL);
 	}
 
 	return 0;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 79ebbec..1f1071d 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -193,7 +193,12 @@ ipv4_connected:
 
 	ip6_dst_store(sk, dst,
 		      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
-		      &np->daddr : NULL);
+		      &np->daddr : NULL,
+#ifdef CONFIG_IPV6_SUBTREES
+		      ipv6_addr_equal(&fl.fl6_src, &np->saddr) ?
+		      &np->saddr :
+#endif
+		      NULL);
 
 	sk->sk_state = TCP_ESTABLISHED;
 out:
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 7a51a25..827f41d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -186,7 +186,7 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 			return err;
 		}
 
-		__ip6_dst_store(sk, dst, NULL);
+		__ip6_dst_store(sk, dst, NULL, NULL);
 	}
 
 	skb->dst = dst_clone(dst);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1102d0d..133ae15 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -762,6 +762,9 @@ static struct dst_entry *ip6_sk_dst_chec
 	 * 2. oif also should be the same.
 	 */
 	if (ip6_rt_check(&rt->rt6i_dst, &fl->fl6_dst, np->daddr_cache) ||
+#ifdef CONFIG_IPV6_SUBTREES
+	    ip6_rt_check(&rt->rt6i_src, &fl->fl6_src, np->saddr_cache) ||
+#endif
 	    (fl->oif && fl->oif != dst->dev->ifindex)) {
 		dst_release(dst);
 		dst = NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 08c227c..f1134f0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -272,7 +272,7 @@ static int tcp_v6_connect(struct sock *s
 	inet->rcv_saddr = LOOPBACK4_IPV6;
 
 	sk->sk_gso_type = SKB_GSO_TCPV6;
-	__ip6_dst_store(sk, dst, NULL);
+	__ip6_dst_store(sk, dst, NULL, NULL);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
@@ -954,7 +954,7 @@ static struct sock * tcp_v6_syn_recv_soc
 	 */
 
 	sk->sk_gso_type = SKB_GSO_TCPV6;
-	__ip6_dst_store(newsk, dst, NULL);
+	__ip6_dst_store(newsk, dst, NULL, NULL);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 780b89f..09c1dc8 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -842,7 +842,12 @@ do_append_data:
 		if (connected) {
 			ip6_dst_store(sk, dst,
 				      ipv6_addr_equal(&fl->fl6_dst, &np->daddr) ?
-				      &np->daddr : NULL);
+				      &np->daddr : NULL,
+#ifdef CONFIG_IPV6_SUBTREES
+				      ipv6_addr_equal(&fl->fl6_src, &np->saddr) ?
+				      &np->saddr :
+#endif
+				      NULL);
 		} else {
 			dst_release(dst);
 		}

---
commit 61391ed3da4ba78353febdb69e9faa9832479425
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:17:47 2006 +0900

    [IPV6] ROUTE: Make sure we have fn->leaf when adding a node on subtree.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1f23161..37d0f59 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -81,6 +81,7 @@ #define SUBTREE(fn) NULL
 #endif
 
 static void fib6_prune_clones(struct fib6_node *fn, struct rt6_info *rt);
+static struct rt6_info * fib6_find_prefix(struct fib6_node *fn);
 static struct fib6_node * fib6_repair_tree(struct fib6_node *fn);
 
 /*
@@ -551,7 +552,7 @@ void fib6_force_start_gc(void)
 int fib6_add(struct fib6_node *root, struct rt6_info *rt, 
 		struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
 {
-	struct fib6_node *fn;
+	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
@@ -560,6 +561,8 @@ int fib6_add(struct fib6_node *root, str
 	if (fn == NULL)
 		goto out;
 
+	pn = fn;
+
 #ifdef CONFIG_IPV6_SUBTREES
 	if (rt->rt6i_src.plen) {
 		struct fib6_node *sn;
@@ -605,10 +608,6 @@ #ifdef CONFIG_IPV6_SUBTREES
 			/* Now link new subtree to main tree */
 			sfn->parent = fn;
 			fn->subtree = sfn;
-			if (fn->leaf == NULL) {
-				fn->leaf = rt;
-				atomic_inc(&rt->rt6i_ref);
-			}
 		} else {
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
@@ -618,6 +617,10 @@ #ifdef CONFIG_IPV6_SUBTREES
 				goto st_failure;
 		}
 
+		if (fn->leaf == NULL) {
+			fn->leaf = rt;
+			atomic_inc(&rt->rt6i_ref);
+		}
 		fn = sn;
 	}
 #endif
@@ -631,8 +634,25 @@ #endif
 	}
 
 out:
-	if (err)
+	if (err) {
+#ifdef CONFIG_IPV6_SUBTREES
+		/*
+		 * If fib6_add_1 has cleared the old leaf pointer in the
+		 * super-tree leaf node we have to find a new one for it.
+		 */
+		if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO)) {
+			pn->leaf = fib6_find_prefix(pn);
+#if RT6_DEBUG >= 2
+			if (!pn->leaf) {
+				BUG_TRAP(pn->leaf != NULL);
+				pn->leaf = &ip6_null_entry;
+			}
+#endif
+			atomic_inc(&pn->leaf->rt6i_ref);
+		}
+#endif
 		dst_free(&rt->u.dst);
+	}
 	return err;
 
 #ifdef CONFIG_IPV6_SUBTREES

---
commit 7c191ae22dee4465fffd8603429385fbea518faa
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:18:06 2006 +0900

    [IPV6] ROUTE: Prune clones from main tree as well.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 37d0f59..fd059a2 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -630,7 +630,7 @@ #endif
 	if (err == 0) {
 		fib6_start_gc(rt);
 		if (!(rt->rt6i_flags&RTF_CACHE))
-			fib6_prune_clones(fn, rt);
+			fib6_prune_clones(pn, rt);
 	}
 
 out:

---
commit 7e7d663f87c72805f68317d402107e81ff309c0d
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:18:31 2006 +0900

    [IPV6] ROUTE: Fix looking up a route on subtree.
    
    Even on RTN_ROOT node, we need to process its subtree first.
    Fix NULL pointer dereference in fib6_locate().
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index fd059a2..c7b63a6 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -704,33 +704,26 @@ static struct fib6_node * fib6_lookup_1(
 		break;
 	}
 
-	while ((fn->fn_flags & RTN_ROOT) == 0) {
-#ifdef CONFIG_IPV6_SUBTREES
-		if (fn->subtree) {
-			struct fib6_node *st;
-			struct lookup_args *narg;
-
-			narg = args + 1;
-
-			if (narg->addr) {
-				st = fib6_lookup_1(fn->subtree, narg);
-
-				if (st && !(st->fn_flags & RTN_ROOT))
-					return st;
-			}
-		}
-#endif
-
-		if (fn->fn_flags & RTN_RTINFO) {
+	while(fn) {
+		if (SUBTREE(fn) || fn->fn_flags & RTN_RTINFO) {
 			struct rt6key *key;
 
 			key = (struct rt6key *) ((u8 *) fn->leaf +
 						 args->offset);
 
-			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen))
-				return fn;
+			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen)) {
+#ifdef CONFIG_IPV6_SUBTREES
+				if (fn->subtree)
+					fn = fib6_lookup_1(fn->subtree, args + 1);
+#endif
+				if (!fn || fn->fn_flags & RTN_RTINFO)
+					return fn;
+			}
 		}
 
+		if (fn->fn_flags & RTN_ROOT)
+			break;
+
 		fn = fn->parent;
 	}
 
@@ -807,10 +800,8 @@ struct fib6_node * fib6_locate(struct fi
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src_len) {
 		BUG_TRAP(saddr!=NULL);
-		if (fn == NULL)
-			fn = fn->subtree;
-		if (fn)
-			fn = fib6_locate_1(fn, saddr, src_len,
+		if (fn && fn->subtree)
+			fn = fib6_locate_1(fn->subtree, saddr, src_len,
 					   offsetof(struct rt6_info, rt6i_src));
 	}
 #endif

---
commit 1b5fab0cbe09e9aa00ff1c7f13aa204aca8c4b29
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:18:56 2006 +0900

    [IPV6] ROUTE: Make sure we do not exceed args in fib6_lookup_1().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c7b63a6..b24b6a4 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -683,6 +683,9 @@ static struct fib6_node * fib6_lookup_1(
 	struct fib6_node *fn;
 	int dir;
 
+	if (unlikely(args->offset == 0))
+		return NULL;
+
 	/*
 	 *	Descend on a tree
 	 */
@@ -733,16 +736,22 @@ #endif
 struct fib6_node * fib6_lookup(struct fib6_node *root, struct in6_addr *daddr,
 			       struct in6_addr *saddr)
 {
-	struct lookup_args args[2];
 	struct fib6_node *fn;
-
-	args[0].offset = offsetof(struct rt6_info, rt6i_dst);
-	args[0].addr = daddr;
-
+	struct lookup_args args[] = {
+		{
+			.offset = offsetof(struct rt6_info, rt6i_dst),
+			.addr = daddr,
+		},
 #ifdef CONFIG_IPV6_SUBTREES
-	args[1].offset = offsetof(struct rt6_info, rt6i_src);
-	args[1].addr = saddr;
+		{
+			.offset = offsetof(struct rt6_info, rt6i_src),
+			.addr = saddr,
+		},
 #endif
+		{
+			.offset = 0,	/* sentinel */
+		}
+	};
 
 	fn = fib6_lookup_1(root, args);
 

---
commit eec98f168a438781c133270dfdf456b345fd48d2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:19:15 2006 +0900

    [IPV6] ROUTE: Allow searching subtree only.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index b24b6a4..3d45a44 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -753,7 +753,7 @@ #endif
 		}
 	};
 
-	fn = fib6_lookup_1(root, args);
+	fn = fib6_lookup_1(root, daddr ? args : args + 1);
 
 	if (fn == NULL || fn->fn_flags & RTN_TL_ROOT)
 		fn = root;

---
commit 450a6aa5da9a8ffba9a9e462183b0ab76bbfd40c
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:19:37 2006 +0900

    [IPV6] ROUTE: Put SUBTREE() as FIB6_SUBTREE() into ip6_fib.h for future use.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index c0660ce..ca9ab71 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -39,6 +39,11 @@ struct fib6_node
 	__u32			fn_sernum;
 };
 
+#ifndef CONFIG_IPV6_SUBTREES
+#define FIB6_SUBTREE(fn)	NULL
+#else
+#define FIB6_SUBTREE(fn)	((fn)->subtree)
+#endif
 
 /*
  *	routing information
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 3d45a44..026ef67 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -74,10 +74,8 @@ DEFINE_RWLOCK(fib6_walker_lock);
 
 #ifdef CONFIG_IPV6_SUBTREES
 #define FWS_INIT FWS_S
-#define SUBTREE(fn) ((fn)->subtree)
 #else
 #define FWS_INIT FWS_L
-#define SUBTREE(fn) NULL
 #endif
 
 static void fib6_prune_clones(struct fib6_node *fn, struct rt6_info *rt);
@@ -708,7 +706,7 @@ static struct fib6_node * fib6_lookup_1(
 	}
 
 	while(fn) {
-		if (SUBTREE(fn) || fn->fn_flags & RTN_RTINFO) {
+		if (FIB6_SUBTREE(fn) || fn->fn_flags & RTN_RTINFO) {
 			struct rt6key *key;
 
 			key = (struct rt6key *) ((u8 *) fn->leaf +
@@ -839,7 +837,7 @@ static struct rt6_info * fib6_find_prefi
 		if(fn->right)
 			return fn->right->leaf;
 
-		fn = SUBTREE(fn);
+		fn = FIB6_SUBTREE(fn);
 	}
 	return NULL;
 }
@@ -870,7 +868,7 @@ static struct fib6_node * fib6_repair_tr
 		if (fn->right) child = fn->right, children |= 1;
 		if (fn->left) child = fn->left, children |= 2;
 
-		if (children == 3 || SUBTREE(fn) 
+		if (children == 3 || FIB6_SUBTREE(fn) 
 #ifdef CONFIG_IPV6_SUBTREES
 		    /* Subtree root (i.e. fn) may have one child */
 		    || (children && fn->fn_flags&RTN_ROOT)
@@ -889,9 +887,9 @@ #endif
 
 		pn = fn->parent;
 #ifdef CONFIG_IPV6_SUBTREES
-		if (SUBTREE(pn) == fn) {
+		if (FIB6_SUBTREE(pn) == fn) {
 			BUG_TRAP(fn->fn_flags&RTN_ROOT);
-			SUBTREE(pn) = NULL;
+			FIB6_SUBTREE(pn) = NULL;
 			nstate = FWS_L;
 		} else {
 			BUG_TRAP(!(fn->fn_flags&RTN_ROOT));
@@ -939,7 +937,7 @@ #endif
 		read_unlock(&fib6_walker_lock);
 
 		node_free(fn);
-		if (pn->fn_flags&RTN_RTINFO || SUBTREE(pn))
+		if (pn->fn_flags&RTN_RTINFO || FIB6_SUBTREE(pn))
 			return pn;
 
 		rt6_release(pn->leaf);
@@ -1082,8 +1080,8 @@ int fib6_walk_continue(struct fib6_walke
 		switch (w->state) {
 #ifdef CONFIG_IPV6_SUBTREES
 		case FWS_S:
-			if (SUBTREE(fn)) {
-				w->node = SUBTREE(fn);
+			if (FIB6_SUBTREE(fn)) {
+				w->node = FIB6_SUBTREE(fn);
 				continue;
 			}
 			w->state = FWS_L;
@@ -1117,7 +1115,7 @@ #endif	
 			pn = fn->parent;
 			w->node = pn;
 #ifdef CONFIG_IPV6_SUBTREES
-			if (SUBTREE(pn) == fn) {
+			if (FIB6_SUBTREE(pn) == fn) {
 				BUG_TRAP(fn->fn_flags&RTN_ROOT);
 				w->state = FWS_L;
 				continue;

---
commit 09aa35ff359e520abb11b6f71deb21f79da30a52
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:29:18 2006 +0900

    [IPV6] ROUTE: Search subtree when backtracking.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1698fec..0d8759c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -481,17 +481,23 @@ int rt6_route_rcv(struct net_device *dev
 }
 #endif
 
-#define BACKTRACK() \
-if (rt == &ip6_null_entry && flags & RT6_F_STRICT) { \
-	while ((fn = fn->parent) != NULL) { \
-		if (fn->fn_flags & RTN_TL_ROOT) { \
-			dst_hold(&rt->u.dst); \
-			goto out; \
+#define BACKTRACK(saddr) \
+do { \
+	if (rt == &ip6_null_entry) { \
+		struct fib6_node *pn; \
+		while (fn) { \
+			if (fn->fn_flags & RTN_TL_ROOT) \
+				goto out; \
+			pn = fn->parent; \
+			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn) \
+				fn = fib6_lookup(pn->subtree, NULL, saddr); \
+			else \
+				fn = pn; \
+			if (fn->fn_flags & RTN_RTINFO) \
+				goto restart; \
 		} \
-		if (fn->fn_flags & RTN_RTINFO) \
-			goto restart; \
 	} \
-}
+} while(0)
 
 static struct rt6_info *ip6_pol_route_lookup(struct fib6_table *table,
 					     struct flowi *fl, int flags)
@@ -504,7 +510,7 @@ static struct rt6_info *ip6_pol_route_lo
 restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(rt, fl->oif, flags & RT6_F_STRICT);
-	BACKTRACK();
+	BACKTRACK(&fl->fl6_src);
 	dst_hold(&rt->u.dst);
 out:
 	read_unlock_bh(&table->tb6_lock);
@@ -634,7 +640,7 @@ restart_2:
 
 restart:
 	rt = rt6_select(&fn->leaf, fl->iif, strict | reachable);
-	BACKTRACK();
+	BACKTRACK(&fl->fl6_src);
 	if (rt == &ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
@@ -729,7 +735,7 @@ restart_2:
 
 restart:
 	rt = rt6_select(&fn->leaf, fl->oif, strict | reachable);
-	BACKTRACK();
+	BACKTRACK(&fl->fl6_src);
 	if (rt == &ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;

---
commit a75bc4c27c306402d721310e92060969e6e5a031
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:29:33 2006 +0900

    [IPV6] ROUTE: Purge clones on other trees when deleting a route.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 026ef67..3fb15cf 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1023,8 +1023,18 @@ #endif
 
 	BUG_TRAP(fn->fn_flags&RTN_RTINFO);
 
-	if (!(rt->rt6i_flags&RTF_CACHE))
-		fib6_prune_clones(fn, rt);
+	if (!(rt->rt6i_flags&RTF_CACHE)) {
+		struct fib6_node *pn = fn;
+#ifdef CONFIG_IPV6_SUBTREES
+		/* clones of this route might be in another subtree */
+		if (rt->rt6i_src.plen) {
+			while (!(pn->fn_flags&RTN_ROOT))
+				pn = pn->parent;
+			pn = pn->parent;
+		}
+#endif
+		fib6_prune_clones(pn, rt);
+	}
 
 	/*
 	 *	Walk the leaf entries looking for ourself

---
commit 5cb675bce7549177c09ad42e48e07a59df5e0c3f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:33:35 2006 +0900

    [IPV6] NDISC: Search subtrees when backtracking on receipt of redirects.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0d8759c..1795655 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1335,17 +1335,10 @@ restart:
 		break;
 	}
 
-	if (!rt) {
-		if (rt6_need_strict(&fl->fl6_dst)) {
-			while ((fn = fn->parent) != NULL) {
-				if (fn->fn_flags & RTN_ROOT)
-					break;
-				if (fn->fn_flags & RTN_RTINFO)
-					goto restart;
-			}
-		}
+	if (!rt)
 		rt = &ip6_null_entry;
-	}
+	BACKTRACK(&fl->fl6_src);
+out:
 	dst_hold(&rt->u.dst);
 
 	read_unlock_bh(&table->tb6_lock);

---
commit 7546f14b3b4bc90958207f3609edde0875bda619
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:34:43 2006 +0900

    [IPV6] ROUTE: Add credits about subtree fixes.
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 3fb15cf..77cefc9 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -18,6 +18,7 @@
  * 	Yuji SEKIYA @USAGI:	Support default route on router node;
  * 				remove ip6_null_entry from the top of
  * 				routing table.
+ * 	Ville Nuorvala:		Fixed routing subtrees.
  */
 #include <linux/errno.h>
 #include <linux/types.h>
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1795655..6794fe3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -22,6 +22,8 @@
  *		routers in REACHABLE, STALE, DELAY or PROBE states).
  *		- always select the same router if it is (probably)
  *		reachable.  otherwise, round-robin the list.
+ *	Ville Nuorvala
+ *		Fixed routing subtrees.
  */
 
 #include <linux/capability.h>

---
commit 9458f9452e16b5ef6c0c70e0e134513a5f07632b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 17:37:16 2006 +0900

    [IPV6] KCONFIG: Add subtrees support.
    
    This is for developers only.
    Based on MIPL2 kernel patch.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 540e800..952cf1b 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -135,6 +135,20 @@ config IPV6_TUNNEL
 
 	  If unsure, say N.
 
+config IPV6_SUBTREES
+	bool "IPv6: source address based routing"
+	depends on IPV6 && EXPERIMENTAL
+	---help---
+	  Enable routing by source address or prefix.
+
+	  The destination address is still the primary routing key, so mixing
+	  normal and source prefix specific routes in the same routing table
+	  may sometimes lead to unintended routing behavior.  This can be
+	  avoided by defining different routing tables for the normal and
+	  source prefix specific routes.
+
+	  If unsure, say N.
+
 config IPV6_MULTIPLE_TABLES
 	bool "IPv6: Multiple Routing Tables"
 	depends on IPV6 && EXPERIMENTAL

---
commit 218aaaf16e581fce753fcf581d40915da1e23b06
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Aug 9 18:05:02 2006 +0900

    [IPV6] ROUTE: Unify RT6_F_xxx and RT6_SELECT_F_xxx flags
    
    Unify RT6_F_xxx and RT6_SELECT_F_xxx flags into
    RT6_LOOKUP_F_xxx flags, and put them into ip6_route.h
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index ca9ab71..21b8cc5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -174,9 +174,6 @@ #define FIB6_TABLE_MAX		FIB6_TABLE_MIN
 #define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
 #endif
 
-#define RT6_F_STRICT		1
-#define RT6_F_HAS_SADDR		2
-
 typedef struct rt6_info *(*pol_lookup_t)(struct fib6_table *,
 					 struct flowi *, int);
 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 85b320c..c75c968 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -32,6 +32,10 @@ #include <net/sock.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 
+#define RT6_LOOKUP_F_IFACE	0x1
+#define RT6_LOOKUP_F_REACHABLE	0x2
+#define RT6_LOOKUP_F_HAS_SADDR	0x4
+
 struct pol_chain {
 	int			type;
 	int			priority;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 22a2fdb..7505f4b 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -117,7 +117,7 @@ static int fib6_rule_match(struct fib_ru
 	if (!ipv6_prefix_equal(&fl->fl6_dst, &r->dst.addr, r->dst.plen))
 		return 0;
 
-	if ((flags & RT6_F_HAS_SADDR) &&
+	if ((flags & RT6_LOOKUP_F_HAS_SADDR) &&
 	    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
 		return 0;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6794fe3..28e1a03 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -76,9 +76,6 @@ #endif
 
 #define CLONE_OFFLINK_ROUTE 0
 
-#define RT6_SELECT_F_IFACE	0x1
-#define RT6_SELECT_F_REACHABLE	0x2
-
 static int ip6_rt_max_size = 4096;
 static int ip6_rt_gc_min_interval = HZ / 2;
 static int ip6_rt_gc_timeout = 60*HZ;
@@ -340,7 +337,7 @@ static int rt6_score_route(struct rt6_in
 	int m, n;
 		
 	m = rt6_check_dev(rt, oif);
-	if (!m && (strict & RT6_SELECT_F_IFACE))
+	if (!m && (strict & RT6_LOOKUP_F_IFACE))
 		return -1;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
@@ -348,7 +345,7 @@ #endif
 	n = rt6_check_neigh(rt);
 	if (n > 1)
 		m |= 16;
-	else if (!n && strict & RT6_SELECT_F_REACHABLE)
+	else if (!n && strict & RT6_LOOKUP_F_REACHABLE)
 		return -1;
 	return m;
 }
@@ -388,7 +385,7 @@ static struct rt6_info *rt6_select(struc
 	}
 
 	if (!match &&
-	    (strict & RT6_SELECT_F_REACHABLE) &&
+	    (strict & RT6_LOOKUP_F_REACHABLE) &&
 	    last && last != rt0) {
 		/* no entries matched; do round-robin */
 		static DEFINE_SPINLOCK(lock);
@@ -511,7 +508,7 @@ static struct rt6_info *ip6_pol_route_lo
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(rt, fl->oif, flags & RT6_F_STRICT);
+	rt = rt6_device_match(rt, fl->oif, flags);
 	BACKTRACK(&fl->fl6_src);
 	dst_hold(&rt->u.dst);
 out:
@@ -537,7 +534,7 @@ struct rt6_info *rt6_lookup(struct in6_a
 		},
 	};
 	struct dst_entry *dst;
-	int flags = strict ? RT6_F_STRICT : 0;
+	int flags = strict ? RT6_LOOKUP_F_IFACE : 0;
 
 	dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_lookup);
 	if (dst->error == 0)
@@ -629,10 +626,9 @@ static struct rt6_info *ip6_pol_route_in
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = RT6_SELECT_F_REACHABLE;
+	int reachable = RT6_LOOKUP_F_REACHABLE;
 
-	if (flags & RT6_F_STRICT)
-		strict = RT6_SELECT_F_IFACE;
+	strict |= flags & RT6_LOOKUP_F_IFACE;
 
 relookup:
 	read_lock_bh(&table->tb6_lock);
@@ -708,10 +704,7 @@ void ip6_route_input(struct sk_buff *skb
 		},
 		.proto = iph->nexthdr,
 	};
-	int flags = 0;
-
-	if (rt6_need_strict(&iph->daddr))
-		flags |= RT6_F_STRICT;
+	int flags = rt6_need_strict(&iph->daddr) ? RT6_LOOKUP_F_IFACE : 0;
 
 	skb->dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_input);
 }
@@ -724,10 +717,9 @@ static struct rt6_info *ip6_pol_route_ou
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = RT6_SELECT_F_REACHABLE;
+	int reachable = RT6_LOOKUP_F_REACHABLE;
 
-	if (flags & RT6_F_STRICT)
-		strict = RT6_SELECT_F_IFACE;
+	strict |= flags & RT6_LOOKUP_F_IFACE;
 
 relookup:
 	read_lock_bh(&table->tb6_lock);
@@ -793,7 +785,7 @@ struct dst_entry * ip6_route_output(stru
 	int flags = 0;
 
 	if (rt6_need_strict(&fl->fl6_dst))
-		flags |= RT6_F_STRICT;
+		flags |= RT6_LOOKUP_F_IFACE;
 
 	return fib6_rule_lookup(fl, flags, ip6_pol_route_output);
 }
@@ -1330,7 +1322,8 @@ restart:
 			continue;
 		if (!(rt->rt6i_flags & RTF_GATEWAY))
 			continue;
-		if ((flags & RT6_F_STRICT) && fl->oif != rt->rt6i_dev->ifindex)
+		if ((flags & RT6_LOOKUP_F_IFACE) &&
+		    fl->oif != rt->rt6i_dev->ifindex)
 			continue;
 		if (!ipv6_addr_equal(&rdfl->gateway, &rt->rt6i_gateway))
 			continue;
@@ -1365,7 +1358,7 @@ static struct rt6_info *ip6_route_redire
 		},
 		.gateway = *gateway,
 	};
-	int flags = rt6_need_strict(dest) ? RT6_F_STRICT : 0;
+	int flags = rt6_need_strict(dest) ? RT6_LOOKUP_F_IFACE : 0;
 
 	return (struct rt6_info *)fib6_rule_lookup((struct flowi *)&rdfl, flags, __ip6_route_redirect);
 }

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
