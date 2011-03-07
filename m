From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 7/8] Phonet: support active connection without pipe controller on modem
Date: Mon,  7 Mar 2011 12:46:11 +0200
Message-ID: <1299494772-3965-7-git-send-email-remi.denis-courmont@nokia.com>
References: <201103071245.47722.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.26]:36601 "EHLO mgw-da02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888Ab1CGKpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 05:45:24 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-da02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p27AjHe8005748
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2011 12:45:23 +0200
In-Reply-To: <201103071245.47722.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides support for newer ISI modems with no need for the
earlier experimental compile-time alternative choice. This also fixes
a number of remaining bugs in the old ST-E code.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |   53 +++++------
 net/phonet/pep.c                    |  172 ++++++++++++++++++++-------=
-------
 net/phonet/socket.c                 |  102 ++++++++-------------
 3 files changed, 165 insertions(+), 162 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index cacac96..3d12779 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -154,9 +154,28 @@ connections, one per accept()'d socket.
     write(cfd, msg, msglen);
   }
=20
-Connections are established between two endpoints by a "third party"
-application. This means that both endpoints are passive; so connect()
-is not possible.
+Connections are traditionally established between two endpoints by a
+"third party" application. This means that both endpoints are passive.
+
+
+As of Linux kernel version 2.6.39, it is also possible to connect
+two endpoints directly, using connect() on the active side. This is
+intended to support the newer Nokia Wireless Modem API, as found in
+e.g. the Nokia Slim Modem in the ST-Ericsson U8500 platform:
+
+  struct sockaddr_spn spn;
+  int fd;
+
+  fd =3D socket(PF_PHONET, SOCK_SEQPACKET, PN_PROTO_PIPE);
+  memset(&spn, 0, sizeof(spn));
+  spn.spn_family =3D AF_PHONET;
+  spn.spn_obj =3D ...;
+  spn.spn_dev =3D ...;
+  spn.spn_resource =3D 0xD9;
+  connect(fd, (struct sockaddr *)&spn, sizeof(spn));
+  /* normal I/O here ... */
+  close(fd);
+
=20
 WARNING:
 When polling a connected pipe socket for writability, there is an
@@ -189,17 +208,8 @@ The pipe protocol provides two socket options at t=
he SOL_PNPIPE level:
 Phonet Pipe-controller Implementation
 -------------------------------------
=20
-Phonet Pipe-controller is enabled by selecting the CONFIG_PHONET_PIPEC=
TRLR Kconfig
-option. It is useful when communicating with those Nokia Modems which =
do not
-implement Pipe controller in them e.g. Nokia Slim Modem used in ST-Eri=
csson
-U8500 platform.
-
-The implementation is based on the Data Connection Establishment Seque=
nce
-depicted in 'Nokia Wireless Modem API - Wireless_modem_user_guide.pdf'
-document.
-
-It allows a phonet sequenced socket (host-pep) to initiate a Pipe conn=
ection
-between itself and a remote pipe-end point (e.g. modem).
+Phonet Pipe-controller is enabled by selecting the CONFIG_PHONET_PIPEC=
TRLR
+Kconfig option.
=20
 The implementation adds socket options at SOL_PNPIPE level:
=20
@@ -207,21 +217,6 @@ The implementation adds socket options at SOL_PNPI=
PE level:
     is disabled. If the value is non-zero, the pipe is enabled. If the=
 pipe
     is not (yet) connected, ENOTCONN is error is returned.
=20
-The implementation also adds socket 'connect'. On calling the 'connect=
', pipe
-will be created between the source socket and the destination, and the=
 pipe
-state will be set to PIPE_DISABLED.
-
-After a pipe has been created and enabled successfully, the Pipe data =
can be
-exchanged between the host-pep and remote-pep (modem).
-
-User-space would typically follow below sequence with Pipe controller:=
-
--socket
--bind
--setsockopt for PNPIPE_PIPE_HANDLE
--connect
--setsockopt for PNPIPE_ENCAP_IP
--setsockopt for PNPIPE_ENABLE
-
=20
 Authors
 -------
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index abfb795..671effb 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -136,7 +136,6 @@ static int pep_indicate(struct sock *sk, u8 id, u8 =
code,
=20
 #define PAD 0x00
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
 static int pipe_handler_request(struct sock *sk, u8 id, u8 code,
 				const void *data, int len)
 {
@@ -168,11 +167,7 @@ static int pipe_handler_send_created_ind(struct so=
ck *sk)
 				data, 4, GFP_ATOMIC);
 }
=20
-static int pipe_handler_send_ind(struct sock *sk, u8 id)
-{
-	return pep_indicate(sk, id, PAD, NULL, 0, GFP_ATOMIC);
-}
-
+#ifdef CONFIG_PHONET_PIPECTRLR
 static int pipe_handler_enable_pipe(struct sock *sk, int enable)
 {
 	u8 id =3D enable ? PNS_PEP_ENABLE_REQ : PNS_PEP_DISABLE_REQ;
@@ -376,32 +371,11 @@ static int pipe_do_rcv(struct sock *sk, struct sk=
_buff *skb)
 			sk->sk_state_change(sk);
 		break;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNS_PEP_DISCONNECT_RESP:
-		sk->sk_state =3D TCP_CLOSE;
-		break;
-#endif
-
 	case PNS_PEP_ENABLE_REQ:
 		/* Wait for PNS_PIPE_(ENABLED|REDIRECTED)_IND */
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNS_PEP_ENABLE_RESP:
-		pipe_handler_send_ind(sk, PNS_PIPE_ENABLED_IND);
-
-		if (!pn_flow_safe(pn->tx_fc)) {
-			atomic_set(&pn->tx_credits, 1);
-			sk->sk_write_space(sk);
-		}
-		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
-			break; /* Nothing to do */
-		sk->sk_state =3D TCP_ESTABLISHED;
-		pipe_grant_credits(sk, GFP_ATOMIC);
-		break;
-#endif
-
 	case PNS_PEP_RESET_REQ:
 		switch (hdr->state_after_reset) {
 		case PN_PIPE_DISABLE:
@@ -420,15 +394,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNS_PEP_DISABLE_RESP:
-		atomic_set(&pn->tx_credits, 0);
-		pipe_handler_send_ind(sk, PNS_PIPE_DISABLED_IND);
-		sk->sk_state =3D TCP_SYN_RECV;
-		pn->rx_credits =3D 0;
-		break;
-#endif
-
 	case PNS_PEP_CTRL_REQ:
 		if (skb_queue_len(&pn->ctrlreq_queue) >=3D PNPIPE_CTRLREQ_MAX) {
 			atomic_inc(&sk->sk_drops);
@@ -521,7 +486,6 @@ static void pipe_destruct(struct sock *sk)
 	skb_queue_purge(&pn->ctrlreq_queue);
 }
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
 static u8 pipe_negotiate_fc(const u8 *fcs, unsigned n)
 {
 	unsigned i;
@@ -546,6 +510,8 @@ static int pep_connresp_rcv(struct sock *sk, struct=
 sk_buff *skb)
 		return -EINVAL;
=20
 	hdr =3D pnp_hdr(skb);
+	if (hdr->error_code !=3D PN_PIPE_NO_ERROR)
+		return -ECONNREFUSED;
=20
 	/* Parse sub-blocks */
 	n_sb =3D hdr->data[4];
@@ -573,14 +539,74 @@ static int pep_connresp_rcv(struct sock *sk, stru=
ct sk_buff *skb)
 		n_sb--;
 	}
=20
-	sk->sk_state =3D TCP_SYN_RECV;
-	sk->sk_backlog_rcv =3D pipe_do_rcv;
-	pn->rx_credits =3D 0;
-	sk->sk_state_change(sk);
-
 	return pipe_handler_send_created_ind(sk);
 }
-#endif
+
+/* Queue an skb to an actively connected sock.
+ * Socket lock must be held. */
+static int pipe_handler_do_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	int err =3D NET_RX_SUCCESS;
+
+	switch (hdr->message_id) {
+	case PNS_PIPE_ALIGNED_DATA:
+		__skb_pull(skb, 1);
+		/* fall through */
+	case PNS_PIPE_DATA:
+		__skb_pull(skb, 3); /* Pipe data header */
+		if (!pn_flow_safe(pn->rx_fc)) {
+			err =3D sock_queue_rcv_skb(sk, skb);
+			if (!err)
+				return NET_RX_SUCCESS;
+			err =3D NET_RX_DROP;
+			break;
+		}
+
+		if (pn->rx_credits =3D=3D 0) {
+			atomic_inc(&sk->sk_drops);
+			err =3D NET_RX_DROP;
+			break;
+		}
+		pn->rx_credits--;
+		skb->dev =3D NULL;
+		skb_set_owner_r(skb, sk);
+		err =3D skb->len;
+		skb_queue_tail(&sk->sk_receive_queue, skb);
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_data_ready(sk, err);
+		return NET_RX_SUCCESS;
+
+	case PNS_PEP_CONNECT_RESP:
+		if (sk->sk_state !=3D TCP_SYN_SENT)
+			break;
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_state_change(sk);
+		if (pep_connresp_rcv(sk, skb)) {
+			sk->sk_state =3D TCP_CLOSE_WAIT;
+			break;
+		}
+
+		sk->sk_state =3D TCP_ESTABLISHED;
+		if (!pn_flow_safe(pn->tx_fc)) {
+			atomic_set(&pn->tx_credits, 1);
+			sk->sk_write_space(sk);
+		}
+		pipe_grant_credits(sk, GFP_ATOMIC);
+		break;
+
+	case PNS_PEP_DISCONNECT_RESP:
+		/* sock should already be dead, nothing to do */
+		break;
+
+	case PNS_PEP_STATUS_IND:
+		pipe_rcv_status(sk, skb);
+		break;
+	}
+	kfree_skb(skb);
+	return err;
+}
=20
 /* Listening sock must be locked */
 static struct sock *pep_find_pipe(const struct hlist_head *hlist,
@@ -649,12 +675,6 @@ static int pep_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 			sk->sk_data_ready(sk, 0);
 		return NET_RX_SUCCESS;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNS_PEP_CONNECT_RESP:
-		pep_connresp_rcv(sk, skb);
-		break;
-#endif
-
 	case PNS_PEP_DISCONNECT_REQ:
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
@@ -667,15 +687,19 @@ static int pep_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 	case PNS_PEP_ENABLE_REQ:
 	case PNS_PEP_DISABLE_REQ:
 		/* invalid handle is not even allowed here! */
-	default:
 		break;
+
+	default:
+		if ((1 << sk->sk_state)
+				& ~(TCPF_CLOSE|TCPF_LISTEN|TCPF_CLOSE_WAIT))
+			/* actively connected socket */
+			return pipe_handler_do_rcv(sk, skb);
 	}
 drop:
 	kfree_skb(skb);
 	return NET_RX_SUCCESS;
 }
=20
-#ifndef CONFIG_PHONET_PIPECTRLR
 static int pipe_do_remove(struct sock *sk)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
@@ -693,7 +717,6 @@ static int pipe_do_remove(struct sock *sk)
 	ph->data[0] =3D PAD;
 	return pn_skb_send(sk, skb, NULL);
 }
-#endif
=20
 /* associated socket ceases to exist */
 static void pep_sock_close(struct sock *sk, long timeout)
@@ -706,13 +729,12 @@ static void pep_sock_close(struct sock *sk, long =
timeout)
=20
 	lock_sock(sk);
 	if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED)) {
-#ifndef CONFIG_PHONET_PIPECTRLR
-		/* Forcefully remove dangling Phonet pipe */
-		pipe_do_remove(sk);
-#else
-		/* send pep disconnect request */
-		pipe_handler_request(sk, PNS_PEP_DISCONNECT_REQ, PAD, NULL, 0);
-#endif
+		if (sk->sk_backlog_rcv =3D=3D pipe_do_rcv)
+			/* Forcefully remove dangling Phonet pipe */
+			pipe_do_remove(sk);
+		else
+			pipe_handler_request(sk, PNS_PEP_DISCONNECT_REQ, PAD,
+						NULL, 0);
 	}
 	sk->sk_state =3D TCP_CLOSE;
=20
@@ -844,20 +866,22 @@ drop:
 	return newsk;
 }
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
 static int pep_sock_connect(struct sock *sk, struct sockaddr *addr, in=
t len)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
-	const struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
+	int err;
 	u8 data[4] =3D { 0 /* sub-blocks */, PAD, PAD, PAD };
=20
-	pn->pn_sk.dobject =3D pn_sockaddr_get_object(spn);
-	pn->pn_sk.resource =3D pn_sockaddr_get_resource(spn);
 	pn->pipe_handle =3D 1; /* anything but INVALID_HANDLE */
-	return pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
-					PN_PIPE_DISABLE, data, 4);
+	err =3D pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
+					PN_PIPE_ENABLE, data, 4);
+	if (err) {
+		pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
+		return err;
+	}
+	sk->sk_state =3D TCP_SYN_SENT;
+	return 0;
 }
-#endif
=20
 static int pep_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
@@ -890,8 +914,16 @@ static int pep_init(struct sock *sk)
=20
 	sk->sk_destruct =3D pipe_destruct;
 	INIT_HLIST_HEAD(&pn->hlist);
+	pn->listener =3D NULL;
 	skb_queue_head_init(&pn->ctrlreq_queue);
+	atomic_set(&pn->tx_credits, 0);
+	pn->ifindex =3D 0;
+	pn->peer_type =3D 0;
 	pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
+	pn->rx_credits =3D 0;
+	pn->rx_fc =3D pn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
+	pn->init_enable =3D 1;
+	pn->aligned =3D 0;
 	return 0;
 }
=20
@@ -1219,9 +1251,9 @@ static void pep_sock_unhash(struct sock *sk)
=20
 	lock_sock(sk);
=20
-#ifndef CONFIG_PHONET_PIPECTRLR
-	if ((1 << sk->sk_state) & ~(TCPF_CLOSE|TCPF_LISTEN)) {
+	if (pn->listener !=3D NULL) {
 		skparent =3D pn->listener;
+		pn->listener =3D NULL;
 		release_sock(sk);
=20
 		pn =3D pep_sk(skparent);
@@ -1229,7 +1261,7 @@ static void pep_sock_unhash(struct sock *sk)
 		sk_del_node_init(sk);
 		sk =3D skparent;
 	}
-#endif
+
 	/* Unhash a listening sock only when it is closed
 	 * and all of its active connected pipes are closed. */
 	if (hlist_empty(&pn->hlist))
@@ -1243,9 +1275,7 @@ static void pep_sock_unhash(struct sock *sk)
 static struct proto pep_proto =3D {
 	.close		=3D pep_sock_close,
 	.accept		=3D pep_sock_accept,
-#ifdef CONFIG_PHONET_PIPECTRLR
 	.connect	=3D pep_sock_connect,
-#endif
 	.ioctl		=3D pep_ioctl,
 	.init		=3D pep_init,
 	.setsockopt	=3D pep_setsockopt,
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 1eccfc3..b1adafa 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -225,15 +225,18 @@ static int pn_socket_autobind(struct socket *sock=
)
 	return 0; /* socket was already bound */
 }
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
 static int pn_socket_connect(struct socket *sock, struct sockaddr *add=
r,
 		int len, int flags)
 {
 	struct sock *sk =3D sock->sk;
+	struct pn_sock *pn =3D pn_sk(sk);
 	struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
-	long timeo;
+	struct task_struct *tsk =3D current;
+	long timeo =3D sock_rcvtimeo(sk, flags & O_NONBLOCK);
 	int err;
=20
+	if (pn_socket_autobind(sock))
+		return -ENOBUFS;
 	if (len < sizeof(struct sockaddr_pn))
 		return -EINVAL;
 	if (spn->spn_family !=3D AF_PHONET)
@@ -243,82 +246,61 @@ static int pn_socket_connect(struct socket *sock,=
 struct sockaddr *addr,
=20
 	switch (sock->state) {
 	case SS_UNCONNECTED:
-		sk->sk_state =3D TCP_CLOSE;
-		break;
-	case SS_CONNECTING:
-		switch (sk->sk_state) {
-		case TCP_SYN_RECV:
-			sock->state =3D SS_CONNECTED;
-			err =3D -EISCONN;
-			goto out;
-		case TCP_CLOSE:
-			err =3D -EALREADY;
-			if (flags & O_NONBLOCK)
-				goto out;
-			goto wait_connect;
-		}
-		break;
-	case SS_CONNECTED:
-		switch (sk->sk_state) {
-		case TCP_SYN_RECV:
+		if (sk->sk_state !=3D TCP_CLOSE) {
 			err =3D -EISCONN;
 			goto out;
-		case TCP_CLOSE:
-			sock->state =3D SS_UNCONNECTED;
-			break;
 		}
 		break;
-	case SS_DISCONNECTING:
-	case SS_FREE:
-		break;
+	case SS_CONNECTING:
+		err =3D -EALREADY;
+		goto out;
+	default:
+		err =3D -EISCONN;
+		goto out;
 	}
-	sk->sk_state =3D TCP_CLOSE;
-	sk_stream_kill_queues(sk);
=20
+	pn->dobject =3D pn_sockaddr_get_object(spn);
+	pn->resource =3D pn_sockaddr_get_resource(spn);
 	sock->state =3D SS_CONNECTING;
+
 	err =3D sk->sk_prot->connect(sk, addr, len);
-	if (err < 0) {
+	if (err) {
 		sock->state =3D SS_UNCONNECTED;
-		sk->sk_state =3D TCP_CLOSE;
+		pn->dobject =3D 0;
 		goto out;
 	}
=20
-	err =3D -EINPROGRESS;
-wait_connect:
-	if (sk->sk_state !=3D TCP_SYN_RECV && (flags & O_NONBLOCK))
-		goto out;
-
-	timeo =3D sock_sndtimeo(sk, flags & O_NONBLOCK);
-	release_sock(sk);
+	while (sk->sk_state =3D=3D TCP_SYN_SENT) {
+		DEFINE_WAIT(wait);
=20
-	err =3D -ERESTARTSYS;
-	timeo =3D wait_event_interruptible_timeout(*sk_sleep(sk),
-			sk->sk_state !=3D TCP_CLOSE,
-			timeo);
-
-	lock_sock(sk);
-	if (timeo < 0)
-		goto out; /* -ERESTARTSYS */
-
-	err =3D -ETIMEDOUT;
-	if (timeo =3D=3D 0 && sk->sk_state !=3D TCP_SYN_RECV)
-		goto out;
+		if (!timeo) {
+			err =3D -EINPROGRESS;
+			goto out;
+		}
+		if (signal_pending(tsk)) {
+			err =3D sock_intr_errno(timeo);
+			goto out;
+		}
=20
-	if (sk->sk_state !=3D TCP_SYN_RECV) {
-		sock->state =3D SS_UNCONNECTED;
-		err =3D sock_error(sk);
-		if (!err)
-			err =3D -ECONNREFUSED;
-		goto out;
+		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
+						TASK_INTERRUPTIBLE);
+		release_sock(sk);
+		timeo =3D schedule_timeout(timeo);
+		lock_sock(sk);
+		finish_wait(sk_sleep(sk), &wait);
 	}
-	sock->state =3D SS_CONNECTED;
-	err =3D 0;
=20
+	if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED))
+		err =3D 0;
+	else if (sk->sk_state =3D=3D TCP_CLOSE_WAIT)
+		err =3D -ECONNRESET;
+	else
+		err =3D -ECONNREFUSED;
+	sock->state =3D err ? SS_UNCONNECTED : SS_CONNECTED;
 out:
 	release_sock(sk);
 	return err;
 }
-#endif
=20
 static int pn_socket_accept(struct socket *sock, struct socket *newsoc=
k,
 				int flags)
@@ -486,11 +468,7 @@ const struct proto_ops phonet_stream_ops =3D {
 	.owner		=3D THIS_MODULE,
 	.release	=3D pn_socket_release,
 	.bind		=3D pn_socket_bind,
-#ifdef CONFIG_PHONET_PIPECTRLR
 	.connect	=3D pn_socket_connect,
-#else
-	.connect	=3D sock_no_connect,
-#endif
 	.socketpair	=3D sock_no_socketpair,
 	.accept		=3D pn_socket_accept,
 	.getname	=3D pn_socket_getname,
--=20
1.7.1

