From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/7] tcp: tcp_mark_head_lost() optimization
Date: Thu,  5 Oct 2017 22:21:24 -0700
Message-ID: <20171006052127.19913-5-edumazet@google.com>
References: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:49682 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJFFVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:43 -0400
Received: by mail-pf0-f182.google.com with SMTP id l188so9047354pfc.6
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:43 -0700 (PDT)
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be a bit more expensive to get the head of rtx queue
once rtx queue is converted to an rb-tree.

We can avoid this extra cost in case tp->lost_skb_hint is set.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 90afe41435966fc62ae8cb5799ca4c99995076dc..abc3b1db81f85a7feebda40cebc90c07afcef446 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2207,12 +2207,12 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 	const u32 loss_high = tcp_is_sack(tp) ?  tp->snd_nxt : tp->high_seq;
 
 	WARN_ON(packets > tp->packets_out);
-	if (tp->lost_skb_hint) {
-		skb = tp->lost_skb_hint;
-		cnt = tp->lost_cnt_hint;
+	skb = tp->lost_skb_hint;
+	if (skb) {
 		/* Head already handled? */
-		if (mark_head && skb != tcp_write_queue_head(sk))
+		if (mark_head && after(TCP_SKB_CB(skb)->seq, tp->snd_una))
 			return;
+		cnt = tp->lost_cnt_hint;
 	} else {
 		skb = tcp_write_queue_head(sk);
 		cnt = 0;
-- 
2.14.2.920.gcf0c67979c-goog
