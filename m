From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t type
Date: Thu, 23 Jun 2011 13:38:51 -0700
Message-ID: <BANLkTimig_Fgi9DFOs4u_R1hAYLxfaa0cJXwO_rQ4P6bkm+-QA@mail.gmail.com>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl> <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
 <1308604618.2701.189.camel@bwh-desktop> <BANLkTi=RB1MSR=c6GhXr4bsrPtFJVZnaZ8ZLCN=o339S_BE7iw@mail.gmail.com>
 <1308852228.2712.5.camel@bwh-desktop> <BANLkTikTquu8jr7U-8s=8kQcqT86Ji1MqnSKug+3zQdgsVKxKA@mail.gmail.com>
 <1308855335.2712.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:29326 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933927Ab1FWUjQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 16:39:16 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p5NKdEY0004194
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 13:39:14 -0700
Received: from bwz15 (bwz15.prod.google.com [10.188.26.15])
	by wpaz21.hot.corp.google.com with ESMTP id p5NKdB6Z010050
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 13:39:12 -0700
Received: by bwz15 with SMTP id 15so2961651bwz.33
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 13:39:11 -0700 (PDT)
In-Reply-To: <1308855335.2712.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2011 at 11:55 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2011-06-23 at 11:21 -0700, Mahesh Bandewar wrote:
>> On Thu, Jun 23, 2011 at 11:03 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> > On Thu, 2011-06-23 at 10:50 -0700, Mahesh Bandewar wrote:
>> >> On Mon, Jun 20, 2011 at 2:16 PM, Ben Hutchings
>> >> <bhutchings@solarflare.com> wrote:
>> >> >
>> >> > On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wr=
ote:
>> >> > [...]
>> >> > > @@ -125,19 +131,26 @@ static int ethtool_set_features(struct =
net_device *dev, void __user *useraddr)
>> >> > > =C2=A0 =C2=A0 =C2=A0 if (copy_from_user(features, useraddr, s=
izeof(features)))
>> >> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EFAU=
LT;
>> >> > >
>> >> > > - =C2=A0 =C2=A0 if (features[0].valid & ~NETIF_F_ETHTOOL_BITS=
)
>> >> > > + =C2=A0 =C2=A0 /* I wonder if the compiler will be smart eno=
ugh to loop-unroll
>> >> > > + =C2=A0 =C2=A0 =C2=A0* and optimize this... (no worries if n=
ot) --mq */
>> >> > > + =C2=A0 =C2=A0 for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0=
; ) {
>> >> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 valid =3D (valid =
<< 32)|features[i].valid;
>> >> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted =3D (wante=
d << 32)|features[i].requested;
>> >> > > + =C2=A0 =C2=A0 }
>> >> > [...]
>> >> >
>> >> > I don't know (or care) about optimisation of this, but I would =
expect
>> >> > gcc to complain about shifting a 32-bit value by 32 bits. =C2=A0=
I suggest you
>> >> > write this as:
>> >> >
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < ETHTOOL_DEV_FEATUR=
E_WORDS; ++i) {
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0valid |=3D=
 (netdev_features_t)features[i].valid << 32 *i;
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wanted |=
=3D (netdev_features_t)features[i].requested << 32 *i;
>> >>
>> >> It's a valid point but this type of typecast or similar usage wou=
ld
>> >> imply that netdev_feature_t is an int of XXX bits. That's not opa=
que
>> >> and would hinder the way you can abstract the feature type.
>> >
>> > Yes, ethtool_{get,set}_features() will have to be changed if and w=
hen
>> > the representation of netdev_features_t is changed significantly. =
=C2=A0I
>> > don't think there's any way of avoiding that and I don't think it =
really
>> > matters.
>> >
>> Well, if you have a conversion routine that converts (whatever the)
>> netdev_type_t type is to the ethtool representation (array of u32 fo=
r
>> example). So the changes would have to be done in that conversion
>> routine only and not get/set_features() ethtool methods as such.
>
> These are precisely those conversion routines, because there is no ot=
her
> place that needs to deal with the ethtool representation...
>
Oh, I was considering get/set_features ethtool methods as APIs  to
manipulate certain bits from user-space into kernel space. I was
disassociating features bit representation as a separate aspect and
(of course) the conversion. So depending on the type selection you may
or may not need these conversion routines.

--mahesh..

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
