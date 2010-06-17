From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Thu, 17 Jun 2010 12:28:38 +0200
Message-ID: <1276770518.2519.1.camel@edumazet-laptop>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <201006161624.12101.arnd@arndb.de> <4C18ED97.3060702@trash.net>
	 <201006162026.28900.arnd@arndb.de>
	 <1276714691.2970.9.camel@edumazet-laptop>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDC69DDE7E@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
	Pedro Garcia <pedro.netdev@dondevamos.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43714 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab0FQK2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jun 2010 06:28:43 -0400
Received: by wyf19 with SMTP id 19so31949wyf.19
        for <netdev@vger.kernel.org>; Thu, 17 Jun 2010 03:28:41 -0700 (PDT)
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC69DDE7E@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 juin 2010 =C3=A0 01:56 -0700, Vladislav Zolotarov a =C3=A9c=
rit :
>=20
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel=
=2Eorg] On
> > Behalf Of Eric Dumazet
> > Sent: Wednesday, June 16, 2010 9:58 PM
> > To: Arnd Bergmann
> > Cc: Patrick McHardy; Pedro Garcia; netdev@vger.kernel.org; Ben Hutc=
hings
> > Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan=
 tag"
> > (802.1p packet)
> >=20
> > Le mercredi 16 juin 2010 =C3=A0 20:26 +0200, Arnd Bergmann a =C3=A9=
crit :
> > > On Wednesday 16 June 2010 17:28:23 Patrick McHardy wrote:
> > >
> > > > Since we don't have any special VLAN handling in the bridging c=
ode, I
> > > > guess it comes down to optionally using a different ethertype v=
alue
> > > > (0x88a8) in the VLAN code. We probably also need some indicatio=
n from
> > > > device drivers whether they are able to add these headers to av=
oid
> > > > trying to offload tagging in case they're not.
> > >
> > > It's probably a little more than just supporting the new ethertyp=
e, but not
> > > much. The outer tag can be handled like our current VLAN module d=
oes,
> > > but the standard does not allow a regular frame to be encapsulate=
d
> > directly,
> > > but rather requires one of
> > >
> > > 1. In 802.1ad: an 802.1Q VLAN tag (ethertype 0x8100) followed by =
the frame
> > > 2. In 802.1ah: A service tag (ethertype 0x88e7) followed by the 8=
02.1Q VLAN
> > tag
> > >    and then the frame.
> > >
> > > Maybe what we can do is extend the vlan code to understand all th=
ree frame
> > > formats (q, ad and ah) or at least the first two so we configure =
both the
> > > provider VID and the Customer VID for the interface in case of 80=
2.1ad but
> > > only the regular VID in 802.1Q.
> > >
> > > Device drivers can then flag whether they support both formats or=
 just
> > > the regular Q tag.
> > >
> > > 	Arnd
> >=20
> > Speaking of device drivers, I see bnx2 (hardware accelerated) is ab=
le to
> > insert a 8021q tag in case no vlgrp is defined (the 8201q tag that =
was
> > removed by NIC)... interesting ping pong games, since our 8021q sta=
ck
> > will remove it again, eventually.
> >=20
> > So VLAN 0 'problem' on bnx2 could be solved with following patch
> > (avoiding this insert if vtag=3D=3D0)
> >=20
> >=20
> >=20
> > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > index 522de9f..b5d4d05 100644
> > --- a/drivers/net/bnx2.c
> > +++ b/drivers/net/bnx2.c
> > @@ -3192,7 +3192,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi=
 *bnapi,
> > int budget)
> >  				hw_vlan =3D 1;
> >  			else
> >  #endif
> > -			{
> > +			if (vtag) {
> >  				struct vlan_ethhdr *ve =3D (struct vlan_ethhdr *)
> >  					__skb_push(skb, 4);
> >=20
> >=20
> >=20
> > --
>=20
> This way u will loose all the priority information that was on the VL=
AN header.

16bits vtag =3D 0 : there is no priority information.



