From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and
 'bindlock'
Date: Fri, 2 Sep 2016 11:13:09 -0700 (PDT)
Message-ID: <alpine.LFD.2.20.1609021109340.4072@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Dumazet <edumazet@google.com>, willy tarreau <w@1wt.eu>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34031 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbcIBSNL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:13:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so6087549pfb.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 11:13:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 1 Sep 2016 14:43:53 -0700
Subject: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and 'bindlock'

Right now we use the 'readlock' both for protecting some of the af_unix
IO path and for making the bind be single-threaded.

The two are independent, but using the same lock makes for a nasty
deadlock due to ordering with regards to filesystem locking.  The bind
locking would want to nest outside the VSF pathname locking, but the IO
locking wants to nest inside some of those same locks.

We tried to fix this earlier with commit c845acb324aa ("af_unix: Fix
splice-bind deadlock") which moved the readlock inside the vfs locks,
but that caused problems with overlayfs that will then call back into
filesystem routines that take the lock in the wrong order anyway.

Splitting the locks means that we can go back to having the bind lock be
the outermost lock, and we don't have any deadlocks with lock ordering.

Acked-by: Rainer Weikusat <rweikusat@cyberadapt.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---

This patch is really trivial, and I've tried to be careful and look at the 
locking, but somebody who really knows the AF_UNIX code should definitely 
take a second look.

Note that I did the revert (that re-introduces the original splice 
deadlock) first, because that made the whole series much easier to 
explain. Doing it in the other order made the revert nastier because this 
patch obviously touches the same code that the revert in 1/2 does.

So this way the series ends up being "go back to the original code with 
the original deadlock, and then fix that original deadlock by splitting 
the bind lock".

 include/net/af_unix.h |  2 +-
 net/unix/af_unix.c    | 45 +++++++++++++++++++++++----------------------
 2 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 9b4c418bebd8..fd60eccb59a6 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -52,7 +52,7 @@ struct unix_sock {
 	struct sock		sk;
 	struct unix_address     *addr;
 	struct path		path;
-	struct mutex		readlock;
+	struct mutex		iolock, bindlock;
 	struct sock		*peer;
 	struct list_head	link;
 	atomic_long_t		inflight;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 433ae1bbef97..8309687a56b0 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -661,11 +661,11 @@ static int unix_set_peek_off(struct sock *sk, int val)
 {
 	struct unix_sock *u = unix_sk(sk);
 
-	if (mutex_lock_interruptible(&u->readlock))
+	if (mutex_lock_interruptible(&u->iolock))
 		return -EINTR;
 
 	sk->sk_peek_off = val;
-	mutex_unlock(&u->readlock);
+	mutex_unlock(&u->iolock);
 
 	return 0;
 }
@@ -779,7 +779,8 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	spin_lock_init(&u->lock);
 	atomic_long_set(&u->inflight, 0);
 	INIT_LIST_HEAD(&u->link);
-	mutex_init(&u->readlock); /* single task reading lock */
+	mutex_init(&u->iolock); /* single task reading lock */
+	mutex_init(&u->bindlock); /* single task binding lock */
 	init_waitqueue_head(&u->peer_wait);
 	init_waitqueue_func_entry(&u->peer_wake, unix_dgram_peer_wake_relay);
 	unix_insert_socket(unix_sockets_unbound(sk), sk);
@@ -848,7 +849,7 @@ static int unix_autobind(struct socket *sock)
 	int err;
 	unsigned int retries = 0;
 
-	err = mutex_lock_interruptible(&u->readlock);
+	err = mutex_lock_interruptible(&u->bindlock);
 	if (err)
 		return err;
 
@@ -895,7 +896,7 @@ retry:
 	spin_unlock(&unix_table_lock);
 	err = 0;
 
-out:	mutex_unlock(&u->readlock);
+out:	mutex_unlock(&u->bindlock);
 	return err;
 }
 
@@ -1009,7 +1010,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
-	err = mutex_lock_interruptible(&u->readlock);
+	err = mutex_lock_interruptible(&u->bindlock);
 	if (err)
 		goto out;
 
@@ -1063,7 +1064,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 out_unlock:
 	spin_unlock(&unix_table_lock);
 out_up:
-	mutex_unlock(&u->readlock);
+	mutex_unlock(&u->bindlock);
 out:
 	return err;
 }
@@ -1955,17 +1956,17 @@ static ssize_t unix_stream_sendpage(struct socket *socket, struct page *page,
 	if (false) {
 alloc_skb:
 		unix_state_unlock(other);
-		mutex_unlock(&unix_sk(other)->readlock);
+		mutex_unlock(&unix_sk(other)->iolock);
 		newskb = sock_alloc_send_pskb(sk, 0, 0, flags & MSG_DONTWAIT,
 					      &err, 0);
 		if (!newskb)
 			goto err;
 	}
 
-	/* we must acquire readlock as we modify already present
+	/* we must acquire iolock as we modify already present
 	 * skbs in the sk_receive_queue and mess with skb->len
 	 */
-	err = mutex_lock_interruptible(&unix_sk(other)->readlock);
+	err = mutex_lock_interruptible(&unix_sk(other)->iolock);
 	if (err) {
 		err = flags & MSG_DONTWAIT ? -EAGAIN : -ERESTARTSYS;
 		goto err;
@@ -2032,7 +2033,7 @@ alloc_skb:
 	}
 
 	unix_state_unlock(other);
-	mutex_unlock(&unix_sk(other)->readlock);
+	mutex_unlock(&unix_sk(other)->iolock);
 
 	other->sk_data_ready(other);
 	scm_destroy(&scm);
@@ -2041,7 +2042,7 @@ alloc_skb:
 err_state_unlock:
 	unix_state_unlock(other);
 err_unlock:
-	mutex_unlock(&unix_sk(other)->readlock);
+	mutex_unlock(&unix_sk(other)->iolock);
 err:
 	kfree_skb(newskb);
 	if (send_sigpipe && !(flags & MSG_NOSIGNAL))
@@ -2109,7 +2110,7 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
 	do {
-		mutex_lock(&u->readlock);
+		mutex_lock(&u->iolock);
 
 		skip = sk_peek_offset(sk, flags);
 		skb = __skb_try_recv_datagram(sk, flags, &peeked, &skip, &err,
@@ -2117,14 +2118,14 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 		if (skb)
 			break;
 
-		mutex_unlock(&u->readlock);
+		mutex_unlock(&u->iolock);
 
 		if (err != -EAGAIN)
 			break;
 	} while (timeo &&
 		 !__skb_wait_for_more_packets(sk, &err, &timeo, last));
 
-	if (!skb) { /* implies readlock unlocked */
+	if (!skb) { /* implies iolock unlocked */
 		unix_state_lock(sk);
 		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
 		if (sk->sk_type == SOCK_SEQPACKET && err == -EAGAIN &&
@@ -2189,7 +2190,7 @@ static int unix_dgram_recvmsg(struct socket *sock, struct msghdr *msg,
 
 out_free:
 	skb_free_datagram(sk, skb);
-	mutex_unlock(&u->readlock);
+	mutex_unlock(&u->iolock);
 out:
 	return err;
 }
@@ -2284,7 +2285,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 	/* Lock the socket to prevent queue disordering
 	 * while sleeps in memcpy_tomsg
 	 */
-	mutex_lock(&u->readlock);
+	mutex_lock(&u->iolock);
 
 	if (flags & MSG_PEEK)
 		skip = sk_peek_offset(sk, flags);
@@ -2326,7 +2327,7 @@ again:
 				break;
 			}
 
-			mutex_unlock(&u->readlock);
+			mutex_unlock(&u->iolock);
 
 			timeo = unix_stream_data_wait(sk, timeo, last,
 						      last_len);
@@ -2337,7 +2338,7 @@ again:
 				goto out;
 			}
 
-			mutex_lock(&u->readlock);
+			mutex_lock(&u->iolock);
 			goto redo;
 unlock:
 			unix_state_unlock(sk);
@@ -2440,7 +2441,7 @@ unlock:
 		}
 	} while (size);
 
-	mutex_unlock(&u->readlock);
+	mutex_unlock(&u->iolock);
 	if (state->msg)
 		scm_recv(sock, state->msg, &scm, flags);
 	else
@@ -2481,9 +2482,9 @@ static ssize_t skb_unix_socket_splice(struct sock *sk,
 	int ret;
 	struct unix_sock *u = unix_sk(sk);
 
-	mutex_unlock(&u->readlock);
+	mutex_unlock(&u->iolock);
 	ret = splice_to_pipe(pipe, spd);
-	mutex_lock(&u->readlock);
+	mutex_lock(&u->iolock);
 
 	return ret;
 }
-- 
2.10.0.rc0.2.g0a9fa47
