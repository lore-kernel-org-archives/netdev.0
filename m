From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [RFC] unix: fix use-after-free in unix_dgram_poll()/ 4.2.5
Date: Fri, 30 Oct 2015 20:52:08 +0000
Message-ID: <877fm43wqv.fsf_-_@doppelsaurus.mobileactivedefense.com>
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
	<874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com>
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
In-Reply-To: <874mhbx7o1.fsf_-_@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Wed, 28 Oct 2015 16:46:38 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same changes ported to 4.2.5 with some minor improvments (I hope),
namely,

	- applied a round of DeMorgan to the 'quick' check function in
          order to simplify the condition

	- fixed a (minor) error in the dgram_sendmsg change: In case the
          2nd check resulted in 'can send now', the code would continue
          with 'wait until timeout expired' (since timeo was 0 in the
          case, this shouldn't make much of a practical difference)

	- (hopefully) more intelligible function names and better
          explanation

	- dropped the POLL_OUT_ALL macro again as that's really
          unrelated

---
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -62,6 +62,7 @@ struct unix_sock {
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
+	wait_queue_t		peer_wake;
 };
 
 static inline struct unix_sock *unix_sk(struct sock *sk)
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
+/* Needs 'this' unix state lock. Lockless check if data can (likely)
+ * be sent.
+ */
+static inline int unix_dgram_peer_recv_ready(struct sock *sk,
+					     struct sock *other)
+{
+	return unix_peer(other) == sk || !unix_recvq_full(other);
+}
+
+/* Needs 'this' unix state lock. After recv_ready indicated not ready,
+ * establish peer_wait connection if still needed.
+ */
+static int unix_dgram_peer_wake_me(struct sock *sk, struct sock *other)
+{
+	int conned;
+
+	conned = unix_dgram_peer_wake_connect(sk, other);
+
+	if (unix_recvq_full(other))
+		return 1;
+
+	if (conned)
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
@@ -983,7 +1102,7 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)addr;
 	struct sock *other;
 	unsigned int hash;
-	int err;
+	int err, disconned;
 
 	if (addr->sa_family != AF_UNSPEC) {
 		err = unix_mkname(sunaddr, alen, &hash);
@@ -1031,6 +1150,14 @@ restart:
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk) = other;
+
+		disconned = unix_dgram_peer_wake_disconnect(sk, other);
+		if (disconned)
+			wake_up_interruptible_poll(sk_sleep(sk),
+						   POLLOUT |
+						   POLLWRNORM |
+						   POLLWRBAND);
+
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1463,7 +1590,7 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
 	struct sock *other = NULL;
 	int namelen = 0; /* fake GCC */
-	int err;
+	int err, disconned;
 	unsigned int hash;
 	struct sk_buff *skb;
 	long timeo;
@@ -1565,6 +1692,14 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+
+			disconned = unix_dgram_peer_wake_disconnect(sk, other);
+			if (disconned)
+				wake_up_interruptible_poll(sk_sleep(sk),
+							   POLLOUT |
+							   POLLWRNORM |
+							   POLLWRBAND);
+
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -1590,10 +1725,14 @@ restart:
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
@@ -2453,14 +2592,16 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
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
