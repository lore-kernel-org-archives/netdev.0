From: Andreas Hofmeister <andi@collax.com>
Subject: [PATCH] ipv6: fix route lookup in addrconf_prefix_rcv()
Date: Wed, 26 Oct 2011 15:24:29 +0200
Message-ID: <1319635469-19016-1-git-send-email-andi@collax.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.collax.com ([213.218.25.154]:52283 "EHLO mail.collax.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932742Ab1JZNYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 09:24:31 -0400
Received: from localhost (mail.collax.com [127.0.0.1])
	by localhost (Postfix) with ESMTP id A158417F000B
	for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 15:24:29 +0200 (CEST)
Received: from mail.collax.com ([127.0.0.1])
	by localhost (mail.collax.com [127.0.0.1]) (amavisd-new, port 10033)
	with ESMTP id LIFOdaw75OTO for <netdev@vger.kernel.org>;
	Wed, 26 Oct 2011 15:24:29 +0200 (CEST)
Received: from vmhost.coreworks.de (unknown [172.16.0.12])
	by mail.collax.com (Postfix) with ESMTP id 5BF5117F0009
	for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 15:24:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The route lookup to find a previously auto-configured route for a prefixes used
to use rt6_lookup(), with the prefix from the RA used as an address. However,
that kind of lookup ignores routing tables, the prefix length and route flags,
so when there were other matching routes, even in different tables and/or with
a different prefix length, the wrong route would be manipulated.

Now, a new function "addrconf_get_prefix_route()" is used for the route lookup,
which searches in RT6_TABLE_PREFIX and takes the prefix-length and route flags
into account.

Signed-off-by: Andreas Hofmeister <andi@collax.com>
---
 net/ipv6/addrconf.c |   43 ++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 12368c5..4193cbb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1713,6 +1713,40 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 	ip6_route_add(&cfg);
 }
 
+
+static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
+						  int plen,
+						  const struct net_device *dev,
+						  u32 flags, u32 noflags)
+{
+	struct fib6_node *fn;
+	struct rt6_info *rt = NULL;
+	struct fib6_table *table;
+
+	table = fib6_get_table(dev_net(dev), RT6_TABLE_PREFIX);
+	if (table == NULL)
+		return NULL;
+
+	write_lock_bh(&table->tb6_lock);
+	fn = fib6_locate(&table->tb6_root, pfx, plen, NULL, 0);
+	if (!fn)
+		goto out;
+	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
+		if (rt->rt6i_dev->ifindex != dev->ifindex)
+			continue;
+		if ((rt->rt6i_flags & flags) != flags)
+			continue;
+		if ((noflags != 0) && ((rt->rt6i_flags & flags) != 0))
+			continue;
+		dst_hold(&rt->dst);
+		break;
+	}
+out:
+	write_unlock_bh(&table->tb6_lock);
+	return rt;
+}
+
+
 /* Create "default" multicast route to the interface */
 
 static void addrconf_add_mroute(struct net_device *dev)
@@ -1842,10 +1876,13 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		if (addrconf_finite_timeout(rt_expires))
 			rt_expires *= HZ;
 
-		rt = rt6_lookup(net, &pinfo->prefix, NULL,
-				dev->ifindex, 1);
+		rt = addrconf_get_prefix_route(&pinfo->prefix,
+					       pinfo->prefix_len,
+					       dev,
+					       RTF_ADDRCONF | RTF_PREFIX_RT,
+					       RTF_GATEWAY | RTF_DEFAULT);
 
-		if (rt && addrconf_is_prefix_route(rt)) {
+		if (rt) {
 			/* Autoconf prefix route */
 			if (valid_lft == 0) {
 				ip6_del_rt(rt);
-- 
1.7.6.1
