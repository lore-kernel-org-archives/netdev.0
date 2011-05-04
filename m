From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/8] ipv4: Rework ipmr_rt_fib_lookup() flow key
 initialization.
Date: Wed, 04 May 2011 10:14:42 -0700 (PDT)
Message-ID: <20110504.101442.226771183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751916Ab1EDRPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7A88724C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use information from the skb as much as possible, currently
this means daddr, saddr, and TOS.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipmr.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c81b9b6..3ad38a4 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1788,12 +1788,14 @@ dont_forward:
 	return 0;
 }
 
-static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct rtable *rt)
+static struct mr_table *ipmr_rt_fib_lookup(struct net *net, struct sk_buff *skb)
 {
+	struct rtable *rt = skb_rtable(skb);
+	struct iphdr *iph = ip_hdr(skb);
 	struct flowi4 fl4 = {
-		.daddr = rt->rt_key_dst,
-		.saddr = rt->rt_key_src,
-		.flowi4_tos = rt->rt_tos,
+		.daddr = iph->daddr,
+		.saddr = iph->saddr,
+		.flowi4_tos = iph->tos,
 		.flowi4_oif = rt->rt_oif,
 		.flowi4_iif = rt->rt_iif,
 		.flowi4_mark = rt->rt_mark,
@@ -1825,7 +1827,7 @@ int ip_mr_input(struct sk_buff *skb)
 	if (IPCB(skb)->flags & IPSKB_FORWARDED)
 		goto dont_forward;
 
-	mrt = ipmr_rt_fib_lookup(net, skb_rtable(skb));
+	mrt = ipmr_rt_fib_lookup(net, skb);
 	if (IS_ERR(mrt)) {
 		kfree_skb(skb);
 		return PTR_ERR(mrt);
@@ -1957,7 +1959,7 @@ int pim_rcv_v1(struct sk_buff *skb)
 
 	pim = igmp_hdr(skb);
 
-	mrt = ipmr_rt_fib_lookup(net, skb_rtable(skb));
+	mrt = ipmr_rt_fib_lookup(net, skb);
 	if (IS_ERR(mrt))
 		goto drop;
 	if (!mrt->mroute_do_pim ||
@@ -1989,7 +1991,7 @@ static int pim_rcv(struct sk_buff *skb)
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
-	mrt = ipmr_rt_fib_lookup(net, skb_rtable(skb));
+	mrt = ipmr_rt_fib_lookup(net, skb);
 	if (IS_ERR(mrt))
 		goto drop;
 	if (__pim_rcv(mrt, skb, sizeof(*pim))) {
-- 
1.7.4.5

