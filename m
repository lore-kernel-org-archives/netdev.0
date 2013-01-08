From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6: Use container_of macro instead of magic number
 to get ipv6 header.
Date: Wed, 09 Jan 2013 01:44:23 +0900
Message-ID: <50EC4CE7.2020707@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59203 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756380Ab3AHQoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 11:44:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv6_recv_error(), addr_offset points to daddr field of the ip header.
To get ipv6 header, use container_of() macro instead of substracting magic
number (24).

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/datagram.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 8edf260..56b692b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -356,12 +356,11 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		sin->sin6_port = serr->port;
 		sin->sin6_scope_id = 0;
 		if (skb->protocol == htons(ETH_P_IPV6)) {
-			sin->sin6_addr =
-				*(struct in6_addr *)(nh + serr->addr_offset);
+			const struct ipv6hdr *ip6h = container_of((struct in6_addr *)(nh + serr->addr_offset),
+								  struct ipv6hdr, daddr);
+			sin->sin6_addr = ip6h->daddr;
 			if (np->sndflow)
-				sin->sin6_flowinfo =
-					(*(__be32 *)(nh + serr->addr_offset - 24) &
-					 IPV6_FLOWINFO_MASK);
+				sin->sin6_flowinfo = *(__be32 *)ip6h & IPV6_FLOWINFO_MASK;
 			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
-- 
1.7.9.5
