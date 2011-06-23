From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t type
Date: Thu, 23 Jun 2011 11:21:24 -0700
Message-ID: <BANLkTikTquu8jr7U-8s=8kQcqT86Ji1MqnSKug+3zQdgsVKxKA@mail.gmail.com>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl> <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
 <1308604618.2701.189.camel@bwh-desktop> <BANLkTi=RB1MSR=c6GhXr4bsrPtFJVZnaZ8ZLCN=o339S_BE7iw@mail.gmail.com>
 <1308852228.2712.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:36626 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933189Ab1FWSWH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:22:07 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p5NILuik001090
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 11:22:06 -0700
Received: from bwz5 (bwz5.prod.google.com [10.188.26.5])
	by kpbe12.cbf.corp.google.com with ESMTP id p5NIKwTp005845
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 11:21:44 -0700
Received: by bwz5 with SMTP id 5so2193747bwz.20
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 11:21:44 -0700 (PDT)
In-Reply-To: <1308852228.2712.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2011 at 11:03 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2011-06-23 at 10:50 -0700, Mahesh Bandewar wrote:
>> On Mon, Jun 20, 2011 at 2:16 PM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>> >
>> > On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote=
:
>> > [...]
>> > > @@ -125,19 +131,26 @@ static int ethtool_set_features(struct net=
_device *dev, void __user *useraddr)
>> > > =C2=A0 =C2=A0 =C2=A0 if (copy_from_user(features, useraddr, size=
of(features)))
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EFAULT;
>> > >
>> > > - =C2=A0 =C2=A0 if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
>> > > + =C2=A0 =C2=A0 /* I wonder if the compiler will be smart enough=
 to loop-unroll
>> > > + =C2=A0 =C2=A0 =C2=A0* and optimize this... (no worries if not)=
 --mq */
>> > > + =C2=A0 =C2=A0 for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0; )=
 {
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 valid =3D (valid << =
32)|features[i].valid;
>> > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted =3D (wanted <=
< 32)|features[i].requested;
>> > > + =C2=A0 =C2=A0 }
>> > [...]
>> >
>> > I don't know (or care) about optimisation of this, but I would exp=
ect
>> > gcc to complain about shifting a 32-bit value by 32 bits. =C2=A0I =
suggest you
>> > write this as:
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < ETHTOOL_DEV_FEATURE_W=
ORDS; ++i) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0valid |=3D =
(netdev_features_t)features[i].valid << 32 *i;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wanted |=3D=
 (netdev_features_t)features[i].requested << 32 *i;
>>
>> It's a valid point but this type of typecast or similar usage would
>> imply that netdev_feature_t is an int of XXX bits. That's not opaque
>> and would hinder the way you can abstract the feature type.
>
> Yes, ethtool_{get,set}_features() will have to be changed if and when
> the representation of netdev_features_t is changed significantly. =C2=
=A0I
> don't think there's any way of avoiding that and I don't think it rea=
lly
> matters.
>
Well, if you have a conversion routine that converts (whatever the)
netdev_type_t type is to the ethtool representation (array of u32 for
example). So the changes would have to be done in that conversion
routine only and not get/set_features() ethtool methods as such.

--mahesh..

> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
