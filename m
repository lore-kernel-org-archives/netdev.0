From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/6] Phonet: use socket destination in pipe protocol
Date: Fri, 25 Feb 2011 11:14:58 +0200
Message-ID: <1298625301-13909-3-git-send-email-remi.denis-courmont@nokia.com>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30615 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab1BYJOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 04:14:24 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1P9EHG2005431
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:14:22 +0200
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    1 -
 net/phonet/pep.c         |   41 ++++++++++++++++----------------------=
---
 2 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index b60b28c..788ccf3 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -47,7 +47,6 @@ struct pep_sock {
 	u8			aligned;
 #ifdef CONFIG_PHONET_PIPECTRLR
 	u8			pipe_state;
-	struct sockaddr_pn	remote_pep;
 #endif
 };
=20
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 3e60f2e..4fce882 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -50,11 +50,6 @@
 #define CREDITS_MAX	10
 #define CREDITS_THR	7
=20
-static const struct sockaddr_pn pipe_srv =3D {
-	.spn_family =3D AF_PHONET,
-	.spn_resource =3D 0xD9, /* pipe service */
-};
-
 #define pep_sb_size(s) (((s) + 5) & ~3) /* 2-bytes head, 32-bits align=
ed */
=20
 /* Get the next TLV sub-block. */
@@ -88,6 +83,7 @@ static int pep_reply(struct sock *sk, struct sk_buff =
*oskb,
 	const struct pnpipehdr *oph =3D pnp_hdr(oskb);
 	struct pnpipehdr *ph;
 	struct sk_buff *skb;
+	struct sockaddr_pn peer;
=20
 	skb =3D alloc_skb(MAX_PNPIPE_HEADER + len, priority);
 	if (!skb)
@@ -105,7 +101,8 @@ static int pep_reply(struct sock *sk, struct sk_buf=
f *oskb,
 	ph->pipe_handle =3D oph->pipe_handle;
 	ph->error_code =3D code;
=20
-	return pn_skb_send(sk, skb, &pipe_srv);
+	pn_skb_get_src_sockaddr(oskb, &peer);
+	return pn_skb_send(sk, skb, &peer);
 }
=20
 #define PAD 0x00
@@ -220,7 +217,7 @@ static int pipe_handler_send_req(struct sock *sk, u=
8 utid,
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D PN_PIPE_NO_ERROR;
=20
-	return pn_skb_send(sk, skb, &pn->remote_pep);
+	return pn_skb_send(sk, skb, NULL);
 }
=20
 static int pipe_handler_send_created_ind(struct sock *sk,
@@ -262,7 +259,7 @@ static int pipe_handler_send_created_ind(struct soc=
k *sk,
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D err_code;
=20
-	return pn_skb_send(sk, skb, &pn->remote_pep);
+	return pn_skb_send(sk, skb, NULL);
 }
=20
 static int pipe_handler_send_ind(struct sock *sk, u8 utid, u8 msg_id)
@@ -295,7 +292,7 @@ static int pipe_handler_send_ind(struct sock *sk, u=
8 utid, u8 msg_id)
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->error_code =3D err_code;
=20
-	return pn_skb_send(sk, skb, &pn->remote_pep);
+	return pn_skb_send(sk, skb, NULL);
 }
=20
 static int pipe_handler_enable_pipe(struct sock *sk, int enable)
@@ -396,11 +393,7 @@ static int pipe_snd_status(struct sock *sk, u8 typ=
e, u8 status, gfp_t priority)
 	ph->data[3] =3D PAD;
 	ph->data[4] =3D status;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	return pn_skb_send(sk, skb, &pn->remote_pep);
-#else
-	return pn_skb_send(sk, skb, &pipe_srv);
-#endif
+	return pn_skb_send(sk, skb, NULL);
 }
=20
 /* Send our RX flow control information to the sender.
@@ -722,7 +715,7 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 	struct sock *newsk;
 	struct pep_sock *newpn, *pn =3D pep_sk(sk);
 	struct pnpipehdr *hdr;
-	struct sockaddr_pn dst;
+	struct sockaddr_pn dst, src;
 	u16 peer_type;
 	u8 pipe_handle, enabled, n_sb;
 	u8 aligned =3D 0;
@@ -789,8 +782,10 @@ static int pep_connreq_rcv(struct sock *sk, struct=
 sk_buff *skb)
=20
 	newpn =3D pep_sk(newsk);
 	pn_skb_get_dst_sockaddr(skb, &dst);
+	pn_skb_get_src_sockaddr(skb, &src);
 	newpn->pn_sk.sobject =3D pn_sockaddr_get_object(&dst);
-	newpn->pn_sk.resource =3D pn->pn_sk.resource;
+	newpn->pn_sk.dobject =3D pn_sockaddr_get_object(&src);
+	newpn->pn_sk.resource =3D pn_sockaddr_get_resource(&dst);
 	skb_queue_head_init(&newpn->ctrlreq_queue);
 	newpn->pipe_handle =3D pipe_handle;
 	atomic_set(&newpn->tx_credits, 0);
@@ -925,7 +920,7 @@ static int pipe_do_remove(struct sock *sk)
 	ph->pipe_handle =3D pn->pipe_handle;
 	ph->data[0] =3D PAD;
=20
-	return pn_skb_send(sk, skb, &pipe_srv);
+	return pn_skb_send(sk, skb, NULL);
 }
=20
 /* associated socket ceases to exist */
@@ -1042,10 +1037,10 @@ out:
 static int pep_sock_connect(struct sock *sk, struct sockaddr *addr, in=
t len)
 {
 	struct pep_sock *pn =3D pep_sk(sk);
-	struct sockaddr_pn *spn =3D  (struct sockaddr_pn *)addr;
-
-	memcpy(&pn->remote_pep, spn, sizeof(struct sockaddr_pn));
+	const struct sockaddr_pn *spn =3D (struct sockaddr_pn *)addr;
=20
+	pn->pn_sk.dobject =3D pn_sockaddr_get_object(spn);
+	pn->pn_sk.resource =3D pn_sockaddr_get_resource(spn);
 	return pipe_handler_send_req(sk,
 			PNS_PEP_CONNECT_UTID, PNS_PEP_CONNECT_REQ,
 			GFP_ATOMIC);
@@ -1222,11 +1217,7 @@ static int pipe_skb_send(struct sock *sk, struct=
 sk_buff *skb)
 	} else
 		ph->message_id =3D PNS_PIPE_DATA;
 	ph->pipe_handle =3D pn->pipe_handle;
-#ifdef CONFIG_PHONET_PIPECTRLR
-	err =3D pn_skb_send(sk, skb, &pn->remote_pep);
-#else
-	err =3D pn_skb_send(sk, skb, &pipe_srv);
-#endif
+	err =3D pn_skb_send(sk, skb, NULL);
=20
 	if (err && pn_flow_safe(pn->tx_fc))
 		atomic_inc(&pn->tx_credits);
--=20
1.7.1

