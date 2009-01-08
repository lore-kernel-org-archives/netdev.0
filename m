From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: swapper: page allocation failure. order:2, mode:0x4020 in 2.6.27
Date: Thu,  8 Jan 2009 10:19:23 +0900 (JST)
Message-ID: <20090108100917.65F3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <a06240403c58ae633aba5@[129.98.90.227]>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Maurice Volaski <mvolaski@aecom.yu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:40805 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757562AbZAHBT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 20:19:26 -0500
In-Reply-To: <a06240403c58ae633aba5@[129.98.90.227]>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

(cc to netdev)

> Just started with 2.6.27-gentoo-r7 (I think gentoo may have patches 
> from 2.6.28) on an x64 system and during an apparently idle time, I 
> saw this:
> 
> Jan  6 23:20:19 [kernel] [358105.255843] swapper: page allocation 
> failure. order:2, mode:0x4020
> Jan  6 23:20:19 [kernel] [358105.255851] Pid: 0, comm: swapper Not 
> tainted 2.6.27-gentoo-r7 #3
> Jan  6 23:20:19 [kernel] [358105.255854]
> Jan  6 23:20:19 [kernel] [358105.255854] Call Trace:
> Jan  6 23:20:19 [kernel] [358105.255857]  <IRQ>  [<ffffffff81076bbf>] 
> __alloc_pages_internal+0x41a/0x439
> Jan  6 23:20:19 [kernel] [358105.255872]  [<ffffffff8126575c>] ? 
> __netdev_alloc_skb+0x1d/0x39
> Jan  6 23:20:19 [kernel] [358105.255875]  [<ffffffff81076c4c>] 
> __get_free_pages+0x17/0x56
> Jan  6 23:20:19 [kernel] [358105.255879]  [<ffffffff8109632b>] 
> __kmalloc_track_caller+0x3b/0xbb
> Jan  6 23:20:19 [kernel] [358105.255882]  [<ffffffff81264d87>] 
> __alloc_skb+0x66/0x12c
> Jan  6 23:20:19 [kernel] [358105.255885]  [<ffffffff8126575c>] 
> __netdev_alloc_skb+0x1d/0x39
> Jan  6 23:20:19 [kernel] [358105.255899]  [<ffffffffa00d203c>] 
> tg3_alloc_rx_skb+0xd1/0x195 [tg3]

if stack dump has tg3_alloc_rx_skb(), that isn't bug. (maybe)
tg3 network card often reqire non order-0 pages under irq/softirq context.

but linux memory manager can't drop any cache under irq/softirq context.
therefore the allocation failure is relatively typical.

the allocation failure in packet receive (tg3_alloc_rx_skb) cause
packet dropping and network peer resend the same packet.
it decrease network performance a bit. but it doesn't cause any serious problem.

last problem is, why we should look this false-positive warning repeatedly.


net-guys, if I say false thing, please fix.



> Jan  6 23:20:19 [kernel] [358105.255906]  [<ffffffffa00d9eb2>] 
> tg3_poll+0x563/0xa68 [tg3]
> Jan  6 23:20:19 [kernel] [358105.255910]  [<ffffffff8104b567>] ? 
> clockevents_program_event+0x73/0x7c
> Jan  6 23:20:19 [kernel] [358105.255914]  [<ffffffff81268608>] 
> net_rx_action+0xd3/0x1d0
> Jan  6 23:20:19 [kernel] [358105.255917]  [<ffffffff81268597>] ? 
> net_rx_action+0x62/0x1d0
> Jan  6 23:20:19 [kernel] [358105.255921]  [<ffffffff81035222>] 
> __do_softirq+0x6d/0xdd
> Jan  6 23:20:19 [kernel] [358105.255925]  [<ffffffff8100d2cc>] 
> call_softirq+0x1c/0x28
> Jan  6 23:20:19 [kernel] [358105.255928]  [<ffffffff8100e405>] 
> do_softirq+0x34/0x72
> Jan  6 23:20:19 [kernel] [358105.255931]  [<ffffffff81034f54>] 
> irq_exit+0x3f/0x82
> Jan  6 23:20:19 [kernel] [358105.255933]  [<ffffffff8100e6ee>] 
> do_IRQ+0x146/0x168
> Jan  6 23:20:19 [kernel] [358105.255936]  [<ffffffff8100c541>] 
> ret_from_intr+0x0/0xa
> Jan  6 23:20:19 [kernel] [358105.255938]  <EOI>  [<ffffffff812dd3cc>] 
> ? __atomic_notifier_call_chain+0x0/0x87
> Jan  6 23:20:19 [kernel] [358105.255947]  [<ffffffff81012593>] ? 
> default_idle+0x2b/0x40
> Jan  6 23:20:19 [kernel] [358105.255950]  [<ffffffff8100b041>] ? 
> enter_idle+0x22/0x24
> Jan  6 23:20:19 [kernel] [358105.255952]  [<ffffffff8100b0d3>] ? 
> cpu_idle+0x90/0xd8
> Jan  6 23:20:19 [kernel] [358105.255956]  [<ffffffff812d4ce7>] ? 
> start_secondary+0x155/0x159
> Jan  6 23:20:19 [kernel] [358105.255958]
> Jan  6 23:20:19 [kernel] [358105.255959] Mem-Info:
> Jan  6 23:20:19 [kernel] [358105.255961] DMA per-cpu:
> Jan  6 23:20:19 [kernel] [358105.255963] CPU    0: hi:    0, btch:   1 usd:   0
> Jan  6 23:20:19 [kernel] [358105.255965] CPU    1: hi:    0, btch:   1 usd:   0
> Jan  6 23:20:19 [kernel] [358105.255967] DMA32 per-cpu:
> Jan  6 23:20:19 [kernel] [358105.255968] CPU    0: hi:  186, btch:  31 usd: 126
> Jan  6 23:20:19 [kernel] [358105.255970] CPU    1: hi:  186, btch:  31 usd: 148
> Jan  6 23:20:19 [kernel] [358105.255972] Normal per-cpu:
> Jan  6 23:20:19 [kernel] [358105.255973] CPU    0: hi:  186, btch:  31 usd: 181
> Jan  6 23:20:19 [kernel] [358105.255975] CPU    1: hi:  186, btch:  31 usd: 183
> Jan  6 23:20:19 [kernel] [358105.255978] Active:218402 
> inactive:819867 dirty:27016 writeback:0 unstable:0
> Jan  6 23:20:19 [kernel] [358105.255980]  free:44839 slab:151548 
> mapped:5449 pagetables:2110 bounce:0
> Jan  6 23:20:19 [kernel] [358105.255983] DMA free:5328kB min:4kB 
> low:4kB high:4kB active:0kB inactive:0kB present:4256kB 
> pages_scanned:0 all_unreclaimable? yes
> Jan  6 23:20:19 [kernel] [358105.255986] lowmem_reserve[]: 0 3480 5484 5484
> Jan  6 23:20:19 [kernel] [358105.255991] DMA32 free:169860kB 
> min:6008kB low:7508kB high:9012kB active:433812kB inactive:1876764kB 
> present:3563808kB pages_scanned:0 all_unreclaimable? no
> Jan  6 23:20:19 [kernel] [358105.255993] lowmem_reserve[]: 0 0 2004 2004
> Jan  6 23:20:19 [kernel] [358105.255998] Normal free:4168kB 
> min:3460kB low:4324kB high:5188kB active:439796kB inactive:1402704kB 
> present:2052096kB pages_scanned:0 all_unreclaimable? no
> Jan  6 23:20:19 [kernel] [358105.256000] lowmem_reserve[]: 0 0 0 0
> Jan  6 23:20:19 [kernel] [358105.256004] DMA: 2*4kB 3*8kB 5*16kB 
> 5*32kB 3*64kB 4*128kB 3*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 
> 5328kB
> Jan  6 23:20:19 [kernel] [358105.256012] DMA32: 42208*4kB 0*8kB 
> 12*16kB 3*32kB 0*64kB 1*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 
> 0*4096kB = 169760kB
> Jan  6 23:20:19 [kernel] [358105.256020] Normal: 914*4kB 1*8kB 2*16kB 
> 1*32kB 1*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 
> 4176kB
> Jan  6 23:20:19 [kernel] [358105.256029] 1015437 total pagecache pages
> Jan  6 23:20:19 [kernel] [358105.256031] 0 pages in swap cache
> Jan  6 23:20:19 [kernel] [358105.256032] Swap cache stats: add 0, 
> delete 0, find 0/0
> Jan  6 23:20:19 [kernel] [358105.256034] Free swap  = 0kB
> Jan  6 23:20:19 [kernel] [358105.256035] Total swap = 0kB
> Jan  6 23:20:19 [kernel] [358105.285015] 1572848 pages RAM
> Jan  6 23:20:19 [kernel] [358105.285015] 170874 pages reserved
> Jan  6 23:20:19 [kernel] [358105.285015] 986700 pages shared
> Jan  6 23:20:19 [kernel] [358105.285015] 411152 pages non-shared
> -- 
> 
> Maurice Volaski, mvolaski@aecom.yu.edu
> Computing Support, Rose F. Kennedy Center
> Albert Einstein College of Medicine of Yeshiva University
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



