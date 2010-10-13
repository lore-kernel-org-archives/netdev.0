From: Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Subject: [PATCH V2] Phonet: 'connect' socket implementation for Pipe controller
Date: Wed, 13 Oct 2010 11:44:43 +0530
Message-ID: <1286950483-18804-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linus.walleij@stericsson.com>, <gulshan.karmani@stericsson.com>,
	<sudeep.divakaran@stericssonc.com>,
	Kumar Sanghvi <kumar.sanghvi@stericsson.com>
To: <remi.denis-courmont@nokia.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:35952 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752657Ab0JMGP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 02:15:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Based on suggestion by R=C3=A9mi Denis-Courmont to implement 'connect'
for Pipe controller logic,  this patch implements 'connect' socket
call for the Pipe controller logic.
The patch does following:-
- Removes setsockopts for PNPIPE_CREATE and PNPIPE_DESTROY
- Adds setsockopt for setting the Pipe handle value
- Implements connect socket call
- Updates the Pipe controller logic

User-space should now follow below sequence with Pipe controller:-
-socket
-bind
-setsockopt for PNPIPE_PIPE_HANDLE
-connect
-setsockopt for PNPIPE_ENCAP_IP
-setsockopt for PNPIPE_ENABLE

GPRS/3G data has been tested working fine with this.

Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
---
Changes:

 v2: Fixes for review comments by R=C3=A9mi Denis-Courmontt.
     Kept pn_socket_connect under #ifdef to remove compiler warning if =
Pipe
     controller is not used.

 include/linux/phonet.h   |    3 +-
 include/net/phonet/pep.h |    4 +-
 net/phonet/pep.c         |  300 +++++++++++++++++---------------------=
-------
 net/phonet/socket.c      |   99 +++++++++++++++
 4 files changed, 215 insertions(+), 191 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index e27cbf9..26c8df7 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -36,10 +36,9 @@
 /* Socket options for SOL_PNPIPE level */
 #define PNPIPE_ENCAP		1
 #define PNPIPE_IFINDEX		2
-#define PNPIPE_CREATE           3
+#define PNPIPE_PIPE_HANDLE	3
 #define PNPIPE_ENABLE           4
 /* unused slot */
-#define PNPIPE_DESTROY          6
=20
 #define PNADDR_ANY		0
 #define PNADDR_BROADCAST	0xFC
diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index def6cfa..b60b28c 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -46,8 +46,8 @@ struct pep_sock {
 	u8			init_enable;	/* auto-enable at creation */
 	u8			aligned;
 #ifdef CONFIG_PHONET_PIPECTRLR
-	u16                     remote_pep;
-	u8                      pipe_state;
+	u8			pipe_state;
+	struct sockaddr_pn	remote_pep;
 #endif
 };
=20
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index f818f76..9c903f9 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -88,15 +88,6 @@ static int pep_reply(struct sock *sk, struct sk_buff=
 *oskb,
 	const struct pnpipehdr *oph =3D pnp_hdr(oskb);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	const struct phonethdr *hdr =3D pn_hdr(oskb);
-	struct sockaddr_pn spn =3D {
-		.spn_family =3D AF_PHONET,
-		.spn_resource =3D 0xD9,
-		.spn_dev =3D hdr->pn_sdev,
-		.spn_obj =3D hdr->pn_sobj,
-	};
-#endif
=20
 	skb =3D alloc_skb(MAX_PNPIPE_HEADER + len, priority);
 	if (!skb)
@@ -114,11 +105,7 @@ static int pep_reply(struct sock *sk, struct sk_bu=
ff *oskb,
 	ph->pipe_handle =3D oph->pipe_handle;
 	ph->error_code =3D code;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	return pn_skb_send(sk, skb, &spn);
-#else
 	return pn_skb_send(sk, skb, &pipe_srv);
-#endif
 }
=20
 #define PAD 0x00
@@ -188,18 +175,13 @@ static int pipe_get_flow_info(struct sock *sk, st=
ruct sk_buff *skb,
 	return 0;
 }
=20
-static int pipe_handler_send_req(struct sock *sk, u16 dobj, u8 utid,
-		u8 msg_id, u8 p_handle, gfp_t priority)
+static int pipe_handler_send_req(struct sock *sk, u8 utid,
+		u8 msg_id, gfp_t priority)
 {
 	int len;
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
-	struct sockaddr_pn spn =3D {
-		.spn_family =3D AF_PHONET,
-		.spn_resource =3D 0xD9,
-		.spn_dev =3D pn_dev(dobj),
-		.spn_obj =3D pn_obj(dobj),
-	};
+	struct pep_sock *pn =3D pep_sk(sk);
=20
 	static const u8 data[4] =3D {
 		PAD, PAD, PAD, PAD,
@@ -235,30 +217,25 @@ static int pipe_handler_send_req(struct sock *sk,=
 u16 dobj, u8 utid,
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D utid;
 	ph->message_id =3D msg_id;
-	ph->pipe_handle =3D p_handle;
+	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D PN_PIPE_NO_ERROR;
=20
-	return pn_skb_send(sk, skb, &spn);
+	return pn_skb_send(sk, skb, &pn->remote_pep);
 }
=20
-static int pipe_handler_send_created_ind(struct sock *sk, u16 dobj,
-		u8 utid, u8 p_handle, u8 msg_id, u8 tx_fc, u8 rx_fc)
+static int pipe_handler_send_created_ind(struct sock *sk,
+		u8 utid, u8 msg_id)
 {
 	int err_code;
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
-	struct sockaddr_pn spn =3D {
-		.spn_family =3D AF_PHONET,
-		.spn_resource =3D 0xD9,
-		.spn_dev =3D pn_dev(dobj),
-		.spn_obj =3D pn_obj(dobj),
-	};
=20
+	struct pep_sock *pn =3D pep_sk(sk);
 	static u8 data[4] =3D {
 		0x03, 0x04,
 	};
-	data[2] =3D tx_fc;
-	data[3] =3D rx_fc;
+	data[2] =3D pn->tx_fc;
+	data[3] =3D pn->rx_fc;
=20
 	/*
 	 * actually, below is number of sub-blocks and not error code.
@@ -282,24 +259,18 @@ static int pipe_handler_send_created_ind(struct s=
ock *sk, u16 dobj,
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D utid;
 	ph->message_id =3D msg_id;
-	ph->pipe_handle =3D p_handle;
+	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D err_code;
=20
-	return pn_skb_send(sk, skb, &spn);
+	return pn_skb_send(sk, skb, &pn->remote_pep);
 }
=20
-static int pipe_handler_send_ind(struct sock *sk, u16 dobj, u8 utid,
-		u8 p_handle, u8 msg_id)
+static int pipe_handler_send_ind(struct sock *sk, u8 utid, u8 msg_id)
 {
 	int err_code;
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
-	struct sockaddr_pn spn =3D {
-		.spn_family =3D AF_PHONET,
-		.spn_resource =3D 0xD9,
-		.spn_dev =3D pn_dev(dobj),
-		.spn_obj =3D pn_obj(dobj),
-	};
+	struct pep_sock *pn =3D pep_sk(sk);
=20
 	/*
 	 * actually, below is a filler.
@@ -321,10 +292,10 @@ static int pipe_handler_send_ind(struct sock *sk,=
 u16 dobj, u8 utid,
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D utid;
 	ph->message_id =3D msg_id;
-	ph->pipe_handle =3D p_handle;
+	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D err_code;
=20
-	return pn_skb_send(sk, skb, &spn);
+	return pn_skb_send(sk, skb, &pn->remote_pep);
 }
=20
 static int pipe_handler_enable_pipe(struct sock *sk, int enable)
@@ -339,34 +310,7 @@ static int pipe_handler_enable_pipe(struct sock *s=
k, int enable)
 		utid =3D PNS_PIPE_DISABLE_UTID;
 		req =3D PNS_PEP_DISABLE_REQ;
 	}
-	return pipe_handler_send_req(sk, pn->pn_sk.sobject, utid, req,
-			pn->pipe_handle, GFP_ATOMIC);
-}
-
-static int pipe_handler_create_pipe(struct sock *sk, int pipe_handle, =
int cmd)
-{
-	int ret;
-	struct pep_sock *pn =3D pep_sk(sk);
-
-	switch (cmd) {
-	case PNPIPE_CREATE:
-		ret =3D pipe_handler_send_req(sk, pn->pn_sk.sobject,
-				PNS_PEP_CONNECT_UTID, PNS_PEP_CONNECT_REQ,
-				pipe_handle, GFP_ATOMIC);
-		break;
-
-	case PNPIPE_DESTROY:
-		ret =3D pipe_handler_send_req(sk, pn->remote_pep,
-				PNS_PEP_DISCONNECT_UTID,
-				PNS_PEP_DISCONNECT_REQ,
-				pn->pipe_handle, GFP_ATOMIC);
-		break;
-
-	default:
-		ret =3D -EINVAL;
-	}
-
-	return ret;
+	return pipe_handler_send_req(sk, utid, req, GFP_ATOMIC);
 }
 #endif
=20
@@ -434,14 +378,6 @@ static int pipe_snd_status(struct sock *sk, u8 typ=
e, u8 status, gfp_t priority)
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	struct sockaddr_pn spn =3D {
-		.spn_family =3D AF_PHONET,
-		.spn_resource =3D 0xD9,
-		.spn_dev =3D pn_dev(pn->remote_pep),
-		.spn_obj =3D pn_obj(pn->remote_pep),
-	};
-#endif
=20
 	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, priority);
 	if (!skb)
@@ -462,7 +398,7 @@ static int pipe_snd_status(struct sock *sk, u8 type=
, u8 status, gfp_t priority)
 	ph->data[4] =3D status;
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
-	return pn_skb_send(sk, skb, &spn);
+	return pn_skb_send(sk, skb, &pn->remote_pep);
 #else
 	return pn_skb_send(sk, skb, &pipe_srv);
 #endif
@@ -582,12 +518,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 	struct pnpipehdr *hdr =3D pnp_hdr(skb);
 	struct sk_buff_head *queue;
 	int err =3D 0;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	struct phonethdr *ph =3D pn_hdr(skb);
-	static u8 host_pref_rx_fc[3], host_req_tx_fc[3];
-	u8 remote_pref_rx_fc[3], remote_req_tx_fc[3];
-	u8 negotiated_rx_fc, negotiated_tx_fc;
-#endif
=20
 	BUG_ON(sk->sk_state =3D=3D TCP_CLOSE_WAIT);
=20
@@ -596,40 +526,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
 		break;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNS_PEP_CONNECT_RESP:
-		if ((ph->pn_sdev =3D=3D pn_dev(pn->remote_pep)) &&
-				(ph->pn_sobj =3D=3D pn_obj(pn->remote_pep))) {
-			pipe_get_flow_info(sk, skb, remote_pref_rx_fc,
-					remote_req_tx_fc);
-
-			 negotiated_tx_fc =3D pipe_negotiate_fc(remote_req_tx_fc,
-					 host_pref_rx_fc,
-					 sizeof(host_pref_rx_fc));
-			 negotiated_rx_fc =3D pipe_negotiate_fc(host_req_tx_fc,
-					 remote_pref_rx_fc,
-					 sizeof(host_pref_rx_fc));
-
-			pn->pipe_state =3D PIPE_DISABLED;
-			pipe_handler_send_created_ind(sk, pn->remote_pep,
-					PNS_PIPE_CREATED_IND_UTID,
-					pn->pipe_handle, PNS_PIPE_CREATED_IND,
-					negotiated_tx_fc, negotiated_rx_fc);
-			pipe_handler_send_created_ind(sk, pn->pn_sk.sobject,
-					PNS_PIPE_CREATED_IND_UTID,
-					pn->pipe_handle, PNS_PIPE_CREATED_IND,
-					negotiated_tx_fc, negotiated_rx_fc);
-		} else {
-			pipe_handler_send_req(sk, pn->remote_pep,
-					PNS_PEP_CONNECT_UTID,
-					PNS_PEP_CONNECT_REQ, pn->pipe_handle,
-					GFP_ATOMIC);
-			pipe_get_flow_info(sk, skb, host_pref_rx_fc,
-					host_req_tx_fc);
-		}
-		break;
-#endif
-
 	case PNS_PEP_DISCONNECT_REQ:
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		sk->sk_state =3D TCP_CLOSE_WAIT;
@@ -640,10 +536,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_DISCONNECT_RESP:
 		pn->pipe_state =3D PIPE_IDLE;
-		pipe_handler_send_req(sk, pn->pn_sk.sobject,
-				PNS_PEP_DISCONNECT_UTID,
-				PNS_PEP_DISCONNECT_REQ, pn->pipe_handle,
-				GFP_KERNEL);
+		sk->sk_state =3D TCP_CLOSE;
 		break;
 #endif
=20
@@ -654,21 +547,18 @@ static int pipe_do_rcv(struct sock *sk, struct sk=
_buff *skb)
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_ENABLE_RESP:
-		if ((ph->pn_sdev =3D=3D pn_dev(pn->remote_pep)) &&
-				(ph->pn_sobj =3D=3D pn_obj(pn->remote_pep))) {
-			pn->pipe_state =3D PIPE_ENABLED;
-			pipe_handler_send_ind(sk, pn->remote_pep,
-					PNS_PIPE_ENABLED_IND_UTID,
-					pn->pipe_handle, PNS_PIPE_ENABLED_IND);
-			pipe_handler_send_ind(sk, pn->pn_sk.sobject,
-					PNS_PIPE_ENABLED_IND_UTID,
-					pn->pipe_handle, PNS_PIPE_ENABLED_IND);
-		} else
-			pipe_handler_send_req(sk, pn->remote_pep,
-					PNS_PIPE_ENABLE_UTID,
-					PNS_PEP_ENABLE_REQ, pn->pipe_handle,
-					GFP_KERNEL);
+		pn->pipe_state =3D PIPE_ENABLED;
+		pipe_handler_send_ind(sk, PNS_PIPE_ENABLED_IND_UTID,
+				PNS_PIPE_ENABLED_IND);
=20
+		if (!pn_flow_safe(pn->tx_fc)) {
+			atomic_set(&pn->tx_credits, 1);
+			sk->sk_write_space(sk);
+		}
+		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
+			break; /* Nothing to do */
+		sk->sk_state =3D TCP_ESTABLISHED;
+		pipe_grant_credits(sk);
 		break;
 #endif
=20
@@ -692,22 +582,12 @@ static int pipe_do_rcv(struct sock *sk, struct sk=
_buff *skb)
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_DISABLE_RESP:
-		if ((ph->pn_sdev =3D=3D pn_dev(pn->remote_pep)) &&
-				(ph->pn_sobj =3D=3D pn_obj(pn->remote_pep))) {
-			pn->pipe_state =3D PIPE_DISABLED;
-			pipe_handler_send_ind(sk, pn->remote_pep,
-					PNS_PIPE_DISABLED_IND_UTID,
-					pn->pipe_handle,
-					PNS_PIPE_DISABLED_IND);
-			pipe_handler_send_ind(sk, pn->pn_sk.sobject,
-					PNS_PIPE_DISABLED_IND_UTID,
-					pn->pipe_handle,
-					PNS_PIPE_DISABLED_IND);
-		} else
-			pipe_handler_send_req(sk, pn->remote_pep,
-					PNS_PIPE_DISABLE_UTID,
-					PNS_PEP_DISABLE_REQ, pn->pipe_handle,
-					GFP_KERNEL);
+		pn->pipe_state =3D PIPE_DISABLED;
+		atomic_set(&pn->tx_credits, 0);
+		pipe_handler_send_ind(sk, PNS_PIPE_DISABLED_IND_UTID,
+				PNS_PIPE_DISABLED_IND);
+		sk->sk_state =3D TCP_SYN_RECV;
+		pn->rx_credits =3D 0;
 		break;
 #endif
=20
@@ -802,6 +682,42 @@ static void pipe_destruct(struct sock *sk)
 	skb_queue_purge(&pn->ctrlreq_queue);
 }
=20
+#ifdef CONFIG_PHONET_PIPECTRLR
+static int pep_connresp_rcv(struct sock *sk, struct sk_buff *skb)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	u8 host_pref_rx_fc[3] =3D {3, 2, 1}, host_req_tx_fc[3] =3D {3, 2, 1};
+	u8 remote_pref_rx_fc[3], remote_req_tx_fc[3];
+	u8 negotiated_rx_fc, negotiated_tx_fc;
+	int ret;
+
+	pipe_get_flow_info(sk, skb, remote_pref_rx_fc,
+			remote_req_tx_fc);
+	negotiated_tx_fc =3D pipe_negotiate_fc(remote_req_tx_fc,
+			host_pref_rx_fc,
+			sizeof(host_pref_rx_fc));
+	negotiated_rx_fc =3D pipe_negotiate_fc(host_req_tx_fc,
+			remote_pref_rx_fc,
+			sizeof(host_pref_rx_fc));
+
+	pn->pipe_state =3D PIPE_DISABLED;
+	sk->sk_state =3D TCP_SYN_RECV;
+	sk->sk_backlog_rcv =3D pipe_do_rcv;
+	sk->sk_destruct =3D pipe_destruct;
+	pn->rx_credits =3D 0;
+	pn->rx_fc =3D negotiated_rx_fc;
+	pn->tx_fc =3D negotiated_tx_fc;
+	sk->sk_state_change(sk);
+
+	ret =3D pipe_handler_send_created_ind(sk,
+			PNS_PIPE_CREATED_IND_UTID,
+			PNS_PIPE_CREATED_IND
+			);
+
+	return ret;
+}
+#endif
+
 static int pep_connreq_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct sock *newsk;
@@ -884,9 +800,6 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 	newpn->rx_fc =3D newpn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
 	newpn->init_enable =3D enabled;
 	newpn->aligned =3D aligned;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	newpn->remote_pep =3D pn->remote_pep;
-#endif
=20
 	BUG_ON(!skb_queue_empty(&newsk->sk_receive_queue));
 	skb_queue_head(&newsk->sk_receive_queue, skb);
@@ -968,6 +881,12 @@ static int pep_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		err =3D pep_connreq_rcv(sk, skb);
 		break;
=20
+#ifdef CONFIG_PHONET_PIPECTRLR
+	case PNS_PEP_CONNECT_RESP:
+		err =3D pep_connresp_rcv(sk, skb);
+		break;
+#endif
+
 	case PNS_PEP_DISCONNECT_REQ:
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
@@ -1032,6 +951,18 @@ static void pep_sock_close(struct sock *sk, long =
timeout)
 		/* Forcefully remove dangling Phonet pipe */
 		pipe_do_remove(sk);
=20
+#ifdef CONFIG_PHONET_PIPECTRLR
+	if (pn->pipe_state !=3D PIPE_IDLE) {
+		/* send pep disconnect request */
+		pipe_handler_send_req(sk,
+				PNS_PEP_DISCONNECT_UTID, PNS_PEP_DISCONNECT_REQ,
+				GFP_KERNEL);
+
+		pn->pipe_state =3D PIPE_IDLE;
+		sk->sk_state =3D TCP_CLOSE;
+	}
+#endif
+
 	ifindex =3D pn->ifindex;
 	pn->ifindex =3D 0;
 	release_sock(sk);
@@ -1108,6 +1039,20 @@ out:
 	return newsk;
 }
=20
+#ifdef CONFIG_PHONET_PIPECTRLR
+static int pep_sock_connect(struct sock *sk, struct sockaddr *addr, in=
t len)
+{
+	struct pep_sock *pn =3D pep_sk(sk);
+	struct sockaddr_pn *spn =3D  (struct sockaddr_pn *)addr;
+
+	memcpy(&pn->remote_pep, spn, sizeof(struct sockaddr_pn));
+
+	return pipe_handler_send_req(sk,
+			PNS_PEP_CONNECT_UTID, PNS_PEP_CONNECT_REQ,
+			GFP_ATOMIC);
+}
+#endif
+
 static int pep_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
@@ -1149,10 +1094,6 @@ static int pep_setsockopt(struct sock *sk, int l=
evel, int optname,
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	int val =3D 0, err =3D 0;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	int remote_pep;
-	int pipe_handle;
-#endif
=20
 	if (level !=3D SOL_PNPIPE)
 		return -ENOPROTOOPT;
@@ -1164,28 +1105,15 @@ static int pep_setsockopt(struct sock *sk, int =
level, int optname,
 	lock_sock(sk);
 	switch (optname) {
 #ifdef CONFIG_PHONET_PIPECTRLR
-	case PNPIPE_CREATE:
+	case PNPIPE_PIPE_HANDLE:
 		if (val) {
 			if (pn->pipe_state > PIPE_IDLE) {
 				err =3D -EFAULT;
 				break;
 			}
-			remote_pep =3D val & 0xFFFF;
-			pipe_handle =3D  (val >> 16) & 0xFF;
-			pn->remote_pep =3D remote_pep;
-			err =3D pipe_handler_create_pipe(sk, pipe_handle,
-					PNPIPE_CREATE);
-			break;
-		}
-
-	case PNPIPE_DESTROY:
-		if (pn->pipe_state < PIPE_DISABLED) {
-			err =3D -EFAULT;
+			pn->pipe_handle =3D val;
 			break;
 		}
-
-		err =3D pipe_handler_create_pipe(sk, 0x0, PNPIPE_DESTROY);
-		break;
 #endif
=20
 	case PNPIPE_ENCAP:
@@ -1278,14 +1206,6 @@ static int pipe_skb_send(struct sock *sk, struct=
 sk_buff *skb)
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
 	int err;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	struct sockaddr_pn spn =3D {
-		.spn_family =3D AF_PHONET,
-		.spn_resource =3D 0xD9,
-		.spn_dev =3D pn_dev(pn->remote_pep),
-		.spn_obj =3D pn_obj(pn->remote_pep),
-	};
-#endif
=20
 	if (pn_flow_safe(pn->tx_fc) &&
 	    !atomic_add_unless(&pn->tx_credits, -1, 0)) {
@@ -1304,7 +1224,7 @@ static int pipe_skb_send(struct sock *sk, struct =
sk_buff *skb)
 		ph->message_id =3D PNS_PIPE_DATA;
 	ph->pipe_handle =3D pn->pipe_handle;
 #ifdef CONFIG_PHONET_PIPECTRLR
-	err =3D pn_skb_send(sk, skb, &spn);
+	err =3D pn_skb_send(sk, skb, &pn->remote_pep);
 #else
 	err =3D pn_skb_send(sk, skb, &pipe_srv);
 #endif
@@ -1504,6 +1424,8 @@ static void pep_sock_unhash(struct sock *sk)
 	struct sock *skparent =3D NULL;
=20
 	lock_sock(sk);
+
+#ifndef CONFIG_PHONET_PIPECTRLR
 	if ((1 << sk->sk_state) & ~(TCPF_CLOSE|TCPF_LISTEN)) {
 		skparent =3D pn->listener;
 		release_sock(sk);
@@ -1513,6 +1435,7 @@ static void pep_sock_unhash(struct sock *sk)
 		sk_del_node_init(sk);
 		sk =3D skparent;
 	}
+#endif
 	/* Unhash a listening sock only when it is closed
 	 * and all of its active connected pipes are closed. */
 	if (hlist_empty(&pn->hlist))
@@ -1526,6 +1449,9 @@ static void pep_sock_unhash(struct sock *sk)
 static struct proto pep_proto =3D {
 	.close		=3D pep_sock_close,
 	.accept		=3D pep_sock_accept,
+#ifdef CONFIG_PHONET_PIPECTRLR
+	.connect	=3D pep_sock_connect,
+#endif
 	.ioctl		=3D pep_ioctl,
 	.init		=3D pep_init,
 	.setsockopt	=3D pep_setsockopt,
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index aca8fba..25f746d 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -225,6 +225,101 @@ static int pn_socket_autobind(struct socket *sock=
)
 	return 0; /* socket was already bound */
 }
=20
+#ifdef CONFIG_PHONET_PIPECTRLR
+static int pn_socket_connect(struct socket *sock, struct sockaddr *add=
r,
+		int len, int flags)
+{
+	struct sock *sk =3D sock->sk;
+	struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
+	long timeo;
+	int err;
+
+	if (len < sizeof(struct sockaddr_pn))
+		return -EINVAL;
+	if (spn->spn_family !=3D AF_PHONET)
+		return -EAFNOSUPPORT;
+
+	lock_sock(sk);
+
+	switch (sock->state) {
+	case SS_UNCONNECTED:
+		sk->sk_state =3D TCP_CLOSE;
+		break;
+	case SS_CONNECTING:
+		switch (sk->sk_state) {
+		case TCP_SYN_RECV:
+			sock->state =3D SS_CONNECTED;
+			err =3D -EISCONN;
+			goto out;
+		case TCP_CLOSE:
+			err =3D -EALREADY;
+			if (flags & O_NONBLOCK)
+				goto out;
+			goto wait_connect;
+		}
+		break;
+	case SS_CONNECTED:
+		switch (sk->sk_state) {
+		case TCP_SYN_RECV:
+			err =3D -EISCONN;
+			goto out;
+		case TCP_CLOSE:
+			sock->state =3D SS_UNCONNECTED;
+			break;
+		}
+		break;
+	case SS_DISCONNECTING:
+	case SS_FREE:
+		break;
+	}
+	sk->sk_state =3D TCP_CLOSE;
+	sk_stream_kill_queues(sk);
+
+	sock->state =3D SS_CONNECTING;
+	err =3D sk->sk_prot->connect(sk, addr, len);
+	if (err < 0) {
+		sock->state =3D SS_UNCONNECTED;
+		sk->sk_state =3D TCP_CLOSE;
+		goto out;
+	}
+
+	err =3D -EINPROGRESS;
+wait_connect:
+	if (sk->sk_state !=3D TCP_SYN_RECV && (flags & O_NONBLOCK))
+		goto out;
+
+	timeo =3D sock_sndtimeo(sk, flags & O_NONBLOCK);
+	release_sock(sk);
+
+	err =3D -ERESTARTSYS;
+	timeo =3D wait_event_interruptible_timeout(*sk_sleep(sk),
+			sk->sk_state !=3D TCP_CLOSE,
+			timeo);
+
+	lock_sock(sk);
+	if (timeo < 0)
+		goto out; /* -ERESTARTSYS */
+
+	err =3D -ETIMEDOUT;
+	if (timeo =3D=3D 0 && sk->sk_state !=3D TCP_SYN_RECV)
+		goto out;
+
+	if (sk->sk_state !=3D TCP_SYN_RECV) {
+		sock->state =3D SS_UNCONNECTED;
+		err =3D sock_error(sk);
+		if (!err)
+			err =3D -ECONNREFUSED;
+		goto out;
+	}
+	sock->state =3D SS_CONNECTED;
+	err =3D 0;
+
+out:
+	release_sock(sk);
+	return err;
+}
+#endif
+
 static int pn_socket_accept(struct socket *sock, struct socket *newsoc=
k,
 				int flags)
 {
@@ -393,7 +488,11 @@ const struct proto_ops phonet_stream_ops =3D {
 	.owner		=3D THIS_MODULE,
 	.release	=3D pn_socket_release,
 	.bind		=3D pn_socket_bind,
+#ifdef CONFIG_PHONET_PIPECTRLR
+	.connect	=3D pn_socket_connect,
+#else
 	.connect	=3D sock_no_connect,
+#endif
 	.socketpair	=3D sock_no_socketpair,
 	.accept		=3D pn_socket_accept,
 	.getname	=3D pn_socket_getname,
--=20
1.7.2.dirty

