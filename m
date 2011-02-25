From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 4/6] Phonet: remove redumdant pep->pipe_state
Date: Fri, 25 Feb 2011 11:14:59 +0200
Message-ID: <1298625301-13909-4-git-send-email-remi.denis-courmont@nokia.com>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30649 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932386Ab1BYJO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 04:14:26 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1P9EHG3005431
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:14:24 +0200
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk->sk_state already contains the pipe state.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    9 ---------
 net/phonet/pep.c         |   25 ++++++-------------------
 2 files changed, 6 insertions(+), 28 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 788ccf3..4c48ed8 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -45,9 +45,6 @@ struct pep_sock {
 	u8			tx_fc;	/* TX flow control */
 	u8			init_enable;	/* auto-enable at creation */
 	u8			aligned;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	u8			pipe_state;
-#endif
 };
=20
 static inline struct pep_sock *pep_sk(struct sock *sk)
@@ -177,12 +174,6 @@ enum {
 #define PNS_PIPE_DISABLED_IND_UTID     0x11
 #define PNS_PEP_DISCONNECT_UTID        0x06
=20
-/* Used for tracking state of a pipe */
-enum {
-	PIPE_IDLE,
-	PIPE_DISABLED,
-	PIPE_ENABLED,
-};
 #endif /* CONFIG_PHONET_PIPECTRLR */
=20
 #endif
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 4fce882..15775a7 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -527,7 +527,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_DISCONNECT_RESP:
-		pn->pipe_state =3D PIPE_IDLE;
 		sk->sk_state =3D TCP_CLOSE;
 		break;
 #endif
@@ -539,7 +538,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_ENABLE_RESP:
-		pn->pipe_state =3D PIPE_ENABLED;
 		pipe_handler_send_ind(sk, PNS_PIPE_ENABLED_IND_UTID,
 				PNS_PIPE_ENABLED_IND);
=20
@@ -574,7 +572,6 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_DISABLE_RESP:
-		pn->pipe_state =3D PIPE_DISABLED;
 		atomic_set(&pn->tx_credits, 0);
 		pipe_handler_send_ind(sk, PNS_PIPE_DISABLED_IND_UTID,
 				PNS_PIPE_DISABLED_IND);
@@ -692,7 +689,6 @@ static int pep_connresp_rcv(struct sock *sk, struct=
 sk_buff *skb)
 			remote_pref_rx_fc,
 			sizeof(host_pref_rx_fc));
=20
-	pn->pipe_state =3D PIPE_DISABLED;
 	sk->sk_state =3D TCP_SYN_RECV;
 	sk->sk_backlog_rcv =3D pipe_do_rcv;
 	sk->sk_destruct =3D pipe_destruct;
@@ -941,21 +937,18 @@ static void pep_sock_close(struct sock *sk, long =
timeout)
 		sk_for_each_safe(sknode, p, n, &pn->ackq)
 			sk_del_node_init(sknode);
 		sk->sk_state =3D TCP_CLOSE;
-	} else if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED))
+	} else if ((1 << sk->sk_state) & (TCPF_SYN_RECV|TCPF_ESTABLISHED)) {
+#ifndef CONFIG_PHONET_PIPECTRLR
 		/* Forcefully remove dangling Phonet pipe */
 		pipe_do_remove(sk);
-
-#ifdef CONFIG_PHONET_PIPECTRLR
-	if (pn->pipe_state !=3D PIPE_IDLE) {
+#else
 		/* send pep disconnect request */
 		pipe_handler_send_req(sk,
 				PNS_PEP_DISCONNECT_UTID, PNS_PEP_DISCONNECT_REQ,
 				GFP_KERNEL);
-
-		pn->pipe_state =3D PIPE_IDLE;
 		sk->sk_state =3D TCP_CLOSE;
-	}
 #endif
+	}
=20
 	ifindex =3D pn->ifindex;
 	pn->ifindex =3D 0;
@@ -1101,10 +1094,6 @@ static int pep_setsockopt(struct sock *sk, int l=
evel, int optname,
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNPIPE_PIPE_HANDLE:
 		if (val) {
-			if (pn->pipe_state > PIPE_IDLE) {
-				err =3D -EFAULT;
-				break;
-			}
 			pn->pipe_handle =3D val;
 			break;
 		}
@@ -1138,7 +1127,7 @@ static int pep_setsockopt(struct sock *sk, int le=
vel, int optname,
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNPIPE_ENABLE:
-		if (pn->pipe_state <=3D PIPE_IDLE) {
+		if ((1 << sk->sk_state) & ~(TCPF_SYN_RECV|TCPF_ESTABLISHED)) {
 			err =3D -ENOTCONN;
 			break;
 		}
@@ -1177,9 +1166,7 @@ static int pep_getsockopt(struct sock *sk, int le=
vel, int optname,
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNPIPE_ENABLE:
-		if (pn->pipe_state <=3D PIPE_IDLE)
-			return -ENOTCONN;
-		val =3D pn->pipe_state !=3D PIPE_DISABLED;
+		val =3D sk->sk_state =3D=3D TCP_ESTABLISHED;
 		break;
 #endif
=20
--=20
1.7.1

