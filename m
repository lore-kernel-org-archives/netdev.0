From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v3 1/3] net: unix: fix use-after-free in unix_dgram_poll()
Date: Wed,  7 Oct 2015 23:19:35 -0400
Message-ID: <8f8dfc6fdb8015091b58509044b15489df261461.1444272769.git.jbaron@akamai.com>
References: <cover.1444272769.git.jbaron@akamai.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1444272769.git.jbaron@akamai.com>
In-Reply-To: <cover.1444272769.git.jbaron@akamai.com>
References: <cover.1444272769.git.jbaron@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
queue associated with the socket s that we are poll'ing against, but also calls
sock_poll_wait() for a remote peer socket p, if it is connected. Thus,
if we call poll()/select()/epoll() for the socket s, there are then
a couple of code paths in which the remote peer socket p and its associated
peer_wait queue can be freed before poll()/select()/epoll() have a chance
to remove themselves from the remote peer socket.

The way that remote peer socket can be freed are:

1. If s calls connect() to a connect to a new socket other than p, it will
drop its reference on p, and thus a close() on p will free it.

2. If we call close on p(), then a subsequent sendmsg() from s, will drop
the final reference to p, allowing it to be freed.

Address this issue, by reverting unix_dgram_poll() to only register with
the wait queue associated with s and register a callback with the remote peer
socket on connect() that will wake up the wait queue associated with s. If
scenarios 1 or 2 occur above we then simply remove the callback from the
remote peer. This then presents the expected semantics to poll()/select()/
epoll().

I've implemented this for sock-type, SOCK_RAW, SOCK_DGRAM, and SOCK_SEQPACKET
but not for SOCK_STREAM, since SOCK_STREAM does not use unix_dgram_poll().

Introduced in commit ec0d215f9420 ("af_unix: fix 'poll for write'/connected
DGRAM sockets").

Tested-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 32 +++++++++++++++++++++++++++++++-
 2 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 4a167b3..9698aff 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -62,6 +62,7 @@ struct unix_sock {
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
+	wait_queue_t		wait;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..f789423 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -420,6 +420,9 @@ static void unix_release_sock(struct sock *sk, int embrion)
 	skpair = unix_peer(sk);
 
 	if (skpair != NULL) {
+		if (sk->sk_type != SOCK_STREAM)
+			remove_wait_queue(&unix_sk(skpair)->peer_wait,
+					  &u->wait);
 		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
 			unix_state_lock(skpair);
 			/* No more writes */
@@ -636,6 +639,16 @@ static struct proto unix_proto = {
  */
 static struct lock_class_key af_unix_sk_receive_queue_lock_key;
 
+static int peer_wake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct unix_sock *u;
+
+	u = container_of(wait, struct unix_sock, wait);
+	wake_up_interruptible_sync_poll(sk_sleep(&u->sk), key);
+
+	return 0;
+}
+
 static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 {
 	struct sock *sk = NULL;
@@ -664,6 +677,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
+	init_waitqueue_func_entry(&u->wait, peer_wake);
 	unix_insert_socket(unix_sockets_unbound(sk), sk);
 out:
 	if (sk == NULL)
@@ -1030,7 +1044,11 @@ restart:
 	 */
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
+
+		remove_wait_queue(&unix_sk(old_peer)->peer_wait,
+				  &unix_sk(sk)->wait);
 		unix_peer(sk) = other;
+		add_wait_queue(&unix_sk(other)->peer_wait, &unix_sk(sk)->wait);
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1038,8 +1056,12 @@ restart:
 		sock_put(old_peer);
 	} else {
 		unix_peer(sk) = other;
+		add_wait_queue(&unix_sk(other)->peer_wait, &unix_sk(sk)->wait);
 		unix_state_double_unlock(sk, other);
 	}
+	/* New remote may have created write space for us */
+	wake_up_interruptible_sync_poll(sk_sleep(sk),
+					POLLOUT | POLLWRNORM | POLLWRBAND);
 	return 0;
 
 out_unlock:
@@ -1194,6 +1216,8 @@ restart:
 
 	sock_hold(sk);
 	unix_peer(newsk)	= sk;
+	if (sk->sk_type == SOCK_SEQPACKET)
+		add_wait_queue(&unix_sk(sk)->peer_wait, &unix_sk(newsk)->wait);
 	newsk->sk_state		= TCP_ESTABLISHED;
 	newsk->sk_type		= sk->sk_type;
 	init_peercred(newsk);
@@ -1220,6 +1244,8 @@ restart:
 
 	smp_mb__after_atomic();	/* sock_hold() does an atomic_inc() */
 	unix_peer(sk)	= newsk;
+	if (sk->sk_type == SOCK_SEQPACKET)
+		add_wait_queue(&unix_sk(newsk)->peer_wait, &unix_sk(sk)->wait);
 
 	unix_state_unlock(sk);
 
@@ -1254,6 +1280,10 @@ static int unix_socketpair(struct socket *socka, struct socket *sockb)
 	sock_hold(skb);
 	unix_peer(ska) = skb;
 	unix_peer(skb) = ska;
+	if (ska->sk_type != SOCK_STREAM) {
+		add_wait_queue(&unix_sk(ska)->peer_wait, &unix_sk(skb)->wait);
+		add_wait_queue(&unix_sk(skb)->peer_wait, &unix_sk(ska)->wait);
+	}
 	init_peercred(ska);
 	init_peercred(skb);
 
@@ -1565,6 +1595,7 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+			remove_wait_queue(&unix_sk(other)->peer_wait, &u->wait);
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -2441,7 +2472,6 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	other = unix_peer_get(sk);
 	if (other) {
 		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
 			if (unix_recvq_full(other))
 				writable = 0;
 		}
-- 
2.6.1
