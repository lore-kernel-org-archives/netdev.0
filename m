From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/8] Phonet: fix NULL dereference on TX path with implicit source
Date: Wed,  9 Mar 2011 10:44:06 +0200
Message-ID: <1299660253-4446-1-git-send-email-remi.denis-courmont@nokia.com>
References: <201103091043.32391.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30233 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756689Ab1CIIoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 03:44:16 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p298iEY4019524
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 10:44:14 +0200
In-Reply-To: <201103091043.32391.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous Phonet patch series introduced per-socket implicit
destination (i.e. connect()). In that case, the destination
socket address is NULL in the transmit function.
However commit a8059512b120362b15424f152b2548fe8b11bd0c
("Phonet: implement per-socket destination/peer address")
is incomplete and would trigger a NULL dereference.
(Fortunately, the code is not in released kernel, and in fact
 currently not reachable.)

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 30cc676..4706b77 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -262,10 +262,9 @@ int pn_skb_send(struct sock *sk, struct sk_buff *s=
kb,
 	else if (phonet_address_lookup(net, daddr) =3D=3D 0) {
 		dev =3D phonet_device_get(net);
 		skb->pkt_type =3D PACKET_LOOPBACK;
-	} else if (pn_sockaddr_get_object(target) =3D=3D 0) {
+	} else if (dst =3D=3D 0) {
 		/* Resource routing (small race until phonet_rcv()) */
-		struct sock *sk =3D pn_find_sock_by_res(net,
-							target->spn_resource);
+		struct sock *sk =3D pn_find_sock_by_res(net, res);
 		if (sk)	{
 			sock_put(sk);
 			dev =3D phonet_device_get(net);
--=20
1.7.1

