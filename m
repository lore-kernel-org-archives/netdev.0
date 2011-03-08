From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 3/8] Phonet: correct pipe backlog callback return values
Date: Tue,  8 Mar 2011 15:57:01 +0200
Message-ID: <1299592626-18510-3-git-send-email-remi.denis-courmont@nokia.com>
References: <201103081556.18877.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:37517 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754870Ab1CHN5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 08:57:11 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p28Dv8Ce006174
	for <netdev@vger.kernel.org>; Tue, 8 Mar 2011 15:57:09 +0200
In-Reply-To: <201103081556.18877.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases, the Phonet pipe backlog callbacks returned negative
errno instead. In some other cases, NET_RX_DROP was returned even
though there was no buffering issue.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 875e86c..40952c7 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -522,7 +522,8 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 		if (!pn_flow_safe(pn->rx_fc)) {
 			err =3D sock_queue_rcv_skb(sk, skb);
 			if (!err)
-				return 0;
+				return NET_RX_SUCCESS;
+			err =3D -ENOBUFS;
 			break;
 		}
=20
@@ -575,7 +576,7 @@ static int pipe_do_rcv(struct sock *sk, struct sk_b=
uff *skb)
 	}
 out:
 	kfree_skb(skb);
-	return err;
+	return (err =3D=3D -ENOBUFS) ? NET_RX_DROP : NET_RX_SUCCESS;
=20
 queue:
 	skb->dev =3D NULL;
@@ -584,7 +585,7 @@ queue:
 	skb_queue_tail(queue, skb);
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_data_ready(sk, err);
-	return 0;
+	return NET_RX_SUCCESS;
 }
=20
 /* Destroy connected sock. */
@@ -686,11 +687,6 @@ static int pep_connreq_rcv(struct sock *sk, struct=
 sk_buff *skb)
 	}
 	peer_type =3D hdr->other_pep_type << 8;
=20
-	if (unlikely(sk->sk_state !=3D TCP_LISTEN) || sk_acceptq_is_full(sk))=
 {
-		pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
-		return -ENOBUFS;
-	}
-
 	/* Parse sub-blocks (options) */
 	n_sb =3D hdr->data[4];
 	while (n_sb > 0) {
@@ -790,7 +786,6 @@ static int pep_do_rcv(struct sock *sk, struct sk_bu=
ff *skb)
 	struct sock *sknode;
 	struct pnpipehdr *hdr;
 	struct sockaddr_pn dst;
-	int err =3D NET_RX_SUCCESS;
 	u8 pipe_handle;
=20
 	if (!pskb_may_pull(skb, sizeof(*hdr)))
@@ -814,18 +809,20 @@ static int pep_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 		sock_put(sknode);
 		if (net_ratelimit())
 			printk(KERN_WARNING"Phonet unconnected PEP ignored");
-		err =3D NET_RX_DROP;
 		goto drop;
 	}
=20
 	switch (hdr->message_id) {
 	case PNS_PEP_CONNECT_REQ:
-		err =3D pep_connreq_rcv(sk, skb);
+		if (sk->sk_state =3D=3D TCP_LISTEN && !sk_acceptq_is_full(sk))
+			pep_connreq_rcv(sk, skb);
+		else
+			pep_reject_conn(sk, skb, PN_PIPE_ERR_PEP_IN_USE);
 		break;
=20
 #ifdef CONFIG_PHONET_PIPECTRLR
 	case PNS_PEP_CONNECT_RESP:
-		err =3D pep_connresp_rcv(sk, skb);
+		pep_connresp_rcv(sk, skb);
 		break;
 #endif
=20
@@ -842,11 +839,11 @@ static int pep_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 	case PNS_PEP_DISABLE_REQ:
 		/* invalid handle is not even allowed here! */
 	default:
-		err =3D NET_RX_DROP;
+		break;
 	}
 drop:
 	kfree_skb(skb);
-	return err;
+	return NET_RX_SUCCESS;
 }
=20
 #ifndef CONFIG_PHONET_PIPECTRLR
--=20
1.7.1

