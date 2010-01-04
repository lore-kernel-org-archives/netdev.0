From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 2/3] Phonet: zero-copy GPRS TX
Date: Mon,  4 Jan 2010 14:02:48 +0200
Message-ID: <1262606569-3021-2-git-send-email-remi@remlab.net>
References: <1262606569-3021-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:50112 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096Ab0ADMJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 07:09:26 -0500
In-Reply-To: <1262606569-3021-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Send aligned pipe payload if requested to do so. Then, the socket buffe=
r
needs not be fragmented anymore.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pep.h |    2 ++
 net/phonet/pep.c         |   16 ++++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/net/phonet/pep.h b/include/net/phonet/pep.h
index c371625..35672b1 100644
--- a/include/net/phonet/pep.h
+++ b/include/net/phonet/pep.h
@@ -44,6 +44,7 @@ struct pep_sock {
 	u8			rx_fc;	/* RX flow control */
 	u8			tx_fc;	/* TX flow control */
 	u8			init_enable;	/* auto-enable at creation */
+	u8			aligned;
 };
=20
 static inline struct pep_sock *pep_sk(struct sock *sk)
@@ -139,6 +140,7 @@ enum {
 	PN_PIPE_SB_NEGOTIATED_FC,
 	PN_PIPE_SB_REQUIRED_FC_TX,
 	PN_PIPE_SB_PREFERRED_FC_RX,
+	PN_PIPE_SB_ALIGNED_DATA,
 };
=20
 /* Phonet pipe flow control models */
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index e23e309..72db27e 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -444,6 +444,7 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 	struct sockaddr_pn dst;
 	u16 peer_type;
 	u8 pipe_handle, enabled, n_sb;
+	u8 aligned =3D 0;
=20
 	if (!pskb_pull(skb, sizeof(*hdr) + 4))
 		return -EINVAL;
@@ -482,6 +483,9 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 				return -EINVAL;
 			peer_type =3D (peer_type & 0xff00) | data[0];
 			break;
+		case PN_PIPE_SB_ALIGNED_DATA:
+			aligned =3D data[0] !=3D 0;
+			break;
 		}
 		n_sb--;
 	}
@@ -513,6 +517,7 @@ static int pep_connreq_rcv(struct sock *sk, struct =
sk_buff *skb)
 	newpn->rx_credits =3D 0;
 	newpn->rx_fc =3D newpn->tx_fc =3D PN_LEGACY_FLOW_CONTROL;
 	newpn->init_enable =3D enabled;
+	newpn->aligned =3D aligned;
=20
 	BUG_ON(!skb_queue_empty(&newsk->sk_receive_queue));
 	skb_queue_head(&newsk->sk_receive_queue, skb);
@@ -832,11 +837,15 @@ static int pipe_skb_send(struct sock *sk, struct =
sk_buff *skb)
 		return -ENOBUFS;
 	}
=20
-	skb_push(skb, 3);
+	skb_push(skb, 3 + pn->aligned);
 	skb_reset_transport_header(skb);
 	ph =3D pnp_hdr(skb);
 	ph->utid =3D 0;
-	ph->message_id =3D PNS_PIPE_DATA;
+	if (pn->aligned) {
+		ph->message_id =3D PNS_PIPE_ALIGNED_DATA;
+		ph->data[0] =3D 0; /* padding */
+	} else
+		ph->message_id =3D PNS_PIPE_DATA;
 	ph->pipe_handle =3D pn->pipe_handle;
=20
 	return pn_skb_send(sk, skb, &pipe_srv);
@@ -930,6 +939,9 @@ int pep_write(struct sock *sk, struct sk_buff *skb)
 	struct sk_buff *rskb, *fs;
 	int flen =3D 0;
=20
+	if (pep_sk(sk)->aligned)
+		return pipe_skb_send(sk, skb);
+
 	rskb =3D alloc_skb(MAX_PNPIPE_HEADER, GFP_ATOMIC);
 	if (!rskb) {
 		kfree_skb(skb);
--=20
1.6.3.3

