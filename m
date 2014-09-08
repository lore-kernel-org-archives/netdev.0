From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: refresh rt6i_genid in ip6_pol_route()
Date: Mon, 08 Sep 2014 03:28:12 -0700
Message-ID: <1410172092.11872.85.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410149905.11872.73.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140907.212742.893555292268057160.davem@davemloft.net>
		 <1410151434.11872.82.camel@edumazet-glaptop2.roam.corp.google.com>
		 <20140907.215943.213418445039957641.davem@davemloft.net>
	 <1410152829.11872.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <540D64C2.9050000@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:65319 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbaIHK2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 06:28:16 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so2144182pab.40
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 03:28:15 -0700 (PDT)
In-Reply-To: <540D64C2.9050000@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 10:11 +0200, Nicolas Dichtel wrote:
> Le 08/09/2014 07:07, Eric Dumazet a =C3=A9crit :
> > On Sun, 2014-09-07 at 21:59 -0700, David Miller wrote:
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Sun, 07 Sep 2014 21:43:54 -0700
> >>
> >>> On Sun, 2014-09-07 at 21:27 -0700, David Miller wrote:
> >>>> From: Eric Dumazet <eric.dumazet@gmail.com>
> >>>> Date: Sun, 07 Sep 2014 21:18:25 -0700
> >>>>
> >>>>> On Sun, 2014-09-07 at 15:54 -0700, David Miller wrote:
> >>>>>
> >>>>>> This might be broken.
> >>>>>>
> >>>>>> We are dealing here with persistent entries in the ipv6 routin=
e trie.
> >>>>>>
> >>>>>> If you just bump the genid on the next person to look it up, o=
ther
> >>>>>> sockets and cached entities might not have validated the route=
 yet,
> >>>>>> and now will falsely see the route as valid.  We have to ensur=
e that
> >>>>>> they too drop this route and perform a relookup.
> >>>>>
> >>>>> I am confused, I thought it was the role of the cookie.
> >>>>>
> >>>>> (Ie socket has to store its own cookie to be able to validate a=
 route)
> >>>>>
> >>>>> Before 6f3118b571b8 patch, how was this done anyway ?
> >>>>>
> >>>>> If persistent routes cannot refresh the genid, then they are us=
eless ?
> >>>>
> >>>> I just speak about the genid aspect.
> >>>>
> >>>> I understand that cookie (via node->fn_sernum) invalidates the p=
ath
> >>>> in the fib_trie, but the genid protects against other circumstan=
ces
> >>>> (matching IPSEC rule, f.e.)
> >>>>
> >>>> You have to make sure all other sockets did a full route lookup
> >>>> (including IPSEC) before you can safely adjust the genid.
> >>>>
> >>>> I could be wrong, recheck my analysis please :-)
> >>>
> >>> So this whole genid protection can not work, unless we make sure =
a
> >>> socket cannot share a route with another socket.
> >>>
> >>> This means we have to clone all routes.
> >>
> >> I'm willing to revert the change in question if you think that's t=
he
> >> sanest way forward.
> >>
> >> The bug fix for more obscure use cases (IPSEC) if pointless if it
> >> breaks more common things (TCP input route caching).
> >
> > Lets wait for Nicolas and/or Hannes input, they might have some ide=
as...
>=20
> The initial problem was in SCTP. Here is the thread after the v1 patc=
h:
> http://patchwork.ozlabs.org/patch/182235/
>=20
> Before the patch, SCTP stored the IPv6 route in its cache and if an I=
Psec
> rules was inserted after that operation, SCTP never invalidated the c=
ached
> route to use a new xfrm route.

This thread mentions output route.

The problem I currently have with IPv6 early demux is for input routes.
