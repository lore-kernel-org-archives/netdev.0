From: Miroslav Kratochvil <exa.exa@gmail.com>
Subject: iptables/tc: page allocation failures question
Date: Sat, 3 Nov 2012 11:27:13 +0100
Message-ID: <CAO0uZ+_AZG2cT4NvvLKrbkKjMm09vi_Dqd6d49h0hE5Lh9+pmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58660 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab2KCK1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 06:27:14 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so4536440vbb.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 03:27:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I've got several linux boxes that do mostly routing and traffic
shaping stuff. The load isn't any dramatic - it's around 100Mbit of
traffic shaping over a HFSC qdisc with ~10k classes/filters.

Recently I started seeing messages like this in dmesg:

iptables: page allocation failure: order:9, mode:0xc0d0

tc: page allocation failure (....)

(full messages are attached below)

I understood that it means the kernel couldn't allocate memory for
execution of given command - it is usually triggered by stuff like 'tc
class add' or 'iptables -A something'.

The boxes, on the other hand, still have pretty much free memory
(alloc+buffers+cache fill around 400MB of 2 gigs available, swap is
empty). I guess the problem is caused by the fact that the allocation
is constrained by something (like GFP_ATOMIC, or that they can only
allocate lower memory). Is this true? If so, is there some possibility
to avoid such constraint?

What also worries me is that when the box at some point starts to do
memory allocation failures, I've been unable to make it stop, even if
I delete all qdiscs/iptable entries, clear every cache I know about
and restart most of userspace, which should hopefully free a good
amount of memory, nothing can be added back.

I'm attaching the dmesg of the failure below. Could anyone provide a
comment on this, or possibly point me to what can cause this behavior?
Is there any better debug output that could clarify this?

Thanks in advance,
Mirek Kratochvil


now how it happens:
# iptables -A FORWARD -s 192.168.0.0/24 -m recent -p tcp --name somelist --set
        /// it waits around 10 seconds here
iptables: Memory allocation problem.
# dmesg
[3391568.085980] iptables: page allocation failure: order:9, mode:0xc0d0
[3391568.085983] Pid: 21115, comm: iptables Not tainted 3.1.1 #3
[3391568.085985] Call Trace:
[3391568.085991]  [<ffffffff810a4172>] ? warn_alloc_failed+0xf2/0x140
[3391568.085993]  [<ffffffff810b3fc0>] ? next_zone+0x30/0x40
[3391568.085995]  [<ffffffff810a6fe0>] ? page_alloc_cpu_notify+0x40/0x40
[3391568.085997]  [<ffffffff810a69f9>] ? __alloc_pages_nodemask+0x609/0x790
[3391568.086000]  [<ffffffff810d3740>] ? alloc_pages_current+0xa0/0x110
[3391568.086002]  [<ffffffff810a3c79>] ? __get_free_pages+0x9/0x40
[3391568.086006]  [<ffffffff814d40c5>] ? recent_mt_check+0x165/0x2a0
[3391568.086007]  [<ffffffff814d1ac2>] ? xt_check_match+0xb2/0x1f0
[3391568.086010]  [<ffffffff8109f758>] ? find_get_page+0x18/0xa0
[3391568.086015]  [<ffffffff815bfc69>] ? _raw_spin_lock_bh+0x9/0x20
[3391568.086024]  [<ffffffff815be9b9>] ? mutex_lock_interruptible+0x9/0x40
[3391568.086026]  [<ffffffff814d12f0>] ? xt_find_match+0xb0/0x110
[3391568.086029]  [<ffffffff815226fe>] ? translate_table+0x29e/0x640
[3391568.086031]  [<ffffffff815237ba>] ? do_ipt_set_ctl+0x13a/0x1b0
[3391568.086036]  [<ffffffff814cdb0a>] ? nf_sockopt+0x5a/0xb0
[3391568.086039]  [<ffffffff814cdb9a>] ? nf_setsockopt+0x1a/0x20
[3391568.086044]  [<ffffffff814e2933>] ? ip_setsockopt+0x93/0xc0
[3391568.086048]  [<ffffffff81485e02>] ? sockfd_lookup_light+0x22/0x90
[3391568.086051]  [<ffffffff81488d7d>] ? sys_setsockopt+0x6d/0xd0
[3391568.086054]  [<ffffffff815c043b>] ? system_call_fastpath+0x16/0x1b
[3391568.086057] Mem-Info:
[3391568.086058] Node 0 DMA per-cpu:
[3391568.086061] CPU    0: hi:    0, btch:   1 usd:   0
[3391568.086063] CPU    1: hi:    0, btch:   1 usd:   0
[3391568.086064] CPU    2: hi:    0, btch:   1 usd:   0
[3391568.086065] CPU    3: hi:    0, btch:   1 usd:   0
[3391568.086066] Node 0 DMA32 per-cpu:
[3391568.086067] CPU    0: hi:  186, btch:  31 usd:   0
[3391568.086068] CPU    1: hi:  186, btch:  31 usd:   0
[3391568.086069] CPU    2: hi:  186, btch:  31 usd:  25
[3391568.086071] CPU    3: hi:  186, btch:  31 usd:   0
[3391568.086075] active_anon:10259 inactive_anon:3453 isolated_anon:0
[3391568.086076]  active_file:261 inactive_file:269 isolated_file:4
[3391568.086077]  unevictable:0 dirty:0 writeback:3640 unstable:0
[3391568.086078]  free:447441 slab_reclaimable:892 slab_unreclaimable:41475
[3391568.086079]  mapped:4747 shmem:4488 pagetables:694 bounce:0
[3391568.086081] Node 0 DMA free:11104kB min:40kB low:48kB high:60kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15648kB
mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB
slab_reclaimable:128kB slab_unreclaimable:4664kB kernel_stack:8kB
pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? yes
[3391568.086091] lowmem_reserve[]: 0 1978 1978 1978
[3391568.086096] Node 0 DMA32 free:1778660kB min:5668kB low:7084kB
high:8500kB active_anon:41036kB inactive_anon:13812kB
active_file:1044kB inactive_file:1076kB unevictable:0kB
isolated(anon):0kB isolated(file):144kB present:2026068kB mlocked:0kB
dirty:0kB writeback:14560kB mapped:18988kB shmem:17952kB
slab_reclaimable:3440kB slab_unreclaimable:161236kB kernel_stack:704kB
pagetables:2776kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:288 all_unreclaimable? no
[3391568.086107] lowmem_reserve[]: 0 0 0 0
[3391568.086112] Node 0 DMA: 18*4kB 7*8kB 10*16kB 12*32kB 9*64kB
9*128kB 8*256kB 3*512kB 3*1024kB 1*2048kB 0*4096kB = 11104kB
[3391568.086119] Node 0 DMA32: 13255*4kB 14135*8kB 14291*16kB
11013*32kB 6973*64kB 2976*128kB 614*256kB 88*512kB 2*1024kB 0*2048kB
0*4096kB = 1778660kB
[3391568.086139] 8553 total pagecache pages
[3391568.086140] 3528 pages in swap cache
[3391568.086142] Swap cache stats: add 666897, delete 663369, find
317604632/317669671
[3391568.086144] Free swap  = 973916kB
[3391568.086146] Total swap = 1048572kB
[3391568.091300] 522224 pages RAM
[3391568.091302] 14130 pages reserved
[3391568.091302] 14125 pages shared
[3391568.091303] 55020 pages non-shared
