From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: on peeking bad csum, drop packets even if not
 at head
Date: Mon, 21 Aug 2017 15:40:32 -0700
Message-ID: <1503355232.2499.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, pabeni@redhat.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34026 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932065AbdHUWke (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 18:40:34 -0400
Received: by mail-pg0-f65.google.com with SMTP id i12so10341803pgr.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 15:40:34 -0700 (PDT)
In-Reply-To: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 17:39 -0400, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> When peeking, if a bad csum is discovered, the skb is unlinked from
> the queue with __sk_queue_drop_skb and the peek operation restarted.
> 
> __sk_queue_drop_skb only drops packets that match the queue head. With
> sk_peek_off, the skb need not be at head, causing the call to fail and
> the same skb to be found again on restart.
> 
> Walk the queue to find the correct skb. Limit the walk to sk_peek_off,
> to bound cycle cost to at most twice the original skb_queue_walk in
> __skb_try_recv_from_queue.
> 
> The operation may race with updates to sk_peek_off. As the operation
> is retried, it will eventually succeed.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

You forgot the Fixes: tag, that such a bug fix deserves.

I am not a big fan of your patch and would prefer a solution without the
loop.

skb already have ->next and ->prev pointer telling us its position in
the receive queue.

We only need to make sure we are the last owner of this skb before doing
the check (ie cancel the kfree_skb() that usually follows the call to
v__sk_queue_drop_skb() of skb->next being NULL or not.

Something like :

 include/net/sock.h  |    2 +-
 net/core/datagram.c |   22 ++++++++++++++--------
 net/ipv4/udp.c      |    2 +-
 net/ipv6/udp.c      |    2 +-
 4 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index aeeec62992ca..6e43bab92d95 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2030,7 +2030,7 @@ void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
 int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
-			struct sk_buff *skb, unsigned int flags,
+			struct sk_buff **pskb, unsigned int flags,
 			void (*destructor)(struct sock *sk,
 					   struct sk_buff *skb));
 int __sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index a21ca8dee5ea..7e129f91af89 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -353,21 +353,27 @@ void __skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb, int len)
 EXPORT_SYMBOL(__skb_free_datagram_locked);
 
 int __sk_queue_drop_skb(struct sock *sk, struct sk_buff_head *sk_queue,
-			struct sk_buff *skb, unsigned int flags,
+			struct sk_buff **pskb, unsigned int flags,
 			void (*destructor)(struct sock *sk,
 					   struct sk_buff *skb))
 {
 	int err = 0;
 
 	if (flags & MSG_PEEK) {
+		struct sk_buff *skb = *pskb;
+
 		err = -ENOENT;
 		spin_lock_bh(&sk_queue->lock);
-		if (skb == skb_peek(sk_queue)) {
-			__skb_unlink(skb, sk_queue);
-			refcount_dec(&skb->users);
-			if (destructor)
-				destructor(sk, skb);
-			err = 0;
+		refcount_dec(&skb->users);
+		*pskb = NULL;
+		if (refcount_dec_if_one(&skb->users)) {
+			if (skb->next) {
+				__skb_unlink(skb, sk_queue);
+				if (destructor)
+					destructor(sk, skb);
+				err = 0;
+			}
+			__kfree_skb(skb);
 		}
 		spin_unlock_bh(&sk_queue->lock);
 	}
@@ -400,7 +406,7 @@ EXPORT_SYMBOL(__sk_queue_drop_skb);
 
 int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 {
-	int err = __sk_queue_drop_skb(sk, &sk->sk_receive_queue, skb, flags,
+	int err = __sk_queue_drop_skb(sk, &sk->sk_receive_queue, &skb, flags,
 				      NULL);
 
 	kfree_skb(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd1d044a7fa5..b5f90b845a6f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1648,7 +1648,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	return err;
 
 csum_copy_err:
-	if (!__sk_queue_drop_skb(sk, &udp_sk(sk)->reader_queue, skb, flags,
+	if (!__sk_queue_drop_skb(sk, &udp_sk(sk)->reader_queue, &skb, flags,
 				 udp_skb_destructor)) {
 		UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
 		UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 20039c8501eb..214a973571fd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -465,7 +465,7 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	return err;
 
 csum_copy_err:
-	if (!__sk_queue_drop_skb(sk, &udp_sk(sk)->reader_queue, skb, flags,
+	if (!__sk_queue_drop_skb(sk, &udp_sk(sk)->reader_queue, &skb, flags,
 				 udp_skb_destructor)) {
 		if (is_udp4) {
 			UDP_INC_STATS(sock_net(sk),
