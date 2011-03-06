From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH net-next-2.6] net: harmonize the call to ptype_all and ptype_base handlers.
Date: Sun,  6 Mar 2011 14:25:16 +0100
Message-ID: <1299417916-14198-1-git-send-email-nicolas.2p.debian@free.fr>
References: <4D738751.6050209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@vyatta.com, eric.dumazet@gmail.com,
	kaber@trash.net, fubar@us.ibm.com, andy@greyhouse.net,
	=?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:57059 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab1CFNZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 08:25:37 -0500
In-Reply-To: <4D738751.6050209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, ptype_all and ptype_base delivery in __netif_receive_skb() i=
s
inconsistent.

- For ptype_all, we deliver to every device crossed while walking the
rx_handler path (inside the another_round loop), and there is no way to=
 stop
wildcard delivery (no exact match logic).
- For ptype_base, we deliver to the lowest device (orig_dev) and to the=
 highest
(skb->dev) and we can ask for exact match delivery.

This patch try and fix this, by:

1/ Doing exact match delivery for both ptype_all and ptype_base, while =
walking
   the rx_handler path.
2/ Doing wildcard match delivery at the end of __netif_receive_skb(), i=
f not
   asked to do exact match delivery only.

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---

This apply on top of the last batch of patch from Jiri Pirko.
---
 net/core/dev.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c71bd18..a368223 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3117,8 +3117,6 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 {
 	struct packet_type *ptype, *pt_prev;
 	rx_handler_func_t *rx_handler;
-	struct net_device *orig_dev;
-	struct net_device *null_or_dev;
 	bool deliver_exact =3D false;
 	int ret =3D NET_RX_DROP;
 	__be16 type;
@@ -3134,7 +3132,6 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
=20
 	if (!skb->skb_iif)
 		skb->skb_iif =3D skb->dev->ifindex;
-	orig_dev =3D skb->dev;
=20
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
@@ -3156,7 +3153,17 @@ another_round:
 #endif
=20
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
+		if (ptype->dev =3D=3D skb->dev) {
+			if (pt_prev)
+				ret =3D deliver_skb(skb, pt_prev);
+			pt_prev =3D ptype;
+		}
+	}
+
+	type =3D skb->protocol;
+	list_for_each_entry_rcu(ptype,
+			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
+		if (ptype->type =3D=3D type && ptype->dev =3D=3D skb->dev) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev);
 			pt_prev =3D ptype;
@@ -3205,20 +3212,29 @@ ncls:
 	vlan_on_bond_hook(skb);
=20
 	/* deliver only exact match when indicated */
-	null_or_dev =3D deliver_exact ? skb->dev : NULL;
+	if (deliver_exact)
+		goto skip_wildcard_delivery;
+
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
+		if (!ptype->dev) {
+			if (pt_prev)
+				ret =3D deliver_skb(skb, pt_prev);
+			pt_prev =3D ptype;
+		}
+	}
=20
 	type =3D skb->protocol;
 	list_for_each_entry_rcu(ptype,
 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type =3D=3D type &&
-		    (ptype->dev =3D=3D null_or_dev || ptype->dev =3D=3D skb->dev ||
-		     ptype->dev =3D=3D orig_dev)) {
+		if (ptype->type =3D=3D type && !ptype->dev) {
 			if (pt_prev)
 				ret =3D deliver_skb(skb, pt_prev);
 			pt_prev =3D ptype;
 		}
 	}
=20
+skip_wildcard_delivery:=09
+
 	if (pt_prev) {
 		ret =3D pt_prev->func(skb, skb->dev, pt_prev);
 	} else {
--=20
1.7.2.3

