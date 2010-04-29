From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sock_def_readable() and friends RCU
 conversion
Date: Thu, 29 Apr 2010 23:01:49 +0200
Message-ID: <1272574909.2209.150.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65186 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933750Ab0D3SXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:23:02 -0400
Received: by bwz19 with SMTP id 19so301159bwz.21
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 11:23:00 -0700 (PDT)
In-Reply-To: <1272573383.3969.8.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 avril 2010 =C3=A0 16:36 -0400, jamal a =C3=A9crit :

> Results attached.
> With your app rps does a hell lot better and non-rps worse ;->
> With my proggie, non-rps does much better than yours and rps does
> a lot worse for same setup. I see the scheduler kicking quiet a bit i=
n
> non-rps for you...
>=20
> The main difference between us as i see it is:
> a) i use epoll - actually linked to libevent (1.0.something)
> b) I fork processes and you use pthreads.
>=20
> I dont have time to chase it today, but 1) I am either going to chang=
e
> yours to use libevent or make mine get rid of it then 2) move towards
> pthreads or have yours fork..
> then observe if that makes any difference..
>=20

Thanks !

Here is last 'patch of the day' for me ;)

Next one will be able to coalesce wakeup calls (they'll be delayed at
the end of net_rx_action(), like a patch I did last year to help
multicast reception)

vger seems to be down, I suspect I'll have to resend it later.

[PATCH net-next-2.6] net: sock_def_readable() and friends RCU conversio=
n

sk_callback_lock rwlock actually protects sk->sk_sleep pointer, so we
need two atomic operations (and associated dirtying) per incoming
packet.

RCU conversion is pretty much needed :

1) Add a new structure, called "struct socket_wq" to hold all fields
that will need rcu_read_lock() protection (currently: a
wait_queue_head_t and a struct fasync_struct pointer).

[Future patch will add a list anchor for wakeup coalescing]

2) Attach one of such structure to each "struct socket" created in
sock_alloc_inode().

3) Respect RCU grace period when freeing a "struct socket_wq"

4) Change sk_sleep pointer in "struct sock" by sk_wq, pointer to "struc=
t
socket_wq"

5) Change sk_sleep() function to use new sk->sk_wq instead of
sk->sk_sleep

6) Change sk_has_sleeper() to wq_has_sleeper() that must be used inside
a rcu_read_lock() section.

7) Change all sk_has_sleeper() callers to :
  - Use rcu_read_lock() instead of read_lock(&sk->sk_callback_lock)
  - Use wq_has_sleeper() to eventually wakeup tasks.
  - Use rcu_read_unlock() instead of read_unlock(&sk->sk_callback_lock)

8) sock_wake_async() is modified to use rcu protection as well.

9) Exceptions :
  macvtap, drivers/net/tun.c, af_unix use integrated "struct socket_wq"
instead of dynamically allocated ones. They dont need rcu freeing.

Some cleanups or followups are probably needed, (possible
sk_callback_lock conversion to a spinlock for example...).

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---=20
 drivers/net/macvtap.c |   13 +++++++---
 drivers/net/tun.c     |   21 +++++++++-------
 include/linux/net.h   |   14 +++++++----
 include/net/af_unix.h |   20 ++++++++--------
 include/net/sock.h    |   40 ++++++++++++++++----------------
 net/atm/common.c      |   22 +++++++++++------
 net/core/sock.c       |   50 ++++++++++++++++++++++++----------------
 net/core/stream.c     |   10 +++++---
 net/dccp/output.c     |   10 ++++----
 net/iucv/af_iucv.c    |   11 +++++---
 net/phonet/pep.c      |    8 +++---
 net/phonet/socket.c   |    2 -
 net/rxrpc/af_rxrpc.c  |   10 ++++----
 net/sctp/socket.c     |    2 -
 net/socket.c          |   47 ++++++++++++++++++++++++++++---------
 net/unix/af_unix.c    |   17 ++++++-------
 16 files changed, 182 insertions(+), 115 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d97e1fd..1c4110d 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -37,6 +37,7 @@
 struct macvtap_queue {
 	struct sock sk;
 	struct socket sock;
+	struct socket_wq wq;
 	struct macvlan_dev *vlan;
 	struct file *file;
 	unsigned int flags;
@@ -242,12 +243,15 @@ static struct rtnl_link_ops macvtap_link_ops __re=
ad_mostly =3D {
=20
 static void macvtap_sock_write_space(struct sock *sk)
 {
+	wait_queue_head_t *wqueue;
+
 	if (!sock_writeable(sk) ||
 	    !test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
=20
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible_poll(sk_sleep(sk), POLLOUT | POLLWRNORM | POLL=
WRBAND);
+	wqueue =3D sk_sleep(sk);
+	if (wqueue && waitqueue_active(wqueue))
+		wake_up_interruptible_poll(wqueue, POLLOUT | POLLWRNORM | POLLWRBAND=
);
 }
=20
 static int macvtap_open(struct inode *inode, struct file *file)
@@ -272,7 +276,8 @@ static int macvtap_open(struct inode *inode, struct=
 file *file)
 	if (!q)
 		goto out;
=20
-	init_waitqueue_head(&q->sock.wait);
+	q->sock.wq =3D &q->wq;
+	init_waitqueue_head(&q->wq.wait);
 	q->sock.type =3D SOCK_RAW;
 	q->sock.state =3D SS_CONNECTED;
 	q->sock.file =3D file;
@@ -308,7 +313,7 @@ static unsigned int macvtap_poll(struct file *file,=
 poll_table * wait)
 		goto out;
=20
 	mask =3D 0;
-	poll_wait(file, &q->sock.wait, wait);
+	poll_wait(file, &q->wq.wait, wait);
=20
 	if (!skb_queue_empty(&q->sk.sk_receive_queue))
 		mask |=3D POLLIN | POLLRDNORM;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 20a1793..e525a6c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -109,7 +109,7 @@ struct tun_struct {
=20
 	struct tap_filter       txflt;
 	struct socket		socket;
-
+	struct socket_wq	wq;
 #ifdef TUN_DEBUG
 	int debug;
 #endif
@@ -323,7 +323,7 @@ static void tun_net_uninit(struct net_device *dev)
 	/* Inform the methods they need to stop using the dev.
 	 */
 	if (tfile) {
-		wake_up_all(&tun->socket.wait);
+		wake_up_all(&tun->wq.wait);
 		if (atomic_dec_and_test(&tfile->count))
 			__tun_detach(tun);
 	}
@@ -398,7 +398,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb=
, struct net_device *dev)
 	/* Notify and wake up reader process */
 	if (tun->flags & TUN_FASYNC)
 		kill_fasync(&tun->fasync, SIGIO, POLL_IN);
-	wake_up_interruptible_poll(&tun->socket.wait, POLLIN |
+	wake_up_interruptible_poll(&tun->wq.wait, POLLIN |
 				   POLLRDNORM | POLLRDBAND);
 	return NETDEV_TX_OK;
=20
@@ -498,7 +498,7 @@ static unsigned int tun_chr_poll(struct file *file,=
 poll_table * wait)
=20
 	DBG(KERN_INFO "%s: tun_chr_poll\n", tun->dev->name);
=20
-	poll_wait(file, &tun->socket.wait, wait);
+	poll_wait(file, &tun->wq.wait, wait);
=20
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |=3D POLLIN | POLLRDNORM;
@@ -773,7 +773,7 @@ static ssize_t tun_do_read(struct tun_struct *tun,
=20
 	DBG(KERN_INFO "%s: tun_chr_read\n", tun->dev->name);
=20
-	add_wait_queue(&tun->socket.wait, &wait);
+	add_wait_queue(&tun->wq.wait, &wait);
 	while (len) {
 		current->state =3D TASK_INTERRUPTIBLE;
=20
@@ -804,7 +804,7 @@ static ssize_t tun_do_read(struct tun_struct *tun,
 	}
=20
 	current->state =3D TASK_RUNNING;
-	remove_wait_queue(&tun->socket.wait, &wait);
+	remove_wait_queue(&tun->wq.wait, &wait);
=20
 	return ret;
 }
@@ -861,6 +861,7 @@ static struct rtnl_link_ops tun_link_ops __read_mos=
tly =3D {
 static void tun_sock_write_space(struct sock *sk)
 {
 	struct tun_struct *tun;
+	wait_queue_head_t *wqueue;
=20
 	if (!sock_writeable(sk))
 		return;
@@ -868,8 +869,9 @@ static void tun_sock_write_space(struct sock *sk)
 	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
=20
-	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-		wake_up_interruptible_sync_poll(sk_sleep(sk), POLLOUT |
+	wqueue =3D sk_sleep(sk);
+	if (wqueue && waitqueue_active(wqueue))
+		wake_up_interruptible_sync_poll(wqueue, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
=20
 	tun =3D tun_sk(sk)->tun;
@@ -1039,7 +1041,8 @@ static int tun_set_iff(struct net *net, struct fi=
le *file, struct ifreq *ifr)
 		if (!sk)
 			goto err_free_dev;
=20
-		init_waitqueue_head(&tun->socket.wait);
+		tun->socket.wq =3D &tun->wq;
+		init_waitqueue_head(&tun->wq.wait);
 		tun->socket.ops =3D &tun_socket_ops;
 		sock_init_data(&tun->socket, sk);
 		sk->sk_write_space =3D tun_sock_write_space;
diff --git a/include/linux/net.h b/include/linux/net.h
index 4157b5d..2b4deee 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -59,6 +59,7 @@ typedef enum {
 #include <linux/wait.h>
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/kmemcheck.h>
+#include <linux/rcupdate.h>
=20
 struct poll_table_struct;
 struct pipe_inode_info;
@@ -116,6 +117,12 @@ enum sock_shutdown_cmd {
 	SHUT_RDWR	=3D 2,
 };
=20
+struct socket_wq {
+	wait_queue_head_t	wait;
+	struct fasync_struct	*fasync_list;
+	struct rcu_head		rcu;
+} ____cacheline_aligned_in_smp;
+
 /**
  *  struct socket - general BSD socket
  *  @state: socket state (%SS_CONNECTED, etc)
@@ -135,11 +142,8 @@ struct socket {
 	kmemcheck_bitfield_end(type);
=20
 	unsigned long		flags;
-	/*
-	 * Please keep fasync_list & wait fields in the same cache line
-	 */
-	struct fasync_struct	*fasync_list;
-	wait_queue_head_t	wait;
+
+	struct socket_wq	*wq;
=20
 	struct file		*file;
 	struct sock		*sk;
diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 1614d78..20725e2 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -30,7 +30,7 @@ struct unix_skb_parms {
 #endif
 };
=20
-#define UNIXCB(skb) 	(*(struct unix_skb_parms*)&((skb)->cb))
+#define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
 #define UNIXCREDS(skb)	(&UNIXCB((skb)).creds)
 #define UNIXSID(skb)	(&UNIXCB((skb)).secid)
=20
@@ -45,21 +45,23 @@ struct unix_skb_parms {
 struct unix_sock {
 	/* WARNING: sk has to be the first member */
 	struct sock		sk;
-        struct unix_address     *addr;
-        struct dentry		*dentry;
-        struct vfsmount		*mnt;
+	struct unix_address     *addr;
+	struct dentry		*dentry;
+	struct vfsmount		*mnt;
 	struct mutex		readlock;
-        struct sock		*peer;
-        struct sock		*other;
+	struct sock		*peer;
+	struct sock		*other;
 	struct list_head	link;
-        atomic_long_t           inflight;
-        spinlock_t		lock;
+	atomic_long_t		inflight;
+	spinlock_t		lock;
 	unsigned int		gc_candidate : 1;
 	unsigned int		gc_maybe_cycle : 1;
-        wait_queue_head_t       peer_wait;
+	struct socket_wq	peer_wq;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
=20
+#define peer_wait peer_wq.wait
+
 #ifdef CONFIG_SYSCTL
 extern int unix_sysctl_register(struct net *net);
 extern void unix_sysctl_unregister(struct net *net);
diff --git a/include/net/sock.h b/include/net/sock.h
index d361c77..03d0046 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -159,7 +159,7 @@ struct sock_common {
   *	@sk_userlocks: %SO_SNDBUF and %SO_RCVBUF settings
   *	@sk_lock:	synchronizer
   *	@sk_rcvbuf: size of receive buffer in bytes
-  *	@sk_sleep: sock wait queue
+  *	@sk_wq: sock wait queue and async head
   *	@sk_dst_cache: destination cache
   *	@sk_dst_lock: destination cache lock
   *	@sk_policy: flow policy
@@ -257,7 +257,7 @@ struct sock {
 		struct sk_buff *tail;
 		int len;
 	} sk_backlog;
-	wait_queue_head_t	*sk_sleep;
+	struct socket_wq	*sk_wq;
 	struct dst_entry	*sk_dst_cache;
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
@@ -1219,7 +1219,7 @@ static inline void sk_set_socket(struct sock *sk,=
 struct socket *sock)
=20
 static inline wait_queue_head_t *sk_sleep(struct sock *sk)
 {
-	return sk->sk_sleep;
+	return &sk->sk_wq->wait;
 }
 /* Detach socket from process context.
  * Announce socket dead, detach it from wait queue and inode.
@@ -1233,14 +1233,14 @@ static inline void sock_orphan(struct sock *sk)
 	write_lock_bh(&sk->sk_callback_lock);
 	sock_set_flag(sk, SOCK_DEAD);
 	sk_set_socket(sk, NULL);
-	sk->sk_sleep  =3D NULL;
+	sk->sk_wq  =3D NULL;
 	write_unlock_bh(&sk->sk_callback_lock);
 }
=20
 static inline void sock_graft(struct sock *sk, struct socket *parent)
 {
 	write_lock_bh(&sk->sk_callback_lock);
-	sk->sk_sleep =3D &parent->wait;
+	rcu_assign_pointer(sk->sk_wq, parent->wq);
 	parent->sk =3D sk;
 	sk_set_socket(sk, parent);
 	security_sock_graft(sk, parent);
@@ -1392,12 +1392,12 @@ static inline int sk_has_allocations(const stru=
ct sock *sk)
 }
=20
 /**
- * sk_has_sleeper - check if there are any waiting processes
- * @sk: socket
+ * wq_has_sleeper - check if there are any waiting processes
+ * @sk: struct socket_wq
  *
- * Returns true if socket has waiting processes
+ * Returns true if socket_wq has waiting processes
  *
- * The purpose of the sk_has_sleeper and sock_poll_wait is to wrap the=
 memory
+ * The purpose of the wq_has_sleeper and sock_poll_wait is to wrap the=
 memory
  * barrier call. They were added due to the race found within the tcp =
code.
  *
  * Consider following tcp code paths:
@@ -1410,9 +1410,10 @@ static inline int sk_has_allocations(const struc=
t sock *sk)
  *   ...                 ...
  *   tp->rcv_nxt check   sock_def_readable
  *   ...                 {
- *   schedule               ...
- *                          if (sk_sleep(sk) && waitqueue_active(sk_sl=
eep(sk)))
- *                              wake_up_interruptible(sk_sleep(sk))
+ *   schedule               rcu_read_lock();
+ *                          wq =3D rcu_dereference(sk->sk_wq);
+ *                          if (wq && waitqueue_active(&wq->wait))
+ *                              wake_up_interruptible(&wq->wait)
  *                          ...
  *                       }
  *
@@ -1421,28 +1422,27 @@ static inline int sk_has_allocations(const stru=
ct sock *sk)
  * could then endup calling schedule and sleep forever if there are no=
 more
  * data on the socket.
  *
- * The sk_has_sleeper is always called right after a call to read_lock=
, so we
- * can use smp_mb__after_lock barrier.
  */
-static inline int sk_has_sleeper(struct sock *sk)
+static inline bool wq_has_sleeper(struct socket_wq *wq)
 {
+
 	/*
 	 * We need to be sure we are in sync with the
 	 * add_wait_queue modifications to the wait queue.
 	 *
 	 * This memory barrier is paired in the sock_poll_wait.
 	 */
-	smp_mb__after_lock();
-	return sk_sleep(sk) && waitqueue_active(sk_sleep(sk));
+	smp_mb();
+	return wq && waitqueue_active(&wq->wait);
 }
-
+=20
 /**
  * sock_poll_wait - place memory barrier behind the poll_wait call.
  * @filp:           file
  * @wait_address:   socket wait queue
  * @p:              poll_table
  *
- * See the comments in the sk_has_sleeper function.
+ * See the comments in the wq_has_sleeper function.
  */
 static inline void sock_poll_wait(struct file *filp,
 		wait_queue_head_t *wait_address, poll_table *p)
@@ -1453,7 +1453,7 @@ static inline void sock_poll_wait(struct file *fi=
lp,
 		 * We need to be sure we are in sync with the
 		 * socket flags modification.
 		 *
-		 * This memory barrier is paired in the sk_has_sleeper.
+		 * This memory barrier is paired in the wq_has_sleeper.
 		*/
 		smp_mb();
 	}
diff --git a/net/atm/common.c b/net/atm/common.c
index e3e10e6..b43feb1 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -90,10 +90,13 @@ static void vcc_sock_destruct(struct sock *sk)
=20
 static void vcc_def_wakeup(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
-	if (sk_has_sleeper(sk))
-		wake_up(sk_sleep(sk));
-	read_unlock(&sk->sk_callback_lock);
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq =3D rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up(&wq->wait);
+	rcu_read_unlock();
 }
=20
 static inline int vcc_writable(struct sock *sk)
@@ -106,16 +109,19 @@ static inline int vcc_writable(struct sock *sk)
=20
 static void vcc_write_space(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
+	struct socket_wq *wq;
+
+	rcu_read_lock();
=20
 	if (vcc_writable(sk)) {
-		if (sk_has_sleeper(sk))
-			wake_up_interruptible(sk_sleep(sk));
+		wq =3D rcu_dereference(sk->sk_wq);
+		if (wq_has_sleeper(wq))
+			wake_up_interruptible(&wq->wait);
=20
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
=20
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 static struct proto vcc_proto =3D {
diff --git a/net/core/sock.c b/net/core/sock.c
index 5104175..94c4aff 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1211,7 +1211,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
 		 */
 		sk_refcnt_debug_inc(newsk);
 		sk_set_socket(newsk, NULL);
-		newsk->sk_sleep	 =3D NULL;
+		newsk->sk_wq =3D NULL;
=20
 		if (newsk->sk_prot->sockets_allocated)
 			percpu_counter_inc(newsk->sk_prot->sockets_allocated);
@@ -1800,41 +1800,53 @@ EXPORT_SYMBOL(sock_no_sendpage);
=20
 static void sock_def_wakeup(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
-	if (sk_has_sleeper(sk))
-		wake_up_interruptible_all(sk_sleep(sk));
-	read_unlock(&sk->sk_callback_lock);
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq =3D rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_all(&wq->wait);
+	rcu_read_unlock();
 }
=20
 static void sock_def_error_report(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
-	if (sk_has_sleeper(sk))
-		wake_up_interruptible_poll(sk_sleep(sk), POLLERR);
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq =3D rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_poll(&wq->wait, POLLERR);
 	sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 static void sock_def_readable(struct sock *sk, int len)
 {
-	read_lock(&sk->sk_callback_lock);
-	if (sk_has_sleeper(sk))
-		wake_up_interruptible_sync_poll(sk_sleep(sk), POLLIN |
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq =3D rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 static void sock_def_write_space(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
+	struct socket_wq *wq;
+
+	rcu_read_lock();
=20
 	/* Do not wake up a writer until he can make "significant"
 	 * progress.  --DaveM
 	 */
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
-		if (sk_has_sleeper(sk))
-			wake_up_interruptible_sync_poll(sk_sleep(sk), POLLOUT |
+		wq =3D rcu_dereference(sk->sk_wq);
+		if (wq_has_sleeper(wq))
+			wake_up_interruptible_sync_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
=20
 		/* Should agree with poll, otherwise some programs break */
@@ -1842,7 +1854,7 @@ static void sock_def_write_space(struct sock *sk)
 			sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
=20
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 static void sock_def_destruct(struct sock *sk)
@@ -1896,10 +1908,10 @@ void sock_init_data(struct socket *sock, struct=
 sock *sk)
=20
 	if (sock) {
 		sk->sk_type	=3D	sock->type;
-		sk->sk_sleep	=3D	&sock->wait;
+		sk->sk_wq	=3D	sock->wq;
 		sock->sk	=3D	sk;
 	} else
-		sk->sk_sleep	=3D	NULL;
+		sk->sk_wq	=3D	NULL;
=20
 	spin_lock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
diff --git a/net/core/stream.c b/net/core/stream.c
index 7b3c3f3..cc196f4 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -28,15 +28,19 @@
 void sk_stream_write_space(struct sock *sk)
 {
 	struct socket *sock =3D sk->sk_socket;
+	struct socket_wq *wq;
=20
 	if (sk_stream_wspace(sk) >=3D sk_stream_min_wspace(sk) && sock) {
 		clear_bit(SOCK_NOSPACE, &sock->flags);
=20
-		if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
-			wake_up_interruptible_poll(sk_sleep(sk), POLLOUT |
+		rcu_read_lock();
+		wq =3D rcu_dereference(sk->sk_wq);
+		if (wq_has_sleeper(wq))
+			wake_up_interruptible_poll(&wq->wait, POLLOUT |
 						POLLWRNORM | POLLWRBAND);
-		if (sock->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
+		if (wq && wq->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
 			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
+		rcu_read_unlock();
 	}
 }
=20
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 2d3dcb3..aadbdb5 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -195,15 +195,17 @@ EXPORT_SYMBOL_GPL(dccp_sync_mss);
=20
 void dccp_write_space(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
+	struct socket_wq *wq;
=20
-	if (sk_has_sleeper(sk))
-		wake_up_interruptible(sk_sleep(sk));
+	rcu_read_lock();
+	wq =3D rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible(&wq->wait);
 	/* Should agree with poll, otherwise some programs break */
 	if (sock_writeable(sk))
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
=20
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 /**
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 9636b7d..8be324f 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -305,11 +305,14 @@ static inline int iucv_below_msglim(struct sock *=
sk)
  */
 static void iucv_sock_wake_msglim(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
-	if (sk_has_sleeper(sk))
-		wake_up_interruptible_all(sk_sleep(sk));
+	struct socket_wq *wq;
+
+	rcu_read_lock();
+	wq =3D rcu_dereference(sk->sk_wq);
+	if (wq_has_sleeper(wq))
+		wake_up_interruptible_all(&wq->wait);
 	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 /* Timers */
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index e2a9576..af4d38b 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -664,12 +664,12 @@ static int pep_wait_connreq(struct sock *sk, int =
noblock)
 		if (signal_pending(tsk))
 			return sock_intr_errno(timeo);
=20
-		prepare_to_wait_exclusive(&sk->sk_socket->wait, &wait,
+		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
 						TASK_INTERRUPTIBLE);
 		release_sock(sk);
 		timeo =3D schedule_timeout(timeo);
 		lock_sock(sk);
-		finish_wait(&sk->sk_socket->wait, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 	}
=20
 	return 0;
@@ -910,10 +910,10 @@ disabled:
 			goto out;
 		}
=20
-		prepare_to_wait(&sk->sk_socket->wait, &wait,
+		prepare_to_wait(sk_sleep(sk), &wait,
 				TASK_INTERRUPTIBLE);
 		done =3D sk_wait_event(sk, &timeo, atomic_read(&pn->tx_credits));
-		finish_wait(&sk->sk_socket->wait, &wait);
+		finish_wait(sk_sleep(sk), &wait);
=20
 		if (sk->sk_state !=3D TCP_ESTABLISHED)
 			goto disabled;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index c785bfd..6e9848b 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -265,7 +265,7 @@ static unsigned int pn_socket_poll(struct file *fil=
e, struct socket *sock,
 	struct pep_sock *pn =3D pep_sk(sk);
 	unsigned int mask =3D 0;
=20
-	poll_wait(file, &sock->wait, wait);
+	poll_wait(file, sk_sleep(sk), wait);
=20
 	switch (sk->sk_state) {
 	case TCP_LISTEN:
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index c432d76..0b9bb20 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -62,13 +62,15 @@ static inline int rxrpc_writable(struct sock *sk)
 static void rxrpc_write_space(struct sock *sk)
 {
 	_enter("%p", sk);
-	read_lock(&sk->sk_callback_lock);
+	rcu_read_lock();
 	if (rxrpc_writable(sk)) {
-		if (sk_has_sleeper(sk))
-			wake_up_interruptible(sk_sleep(sk));
+		struct socket_wq *wq =3D rcu_dereference(sk->sk_wq);
+
+		if (wq_has_sleeper(wq))
+			wake_up_interruptible(&wq->wait);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 /*
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 13d8229..d54700a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6065,7 +6065,7 @@ static void __sctp_write_space(struct sctp_associ=
ation *asoc)
 			 * here by modeling from the current TCP/UDP code.
 			 * We have not tested with it yet.
 			 */
-			if (sock->fasync_list &&
+			if (sock->wq->fasync_list &&
 			    !(sk->sk_shutdown & SEND_SHUTDOWN))
 				sock_wake_async(sock,
 						SOCK_WAKE_SPACE, POLL_OUT);
diff --git a/net/socket.c b/net/socket.c
index 9822081..a0a59cb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -252,9 +252,14 @@ static struct inode *sock_alloc_inode(struct super=
_block *sb)
 	ei =3D kmem_cache_alloc(sock_inode_cachep, GFP_KERNEL);
 	if (!ei)
 		return NULL;
-	init_waitqueue_head(&ei->socket.wait);
+	ei->socket.wq =3D kmalloc(sizeof(struct socket_wq), GFP_KERNEL);
+	if (!ei->socket.wq) {
+		kmem_cache_free(sock_inode_cachep, ei);
+		return NULL;
+	}
+	init_waitqueue_head(&ei->socket.wq->wait);
+	ei->socket.wq->fasync_list =3D NULL;
=20
-	ei->socket.fasync_list =3D NULL;
 	ei->socket.state =3D SS_UNCONNECTED;
 	ei->socket.flags =3D 0;
 	ei->socket.ops =3D NULL;
@@ -264,10 +269,21 @@ static struct inode *sock_alloc_inode(struct supe=
r_block *sb)
 	return &ei->vfs_inode;
 }
=20
+
+static void wq_free_rcu(struct rcu_head *head)
+{
+	struct socket_wq *wq =3D container_of(head, struct socket_wq, rcu);
+
+	kfree(wq);
+}
+
 static void sock_destroy_inode(struct inode *inode)
 {
-	kmem_cache_free(sock_inode_cachep,
-			container_of(inode, struct socket_alloc, vfs_inode));
+	struct socket_alloc *ei;
+
+	ei =3D container_of(inode, struct socket_alloc, vfs_inode);
+	call_rcu(&ei->socket.wq->rcu, wq_free_rcu);
+	kmem_cache_free(sock_inode_cachep, ei);
 }
=20
 static void init_once(void *foo)
@@ -513,7 +529,7 @@ void sock_release(struct socket *sock)
 		module_put(owner);
 	}
=20
-	if (sock->fasync_list)
+	if (sock->wq->fasync_list)
 		printk(KERN_ERR "sock_release: fasync list not empty!\n");
=20
 	percpu_sub(sockets_in_use, 1);
@@ -1080,9 +1096,9 @@ static int sock_fasync(int fd, struct file *filp,=
 int on)
=20
 	lock_sock(sk);
=20
-	fasync_helper(fd, filp, on, &sock->fasync_list);
+	fasync_helper(fd, filp, on, &sock->wq->fasync_list);
=20
-	if (!sock->fasync_list)
+	if (!sock->wq->fasync_list)
 		sock_reset_flag(sk, SOCK_FASYNC);
 	else
 		sock_set_flag(sk, SOCK_FASYNC);
@@ -1091,12 +1107,20 @@ static int sock_fasync(int fd, struct file *fil=
p, int on)
 	return 0;
 }
=20
-/* This function may be called only under socket lock or callback_lock=
 */
+/* This function may be called only under socket lock or callback_lock=
 or rcu_lock */
=20
 int sock_wake_async(struct socket *sock, int how, int band)
 {
-	if (!sock || !sock->fasync_list)
+	struct socket_wq *wq;
+
+	if (!sock)
 		return -1;
+	rcu_read_lock();
+	wq =3D rcu_dereference(sock->wq);
+	if (!wq || !wq->fasync_list) {
+		rcu_read_unlock();
+		return -1;
+	}
 	switch (how) {
 	case SOCK_WAKE_WAITD:
 		if (test_bit(SOCK_ASYNC_WAITDATA, &sock->flags))
@@ -1108,11 +1132,12 @@ int sock_wake_async(struct socket *sock, int ho=
w, int band)
 		/* fall through */
 	case SOCK_WAKE_IO:
 call_kill:
-		kill_fasync(&sock->fasync_list, SIGIO, band);
+		kill_fasync(&wq->fasync_list, SIGIO, band);
 		break;
 	case SOCK_WAKE_URG:
-		kill_fasync(&sock->fasync_list, SIGURG, band);
+		kill_fasync(&wq->fasync_list, SIGURG, band);
 	}
+	rcu_read_unlock();
 	return 0;
 }
=20
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 87c0360..fef2cc5 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -313,13 +313,16 @@ static inline int unix_writable(struct sock *sk)
=20
 static void unix_write_space(struct sock *sk)
 {
-	read_lock(&sk->sk_callback_lock);
+	struct socket_wq *wq;
+
+	rcu_read_lock();
 	if (unix_writable(sk)) {
-		if (sk_has_sleeper(sk))
-			wake_up_interruptible_sync(sk_sleep(sk));
+		wq =3D rcu_dereference(sk->sk_wq);
+		if (wq_has_sleeper(wq))
+			wake_up_interruptible_sync(&wq->wait);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
-	read_unlock(&sk->sk_callback_lock);
+	rcu_read_unlock();
 }
=20
 /* When dgram socket disconnects (or changes its peer), we clear its r=
eceive
@@ -406,9 +409,7 @@ static int unix_release_sock(struct sock *sk, int e=
mbrion)
 				skpair->sk_err =3D ECONNRESET;
 			unix_state_unlock(skpair);
 			skpair->sk_state_change(skpair);
-			read_lock(&skpair->sk_callback_lock);
 			sk_wake_async(skpair, SOCK_WAKE_WAITD, POLL_HUP);
-			read_unlock(&skpair->sk_callback_lock);
 		}
 		sock_put(skpair); /* It may now die */
 		unix_peer(sk) =3D NULL;
@@ -1142,7 +1143,7 @@ restart:
 	newsk->sk_peercred.pid	=3D task_tgid_vnr(current);
 	current_euid_egid(&newsk->sk_peercred.uid, &newsk->sk_peercred.gid);
 	newu =3D unix_sk(newsk);
-	newsk->sk_sleep		=3D &newu->peer_wait;
+	newsk->sk_wq		=3D &newu->peer_wq;
 	otheru =3D unix_sk(other);
=20
 	/* copy address information from listening to new sock*/
@@ -1931,12 +1932,10 @@ static int unix_shutdown(struct socket *sock, i=
nt mode)
 			other->sk_shutdown |=3D peer_mode;
 			unix_state_unlock(other);
 			other->sk_state_change(other);
-			read_lock(&other->sk_callback_lock);
 			if (peer_mode =3D=3D SHUTDOWN_MASK)
 				sk_wake_async(other, SOCK_WAKE_WAITD, POLL_HUP);
 			else if (peer_mode & RCV_SHUTDOWN)
 				sk_wake_async(other, SOCK_WAKE_WAITD, POLL_IN);
-			read_unlock(&other->sk_callback_lock);
 		}
 		if (other)
 			sock_put(other);


