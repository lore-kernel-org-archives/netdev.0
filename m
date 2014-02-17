From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] unix: add read side socket memory accounting for dgram sockets
Date: Mon, 17 Feb 2014 04:58:26 +0100
Message-ID: <20140217035826.GG8634@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yannick@koehler.name, eric.dumazet@gmail.com, davem@davemloft.net,
	xiyou.wangcong@gmail.com, dan@mindstab.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59726 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbaBQD62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 22:58:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current situation:

We allocate memory with sock_alloc_send_pskb which accounts skb to the
sending socket's sk_wmem_alloc. The skb->destructor does a sock_wfree
as soon as the recipient retrieves the data and skb is destroyed.

The problem with this implementation is that an unconnected unix dgram
server could get blocked sending further data, if a client does not
retrieve its frames from its sk_receive_queue because sk_wmem_alloc is
under control of the client.

This patch does the following improvment:

We still allocate dgram packets with sock_alloc_send_pskb, which now
does normally not block if the socket has too many packets in flight.

While delivering the skb to the client in unix_dgram_sendmsg we check
for the recipients sockets rmem and block there if sk_rcvbuf is surpassed.

As the sender socket is not attached to the skb while retrieving it any
more, we must attach the unix dgram peers address to the skb directly,
this is done via a new field in unix_skb_parms.

Note, socket buffer limitation is already in place from the generic
socket layer. The client cannot request more than sysctl_rmem_max
(/proc/sys/net/core/rmem_max) bytes of receive buffer.

The (unix_peer(other) != sk) checks are removed as we now no longer block
in in sock_alloc_send_pskb if we try to send data to ourself, as send
buffer will always be free. To avoid DoS we need to bring the sender
to a stop trying to deliver skbs to its own socket receive queue here.
The same logic applies to the unix_dgram_poll change.

So, currently the following protections are in place to not get a victim
of a DoS:
* sk_receive_queue length limitation by sk_max_ack_backlog
* sk_rcvbuf length limiting on  the receiving socket
* sending buffer limitations in case of too may concurrent send requests

With this patch it is possible to maybe relax the unix_recq_full check in
future or make the sk_max_ack_backlog configurable in future on a per-socket
basis.

Reported-by: Yannick Koehler <yannick@koehler.name>
CC: Yannick Koehler <yannick@koehler.name>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Dan Ballard <dan@mindstab.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 79 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 63 insertions(+), 17 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index a175ba4..52fbabd 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -36,6 +36,7 @@ struct unix_skb_parms {
 	u32			secid;		/* Security ID		*/
 #endif
 	u32			consumed;
+	struct unix_address	*dgram_peer;
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 29fc8be..5583c02 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -187,6 +187,12 @@ static inline int unix_recvq_full(struct sock const *sk)
 	return skb_queue_len(&sk->sk_receive_queue) > sk->sk_max_ack_backlog;
 }
 
+static bool unix_rmem_full(const struct sock *sk,
+			   const struct sk_buff *skb)
+{
+	return sk_rmem_alloc_get(sk) + skb->truesize > sk->sk_rcvbuf;
+}
+
 struct sock *unix_peer_get(struct sock *s)
 {
 	struct sock *peer;
@@ -322,6 +328,11 @@ static inline int unix_writable(struct sock *sk)
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
 }
 
+static int unix_other_writable(const struct sock *other)
+{
+	return (atomic_read(&other->sk_rmem_alloc) << 2) <= other->sk_rcvbuf;
+}
+
 static void unix_write_space(struct sock *sk)
 {
 	struct socket_wq *wq;
@@ -1048,8 +1059,13 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 	prepare_to_wait_exclusive(&u->peer_wait, &wait, TASK_INTERRUPTIBLE);
 
 	sched = !sock_flag(other, SOCK_DEAD) &&
-		!(other->sk_shutdown & RCV_SHUTDOWN) &&
-		unix_recvq_full(other);
+		!(other->sk_shutdown & RCV_SHUTDOWN);
+
+	if (other->sk_type == SOCK_STREAM)
+		sched = sched && unix_recvq_full(other);
+	else
+		sched = sched && (unix_recvq_full(other) ||
+				  unix_other_writable(other));
 
 	unix_state_unlock(other);
 
@@ -1367,9 +1383,33 @@ static void unix_destruct_scm(struct sk_buff *skb)
 	/* Alas, it calls VFS */
 	/* So fscking what? fput() had been SMP-safe since the last Summer */
 	scm_destroy(&scm);
+}
+
+static void unix_skb_destruct_r(struct sk_buff *skb)
+{
+	unix_destruct_scm(skb);
+	if (UNIXCB(skb).dgram_peer)
+		unix_release_addr(UNIXCB(skb).dgram_peer);
+	sock_rfree(skb);
+}
+
+static void unix_skb_destruct_w(struct sk_buff *skb)
+{
+	unix_destruct_scm(skb);
+	if (UNIXCB(skb).dgram_peer)
+		unix_release_addr(UNIXCB(skb).dgram_peer);
 	sock_wfree(skb);
 }
 
+static void unix_skb_set_owner_r(struct sk_buff *skb, struct sock *sk,
+				   struct sock *other)
+{
+	sock_wfree(skb);
+	skb->sk = other;
+	skb->destructor = unix_skb_destruct_r;
+	atomic_add(skb->truesize, &other->sk_rmem_alloc);
+}
+
 #define MAX_RECURSION_LEVEL 4
 
 static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
@@ -1417,7 +1457,6 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
-	skb->destructor = unix_destruct_scm;
 	return err;
 }
 
@@ -1504,6 +1543,12 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
+	if (u->addr) {
+		UNIXCB(skb).dgram_peer = u->addr;
+		atomic_inc(&UNIXCB(skb).dgram_peer->refcnt);
+	}
+	skb->destructor = unix_skb_destruct_w;
+
 	err = unix_scm_to_skb(siocb->scm, skb, true);
 	if (err < 0)
 		goto out_free;
@@ -1579,7 +1624,7 @@ restart:
 			goto out_unlock;
 	}
 
-	if (unix_peer(other) != sk && unix_recvq_full(other)) {
+	if (unix_recvq_full(other) || unix_rmem_full(other, skb)) {
 		if (!timeo) {
 			err = -EAGAIN;
 			goto out_unlock;
@@ -1597,6 +1642,7 @@ restart:
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
 	maybe_add_creds(skb, sock, other);
+	unix_skb_set_owner_r(skb, sk, other);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1677,6 +1723,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if (!skb)
 			goto out_err;
 
+		skb->destructor = unix_skb_destruct_w;
+
 		/* Only send the fds in the first buffer */
 		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
 		if (err < 0) {
@@ -1760,13 +1808,12 @@ static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
 	return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
 }
 
-static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
+static void unix_copy_addr(struct msghdr *msg,
+			   struct unix_address *ua)
 {
-	struct unix_sock *u = unix_sk(sk);
-
-	if (u->addr) {
-		msg->msg_namelen = u->addr->len;
-		memcpy(msg->msg_name, u->addr->name, u->addr->len);
+	if (ua) {
+		msg->msg_namelen = ua->len;
+		memcpy(msg->msg_name, ua->name, ua->len);
 	}
 }
 
@@ -1810,7 +1857,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 					POLLOUT | POLLWRNORM | POLLWRBAND);
 
 	if (msg->msg_name)
-		unix_copy_addr(msg, skb->sk);
+		unix_copy_addr(msg, UNIXCB(skb).dgram_peer);
 
 	if (size > skb->len - skip)
 		size = skb->len - skip;
@@ -2013,7 +2060,7 @@ again:
 
 		/* Copy address just once */
 		if (sunaddr) {
-			unix_copy_addr(msg, skb->sk);
+			unix_copy_addr(msg, unix_sk(skb->sk)->addr);
 			sunaddr = NULL;
 		}
 
@@ -2237,11 +2284,9 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
 	if (other) {
-		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
-			if (unix_recvq_full(other))
-				writable = 0;
-		}
+		sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
+		if (unix_recvq_full(other) || !unix_other_writable(other))
+			writable = 0;
 		sock_put(other);
 	}
 
-- 
1.8.5.3
