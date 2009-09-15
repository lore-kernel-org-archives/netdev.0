From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 4/5] Phonet: route outgoing packets
Date: Tue, 15 Sep 2009 14:32:22 +0300
Message-ID: <1253014343-20326-4-git-send-email-remi@remlab.net>
References: <a9972d3fe3d2bf09387bee7827b571c0@chewa.net>
 <1253014343-20326-1-git-send-email-remi@remlab.net>
 <1253014343-20326-2-git-send-email-remi@remlab.net>
 <1253014343-20326-3-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:59539 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064AbZIOLcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 07:32:20 -0400
In-Reply-To: <1253014343-20326-3-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 013f471..f0ef6f8 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -190,9 +190,8 @@ static int pn_send(struct sk_buff *skb, struct net_=
device *dev,
 	skb->priority =3D 0;
 	skb->dev =3D dev;
=20
-	if (pn_addr(src) =3D=3D pn_addr(dst)) {
+	if (skb->pkt_type =3D=3D PACKET_LOOPBACK) {
 		skb_reset_mac_header(skb);
-		skb->pkt_type =3D PACKET_LOOPBACK;
 		skb_orphan(skb);
 		if (irq)
 			netif_rx(skb);
@@ -222,6 +221,9 @@ static int pn_raw_send(const void *data, int len, s=
truct net_device *dev,
 	if (skb =3D=3D NULL)
 		return -ENOMEM;
=20
+	if (phonet_address_lookup(dev_net(dev), pn_addr(dst)) =3D=3D 0)
+		skb->pkt_type =3D PACKET_LOOPBACK;
+
 	skb_reserve(skb, MAX_PHONET_HEADER);
 	__skb_put(skb, len);
 	skb_copy_to_linear_data(skb, data, len);
@@ -235,6 +237,7 @@ static int pn_raw_send(const void *data, int len, s=
truct net_device *dev,
 int pn_skb_send(struct sock *sk, struct sk_buff *skb,
 		const struct sockaddr_pn *target)
 {
+	struct net *net =3D sock_net(sk);
 	struct net_device *dev;
 	struct pn_sock *pn =3D pn_sk(sk);
 	int err;
@@ -243,9 +246,13 @@ int pn_skb_send(struct sock *sk, struct sk_buff *s=
kb,
=20
 	err =3D -EHOSTUNREACH;
 	if (sk->sk_bound_dev_if)
-		dev =3D dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
-	else
-		dev =3D phonet_device_get(sock_net(sk));
+		dev =3D dev_get_by_index(net, sk->sk_bound_dev_if);
+	else if (phonet_address_lookup(net, daddr) =3D=3D 0) {
+		dev =3D phonet_device_get(net);
+		skb->pkt_type =3D PACKET_LOOPBACK;
+	} else
+		dev =3D phonet_route_output(net, daddr);
+
 	if (!dev || !(dev->flags & IFF_UP))
 		goto drop;
=20
--=20
1.6.0.4

