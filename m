From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [RFT PATCH 7/9] ethtool: prepare for larger netdev_features_t type
Date: Thu, 23 Jun 2011 10:50:59 -0700
Message-ID: <BANLkTi=RB1MSR=c6GhXr4bsrPtFJVZnaZ8ZLCN=o339S_BE7iw@mail.gmail.com>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl> <852a74b9068b3be7413a65023f6096f142dfd805.1308596963.git.mirq-linux@rere.qmqm.pl>
 <1308604618.2701.189.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:60691 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933126Ab1FWRvV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 13:51:21 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p5NHpKpQ013171
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 10:51:20 -0700
Received: from bwz1 (bwz1.prod.google.com [10.188.26.1])
	by wpaz1.hot.corp.google.com with ESMTP id p5NHp3cS021980
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 10:51:19 -0700
Received: by bwz1 with SMTP id 1so2950871bwz.22
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2011 10:51:19 -0700 (PDT)
In-Reply-To: <1308604618.2701.189.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 20, 2011 at 2:16 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>
> On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> [...]
> > @@ -125,19 +131,26 @@ static int ethtool_set_features(struct net_de=
vice *dev, void __user *useraddr)
> > =C2=A0 =C2=A0 =C2=A0 if (copy_from_user(features, useraddr, sizeof(=
features)))
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EFAULT;
> >
> > - =C2=A0 =C2=A0 if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
> > + =C2=A0 =C2=A0 /* I wonder if the compiler will be smart enough to=
 loop-unroll
> > + =C2=A0 =C2=A0 =C2=A0* and optimize this... (no worries if not) --=
mq */
> > + =C2=A0 =C2=A0 for (i =3D ETHTOOL_DEV_FEATURE_WORDS; i-- > 0; ) {
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 valid =3D (valid << 32)=
|features[i].valid;
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wanted =3D (wanted << 3=
2)|features[i].requested;
> > + =C2=A0 =C2=A0 }
> [...]
>
> I don't know (or care) about optimisation of this, but I would expect
> gcc to complain about shifting a 32-bit value by 32 bits. =C2=A0I sug=
gest you
> write this as:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORD=
S; ++i) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0valid |=3D (ne=
tdev_features_t)features[i].valid << 32 *i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wanted |=3D (n=
etdev_features_t)features[i].requested << 32 *i;

It's a valid point but this type of typecast or similar usage would
imply that netdev_feature_t is an int of XXX bits. That's not opaque
and would hinder the way you can abstract the feature type.

--mahesh..
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> Ben.
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
