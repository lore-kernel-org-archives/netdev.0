From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Wed, 15 May 2013 21:44:31 -0700
Message-ID: <1368679471.4519.104.camel@edumazet-glaptop>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	 <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
	 <1368659900.4519.57.camel@edumazet-glaptop>
	 <1368660613.4519.60.camel@edumazet-glaptop>
	 <CAHo-Oozt9tmfhhFHj0o+bGfRevcZw+YD6PpHAr-U_S76AbC+2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:37455 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab3EPEoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 00:44:34 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so909704pbb.38
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 21:44:33 -0700 (PDT)
In-Reply-To: <CAHo-Oozt9tmfhhFHj0o+bGfRevcZw+YD6PpHAr-U_S76AbC+2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post on netdev.

On Wed, 2013-05-15 at 21:31 -0700, Maciej =C5=BBenczykowski wrote:
> I think it should always be possible to enable both TSO and GSO on th=
e
> bond master - regardless of what the slaves support and/or currently
> have enabled.
> At the last moment as we're passing a packet to a slave, we should
> check whether the slave will like it and if not GSO it.
> This means TSO or GSO enabled on the master can effectively almost
> force (or force emulation of) GSO on slaves.
> Even if the slaves themselves don't support GSO.

GSO is software provided in core network.

>=20
> There's a lot more room for argument with regards to the default stat=
e
> of TSO/GSO on the master.
> I would argue for default to on for both.
> One could argue that if none of the slaves support GSO or TSO then
> maybe it should default to off, but I don't buy that.
>=20
> I don't really understand the point of passing GSO/TSO up from the
> slaves to the master.
> Although the maximum size and/or number of segs for a packet probably
> needs to be propagated from TSO capable devices,
> unless one were to add a "split big GSO packet into smaller (but stil=
l
> larger than mtu) TSO packets" step as well.

We could always build GSO packets in TCP stack and if these packets lan=
d
on a non SG/TSO capable device, segment them, but it would be more
expensive than building non GSO packets at the beginning.
Its also risky because this segmentation uses GFP_ATOMIC allocations an=
d
therefore can easily fail (especially if SG is lacking)

So bonding has heuristics :=20

- If at least one slave supports TSO, then the master supports TSO=20
- If at least one slave support GSO, then the master supports GSO
=2E..

Point is : as we do have software fallback, we should allow the admin t=
o
set/unset TSO on the bonding master, regardless of slaves settings.

Depending on the netfilter/qdisc setups, an admin might know better tha=
n
the kernel heuristics.
