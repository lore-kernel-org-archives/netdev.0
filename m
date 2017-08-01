From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_data_queue() cleanup
Date: Tue, 01 Aug 2017 07:02:44 -0700
Message-ID: <1501596164.25002.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34922 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdHAOCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:02:47 -0400
Received: by mail-wm0-f65.google.com with SMTP id r77so3210843wmd.2
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 07:02:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit c13ee2a4f03f ("tcp: reindent two spots after prequeue removal")
removed code in tcp_data_queue().

We can go a little farther, removing an always true test,
and removing initializers for fragstolen and eaten variables.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_input.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index af0a98d54b627a90d90fb9f1f2a600277c620559..df670d7ed98df1c108dc654cf446344ff9fdd4be 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4564,8 +4564,8 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	bool fragstolen = false;
-	int eaten = -1;
+	bool fragstolen;
+	int eaten;
 
 	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq) {
 		__kfree_skb(skb);
@@ -4588,12 +4588,11 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 
 		/* Ok. In sequence. In window. */
 queue_and_out:
-		if (eaten < 0) {
-			if (skb_queue_len(&sk->sk_receive_queue) == 0)
-				sk_forced_mem_schedule(sk, skb->truesize);
-			else if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
-				goto drop;
-		}
+		if (skb_queue_len(&sk->sk_receive_queue) == 0)
+			sk_forced_mem_schedule(sk, skb->truesize);
+		else if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
+			goto drop;
+
 		eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
 		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);
 		if (skb->len)
