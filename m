From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Fri, 08 Oct 2010 18:27:47 +0200
Message-ID: <1286555267.2959.594.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	 <20101008145256.GB10393@redhat.com>
	 <1286550247.2959.444.camel@edumazet-laptop>
	 <20101008160341.GC10393@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50309 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427Ab0JHQ1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:27:53 -0400
Received: by wwj40 with SMTP id 40so1416952wwj.1
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 09:27:52 -0700 (PDT)
In-Reply-To: <20101008160341.GC10393@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 18:03 +0200, Stanislaw Gruszka a =C3=
=A9crit :
> On Fri, Oct 08, 2010 at 05:04:07PM +0200, Eric Dumazet wrote:
> > Le vendredi 08 octobre 2010 =C3=A0 16:52 +0200, Stanislaw Gruszka a=
 =C3=A9crit :
> > > On Fri, Oct 08, 2010 at 04:25:00PM +0200, Stanislaw Gruszka wrote=
:
> > > > We have fedora bug report where driver fail to initialize after
> > > > suspend/resume because of memory allocation errors:
> > > > https://bugzilla.redhat.com/show_bug.cgi?id=3D629158
> > >=20
> > > There is also one more thing to do regarding above. Calltraces fr=
om bug
> > > reports, shows that order 3 allocation fail. On arch with 4kB pag=
es,
> > > order 3 mean 32kB allocation. We want to alloc 16kB, but there is=
 also
> > > internal sk_buff data what make that we exceed the boundary and t=
ake
> > > 32kB from allocator, getting almost 50% wastage.
> > >=20
> >=20
> > Or its only an 1460+overhead allocation, and SLUB uses order-3 page=
s to
> > satisfy 2048 bytes allocations.
>=20
> Rather not, trace show failure in rtl8169_rx_fill, where we allocate =
rx
> buffers and these are 16kB big by default.
>=20

Only when gfp_t is GFP_KERNEL to fill rx buffers. (after your patch
applied of course). This should succeed. If not, driver cannot load and
function, since this NIC really needs 16KB buffers in order to avoid a
hardware bug.

Once allocated for RX rings, we never free them (never give this skb to
upper stack) : When we receive a frame, we copybreak it, (using
GFP_ATOMIC) so it depends on MTU.

With MTU=3D1500, I am pretty sure we allocate 2048 bytes chunks, not mo=
re.


> I think, only on these drivers which do alloc_skb(n*PAGE_SIZE).
> As alternative we can be smarter in alloc_skb.

Only if MTU is non standard, then.

I repeat : With standard MTU=3D1500, we dont allocate huge skbs in rx
path, only small (<2048 bytes) ones.

=46or bigger frames, then you might allocate fragments, using pages, an=
d
dont care if PAGE_SIZE is 64Kbytes.



