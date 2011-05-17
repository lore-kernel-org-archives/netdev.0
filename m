From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Tue, 17 May 2011 16:46:35 +0200
Message-ID: <20110517144635.GA22878@rere.qmqm.pl>
References: <20110516093822.GA2779@gondor.apana.org.au>
 <20110516094821.GA9427@redhat.com>
 <20110516104309.GA3534@gondor.apana.org.au>
 <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au>
 <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au>
 <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
 <20110517081954.A227013A6A@rere.qmqm.pl>
 <20110517142943.GA926@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:32882 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755105Ab1EQOqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 10:46:39 -0400
Content-Disposition: inline
In-Reply-To: <20110517142943.GA926@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 05:29:43PM +0300, Michael S. Tsirkin wrote:
> On Tue, May 17, 2011 at 10:19:54AM +0200, Micha=B3 Miros=B3aw wrote:
> > tun->set_features are meant to limit not force the features.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  drivers/net/tun.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 74e9405..f77c6d0 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -458,7 +458,7 @@ static u32 tun_net_fix_features(struct net_devi=
ce *dev, u32 features)
> >  {
> >  	struct tun_struct *tun =3D netdev_priv(dev);
> > =20
> > -	return (features & tun->set_features) | (features & ~TUN_USER_FEA=
TURES);
> > +	return features & (tun->set_features | ~TUN_USER_FEATURES);
> >  }
> > =20
> >  static const struct net_device_ops tun_netdev_ops =3D {
> > --=20
> > 1.7.2.5
>=20
> One thing that this will do though: previously, if
> ethtool disables offloads, then an application enables
> them, the application will have the last say.
> With this patch, the most conservative approach wins.
> Right?

Exactly.

On device creation, wanted_features default to all offloads
enabled, so unless an admin changes the flags, the application controls
what is enabled. This matters only when using persistent tun/tap and
admin and user are two different people. If the admin is using queues
and doesn't want to handle e.g. TSO packets (I'm not sure if they are
properly accounted in all queuing disciplines), then the feature should
not be enabled by user.

> If we want to have the existing behaviour
> I think the following would do this (untested). What do you think?
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 74e9405..1d6c7bc 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1199,6 +1199,8 @@ static int set_offload(struct tun_struct *tun, =
unsigned long arg)
>  		return -EINVAL;
> =20
>  	tun->set_features =3D features;
> +	tun->dev->features &=3D TUN_USER_FEATURES;
> +	tun->dev->features |=3D (features & TUN_USER_FEATURES);
>  	netdev_update_features(tun->dev);

tun->dev->features will be recalculated by netdev_update_features()
anyway. For this to work as you described it would need to alter
wanted_features. I don't like the idea that something other than one
of ethtool_ops is changing this field, as it then becomes something
else that what the admin wants (even if that is not what he gets).

Best Regards,
Micha=B3 Miros=B3aw
