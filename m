From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Mainline kernel OLTP performance update
Date: Tue, 20 Jan 2009 13:16:23 +0800
Message-ID: <1232428583.11429.83.camel@ymzhang>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Wilcox <matthew@wil.cx>,
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
To: Andi Kleen <andi@firstfloor.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:19988 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750769AbZATFQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 00:16:31 -0500
In-Reply-To: <87sknjeemn.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-16 at 11:20 +0100, Andi Kleen wrote:
> "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> writes:
>=20
>=20
> > I think that's because SLQB
> > doesn't pass through big object allocation to page allocator.
> > netperf UDP-U-1k has less improvement with SLQB.
>=20
> That sounds like just the page allocator needs to be improved.
> That would help everyone. We talked a bit about this earlier,
> some of the heuristics for hot/cold pages are quite outdated
> and have been tuned for obsolete machines and also its fast path
> is quite long. Unfortunately no code currently.
Andi,

Thanks for your kind information. I did more investigation with SLUB
on netperf UDP-U-4k issue.

oprofile shows:
328058   30.1342  linux-2.6.29-rc2         copy_user_generic_string
134666   12.3699  linux-2.6.29-rc2         __free_pages_ok
125447   11.5231  linux-2.6.29-rc2         get_page_from_freelist
22611     2.0770  linux-2.6.29-rc2         __sk_mem_reclaim
21442     1.9696  linux-2.6.29-rc2         list_del
21187     1.9462  linux-2.6.29-rc2         __ip_route_output_key

So =EF=BB=BF__free_pages_ok and =EF=BB=BFget_page_from_freelist consume=
 too much cpu time.
With SLQB, these 2 functions almost don't consume time.

Command 'slabinfo -AD' shows:
Name                   Objects    Alloc     Free   %Fast
:0000256                  1685 29611065 29609548  99  99
:0000168                  2987   164689   161859  94  39
:0004096                  1471   114918   113490  99  97

So kmem_cache =EF=BB=BF:0000256 is very active.

Kernel stack dump in =EF=BB=BF__free_pages_ok shows
 [<ffffffff8027010f>] __free_pages_ok+0x109/0x2e0
 [<ffffffff8024bb34>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8060f387>] __kfree_skb+0x9/0x6f
 [<ffffffff8061204b>] skb_free_datagram+0xc/0x31
 [<ffffffff8064b528>] udp_recvmsg+0x1e7/0x26f
 [<ffffffff8060b509>] sock_common_recvmsg+0x30/0x45
 [<ffffffff80609acd>] sock_recvmsg+0xd5/0xed

The callchain is:
=EF=BB=BF__kfree_skb =3D>
	kfree_skbmem =3D>
		kmem_cache_free(skbuff_head_cache, skb);

kmem_cache =EF=BB=BFskbuff_head_cache's object size is just 256, so it =
shares the kmem_cache
with =EF=BB=BF:0000256. Their order is 1 which means every slab consist=
s of 2 physical pages.

=EF=BB=BFnetperf UDP-U-4k is a UDP stream testing. client process keeps=
 sending 4k-size packets
to server process and server process just receives the packets one by o=
ne.

If we start CPU_NUM clients and the same number of servers, every clien=
t will send lots
of packets within one sched slice, then process scheduler schedules the=
 server to receive
many packets within one sched slice; then client resends again. So ther=
e are many packets
in the queue. When server receive the packets, it frees =EF=BB=BFskbuff=
_head_cache. When the slab's
objects are all free, the slab will be released by calling __free_pages=
=2E Such batch
sending/receiving creates lots of slab free activity.

Page allocator has an array at zone_pcp(zone, cpu)->pcp to keep a page =
buffer for page order 0.
But here =EF=BB=BFskbuff_head_cache's order is 1, so UDP-U-4k couldn't =
benefit from the page buffer.

SLQB has no such issue, because:
1) SLQB has a percpu freelist. Free objects are put to the list firstly=
 and can be picked up
later on quickly without lock. A batch parameter to control the free ob=
ject recollection is mostly
1024.
2) SLQB slab order mostly is 0, so although sometimes it calls alloc_pa=
ges/free_pages, it can
benefit from =EF=BB=BFzone_pcp(zone, cpu)->pcp page buffer.

So SLUB need resolve such issues that one process allocates a batch of =
objects and another process
frees them batchly.

yanmin


