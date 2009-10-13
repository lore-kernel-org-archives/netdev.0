From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [Bug #14265] ifconfig: page allocation failure. order:5,
	mode:0x8020 w/ e100
Date: Tue, 13 Oct 2009 14:29:08 +0200
Message-ID: <20091013122907.GA4713@bizet.domek.prywatny>
References: <56acieJJ2fF.A.nEB.Hzl0KB@chimera> <L6tb-VyKHZK.A.YoC.lzl0KB@chimera> <20091012.040536.10656720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rjw@sisk.pl, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, karol.k.lewandowski@gmail.com,
	mel@csn.ul.ie, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759633AbZJMMbF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091012.040536.10656720.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2009 at 04:05:36AM -0700, David Miller wrote:
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> Date: Mon, 12 Oct 2009 01:01:08 +0200 (CEST)
> 
> [ Netdev CC:'d ]
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14265
> > Subject		: ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
> > Submitter	: Karol Lewandowski <karol.k.lewandowski@gmail.com>
> > Date		: 2009-09-15 12:05 (27 days old)
> > References	: http://marc.info/?l=linux-kernel&m=125301636509517&w=4
> 
> A 128K memory allocation fails after resume, film at 11.
> 
> That e100 driver code has been that way forever, so likely it's
> something in the page allocator or similar that is making this happen
> more likely now.  Perhaps it's related to the iwlagn allocation
> failures being tracked down in another thread.
> 
> It's a shame that pci_alloc_consistent() has to always use GFP_ATOMIC
> for compatability.
> 
> As far as I can tell, these code paths can sleep.  So maybe the
> following hack would fix this for now.  Could someone test this?

Sadly this patch doesn't help.  I've tested it on post 2.6.32-rc4
kernel, and got failures after few tries.  Frans has been more
successful[1] at tracking this problem down than I've been (I failed
miserably, to be honest).

[1] http://lkml.org/lkml/2009/10/11/247

Thanks.


e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 9, MAC addr 00:10:a4:89:e8:84
ifconfig: page allocation failure. order:5, mode:0x80d0
Pid: 4528, comm: ifconfig Tainted: G        W  2.6.32-rc4-00001-gd93a8f8-dirty #2
Call Trace:
 [<c0161034>] ? __alloc_pages_nodemask+0x43e/0x4a8
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0933b68>] ? e100_alloc_cbs+0xc0/0x16d [e100]
 [<d0934be9>] ? e100_up+0x1b/0xf5 [e100]
 [<d0934cda>] ? e100_open+0x17/0x41 [e100]
 [<c0305f11>] ? dev_open+0x8f/0xc5
 [<c03056d0>] ? dev_change_flags+0xa2/0x155
 [<c033c103>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c02f92be>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c01872da>] ? vfs_ioctl+0x16/0x4a
 [<c0187ba6>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfb3>] ? handle_mm_fault+0x214/0x462
 [<c0356e8e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187c09>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   0
active_anon:26670 inactive_anon:28253 isolated_anon:0
 active_file:2153 inactive_file:2367 isolated_file:0
 unevictable:0 dirty:15 writeback:24 unstable:0 buffer:151
 free:1291 slab_reclaimable:682 slab_unreclaimable:1101
 mapped:2234 shmem:70 pagetables:519 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:5032kB inactive_anon:5116kB active_file:296kB inactive_file:364kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:300kB shmem:0kB slab_reclaimable:8kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:8kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:4088kB min:1908kB low:2384kB high:2860kB active_anon:101648kB inactive_anon:107896kB active_file:8316kB inactive_file:9104kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:60kB writeback:96kB mapped:8636kB shmem:280kB slab_reclaimable:2720kB slab_unreclaimable:4364kB kernel_stack:472kB pagetables:2068kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 2*8kB 2*16kB 14*32kB 5*64kB 2*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 550*4kB 106*8kB 53*16kB 4*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4088kB
10052 total pagecache pages
5462 pages in swap cache
Swap cache stats: add 42476, delete 37014, find 32571/34728
Free swap  = 412384kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
8293 pages shared
58694 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x80d0
Pid: 4528, comm: ifconfig Tainted: G        W  2.6.32-rc4-00001-gd93a8f8-dirty #2
Call Trace:
 [<c0161034>] ? __alloc_pages_nodemask+0x43e/0x4a8
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0933b68>] ? e100_alloc_cbs+0xc0/0x16d [e100]
 [<d0934be9>] ? e100_up+0x1b/0xf5 [e100]
 [<d0934cda>] ? e100_open+0x17/0x41 [e100]
 [<c0305f11>] ? dev_open+0x8f/0xc5
 [<c03056d0>] ? dev_change_flags+0xa2/0x155
 [<c033c103>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c02f92be>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c01872da>] ? vfs_ioctl+0x16/0x4a
 [<c0187ba6>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c017dd04>] ? vfs_write+0xf4/0x105
 [<c0187c09>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   0
active_anon:26162 inactive_anon:28360 isolated_anon:27
 active_file:2077 inactive_file:2461 isolated_file:5
 unevictable:0 dirty:14 writeback:262 unstable:0 buffer:149
 free:1639 slab_reclaimable:682 slab_unreclaimable:1103
 mapped:2184 shmem:70 pagetables:519 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:5032kB inactive_anon:5116kB active_file:296kB inactive_file:364kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:300kB shmem:0kB slab_reclaimable:8kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:8kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:5480kB min:1908kB low:2384kB high:2860kB active_anon:99616kB inactive_anon:108324kB active_file:8012kB inactive_file:9480kB unevictable:0kB isolated(anon):108kB isolated(file):20kB present:243776kB mlocked:0kB dirty:56kB writeback:1048kB mapped:8436kB shmem:280kB slab_reclaimable:2720kB slab_unreclaimable:4372kB kernel_stack:472kB pagetables:2068kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 2*8kB 2*16kB 14*32kB 5*64kB 2*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 596*4kB 143*8kB 70*16kB 16*32kB 3*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5480kB
10454 total pagecache pages
5845 pages in swap cache
Swap cache stats: add 43307, delete 37462, find 32586/34751
Free swap  = 409320kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
8220 pages shared
58380 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x80d0
Pid: 4562, comm: ifconfig Tainted: G        W  2.6.32-rc4-00001-gd93a8f8-dirty #2
Call Trace:
 [<c0161034>] ? __alloc_pages_nodemask+0x43e/0x4a8
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0933b68>] ? e100_alloc_cbs+0xc0/0x16d [e100]
 [<d0934be9>] ? e100_up+0x1b/0xf5 [e100]
 [<d0934cda>] ? e100_open+0x17/0x41 [e100]
 [<c0305f11>] ? dev_open+0x8f/0xc5
 [<c03056d0>] ? dev_change_flags+0xa2/0x155
 [<c033c103>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c02f92be>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c01872da>] ? vfs_ioctl+0x16/0x4a
 [<c0187ba6>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfb3>] ? handle_mm_fault+0x214/0x462
 [<c0356e8e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187c09>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   0
active_anon:22485 inactive_anon:31175 isolated_anon:0
 active_file:1840 inactive_file:3750 isolated_file:0
 unevictable:0 dirty:24 writeback:2374 unstable:0 buffer:149
 free:1431 slab_reclaimable:675 slab_unreclaimable:1173
 mapped:2106 shmem:69 pagetables:509 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:5032kB inactive_anon:5116kB active_file:296kB inactive_file:364kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:300kB shmem:0kB slab_reclaimable:8kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:8kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:4648kB min:1908kB low:2384kB high:2860kB active_anon:84908kB inactive_anon:119584kB active_file:7064kB inactive_file:14636kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:96kB writeback:9496kB mapped:8124kB shmem:276kB slab_reclaimable:2692kB slab_unreclaimable:4652kB kernel_stack:464kB pagetables:2028kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 2*8kB 2*16kB 14*32kB 5*64kB 2*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 430*4kB 64*8kB 25*16kB 45*32kB 7*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4648kB
16003 total pagecache pages
10343 pages in swap cache
Swap cache stats: add 49019, delete 38676, find 32912/35144
Free swap  = 387940kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
6947 pages shared
58627 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x80d0
Pid: 4562, comm: ifconfig Tainted: G        W  2.6.32-rc4-00001-gd93a8f8-dirty #2
Call Trace:
 [<c0161034>] ? __alloc_pages_nodemask+0x43e/0x4a8
 [<c0104d7f>] ? dma_generic_alloc_coherent+0x4a/0xa7
 [<c0104d35>] ? dma_generic_alloc_coherent+0x0/0xa7
 [<d0933b68>] ? e100_alloc_cbs+0xc0/0x16d [e100]
 [<d0934be9>] ? e100_up+0x1b/0xf5 [e100]
 [<d0934cda>] ? e100_open+0x17/0x41 [e100]
 [<c0305f11>] ? dev_open+0x8f/0xc5
 [<c03056d0>] ? dev_change_flags+0xa2/0x155
 [<c033c103>] ? devinet_ioctl+0x22a/0x51b
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c02f92be>] ? sock_ioctl+0x1c0/0x1e4
 [<c02f90fe>] ? sock_ioctl+0x0/0x1e4
 [<c01872da>] ? vfs_ioctl+0x16/0x4a
 [<c0187ba6>] ? do_vfs_ioctl+0x48f/0x4c6
 [<c016dfb3>] ? handle_mm_fault+0x214/0x462
 [<c011c0a1>] ? finish_task_switch+0x23/0x61
 [<c0356e8e>] ? do_page_fault+0x2ce/0x2e4
 [<c0187c09>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:   0
active_anon:19062 inactive_anon:33723 isolated_anon:0
 active_file:1517 inactive_file:4598 isolated_file:0
 unevictable:0 dirty:26 writeback:2979 unstable:0 buffer:149
 free:1762 slab_reclaimable:670 slab_unreclaimable:1196
 mapped:1952 shmem:65 pagetables:509 bounce:0
DMA free:1076kB min:124kB low:152kB high:184kB active_anon:5032kB inactive_anon:5116kB active_file:296kB inactive_file:364kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15868kB mlocked:0kB dirty:0kB writeback:0kB mapped:300kB shmem:0kB slab_reclaimable:8kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:8kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:5972kB min:1908kB low:2384kB high:2860kB active_anon:71216kB inactive_anon:129776kB active_file:5772kB inactive_file:18028kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:243776kB mlocked:0kB dirty:104kB writeback:11916kB mapped:7508kB shmem:260kB slab_reclaimable:2672kB slab_unreclaimable:4744kB kernel_stack:464kB pagetables:2028kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 1*4kB 2*8kB 2*16kB 14*32kB 5*64kB 2*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1076kB
Normal: 423*4kB 45*8kB 47*16kB 61*32kB 19*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 5972kB
20642 total pagecache pages
14462 pages in swap cache
Swap cache stats: add 54216, delete 39754, find 33267/35545
Free swap  = 367980kB
Total swap = 514040kB
65520 pages RAM
1689 pages reserved
6413 pages shared
58337 pages non-shared
