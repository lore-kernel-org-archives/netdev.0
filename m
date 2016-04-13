From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: simplify sk_receive_queue locking
Date: Wed, 13 Apr 2016 19:12:29 -0300
Message-ID: <6c4b2f1fab1e792537cc1661b130724d1ea26279.1460583258.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbcDMWMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 18:12:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP already serializes access to rcvbuf through its sock lock:
sctp_recvmsg takes it right in the start and release at the end, while
rx path will also take the lock before doing any socket processing. On
sctp_rcv() it will check if there is an user using the socket and, if
there is, it will queue incoming packets to the backlog. The backlog
processing will do the same. Even timers will do such check and
re-schedule if an user is using the socket.

Simplifying this will allow us to remove sctp_skb_list_tail and get ride
of some expensive lockings.  The lists that it is used on are also
mangled with functions like __skb_queue_tail and __skb_unlink in the
same context, like on sctp_ulpq_tail_event() and sctp_clear_pd().
sctp_close() will also purge those while using only the sock lock.

Therefore the lockings performed by sctp_skb_list_tail() are not
necessary. This patch removes this function and replaces its calls with
just skb_queue_splice_tail_init() instead.

The biggest gain is at sctp_ulpq_tail_event(), because the events always
contain a list, even if it's queueing a single skb and this was
triggering expensive calls to spin_lock_irqsave/_irqrestore for every
data chunk received.

As SCTP will deliver each data chunk on a corresponding recvmsg, the
more effective the change will be.
Before this patch, with chunks with 30 bytes:
netperf -t SCTP_STREAM -H 192.168.1.2 -cC -l 60 -- -m 30 -S 400000
400000 -s 400000 400000
on a 10Gbit link with 1500 MTU:

SCTP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

425984 425984     30    60.00       137.45   7.34     7.36     52.504  52.608

With it:

SCTP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

425984 425984     30    60.00       179.10   7.97     6.70     43.740  36.788

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Tested doing single and multi-threaded recvmsg()s on a socket flooded
with chunks, varying sizes across tests, all good.
netperf as above also good.
sctp_test too.

 include/net/sctp/sctp.h | 15 ---------------
 net/sctp/socket.c       |  4 +---
 net/sctp/ulpqueue.c     |  5 +++--
 3 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 03fb33efcae21d54192204629ff4ced2e36e7d4d..978d5f67d5a700aaa6d15d31c7eff62b430b589a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -359,21 +359,6 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp);
 #define sctp_skb_for_each(pos, head, tmp) \
 	skb_queue_walk_safe(head, pos, tmp)
 
-/* A helper to append an entire skb list (list) to another (head). */
-static inline void sctp_skb_list_tail(struct sk_buff_head *list,
-				      struct sk_buff_head *head)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&head->lock, flags);
-	spin_lock(&list->lock);
-
-	skb_queue_splice_tail_init(list, head);
-
-	spin_unlock(&list->lock);
-	spin_unlock_irqrestore(&head->lock, flags);
-}
-
 /**
  *	sctp_list_dequeue - remove from the head of the queue
  *	@list: list to dequeue from
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 36697f85ce48be39f41ddedd9f53369c7f9e28d8..bf265a4bba6e85a31cb9779511c2af9eac077710 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6766,13 +6766,11 @@ struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 		 *  However, this function was correct in any case. 8)
 		 */
 		if (flags & MSG_PEEK) {
-			spin_lock_bh(&sk->sk_receive_queue.lock);
 			skb = skb_peek(&sk->sk_receive_queue);
 			if (skb)
 				atomic_inc(&skb->users);
-			spin_unlock_bh(&sk->sk_receive_queue.lock);
 		} else {
-			skb = skb_dequeue(&sk->sk_receive_queue);
+			skb = __skb_dequeue(&sk->sk_receive_queue);
 		}
 
 		if (skb)
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 72e5b3e41cddf9d79371de8ab01484e4601b97b6..ec12a8920e5fd7a0f26d19f1695bc2feeae41518 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -141,7 +141,8 @@ int sctp_clear_pd(struct sock *sk, struct sctp_association *asoc)
 		 */
 		if (!skb_queue_empty(&sp->pd_lobby)) {
 			struct list_head *list;
-			sctp_skb_list_tail(&sp->pd_lobby, &sk->sk_receive_queue);
+			skb_queue_splice_tail_init(&sp->pd_lobby,
+						   &sk->sk_receive_queue);
 			list = (struct list_head *)&sctp_sk(sk)->pd_lobby;
 			INIT_LIST_HEAD(list);
 			return 1;
@@ -252,7 +253,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	 * collected on a list.
 	 */
 	if (skb_list)
-		sctp_skb_list_tail(skb_list, queue);
+		skb_queue_splice_tail_init(skb_list, queue);
 	else
 		__skb_queue_tail(queue, skb);
 
-- 
2.5.0
