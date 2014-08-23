From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove dead code after sk_data_ready change
Date: Fri, 22 Aug 2014 20:30:12 -0700
Message-ID: <1408764612.5604.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35481 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbaHWDaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 23:30:14 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so17102334pdj.28
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 20:30:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As a followup to commit 676d23690fb ("net: Fix use after free by
removing length arg from sk_data_ready callbacks"), we can remove
some useless code in sock_queue_rcv_skb() and rxrpc_queue_rcv_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c      |    8 --------
 net/rxrpc/ar-input.c |    9 +--------
 2 files changed, 1 insertion(+), 16 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 2714811afbd8..f7f2352200ad 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -437,7 +437,6 @@ static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
 int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
-	int skb_len;
 	unsigned long flags;
 	struct sk_buff_head *list = &sk->sk_receive_queue;
 
@@ -459,13 +458,6 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
 
-	/* Cache the SKB length before we tack it onto the receive
-	 * queue.  Once it is added it no longer belongs to us and
-	 * may be freed by other threads of control pulling packets
-	 * from the queue.
-	 */
-	skb_len = skb->len;
-
 	/* we escape from rcu protected region, make sure we dont leak
 	 * a norefcounted dst
 	 */
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 63b21e580de9..481f89f93789 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -45,7 +45,7 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_sock *rx = call->socket;
 	struct sock *sk;
-	int skb_len, ret;
+	int ret;
 
 	_enter(",,%d,%d", force, terminal);
 
@@ -101,13 +101,6 @@ int rxrpc_queue_rcv_skb(struct rxrpc_call *call, struct sk_buff *skb,
 			rx->interceptor(sk, call->user_call_ID, skb);
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
 		} else {
-
-			/* Cache the SKB length before we tack it onto the
-			 * receive queue.  Once it is added it no longer
-			 * belongs to us and may be freed by other threads of
-			 * control pulling packets from the queue */
-			skb_len = skb->len;
-
 			_net("post skb %p", skb);
 			__skb_queue_tail(&sk->sk_receive_queue, skb);
 			spin_unlock_bh(&sk->sk_receive_queue.lock);
