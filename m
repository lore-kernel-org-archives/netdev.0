From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/3] tcp: do not copy headers in tcp_collapse()
Date: Sun, 14 Sep 2014 19:56:20 -0700
Message-ID: <1410749780-30613-4-git-send-email-edumazet@google.com>
References: <1410749780-30613-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:57709 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaIOC5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 22:57:12 -0400
Received: by mail-pa0-f74.google.com with SMTP id lj1so677695pab.5
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 19:57:12 -0700 (PDT)
In-Reply-To: <1410749780-30613-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_collapse() wants to shrink skb so that the overhead is minimal.

Now we store tcp flags into TCP_SKB_CB(skb)->tcp_flags, we no longer
need to keep around full headers.
Whole available space is dedicated to the payload.

Signed-of-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 228bf0c5ff19..ea92f23ffaf1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4535,26 +4535,13 @@ restart:
 		return;
 
 	while (before(start, end)) {
+		int copy = min_t(int, SKB_MAX_ORDER(0, 0), end - start);
 		struct sk_buff *nskb;
-		unsigned int header = skb_headroom(skb);
-		int copy = SKB_MAX_ORDER(header, 0);
 
-		/* Too big header? This can happen with IPv6. */
-		if (copy < 0)
-			return;
-		if (end - start < copy)
-			copy = end - start;
-		nskb = alloc_skb(copy + header, GFP_ATOMIC);
+		nskb = alloc_skb(copy, GFP_ATOMIC);
 		if (!nskb)
 			return;
 
-		skb_set_mac_header(nskb, skb_mac_header(skb) - skb->head);
-		skb_set_network_header(nskb, (skb_network_header(skb) -
-					      skb->head));
-		skb_set_transport_header(nskb, (skb_transport_header(skb) -
-						skb->head));
-		skb_reserve(nskb, header);
-		memcpy(nskb->head, skb->head, header);
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
 		__skb_queue_before(list, skb, nskb);
-- 
2.1.0.rc2.206.gedb03e5
