From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 03/17] ndisc: Introduce struct red_msg for redirect
 message.
Date: Tue, 18 Dec 2012 19:53:42 +0900
Message-ID: <50D04B36.4000803@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56602 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754068Ab2LRKxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:53:46 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |    7 +++++++
 net/ipv6/ndisc.c    |   25 +++++++++++--------------
 net/ipv6/route.c    |   24 ++++++++++--------------
 3 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 7af1ea8..a7df01d 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -78,6 +78,13 @@ struct ra_msg {
 	__be32			retrans_timer;
 };
 
+struct red_msg {
+	struct icmp6hdr		icmph;
+	struct in6_addr		target;
+	struct in6_addr		dest;
+	__u8			opt[0];
+};
+
 struct nd_opt_hdr {
 	__u8		nd_opt_type;
 	__u8		nd_opt_len;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a1d2a45..a181113 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1337,12 +1337,11 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct net_device *dev = skb->dev;
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
-	int len = sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
+	int len = sizeof(struct red_msg);
 	struct inet_peer *peer;
 	struct sk_buff *buff;
-	struct icmp6hdr *icmph;
+	struct red_msg *msg;
 	struct in6_addr saddr_buf;
-	struct in6_addr *addrp;
 	struct rt6_info *rt;
 	struct dst_entry *dst;
 	struct inet6_dev *idev;
@@ -1436,21 +1435,19 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
-	icmph = icmp6_hdr(buff);
+	msg = (struct red_msg *)icmp6_hdr(buff);
 
-	memset(icmph, 0, sizeof(struct icmp6hdr));
-	icmph->icmp6_type = NDISC_REDIRECT;
+	memset(&msg->icmph, 0, sizeof(struct icmp6hdr));
+	msg->icmph.icmp6_type = NDISC_REDIRECT;
 
 	/*
 	 *	copy target and destination addresses
 	 */
 
-	addrp = (struct in6_addr *)(icmph + 1);
-	*addrp = *target;
-	addrp++;
-	*addrp = ipv6_hdr(skb)->daddr;
+	msg->target = *target;
+	msg->dest = ipv6_hdr(skb)->daddr;
 
-	opt = (u8*) (addrp + 1);
+	opt = msg->opt;
 
 	/*
 	 *	include target_address option
@@ -1471,9 +1468,9 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 
 	memcpy(opt, ipv6_hdr(skb), rd_len - 8);
 
-	icmph->icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
-					     len, IPPROTO_ICMPV6,
-					     csum_partial(icmph, len, 0));
+	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
+						 len, IPPROTO_ICMPV6,
+						 csum_partial(msg, len, 0));
 
 	skb_dst_set(buff, dst);
 	rcu_read_lock();
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e229a3b..ec31862 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1705,37 +1705,33 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	struct net *net = dev_net(skb->dev);
 	struct netevent_redirect netevent;
 	struct rt6_info *rt, *nrt = NULL;
-	const struct in6_addr *target;
 	struct ndisc_options ndopts;
-	const struct in6_addr *dest;
 	struct neighbour *old_neigh;
 	struct inet6_dev *in6_dev;
 	struct neighbour *neigh;
-	struct icmp6hdr *icmph;
+	struct red_msg *msg;
 	int optlen, on_link;
 	u8 *lladdr;
 
 	optlen = skb->tail - skb->transport_header;
-	optlen -= sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
+	optlen -= sizeof(*msg);
 
 	if (optlen < 0) {
 		net_dbg_ratelimited("rt6_do_redirect: packet too short\n");
 		return;
 	}
 
-	icmph = icmp6_hdr(skb);
-	target = (const struct in6_addr *) (icmph + 1);
-	dest = target + 1;
+	msg = (struct red_msg *)icmp6_hdr(skb);
 
-	if (ipv6_addr_is_multicast(dest)) {
+	if (ipv6_addr_is_multicast(&msg->dest)) {
 		net_dbg_ratelimited("rt6_do_redirect: destination address is multicast\n");
 		return;
 	}
 
 	on_link = 0;
-	if (ipv6_addr_equal(dest, target)) {
+	if (ipv6_addr_equal(&msg->dest, &msg->target)) {
 		on_link = 1;
-	} else if (ipv6_addr_type(target) !=
+	} else if (ipv6_addr_type(&msg->target) !=
 		   (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
 		net_dbg_ratelimited("rt6_do_redirect: target address is not link-local unicast\n");
 		return;
@@ -1752,7 +1748,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	 *	first-hop router for the specified ICMP Destination Address.
 	 */
 
-	if (!ndisc_parse_options((u8*)(dest + 1), optlen, &ndopts)) {
+	if (!ndisc_parse_options(msg->opt, optlen, &ndopts)) {
 		net_dbg_ratelimited("rt6_redirect: invalid ND options\n");
 		return;
 	}
@@ -1779,7 +1775,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	 */
 	dst_confirm(&rt->dst);
 
-	neigh = __neigh_lookup(&nd_tbl, target, skb->dev, 1);
+	neigh = __neigh_lookup(&nd_tbl, &msg->target, skb->dev, 1);
 	if (!neigh)
 		return;
 
@@ -1799,7 +1795,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 				     NEIGH_UPDATE_F_ISROUTER))
 		     );
 
-	nrt = ip6_rt_copy(rt, dest);
+	nrt = ip6_rt_copy(rt, &msg->dest);
 	if (!nrt)
 		goto out;
 
@@ -1817,7 +1813,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	netevent.old_neigh = old_neigh;
 	netevent.new = &nrt->dst;
 	netevent.new_neigh = neigh;
-	netevent.daddr = dest;
+	netevent.daddr = &msg->dest;
 	call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
 
 	if (rt->rt6i_flags & RTF_CACHE) {
-- 
1.7.9.5
