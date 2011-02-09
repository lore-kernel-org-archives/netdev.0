From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [net-2.6][2.6.38-rc2] panic during stress testing
Date: Wed, 9 Feb 2011 10:12:03 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1102081611130.5424@JBRANDEB-DESK2.amr.corp.intel.com>
References: <1297189925.4087.8.camel@jbrandeb-mobl2> <20110208.135113.59683468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43137 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605Ab1BISMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 13:12:25 -0500
In-Reply-To: <20110208.135113.59683468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 8 Feb 2011, David Miller wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date: Tue, 08 Feb 2011 10:32:05 -0800
> 
> > We are currently testing patches and ran into this panic, doesn't
> > immediately seem related to the driver.
> > 
> > During TCP/UDP ipv4/6 stress testing on 82574L, 2.6.38-rc2 x86_64
> > (net-2.6 with e1000e patches under test) gets numerous OOM killer
> > messages, followed by a bug/Oops and panic. could not reproduce the
> > bug/panic on 2.6.37, but the OOM killer messages are still seen.
> > 
> > Could well be related somehow to testing with DEBUG_PAGEALLOC enabled.
> > 
> > panic dump and .config follows:
> > 
> > BUG: unable to handle kernel paging request at ffffffff81089738
> > IP: [<ffffffff812e2139>] dst_destroy+0x4b/0xf3
> > PGD 1695067 PUD 1699063 PMD 10001e1 
> > Oops: 0003 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
> > CPU 1 
> > Modules linked in: nfsd exportfs lockd sunrpc dca e1000e [last unloaded: igb]
> 
> So some piece of freed memory is being referenced in dst_destroy(), can you
> match dst_destroy+0x4b to a line in that function for your build?

appears to be (best as I can tell)

(gdb) l *(dst_destroy+0x4b)
0x20d is in dst_destroy 
(/usr/src/net-2.6-e1000e/arch/x86/include/asm/atomic.h:123).
118      */
119     static inline int atomic_dec_and_test(atomic_t *v)
120     {
121             unsigned char c;
122
123             asm volatile(LOCK_PREFIX "decl %0; sete %1"
124                          : "+m" (v->counter), "=qm" (c)
125                          : : "memory");
126             return c != 0;
127     }
(gdb) l *(dst_destroy+0x4a)
0x20c is in dst_destroy (net/core/dst.c:235).
230             dst->hh = NULL;
231             if (hh)
232                     hh_cache_put(hh);
233
234             if (neigh) {
235                     dst->neighbour = NULL;
>>> 236                     neigh_release(neigh);
237             }
238
239             dst_entries_add(dst->ops, -1);

283 static inline void neigh_release(struct neighbour *neigh)
284 {
>>> 285         if (atomic_dec_and_test(&neigh->refcnt))
286                 neigh_destroy(neigh);
287 }

neigh appears to be zero? since the check just above in dst_destroy was 
checking it against NULL already, maybe we have a race, with some other 
free of neigh (assigned from dst->neighbor)

This is quickly getting beyond me, I tried to check for some changes 
around dst->neighbor but didn't see anything recent.





