From: Anders Franzen <Anders.Franzen@ericsson.com>
Subject: Re: [net-2.6 PATCH] ipv6: fix missing in6_ifa_put in addrconf
Date: Wed, 17 Nov 2010 16:20:30 +0100
Message-ID: <1290007231.2222.10.camel@seasc7941.dyn.rnd.as.sw.ericsson.se>
References: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
	 <1289889454.3364.122.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:45038 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab0KQPUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 10:20:06 -0500
In-Reply-To: <1289889454.3364.122.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I was hunting for a bug that a colleague discovered.
When we exit a network namespace, the ns was hanging with dangling
references to dev lo.

When I saw the patch below, I fetched the latest net-next from Daves
repository.

And the problem is gone. Was this really the fix, since it seems to me
that this is a fix to a recently added patch (dont remove address ....)=
=2E

Did you fix anything else in the Ipv6 addrconf w.r.g dev_hold/dev_put?

netns still have problems with slab corruption during exit though:

 Nov 17 15:00:20 p04 user.err kernel: Slab corruption: size-4096
start=3Dffff88000612a000, len=3D4096
Nov 17 15:00:20 p04 user.err kernel: 020: 6b 6b 6b 6b 6b 6b
Nov 17 15:00:20 p04 user.info kernel:  6b 6b 00 00 00 00 00 00 00
Nov 17 15:00:20 p04 user.info kernel:  00

BR
  Anders


On Tue, 2010-11-16 at 07:37 +0100, Eric Dumazet wrote:
> Le lundi 15 novembre 2010 =C3=A0 22:29 -0800, John Fastabend a =C3=A9=
crit :
> > Fix ref count bug introduced by
> >=20
> > commit 2de795707294972f6c34bae9de713e502c431296
> > Author: Lorenzo Colitti <lorenzo@google.com>
> > Date:   Wed Oct 27 18:16:49 2010 +0000
> >=20
> > ipv6: addrconf: don't remove address state on ifdown if the address
> > is being kept
> >=20
> >=20
> > Fix logic so that addrconf_ifdown() decrements the inet6_ifaddr
> > refcnt correctly with in6_ifa_put().
> >=20
> > Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > ---
> >=20
> >  net/ipv6/addrconf.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index b41ce0f..aaa3ca4 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -2754,13 +2754,13 @@ static int addrconf_ifdown(struct net_devic=
e *dev, int how)
> >  			ifa->state =3D INET6_IFADDR_STATE_DEAD;
> >  			spin_unlock_bh(&ifa->state_lock);
> > =20
> > -			if (state =3D=3D INET6_IFADDR_STATE_DEAD) {
> > -				in6_ifa_put(ifa);
> > -			} else {
> > +			if (state !=3D INET6_IFADDR_STATE_DEAD) {
> >  				__ipv6_ifa_notify(RTM_DELADDR, ifa);
> >  				atomic_notifier_call_chain(&inet6addr_chain,
> >  							   NETDEV_DOWN, ifa);
> >  			}
> > +
> > +			in6_ifa_put(ifa);
> >  			write_lock_bh(&idev->lock);
> >  		}
> >  	}
> >=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Thanks again John
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


