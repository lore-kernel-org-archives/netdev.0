From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 5/8] Phonet: allocate sock from accept syscall rather than soft IRQ
Date: Fri,  4 Mar 2011 12:00:28 +0200
Message-ID: <1299232831-3132-5-git-send-email-remi.denis-courmont@nokia.com>
References: <201103031322.37184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:47007 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759288Ab1CDJ7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 04:59:42 -0500
Received: from leon.remlab.com ([172.21.24.67])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p249xdab012056
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 11:59:40 +0200
In-Reply-To: <201103031322.37184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves most of the accept logic to process context, and simplifies
the code a bit at the same time.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    1 -
 net/phonet/pep.c         |  284 +++++++++++++++++++-------------------=
--------
 net/phonet/socket.c      |   10 +-
 3 files changed, 121 insertions(+), 174 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 38eed1b..b669fe6 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -28,7 +28,6 @@ struct pep_sock {
=20
 	/* XXX: union-ify listening vs connected stuff ? */
 	/* Listening socket stuff: */
-	struct hlist_head	ackq;
 	struct hlist_head	hlist;
=20
 	/* Connected socket stuff: */
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 610794a..c0fab4c 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -42,7 +42,7 @@
  * TCP_ESTABLISHED	connected pipe in enabled state
  *
  * pep_sock locking:
- *  - sk_state, ackq, hlist: sock lock needed
+ *  - sk_state, hlist: sock lock needed
  *  - listener: read only
  *  - pipe_handle: read only
  */
@@ -202,11 +202,12 @@ static int pep_accept_conn(struct sock *sk, struc=
t sk_buff *skb)
 				GFP_KERNEL);
 }
=20
-static int pep_reject_conn(struct sock *sk, struct sk_buff *skb, u8 co=
de)
+static int pep_reject_conn(struct sock *sk, struct sk_buff *skb, u8 co=
de,
+				gfp_t priority)
 {
 	static const u8 data[4] =3D { PAD, PAD, PAD, 0 /* sub-blocks */ };
 	WARN_ON(code =3D=3D PN_PIPE_NO_ERROR);
-	return pep_reply(sk, skb, code, data, sizeof(data), GFP_ATOMIC);
+	return pep_reply(sk, skb, code, data, sizeof(data), priority);
 }
=20
 /* Control requests are not sent by the pipe service and have a specif=
ic
@@ -365,7 +366,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
=20
 	switch (hdr->message_id) {
 	case PNS_PEP_CONNECT_REQ:
-		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE, GFP_ATOMIC);
 		break;
=20
 	case PNS_PEP_DISCONNECT_REQ:
@@ -574,7 +575,6 @@ static int pep_connresp_rcv(struct sock *sk, struct=
 sk_buff *skb)
=20
 	sk->sk_state =3D TCP_SYN_RECV;
 	sk->sk_backlog_rcv =3D pipe_do_rcv;
-	sk->sk_destruct =3D pipe_destruct;
 	pn->rx_credits =3D 0;
 	sk->sk_state_change(sk);
=20
@@ -582,96 +582,6 @@ static int pep_connresp_rcv(struct sock *sk, struc=
t sk_buff *skb)
 }
 #endif
=20
-static int pep_connreq_rcv(struct sock *sk, struct sk_buff *skb)
-{
-	struct sock *newsk;
-	struct pep_sock *newpn, *pn =3D pep_sk(sk);
-	struct pnpipehdr *hdr;
-	struct sockaddr_pn dst, src;
-	u16 peer_type;
-	u8 pipe_handle, enabled, n_sb;
-	u8 aligned =3D 0;
-
-	if (!pskb_pull(skb, sizeof(*hdr) + 4))
-		return -EINVAL;
-
-	hdr =3D pnp_hdr(skb);
-	pipe_handle =3D hdr->pipe_handle;
-	switch (hdr->state_after_connect) {
-	case PN_PIPE_DISABLE:
-		enabled =3D 0;
-		break;
-	case PN_PIPE_ENABLE:
-		enabled =3D 1;
-		break;
-	default:
-		pep_reject_conn(sk, skb, PN_PIPE_ERR_INVALID_PARAM);
-		return -EINVAL;
-	}
-	peer_type =3D hdr->other_pep_type << 8;
-
-	/* Parse sub-blocks (options) */
-	n_sb =3D hdr->data[4];
-	while (n_sb > 0) {
-		u8 type, buf[1], len =3D sizeof(buf);
-		const u8 *data =3D pep_get_sb(skb, &type, &len, buf);
-
-		if (data =3D=3D NULL)
-			return -EINVAL;
-		switch (type) {
-		case PN_PIPE_SB_CONNECT_REQ_PEP_SUB_TYPE:
-			if (len < 1)
-				return -EINVAL;
-			peer_type =3D (peer_type & 0xff00) | data[0];
-			break;
-		case PN_PIPE_SB_ALIGNED_DATA:
-			aligned =3D data[0] !=3D 0;
-			break;
-		}
-		n_sb--;
-	}
-
-	skb =3D skb_clone(skb, GFP_ATOMIC);
-	if (!skb)
-		return -ENOMEM;
-
-	/* Create a new to-be-accepted sock */
-	newsk =3D sk_alloc(sock_net(sk), PF_PHONET, GFP_ATOMIC, sk->sk_prot);
-	if (!newsk) {
-		kfree_skb(skb);
-		return -ENOMEM;
-	}
-	sock_init_data(NULL, newsk);
-	newsk->sk_state =3D TCP_SYN_RECV;
-	newsk->sk_backlog_rcv =3D pipe_do_rcv;
-	newsk->sk_protocol =3D sk->sk_protocol;
-	newsk->sk_destruct =3D pipe_destruct;
-
-	newpn =3D pep_sk(newsk);
-	pn_skb_get_dst_sockaddr(skb, &dst);
-	pn_skb_get_src_sockaddr(skb, &src);
-	newpn->pn_sk.sobject =3D pn_sockaddr_get_object(&dst);
-	newpn->pn_sk.dobject =3D pn_sockaddr_get_object(&src);
-	newpn->pn_sk.resource =3D pn_sockaddr_get_resource(&dst);
-	skb_queue_head_init(&newpn->ctrlreq_queue);
-	newpn->pipe_handle =3D pipe_handle;
-	atomic_set(&newpn->tx_credits, 0);
-	newpn->peer_type =3D peer_type;
-	newpn->rx_credits =3D 0;
-	newpn->rx_fc =3D newpn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
-	newpn->init_enable =3D enabled;
-	newpn->aligned =3D aligned;
-
-	BUG_ON(!skb_queue_empty(&newsk->sk_receive_queue));
-	skb_queue_head(&newsk->sk_receive_queue, skb);
-	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, 0);
-
-	sk_acceptq_added(sk);
-	sk_add_node(newsk, &pn->ackq);
-	return 0;
-}
-
 /* Listening sock must be locked */
 static struct sock *pep_find_pipe(const struct hlist_head *hlist,
 					const struct sockaddr_pn *dst,
@@ -726,22 +636,18 @@ static int pep_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 	if (sknode)
 		return sk_receive_skb(sknode, skb, 1);
=20
-	/* Look for a pipe handle pending accept */
-	sknode =3D pep_find_pipe(&pn->ackq, &dst, pipe_handle);
-	if (sknode) {
-		sock_put(sknode);
-		if (net_ratelimit())
-			printk(KERN_WARNING"Phonet unconnected PEP ignored");
-		goto drop;
-	}
-
 	switch (hdr->message_id) {
 	case PNS_PEP_CONNECT_REQ:
-		if (sk->sk_state =3D=3D TCP_LISTEN && !sk_acceptq_is_full(sk))
-			pep_connreq_rcv(sk, skb);
-		else
-			pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
-		break;
+		if (sk->sk_state !=3D TCP_LISTEN || sk_acceptq_is_full(sk)) {
+			pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE,
+					GFP_ATOMIC);
+			break;
+		}
+		skb_queue_head(&sk->sk_receive_queue, skb);
+		sk_acceptq_added(sk);
+		if (!sock_flag(sk, SOCK_DEAD))
+			sk->sk_data_ready(sk, 0);
+		return NET_RX_SUCCESS;
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_CONNECT_RESP:
@@ -799,24 +705,16 @@ static void pep_sock_close(struct sock *sk, long =
timeout)
 	sk_common_release(sk);
=20
 	lock_sock(sk);
-	if (sk->sk_state =3D=3D TCP_LISTEN) {
-		/* Destroy the listen queue */
-		struct sock *sknode;
-		struct hlist_node *p, *n;
-
-		sk_for_each_safe(sknode, p, n, &pn->ackq)
-			sk_del_node_init(sknode);
-		sk->sk_state =3D TCP_CLOSE;
-	} else if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED)) {
+	if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED)) {
 #ifndef CONFIG_PHONET_PIPECTRLR
 		/* Forcefully remove dangling Phonet pipe */
 		pipe_do_remove(sk);
 #else
 		/* send pep disconnect request */
 		pipe_handler_request(sk, PNS_PEP_DISCONNECT_REQ, PAD, NULL, 0);
-		sk->sk_state =3D TCP_CLOSE;
 #endif
 	}
+	sk->sk_state =3D TCP_CLOSE;
=20
 	ifindex =3D pn->ifindex;
 	pn->ifindex =3D 0;
@@ -827,69 +725,121 @@ static void pep_sock_close(struct sock *sk, long=
 timeout)
 	sock_put(sk);
 }
=20
-static int pep_wait_connreq(struct sock *sk, int noblock)
+static struct sock *pep_sock_accept(struct sock *sk, int flags, int *e=
rrp)
 {
-	struct task_struct *tsk =3D current;
-	struct pep_sock *pn =3D pep_sk(sk);
-	long timeo =3D sock_rcvtimeo(sk, noblock);
-
-	for (;;) {
-		DEFINE_WAIT(wait);
+	struct pep_sock *pn =3D pep_sk(sk), *newpn;
+	struct sock *newsk =3D NULL;
+	struct sk_buff *skb;
+	struct pnpipehdr *hdr;
+	struct sockaddr_pn dst, src;
+	int err;
+	u16 peer_type;
+	u8 pipe_handle, enabled, n_sb;
+	u8 aligned =3D 0;
=20
-		if (sk->sk_state !=3D TCP_LISTEN)
-			return -EINVAL;
-		if (!hlist_empty(&pn->ackq))
-			break;
-		if (!timeo)
-			return -EWOULDBLOCK;
-		if (signal_pending(tsk))
-			return sock_intr_errno(timeo);
+	skb =3D skb_recv_datagram(sk, 0, flags & O_NONBLOCK, errp);
+	if (!skb)
+		return NULL;
=20
-		prepare_to_wait_exclusive(sk_sleep(sk), &wait,
-						TASK_INTERRUPTIBLE);
-		release_sock(sk);
-		timeo =3D schedule_timeout(timeo);
-		lock_sock(sk);
-		finish_wait(sk_sleep(sk), &wait);
+	lock_sock(sk);
+	if (sk->sk_state !=3D TCP_LISTEN) {
+		err =3D -EINVAL;
+		goto drop;
 	}
+	sk_acceptq_removed(sk);
=20
-	return 0;
-}
+	err =3D -EPROTO;
+	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
+		goto drop;
=20
-static struct sock *pep_sock_accept(struct sock *sk, int flags, int *e=
rrp)
-{
-	struct pep_sock *pn =3D pep_sk(sk);
-	struct sock *newsk =3D NULL;
-	struct sk_buff *oskb;
-	int err;
+	hdr =3D pnp_hdr(skb);
+	pipe_handle =3D hdr->pipe_handle;
+	switch (hdr->state_after_connect) {
+	case PN_PIPE_DISABLE:
+		enabled =3D 0;
+		break;
+	case PN_PIPE_ENABLE:
+		enabled =3D 1;
+		break;
+	default:
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_INVALID_PARAM,
+				GFP_KERNEL);
+		goto drop;
+	}
+	peer_type =3D hdr->other_pep_type << 8;
=20
-	lock_sock(sk);
-	err =3D pep_wait_connreq(sk, flags & O_NONBLOCK);
-	if (err)
-		goto out;
+	/* Parse sub-blocks (options) */
+	n_sb =3D hdr->data[4];
+	while (n_sb > 0) {
+		u8 type, buf[1], len =3D sizeof(buf);
+		const u8 *data =3D pep_get_sb(skb, &type, &len, buf);
=20
-	newsk =3D __sk_head(&pn->ackq);
+		if (data =3D=3D NULL)
+			goto drop;
+		switch (type) {
+		case PN_PIPE_SB_CONNECT_REQ_PEP_SUB_TYPE:
+			if (len < 1)
+				goto drop;
+			peer_type =3D (peer_type & 0xff00) | data[0];
+			break;
+		case PN_PIPE_SB_ALIGNED_DATA:
+			aligned =3D data[0] !=3D 0;
+			break;
+		}
+		n_sb--;
+	}
=20
-	oskb =3D skb_dequeue(&newsk->sk_receive_queue);
-	err =3D pep_accept_conn(newsk, oskb);
-	if (err) {
-		skb_queue_head(&newsk->sk_receive_queue, oskb);
+	/* Check for duplicate pipe handle */
+	newsk =3D pep_find_pipe(&pn->hlist, &dst, pipe_handle);
+	if (unlikely(newsk)) {
+		__sock_put(newsk);
 		newsk =3D NULL;
-		goto out;
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE, GFP_KERNEL);
+		goto drop;
+	}
+
+	/* Create a new to-be-accepted sock */
+	newsk =3D sk_alloc(sock_net(sk), PF_PHONET, GFP_KERNEL, sk->sk_prot);
+	if (!newsk) {
+		pep_reject_conn(sk, skb, PN_PIPE_ERR_OVERLOAD, GFP_KERNEL);
+		err =3D -ENOBUFS;
+		goto drop;
 	}
-	kfree_skb(oskb);
=20
+	sock_init_data(NULL, newsk);
+	newsk->sk_state =3D TCP_SYN_RECV;
+	newsk->sk_backlog_rcv =3D pipe_do_rcv;
+	newsk->sk_protocol =3D sk->sk_protocol;
+	newsk->sk_destruct =3D pipe_destruct;
+
+	newpn =3D pep_sk(newsk);
+	pn_skb_get_dst_sockaddr(skb, &dst);
+	pn_skb_get_src_sockaddr(skb, &src);
+	newpn->pn_sk.sobject =3D pn_sockaddr_get_object(&dst);
+	newpn->pn_sk.dobject =3D pn_sockaddr_get_object(&src);
+	newpn->pn_sk.resource =3D pn_sockaddr_get_resource(&dst);
 	sock_hold(sk);
-	pep_sk(newsk)->listener =3D sk;
+	newpn->listener =3D sk;
+	skb_queue_head_init(&newpn->ctrlreq_queue);
+	newpn->pipe_handle =3D pipe_handle;
+	atomic_set(&newpn->tx_credits, 0);
+	newpn->ifindex =3D 0;
+	newpn->peer_type =3D peer_type;
+	newpn->rx_credits =3D 0;
+	newpn->rx_fc =3D newpn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
+	newpn->init_enable =3D enabled;
+	newpn->aligned =3D aligned;
=20
-	sock_hold(newsk);
-	sk_del_node_init(newsk);
-	sk_acceptq_removed(sk);
+	err =3D pep_accept_conn(newsk, skb);
+	if (err) {
+		sock_put(newsk);
+		newsk =3D NULL;
+		goto drop;
+	}
 	sk_add_node(newsk, &pn->hlist);
-	__sock_put(newsk);
-
-out:
+drop:
 	release_sock(sk);
+	kfree_skb(skb);
 	*errp =3D err;
 	return newsk;
 }
@@ -937,7 +887,7 @@ static int pep_init(struct sock *sk)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
=20
-	INIT_HLIST_HEAD(&pn->ackq);
+	sk->sk_destruct =3D pipe_destruct;
 	INIT_HLIST_HEAD(&pn->hlist);
 	skb_queue_head_init(&pn->ctrlreq_queue);
 	pn->pipe_handle =3D PN_PIPE_INVALID_HANDLE;
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 65a0333..1eccfc3 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -327,6 +327,9 @@ static int pn_socket_accept(struct socket *sock, st=
ruct socket *newsock,
 	struct sock *newsk;
 	int err;
=20
+	if (unlikely(sk->sk_state !=3D TCP_LISTEN))
+		return -EINVAL;
+
 	newsk =3D sk->sk_prot->accept(sk, flags, &err);
 	if (!newsk)
 		return err;
@@ -363,13 +366,8 @@ static unsigned int pn_socket_poll(struct file *fi=
le, struct socket *sock,
=20
 	poll_wait(file, sk_sleep(sk), wait);
=20
-	switch (sk->sk_state) {
-	case TCP_LISTEN:
-		return hlist_empty(&pn->ackq) ? 0 : POLLIN;
-	case TCP_CLOSE:
+	if (sk->sk_state =3D=3D TCP_CLOSE)
 		return POLLERR;
-	}
-
 	if (!skb_queue_empty(&sk->sk_receive_queue))
 		mask |=3D POLLIN | POLLRDNORM;
 	if (!skb_queue_empty(&pn->ctrlreq_queue))
--=20
1.7.1

