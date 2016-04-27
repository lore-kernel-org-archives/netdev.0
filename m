From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not block bh during prequeue processing
Date: Wed, 27 Apr 2016 11:59:54 -0700
Message-ID: <1461783594.5535.84.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35482 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbcD0S75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 14:59:57 -0400
Received: by mail-pf0-f179.google.com with SMTP id n1so26316701pfn.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 11:59:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

AFAIK, nothing in current TCP stack absolutely wants BH
being disabled once socket is owned by a thread running in
process context.

As mentioned in my prior patch ("tcp: give prequeue mode some care"),
processing a batch of packets might take time, better not block BH
at all.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c       |    4 ----
 net/ipv4/tcp_input.c |   30 ++----------------------------
 2 files changed, 2 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858991af..7a0f6f738155 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1445,12 +1445,8 @@ static void tcp_prequeue_process(struct sock *sk)
 
 	NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPPREQUEUED);
 
-	/* RX process wants to run with disabled BHs, though it is not
-	 * necessary */
-	local_bh_disable();
 	while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
 		sk_backlog_rcv(sk, skb);
-	local_bh_enable();
 
 	/* Clear memory counter. */
 	tp->ucopy.memory = 0;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 967520dbe0bf..2a0d19e0044f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4608,14 +4608,12 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 
 			__set_current_state(TASK_RUNNING);
 
-			local_bh_enable();
 			if (!skb_copy_datagram_msg(skb, 0, tp->ucopy.msg, chunk)) {
 				tp->ucopy.len -= chunk;
 				tp->copied_seq += chunk;
 				eaten = (chunk == skb->len);
 				tcp_rcv_space_adjust(sk);
 			}
-			local_bh_disable();
 		}
 
 		if (eaten <= 0) {
@@ -5131,7 +5129,6 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 	int chunk = skb->len - hlen;
 	int err;
 
-	local_bh_enable();
 	if (skb_csum_unnecessary(skb))
 		err = skb_copy_datagram_msg(skb, hlen, tp->ucopy.msg, chunk);
 	else
@@ -5143,32 +5140,9 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 		tcp_rcv_space_adjust(sk);
 	}
 
-	local_bh_disable();
 	return err;
 }
 
-static __sum16 __tcp_checksum_complete_user(struct sock *sk,
-					    struct sk_buff *skb)
-{
-	__sum16 result;
-
-	if (sock_owned_by_user(sk)) {
-		local_bh_enable();
-		result = __tcp_checksum_complete(skb);
-		local_bh_disable();
-	} else {
-		result = __tcp_checksum_complete(skb);
-	}
-	return result;
-}
-
-static inline bool tcp_checksum_complete_user(struct sock *sk,
-					     struct sk_buff *skb)
-{
-	return !skb_csum_unnecessary(skb) &&
-	       __tcp_checksum_complete_user(sk, skb);
-}
-
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
@@ -5382,7 +5356,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				}
 			}
 			if (!eaten) {
-				if (tcp_checksum_complete_user(sk, skb))
+				if (tcp_checksum_complete(skb))
 					goto csum_error;
 
 				if ((int)skb->truesize > sk->sk_forward_alloc)
@@ -5426,7 +5400,7 @@ no_ack:
 	}
 
 slow_path:
-	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
+	if (len < (th->doff << 2) || tcp_checksum_complete(skb))
 		goto csum_error;
 
 	if (!th->ack && !th->rst && !th->syn)
