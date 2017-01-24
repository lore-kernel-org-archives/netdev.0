From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: reduce skb overhead in selected places
Date: Tue, 24 Jan 2017 14:57:36 -0800
Message-ID: <1485298656.16328.355.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33882 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdAXW5h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 17:57:37 -0500
Received: by mail-pg0-f68.google.com with SMTP id t6so17712028pgt.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 14:57:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_add_backlog() can use skb_condense() helper to get better
gains and less SKB_TRUESIZE() magic. This only happens when socket
backlog has to be used.

Some attacks involve specially crafted out of order tiny TCP packets,
clogging the ofo queue of (many) sockets.
Then later, expensive collapse happens, trying to copy all these skbs
into single ones.
This unfortunately does not work if each skb has no neighbor in TCP
sequence order.

By using skb_condense() if the skb could not be coalesced to a prior
one, we defeat these kind of threats, potentially saving 4K per skb
(or more, since this is one page fragment).

A typical NAPI driver allocates gro packets with GRO_MAX_HEAD bytes
in skb->head, meaning the copy done by skb_condense() is limited to
about 200 bytes.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |    1 +
 net/ipv4/tcp_ipv4.c  |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bfa165cc455ad0a9aea44964aa663dbe6085..3de6eba378ade2c0d4a8400ecb5582a7d126 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4507,6 +4507,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 end:
 	if (skb) {
 		tcp_grow_window(sk, skb);
+		skb_condense(skb);
 		skb_set_owner_r(skb, sk);
 	}
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f7325b25b06e65581ecc496f95e819aa738c..a90b4540c11eca6ed5b374ec69c8ced2ff18 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1556,8 +1556,7 @@ bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb)
 	 * It has been noticed pure SACK packets were sometimes dropped
 	 * (if cooked by drivers without copybreak feature).
 	 */
-	if (!skb->data_len)
-		skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
+	skb_condense(skb);
 
 	if (unlikely(sk_add_backlog(sk, skb, limit))) {
 		bh_unlock_sock(sk);
