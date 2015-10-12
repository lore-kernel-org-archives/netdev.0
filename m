From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH v2 1/3] unix: fix use-after-free in unix_dgram_poll()
Date: Mon, 12 Oct 2015 21:41:28 +0100
Message-ID: <87lhb7sttz.fsf@doppelsaurus.mobileactivedefense.com>
References: <cover.1443817522.git.jbaron@akamai.com>
	<f4e283269e7063317956ea1de6fdc58449ee75cd.1443817522.git.jbaron@akamai.com>
	<87bncdxool.fsf@doppelsaurus.mobileactivedefense.com>
	<5612B9A9.8050301@akamai.com>
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
In-Reply-To: <5612B9A9.8050301@akamai.com> (Jason Baron's message of "Mon, 05
	Oct 2015 13:55:53 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Baron <jbaron@akamai.com> writes:
> On 10/05/2015 12:31 PM, Rainer Weikusat wrote:

[...]

>> Here's a more simple idea which _might_ work. The underlying problem
>> seems to be that the second sock_poll_wait introduces a covert reference
>> to the peer socket which isn't accounted for. The basic idea behind this
>> is to execute an additional sock_hold for the peer whenever the
>> sock_poll_wait is called for it and store it (the struct sock *) in a
>> new struct unix_sock member.

[...]

> Interesting - will this work for the test case you supplied where we are in
> epoll_wait() and another thread does a connect() to a new target? In that
> case, even if we issue a wakeup to the epoll thread, its not going to have
> a non-NULL poll_table, so it wouldn't be added to the new target. IE
> the first test case here:
>
> https://lkml.org/lkml/2015/10/4/154

"Indeed it would not." I've also meanwhile found the time to check what
is and isn't locked here and found that Eric's "this looks racy" was
also justified. In theory, a clean solution could be based on modifying
the various polling implementations to keep a piece of data for a polled
something and provided that again on each subsequent poll call. This
could then be used to keep the peer socket alive for as long as
necessary were it possible to change the set of wait queues with every
poll call. Since this also isn't the case, the idea to increment the
reference count of the peer socket won't fly.

OTOH, something I seriously dislike about your relaying implementation
is the unconditional add_wait_queue upon connect as this builds up a
possibly large wait queue of entities entirely uninterested in the
event which will need to be traversed even if peer_wait wakeups will
only happen if at least someone actually wants to be notified. This
could be changed such that the struct unix_sock member is only put onto
the peer's wait queue in poll and only if it hasn't already been put
onto it. The connection could then be severed if some kind of
'disconnect' occurs.

The code below (again based on 3.2.54) is what I'm currently running and
it has survived testing during the day (without trying the exercise in
hexadecimal as that doesn't cause failure for me, anyway). The wakeup
relaying function checks that a socket wait queue actually still exists
because I used to get null pointers oopses without every now and then
(I've also tested this with an additional printk printing 'no q' in case
the pointer was actually null to verify that this really occurs here).

---------------------
--- linux-2-6.b/net/unix/af_unix.c	2015-10-12 21:07:27.237102277 +0100
+++ linux-2-6/net/unix/af_unix.c	2015-10-12 21:10:26.319384298 +0100
@@ -303,6 +303,51 @@ found:
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
+static void unix_peer_wake_connect(struct sock *me, struct sock *peer)
+{
+	struct unix_sock *u, *u_peer;
+
+	u = unix_sk(me);
+	u_peer = unix_sk(peer);
+
+	if (!u->peer_wake.private)
+		return;
+
+	u->peer_wake.private = peer;
+	add_wait_queue(&u_peer->peer_wait, &u->peer_wake);
+}
+
+static int unix_peer_wake_disconnect(struct sock *me, struct sock *peer)
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
@@ -409,6 +454,8 @@ static void unix_release_sock(struct soc
 			skpair->sk_state_change(skpair);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
 		}
+
+		unix_peer_wake_disconnect(sk, skpair);
 		sock_put(skpair); /* It may now die */
 		unix_peer(sk) = NULL;
 	}
@@ -630,6 +677,7 @@ static struct sock *unix_create1(struct
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
+	init_waitqueue_func_entry(&u->peer_wake, unix_peer_wake_relay);
 	unix_insert_socket(unix_sockets_unbound, sk);
 out:
 	if (sk == NULL)
@@ -953,7 +1001,7 @@ static int unix_dgram_connect(struct soc
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
 	struct sock *other;
 	unsigned hash;
-	int err;
+	int err, disconned;
 
 	if (addr->sa_family != AF_UNSPEC) {
 		err = unix_mkname(sunaddr, alen, &hash);
@@ -1001,6 +1049,11 @@ restart:
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk) = other;
+
+		disconned = unix_peer_wake_disconnect(sk, other);
+		if (disconned)
+			wake_up_interruptible_poll(sk_sleep(sk), POLLOUT);
+
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1439,7 +1492,7 @@ static int unix_dgram_sendmsg(struct kio
 	struct sk_buff *skb;
 	long timeo;
 	struct scm_cookie tmp_scm;
-	int max_level;
+	int max_level, disconned;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1525,6 +1578,12 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+
+			disconned = unix_peer_wake_disconnect(sk, other);
+			if (disconned)
+				wake_up_interruptible_poll(sk_sleep(sk),
+							POLLOUT);
+
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -2170,10 +2229,20 @@ static unsigned int unix_dgram_poll(stru
 	other = unix_peer_get(sk);
 	if (other) {
 		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
-			if (unix_recvq_full(other))
-				writable = 0;
+			unix_state_lock(sk);
+
+			if (unix_peer(sk) == other) {
+				unix_peer_wake_connect(sk, other);
+
+				if (unix_recvq_full(other))
+					writable = 0;
+				else
+					unix_peer_wake_disconnect(sk, other);
+			}
+
+			unix_state_unlock(sk);
 		}
+
 		sock_put(other);
 	}
 
--- linux-2-6.b/include/net/af_unix.h	2015-10-12 21:07:27.237102277 +0100
+++ linux-2-6/include/net/af_unix.h	2015-10-11 20:12:47.598690519 +0100
@@ -58,6 +58,7 @@ struct unix_sock {
 	unsigned int		gc_maybe_cycle : 1;
 	unsigned char		recursion_level;
 	struct socket_wq	peer_wq;
+	wait_queue_t		peer_wake;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
