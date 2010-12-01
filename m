From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: 2.6.35 -> 2.6.36 panic when vlan and promisc with tg3
Date: Wed, 1 Dec 2010 11:17:16 +0100
Message-ID: <20101201111716.424fb771@xenia.leun.net>
References: <20101129201716.1d0257c4@xenia.leun.net>
	<4CF442FA.4070701@candelatech.com>
	<20101130095944.41b5f7b6@xenia.leun.net>
	<1291108809.2904.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv04.lahn.de ([213.239.197.57]:59173 "EHLO serv04.lahn.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623Ab0LAKS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 05:18:27 -0500
In-Reply-To: <1291108809.2904.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Nov 2010 10:20:09 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 30 novembre 2010 =E0 09:59 +0100, Michael Leun a =E9crit :
> > On Mon, 29 Nov 2010 16:19:06 -0800
> > Ben Greear <greearb@candelatech.com> wrote:
> >=20
> > > On 11/29/2010 11:17 AM, Michael Leun wrote:
> > > > UG: unable to handle kernel paging request at 01cc921c
> > > > IP: [<c034bfce>] vlan_hwaccel_do_receive+0x59/0xd0
> > > > *pdpt =3D 0000000036a2a001 *pde =3D 0000000000000000
> > > > Oops: 0002 [#1] SMP
> > > > last sysfs
> > > >
> > > > Then machine dead.
> > > >
> > > > In 2.6.35.x this did not happen (but vlans broken - cannot see
> > > > vlan tags with tcpdump),
> > >=20
> > > Try this patch:
> > >=20
> > > http://permalink.gmane.org/gmane.linux.network/176566
> > >=20
> > > It looks like this hasn't made it into stable yet?
> >=20
> > > > To reproduce:
> > > >
> > > > ip link set eth0 up
> > > > vconfig add eth0 2
> > > > ip link set eth0 promisc on
> >=20
> > It makes it better - it does not crash anymore on this commands -
> > but if you add an "tcpdump -i eth0 -n" at the end it does. So,
> > unfortunately no real solution.
> >=20
> > I guess, "dropping packet no one is interested in" (as noted in the
> > patch) does not work very well if tcpdump is actually interested?
> >=20
>=20
> Could you try with following patch instead, for net/core/dev.c=20
>=20
> (and keep the net/8021q/vlan_core.c part)
>=20
> --- net/core/dev.c.orig
> +++ net/core/dev.c
> @@ -2891,6 +2891,9 @@
>  ncls:
>  #endif
> =20
> +	if (unlikely(vlan_tx_tag_present(skb)))
> +		goto bypass;
> +
>  	/* Handle special case of bridge or macvlan */
>  	rx_handler =3D rcu_dereference(skb->dev->rx_handler);
>  	if (rx_handler) {
> @@ -2927,6 +2930,7 @@
>  		}
>  	}
> =20
> +bypass:
>  	if (pt_prev) {
>  		ret =3D pt_prev->func(skb, skb->dev, pt_prev,
> orig_dev); } else {
>=20
>=20

Yup, from what I've tested this works (and tcpdump sees broadcast
packets even for vlans not configured at the moment including vlan tag
- yipee!).

--=20
MfG,

Michael Leun

