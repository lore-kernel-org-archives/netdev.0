From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/15] ipv4: Don't use rt->rt_{src,dst} in ip_queue_xmit().
Date: Sun, 08 May 2011 15:37:54 -0700 (PDT)
Message-ID: <20110508.153754.102570401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755867Ab1EHWi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:38:26 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7562424C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now we can pick it out of the provided flow key.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 14ee1e4..b88ee5f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -327,12 +327,12 @@ int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 	 */
 	rcu_read_lock();
 	inet_opt = rcu_dereference(inet->inet_opt);
+	fl4 = &fl->u.ip4;
 	rt = skb_rtable(skb);
 	if (rt != NULL)
 		goto packet_routed;
 
 	/* Make sure we can route this packet. */
-	fl4 = &fl->u.ip4;
 	rt = (struct rtable *)__sk_dst_check(sk, 0);
 	if (rt == NULL) {
 		__be32 daddr;
@@ -360,7 +360,7 @@ int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 	skb_dst_set_noref(skb, &rt->dst);
 
 packet_routed:
-	if (inet_opt && inet_opt->opt.is_strictroute && rt->rt_dst != rt->rt_gateway)
+	if (inet_opt && inet_opt->opt.is_strictroute && fl4->daddr != rt->rt_gateway)
 		goto no_route;
 
 	/* OK, we know where to send it, allocate and build IP header. */
@@ -374,8 +374,8 @@ packet_routed:
 		iph->frag_off = 0;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
 	iph->protocol = sk->sk_protocol;
-	iph->saddr    = rt->rt_src;
-	iph->daddr    = rt->rt_dst;
+	iph->saddr    = fl4->saddr;
+	iph->daddr    = fl4->daddr;
 	/* Transport layer set skb->h.foo itself. */
 
 	if (inet_opt && inet_opt->opt.optlen) {
-- 
1.7.5.1

