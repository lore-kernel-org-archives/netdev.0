From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Sun, 18 Oct 2015 21:58:51 +0100
Message-ID: <87fv17x59w.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<5612B9A9.8050301@akamai.com>
	<87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
	<561DCFA4.3010300@akamai.com>
	<87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
	<561F156E.9050905@akamai.com>
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
In-Reply-To: <561F156E.9050905@akamai.com> (Jason Baron's message of "Wed, 14
	Oct 2015 22:54:38 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> ....
>> 
>> X-Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> 

Sorry for the delayed reply but I had to do some catching up on what the
people who pay me consider 'useful work' :-).

> So the patches I've posted and yours both use the idea of a relaying
> the remote peer wakeup via callbacks that are internal to the net/unix,
> such that we avoid exposing the remote peer wakeup to the external
> poll()/select()/epoll(). They differ in when and how those callbacks
> are registered/unregistered.

Yes. In my opinion, that's the next best idea considering that the need
to handle this particular situation is presumably specfcific to the
af_unix.c code and thus, doesn't warrant changes to all I/O multiplexing
implementations.

> So I think your approach here will generally keep the peer wait wakeup
> queue to its absolute minimum, by removing from that queue when
> we set POLLOUT, however it requires taking the peer waitqueue lock on
> every poll() call.
>
> So I think there are tradeoffs here vs. what I've
> posted. So for example, if there are a lot of writers against one 'server'
> socket, there is going to be a lot of lock contention with your approach
> here. So I think the performance is going to depend on the workload that
> is tested.

This approach is really completely run-of-the-mill "possibly sleep until
some event occurs" code, eg, you'll find a description of this exact
procedure on p. 157 of chapter 6 of

https://lwn.net/Kernel/LDD3/

The idea behind 'the wait queue' (insofar I'm aware of it) is that it
will be used as list of threads who need to be notified when the
associated event occurs. Since you seem to argue that the run-of-the-mill
algorithm is too slow for this particular case, is there anything to
back this up?

This is also sort-of a zero-sum game as the idea to enqueue on a wait
queue because the event could possibly become interesting in future
really just shifts (for n:1 connected sockets) work from the (possibly
many) clients to the single server. And considering that 'the wait'
became necessary (if it became necessary) because flow-control kicked in
to stop clients from sending more data to the server until it had time
to catch up with the already sent data, this doesn't seem like a good
idea to me.

Using a flag to signal that at least some of the members of this queue
actually want to be woken up will also only save work if it is assumed
that most threads won't ever really be waiting for this, ie, won't
execute the corresponding unix_dgram_poll code. But if that code isn't
going to be executed most of the time, anyway, why optimize it?

It's also not really necessary to take the waitqueue lock on every poll,
eg, the code in unix_dgram_poll could be changed like this:

                need_wakeup = 0;
                unix_state_lock(sk);

                other = unix_peer(sk);
                if (other && unix_peer(other) != sk) {
                        if (unix_recvq_full(other)) {
                                need_wakeup = !unix_peer_wake_connect(sk, other);

                                if (unix_recvq_full(other)) {
                                        writable = 0;
                                        need_wakeup = 0;
                                } else
                                        unix_peer_wake_disconnect(sk, other);
                        } else
                                need_wakeup = unix_peer_wake_disconnect(sk, other);
                }

                unix_state_unlock(sk);
                if (need_wakeup)
                        wake_up_interruptible_poll(sk_sleep(sk), POLL_OUT_ALL);

I'm no big fan of adding complications like this based on the conjecture
that they might be useful, but this one seems justified to me. IMHO,
there are two interesting cases here:

1. The current thread won't have to wait. It should detect this quickly
   so that it can get back to work, hence, check for this before
   'preparing to wait'.

2. Nothing to be done here right now, hence, performing an additional
   check for 'still not writeable' shouldn't matter much.

Yet another 3.2.54 patch with the change above

-----------
--- linux-2-6.b/net/unix/af_unix.c	2015-10-18 20:41:10.829404899 +0100
+++ linux-2-6/net/unix/af_unix.c	2015-10-18 20:17:34.819134482 +0100
@@ -115,6 +115,8 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 
+#define POLL_OUT_ALL	(POLLOUT | POLLWRNORM | POLLWRBAND)
+
 static struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 static DEFINE_SPINLOCK(unix_table_lock);
 static atomic_long_t unix_nr_socks;
@@ -303,6 +305,53 @@ found:
 	return s;
 }
 
+static int unix_peer_wake_relay(wait_queue_t *q, unsigned mode, int flags,
+				void *key)
+{
+	struct unix_sock *u;
+	wait_queue_head_t *u_sleep;
+
+	u = container_of(q, struct unix_sock, peer_wake);
+
+	u_sleep = sk_sleep(&u->sk);
+	if (u_sleep)
+		wake_up_interruptible_poll(u_sleep, key);
+
+	return 0;
+}
+
+static inline int unix_peer_wake_connect(struct sock *me, struct sock *peer)
+{
+	struct unix_sock *u, *u_peer;
+
+	u = unix_sk(me);
+	u_peer = unix_sk(peer);
+
+	if (u->peer_wake.private)
+		return 0;
+
+	u->peer_wake.private = peer;
+	add_wait_queue(&u_peer->peer_wait, &u->peer_wake);
+
+	return 1;
+}
+
+static inline int unix_peer_wake_disconnect(struct sock *me, struct sock *peer)
+{
+	struct unix_sock *u, *u_peer;
+
+	u = unix_sk(me);
+	u_peer = unix_sk(peer);
+
+	if (u->peer_wake.private != peer)
+		return 0;
+
+	remove_wait_queue(&u_peer->peer_wait, &u->peer_wake);
+	u->peer_wake.private = NULL;
+
+	return 1;
+}
+
 static inline int unix_writable(struct sock *sk)
 {
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
@@ -317,7 +366,7 @@ static void unix_write_space(struct sock
 		wq = rcu_dereference(sk->sk_wq);
 		if (wq_has_sleeper(wq))
 			wake_up_interruptible_sync_poll(&wq->wait,
-				POLLOUT | POLLWRNORM | POLLWRBAND);
+							POLL_OUT_ALL);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
 	rcu_read_unlock();
@@ -409,6 +458,8 @@ static void unix_release_sock(struct soc
 			skpair->sk_state_change(skpair);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
 		}
+
+		unix_peer_wake_disconnect(sk, skpair);
 		sock_put(skpair); /* It may now die */
 		unix_peer(sk) = NULL;
 	}
@@ -630,6 +681,7 @@ static struct sock *unix_create1(struct
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
+	init_waitqueue_func_entry(&u->peer_wake, unix_peer_wake_relay);
 	unix_insert_socket(unix_sockets_unbound, sk);
 out:
 	if (sk == NULL)
@@ -953,7 +1005,7 @@ static int unix_dgram_connect(struct soc
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
 	struct sock *other;
 	unsigned hash;
-	int err;
+	int err, disconned;
 
 	if (addr->sa_family != AF_UNSPEC) {
 		err = unix_mkname(sunaddr, alen, &hash);
@@ -1001,6 +1053,11 @@ restart:
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk) = other;
+
+		disconned = unix_peer_wake_disconnect(sk, other);
+		if (disconned)
+			wake_up_interruptible_poll(sk_sleep(sk), POLL_OUT_ALL);
+
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1439,7 +1496,7 @@ static int unix_dgram_sendmsg(struct kio
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
-	int max_level;
+	int max_level, disconned;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1525,6 +1582,12 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+
+			disconned = unix_peer_wake_disconnect(sk, other);
+			if (disconned)
+				wake_up_interruptible_poll(sk_sleep(sk),
+							POLL_OUT_ALL);
+
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -1783,8 +1846,7 @@ static int unix_dgram_recvmsg(struct kio
 		goto out_unlock;
 	}
 
-	wake_up_interruptible_sync_poll(&u->peer_wait,
-					POLLOUT | POLLWRNORM | POLLWRBAND);
+	wake_up_interruptible_sync_poll(&u->peer_wait, POLL_OUT_ALL);
 
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);
@@ -2127,7 +2189,7 @@ static unsigned int unix_poll(struct fil
 	 * connection. This prevents stuck sockets.
 	 */
 	if (unix_writable(sk))
-		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+		mask |= POLL_OUT_ALL;
 
 	return mask;
 }
@@ -2137,6 +2199,7 @@ static unsigned int unix_dgram_poll(stru
 {
 	struct sock *sk = sock->sk, *other;
 	unsigned int mask, writable;
+	int need_wakeup;
 
 	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask = 0;
@@ -2163,22 +2226,55 @@ static unsigned int unix_dgram_poll(stru
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
+	if (writable) {
+		/*
+		 * If sk is asymmetrically connected to a peer,
+		 * whether or not data can actually be written depends
+		 * on the number of messages already enqueued for
+		 * reception on the peer socket, so check for this
+		 * condition, too.
+		 *
+		 * In case the socket is deemed not writeable because
+		 * of this, link it onto the peer_wait queue of the
+		 * peer to ensure that a wake up happens even if no
+		 * datagram already enqueued for processing was sent
+		 * using sk.
+		 *
+		 * If a thread finds the socket writable but wasn't
+		 * the one which connected, do a wake up as the
+		 * current thread might never have slept and hence,
+		 * might have broken the link before regular wake up
+		 * could happen.
+		 */
+
+		need_wakeup = 0;
+		unix_state_lock(sk);
+
+		other = unix_peer(sk);
+		if (other && unix_peer(other) != sk) {
+			if (unix_recvq_full(other)) {
+				need_wakeup = !unix_peer_wake_connect(sk, other);
+
+				if (unix_recvq_full(other)) {
+					writable = 0;
+					need_wakeup = 0;
+				} else
+					unix_peer_wake_disconnect(sk, other);
+			} else
+				need_wakeup = unix_peer_wake_disconnect(sk, other);
 		}
-		sock_put(other);
+
+		unix_state_unlock(sk);
+		if (need_wakeup)
+			wake_up_interruptible_poll(sk_sleep(sk), POLL_OUT_ALL);
 	}
 
 	if (writable)
-		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
+		mask |= POLL_OUT_ALL;
 	else
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
--- linux-2-6.b/include/net/af_unix.h	2015-10-18 20:41:10.833404775 +0100
+++ linux-2-6/include/net/af_unix.h	2015-10-11 20:12:47.598690519 +0100
@@ -58,6 +58,7 @@ struct unix_sock {
 	unsigned int		gc_maybe_cycle : 1;
 	unsigned char		recursion_level;
 	struct socket_wq	peer_wq;
+	wait_queue_t		peer_wake;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
