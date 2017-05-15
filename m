From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/3] udp: keep the sk_receive_queue held when splicing
Date: Mon, 15 May 2017 11:01:44 +0200
Message-ID: <41a898cfb2cf7ee618237a62bc48df1defed8957.1494837879.git.pabeni@redhat.com>
References: <cover.1494837879.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933764AbdEOJDL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 05:03:11 -0400
In-Reply-To: <cover.1494837879.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On packet reception, when we are forced to splice the
sk_receive_queue, we can keep the related lock held, so
that we can avoid re-acquiring it, if fwd memory
scheduling is required.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 36 ++++++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 492c76b..d698973 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1164,7 +1164,8 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 }
 
 /* fully reclaim rmem/fwd memory allocated for skb */
-static void udp_rmem_release(struct sock *sk, int size, int partial)
+static void udp_rmem_release(struct sock *sk, int size, int partial,
+			     int rx_queue_lock_held)
 {
 	struct udp_sock *up = udp_sk(sk);
 	struct sk_buff_head *sk_queue;
@@ -1181,9 +1182,13 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
 	}
 	up->forward_deficit = 0;
 
-	/* acquire the sk_receive_queue for fwd allocated memory scheduling */
+	/* acquire the sk_receive_queue for fwd allocated memory scheduling,
+	 * if the called don't held it already
+	 */
 	sk_queue = &sk->sk_receive_queue;
-	spin_lock(&sk_queue->lock);
+	if (!rx_queue_lock_held)
+		spin_lock(&sk_queue->lock);
+
 
 	sk->sk_forward_alloc += size;
 	amt = (sk->sk_forward_alloc - partial) & ~(SK_MEM_QUANTUM - 1);
@@ -1197,7 +1202,8 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
 	/* this can save us from acquiring the rx queue lock on next receive */
 	skb_queue_splice_tail_init(sk_queue, &up->reader_queue);
 
-	spin_unlock(&sk_queue->lock);
+	if (!rx_queue_lock_held)
+		spin_unlock(&sk_queue->lock);
 }
 
 /* Note: called with reader_queue.lock held.
@@ -1207,10 +1213,16 @@ static void udp_rmem_release(struct sock *sk, int size, int partial)
  */
 void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 {
-	udp_rmem_release(sk, skb->dev_scratch, 1);
+	udp_rmem_release(sk, skb->dev_scratch, 1, 0);
 }
 EXPORT_SYMBOL(udp_skb_destructor);
 
+/* as above, but the caller held the rx queue lock, too */
+void udp_skb_dtor_locked(struct sock *sk, struct sk_buff *skb)
+{
+	udp_rmem_release(sk, skb->dev_scratch, 1, 1);
+}
+
 /* Idea of busylocks is to let producers grab an extra spinlock
  * to relieve pressure on the receive_queue spinlock shared by consumer.
  * Under flood, this means that only one producer can be in line
@@ -1325,7 +1337,7 @@ void udp_destruct_sock(struct sock *sk)
 		total += skb->truesize;
 		kfree_skb(skb);
 	}
-	udp_rmem_release(sk, total, 0);
+	udp_rmem_release(sk, total, 0, 1);
 
 	inet_sock_destruct(sk);
 }
@@ -1397,7 +1409,7 @@ static int first_packet_length(struct sock *sk)
 	}
 	res = skb ? skb->len : -1;
 	if (total)
-		udp_rmem_release(sk, total, 1);
+		udp_rmem_release(sk, total, 1, 0);
 	spin_unlock_bh(&rcvq->lock);
 	return res;
 }
@@ -1471,16 +1483,20 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
 				goto busy_check;
 			}
 
-			/* refill the reader queue and walk it again */
+			/* refill the reader queue and walk it again
+			 * keep both queues locked to avoid re-acquiring
+			 * the sk_receive_queue lock if fwd memory scheduling
+			 * is needed.
+			 */
 			_off = *off;
 			spin_lock(&sk_queue->lock);
 			skb_queue_splice_tail_init(sk_queue, queue);
-			spin_unlock(&sk_queue->lock);
 
 			skb = __skb_try_recv_from_queue(sk, queue, flags,
-							udp_skb_destructor,
+							udp_skb_dtor_locked,
 							peeked, &_off, err,
 							&last);
+			spin_unlock(&sk_queue->lock);
 			spin_unlock_bh(&queue->lock);
 			if (skb) {
 				*off = _off;
-- 
2.9.3
