From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv4: only create late gso-skb if skb is already set up with CHECKSUM_PARTIAL
Date: Mon, 22 Feb 2016 18:43:25 +0100
Message-ID: <1456163005-15809-1-git-send-email-hannes@stressinduktion.org>
Cc: Jiri Benc <jbenc@redhat.com>, Wakko Warner <wakko@animx.eu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:36188 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751096AbcBVRne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 12:43:34 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 219B720D2C
	for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 12:43:34 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we break the contract with GSO to only pass CHECKSUM_PARTIAL
skbs down. This can easily happen with UDP+IPv4 sockets with the first
MSG_MORE write smaller than the MTU, second write is a sendfile.

Returning -EOPNOTSUPP lets the callers fall back into normal sendmsg path,
were we calculate the checksum manually during copying.

Commit d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked
sockets") started to exposes this bug.

Fixes: d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")
Reported-by: Jiri Benc <jbenc@redhat.com>
Cc: Jiri Benc <jbenc@redhat.com>
Reported-by: Wakko Warner <wakko@animx.eu.org>
Cc: Wakko Warner <wakko@animx.eu.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/ip_output.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 64878efa045c13..565bf64b2b7d60 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1236,13 +1236,16 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 	if (!skb)
 		return -EINVAL;
 
-	cork->length += size;
 	if ((size + skb->len > mtu) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO)) {
+		if (skb->ip_summed != CHECKSUM_PARTIAL)
+			return -EOPNOTSUPP;
+
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	}
+	cork->length += size;
 
 	while (size > 0) {
 		if (skb_is_gso(skb)) {
-- 
2.5.0
