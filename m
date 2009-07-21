From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: account for dropped RX packets
Date: Tue, 21 Jul 2009 14:57:59 +0300
Message-ID: <1248177479-12669-3-git-send-email-remi.denis-courmont@nokia.com>
References: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com>
 <1248177479-12669-2-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:54701 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbZGULz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 07:55:57 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6LBtZU2012342
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 14:55:46 +0300
Received: from localhost.localdomain (esdhcp03634.research.nokia.com [172.21.36.34])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6LBtWcE014694
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 14:55:35 +0300
In-Reply-To: <1248177479-12669-2-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index eef833e..b8252d2 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -346,8 +346,10 @@ static int pipe_do_rcv(struct sock *sk, struct sk_=
buff *skb)
 		break;
=20
 	case PNS_PEP_CTRL_REQ:
-		if (skb_queue_len(&pn->ctrlreq_queue) >=3D PNPIPE_CTRLREQ_MAX)
+		if (skb_queue_len(&pn->ctrlreq_queue) >=3D PNPIPE_CTRLREQ_MAX) {
+			atomic_inc(&sk->sk_drops);
 			break;
+		}
 		__skb_pull(skb, 4);
 		queue =3D &pn->ctrlreq_queue;
 		goto queue;
@@ -358,10 +360,13 @@ static int pipe_do_rcv(struct sock *sk, struct sk=
_buff *skb)
 			err =3D sock_queue_rcv_skb(sk, skb);
 			if (!err)
 				return 0;
+			if (err =3D=3D -ENOMEM)
+				atomic_inc(&sk->sk_drops);
 			break;
 		}
=20
 		if (pn->rx_credits =3D=3D 0) {
+			atomic_inc(&sk->sk_drops);
 			err =3D -ENOBUFS;
 			break;
 		}
--=20
1.6.0.4

