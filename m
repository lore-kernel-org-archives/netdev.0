From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 11:50:50 +0200
Message-ID: <20080731095050.GD23814@xi.wantstofly.org>
References: <20080730235004.GC21999@xi.wantstofly.org> <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org> <20080730.181047.39922732.davem@davemloft.net> <Pine.LNX.4.64.0807311010250.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, akarkare@marvell.com,
	nico@cam.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:59104 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYGaJuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 05:50:52 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807311010250.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 10:34:13AM +0300, Ilpo J=E4rvinen wrote:

> > > The hacky patch below (on top of 2.6.27-rc1 + stubbing out the
> > > sk_can_gso() check) reduces the 1 GiB 1000 Mb/s sendfile test fro=
m:
> >  ...
> > > I.e. dramatic CPU time improvements, and some overall speedup as =
well.
> > >=20
> > > I wonder if something like this can be done in a less hacky fashi=
on --
> > > the hard part I guess is deciding when to keep coalescing (to red=
uce
> > > CPU overhead) vs. when to push out what has been coalesced so far=
 (in
> > > order to keep the pipe filled), and I'm not sure I have good idea=
s
> > > about how to make that decision.
> >=20
> > Interesting, I'll take a closer look at this.
> >=20
> > Actually your patch is less of a surprise, because one of the issue=
s I
> > had to surmount constantly when rewriting the TSO output path was t=
he
> > implicit conflict between TSO deferral (to accumulate segments) and
> > the nagle logic.
>=20
> I think your statement makes very little sense to me (though I had to=
=20
> lookup the meaning of surmount but that seems not so significant=20
> anyway)... They both work into the same direction, ie., to delay send=
ing=20
> to prevent excessive processing of small bits, but the region of oper=
ation=20
> shouldn't overlap (nagle works with <mss, and tso deferring logic=20
> basically begins from where the nagle ends)?
>=20
> It seems to me that this not about conflict between TSO deferring and=
=20
> nagle sub-mss logic at all (perhaps there wasn't as direct relation t=
o=20
> this issue as I read...?) AFAICT, the change only makes (!nonagle &&=20
> tp->packets_out && tcp_minshall_check(tp)) test in tcp_nagle_check mo=
re=20
> likely to occur (and result in false), ie., basically we end up using=
=20
> nagle test also to prevent sending of >=3D mss skbs, besides the usua=
l=20
> functionality which is to prevent sending in case of < mss sized ones=
=2E=20
> ...Which seems just an extension to what we checked for in=20
> tcp_tso_should_defer().

I wanted a way to get larger GSO segments, and the idea was to rig
the nagle check to consider sub-N*mss frames as small frames and not
let more than one of them into the pipe at any given time.  I don't
know whether the change I made accomplishes exactly that, but it did
end up giving me larger GSO segments, which was the goal.

It makes the GSO segment size distribution pretty chaotic, though:

10k seg: 2:851 3:430 4:3385 5:330 6:3611 7:382 8:949 9:18 10:43 11:1
10k size: 5:851 8:430 11:3385 14:330 17:3611 19:382 22:949 25:18 28:43 =
31:1
10k seg: 2:1952 3:410 4:2855 5:340 6:2956 7:356 8:1059 9:24 10:48
10k size: 5:1952 8:410 11:2855 14:340 17:2956 19:356 22:1059 25:24 28:4=
8
10k seg: 2:1036 3:569 4:4824 5:369 6:2241 7:251 8:643 9:20 10:46 11:1
10k size: 5:1036 8:569 11:4824 14:369 17:2241 19:251 22:643 25:20 28:46=
 31:1
10k seg: 2:1270 3:408 4:3686 5:350 6:2910 7:319 8:988 9:15 10:54
10k size: 5:1270 8:408 11:3686 14:350 17:2910 19:319 22:988 25:15 28:54
10k seg: 2:870 3:407 4:4211 5:380 6:3392 7:286 8:389 9:20 10:45
10k size: 5:870 8:407 11:4211 14:380 17:3392 19:286 22:389 25:20 28:45
10k seg: 2:1217 3:411 4:3542 5:315 6:3263 7:348 8:832 9:23 10:48 11:1
10k size: 5:1217 8:411 11:3542 14:315 17:3263 19:348 22:832 25:23 28:48=
 31:1

("10k seg" numbers are the distribution of gso_segs for 10k skbuffs,
and "10k size" are the distribution of skb->len >> 9 for 10k skbuffs.)
