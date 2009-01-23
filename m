From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 08:52:27 +0200
Message-ID: <4979692B.3050703@cs.helsinki.fi>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>	 <200901161503.13730.nickpiggin@yahoo.com.au>	 <20090115201210.ca1a9542.akpm@linux-foundation.org>	 <200901161746.25205.nickpiggin@yahoo.com.au>	 <20090116065546.GJ31013@parisc-linux.org>	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>	 <1232428583.11429.83.camel@ymzhang>	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>	 <1232613395.11429.122.camel@ymzhang>	 <1232615707.14549.6.camel@penberg-laptop>	 <1232616517.11429.129.camel@ymzhang>	 <1232617672.14549.25.camel@penberg-laptop> <1232679773.11429.155.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
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
	anirban.chakraborty@qlogic.com, mingo@elte.hu
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1232679773.11429.155.camel@ymzhang>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhang, Yanmin wrote:
>>>> If it's the former, with big enough size passed to __alloc_skb(), =
the
>>>> networking code might be taking a hit from the SLUB page allocator
>>>> pass-through.
>> Do we know what kind of size is being passed to __alloc_skb() in thi=
s
>> case?
> In function __alloc_skb, original parameter size=3D4155,
> SKB_DATA_ALIGN(size)=3D4224, sizeof(struct skb_shared_info)=3D472, so
> __kmalloc_track_caller's parameter size=3D4696.

OK, so all allocations go straight to the page allocator.

>=20
>>  Maybe we want to do something like this.
>>
>> SLUB: revert page allocator pass-through
> This patch amost fixes the netperf UDP-U-4k issue.
>=20
> #slabinfo -AD
> Name                   Objects    Alloc     Free   %Fast
> :0000256                  1658 70350463 70348946  99  99=20
> kmalloc-8192                31 70322309 70322293  99  99=20
> :0000168                  2592   143154   140684  93  28=20
> :0004096                  1456    91072    89644  99  96=20
> :0000192                  3402    63838    60491  89  11=20
> :0000064                  6177    49635    43743  98  77=20
>=20
> So =EF=BB=BFkmalloc-8192 appears. Without the patch, =EF=BB=BFkmalloc=
-8192 hides.
> =EF=BB=BFkmalloc-8192's default order on my 8-core stoakley is 2.

Christoph, should we merge my patch as-is or do you have an alternative=
=20
fix in mind? We could, of course, increase kmalloc() caches one level u=
p=20
to 8192 or higher.

>=20
> 1) If I start CPU_NUM clients and servers, SLUB's result is about 2% =
better than SLQB's;
> 2) If I start 1 clinet and 1 server, and bind them to different physi=
cal cpu, SLQB's result
> is about 10% better than SLUB's.
>=20
> I don't know why there is still 10% difference with item 2). Maybe ca=
chemiss causes it?

Maybe we can use the perfstat and/or kerneltop utilities of the new per=
f=20
counters patch to diagnose this:

http://lkml.org/lkml/2009/1/21/273

And do oprofile, of course. Thanks!

		Pekka
--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
