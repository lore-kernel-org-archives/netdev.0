From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 5/6] Phonet: don't bother with transaction IDs (especially for indications)
Date: Fri, 25 Feb 2011 11:15:00 +0200
Message-ID: <1298625301-13909-5-git-send-email-remi.denis-courmont@nokia.com>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30678 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab1BYJO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 04:14:28 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1P9EHG4005431
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:14:26 +0200
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |   11 ----------
 net/phonet/pep.c         |   49 +++++++++++++-------------------------=
-------
 2 files changed, 14 insertions(+), 46 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index 4c48ed8..37f23dc 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -165,15 +165,4 @@ enum {
 	PEP_IND_READY,
 };
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-#define PNS_PEP_CONNECT_UTID           0x02
-#define PNS_PIPE_CREATED_IND_UTID      0x04
-#define PNS_PIPE_ENABLE_UTID           0x0A
-#define PNS_PIPE_ENABLED_IND_UTID      0x0C
-#define PNS_PIPE_DISABLE_UTID          0x0F
-#define PNS_PIPE_DISABLED_IND_UTID     0x11
-#define PNS_PEP_DISCONNECT_UTID        0x06
-
-#endif /* CONFIG_PHONET_PIPECTRLR */
-
 #endif
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 15775a7..0ecab59 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -172,8 +172,7 @@ static int pipe_get_flow_info(struct sock *sk, stru=
ct sk_buff *skb,
 	return 0;
 }
=20
-static int pipe_handler_send_req(struct sock *sk, u8 utid,
-		u8 msg_id, gfp_t priority)
+static int pipe_handler_send_req(struct sock *sk, u8 msg_id, gfp_t pri=
ority)
 {
 	int len;
 	struct pnpipehdr *ph;
@@ -212,7 +211,7 @@ static int pipe_handler_send_req(struct sock *sk, u=
8 utid,
 	__skb_push(skb, sizeof(*ph));
 	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
-	ph->utid =3D utid;
+	ph->utid =3D msg_id; /* whatever */
 	ph->message_id =3D msg_id;
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D PN_PIPE_NO_ERROR;
@@ -220,8 +219,7 @@ static int pipe_handler_send_req(struct sock *sk, u=
8 utid,
 	return pn_skb_send(sk, skb, NULL);
 }
=20
-static int pipe_handler_send_created_ind(struct sock *sk,
-		u8 utid, u8 msg_id)
+static int pipe_handler_send_created_ind(struct sock *sk, u8 msg_id)
 {
 	int err_code;
 	struct pnpipehdr *ph;
@@ -254,7 +252,7 @@ static int pipe_handler_send_created_ind(struct soc=
k *sk,
 	__skb_push(skb, sizeof(*ph));
 	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
-	ph->utid =3D utid;
+	ph->utid =3D 0;
 	ph->message_id =3D msg_id;
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D err_code;
@@ -262,7 +260,7 @@ static int pipe_handler_send_created_ind(struct soc=
k *sk,
 	return pn_skb_send(sk, skb, NULL);
 }
=20
-static int pipe_handler_send_ind(struct sock *sk, u8 utid, u8 msg_id)
+static int pipe_handler_send_ind(struct sock *sk, u8 msg_id)
 {
 	int err_code;
 	struct pnpipehdr *ph;
@@ -287,7 +285,7 @@ static int pipe_handler_send_ind(struct sock *sk, u=
8 utid, u8 msg_id)
 	__skb_push(skb, sizeof(*ph));
 	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
-	ph->utid =3D utid;
+	ph->utid =3D 0;
 	ph->message_id =3D msg_id;
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D err_code;
@@ -297,16 +295,9 @@ static int pipe_handler_send_ind(struct sock *sk, =
u8 utid, u8 msg_id)
=20
 static int pipe_handler_enable_pipe(struct sock *sk, int enable)
 {
-	int utid, req;
-
-	if (enable) {
-		utid =3D PNS_PIPE_ENABLE_UTID;
-		req =3D PNS_PEP_ENABLE_REQ;
-	} else {
-		utid =3D PNS_PIPE_DISABLE_UTID;
-		req =3D PNS_PEP_DISABLE_REQ;
-	}
-	return pipe_handler_send_req(sk, utid, req, GFP_ATOMIC);
+	u8 id =3D enable ? PNS_PEP_ENABLE_REQ : PNS_PEP_DISABLE_REQ;
+
+	return pipe_handler_send_req(sk, id, GFP_KERNEL);
 }
 #endif
=20
@@ -538,8 +529,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_ENABLE_RESP:
-		pipe_handler_send_ind(sk, PNS_PIPE_ENABLED_IND_UTID,
-				PNS_PIPE_ENABLED_IND);
+		pipe_handler_send_ind(sk, PNS_PIPE_ENABLED_IND);
=20
 		if (!pn_flow_safe(pn->tx_fc)) {
 			atomic_set(&pn->tx_credits, 1);
@@ -573,8 +563,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_DISABLE_RESP:
 		atomic_set(&pn->tx_credits, 0);
-		pipe_handler_send_ind(sk, PNS_PIPE_DISABLED_IND_UTID,
-				PNS_PIPE_DISABLED_IND);
+		pipe_handler_send_ind(sk, PNS_PIPE_DISABLED_IND);
 		sk->sk_state =3D TCP_SYN_RECV;
 		pn->rx_credits =3D 0;
 		break;
@@ -678,7 +667,6 @@ static int pep_connresp_rcv(struct sock *sk, struct=
 sk_buff *skb)
 	u8 host_pref_rx_fc[3] =3D {3, 2, 1}, host_req_tx_fc[3] =3D {3, 2, 1};
 	u8 remote_pref_rx_fc[3], remote_req_tx_fc[3];
 	u8 negotiated_rx_fc, negotiated_tx_fc;
-	int ret;
=20
 	pipe_get_flow_info(sk, skb, remote_pref_rx_fc,
 			remote_req_tx_fc);
@@ -697,12 +685,7 @@ static int pep_connresp_rcv(struct sock *sk, struc=
t sk_buff *skb)
 	pn->tx_fc =3D negotiated_tx_fc;
 	sk->sk_state_change(sk);
=20
-	ret =3D pipe_handler_send_created_ind(sk,
-			PNS_PIPE_CREATED_IND_UTID,
-			PNS_PIPE_CREATED_IND
-			);
-
-	return ret;
+	return pipe_handler_send_created_ind(sk, PNS_PIPE_CREATED_IND);
 }
 #endif
=20
@@ -943,9 +926,7 @@ static void pep_sock_close(struct sock *sk, long ti=
meout)
 		pipe_do_remove(sk);
 #else
 		/* send pep disconnect request */
-		pipe_handler_send_req(sk,
-				PNS_PEP_DISCONNECT_UTID, PNS_PEP_DISCONNECT_REQ,
-				GFP_KERNEL);
+		pipe_handler_send_req(sk, PNS_PEP_DISCONNECT_REQ, GFP_KERNEL);
 		sk->sk_state =3D TCP_CLOSE;
 #endif
 	}
@@ -1034,9 +1015,7 @@ static int pep_sock_connect(struct sock *sk, stru=
ct sockaddr *addr, int len)
=20
 	pn->pn_sk.dobject =3D pn_sockaddr_get_object(spn);
 	pn->pn_sk.resource =3D pn_sockaddr_get_resource(spn);
-	return pipe_handler_send_req(sk,
-			PNS_PEP_CONNECT_UTID, PNS_PEP_CONNECT_REQ,
-			GFP_ATOMIC);
+	return pipe_handler_send_req(sk, PNS_PEP_CONNECT_REQ, GFP_KERNEL);
 }
 #endif
=20
--=20
1.7.1

