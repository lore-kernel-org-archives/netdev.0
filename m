From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [RFC] unix: fix use-after-free in unix_dgram_poll()
Date: Wed, 28 Oct 2015 16:46:38 +0000
Message-ID: <874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<5612B9A9.8050301@akamai.com>
	<87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
	<561DCFA4.3010300@akamai.com>
	<87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
	<561F156E.9050905@akamai.com>
	<87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
	<5625073C.5010809@akamai.com>
	<87vba1i383.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vba1i383.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Tue, 20 Oct 2015 23:29:00 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Weikusat <rw@doppelsaurus.mobileactivedefense.com> writes:
> Jason Baron <jbaron@akamai.com> writes:

[...]

>> 2)
>>
>> For the case of epoll() in edge triggered mode we need to ensure that
>> when we return -EAGAIN from unix_dgram_sendmsg() when unix_recvq_full()
>> is true, we need to add a unix_peer_wake_connect() call to guarantee a
>> wakeup. Otherwise, we are going to potentially hang there.
>
> I consider this necessary.

(As already discussed privately) just doing this would open up another
way for sockets to be enqueued on the peer_wait queue of the peer
forever despite no one wants to be notified of write space
availability. Here's another RFC patch addressing the issues so far plus
this one by breaking the connection to the peer socket from the wake up
relaying function. This has the nice additional property that the
dgram_poll code becomes somewhat simpler as the "dequeued where we
didn't enqueue" situation can no longer occur and the not-so-nice
additional property that the connect and disconnect functions need to
take the peer_wait.lock spinlock explicitly so that this lock is used to
ensure that no two threads modifiy the private pointer of the client
wait_queue_t.

I've also moved the check, possibly enqueue then recheck and possibly
dequeue dance into a pair of functions as this code would be identical
for both unix_dgram_poll and unix_dgram_sendmsg (I'm not really happy
with the names, though).

---
--- linux-2-6.b/net/unix/af_unix.c	2015-10-28 16:06:29.581960497 +0000
+++ linux-2-6/net/unix/af_unix.c	2015-10-28 16:14:55.326065483 +0000
@@ -115,6 +115,8 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 
+#define POLL_OUT_ALL	(POLLOUT | POLLWRNORM | POLLWRBAND)
+
 static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 static DEFINE_SPINLOCK(unix_table_lock);
 static atomic_long_t unix_nr_socks;
@@ -303,6 +305,117 @@ found:
 	return s;
 }
 
+/*
+ * Support code for asymmetrically connected dgram sockets
+ *
+ * If a datagram socket is connected to a socket not itself connected
+ * to the first socket (eg, /dev/log), clients may only enqueue more
+ * messages if the present receive queue of the server socket is not
+ * "too large". This means there's a second writability condition poll
+ * and sendmsg need to test. The dgram recv code will do a wake up on
+ * the peer_wait wait queue of a socket upon reception of a datagram
+ * which needs to be propagated to sleeping writers since these might
+ * not yet have sent anything. This can't be accomplished via
+ * poll_wait because the lifetime of the server socket might be less
+ * than that of its clients if these break their association with it
+ * or if the server socket is closed while clients are still connected
+ * to it and there's no way to inform "a polling implementation" that
+ * it should let go of a certain wait queue
+ *
+ * In order to achieve wake up propagation, a wait_queue_t of the
+ * client socket is thus enqueued on the peer_wait queue of the server
+ * socket whose wake function does a wake_up on the ordinary client
+ * socket wait queue. This connection is established whenever a write
+ * (or poll for write) hit the flow control condition and broken when
+ * the connection to the server socket is dissolved or after a wake up
+ * was relayed.
+ */
+
+static int unix_dgram_peer_wake_relay(wait_queue_t *q, unsigned mode, int flags,
+				void *key)
+{
+	struct unix_sock *u;
+	wait_queue_head_t *u_sleep;
+
+	u = container_of(q, struct unix_sock, peer_wake);
+
+	__remove_wait_queue(&unix_sk(u->peer_wake.private)->peer_wait,
+			    &u->peer_wake);
+	u->peer_wake.private = NULL;
+
+	/* relaying can only happen while the wq still exists */
+	u_sleep = sk_sleep(&u->sk);
+	if (u_sleep)
+		wake_up_interruptible_poll(u_sleep, key);
+
+	return 0;
+}
+
+static int unix_dgram_peer_wake_connect(struct sock *sk, struct sock *other)
+{
+	struct unix_sock *u, *u_other;
+	int rc;
+
+	u = unix_sk(sk);
+	u_other = unix_sk(other);
+	rc = 0;
+
+	spin_lock(&u_other->peer_wait.lock);
+
+	if (!u->peer_wake.private) {
+		u->peer_wake.private = other;
+		__add_wait_queue(&u_other->peer_wait, &u->peer_wake);
+
+		rc = 1;
+	}
+
+	spin_unlock(&u_other->peer_wait.lock);
+	return rc;
+}
+
+static int unix_dgram_peer_wake_disconnect(struct sock *sk, struct sock *other)
+{
+	struct unix_sock *u, *u_other;
+	int rc;
+
+	u = unix_sk(sk);
+	u_other = unix_sk(other);
+	rc = 0;
+
+	spin_lock(&u_other->peer_wait.lock);
+
+	if (u->peer_wake.private == other) {
+		__remove_wait_queue(&u_other->peer_wait, &u->peer_wake);
+		u->peer_wake.private = NULL;
+
+		rc = 1;
+	}
+
+	spin_unlock(&u_other->peer_wait.lock);
+	return rc;
+}
+
+static inline int unix_dgram_peer_recvq_space(struct sock *sk,
+					      struct sock *other)
+{
+	return !(unix_peer(other) != sk && unix_recvq_full(other));
+}
+
+static int unix_dgram_peer_recv_wake_prep(struct sock *sk, struct sock *other)
+{
+	int queued;
+
+	queued = unix_dgram_peer_wake_connect(sk, other);
+
+	if (unix_recvq_full(other))
+		return 1;
+
+	if (queued)
+		unix_dgram_peer_wake_disconnect(sk, other);
+
+	return 0;
+}
+
 static inline int unix_writable(struct sock *sk)
 {
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
@@ -317,7 +430,7 @@ static void unix_write_space(struct sock
 		wq = rcu_dereference(sk->sk_wq);
 		if (wq_has_sleeper(wq))
 			wake_up_interruptible_sync_poll(&wq->wait,
-				POLLOUT | POLLWRNORM | POLLWRBAND);
+							POLL_OUT_ALL);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
 	rcu_read_unlock();
@@ -409,6 +522,8 @@ static void unix_release_sock(struct soc
 			skpair->sk_state_change(skpair);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
 		}
+
+		unix_dgram_peer_wake_disconnect(sk, skpair);
 		sock_put(skpair); /* It may now die */
 		unix_peer(sk) = NULL;
 	}
@@ -630,6 +745,7 @@ static struct sock *unix_create1(struct
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
+	init_waitqueue_func_entry(&u->peer_wake, unix_dgram_peer_wake_relay);
 	unix_insert_socket(unix_sockets_unbound, sk);
 out:
 	if (sk == NULL)
@@ -953,7 +1069,7 @@ static int unix_dgram_connect(struct soc
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
 	struct sock *other;
 	unsigned hash;
-	int err;
+	int err, disconned;
 
 	if (addr->sa_family != AF_UNSPEC) {
 		err = unix_mkname(sunaddr, alen, &hash);
@@ -1001,6 +1117,11 @@ restart:
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk) = other;
+
+		disconned = unix_dgram_peer_wake_disconnect(sk, other);
+		if (disconned)
+			wake_up_interruptible_poll(sk_sleep(sk), POLL_OUT_ALL);
+
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1439,7 +1560,7 @@ static int unix_dgram_sendmsg(struct kio
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
-	int max_level;
+	int max_level, disconned;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1525,6 +1646,12 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+
+			disconned = unix_dgram_peer_wake_disconnect(sk, other);
+			if (disconned)
+				wake_up_interruptible_poll(sk_sleep(sk),
+							POLL_OUT_ALL);
+
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -1550,8 +1677,8 @@ restart:
 			goto out_unlock;
 	}
 
-	if (unix_peer(other) != sk && unix_recvq_full(other)) {
-		if (!timeo) {
+	if (!unix_dgram_peer_recvq_space(sk, other)) {
+		if (!timeo && unix_dgram_peer_recv_wake_prep(sk, other)) {
 			err = -EAGAIN;
 			goto out_unlock;
 		}
@@ -1783,8 +1910,7 @@ static int unix_dgram_recvmsg(struct kio
 		goto out_unlock;
 	}
 
-	wake_up_interruptible_sync_poll(&u->peer_wait,
-					POLLOUT | POLLWRNORM | POLLWRBAND);
+	wake_up_interruptible_sync_poll(&u->peer_wait, POLL_OUT_ALL);
 
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);
@@ -2127,7 +2253,7 @@ static unsigned int unix_poll(struct fil
 	 * connection. This prevents stuck sockets.
 	 */
 	if (unix_writable(sk))
-		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+		mask |= POLL_OUT_ALL;
 
 	return mask;
 }
@@ -2163,22 +2289,24 @@ static unsigned int unix_dgram_poll(stru
 	}
 
 	/* No write status requested, avoid expensive OUT tests. */
-	if (wait && !(wait->key & (POLLWRBAND | POLLWRNORM | POLLOUT)))
+	if (wait && !(wait->key & POLL_OUT_ALL))
 		return mask;
 
 	writable = unix_writable(sk);
-	other = unix_peer_get(sk);
-	if (other) {
-		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
-			if (unix_recvq_full(other))
-				writable = 0;
-		}
-		sock_put(other);
+	if (writable) {
+		unix_state_lock(sk);
+
+		other = unix_peer(sk);
+		if (other
+		    && !unix_dgram_peer_recvq_space(sk, other)
+		    && unix_dgram_peer_recv_wake_prep(sk, other))
+			writable = 0;
+
+		unix_state_unlock(sk);
 	}
 
 	if (writable)
-		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+		mask |= POLL_OUT_ALL;
 	else
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
--- linux-2-6.b/include/net/af_unix.h	2015-10-28 16:06:29.613959493 +0000
+++ linux-2-6/include/net/af_unix.h	2015-10-11 20:12:47.598690519 +0100
@@ -58,6 +58,7 @@ struct unix_sock {
 	unsigned int		gc_maybe_cycle : 1;
 	unsigned char		recursion_level;
 	struct socket_wq	peer_wq;
+	wait_queue_t		peer_wake;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
