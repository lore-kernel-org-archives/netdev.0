From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH net 3/3] unix/stream: fix peeking with an offset larger than data in queue
Date: Thu, 25 Apr 2013 09:47:18 -0400
Message-ID: <1366897638-21882-3-git-send-email-bpoirier@suse.de>
References: <1366897638-21882-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366897638-21882-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, peeking on a unix stream socket with an offset larger than len of
the data in the sk receive queue returns immediately with bogus data.

This patch fixes this so that the behavior is the same as peeking with no
offset on an empty queue: the caller blocks.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 net/unix/af_unix.c |   25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2db702d..1a02af0 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1859,10 +1859,10 @@ out:
 }
 
 /*
- *	Sleep until data has arrive. But check for races..
+ *	Sleep until more data has arrived. But check for races..
  */
-
-static long unix_stream_data_wait(struct sock *sk, long timeo)
+static long unix_stream_data_wait(struct sock *sk, long timeo,
+				  struct sk_buff *last)
 {
 	DEFINE_WAIT(wait);
 
@@ -1871,7 +1871,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo)
 	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
-		if (!skb_queue_empty(&sk->sk_receive_queue) ||
+		if (skb_peek_tail(&sk->sk_receive_queue) != last ||
 		    sk->sk_err ||
 		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current) ||
@@ -1890,8 +1890,6 @@ static long unix_stream_data_wait(struct sock *sk, long timeo)
 	return timeo;
 }
 
-
-
 static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size,
 			       int flags)
@@ -1936,14 +1934,12 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 	}
 
-	skip = sk_peek_offset(sk, flags);
-
 	do {
 		int chunk;
-		struct sk_buff *skb;
+		struct sk_buff *skb, *last;
 
 		unix_state_lock(sk);
-		skb = skb_peek(&sk->sk_receive_queue);
+		last = skb = skb_peek(&sk->sk_receive_queue);
 again:
 		if (skb == NULL) {
 			unix_sk(sk)->recursion_level = 0;
@@ -1966,7 +1962,7 @@ again:
 				break;
 			mutex_unlock(&u->readlock);
 
-			timeo = unix_stream_data_wait(sk, timeo);
+			timeo = unix_stream_data_wait(sk, timeo, last);
 
 			if (signal_pending(current)
 			    ||  mutex_lock_interruptible(&u->readlock)) {
@@ -1980,10 +1976,13 @@ again:
 			break;
 		}
 
-		if (skip >= skb->len) {
+		skip = sk_peek_offset(sk, flags);
+		while (skip >= skb->len) {
 			skip -= skb->len;
+			last = skb;
 			skb = skb_peek_next(skb, &sk->sk_receive_queue);
-			goto again;
+			if (!skb)
+				goto again;
 		}
 
 		unix_state_unlock(sk);
-- 
1.7.10.4
