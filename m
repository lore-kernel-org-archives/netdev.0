From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Fri, 07 Dec 2007 17:32:01 -0800 (PST)
Message-ID: <20071207.173201.95379610.davem@davemloft.net>
References: <Pine.LNX.4.64.0712071254070.18529@kivilampi-30.cs.helsinki.fi>
	<20071207.044150.02925935.davem@davemloft.net>
	<Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56280
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754062AbXLHBcE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 20:32:04 -0500
In-Reply-To: <Pine.LNX.4.64.0712071442530.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 7 Dec 2007 15:05:59 +0200 (EET)

> On Fri, 7 Dec 2007, David Miller wrote:
>=20
> > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Fri, 7 Dec 2007 13:05:46 +0200 (EET)
> >=20
> > > I guess if you get a large cumulative ACK, the amount of processi=
ng is=20
> > > still overwhelming (added DaveM if he has some idea how to combat=
 it).
> > >=20
> > > Even a simple scenario (this isn't anything fancy at all, will oc=
cur all=20
> > > the time): Just one loss =3D> rest skbs grow one by one into a si=
ngle=20
> > > very large SACK block (and we do that efficiently for sure) =3D> =
then the=20
> > > fast retransmit gets delivered and a cumulative ACK for whole ori=
g_window=20
> > > arrives =3D> clean_rtx_queue has to do a lot of processing. In th=
is case we=20
> > > could optimize RB-tree cleanup away (by just blanking it all) but=
 still=20
> > > getting rid of all those skbs is going to take a larger moment th=
an I'd=20
> > > like to see.
> > >=20
> > > That tree blanking could be extended to cover anything which ACK =
more than=20
> > > half of the tree by just replacing the root (and dealing with pot=
ential=20
> > > recolorization of the root).
> >=20
> > Yes, it's the classic problem.  But it ought to be at least
> > partially masked when TSO is in use, because we'll only process
> > a handful of SKBs.  The more effectively TSO batches, the
> > less work clean_rtx_queue() will do.
>=20
> No, that's not what is going to happen, TSO won't help at all
> because one-by-one SACKs will fragment every single one of them
> (see tcp_match_skb_to_sack) :-(. ...So we're back in non-TSO
> case, or am I missing something?

You're of course right, and it's ironic that I wrote the SACK
splitting code so I should have known this :-)

A possible approach just occurred to me wherein we maintain
the SACK state external to the SKBs so that we don't need to
mess with them at all.

That would allow us to eliminate the TSO splitting but it would
not remove the general problem of clean_rtx_queue()'s overhead.

I'll try to give some thought to this over the weekend.
