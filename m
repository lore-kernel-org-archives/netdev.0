From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 11:02:53 +0800
Message-ID: <1232679773.11429.155.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
	 <1232613395.11429.122.camel@ymzhang>
	 <1232615707.14549.6.camel@penberg-laptop>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
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
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1232617672.14549.25.camel@penberg-laptop>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-01-22 at 11:47 +0200, Pekka Enberg wrote:
> On Thu, 2009-01-22 at 17:28 +0800, Zhang, Yanmin wrote:
> > On Thu, 2009-01-22 at 11:15 +0200, Pekka Enberg wrote:
> > > On Thu, 2009-01-22 at 16:36 +0800, Zhang, Yanmin wrote:
> > > > On Wed, 2009-01-21 at 18:58 -0500, Christoph Lameter wrote:
> > > > > On Tue, 20 Jan 2009, Zhang, Yanmin wrote:
> > > > >=20
> > > > > > kmem_cache =EF=BB=BFskbuff_head_cache's object size is just=
 256, so it shares the kmem_cache
> > > > > > with =EF=BB=BF:0000256. Their order is 1 which means every =
slab consists of 2 physical pages.
> > > > >=20
> > > > > That order can be changed. Try specifying slub_max_order=3D0 =
on the kernel
> > > > > command line to force an order 0 alloc.
> > > > I tried =EF=BB=BFslub_max_order=3D0 and there is no improvement=
 on this UDP-U-4k issue.
> > > > Both get_page_from_freelist and __free_pages_ok's cpu time are =
still very high.
> > > >=20
> > > > I checked my instrumentation in kernel and found it's caused by=
 large object allocation/free
> > > > whose size is more than PAGE_SIZE. Here its order is 1.
> > > >=20
> > > > The right free callchain is __kfree_skb =3D> skb_release_all =3D=
> skb_release_data.
> > > >=20
> > > > So this case isn't the issue that batch of allocation/free migh=
t erase partial page
> > > > functionality.
> > >=20
> > > So is this the kfree(skb->head) in skb_release_data() or the put_=
page()
> > > calls in the same function in a loop?
> > It's =EF=BB=BFkfree(skb->head).
> >=20
> > >=20
> > > If it's the former, with big enough size passed to __alloc_skb(),=
 the
> > > networking code might be taking a hit from the SLUB page allocato=
r
> > > pass-through.
>=20
> Do we know what kind of size is being passed to __alloc_skb() in this
> case?
In function __alloc_skb, original parameter size=3D4155,
SKB_DATA_ALIGN(size)=3D4224, sizeof(struct skb_shared_info)=3D472, so
__kmalloc_track_caller's parameter size=3D4696.

>  Maybe we want to do something like this.
>=20
> 		Pekka
>=20
> SLUB: revert page allocator pass-through
This patch amost fixes the netperf UDP-U-4k issue.

#slabinfo -AD
Name                   Objects    Alloc     Free   %Fast
:0000256                  1658 70350463 70348946  99  99=20
kmalloc-8192                31 70322309 70322293  99  99=20
:0000168                  2592   143154   140684  93  28=20
:0004096                  1456    91072    89644  99  96=20
:0000192                  3402    63838    60491  89  11=20
:0000064                  6177    49635    43743  98  77=20

So =EF=BB=BFkmalloc-8192 appears. Without the patch, =EF=BB=BFkmalloc-8=
192 hides.
=EF=BB=BFkmalloc-8192's default order on my 8-core stoakley is 2.

1) If I start CPU_NUM clients and servers, SLUB's result is about 2% be=
tter than SLQB's;
2) If I start 1 clinet and 1 server, and bind them to different physica=
l cpu, SLQB's result
is about 10% better than SLUB's.

I don't know why there is still 10% difference with item 2). Maybe cach=
emiss causes it?

>=20
> This is a revert of commit aadb4bc4a1f9108c1d0fbd121827c936c2ed4217 (=
"SLUB:
> direct pass through of page size or higher kmalloc requests").
> ---
>=20
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 2f5c16b..3bd3662 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h


--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
