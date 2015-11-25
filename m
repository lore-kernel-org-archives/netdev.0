From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: use-after-free in sock_wake_async
Date: Wed, 25 Nov 2015 09:11:34 -0800
Message-ID: <1448471494.24696.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	 <CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	 <87poyzj7j2.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iKg0Lc7OVLhxUOzPRr4OhEGxA8L7V1jyaqFAS6+7kEXTA@mail.gmail.com>
	 <87io4qevdp.fsf@doppelsaurus.mobileactivedefense.com>
	 <CANn89iJgW+6giMUicU1m831+mkaNy9z1hQB-ixvRHBqZo-7Yig@mail.gmail.com>
	 <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33312 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbKYRLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 12:11:36 -0500
In-Reply-To: <87io4q3u8u.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 16:43 +0000, Rainer Weikusat wrote:
> Eric Dumazet <edumazet@google.com> writes:
> > On Tue, Nov 24, 2015 at 5:10 PM, Rainer Weikusat
> > <rweikusat@mobileactivedefense.com> wrote:
> 
> [...]
> 
> >> It's also easy to verify: Swap the unix_state_lock and
> >> other->sk_data_ready and see if the issue still occurs. Right now (this
> >> may change after I had some sleep as it's pretty late for me), I don't
> >> think there's another local fix: The ->sk_data_ready accesses a
> >> pointer after the lock taken by the code which will clear and
> >> then later free it was released.
> >
> > It seems that :
> >
> > int sock_wake_async(struct socket *sock, int how, int band)
> >
> > should really be changed to
> >
> > int sock_wake_async(struct socket_wq *wq, int how, int band)
> >
> > So that RCU rules (already present) apply safely.
> >
> > sk->sk_socket is inherently racy (that is : racy without using
> > sk_callback_lock rwlock )
> 
> The comment above sock_wait_async states that
> 
> /* This function may be called only under socket lock or callback_lock or rcu_lock */
> 
> In this case, it's called via sk_wake_async (include/net/sock.h) which
> is - in turn - called via sock_def_readable (the 'default' data ready
> routine/ net/core/sock.c) which looks like this:
> 
> static void sock_def_readable(struct sock *sk)
> {
> 	struct socket_wq *wq;
> 
> 	rcu_read_lock();
> 	wq = rcu_dereference(sk->sk_wq);
> 	if (wq_has_sleeper(wq))
> 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
> 						POLLRDNORM | POLLRDBAND);
> 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
> 	rcu_read_unlock();
> }
> 
> and should thus satisfy the constraint documented by the comment (I
> didn't verify if the comment is actually correct, though).
> 
> Further - sorry about that - I think changing code in "half of the
> network stack" in order to avoid calling a certain routine which will
> only ever do something in case someone's using signal-driven I/O with an
> already acquired lock held is a terrifying idea. Because of this, I
> propose the following alternate patch which should also solve the
> problem by ensuring that the ->sk_data_ready activity happens before
> unix_release_sock/ sock_release get a chance to clear or free anything
> which will be needed.
> 
> In case this demonstrably causes other issues, a more complicated
> alternate idea (still restricting itself to changes to the af_unix code)
> would be to move the socket_wq structure to a dummy struct socket
> allocated by unix_release_sock and freed by the destructor.
> 
> ---
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 4e95bdf..5c87ea6 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1754,8 +1754,8 @@ restart_locked:
>         skb_queue_tail(&other->sk_receive_queue, skb);
>         if (max_level > unix_sk(other)->recursion_level)
>                 unix_sk(other)->recursion_level = max_level;
> -       unix_state_unlock(other);
>         other->sk_data_ready(other);
> +       unix_state_unlock(other);
>         sock_put(other);
>         scm_destroy(&scm);
>         return len;
> @@ -1860,8 +1860,8 @@ static int unix_stream_sendmsg(struct socket *sock, struct msghdr *msg,
>                 skb_queue_tail(&other->sk_receive_queue, skb);
>                 if (max_level > unix_sk(other)->recursion_level)
>                         unix_sk(other)->recursion_level = max_level;
> -               unix_state_unlock(other);
>                 other->sk_data_ready(other);
> +               unix_state_unlock(other);
>                 sent += size;
>         }
>  


The issue is way more complex than that.

We cannot prevent inode from disappearing.
We can not safely dereference "(struct socket *)->flags"

locking the 'struct sock' wont help at all.

Here is my current work/patch :

It ran for ~2 hours under stress without warning, but I want it to run
24 hours before official submission.


Note that moving flags into sk_wq will actually avoid one cache line
miss in fast path, so might give performance improvement.

This minimal patch only moves SOCK_ASYNC_NOSPACE and SOCK_ASYNC_WAITDATA
but we can move other flags later.

sock_wake_async() must not even attempt to deref a struct socket.

-> sock_wake_async(struct socket_wq *wq, int how, int band);

Thanks.

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 0aa6fdfb448a..6d4d4569447e 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -125,7 +125,7 @@ static int aead_wait_for_data(struct sock *sk, unsigned flags)
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
 
-	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	for (;;) {
 		if (signal_pending(current))
@@ -139,7 +139,7 @@ static int aead_wait_for_data(struct sock *sk, unsigned flags)
 	}
 	finish_wait(sk_sleep(sk), &wait);
 
-	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	return err;
 }
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index af31a0ee4057..ca9efe17db1a 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -212,7 +212,7 @@ static int skcipher_wait_for_wmem(struct sock *sk, unsigned flags)
 	if (flags & MSG_DONTWAIT)
 		return -EAGAIN;
 
-	set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	for (;;) {
 		if (signal_pending(current))
@@ -258,7 +258,7 @@ static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
 		return -EAGAIN;
 	}
 
-	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	for (;;) {
 		if (signal_pending(current))
@@ -272,7 +272,7 @@ static int skcipher_wait_for_data(struct sock *sk, unsigned flags)
 	}
 	finish_wait(sk_sleep(sk), &wait);
 
-	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 
 	return err;
 }
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 54036ae0a388..234a43fb7819 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -495,15 +495,19 @@ static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
 
 static void macvtap_sock_write_space(struct sock *sk)
 {
-	wait_queue_head_t *wqueue;
+	struct socket_wq *sk_wq;
 
-	if (!sock_writeable(sk) ||
-	    !test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
-		return;
-
-	wqueue = sk_sleep(sk);
-	if (wqueue && waitqueue_active(wqueue))
-		wake_up_interruptible_poll(wqueue, POLLOUT | POLLWRNORM | POLLWRBAND);
+	rcu_read_lock();
+	sk_wq = rcu_dereference(sk->sk_wq);
+	if (sock_writeable(sk) && sk_wq &&
+	    test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sk_wq->flags)) {
+
+		if (waitqueue_active(&sk_wq->wait))
+			wake_up_interruptible_poll(&sk_wq->wait,
+						   POLLOUT | POLLWRNORM |
+						   POLLWRBAND);
+	}
+	rcu_read_unlock();
 }
 
 static void macvtap_sock_destruct(struct sock *sk)
@@ -585,7 +589,7 @@ static unsigned int macvtap_poll(struct file *file, poll_table * wait)
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sock_writeable(&q->sk) ||
-	    (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &q->sock.flags) &&
+	    (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &q->wq.flags) &&
 	     sock_writeable(&q->sk)))
 		mask |= POLLOUT | POLLWRNORM;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b1878faea397..bda626e8a2ee 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1040,7 +1040,7 @@ static unsigned int tun_chr_poll(struct file *file, poll_table *wait)
 		mask |= POLLIN | POLLRDNORM;
 
 	if (sock_writeable(sk) ||
-	    (!test_and_set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags) &&
+	    (!test_and_set_bit(SOCKWQ_ASYNC_NOSPACE, &sk->sk_wq_raw->flags) &&
 	     sock_writeable(sk)))
 		mask |= POLLOUT | POLLWRNORM;
 
@@ -1482,22 +1482,23 @@ static struct rtnl_link_ops tun_link_ops __read_mostly = {
 
 static void tun_sock_write_space(struct sock *sk)
 {
+	struct socket_wq *sk_wq;
 	struct tun_file *tfile;
-	wait_queue_head_t *wqueue;
 
 	if (!sock_writeable(sk))
 		return;
 
-	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
-		return;
-
-	wqueue = sk_sleep(sk);
-	if (wqueue && waitqueue_active(wqueue))
-		wake_up_interruptible_sync_poll(wqueue, POLLOUT |
-						POLLWRNORM | POLLWRBAND);
-
-	tfile = container_of(sk, struct tun_file, sk);
-	kill_fasync(&tfile->fasync, SIGIO, POLL_OUT);
+	rcu_read_lock();
+	sk_wq = rcu_dereference(sk->sk_wq);
+	if (sk_wq && test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sk_wq->flags)) {
+		if (waitqueue_active(&sk_wq->wait))
+			wake_up_interruptible_sync_poll(&sk_wq->wait, POLLOUT |
+							POLLWRNORM | POLLWRBAND);
+
+		tfile = container_of(sk, struct tun_file, sk);
+		kill_fasync(&tfile->fasync, SIGIO, POLL_OUT);
+	}
+	rcu_read_unlock();
 }
 
 static int tun_sendmsg(struct socket *sock, struct msghdr *m, size_t total_len)
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 87e9d796cf7d..53a083f5ab20 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -421,7 +421,7 @@ static void lowcomms_write_space(struct sock *sk)
 
 	if (test_and_clear_bit(CF_APP_LIMITED, &con->flags)) {
 		con->sock->sk->sk_write_pending--;
-		clear_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &con->sock->wq->flags);
 	}
 
 	if (!test_and_set_bit(CF_WRITE_PENDING, &con->flags))
@@ -1448,7 +1448,7 @@ static void send_to_sock(struct connection *con)
 					      msg_flags);
 			if (ret == -EAGAIN || ret == 0) {
 				if (ret == -EAGAIN &&
-				    test_bit(SOCK_ASYNC_NOSPACE, &con->sock->flags) &&
+				    test_bit(SOCKWQ_ASYNC_NOSPACE, &con->sock->wq->flags) &&
 				    !test_and_set_bit(CF_APP_LIMITED, &con->flags)) {
 					/* Notify TCP that we're limited by the
 					 * application window size.
diff --git a/include/linux/net.h b/include/linux/net.h
index 70ac5e28e6b7..d29de6dfd057 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -34,8 +34,11 @@ struct inode;
 struct file;
 struct net;
 
-#define SOCK_ASYNC_NOSPACE	0
-#define SOCK_ASYNC_WAITDATA	1
+/* Historically, SOCKWQ_ASYNC_NOSPACE & SOCKWQ_ASYNC_WAITDATA were located
+ * in sock->flags, but moved into sk->sk_wq->flags to be RCU protected
+ */
+#define SOCKWQ_ASYNC_NOSPACE	0
+#define SOCKWQ_ASYNC_WAITDATA	1
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
@@ -89,6 +92,7 @@ struct socket_wq {
 	/* Note: wait MUST be first field of socket_wq */
 	wait_queue_head_t	wait;
 	struct fasync_struct	*fasync_list;
+	unsigned long		flags; /* %SOCKWQ_ASYNC_NOSPACE, etc */
 	struct rcu_head		rcu;
 } ____cacheline_aligned_in_smp;
 
@@ -96,7 +100,7 @@ struct socket_wq {
  *  struct socket - general BSD socket
  *  @state: socket state (%SS_CONNECTED, etc)
  *  @type: socket type (%SOCK_STREAM, etc)
- *  @flags: socket flags (%SOCK_ASYNC_NOSPACE, etc)
+ *  @flags: socket flags (%SOCK_NOSPACE, etc)
  *  @ops: protocol specific socket operations
  *  @file: File back pointer for gc
  *  @sk: internal networking protocol agnostic socket representation
@@ -109,7 +113,7 @@ struct socket {
 	short			type;
 	kmemcheck_bitfield_end(type);
 
-	unsigned long		flags;
+	unsigned long		flags; /* will soon be moved/merged with wq->flags */
 
 	struct socket_wq __rcu	*wq;
 
@@ -202,7 +206,7 @@ enum {
 	SOCK_WAKE_URG,
 };
 
-int sock_wake_async(struct socket *sk, int how, int band);
+int sock_wake_async(struct socket_wq *wq, int how, int band);
 int sock_register(const struct net_proto_family *fam);
 void sock_unregister(int family);
 int __sock_create(struct net *net, int family, int type, int proto,
diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4ba18d1..89adbcb7e3aa 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -384,8 +384,10 @@ struct sock {
 	int			sk_rcvbuf;
 
 	struct sk_filter __rcu	*sk_filter;
-	struct socket_wq __rcu	*sk_wq;
-
+	union {
+		struct socket_wq __rcu	*sk_wq;
+		struct socket_wq	*sk_wq_raw;
+	};
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
 #endif
@@ -2005,10 +2007,23 @@ static inline unsigned long sock_wspace(struct sock *sk)
 	return amt;
 }
 
-static inline void sk_wake_async(struct sock *sk, int how, int band)
+static inline void sk_set_bit(int nr, struct sock *sk)
+{
+	set_bit(nr, &sk->sk_wq_raw->flags);
+}
+
+static inline void sk_clear_bit(int nr, struct sock *sk)
 {
-	if (sock_flag(sk, SOCK_FASYNC))
-		sock_wake_async(sk->sk_socket, how, band);
+	clear_bit(nr, &sk->sk_wq_raw->flags);
+}
+
+static inline void sk_wake_async(const struct sock *sk, int how, int band)
+{
+	if (sock_flag(sk, SOCK_FASYNC)) {
+		rcu_read_lock();
+		sock_wake_async(rcu_dereference(sk->sk_wq), how, band);
+		rcu_read_unlock();
+	}
 }
 
 /* Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index a3bffd1ec2b4..70306cc9d814 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -271,11 +271,11 @@ static long bt_sock_data_wait(struct sock *sk, long timeo)
 		if (signal_pending(current) || !timeo)
 			break;
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	}
 
 	__set_current_state(TASK_RUNNING);
@@ -441,7 +441,7 @@ unsigned int bt_sock_poll(struct file *file, struct socket *sock,
 	if (!test_bit(BT_SK_SUSPEND, &bt_sk(sk)->flags) && sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index cc858919108e..d427a08d899c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -323,7 +323,7 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
 			!timeo)
 			break;
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA);
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
@@ -331,7 +331,7 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
 		if (sock_flag(sk, SOCK_DEAD))
 			break;
 
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	}
 
 	finish_wait(sk_sleep(sk), &wait);
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 617088aee21d..d62af69ad844 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -785,7 +785,7 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 	if (sock_writeable(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54bfb5a..9d79569935a3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1815,7 +1815,7 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
 {
 	DEFINE_WAIT(wait);
 
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 	for (;;) {
 		if (!timeo)
 			break;
@@ -1861,7 +1861,7 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 		if (sk_wmem_alloc_get(sk) < sk->sk_sndbuf)
 			break;
 
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		err = -EAGAIN;
 		if (!timeo)
@@ -2048,9 +2048,9 @@ int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb)
 	DEFINE_WAIT(wait);
 
 	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	rc = sk_wait_event(sk, timeo, skb_peek_tail(&sk->sk_receive_queue) != skb);
-	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	finish_wait(sk_sleep(sk), &wait);
 	return rc;
 }
diff --git a/net/core/stream.c b/net/core/stream.c
index d70f77a0c889..b96f7a79e544 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -39,7 +39,7 @@ void sk_stream_write_space(struct sock *sk)
 			wake_up_interruptible_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
-			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
+			sock_wake_async(wq, SOCK_WAKE_SPACE, POLL_OUT);
 		rcu_read_unlock();
 	}
 }
@@ -126,7 +126,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		current_timeo = vm_wait = (prandom_u32() % (HZ / 5)) + 2;
 
 	while (1) {
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 
@@ -139,7 +139,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 		}
 		if (signal_pending(current))
 			goto do_interrupted;
-		clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 		if (sk_stream_memory_free(sk) && !vm_wait)
 			break;
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index b5cf13a28009..41e65804ddf5 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -339,8 +339,7 @@ unsigned int dccp_poll(struct file *file, struct socket *sock,
 			if (sk_stream_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
-				set_bit(SOCK_ASYNC_NOSPACE,
-					&sk->sk_socket->flags);
+				sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 
 				/* Race breaker. If space is freed after
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 675cf94e04f8..eebf5ac8ce18 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1747,9 +1747,9 @@ static int dn_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		}
 
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		sk_wait_event(sk, &timeo, dn_data_ready(sk, queue, flags, target));
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		finish_wait(sk_sleep(sk), &wait);
 	}
 
@@ -2004,10 +2004,10 @@ static int dn_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 			}
 
 			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-			set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 			sk_wait_event(sk, &timeo,
 				      !dn_queue_too_long(scp, queue, flags));
-			clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 			finish_wait(sk_sleep(sk), &wait);
 			continue;
 		}
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c1728771cf89..c82cca18c90f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -517,8 +517,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 			if (sk_stream_is_writeable(sk)) {
 				mask |= POLLOUT | POLLWRNORM;
 			} else {  /* send SIGIO later */
-				set_bit(SOCK_ASYNC_NOSPACE,
-					&sk->sk_socket->flags);
+				sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 
 				/* Race breaker. If space is freed after
@@ -906,7 +905,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 			goto out_err;
 	}
 
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 	copied = 0;
@@ -1134,7 +1133,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	}
 
 	/* This should be in poll */
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index fcb2752419c6..435608c4306d 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1483,7 +1483,7 @@ unsigned int iucv_sock_poll(struct file *file, struct socket *sock,
 	if (sock_writeable(sk) && iucv_below_msglim(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index b7de0da46acd..ecf0a0196f18 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -572,7 +572,7 @@ static unsigned int llcp_sock_poll(struct file *file, struct socket *sock,
 	if (sock_writeable(sk) && sk->sk_state == LLCP_CONNECTED)
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	pr_debug("mask 0x%x\n", mask);
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index a40d3afe93b7..14c4e12c47b0 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -531,7 +531,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
 
 	/* this should be in poll */
-	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+	sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		return -EPIPE;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 897c01c029ca..157ffb68617a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6458,7 +6458,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	if (sctp_writeable(sk)) {
 		mask |= POLLOUT | POLLWRNORM;
 	} else {
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 		/*
 		 * Since the socket is not locked, the buffer
 		 * might be made available after the writeable check and
@@ -6808,18 +6808,25 @@ static void __sctp_write_space(struct sctp_association *asoc)
 			wake_up_interruptible(&asoc->wait);
 
 		if (sctp_writeable(sk)) {
-			wait_queue_head_t *wq = sk_sleep(sk);
+			struct socket_wq *sk_wq;
 
-			if (wq && waitqueue_active(wq))
-				wake_up_interruptible(wq);
+			rcu_read_lock();
+			sk_wq = rcu_dereference(sk->sk_wq);
+			if (sk_wq) {
+				wait_queue_head_t *wq = &sk_wq->wait;
 
-			/* Note that we try to include the Async I/O support
-			 * here by modeling from the current TCP/UDP code.
-			 * We have not tested with it yet.
-			 */
-			if (!(sk->sk_shutdown & SEND_SHUTDOWN))
-				sock_wake_async(sock,
-						SOCK_WAKE_SPACE, POLL_OUT);
+				if (waitqueue_active(wq))
+					wake_up_interruptible(wq);
+
+				/* Note that we try to include the Async I/O support
+				 * here by modeling from the current TCP/UDP code.
+				 * We have not tested with it yet.
+				 */
+				if (!(sk->sk_shutdown & SEND_SHUTDOWN))
+					sock_wake_async(sk_wq, SOCK_WAKE_SPACE,
+							POLL_OUT);
+			}
+			rcu_read_unlock();
 		}
 	}
 }
diff --git a/net/socket.c b/net/socket.c
index dd2c247c99e3..83a9770800f8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1058,25 +1058,18 @@ static int sock_fasync(int fd, struct file *filp, int on)
 
 /* This function may be called only under socket lock or callback_lock or rcu_lock */
 
-int sock_wake_async(struct socket *sock, int how, int band)
+int sock_wake_async(struct socket_wq *wq, int how, int band)
 {
-	struct socket_wq *wq;
-
-	if (!sock)
-		return -1;
-	rcu_read_lock();
-	wq = rcu_dereference(sock->wq);
-	if (!wq || !wq->fasync_list) {
-		rcu_read_unlock();
+	if (!wq || !wq->fasync_list)
 		return -1;
-	}
+
 	switch (how) {
 	case SOCK_WAKE_WAITD:
-		if (test_bit(SOCK_ASYNC_WAITDATA, &sock->flags))
+		if (test_bit(SOCKWQ_ASYNC_WAITDATA, &wq->flags))
 			break;
 		goto call_kill;
 	case SOCK_WAKE_SPACE:
-		if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags))
+		if (!test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &wq->flags))
 			break;
 		/* fall through */
 	case SOCK_WAKE_IO:
@@ -1086,7 +1079,7 @@ call_kill:
 	case SOCK_WAKE_URG:
 		kill_fasync(&wq->fasync_list, SIGURG, band);
 	}
-	rcu_read_unlock();
+
 	return 0;
 }
 EXPORT_SYMBOL(sock_wake_async);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1d1a70498910..3a64ec0f49ab 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -398,7 +398,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	if (unlikely(!sock))
 		return -ENOTSOCK;
 
-	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+	clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->wq->flags);
 	if (base != 0) {
 		addr = NULL;
 		addrlen = 0;
@@ -442,7 +442,7 @@ static void xs_nospace_callback(struct rpc_task *task)
 	struct sock_xprt *transport = container_of(task->tk_rqstp->rq_xprt, struct sock_xprt, xprt);
 
 	transport->inet->sk_write_pending--;
-	clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+	clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->wq->flags);
 }
 
 /**
@@ -467,7 +467,7 @@ static int xs_nospace(struct rpc_task *task)
 
 	/* Don't race with disconnect */
 	if (xprt_connected(xprt)) {
-		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
+		if (test_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->wq->flags)) {
 			/*
 			 * Notify TCP that we're limited by the application
 			 * window size
@@ -478,7 +478,7 @@ static int xs_nospace(struct rpc_task *task)
 			xprt_wait_for_buffer_space(task, xs_nospace_callback);
 		}
 	} else {
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->wq->flags);
 		ret = -ENOTCONN;
 	}
 
@@ -626,7 +626,7 @@ process_status:
 	case -EPERM:
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED. */
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->wq->flags);
 	}
 
 	return status;
@@ -715,7 +715,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -EADDRINUSE:
 	case -ENOBUFS:
 	case -EPIPE:
-		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		clear_bit(SOCKWQ_ASYNC_NOSPACE, &transport->sock->wq->flags);
 	}
 
 	return status;
@@ -1618,7 +1618,7 @@ static void xs_write_space(struct sock *sk)
 
 	if (unlikely(!(xprt = xprt_from_sock(sk))))
 		return;
-	if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
+	if (test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->wq->flags) == 0)
 		return;
 
 	xprt_write_space(xprt);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4e95bdf973d9..1a87a0e1c9e3 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2139,7 +2139,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 		    !timeo)
 			break;
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 		unix_state_unlock(sk);
 		timeo = freezable_schedule_timeout(timeo);
 		unix_state_lock(sk);
@@ -2147,7 +2147,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 		if (sock_flag(sk, SOCK_DEAD))
 			break;
 
-		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_clear_bit(SOCKWQ_ASYNC_WAITDATA, sk);
 	}
 
 	finish_wait(sk_sleep(sk), &wait);
@@ -2634,7 +2634,7 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	if (writable)
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
-		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
+		sk_set_bit(SOCKWQ_ASYNC_NOSPACE, sk);
 
 	return mask;
 }
