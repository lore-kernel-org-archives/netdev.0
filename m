From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sk_sleep() helper
Date: Wed, 21 Apr 2010 01:03:51 +0200
Message-ID: <1271804631.7895.519.camel@edumazet-laptop>
References: <1270803809.2623.69.camel@edumazet-laptop>
	 <20100413.015232.67916764.davem@davemloft.net>
	 <1271199845.16881.586.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:45524 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625Ab0DTXEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:04:00 -0400
Received: by bwz25 with SMTP id 25so7425038bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:03:58 -0700 (PDT)
In-Reply-To: <1271199845.16881.586.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 01:04 +0200, Eric Dumazet a =C3=A9crit=
 :

> I am now working on sk_callback_lock case, to speedup
> sock_def_readable(), sock_def_write_space() in typical cases
> (SOCK_FASYNC not set)
>=20
> Instead of using rcu on whole "struct socket", my plan is to use a sm=
all
> structure :
>=20
> struct wait_queue_head_rcu {
> 	wait_queue_head_t wait;
> 	struct rcu_head	  rcu;
> } ____cacheline_aligned_in_smp;
>=20
> and make sk->sk_sleep points to this 'wait' field.
>=20

I am preparing this now, and submit this preliminary patch.

Thanks !

[PATCH net-next-2.6] net: sk_sleep() helper

Define a new function to return the waitqueue of a "struct sock".

static inline wait_queue_head_t *sk_sleep(struct sock *sk)
{
	return sk->sk_sleep;
}

Change all read occurrences of sk_sleep by a call to this function.

Needed for a future RCU conversion. sk_sleep wont be a field directly
available.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/atm/atmtcp.c            |    6 +-
 drivers/net/macvtap.c           |    4 -
 drivers/net/tun.c               |    4 -
 drivers/scsi/iscsi_tcp.c        |    4 -
 include/net/sock.h              |   10 +++-
 include/net/tcp.h               |    2=20
 net/atm/common.c                |   12 ++---
 net/atm/signaling.c             |    2=20
 net/atm/svc.c                   |   62 +++++++++++++++---------------
 net/ax25/af_ax25.c              |    8 +--
 net/bluetooth/af_bluetooth.c    |    6 +-
 net/bluetooth/bnep/core.c       |    8 +--
 net/bluetooth/bnep/netdev.c     |    6 +-
 net/bluetooth/cmtp/cmtp.h       |    2=20
 net/bluetooth/cmtp/core.c       |    4 -
 net/bluetooth/hidp/core.c       |   10 ++--
 net/bluetooth/hidp/hidp.h       |    4 -
 net/bluetooth/l2cap.c           |    4 -
 net/bluetooth/rfcomm/sock.c     |    8 +--
 net/bluetooth/sco.c             |    4 -
 net/caif/caif_socket.c          |    2=20
 net/core/datagram.c             |    6 +-
 net/core/sock.c                 |   16 +++----
 net/core/stream.c               |   16 +++----
 net/dccp/output.c               |    6 +-
 net/dccp/proto.c                |    2=20
 net/decnet/af_decnet.c          |   26 ++++++------
 net/ipv4/af_inet.c              |    6 +-
 net/ipv4/inet_connection_sock.c |    4 -
 net/ipv4/tcp.c                  |    2=20
 net/irda/af_irda.c              |   14 +++---
 net/iucv/af_iucv.c              |   12 ++---
 net/llc/af_llc.c                |   12 ++---
 net/netfilter/ipvs/ip_vs_sync.c |    2=20
 net/netrom/af_netrom.c          |    8 +--
 net/rds/af_rds.c                |    2=20
 net/rds/rds.h                   |    2=20
 net/rds/recv.c                  |    2=20
 net/rds/send.c                  |    2=20
 net/rose/af_rose.c              |    8 +--
 net/rxrpc/af_rxrpc.c            |    4 -
 net/sctp/socket.c               |   20 ++++-----
 net/sunrpc/svcsock.c            |   24 +++++------
 net/tipc/socket.c               |   26 ++++++------
 net/unix/af_unix.c              |   10 ++--
 net/x25/af_x25.c                |    8 +--
 46 files changed, 208 insertions(+), 204 deletions(-)

diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index b867121..b910181 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -68,7 +68,7 @@ static int atmtcp_send_control(struct atm_vcc *vcc,in=
t type,
 	*(struct atm_vcc **) &new_msg->vcc =3D vcc;
 	old_test =3D test_bit(flag,&vcc->flags);
 	out_vcc->push(out_vcc,skb);
-	add_wait_queue(sk_atm(vcc)->sk_sleep, &wait);
+	add_wait_queue(sk_sleep(sk_atm(vcc)), &wait);
 	while (test_bit(flag,&vcc->flags) =3D=3D old_test) {
 		mb();
 		out_vcc =3D PRIV(vcc->dev) ? PRIV(vcc->dev)->vcc : NULL;
@@ -80,7 +80,7 @@ static int atmtcp_send_control(struct atm_vcc *vcc,in=
t type,
 		schedule();
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk_atm(vcc)->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk_atm(vcc)), &wait);
 	return error;
 }
=20
@@ -105,7 +105,7 @@ static int atmtcp_recv_control(const struct atmtcp_=
control *msg)
 		    msg->type);
 		return -EINVAL;
 	}
-	wake_up(sk_atm(vcc)->sk_sleep);
+	wake_up(sk_sleep(sk_atm(vcc)));
 	return 0;
 }
=20
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index abba3cc..85d6420 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -246,8 +246,8 @@ static void macvtap_sock_write_space(struct sock *s=
k)
 	    !test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
=20
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_poll(sk->sk_sleep, POLLOUT | POLLWRNORM | POLL=
WRBAND);
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible_poll(sk_sleep(sk), POLLOUT | POLLWRNORM | POLL=
WRBAND);
 }
=20
 static int macvtap_open(struct inode *inode, struct file *file)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4326520..20a1793 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -868,8 +868,8 @@ static void tun_sock_write_space(struct sock *sk)
 	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
=20
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT |
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible_sync_poll(sk_sleep(sk), POLLOUT |
 						POLLWRNORM | POLLWRBAND);
=20
 	tun =3D tun_sk(sk)->tun;
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 0ee725c..9eae04a 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -599,9 +599,9 @@ static void iscsi_sw_tcp_conn_stop(struct iscsi_cls=
_conn *cls_conn, int flag)
 	set_bit(ISCSI_SUSPEND_BIT, &conn->suspend_rx);
 	write_unlock_bh(&tcp_sw_conn->sock->sk->sk_callback_lock);
=20
-	if (sock->sk->sk_sleep && waitqueue_active(sock->sk->sk_sleep)) {
+	if (sk_sleep(sock->sk) && waitqueue_active(sk_sleep(sock->sk))) {
 		sock->sk->sk_err =3D EIO;
-		wake_up_interruptible(sock->sk->sk_sleep);
+		wake_up_interruptible(sk_sleep(sock->sk));
 	}
=20
 	iscsi_conn_stop(cls_conn, flag);
diff --git a/include/net/sock.h b/include/net/sock.h
index 56df440..8ab0514 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1160,6 +1160,10 @@ static inline void sk_set_socket(struct sock *sk=
, struct socket *sock)
 	sk->sk_socket =3D sock;
 }
=20
+static inline wait_queue_head_t *sk_sleep(struct sock *sk)
+{
+	return sk->sk_sleep;
+}
 /* Detach socket from process context.
  * Announce socket dead, detach it from wait queue and inode.
  * Note that parent inode held reference count on this struct sock,
@@ -1346,8 +1350,8 @@ static inline int sk_has_allocations(const struct=
 sock *sk)
  *   tp->rcv_nxt check   sock_def_readable
  *   ...                 {
  *   schedule               ...
- *                          if (sk->sk_sleep && waitqueue_active(sk->s=
k_sleep))
- *                              wake_up_interruptible(sk->sk_sleep)
+ *                          if (sk_sleep(sk) && waitqueue_active(sk_sl=
eep(sk)))
+ *                              wake_up_interruptible(sk_sleep(sk))
  *                          ...
  *                       }
  *
@@ -1368,7 +1372,7 @@ static inline int sk_has_sleeper(struct sock *sk)
 	 * This memory barrier is paired in the sock_poll_wait.
 	 */
 	smp_mb__after_lock();
-	return sk->sk_sleep && waitqueue_active(sk->sk_sleep);
+	return sk_sleep(sk) && waitqueue_active(sk_sleep(sk));
 }
=20
 /**
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70c5159..b7d83d2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, str=
uct sk_buff *skb)
=20
 		tp->ucopy.memory =3D 0;
 	} else if (skb_queue_len(&tp->ucopy.prequeue) =3D=3D 1) {
-		wake_up_interruptible_sync_poll(sk->sk_sleep,
+		wake_up_interruptible_sync_poll(sk_sleep(sk),
 					   POLLIN | POLLRDNORM | POLLRDBAND);
 		if (!inet_csk_ack_scheduled(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
diff --git a/net/atm/common.c b/net/atm/common.c
index 97ed94a..e3e10e6 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -92,7 +92,7 @@ static void vcc_def_wakeup(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
 	if (sk_has_sleeper(sk))
-		wake_up(sk->sk_sleep);
+		wake_up(sk_sleep(sk));
 	read_unlock(&sk->sk_callback_lock);
 }
=20
@@ -110,7 +110,7 @@ static void vcc_write_space(struct sock *sk)
=20
 	if (vcc_writable(sk)) {
 		if (sk_has_sleeper(sk))
-			wake_up_interruptible(sk->sk_sleep);
+			wake_up_interruptible(sk_sleep(sk));
=20
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
@@ -549,7 +549,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *=
sock, struct msghdr *m,
 	}
=20
 	eff =3D (size+3) & ~3; /* align to word boundary */
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	error =3D 0;
 	while (!(skb =3D alloc_tx(vcc, eff))) {
 		if (m->msg_flags & MSG_DONTWAIT) {
@@ -568,9 +568,9 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *=
sock, struct msghdr *m,
 			send_sig(SIGPIPE, current, 0);
 			break;
 		}
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (error)
 		goto out;
 	skb->dev =3D NULL; /* for paths shared with net_device interfaces */
@@ -595,7 +595,7 @@ unsigned int vcc_poll(struct file *file, struct soc=
ket *sock, poll_table *wait)
 	struct atm_vcc *vcc;
 	unsigned int mask;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask =3D 0;
=20
 	vcc =3D ATM_SD(sock);
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 6ba6e46..509c8ac 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -131,7 +131,7 @@ static int sigd_send(struct atm_vcc *vcc, struct sk=
_buff *skb)
 		}
 		sk->sk_ack_backlog++;
 		skb_queue_tail(&sk->sk_receive_queue, skb);
-		pr_debug("waking sk->sk_sleep 0x%p\n", sk->sk_sleep);
+		pr_debug("waking sk_sleep(sk) 0x%p\n", sk_sleep(sk));
 		sk->sk_state_change(sk);
 as_indicate_complete:
 		release_sock(sk);
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 3ba9a45..754ee47 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -49,14 +49,14 @@ static void svc_disconnect(struct atm_vcc *vcc)
=20
 	pr_debug("%p\n", vcc);
 	if (test_bit(ATM_VF_REGIS, &vcc->flags)) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc, as_close, NULL, NULL, NULL);
 		while (!test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 			schedule();
-			prepare_to_wait(sk->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk), &wait,
 					TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
@@ -125,13 +125,13 @@ static int svc_bind(struct socket *sock, struct s=
ockaddr *sockaddr,
 	}
 	vcc->local =3D *addr;
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc, as_bind, NULL, NULL, &vcc->local);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	clear_bit(ATM_VF_REGIS, &vcc->flags); /* doesn't count */
 	if (!sigd) {
 		error =3D -EUNATCH;
@@ -201,10 +201,10 @@ static int svc_connect(struct socket *sock, struc=
t sockaddr *sockaddr,
 		}
 		vcc->remote =3D *addr;
 		set_bit(ATM_VF_WAITING, &vcc->flags);
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc, as_connect, NULL, NULL, &vcc->remote);
 		if (flags & O_NONBLOCK) {
-			finish_wait(sk->sk_sleep, &wait);
+			finish_wait(sk_sleep(sk), &wait);
 			sock->state =3D SS_CONNECTING;
 			error =3D -EINPROGRESS;
 			goto out;
@@ -213,7 +213,7 @@ static int svc_connect(struct socket *sock, struct =
sockaddr *sockaddr,
 		while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
-				prepare_to_wait(sk->sk_sleep, &wait,
+				prepare_to_wait(sk_sleep(sk), &wait,
 						TASK_INTERRUPTIBLE);
 				continue;
 			}
@@ -232,14 +232,14 @@ static int svc_connect(struct socket *sock, struc=
t sockaddr *sockaddr,
 			 */
 			sigd_enq(vcc, as_close, NULL, NULL, NULL);
 			while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
-				prepare_to_wait(sk->sk_sleep, &wait,
+				prepare_to_wait(sk_sleep(sk), &wait,
 						TASK_INTERRUPTIBLE);
 				schedule();
 			}
 			if (!sk->sk_err)
 				while (!test_bit(ATM_VF_RELEASED, &vcc->flags) &&
 				       sigd) {
-					prepare_to_wait(sk->sk_sleep, &wait,
+					prepare_to_wait(sk_sleep(sk), &wait,
 							TASK_INTERRUPTIBLE);
 					schedule();
 				}
@@ -250,7 +250,7 @@ static int svc_connect(struct socket *sock, struct =
sockaddr *sockaddr,
 			error =3D -EINTR;
 			break;
 		}
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 		if (error)
 			goto out;
 		if (!sigd) {
@@ -302,13 +302,13 @@ static int svc_listen(struct socket *sock, int ba=
cklog)
 		goto out;
 	}
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc, as_listen, NULL, NULL, &vcc->local);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (!sigd) {
 		error =3D -EUNATCH;
 		goto out;
@@ -343,7 +343,7 @@ static int svc_accept(struct socket *sock, struct s=
ocket *newsock, int flags)
 	while (1) {
 		DEFINE_WAIT(wait);
=20
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		while (!(skb =3D skb_dequeue(&sk->sk_receive_queue)) &&
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED, &old_vcc->flags))
@@ -363,10 +363,10 @@ static int svc_accept(struct socket *sock, struct=
 socket *newsock, int flags)
 				error =3D -ERESTARTSYS;
 				break;
 			}
-			prepare_to_wait(sk->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk), &wait,
 					TASK_INTERRUPTIBLE);
 		}
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 		if (error)
 			goto out;
 		if (!skb) {
@@ -392,17 +392,17 @@ static int svc_accept(struct socket *sock, struct=
 socket *newsock, int flags)
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		set_bit(ATM_VF_WAITING, &new_vcc->flags);
-		prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait,
+		prepare_to_wait(sk_sleep(sk_atm(new_vcc)), &wait,
 				TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc, as_accept, old_vcc, NULL, NULL);
 		while (test_bit(ATM_VF_WAITING, &new_vcc->flags) && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
-			prepare_to_wait(sk_atm(new_vcc)->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk_atm(new_vcc)), &wait,
 					TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(sk_atm(new_vcc)->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk_atm(new_vcc)), &wait);
 		if (!sigd) {
 			error =3D -EUNATCH;
 			goto out;
@@ -438,14 +438,14 @@ int svc_change_qos(struct atm_vcc *vcc, struct at=
m_qos *qos)
 	DEFINE_WAIT(wait);
=20
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc, as_modify, NULL, NULL, &vcc->local, qos, 0);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) &&
 	       !test_bit(ATM_VF_RELEASED, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (!sigd)
 		return -EUNATCH;
 	return -sk->sk_err;
@@ -534,20 +534,20 @@ static int svc_addparty(struct socket *sock, stru=
ct sockaddr *sockaddr,
=20
 	lock_sock(sk);
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	sigd_enq(vcc, as_addparty, NULL, NULL,
 		 (struct sockaddr_atmsvc *) sockaddr);
 	if (flags & O_NONBLOCK) {
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 		error =3D -EINPROGRESS;
 		goto out;
 	}
 	pr_debug("added wait queue\n");
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	error =3D xchg(&sk->sk_err_soft, 0);
 out:
 	release_sock(sk);
@@ -563,13 +563,13 @@ static int svc_dropparty(struct socket *sock, int=
 ep_ref)
=20
 	lock_sock(sk);
 	set_bit(ATM_VF_WAITING, &vcc->flags);
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	sigd_enq2(vcc, as_dropparty, NULL, NULL, NULL, NULL, ep_ref);
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (!sigd) {
 		error =3D -EUNATCH;
 		goto out;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 65c5801..cfdfd7e 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1281,7 +1281,7 @@ static int __must_check ax25_connect(struct socke=
t *sock,
 		DEFINE_WAIT(wait);
=20
 		for (;;) {
-			prepare_to_wait(sk->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk), &wait,
 					TASK_INTERRUPTIBLE);
 			if (sk->sk_state !=3D TCP_SYN_SENT)
 				break;
@@ -1294,7 +1294,7 @@ static int __must_check ax25_connect(struct socke=
t *sock,
 			err =3D -ERESTARTSYS;
 			break;
 		}
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
=20
 		if (err)
 			goto out_release;
@@ -1346,7 +1346,7 @@ static int ax25_accept(struct socket *sock, struc=
t socket *newsock, int flags)
 	 *	hooked into the SABM we saved
 	 */
 	for (;;) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		skb =3D skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
 			break;
@@ -1364,7 +1364,7 @@ static int ax25_accept(struct socket *sock, struc=
t socket *newsock, int flags)
 		err =3D -ERESTARTSYS;
 		break;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
=20
 	if (err)
 		goto out;
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.=
c
index 404a850..421c45b 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -288,7 +288,7 @@ unsigned int bt_sock_poll(struct file * file, struc=
t socket *sock, poll_table *w
=20
 	BT_DBG("sock %p, sk %p", sock, sk);
=20
-	poll_wait(file, sk->sk_sleep, wait);
+	poll_wait(file, sk_sleep(sk), wait);
=20
 	if (sk->sk_state =3D=3D BT_LISTEN)
 		return bt_accept_poll(sk);
@@ -378,7 +378,7 @@ int bt_sock_wait_state(struct sock *sk, int state, =
unsigned long timeo)
=20
 	BT_DBG("sk %p", sk);
=20
-	add_wait_queue(sk->sk_sleep, &wait);
+	add_wait_queue(sk_sleep(sk), &wait);
 	while (sk->sk_state !=3D state) {
 		set_current_state(TASK_INTERRUPTIBLE);
=20
@@ -401,7 +401,7 @@ int bt_sock_wait_state(struct sock *sk, int state, =
unsigned long timeo)
 			break;
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return err;
 }
 EXPORT_SYMBOL(bt_sock_wait_state);
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 8062dad..f10b41f 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -474,7 +474,7 @@ static int bnep_session(void *arg)
 	set_user_nice(current, -15);
=20
 	init_waitqueue_entry(&wait, current);
-	add_wait_queue(sk->sk_sleep, &wait);
+	add_wait_queue(sk_sleep(sk), &wait);
 	while (!atomic_read(&s->killed)) {
 		set_current_state(TASK_INTERRUPTIBLE);
=20
@@ -496,7 +496,7 @@ static int bnep_session(void *arg)
 		schedule();
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
=20
 	/* Cleanup session */
 	down_write(&bnep_session_sem);
@@ -507,7 +507,7 @@ static int bnep_session(void *arg)
 	/* Wakeup user-space polling for socket errors */
 	s->sock->sk->sk_err =3D EUNATCH;
=20
-	wake_up_interruptible(s->sock->sk->sk_sleep);
+	wake_up_interruptible(sk_sleep(s->sock->sk));
=20
 	/* Release the socket */
 	fput(s->sock->file);
@@ -638,7 +638,7 @@ int bnep_del_connection(struct bnep_conndel_req *re=
q)
=20
 		/* Kill session thread */
 		atomic_inc(&s->killed);
-		wake_up_interruptible(s->sock->sk->sk_sleep);
+		wake_up_interruptible(sk_sleep(s->sock->sk));
 	} else
 		err =3D -ENOENT;
=20
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index d48b33f..0faad5c 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -109,7 +109,7 @@ static void bnep_net_set_mc_list(struct net_device =
*dev)
 	}
=20
 	skb_queue_tail(&sk->sk_write_queue, skb);
-	wake_up_interruptible(sk->sk_sleep);
+	wake_up_interruptible(sk_sleep(sk));
 #endif
 }
=20
@@ -193,11 +193,11 @@ static netdev_tx_t bnep_net_xmit(struct sk_buff *=
skb,
 	/*
 	 * We cannot send L2CAP packets from here as we are potentially in a =
bh.
 	 * So we have to queue them and wake up session thread which is sleep=
ing
-	 * on the sk->sk_sleep.
+	 * on the sk_sleep(sk).
 	 */
 	dev->trans_start =3D jiffies;
 	skb_queue_tail(&sk->sk_write_queue, skb);
-	wake_up_interruptible(sk->sk_sleep);
+	wake_up_interruptible(sk_sleep(sk));
=20
 	if (skb_queue_len(&sk->sk_write_queue) >=3D BNEP_TX_QUEUE_LEN) {
 		BT_DBG("tx queue is full");
diff --git a/net/bluetooth/cmtp/cmtp.h b/net/bluetooth/cmtp/cmtp.h
index e4663aa..785e79e 100644
--- a/net/bluetooth/cmtp/cmtp.h
+++ b/net/bluetooth/cmtp/cmtp.h
@@ -125,7 +125,7 @@ static inline void cmtp_schedule(struct cmtp_sessio=
n *session)
 {
 	struct sock *sk =3D session->sock->sk;
=20
-	wake_up_interruptible(sk->sk_sleep);
+	wake_up_interruptible(sk_sleep(sk));
 }
=20
 /* CMTP init defines */
diff --git a/net/bluetooth/cmtp/core.c b/net/bluetooth/cmtp/core.c
index 0073ec8..d4c6af0 100644
--- a/net/bluetooth/cmtp/core.c
+++ b/net/bluetooth/cmtp/core.c
@@ -284,7 +284,7 @@ static int cmtp_session(void *arg)
 	set_user_nice(current, -15);
=20
 	init_waitqueue_entry(&wait, current);
-	add_wait_queue(sk->sk_sleep, &wait);
+	add_wait_queue(sk_sleep(sk), &wait);
 	while (!atomic_read(&session->terminate)) {
 		set_current_state(TASK_INTERRUPTIBLE);
=20
@@ -301,7 +301,7 @@ static int cmtp_session(void *arg)
 		schedule();
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
=20
 	down_write(&cmtp_session_sem);
=20
diff --git a/net/bluetooth/hidp/core.c b/net/bluetooth/hidp/core.c
index 280529a..bfe641b 100644
--- a/net/bluetooth/hidp/core.c
+++ b/net/bluetooth/hidp/core.c
@@ -561,8 +561,8 @@ static int hidp_session(void *arg)
=20
 	init_waitqueue_entry(&ctrl_wait, current);
 	init_waitqueue_entry(&intr_wait, current);
-	add_wait_queue(ctrl_sk->sk_sleep, &ctrl_wait);
-	add_wait_queue(intr_sk->sk_sleep, &intr_wait);
+	add_wait_queue(sk_sleep(ctrl_sk), &ctrl_wait);
+	add_wait_queue(sk_sleep(intr_sk), &intr_wait);
 	while (!atomic_read(&session->terminate)) {
 		set_current_state(TASK_INTERRUPTIBLE);
=20
@@ -584,8 +584,8 @@ static int hidp_session(void *arg)
 		schedule();
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(intr_sk->sk_sleep, &intr_wait);
-	remove_wait_queue(ctrl_sk->sk_sleep, &ctrl_wait);
+	remove_wait_queue(sk_sleep(intr_sk), &intr_wait);
+	remove_wait_queue(sk_sleep(ctrl_sk), &ctrl_wait);
=20
 	down_write(&hidp_session_sem);
=20
@@ -609,7 +609,7 @@ static int hidp_session(void *arg)
=20
 	fput(session->intr_sock->file);
=20
-	wait_event_timeout(*(ctrl_sk->sk_sleep),
+	wait_event_timeout(*(sk_sleep(ctrl_sk)),
 		(ctrl_sk->sk_state =3D=3D BT_CLOSED), msecs_to_jiffies(500));
=20
 	fput(session->ctrl_sock->file);
diff --git a/net/bluetooth/hidp/hidp.h b/net/bluetooth/hidp/hidp.h
index a4e215d..8d934a1 100644
--- a/net/bluetooth/hidp/hidp.h
+++ b/net/bluetooth/hidp/hidp.h
@@ -164,8 +164,8 @@ static inline void hidp_schedule(struct hidp_sessio=
n *session)
 	struct sock *ctrl_sk =3D session->ctrl_sock->sk;
 	struct sock *intr_sk =3D session->intr_sock->sk;
=20
-	wake_up_interruptible(ctrl_sk->sk_sleep);
-	wake_up_interruptible(intr_sk->sk_sleep);
+	wake_up_interruptible(sk_sleep(ctrl_sk));
+	wake_up_interruptible(sk_sleep(intr_sk));
 }
=20
 /* HIDP init defines */
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 99d68c3..c1e60ee 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1147,7 +1147,7 @@ static int l2cap_sock_accept(struct socket *sock,=
 struct socket *newsock, int fl
 	BT_DBG("sk %p timeo %ld", sk, timeo);
=20
 	/* Wait for an incoming connection. (wake-one). */
-	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
 	while (!(nsk =3D bt_accept_dequeue(sk, newsock))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (!timeo) {
@@ -1170,7 +1170,7 @@ static int l2cap_sock_accept(struct socket *sock,=
 struct socket *newsock, int fl
 		}
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
=20
 	if (err)
 		goto done;
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 8ed3c37..43fbf6b 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -503,7 +503,7 @@ static int rfcomm_sock_accept(struct socket *sock, =
struct socket *newsock, int f
 	BT_DBG("sk %p timeo %ld", sk, timeo);
=20
 	/* Wait for an incoming connection. (wake-one). */
-	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
 	while (!(nsk =3D bt_accept_dequeue(sk, newsock))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (!timeo) {
@@ -526,7 +526,7 @@ static int rfcomm_sock_accept(struct socket *sock, =
struct socket *newsock, int f
 		}
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
=20
 	if (err)
 		goto done;
@@ -621,7 +621,7 @@ static long rfcomm_sock_data_wait(struct sock *sk, =
long timeo)
 {
 	DECLARE_WAITQUEUE(wait, current);
=20
-	add_wait_queue(sk->sk_sleep, &wait);
+	add_wait_queue(sk_sleep(sk), &wait);
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
=20
@@ -640,7 +640,7 @@ static long rfcomm_sock_data_wait(struct sock *sk, =
long timeo)
 	}
=20
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return timeo;
 }
=20
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index ca6b2ad..b406d3e 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -567,7 +567,7 @@ static int sco_sock_accept(struct socket *sock, str=
uct socket *newsock, int flag
 	BT_DBG("sk %p timeo %ld", sk, timeo);
=20
 	/* Wait for an incoming connection. (wake-one). */
-	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
 	while (!(ch =3D bt_accept_dequeue(sk, newsock))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (!timeo) {
@@ -590,7 +590,7 @@ static int sco_sock_accept(struct socket *sock, str=
uct socket *newsock, int flag
 		}
 	}
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
=20
 	if (err)
 		goto done;
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index cdf62b9..90317e7 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -689,7 +689,7 @@ static unsigned int caif_poll(struct file *file, st=
ruct socket *sock,
 	struct sock *sk =3D sock->sk;
 	struct caifsock *cf_sk =3D container_of(sk, struct caifsock, sk);
 	u32 mask =3D 0;
-	poll_wait(file, sk->sk_sleep, wait);
+	poll_wait(file, sk_sleep(sk), wait);
 	lock_sock(&(cf_sk->sk));
 	if (!STATE_IS_OPEN(cf_sk)) {
 		if (!STATE_IS_PENDING(cf_sk))
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 2dccd4e..5574a5d 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -86,7 +86,7 @@ static int wait_for_packet(struct sock *sk, int *err,=
 long *timeo_p)
 	int error;
 	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
=20
-	prepare_to_wait_exclusive(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait_exclusive(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 	/* Socket errors? */
 	error =3D sock_error(sk);
@@ -115,7 +115,7 @@ static int wait_for_packet(struct sock *sk, int *er=
r, long *timeo_p)
 	error =3D 0;
 	*timeo_p =3D schedule_timeout(*timeo_p);
 out:
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return error;
 interrupted:
 	error =3D sock_intr_errno(*timeo_p);
@@ -726,7 +726,7 @@ unsigned int datagram_poll(struct file *file, struc=
t socket *sock,
 	struct sock *sk =3D sock->sk;
 	unsigned int mask;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask =3D 0;
=20
 	/* exceptional events? */
diff --git a/net/core/sock.c b/net/core/sock.c
index 7effa1e..58ebd14 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1395,7 +1395,7 @@ static long sock_wait_for_wmem(struct sock *sk, l=
ong timeo)
 		if (signal_pending(current))
 			break;
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf)
 			break;
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
@@ -1404,7 +1404,7 @@ static long sock_wait_for_wmem(struct sock *sk, l=
ong timeo)
 			break;
 		timeo =3D schedule_timeout(timeo);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return timeo;
 }
=20
@@ -1570,11 +1570,11 @@ int sk_wait_data(struct sock *sk, long *timeo)
 	int rc;
 	DEFINE_WAIT(wait);
=20
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	rc =3D sk_wait_event(sk, timeo, !skb_queue_empty(&sk->sk_receive_queu=
e));
 	clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return rc;
 }
 EXPORT_SYMBOL(sk_wait_data);
@@ -1798,7 +1798,7 @@ static void sock_def_wakeup(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
 	if (sk_has_sleeper(sk))
-		wake_up_interruptible_all(sk->sk_sleep);
+		wake_up_interruptible_all(sk_sleep(sk));
 	read_unlock(&sk->sk_callback_lock);
 }
=20
@@ -1806,7 +1806,7 @@ static void sock_def_error_report(struct sock *sk=
)
 {
 	read_lock(&sk->sk_callback_lock);
 	if (sk_has_sleeper(sk))
-		wake_up_interruptible_poll(sk->sk_sleep, POLLERR);
+		wake_up_interruptible_poll(sk_sleep(sk), POLLERR);
 	sk_wake_async(sk, SOCK_WAKE_IO, POLL_ERR);
 	read_unlock(&sk->sk_callback_lock);
 }
@@ -1815,7 +1815,7 @@ static void sock_def_readable(struct sock *sk, in=
t len)
 {
 	read_lock(&sk->sk_callback_lock);
 	if (sk_has_sleeper(sk))
-		wake_up_interruptible_sync_poll(sk->sk_sleep, POLLIN |
+		wake_up_interruptible_sync_poll(sk_sleep(sk), POLLIN |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
 	read_unlock(&sk->sk_callback_lock);
@@ -1830,7 +1830,7 @@ static void sock_def_write_space(struct sock *sk)
 	 */
 	if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
 		if (sk_has_sleeper(sk))
-			wake_up_interruptible_sync_poll(sk->sk_sleep, POLLOUT |
+			wake_up_interruptible_sync_poll(sk_sleep(sk), POLLOUT |
 						POLLWRNORM | POLLWRBAND);
=20
 		/* Should agree with poll, otherwise some programs break */
diff --git a/net/core/stream.c b/net/core/stream.c
index a37debf..7b3c3f3 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -32,8 +32,8 @@ void sk_stream_write_space(struct sock *sk)
 	if (sk_stream_wspace(sk) >=3D sk_stream_min_wspace(sk) && sock) {
 		clear_bit(SOCK_NOSPACE, &sock->flags);
=20
-		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-			wake_up_interruptible_poll(sk->sk_sleep, POLLOUT |
+		if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+			wake_up_interruptible_poll(sk_sleep(sk), POLLOUT |
 						POLLWRNORM | POLLWRBAND);
 		if (sock->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
 			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
@@ -66,13 +66,13 @@ int sk_stream_wait_connect(struct sock *sk, long *t=
imeo_p)
 		if (signal_pending(tsk))
 			return sock_intr_errno(*timeo_p);
=20
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		sk->sk_write_pending++;
 		done =3D sk_wait_event(sk, timeo_p,
 				     !sk->sk_err &&
 				     !((1 << sk->sk_state) &
 				       ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT)));
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 		sk->sk_write_pending--;
 	} while (!done);
 	return 0;
@@ -96,13 +96,13 @@ void sk_stream_wait_close(struct sock *sk, long tim=
eout)
 		DEFINE_WAIT(wait);
=20
 		do {
-			prepare_to_wait(sk->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk), &wait,
 					TASK_INTERRUPTIBLE);
 			if (sk_wait_event(sk, &timeout, !sk_stream_closing(sk)))
 				break;
 		} while (!signal_pending(current) && timeout);
=20
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 	}
 }
=20
@@ -126,7 +126,7 @@ int sk_stream_wait_memory(struct sock *sk, long *ti=
meo_p)
 	while (1) {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
=20
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 			goto do_error;
@@ -157,7 +157,7 @@ int sk_stream_wait_memory(struct sock *sk, long *ti=
meo_p)
 		*timeo_p =3D current_timeo;
 	}
 out:
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return err;
=20
 do_error:
diff --git a/net/dccp/output.c b/net/dccp/output.c
index e98b65e..2d3dcb3 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -198,7 +198,7 @@ void dccp_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
=20
 	if (sk_has_sleeper(sk))
-		wake_up_interruptible(sk->sk_sleep);
+		wake_up_interruptible(sk_sleep(sk));
 	/* Should agree with poll, otherwise some programs break */
 	if (sock_writeable(sk))
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
@@ -225,7 +225,7 @@ static int dccp_wait_for_ccid(struct sock *sk, stru=
ct sk_buff *skb, int delay)
 		dccp_pr_debug("delayed send by %d msec\n", delay);
 		jiffdelay =3D msecs_to_jiffies(delay);
=20
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 		sk->sk_write_pending++;
 		release_sock(sk);
@@ -241,7 +241,7 @@ static int dccp_wait_for_ccid(struct sock *sk, stru=
ct sk_buff *skb, int delay)
 		rc =3D ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 	} while ((delay =3D rc) > 0);
 out:
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return rc;
=20
 do_error:
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index a0e38d8..b03ecf6 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -312,7 +312,7 @@ unsigned int dccp_poll(struct file *file, struct so=
cket *sock,
 	unsigned int mask;
 	struct sock *sk =3D sock->sk;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	if (sk->sk_state =3D=3D DCCP_LISTEN)
 		return inet_csk_listen_poll(sk);
=20
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 55e3b6b..d6b93d1 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -832,7 +832,7 @@ static int dn_confirm_accept(struct sock *sk, long =
*timeo, gfp_t allocation)
 	scp->segsize_loc =3D dst_metric(__sk_dst_get(sk), RTAX_ADVMSS);
 	dn_send_conn_conf(sk, allocation);
=20
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	for(;;) {
 		release_sock(sk);
 		if (scp->state =3D=3D DN_CC)
@@ -850,9 +850,9 @@ static int dn_confirm_accept(struct sock *sk, long =
*timeo, gfp_t allocation)
 		err =3D -EAGAIN;
 		if (!*timeo)
 			break;
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (err =3D=3D 0) {
 		sk->sk_socket->state =3D SS_CONNECTED;
 	} else if (scp->state !=3D DN_CC) {
@@ -873,7 +873,7 @@ static int dn_wait_run(struct sock *sk, long *timeo=
)
 	if (!*timeo)
 		return -EALREADY;
=20
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	for(;;) {
 		release_sock(sk);
 		if (scp->state =3D=3D DN_CI || scp->state =3D=3D DN_CC)
@@ -891,9 +891,9 @@ static int dn_wait_run(struct sock *sk, long *timeo=
)
 		err =3D -ETIMEDOUT;
 		if (!*timeo)
 			break;
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 out:
 	if (err =3D=3D 0) {
 		sk->sk_socket->state =3D SS_CONNECTED;
@@ -1040,7 +1040,7 @@ static struct sk_buff *dn_wait_for_connect(struct=
 sock *sk, long *timeo)
 	struct sk_buff *skb =3D NULL;
 	int err =3D 0;
=20
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	for(;;) {
 		release_sock(sk);
 		skb =3D skb_dequeue(&sk->sk_receive_queue);
@@ -1060,9 +1060,9 @@ static struct sk_buff *dn_wait_for_connect(struct=
 sock *sk, long *timeo)
 		err =3D -EAGAIN;
 		if (!*timeo)
 			break;
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
=20
 	return skb =3D=3D NULL ? ERR_PTR(err) : skb;
 }
@@ -1746,11 +1746,11 @@ static int dn_recvmsg(struct kiocb *iocb, struc=
t socket *sock,
 			goto out;
 		}
=20
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 		sk_wait_event(sk, &timeo, dn_data_ready(sk, queue, flags, target));
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 	}
=20
 	skb_queue_walk_safe(queue, skb, n) {
@@ -2003,12 +2003,12 @@ static int dn_sendmsg(struct kiocb *iocb, struc=
t socket *sock,
 				goto out;
 			}
=20
-			prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+			prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 			set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 			sk_wait_event(sk, &timeo,
 				      !dn_queue_too_long(scp, queue, flags));
 			clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
-			finish_wait(sk->sk_sleep, &wait);
+			finish_wait(sk_sleep(sk), &wait);
 			continue;
 		}
=20
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index c5376c7..5ca7290 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -548,7 +548,7 @@ static long inet_wait_for_connect(struct sock *sk, =
long timeo)
 {
 	DEFINE_WAIT(wait);
=20
-	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 	/* Basic assumption: if someone sets sk->sk_err, he _must_
 	 * change state of the socket from TCP_SYN_*.
@@ -561,9 +561,9 @@ static long inet_wait_for_connect(struct sock *sk, =
long timeo)
 		lock_sock(sk);
 		if (signal_pending(current) || !timeo)
 			break;
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return timeo;
 }
=20
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 8da6429..e0a3e35 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -234,7 +234,7 @@ static int inet_csk_wait_for_connect(struct sock *s=
k, long timeo)
 	 * having to remove and re-insert us on the wait queue.
 	 */
 	for (;;) {
-		prepare_to_wait_exclusive(sk->sk_sleep, &wait,
+		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
 					  TASK_INTERRUPTIBLE);
 		release_sock(sk);
 		if (reqsk_queue_empty(&icsk->icsk_accept_queue))
@@ -253,7 +253,7 @@ static int inet_csk_wait_for_connect(struct sock *s=
k, long timeo)
 		if (!timeo)
 			break;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return err;
 }
=20
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0f8caf6..7720833 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -378,7 +378,7 @@ unsigned int tcp_poll(struct file *file, struct soc=
ket *sock, poll_table *wait)
 	struct sock *sk =3D sock->sk;
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	if (sk->sk_state =3D=3D TCP_LISTEN)
 		return inet_csk_listen_poll(sk);
=20
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 2a4efce..79986a6 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -347,7 +347,7 @@ static void irda_flow_indication(void *instance, vo=
id *sap, LOCAL_FLOW flow)
 		self->tx_flow =3D flow;
 		IRDA_DEBUG(1, "%s(), IrTTP wants us to start again\n",
 			   __func__);
-		wake_up_interruptible(sk->sk_sleep);
+		wake_up_interruptible(sk_sleep(sk));
 		break;
 	default:
 		IRDA_DEBUG(0, "%s(), Unknown flow command!\n", __func__);
@@ -900,7 +900,7 @@ static int irda_accept(struct socket *sock, struct =
socket *newsock, int flags)
 		if (flags & O_NONBLOCK)
 			goto out;
=20
-		err =3D wait_event_interruptible(*(sk->sk_sleep),
+		err =3D wait_event_interruptible(*(sk_sleep(sk)),
 					skb_peek(&sk->sk_receive_queue));
 		if (err)
 			goto out;
@@ -1066,7 +1066,7 @@ static int irda_connect(struct socket *sock, stru=
ct sockaddr *uaddr,
 		goto out;
=20
 	err =3D -ERESTARTSYS;
-	if (wait_event_interruptible(*(sk->sk_sleep),
+	if (wait_event_interruptible(*(sk_sleep(sk)),
 				     (sk->sk_state !=3D TCP_SYN_SENT)))
 		goto out;
=20
@@ -1318,7 +1318,7 @@ static int irda_sendmsg(struct kiocb *iocb, struc=
t socket *sock,
=20
 	/* Check if IrTTP is wants us to slow down */
=20
-	if (wait_event_interruptible(*(sk->sk_sleep),
+	if (wait_event_interruptible(*(sk_sleep(sk)),
 	    (self->tx_flow !=3D FLOW_STOP  ||  sk->sk_state !=3D TCP_ESTABLIS=
HED))) {
 		err =3D -ERESTARTSYS;
 		goto out;
@@ -1477,7 +1477,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb=
, struct socket *sock,
 			if (copied >=3D target)
 				break;
=20
-			prepare_to_wait_exclusive(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+			prepare_to_wait_exclusive(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 			/*
 			 *	POSIX 1003.1g mandates this order.
@@ -1497,7 +1497,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb=
, struct socket *sock,
 				/* Wait process until data arrives */
 				schedule();
=20
-			finish_wait(sk->sk_sleep, &wait);
+			finish_wait(sk_sleep(sk), &wait);
=20
 			if (err)
 				goto out;
@@ -1787,7 +1787,7 @@ static unsigned int irda_poll(struct file * file,=
 struct socket *sock,
 	IRDA_DEBUG(4, "%s()\n", __func__);
=20
 	lock_kernel();
-	poll_wait(file, sk->sk_sleep, wait);
+	poll_wait(file, sk_sleep(sk), wait);
 	mask =3D 0;
=20
 	/* Exceptional events? */
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index c18286a..9636b7d 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -59,7 +59,7 @@ do {									\
 	DEFINE_WAIT(__wait);						\
 	long __timeo =3D timeo;						\
 	ret =3D 0;							\
-	prepare_to_wait(sk->sk_sleep, &__wait, TASK_INTERRUPTIBLE);	\
+	prepare_to_wait(sk_sleep(sk), &__wait, TASK_INTERRUPTIBLE);	\
 	while (!(condition)) {						\
 		if (!__timeo) {						\
 			ret =3D -EAGAIN;					\
@@ -76,7 +76,7 @@ do {									\
 		if (ret)						\
 			break;						\
 	}								\
-	finish_wait(sk->sk_sleep, &__wait);				\
+	finish_wait(sk_sleep(sk), &__wait);				\
 } while (0)
=20
 #define iucv_sock_wait(sk, condition, timeo)				\
@@ -307,7 +307,7 @@ static void iucv_sock_wake_msglim(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);
 	if (sk_has_sleeper(sk))
-		wake_up_interruptible_all(sk->sk_sleep);
+		wake_up_interruptible_all(sk_sleep(sk));
 	sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	read_unlock(&sk->sk_callback_lock);
 }
@@ -795,7 +795,7 @@ static int iucv_sock_accept(struct socket *sock, st=
ruct socket *newsock,
 	timeo =3D sock_rcvtimeo(sk, flags & O_NONBLOCK);
=20
 	/* Wait for an incoming connection */
-	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
 	while (!(nsk =3D iucv_accept_dequeue(sk, newsock))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (!timeo) {
@@ -819,7 +819,7 @@ static int iucv_sock_accept(struct socket *sock, st=
ruct socket *newsock,
 	}
=20
 	set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
=20
 	if (err)
 		goto done;
@@ -1269,7 +1269,7 @@ unsigned int iucv_sock_poll(struct file *file, st=
ruct socket *sock,
 	struct sock *sk =3D sock->sk;
 	unsigned int mask =3D 0;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
=20
 	if (sk->sk_state =3D=3D IUCV_LISTEN)
 		return iucv_accept_poll(sk);
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 2db6a9f..023ba82 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -536,7 +536,7 @@ static int llc_ui_wait_for_disc(struct sock *sk, lo=
ng timeout)
 	int rc =3D 0;
=20
 	while (1) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		if (sk_wait_event(sk, &timeout, sk->sk_state =3D=3D TCP_CLOSE))
 			break;
 		rc =3D -ERESTARTSYS;
@@ -547,7 +547,7 @@ static int llc_ui_wait_for_disc(struct sock *sk, lo=
ng timeout)
 			break;
 		rc =3D 0;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return rc;
 }
=20
@@ -556,13 +556,13 @@ static int llc_ui_wait_for_conn(struct sock *sk, =
long timeout)
 	DEFINE_WAIT(wait);
=20
 	while (1) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		if (sk_wait_event(sk, &timeout, sk->sk_state !=3D TCP_SYN_SENT))
 			break;
 		if (signal_pending(current) || !timeout)
 			break;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return timeout;
 }
=20
@@ -573,7 +573,7 @@ static int llc_ui_wait_for_busy_core(struct sock *s=
k, long timeout)
 	int rc;
=20
 	while (1) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		rc =3D 0;
 		if (sk_wait_event(sk, &timeout,
 				  (sk->sk_shutdown & RCV_SHUTDOWN) ||
@@ -588,7 +588,7 @@ static int llc_ui_wait_for_busy_core(struct sock *s=
k, long timeout)
 		if (!timeout)
 			break;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return rc;
 }
=20
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs=
_sync.c
index 8fb0ae6..7ba0693 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -802,7 +802,7 @@ static int sync_thread_backup(void *data)
 		ip_vs_backup_mcast_ifn, ip_vs_backup_syncid);
=20
 	while (!kthread_should_stop()) {
-		wait_event_interruptible(*tinfo->sock->sk->sk_sleep,
+		wait_event_interruptible(*sk_sleep(tinfo->sock->sk),
 			 !skb_queue_empty(&tinfo->sock->sk->sk_receive_queue)
 			 || kthread_should_stop());
=20
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index fa07f04..06cb027 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -739,7 +739,7 @@ static int nr_connect(struct socket *sock, struct s=
ockaddr *uaddr,
 		DEFINE_WAIT(wait);
=20
 		for (;;) {
-			prepare_to_wait(sk->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk), &wait,
 					TASK_INTERRUPTIBLE);
 			if (sk->sk_state !=3D TCP_SYN_SENT)
 				break;
@@ -752,7 +752,7 @@ static int nr_connect(struct socket *sock, struct s=
ockaddr *uaddr,
 			err =3D -ERESTARTSYS;
 			break;
 		}
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
 		if (err)
 			goto out_release;
 	}
@@ -798,7 +798,7 @@ static int nr_accept(struct socket *sock, struct so=
cket *newsock, int flags)
 	 *	hooked into the SABM we saved
 	 */
 	for (;;) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		skb =3D skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
 			break;
@@ -816,7 +816,7 @@ static int nr_accept(struct socket *sock, struct so=
cket *newsock, int flags)
 		err =3D -ERESTARTSYS;
 		break;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (err)
 		goto out_release;
=20
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 7919a9e..aebfecb 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -158,7 +158,7 @@ static unsigned int rds_poll(struct file *file, str=
uct socket *sock,
 	unsigned int mask =3D 0;
 	unsigned long flags;
=20
-	poll_wait(file, sk->sk_sleep, wait);
+	poll_wait(file, sk_sleep(sk), wait);
=20
 	if (rs->rs_seen_congestion)
 		poll_wait(file, &rds_poll_waitq, wait);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 4bec6e2..c224b5b 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -492,7 +492,7 @@ void rds_sock_put(struct rds_sock *rs);
 void rds_wake_sk_sleep(struct rds_sock *rs);
 static inline void __rds_wake_sk_sleep(struct sock *sk)
 {
-	wait_queue_head_t *waitq =3D sk->sk_sleep;
+	wait_queue_head_t *waitq =3D sk_sleep(sk);
=20
 	if (!sock_flag(sk, SOCK_DEAD) && waitq)
 		wake_up(waitq);
diff --git a/net/rds/recv.c b/net/rds/recv.c
index e2a2b93..795a00b 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -432,7 +432,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *=
sock, struct msghdr *msg,
 				break;
 			}
=20
-			timeo =3D wait_event_interruptible_timeout(*sk->sk_sleep,
+			timeo =3D wait_event_interruptible_timeout(*sk_sleep(sk),
 					(!list_empty(&rs->rs_notify_queue) ||
 					 rs->rs_cong_notify ||
 					 rds_next_incoming(rs, &inc)), timeo);
diff --git a/net/rds/send.c b/net/rds/send.c
index 53d6795..9c1c6bc 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -915,7 +915,7 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *=
sock, struct msghdr *msg,
 			goto out;
 		}
=20
-		timeo =3D wait_event_interruptible_timeout(*sk->sk_sleep,
+		timeo =3D wait_event_interruptible_timeout(*sk_sleep(sk),
 					rds_send_queue_rm(rs, conn, rm,
 							  rs->rs_bound_port,
 							  dport,
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 4fb711a..8e45e76 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -845,7 +845,7 @@ rose_try_next_neigh:
 		DEFINE_WAIT(wait);
=20
 		for (;;) {
-			prepare_to_wait(sk->sk_sleep, &wait,
+			prepare_to_wait(sk_sleep(sk), &wait,
 					TASK_INTERRUPTIBLE);
 			if (sk->sk_state !=3D TCP_SYN_SENT)
 				break;
@@ -858,7 +858,7 @@ rose_try_next_neigh:
 			err =3D -ERESTARTSYS;
 			break;
 		}
-		finish_wait(sk->sk_sleep, &wait);
+		finish_wait(sk_sleep(sk), &wait);
=20
 		if (err)
 			goto out_release;
@@ -911,7 +911,7 @@ static int rose_accept(struct socket *sock, struct =
socket *newsock, int flags)
 	 *	hooked into the SABM we saved
 	 */
 	for (;;) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 		skb =3D skb_dequeue(&sk->sk_receive_queue);
 		if (skb)
@@ -930,7 +930,7 @@ static int rose_accept(struct socket *sock, struct =
socket *newsock, int flags)
 		err =3D -ERESTARTSYS;
 		break;
 	}
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	if (err)
 		goto out_release;
=20
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index c060095..c432d76 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -65,7 +65,7 @@ static void rxrpc_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
 	if (rxrpc_writable(sk)) {
 		if (sk_has_sleeper(sk))
-			wake_up_interruptible(sk->sk_sleep);
+			wake_up_interruptible(sk_sleep(sk));
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
 	read_unlock(&sk->sk_callback_lock);
@@ -589,7 +589,7 @@ static unsigned int rxrpc_poll(struct file *file, s=
truct socket *sock,
 	unsigned int mask;
 	struct sock *sk =3D sock->sk;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask =3D 0;
=20
 	/* the socket is readable if there are any messages waiting on the Rx
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c194127..f34adcc 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5702,7 +5702,7 @@ unsigned int sctp_poll(struct file *file, struct =
socket *sock, poll_table *wait)
 	struct sctp_sock *sp =3D sctp_sk(sk);
 	unsigned int mask;
=20
-	poll_wait(file, sk->sk_sleep, wait);
+	poll_wait(file, sk_sleep(sk), wait);
=20
 	/* A TCP-style listening socket becomes readable when the accept queu=
e
 	 * is not empty.
@@ -5943,7 +5943,7 @@ static int sctp_wait_for_packet(struct sock * sk,=
 int *err, long *timeo_p)
 	int error;
 	DEFINE_WAIT(wait);
=20
-	prepare_to_wait_exclusive(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait_exclusive(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 	/* Socket errors? */
 	error =3D sock_error(sk);
@@ -5980,14 +5980,14 @@ static int sctp_wait_for_packet(struct sock * s=
k, int *err, long *timeo_p)
 	sctp_lock_sock(sk);
=20
 ready:
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	return 0;
=20
 interrupted:
 	error =3D sock_intr_errno(*timeo_p);
=20
 out:
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	*err =3D error;
 	return error;
 }
@@ -6061,8 +6061,8 @@ static void __sctp_write_space(struct sctp_associ=
ation *asoc)
 			wake_up_interruptible(&asoc->wait);
=20
 		if (sctp_writeable(sk)) {
-			if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-				wake_up_interruptible(sk->sk_sleep);
+			if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+				wake_up_interruptible(sk_sleep(sk));
=20
 			/* Note that we try to include the Async I/O support
 			 * here by modeling from the current TCP/UDP code.
@@ -6296,7 +6296,7 @@ static int sctp_wait_for_accept(struct sock *sk, =
long timeo)
=20
=20
 	for (;;) {
-		prepare_to_wait_exclusive(sk->sk_sleep, &wait,
+		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
 					  TASK_INTERRUPTIBLE);
=20
 		if (list_empty(&ep->asocs)) {
@@ -6322,7 +6322,7 @@ static int sctp_wait_for_accept(struct sock *sk, =
long timeo)
 			break;
 	}
=20
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
=20
 	return err;
 }
@@ -6332,7 +6332,7 @@ static void sctp_wait_for_close(struct sock *sk, =
long timeout)
 	DEFINE_WAIT(wait);
=20
 	do {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		if (list_empty(&sctp_sk(sk)->ep->asocs))
 			break;
 		sctp_release_sock(sk);
@@ -6340,7 +6340,7 @@ static void sctp_wait_for_close(struct sock *sk, =
long timeout)
 		sctp_lock_sock(sk);
 	} while (!signal_pending(current) && timeout);
=20
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 }
=20
 static void sctp_skb_set_owner_r_frag(struct sk_buff *skb, struct sock=
 *sk)
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a29f259..ce0d5b3 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -419,8 +419,8 @@ static void svc_udp_data_ready(struct sock *sk, int=
 count)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible(sk->sk_sleep);
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible(sk_sleep(sk));
 }
=20
 /*
@@ -436,10 +436,10 @@ static void svc_write_space(struct sock *sk)
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
=20
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep)) {
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk))) {
 		dprintk("RPC svc_write_space: someone sleeping on %p\n",
 		       svsk);
-		wake_up_interruptible(sk->sk_sleep);
+		wake_up_interruptible(sk_sleep(sk));
 	}
 }
=20
@@ -757,8 +757,8 @@ static void svc_tcp_listen_data_ready(struct sock *=
sk, int count_unused)
 			printk("svc: socket %p: no user data\n", sk);
 	}
=20
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_all(sk->sk_sleep);
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible_all(sk_sleep(sk));
 }
=20
 /*
@@ -777,8 +777,8 @@ static void svc_tcp_state_change(struct sock *sk)
 		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_all(sk->sk_sleep);
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible_all(sk_sleep(sk));
 }
=20
 static void svc_tcp_data_ready(struct sock *sk, int count)
@@ -791,8 +791,8 @@ static void svc_tcp_data_ready(struct sock *sk, int=
 count)
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 		svc_xprt_enqueue(&svsk->sk_xprt);
 	}
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible(sk->sk_sleep);
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible(sk_sleep(sk));
 }
=20
 /*
@@ -1494,8 +1494,8 @@ static void svc_sock_detach(struct svc_xprt *xprt=
)
 	sk->sk_data_ready =3D svsk->sk_odata;
 	sk->sk_write_space =3D svsk->sk_owspace;
=20
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible(sk->sk_sleep);
+	if (sk_sleep(sk) && waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible(sk_sleep(sk));
 }
=20
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index cfb20b8..66e889b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -446,7 +446,7 @@ static unsigned int poll(struct file *file, struct =
socket *sock,
 	struct sock *sk =3D sock->sk;
 	u32 mask;
=20
-	poll_wait(file, sk->sk_sleep, wait);
+	poll_wait(file, sk_sleep(sk), wait);
=20
 	if (!skb_queue_empty(&sk->sk_receive_queue) ||
 	    (sock->state =3D=3D SS_UNCONNECTED) ||
@@ -591,7 +591,7 @@ static int send_msg(struct kiocb *iocb, struct sock=
et *sock,
 			break;
 		}
 		release_sock(sk);
-		res =3D wait_event_interruptible(*sk->sk_sleep,
+		res =3D wait_event_interruptible(*sk_sleep(sk),
 					       !tport->congested);
 		lock_sock(sk);
 		if (res)
@@ -650,7 +650,7 @@ static int send_packet(struct kiocb *iocb, struct s=
ocket *sock,
 			break;
 		}
 		release_sock(sk);
-		res =3D wait_event_interruptible(*sk->sk_sleep,
+		res =3D wait_event_interruptible(*sk_sleep(sk),
 			(!tport->congested || !tport->connected));
 		lock_sock(sk);
 		if (res)
@@ -931,7 +931,7 @@ restart:
 			goto exit;
 		}
 		release_sock(sk);
-		res =3D wait_event_interruptible(*sk->sk_sleep,
+		res =3D wait_event_interruptible(*sk_sleep(sk),
 			(!skb_queue_empty(&sk->sk_receive_queue) ||
 			 (sock->state =3D=3D SS_DISCONNECTING)));
 		lock_sock(sk);
@@ -1064,7 +1064,7 @@ restart:
 			goto exit;
 		}
 		release_sock(sk);
-		res =3D wait_event_interruptible(*sk->sk_sleep,
+		res =3D wait_event_interruptible(*sk_sleep(sk),
 			(!skb_queue_empty(&sk->sk_receive_queue) ||
 			 (sock->state =3D=3D SS_DISCONNECTING)));
 		lock_sock(sk);
@@ -1271,8 +1271,8 @@ static u32 filter_rcv(struct sock *sk, struct sk_=
buff *buf)
 		tipc_disconnect_port(tipc_sk_port(sk));
 	}
=20
-	if (waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible(sk->sk_sleep);
+	if (waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible(sk_sleep(sk));
 	return TIPC_OK;
 }
=20
@@ -1343,8 +1343,8 @@ static void wakeupdispatch(struct tipc_port *tpor=
t)
 {
 	struct sock *sk =3D (struct sock *)tport->usr_handle;
=20
-	if (waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible(sk->sk_sleep);
+	if (waitqueue_active(sk_sleep(sk)))
+		wake_up_interruptible(sk_sleep(sk));
 }
=20
 /**
@@ -1426,7 +1426,7 @@ static int connect(struct socket *sock, struct so=
ckaddr *dest, int destlen,
 	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
=20
 	release_sock(sk);
-	res =3D wait_event_interruptible_timeout(*sk->sk_sleep,
+	res =3D wait_event_interruptible_timeout(*sk_sleep(sk),
 			(!skb_queue_empty(&sk->sk_receive_queue) ||
 			(sock->state !=3D SS_CONNECTING)),
 			sk->sk_rcvtimeo);
@@ -1521,7 +1521,7 @@ static int accept(struct socket *sock, struct soc=
ket *new_sock, int flags)
 			goto exit;
 		}
 		release_sock(sk);
-		res =3D wait_event_interruptible(*sk->sk_sleep,
+		res =3D wait_event_interruptible(*sk_sleep(sk),
 				(!skb_queue_empty(&sk->sk_receive_queue)));
 		lock_sock(sk);
 		if (res)
@@ -1632,8 +1632,8 @@ restart:
 		/* Discard any unreceived messages; wake up sleeping tasks */
=20
 		discard_rx_queue(sk);
-		if (waitqueue_active(sk->sk_sleep))
-			wake_up_interruptible(sk->sk_sleep);
+		if (waitqueue_active(sk_sleep(sk)))
+			wake_up_interruptible(sk_sleep(sk));
 		res =3D 0;
 		break;
=20
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3d9122e..87c0360 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -316,7 +316,7 @@ static void unix_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
 	if (unix_writable(sk)) {
 		if (sk_has_sleeper(sk))
-			wake_up_interruptible_sync(sk->sk_sleep);
+			wake_up_interruptible_sync(sk_sleep(sk));
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
 	read_unlock(&sk->sk_callback_lock);
@@ -1736,7 +1736,7 @@ static long unix_stream_data_wait(struct sock *sk=
, long timeo)
 	unix_state_lock(sk);
=20
 	for (;;) {
-		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
=20
 		if (!skb_queue_empty(&sk->sk_receive_queue) ||
 		    sk->sk_err ||
@@ -1752,7 +1752,7 @@ static long unix_stream_data_wait(struct sock *sk=
, long timeo)
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	}
=20
-	finish_wait(sk->sk_sleep, &wait);
+	finish_wait(sk_sleep(sk), &wait);
 	unix_state_unlock(sk);
 	return timeo;
 }
@@ -1991,7 +1991,7 @@ static unsigned int unix_poll(struct file *file, =
struct socket *sock, poll_table
 	struct sock *sk =3D sock->sk;
 	unsigned int mask;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask =3D 0;
=20
 	/* exceptional events? */
@@ -2028,7 +2028,7 @@ static unsigned int unix_dgram_poll(struct file *=
file, struct socket *sock,
 	struct sock *sk =3D sock->sk, *other;
 	unsigned int mask, writable;
=20
-	sock_poll_wait(file, sk->sk_sleep, wait);
+	sock_poll_wait(file, sk_sleep(sk), wait);
 	mask =3D 0;
=20
 	/* exceptional events? */
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index cbddd0c..6cffbc4 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -718,7 +718,7 @@ static int x25_wait_for_connection_establishment(st=
ruct sock *sk)
 	DECLARE_WAITQUEUE(wait, current);
 	int rc;
=20
-	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
 	for (;;) {
 		__set_current_state(TASK_INTERRUPTIBLE);
 		rc =3D -ERESTARTSYS;
@@ -738,7 +738,7 @@ static int x25_wait_for_connection_establishment(st=
ruct sock *sk)
 			break;
 	}
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return rc;
 }
=20
@@ -838,7 +838,7 @@ static int x25_wait_for_data(struct sock *sk, long =
timeout)
 	DECLARE_WAITQUEUE(wait, current);
 	int rc =3D 0;
=20
-	add_wait_queue_exclusive(sk->sk_sleep, &wait);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
 	for (;;) {
 		__set_current_state(TASK_INTERRUPTIBLE);
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
@@ -858,7 +858,7 @@ static int x25_wait_for_data(struct sock *sk, long =
timeout)
 			break;
 	}
 	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(sk->sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	return rc;
 }
=20


