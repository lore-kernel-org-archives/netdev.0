From: Josh Hunt <johunt@akamai.com>
Subject: [PATCH v2] ipv6: Fix protocol resubmission
Date: Fri, 29 May 2015 16:04:46 -0400
Message-ID: <1432929886-14259-1-git-send-email-johunt@akamai.com>
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:64087 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882AbbE2UEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 16:04:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I came across this problem while trying to use UDP encapsulation with IPv6. The
change below fixes that, but it was not immediately apparent if there are any
other protocols relying on this broken behavior. FWIW the behavior below now
matches IPv4.

Josh

v2: Actually sets nexthdr so we can use it ;)

---

UDP encapsulation is broken on IPv6 because it expects when it returns a negative
value that the packet will be resubmitted to the stack with the handler corresponding
to the return value. The check currently looks for return values > 0 and then resubmits.

This patch fixes that check and also moves the resubmit label to take advantage of
the return code identifying the next protocol we want to process.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---
 net/ipv6/ip6_input.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index f2e464e..e16c289 100644
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
@@ -246,9 +246,10 @@ resubmit:
 			goto discard;
 
 		ret = ipprot->handler(skb);
-		if (ret > 0)
+		if (ret < 0) {
+			nexthdr = -ret;
 			goto resubmit;
-		else if (ret == 0)
+		} else if (ret == 0)
 			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
 	} else {
 		if (!raw) {
-- 
1.7.9.5
