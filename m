From: Hillf Danton <dhillf@gmail.com>
Subject: Re: [PATCH 00/15] Swap-over-NBD without deadlocking V8
Date: Tue, 7 Feb 2012 20:45:18 +0800
Message-ID: <CAJd=RBAvvzK=TXwDaEjq2t+uEuP2PSi6zaUj7EW4UbL_AUsJAg@mail.gmail.com>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Mel Gorman <mgorman@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328568978-17553-1-git-send-email-mgorman@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 7, 2012 at 6:56 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> The core issue is that network block devices do not use mempools like=
 normal
> block devices do. As the host cannot control where they receive packe=
ts from,
> they cannot reliably work out in advance how much memory they might n=
eed.
>
>
> Patch 1 serialises access to min_free_kbytes. It's not strictly neede=
d
> =C2=A0 =C2=A0 =C2=A0 =C2=A0by this series but as the series cares abo=
ut watermarks in
> =C2=A0 =C2=A0 =C2=A0 =C2=A0general, it's a harmless fix. It could be =
merged independently.
>
>
Any light shed on tuning min_free_kbytes for every day work?


> Patch 2 adds knowledge of the PFMEMALLOC reserves to SLAB and SLUB to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0preserve access to pages allocated under l=
ow memory situations
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to callers that are freeing memory.
>
> Patch 3 introduces __GFP_MEMALLOC to allow access to the PFMEMALLOC
> =C2=A0 =C2=A0 =C2=A0 =C2=A0reserves without setting PFMEMALLOC.
>
> Patch 4 opens the possibility for softirqs to use PFMEMALLOC reserves
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for later use by network packet processing=
=2E
>
> Patch 5 ignores memory policies when ALLOC_NO_WATERMARKS is set.
>
> Patches 6-11 allows network processing to use PFMEMALLOC reserves whe=
n
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the socket has been marked as being used b=
y the VM to clean
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pages. If packets are received and stored =
in pages that were
> =C2=A0 =C2=A0 =C2=A0 =C2=A0allocated under low-memory situations and =
are unrelated to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0the VM, the packets are dropped.
>
> Patch 12 is a micro-optimisation to avoid a function call in the
> =C2=A0 =C2=A0 =C2=A0 =C2=A0common case.
>
> Patch 13 tags NBD sockets as being SOCK_MEMALLOC so they can use
> =C2=A0 =C2=A0 =C2=A0 =C2=A0PFMEMALLOC if necessary.
>
If it is feasible to bypass hang by tuning min_mem_kbytes, things may
become simpler if NICs are also tagged. Sock buffers, pre-allocated if
necessary just after NICs are turned on, are not handed back to kmem
cache but queued on local lists which are maintained by NIC driver, bas=
ed
the on the info of min_mem_kbytes or similar, for tagged NICs.
Upside is no changes in VM core. Downsides?


> Patch 14 notes that it is still possible for the PFMEMALLOC reserve
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to be depleted. To prevent this, direct re=
claimers get
> =C2=A0 =C2=A0 =C2=A0 =C2=A0throttled on a waitqueue if 50% of the PFM=
EMALLOC reserves are
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depleted. =C2=A0It is expected that kswapd=
 and the direct reclaimers
> =C2=A0 =C2=A0 =C2=A0 =C2=A0already running will clean enough pages fo=
r the low watermark
> =C2=A0 =C2=A0 =C2=A0 =C2=A0to be reached and the throttled processes =
are woken up.
>
> Patch 15 adds a statistic to track how often processes get throttled
>
>
> For testing swap-over-NBD, a machine was booted with 2G of RAM with a
> swapfile backed by NBD. 8*NUM_CPU processes were started that create
> anonymous memory mappings and read them linearly in a loop. The total
> size of the mappings were 4*PHYSICAL_MEMORY to use swap heavily under
> memory pressure. Without the patches, the machine locks up within
> minutes and runs to completion with them applied.
>
>
While testing, what happens if the network wire is plugged off over
three minutes?

Thanks
Hillf
