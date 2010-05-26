From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: NULL Pointer Deference: NFS & Telnet
Date: Wed, 26 May 2010 22:48:53 +0200
Message-ID: <1274906933.2542.17.camel@edumazet-laptop>
References: <27F9C60D11D683428E133F85D2BB4A53043E33A997@dlee03.ent.ti.com>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFE6@dlee03.ent.ti.com>
	 <20100525.185236.193707791.davem@davemloft.net>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EDFF1@dlee03.ent.ti.com>
	 <1274851741.25136.16.camel@edumazet-laptop>
	 <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"tony@atomide.com" <tony@atomide.com>,
	"Shilimkar, Santosh" <santosh.shilimkar@ti.com>,
	"Ha, Tristram" <Tristram.Ha@micrel.com>
To: "Arce, Abraham" <x0066660@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <27F9C60D11D683428E133F85D2BB4A53043E3EE6A3@dlee03.ent.ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 26 mai 2010 =C3=A0 15:19 -0500, Arce, Abraham a =C3=A9crit =
:

> By increasing the allocation length of our rx skbuff the corruption i=
ssue is fixed... I have increased it by 2... Were we writing outside ou=
r boundaries of skb data?
>=20
> Please let me know about this approach...
>=20
> diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
> index b4fb07a..6da81e1 100644
> --- a/drivers/net/ks8851.c
> +++ b/drivers/net/ks8851.c
> @@ -504,7 +504,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
>                                ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE=
);
>=20
>                 if (rxlen > 0) {
> -                       skb =3D netdev_alloc_skb(ks->netdev, rxlen + =
2 + 8);
> +                       skb =3D netdev_alloc_skb(ks->netdev, rxlen + =
4 + 8);
>                         if (!skb) {
>=20
> Best Regards
> Abraham
>=20

Yes that makes sense, nr_frag is right after the packet (padded to L1
cache size)

But please do the correct allocation ?

Also, we dont need FCS ?

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index b4fb07a..05bd312 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -503,8 +503,9 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 		ks8851_wrreg16(ks, KS_RXQCR,
 			       ks->rc_rxqcr | RXQCR_SDA | RXQCR_ADRFE);
=20
-		if (rxlen > 0) {
-			skb =3D netdev_alloc_skb(ks->netdev, rxlen + 2 + 8);
+		if (rxlen > 4) {
+			rxlen -=3D 4;
+			skb =3D netdev_alloc_skb(ks->netdev, 2 + 8 + ALIGN(rxlen, 4));
 			if (!skb) {
 				/* todo - dump frame and move on */
 			}
@@ -513,7 +514,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 			 * for the status header and 4 bytes of garbage */
 			skb_reserve(skb, 2 + 4 + 4);
=20
-			rxpkt =3D skb_put(skb, rxlen - 4) - 8;
+			rxpkt =3D skb_put(skb, rxlen) - 8;
=20
 			/* align the packet length to 4 bytes, and add 4 bytes
 			 * as we're getting the rx status header as well */
@@ -526,7 +527,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 			netif_rx(skb);
=20
 			ks->netdev->stats.rx_packets++;
-			ks->netdev->stats.rx_bytes +=3D rxlen - 4;
+			ks->netdev->stats.rx_bytes +=3D rxlen;
 		}
=20
 		ks8851_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr);
