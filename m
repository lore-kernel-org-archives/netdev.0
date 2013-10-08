From: Jiri Pirko <jiri@resnulli.us>
Subject: [PATCH net stable REPOST] ipv6: restrict neighbor entry creation to
 output flow
Date: Tue, 8 Oct 2013 16:41:13 +0200
Message-ID: <20131008144113.GA4293@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hannes@stressinduktion.org, jiri@resnulli.us, dbanerje@akamai.com,
	yoshfuji@linux-ipv6.org, mleitner@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:39719 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509Ab3JHOlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 10:41:16 -0400
Received: by mail-ea0-f179.google.com with SMTP id b10so4053056eae.10
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 07:41:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>

This patch is based on 3.2.y branch, the one used by reporter. Please let me
know if it should be different. Thanks.

The patch which introduced the regression was applied on stables:
3.0.64 3.4.31 3.7.8 3.2.39

The patch which introduced the regression was for stable trees only.

---8<---

Commit 0d6a77079c475033cb622c07c5a880b392ef664e "ipv6: do not create
neighbor entries for local delivery" introduced a regression on
which routes to local delivery would not work anymore. Like this:

    $ ip -6 route add local 2001::/64 dev lo
    $ ping6 -c1 2001::9
    PING 2001::9(2001::9) 56 data bytes
    ping: sendmsg: Invalid argument

As this is a local delivery, that commit would not allow the creation of a
neighbor entry and thus the packet cannot be sent.

But as TPROXY scenario actually needs to avoid the neighbor entry creation only
for input flow, this patch now limits previous patch to input flow, keeping
output as before that patch.

Reported-by: Debabrata Banerjee <dbavatar@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 18ea73c..bc9103d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -791,7 +791,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_info *ort,
 }
 
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
-				      struct flowi6 *fl6, int flags)
+				      struct flowi6 *fl6, int flags, bool input)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
@@ -799,8 +799,11 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	int attempts = 3;
 	int err;
 	int reachable = net->ipv6.devconf_all->forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
+	int local = RTF_NONEXTHOP;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
+	if (input)
+		local |= RTF_LOCAL;
 
 relookup:
 	read_lock_bh(&table->tb6_lock);
@@ -820,7 +823,7 @@ restart:
 	read_unlock_bh(&table->tb6_lock);
 
 	if (!dst_get_neighbour_raw(&rt->dst)
-	    && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
+	    && !(rt->rt6i_flags & local))
 		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
 	else if (!(rt->dst.flags & DST_HOST))
 		nrt = rt6_alloc_clone(rt, &fl6->daddr);
@@ -864,7 +867,7 @@ out2:
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
 					    struct flowi6 *fl6, int flags)
 {
-	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags);
+	return ip6_pol_route(net, table, fl6->flowi6_iif, fl6, flags, true);
 }
 
 void ip6_route_input(struct sk_buff *skb)
@@ -890,7 +893,7 @@ void ip6_route_input(struct sk_buff *skb)
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
 {
-	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
+	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags, false);
 }
 
 struct dst_entry * ip6_route_output(struct net *net, const struct sock *sk,
-- 
1.8.3.1
