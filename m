From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH] ipv6: Fix protocol resubmission
Date: Fri, 29 May 2015 15:56:31 -0400
Message-ID: <1432929391-14148-1-git-send-email-johunt@akamai.com>
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:40947 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757043AbbE2T4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 15:56:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I came across this problem while trying to use UDP encapsulation with IPv6. The
change below fixes that, but it was not immediately apparent if there are any
other protocols relying on this broken behavior. FWIW the behavior below now
matches IPv4.

Josh
---

UDP encapsulation is broken on IPv6 because it expects when it returns a negative
value that the packet will be resubmitted to the stack with the handler corresponding
to the return value. The check currently looks for return values > 0 and then resubmits.

This patch fixes that check and also moves the resubmit label to take advantage of
the return code identifying the next protocol we want to process.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/ipv6/ip6_input.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f2e464e..a4c1026 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -212,13 +212,13 @@ static int ip6_input_finish(struct sock *sk, struct sk_buff *skb)
 	 */
 
 	rcu_read_lock();
-resubmit:
 	idev = ip6_dst_idev(skb_dst(skb));
 	if (!pskb_pull(skb, skb_transport_offset(skb)))
 		goto discard;
 	nhoff = IP6CB(skb)->nhoff;
 	nexthdr = skb_network_header(skb)[nhoff];
 
+resubmit:
 	raw = raw6_local_deliver(skb, nexthdr);
 	ipprot = rcu_dereference(inet6_protos[nexthdr]);
 	if (ipprot) {
@@ -246,7 +246,7 @@ resubmit:
 			goto discard;
 
 		ret = ipprot->handler(skb);
-		if (ret > 0)
+		if (ret < 0)
 			goto resubmit;
 		else if (ret == 0)
 			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
-- 
1.7.9.5
