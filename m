From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/2] [IPV4] IPSEC: Omit redirect for tunnelled packet.
Date: Fri, 24 Aug 2007 19:09:01 +0900
Message-ID: <11879501412786-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44450 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1764556AbXHXKJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 06:09:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPv4 IPsec tunnel gateway incorrectly sends redirect to
sender if it is onlink host when network device the IPsec tunnelled
packet is arrived is the same as the one the decapsulated packet
is sent.

With this patch, it omits to send the redirect when the forwarding
skbuff carries secpath, since such skbuff should be assumed as
a decapsulated packet from IPsec tunnel by own.

Request for comments:
Alternatively we'd have another way to change net/ipv4/route.c
(__mkroute_input) to use RTCF_DOREDIRECT flag unless skbuff
has no secpath. It is better than this patch at performance
point of view because IPv4 redirect judgement is done at
routing slow-path. However, it should be taken care of resource
changes between SAD(XFRM states) and routing table. In other words,
When IPv4 SAD is changed does the related routing entry go to its
slow-path? If not, it is reasonable to apply this patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv4/ip_forward.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 8c95cf0..afbf938 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -105,7 +105,7 @@ int ip_forward(struct sk_buff *skb)
 	 *	We now generate an ICMP HOST REDIRECT giving the route
 	 *	we calculated.
 	 */
-	if (rt->rt_flags&RTCF_DOREDIRECT && !opt->srr)
+	if (rt->rt_flags&RTCF_DOREDIRECT && !opt->srr && !skb->sp)
 		ip_rt_send_redirect(skb);
 
 	skb->priority = rt_tos2priority(iph->tos);
-- 
1.4.4.2

