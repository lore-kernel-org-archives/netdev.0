From: Sazpaimon <Sazpaimon@sonic-cult.org>
Subject: Peculiar memory leack possibly involving forcedeth
Date: Sat, 19 Jul 2008 00:58:48 -0700
Message-ID: <48819EB8.9080704@sonic-cult.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from u15254048.onlinehome-server.com ([74.208.47.186]:53829 "EHLO
	u15254048.onlinehome-server.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751809AbYGSI05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 04:26:57 -0400
Received: from cpe-72-130-16-54.socal.res.rr.com ([72.130.16.54] helo=[127.0.0.1])
	by u15254048.onlinehome-server.com with esmtpa (Exim 4.67)
	(envelope-from <Sazpaimon@sonic-cult.org>)
	id 1KK7KO-0002Uq-IN
	for netdev@vger.kernel.org; Sat, 19 Jul 2008 07:58:04 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, on my 2.6.24-1-amd64 Debian box, I seem to be getting a leak related 
to forcedeth, leaving my machine unavailable until I reboot it.  As my 
output from my serial console shows, oom-killer isn't taking effect, and 
as such there's nothing that can be done.  I'm hoping this call trace 
can help track down the issue.

Mem-info:
Node 0 DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 
usd:   0
Node 0 DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:   0   Cold: hi:   62, btch:  15 
usd:   0
Active:79165 inactive:109684 dirty:0 writeback:0 unstable:0
 free:1352 slab:17120 mapped:15 pagetables:32379 bounce:0
Node 0 DMA free:3920kB min:24kB low:28kB high:36kB active:452kB 
inactive:136kB present:6084kB pages_scanned:1346 all_unreclaimable? no
lowmem_reserve[]: 0 977 977 977
Node 0 DMA32 free:1488kB min:3984kB low:4980kB high:5976kB 
active:316208kB inactive:438600kB present:1000976kB 
pages_scanned:2085485 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 150*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 3920kB
Node 0 DMA32: 100*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 2*512kB 
0*1024kB 0*2048kB 0*4096kB = 1488kB
Swap cache: add 5049008, delete 5049007, find 75384654/75945454, race 
412+222
Free swap  = 0kB
Total swap = 1959920kB
Free swap:            0kB
257808 pages of RAM
4639 reserved pages
251166 pages shared
1 pages swap cached
printk: 83 messages suppressed.
named: page allocation failure. order:0, mode:0x20
Pid: 30047, comm: named Not tainted 2.6.24-1-amd64 #1

Call Trace:
 <IRQ>  [<ffffffff80277404>] __alloc_pages+0x2f0/0x309
 [<ffffffff8029300f>] kmem_getpages+0x95/0x145
 [<ffffffff8029300f>] kmem_getpages+0x95/0x145
 [<ffffffff80293578>] fallback_alloc+0x11e/0x18a
 [<ffffffff802931ef>] kmem_cache_alloc_node+0x93/0xc4
 [<ffffffff803a86c1>] __alloc_skb+0x64/0x12d
 [<ffffffff8022ceeb>] __update_rq_clock+0x16/0x8b
 [<ffffffff88086841>] :forcedeth:nv_alloc_rx_optimized+0x57/0x198
 [<ffffffff88089583>] :forcedeth:nv_do_rx_refill+0x0/0xc3
 [<ffffffff880895df>] :forcedeth:nv_do_rx_refill+0x5c/0xc3
 [<ffffffff88089583>] :forcedeth:nv_do_rx_refill+0x0/0xc3
 [<ffffffff8023dd50>] run_timer_softirq+0x16a/0x1df
 [<ffffffff8024ae87>] ktime_get+0xc/0x41
 [<ffffffff8023a989>] __do_softirq+0x55/0xc3
 [<ffffffff8020cfbc>] call_softirq+0x1c/0x28
 [<ffffffff8020ec12>] do_softirq+0x2c/0x7d
 [<ffffffff8023a8ef>] irq_exit+0x3f/0x84
 [<ffffffff8021dabe>] smp_apic_timer_interrupt+0x40/0x52
 [<ffffffff8020ca66>] apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff802864e6>] page_check_address+0x27/0xea
 [<ffffffff80286579>] page_check_address+0xba/0xea
 [<ffffffff802865f4>] page_referenced_one+0x4b/0xba
 [<ffffffff8028b014>] get_swap_page+0x1a/0x29e
 [<ffffffff802871da>] page_referenced+0x6d/0xe2
 [<ffffffff8027ae47>] shrink_page_list+0x11b/0x563
 [<ffffffff802864e6>] page_check_address+0x27/0xea
 [<ffffffff802865c4>] page_referenced_one+0x1b/0xba
 [<ffffffff8027a4a1>] isolate_lru_pages+0x5d/0x1d9
 [<ffffffff8027b3ac>] shrink_inactive_list+0x11d/0x381
 [<ffffffff8027b6f4>] shrink_zone+0xe4/0x107
 [<ffffffff80248206>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8027c4cd>] try_to_free_pages+0x17b/0x28e
 [<ffffffff80248206>] autoremove_wake_function+0x0/0x2e
 [<ffffffff802772de>] __alloc_pages+0x1ca/0x309
 [<ffffffff8024ab13>] hrtimer_try_to_cancel+0x67/0x70
 [<ffffffff80278e1e>] __do_page_cache_readahead+0x79/0x183
 [<ffffffff80273a51>] filemap_fault+0x15a/0x30b
 [<ffffffff8027e496>] __do_fault+0x68/0x39b
 [<ffffffff8028003b>] handle_mm_fault+0x330/0x6d8
 [<ffffffff802235ea>] do_page_fault+0x358/0x702
 [<ffffffff8024cd35>] getnstimeofday+0x4e/0x85
 [<ffffffff8024ae4b>] ktime_get_ts+0x17/0x47
 [<ffffffff80252840>] sys_futex+0xfa/0x118
 [<ffffffff80416ac9>] error_exit+0x0/0x51

Mem-info:
Node 0 DMA per-cpu:
CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 
usd:   0
Node 0 DMA32 per-cpu:
CPU    0: Hot: hi:  186, btch:  31 usd:   0   Cold: hi:   62, btch:  15 
usd:   0
Active:81674 inactive:107148 dirty:0 writeback:0 unstable:0
 free:1352 slab:17120 mapped:15 pagetables:32379 bounce:0
Node 0 DMA free:3920kB min:24kB low:28kB high:36kB active:452kB 
inactive:136kB present:6084kB pages_scanned:1346 all_unreclaimable? no
lowmem_reserve[]: 0 977 977 977
Node 0 DMA32 free:1488kB min:3984kB low:4980kB high:5976kB 
active:326244kB inactive:428456kB present:1000976kB 
pages_scanned:2152432 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
Node 0 DMA: 150*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 3920kB
Node 0 DMA32: 100*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 0*256kB 2*512kB 
0*1024kB 0*2048kB 0*4096kB = 1488kB
Swap cache: add 5049008, delete 5049007, find 75384654/75945454, race 
412+222
Free swap  = 0kB
Total swap = 1959920kB
Free swap:            0kB
257808 pages of RAM
4639 reserved pages
251194 pages shared
1 pages swap cached
printk: 83 messages suppressed.
icecast2: page allocation failure. order:0, mode:0x20
Pid: 24353, comm: icecast2 Not tainted 2.6.24-1-amd64 #1

Call Trace:
 <IRQ>  [<ffffffff80277404>] __alloc_pages+0x2f0/0x309
 [<ffffffff8029300f>] kmem_getpages+0x95/0x145
 [<ffffffff8029300f>] kmem_getpages+0x95/0x145
 [<ffffffff80293578>] fallback_alloc+0x11e/0x18a
 [<ffffffff802931ef>] kmem_cache_alloc_node+0x93/0xc4
 [<ffffffff803a86c1>] __alloc_skb+0x64/0x12d
 [<ffffffff88086841>] :forcedeth:nv_alloc_rx_optimized+0x57/0x198
 [<ffffffff88089583>] :forcedeth:nv_do_rx_refill+0x0/0xc3
 [<ffffffff880895df>] :forcedeth:nv_do_rx_refill+0x5c/0xc3
 [<ffffffff88089583>] :forcedeth:nv_do_rx_refill+0x0/0xc3
 [<ffffffff8023dd50>] run_timer_softirq+0x16a/0x1df
 [<ffffffff8023a989>] __do_softirq+0x55/0xc3
 [<ffffffff8020cfbc>] call_softirq+0x1c/0x28
 [<ffffffff8020ec12>] do_softirq+0x2c/0x7d
 [<ffffffff8023a8ef>] irq_exit+0x3f/0x84
 [<ffffffff8021dabe>] smp_apic_timer_interrupt+0x40/0x52
 [<ffffffff8020ca66>] apic_timer_interrupt+0x66/0x70
 <EOI>  [<ffffffff80286519>] page_check_address+0x5a/0xea
 [<ffffffff80286579>] page_check_address+0xba/0xea
 [<ffffffff802865f4>] page_referenced_one+0x4b/0xba
 [<ffffffff80286660>] page_referenced_one+0xb7/0xba
 [<ffffffff802871da>] page_referenced+0x6d/0xe2
 [<ffffffff8027a845>] shrink_active_list+0x228/0x50b
 [<ffffffff8027b5f9>] shrink_inactive_list+0x36a/0x381
 [<ffffffff8027b6d6>] shrink_zone+0xc6/0x107
 [<ffffffff80248206>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8027c4cd>] try_to_free_pages+0x17b/0x28e
 [<ffffffff80248206>] autoremove_wake_function+0x0/0x2e
 [<ffffffff802772de>] __alloc_pages+0x1ca/0x309
 [<ffffffff804157a5>] __wait_on_bit_lock+0x5b/0x66
 [<ffffffff80278e1e>] __do_page_cache_readahead+0x79/0x183
 [<ffffffff80273a51>] filemap_fault+0x15a/0x30b
 [<ffffffff8027e496>] __do_fault+0x68/0x39b
 [<ffffffff803a4985>] lock_sock_nested+0x9f/0xaa
 [<ffffffff8028003b>] handle_mm_fault+0x330/0x6d8
 [<ffffffff802235ea>] do_page_fault+0x358/0x702
 [<ffffffff80296e5d>] fd_install+0x25/0x59
 [<ffffffff803d6786>] tcp_poll+0x0/0x138
 [<ffffffff80416ac9>] error_exit+0x0/0x51



