From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3.10-rc] ipv6: Process unicast packet with Router Alert by
 checking flag in skb.
Date: Sat, 22 Jun 2013 11:13:13 +0900
Message-ID: <51C50839.7070804@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33127 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754357Ab3FVCUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 22:20:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Router Alert option is marked in skb.
Previously, IP6CB(skb)->ra was set to positive value for such packets.
Since commit dd3332bf ("ipv6: Store Router Alert option in IP6CB
directly."), IP6SKB_ROUTERALERT is set in IP6CB(skb)->flags, and
the value of Router Alert option (in network byte order) is set
to IP6CB(skb)->ra for such packets.

Multicast forwarding path uses that flag and value, but unicast
forwarding path does not use the flag and misuses IP6CB(skb)->ra
value.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_output.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index dae1949..95703ba 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -381,9 +381,8 @@ int ip6_forward(struct sk_buff *skb)
 	 *	cannot be fragmented, because there is no warranty
 	 *	that different fragments will go along one path. --ANK
 	 */
-	if (opt->ra) {
-		u8 *ptr = skb_network_header(skb) + opt->ra;
-		if (ip6_call_ra_chain(skb, (ptr[2]<<8) + ptr[3]))
+	if (unlikely(opt->flags & IP6SKB_ROUTERALERT)) {
+		if (ip6_call_ra_chain(skb, ntohs(opt->ra)))
 			return 0;
 	}
 
-- 
1.7.9.5
