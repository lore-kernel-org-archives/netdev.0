From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH 01/02] core: enable more fine-grained datagram reception control
Date: Sun, 06 Dec 2015 21:11:34 +0000
Message-ID: <874mfv7055.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:51845 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754281AbbLFVLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 16:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __skb_recv_datagram routine in core/ datagram.c provides a general
skb reception factility supposed to be utilized by protocol modules
providing datagram sockets. It encompasses both the actual recvmsg code
and a surrounding 'sleep until data is available' loop. This is
inconvenient if a protocol module has to use additional locking in order
to maintain some per-socket state the generic datagram socket code is
unaware of (as the af_unix code does). The patch below moves the recvmsg
proper code into a new __skb_try_recv_datagram routine which doesn't
sleep and renames wait_for_more_packets to
__skb_wait_for_more_packets, both routines being exported interfaces. The
original __skb_recv_datagram routine is reimplemented on top of these
two functions such that its user-visible behaviour remains unchanged.

Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4355129..dce91ac 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2788,6 +2788,12 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
 #define skb_walk_frags(skb, iter)	\
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
+
+int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
+				const struct sk_buff *skb);
+struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned flags,
+					int *peeked, int *off, int *err,
+					struct sk_buff **last);
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
 				    int *peeked, int *off, int *err);
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
diff --git a/net/core/datagram.c b/net/core/datagram.c
index d62af69..7daff66 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -83,8 +83,8 @@ static int receiver_wake_function(wait_queue_t *wait, unsigned int mode, int syn
 /*
  * Wait for the last received packet to be different from skb
  */
-static int wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
-				 const struct sk_buff *skb)
+int __skb_wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
+				const struct sk_buff *skb)
 {
 	int error;
 	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
@@ -130,6 +130,7 @@ out_noerr:
 	error = 1;
 	goto out;
 }
+EXPORT_SYMBOL(__skb_wait_for_more_packets);
 
 static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
 {
@@ -161,13 +162,15 @@ done:
 }
 
 /**
- *	__skb_recv_datagram - Receive a datagram skbuff
+ *	__skb_try_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
  *	@flags: MSG_ flags
  *	@peeked: returns non-zero if this packet has been seen before
  *	@off: an offset in bytes to peek skb from. Returns an offset
  *	      within an skb where data actually starts
  *	@err: error code returned
+ *	@last: set to last peeked message to inform the wait function
+ *	       what to look for when peeking
  *
  *	Get a datagram skbuff, understands the peeking, nonblocking wakeups
  *	and possible races. This replaces identical code in packet, raw and
@@ -175,9 +178,11 @@ done:
  *	the long standing peek and read race for datagram sockets. If you
  *	alter this routine remember it must be re-entrant.
  *
- *	This function will lock the socket if a skb is returned, so the caller
- *	needs to unlock the socket in that case (usually by calling
- *	skb_free_datagram)
+ *	This function will lock the socket if a skb is returned, so
+ *	the caller needs to unlock the socket in that case (usually by
+ *	calling skb_free_datagram). Returns NULL with *err set to
+ *	-EAGAIN if no data was available or to some other value if an
+ *	error was detected.
  *
  *	* It does not lock socket since today. This function is
  *	* free of race conditions. This measure should/can improve
@@ -191,13 +196,13 @@ done:
  *	quite explicitly by POSIX 1003.1g, don't change them without having
  *	the standard around please.
  */
-struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
-				    int *peeked, int *off, int *err)
+struct sk_buff *__skb_try_recv_datagram(struct sock *sk, unsigned int flags,
+					int *peeked, int *off, int *err,
+					struct sk_buff **last)
 {
 	struct sk_buff_head *queue = &sk->sk_receive_queue;
-	struct sk_buff *skb, *last;
+	struct sk_buff *skb;
 	unsigned long cpu_flags;
-	long timeo;
 	/*
 	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
 	 */
@@ -206,8 +211,6 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 	if (error)
 		goto no_packet;
 
-	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
-
 	do {
 		/* Again only user level code calls this function, so nothing
 		 * interrupt level will suddenly eat the receive_queue.
@@ -217,10 +220,10 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		 */
 		int _off = *off;
 
-		last = (struct sk_buff *)queue;
+		*last = (struct sk_buff *)queue;
 		spin_lock_irqsave(&queue->lock, cpu_flags);
 		skb_queue_walk(queue, skb) {
-			last = skb;
+			*last = skb;
 			*peeked = skb->peeked;
 			if (flags & MSG_PEEK) {
 				if (_off >= skb->len && (skb->len || _off ||
@@ -231,8 +234,11 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 
 				skb = skb_set_peeked(skb);
 				error = PTR_ERR(skb);
-				if (IS_ERR(skb))
-					goto unlock_err;
+				if (IS_ERR(skb)) {
+					spin_unlock_irqrestore(&queue->lock,
+							       cpu_flags);
+					goto no_packet;
+				}
 
 				atomic_inc(&skb->users);
 			} else
@@ -242,25 +248,38 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 			*off = _off;
 			return skb;
 		}
+
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
+	} while (sk_can_busy_loop(sk) &&
+		 sk_busy_loop(sk, flags & MSG_DONTWAIT));
 
-		if (sk_can_busy_loop(sk) &&
-		    sk_busy_loop(sk, flags & MSG_DONTWAIT))
-			continue;
+	error = -EAGAIN;
 
-		/* User doesn't want to wait */
-		error = -EAGAIN;
-		if (!timeo)
-			goto no_packet;
+no_packet:
+	*err = error;
+	return NULL;
+}
+EXPORT_SYMBOL(__skb_try_recv_datagram);
 
-	} while (!wait_for_more_packets(sk, err, &timeo, last));
+struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
+				    int *peeked, int *off, int *err)
+{
+	struct sk_buff *skb, *last;
+	long timeo;
 
-	return NULL;
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+
+	do {
+		skb = __skb_try_recv_datagram(sk, flags, peeked, off, err,
+					      &last);
+		if (skb)
+			return skb;
+
+		if (*err != EAGAIN)
+			break;
+	} while (timeo &&
+		!__skb_wait_for_more_packets(sk, err, &timeo, last));
 
-unlock_err:
-	spin_unlock_irqrestore(&queue->lock, cpu_flags);
-no_packet:
-	*err = error;
 	return NULL;
 }
 EXPORT_SYMBOL(__skb_recv_datagram);
