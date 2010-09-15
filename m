From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: look up the resource routing table when forwarding
Date: Thu, 16 Sep 2010 01:30:13 +0300
Message-ID: <1284589815-28302-3-git-send-email-remi@remlab.net>
References: <d214bd6716258777ce8b1023208bc347@chewa.net>
 <1284589815-28302-1-git-send-email-remi@remlab.net>
 <1284589815-28302-2-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36522 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496Ab0IOWaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:30:17 -0400
In-Reply-To: <1284589815-28302-2-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 73aee7f..fd95beb 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -251,6 +251,16 @@ int pn_skb_send(struct sock *sk, struct sk_buff *s=
kb,
 	else if (phonet_address_lookup(net, daddr) =3D=3D 0) {
 		dev =3D phonet_device_get(net);
 		skb->pkt_type =3D PACKET_LOOPBACK;
+	} else if (pn_sockaddr_get_object(target) =3D=3D 0) {
+		/* Resource routing (small race until phonet_rcv()) */
+		struct sock *sk =3D pn_find_sock_by_res(net,
+							target->spn_resource);
+		if (sk)	{
+			sock_put(sk);
+			dev =3D phonet_device_get(net);
+			skb->pkt_type =3D PACKET_LOOPBACK;
+		} else
+			dev =3D phonet_route_output(net, daddr);
 	} else
 		dev =3D phonet_route_output(net, daddr);
=20
@@ -383,6 +393,13 @@ static int phonet_rcv(struct sk_buff *skb, struct =
net_device *dev,
 		goto out;
 	}
=20
+	/* resource routing */
+	if (pn_sockaddr_get_object(&sa) =3D=3D 0) {
+		struct sock *sk =3D pn_find_sock_by_res(net, sa.spn_resource);
+		if (sk)
+			return sk_receive_skb(sk, skb, 0);
+	}
+
 	/* check if we are the destination */
 	if (phonet_address_lookup(net, pn_sockaddr_get_addr(&sa)) =3D=3D 0) {
 		/* Phonet packet input */
--=20
1.7.0.4

