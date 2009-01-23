From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/6] Phonet: check destination before delivering packets locally
Date: Fri, 23 Jan 2009 15:00:26 +0200
Message-ID: <1232715630-24951-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:50746 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbZAWNAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:00:45 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0ND0Mli011170
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:43 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0ND0Fo5027886
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:17 +0200
In-Reply-To: <200901231459.29743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/af_phonet.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 13cb323..c7c39d9 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -275,8 +275,6 @@ static inline int can_respond(struct sk_buff *skb)
 		return 0;
=20
 	ph =3D pn_hdr(skb);
-	if (phonet_address_get(skb->dev, ph->pn_rdev) !=3D ph->pn_rdev)
-		return 0; /* we are not the destination */
 	if (ph->pn_res =3D=3D PN_PREFIX && !pskb_may_pull(skb, 5))
 		return 0;
 	if (ph->pn_res =3D=3D PN_COMMGR) /* indications */
@@ -344,8 +342,8 @@ static int phonet_rcv(struct sk_buff *skb, struct n=
et_device *dev,
 			struct packet_type *pkttype,
 			struct net_device *orig_dev)
 {
+	struct net *net =3D dev_net(dev);
 	struct phonethdr *ph;
-	struct sock *sk;
 	struct sockaddr_pn sa;
 	u16 len;
=20
@@ -364,21 +362,21 @@ static int phonet_rcv(struct sk_buff *skb, struct=
 net_device *dev,
 	skb_reset_transport_header(skb);
=20
 	pn_skb_get_dst_sockaddr(skb, &sa);
-	if (pn_sockaddr_get_addr(&sa) =3D=3D 0)
-		goto out; /* currently, we cannot be device 0 */
=20
-	sk =3D pn_find_sock_by_sa(dev_net(dev), &sa);
-	if (sk =3D=3D NULL) {
+	/* check if we are the destination */
+	if (phonet_address_lookup(net, pn_sockaddr_get_addr(&sa)) =3D=3D 0) {
+		/* Phonet packet input */
+		struct sock *sk =3D pn_find_sock_by_sa(net, &sa);
+
+		if (sk)
+			return sk_receive_skb(sk, skb, 0);
+
 		if (can_respond(skb)) {
 			send_obj_unreachable(skb);
 			send_reset_indications(skb);
 		}
-		goto out;
 	}
=20
-	/* Push data to the socket (or other sockets connected to it). */
-	return sk_receive_skb(sk, skb, 0);
-
 out:
 	kfree_skb(skb);
 	return NET_RX_DROP;
--=20
1.5.6.3

