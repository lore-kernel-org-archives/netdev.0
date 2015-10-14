From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Wed, 14 Oct 2015 18:47:34 +0100
Message-ID: <87d1wh8hqh.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<5612B9A9.8050301@akamai.com>
	<87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
	<561DCFA4.3010300@akamai.com>
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
In-Reply-To: <561DCFA4.3010300@akamai.com> (Jason Baron's message of "Tue, 13
	Oct 2015 23:44:36 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 10/12/2015 04:41 PM, Rainer Weikusat wrote:
>> Jason Baron <jbaron@akamai.com> writes:
>>> On 10/05/2015 12:31 PM, Rainer Weikusat wrote:

[...]

>> OTOH, something I seriously dislike about your relaying implementation
>> is the unconditional add_wait_queue upon connect as this builds up a
>> possibly large wait queue of entities entirely uninterested in the
>> event which will need to be traversed even if peer_wait wakeups will
>> only happen if at least someone actually wants to be notified. This
>> could be changed such that the struct unix_sock member is only put onto
>> the peer's wait queue in poll and only if it hasn't already been put
>> onto it. The connection could then be severed if some kind of
>> 'disconnect' occurs.

[...]


> What about the following race?
>
> 1) thread A does poll() on f, finds the wakeup condition low, and adds
> itself to the remote peer_wait queue.
>
> 2) thread B sets the wake up condition in dgram_recvmsg(), but does not
> execute the wakeup of threads yet.
>
> 3) thread C also does a poll() on f, finds now that the wakeup condition
> is set, and hence removes f from the remote peer_wait queue.
>
> Then, thread A misses the POLLOUT, and hangs.

Indeed. This starts to turn into an interesting, little problem. Based
on the code I posted, there are (AFAICT) four possible situations a
thread looking for 'peer will accept data' can find itself in:

A -	supposed to mean 'it connected to the peer_wait queue'
B -	the peer socket is ready to accept messages

A && B
------

Since A, no other thread can be waiting for this event and since B, A
was undone. Fine to return.


!A && B
-------

!A means 'was enqueued to peer_wait during an earlier call'. This means
any number of threads may be waiting. Because of this, do an additional
wake up after disconnecting since the current thread may never have
slept, ie, possibly, no wake up occurred yet.


 A && !B
 -------

 Now connected to receive peer wake ups. Go to sleep.


 !A && !B
 --------

 Someone else connected. Go to sleep.

> I understand your concern about POLLIN only waiters-I think we
> could add the 'relay callback' in dgram_poll() only for those who are
> looking for POLLOUT, and simply avoid the de-registration,

Whether or not the currently running thread wanted to write or to read
can only be determined (AIUI) if a poll_table was passed. If this was
the case and the thread didn't look for 'write space', it will never
execute the code in question, cf

	/* No write status requested, avoid expensive OUT tests. */
	if (wait && !(wait->key & POLL_OUT_ALL))
		return mask;

As to 'concerns', I'll try to word that somewhat differently: The usual
way to handle a 'may sleep' situation is

1. Enqueue on the associated wait_queue.

2. Test the condition

2a) No sleep, dequeue and return

2b) Sleep until woken up

This means the wait queue is used to 'register' threads which want to be
woken up if a certain event happens. It's not used such that a thread
first enqueues itself on all wait queues it could ever need to enqueued
on and that an associated flag is used to inform the code on the way to
doing a wake up whether or not any of the entries on the list actually
corresponds to someone waiting for one. Even if such a flag exists, the
time needed to do the wake up is still proportional to size of the list.

For the given case, take a usual socketpair: It's absolutely pointless
to put these on the peer_wait queues of each other because all datagrams
send by one go to the other, ie, a situation where a thread goes to
sleep because it has to wait until data written via unrelated sockets
has been consumed can never happen.

I'll include the patch I'm currently using below, including an
X-Signed-Off by line to signify that this is the result of kernel
development sponsored by my employer and made available under the usual
terms. Changes since the last version:

	- fixed the inverted (rather accidentally uninverted) test in
          _connect

	- simplified the peer-checking logic: Instead of getting the
          peer with the state locked and then doing all kinds of checks
          which will hopefully enable avoiding to lock the state again,
          then, possibly, lock it again, lock the socket, do the peer
          checks followed by whatever else is necessary, then unlock it

	- addressed the race described above by means of doing a wake_up
          on sk_sleep(sk) if a thread breaks the connection which
          didn't also establish it

	- a comment (yohoho) explaining all of this -- I don't usually
          use comments in my own code because I consider them rather an
          annoyance than helpful

Unrelated change:

	- #defined POLL_OUT_ALL (POLLOUT | POLLWRNORM | POLLWRBAND)
          and use that instead of the explicit triple

X-Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>

---
--- linux-2-6.b/net/unix/af_unix.c	2015-10-14 17:36:28.233632890 +0100
+++ linux-2-6/net/unix/af_unix.c	2015-10-14 17:40:13.678601252 +0100
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
@@ -2163,22 +2226,50 @@ static unsigned int unix_dgram_poll(stru
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
+		 * the one which connected, other threads might be
+		 * sleeping so do a wake up after disconnecting.
+		 */
+
+		need_wakeup = 0;
+		unix_state_lock(sk);
+
+		other = unix_peer(sk);
+		if (other && unix_peer(other) != sk) {
+			need_wakeup = !unix_peer_wake_connect(sk, other);
+
+			if (unix_recvq_full(other)) {
 				writable = 0;
+				need_wakeup = 0;
+			} else
+				unix_peer_wake_disconnect(sk, other);
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
 
--- linux-2-6.b/include/net/af_unix.h	2015-10-14 17:36:28.237632764 +0100
+++ linux-2-6/include/net/af_unix.h	2015-10-11 20:12:47.598690519 +0100
@@ -58,6 +58,7 @@ struct unix_sock {
 	unsigned int		gc_maybe_cycle : 1;
 	unsigned char		recursion_level;
 	struct socket_wq	peer_wq;
+	wait_queue_t		peer_wake;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
