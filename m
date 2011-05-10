From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Tue, 10 May 2011 16:09:36 +0200
Message-ID: <20110510140936.GA39624@tuxmaker.boeblingen.de.ibm.com>
References: <20110510115013.363974020@de.ibm.com> <20110510115047.113084723@de.ibm.com> <BANLkTimUUXp5XiCtVoD+pJyQYcE_r25zyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:56851 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707Ab1EJOJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 10:09:40 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimUUXp5XiCtVoD+pJyQYcE_r25zyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2011 at 03:19:27PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> > From: Frank Blaschka <frank.blaschka@de.ibm.com>
> >
> > Set rx csum default to hw checksumming again.
> > Remove sysfs interface for rx csum (checksumming) and TSO (large_se=
nd).
> > With the new hw_features it does not work to keep the old sysfs
> > interface in parallel. Convert options.checksum_type to new hw_feat=
ures.
> [...]
> > @@ -1482,32 +1476,28 @@ static int qeth_l3_start_ipa_checksum(st
> [...]
> > - =C2=A0 =C2=A0 =C2=A0 rc =3D qeth_l3_send_checksum_command(card);
> > - =C2=A0 =C2=A0 =C2=A0 if (!rc)
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_info(&card->=
gdev->dev,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 card->dev->hw_features &=3D ~IPA_INBOUND_CHECKSUM;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 card->dev->features &=3D ~IPA_INBOUND_CHECKSUM;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 return 0;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>=20
> Should be NETIF_F_RXCSUM probably.
>
Thx for reviewing the patch, yes should be NETIF_F_RXCSUM
=20
> Don't modify hw_features. Limit currently available features in
> ndo_fix_features callback instead when checksumming is (temporarily)
> unavailable.
>
We have a recovery operation in our driver. What can we do in case this
recovery detects the checksumming is not available anymore (during runt=
ime
of the device). ndo_fix_features callback does not come into play at th=
is time.
How can we solve this?

> [...]
> > =C2=A0static int qeth_l3_set_features(struct net_device *dev, u32 f=
eatures)
> > =C2=A0{
> > - =C2=A0 =C2=A0 =C2=A0 enum qeth_checksum_types csum_type;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct qeth_card *card =3D dev->ml_priv;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 changed =3D dev->features ^ features=
;
> > + =C2=A0 =C2=A0 =C2=A0 int on;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(changed & NETIF_F_RXCSUM))
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (features & NETIF_F_RXCSUM)
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 csum_type =3D HW=
_CHECKSUMMING;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 on =3D 1;
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 csum_type =3D SW=
_CHECKSUMMING;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 on =3D 0;
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->features =3D features ^ NETIF_F_RXC=
SUM;
> > - =C2=A0 =C2=A0 =C2=A0 return qeth_l3_set_rx_csum(card, csum_type);
> > + =C2=A0 =C2=A0 =C2=A0 return qeth_l3_set_rx_csum(card, on);
> > =C2=A0}
>=20
> Since you removed dev->features update from qeth_l3_set_rx_csum(), yo=
u
> should also modify this code to match. On exit from ndo_fix_features,
> dev->features should reflect what is currently set, even if part of
Do you mean qeth_l3_set_rx_csum should set dev->features dependent of
the result of the checksum hardware operation?
> the request failed.
>=20
> > =C2=A0static const struct ethtool_ops qeth_l3_ethtool_ops =3D {
> > @@ -3342,6 +3326,12 @@ static int qeth_l3_setup_netdev(struct q
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0card->dev->dev_id =3D card->i=
nfo.unique_id &
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0xffff;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (!card->info.guestlan) {
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 card->dev->hw_features =3D NETIF=
_F_SG |
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETI=
=46_F_RXCSUM | NETIF_F_IP_CSUM |
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETI=
=46_F_TSO;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 card->dev->features =3D NETIF_F_=
RXCSUM;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 }
>=20
> All features except RXCSUM will be disabled by default. Is that the i=
ntent here?
Yes, it is.

>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
