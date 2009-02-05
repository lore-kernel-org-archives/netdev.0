From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Re: Deadlock with icmpv6fuzz
Date: Thu, 5 Feb 2009 15:31:43 +0100
Message-ID: <20090205143143.GA18734@alice>
References: <20090126.213112.197185044.davem@davemloft.net> <20090127075356.GA6255@alice> <20090128093507.GA15956@gondor.apana.org.au> <20090129.174954.263448549.davem@davemloft.net> <20090205130149.GA28152@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:49947 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752545AbZBEObu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2009 09:31:50 -0500
Content-Disposition: inline
In-Reply-To: <20090205130149.GA28152@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Thu, Jan 29, 2009 at 05:49:54PM -0800, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Wed, 28 Jan 2009 20:35:07 +1100
> > 
> > > Any volunteers to fix this?
> > 
> > I'll try to take a stab at it later tonight.
> 
> I took a stab at it.
> 
> ipv6: Copy cork options in ip6_append_data
> 
> As the options passed to ip6_append_data may be ephemeral, we need
> to duplicate it for corking.  This patch applies the simplest fix
> which is to memdup all the relevant bits.

Thanks, this fixes the issue, I've been running icmpv6fuzz for a while
again and the only issue i saw so far was a page allocation failure:

Kernel is only dirty from your patch

[ 2880.044328] icmpv6fuzz: page allocation failure. order:9, mode:0x40d0
[ 2880.044495] Pid: 10968, comm: icmpv6fuzz Not tainted
2.6.29-rc3-00580-ga2fe994-dirty #239
[ 2880.044694] Call Trace:
[ 2880.044802]  [<c016886a>] __alloc_pages_internal+0x38e/0x3aa
[ 2880.044954]  [<c016889a>] __get_free_pages+0x14/0x24
[ 2880.071336]  [<c018412c>] __kmalloc+0x2e/0x122
[ 2880.071466]  [<c06fa1f9>] ? ipv6_flowlabel_opt+0x1b2/0x7b1
[ 2880.071589]  [<c06fa227>] ipv6_flowlabel_opt+0x1e0/0x7b1
[ 2880.071689]  [<c013e32f>] ? mark_held_locks+0x43/0x5a
[ 2880.071818]  [<c0125ecf>] ? local_bh_enable+0xa1/0xba
[ 2880.071910]  [<c013e4f1>] ? trace_hardirqs_on_caller+0x10d/0x14b
[ 2880.092665]  [<c066cfb6>] ? lock_sock_nested+0xb2/0xbd
[ 2880.092800]  [<c06e831d>] ? ipv6_setsockopt+0x8e/0xb89
[ 2880.092922]  [<c06e8c9e>] ipv6_setsockopt+0xa0f/0xb89
[ 2880.093098]  [<c013fce5>] ? __lock_acquire+0x6a8/0x6fe
[ 2880.093192]  [<c013fce5>] ? __lock_acquire+0x6a8/0x6fe
[ 2880.093323]  [<c0106d8d>] ? native_sched_clock+0x41/0x68
[ 2880.093420]  [<c013be58>] ? lock_release_holdtime+0x9f/0xa7
[ 2880.093541]  [<c0106d8d>] ? native_sched_clock+0x41/0x68
[ 2880.093634]  [<c013bda5>] ? put_lock_stats+0xd/0x21
[ 2880.093748]  [<c013be58>] ? lock_release_holdtime+0x9f/0xa7
[ 2880.093847]  [<c06edf93>] rawv6_setsockopt+0x78/0xe9
[ 2880.093963]  [<c066c9dd>] sock_common_setsockopt+0x13/0x18
[ 2880.094257]  [<c066b098>] sys_setsockopt+0x59/0x77
[ 2880.094424]  [<c066c58a>] sys_socketcall+0x12a/0x17b
[ 2880.094631]  [<c0102dc1>] sysenter_do_call+0x12/0x31
[ 2880.094797] Mem-Info:
[ 2880.094961] DMA per-cpu:
[ 2880.095200] CPU    0: hi:    0, btch:   1 usd:   0
[ 2880.095363] Normal per-cpu:
[ 2880.095536] CPU    0: hi:   90, btch:  15 usd:   5
[ 2880.095703] Active_anon:15024 active_file:510 inactive_anon:36637
[ 2880.095707]  inactive_file:761 unevictable:0 dirty:13 writeback:457
unstable:0
[ 2880.095712]  free:1798 slab:3367 mapped:300 pagetables:387 bounce:0
[ 2880.096242] DMA free:300kB min:120kB low:148kB high:180kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB present:15752kB pages_scanned:0 all_unreclaimable? no
[ 2880.096523] lowmem_reserve[]: 0 238 238 238
[ 2880.096838] Normal free:6892kB min:1912kB low:2388kB high:2868kB
active_anon:60096kB inactive_anon:146548kB active_file:2040kB
inactive_file:3044kB unevictable:0kB present:243824kB pages_scanned:0
all_unreclaimable? no
[ 2880.097479] lowmem_reserve[]: 0 0 0 0
[ 2880.097749] DMA: 1*4kB 1*8kB 0*16kB 1*32kB 2*64kB 1*128kB 0*256kB
0*512kB 0*1024kB 0*2048kB 0*4096kB = 300kB
[ 2880.098406] Normal: 415*4kB 130*8kB 10*16kB 4*32kB 5*64kB 2*128kB
1*256kB 2*512kB 2*1024kB 0*2048kB 0*4096kB = 6892kB
[ 2880.098994] 24927 total pagecache pages
[ 2880.130231] 23693 pages in swap cache
[ 2880.130343] Swap cache stats: add 424475, delete 400782, find
17623/61701
[ 2880.130979] Free swap  = 311644kB
[ 2880.131249] Total swap = 746980kB
[ 2880.225394] 65532 pages RAM
[ 2880.225551] 0 pages HighMem
[ 2880.225677] 4932 pages reserved
[ 2880.225772] 1554 pages shared
[ 2880.225889] 57445 pages non-shared

Greetings, Eric
