From: Phil Sutter <phil@nwl.cc>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Fri, 4 Dec 2015 18:01:01 +0100
Message-ID: <20151204170101.GB29598@orbit.nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203125117.GB5505@gondor.apana.org.au>
 <1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151204143956.GA17471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151204143956.GA17471@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Dec 04, 2015 at 10:39:56PM +0800, Herbert Xu wrote:
> On Thu, Dec 03, 2015 at 08:08:39AM -0800, Eric Dumazet wrote:
> >
> > Anyway, __vmalloc() can be used with GFP_ATOMIC, have you tried this ?
> 
> OK I've tried it and I no longer get any ENOMEM errors!

I can't confirm this, sadly. Using 50 threads, results seem to be stable
and good. But increasing the number of threads I can provoke ENOMEM
condition again. See attached log which shows a failing test run with
100 threads.

I tried to extract logs of a test run with as few as possible failing
threads, but wasn't successful. It seems like the error amplifies
itself: While having stable success with less than 70 threads, going
beyond a margin I could not identify exactly, much more threads failed
than expected. For instance, the attached log shows 70 out of 100
threads failing, while for me every single test with 50 threads was
successful.

HTH, Phil

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="test_rhashtable_fail.log"

[ 5196.212230] Running rhashtable test nelem=8, max_size=0, shrinking=0
[ 5196.243846] Test 00:
[ 5196.245990]   Adding 50000 keys
[ 5196.250787] Info: encountered resize
[ 5196.251631] Info: encountered resize
[ 5196.252773] Info: encountered resize
[ 5196.256076]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=3
[ 5196.261961]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[ 5196.263282]   Deleting 50000 keys
[ 5196.267054]   Duration of test: 20359448 ns
[ 5196.267762] Test 01:
[ 5196.270278]   Adding 50000 keys
[ 5196.276804] Info: encountered resize
[ 5196.278164]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=1
[ 5196.287668]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[ 5196.289246]   Deleting 50000 keys
[ 5196.293725]   Duration of test: 22689015 ns
[ 5196.294902] Test 02:
[ 5196.297878]   Adding 50000 keys
[ 5196.305348] Info: encountered resize
[ 5196.306093] Info: encountered resize
[ 5196.306815] Info: encountered resize
[ 5196.307529] Info: encountered resize
[ 5196.308262] Info: encountered resize
[ 5196.308973] Info: encountered resize
[ 5196.309699] Info: encountered resize
[ 5196.310449] Info: encountered resize
[ 5196.311228] Info: encountered resize
[ 5196.311996] Info: encountered resize
[ 5196.312957] Info: encountered resize
[ 5196.314178] Info: encountered resize
[ 5196.318068]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=12
[ 5196.324140]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[ 5196.325661]   Deleting 50000 keys
[ 5196.338875]   Duration of test: 39997796 ns
[ 5196.339718] Test 03:
[ 5196.341610]   Adding 50000 keys
[ 5196.349677]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[ 5196.356153]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[ 5196.357704]   Deleting 50000 keys
[ 5196.362173]   Duration of test: 19844019 ns
[ 5196.363055] Average test time: 25722569
[ 5196.363815] Testing concurrent rhashtable access from 100 threads
[ 5196.684648] vmalloc: allocation failure, allocated 22126592 of 33562624 bytes
[ 5196.685195]   thread[87]: rhashtable_insert_fast failed
[ 5196.687075] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.687652] vmalloc: allocation failure, allocated 22245376 of 33562624 bytes
[ 5196.687653] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.687655] CPU: 1 PID: 12259 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.687656] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.687659]  0000000000000000 0000000025caf0f8 ffff88003094bc70 ffffffff81308384
[ 5196.687660]  0000000002088022 ffff88003094bd00 ffffffff8117b18c ffffffff81815d58
[ 5196.687661]  ffff88003094bc90 ffffffff00000018 ffff88003094bd10 ffff88003094bcb0
[ 5196.687661] Call Trace:
[ 5196.687667]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.687669]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.687673]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.687675]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.687677]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.687681]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.687682]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.687683]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.687684]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.687687]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.687689]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.687691]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.687693]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.687695]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.687697]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.687698]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.687700]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.687701]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.687702] Mem-Info:
[ 5196.687704] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:62 free_cma:0
[ 5196.687708] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.687709] lowmem_reserve[]: 0 976 976 976
[ 5196.687712] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:248kB local_pcp:160kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.687713] lowmem_reserve[]: 0 0 0 0
[ 5196.687719] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.687722] Node 0 DMA32: 30*4kB (UM) 37*8kB (UM) 16*16kB (M) 12*32kB (UM) 5*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.687723] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.687724] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.687724] 102666 total pagecache pages
[ 5196.687726] 12 pages in swap cache
[ 5196.687726] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.687726] Free swap  = 516408kB
[ 5196.687727] Total swap = 520188kB
[ 5196.687727] 262012 pages RAM
[ 5196.687728] 0 pages HighMem/MovableOnly
[ 5196.687728] 7768 pages reserved
[ 5196.687728] 0 pages cma reserved
[ 5196.687728] 0 pages hwpoisoned
[ 5196.688896]   thread[88]: rhashtable_insert_fast failed
[ 5196.691994] vmalloc: allocation failure, allocated 22286336 of 33562624 bytes
[ 5196.691995] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.691997] CPU: 1 PID: 12260 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.692006] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.692024]  0000000000000000 00000000f3c4a7e2 ffff88003094fc70 ffffffff81308384
[ 5196.692025]  0000000002088022 ffff88003094fd00 ffffffff8117b18c ffffffff81815d58
[ 5196.692026]  ffff88003094fc90 ffffffff00000018 ffff88003094fd10 ffff88003094fcb0
[ 5196.692027] Call Trace:
[ 5196.692032]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.692035]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.692038]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.692040]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.692042]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.692046]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.692047]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.692048]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.692050]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.692053]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.692054]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.692057]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.692058]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.692060]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.692062]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.692063]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.692065]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.692066]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.692067] Mem-Info:
[ 5196.692070] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:52 free_cma:0
[ 5196.692073] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.692074] lowmem_reserve[]: 0 976 976 976
[ 5196.692077] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:208kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.692078] lowmem_reserve[]: 0 0 0 0
[ 5196.692083] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.692086] Node 0 DMA32: 30*4kB (UM) 35*8kB (M) 13*16kB (M) 12*32kB (UM) 6*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.692088] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.692088] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.692089] 102666 total pagecache pages
[ 5196.692090] 12 pages in swap cache
[ 5196.692090] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.692091] Free swap  = 516408kB
[ 5196.692091] Total swap = 520188kB
[ 5196.692091] 262012 pages RAM
[ 5196.692092] 0 pages HighMem/MovableOnly
[ 5196.692092] 7768 pages reserved
[ 5196.692092] 0 pages cma reserved
[ 5196.692092] 0 pages hwpoisoned
[ 5196.692689]   thread[89]: rhashtable_insert_fast failed
[ 5196.695065] vmalloc: allocation failure, allocated 22228992 of 33562624 bytes
[ 5196.695066] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.695068] CPU: 1 PID: 12261 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.695069] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.695071]  0000000000000000 000000000d036016 ffff8800096fbc70 ffffffff81308384
[ 5196.695072]  0000000002088022 ffff8800096fbd00 ffffffff8117b18c ffffffff81815d58
[ 5196.695073]  ffff8800096fbc90 ffffffff00000018 ffff8800096fbd10 ffff8800096fbcb0
[ 5196.695073] Call Trace:
[ 5196.695079]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.695081]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.695085]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.695087]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.695089]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.695093]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.695094]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.695095]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.695096]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.695099]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.695101]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.695103]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.695105]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.695106]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.695108]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.695110]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.695111]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.695112]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.695113] Mem-Info:
[ 5196.695115] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:66 free_cma:0
[ 5196.695119] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.695120] lowmem_reserve[]: 0 976 976 976
[ 5196.695123] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:264kB local_pcp:176kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.695124] lowmem_reserve[]: 0 0 0 0
[ 5196.695129] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.695132] Node 0 DMA32: 30*4kB (UM) 37*8kB (UM) 16*16kB (UM) 10*32kB (M) 6*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.695133] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.695134] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.695134] 102666 total pagecache pages
[ 5196.695135] 12 pages in swap cache
[ 5196.695136] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.695136] Free swap  = 516408kB
[ 5196.695136] Total swap = 520188kB
[ 5196.695137] 262012 pages RAM
[ 5196.695137] 0 pages HighMem/MovableOnly
[ 5196.695137] 7768 pages reserved
[ 5196.695137] 0 pages cma reserved
[ 5196.695138] 0 pages hwpoisoned
[ 5196.696538]   thread[90]: rhashtable_insert_fast failed
[ 5196.699063] vmalloc: allocation failure, allocated 22286336 of 33562624 bytes
[ 5196.699064] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.699066] CPU: 1 PID: 12262 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.699067] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.699070]  0000000000000000 00000000345b8f15 ffff8800096ffc70 ffffffff81308384
[ 5196.699071]  0000000002088022 ffff8800096ffd00 ffffffff8117b18c ffffffff81815d58
[ 5196.699072]  ffff8800096ffc90 ffffffff00000018 ffff8800096ffd10 ffff8800096ffcb0
[ 5196.699072] Call Trace:
[ 5196.699077]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.699080]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.699083]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.699085]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.699087]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.699091]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.699092]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.699093]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.699095]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.699097]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.699099]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.699101]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.699103]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.699104]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.699107]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.699108]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.699110]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.699111]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.699111] Mem-Info:
[ 5196.699114] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:52 free_cma:0
[ 5196.699118] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.699119] lowmem_reserve[]: 0 976 976 976
[ 5196.699122] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:208kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.699123] lowmem_reserve[]: 0 0 0 0
[ 5196.699128] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.699131] Node 0 DMA32: 30*4kB (UM) 35*8kB (M) 15*16kB (UM) 11*32kB (UM) 4*64kB (M) 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.699132] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.699133] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.699134] 102666 total pagecache pages
[ 5196.699134] 12 pages in swap cache
[ 5196.699135] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.699135] Free swap  = 516408kB
[ 5196.699136] Total swap = 520188kB
[ 5196.699136] 262012 pages RAM
[ 5196.699136] 0 pages HighMem/MovableOnly
[ 5196.699136] 7768 pages reserved
[ 5196.699137] 0 pages cma reserved
[ 5196.699137] 0 pages hwpoisoned
[ 5196.699733]   thread[91]: rhashtable_insert_fast failed
[ 5196.702130] vmalloc: allocation failure, allocated 22257664 of 33562624 bytes
[ 5196.702131] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.702132] CPU: 1 PID: 12263 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.702133] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.702135]  0000000000000000 00000000ada2b9fc ffff880009143c70 ffffffff81308384
[ 5196.702136]  0000000002088022 ffff880009143d00 ffffffff8117b18c ffffffff81815d58
[ 5196.702137]  ffff880009143c90 ffffffff00000018 ffff880009143d10 ffff880009143cb0
[ 5196.702138] Call Trace:
[ 5196.702143]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.702145]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.702148]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.702151]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.702152]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.702156]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.702157]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.702159]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.702160]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.702163]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.702164]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.702167]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.702168]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.702170]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.702173]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.702174]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.702175]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.702176]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.702177] Mem-Info:
[ 5196.702180] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:59 free_cma:0
[ 5196.702183] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.702184] lowmem_reserve[]: 0 976 976 976
[ 5196.702187] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:236kB local_pcp:148kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.702188] lowmem_reserve[]: 0 0 0 0
[ 5196.702193] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.702197] Node 0 DMA32: 30*4kB (UM) 35*8kB (M) 15*16kB (UM) 11*32kB (UM) 4*64kB (M) 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.702198] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.702198] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.702199] 102666 total pagecache pages
[ 5196.702200] 12 pages in swap cache
[ 5196.702200] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.702201] Free swap  = 516408kB
[ 5196.702201] Total swap = 520188kB
[ 5196.702201] 262012 pages RAM
[ 5196.702201] 0 pages HighMem/MovableOnly
[ 5196.702202] 7768 pages reserved
[ 5196.702202] 0 pages cma reserved
[ 5196.702202] 0 pages hwpoisoned
[ 5196.703408]   thread[92]: rhashtable_insert_fast failed
[ 5196.705758] vmalloc: allocation failure, allocated 22274048 of 33562624 bytes
[ 5196.705759] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.705761] CPU: 1 PID: 12264 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.705761] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.705763]  0000000000000000 00000000968be9a7 ffff880009147c70 ffffffff81308384
[ 5196.705764]  0000000002088022 ffff880009147d00 ffffffff8117b18c ffffffff81815d58
[ 5196.705765]  ffff880009147c90 ffffffff00000018 ffff880009147d10 ffff880009147cb0
[ 5196.705766] Call Trace:
[ 5196.705770]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.705773]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.705777]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.705779]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.705781]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.705785]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.705786]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.705787]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.705789]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.705791]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.705793]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.705795]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.705797]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.705798]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.705801]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.705802]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.705804]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.705805]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.705806] Mem-Info:
[ 5196.705808] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:55 free_cma:0
[ 5196.705812] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.705813] lowmem_reserve[]: 0 976 976 976
[ 5196.705816] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:132kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.705816] lowmem_reserve[]: 0 0 0 0
[ 5196.705821] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.705825] Node 0 DMA32: 30*4kB (M) 37*8kB (M) 18*16kB (UM) 13*32kB (UM) 4*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.705830] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.705831] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.705831] 102666 total pagecache pages
[ 5196.705832] 12 pages in swap cache
[ 5196.705832] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.705834] Free swap  = 516408kB
[ 5196.705834] Total swap = 520188kB
[ 5196.705834] 262012 pages RAM
[ 5196.705835] 0 pages HighMem/MovableOnly
[ 5196.705835] 7768 pages reserved
[ 5196.705835] 0 pages cma reserved
[ 5196.705836] 0 pages hwpoisoned
[ 5196.706493]   thread[93]: rhashtable_insert_fast failed
[ 5196.708940] vmalloc: allocation failure, allocated 22282240 of 33562624 bytes
[ 5196.708941] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.708943] CPU: 1 PID: 12265 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.708943] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.708945]  0000000000000000 00000000f4d21571 ffff88000914bc70 ffffffff81308384
[ 5196.708946]  0000000002088022 ffff88000914bd00 ffffffff8117b18c ffffffff81815d58
[ 5196.708947]  ffff88000914bc90 ffffffff00000018 ffff88000914bd10 ffff88000914bcb0
[ 5196.708947] Call Trace:
[ 5196.708952]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.708955]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.708958]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.708960]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.708962]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.708966]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.708967]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.708969]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.708970]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.708972]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.708974]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.708977]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.708978]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.708979]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.708982]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.708983]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.708985]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.708986]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.708987] Mem-Info:
[ 5196.708989] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:53 free_cma:0
[ 5196.708993] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.708994] lowmem_reserve[]: 0 976 976 976
[ 5196.708997] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:212kB local_pcp:124kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.708997] lowmem_reserve[]: 0 0 0 0
[ 5196.709021] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.709024] Node 0 DMA32: 30*4kB (UM) 35*8kB (M) 13*16kB (M) 14*32kB (UM) 5*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.709026] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.709026] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.709027] 102666 total pagecache pages
[ 5196.709027] 12 pages in swap cache
[ 5196.709028] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.709028] Free swap  = 516408kB
[ 5196.709029] Total swap = 520188kB
[ 5196.709029] 262012 pages RAM
[ 5196.709030] 0 pages HighMem/MovableOnly
[ 5196.709030] 7768 pages reserved
[ 5196.709030] 0 pages cma reserved
[ 5196.709031] 0 pages hwpoisoned
[ 5196.710116]   thread[94]: rhashtable_insert_fast failed
[ 5196.712572] vmalloc: allocation failure, allocated 22233088 of 33562624 bytes
[ 5196.712573] rhashtable_thra: page allocation failure: order:0, mode:0x2088022
[ 5196.712575] CPU: 1 PID: 12266 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5196.712576] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5196.712578]  0000000000000000 00000000b3f81fc2 ffff88000914fc70 ffffffff81308384
[ 5196.712579]  0000000002088022 ffff88000914fd00 ffffffff8117b18c ffffffff81815d58
[ 5196.712580]  ffff88000914fc90 ffffffff00000018 ffff88000914fd10 ffff88000914fcb0
[ 5196.712581] Call Trace:
[ 5196.712587]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5196.712590]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5196.712593]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5196.712595]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5196.712597]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.712601]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5196.712603]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5196.712604]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5196.712605]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5196.712608]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5196.712610]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5196.712612]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5196.712614]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.712615]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5196.712618]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5196.712619]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.712621]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5196.712622]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5196.712623] Mem-Info:
[ 5196.712625] active_anon:16125 inactive_anon:16714 isolated_anon:0
 active_file:36543 inactive_file:53278 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13060 shmem:12833 pagetables:1159 bounce:0
 free:1325 free_pcp:65 free_cma:0
[ 5196.712629] Node 0 DMA free:3924kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.712630] lowmem_reserve[]: 0 976 976 976
[ 5196.712633] Node 0 DMA32 free:1376kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66756kB active_file:146156kB inactive_file:213108kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52216kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:260kB local_pcp:172kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5196.712634] lowmem_reserve[]: 0 0 0 0
[ 5196.712639] Node 0 DMA: 13*4kB (ME) 14*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3924kB
[ 5196.712642] Node 0 DMA32: 30*4kB (M) 37*8kB (UM) 16*16kB (UM) 10*32kB (M) 6*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1376kB
[ 5196.712643] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5196.712644] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5196.712644] 102666 total pagecache pages
[ 5196.712645] 12 pages in swap cache
[ 5196.712646] Swap cache stats: add 1016, delete 1004, find 47/51
[ 5196.712646] Free swap  = 516408kB
[ 5196.712646] Total swap = 520188kB
[ 5196.712647] 262012 pages RAM
[ 5196.712647] 0 pages HighMem/MovableOnly
[ 5196.712647] 7768 pages reserved
[ 5196.712648] 0 pages cma reserved
[ 5196.712648] 0 pages hwpoisoned
[ 5196.713212]   thread[95]: rhashtable_insert_fast failed
[ 5196.716459]   thread[96]: rhashtable_insert_fast failed
[ 5196.719448]   thread[97]: rhashtable_insert_fast failed
[ 5196.723918]   thread[98]: rhashtable_insert_fast failed
[ 5196.727070]   thread[38]: rhashtable_insert_fast failed
[ 5196.732398]   thread[39]: rhashtable_insert_fast failed
[ 5196.735329]   thread[40]: rhashtable_insert_fast failed
[ 5196.740134]   thread[41]: rhashtable_insert_fast failed
[ 5196.743129]   thread[42]: rhashtable_insert_fast failed
[ 5196.748780]   thread[43]: rhashtable_insert_fast failed
[ 5196.751713]   thread[44]: rhashtable_insert_fast failed
[ 5196.756309]   thread[45]: rhashtable_insert_fast failed
[ 5196.759367]   thread[46]: rhashtable_insert_fast failed
[ 5196.762669]   thread[47]: rhashtable_insert_fast failed
[ 5196.765906]   thread[48]: rhashtable_insert_fast failed
[ 5196.769524]   thread[49]: rhashtable_insert_fast failed
[ 5196.772589]   thread[50]: rhashtable_insert_fast failed
[ 5196.776017]   thread[51]: rhashtable_insert_fast failed
[ 5196.779027]   thread[52]: rhashtable_insert_fast failed
[ 5196.782691]   thread[54]: rhashtable_insert_fast failed
[ 5196.786214]   thread[55]: rhashtable_insert_fast failed
[ 5196.790425]   thread[62]: rhashtable_insert_fast failed
[ 5196.793342]   thread[63]: rhashtable_insert_fast failed
[ 5196.796981]   thread[64]: rhashtable_insert_fast failed
[ 5196.800092]   thread[65]: rhashtable_insert_fast failed
[ 5196.803677]   thread[66]: rhashtable_insert_fast failed
[ 5196.806786]   thread[67]: rhashtable_insert_fast failed
[ 5196.811311]   thread[68]: rhashtable_insert_fast failed
[ 5196.814568]   thread[69]: rhashtable_insert_fast failed
[ 5196.819452]   thread[70]: rhashtable_insert_fast failed
[ 5196.824151]   thread[30]: rhashtable_insert_fast failed
[ 5196.828553]   thread[31]: rhashtable_insert_fast failed
[ 5196.831653]   thread[32]: rhashtable_insert_fast failed
[ 5196.834548]   thread[33]: rhashtable_insert_fast failed
[ 5196.837353]   thread[34]: rhashtable_insert_fast failed
[ 5196.840583]   thread[35]: rhashtable_insert_fast failed
[ 5196.843205]   thread[36]: rhashtable_insert_fast failed
[ 5196.846480]   thread[37]: rhashtable_insert_fast failed
[ 5196.849272]   thread[56]: rhashtable_insert_fast failed
[ 5196.853540]   thread[57]: rhashtable_insert_fast failed
[ 5196.867733]   thread[99]: rhashtable_insert_fast failed
[ 5196.882680]   thread[78]: rhashtable_insert_fast failed
[ 5196.885508]   thread[58]: rhashtable_insert_fast failed
[ 5196.888540]   thread[59]: rhashtable_insert_fast failed
[ 5196.891599]   thread[60]: rhashtable_insert_fast failed
[ 5196.895137]   thread[61]: rhashtable_insert_fast failed
[ 5196.906544]   thread[77]: rhashtable_insert_fast failed
[ 5196.912459]   thread[28]: rhashtable_insert_fast failed
[ 5196.915968]   thread[86]: rhashtable_insert_fast failed
[ 5196.920906]   thread[81]: rhashtable_insert_fast failed
[ 5196.924751]   thread[84]: rhashtable_insert_fast failed
[ 5196.929254]   thread[79]: rhashtable_insert_fast failed
[ 5196.933818]   thread[72]: rhashtable_insert_fast failed
[ 5196.938357]   thread[74]: rhashtable_insert_fast failed
[ 5196.941435]   thread[80]: rhashtable_insert_fast failed
[ 5196.944989]   thread[71]: rhashtable_insert_fast failed
[ 5196.948319]   thread[83]: rhashtable_insert_fast failed
[ 5196.952994]   thread[82]: rhashtable_insert_fast failed
[ 5196.955952]   thread[75]: rhashtable_insert_fast failed
[ 5196.959954]   thread[73]: rhashtable_insert_fast failed
[ 5196.962849]   thread[85]: rhashtable_insert_fast failed
[ 5196.967296]   thread[27]: rhashtable_insert_fast failed
[ 5197.388390] CPU: 0 PID: 12200 Comm: rhashtable_thra Not tainted 4.4.0-rc1rhashtable+ #141
[ 5197.390022] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
[ 5197.392029]  0000000000000000 0000000067bc472b ffff880005ab7c70 ffffffff81308384
[ 5197.393658]  0000000002088022 ffff880005ab7d00 ffffffff8117b18c ffffffff81815d58
[ 5197.395253]  ffff880005ab7c90 ffffffff00000018 ffff880005ab7d10 ffff880005ab7cb0
[ 5197.396868] Call Trace:
[ 5197.397512]  [<ffffffff81308384>] dump_stack+0x44/0x60
[ 5197.398463]  [<ffffffff8117b18c>] warn_alloc_failed+0xfc/0x170
[ 5197.399488]  [<ffffffff811c7b4c>] ? alloc_pages_current+0x8c/0x110
[ 5197.400587]  [<ffffffff811b5eae>] __vmalloc_node_range+0x18e/0x290
[ 5197.401685]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5197.402729]  [<ffffffff811b5ffa>] __vmalloc+0x4a/0x50
[ 5197.403661]  [<ffffffff8131f10a>] ? bucket_table_alloc+0x4a/0xf0
[ 5197.404702]  [<ffffffff8131f10a>] bucket_table_alloc+0x4a/0xf0
[ 5197.405744]  [<ffffffff8131f61d>] rhashtable_insert_rehash+0x5d/0xe0
[ 5197.406840]  [<ffffffffa14e4567>] insert_retry.isra.9.constprop.15+0x177/0x270 [test_rhashtable]
[ 5197.417389]  [<ffffffffa14e4706>] threadfunc+0xa6/0x38e [test_rhashtable]
[ 5197.418579]  [<ffffffff815dd28c>] ? __schedule+0x2ac/0x920
[ 5197.419574]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5197.421283]  [<ffffffffa14e4660>] ? insert_retry.isra.9.constprop.15+0x270/0x270 [test_rhashtable]
[ 5197.423014]  [<ffffffff81093ec8>] kthread+0xd8/0xf0
[ 5197.423933]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5197.424911]  [<ffffffff815e1acf>] ret_from_fork+0x3f/0x70
[ 5197.425935]  [<ffffffff81093df0>] ? kthread_park+0x60/0x60
[ 5197.426920] Mem-Info:
[ 5197.427542] active_anon:16125 inactive_anon:16748 isolated_anon:0
 active_file:36543 inactive_file:49042 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0
 slab_reclaimable:6154 slab_unreclaimable:7835
 mapped:13110 shmem:12833 pagetables:1159 bounce:0
 free:2567 free_pcp:160 free_cma:0
[ 5197.433457] Node 0 DMA free:3964kB min:60kB low:72kB high:88kB active_anon:36kB inactive_anon:100kB active_file:16kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:24kB shmem:16kB slab_reclaimable:364kB slab_unreclaimable:644kB kernel_stack:16kB pagetables:116kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5197.440780] lowmem_reserve[]: 0 976 976 976
[ 5197.441714] Node 0 DMA32 free:6304kB min:3828kB low:4784kB high:5740kB active_anon:64464kB inactive_anon:66892kB active_file:146156kB inactive_file:196164kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1032056kB managed:1001068kB mlocked:0kB dirty:0kB writeback:0kB mapped:52416kB shmem:51316kB slab_reclaimable:24252kB slab_unreclaimable:30696kB kernel_stack:3568kB pagetables:4520kB unstable:0kB bounce:0kB free_pcp:640kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 5197.450137] lowmem_reserve[]: 0 0 0 0
[ 5197.450991] Node 0 DMA: 15*4kB (UME) 18*8kB (UME) 13*16kB (ME) 11*32kB (UME) 10*64kB (UME) 6*128kB (ME) 3*256kB (ME) 2*512kB (UE) 0*1024kB 0*2048kB 0*4096kB = 3964kB
[ 5197.454161] Node 0 DMA32: 224*4kB (UME) 123*8kB (ME) 52*16kB (ME) 36*32kB (UM) 15*64kB (UM) 6*128kB (M) 3*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6360kB
[ 5197.457185] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 5197.458914] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 5197.460587] 98441 total pagecache pages
[ 5197.461382] 19 pages in swap cache
[ 5197.462117] Swap cache stats: add 1062, delete 1043, find 85/100
[ 5197.463488] Free swap  = 517456kB
[ 5197.464266] Total swap = 520188kB
[ 5197.464976] 262012 pages RAM
[ 5197.465652] 0 pages HighMem/MovableOnly
[ 5197.466448] 7768 pages reserved
[ 5197.467153] 0 pages cma reserved
[ 5197.467858] 0 pages hwpoisoned
[ 5199.067127] Test failed: thread 27 returned: -12
[ 5199.067909] Test failed: thread 28 returned: -12
[ 5199.073703] Test failed: thread 30 returned: -12
[ 5199.074493] Test failed: thread 31 returned: -12
[ 5199.075323] Test failed: thread 32 returned: -12
[ 5199.076242] Test failed: thread 33 returned: -12
[ 5199.077090] Test failed: thread 34 returned: -12
[ 5199.077855] Test failed: thread 35 returned: -12
[ 5199.078626] Test failed: thread 36 returned: -12
[ 5199.079478] Test failed: thread 37 returned: -12
[ 5199.080286] Test failed: thread 38 returned: -12
[ 5199.080983] Test failed: thread 39 returned: -12
[ 5199.081750] Test failed: thread 40 returned: -12
[ 5199.082536] Test failed: thread 41 returned: -12
[ 5199.083351] Test failed: thread 42 returned: -12
[ 5199.084135] Test failed: thread 43 returned: -12
[ 5199.084836] Test failed: thread 44 returned: -12
[ 5199.085595] Test failed: thread 45 returned: -12
[ 5199.086621] Test failed: thread 46 returned: -12
[ 5199.087417] Test failed: thread 47 returned: -12
[ 5199.088178] Test failed: thread 48 returned: -12
[ 5199.088917] Test failed: thread 49 returned: -12
[ 5199.089749] Test failed: thread 50 returned: -12
[ 5199.090570] Test failed: thread 51 returned: -12
[ 5199.091392] Test failed: thread 52 returned: -12
[ 5199.092406] Test failed: thread 54 returned: -12
[ 5199.093378] Test failed: thread 55 returned: -12
[ 5199.094385] Test failed: thread 56 returned: -12
[ 5199.095784] Test failed: thread 57 returned: -12
[ 5199.096749] Test failed: thread 58 returned: -12
[ 5199.097722] Test failed: thread 59 returned: -12
[ 5199.098622] Test failed: thread 60 returned: -12
[ 5199.099415] Test failed: thread 61 returned: -12
[ 5199.100230] Test failed: thread 62 returned: -12
[ 5199.100942] Test failed: thread 63 returned: -12
[ 5199.101743] Test failed: thread 64 returned: -12
[ 5199.102568] Test failed: thread 65 returned: -12
[ 5199.103717] Test failed: thread 66 returned: -12
[ 5199.104703] Test failed: thread 67 returned: -12
[ 5199.105510] Test failed: thread 68 returned: -12
[ 5199.106404] Test failed: thread 69 returned: -12
[ 5199.107268] Test failed: thread 70 returned: -12
[ 5199.108522] Test failed: thread 71 returned: -12
[ 5199.109319] Test failed: thread 72 returned: -12
[ 5199.110119] Test failed: thread 73 returned: -12
[ 5199.110822] Test failed: thread 74 returned: -12
[ 5199.111610] Test failed: thread 75 returned: -12
[ 5199.112444] Test failed: thread 77 returned: -12
[ 5199.113243] Test failed: thread 78 returned: -12
[ 5199.113979] Test failed: thread 79 returned: -12
[ 5199.114769] Test failed: thread 80 returned: -12
[ 5199.115564] Test failed: thread 81 returned: -12
[ 5199.116390] Test failed: thread 82 returned: -12
[ 5199.117199] Test failed: thread 83 returned: -12
[ 5199.117912] Test failed: thread 84 returned: -12
[ 5199.118717] Test failed: thread 85 returned: -12
[ 5199.119514] Test failed: thread 86 returned: -12
[ 5199.120727] Test failed: thread 87 returned: -12
[ 5199.121623] Test failed: thread 88 returned: -12
[ 5199.122486] Test failed: thread 89 returned: -12
[ 5199.123291] Test failed: thread 90 returned: -12
[ 5199.124119] Test failed: thread 91 returned: -12
[ 5199.125438] Test failed: thread 92 returned: -12
[ 5199.126270] Test failed: thread 93 returned: -12
[ 5199.127083] Test failed: thread 94 returned: -12
[ 5199.127795] Test failed: thread 95 returned: -12
[ 5199.128602] Test failed: thread 96 returned: -12
[ 5199.129419] Test failed: thread 97 returned: -12
[ 5199.130211] Test failed: thread 98 returned: -12
[ 5199.130913] Test failed: thread 99 returned: -12
[ 5199.131615] Started 100 threads, 70 failed

--0OAP2g/MAC+5xKAE--
