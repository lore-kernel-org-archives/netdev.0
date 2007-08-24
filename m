From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/2] [IPV6] IPSEC: Omit redirect for tunnelled packet.
Date: Fri, 24 Aug 2007 19:08:55 +0900
Message-ID: <11879501353034-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44447 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1764200AbXHXKI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 06:08:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPv6 IPsec tunnel gateway incorrectly sends redirect to
router or sender when network device the IPsec tunnelled packet
is arrived is the same as the one the decapsulated packet
is sent.

With this patch, it omits to send the redirect when the forwarding
skbuff carries secpath, since such skbuff should be assumed as
a decapsulated packet from IPsec tunnel by own.

It may be a rare case for an IPsec security gateway, however
it is not rare when the gateway is MIPv6 Home Agent since
the another tunnel end-point is Mobile Node and it changes
the attached network.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/ip6_output.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5dead39..07b82c2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -441,8 +441,10 @@ int ip6_forward(struct sk_buff *skb)
 
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.
+	   We don't send redirects to frames decapsulated from IPsec.
 	 */
-	if (skb->dev == dst->dev && dst->neighbour && opt->srcrt == 0) {
+	if (skb->dev == dst->dev && dst->neighbour && opt->srcrt == 0 &&
+	    !skb->sp) {
 		struct in6_addr *target = NULL;
 		struct rt6_info *rt;
 		struct neighbour *n = dst->neighbour;
-- 
1.4.4.2

