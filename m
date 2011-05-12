From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 13:10:09 +0200
Message-ID: <20110512111009.GA4176@tuxmaker.boeblingen.de.ibm.com>
References: <20110512054318.241733700@de.ibm.com> <20110512054415.435611676@de.ibm.com> <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com> <20110512072132.GA31817@tuxmaker.boeblingen.de.ibm.com> <BANLkTimAisv82ZbFb8D1AkL8vuK1V5zAXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:36814 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab1ELLKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 07:10:12 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimAisv82ZbFb8D1AkL8vuK1V5zAXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 10:12:51AM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> W dniu 12 maja 2011 09:21 u=C5=BCytkownik Frank Blaschka
> <blaschka@linux.vnet.ibm.com> napisa=C5=82:
> > On Thu, May 12, 2011 at 07:59:45AM +0200, Micha=C5=82 Miros=C5=82aw=
 wrote:
> >> 2011/5/12 =C2=A0<frank.blaschka@de.ibm.com>:
> >> > Set rx csum default to hw checksumming again.
> >> > Remove sysfs interface for rx csum (checksumming) and TSO (large=
_send).
> >> > With the new hw_features it does not work to keep the old sysfs
> >> > interface in parallel. Convert options.checksum_type to new hw_f=
eatures.
> >> [...]
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* hw may hav=
e changed during offline or recovery */
> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!qeth_is_=
supported(card, IPA_INBOUND_CHECKSUM)) {
> >> [...]
> >>
> >> This check should go to ndo_fix_features callback. If it fails the=
n
> >> just return features &~NETIF_F_RXCSUM from there ...
> >>
Ok so all I have to do to complete this is to remove
  card->dev->hw_features &=3D ~NETIF_F_RXCSUM;
from here (ndo_fix_feature has already the check)?

Since we might be in recovery it is smarter to keep the support check h=
ere so we
do not have to use try and error approach to see if capabilities have
changed. Do you aggree?

> >> > +update_feature:
> >> > + =C2=A0 =C2=A0 =C2=A0 rtnl_lock();
> >> > + =C2=A0 =C2=A0 =C2=A0 card->dev->hw_features &=3D ~NETIF_F_RXCS=
UM;
> >> > + =C2=A0 =C2=A0 =C2=A0 card->dev->features &=3D ~NETIF_F_RXCSUM;
> >> > + =C2=A0 =C2=A0 =C2=A0 netdev_update_features(card->dev);
> >> > + =C2=A0 =C2=A0 =C2=A0 rtnl_unlock();
> >>
> >> ... and then this should be just:
> >> rtnl_lock();
> >> netdev_update_features(card->dev);
> >> rtnl_unlock();
> >>
> > This code is part of the recovery, assuming the recovery detects th=
e hw
> > has lost it's rx csum capability I still don't understand how ndo_f=
ix_features
> > come into play?
>=20
> ndo_fix_features is always called before ndo_set_features to alter
> features that are to be enabled. So in this case, it should check if
> checksumming is available and remove NETIF_F_RXCSUM from the set if i=
t
> isn't. The resulting set (after further cleanup by core code) is
> passed to ndo_set_features if the features had changed. hw_features
> only control what can be requested by user.
>=20
> I assume that if the device can loose the checksumming capability
> during runtime, it can also regain it. Above solution will
> automatically reenable checksumming if its requested and the
> capability comes back.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
