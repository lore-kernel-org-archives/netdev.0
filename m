From: Yousuk Seung <ysseung@google.com>
Subject: [PATCH net] tcp: call tcp_rate_skb_sent() when retransmit with unaligned skb->data
Date: Tue, 24 Oct 2017 16:44:42 -0700
Message-ID: <20171024234442.1464-1-ysseung@google.com>
Cc: netdev@vger.kernel.org, Yousuk Seung <ysseung@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:43204 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751277AbdJXXoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 19:44:54 -0400
Received: by mail-io0-f194.google.com with SMTP id 134so25718543ioo.0
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 16:44:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation calls tcp_rate_skb_sent() when tcp_transmit_skb()
is called when it clones skb only. Not calling tcp_rate_skb_sent() is OK
for all such code paths except from __tcp_retransmit_skb() which happens
when skb->data address is not aligned. This may rarely happen e.g. when
small amount of data is sent initially and the receiver partially acks
odd number of bytes for some reason, possibly malicious.

Signed-off-by: Yousuk Seung <ysseung@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 973befc36fd4..1151870018e3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2843,8 +2843,10 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 		nskb = __pskb_copy(skb, MAX_TCP_HEADER, GFP_ATOMIC);
 		err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
 			     -ENOBUFS;
-		if (!err)
+		if (!err) {
 			skb->skb_mstamp = tp->tcp_mstamp;
+			tcp_rate_skb_sent(sk, skb);
+		}
 	} else {
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 	}
-- 
2.15.0.rc0.271.g36b669edcc-goog
