From: David Miller <davem@davemloft.net>
Subject: Re: [Oops] unix_dgram_connect locking problem?
Date: Thu, 31 May 2007 15:22:27 -0700 (PDT)
Message-ID: <20070531.152227.53338417.davem@davemloft.net>
References: <20070511150014.GF23638@slug>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eparis@redhat.com
To: deweerdt@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47775
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbXEaWWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 18:22:14 -0400
In-Reply-To: <20070511150014.GF23638@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frederik Deweerdt <deweerdt@free.fr>
Date: Fri, 11 May 2007 17:00:14 +0200

> I'm seeing an Oops[1] with a 2.6.19.2 kernel:

Frederik, I finally was able to spend some quality time on
this issue today.  Sorry for taking so long.

I came up with a series of two patches, the first one makes
the locking easier to understand by fixing the unix_sock_*()
lock macro names.

The second patch fixes this race conditon by properly holding
both socket locks, being careful to avoid deadlocks, and
checking for possible SOCK_DEAD state.

--------------------
commit d410b81b4eef2e4409f9c38ef201253fbbcc7d94
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu May 31 13:24:26 2007 -0700

    [AF_UNIX]: Make socket locking much less confusing.
    
    The unix_state_*() locking macros imply that there is some
    rwlock kind of thing going on, but the implementation is
    actually a spinlock which makes the code more confusing than
    it needs to be.
    
    So use plain unix_state_lock and unix_state_unlock.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index c0398f5..65f49fd 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -62,13 +62,11 @@ struct unix_skb_parms {
 #define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
 #define UNIXSID(skb)	(&UNIXCB((skb)).secid)
 
-#define unix_state_rlock(s)	spin_lock(&unix_sk(s)->lock)
-#define unix_state_runlock(s)	spin_unlock(&unix_sk(s)->lock)
-#define unix_state_wlock(s)	spin_lock(&unix_sk(s)->lock)
-#define unix_state_wlock_nested(s) \
+#define unix_state_lock(s)	spin_lock(&unix_sk(s)->lock)
+#define unix_state_unlock(s)	spin_unlock(&unix_sk(s)->lock)
+#define unix_state_lock_nested(s) \
 				spin_lock_nested(&unix_sk(s)->lock, \
 				SINGLE_DEPTH_NESTING)
-#define unix_state_wunlock(s)	spin_unlock(&unix_sk(s)->lock)
 
 #ifdef __KERNEL__
 /* The AF_UNIX socket */
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fc12ba5..453ede8 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -174,11 +174,11 @@ static struct sock *unix_peer_get(struct sock *s)
 {
 	struct sock *peer;
 
-	unix_state_rlock(s);
+	unix_state_lock(s);
 	peer = unix_peer(s);
 	if (peer)
 		sock_hold(peer);
-	unix_state_runlock(s);
+	unix_state_unlock(s);
 	return peer;
 }
 
@@ -369,7 +369,7 @@ static int unix_release_sock (struct sock *sk, int embrion)
 	unix_remove_socket(sk);
 
 	/* Clear state */
-	unix_state_wlock(sk);
+	unix_state_lock(sk);
 	sock_orphan(sk);
 	sk->sk_shutdown = SHUTDOWN_MASK;
 	dentry	     = u->dentry;
@@ -378,7 +378,7 @@ static int unix_release_sock (struct sock *sk, int embrion)
 	u->mnt	     = NULL;
 	state = sk->sk_state;
 	sk->sk_state = TCP_CLOSE;
-	unix_state_wunlock(sk);
+	unix_state_unlock(sk);
 
 	wake_up_interruptible_all(&u->peer_wait);
 
@@ -386,12 +386,12 @@ static int unix_release_sock (struct sock *sk, int embrion)
 
 	if (skpair!=NULL) {
 		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
-			unix_state_wlock(skpair);
+			unix_state_lock(skpair);
 			/* No more writes */
 			skpair->sk_shutdown = SHUTDOWN_MASK;
 			if (!skb_queue_empty(&sk->sk_receive_queue) || embrion)
 				skpair->sk_err = ECONNRESET;
-			unix_state_wunlock(skpair);
+			unix_state_unlock(skpair);
 			skpair->sk_state_change(skpair);
 			read_lock(&skpair->sk_callback_lock);
 			sk_wake_async(skpair,1,POLL_HUP);
@@ -448,7 +448,7 @@ static int unix_listen(struct socket *sock, int backlog)
 	err = -EINVAL;
 	if (!u->addr)
 		goto out;			/* No listens on an unbound socket */
-	unix_state_wlock(sk);
+	unix_state_lock(sk);
 	if (sk->sk_state != TCP_CLOSE && sk->sk_state != TCP_LISTEN)
 		goto out_unlock;
 	if (backlog > sk->sk_max_ack_backlog)
@@ -462,7 +462,7 @@ static int unix_listen(struct socket *sock, int backlog)
 	err = 0;
 
 out_unlock:
-	unix_state_wunlock(sk);
+	unix_state_unlock(sk);
 out:
 	return err;
 }
@@ -881,7 +881,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 		if (!other)
 			goto out;
 
-		unix_state_wlock(sk);
+		unix_state_lock(sk);
 
 		err = -EPERM;
 		if (!unix_may_send(sk, other))
@@ -896,7 +896,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 		 *	1003.1g breaking connected state with AF_UNSPEC
 		 */
 		other = NULL;
-		unix_state_wlock(sk);
+		unix_state_lock(sk);
 	}
 
 	/*
@@ -905,19 +905,19 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk)=other;
-		unix_state_wunlock(sk);
+		unix_state_unlock(sk);
 
 		if (other != old_peer)
 			unix_dgram_disconnected(sk, old_peer);
 		sock_put(old_peer);
 	} else {
 		unix_peer(sk)=other;
-		unix_state_wunlock(sk);
+		unix_state_unlock(sk);
 	}
 	return 0;
 
 out_unlock:
-	unix_state_wunlock(sk);
+	unix_state_unlock(sk);
 	sock_put(other);
 out:
 	return err;
@@ -936,7 +936,7 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 		(skb_queue_len(&other->sk_receive_queue) >
 		 other->sk_max_ack_backlog);
 
-	unix_state_runlock(other);
+	unix_state_unlock(other);
 
 	if (sched)
 		timeo = schedule_timeout(timeo);
@@ -994,11 +994,11 @@ restart:
 		goto out;
 
 	/* Latch state of peer */
-	unix_state_rlock(other);
+	unix_state_lock(other);
 
 	/* Apparently VFS overslept socket death. Retry. */
 	if (sock_flag(other, SOCK_DEAD)) {
-		unix_state_runlock(other);
+		unix_state_unlock(other);
 		sock_put(other);
 		goto restart;
 	}
@@ -1048,18 +1048,18 @@ restart:
 		goto out_unlock;
 	}
 
-	unix_state_wlock_nested(sk);
+	unix_state_lock_nested(sk);
 
 	if (sk->sk_state != st) {
-		unix_state_wunlock(sk);
-		unix_state_runlock(other);
+		unix_state_unlock(sk);
+		unix_state_unlock(other);
 		sock_put(other);
 		goto restart;
 	}
 
 	err = security_unix_stream_connect(sock, other->sk_socket, newsk);
 	if (err) {
-		unix_state_wunlock(sk);
+		unix_state_unlock(sk);
 		goto out_unlock;
 	}
 
@@ -1096,7 +1096,7 @@ restart:
 	smp_mb__after_atomic_inc();	/* sock_hold() does an atomic_inc() */
 	unix_peer(sk)	= newsk;
 
-	unix_state_wunlock(sk);
+	unix_state_unlock(sk);
 
 	/* take ten and and send info to listening sock */
 	spin_lock(&other->sk_receive_queue.lock);
@@ -1105,14 +1105,14 @@ restart:
 	 * is installed to listening socket. */
 	atomic_inc(&newu->inflight);
 	spin_unlock(&other->sk_receive_queue.lock);
-	unix_state_runlock(other);
+	unix_state_unlock(other);
 	other->sk_data_ready(other, 0);
 	sock_put(other);
 	return 0;
 
 out_unlock:
 	if (other)
-		unix_state_runlock(other);
+		unix_state_unlock(other);
 
 out:
 	if (skb)
@@ -1178,10 +1178,10 @@ static int unix_accept(struct socket *sock, struct socket *newsock, int flags)
 	wake_up_interruptible(&unix_sk(sk)->peer_wait);
 
 	/* attach accepted sock to socket */
-	unix_state_wlock(tsk);
+	unix_state_lock(tsk);
 	newsock->state = SS_CONNECTED;
 	sock_graft(tsk, newsock);
-	unix_state_wunlock(tsk);
+	unix_state_unlock(tsk);
 	return 0;
 
 out:
@@ -1208,7 +1208,7 @@ static int unix_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_
 	}
 
 	u = unix_sk(sk);
-	unix_state_rlock(sk);
+	unix_state_lock(sk);
 	if (!u->addr) {
 		sunaddr->sun_family = AF_UNIX;
 		sunaddr->sun_path[0] = 0;
@@ -1219,7 +1219,7 @@ static int unix_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_
 		*uaddr_len = addr->len;
 		memcpy(sunaddr, addr->name, *uaddr_len);
 	}
-	unix_state_runlock(sk);
+	unix_state_unlock(sk);
 	sock_put(sk);
 out:
 	return err;
@@ -1337,7 +1337,7 @@ restart:
 			goto out_free;
 	}
 
-	unix_state_rlock(other);
+	unix_state_lock(other);
 	err = -EPERM;
 	if (!unix_may_send(sk, other))
 		goto out_unlock;
@@ -1347,20 +1347,20 @@ restart:
 		 *	Check with 1003.1g - what should
 		 *	datagram error
 		 */
-		unix_state_runlock(other);
+		unix_state_unlock(other);
 		sock_put(other);
 
 		err = 0;
-		unix_state_wlock(sk);
+		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk)=NULL;
-			unix_state_wunlock(sk);
+			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
 			sock_put(other);
 			err = -ECONNREFUSED;
 		} else {
-			unix_state_wunlock(sk);
+			unix_state_unlock(sk);
 		}
 
 		other = NULL;
@@ -1397,14 +1397,14 @@ restart:
 	}
 
 	skb_queue_tail(&other->sk_receive_queue, skb);
-	unix_state_runlock(other);
+	unix_state_unlock(other);
 	other->sk_data_ready(other, len);
 	sock_put(other);
 	scm_destroy(siocb->scm);
 	return len;
 
 out_unlock:
-	unix_state_runlock(other);
+	unix_state_unlock(other);
 out_free:
 	kfree_skb(skb);
 out:
@@ -1494,14 +1494,14 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out_err;
 		}
 
-		unix_state_rlock(other);
+		unix_state_lock(other);
 
 		if (sock_flag(other, SOCK_DEAD) ||
 		    (other->sk_shutdown & RCV_SHUTDOWN))
 			goto pipe_err_free;
 
 		skb_queue_tail(&other->sk_receive_queue, skb);
-		unix_state_runlock(other);
+		unix_state_unlock(other);
 		other->sk_data_ready(other, size);
 		sent+=size;
 	}
@@ -1512,7 +1512,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	return sent;
 
 pipe_err_free:
-	unix_state_runlock(other);
+	unix_state_unlock(other);
 	kfree_skb(skb);
 pipe_err:
 	if (sent==0 && !(msg->msg_flags&MSG_NOSIGNAL))
@@ -1641,7 +1641,7 @@ static long unix_stream_data_wait(struct sock * sk, long timeo)
 {
 	DEFINE_WAIT(wait);
 
-	unix_state_rlock(sk);
+	unix_state_lock(sk);
 
 	for (;;) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -1654,14 +1654,14 @@ static long unix_stream_data_wait(struct sock * sk, long timeo)
 			break;
 
 		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
-		unix_state_runlock(sk);
+		unix_state_unlock(sk);
 		timeo = schedule_timeout(timeo);
-		unix_state_rlock(sk);
+		unix_state_lock(sk);
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	}
 
 	finish_wait(sk->sk_sleep, &wait);
-	unix_state_runlock(sk);
+	unix_state_unlock(sk);
 	return timeo;
 }
 
@@ -1816,12 +1816,12 @@ static int unix_shutdown(struct socket *sock, int mode)
 	mode = (mode+1)&(RCV_SHUTDOWN|SEND_SHUTDOWN);
 
 	if (mode) {
-		unix_state_wlock(sk);
+		unix_state_lock(sk);
 		sk->sk_shutdown |= mode;
 		other=unix_peer(sk);
 		if (other)
 			sock_hold(other);
-		unix_state_wunlock(sk);
+		unix_state_unlock(sk);
 		sk->sk_state_change(sk);
 
 		if (other &&
@@ -1833,9 +1833,9 @@ static int unix_shutdown(struct socket *sock, int mode)
 				peer_mode |= SEND_SHUTDOWN;
 			if (mode&SEND_SHUTDOWN)
 				peer_mode |= RCV_SHUTDOWN;
-			unix_state_wlock(other);
+			unix_state_lock(other);
 			other->sk_shutdown |= peer_mode;
-			unix_state_wunlock(other);
+			unix_state_unlock(other);
 			other->sk_state_change(other);
 			read_lock(&other->sk_callback_lock);
 			if (peer_mode == SHUTDOWN_MASK)
@@ -1973,7 +1973,7 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct sock *s = v;
 		struct unix_sock *u = unix_sk(s);
-		unix_state_rlock(s);
+		unix_state_lock(s);
 
 		seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
 			s,
@@ -2001,7 +2001,7 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 			for ( ; i < len; i++)
 				seq_putc(seq, u->addr->name->sun_path[i]);
 		}
-		unix_state_runlock(s);
+		unix_state_unlock(s);
 		seq_putc(seq, '\n');
 	}
 
--------------------
commit 19fec3e807a487415e77113cb9dbdaa2da739836
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu May 31 15:19:20 2007 -0700

    [AF_UNIX]: Fix datagram connect race causing an OOPS.
    
    Based upon an excellent bug report and initial patch by
    Frederik Deweerdt.
    
    The UNIX datagram connect code blindly dereferences other->sk_socket
    via the call down to the security_unix_may_send() function.
    
    Without locking 'other' that pointer can go NULL via unix_release_sock()
    which does sock_orphan() which also marks the socket SOCK_DEAD.
    
    So we have to lock both 'sk' and 'other' yet avoid all kinds of
    potential deadlocks (connect to self is OK for datagram sockets and it
    is possible for two datagram sockets to perform a simultaneous connect
    to each other).  So what we do is have a "double lock" function similar
    to how we handle this situation in other areas of the kernel.  We take
    the lock of the socket pointer with the smallest address first in
    order to avoid ABBA style deadlocks.
    
    Once we have them both locked, we check to see if SOCK_DEAD is set
    for 'other' and if so, drop everything and retry the lookup.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 453ede8..87c794d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -858,6 +858,31 @@ out_mknod_parent:
 	goto out_up;
 }
 
+static void unix_state_double_lock(struct sock *sk1, struct sock *sk2)
+{
+	if (unlikely(sk1 == sk2) || !sk2) {
+		unix_state_lock(sk1);
+		return;
+	}
+	if (sk1 < sk2) {
+		unix_state_lock(sk1);
+		unix_state_lock_nested(sk2);
+	} else {
+		unix_state_lock(sk2);
+		unix_state_lock_nested(sk1);
+	}
+}
+
+static void unix_state_double_unlock(struct sock *sk1, struct sock *sk2)
+{
+	if (unlikely(sk1 == sk2) || !sk2) {
+		unix_state_unlock(sk1);
+		return;
+	}
+	unix_state_unlock(sk1);
+	unix_state_unlock(sk2);
+}
+
 static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			      int alen, int flags)
 {
@@ -877,11 +902,19 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 		    !unix_sk(sk)->addr && (err = unix_autobind(sock)) != 0)
 			goto out;
 
+restart:
 		other=unix_find_other(sunaddr, alen, sock->type, hash, &err);
 		if (!other)
 			goto out;
 
-		unix_state_lock(sk);
+		unix_state_double_lock(sk, other);
+
+		/* Apparently VFS overslept socket death. Retry. */
+		if (sock_flag(other, SOCK_DEAD)) {
+			unix_state_double_unlock(sk, other);
+			sock_put(other);
+			goto restart;
+		}
 
 		err = -EPERM;
 		if (!unix_may_send(sk, other))
@@ -896,7 +929,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 		 *	1003.1g breaking connected state with AF_UNSPEC
 		 */
 		other = NULL;
-		unix_state_lock(sk);
+		unix_state_double_lock(sk, other);
 	}
 
 	/*
@@ -905,19 +938,19 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk)=other;
-		unix_state_unlock(sk);
+		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
 			unix_dgram_disconnected(sk, old_peer);
 		sock_put(old_peer);
 	} else {
 		unix_peer(sk)=other;
-		unix_state_unlock(sk);
+		unix_state_double_unlock(sk, other);
 	}
 	return 0;
 
 out_unlock:
-	unix_state_unlock(sk);
+	unix_state_double_unlock(sk, other);
 	sock_put(other);
 out:
 	return err;
--------------------
