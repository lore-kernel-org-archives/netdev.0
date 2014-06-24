From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net] ipv6: Fix MLD Query message check
Date: Tue, 24 Jun 2014 19:50:28 +0800
Message-ID: <1403610628-19676-1-git-send-email-liuhangbin@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38622 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaFXLu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 07:50:59 -0400
Received: by mail-pa0-f52.google.com with SMTP id eu11so159211pac.25
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 04:50:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on RFC3810 6.2, we also need to check the hop limit and router alert
option besides source address.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/ipv6/mcast.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 08b367c..fdf7455 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1301,8 +1301,18 @@ int igmp6_event_query(struct sk_buff *skb)
 	len = ntohs(ipv6_hdr(skb)->payload_len) + sizeof(struct ipv6hdr);
 	len -= skb_network_header_len(skb);
 
-	/* Drop queries with not link local source */
-	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
+	/* RFC3810 6.2
+	 * Upon reception of an MLD message that contains a Query, the node
+	 * checks if the source address of the message is a valid link-local
+	 * address, if the Hop Limit is set to 1, and if the Router Alert
+	 * option is present in the Hop-By-Hop Options header of the IPv6
+	 * packet.  If any of these checks fails, the packet is dropped.
+	 */
+	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL) ||
+			ipv6_hdr(skb)->hop_limit != 1 ||
+			ipv6_hdr(skb)->nexthdr != NEXTHDR_HOP ||
+			!(IP6CB(skb)->flags & IP6SKB_ROUTERALERT) ||
+			IP6CB(skb)->ra != htons(IPV6_OPT_ROUTERALERT_MLD))
 		return -EINVAL;
 
 	idev = __in6_dev_get(skb->dev);
-- 
1.8.1.4
