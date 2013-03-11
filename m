From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending
Date: Mon, 11 Mar 2013 20:37:04 +0100
Message-ID: <20130311193704.GA24481@order.stressinduktion.org>
References: <20130204231414.GD6898@order.stressinduktion.org> <20130309214333.GI28531@order.stressinduktion.org> <1362889861.4051.15.camel@edumazet-glaptop> <20130310044043.GB2709@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yannick@koehler.name, xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57122 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223Ab3CKThG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:37:06 -0400
Content-Disposition: inline
In-Reply-To: <20130310044043.GB2709@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 05:40:43AM +0100, Hannes Frederic Sowa wrote:
> On Sun, Mar 10, 2013 at 05:31:01AM +0100, Eric Dumazet wrote:
> > Do you have a user test program ?
> 
> I used a couple of perl scripts. I'll bring them in shape and will post them
> here, hopefully tomorrow.

Did not have enough time yesterday, so now here they are. I just
copy and pasted them together (the code is ugly, sorry). Last test
(test_send_multiple) should fail on current kernels and should work on
kernels with this patch applied (please increase max_dgram_qlen on as
it should not be the limiting factor):

  https://gist.github.com/hannes/5136858

or

  git clone https://gist.github.com/5136858.git

While doing this I added a testcase for poll on self-connected sockets. I
did report a writeable socket here, while in fact it is not. I fixed
this case by removing the 'if (unix_peer(other) != sk)' check in
unix_dgram_poll because it is not necessary anymore.

Two other changes are rather cosmetic: I replaced
atomic_read(&sk->sk_{r,w}mem_alloc) with sk_{r,w}mem_alloc_get.

The thing I am a bit nervous about is the handling of unix_write_space. I
disabled the call in sock_wfree (by setting SOCK_USE_WRITE_QUEUE)  because
I am unsure if we can call sk_wake_async without the socket lock, which
would interfere with the unix_state spinlocks. Otherwise I think it is called
later on without socket lock, too. So I am tempted to remove this hunk from
the patch because otherwise sleeping processes in sock_alloc_send_pskb would
not be woken up.

[PATCH net-next RFC] unix: account skb memory to receiving socket's sk_rmem_alloc on sending

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

Resource exhausion protection for unix dgram sockets is now based
only on sockets rmem checking. Unix dgram sockets do not rely on
sk_max_ack_backlog anymore. The controls for this are
/proc/sys/net/core/{r,w}mem_{default,max}.

This patch also changes the reporting of unix dgram rqueue size, as it
now reports not only the size of the first fragment but the amount of
readable memory for the socket.

Based on the patches from Yannick Koehler and Cong Wang.

Reported-by: Yannick Koehler <yannick@koehler.name>
CC: Yannick Koehler <yannick@koehler.name>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/af_unix.h |  1 +
 net/unix/af_unix.c    | 81 ++++++++++++++++++++++++++++++++++++++-------------
 net/unix/diag.c       |  4 ++-
 3 files changed, 65 insertions(+), 21 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 0a996a3..3855fcc 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -31,6 +31,7 @@ struct unix_skb_parms {
 	struct pid		*pid;		/* Skb credentials	*/
 	const struct cred	*cred;
 	struct scm_fp_list	*fp;		/* Passed files		*/
+	struct unix_address	*peer_address;	/* only used for dgram	*/
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
 #endif
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51be64f..7caf111 100644
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
@@ -316,7 +322,12 @@ found:
 
 static inline int unix_writable(struct sock *sk)
 {
-	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
+	return (sk_wmem_alloc_get(sk) << 2) <= sk->sk_sndbuf;
+}
+
+static inline bool unix_other_writable(struct sock *sk)
+{
+	return (sk_rmem_alloc_get(sk) << 2) <= sk->sk_rcvbuf;
 }
 
 static void unix_write_space(struct sock *sk)
@@ -635,6 +646,8 @@ static struct sock *unix_create1(struct net *net, struct socket *sock)
 		goto out;
 
 	sock_init_data(sock, sk);
+	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_SEQPACKET)
+		sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 	lockdep_set_class(&sk->sk_receive_queue.lock,
 				&af_unix_sk_receive_queue_lock_key);
 
@@ -1032,14 +1045,18 @@ out:
 static long unix_wait_for_peer(struct sock *other, long timeo)
 {
 	struct unix_sock *u = unix_sk(other);
-	int sched;
+	bool sched;
 	DEFINE_WAIT(wait);
 
 	prepare_to_wait_exclusive(&u->peer_wait, &wait, TASK_INTERRUPTIBLE);
 
 	sched = !sock_flag(other, SOCK_DEAD) &&
-		!(other->sk_shutdown & RCV_SHUTDOWN) &&
-		unix_recvq_full(other);
+		!(other->sk_shutdown & RCV_SHUTDOWN);
+
+	if (other->sk_type == SOCK_DGRAM || other->sk_type == SOCK_SEQPACKET)
+		sched = sched && unix_other_writable(other);
+	else
+		sched = sched && unix_recvq_full(other);
 
 	unix_state_unlock(other);
 
@@ -1336,7 +1353,7 @@ static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 		unix_notinflight(scm->fp->fp[i]);
 }
 
-static void unix_destruct_scm(struct sk_buff *skb)
+static inline void __unix_skb_destruct(struct sk_buff *skb)
 {
 	struct scm_cookie scm;
 	memset(&scm, 0, sizeof(scm));
@@ -1348,6 +1365,19 @@ static void unix_destruct_scm(struct sk_buff *skb)
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
 
@@ -1398,7 +1428,7 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
 	if (scm->fp && send_fds)
 		err = unix_attach_fds(scm, skb);
 
-	skb->destructor = unix_destruct_scm;
+	skb->destructor = unix_skb_destruct_w;
 	return err;
 }
 
@@ -1420,6 +1450,15 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 	}
 }
 
+static void unix_skb_set_owner_r(struct sk_buff *skb, struct sock *oldsk,
+				 struct sock *newsk)
+{
+	sock_wfree(skb);
+	skb->sk = newsk;
+	skb->destructor = unix_skb_destruct_r;
+	atomic_add(skb->truesize, &newsk->sk_rmem_alloc);
+}
+
 /*
  *	Send AF_UNIX data.
  */
@@ -1484,6 +1523,11 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
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
@@ -1559,7 +1603,7 @@ restart:
 			goto out_unlock;
 	}
 
-	if (unix_peer(other) != sk && unix_recvq_full(other)) {
+	if (unix_rmem_full(other, skb)) {
 		if (!timeo) {
 			err = -EAGAIN;
 			goto out_unlock;
@@ -1577,6 +1621,7 @@ restart:
 	if (sock_flag(other, SOCK_RCVTSTAMP))
 		__net_timestamp(skb);
 	maybe_add_creds(skb, sock, other);
+	unix_skb_set_owner_r(skb, sk, other);
 	skb_queue_tail(&other->sk_receive_queue, skb);
 	if (max_level > unix_sk(other)->recursion_level)
 		unix_sk(other)->recursion_level = max_level;
@@ -1749,14 +1794,12 @@ static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
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
 
@@ -1802,7 +1845,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 					POLLOUT | POLLWRNORM | POLLWRBAND);
 
 	if (msg->msg_name)
-		unix_copy_addr(msg, skb->sk);
+		unix_copy_addr(msg, UNIXCB(skb).peer_address);
 
 	if (size > skb->len - skip)
 		size = skb->len - skip;
@@ -2002,7 +2045,7 @@ again:
 
 		/* Copy address just once */
 		if (sunaddr) {
-			unix_copy_addr(msg, skb->sk);
+			unix_copy_addr(msg, unix_sk(skb->sk)->addr);
 			sunaddr = NULL;
 		}
 
@@ -2223,11 +2266,9 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
 	if (other) {
-		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
-			if (unix_recvq_full(other))
-				writable = 0;
-		}
+		sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
+		if (!unix_other_writable(other))
+			writable = 0;
 		sock_put(other);
 	}
 
diff --git a/net/unix/diag.c b/net/unix/diag.c
index d591091..41a38ec 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -102,7 +102,9 @@ static int sk_diag_show_rqlen(struct sock *sk, struct sk_buff *nlskb)
 		rql.udiag_rqueue = sk->sk_receive_queue.qlen;
 		rql.udiag_wqueue = sk->sk_max_ack_backlog;
 	} else {
-		rql.udiag_rqueue = (u32) unix_inq_len(sk);
+		rql.udiag_rqueue = (u32) (sk->sk_type == SOCK_DGRAM ?
+					  sk_rmem_alloc_get(sk) :
+					  unix_inq_len(sk));
 		rql.udiag_wqueue = (u32) unix_outq_len(sk);
 	}
 
-- 
1.8.1.4
