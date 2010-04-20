From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 20 Apr 2010 22:57:23 +0200
Message-ID: <1271797043.7895.320.camel@edumazet-laptop>
References: <20100420174401.GB1334@midget.suse.cz>
	 <1271786247.7895.130.camel@edumazet-laptop>
	 <20100420204939.GA15354@smudla-wifi.bakulak.kosire.czf>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:57696 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754666Ab0DTU5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 16:57:32 -0400
Received: by bwz25 with SMTP id 25so7298459bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 13:57:30 -0700 (PDT)
In-Reply-To: <20100420204939.GA15354@smudla-wifi.bakulak.kosire.czf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 avril 2010 =C3=A0 22:49 +0200, Jiri Bohac a =C3=A9crit :
> On Tue, Apr 20, 2010 at 07:57:27PM +0200, Eric Dumazet wrote:
> > Le mardi 20 avril 2010 =C3=A0 19:44 +0200, Jiri Bohac a =C3=A9crit =
:
> > > --- a/net/ipv6/addrconf.c	2010-04-17 00:12:32.000000000 +0200
> > > +++ b/net/ipv6/addrconf.c	2010-04-20 19:07:35.000000000 +0200
> > > @@ -3974,8 +3974,7 @@ static void __ipv6_ifa_notify(int event,
> > >  			addrconf_leave_anycast(ifp);
> > >  		addrconf_leave_solict(ifp->idev, &ifp->addr);
> > >  		dst_hold(&ifp->rt->u.dst);
> > > -		if (ip6_del_rt(ifp->rt))
> > > -			dst_free(&ifp->rt->u.dst);
> > > +		ip6_del_rt(ifp->rt);
> > >  		break;
> > >  	}
> > >  }
> > >=20
> >=20
> >=20
> > I dont understand the problem Jiri.
> >=20
> > We just did dst_hold(&ifp->rt->u.dst), so if ip6_del_rt() fails we =
must
> > dst_free(), or we leak a refcount.
>=20
> Well, no ... dst_free() does not decrement the refcount.
> The "opposite" of dst_hold() is dst_release(). And it does not
> automatically call dst_free() when the refcount drops to 0.
> dst_free() needs to be called explicitly and it apparently
> expects the caller to ensure that two dst_free()s won't be called
> simultaneously. But my bonding example shows this is not the
> case.
>=20
>=20

Ah yes you're right

Maybe ask Stephen ?

commit 93fa159abe50d3c55c7f83622d3f5c09b6e06f4b
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Mon Apr 12 05:41:31 2010 +0000

    IPv6: keep route for tentative address
   =20
    Recent changes preserve IPv6 address when link goes down (good).
    But would cause address to point to dead dst entry (bad).
    The simplest fix is to just not delete route if address is
    being held for later use.
   =20
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1b00bfe..a9913d2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4047,7 +4047,8 @@ static void __ipv6_ifa_notify(int event, struct
inet6_ifaddr *ifp)
                        addrconf_leave_anycast(ifp);
                addrconf_leave_solict(ifp->idev, &ifp->addr);
                dst_hold(&ifp->rt->u.dst);
-               if (ip6_del_rt(ifp->rt))
+
+               if (ifp->dead && ip6_del_rt(ifp->rt))
                        dst_free(&ifp->rt->u.dst);
                break;
        }


