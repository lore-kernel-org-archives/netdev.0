From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 01/13] Implement local diversion of IPv4 skbs
Date: Mon, 05 Mar 2007 16:45:01 +0100
Message-ID: <20070305154501.3471.99384.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:1992 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbXCEPpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:45:04 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id D003A294020
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:45:01 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The input path for non-local bound sockets requires diverting certain
packets locally, even if their destination IP address is not
considered local. We achieve this by assigning a specially crafted dst
entry to these skbs, and optionally also attaching a socket to the skb
so that the upper layer code does not need to redo the socket lookup.

We also have to be able to differentiate between these fake entries
and "real" entries in the cache: it is perfectly legal that the
diversion is done only for certain TCP or UDP packets and not for all
packets of the flow. Since these special dst entries are used only by
the iptables tproxy code, and that code uses exclusively these
entries, simply flagging these entries as DST_DIVERTED is OK. All
other cache lookup paths skip diverted entries, while our new
ip_divert_local() function uses exclusively diverted dst entries.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/dst.h   |    1 
 include/net/route.h |    2 +
 net/ipv4/route.c    |  113 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+), 1 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e12a8ce..4cd0745 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -48,6 +48,7 @@ struct dst_entry
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
 #define DST_BALANCED            0x10
+#define DST_DIVERTED		0x20
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
diff --git a/include/net/route.h b/include/net/route.h
index 749e4df..efaa6b2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -125,6 +125,8 @@ extern int		ip_rt_ioctl(unsigned int cmd, void __user *arg);
 extern void		ip_rt_get_source(u8 *src, struct rtable *rt);
 extern int		ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb);
 
+extern int		ip_divert_local(struct sk_buff *skb, const struct in_device *in, struct sock *sk);
+
 struct in_ifaddr;
 extern void fib_add_ifaddr(struct in_ifaddr *);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 37e0d4d..c526fb2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -100,6 +100,7 @@
 #include <net/ip_fib.h>
 #include <net/arp.h>
 #include <net/tcp.h>
+#include <linux/dccp.h>
 #include <net/icmp.h>
 #include <net/xfrm.h>
 #include <net/ip_mp_alg.h>
@@ -941,9 +942,11 @@ restart:
 	while ((rth = *rthp) != NULL) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 		if (!(rth->u.dst.flags & DST_BALANCED) &&
+		    !((rt->u.dst.flags ^ rth->u.dst.flags) & DST_DIVERTED) &&
 		    compare_keys(&rth->fl, &rt->fl)) {
 #else
-		if (compare_keys(&rth->fl, &rt->fl)) {
+		if (!((rt->u.dst.flags ^ rth->u.dst.flags) & DST_DIVERTED) &&
+		    compare_keys(&rth->fl, &rt->fl)) {
 #endif
 			/* Put it first */
 			*rthp = rth->u.dst.rt_next;
@@ -1165,6 +1168,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.oif != ikeys[k] ||
+				    (rth->u.dst.flags & DST_DIVERTED) ||
 				    rth->fl.iif != 0) {
 					rthp = &rth->u.dst.rt_next;
 					continue;
@@ -1525,6 +1529,111 @@ static int ip_rt_bug(struct sk_buff *skb)
 	return 0;
 }
 
+static void ip_divert_free_sock(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	skb->sk = NULL;
+	skb->destructor = NULL;
+
+	if (sk) {
+		/* TIME_WAIT inet sockets have to be handled differently */
+		if (((sk->sk_protocol == IPPROTO_TCP) && (sk->sk_state == TCP_TIME_WAIT)) ||
+		    ((sk->sk_protocol == IPPROTO_DCCP) && (sk->sk_state == DCCP_TIME_WAIT)))
+			inet_twsk_put(inet_twsk(sk));
+		else
+			sock_put(sk);
+	}
+}
+
+int ip_divert_local(struct sk_buff *skb, const struct in_device *in, struct sock *sk)
+{
+	struct iphdr *iph = skb->nh.iph;
+	struct rtable *rth, *rtres;
+	unsigned hash;
+	const int iif = in->dev->ifindex;
+	u_int8_t tos;
+	int err;
+
+	/* look up hash first */
+	tos = iph->tos & IPTOS_RT_MASK;
+	hash = rt_hash_code(iph->daddr, iph->saddr ^ (iif << 5));
+
+	rcu_read_lock();
+	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
+	     rth = rcu_dereference(rth->u.dst.rt_next)) {
+		if (rth->fl.fl4_dst == iph->daddr &&
+		    rth->fl.fl4_src == iph->saddr &&
+		    rth->fl.iif == iif &&
+		    rth->fl.oif == 0 &&
+		    (rth->u.dst.flags & DST_DIVERTED)) {
+			rth->u.dst.lastuse = jiffies;
+			dst_hold(&rth->u.dst);
+			rth->u.dst.__use++;
+			RT_CACHE_STAT_INC(in_hit);
+			rcu_read_unlock();
+
+			dst_release(skb->dst);
+			skb->dst = (struct dst_entry*)rth;
+
+			if (sk) {
+				sock_hold(sk);
+				skb->sk = sk;
+				skb->destructor = ip_divert_free_sock;
+			}
+
+			return 0;
+		}
+		RT_CACHE_STAT_INC(in_hlist_search);
+	}
+	rcu_read_unlock();
+
+	/* not found in cache, try to allocate a new dst entry */
+	rth = dst_alloc(&ipv4_dst_ops);
+	if (!rth)
+		return -ENOMEM;
+
+	rth->u.dst.output= ip_rt_bug;
+
+	atomic_set(&rth->u.dst.__refcnt, 1);
+	rth->u.dst.flags = DST_HOST | DST_DIVERTED;
+
+	if (in->cnf.no_policy)
+		rth->u.dst.flags |= DST_NOPOLICY;
+
+	rth->fl.fl4_dst = iph->daddr;
+	rth->rt_dst	= iph->daddr;
+	rth->fl.fl4_tos = iph->tos;
+	rth->fl.mark	= skb->mark;
+	rth->fl.fl4_src = iph->saddr;
+	rth->rt_src	= iph->saddr;
+	rth->rt_iif	=
+	rth->fl.iif	= skb->dev->ifindex;
+	rth->u.dst.dev	= &loopback_dev;
+	dev_hold(rth->u.dst.dev);
+	rth->idev	= in_dev_get(rth->u.dst.dev);
+	rth->rt_gateway = iph->daddr;
+	rth->rt_spec_dst= iph->daddr;
+	rth->u.dst.input= ip_local_deliver;
+	rth->rt_flags	= RTCF_LOCAL;
+	rth->rt_type	= RTN_LOCAL;
+
+	err = rt_intern_hash(hash, rth, &rtres);
+	if (err)
+		return err;
+
+	dst_release(skb->dst);
+	skb->dst = (struct dst_entry *) rth;
+
+	if (sk) {
+		sock_hold(sk);
+		skb->sk = sk;
+		skb->destructor = ip_divert_free_sock;
+	}
+
+	return 0;
+}
+
 /*
    We do not cache source address of outgoing interface,
    because it is used only by IP RR, TS and SRR options,
@@ -2103,6 +2212,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->fl.fl4_src == saddr &&
 		    rth->fl.iif == iif &&
 		    rth->fl.oif == 0 &&
+		    !(rth->u.dst.flags & DST_DIVERTED) &&
 		    rth->fl.mark == skb->mark &&
 		    rth->fl.fl4_tos == tos) {
 			rth->u.dst.lastuse = jiffies;
@@ -3199,3 +3309,4 @@ int __init ip_rt_init(void)
 EXPORT_SYMBOL(__ip_select_ident);
 EXPORT_SYMBOL(ip_route_input);
 EXPORT_SYMBOL(ip_route_output_key);
+EXPORT_SYMBOL_GPL(ip_divert_local);

