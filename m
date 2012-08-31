From: Bob Gilligan <gilligan@aristanetworks.com>
Subject: [PATCH 1/2] ipv4: Improve the scaling of the ARP cache for multicast
 destinations.
Date: Thu, 30 Aug 2012 17:55:04 -0700
Message-ID: <50400B68.3060302@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:48889 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab2HaAzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 20:55:08 -0400
Received: by dady13 with SMTP id y13so1582561dad.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 17:55:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ARP cache maintains entries for both unicast and multicast IPv4
next-hop destinations.  The MAC addresses for unicast destinations are
determined by running the ARP protocol, but those for multicast
destinations are determined by a simple direct mapping from the
destination IPv4 multicast address.

Currently, the ARP cache maintains one entry for each IPv4 multicast
destination for each interface that has members in that group.  On a
multicast router that is forwarding traffic for many groups via many
interfaces, the number of ARP cache entries for multicast destinations
can become large. It could be as many as: (number of interfaces) *
(number of groups).  Beside using a great deal of memory, these entries
consume space in the ARP cache that could otherwise be occupied by
unicast entries, makeing it more likely that the ARP cache will become
full.

The mapping from multicast IPv4 address to MAC address can just as
easily be done at the time a packet is to be sent.  With this change,
we maintain one ARP cache entry for each interface that has at least
one multicast group member.  All routes to IPv4 multicast destinations
via a particular interface use the same ARP cache entry.  This entry
does not store the MAC address to use.  Instead, packets for multicast
destinations go to a new output function that maps the destination
IPv4 multicast address into the MAC address and forms the MAC header.

Signed-off-by: Bob Gilligan <gilligan@aristanetworks.com>
---
 net/ipv4/arp.c   |   49 +++++++++++++++++++++++++++++++++++++++++++++----
 net/ipv4/route.c |   14 ++++++++++++--
 2 files changed, 57 insertions(+), 6 deletions(-)

Index: b/net/ipv4/arp.c
===================================================================
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -126,6 +126,7 @@ static int arp_constructor(struct neighb
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb);
 static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb);
 static void parp_redo(struct sk_buff *skb);
+static int arp_multicast_output(struct neighbour *neigh, struct sk_buff *skb);
 
 static const struct neigh_ops arp_generic_ops = {
 	.family =		AF_INET,
@@ -157,6 +158,13 @@ static const struct neigh_ops arp_broken
 	.connected_output =	neigh_compat_output,
 };
 
+static const struct neigh_ops arp_multicast_ops = {
+	.family =		AF_INET,
+	.error_report =		arp_error_report,
+	.output =		arp_multicast_output,
+	.connected_output =	arp_multicast_output,
+};
+
 struct neigh_table arp_tbl = {
 	.family		= AF_INET,
 	.key_len	= 4,
@@ -217,6 +225,38 @@ static u32 arp_hash(const void *pkey,
 	return arp_hashfn(*(u32 *)pkey, dev, *hash_rnd);
 }
 
+
+/*
+ * Output function for IPv4 multicast destinations.  We map the
+ * next-hop address directly into the destination MAC addr here so
+ * that we don't have to store it in the ARP cache entry.  This allows
+ * routes for multiple multicast destinations to share a single ARP
+ * cache entry.
+ */
+static int arp_multicast_output(struct neighbour *neigh, struct sk_buff *skb)
+{
+	int err;
+	struct dst_entry *dst = skb_dst(skb);
+	struct rtable *rt = (struct rtable *)dst;
+	struct net_device *dev = neigh->dev;
+	unsigned char ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
+
+	__skb_pull(skb, skb_network_offset(skb));
+
+	arp_mc_map(rt->rt_gateway, ha, dev, 1);
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
 static int arp_constructor(struct neighbour *neigh)
 {
 	__be32 addr = *(__be32 *)neigh->primary_key;
@@ -287,10 +327,9 @@ static int arp_constructor(struct neighb
 #endif
 		}
 #endif
-		if (neigh->type == RTN_MULTICAST) {
+		if (neigh->type == RTN_MULTICAST)
 			neigh->nud_state = NUD_NOARP;
-			arp_mc_map(addr, neigh->ha, dev, 1);
-		} else if (dev->flags & (IFF_NOARP | IFF_LOOPBACK)) {
+		else if (dev->flags & (IFF_NOARP | IFF_LOOPBACK)) {
 			neigh->nud_state = NUD_NOARP;
 			memcpy(neigh->ha, dev->dev_addr, dev->addr_len);
 		} else if (neigh->type == RTN_BROADCAST ||
@@ -299,7 +338,9 @@ static int arp_constructor(struct neighb
 			memcpy(neigh->ha, dev->broadcast, dev->addr_len);
 		}
 
-		if (dev->header_ops->cache)
+		if (neigh->type == RTN_MULTICAST)
+			neigh->ops = &arp_multicast_ops;
+		else if (dev->header_ops->cache)
 			neigh->ops = &arp_hh_ops;
 		else
 			neigh->ops = &arp_generic_ops;
Index: b/net/ipv4/route.c
===================================================================
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1114,6 +1114,7 @@ static int slow_chain_length(const struc
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
 	static const __be32 inaddr_any = 0;
+	static const __be32 inaddr_unspec_group = htonl(INADDR_UNSPEC_GROUP);
 	struct net_device *dev = dst->dev;
 	const __be32 *pkey = daddr;
 	const struct rtable *rt;
@@ -1123,8 +1124,17 @@ static struct neighbour *ipv4_neigh_look
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
 		pkey = &inaddr_any;
-	else if (rt->rt_gateway)
-		pkey = (const __be32 *) &rt->rt_gateway;
+	else {
+		if (rt->rt_gateway)
+			pkey = (const __be32 *) &rt->rt_gateway;
+		if (pkey && ipv4_is_multicast(*pkey))
+			/*
+			 * Map all multicast destinations to a single
+			 * address so tht they share a single ARP
+			 * cache entry per interface.
+			 */
+			pkey = &inaddr_unspec_group;
+	}
 
 	n = __ipv4_neigh_lookup(dev, *(__force u32 *)pkey);
 	if (n)
