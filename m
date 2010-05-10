From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:51:02 +0200
Message-ID: <1273503062.2221.10.camel@edumazet-laptop>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>
	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
	 <1273222403.2261.26.camel@edumazet-laptop>  <4BE81793.3060905@trash.net>
	 <1273502195.2221.4.camel@edumazet-laptop>  <4BE81B24.4020601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50416 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab0EJOvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:51:07 -0400
Received: by bwz19 with SMTP id 19so1816630bwz.21
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 07:51:06 -0700 (PDT)
In-Reply-To: <4BE81B24.4020601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 mai 2010 =C3=A0 16:41 +0200, Patrick McHardy a =C3=A9crit :
> Eric Dumazet wrote:
> > Le lundi 10 mai 2010 =C3=A0 16:26 +0200, Patrick McHardy a =C3=A9cr=
it :
> >=20
> >> Is the intention just to avoid accounting the packet as dropped?
> >> That seems fine to me since in case of NET_XMIT_CN its actually
> >> not the currently transmitted packet that was dropped.
> >>
> >> But part of the intention of the above mentioned patch was actuall=
y
> >> to inform higher layers of congestion so they can take action if
> >> desired, which would be defeated by this patch.
> >>
> >=20
> > I see, so maybe we want following patch instead ?
> >=20
> > (letting NET_XMIT_CN be given to caller, but accounting current pac=
ket
> > as transmitted ?)
>=20
> Perfect, thanks. I'd suggest to change macvlan in a similar fashion
> for consistency though.
>=20
> In any case please feel free to add my
>=20
> Acked-by: Patrick McHardy <kaber@trash.net>

Indeed, thanks !

[PATCH net-next-2.6] net: congestion notifications are not dropped pack=
ets

vlan/macvlan start_xmit() can inform caller of congestion with
NET_XMIT_CN return value. This doesnt mean packet was dropped.
Increment normal stat counters instead of tx_dropped.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Patrick McHardy <kaber@trash.net>
---
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9a939d8..0f8cd95 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -243,7 +243,7 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 	int ret;
=20
 	ret =3D macvlan_queue_xmit(skb, dev);
-	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
+	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;
 	} else
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b5249c5..55be908 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -327,7 +327,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct =
sk_buff *skb,
 	len =3D skb->len;
 	ret =3D dev_queue_xmit(skb);
=20
-	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
+	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;
 	} else
@@ -353,7 +353,7 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit=
(struct sk_buff *skb,
 	len =3D skb->len;
 	ret =3D dev_queue_xmit(skb);
=20
-	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
+	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) {
 		txq->tx_packets++;
 		txq->tx_bytes +=3D len;
 	} else


