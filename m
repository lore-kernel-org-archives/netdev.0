From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Wed, 16 Jun 2010 20:58:11 +0200
Message-ID: <1276714691.2970.9.camel@edumazet-laptop>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <201006161624.12101.arnd@arndb.de> <4C18ED97.3060702@trash.net>
	 <201006162026.28900.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Pedro Garcia <pedro.netdev@dondevamos.com>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45985 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759049Ab0FPS6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 14:58:17 -0400
Received: by wwb18 with SMTP id 18so5969827wwb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 11:58:14 -0700 (PDT)
In-Reply-To: <201006162026.28900.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 20:26 +0200, Arnd Bergmann a =C3=A9crit=
 :
> On Wednesday 16 June 2010 17:28:23 Patrick McHardy wrote:
>=20
> > Since we don't have any special VLAN handling in the bridging code,=
 I
> > guess it comes down to optionally using a different ethertype value
> > (0x88a8) in the VLAN code. We probably also need some indication fr=
om
> > device drivers whether they are able to add these headers to avoid
> > trying to offload tagging in case they're not.
>=20
> It's probably a little more than just supporting the new ethertype, b=
ut not
> much. The outer tag can be handled like our current VLAN module does,
> but the standard does not allow a regular frame to be encapsulated di=
rectly,
> but rather requires one of=20
>=20
> 1. In 802.1ad: an 802.1Q VLAN tag (ethertype 0x8100) followed by the =
frame
> 2. In 802.1ah: A service tag (ethertype 0x88e7) followed by the 802.1=
Q VLAN tag
>    and then the frame.
>=20
> Maybe what we can do is extend the vlan code to understand all three =
frame
> formats (q, ad and ah) or at least the first two so we configure both=
 the
> provider VID and the Customer VID for the interface in case of 802.1a=
d but
> only the regular VID in 802.1Q.
>=20
> Device drivers can then flag whether they support both formats or jus=
t
> the regular Q tag.
>=20
> 	Arnd

Speaking of device drivers, I see bnx2 (hardware accelerated) is able t=
o
insert a 8021q tag in case no vlgrp is defined (the 8201q tag that was
removed by NIC)... interesting ping pong games, since our 8021q stack
will remove it again, eventually.

So VLAN 0 'problem' on bnx2 could be solved with following patch
(avoiding this insert if vtag=3D=3D0)



diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 522de9f..b5d4d05 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3192,7 +3192,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bn=
api, int budget)
 				hw_vlan =3D 1;
 			else
 #endif
-			{
+			if (vtag) {
 				struct vlan_ethhdr *ve =3D (struct vlan_ethhdr *)
 					__skb_push(skb, 4);
=20


