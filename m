From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Mon, 09 Nov 2015 14:40:48 +0000
Message-ID: <87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	<20151012120249.GB16370@unicorn.suse.cz>
	<1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
	<CACT4Y+Z2H8xPg1Dq0Z=HC3WKm+Uw+ZjK6zOLvxhPwFd4D0CsZw@mail.gmail.com>
	<CACT4Y+Zu7J0n6dU1dSfiW3F9Q0Us3_DBVcD5Pi9NG9LER8MmRg@mail.gmail.com>
	<563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Baron <jbaron@akamai.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Howells <dhowells@redhat.com>,
	Paul Moore <paul@paul-moore.com>, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com,
	netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Fri, 06 Nov 2015 15:15:44 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An AF_UNIX datagram socket being the client in an n:1 association with
some server socket is only allowed to send messages to the server if the
receive queue of this socket contains at most sk_max_ack_backlog
datagrams. This implies that prospective writers might be forced to go
to sleep despite none of the message presently enqueued on the server
receive queue were sent by them. In order to ensure that these will be
woken up once space becomes again available, the present unix_dgram_poll
routine does a second sock_poll_wait call with the peer_wait wait queue
of the server socket as queue argument (unix_dgram_recvmsg does a wake
up on this queue after a datagram was received). This is inherently
problematic because the server socket is only guaranteed to remain alive
for as long as the client still holds a reference to it. In case the
connection is dissolved via connect or by the dead peer detection logic
in unix_dgram_sendmsg, the server socket may be freed despite "the
polling mechanism" (in particular, epoll) still has a pointer to the
corresponding peer_wait queue. There's no way to forcibly deregister a
wait queue with epoll.

Based on an idea by Jason Baron, the patch below changes the code such
that a wait_queue_t belonging to the client socket is enqueued on the
peer_wait queue of the server whenever the peer receive queue full
condition is detected by either a sendmsg or a poll. A wake up on the
peer queue is then relayed to the ordinary wait queue of the client
socket via wake function. The connection to the peer wait queue is again
dissolved if either a wake up is about to be relayed or the client
socket reconnects or a dead peer is detected or the client socket is
itself closed. This enables removing the second sock_poll_wait from
unix_dgram_poll, thus avoiding the use-after-free, while still ensuring
that no blocked writer sleeps forever.

Signed-off-by: Rainer Weikusuat <rweikusat@mobileactivedefense.com>

---
"Why do things always end up messy and complicated"? Patch is against
4.3.0.


diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index b36d837..2a91a05 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -62,6 +62,7 @@ struct unix_sock {
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
+	wait_queue_t		peer_wake;
 };
 
 static inline struct unix_sock *unix_sk(const struct sock *sk)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 94f6582..4f263e3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -326,6 +326,122 @@ found:
 	return s;
 }
 
+/* Support code for asymmetrically connected dgram sockets
+ *
+ * If a datagram socket is connected to a socket not itself connected
+ * to the first socket (eg, /dev/log), clients may only enqueue more
+ * messages if the present receive queue of the server socket is not
+ * "too large". This means there's a second writeability condition
+ * poll and sendmsg need to test. The dgram recv code will do a wake
+ * up on the peer_wait wait queue of a socket upon reception of a
+ * datagram which needs to be propagated to sleeping would-be writers
+ * since these might not have sent anything so far. This can't be
+ * accomplished via poll_wait because the lifetime of the server
+ * socket might be less than that of its clients if these break their
+ * association with it or if the server socket is closed while clients
+ * are still connected to it and there's no way to inform "a polling
+ * implementation" that it should let go of a certain wait queue
+ *
+ * In order to propagate a wake up, a wait_queue_t of the client
+ * socket is enqueued on the peer_wait queue of the server socket
+ * whose wake function does a wake_up on the ordinary client socket
+ * wait queue. This connection is established whenever a write (or
+ * poll for write) hit the flow control condition and broken when the
+ * association to the server socket is dissolved or after a wake up
+ * was relayed.
+ */
+
+static int unix_dgram_peer_wake_relay(wait_queue_t *q, unsigned mode, int flags,
+				      void *key)
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
+/* Needs sk unix state lock. Otherwise lockless check if data can (likely)
+ * be sent.
+ */
+static inline int unix_dgram_peer_recv_ready(struct sock *sk,
+					     struct sock *other)
+{
+	return unix_peer(other) == sk || !unix_recvq_full(other);
+}
+
+/* Needs sk unix state lock. After recv_ready indicated not ready,
+ * establish peer_wait connection if still needed.
+ */
+static int unix_dgram_peer_wake_me(struct sock *sk, struct sock *other)
+{
+	int connected;
+
+	connected = unix_dgram_peer_wake_connect(sk, other);
+
+	if (unix_recvq_full(other))
+		return 1;
+
+	if (connected)
+		unix_dgram_peer_wake_disconnect(sk, other);
+
+	return 0;
+}
+
 static inline int unix_writable(struct sock *sk)
 {
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
@@ -430,6 +546,8 @@ static void unix_release_sock(struct sock *sk, int embrion)
 			skpair->sk_state_change(skpair);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
 		}
+
+		unix_dgram_peer_wake_disconnect(sk, skpair);
 		sock_put(skpair); /* It may now die */
 		unix_peer(sk) = NULL;
 	}
@@ -664,6 +782,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
+	init_waitqueue_func_entry(&u->peer_wake, unix_dgram_peer_wake_relay);
 	unix_insert_socket(unix_sockets_unbound(sk), sk);
 out:
 	if (sk == NULL)
@@ -1031,6 +1150,13 @@ restart:
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk) = other;
+
+		if (unix_dgram_peer_wake_disconnect(sk, other))
+			wake_up_interruptible_poll(sk_sleep(sk),
+						   POLLOUT |
+						   POLLWRNORM |
+						   POLLWRBAND);
+
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1565,6 +1691,13 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+
+			if (unix_dgram_peer_wake_disconnect(sk, other))
+				wake_up_interruptible_poll(sk_sleep(sk),
+							   POLLOUT |
+							   POLLWRNORM |
+							   POLLWRBAND);
+
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -1590,10 +1723,14 @@ restart:
 			goto out_unlock;
 	}
 
-	if (unix_peer(other) != sk && unix_recvq_full(other)) {
+	if (!unix_dgram_peer_recv_ready(sk, other)) {
 		if (!timeo) {
-			err = -EAGAIN;
-			goto out_unlock;
+			if (unix_dgram_peer_wake_me(sk, other)) {
+				err = -EAGAIN;
+				goto out_unlock;
+			}
+
+			goto restart;
 		}
 
 		timeo = unix_wait_for_peer(other, timeo);
@@ -2453,14 +2590,16 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
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
+		if (other &&
+		    !unix_dgram_peer_recv_ready(sk, other) &&
+		    unix_dgram_peer_wake_me(sk, other))
+			writable = 0;
+
+		unix_state_unlock(sk);
 	}
 
 	if (writable)
