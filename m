From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] inet: fix IP(V6)_RECVORIGDSTADDR for udp sockets
Date: Thu, 22 Dec 2016 18:19:16 -0500
Message-ID: <1482448756-83129-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, njagabar@cloudmark.com,
        samanthakumar@google.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34746 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941233AbcLVXTU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 18:19:20 -0500
Received: by mail-qk0-f193.google.com with SMTP id t184so15130474qkd.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 15:19:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Socket cmsg IP(V6)_RECVORIGDSTADDR checks that port range lies within
the packet. For sockets that have transport headers pulled, transport
offset can be negative. Use signed comparison to avoid overflow.

Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
Reported-by: Nisar Jagabar <njagabar@cloudmark.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_sockglue.c | 2 +-
 net/ipv6/datagram.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8b13881..9760734 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -148,7 +148,7 @@ static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	__be16 *ports = (__be16 *)skb_transport_header(skb);
 
-	if (skb_transport_offset(skb) + 4 > skb->len)
+	if (skb_transport_offset(skb) + 4 > (int)skb->len)
 		return;
 
 	/* All current transport protocols have the port numbers in the
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 0489e19..1407426 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -701,7 +701,7 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 		struct sockaddr_in6 sin6;
 		__be16 *ports = (__be16 *) skb_transport_header(skb);
 
-		if (skb_transport_offset(skb) + 4 <= skb->len) {
+		if (skb_transport_offset(skb) + 4 <= (int)skb->len) {
 			/* All current transport protocols have the port numbers in the
 			 * first four bytes of the transport header and this function is
 			 * written with this assumption in mind.
-- 
2.8.0.rc3.226.g39d4020
