From: Bob Gilligan <gilligan@aristanetworks.com>
Subject: [PATCH 2/2] ipv6: Improve the scaling of the IPv6 neighbor cache
 for multicast destinations.
Date: Thu, 30 Aug 2012 17:55:43 -0700
Message-ID: <50400B8F.5020200@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50733 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab2HaAzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 20:55:48 -0400
Received: by pbbrr13 with SMTP id rr13so4018514pbb.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 17:55:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As with the IPv4 ARP cache, the IPv6 neighbor cache maintains entries
for both unicast and multicast IPv6 next-hop destinations.  The MAC
addresses for unicast destinations are determined by running the
Neighbor Discovery protocol, but those for multicast destinations are
determined by a simple direct mapping from the destination IPv6
multicast address.

Currently, the IPv6 neighbor cache maintains one entry for each IPv6
multicast destination for each interface that has members in that
group.  On a multicast router that is forwarding traffic for many
groups via many interfaces, the number of IPv6 neighbor cache entries
for multicast destinations can become large. It could be as many as:
(number of interfaces) * (number of groups).  Beside using a great
deal of memory, these entries consume space in the IPv6 neighbor cache
that could otherwise be occupied by unicast entries, makeing it more
likely that the IPv6 neighbor cache will become full.

The mapping from multicast IPv6 address to MAC address can just as
easily be done at the time a packet is to be sent.  With this change,
we maintain one IPv6 neighbor cache entry for each interface that has
at least one multicast group member.  All routes to IPv6 multicast
destinations via a particular interface use the same IPv6 neighbor
cache entry.  This entry does not store the MAC address to use.
Instead, packets for multicast destinations go to a new output
function that maps the destination IPv6 multicast address into the MAC
address and forms the MAC header.

Signed-off-by: Bob Gilligan <gilligan@aristanetworks.com>
---
 net/ipv6/ndisc.c |   48 ++++++++++++++++++++++++++++++++++++++++++++----
 net/ipv6/route.c |   13 +++++++++++--
 2 files changed, 55 insertions(+), 6 deletions(-)

Index: b/net/ipv6/ndisc.c
===================================================================
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -90,6 +90,7 @@ static void ndisc_error_report(struct ne
 static int pndisc_constructor(struct pneigh_entry *n);
 static void pndisc_destructor(struct pneigh_entry *n);
 static void pndisc_redo(struct sk_buff *skb);
+static int ndisc_multicast_output(struct neighbour *neigh, struct sk_buff *skb);
 
 static const struct neigh_ops ndisc_generic_ops = {
 	.family =		AF_INET6,
@@ -114,6 +115,13 @@ static const struct neigh_ops ndisc_dire
 	.connected_output =	neigh_direct_output,
 };
 
+static const struct neigh_ops ndisc_multicast_ops = {
+	.family =		AF_INET6,
+	.error_report =		ndisc_error_report,
+	.output =		ndisc_multicast_output,
+	.connected_output =	ndisc_multicast_output,
+};
+
 struct neigh_table nd_tbl = {
 	.family =	AF_INET6,
 	.key_len =	sizeof(struct in6_addr),
@@ -342,6 +350,37 @@ static u32 ndisc_hash(const void *pkey,
 	return ndisc_hashfn(pkey, dev, hash_rnd);
 }
 
+/*
+ * Output function for IPv6 multicast destinations.  We map the
+ * nex-hop address directly into the destination MAC addr here so
+ * that we don't have to store it in the neighbor cache entry.  This allows
+ * routes for multiple multicast destinations to share a single neighbor
+ * cache entry.
+ */
+static int ndisc_multicast_output(struct neighbour *neigh, struct sk_buff *skb)
+{
+	int err;
+	struct dst_entry *dst = skb_dst(skb);
+	struct rt6_info *rt = (struct rt6_info *)dst;
+	struct net_device *dev = neigh->dev;
+	unsigned char ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
+
+	__skb_pull(skb, skb_network_offset(skb));
+
+	ndisc_mc_map(&rt->rt6i_gateway, ha, dev, 1);
+
+	err = dev_hard_header(skb, dev, ntohs(skb->protocol), ha, NULL,
+			      skb->len);
+	if (err >= 0)
+		err = dev_queue_xmit(skb);
+	else {
+		err = -EINVAL;
+		kfree_skb(skb);
+	}
+	return err;
+}
+
+
 static int ndisc_constructor(struct neighbour *neigh)
 {
 	struct in6_addr *addr = (struct in6_addr*)&neigh->primary_key;
@@ -365,10 +404,9 @@ static int ndisc_constructor(struct neig
 		neigh->ops = &ndisc_direct_ops;
 		neigh->output = neigh_direct_output;
 	} else {
-		if (is_multicast) {
+		if (is_multicast)
 			neigh->nud_state = NUD_NOARP;
-			ndisc_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
+		else if (dev->flags&(IFF_NOARP|IFF_LOOPBACK)) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 			if (dev->flags&IFF_LOOPBACK)
@@ -377,7 +415,9 @@ static int ndisc_constructor(struct neig
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
-		if (dev->header_ops->cache)
+		if (is_multicast)
+			neigh->ops = &ndisc_multicast_ops;
+		else if (dev->header_ops->cache)
 			neigh->ops = &ndisc_hh_ops;
 		else
 			neigh->ops = &ndisc_generic_ops;
Index: b/net/ipv6/route.c
===================================================================
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -138,6 +138,8 @@ static struct neighbour *ip6_neigh_looku
 	struct neighbour *n;
 
 	daddr = choose_neigh_daddr(rt, daddr);
+	if (ipv6_addr_type(daddr) & IPV6_ADDR_MULTICAST)
+		daddr = &in6addr_linklocal_allnodes;
 	n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
 	if (n)
 		return n;
@@ -146,9 +148,15 @@ static struct neighbour *ip6_neigh_looku
 
 static int rt6_bind_neighbour(struct rt6_info *rt, struct net_device *dev)
 {
-	struct neighbour *n = __ipv6_neigh_lookup(&nd_tbl, dev, &rt->rt6i_gateway);
+	struct neighbour *n;
+	void *daddr = &rt->rt6i_gateway;
+	
+	if (ipv6_addr_type(daddr) & IPV6_ADDR_MULTICAST)
+		daddr = &in6addr_linklocal_allnodes;
+
+	n = __ipv6_neigh_lookup(&nd_tbl, dev, daddr);
 	if (!n) {
-		n = neigh_create(&nd_tbl, &rt->rt6i_gateway, dev);
+		n = neigh_create(&nd_tbl, daddr, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
 	}
@@ -1128,6 +1136,7 @@ struct dst_entry *icmp6_dst_alloc(struct
 		}
 	}
 
+	rt->rt6i_gateway = fl6->daddr;
 	rt->dst.flags |= DST_HOST;
 	rt->dst.output  = ip6_output;
 	dst_set_neighbour(&rt->dst, neigh);
