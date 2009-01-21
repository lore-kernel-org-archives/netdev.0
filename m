From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Mainline kernel OLTP performance update
Date: Wed, 21 Jan 2009 18:58:10 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0901211852060.18367@qirst.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>  <200901161503.13730.nickpiggin@yahoo.com.au>  <20090115201210.ca1a9542.akpm@linux-foundation.org>  <200901161746.25205.nickpiggin@yahoo.com.au>  <20090116065546.GJ31013@parisc-linux.org>
  <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org> <1232428583.11429.83.camel@ymzhang>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-716562517-983847473-1232582290=:18367"
Cc: Andi Kleen <andi@firstfloor.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753728AbZAVAbw@vger.kernel.org>
In-Reply-To: <1232428583.11429.83.camel@ymzhang>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---716562517-983847473-1232582290=:18367
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 20 Jan 2009, Zhang, Yanmin wrote:

> kmem_cache =EF=BB=BFskbuff_head_cache's object size is just 256, so it sh=
ares the kmem_cache
> with =EF=BB=BF:0000256. Their order is 1 which means every slab consists =
of 2 physical pages.

That order can be changed. Try specifying slub_max_order=3D0 on the kernel
command line to force an order 0 alloc.

The queues of the page allocator are of limited use due to their overhead.
Order-1 allocations can actually be 5% faster than order-0. order-0 makes
sense if pages are pushed rapidly to the page allocator and are then
reissues elsewhere. If there is a linear consumption then the page
allocator queues are just overhead.

> Page allocator has an array at zone_pcp(zone, cpu)->pcp to keep a page bu=
ffer for page order 0.
> But here =EF=BB=BFskbuff_head_cache's order is 1, so UDP-U-4k couldn't be=
nefit from the page buffer.

That usually does not matter because of partial list avoiding page
allocator actions.

> SLQB has no such issue, because:
> 1) SLQB has a percpu freelist. Free objects are put to the list firstly a=
nd can be picked up
> later on quickly without lock. A batch parameter to control the free obje=
ct recollection is mostly
> 1024.
> 2) SLQB slab order mostly is 0, so although sometimes it calls alloc_page=
s/free_pages, it can
> benefit from =EF=BB=BFzone_pcp(zone, cpu)->pcp page buffer.
>
> So SLUB need resolve such issues that one process allocates a batch of ob=
jects and another process
> frees them batchly.

SLUB has a percpu freelist but its bounded by the basic allocation unit.
You can increase that by modifying the allocation order. Writing a 3 or 5
into the order value in /sys/kernel/slab/xxx/order would do the trick.
---716562517-983847473-1232582290=:18367--
