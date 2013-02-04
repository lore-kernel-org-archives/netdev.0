From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending
Date: Tue, 5 Feb 2013 00:14:14 +0100
Message-ID: <20130204231414.GD6898@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yannick@koehler.name, eric.dumazet@gmail.com,
	xiyou.wangcong@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43649 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755306Ab3BDXOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 18:14:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I justed sketched up a patch on how to account unix domain dgram socket buffer
to the receiving sock. This problem has been brought up by Yannick Koehler
here: http://article.gmane.org/gmane.linux.network/256128

I still miss proper poll() handling and am working out on how to introduce
the sysctl unix_dgram_*mem* vectors (need to figuire out correct socket
lock handling). Eric mentioned that calling sock_rfree without socket lock
is wrong, but I hope that this is only the case if memory accounting is
taking place (as currently isn't with this patch)? Otherwise I am glad
to hear advises on how to handle the POLLOUT|POLLWRNORM|... case.

Is sticking the unix address into the skbs unixcb a viable solution?

(Patch should work with 3.8-rc6)

Thanks:

[PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending

In case of unix datagram sockets, skb memory was only accounted in the
sending socket's sk_wmem_alloc. Hence, if one receiver would stop to
receive frames on its socket, the sending socket's send buffer space
could get exhausted and the socket would block sending datagrams to
other destionations, too.

This patch places the refcounted peer's unix address for AF_UNIX
SOCK_DGRAM sockets into the skb's UNIXCB. So a reference from the skb
to the receiving struct sock can be set and so enables to do proper skb
destructor handling for rmem and wmem. Buffer memory is then accounted
to the receiving socket. If the socket rmem is exhausted the normal
blocking and timeout behaviour kicks in.

Based on the patches from Yannick Koehler and Cong Wang.

Reported-by: Yannick Koehler <yannick@koehler.name>
CC: Yannick Koehler <yannick@koehler.name>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 61 +++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 51 insertions(+), 11 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 0a996a3..a618a2e 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -31,6 +31,7 @@ struct unix_skb_parms {
 	struct pid		*pid;		/* Skb credentials	*/
 	const struct cred	*cred;
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	struct unix_address	*peer_address;
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
 #endif
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5b5c876..73d1436 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -184,6 +184,12 @@ static inline int unix_recvq_full(struct sock const *sk)
 	return skb_queue_len(&sk->sk_receive_queue) > sk->sk_max_ack_backlog;
 }
 
+static inline bool unix_rmem_full(struct sock const *sk,
+				  struct sk_buff const *skb)
+{
+	return sk_rmem_alloc_get(sk) + skb->truesize > sk->sk_rcvbuf;
+}
+
 struct sock *unix_peer_get(struct sock *s)
 {
 	struct sock *peer;
@@ -637,6 +643,8 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 		goto out;
 
 	sock_init_data(sock, sk);
+	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_SEQPACKET)
+		sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 	lockdep_set_class(&sk->sk_receive_queue.lock,
 				&af_unix_sk_receive_queue_lock_key);
 
@@ -1338,7 +1346,7 @@ static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 		unix_notinflight(scm->fp->fp[i]);
 }
 
-static void unix_destruct_scm(struct sk_buff *skb)
+static inline void __unix_skb_destruct(struct sk_buff *skb)
 {
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
@@ -1350,6 +1358,19 @@ static void unix_destruct_scm(struct sk_buff *skb)
 	/* Alas, it calls VFS */
 	/* So fscking what? fput() had been SMP-safe since the last Summer */
 	scm_destroy(&scm);
+	if (UNIXCB(skb).peer_address)
+		unix_release_addr(UNIXCB(skb).peer_address);
+}
+
+static void unix_skb_destruct_r(struct sk_buff *skb)
+{
+	__unix_skb_destruct(skb);
+	sock_rfree(skb);
+}
+
+static void unix_skb_destruct_w(struct sk_buff *skb)
+{
+	__unix_skb_destruct(skb);
 	sock_wfree(skb);
 }
 
@@ -1400,7 +1421,7 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
-	skb->destructor = unix_destruct_scm;
+	skb->destructor = unix_skb_destruct_w;
 	return err;
 }
 
@@ -1422,6 +1443,19 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 	}
 }
 
+static void unix_skb_set_owner_r(struct sk_buff *skb, struct sock *oldsk,
+					struct sock *newsk)
+{
+	WARN_ON(!sock_flag(oldsk, SOCK_USE_WRITE_QUEUE));
+	WARN_ON(skb->sk != oldsk);
+	sock_wfree(skb);
+	skb->sk = newsk;
+	skb->destructor = unix_skb_destruct_r;
+	atomic_add(skb->truesize, &newsk->sk_rmem_alloc);
+	WARN_ON(sk_has_account(newsk));
+	sk_mem_charge(newsk, skb->truesize); /* nop */
+}
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1486,6 +1520,11 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
+	if (u->addr) {
+		UNIXCB(skb).peer_address = u->addr;
+		atomic_inc(&UNIXCB(skb).peer_address->refcnt);
+	}
+
 	err = unix_scm_to_skb(siocb->scm, skb, true);
 	if (err < 0)
 		goto out_free;
@@ -1561,7 +1600,8 @@ restart:
 			goto out_unlock;
 	}
 
-	if (unix_peer(other) != sk && unix_recvq_full(other)) {
+	if ((unix_peer(other) != sk && unix_recvq_full(other)) ||
+	    unix_rmem_full(other, skb)) {
 		if (!timeo) {
 			err = -EAGAIN;
 			goto out_unlock;
@@ -1579,6 +1619,7 @@ restart:
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
 	maybe_add_creds(skb, sock, other);
+	unix_skb_set_owner_r(skb, sk, other);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1751,14 +1792,12 @@ static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
 	return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
 }
 
-static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
+static void unix_copy_addr(struct msghdr *msg, struct unix_address *ua)
 {
-	struct unix_sock *u = unix_sk(sk);
-
 	msg->msg_namelen = 0;
-	if (u->addr) {
-		msg->msg_namelen = u->addr->len;
-		memcpy(msg->msg_name, u->addr->name, u->addr->len);
+	if (ua) {
+		msg->msg_namelen = ua->len;
+		memcpy(msg->msg_name, ua->name, ua->len);
 	}
 }
 
@@ -1804,7 +1843,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 					POLLOUT | POLLWRNORM | POLLWRBAND);
 
 	if (msg->msg_name)
-		unix_copy_addr(msg, skb->sk);
+		unix_copy_addr(msg, UNIXCB(skb).peer_address);
 
 	if (size > skb->len - skip)
 		size = skb->len - skip;
@@ -2004,7 +2043,7 @@ again:
 
 		/* Copy address just once */
 		if (sunaddr) {
-			unix_copy_addr(msg, skb->sk);
+			unix_copy_addr(msg, unix_sk(skb->sk)->addr);
 			sunaddr = NULL;
 		}
 
-- 
1.8.1
