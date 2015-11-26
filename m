From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] af-unix: passcred support for sendpage
Date: Thu, 26 Nov 2015 12:08:18 +0100
Message-ID: <1448536098-8980-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:38983 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750698AbbKZLIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 06:08:31 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 56B0220797
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:08:30 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sendpage did not care about credentials at all. This could lead to
situations in which because of fd passing between processes we could
append data to skbs with different scm data. It is illegal to splice those
skbs together. Instead we have to allocate a new skb and if requested
fill out the scm details.

Fixes: 869e7c62486ec ("net: af_unix: implement stream sendpage support")
Reported-by: Al Viro <viro@zeniv.linux.org.uk>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/unix/af_unix.c | 79 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 64 insertions(+), 15 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4e95bdf..6ced746 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1551,6 +1551,14 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	return err;
 }
 
+static bool unix_passcred_enabled(const struct socket *sock,
+				  const struct sock *other)
+{
+	return test_bit(SOCK_PASSCRED, &sock->flags) ||
+	       !other->sk_socket ||
+	       test_bit(SOCK_PASSCRED, &other->sk_socket->flags);
+}
+
 /*
  * Some apps rely on write() giving SCM_CREDENTIALS
  * We include credentials if source or destination socket
@@ -1561,14 +1569,41 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 {
 	if (UNIXCB(skb).pid)
 		return;
-	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
-	    !other->sk_socket ||
-	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
+	if (unix_passcred_enabled(sock, other)) {
 		UNIXCB(skb).pid  = get_pid(task_tgid(current));
 		current_uid_gid(&UNIXCB(skb).uid, &UNIXCB(skb).gid);
 	}
 }
 
+static int maybe_init_creds(struct scm_cookie *scm,
+			    struct socket *socket,
+			    const struct sock *other)
+{
+	int err;
+	struct msghdr msg = { .msg_controllen = 0 };
+
+	err = scm_send(socket, &msg, scm, false);
+	if (err)
+		return err;
+
+	if (unix_passcred_enabled(socket, other)) {
+		scm->pid = get_pid(task_tgid(current));
+		current_uid_gid(&scm->creds.uid, &scm->creds.gid);
+	}
+	return err;
+}
+
+static bool unix_skb_scm_eq(struct sk_buff *skb,
+			    struct scm_cookie *scm)
+{
+	const struct unix_skb_parms *u = &UNIXCB(skb);
+
+	return u->pid == scm->pid &&
+	       uid_eq(u->uid, scm->creds.uid) &&
+	       gid_eq(u->gid, scm->creds.gid) &&
+	       unix_secdata_eq(scm, skb);
+}
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1884,8 +1919,10 @@ out_err:
 static ssize_t unix_stream_sendpage(struct socket *socket, struct page *page,
 				    int offset, size_t size, int flags)
 {
-	int err = 0;
-	bool send_sigpipe = true;
+	int err;
+	bool send_sigpipe = false;
+	bool init_scm = true;
+	struct scm_cookie scm;
 	struct sock *other, *sk = socket->sk;
 	struct sk_buff *skb, *newskb = NULL, *tail = NULL;
 
@@ -1903,7 +1940,7 @@ alloc_skb:
 		newskb = sock_alloc_send_pskb(sk, 0, 0, flags & MSG_DONTWAIT,
 					      &err, 0);
 		if (!newskb)
-			return err;
+			goto err;
 	}
 
 	/* we must acquire readlock as we modify already present
@@ -1912,12 +1949,12 @@ alloc_skb:
 	err = mutex_lock_interruptible(&unix_sk(other)->readlock);
 	if (err) {
 		err = flags & MSG_DONTWAIT ? -EAGAIN : -ERESTARTSYS;
-		send_sigpipe = false;
 		goto err;
 	}
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		err = -EPIPE;
+		send_sigpipe = true;
 		goto err_unlock;
 	}
 
@@ -1926,17 +1963,27 @@ alloc_skb:
 	if (sock_flag(other, SOCK_DEAD) ||
 	    other->sk_shutdown & RCV_SHUTDOWN) {
 		err = -EPIPE;
+		send_sigpipe = true;
 		goto err_state_unlock;
 	}
 
+	if (init_scm) {
+		err = maybe_init_creds(&scm, socket, other);
+		if (err)
+			goto err_state_unlock;
+		init_scm = false;
+	}
+
 	skb = skb_peek_tail(&other->sk_receive_queue);
 	if (tail && tail == skb) {
 		skb = newskb;
-	} else if (!skb) {
-		if (newskb)
+	} else if (!skb || !unix_skb_scm_eq(skb, &scm)) {
+		if (newskb) {
 			skb = newskb;
-		else
+		} else {
+			tail = skb;
 			goto alloc_skb;
+		}
 	} else if (newskb) {
 		/* this is fast path, we don't necessarily need to
 		 * call to kfree_skb even though with newskb == NULL
@@ -1957,6 +2004,9 @@ alloc_skb:
 	atomic_add(size, &sk->sk_wmem_alloc);
 
 	if (newskb) {
+		err = unix_scm_to_skb(&scm, skb, false);
+		if (err)
+			goto err_state_unlock;
 		spin_lock(&other->sk_receive_queue.lock);
 		__skb_queue_tail(&other->sk_receive_queue, newskb);
 		spin_unlock(&other->sk_receive_queue.lock);
@@ -1966,7 +2016,7 @@ alloc_skb:
 	mutex_unlock(&unix_sk(other)->readlock);
 
 	other->sk_data_ready(other);
-
+	scm_destroy(&scm);
 	return size;
 
 err_state_unlock:
@@ -1977,6 +2027,8 @@ err:
 	kfree_skb(newskb);
 	if (send_sigpipe && !(flags & MSG_NOSIGNAL))
 		send_sig(SIGPIPE, current, 0);
+	if (!init_scm)
+		scm_destroy(&scm);
 	return err;
 }
 
@@ -2280,10 +2332,7 @@ unlock:
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
-			if ((UNIXCB(skb).pid  != scm.pid) ||
-			    !uid_eq(UNIXCB(skb).uid, scm.creds.uid) ||
-			    !gid_eq(UNIXCB(skb).gid, scm.creds.gid) ||
-			    !unix_secdata_eq(&scm, skb))
+			if (!unix_skb_scm_eq(skb, &scm))
 				break;
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
-- 
2.5.0
