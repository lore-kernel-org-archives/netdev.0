From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v3 net-next 4/4] net: af_unix: implement splice for stream af_unix sockets
Date: Thu, 21 May 2015 17:00:01 +0200
Message-ID: <2608f83f33225b05eb8a4bf0275f05dce83edfd3.1432220158.git.hannes@stressinduktion.org>
References: <cover.1432220158.git.hannes@stressinduktion.org>
Cc: edumazet@google.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:35434 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755652AbbEUPAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 11:00:11 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 7927D2096D
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 11:00:10 -0400 (EDT)
In-Reply-To: <cover.1432220158.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1432220158.git.hannes@stressinduktion.org>
References: <cover.1432220158.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_stream_recvmsg is refactored to unix_stream_read_generic in this
patch and enhanced to deal with pipe splicing. The refactoring is
inneglible, we mostly have to deal with a non-existing struct msghdr
argument.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
* checked that CONFIG_UNIX=m still works, added necessary EXPORT_SYMBOL_GPLss
  (thanks, Eric!)

v3:
* removed __always_inline keyword (thanks, Eric!)

 fs/splice.c        |   1 +
 net/core/skbuff.c  |   1 +
 net/unix/af_unix.c | 140 +++++++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 121 insertions(+), 21 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index bfe62ae..4f355a1 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -261,6 +261,7 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(splice_to_pipe);
 
 void spd_release_page(struct splice_pipe_desc *spd, unsigned int i)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 02769fa..9bac0e6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1942,6 +1942,7 @@ done:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(skb_splice_bits);
 
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7762c0b..b8c4407 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -520,6 +520,9 @@ static int unix_stream_sendmsg(struct socket *, struct msghdr *, size_t);
 static int unix_stream_recvmsg(struct socket *, struct msghdr *, size_t, int);
 static ssize_t unix_stream_sendpage(struct socket *, struct page *, int offset,
 				    size_t size, int flags);
+static ssize_t unix_stream_splice_read(struct socket *,  loff_t *ppos,
+				       struct pipe_inode_info *, size_t size,
+				       unsigned int flags);
 static int unix_dgram_sendmsg(struct socket *, struct msghdr *, size_t);
 static int unix_dgram_recvmsg(struct socket *, struct msghdr *, size_t, int);
 static int unix_dgram_connect(struct socket *, struct sockaddr *,
@@ -561,6 +564,7 @@ static const struct proto_ops unix_stream_ops = {
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	unix_stream_sendpage,
+	.splice_read =	unix_stream_splice_read,
 	.set_peek_off =	unix_set_peek_off,
 };
 
@@ -1957,8 +1961,9 @@ out:
  *	Sleep until more data has arrived. But check for races..
  */
 static long unix_stream_data_wait(struct sock *sk, long timeo,
-				  struct sk_buff *last)
+				  struct sk_buff *last, unsigned int last_len)
 {
+	struct sk_buff *tail;
 	DEFINE_WAIT(wait);
 
 	unix_state_lock(sk);
@@ -1966,7 +1971,9 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
-		if (skb_peek_tail(&sk->sk_receive_queue) != last ||
+		tail = skb_peek_tail(&sk->sk_receive_queue);
+		if (tail != last ||
+		    (tail && tail->len != last_len) ||
 		    sk->sk_err ||
 		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current) ||
@@ -1990,38 +1997,50 @@ static unsigned int unix_skb_len(const struct sk_buff *skb)
 	return skb->len - UNIXCB(skb).consumed;
 }
 
-static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
-			       size_t size, int flags)
+struct unix_stream_read_state {
+	int (*recv_actor)(struct sk_buff *, int, int,
+			  struct unix_stream_read_state *);
+	struct socket *socket;
+	struct msghdr *msg;
+	struct pipe_inode_info *pipe;
+	size_t size;
+	int flags;
+	unsigned int splice_flags;
+};
+
+static int unix_stream_read_generic(struct unix_stream_read_state *state)
 {
 	struct scm_cookie scm;
+	struct socket *sock = state->socket;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
-	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
 	int copied = 0;
+	int flags = state->flags;
 	int noblock = flags & MSG_DONTWAIT;
-	int check_creds = 0;
+	bool check_creds = false;
 	int target;
 	int err = 0;
 	long timeo;
 	int skip;
+	size_t size = state->size;
+	unsigned int last_len;
 
 	err = -EINVAL;
 	if (sk->sk_state != TCP_ESTABLISHED)
 		goto out;
 
 	err = -EOPNOTSUPP;
-	if (flags&MSG_OOB)
+	if (flags & MSG_OOB)
 		goto out;
 
-	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
 	timeo = sock_rcvtimeo(sk, noblock);
 
+	memset(&scm, 0, sizeof(scm));
+
 	/* Lock the socket to prevent queue disordering
 	 * while sleeps in memcpy_tomsg
 	 */
-
-	memset(&scm, 0, sizeof(scm));
-
 	err = mutex_lock_interruptible(&u->readlock);
 	if (unlikely(err)) {
 		/* recvmsg() in non blocking mode is supposed to return -EAGAIN
@@ -2037,6 +2056,7 @@ static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 
 		unix_state_lock(sk);
 		last = skb = skb_peek(&sk->sk_receive_queue);
+		last_len = last ? last->len : 0;
 again:
 		if (skb == NULL) {
 			unix_sk(sk)->recursion_level = 0;
@@ -2059,16 +2079,17 @@ again:
 				break;
 			mutex_unlock(&u->readlock);
 
-			timeo = unix_stream_data_wait(sk, timeo, last);
+			timeo = unix_stream_data_wait(sk, timeo, last,
+						      last_len);
 
-			if (signal_pending(current)
-			    ||  mutex_lock_interruptible(&u->readlock)) {
+			if (signal_pending(current) ||
+			    mutex_lock_interruptible(&u->readlock)) {
 				err = sock_intr_errno(timeo);
 				goto out;
 			}
 
 			continue;
- unlock:
+unlock:
 			unix_state_unlock(sk);
 			break;
 		}
@@ -2077,6 +2098,7 @@ again:
 		while (skip >= unix_skb_len(skb)) {
 			skip -= unix_skb_len(skb);
 			last = skb;
+			last_len = skb->len;
 			skb = skb_peek_next(skb, &sk->sk_receive_queue);
 			if (!skb)
 				goto again;
@@ -2093,18 +2115,20 @@ again:
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
 			scm_set_cred(&scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
-			check_creds = 1;
+			check_creds = true;
 		}
 
 		/* Copy address just once */
-		if (sunaddr) {
-			unix_copy_addr(msg, skb->sk);
+		if (state->msg && state->msg->msg_name) {
+			DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr,
+					 state->msg->msg_name);
+			unix_copy_addr(state->msg, skb->sk);
 			sunaddr = NULL;
 		}
 
 		chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
-		if (skb_copy_datagram_msg(skb, UNIXCB(skb).consumed + skip,
-					  msg, chunk)) {
+		chunk = state->recv_actor(skb, skip, chunk, state);
+		if (chunk < 0) {
 			if (copied == 0)
 				copied = -EFAULT;
 			break;
@@ -2142,11 +2166,85 @@ again:
 	} while (size);
 
 	mutex_unlock(&u->readlock);
-	scm_recv(sock, msg, &scm, flags);
+	if (state->msg)
+		scm_recv(sock, state->msg, &scm, flags);
+	else
+		scm_destroy(&scm);
 out:
 	return copied ? : err;
 }
 
+static int unix_stream_read_actor(struct sk_buff *skb,
+				  int skip, int chunk,
+				  struct unix_stream_read_state *state)
+{
+	int ret;
+
+	ret = skb_copy_datagram_msg(skb, UNIXCB(skb).consumed + skip,
+				    state->msg, chunk);
+	return ret ?: chunk;
+}
+
+static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
+			       size_t size, int flags)
+{
+	struct unix_stream_read_state state = {
+		.recv_actor = unix_stream_read_actor,
+		.socket = sock,
+		.msg = msg,
+		.size = size,
+		.flags = flags
+	};
+
+	return unix_stream_read_generic(&state);
+}
+
+static ssize_t skb_unix_socket_splice(struct sock *sk,
+				      struct pipe_inode_info *pipe,
+				      struct splice_pipe_desc *spd)
+{
+	int ret;
+	struct unix_sock *u = unix_sk(sk);
+
+	mutex_unlock(&u->readlock);
+	ret = splice_to_pipe(pipe, spd);
+	mutex_lock(&u->readlock);
+
+	return ret;
+}
+
+static int unix_stream_splice_actor(struct sk_buff *skb,
+				    int skip, int chunk,
+				    struct unix_stream_read_state *state)
+{
+	return skb_splice_bits(skb, state->socket->sk,
+			       UNIXCB(skb).consumed + skip,
+			       state->pipe, chunk, state->splice_flags,
+			       skb_unix_socket_splice);
+}
+
+static ssize_t unix_stream_splice_read(struct socket *sock,  loff_t *ppos,
+				       struct pipe_inode_info *pipe,
+				       size_t size, unsigned int flags)
+{
+	struct unix_stream_read_state state = {
+		.recv_actor = unix_stream_splice_actor,
+		.socket = sock,
+		.pipe = pipe,
+		.size = size,
+		.splice_flags = flags,
+	};
+
+	if (unlikely(*ppos))
+		return -ESPIPE;
+
+	if (sock->file->f_flags & O_NONBLOCK ||
+	    flags & SPLICE_F_NONBLOCK)
+		state.flags = MSG_DONTWAIT;
+
+	return unix_stream_read_generic(&state);
+}
+
 static int unix_shutdown(struct socket *sock, int mode)
 {
 	struct sock *sk = sock->sk;
-- 
2.1.0
