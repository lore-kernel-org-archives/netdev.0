From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/15] Swap-over-NBD without deadlocking V8
Date: Tue, 7 Feb 2012 13:27:45 +0000
Message-ID: <20120207132745.GH5938@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
 <CAJd=RBAvvzK=TXwDaEjq2t+uEuP2PSi6zaUj7EW4UbL_AUsJAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Hillf Danton <dhillf@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <CAJd=RBAvvzK=TXwDaEjq2t+uEuP2PSi6zaUj7EW4UbL_AUsJAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2012 at 08:45:18PM +0800, Hillf Danton wrote:
> On Tue, Feb 7, 2012 at 6:56 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > The core issue is that network block devices do not use mempools like=
 normal
> > block devices do. As the host cannot control where they receive packe=
ts from,
> > they cannot reliably work out in advance how much memory they might n=
eed.
> >
> >
> > Patch 1 serialises access to min_free_kbytes. It's not strictly neede=
d
> > =A0 =A0 =A0 =A0by this series but as the series cares about watermark=
s in
> > =A0 =A0 =A0 =A0general, it's a harmless fix. It could be merged indep=
endently.
> >
> >
> Any light shed on tuning min_free_kbytes for every day work?
>=20

For every day work, leave min_free_kbytes as the default.

>=20
> > Patch 2 adds knowledge of the PFMEMALLOC reserves to SLAB and SLUB to
> > =A0 =A0 =A0 =A0preserve access to pages allocated under low memory si=
tuations
> > =A0 =A0 =A0 =A0to callers that are freeing memory.
> >
> > Patch 3 introduces __GFP_MEMALLOC to allow access to the PFMEMALLOC
> > =A0 =A0 =A0 =A0reserves without setting PFMEMALLOC.
> >
> > Patch 4 opens the possibility for softirqs to use PFMEMALLOC reserves
> > =A0 =A0 =A0 =A0for later use by network packet processing.
> >
> > Patch 5 ignores memory policies when ALLOC_NO_WATERMARKS is set.
> >
> > Patches 6-11 allows network processing to use PFMEMALLOC reserves whe=
n
> > =A0 =A0 =A0 =A0the socket has been marked as being used by the VM to =
clean
> > =A0 =A0 =A0 =A0pages. If packets are received and stored in pages tha=
t were
> > =A0 =A0 =A0 =A0allocated under low-memory situations and are unrelate=
d to
> > =A0 =A0 =A0 =A0the VM, the packets are dropped.
> >
> > Patch 12 is a micro-optimisation to avoid a function call in the
> > =A0 =A0 =A0 =A0common case.
> >
> > Patch 13 tags NBD sockets as being SOCK_MEMALLOC so they can use
> > =A0 =A0 =A0 =A0PFMEMALLOC if necessary.
> >
>
> If it is feasible to bypass hang by tuning min_mem_kbytes,

No. Increasing or descreasing min_free_kbytes changes the timing but it
will still hang.

> things may
> become simpler if NICs are also tagged.

That would mean making changes to every driver and they do not necessaril=
y
know what higher level protocol like TCP they are transmitting. How is
that simpler? What is the benefit?

> Sock buffers, pre-allocated if
> necessary just after NICs are turned on, are not handed back to kmem
> cache but queued on local lists which are maintained by NIC driver, bas=
ed
> the on the info of min_mem_kbytes or similar, for tagged NICs.

I think you are referring to doing something like SKB recycling within
the driver.

> Upside is no changes in VM core. Downsides?
>=20

That wouls indead requires driver-specific changes and new core
infrastructure to deal with SKB recycling spreading the complexity over a
wider range of code. If all the SKBs are in use for SOCK_MEMALLOC purpose=
s
for whatever reason and more cannot be allocated, it will still hang. So
downsides are it would be equally if not more complex than this approach
that it may still hang.

> > Patch 14 notes that it is still possible for the PFMEMALLOC reserve
> > =A0 =A0 =A0 =A0to be depleted. To prevent this, direct reclaimers get
> > =A0 =A0 =A0 =A0throttled on a waitqueue if 50% of the PFMEMALLOC rese=
rves are
> > =A0 =A0 =A0 =A0depleted. =A0It is expected that kswapd and the direct=
 reclaimers
> > =A0 =A0 =A0 =A0already running will clean enough pages for the low wa=
termark
> > =A0 =A0 =A0 =A0to be reached and the throttled processes are woken up=
.
> >
> > Patch 15 adds a statistic to track how often processes get throttled
> >
> >
> > For testing swap-over-NBD, a machine was booted with 2G of RAM with a
> > swapfile backed by NBD. 8*NUM_CPU processes were started that create
> > anonymous memory mappings and read them linearly in a loop. The total
> > size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
> > memory pressure. Without the patches, the machine locks up within
> > minutes and runs to completion with them applied.
> >
> >
>
> While testing, what happens if the network wire is plugged off over
> three minutes?
>=20

I didn't test the scenario and I don't have a test machine available
right now to try but it is up to the userspace NBD client to manage the
reconnection. It is also up to the admin to prevent the NBD client being
killed by something like the OOM killer and to have it mlocked to avoid
the NBD client itself being swapped. NFS is able to handle this in-kernel
but NBD may be more fragile.

--=20
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
