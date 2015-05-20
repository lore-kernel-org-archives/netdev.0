From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 4/4] net: af_unix: implement splice for stream af_unix sockets
Date: Wed, 20 May 2015 17:35:08 +0200
Message-ID: <3552a4927029e9504f4d4b4e5de4908ab053a5dc.1432135413.git.hannes@stressinduktion.org>
References: <cover.1432135413.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:47391 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbbETPm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:42:26 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 4B79820AC5
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:18 -0400 (EDT)
Received: from stressinduktion.org (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id CF67C6801D6
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:35:17 -0400 (EDT)
In-Reply-To: <cover.1432135413.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1432135413.git.hannes@stressinduktion.org>
References: <cover.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_stream_recvmsg is refactored to unix_stream_read_generic in this
patch and enhanced to deal with pipe splicing. The refactoring is
inneglible, we mostly have to deal with a non-existing struct msghdr
argument.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/unix/af_unix.c | 141 +++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 120 insertions(+), 21 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 9bb880a..d2d3ebf 100644
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
 
@@ -1963,8 +1967,9 @@ out:
  *	Sleep until more data has arrived. But check for races..
  */
 static long unix_stream_data_wait(struct sock *sk, long timeo,
-				  struct sk_buff *last)
+				  struct sk_buff *last, unsigned int last_len)
 {
+	struct sk_buff *tail;
 	DEFINE_WAIT(wait);
 
 	unix_state_lock(sk);
@@ -1972,7 +1977,9 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 	for (;;) {
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
-		if (skb_peek_tail(&sk->sk_receive_queue) != last ||
+		tail = skb_peek_tail(&sk->sk_receive_queue);
+		if (tail != last ||
+		    (tail && tail->len != last_len) ||
 		    sk->sk_err ||
 		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current) ||
@@ -1996,38 +2003,51 @@ static unsigned int unix_skb_len(const struct sk_buff *skb)
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
+static __always_inline
+int unix_stream_read_generic(struct unix_stream_read_state *state)
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
@@ -2043,6 +2063,7 @@ static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 
 		unix_state_lock(sk);
 		last = skb = skb_peek(&sk->sk_receive_queue);
+		last_len = last ? last->len : 0;
 again:
 		if (skb == NULL) {
 			unix_sk(sk)->recursion_level = 0;
@@ -2065,16 +2086,17 @@ again:
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
@@ -2083,6 +2105,7 @@ again:
 		while (skip >= unix_skb_len(skb)) {
 			skip -= unix_skb_len(skb);
 			last = skb;
+			last_len = skb->len;
 			skb = skb_peek_next(skb, &sk->sk_receive_queue);
 			if (!skb)
 				goto again;
@@ -2099,18 +2122,20 @@ again:
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
@@ -2148,11 +2173,85 @@ again:
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
