From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ehea: fix use after free
Date: Wed, 27 Oct 2010 07:21:07 +0200
Message-ID: <1288156867.2652.127.camel@edumazet-laptop>
References: <1288116213-11801-1-git-send-email-leitao@linux.vnet.ibm.com>
	 <1288118920.2652.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51125 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab0J0FVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 01:21:12 -0400
Received: by wyf28 with SMTP id 28so264744wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 22:21:11 -0700 (PDT)
In-Reply-To: <1288118920.2652.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 20:48 +0200, Eric Dumazet a =C3=A9crit =
:

> Note: driver already uses skb after its freeing, before your patch.
>=20
>         if (vlan_tx_tag_present(skb)) {
>                 swqe->tx_control |=3D EHEA_SWQE_VLAN_INSERT;
>                 swqe->vlan_tag =3D vlan_tx_tag_get(skb);
>         }
>=20

Could you please test following patch ?

Thanks

[PATCH] ehea: fix use after free

ehea_start_xmit() dereferences skb after its freeing in ehea_xmit3() to
get vlan tags.

Move the offending block before the potential ehea_xmit3() call.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ehea/ehea_main.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.=
c
index bb7d306..e59d386 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2249,6 +2249,11 @@ static int ehea_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 	memset(swqe, 0, SWQE_HEADER_SIZE);
 	atomic_dec(&pr->swqe_avail);
=20
+	if (vlan_tx_tag_present(skb)) {
+		swqe->tx_control |=3D EHEA_SWQE_VLAN_INSERT;
+		swqe->vlan_tag =3D vlan_tx_tag_get(skb);
+	}
+
 	if (skb->len <=3D SWQE3_MAX_IMM) {
 		u32 sig_iv =3D port->sig_comp_iv;
 		u32 swqe_num =3D pr->swqe_id_counter;
@@ -2279,11 +2284,6 @@ static int ehea_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
 	}
 	pr->swqe_id_counter +=3D 1;
=20
-	if (vlan_tx_tag_present(skb)) {
-		swqe->tx_control |=3D EHEA_SWQE_VLAN_INSERT;
-		swqe->vlan_tag =3D vlan_tx_tag_get(skb);
-	}
-
 	if (netif_msg_tx_queued(port)) {
 		ehea_info("post swqe on QP %d", pr->qp->init_attr.qp_nr);
 		ehea_dump(swqe, 512, "swqe");


