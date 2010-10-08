From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Fri, 8 Oct 2010 18:03:42 +0200
Message-ID: <20101008160341.GC10393@redhat.com>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
 <20101008145256.GB10393@redhat.com>
 <1286550247.2959.444.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429Ab0JHQBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 12:01:45 -0400
Content-Disposition: inline
In-Reply-To: <1286550247.2959.444.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 05:04:07PM +0200, Eric Dumazet wrote:
> Le vendredi 08 octobre 2010 =E0 16:52 +0200, Stanislaw Gruszka a =E9c=
rit :
> > On Fri, Oct 08, 2010 at 04:25:00PM +0200, Stanislaw Gruszka wrote:
> > > We have fedora bug report where driver fail to initialize after
> > > suspend/resume because of memory allocation errors:
> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D629158
> >=20
> > There is also one more thing to do regarding above. Calltraces from=
 bug
> > reports, shows that order 3 allocation fail. On arch with 4kB pages=
,
> > order 3 mean 32kB allocation. We want to alloc 16kB, but there is a=
lso
> > internal sk_buff data what make that we exceed the boundary and tak=
e
> > 32kB from allocator, getting almost 50% wastage.
> >=20
>=20
> Or its only an 1460+overhead allocation, and SLUB uses order-3 pages =
to
> satisfy 2048 bytes allocations.

Rather not, trace show failure in rtl8169_rx_fill, where we allocate rx
buffers and these are 16kB big by default.

> Switch to SLAB -> no more problem ;)

yeh, I wish to, but fedora use SLUB because of some debugging
capabilities.=20

> > To fix we can use similar method as in niu or iwlwifi drivers, allo=
c
> > pages directly form buddy allocator and attach them to skb (by
> > skb_add_rx_frag for example). I'm going to prepare such patch, but
> > I have one doubt, what happens if page size in system is bigger
> > than 16kB, should I care about such case?=20
>=20
> Seems tricky. Should we patch all drivers to do something like that ?

I think, only on these drivers which do alloc_skb(n*PAGE_SIZE).
As alternative we can be smarter in alloc_skb.

Stanislaw
>=20
>=20
>=20
