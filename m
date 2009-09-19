From: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: ipw2200: firmware DMA loading rework
Date: Sat, 19 Sep 2009 15:25:32 +0200
Message-ID: <200909191525.33297.bzolnier@gmail.com>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <43e72e890909021102g7f844c79xefccf305f5f5c5b6@mail.gmail.com> <200909022026.17910.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tso Ted <tytso-3s7WtUTddSA@public.gmane.org>,
	"Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mel Gorman <mel-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200909022026.17910.bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 02 September 2009 20:26:17 Bartlomiej Zolnierkiewicz wrote:
> On Wednesday 02 September 2009 20:02:14 Luis R. Rodriguez wrote:
> > On Wed, Sep 2, 2009 at 10:48 AM, Bartlomiej
> > Zolnierkiewicz<bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > > On Sunday 30 August 2009 14:37:42 Bartlomiej Zolnierkiewicz wrote:
> > >> On Friday 28 August 2009 05:42:31 Zhu Yi wrote:
> > >> > Bartlomiej Zolnierkiewicz reported an atomic order-6 allocation failure
> > >> > for ipw2200 firmware loading in kernel 2.6.30. High order allocation is
> > >>
> > >> s/2.6.30/2.6.31-rc6/
> > >>
> > >> The issue has always been there but it was some recent change that
> > >> explicitly triggered the allocation failures (after 2.6.31-rc1).
> > >
> > > ipw2200 fix works fine but yesterday I got the following error while mounting
> > > ext4 filesystem (mb_history is optional so the mount succeeded):
> > 
> > OK so the mount succeeded.
> > 
> > > EXT4-fs (dm-2): barriers enabled
> > > kjournald2 starting: pid 3137, dev dm-2:8, commit interval 5 seconds
> > > EXT4-fs (dm-2): internal journal on dm-2:8
> > > EXT4-fs (dm-2): delayed allocation enabled
> > > EXT4-fs: file extents enabled
> > > mount: page allocation failure. order:5, mode:0xc0d0
> > > Pid: 3136, comm: mount Not tainted 2.6.31-rc8-00015-gadda766-dirty #78
> > > Call Trace:
> > >  [<c0394de3>] ? printk+0xf/0x14
> > >  [<c016a693>] __alloc_pages_nodemask+0x400/0x442
> > >  [<c016a71b>] __get_free_pages+0xf/0x32
> > >  [<c01865cf>] __kmalloc+0x28/0xfa
> > >  [<c023d96f>] ? __spin_lock_init+0x28/0x4d
> > >  [<c01f529d>] ext4_mb_init+0x392/0x460
> > >  [<c01e99d2>] ext4_fill_super+0x1b96/0x2012
> > >  [<c0239bc8>] ? snprintf+0x15/0x17
> > >  [<c01c0b26>] ? disk_name+0x24/0x69
> > >  [<c018ba63>] get_sb_bdev+0xda/0x117
> > >  [<c01e6711>] ext4_get_sb+0x13/0x15
> > >  [<c01e7e3c>] ? ext4_fill_super+0x0/0x2012
> > >  [<c018ad2d>] vfs_kern_mount+0x3b/0x76
> > >  [<c018adad>] do_kern_mount+0x33/0xbd
> > >  [<c019d0af>] do_mount+0x660/0x6b8
> > >  [<c016a71b>] ? __get_free_pages+0xf/0x32
> > >  [<c019d168>] sys_mount+0x61/0x99
> > >  [<c0102908>] sysenter_do_call+0x12/0x36
> > > Mem-Info:
> > > DMA per-cpu:
> > > CPU    0: hi:    0, btch:   1 usd:   0
> > > Normal per-cpu:
> > > CPU    0: hi:  186, btch:  31 usd:   0
> > > Active_anon:25471 active_file:22802 inactive_anon:25812
> > >  inactive_file:33619 unevictable:2 dirty:2452 writeback:135 unstable:0
> > >  free:4346 slab:4308 mapped:26038 pagetables:912 bounce:0
> > > DMA free:2060kB min:84kB low:104kB high:124kB active_anon:1660kB inactive_anon:1848kB active_file:144kB inactive_file:868kB unevictable:0kB present:15788kB pages_scanned:0 all_unreclaimable? no
> > > lowmem_reserve[]: 0 489 489
> > > Normal free:15324kB min:2788kB low:3484kB high:4180kB active_anon:100224kB inactive_anon:101400kB active_file:91064kB inactive_file:133608kB unevictable:8kB present:501392kB pages_scanned:0 all_unreclaimable? no
> > > lowmem_reserve[]: 0 0 0
> > > DMA: 1*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 2060kB
> > > Normal: 1283*4kB 648*8kB 159*16kB 53*32kB 10*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15324kB
> > > 57947 total pagecache pages
> > > 878 pages in swap cache
> > > Swap cache stats: add 920, delete 42, find 11/11
> > > Free swap  = 1016436kB
> > > Total swap = 1020116kB
> > > 131056 pages RAM
> > > 4233 pages reserved
> > > 90573 pages shared
> > > 77286 pages non-shared
> > > EXT4-fs: mballoc enabled
> > > EXT4-fs (dm-2): mounted filesystem with ordered data mode
> > >
> > > Thus it seems like the original bug is still there and any ideas how to
> > > debug the problem further are appreciated..
> > >
> > > The complete dmesg and kernel config are here:
> > >
> > > http://www.kernel.org/pub/linux/kernel/people/bart/ext4-paf.dmesg
> > > http://www.kernel.org/pub/linux/kernel/people/bart/ext4-paf.config
> > 
> > This looks very similar to the kmemleak ext4 reports upon a mount. If
> > it is the same issue, which from the trace it seems it is, then this
> > is due to an extra kmalloc() allocation and this apparently will not
> > get fixed on 2.6.31 due to the closeness of the merge window and the
> > non-criticalness this issue has been deemed.
> > 
> > A patch fix is part of the ext4-patchqueue
> > http://repo.or.cz/w/ext4-patch-queue.git
> 
> Thanks for the pointer but the page allocation failures that I hit seem
> to be caused by the memory management itself and the ext4 issue fixed by:
> 
> http://repo.or.cz/w/ext4-patch-queue.git?a=blob;f=memory-leak-fix-ext4_group_info-allocation;h=c919fff34e70ec85f96d1833f9ce460c451000de;hb=HEAD
> 
> is a different problem (unrelated to this one).

Here is another data point.

This time it is an order-6 page allocation failure for rt2870sta
(w/ upcoming driver changes) and Linus' tree from few days ago..

ifconfig: page allocation failure. order:6, mode:0x8020
Pid: 4752, comm: ifconfig Tainted: G        WC 2.6.31-04082-g1824090-dirty #80
Call Trace:
 [<c03996f2>] ? printk+0xf/0x15
 [<c016b841>] __alloc_pages_nodemask+0x41d/0x462
 [<c010681e>] dma_generic_alloc_coherent+0x53/0xbd
 [<c02f83aa>] hcd_buffer_alloc+0xdb/0xe8
 [<c01067cb>] ? dma_generic_alloc_coherent+0x0/0xbd
 [<c02ee2d6>] usb_buffer_alloc+0x16/0x1d
 [<e121b627>] NICInitTransmit+0xe2/0x7e4 [rt2870sta]
 [<e121bfb1>] RTMPAllocTxRxRingMemory+0x11c/0x17b [rt2870sta]
 [<e11f0960>] rt28xx_init+0xa5/0x3f8 [rt2870sta]
 [<e121194a>] rt28xx_open+0x53/0xa2 [rt2870sta]
 [<e1211b77>] MainVirtualIF_open+0x23/0xf6 [rt2870sta]
 [<c03383a4>] dev_open+0x86/0xbb
 [<c0337b1a>] dev_change_flags+0x96/0x147
 [<c036e9cb>] devinet_ioctl+0x20f/0x4f8
 [<c036fc8f>] inet_ioctl+0x8e/0xa7
 [<c032ab50>] sock_ioctl+0x1c9/0x1ed
 [<c032a987>] ? sock_ioctl+0x0/0x1ed
 [<c0195732>] vfs_ioctl+0x18/0x71
 [<c0195cbb>] do_vfs_ioctl+0x491/0x4cf
 [<c01779d6>] ? handle_mm_fault+0x242/0x4ff
 [<c0119609>] ? do_page_fault+0x102/0x292
 [<c0140721>] ? up_read+0x16/0x29
 [<c0195d27>] sys_ioctl+0x2e/0x48
 [<c0102908>] sysenter_do_call+0x12/0x36
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd:  84
Active_anon:14664 active_file:30057 inactive_anon:31744
 inactive_file:29940 unevictable:2 dirty:11 writeback:0 unstable:0
 free:5421 slab:4037 mapped:7781 pagetables:963 bounce:0
DMA free:2060kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:124kB active_file:3284kB inactive_file:972kB unevictable:0kB present:15788kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 489 489
Normal free:19624kB min:2788kB low:3484kB high:4180kB active_anon:58656kB inactive_anon:126852kB active_file:116944kB inactive_file:118788kB unevictable:8kB present:501392kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 3*4kB 0*8kB 2*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2060kB
Normal: 2180*4kB 625*8kB 303*16kB 33*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 19624kB
64568 total pagecache pages
3652 pages in swap cache
Swap cache stats: add 21642, delete 17990, find 4906/6079
Free swap  = 981700kB
Total swap = 1020116kB
131056 pages RAM
4262 pages reserved
91941 pages shared
60834 pages non-shared
<-- ERROR in Alloc TX TxContext[0] HTTX_BUFFER !! 
<-- RTMPAllocTxRxRingMemory, Status=3
ERROR!!! RTMPAllocDMAMemory failed, Status[=0x00000003]
!!! rt28xx Initialized fail !!!
