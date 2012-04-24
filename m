From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 10:49:30 +0200
Message-ID: <1335257370.5205.129.camel@edumazet-glaptop>
References: <1335173934.3293.84.camel@edumazet-glaptop>
	 <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop>
	 <20120423.160149.1515408777176168288.davem@davemloft.net>
	 <1335213446.5205.65.camel@edumazet-glaptop>
	 <1335234012.5205.97.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	Netdev <netdev@vger.kernel.org>, therbert@google.com,
	ncardwell@google.com, maze@google.com,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53367 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452Ab2DXItf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:49:35 -0400
Received: by bkuw12 with SMTP id w12so215343bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 01:49:34 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 11:01 +0300, Ilpo J=C3=A4rvinen wrote:
> On Tue, 24 Apr 2012, Eric Dumazet wrote:
>=20
> > On Mon, 2012-04-23 at 22:37 +0200, Eric Dumazet wrote:
> >=20
> > > We could try to coalesce ACKs before backlogging them. I'll work =
on
> > > this.
> >=20
> > I did an experiment, and found a basic coalescing was not working i=
n
> > case of packet loss and SACK storm.
>=20
> ...That case might also have some performance issues at the receiver =
end=20
> when a hole is filled and TCP pushes stuff higher up.
>=20
> > Doing a smart coalescing in this case sounds really complex.
>=20
> Why's that? ...We'd compare options 32-bit at a time (like you alread=
y do=20
> anyway) and if we find difference we check the previous bits to valid=
ate=20
> it's a SACK option (the changing one should be in the first start-end=
=20
> pair). ...As long as there's no hole in every other segment we'd be=20
> winners I think.
>=20
> > Should we really continue this way ?=20
>=20
> Why not, but wouldn't it be nicer to coalesce them already in GRO bel=
ow=20
> with an assumption that GRO is likely to find some "mss" equivivalent=
=20
> which tells the gap between consecutive ACK (or even SACK) seqnos?
>=20
> I've been long thinking that it would be nice to run offloading for A=
CKs=20
> too, and possibly even for SACKs, in both ends, although that might n=
ot be=20
> possible with other than GSO/GRO, at least atm.
>=20
>=20


GRO doesnt coalesce pure acks, thats part of GRO contract.

By the way, I find GRO less and less attractive, if we have fragged skb=
s
provided by drivers, we can do the GRO almost for free in tcp stack,
instead of very complex/duplicated logic before tcp stack.

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dcomm=
it;h=3D1402d366019fedaa2b024f2bac06b7cc9a8782e1

Doing this coalescing in tcp stack solves many problems GRO is unable t=
o
address, like reordering...
