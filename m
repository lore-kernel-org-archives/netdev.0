From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/5] Phonet: use atomic for packet TX window
Date: Wed, 17 Dec 2008 16:07:52 +0200
Message-ID: <1229522874-20636-3-git-send-email-remi.denis-courmont@nokia.com>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:44508 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbYLQOIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 09:08:07 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBHE6Wcb015297
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 08:08:04 -0600
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBHE7sdd016910
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:07:57 +0200
In-Reply-To: <200812171607.14184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GPRS TX flow control won't need to lock the underlying socket anymore.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    2 +-
 net/phonet/pep.c         |   38 +++++++++++++++++++++-----------------
 net/phonet/socket.c      |    2 +-
 3 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index fcd7930..4c61cdc 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -35,12 +35,12 @@ struct pep_sock {
 	struct sock		*listener;
 	struct sk_buff_head	ctrlreq_queue;
 #define PNPIPE_CTRLREQ_MAX	10
+	atomic_t		tx_credits;
 	int			ifindex;
 	u16			peer_type;	/* peer type/subtype */
 	u8			pipe_handle;
=20
 	u8			rx_credits;
-	u8			tx_credits;
 	u8			rx_fc;	/* RX flow control */
 	u8			tx_fc;	/* TX flow control */
 	u8			init_enable;	/* auto-enable at creation */
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index bc6d50f..bb3e678 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -225,6 +225,7 @@ static int pipe_rcv_status(struct sock *sk, struct =
sk_buff *skb)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *hdr =3D pnp_hdr(skb);
+	int wake =3D 0;
=20
 	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
 		return -EINVAL;
@@ -241,16 +242,16 @@ static int pipe_rcv_status(struct sock *sk, struc=
t sk_buff *skb)
 		case PN_LEGACY_FLOW_CONTROL:
 			switch (hdr->data[4]) {
 			case PEP_IND_BUSY:
-				pn->tx_credits =3D 0;
+				atomic_set(&pn->tx_credits, 0);
 				break;
 			case PEP_IND_READY:
-				pn->tx_credits =3D 1;
+				atomic_set(&pn->tx_credits, wake =3D 1);
 				break;
 			}
 			break;
 		case PN_ONE_CREDIT_FLOW_CONTROL:
 			if (hdr->data[4] =3D=3D PEP_IND_READY)
-				pn->tx_credits =3D 1;
+				atomic_set(&pn->tx_credits, wake =3D 1);
 			break;
 		}
 		break;
@@ -258,10 +259,7 @@ static int pipe_rcv_status(struct sock *sk, struct=
 sk_buff *skb)
 	case PN_PEP_IND_ID_MCFC_GRANT_CREDITS:
 		if (pn->tx_fc !=3D PN_MULTI_CREDIT_FLOW_CONTROL)
 			break;
-		if (pn->tx_credits + hdr->data[4] > 0xff)
-			pn->tx_credits =3D 0xff;
-		else
-			pn->tx_credits +=3D hdr->data[4];
+		atomic_add(wake =3D hdr->data[4], &pn->tx_credits);
 		break;
=20
 	default:
@@ -269,7 +267,7 @@ static int pipe_rcv_status(struct sock *sk, struct =
sk_buff *skb)
 				(unsigned)hdr->data[1]);
 		return -EOPNOTSUPP;
 	}
-	if (pn->tx_credits)
+	if (wake)
 		sk->sk_write_space(sk);
 	return 0;
 }
@@ -343,7 +341,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		}
 		/* fall through */
 	case PNS_PEP_DISABLE_REQ:
-		pn->tx_credits =3D 0;
+		atomic_set(&pn->tx_credits, 0);
 		pep_reply(sk, skb, PN_PIPE_NO_ERROR, NULL, 0, GFP_ATOMIC);
 		break;
=20
@@ -390,7 +388,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		/* fall through */
 	case PNS_PIPE_ENABLED_IND:
 		if (!pn_flow_safe(pn->tx_fc)) {
-			pn->tx_credits =3D 1;
+			atomic_set(&pn->tx_credits, 1);
 			sk->sk_write_space(sk);
 		}
 		if (sk->sk_state =3D=3D TCP_ESTABLISHED)
@@ -504,8 +502,9 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 	newpn->pn_sk.resource =3D pn->pn_sk.resource;
 	skb_queue_head_init(&newpn->ctrlreq_queue);
 	newpn->pipe_handle =3D pipe_handle;
+	atomic_set(&newpn->tx_credits, 0);
 	newpn->peer_type =3D peer_type;
-	newpn->rx_credits =3D newpn->tx_credits =3D 0;
+	newpn->rx_credits =3D 0;
 	newpn->rx_fc =3D newpn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
 	newpn->init_enable =3D enabled;
=20
@@ -821,14 +820,18 @@ static int pipe_skb_send(struct sock *sk, struct =
sk_buff *skb)
 	struct pep_sock *pn =3D pep_sk(sk);
 	struct pnpipehdr *ph;
=20
+	if (pn_flow_safe(pn->tx_fc) &&
+	    !atomic_add_unless(&pn->tx_credits, -1, 0)) {
+		kfree_skb(skb);
+		return -ENOBUFS;
+	}
+
 	skb_push(skb, 3);
 	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D 0;
 	ph->message_id =3D PNS_PIPE_DATA;
 	ph->pipe_handle =3D pn->pipe_handle;
-	if (pn_flow_safe(pn->tx_fc) && pn->tx_credits)
-		pn->tx_credits--;
=20
 	return pn_skb_send(sk, skb, &pipe_srv);
 }
@@ -866,7 +869,7 @@ disabled:
 	BUG_ON(sk->sk_state !=3D TCP_ESTABLISHED);
=20
 	/* Wait until flow control allows TX */
-	done =3D pn->tx_credits > 0;
+	done =3D atomic_read(&pn->tx_credits);
 	while (!done) {
 		DEFINE_WAIT(wait);
=20
@@ -881,7 +884,7 @@ disabled:
=20
 		prepare_to_wait(&sk->sk_socket->wait, &wait,
 				TASK_INTERRUPTIBLE);
-		done =3D sk_wait_event(sk, &timeo, pn->tx_credits > 0);
+		done =3D sk_wait_event(sk, &timeo, atomic_read(&pn->tx_credits));
 		finish_wait(&sk->sk_socket->wait, &wait);
=20
 		if (sk->sk_state !=3D TCP_ESTABLISHED)
@@ -895,7 +898,8 @@ disabled:
 			goto out;
 		skb_reserve(skb, MAX_PHONET_HEADER + 3);
=20
-		if (sk->sk_state !=3D TCP_ESTABLISHED || !pn->tx_credits)
+		if (sk->sk_state !=3D TCP_ESTABLISHED ||
+		    !atomic_read(&pn->tx_credits))
 			goto disabled; /* sock_alloc_send_skb might sleep */
 	}
=20
@@ -917,7 +921,7 @@ int pep_writeable(struct sock *sk)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
=20
-	return (sk->sk_state =3D=3D TCP_ESTABLISHED) ? pn->tx_credits : 0;
+	return atomic_read(&pn->tx_credits);
 }
=20
 int pep_write(struct sock *sk, struct sk_buff *skb)
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index c75aa5c..ada2a35 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -227,7 +227,7 @@ static unsigned int pn_socket_poll(struct file *fil=
e, struct socket *sock,
 	if (!mask && sk->sk_state =3D=3D TCP_CLOSE_WAIT)
 		return POLLHUP;
=20
-	if (sk->sk_state =3D=3D TCP_ESTABLISHED && pn->tx_credits)
+	if (sk->sk_state =3D=3D TCP_ESTABLISHED && atomic_read(&pn->tx_credit=
s))
 		mask |=3D POLLOUT | POLLWRNORM | POLLWRBAND;
=20
 	return mask;
--=20
1.5.4.3

