From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netxen: dont set skb->truesize
Date: Tue, 21 Sep 2010 21:55:10 +0200
Message-ID: <1285098910.2452.9.camel@edumazet-laptop>
References: <99737F4847ED0A48AECC9F4A1974A4B80F86F80270@MNEXMB2.qlogic.org>
	 <1285058073.2617.73.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86F80278@MNEXMB2.qlogic.org>
	 <20100921.123338.71122967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51757 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab0IUTzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 15:55:15 -0400
Received: by wwi17 with SMTP id 17so105520wwi.1
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 12:55:14 -0700 (PDT)
In-Reply-To: <20100921.123338.71122967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 12:33 -0700, David Miller a =C3=A9cri=
t :
> From: Amit Salecha <amit.salecha@qlogic.com>
> Date: Tue, 21 Sep 2010 03:41:42 -0500
>=20
> >> So in order to improve "throughput", you were allowing for memory
> >> exhaust and freeze of the _machine_ ?
> >>
> > This won't lead to such problem. truesize is used for accounting on=
ly.
>=20
> Yes, it will.
>=20
> Do you understand that we enforce both socket-level and system-wide
> networking buffer usage in the stack?  And this limiting is based
> upon skb->truesize and therefore only works if skb->truesize is
> accurate?
>=20
> It's meant to keep people from attacking a server and consuming large
> percentages of system memory with networking buffer memory such that
> other tasks cannot complete successfully.
>=20
> And by mis-reporting the truesize you are subverting that entirely.
>=20
> This qlcnic truesize bug is a huge security hole, can't you see this
> now?
>=20

BTW, drivers/net/netxen/netxen_nic_init.c has same problem.

[PATCH] netxen: dont set skb->truesize

skb->truesize is set in core network.

Dont change it unless dealing with fragments.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/netxen/netxen_nic_init.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/=
netxen_nic_init.c
index cabae7b..b075a35 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1540,7 +1540,6 @@ netxen_process_rcv(struct netxen_adapter *adapter=
,
 	if (pkt_offset)
 		skb_pull(skb, pkt_offset);
=20
-	skb->truesize =3D skb->len + sizeof(struct sk_buff);
 	skb->protocol =3D eth_type_trans(skb, netdev);
=20
 	napi_gro_receive(&sds_ring->napi, skb);
@@ -1602,8 +1601,6 @@ netxen_process_lro(struct netxen_adapter *adapter=
,
=20
 	skb_put(skb, lro_length + data_offset);
=20
-	skb->truesize =3D skb->len + sizeof(struct sk_buff) + skb_headroom(sk=
b);
-
 	skb_pull(skb, l2_hdr_offset);
 	skb->protocol =3D eth_type_trans(skb, netdev);
=20


