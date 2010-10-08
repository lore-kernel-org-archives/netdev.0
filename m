From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Fri, 08 Oct 2010 17:04:07 +0200
Message-ID: <1286550247.2959.444.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	 <20101008145256.GB10393@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45249 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758355Ab0JHPER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 11:04:17 -0400
Received: by wyb28 with SMTP id 28so1177328wyb.19
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 08:04:15 -0700 (PDT)
In-Reply-To: <20101008145256.GB10393@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 16:52 +0200, Stanislaw Gruszka a =C3=
=A9crit :
> On Fri, Oct 08, 2010 at 04:25:00PM +0200, Stanislaw Gruszka wrote:
> > We have fedora bug report where driver fail to initialize after
> > suspend/resume because of memory allocation errors:
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D629158
>=20
> There is also one more thing to do regarding above. Calltraces from b=
ug
> reports, shows that order 3 allocation fail. On arch with 4kB pages,
> order 3 mean 32kB allocation. We want to alloc 16kB, but there is als=
o
> internal sk_buff data what make that we exceed the boundary and take
> 32kB from allocator, getting almost 50% wastage.
>=20

Or its only an 1460+overhead allocation, and SLUB uses order-3 pages to
satisfy 2048 bytes allocations.

# grep 2048 /proc/slabinfo=20
kmalloc-2048        8664   8752   2048   16    8 : tunables    0    0
0 : slabdata    547    547      0


8 in the <pagesperslab> column just says that : order-3 pages, even for
small allocations.

Switch to SLAB -> no more problem ;)


> To fix we can use similar method as in niu or iwlwifi drivers, alloc
> pages directly form buddy allocator and attach them to skb (by
> skb_add_rx_frag for example). I'm going to prepare such patch, but
> I have one doubt, what happens if page size in system is bigger
> than 16kB, should I care about such case?=20

Seems tricky. Should we patch all drivers to do something like that ?



