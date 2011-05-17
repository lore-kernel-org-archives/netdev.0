From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Tue, 17 May 2011 17:54:28 +0300
Message-ID: <20110517145428.GA1472@redhat.com>
References: <20110516094821.GA9427@redhat.com>
 <20110516104309.GA3534@gondor.apana.org.au>
 <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au>
 <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au>
 <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
 <20110517081954.A227013A6A@rere.qmqm.pl>
 <20110517142943.GA926@redhat.com>
 <20110517144635.GA22878@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388Ab1EQOya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 10:54:30 -0400
Content-Disposition: inline
In-Reply-To: <20110517144635.GA22878@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 04:46:35PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Tue, May 17, 2011 at 05:29:43PM +0300, Michael S. Tsirkin wrote:
> > On Tue, May 17, 2011 at 10:19:54AM +0200, Micha=C5=82 Miros=C5=82aw=
 wrote:
> > > tun->set_features are meant to limit not force the features.
> > >=20
> > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl=
>
> > > ---
> > >  drivers/net/tun.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >=20
> > > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > > index 74e9405..f77c6d0 100644
> > > --- a/drivers/net/tun.c
> > > +++ b/drivers/net/tun.c
> > > @@ -458,7 +458,7 @@ static u32 tun_net_fix_features(struct net_de=
vice *dev, u32 features)
> > >  {
> > >  	struct tun_struct *tun =3D netdev_priv(dev);
> > > =20
> > > -	return (features & tun->set_features) | (features & ~TUN_USER_F=
EATURES);
> > > +	return features & (tun->set_features | ~TUN_USER_FEATURES);
> > >  }
> > > =20
> > >  static const struct net_device_ops tun_netdev_ops =3D {
> > > --=20
> > > 1.7.2.5
> >=20
> > One thing that this will do though: previously, if
> > ethtool disables offloads, then an application enables
> > them, the application will have the last say.
> > With this patch, the most conservative approach wins.
> > Right?
>=20
> Exactly.
>=20
> On device creation, wanted_features default to all offloads
> enabled, so unless an admin changes the flags, the application contro=
ls
> what is enabled. This matters only when using persistent tun/tap and
> admin and user are two different people. If the admin is using queues
> and doesn't want to handle e.g. TSO packets (I'm not sure if they are
> properly accounted in all queuing disciplines), then the feature shou=
ld
> not be enabled by user.
>=20
> > If we want to have the existing behaviour
> > I think the following would do this (untested). What do you think?
> >=20
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 74e9405..1d6c7bc 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -1199,6 +1199,8 @@ static int set_offload(struct tun_struct *tun=
, unsigned long arg)
> >  		return -EINVAL;
> > =20
> >  	tun->set_features =3D features;
> > +	tun->dev->features &=3D TUN_USER_FEATURES;
> > +	tun->dev->features |=3D (features & TUN_USER_FEATURES);
> >  	netdev_update_features(tun->dev);
>=20
> tun->dev->features will be recalculated by netdev_update_features()
> anyway. For this to work as you described it would need to alter
> wanted_features. I don't like the idea that something other than one
> of ethtool_ops is changing this field, as it then becomes something
> else that what the admin wants (even if that is not what he gets).
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

Yes, with virtualization admin and the app are two different people
usually.  The device doesn't have to be persistent though I think -
what limits this to persistent devices?
I agree this behaviour seems more consistent, I just hope this change
does not break any setups.

--=20
MST
