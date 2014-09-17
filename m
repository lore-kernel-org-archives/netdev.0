From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not fake tcp headers in tcp_send_rcvq()
Date: Wed, 17 Sep 2014 03:14:42 -0700
Message-ID: <1410948882.7106.212.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:39930 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025AbaIQKOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 06:14:45 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so1874907pab.10
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 03:14:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Now we no longer rely on having tcp headers for skbs in receive queue,
tcp repair do not need to build fake ones.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note: It seems we have no checks against too big sizes and alloc_skb()
      could die hard ?

 net/ipv4/tcp_input.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ea92f23ffaf1..02fb66d4a018 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4304,24 +4304,19 @@ static int __must_check tcp_queue_rcv(struct sock *sk, struct sk_buff *skb, int
 
 int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 {
-	struct sk_buff *skb = NULL;
-	struct tcphdr *th;
+	struct sk_buff *skb;
 	bool fragstolen;
 
 	if (size == 0)
 		return 0;
 
-	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
+	skb = alloc_skb(size, sk->sk_allocation);
 	if (!skb)
 		goto err;
 
-	if (tcp_try_rmem_schedule(sk, skb, size + sizeof(*th)))
+	if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
 		goto err_free;
 
-	th = (struct tcphdr *)skb_put(skb, sizeof(*th));
-	skb_reset_transport_header(skb);
-	memset(th, 0, sizeof(*th));
-
 	if (memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size))
 		goto err_free;
 
@@ -4329,7 +4324,7 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + size;
 	TCP_SKB_CB(skb)->ack_seq = tcp_sk(sk)->snd_una - 1;
 
-	if (tcp_queue_rcv(sk, skb, sizeof(*th), &fragstolen)) {
+	if (tcp_queue_rcv(sk, skb, 0, &fragstolen)) {
 		WARN_ON_ONCE(fragstolen); /* should not happen */
 		__kfree_skb(skb);
 	}
