From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 02 Sep 2010 11:31:49 +0200
Message-ID: <1283419909.2454.137.camel@edumazet-laptop>
References: <20100830.095012.233695092.davem@davemloft.net>
	 <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local>
	 <20100901.145151.93454549.davem@davemloft.net>
	 <20100902083327.GA6246@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36382 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab0IBJby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 05:31:54 -0400
Received: by wwj40 with SMTP id 40so548943wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 02:31:53 -0700 (PDT)
In-Reply-To: <20100902083327.GA6246@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 08:33 +0000, Jarek Poplawski a =C3=A9=
crit :
> On Wed, Sep 01, 2010 at 02:51:51PM -0700, David Miller wrote:
> > The only scenerio you can guarentee that all packets for a given
> > flow key will be treated the same is the one where the input device
> > is the same as well.
> >=20
> > When there is a single napi --> device mapping, it works, but witho=
ut
> > that invariant it doesn't.
>=20
> Do you mean a single napi can't be used eg. for vlan_gro and napi_gro=
?
> (napi_gro handles flows for skb->dev different from napi->dev or I
> miss something?)
>=20

Same napi can be used both for vlan tagged trafic and "non tagged
trafic".

vlan_gro_common() does the right thing, when initializing skb->dev to
the vlan device, before doing the GRO loop.

So if we receive two packets on same ethernet device, two different
vlans, vlan_gro_common() automatically say they are not part of the sam=
e
flow, even if upper layers would say "it's ok for these two packets to
merge". Of course, we wont ask upper layers what they think :)

So we must keep the test against skb->dev, because of vlans,

diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;

(both in vlan_gro_common() and __napi_gro_receive())


