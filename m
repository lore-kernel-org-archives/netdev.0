From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Handle PMTU in ICMP error handlers.
Date: Fri, 15 Jun 2012 15:00:52 -0700 (PDT)
Message-ID: <20120615.150052.774388947489484043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757323Ab2FOWAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 18:00:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 07057584FEA
	for <netdev@vger.kernel.org>; Fri, 15 Jun 2012 15:00:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One tricky issue on the ipv6 side vs. ipv4 is that the ICMP callouts
to handle the error pass the 32-bit info cookie in network byte order
whereas ipv4 passes it around in host byte order.

Like the ipv4 side, we have two helper functions.  One for when we
have a socket context and one for when we do not.

ip6ip6 tunnels are not handled here, because they handle PMTU events
by essentially relaying another ICMP packet-too-big message back to
the original sender.

This patch allows us to get rid of rt6_do_pmtu_disc().  It handles all
kinds of situations that simply cannot happen when we do the PMTU
update directly using a fully resolved route.

In fact, the "plen == 128" check in ip6_rt_update_pmtu() can very
likely be removed or changed into a BUG_ON() check.  We should never
have a prefixed ipv6 route when we get there.

Another piece of strange history here is that TCP and DCCP, unlike in
ipv4, never invoke the update_pmtu() method from their ICMP error
handlers.  This is incredibly astonishing since this is the context
where we have the most accurate context in which to make a PMTU
update, namely we have a fully connected socket and associated cached
socket route.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    8 +--
 net/dccp/ipv6.c         |    2 +
 net/ipv6/ah6.c          |    3 +-
 net/ipv6/esp6.c         |    2 +
 net/ipv6/icmp.c         |    6 +-
 net/ipv6/ipcomp6.c      |    2 +
 net/ipv6/raw.c          |    5 +-
 net/ipv6/route.c        |  143 +++++++++++------------------------------------
 net/ipv6/tcp_ipv6.c     |    2 +
 net/ipv6/udp.c          |    3 +
 10 files changed, 54 insertions(+), 122 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index a2cda24..58cb3fc 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -140,10 +140,10 @@ extern void			rt6_redirect(const struct in6_addr *dest,
 					     u8 *lladdr,
 					     int on_link);
 
-extern void			rt6_pmtu_discovery(const struct in6_addr *daddr,
-						   const struct in6_addr *saddr,
-						   struct net_device *dev,
-						   u32 pmtu);
+extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
+			    int oif, u32 mark);
+extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
+			       __be32 mtu);
 
 struct netlink_callback;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index fa9512d..9991be0 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -165,6 +165,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		} else
 			dst_hold(dst);
 
+		dst->ops->update_pmtu(dst, ntohl(info));
+
 		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
 			dccp_sync_mss(sk, dst_mtu(dst));
 		} /* else let the usual retransmit timer handle it */
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index f1a4a2c..49d4d26 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -35,6 +35,7 @@
 #include <linux/pfkeyv2.h>
 #include <linux/string.h>
 #include <linux/scatterlist.h>
+#include <net/ip6_route.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -621,7 +622,7 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	NETDEBUG(KERN_DEBUG "pmtu discovery on SA AH/%08x/%pI6\n",
 		 ntohl(ah->spi), &iph->daddr);
-
+	ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index db1521f..89a615b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -39,6 +39,7 @@
 #include <linux/random.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <net/ip6_route.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -442,6 +443,7 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 	pr_debug("pmtu discovery on SA ESP/%08x/%pI6\n",
 		 ntohl(esph->spi), &iph->daddr);
+	ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index ed89bba..5247d5c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -649,7 +649,6 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct inet6_dev *idev = __in6_dev_get(dev);
 	const struct in6_addr *saddr, *daddr;
-	const struct ipv6hdr *orig_hdr;
 	struct icmp6hdr *hdr;
 	u8 type;
 
@@ -661,7 +660,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 				 XFRM_STATE_ICMP))
 			goto drop_no_count;
 
-		if (!pskb_may_pull(skb, sizeof(*hdr) + sizeof(*orig_hdr)))
+		if (!pskb_may_pull(skb, sizeof(*hdr) + sizeof(struct ipv6hdr)))
 			goto drop_no_count;
 
 		nh = skb_network_offset(skb);
@@ -722,9 +721,6 @@ static int icmpv6_rcv(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 			goto discard_it;
 		hdr = icmp6_hdr(skb);
-		orig_hdr = (struct ipv6hdr *) (hdr + 1);
-		rt6_pmtu_discovery(&orig_hdr->daddr, &orig_hdr->saddr, dev,
-				   ntohl(hdr->icmp6_mtu));
 
 		/*
 		 *	Drop through to notify
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 5cb75bf..9283238 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -46,6 +46,7 @@
 #include <linux/list.h>
 #include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
+#include <net/ip6_route.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -74,6 +75,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	pr_debug("pmtu discovery on SA IPCOMP/%08x/%pI6\n",
 		 spi, &iph->daddr);
+	ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
 }
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 93d6983..43b0042 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -328,9 +328,10 @@ static void rawv6_err(struct sock *sk, struct sk_buff *skb,
 		return;
 
 	harderr = icmpv6_err_convert(type, code, &err);
-	if (type == ICMPV6_PKT_TOOBIG)
+	if (type == ICMPV6_PKT_TOOBIG) {
+		ip6_sk_update_pmtu(skb, sk, info);
 		harderr = (np->pmtudisc == IPV6_PMTUDISC_DO);
-
+	}
 	if (np->recverr) {
 		u8 *payload = skb->data;
 		if (!inet->hdrincl)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 58a3ec2..0d41f68 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1049,7 +1049,10 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info*)dst;
 
+	dst_confirm(dst);
 	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
+		struct net *net = dev_net(dst->dev);
+
 		rt6->rt6i_flags |= RTF_MODIFIED;
 		if (mtu < IPV6_MIN_MTU) {
 			u32 features = dst_metric(dst, RTAX_FEATURES);
@@ -1058,9 +1061,39 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 			dst_metric_set(dst, RTAX_FEATURES, features);
 		}
 		dst_metric_set(dst, RTAX_MTU, mtu);
+		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 	}
 }
 
+void ip6_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
+		     int oif, __be32 mark)
+{
+	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_oif = oif;
+	fl6.flowi6_mark = mark;
+	fl6.flowi6_flags = FLOWI_FLAG_PRECOW_METRICS;
+	fl6.daddr = iph->daddr;
+	fl6.saddr = iph->saddr;
+	fl6.flowlabel = (*(__be32 *) iph) & IPV6_FLOWINFO_MASK;
+
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (!dst->error)
+		ip6_rt_update_pmtu(dst, ntohl(mtu));
+	dst_release(dst);
+}
+EXPORT_SYMBOL_GPL(ip6_update_pmtu);
+
+void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
+{
+	ip6_update_pmtu(skb, sock_net(sk), mtu,
+			sk->sk_bound_dev_if, sk->sk_mark);
+}
+EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
+
 static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 {
 	struct net_device *dev = dst->dev;
@@ -1704,116 +1737,6 @@ out:
 }
 
 /*
- *	Handle ICMP "packet too big" messages
- *	i.e. Path MTU discovery
- */
-
-static void rt6_do_pmtu_disc(const struct in6_addr *daddr, const struct in6_addr *saddr,
-			     struct net *net, u32 pmtu, int ifindex)
-{
-	struct rt6_info *rt, *nrt;
-	int allfrag = 0;
-again:
-	rt = rt6_lookup(net, daddr, saddr, ifindex, 0);
-	if (!rt)
-		return;
-
-	if (rt6_check_expired(rt)) {
-		ip6_del_rt(rt);
-		goto again;
-	}
-
-	if (pmtu >= dst_mtu(&rt->dst))
-		goto out;
-
-	if (pmtu < IPV6_MIN_MTU) {
-		/*
-		 * According to RFC2460, PMTU is set to the IPv6 Minimum Link
-		 * MTU (1280) and a fragment header should always be included
-		 * after a node receiving Too Big message reporting PMTU is
-		 * less than the IPv6 Minimum Link MTU.
-		 */
-		pmtu = IPV6_MIN_MTU;
-		allfrag = 1;
-	}
-
-	/* New mtu received -> path was valid.
-	   They are sent only in response to data packets,
-	   so that this nexthop apparently is reachable. --ANK
-	 */
-	dst_confirm(&rt->dst);
-
-	/* Host route. If it is static, it would be better
-	   not to override it, but add new one, so that
-	   when cache entry will expire old pmtu
-	   would return automatically.
-	 */
-	if (rt->rt6i_flags & RTF_CACHE) {
-		dst_metric_set(&rt->dst, RTAX_MTU, pmtu);
-		if (allfrag) {
-			u32 features = dst_metric(&rt->dst, RTAX_FEATURES);
-			features |= RTAX_FEATURE_ALLFRAG;
-			dst_metric_set(&rt->dst, RTAX_FEATURES, features);
-		}
-		rt6_update_expires(rt, net->ipv6.sysctl.ip6_rt_mtu_expires);
-		rt->rt6i_flags |= RTF_MODIFIED;
-		goto out;
-	}
-
-	/* Network route.
-	   Two cases are possible:
-	   1. It is connected route. Action: COW
-	   2. It is gatewayed route or NONEXTHOP route. Action: clone it.
-	 */
-	if (!dst_get_neighbour_noref_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))
-		nrt = rt6_alloc_cow(rt, daddr, saddr);
-	else
-		nrt = rt6_alloc_clone(rt, daddr);
-
-	if (nrt) {
-		dst_metric_set(&nrt->dst, RTAX_MTU, pmtu);
-		if (allfrag) {
-			u32 features = dst_metric(&nrt->dst, RTAX_FEATURES);
-			features |= RTAX_FEATURE_ALLFRAG;
-			dst_metric_set(&nrt->dst, RTAX_FEATURES, features);
-		}
-
-		/* According to RFC 1981, detecting PMTU increase shouldn't be
-		 * happened within 5 mins, the recommended timer is 10 mins.
-		 * Here this route expiration time is set to ip6_rt_mtu_expires
-		 * which is 10 mins. After 10 mins the decreased pmtu is expired
-		 * and detecting PMTU increase will be automatically happened.
-		 */
-		rt6_update_expires(nrt, net->ipv6.sysctl.ip6_rt_mtu_expires);
-		nrt->rt6i_flags |= RTF_DYNAMIC;
-		ip6_ins_rt(nrt);
-	}
-out:
-	dst_release(&rt->dst);
-}
-
-void rt6_pmtu_discovery(const struct in6_addr *daddr, const struct in6_addr *saddr,
-			struct net_device *dev, u32 pmtu)
-{
-	struct net *net = dev_net(dev);
-
-	/*
-	 * RFC 1981 states that a node "MUST reduce the size of the packets it
-	 * is sending along the path" that caused the Packet Too Big message.
-	 * Since it's not possible in the general case to determine which
-	 * interface was used to send the original packet, we update the MTU
-	 * on the interface that will be used to send future packets. We also
-	 * update the MTU on the interface that received the Packet Too Big in
-	 * case the original packet was forced out that interface with
-	 * SO_BINDTODEVICE or similar. This is the next best thing to the
-	 * correct behaviour, which would be to update the MTU on all
-	 * interfaces.
-	 */
-	rt6_do_pmtu_disc(daddr, saddr, net, pmtu, 0);
-	rt6_do_pmtu_disc(daddr, saddr, net, pmtu, dev->ifindex);
-}
-
-/*
  *	Misc support functions
  */
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f91b0bf..26a8862 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -415,6 +415,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		} else
 			dst_hold(dst);
 
+		dst->ops->update_pmtu(dst, ntohl(info));
+
 		if (inet_csk(sk)->icsk_pmtu_cookie > dst_mtu(dst)) {
 			tcp_sync_mss(sk, dst_mtu(dst));
 			tcp_simple_retransmit(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f05099f..051ad48 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -479,6 +479,9 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (sk == NULL)
 		return;
 
+	if (type == ICMPV6_PKT_TOOBIG)
+		ip6_sk_update_pmtu(skb, sk, info);
+
 	np = inet6_sk(sk);
 
 	if (!icmpv6_err_convert(type, code, &err) && !np->recverr)
-- 
1.7.10
