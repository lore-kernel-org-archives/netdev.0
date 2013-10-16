From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: remove redundant code in __tcp_retransmit_skb()
Date: Wed, 16 Oct 2013 12:36:51 -0400
Message-ID: <1381941411-30645-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:38755 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760719Ab3JPQg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 12:36:58 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so95787pde.2
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 09:36:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the specialized code in __tcp_retransmit_skb() that tries to trim
any ACKed payload preceding a FIN before we retransmit (this was added
in 1999 in v2.2.3pre3). This trimming code was made unreachable by the
more general code added above it that uses tcp_trim_head() to trim any
ACKed payload, with or without a FIN (this was added in "[NET]: Add
segmentation offload support to TCP." in 2002 circa v2.5.33).

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e5ce0e1..ce7c4d9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2351,21 +2351,6 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 
 	tcp_retrans_try_collapse(sk, skb, cur_mss);
 
-	/* Some Solaris stacks overoptimize and ignore the FIN on a
-	 * retransmit when old data is attached.  So strip it off
-	 * since it is cheap to do so and saves bytes on the network.
-	 */
-	if (skb->len > 0 &&
-	    (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) &&
-	    tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
-		if (!pskb_trim(skb, 0)) {
-			/* Reuse, even though it does some unnecessary work */
-			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
-					     TCP_SKB_CB(skb)->tcp_flags);
-			skb->ip_summed = CHECKSUM_NONE;
-		}
-	}
-
 	/* Make a copy, if the first transmission SKB clone we made
 	 * is still in somebody's hands, else make a clone.
 	 */
-- 
1.8.4
