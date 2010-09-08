From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: NULL Pointer Deference: NFS & Telnet
Date: Wed, 08 Sep 2010 18:15:50 +0200
Message-ID: <1283962550.2748.92.camel@edumazet-laptop>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
	 <1274851741.25136.16.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
	 <1274906933.2542.17.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A5304509AF8DA@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
	"Ha, Tristram" <Tristram.Ha@micrel.com>
To: "Arce, Abraham" <x0066660@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64919 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab0IHQP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 12:15:56 -0400
Received: by fxm16 with SMTP id 16so199015fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 09:15:55 -0700 (PDT)
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A5304509AF8DA@dlee03.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 16:43 -0500, Arce, Abraham a =C3=A9cr=
it :
> Eric, David,
>=20
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>=20
> [..]
>=20
> > > By increasing the allocation length of our rx skbuff the corrupti=
on issue is
> > fixed... I have increased it by 2... Were we writing outside our bo=
undaries of
> > skb data?
> > >
> >
> > Yes that makes sense, nr_frag is right after the packet (padded to =
L1
> > cache size)
> >
> > But please do the correct allocation ?
> >
> > Also, we dont need FCS ?
>=20
> FCS -> CRC is enable in hardware, under ks8851_net_open()
>=20
>  TXCR_TXCRC | /* add CRC */
>=20
> How about the following patch? I am using added helper function:
> netdev_alloc_skb_ip_align()

Hmm, I prefer following patch (not tested), to really cope with
allocation errors (instead of crashing because of NULL dereference), an=
d
allocate and skb of exactly the needed size.

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b4fb07a..4a4038e 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -503,30 +503,31 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 		ks8851_wrreg16(ks, KS_RXQCR,
 			       ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);
=20
-		if (rxlen > 0) {
-			skb =3D netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
-			if (!skb) {
-				/* todo - dump frame and move on */
+		if (rxlen > 4) {
+			unsigned int rxalign;
+		=09
+			rxlen -=3D 4;
+			rxalign =3D ALIGN(rxlen, 4);
+			skb =3D netdev_alloc_skb_ip_align(ks->netdev, rxalign);
+			if (skb) {
+
+				/* 4 bytes of status header + 4 bytes of garbage:
+				 * we put them before ethernet header, so that
+				 * they are copied, but ignored.
+				 */
+				rxpkt =3D skb_put(skb, rxlen) - 8;
+
+				ks8851_rdfifo(ks, rxpkt, rxalign + 8);
+
+				if (netif_msg_pktdata(ks))
+					ks8851_dbg_dumpkkt(ks, rxpkt);
+
+				skb->protocol =3D eth_type_trans(skb, ks->netdev);
+				netif_rx(skb);
+
+				ks->netdev->stats.rx_packets++;
+				ks->netdev->stats.rx_bytes +=3D rxlen;
 			}
-
-			/* two bytes to ensure ip is aligned, and four bytes
-			 * for the status header and 4 bytes of garbage */
-			skb_reserve(skb, 2 + 4 + 4);
-
-			rxpkt =3D skb_put(skb, rxlen - 4) - 8;
-
-			/* align the packet length to 4 bytes, and add 4 bytes
-			 * as we're getting the rx status header as well */
-			ks8851_rdfifo(ks, rxpkt, ALIGN(rxlen, 4) + 8);
-
-			if (netif_msg_pktdata(ks))
-				ks8851_dbg_dumpkkt(ks, rxpkt);
-
-			skb->protocol =3D eth_type_trans(skb, ks->netdev);
-			netif_rx(skb);
-
-			ks->netdev->stats.rx_packets++;
-			ks->netdev->stats.rx_bytes +=3D rxlen - 4;
 		}
=20
 		ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);


