From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t
 type
Date: Thu, 23 Jun 2011 19:55:35 +0100
Message-ID: <1308855335.2712.15.camel@bwh-desktop>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	 <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
	 <1308604618.2701.189.camel@bwh-desktop>
	 <BANLkTi=RB1MSR=c6GhXr4bsrPtFJVZnaZ8ZLCN=o339S_BE7iw@mail.gmail.com>
	 <1308852228.2712.5.camel@bwh-desktop>
	 <BANLkTikTquu8jr7U-8s=8kQcqT86Ji1MqnSKug+3zQdgsVKxKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13887 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759844Ab1FWSzi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:55:38 -0400
In-Reply-To: <BANLkTikTquu8jr7U-8s=8kQcqT86Ji1MqnSKug+3zQdgsVKxKA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-06-23 at 11:21 -0700, Mahesh Bandewar wrote:
> On Thu, Jun 23, 2011 at 11:03 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Thu, 2011-06-23 at 10:50 -0700, Mahesh Bandewar wrote:
> >> On Mon, Jun 20, 2011 at 2:16 PM, Ben Hutchings
> >> <bhutchings@solarflare.com> wrote:
> >> >
> >> > On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> >> > [...]
> >> > > @@ -125,19 +131,26 @@ static int ethtool_set_features(struct n=
et_device *dev, void __user *useraddr)
> >> > >       if (copy_from_user(features, useraddr, sizeof(features))=
)
> >> > >               return -EFAULT;
> >> > >
> >> > > -     if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
> >> > > +     /* I wonder if the compiler will be smart enough to loop=
-unroll
> >> > > +      * and optimize this... (no worries if not) --mq */
> >> > > +     for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0; ) {
> >> > > +             valid =3D (valid << 32)|features[i].valid;
> >> > > +             wanted =3D (wanted << 32)|features[i].requested;
> >> > > +     }
> >> > [...]
> >> >
> >> > I don't know (or care) about optimisation of this, but I would e=
xpect
> >> > gcc to complain about shifting a 32-bit value by 32 bits.  I sug=
gest you
> >> > write this as:
> >> >
> >> >        for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORDS; ++i) {
> >> >                valid |=3D (netdev_features_t)features[i].valid <=
< 32 *i;
> >> >                wanted |=3D (netdev_features_t)features[i].reques=
ted << 32 *i;
> >>
> >> It's a valid point but this type of typecast or similar usage woul=
d
> >> imply that netdev_feature_t is an int of XXX bits. That's not opaq=
ue
> >> and would hinder the way you can abstract the feature type.
> >
> > Yes, ethtool_{get,set}_features() will have to be changed if and wh=
en
> > the representation of netdev_features_t is changed significantly.  =
I
> > don't think there's any way of avoiding that and I don't think it r=
eally
> > matters.
> >
> Well, if you have a conversion routine that converts (whatever the)
> netdev_type_t type is to the ethtool representation (array of u32 for
> example). So the changes would have to be done in that conversion
> routine only and not get/set_features() ethtool methods as such.

These are precisely those conversion routines, because there is no othe=
r
place that needs to deal with the ethtool representation...

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

