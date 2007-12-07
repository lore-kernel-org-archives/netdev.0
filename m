From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] TCP illinois max rtt aging
Date: Fri, 07 Dec 2007 04:41:50 -0800 (PST)
Message-ID: <20071207.044150.02925935.davem@davemloft.net>
References: <Pine.LNX.4.64.0712041031110.18529@kivilampi-30.cs.helsinki.fi>
	<aa7d2c6d0712061927g2e6f1679o8b05f76d723c0c76@mail.gmail.com>
	<Pine.LNX.4.64.0712071254070.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lachlan.andrew@gmail.com, netdev@vger.kernel.org,
	quetchen@caltech.edu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753429AbXLGMlv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 07:41:51 -0500
In-Reply-To: <Pine.LNX.4.64.0712071254070.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 7 Dec 2007 13:05:46 +0200 (EET)

> I guess if you get a large cumulative ACK, the amount of processing i=
s=20
> still overwhelming (added DaveM if he has some idea how to combat it)=
=2E
>=20
> Even a simple scenario (this isn't anything fancy at all, will occur =
all=20
> the time): Just one loss =3D> rest skbs grow one by one into a single=
=20
> very large SACK block (and we do that efficiently for sure) =3D> then=
 the=20
> fast retransmit gets delivered and a cumulative ACK for whole orig_wi=
ndow=20
> arrives =3D> clean_rtx_queue has to do a lot of processing. In this c=
ase we=20
> could optimize RB-tree cleanup away (by just blanking it all) but sti=
ll=20
> getting rid of all those skbs is going to take a larger moment than I=
'd=20
> like to see.
>=20
> That tree blanking could be extended to cover anything which ACK more=
 than=20
> half of the tree by just replacing the root (and dealing with potenti=
al=20
> recolorization of the root).

Yes, it's the classic problem.  But it ought to be at least
partially masked when TSO is in use, because we'll only process
a handful of SKBs.  The more effectively TSO batches, the
less work clean_rtx_queue() will do.

When not doing TSO the behavior is super-stupid, we bump reference
counts on the same page multiple times while running over the SKBs
since consequetive SKBs cover data in different spans of the same
page.

The core issue is that we have a poorly behaving data container,
and therefore that's obviously what we need to change.

Conceptually what we probably need to do is seperate the data
maintainence from the SKB objects themselves.  There is a blob
that maintains the paged data state for everything in the
retransmit queue.  SKBs are built and get the page pointers
but don't actually grab references to the pages, the blob
does that and it keeps track of how many SKB references to each
page there are, non-atomically.

The hardest part is dealing with the page lifetime issues.
Unfortunately, when we trim the rtx queue, references to the clones
can still exist in the driver output path.  It's a difficult problem
to overcome in fact, so in the end my suggestion above might not
even be workable.

> No idea about what it could do, haven't yet looked web100, I was plan=
ning=20
> at some point of time...

Web100 just provides statistics and other kinds of connection data
to userspace, all the actual algorithm etc. modifications have been
merged upstream and yanked out of the web100 patch.  I was looking
at it the other night and it's frankly totally uninteresting these
days :-)
