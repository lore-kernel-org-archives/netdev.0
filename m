From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 4/8] Phonet: factor common code to send control messages
Date: Wed,  9 Mar 2011 10:44:09 +0200
Message-ID: <1299660253-4446-4-git-send-email-remi.denis-courmont@nokia.com>
References: <201103091043.32391.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30328 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756895Ab1CIIoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 03:44:22 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p298iEY7019524
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 10:44:20 +0200
In-Reply-To: <201103091043.32391.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the addition of the pipe controller, there is now quite a bit
of repetitive code for small signaling messages. Lets factor it.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |  225 ++++++++++++++++++----------------------------=
--------
 1 files changed, 73 insertions(+), 152 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 40952c7..610794a 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -77,24 +77,34 @@ static unsigned char *pep_get_sb(struct sk_buff *sk=
b, u8 *ptype, u8 *plen,
 	return data;
 }
=20
-static int pep_reply(struct sock *sk, struct sk_buff *oskb,
-			u8 code, const void *data, int len, gfp_t priority)
+static struct sk_buff *pep_alloc_skb(struct sock *sk, const void *payl=
oad,
+					int len, gfp_t priority)
+{
+	struct sk_buff *skb =3D alloc_skb(MAX_PNPIPE_HEADER + len, priority);
+	if (!skb)
+		return NULL;
+	skb_set_owner_w(skb, sk);
+
+	skb_reserve(skb, MAX_PNPIPE_HEADER);
+	__skb_put(skb, len);
+	skb_copy_to_linear_data(skb, payload, len);
+	__skb_push(skb, sizeof(struct pnpipehdr));
+	skb_reset_transport_header(skb);
+	return skb;
+}
+
+static int pep_reply(struct sock *sk, struct sk_buff *oskb, u8 code,
+			const void *data, int len, gfp_t priority)
 {
 	const struct pnpipehdr *oph =3D pnp_hdr(oskb);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
 	struct sockaddr_pn peer;
=20
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER + len, priority);
+	skb =3D pep_alloc_skb(sk, data, len, priority);
 	if (!skb)
 		return -ENOMEM;
-	skb_set_owner_w(skb, sk);
=20
-	skb_reserve(skb, MAX_PNPIPE_HEADER);
-	__skb_put(skb, len);
-	skb_copy_to_linear_data(skb, data, len);
-	__skb_push(skb, sizeof(*ph));
-	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D oph->utid;
 	ph->message_id =3D oph->message_id + 1; /* REQ -> RESP */
@@ -105,135 +115,69 @@ static int pep_reply(struct sock *sk, struct sk_=
buff *oskb,
 	return pn_skb_send(sk, skb, &peer);
 }
=20
-#define PAD 0x00
-
-#ifdef CONFIG_PHONET_PIPECTRLR
-static int pipe_handler_send_req(struct sock *sk, u8 msg_id, gfp_t pri=
ority)
+static int pep_indicate(struct sock *sk, u8 id, u8 code,
+			const void *data, int len, gfp_t priority)
 {
-	int len;
+	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
-	struct pep_sock *pn =3D pep_sk(sk);
-
-	static const u8 data[4] =3D {
-		PAD, PAD, PAD, PAD,
-	};
=20
-	switch (msg_id) {
-	case PNS_PEP_CONNECT_REQ:
-		len =3D sizeof(data);
-		break;
-
-	case PNS_PEP_DISCONNECT_REQ:
-	case PNS_PEP_ENABLE_REQ:
-	case PNS_PEP_DISABLE_REQ:
-		len =3D 0;
-		break;
-
-	default:
-		return -EINVAL;
-	}
-
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER + len, priority);
+	skb =3D pep_alloc_skb(sk, data, len, priority);
 	if (!skb)
 		return -ENOMEM;
-	skb_set_owner_w(skb, sk);
=20
-	skb_reserve(skb, MAX_PNPIPE_HEADER);
-	if (len) {
-		__skb_put(skb, len);
-		skb_copy_to_linear_data(skb, data, len);
-	}
-	__skb_push(skb, sizeof(*ph));
-	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
-	ph->utid =3D msg_id; /* whatever */
-	ph->message_id =3D msg_id;
+	ph->utid =3D 0;
+	ph->message_id =3D id;
 	ph->pipe_handle =3D pn->pipe_handle;
-	ph->error_code =3D PN_PIPE_NO_ERROR;
-
+	ph->data[0] =3D code;
 	return pn_skb_send(sk, skb, NULL);
 }
=20
-static int pipe_handler_send_created_ind(struct sock *sk, u8 msg_id)
+#define PAD 0x00
+
+#ifdef CONFIG_PHONET_PIPECTRLR
+static int pipe_handler_request(struct sock *sk, u8 id, u8 code,
+				const void *data, int len)
 {
-	int err_code;
+	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
=20
-	struct pep_sock *pn =3D pep_sk(sk);
-	static u8 data[4] =3D {
-		0x03, 0x04,
-	};
-	data[2] =3D pn->tx_fc;
-	data[3] =3D pn->rx_fc;
-
-	/*
-	 * actually, below is number of sub-blocks and not error code.
-	 * Pipe_created_ind message format does not have any
-	 * error code field. However, the Phonet stack will always send
-	 * an error code as part of pnpipehdr. So, use that err_code to
-	 * specify the number of sub-blocks.
-	 */
-	err_code =3D 0x01;
-
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER + sizeof(data), GFP_ATOMIC);
+	skb =3D pep_alloc_skb(sk, data, len, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
-	skb_set_owner_w(skb, sk);
=20
-	skb_reserve(skb, MAX_PNPIPE_HEADER);
-	__skb_put(skb, sizeof(data));
-	skb_copy_to_linear_data(skb, data, sizeof(data));
-	__skb_push(skb, sizeof(*ph));
-	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
-	ph->utid =3D 0;
-	ph->message_id =3D msg_id;
+	ph->utid =3D id; /* whatever */
+	ph->message_id =3D id;
 	ph->pipe_handle =3D pn->pipe_handle;
-	ph->error_code =3D err_code;
-
+	ph->data[0] =3D code;
 	return pn_skb_send(sk, skb, NULL);
 }
=20
-static int pipe_handler_send_ind(struct sock *sk, u8 msg_id)
+static int pipe_handler_send_created_ind(struct sock *sk)
 {
-	int err_code;
-	struct pnpipehdr *ph;
-	struct sk_buff *skb;
 	struct pep_sock *pn =3D pep_sk(sk);
+	u8 data[4] =3D {
+		PN_PIPE_SB_NEGOTIATED_FC, pep_sb_size(2),
+		pn->tx_fc, pn->rx_fc,
+	};
=20
-	/*
-	 * actually, below is a filler.
-	 * Pipe_enabled/disabled_ind message format does not have any
-	 * error code field. However, the Phonet stack will always send
-	 * an error code as part of pnpipehdr. So, use that err_code to
-	 * specify the filler value.
-	 */
-	err_code =3D 0x0;
-
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER, GFP_ATOMIC);
-	if (!skb)
-		return -ENOMEM;
-	skb_set_owner_w(skb, sk);
-
-	skb_reserve(skb, MAX_PNPIPE_HEADER);
-	__skb_push(skb, sizeof(*ph));
-	skb_reset_transport_header(skb);
-	ph =3D pnp_hdr(skb);
-	ph->utid =3D 0;
-	ph->message_id =3D msg_id;
-	ph->pipe_handle =3D pn->pipe_handle;
-	ph->error_code =3D err_code;
+	return pep_indicate(sk, PNS_PIPE_CREATED_IND, 1 /* sub-blocks */,
+				data, 4, GFP_ATOMIC);
+}
=20
-	return pn_skb_send(sk, skb, NULL);
+static int pipe_handler_send_ind(struct sock *sk, u8 id)
+{
+	return pep_indicate(sk, id, PAD, NULL, 0, GFP_ATOMIC);
 }
=20
 static int pipe_handler_enable_pipe(struct sock *sk, int enable)
 {
 	u8 id =3D enable ? PNS_PEP_ENABLE_REQ : PNS_PEP_DISABLE_REQ;
=20
-	return pipe_handler_send_req(sk, id, GFP_KERNEL);
+	return pipe_handler_request(sk, id, PAD, NULL, 0);
 }
 #endif
=20
@@ -274,23 +218,21 @@ static int pep_ctrlreq_error(struct sock *sk, str=
uct sk_buff *oskb, u8 code,
 	struct sk_buff *skb;
 	struct pnpipehdr *ph;
 	struct sockaddr_pn dst;
+	u8 data[4] =3D {
+		oph->data[0], /* PEP type */
+		code, /* error code, at an unusual offset */
+		PAD, PAD,
+	};
=20
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, priority);
+	skb =3D pep_alloc_skb(sk, data, 4, priority);
 	if (!skb)
 		return -ENOMEM;
-	skb_set_owner_w(skb, sk);
-
-	skb_reserve(skb, MAX_PHONET_HEADER);
-	ph =3D (struct pnpipehdr *)skb_put(skb, sizeof(*ph) + 4);
=20
+	ph =3D pnp_hdr(skb);
 	ph->utid =3D oph->utid;
 	ph->message_id =3D PNS_PEP_CTRL_RESP;
 	ph->pipe_handle =3D oph->pipe_handle;
 	ph->data[0] =3D oph->data[1]; /* CTRL id */
-	ph->data[1] =3D oph->data[0]; /* PEP type */
-	ph->data[2] =3D code; /* error code, at an usual offset */
-	ph->data[3] =3D PAD;
-	ph->data[4] =3D PAD;
=20
 	pn_skb_get_src_sockaddr(oskb, &dst);
 	return pn_skb_send(sk, skb, &dst);
@@ -298,34 +240,15 @@ static int pep_ctrlreq_error(struct sock *sk, str=
uct sk_buff *oskb, u8 code,
=20
 static int pipe_snd_status(struct sock *sk, u8 type, u8 status, gfp_t =
priority)
 {
-	struct pep_sock *pn =3D pep_sk(sk);
-	struct pnpipehdr *ph;
-	struct sk_buff *skb;
+	u8 data[4] =3D { type, PAD, PAD, status };
=20
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER + 4, priority);
-	if (!skb)
-		return -ENOMEM;
-	skb_set_owner_w(skb, sk);
-
-	skb_reserve(skb, MAX_PNPIPE_HEADER + 4);
-	__skb_push(skb, sizeof(*ph) + 4);
-	skb_reset_transport_header(skb);
-	ph =3D pnp_hdr(skb);
-	ph->utid =3D 0;
-	ph->message_id =3D PNS_PEP_STATUS_IND;
-	ph->pipe_handle =3D pn->pipe_handle;
-	ph->pep_type =3D PN_PEP_TYPE_COMMON;
-	ph->data[1] =3D type;
-	ph->data[2] =3D PAD;
-	ph->data[3] =3D PAD;
-	ph->data[4] =3D status;
-
-	return pn_skb_send(sk, skb, NULL);
+	return pep_indicate(sk, PNS_PEP_STATUS_IND, PN_PEP_TYPE_COMMON,
+				data, 4, priority);
 }
=20
 /* Send our RX flow control information to the sender.
  * Socket must be locked. */
-static void pipe_grant_credits(struct sock *sk)
+static void pipe_grant_credits(struct sock *sk, gfp_t priority)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
=20
@@ -335,16 +258,16 @@ static void pipe_grant_credits(struct sock *sk)
 	case PN_LEGACY_FLOW_CONTROL: /* TODO */
 		break;
 	case PN_ONE_CREDIT_FLOW_CONTROL:
-		pipe_snd_status(sk, PN_PEP_IND_FLOW_CONTROL,
-				PEP_IND_READY, GFP_ATOMIC);
-		pn->rx_credits =3D 1;
+		if (pipe_snd_status(sk, PN_PEP_IND_FLOW_CONTROL,
+					PEP_IND_READY, priority) =3D=3D 0)
+			pn->rx_credits =3D 1;
 		break;
 	case PN_MULTI_CREDIT_FLOW_CONTROL:
 		if ((pn->rx_credits + CREDITS_THR) > CREDITS_MAX)
 			break;
 		if (pipe_snd_status(sk, PN_PEP_IND_ID_MCFC_GRANT_CREDITS,
 					CREDITS_MAX - pn->rx_credits,
-					GFP_ATOMIC) =3D=3D 0)
+					priority) =3D=3D 0)
 			pn->rx_credits =3D CREDITS_MAX;
 		break;
 	}
@@ -474,7 +397,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
 			break; /* Nothing to do */
 		sk->sk_state =3D TCP_ESTABLISHED;
-		pipe_grant_credits(sk);
+		pipe_grant_credits(sk, GFP_ATOMIC);
 		break;
 #endif
=20
@@ -561,7 +484,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
 			break; /* Nothing to do */
 		sk->sk_state =3D TCP_ESTABLISHED;
-		pipe_grant_credits(sk);
+		pipe_grant_credits(sk, GFP_ATOMIC);
 		break;
=20
 	case PNS_PIPE_DISABLED_IND:
@@ -655,7 +578,7 @@ static int pep_connresp_rcv(struct sock *sk, struct=
 sk_buff *skb)
 	pn->rx_credits =3D 0;
 	sk->sk_state_change(sk);
=20
-	return pipe_handler_send_created_ind(sk, PNS_PIPE_CREATED_IND);
+	return pipe_handler_send_created_ind(sk);
 }
 #endif
=20
@@ -853,19 +776,15 @@ static int pipe_do_remove(struct sock *sk)
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
=20
-	skb =3D alloc_skb(MAX_PNPIPE_HEADER, GFP_KERNEL);
+	skb =3D pep_alloc_skb(sk, NULL, 0, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
=20
-	skb_reserve(skb, MAX_PNPIPE_HEADER);
-	__skb_push(skb, sizeof(*ph));
-	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D 0;
 	ph->message_id =3D PNS_PIPE_REMOVE_REQ;
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->data[0] =3D PAD;
-
 	return pn_skb_send(sk, skb, NULL);
 }
 #endif
@@ -894,7 +813,7 @@ static void pep_sock_close(struct sock *sk, long ti=
meout)
 		pipe_do_remove(sk);
 #else
 		/* send pep disconnect request */
-		pipe_handler_send_req(sk, PNS_PEP_DISCONNECT_REQ, GFP_KERNEL);
+		pipe_handler_request(sk, PNS_PEP_DISCONNECT_REQ, PAD, NULL, 0);
 		sk->sk_state =3D TCP_CLOSE;
 #endif
 	}
@@ -980,10 +899,12 @@ static int pep_sock_connect(struct sock *sk, stru=
ct sockaddr *addr, int len)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	const struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
+	u8 data[4] =3D { 0 /* sub-blocks */, PAD, PAD, PAD };
=20
 	pn->pn_sk.dobject =3D pn_sockaddr_get_object(spn);
 	pn->pn_sk.resource =3D pn_sockaddr_get_resource(spn);
-	return pipe_handler_send_req(sk, PNS_PEP_CONNECT_REQ, GFP_KERNEL);
+	return pipe_handler_request(sk, PNS_PEP_CONNECT_REQ,
+					PN_PIPE_DISABLE, data, 4);
 }
 #endif
=20
@@ -1280,7 +1201,7 @@ struct sk_buff *pep_read(struct sock *sk)
 	struct sk_buff *skb =3D skb_dequeue(&sk->sk_receive_queue);
=20
 	if (sk->sk_state =3D=3D TCP_ESTABLISHED)
-		pipe_grant_credits(sk);
+		pipe_grant_credits(sk, GFP_ATOMIC);
 	return skb;
 }
=20
@@ -1325,7 +1246,7 @@ static int pep_recvmsg(struct kiocb *iocb, struct=
 sock *sk,
 	}
=20
 	if (sk->sk_state =3D=3D TCP_ESTABLISHED)
-		pipe_grant_credits(sk);
+		pipe_grant_credits(sk, GFP_KERNEL);
 	release_sock(sk);
 copy:
 	msg->msg_flags |=3D MSG_EOR;
--=20
1.7.1

