From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH 4/6] Phonet: receive pipe control requests as out-of-band data
Date: Wed,  1 Oct 2008 13:13:03 +0300
Message-ID: <1222855985-22859-4-git-send-email-remi.denis-courmont@nokia.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:38249 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbYJAKNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 06:13:31 -0400
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m91ADG2b022099
	for <netdev@vger.kernel.org>; Wed, 1 Oct 2008 13:13:29 +0300
In-Reply-To: <200810011312.17288.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    2 +
 net/phonet/pep.c         |   65 +++++++++++++++++++++++++++++++++-----=
-------
 net/phonet/socket.c      |    4 ++-
 3 files changed, 52 insertions(+), 19 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 6b89d12..b06852b 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -33,6 +33,8 @@ struct pep_sock {
=20
 	/* Connected socket stuff: */
 	struct sock		*listener;
+	struct sk_buff_head	ctrlreq_queue;
+#define PNPIPE_CTRLREQ_MAX	10
 	u16			peer_type;	/* peer type/subtype */
 	u8			pipe_handle;
=20
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 0c1f19f..9a2ed45 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -135,14 +135,15 @@ static int pep_reject_conn(struct sock *sk, struc=
t sk_buff *skb, u8 code)
=20
 /* Control requests are not sent by the pipe service and have a specif=
ic
  * message format. */
-static int pep_ctrlreq_error(struct sock *sk, struct sk_buff *oskb, u8=
 code)
+static int pep_ctrlreq_error(struct sock *sk, struct sk_buff *oskb, u8=
 code,
+				gfp_t priority)
 {
 	const struct pnpipehdr *oph =3D pnp_hdr(oskb);
 	struct sk_buff *skb;
 	struct pnpipehdr *ph;
 	struct sockaddr_pn dst;
=20
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, GFP_ATOMIC);
+	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, priority);
 	if (!skb)
 		return -ENOMEM;
 	skb_set_owner_w(skb, sk);
@@ -303,6 +304,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	struct sk_buff_head *queue;
 	int err =3D 0;
=20
 	BUG_ON(sk->sk_state =3D=3D TCP_CLOSE_WAIT);
@@ -343,9 +345,11 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 		break;
=20
 	case PNS_PEP_CTRL_REQ:
-		/* TODO */
-		pep_ctrlreq_error(sk, skb, PN_PIPE_NO_ERROR);
-		break;
+		if (skb_queue_len(&pn->ctrlreq_queue) >=3D PNPIPE_CTRLREQ_MAX)
+			break;
+		__skb_pull(skb, 4);
+		queue =3D &pn->ctrlreq_queue;
+		goto queue;
=20
 	case PNS_PIPE_DATA:
 		__skb_pull(skb, 3); /* Pipe data header */
@@ -361,13 +365,8 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 			break;
 		}
 		pn->rx_credits--;
-		skb->dev =3D NULL;
-		skb_set_owner_r(skb, sk);
-		err =3D skb->len;
-		skb_queue_tail(&sk->sk_receive_queue, skb);
-		if (!sock_flag(sk, SOCK_DEAD))
-			sk->sk_data_ready(sk, err);
-		return 0;
+		queue =3D &sk->sk_receive_queue;
+		goto queue;
=20
 	case PNS_PEP_STATUS_IND:
 		pipe_rcv_status(sk, skb);
@@ -411,12 +410,24 @@ static int pipe_do_rcv(struct sock *sk, struct sk=
_buff *skb)
 out:
 	kfree_skb(skb);
 	return err;
+
+queue:
+	skb->dev =3D NULL;
+	skb_set_owner_r(skb, sk);
+	err =3D skb->len;
+	skb_queue_tail(queue, skb);
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, err);
+	return 0;
 }
=20
 /* Destroy connected sock. */
 static void pipe_destruct(struct sock *sk)
 {
+	struct pep_sock *pn =3D pep_sk(sk);
+
 	skb_queue_purge(&sk->sk_receive_queue);
+	skb_queue_purge(&pn->ctrlreq_queue);
 }
=20
 static int pep_connreq_rcv(struct sock *sk, struct sk_buff *skb)
@@ -489,6 +500,7 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 	pn_skb_get_dst_sockaddr(skb, &dst);
 	newpn->pn_sk.sobject =3D pn_sockaddr_get_object(&dst);
 	newpn->pn_sk.resource =3D pn->pn_sk.resource;
+	skb_queue_head_init(&newpn->ctrlreq_queue);
 	newpn->pipe_handle =3D pipe_handle;
 	newpn->peer_type =3D peer_type;
 	newpn->rx_credits =3D newpn->tx_credits =3D 0;
@@ -579,7 +591,7 @@ static int pep_do_rcv(struct sock *sk, struct sk_bu=
ff *skb)
 		break;
=20
 	case PNS_PEP_CTRL_REQ:
-		pep_ctrlreq_error(sk, skb, PN_PIPE_INVALID_HANDLE);
+		pep_ctrlreq_error(sk, skb, PN_PIPE_INVALID_HANDLE, GFP_ATOMIC);
 		break;
=20
 	case PNS_PEP_RESET_REQ:
@@ -682,6 +694,7 @@ out:
=20
 static int pep_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
+	struct pep_sock *pn =3D pep_sk(sk);
 	int answ;
=20
 	switch (cmd) {
@@ -690,7 +703,10 @@ static int pep_ioctl(struct sock *sk, int cmd, uns=
igned long arg)
 			return -EINVAL;
=20
 		lock_sock(sk);
-		if (!skb_queue_empty(&sk->sk_receive_queue))
+		if (sock_flag(sk, SOCK_URGINLINE)
+		 && !skb_queue_empty(&pn->ctrlreq_queue))
+			answ =3D skb_peek(&pn->ctrlreq_queue)->len;
+		else if (!skb_queue_empty(&sk->sk_receive_queue))
 			answ =3D skb_peek(&sk->sk_receive_queue)->len;
 		else
 			answ =3D 0;
@@ -707,6 +723,7 @@ static int pep_init(struct sock *sk)
=20
 	INIT_HLIST_HEAD(&pn->ackq);
 	INIT_HLIST_HEAD(&pn->hlist);
+	skb_queue_head_init(&pn->ctrlreq_queue);
 	pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
 	return 0;
 }
@@ -807,11 +824,24 @@ static int pep_recvmsg(struct kiocb *iocb, struct=
 sock *sk,
 	struct sk_buff *skb;
 	int err;
=20
-	if (unlikely(flags & MSG_OOB))
-		return -EOPNOTSUPP;
 	if (unlikely(1 << sk->sk_state & (TCPF_LISTEN | TCPF_CLOSE)))
 		return -ENOTCONN;
=20
+	if ((flags & MSG_OOB) || sock_flag(sk, SOCK_URGINLINE)) {
+		/* Dequeue and acknowledge control request */
+		struct pep_sock *pn =3D pep_sk(sk);
+
+		skb =3D skb_dequeue(&pn->ctrlreq_queue);
+		if (skb) {
+			pep_ctrlreq_error(sk, skb, PN_PIPE_NO_ERROR,
+						GFP_KERNEL);
+			msg->msg_flags |=3D MSG_OOB;
+			goto copy;
+		}
+		if (flags & MSG_OOB)
+			return -EINVAL;
+	}
+
 	skb =3D skb_recv_datagram(sk, flags, noblock, &err);
 	lock_sock(sk);
 	if (skb =3D=3D NULL) {
@@ -824,9 +854,8 @@ static int pep_recvmsg(struct kiocb *iocb, struct s=
ock *sk,
 	if (sk->sk_state =3D=3D TCP_ESTABLISHED)
 		pipe_grant_credits(sk);
 	release_sock(sk);
-
+copy:
 	msg->msg_flags |=3D MSG_EOR;
-
 	if (skb->len > len)
 		msg->msg_flags |=3D MSG_TRUNC;
 	else
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index cea1136..a9c3d1f 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -220,7 +220,9 @@ static unsigned int pn_socket_poll(struct file *fil=
e, struct socket *sock,
=20
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |=3D POLLIN | POLLRDNORM;
-	else if (sk->sk_state =3D=3D TCP_CLOSE_WAIT)
+	if (!skb_queue_empty(&pn->ctrlreq_queue))
+		mask |=3D POLLPRI;
+	if (!mask && sk->sk_state =3D=3D TCP_CLOSE_WAIT)
 		return POLLHUP;
=20
 	if (sk->sk_state =3D=3D TCP_ESTABLISHED && pn->tx_credits)
--=20
1.5.4.3

