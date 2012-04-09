From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big network copies (page allocation failure)
Date: Mon, 9 Apr 2012 10:20:51 -0700
Message-ID: <20120409172051.GR32290@merlins.org>
References: <20120329163800.GH24933@merlins.org> <1333044575.2656.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:56245 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab2DIRUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 13:20:53 -0400
Content-Disposition: inline
In-Reply-To: <1333044575.2656.1.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 29, 2012 at 07:09:35PM +0100, Ben Hutchings wrote:
> On Thu, 2012-03-29 at 09:38 -0700, Marc MERLIN wrote:
> [...]
> > Below are some sysreq dumps I took (syslog to local disk was still
> > working fine). I know I have Tainted 'G', and I have no idea where that
> > came from, sorry :-/
> [...]
> 
> 'G' isn't a taint flag, but the following 'O' is; it means you have one
> or more out-of-tree modules loaded.  Care to tell us what they are?

Ok, I just had time to reproduce this without tainting. It was with 3.2.5
though since I'm debugging a battery power use issue too.

I confirmed that the problem only happens when I do NFS copies. Doing the
same copy with rsync over SSH works fine.

I'm not much of a kernel guy, but it looks like there is a memory problem,
which in turn causes the network driver to deadlock waiting on RAM with 
interrupts turned off (mouse cursor won't move). Eventually it gets a bit of
the special RAM it seems to need, at that point, my frozen mouse pointer
unfreezes until it locks again soon after.

So there are 2 problems
1) memory issue
2) driver waits for RAM with interrupts turned off

The log below shows offlineimap first getting memory allocation problems
as soon after I start the copy, then firefox, and some:
ieee80211 phy0: failed to reallocate TX buffer

No taint flags this time.
I'll paste a few lines below.

Any idea what's going on, what bucket of RAM is an issue for the driver
(total RAM is more than plenty), and where I should go from there?

kernel config: http://marc.merlins.org/tmp/config.txt

Thanks,
Marc

09:44:12  offlineimap: page allocation failure: order:1, mode:0x20
09:44:12  Pid: 6269, comm: offlineimap Tainted: G           O 3.2.5amd64-volpreempt-noide-20120208 #1
09:44:12  Call Trace:
09:44:12   <IRQ>  [<ffffffff810b755a>] ? warn_alloc_failed+0x11a/0x12d
09:44:12   [<ffffffff810ba394>] ? __alloc_pages_nodemask+0x6b2/0x726
09:44:12   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:12   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:12   [<ffffffff810ea421>] ? fallback_alloc+0x123/0x1c2
09:44:12   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:12   [<ffffffff810ea923>] ? __kmalloc+0xba/0x112
09:44:12   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:12   [<ffffffffa07a81c0>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
09:44:12   [<ffffffffa07aa087>] ? ieee80211_subif_start_xmit+0x68e/0x80c [mac80211]
09:44:12   [<ffffffffa07922c8>] ? ieee80211_tx_status_irqsafe+0x2e/0x7f [mac80211]
09:44:12   [<ffffffff812877f3>] ? dev_hard_start_xmit+0x3fc/0x543
09:44:12   [<ffffffff81070551>] ? arch_local_irq_save+0x11/0x17
09:44:12   [<ffffffff8129da01>] ? sch_direct_xmit+0x5e/0x12f
09:44:12   [<ffffffff8129dbc9>] ? __qdisc_run+0xf7/0x10f
09:44:12   [<ffffffff81282d56>] ? net_tx_action+0xf1/0x128
09:44:12   [<ffffffff8104bc88>] ? __do_softirq+0xb9/0x177
09:44:12   [<ffffffff81065863>] ? timekeeping_get_ns+0xd/0x2a
09:44:12   [<ffffffff81349dac>] ? call_softirq+0x1c/0x30
09:44:12   [<ffffffff8100f875>] ? do_softirq+0x3c/0x7b
09:44:12   [<ffffffff8104bef0>] ? irq_exit+0x3c/0x9a
09:44:12   [<ffffffff8100f5a5>] ? do_IRQ+0x82/0x98
09:44:12   [<ffffffff81342e2e>] ? common_interrupt+0x6e/0x6e
09:44:12   <EOI>  [<ffffffff81061e33>] ? hrtimer_cancel+0xc/0x16
09:44:12   [<ffffffff8110629a>] ? select_estimate_accuracy+0xcf/0xed
09:44:12   [<ffffffff8110629a>] ? select_estimate_accuracy+0xcf/0xed
09:44:12   [<ffffffff81106464>] ? do_select+0x13c/0x46a
09:44:12   [<ffffffff81034a8c>] ? walk_tg_tree_from+0x70/0x99
09:44:12   [<ffffffff811060ab>] ? poll_freewait+0x97/0x97
09:44:12   [<ffffffff8103a520>] ? update_curr+0xd0/0xf5
09:44:12   [<ffffffff8100d758>] ? __switch_to+0x1fc/0x20e
09:44:12   [<ffffffff8103ac9c>] ? dequeue_entity+0x13e/0x161
09:44:12   [<ffffffff8103891c>] ? finish_task_switch+0x88/0xb9
09:44:12   [<ffffffff813417fc>] ? __schedule+0x5ac/0x5c3
09:44:12   [<ffffffff8106c902>] ? get_futex_value_locked+0x2d/0x3d
09:44:12   [<ffffffff810349f1>] ? set_task_rq+0x23/0x35
09:44:12   [<ffffffff81035ef0>] ? cpumask_next+0x17/0x1a
09:44:12   [<ffffffff8104073f>] ? select_task_rq_fair+0x435/0x67e
09:44:12   [<ffffffff8101353d>] ? paravirt_read_tsc+0x5/0x8
09:44:12   [<ffffffff81013999>] ? native_sched_clock+0x27/0x2f
09:44:12   [<ffffffff810139a6>] ? sched_clock+0x5/0x8
09:44:12   [<ffffffff810634b0>] ? sched_clock_local+0xd/0x6f
09:44:12   [<ffffffff81026aa4>] ? _flat_send_IPI_mask+0x68/0x78
09:44:12   [<ffffffff8103f175>] ? try_to_wake_up+0x187/0x196
09:44:12   [<ffffffff81106907>] ? core_sys_select+0x175/0x21a
09:44:12   [<ffffffff8106e85a>] ? do_futex+0xab/0x7ed
09:44:12   [<ffffffff8104afef>] ? timespec_add_safe+0x32/0x63
09:44:12   [<ffffffff81028a44>] ? read_hpet+0xd/0x10
09:44:12   [<ffffffff81065863>] ? timekeeping_get_ns+0xd/0x2a
09:44:12   [<ffffffff81106a34>] ? sys_select+0x88/0xad
09:44:12   [<ffffffff81347b52>] ? system_call_fastpath+0x16/0x1b
09:44:12  Mem-Info:
09:44:12  Node 0 DMA per-cpu:
09:44:12  CPU    0: hi:    0, btch:   1 usd:   0
09:44:12  CPU    1: hi:    0, btch:   1 usd:   0
09:44:12  Node 0 DMA32 per-cpu:
09:44:12  CPU    0: hi:  186, btch:  31 usd:  96
09:44:12  CPU    1: hi:  186, btch:  31 usd:  61
09:44:12  Node 0 Normal per-cpu:
09:44:12  CPU    0: hi:  186, btch:  31 usd: 178
09:44:12  CPU    1: hi:  186, btch:  31 usd:  37
09:44:12  active_anon:992922 inactive_anon:263416 isolated_anon:0
09:44:12   active_file:59734 inactive_file:529995 isolated_file:0
09:44:12   unevictable:1 dirty:52839 writeback:339893 unstable:7544
09:44:12   free:55501 slab_reclaimable:33311 slab_unreclaimable:30518
09:44:12   mapped:18500 shmem:43519 pagetables:21479 bounce:0
09:44:12  Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
09:44:12  lowmem_reserve[]: 0 2960 7947 7947
09:44:12  Node 0 DMA32 free:153280kB min:25128kB low:31408kB high:37692kB active_anon:1579176kB inactive_anon:524080kB active_file:33708kB inactive_file:618072kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:81192kB writeback:322428kB mapped:6704kB shmem:67068kB slab_reclaimable:41408kB slab_unreclaimable:30268kB kernel_stack:2216kB pagetables:24408kB unstable:10048kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:12  lowmem_reserve[]: 0 0 4986 4986
09:44:12  Node 0 Normal free:52816kB min:42324kB low:52904kB high:63484kB active_anon:2392512kB inactive_anon:529584kB active_file:205228kB inactive_file:1501908kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:5106560kB mlocked:4kB dirty:130164kB writeback:1037144kB mapped:67296kB shmem:107008kB slab_reclaimable:91836kB slab_unreclaimable:91804kB kernel_stack:4216kB pagetables:61508kB unstable:20128kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:12  lowmem_reserve[]: 0 0 0 0
09:44:12  Node 0 DMA: 1*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15908kB
09:44:12  Node 0 DMA32: 37156*4kB 0*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 153280kB
09:44:12  Node 0 Normal: 12180*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 52816kB
09:44:12  676507 total pagecache pages
09:44:12  43251 pages in swap cache
09:44:12  Swap cache stats: add 803319, delete 760068, find 297792/318561
09:44:12  Free swap  = 1763732kB
09:44:12  Total swap = 4106248kB
09:44:12  2080752 pages RAM
09:44:12  57163 pages reserved
09:44:12  988140 pages shared
09:44:12  1496507 pages non-shared
09:44:12  ieee80211 phy0: failed to reallocate TX buffer
09:44:12  kworker/0:1: page allocation failure: order:1, mode:0x20
09:44:12  Pid: 8162, comm: kworker/0:1 Tainted: G           O 3.2.5amd64-volpreempt-noide-20120208 #1
09:44:12  Call Trace:
09:44:12   <IRQ>  [<ffffffff810b755a>] ? warn_alloc_failed+0x11a/0x12d
09:44:12   [<ffffffff810ba394>] ? __alloc_pages_nodemask+0x6b2/0x726
09:44:12   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:12   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:12   [<ffffffff810ea421>] ? fallback_alloc+0x123/0x1c2
09:44:12   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:12   [<ffffffff810ea923>] ? __kmalloc+0xba/0x112
09:44:12   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:12   [<ffffffffa07a81c0>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
09:44:12   [<ffffffffa07aa087>] ? ieee80211_subif_start_xmit+0x68e/0x80c [mac80211]
09:44:12   [<ffffffffa07922c8>] ? ieee80211_tx_status_irqsafe+0x2e/0x7f [mac80211]
09:44:12   [<ffffffff812877f3>] ? dev_hard_start_xmit+0x3fc/0x543
09:44:12   [<ffffffff81070551>] ? arch_local_irq_save+0x11/0x17
09:44:12   [<ffffffff8129da01>] ? sch_direct_xmit+0x5e/0x12f
09:44:12   [<ffffffff8129dbc9>] ? __qdisc_run+0xf7/0x10f
09:44:12   [<ffffffff81282d56>] ? net_tx_action+0xf1/0x128
09:44:12   [<ffffffff8104bc88>] ? __do_softirq+0xb9/0x177
09:44:12   [<ffffffff8103a946>] ? check_preempt_wakeup+0x10c/0x18e
09:44:12   [<ffffffff81349dac>] ? call_softirq+0x1c/0x30
09:44:12   [<ffffffff8100f875>] ? do_softirq+0x3c/0x7b
09:44:12   [<ffffffff8104bef0>] ? irq_exit+0x3c/0x9a
09:44:12   [<ffffffff8100f5a5>] ? do_IRQ+0x82/0x98
09:44:12   [<ffffffff81342e2e>] ? common_interrupt+0x6e/0x6e
09:44:12   <EOI>  [<ffffffffa0089052>] ? dec128+0x15a/0x80c [aes_x86_64]
09:44:12   [<ffffffff8118f263>] ? crypto_cbc_decrypt_inplace.isra.4+0x84/0xef
09:44:12   [<ffffffffa06bb6ee>] ? decode_attr_time+0x2f/0x5d [nfs]
09:44:12   [<ffffffffa0089704>] ? dec128+0x80c/0x80c [aes_x86_64]
09:44:12   [<ffffffff8118f328>] ? crypto_cbc_decrypt+0x5a/0x10a
09:44:12   [<ffffffff8118756b>] ? async_decrypt+0x37/0x3c
09:44:12   [<ffffffffa0108df7>] ? crypt_convert+0x223/0x2b8 [dm_crypt]
09:44:12   [<ffffffffa0109185>] ? kcryptd_crypt+0x56/0x342 [dm_crypt]
09:44:12   [<ffffffffa010912f>] ? crypt_convert_init.isra.17+0x4f/0x4f [dm_crypt]
09:44:12   [<ffffffffa010912f>] ? crypt_convert_init.isra.17+0x4f/0x4f [dm_crypt]
09:44:12   [<ffffffffa010912f>] ? crypt_convert_init.isra.17+0x4f/0x4f [dm_crypt]
09:44:12   [<ffffffff8105ac3d>] ? process_one_work+0x163/0x284
09:44:12   [<ffffffff8105bc05>] ? worker_thread+0xc2/0x145
09:44:12   [<ffffffff8105bb43>] ? manage_workers.isra.23+0x15b/0x15b
09:44:12   [<ffffffff8105ed41>] ? kthread+0x76/0x7e
09:44:12   [<ffffffff81349cb4>] ? kernel_thread_helper+0x4/0x10
09:44:12   [<ffffffff8105eccb>] ? kthread_worker_fn+0x139/0x139
09:44:12   [<ffffffff81349cb0>] ? gs_change+0x13/0x13
09:44:12  Mem-Info:
09:44:12  Node 0 DMA per-cpu:
09:44:12  CPU    0: hi:    0, btch:   1 usd:   0
09:44:12  CPU    1: hi:    0, btch:   1 usd:   0
09:44:12  Node 0 DMA32 per-cpu:
09:44:12  CPU    0: hi:  186, btch:  31 usd:  77
09:44:12  CPU    1: hi:  186, btch:  31 usd:  53
09:44:12  Node 0 Normal per-cpu:
09:44:12  CPU    0: hi:  186, btch:  31 usd: 165
09:44:12  CPU    1: hi:  186, btch:  31 usd:  64
09:44:12  active_anon:992922 inactive_anon:263441 isolated_anon:0
09:44:12   active_file:59734 inactive_file:530249 isolated_file:0
09:44:12   unevictable:1 dirty:52950 writeback:339764 unstable:7673
09:44:12   free:55214 slab_reclaimable:33311 slab_unreclaimable:30507
09:44:12   mapped:18500 shmem:43519 pagetables:21479 bounce:0
09:44:12  Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
09:44:12  lowmem_reserve[]: 0 2960 7947 7947
09:44:12  Node 0 DMA32 free:152124kB min:25128kB low:31408kB high:37692kB active_anon:1579176kB inactive_anon:524180kB active_file:33708kB inactive_file:618972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:81636kB writeback:322428kB mapped:6704kB shmem:67068kB slab_reclaimable:41408kB slab_unreclaimable:30456kB kernel_stack:2216kB pagetables:24408kB unstable:10048kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:12  lowmem_reserve[]: 0 0 4986 4986
09:44:12  Node 0 Normal free:52824kB min:42324kB low:52904kB high:63484kB active_anon:2392512kB inactive_anon:529584kB active_file:205228kB inactive_file:1502024kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:5106560kB mlocked:4kB dirty:130164kB writeback:1036628kB mapped:67296kB shmem:107008kB slab_reclaimable:91836kB slab_unreclaimable:91572kB kernel_stack:4216kB pagetables:61508kB unstable:20644kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:12  lowmem_reserve[]: 0 0 0 0
09:44:12  Node 0 DMA: 1*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15908kB
09:44:12  Node 0 DMA32: 36855*4kB 0*8kB 0*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 152124kB
09:44:12  Node 0 Normal: 12182*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 52824kB
09:44:12  676809 total pagecache pages
09:44:12  43260 pages in swap cache
09:44:12  Swap cache stats: add 803337, delete 760077, find 297801/318574
09:44:12  Free swap  = 1763768kB
09:44:12  Total swap = 4106248kB
09:44:12  2080752 pages RAM
09:44:12  57163 pages reserved
09:44:12  988161 pages shared
09:44:12  1496613 pages non-shared
09:44:12  ieee80211 phy0: failed to reallocate TX buffer
09:44:13  firefox-bin: page allocation failure: order:1, mode:0x20
09:44:13  Pid: 6697, comm: firefox-bin Tainted: G           O 3.2.5amd64-volpreempt-noide-20120208 #1
09:44:13  Call Trace:
09:44:13   <IRQ>  [<ffffffff810b755a>] ? warn_alloc_failed+0x11a/0x12d
09:44:13   [<ffffffff810ba394>] ? __alloc_pages_nodemask+0x6b2/0x726
09:44:13   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:13   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:13   [<ffffffff810ea421>] ? fallback_alloc+0x123/0x1c2
09:44:13   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:13   [<ffffffff810ea923>] ? __kmalloc+0xba/0x112
09:44:13   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:13   [<ffffffffa07a81c0>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
09:44:13   [<ffffffffa07aa087>] ? ieee80211_subif_start_xmit+0x68e/0x80c [mac80211]
09:44:13   [<ffffffff812877f3>] ? dev_hard_start_xmit+0x3fc/0x543
09:44:13   [<ffffffff8129da01>] ? sch_direct_xmit+0x5e/0x12f
09:44:13   [<ffffffff8129dbc9>] ? __qdisc_run+0xf7/0x10f
09:44:13   [<ffffffff81282d56>] ? net_tx_action+0xf1/0x128
09:44:13   [<ffffffff8104bc88>] ? __do_softirq+0xb9/0x177
09:44:13   [<ffffffff8103a95f>] ? check_preempt_wakeup+0x125/0x18e
09:44:13   [<ffffffff81349dac>] ? call_softirq+0x1c/0x30
09:44:13   [<ffffffff8100f875>] ? do_softirq+0x3c/0x7b
09:44:13   [<ffffffff8104bef0>] ? irq_exit+0x3c/0x9a
09:44:13   [<ffffffff8100f5a5>] ? do_IRQ+0x82/0x98
09:44:13   [<ffffffff81342e2e>] ? common_interrupt+0x6e/0x6e
09:44:13   <EOI>  [<ffffffff81347c84>] ? sysret_audit+0x16/0x20
09:44:13  Mem-Info:
09:44:13  Node 0 DMA per-cpu:
09:44:13  CPU    0: hi:    0, btch:   1 usd:   0
09:44:13  CPU    1: hi:    0, btch:   1 usd:   0
09:44:13  Node 0 DMA32 per-cpu:
09:44:13  CPU    0: hi:  186, btch:  31 usd:  78
09:44:13  CPU    1: hi:  186, btch:  31 usd:  66
09:44:13  Node 0 Normal per-cpu:
09:44:13  CPU    0: hi:  186, btch:  31 usd: 165
09:44:13  CPU    1: hi:  186, btch:  31 usd:  70
09:44:13  active_anon:992947 inactive_anon:263499 isolated_anon:0
09:44:13   active_file:59734 inactive_file:535571 isolated_file:0
09:44:13   unevictable:1 dirty:56763 writeback:339764 unstable:7673
09:44:13   free:49597 slab_reclaimable:33311 slab_unreclaimable:30582
09:44:13   mapped:18500 shmem:43562 pagetables:21479 bounce:0
09:44:13  Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
09:44:13  lowmem_reserve[]: 0 2960 7947 7947
09:44:13  Node 0 DMA32 free:129656kB min:25128kB low:31408kB high:37692kB active_anon:1579276kB inactive_anon:524180kB active_file:33708kB inactive_file:640772kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:92588kB writeback:322428kB mapped:6704kB shmem:67068kB slab_reclaimable:41408kB slab_unreclaimable:30756kB kernel_stack:2216kB pagetables:24408kB unstable:10048kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:13  lowmem_reserve[]: 0 0 4986 4986
09:44:13  Node 0 Normal free:52824kB min:42324kB low:52904kB high:63484kB active_anon:2392512kB inactive_anon:529816kB active_file:205228kB inactive_file:1501512kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:5106560kB mlocked:4kB dirty:134464kB writeback:1036628kB mapped:67296kB shmem:107180kB slab_reclaimable:91836kB slab_unreclaimable:91572kB kernel_stack:4216kB pagetables:61508kB unstable:20644kB bounce:0kB writeback_tmp:0kB pages_scanned:1703 all_unreclaimable? no
09:44:13  lowmem_reserve[]: 0 0 0 0
09:44:13  Node 0 DMA: 1*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15908kB
09:44:13  Node 0 DMA32: 31254*4kB 0*8kB 0*16kB 1*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 129656kB
09:44:13  Node 0 Normal: 12182*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 52824kB
09:44:13  682242 total pagecache pages
09:44:13  43259 pages in swap cache
09:44:13  Swap cache stats: add 803338, delete 760079, find 297802/318575
09:44:13  Free swap  = 1763768kB
09:44:13  Total swap = 4106248kB
09:44:13  2080752 pages RAM
09:44:13  57163 pages reserved
09:44:13  992010 pages shared
09:44:13  1498343 pages non-shared
09:44:13  ieee80211 phy0: failed to reallocate TX buffer
09:44:13  firefox-bin: page allocation failure: order:1, mode:0x20
09:44:13  Pid: 6706, comm: firefox-bin Tainted: G           O 3.2.5amd64-volpreempt-noide-20120208 #1
09:44:13  Call Trace:
09:44:13   <IRQ>  [<ffffffff810b755a>] ? warn_alloc_failed+0x11a/0x12d
09:44:13   [<ffffffff810ba394>] ? __alloc_pages_nodemask+0x6b2/0x726
09:44:13   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:13   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:13   [<ffffffff810ea421>] ? fallback_alloc+0x123/0x1c2
09:44:13   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:13   [<ffffffff810ea923>] ? __kmalloc+0xba/0x112
09:44:13   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:13   [<ffffffffa07a81c0>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
09:44:13   [<ffffffffa07aa087>] ? ieee80211_subif_start_xmit+0x68e/0x80c [mac80211]
09:44:13   [<ffffffffa07922c8>] ? ieee80211_tx_status_irqsafe+0x2e/0x7f [mac80211]
09:44:13   [<ffffffff812877f3>] ? dev_hard_start_xmit+0x3fc/0x543
09:44:13   [<ffffffff81070551>] ? arch_local_irq_save+0x11/0x17
09:44:13   [<ffffffff8129da01>] ? sch_direct_xmit+0x5e/0x12f
09:44:13   [<ffffffff8129dbc9>] ? __qdisc_run+0xf7/0x10f
09:44:13   [<ffffffff81282d56>] ? net_tx_action+0xf1/0x128
09:44:13   [<ffffffff8104bc88>] ? __do_softirq+0xb9/0x177
09:44:13   [<ffffffff8106a67b>] ? clockevents_program_event+0xaa/0xce
09:44:13   [<ffffffff81349dac>] ? call_softirq+0x1c/0x30
09:44:13   [<ffffffff8100f875>] ? do_softirq+0x3c/0x7b
09:44:13   [<ffffffff8104bef0>] ? irq_exit+0x3c/0x9a
09:44:13   [<ffffffff8100f5a5>] ? do_IRQ+0x82/0x98
09:44:13   [<ffffffff81342e2e>] ? common_interrupt+0x6e/0x6e
09:44:13   <EOI>  [<ffffffff81347c84>] ? sysret_audit+0x16/0x20
09:44:13  Mem-Info:
09:44:13  Node 0 DMA per-cpu:
09:44:13  CPU    0: hi:    0, btch:   1 usd:   0
09:44:13  CPU    1: hi:    0, btch:   1 usd:   0
09:44:13  Node 0 DMA32 per-cpu:
09:44:13  CPU    0: hi:  186, btch:  31 usd:  69
09:44:13  CPU    1: hi:  186, btch:  31 usd:  35
09:44:13  Node 0 Normal per-cpu:
09:44:13  CPU    0: hi:  186, btch:  31 usd: 178
09:44:13  CPU    1: hi:  186, btch:  31 usd:  68
09:44:13  active_anon:992947 inactive_anon:263499 isolated_anon:0
09:44:13   active_file:59734 inactive_file:536198 isolated_file:0
09:44:13   unevictable:1 dirty:57182 writeback:339764 unstable:7673
09:44:13   free:49028 slab_reclaimable:33311 slab_unreclaimable:30581
09:44:13   mapped:18500 shmem:43562 pagetables:21479 bounce:0
09:44:13  Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
09:44:13  lowmem_reserve[]: 0 2960 7947 7947
09:44:13  Node 0 DMA32 free:127380kB min:25128kB low:31408kB high:37692kB active_anon:1579276kB inactive_anon:524180kB active_file:33708kB inactive_file:643272kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:93920kB writeback:322428kB mapped:6704kB shmem:67068kB slab_reclaimable:41408kB slab_unreclaimable:30752kB kernel_stack:2216kB pagetables:24408kB unstable:10048kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:13  lowmem_reserve[]: 0 0 4986 4986
09:44:13  Node 0 Normal free:52824kB min:42324kB low:52904kB high:63484kB active_anon:2392512kB inactive_anon:529816kB active_file:205228kB inactive_file:1501520kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:5106560kB mlocked:4kB dirty:134808kB writeback:1036628kB mapped:67296kB shmem:107180kB slab_reclaimable:91836kB slab_unreclaimable:91572kB kernel_stack:4216kB pagetables:61508kB unstable:20644kB bounce:0kB writeback_tmp:0kB pages_scanned:112 all_unreclaimable? no
09:44:13  lowmem_reserve[]: 0 0 0 0
09:44:13  Node 0 DMA: 1*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15908kB
09:44:13  Node 0 DMA32: 30640*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 127256kB
09:44:13  Node 0 Normal: 12182*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 52824kB
09:44:13  682828 total pagecache pages
09:44:13  43261 pages in swap cache
09:44:13  Swap cache stats: add 803340, delete 760079, find 297802/318575
09:44:13  Free swap  = 1763760kB
09:44:13  Total swap = 4106248kB
09:44:13  2080752 pages RAM
09:44:13  57163 pages reserved
09:44:13  992430 pages shared
09:44:13  1498647 pages non-shared
09:44:13  ieee80211 phy0: failed to reallocate TX buffer
09:44:13  kworker/0:0: page allocation failure: order:1, mode:0x20
09:44:13  Pid: 7949, comm: kworker/0:0 Tainted: G           O 3.2.5amd64-volpreempt-noide-20120208 #1
09:44:13  Call Trace:
09:44:13   <IRQ>  [<ffffffff810b755a>] ? warn_alloc_failed+0x11a/0x12d
09:44:13   [<ffffffff810ba394>] ? __alloc_pages_nodemask+0x6b2/0x726
09:44:13   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:13   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:13   [<ffffffff810ea421>] ? fallback_alloc+0x123/0x1c2
09:44:13   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:13   [<ffffffff810ea923>] ? __kmalloc+0xba/0x112
09:44:13   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:13   [<ffffffffa07a81c0>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
09:44:13   [<ffffffffa07aa087>] ? ieee80211_subif_start_xmit+0x68e/0x80c [mac80211]
09:44:13   [<ffffffffa07922c8>] ? ieee80211_tx_status_irqsafe+0x2e/0x7f [mac80211]
09:44:13   [<ffffffff812877f3>] ? dev_hard_start_xmit+0x3fc/0x543
09:44:13   [<ffffffff8129da01>] ? sch_d9704>] ? dec128+0x80c/0x80c [aes_x86_64]
09:44:13   [<ffffffff810349f1>] ? set_task_rq+0x23/0x35
09:44:13   [<ffffffff8118f328>] ? crypto_cbc_decrypt+0x5a/0x10a
09:44:13   [<ffffffff8118756b>] ? async_decrypt+0x37/0x3c
09:44:13   [<ffffffffa0108df7>] ? crypt_convert+0x223/0x2b8 [dm_crypt]
09:44:13   [<ffffffffa0109185>] ? kcryptd_crypt+0x56/0x342 [dm_crypt]
09:44:13   [<ffffffff810388e2>] ? finish_task_switch+0x4e/0xb9
09:44:13   [<ffffffff811a4021>] ? cfq_init_queue+0x403/0x403
09:44:13   [<ffffffffa010912f>] ? crypt_convert_init.isra.17+0x4f/0x4f [dm_crypt]
09:44:13   [<ffffffff8105ac3d>] ? process_one_work+0x163/0x284
09:44:13   [<ffffffff8105bc05>] ? worker_thread+0xc2/0x145
09:44:13   [<ffffffff8105bb43>] ? manage_workers.isra.23+0x15b/0x15b
09:44:13   [<ffffffff8105ed41>] ? kthread+0x76/0x7e
09:44:13   [<ffffffff81349cb4>] ? kernel_thread_helper+0x4/0x10
09:44:13   [<ffffffff8105eccb>] ? kthread_worker_fn+0x139/0x139
09:44:13   [<ffffffff81349cb0>] ? gs_change+0x13/0x13
09:44:13  Mem-Info:
09:44:13  Node 0 DMA per-cpu:
09:44:13  CPU    0: hi:    0, btch:   1 usd:   0
09:44:13  CPU    1: hi:    0, btch:   1 usd:   0
09:44:13  Node 0 DMA32 per-cpu:
09:44:13  CPU    0: hi:  186, btch:  31 usd:  17
09:44:13  CPU    1: hi:  186, btch:  31 usd:   0
09:44:13  Node 0 Normal per-cpu:
09:44:13  CPU    0: hi:  186, btch:  31 usd:  69
09:44:13  CPU    1: hi:  186, btch:  31 usd: 125
09:44:13  active_anon:992968 inactive_anon:263499 isolated_anon:1
09:44:13   active_file:59749 inactive_file:538771 isolated_file:12
09:44:13   unevictable:1 dirty:59393 writeback:339244 unstable:8193
09:44:13   free:46512 slab_reclaimable:33220 slab_unreclaimable:30692
09:44:13   mapped:18504 shmem:43598 pagetables:21479 bounce:0
09:44:13  Node 0 DMA free:15908kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
09:44:13  lowmem_reserve[]: 0 2960 7947 7947
09:44:13  Node 0 DMA32 free:117308kB min:25128kB low:31408kB high:37692kB active_anon:1579336kB inactive_anon:524204kB active_file:33764kB inactive_file:653796kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3031688kB mlocked:0kB dirty:99216kB writeback:322356kB mapped:6716kB shmem:67128kB slab_reclaimable:41324kB slab_unreclaimable:30888kB kernel_stack:2216kB pagetables:24408kB unstable:10120kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:13  lowmem_reserve[]: 0 0 4986 4986
09:44:13  Node 0 Normal free:52832kB min:42324kB low:52904kB high:63484kB active_anon:2392536kB inactive_anon:529792kB active_file:205232kB inactive_file:1501288kB unevictable:4kB isolated(anon):4kB isolated(file):48kB present:5106560kB mlocked:4kB dirty:138356kB writeback:1034620kB mapped:67300kB shmem:107264kB slab_reclaimable:91556kB slab_unreclaimable:91880kB kernel_stack:4216kB pagetables:61508kB unstable:22652kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
09:44:13  lowmem_reserve[]: 0 0 0 0
09:44:13  Node 0 DMA: 1*4kB 0*8kB 0*16kB 1*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15908kB
09:44:13  Node 0 DMA32: 28147*4kB 0*8kB 1*16kB 1*32kB 1*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 117308kB
09:44:13  Node 0 Normal: 12094*4kB 5*8kB 12*16kB 4*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 52832kB
09:44:13  685431 total pagecache pages
09:44:13  43261 pages in swap cache
09:44:13  Swap cache stats: add 803341, delete 760080, find 297802/318575
09:44:13  Free swap  = 1763756kB
09:44:13  Total swap = 4106248kB
09:44:13  2080752 pages RAM
09:44:13  57163 pages reserved
09:44:13  994159 pages shared
09:44:13  1498949 pages non-shared
09:44:13  ieee80211 phy0: failed to reallocate TX buffer
09:44:13  kworker/0:0: page allocation failure: order:1, mode:0x20

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
