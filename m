From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] tcp: allow one skb to be received per socket under memory pressure
Date: Fri, 15 May 2015 07:53:57 -0700
Message-ID: <1431701638-24451-6-git-send-email-edumazet@google.com>
References: <1431701638-24451-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Jason Baron <jbaron@akamai.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:34222 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934224AbbEOOyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 10:54:31 -0400
Received: by obcuy5 with SMTP id uy5so2336162obc.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 07:54:30 -0700 (PDT)
In-Reply-To: <1431701638-24451-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing tight tcp_mem settings, I found tcp sessions could be
stuck because we do not allow even one skb to be received on them.

By allowing one skb to be received, we introduce fairness and
eventuallu force memory hogs to release their allocation.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 093779f7e893..f6763faf0a60 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4507,10 +4507,12 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 
 		if (eaten <= 0) {
 queue_and_out:
-			if (eaten < 0 &&
-			    tcp_try_rmem_schedule(sk, skb, skb->truesize))
-				goto drop;
-
+			if (eaten < 0) {
+				if (skb_queue_len(&sk->sk_write_queue) == 0)
+					sk_forced_mem_schedule(sk, skb->truesize);
+				else if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
+					goto drop;
+			}
 			eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
 		}
 		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
-- 
2.2.0.rc0.207.ga3a616c
