From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sk_sleep() helper
Date: Mon, 26 Apr 2010 10:20:06 +0200
Message-ID: <1272270006.2346.13.camel@edumazet-laptop>
References: <20100413.015232.67916764.davem@davemloft.net>
	 <1271199845.16881.586.camel@edumazet-laptop>
	 <1271804631.7895.519.camel@edumazet-laptop>
	 <20100420.163919.82125824.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:52569 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab0DZIUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 04:20:11 -0400
Received: by bwz19 with SMTP id 19so228125bwz.21
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 01:20:09 -0700 (PDT)
In-Reply-To: <20100420.163919.82125824.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 16:39 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 21 Apr 2010 01:03:51 +0200
>=20
> > [PATCH net-next-2.6] net: sk_sleep() helper
>=20
> Looks good, applied, thanks Eric.

Here is a followup to this patch, I missed three files in this
conversion.

Thanks !

[PATCH net-next-2.6] net: use sk_sleep()

Commit aa395145 (net: sk_sleep() helper) missed three files in the
conversion.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/macvtap.c  |    6 +++---
 net/caif/caif_socket.c |   30 +++++++++++++++---------------
 net/rxrpc/ar-recvmsg.c |    6 +++---
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 85d6420..d97e1fd 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -181,7 +181,7 @@ static int macvtap_forward(struct net_device *dev, =
struct sk_buff *skb)
 		return -ENOLINK;
=20
 	skb_queue_tail(&q->sk.sk_receive_queue, skb);
-	wake_up_interruptible_poll(q->sk.sk_sleep, POLLIN | POLLRDNORM | POLL=
RDBAND);
+	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | PO=
LLRDBAND);
 	return 0;
 }
=20
@@ -562,7 +562,7 @@ static ssize_t macvtap_do_read(struct macvtap_queue=
 *q, struct kiocb *iocb,
 	struct sk_buff *skb;
 	ssize_t ret =3D 0;
=20
-	add_wait_queue(q->sk.sk_sleep, &wait);
+	add_wait_queue(sk_sleep(&q->sk), &wait);
 	while (len) {
 		current->state =3D TASK_INTERRUPTIBLE;
=20
@@ -587,7 +587,7 @@ static ssize_t macvtap_do_read(struct macvtap_queue=
 *q, struct kiocb *iocb,
 	}
=20
 	current->state =3D TASK_RUNNING;
-	remove_wait_queue(q->sk.sk_sleep, &wait);
+	remove_wait_queue(sk_sleep(&q->sk), &wait);
 	return ret;
 }
=20
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 90317e7..d455375 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -169,7 +169,7 @@ static int caif_sktrecv_cb(struct cflayer *layr, st=
ruct cfpkt *pkt)
=20
 	/* Signal reader that data is available. */
=20
-	wake_up_interruptible(cf_sk->sk.sk_sleep);
+	wake_up_interruptible(sk_sleep(&cf_sk->sk));
=20
 	return 0;
 }
@@ -203,7 +203,7 @@ static void caif_sktflowctrl_cb(struct cflayer *lay=
r,
 		dbfs_atomic_inc(&cnt.num_tx_flow_on_ind);
 		/* Signal reader that data is available. */
 		SET_TX_FLOW_ON(cf_sk);
-		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		wake_up_interruptible(sk_sleep(&cf_sk->sk));
 		break;
=20
 	case CAIF_CTRLCMD_FLOW_OFF_IND:
@@ -217,7 +217,7 @@ static void caif_sktflowctrl_cb(struct cflayer *lay=
r,
 		caif_assert(STATE_IS_OPEN(cf_sk));
 		SET_PENDING_OFF(cf_sk);
 		SET_TX_FLOW_ON(cf_sk);
-		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		wake_up_interruptible(sk_sleep(&cf_sk->sk));
 		break;
=20
 	case CAIF_CTRLCMD_DEINIT_RSP:
@@ -225,8 +225,8 @@ static void caif_sktflowctrl_cb(struct cflayer *lay=
r,
 		caif_assert(!STATE_IS_OPEN(cf_sk));
 		SET_PENDING_OFF(cf_sk);
 		if (!STATE_IS_PENDING_DESTROY(cf_sk)) {
-			if (cf_sk->sk.sk_sleep !=3D NULL)
-				wake_up_interruptible(cf_sk->sk.sk_sleep);
+			if (sk_sleep(&cf_sk->sk) !=3D NULL)
+				wake_up_interruptible(sk_sleep(&cf_sk->sk));
 		}
 		dbfs_atomic_inc(&cnt.num_deinit);
 		sock_put(&cf_sk->sk);
@@ -238,7 +238,7 @@ static void caif_sktflowctrl_cb(struct cflayer *lay=
r,
 		SET_STATE_CLOSED(cf_sk);
 		SET_PENDING_OFF(cf_sk);
 		SET_TX_FLOW_OFF(cf_sk);
-		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		wake_up_interruptible(sk_sleep(&cf_sk->sk));
 		break;
=20
 	case CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND:
@@ -247,7 +247,7 @@ static void caif_sktflowctrl_cb(struct cflayer *lay=
r,
 		/* Use sk_shutdown to indicate remote shutdown indication */
 		cf_sk->sk.sk_shutdown |=3D RCV_SHUTDOWN;
 		cf_sk->file_mode =3D 0;
-		wake_up_interruptible(cf_sk->sk.sk_sleep);
+		wake_up_interruptible(sk_sleep(&cf_sk->sk));
 		break;
=20
 	default:
@@ -325,7 +325,7 @@ static int caif_recvmsg(struct kiocb *iocb, struct =
socket *sock,
 		release_sock(&cf_sk->sk);
=20
 		result =3D
-		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 					     !STATE_IS_PENDING(cf_sk));
=20
 		lock_sock(&(cf_sk->sk));
@@ -365,7 +365,7 @@ static int caif_recvmsg(struct kiocb *iocb, struct =
socket *sock,
 		release_sock(&cf_sk->sk);
=20
 		/* Block reader until data arrives or socket is closed. */
-		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		if (wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 					cfpkt_qpeek(cf_sk->pktq)
 					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
 					|| !STATE_IS_OPEN(cf_sk)) =3D=3D
@@ -537,7 +537,7 @@ static int caif_sendmsg(struct kiocb *kiocb, struct=
 socket *sock,
 		 * for its conclusion.
 		 */
 		result =3D
-		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 					     !STATE_IS_PENDING(cf_sk));
 		/* I want to be alone on cf_sk (except status and queue) */
 		lock_sock(&(cf_sk->sk));
@@ -573,7 +573,7 @@ static int caif_sendmsg(struct kiocb *kiocb, struct=
 socket *sock,
 		release_sock(&cf_sk->sk);
=20
 		/* Wait until flow is on or socket is closed */
-		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		if (wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 					TX_FLOW_IS_ON(cf_sk)
 					|| !STATE_IS_OPEN(cf_sk)
 					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
@@ -650,7 +650,7 @@ static int caif_sendmsg(struct kiocb *kiocb, struct=
 socket *sock,
 		release_sock(&cf_sk->sk);
=20
 		/* Wait until flow is on or socket is closed */
-		if (wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		if (wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 					TX_FLOW_IS_ON(cf_sk)
 					|| !STATE_IS_OPEN(cf_sk)
 					|| STATE_IS_REMOTE_SHUTDOWN(cf_sk)
@@ -898,7 +898,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uservaddr,
 			 * for its conclusion.
 			 */
 			result =3D
-			    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+			    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 						     !STATE_IS_PENDING(cf_sk));
=20
 			lock_sock(&(cf_sk->sk));
@@ -965,7 +965,7 @@ static int caif_connect(struct socket *sock, struct=
 sockaddr *uservaddr,
 		release_sock(&cf_sk->sk);
=20
 		result =3D
-		    wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		    wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 					     !STATE_IS_PENDING(cf_sk));
=20
 		lock_sock(&(cf_sk->sk));
@@ -1107,7 +1107,7 @@ static int caif_release(struct socket *sock)
 	 * CAIF stack.
 	 */
 	if (!(sock->file->f_flags & O_NONBLOCK)) {
-		res =3D wait_event_interruptible(*cf_sk->sk.sk_sleep,
+		res =3D wait_event_interruptible(*sk_sleep(&cf_sk->sk),
 						!STATE_IS_PENDING(cf_sk));
=20
 		if (res =3D=3D -ERESTARTSYS) {
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 60c2b94..0c65013 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -91,7 +91,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *=
sock,
=20
 			/* wait for a message to turn up */
 			release_sock(&rx->sk);
-			prepare_to_wait_exclusive(rx->sk.sk_sleep, &wait,
+			prepare_to_wait_exclusive(sk_sleep(&rx->sk), &wait,
 						  TASK_INTERRUPTIBLE);
 			ret =3D sock_error(&rx->sk);
 			if (ret)
@@ -102,7 +102,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket=
 *sock,
 					goto wait_interrupted;
 				timeo =3D schedule_timeout(timeo);
 			}
-			finish_wait(rx->sk.sk_sleep, &wait);
+			finish_wait(sk_sleep(&rx->sk), &wait);
 			lock_sock(&rx->sk);
 			continue;
 		}
@@ -356,7 +356,7 @@ csum_copy_error:
 wait_interrupted:
 	ret =3D sock_intr_errno(timeo);
 wait_error:
-	finish_wait(rx->sk.sk_sleep, &wait);
+	finish_wait(sk_sleep(&rx->sk), &wait);
 	if (continue_call)
 		rxrpc_put_call(continue_call);
 	if (copied)


