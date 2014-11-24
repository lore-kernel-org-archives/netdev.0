From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/17] netfilter: nf_conntrack_h323: lookup route from proper net namespace
Date: Mon, 24 Nov 2014 14:27:52 +0100
Message-ID: <1416835674-11871-16-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44921 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063AbaKXN0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:26:01 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>

Signed-off-by: Vasily Averin <vvs@parallels.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_h323_main.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 3a3a60b..1d69f5b 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -728,7 +728,8 @@ static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 
 /* If the calling party is on the same side of the forward-to party,
  * we don't need to track the second call */
-static int callforward_do_filter(const union nf_inet_addr *src,
+static int callforward_do_filter(struct net *net,
+				 const union nf_inet_addr *src,
 				 const union nf_inet_addr *dst,
 				 u_int8_t family)
 {
@@ -750,9 +751,9 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 
 		memset(&fl2, 0, sizeof(fl2));
 		fl2.daddr = dst->ip;
-		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
+		if (!afinfo->route(net, (struct dst_entry **)&rt1,
 				   flowi4_to_flowi(&fl1), false)) {
-			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
+			if (!afinfo->route(net, (struct dst_entry **)&rt2,
 					   flowi4_to_flowi(&fl2), false)) {
 				if (rt_nexthop(rt1, fl1.daddr) ==
 				    rt_nexthop(rt2, fl2.daddr) &&
@@ -774,9 +775,9 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 
 		memset(&fl2, 0, sizeof(fl2));
 		fl2.daddr = dst->in6;
-		if (!afinfo->route(&init_net, (struct dst_entry **)&rt1,
+		if (!afinfo->route(net, (struct dst_entry **)&rt1,
 				   flowi6_to_flowi(&fl1), false)) {
-			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
+			if (!afinfo->route(net, (struct dst_entry **)&rt2,
 					   flowi6_to_flowi(&fl2), false)) {
 				if (ipv6_addr_equal(rt6_nexthop(rt1),
 						    rt6_nexthop(rt2)) &&
@@ -807,6 +808,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 	__be16 port;
 	union nf_inet_addr addr;
 	struct nf_conntrack_expect *exp;
+	struct net *net = nf_ct_net(ct);
 	typeof(nat_callforwarding_hook) nat_callforwarding;
 
 	/* Read alternativeAddress */
@@ -816,7 +818,7 @@ static int expect_callforwarding(struct sk_buff *skb,
 	/* If the calling party is on the same side of the forward-to party,
 	 * we don't need to track the second call */
 	if (callforward_filter &&
-	    callforward_do_filter(&addr, &ct->tuplehash[!dir].tuple.src.u3,
+	    callforward_do_filter(net, &addr, &ct->tuplehash[!dir].tuple.src.u3,
 				  nf_ct_l3num(ct))) {
 		pr_debug("nf_ct_q931: Call Forwarding not tracked\n");
 		return 0;
-- 
1.7.10.4
