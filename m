From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] caif: fix leaks and race in caif_queue_rcv_skb()
Date: Fri, 17 Jul 2015 10:19:23 +0200
Message-ID: <1437121163.1026.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35761 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122AbbGQIT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 04:19:27 -0400
Received: by wibxm9 with SMTP id xm9so32718671wib.0
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 01:19:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) If sk_filter() is applied, skb was leaked (not freed)
2) Testing SOCK_DEAD twice is racy :
   packet could be freed while already queued.
3) Remove obsolete comment about caching skb->len

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/caif/caif_socket.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 3cc71b9f5517..cc858919108e 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -121,12 +121,13 @@ static void caif_flow_ctrl(struct sock *sk, int mode)
  * Copied from sock.c:sock_queue_rcv_skb(), but changed so packets are
  * not dropped, but CAIF is sending flow off instead.
  */
-static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+static void caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 	unsigned long flags;
 	struct sk_buff_head *list = &sk->sk_receive_queue;
 	struct caifsock *cf_sk = container_of(sk, struct caifsock, sk);
+	bool queued = false;
 
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 		(unsigned int)sk->sk_rcvbuf && rx_flow_is_on(cf_sk)) {
@@ -139,7 +140,8 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 
 	err = sk_filter(sk, skb);
 	if (err)
-		return err;
+		goto out;
+
 	if (!sk_rmem_schedule(sk, skb, skb->truesize) && rx_flow_is_on(cf_sk)) {
 		set_rx_flow_off(cf_sk);
 		net_dbg_ratelimited("sending flow OFF due to rmem_schedule\n");
@@ -147,21 +149,16 @@ static int caif_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	}
 	skb->dev = NULL;
 	skb_set_owner_r(skb, sk);
-	/* Cache the SKB length before we tack it onto the receive
-	 * queue. Once it is added it no longer belongs to us and
-	 * may be freed by other threads of control pulling packets
-	 * from the queue.
-	 */
 	spin_lock_irqsave(&list->lock, flags);
-	if (!sock_flag(sk, SOCK_DEAD))
+	queued = !sock_flag(sk, SOCK_DEAD);
+	if (queued)
 		__skb_queue_tail(list, skb);
 	spin_unlock_irqrestore(&list->lock, flags);
-
-	if (!sock_flag(sk, SOCK_DEAD))
+out:
+	if (queued)
 		sk->sk_data_ready(sk);
 	else
 		kfree_skb(skb);
-	return 0;
 }
 
 /* Packet Receive Callback function called from CAIF Stack */
