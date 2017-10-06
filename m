From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/7] tcp: pass previous skb to tcp_shifted_skb()
Date: Thu,  5 Oct 2017 22:21:26 -0700
Message-ID: <20171006052127.19913-7-edumazet@google.com>
References: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:43821 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751833AbdJFFVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:47 -0400
Received: by mail-pf0-f171.google.com with SMTP id d2so5859616pfh.0
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:47 -0700 (PDT)
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to recompute previous skb, as it will be a bit more
expensive when rtx queue is converted to RB tree.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index be7644204cd4493d0574aa065afbd6cb82a6b3bb..72c4732ae2da122a878e4673ce56812055de1972 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1288,13 +1288,13 @@ static u8 tcp_sacktag_one(struct sock *sk,
 /* Shift newly-SACKed bytes from this skb to the immediately previous
  * already-SACKed sk_buff. Mark the newly-SACKed bytes as such.
  */
-static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
+static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *prev,
+			    struct sk_buff *skb,
 			    struct tcp_sacktag_state *state,
 			    unsigned int pcount, int shifted, int mss,
 			    bool dup_sack)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
 	u32 start_seq = TCP_SKB_CB(skb)->seq;	/* start of newly-SACKed */
 	u32 end_seq = start_seq + shifted;	/* end of newly-SACKed */
 
@@ -1495,7 +1495,7 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 
 	if (!skb_shift(prev, skb, len))
 		goto fallback;
-	if (!tcp_shifted_skb(sk, skb, state, pcount, len, mss, dup_sack))
+	if (!tcp_shifted_skb(sk, prev, skb, state, pcount, len, mss, dup_sack))
 		goto out;
 
 	/* Hole filled allows collapsing with the next as well, this is very
@@ -1514,7 +1514,8 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 	len = skb->len;
 	if (skb_shift(prev, skb, len)) {
 		pcount += tcp_skb_pcount(skb);
-		tcp_shifted_skb(sk, skb, state, tcp_skb_pcount(skb), len, mss, 0);
+		tcp_shifted_skb(sk, prev, skb, state, tcp_skb_pcount(skb),
+				len, mss, 0);
 	}
 
 out:
-- 
2.14.2.920.gcf0c67979c-goog
