From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Thu, 22 Jan 2009 16:36:34 +0800
Message-ID: <1232613395.11429.122.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:47737 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750788AbZAVIgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 03:36:45 -0500
In-Reply-To: <alpine.DEB.1.10.0901211852060.18367@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-21 at 18:58 -0500, Christoph Lameter wrote:
> On Tue, 20 Jan 2009, Zhang, Yanmin wrote:
>=20
> > kmem_cache =EF=BB=BFskbuff_head_cache's object size is just 256, so=
 it shares the kmem_cache
> > with =EF=BB=BF:0000256. Their order is 1 which means every slab con=
sists of 2 physical pages.
>=20
> That order can be changed. Try specifying slub_max_order=3D0 on the k=
ernel
> command line to force an order 0 alloc.
I tried =EF=BB=BFslub_max_order=3D0 and there is no improvement on this=
 UDP-U-4k issue.
Both get_page_from_freelist and __free_pages_ok's cpu time are still ve=
ry high.

I checked my instrumentation in kernel and found it's caused by large o=
bject allocation/free
whose size is more than PAGE_SIZE. Here its order is 1.

The right free callchain is __kfree_skb =3D> skb_release_all =3D> skb_r=
elease_data.

So this case isn't the issue that batch of allocation/free might erase =
partial page
functionality.

'#slaninfo -AD' couldn't show statistics of large object allocation/fre=
e. Can we add
such info? That will be more helpful.

In addition, I didn't find such issue wih TCP stream testing.

>=20
> The queues of the page allocator are of limited use due to their over=
head.
> Order-1 allocations can actually be 5% faster than order-0. order-0 m=
akes
> sense if pages are pushed rapidly to the page allocator and are then
> reissues elsewhere. If there is a linear consumption then the page
> allocator queues are just overhead.
>=20
> > Page allocator has an array at zone_pcp(zone, cpu)->pcp to keep a p=
age buffer for page order 0.
> > But here =EF=BB=BFskbuff_head_cache's order is 1, so UDP-U-4k could=
n't benefit from the page buffer.
>=20
> That usually does not matter because of partial list avoiding page
> allocator actions.

>=20
> > SLQB has no such issue, because:
> > 1) SLQB has a percpu freelist. Free objects are put to the list fir=
stly and can be picked up
> > later on quickly without lock. A batch parameter to control the fre=
e object recollection is mostly
> > 1024.
> > 2) SLQB slab order mostly is 0, so although sometimes it calls allo=
c_pages/free_pages, it can
> > benefit from =EF=BB=BFzone_pcp(zone, cpu)->pcp page buffer.
> >
> > So SLUB need resolve such issues that one process allocates a batch=
 of objects and another process
> > frees them batchly.
>=20
> SLUB has a percpu freelist but its bounded by the basic allocation un=
it.
> You can increase that by modifying the allocation order. Writing a 3 =
or 5
> into the order value in /sys/kernel/slab/xxx/order would do the trick=
=2E

