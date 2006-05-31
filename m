From: Ben Greear <greearb@candelatech.com>
Subject: TCP connection hang problem with 2.6.16.16, e1000.
Date: Wed, 31 May 2006 09:45:36 -0700
Message-ID: <447DC830.4080201@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040706040606070706010006"
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53677 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751715AbWEaQpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 12:45:39 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k4VGjZOr031069
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 09:45:36 -0700
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040706040606070706010006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Kernel is 2.6.16.16 with my patches, including a patch to the
e1000.  I also rebuilt a fresh kernel with only the attached
send-to-self patch.  I see the hang, but there was no OOM messages,
probably because the machine was freshly rebooted and had plenty
of buffers available.  I will try to reproduce this with some other
NICs next...

I am running 2 TCP connections between two ports of a pro/1000 NIC with
fiber interfaces.  Both connections are trying to send 200Mbps in both
directions.  Each write to the socket is 5000 bytes.  MTU is 1500.

After maybe 10 seconds, I see out-of-memory errors on the console and
then the connections hang and send no more traffic.  However, the
NICs are still showing ~215kpps.  According to ethereal, these are
duplicate acks.

   0.928361  172.1.5.169 -> 172.1.5.168  TCP [TCP Dup ACK 4#1389] 33020 > 33019
[ACK] Seq=4294967208 Ack=32 Win=23 Len=0 TSV=1278643133 TSER=1278356385
   0.928618  172.1.5.169 -> 172.1.5.168  TCP [TCP Dup ACK 2#1300] 33018 > 33017
[ACK] Seq=0 Ack=0 Win=538 Len=0 TSV=1278643133 TSER=1278338974
   0.928858  172.1.5.169 -> 172.1.5.168  TCP [TCP Dup ACK 4#1390] 33020 > 33019
[ACK] Seq=4294967208 Ack=32 Win=23 Len=0 TSV=1278643134 TSER=1278356385
   0.929190  172.1.5.169 -> 172.1.5.168  TCP [TCP Dup ACK 2#1301] 33018 > 33017
[ACK] Seq=0 Ack=0 Win=538 Len=0 TSV=1278643134 TSER=1278338974
   0.929461  172.1.5.169 -> 172.1.5.168  TCP [TCP Dup ACK 2#1302] 33018 > 33017
[ACK] Seq=0 Ack=0 Win=538 Len=0 TSV=1278643134 TSER=1278338974
   0.929716  172.1.5.169 -> 172.1.5.168  TCP [TCP Dup ACK 4#1391] 33020 > 33019
[ACK] Seq=4294967208 Ack=32 Win=23 Len=0 TSV=1278643134 TSER=1278356385

107215 packets dropped

Stopping the TCP connection does not appear to immediately fix the problem:
The connections are in the FIN_WAIT1 state and the dup acks continue to flow.

ifdown/ifup after stopping the connections seems to clear the problem.

I saw no more OOM messages with TOE disabled, but the connection still
hangs.


The OOM related console messages are attached.

The problem also happens when no OOM messages are printed, but it runs slightly
longer (maybe 15-20 seconds).

I suspect that a dropped packet or packets is somehow the problem.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------040706040606070706010006
Content-Type: text/plain;
 name="messages"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="messages"

May 28 04:02:06 xeon-dt syslogd 1.4.1: restart.
May 30 11:54:40 xeon-dt kernel: e1000: eth4: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
May 30 11:54:43 xeon-dt kernel: e1000: eth3: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
May 30 12:33:54 xeon-dt kernel: e1000: eth4: e1000_watchdog_task: NIC Link is Down
May 30 12:33:54 xeon-dt kernel: e1000: eth3: e1000_watchdog_task: NIC Link is Down
May 30 12:33:58 xeon-dt kernel: e1000: eth3: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
May 30 12:33:58 xeon-dt kernel: e1000: eth4: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
May 30 12:52:57 xeon-dt kernel: e1000: eth4: e1000_watchdog_task: NIC Link is Down
May 30 12:52:57 xeon-dt kernel: e1000: eth3: e1000_watchdog_task: NIC Link is Down
May 31 08:07:00 xeon-dt kernel: irqbalance: page allocation failure. order:1, mode:0x20
May 31 08:07:00 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:07:00 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:07:00 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:07:00 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:07:00 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:07:00 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:00 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:07:00 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:07:00 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:07:00 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:07:00 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:07:01 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:07:01 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:07:01 xeon-dt kernel:  [<78141615>] handle_IRQ_event+0x26/0x59
May 31 08:07:01 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:07:02 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:07:02 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:07:02 xeon-dt kernel:  [<782ee9bc>] tcp_v4_rcv+0x6ff/0x9b0
May 31 08:07:02 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:07:02 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:07:02 xeon-dt kernel:  [<78125460>] getnstimeofday+0x10/0x2a
May 31 08:07:02 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:07:02 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:07:03 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:07:03 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:07:03 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:07:04 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:07:04 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:07:04 xeon-dt kernel:  [<781d007b>] as_get_io_context+0x15/0x33
May 31 08:07:04 xeon-dt kernel:  [<7831adfb>] _spin_lock+0x4e/0x8e
May 31 08:07:04 xeon-dt kernel:  [<7817808f>] d_rehash+0x4b/0x7a
May 31 08:07:05 xeon-dt kernel:  [<78196900>] proc_lookup+0x83/0xb9
May 31 08:07:05 xeon-dt kernel:  [<78193bea>] proc_root_lookup+0x19/0x47
May 31 08:07:05 xeon-dt kernel:  [<7816db17>] real_lookup+0xb5/0xd1
May 31 08:07:05 xeon-dt kernel:  [<7816dd93>] do_lookup+0x85/0x90
May 31 08:07:05 xeon-dt kernel:  [<7816de86>] __link_path_walk+0xe8/0xc6f
May 31 08:07:05 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:07:05 xeon-dt kernel:  [<f898b750>] e1000_clean_tx_irq+0x123/0x32e [e1000]
May 31 08:07:05 xeon-dt kernel:  [<f898bba4>] e1000_clean_rx_irq+0x249/0x5c6 [e1000]
May 31 08:07:05 xeon-dt kernel:  [<7816ea54>] link_path_walk+0x47/0xc4
May 31 08:07:05 xeon-dt kernel:  [<78155eb6>] free_pages_and_swap_cache+0x54/0x75
May 31 08:07:05 xeon-dt kernel:  [<7816135b>] get_empty_filp+0x77/0x15d
May 31 08:07:05 xeon-dt kernel:  [<7816edf5>] do_path_lookup+0x124/0x26f
May 31 08:07:05 xeon-dt kernel:  [<7816efa8>] __path_lookup_intent_open+0x50/0x90
May 31 08:07:05 xeon-dt kernel:  [<7816f84d>] open_namei+0xcb/0x631
May 31 08:07:05 xeon-dt kernel:  [<7814e658>] unmap_vmas+0xff/0x245
May 31 08:07:05 xeon-dt kernel:  [<7815f853>] do_filp_open+0x2e/0x4d
May 31 08:07:06 xeon-dt kernel:  [<78155eb6>] free_pages_and_swap_cache+0x54/0x75
May 31 08:07:06 xeon-dt kernel:  [<7815fb65>] do_sys_open+0x3e/0xb2
May 31 08:07:06 xeon-dt kernel:  [<7815fbf5>] sys_open+0x1c/0x20
May 31 08:07:06 xeon-dt kernel:  [<78102c93>] sysenter_past_esp+0x54/0x75
May 31 08:07:06 xeon-dt kernel: Mem-info:
May 31 08:07:06 xeon-dt kernel: DMA per-cpu:
May 31 08:07:06 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:07:06 xeon-dt kernel: Normal per-cpu:
May 31 08:07:06 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:183
May 31 08:07:06 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:47
May 31 08:07:06 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:51
May 31 08:07:06 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:33
May 31 08:07:06 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:167
May 31 08:07:06 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:52
May 31 08:07:06 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:23
May 31 08:07:06 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:14
May 31 08:07:06 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:07:06 xeon-dt kernel: Free pages:       39080kB (0kB HighMem)
May 31 08:07:06 xeon-dt kernel: Active:141705 inactive:50502 dirty:96 writeback:0 unstable:0 free:9770 slab:311263 mapped:13115 pagetables:231
May 31 08:07:06 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:510 all_unreclaimable? yes
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:06 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:06 xeon-dt kernel: Normal free:30936kB min:5744kB low:7180kB high:8616kB active:566472kB inactive:202008kB present:2080704kB pages_scanned:7 all_unreclaimable? no
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:06 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:06 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:07:06 xeon-dt kernel: DMA32: empty
May 31 08:07:06 xeon-dt kernel: Normal: 6654*4kB 406*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 30936kB
May 31 08:07:06 xeon-dt kernel: HighMem: empty
May 31 08:07:06 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:07:06 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:07:06 xeon-dt kernel: Total swap = 2040244kB
May 31 08:07:06 xeon-dt kernel: Free swap:       2040244kB
May 31 08:07:06 xeon-dt kernel: 524272 pages of RAM
May 31 08:07:06 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:07:06 xeon-dt kernel: 7484 reserved pages
May 31 08:07:06 xeon-dt kernel: 157201 pages shared
May 31 08:07:06 xeon-dt kernel: 0 pages swap cached
May 31 08:07:06 xeon-dt kernel: 96 pages dirty
May 31 08:07:06 xeon-dt kernel: 0 pages writeback
May 31 08:07:06 xeon-dt kernel: 13115 pages mapped
May 31 08:07:06 xeon-dt kernel: 311263 pages slab
May 31 08:07:06 xeon-dt kernel: 231 pages pagetables
May 31 08:07:06 xeon-dt kernel: swapper: page allocation failure. order:1, mode:0x20
May 31 08:07:06 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:07:06 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:07:06 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:07:06 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:07:06 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:07:06 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:06 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:07:06 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:07:06 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:07:06 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:07:06 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:07:06 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:07:06 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:07:06 xeon-dt kernel:  [<7815d312>] cache_grow+0x12c/0x14e
May 31 08:07:06 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:07:06 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:07:06 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:07:06 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:07:06 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:07:06 xeon-dt kernel:  [<78125460>] getnstimeofday+0x10/0x2a
May 31 08:07:06 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:07:06 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:07:06 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:07:06 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:07:06 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:07:06 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:07:06 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:07:06 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:07:06 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:07:06 xeon-dt kernel:  [<78100cfd>] default_idle+0x33/0x52
May 31 08:07:06 xeon-dt kernel:  [<78100d9e>] cpu_idle+0x6e/0x9f
May 31 08:07:06 xeon-dt kernel: Mem-info:
May 31 08:07:06 xeon-dt kernel: DMA per-cpu:
May 31 08:07:06 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:07:06 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:07:06 xeon-dt kernel: Normal per-cpu:
May 31 08:07:06 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:18
May 31 08:07:06 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:47
May 31 08:07:06 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:3
May 31 08:07:06 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:33
May 31 08:07:06 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:177
May 31 08:07:06 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:52
May 31 08:07:06 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:9
May 31 08:07:06 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:14
May 31 08:07:06 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:07:06 xeon-dt kernel: Free pages:       32536kB (0kB HighMem)
May 31 08:07:06 xeon-dt kernel: Active:141711 inactive:50496 dirty:97 writeback:1 unstable:0 free:8134 slab:312584 mapped:13115 pagetables:231
May 31 08:07:06 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:510 all_unreclaimable? yes
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:06 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:06 xeon-dt kernel: Normal free:24392kB min:5744kB low:7180kB high:8616kB active:566496kB inactive:201984kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:06 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:06 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:06 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:07:06 xeon-dt kernel: DMA32: empty
May 31 08:07:06 xeon-dt kernel: Normal: 5828*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 24392kB
May 31 08:07:06 xeon-dt kernel: HighMem: empty
May 31 08:07:07 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:07:07 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:07:07 xeon-dt kernel: Total swap = 2040244kB
May 31 08:07:07 xeon-dt kernel: Free swap:       2040244kB
May 31 08:07:07 xeon-dt kernel: 524272 pages of RAM
May 31 08:07:07 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:07:07 xeon-dt kernel: 7484 reserved pages
May 31 08:07:07 xeon-dt kernel: 157201 pages shared
May 31 08:07:07 xeon-dt kernel: 0 pages swap cached
May 31 08:07:07 xeon-dt kernel: 97 pages dirty
May 31 08:07:07 xeon-dt kernel: 1 pages writeback
May 31 08:07:07 xeon-dt kernel: 13115 pages mapped
May 31 08:07:07 xeon-dt kernel: 312584 pages slab
May 31 08:07:07 xeon-dt kernel: 231 pages pagetables
May 31 08:07:07 xeon-dt kernel: swapper: page allocation failure. order:1, mode:0x20
May 31 08:07:07 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:07:07 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:07:07 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:07:07 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:07:07 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:07:07 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:07 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:07:07 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:07:07 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:07:07 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:07:07 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:07:07 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:07:07 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:07:07 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:07:07 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:07 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:07:07 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:07:07 xeon-dt kernel:  [<f898b750>] e1000_clean_tx_irq+0x123/0x32e [e1000]
May 31 08:07:07 xeon-dt kernel:  [<f898bba4>] e1000_clean_rx_irq+0x249/0x5c6 [e1000]
May 31 08:07:07 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:07:07 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:07:07 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:07:07 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:07:07 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:07:07 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:07:07 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:07:07 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:07:07 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:07:07 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:07:07 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:07:07 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:07:07 xeon-dt kernel:  [<78100cfd>] default_idle+0x33/0x52
May 31 08:07:07 xeon-dt kernel:  [<78100d9e>] cpu_idle+0x6e/0x9f
May 31 08:07:07 xeon-dt kernel:  [<7841a7ed>] start_kernel+0x181/0x1bd
May 31 08:07:07 xeon-dt kernel:  [<7841a283>] unknown_bootoption+0x0/0x1a0
May 31 08:07:07 xeon-dt kernel: Mem-info:
May 31 08:07:07 xeon-dt kernel: DMA per-cpu:
May 31 08:07:07 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:07:07 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:07:07 xeon-dt kernel: Normal per-cpu:
May 31 08:07:07 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:163
May 31 08:07:07 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:47
May 31 08:07:07 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:35
May 31 08:07:07 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:33
May 31 08:07:07 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:120
May 31 08:07:07 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:59
May 31 08:07:07 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:9
May 31 08:07:07 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:14
May 31 08:07:07 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:07:07 xeon-dt kernel: Free pages:       70496kB (0kB HighMem)
May 31 08:07:07 xeon-dt kernel: Active:127541 inactive:54939 dirty:97 writeback:0 unstable:0 free:17624 slab:312881 mapped:13115 pagetables:231
May 31 08:07:07 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:680 all_unreclaimable? yes
May 31 08:07:07 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:07 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:07 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:07 xeon-dt kernel: Normal free:62352kB min:5744kB low:7180kB high:8616kB active:509816kB inactive:219756kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:07 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:07 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:07 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:07 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:07:07 xeon-dt kernel: DMA32: empty
May 31 08:07:07 xeon-dt kernel: Normal: 14506*4kB 389*8kB 10*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 62352kB
May 31 08:07:07 xeon-dt kernel: HighMem: empty
May 31 08:07:07 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:07:07 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:07:07 xeon-dt kernel: Total swap = 2040244kB
May 31 08:07:07 xeon-dt kernel: Free swap:       2040244kB
May 31 08:07:07 xeon-dt kernel: 524272 pages of RAM
May 31 08:07:07 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:07:07 xeon-dt kernel: 7484 reserved pages
May 31 08:07:07 xeon-dt kernel: 155073 pages shared
May 31 08:07:07 xeon-dt kernel: 0 pages swap cached
May 31 08:07:07 xeon-dt kernel: 97 pages dirty
May 31 08:07:07 xeon-dt kernel: 0 pages writeback
May 31 08:07:07 xeon-dt kernel: 13115 pages mapped
May 31 08:07:07 xeon-dt kernel: 312881 pages slab
May 31 08:07:07 xeon-dt kernel: 231 pages pagetables
May 31 08:07:07 xeon-dt kernel: kswapd0: page allocation failure. order:1, mode:0x20
May 31 08:07:07 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:07:07 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:07:07 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:07:07 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:07:07 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:07:07 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:07 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:07:07 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:07:07 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:07:07 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:07:07 xeon-dt kernel:  [<782e6edf>] tcp_rcv_established+0x204/0x6cf
May 31 08:07:07 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:07:07 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:07:07 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:07:07 xeon-dt kernel:  [<782ee9bc>] tcp_v4_rcv+0x6ff/0x9b0
May 31 08:07:07 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:07:07 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:07:07 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:07:07 xeon-dt kernel:  [<782b3eab>] __kfree_skb+0x4d/0x102
May 31 08:07:08 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:07:08 xeon-dt kernel:  [<781060cf>] do_gettimeofday+0x1c/0xb8
May 31 08:07:08 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:07:08 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:07:08 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:07:08 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:07:08 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:07:08 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:07:08 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:07:08 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:07:08 xeon-dt kernel:  [<7831007b>] skb_cow_data+0x8a/0x245
May 31 08:07:08 xeon-dt kernel:  [<78176e61>] dentry_iput+0x48/0xb9
May 31 08:07:08 xeon-dt kernel:  [<7831add1>] _spin_lock+0x24/0x8e
May 31 08:07:08 xeon-dt kernel:  [<78177376>] prune_dcache+0xc6/0x120
May 31 08:07:08 xeon-dt kernel:  [<781776ee>] shrink_dcache_memory+0x14/0x37
May 31 08:07:08 xeon-dt kernel:  [<7814ad72>] shrink_slab+0x16b/0x1c0
May 31 08:07:08 xeon-dt kernel:  [<7814881d>] throttle_vm_writeout+0x1e/0x5d
May 31 08:07:08 xeon-dt kernel:  [<7814c05b>] balance_pgdat+0x2a1/0x375
May 31 08:07:08 xeon-dt kernel:  [<7814c210>] kswapd+0xe1/0x100
May 31 08:07:08 xeon-dt kernel:  [<7813346a>] autoremove_wake_function+0x0/0x43
May 31 08:07:08 xeon-dt kernel:  [<78102bca>] ret_from_fork+0x6/0x14
May 31 08:07:08 xeon-dt kernel:  [<7813346a>] autoremove_wake_function+0x0/0x43
May 31 08:07:08 xeon-dt kernel:  [<7814c12f>] kswapd+0x0/0x100
May 31 08:07:08 xeon-dt kernel:  [<78101109>] kernel_thread_helper+0x5/0xb
May 31 08:07:08 xeon-dt kernel: Mem-info:
May 31 08:07:08 xeon-dt kernel: DMA per-cpu:
May 31 08:07:08 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:07:08 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:07:08 xeon-dt kernel: Normal per-cpu:
May 31 08:07:08 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:100
May 31 08:07:08 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:47
May 31 08:07:08 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:30
May 31 08:07:08 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:33
May 31 08:07:08 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:166
May 31 08:07:08 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:52
May 31 08:07:08 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:3
May 31 08:07:08 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:14
May 31 08:07:08 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:07:08 xeon-dt kernel: Free pages:       69708kB (0kB HighMem)
May 31 08:07:08 xeon-dt kernel: Active:127352 inactive:55000 dirty:97 writeback:0 unstable:0 free:17427 slab:312954 mapped:13115 pagetables:231
May 31 08:07:08 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:680 all_unreclaimable? yes
May 31 08:07:08 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:08 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:08 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:08 xeon-dt kernel: Normal free:61564kB min:5744kB low:7180kB high:8616kB active:509060kB inactive:220000kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:08 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:08 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:08 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:08 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:07:08 xeon-dt kernel: DMA32: empty
May 31 08:07:08 xeon-dt kernel: Normal: 15121*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 61564kB
May 31 08:07:08 xeon-dt kernel: HighMem: empty
May 31 08:07:08 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:07:08 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:07:08 xeon-dt kernel: Total swap = 2040244kB
May 31 08:07:08 xeon-dt kernel: Free swap:       2040244kB
May 31 08:07:08 xeon-dt kernel: 524272 pages of RAM
May 31 08:07:08 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:07:08 xeon-dt kernel: 7484 reserved pages
May 31 08:07:08 xeon-dt kernel: 155088 pages shared
May 31 08:07:08 xeon-dt kernel: 0 pages swap cached
May 31 08:07:09 xeon-dt kernel: 97 pages dirty
May 31 08:07:09 xeon-dt kernel: 0 pages writeback
May 31 08:07:09 xeon-dt kernel: 13115 pages mapped
May 31 08:07:09 xeon-dt kernel: 312954 pages slab
May 31 08:07:09 xeon-dt kernel: 231 pages pagetables
May 31 08:07:09 xeon-dt kernel: events/2: page allocation failure. order:1, mode:0x20
May 31 08:07:09 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:07:09 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:07:09 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:07:09 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:07:09 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:07:09 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:09 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:07:09 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:07:09 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:07:09 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:07:09 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:07:09 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:07:09 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:07:09 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:07:09 xeon-dt kernel:  [<7815d455>] cache_alloc_refill+0x121/0x206
May 31 08:07:09 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:07:09 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:07:09 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:07:09 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:07:09 xeon-dt kernel:  [<781060cf>] do_gettimeofday+0x1c/0xb8
May 31 08:07:09 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:07:09 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:07:09 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:07:09 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:07:09 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:07:09 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:07:09 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:07:09 xeon-dt kernel:  [<7831b219>] _spin_unlock_irq+0xb/0x24
May 31 08:07:09 xeon-dt kernel:  [<7815df70>] cache_reap+0x11c/0x1a0
May 31 08:07:09 xeon-dt kernel:  [<7812fa8a>] run_workqueue+0x71/0xe5
May 31 08:07:09 xeon-dt kernel:  [<7815de54>] cache_reap+0x0/0x1a0
May 31 08:07:09 xeon-dt kernel:  [<7812fc12>] worker_thread+0x114/0x136
May 31 08:07:09 xeon-dt kernel:  [<7811b16d>] default_wake_function+0x0/0xc
May 31 08:07:09 xeon-dt kernel:  [<7811b16d>] default_wake_function+0x0/0xc
May 31 08:07:09 xeon-dt kernel:  [<7812fafe>] worker_thread+0x0/0x136
May 31 08:07:09 xeon-dt kernel:  [<78132f0e>] kthread+0x9c/0xa1
May 31 08:07:09 xeon-dt kernel:  [<78132e72>] kthread+0x0/0xa1
May 31 08:07:09 xeon-dt kernel:  [<78101109>] kernel_thread_helper+0x5/0xb
May 31 08:07:09 xeon-dt kernel: Mem-info:
May 31 08:07:09 xeon-dt kernel: DMA per-cpu:
May 31 08:07:09 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:07:10 xeon-dt kernel: Normal per-cpu:
May 31 08:07:10 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:34
May 31 08:07:10 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:47
May 31 08:07:10 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:5
May 31 08:07:10 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:33
May 31 08:07:10 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:69
May 31 08:07:10 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:52
May 31 08:07:10 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:180
May 31 08:07:10 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:55
May 31 08:07:10 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:07:10 xeon-dt kernel: Free pages:       90752kB (0kB HighMem)
May 31 08:07:10 xeon-dt kernel: Active:119806 inactive:57132 dirty:48 writeback:0 unstable:0 free:22688 slab:312671 mapped:13115 pagetables:231
May 31 08:07:10 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:748 all_unreclaimable? yes
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:10 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:10 xeon-dt kernel: Normal free:82608kB min:5744kB low:7180kB high:8616kB active:478876kB inactive:228528kB present:2080704kB pages_scanned:26 all_unreclaimable? no
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:10 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:10 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:07:10 xeon-dt kernel: DMA32: empty
May 31 08:07:10 xeon-dt kernel: Normal: 19568*4kB 282*8kB 26*16kB 18*32kB 1*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 82608kB
May 31 08:07:10 xeon-dt kernel: HighMem: empty
May 31 08:07:10 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:07:10 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:07:10 xeon-dt kernel: Total swap = 2040244kB
May 31 08:07:10 xeon-dt kernel: Free swap:       2040244kB
May 31 08:07:10 xeon-dt kernel: 524272 pages of RAM
May 31 08:07:10 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:07:10 xeon-dt kernel: 7484 reserved pages
May 31 08:07:10 xeon-dt kernel: 153733 pages shared
May 31 08:07:10 xeon-dt kernel: 0 pages swap cached
May 31 08:07:10 xeon-dt kernel: 48 pages dirty
May 31 08:07:10 xeon-dt kernel: 0 pages writeback
May 31 08:07:10 xeon-dt kernel: 13115 pages mapped
May 31 08:07:10 xeon-dt kernel: 312671 pages slab
May 31 08:07:10 xeon-dt kernel: 231 pages pagetables
May 31 08:07:10 xeon-dt kernel: swapper: page allocation failure. order:1, mode:0x20
May 31 08:07:10 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:07:10 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:07:10 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:07:10 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:07:10 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:07:10 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:07:10 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:07:10 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:07:10 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:07:10 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:07:10 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:07:10 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:07:10 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:07:10 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:07:10 xeon-dt kernel:  [<78141701>] __do_IRQ+0xb9/0xec
May 31 08:07:10 xeon-dt kernel:  [<78125842>] irq_exit+0xb/0x44
May 31 08:07:10 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:07:10 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:07:10 xeon-dt kernel:  [<78125460>] getnstimeofday+0x10/0x2a
May 31 08:07:10 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:07:10 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:07:10 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:07:10 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:07:10 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:07:10 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:07:10 xeon-dt kernel:  [<78103748>] apic_timer_interrupt+0x1c/0x24
May 31 08:07:10 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:07:10 xeon-dt kernel:  [<78100cfd>] default_idle+0x33/0x52
May 31 08:07:10 xeon-dt kernel:  [<78100d9e>] cpu_idle+0x6e/0x9f
May 31 08:07:10 xeon-dt kernel: Mem-info:
May 31 08:07:10 xeon-dt kernel: DMA per-cpu:
May 31 08:07:10 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:07:10 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:07:10 xeon-dt kernel: Normal per-cpu:
May 31 08:07:10 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:15
May 31 08:07:10 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:46
May 31 08:07:10 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:35
May 31 08:07:10 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:54
May 31 08:07:10 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:81
May 31 08:07:10 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:52
May 31 08:07:10 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:158
May 31 08:07:10 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:54
May 31 08:07:10 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:07:10 xeon-dt kernel: Free pages:      116860kB (0kB HighMem)
May 31 08:07:10 xeon-dt kernel: Active:112052 inactive:59078 dirty:49 writeback:0 unstable:0 free:29215 slab:310711 mapped:13154 pagetables:236
May 31 08:07:10 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:850 all_unreclaimable? yes
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:10 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:07:10 xeon-dt kernel: Normal free:108716kB min:5744kB low:7180kB high:8616kB active:447860kB inactive:236312kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:10 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:07:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:07:10 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:07:10 xeon-dt kernel: DMA32: empty
May 31 08:07:10 xeon-dt kernel: Normal: 26097*4kB 399*8kB 5*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 108716kB
May 31 08:07:10 xeon-dt kernel: HighMem: empty
May 31 08:07:10 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:07:10 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:07:10 xeon-dt kernel: Total swap = 2040244kB
May 31 08:07:10 xeon-dt kernel: Free swap:       2040244kB
May 31 08:07:10 xeon-dt kernel: 524272 pages of RAM
May 31 08:07:10 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:07:10 xeon-dt kernel: 7484 reserved pages
May 31 08:07:10 xeon-dt kernel: 150664 pages shared
May 31 08:07:10 xeon-dt kernel: 0 pages swap cached
May 31 08:07:10 xeon-dt kernel: 49 pages dirty
May 31 08:07:10 xeon-dt kernel: 0 pages writeback
May 31 08:07:10 xeon-dt kernel: 13154 pages mapped
May 31 08:07:10 xeon-dt kernel: 310711 pages slab
May 31 08:07:10 xeon-dt kernel: 236 pages pagetables
May 31 08:10:39 xeon-dt kernel: e1000: eth2: e1000_watchdog_task: NIC Link is Down
May 31 08:10:39 xeon-dt kernel: e1000: eth2: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:10:39 xeon-dt kernel: e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:10:39 xeon-dt kernel: e1000: eth1: e1000_watchdog_task: NIC Link is Down
May 31 08:10:40 xeon-dt kernel: e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:10:40 xeon-dt kernel: e1000: eth2: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:11:17 xeon-dt login(pam_unix)[4227]: authentication failure; logname=LOGIN uid=0 euid=0 tty=tty1 ruser= rhost=  user=root
May 31 08:11:19 xeon-dt login[4227]: FAILED LOGIN 1 FROM (null) FOR root, Authentication failure
May 31 08:11:24 xeon-dt login(pam_unix)[4227]: session opened for user root by LOGIN(uid=0)
May 31 08:11:24 xeon-dt  -- root[4227]: ROOT LOGIN ON tty1
May 31 08:12:35 xeon-dt kernel: device eth1 entered promiscuous mode
May 31 08:12:37 xeon-dt kernel: device eth1 left promiscuous mode
May 31 08:13:50 xeon-dt kernel: e1000: eth2: e1000_watchdog_task: NIC Link is Down
May 31 08:13:50 xeon-dt kernel: e1000: eth2: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:13:50 xeon-dt kernel: e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:13:50 xeon-dt kernel: e1000: eth1: e1000_watchdog_task: NIC Link is Down
May 31 08:13:50 xeon-dt kernel: e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:13:50 xeon-dt kernel: e1000: eth2: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
May 31 08:15:05 xeon-dt kernel: swapper: page allocation failure. order:1, mode:0x20
May 31 08:15:05 xeon-dt kernel: swapper: page allocation failure. order:1, mode:0x20
May 31 08:15:05 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:15:05 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:15:05 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:15:05 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:15:05 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:15:05 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:05 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:15:05 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:15:05 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:15:05 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:15:05 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:15:05 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:15:05 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:15:05 xeon-dt kernel:  [<7815d312>] cache_grow+0x12c/0x14e
May 31 08:15:05 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:15:05 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:15:05 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:15:05 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:15:05 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:15:05 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:15:05 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:15:05 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:15:05 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:15:05 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:05 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:15:05 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:15:05 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:15:05 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:15:05 xeon-dt kernel:  [<78100cfd>] default_idle+0x33/0x52
May 31 08:15:05 xeon-dt kernel:  [<78100d9e>] cpu_idle+0x6e/0x9f
May 31 08:15:06 xeon-dt kernel: Mem-info:
May 31 08:15:06 xeon-dt kernel: DMA per-cpu:
May 31 08:15:06 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:15:06 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:15:07 xeon-dt kernel: Normal per-cpu:
May 31 08:15:07 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:18
May 31 08:15:07 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:37
May 31 08:15:07 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:178
May 31 08:15:08 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:12
May 31 08:15:08 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:180
May 31 08:15:08 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:48
May 31 08:15:08 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:30
May 31 08:15:08 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:8
May 31 08:15:08 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:15:08 xeon-dt kernel: Free pages:       86132kB (0kB HighMem)
May 31 08:15:08 xeon-dt kernel: Active:113418 inactive:61465 dirty:94 writeback:0 unstable:0 free:21533 slab:316451 mapped:13243 pagetables:238
May 31 08:15:08 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:08 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:08 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:08 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:08 xeon-dt kernel: Normal free:77988kB min:5744kB low:7180kB high:8616kB active:453324kB inactive:245860kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:08 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:08 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:08 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:08 xeon-dt kernel: DMA: 0*4kB 0*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:15:08 xeon-dt kernel: DMA32: empty
May 31 08:15:08 xeon-dt kernel: Normal: 19229*4kB 0*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 77988kB
May 31 08:15:08 xeon-dt kernel: HighMem: empty
May 31 08:15:08 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:15:08 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:15:08 xeon-dt kernel: Total swap = 2040244kB
May 31 08:15:08 xeon-dt kernel: Free swap:       2040244kB
May 31 08:15:08 xeon-dt kernel: 524272 pages of RAM
May 31 08:15:08 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:15:08 xeon-dt kernel: 7484 reserved pages
May 31 08:15:08 xeon-dt kernel: 151287 pages shared
May 31 08:15:08 xeon-dt kernel: 0 pages swap cached
May 31 08:15:08 xeon-dt kernel: 94 pages dirty
May 31 08:15:08 xeon-dt kernel: 0 pages writeback
May 31 08:15:08 xeon-dt kernel: 13243 pages mapped
May 31 08:15:08 xeon-dt kernel: 316451 pages slab
May 31 08:15:08 xeon-dt kernel: 238 pages pagetables
May 31 08:15:08 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:15:08 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:15:08 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:15:08 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:15:08 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:15:08 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:08 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:15:08 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:15:08 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:15:08 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:15:08 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:15:08 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:15:08 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:15:08 xeon-dt kernel:  [<7815d312>] cache_grow+0x12c/0x14e
May 31 08:15:08 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:15:08 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:15:08 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:15:08 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:15:08 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:15:08 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:15:09 xeon-dt kernel:  [<f898b750>] e1000_clean_tx_irq+0x123/0x32e [e1000]
May 31 08:15:09 xeon-dt kernel:  [<781060cf>] do_gettimeofday+0x1c/0xb8
May 31 08:15:09 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:15:09 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:15:09 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:15:09 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:15:09 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:09 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:15:09 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:15:09 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:15:09 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:15:09 xeon-dt kernel:  [<78100cfd>] default_idle+0x33/0x52
May 31 08:15:09 xeon-dt kernel:  [<78100d9e>] cpu_idle+0x6e/0x9f
May 31 08:15:09 xeon-dt kernel: Mem-info:
May 31 08:15:09 xeon-dt kernel: DMA per-cpu:
May 31 08:15:09 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:15:09 xeon-dt kernel: Normal per-cpu:
May 31 08:15:09 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:18
May 31 08:15:09 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:37
May 31 08:15:09 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:173
May 31 08:15:09 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:58
May 31 08:15:09 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:180
May 31 08:15:09 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:48
May 31 08:15:09 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:35
May 31 08:15:09 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:8
May 31 08:15:09 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:15:09 xeon-dt kernel: Free pages:      108132kB (0kB HighMem)
May 31 08:15:09 xeon-dt kernel: Active:109890 inactive:62337 dirty:94 writeback:0 unstable:0 free:27033 slab:313563 mapped:13243 pagetables:238
May 31 08:15:09 xeon-dt kernel: DMA free:8296kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:09 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:09 xeon-dt kernel: Normal free:99836kB min:5744kB low:7180kB high:8616kB active:439212kB inactive:249348kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:09 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:09 xeon-dt kernel: DMA: 36*4kB 1*8kB 1*16kB 0*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8296kB
May 31 08:15:09 xeon-dt kernel: DMA32: empty
May 31 08:15:09 xeon-dt kernel: Normal: 23879*4kB 406*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 99836kB
May 31 08:15:09 xeon-dt kernel: HighMem: empty
May 31 08:15:09 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:15:09 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:15:09 xeon-dt kernel: Total swap = 2040244kB
May 31 08:15:09 xeon-dt kernel: Free swap:       2040244kB
May 31 08:15:09 xeon-dt kernel: 524272 pages of RAM
May 31 08:15:09 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:15:09 xeon-dt kernel: 7484 reserved pages
May 31 08:15:09 xeon-dt kernel: 148633 pages shared
May 31 08:15:09 xeon-dt kernel: 0 pages swap cached
May 31 08:15:09 xeon-dt kernel: 94 pages dirty
May 31 08:15:09 xeon-dt kernel: 0 pages writeback
May 31 08:15:09 xeon-dt kernel: 13243 pages mapped
May 31 08:15:09 xeon-dt kernel: 313558 pages slab
May 31 08:15:09 xeon-dt kernel: 238 pages pagetables
May 31 08:15:09 xeon-dt kernel: btserver: page allocation failure. order:1, mode:0x20
May 31 08:15:09 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:15:09 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:15:09 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:15:09 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:15:09 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:15:09 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:09 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:15:09 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:15:09 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:15:09 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:15:09 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:15:09 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:15:09 xeon-dt kernel:  [<782b2927>] __release_sock+0x3e/0x5d
May 31 08:15:09 xeon-dt kernel:  [<782b30aa>] release_sock+0x6e/0x70
May 31 08:15:09 xeon-dt kernel:  [<782df1a2>] tcp_sendmsg+0x326/0xad5
May 31 08:15:09 xeon-dt kernel:  [<7814720d>] __alloc_pages+0x52/0x2b8
May 31 08:15:09 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:15:09 xeon-dt kernel:  [<782fa5bd>] inet_sendmsg+0x47/0x5f
May 31 08:15:09 xeon-dt kernel:  [<782af085>] sock_sendmsg+0xfd/0xff
May 31 08:15:09 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:09 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:15:09 xeon-dt kernel:  [<7813346a>] autoremove_wake_function+0x0/0x43
May 31 08:15:09 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:15:09 xeon-dt kernel:  [<f898b750>] e1000_clean_tx_irq+0x123/0x32e [e1000]
May 31 08:15:09 xeon-dt kernel:  [<f898bba4>] e1000_clean_rx_irq+0x249/0x5c6 [e1000]
May 31 08:15:09 xeon-dt kernel:  [<78161670>] fget+0x5a/0x98
May 31 08:15:09 xeon-dt kernel:  [<782b0779>] sys_sendto+0xc7/0xe2
May 31 08:15:09 xeon-dt kernel:  [<782b9b40>] net_rx_action+0x147/0x1ae
May 31 08:15:09 xeon-dt kernel:  [<781256e2>] __do_softirq+0x6a/0xd0
May 31 08:15:09 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:09 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:15:09 xeon-dt kernel:  [<782b07cb>] sys_send+0x37/0x3b
May 31 08:15:09 xeon-dt kernel:  [<782b0f48>] sys_socketcall+0x150/0x26d
May 31 08:15:09 xeon-dt kernel:  [<78124cf2>] sys_gettimeofday+0x2c/0x65
May 31 08:15:09 xeon-dt kernel:  [<78102c93>] sysenter_past_esp+0x54/0x75
May 31 08:15:09 xeon-dt kernel: Mem-info:
May 31 08:15:09 xeon-dt kernel: DMA per-cpu:
May 31 08:15:09 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:15:09 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:15:09 xeon-dt kernel: Normal per-cpu:
May 31 08:15:09 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:105
May 31 08:15:09 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:56
May 31 08:15:09 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:173
May 31 08:15:09 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:58
May 31 08:15:09 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:157
May 31 08:15:09 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:60
May 31 08:15:09 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:25
May 31 08:15:09 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:8
May 31 08:15:09 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:15:09 xeon-dt kernel: Free pages:      129132kB (0kB HighMem)
May 31 08:15:09 xeon-dt kernel: Active:106610 inactive:63452 dirty:96 writeback:0 unstable:0 free:32283 slab:310207 mapped:13243 pagetables:238
May 31 08:15:09 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:136 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:09 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:09 xeon-dt kernel: Normal free:120988kB min:5744kB low:7180kB high:8616kB active:426092kB inactive:253808kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:09 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:09 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:09 xeon-dt kernel: DMA: 36*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:15:09 xeon-dt kernel: DMA32: empty
May 31 08:15:09 xeon-dt kernel: Normal: 29161*4kB 399*8kB 6*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 120988kB
May 31 08:15:09 xeon-dt kernel: HighMem: empty
May 31 08:15:09 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:15:09 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:15:09 xeon-dt kernel: Total swap = 2040244kB
May 31 08:15:09 xeon-dt kernel: Free swap:       2040244kB
May 31 08:15:09 xeon-dt kernel: 524272 pages of RAM
May 31 08:15:09 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:15:09 xeon-dt kernel: 7484 reserved pages
May 31 08:15:09 xeon-dt kernel: 146453 pages shared
May 31 08:15:09 xeon-dt kernel: 0 pages swap cached
May 31 08:15:09 xeon-dt kernel: 96 pages dirty
May 31 08:15:09 xeon-dt kernel: 0 pages writeback
May 31 08:15:09 xeon-dt kernel: 13243 pages mapped
May 31 08:15:09 xeon-dt kernel: 310207 pages slab
May 31 08:15:09 xeon-dt kernel: 238 pages pagetables
May 31 08:15:09 xeon-dt kernel: kswapd0: page allocation failure. order:1, mode:0x20
May 31 08:15:09 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:15:09 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:15:09 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:15:09 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:15:09 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:15:09 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:09 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:15:09 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:15:09 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:15:10 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:15:10 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:15:10 xeon-dt kernel:  [<782e6ef8>] tcp_rcv_established+0x21d/0x6cf
May 31 08:15:10 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:15:10 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:15:10 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:15:10 xeon-dt kernel:  [<7815d312>] cache_grow+0x12c/0x14e
May 31 08:15:10 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:15:10 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:15:10 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:10 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:15:10 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:15:10 xeon-dt kernel:  [<f898b750>] e1000_clean_tx_irq+0x123/0x32e [e1000]
May 31 08:15:10 xeon-dt kernel:  [<f898bba4>] e1000_clean_rx_irq+0x249/0x5c6 [e1000]
May 31 08:15:10 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:15:10 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:15:10 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:15:10 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:15:10 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:10 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:15:10 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:10 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:15:10 xeon-dt kernel:  [<78176dd0>] d_callback+0x0/0x24
May 31 08:15:10 xeon-dt kernel:  [<78130911>] call_rcu+0x1a/0x6e
May 31 08:15:10 xeon-dt kernel:  [<78177380>] prune_dcache+0xd0/0x120
May 31 08:15:10 xeon-dt kernel:  [<781776ee>] shrink_dcache_memory+0x14/0x37
May 31 08:15:10 xeon-dt kernel:  [<7814ad72>] shrink_slab+0x16b/0x1c0
May 31 08:15:10 xeon-dt kernel:  [<7814881d>] throttle_vm_writeout+0x1e/0x5d
May 31 08:15:10 xeon-dt kernel:  [<7814c05b>] balance_pgdat+0x2a1/0x375
May 31 08:15:10 xeon-dt kernel:  [<7814c210>] kswapd+0xe1/0x100
May 31 08:15:10 xeon-dt kernel:  [<7813346a>] autoremove_wake_function+0x0/0x43
May 31 08:15:10 xeon-dt kernel:  [<78102bca>] ret_from_fork+0x6/0x14
May 31 08:15:10 xeon-dt kernel:  [<7813346a>] autoremove_wake_function+0x0/0x43
May 31 08:15:10 xeon-dt kernel:  [<7814c12f>] kswapd+0x0/0x100
May 31 08:15:10 xeon-dt kernel:  [<78101109>] kernel_thread_helper+0x5/0xb
May 31 08:15:10 xeon-dt kernel: Mem-info:
May 31 08:15:10 xeon-dt kernel: DMA per-cpu:
May 31 08:15:10 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:15:10 xeon-dt kernel: Normal per-cpu:
May 31 08:15:10 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:7
May 31 08:15:10 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:56
May 31 08:15:10 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:179
May 31 08:15:10 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:47
May 31 08:15:10 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:30
May 31 08:15:10 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:60
May 31 08:15:10 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:2
May 31 08:15:10 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:8
May 31 08:15:10 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:15:10 xeon-dt kernel: Free pages:      119148kB (0kB HighMem)
May 31 08:15:10 xeon-dt kernel: Active:106530 inactive:63475 dirty:96 writeback:0 unstable:0 free:29787 slab:309881 mapped:13243 pagetables:238
May 31 08:15:10 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:136 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:10 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:10 xeon-dt kernel: Normal free:111004kB min:5744kB low:7180kB high:8616kB active:425772kB inactive:253900kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:10 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:10 xeon-dt kernel: DMA: 36*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:15:10 xeon-dt kernel: DMA32: empty
May 31 08:15:10 xeon-dt kernel: Normal: 27481*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 111004kB
May 31 08:15:10 xeon-dt kernel: HighMem: empty
May 31 08:15:10 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:15:10 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:15:10 xeon-dt kernel: Total swap = 2040244kB
May 31 08:15:10 xeon-dt kernel: Free swap:       2040244kB
May 31 08:15:10 xeon-dt kernel: 524272 pages of RAM
May 31 08:15:10 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:15:10 xeon-dt kernel: 7484 reserved pages
May 31 08:15:10 xeon-dt kernel: 146589 pages shared
May 31 08:15:10 xeon-dt kernel: 0 pages swap cached
May 31 08:15:10 xeon-dt kernel: 96 pages dirty
May 31 08:15:10 xeon-dt kernel: 0 pages writeback
May 31 08:15:10 xeon-dt kernel: 13243 pages mapped
May 31 08:15:10 xeon-dt kernel: 309881 pages slab
May 31 08:15:10 xeon-dt kernel: 238 pages pagetables
May 31 08:15:10 xeon-dt kernel: swapper: page allocation failure. order:1, mode:0x20
May 31 08:15:10 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:15:10 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:15:10 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:15:10 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:15:10 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:15:10 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:10 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:15:10 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:15:10 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:15:10 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:15:10 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:15:10 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:15:10 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:15:10 xeon-dt kernel:  [<7815d312>] cache_grow+0x12c/0x14e
May 31 08:15:10 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:15:10 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:15:10 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:15:10 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:15:10 xeon-dt kernel:  [<782b3eab>] __kfree_skb+0x4d/0x102
May 31 08:15:10 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:15:10 xeon-dt kernel:  [<78125460>] getnstimeofday+0x10/0x2a
May 31 08:15:10 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:15:10 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:15:10 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:15:10 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:15:10 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:10 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:15:10 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:15:10 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:15:10 xeon-dt kernel:  [<78100cca>] default_idle+0x0/0x52
May 31 08:15:10 xeon-dt kernel:  [<78100cfd>] default_idle+0x33/0x52
May 31 08:15:10 xeon-dt kernel:  [<78100d9e>] cpu_idle+0x6e/0x9f
May 31 08:15:10 xeon-dt kernel: Mem-info:
May 31 08:15:10 xeon-dt kernel: DMA per-cpu:
May 31 08:15:10 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:15:10 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:15:10 xeon-dt kernel: Normal per-cpu:
May 31 08:15:10 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:155
May 31 08:15:10 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:51
May 31 08:15:10 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:141
May 31 08:15:10 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:47
May 31 08:15:10 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:160
May 31 08:15:10 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:60
May 31 08:15:10 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:1
May 31 08:15:10 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:8
May 31 08:15:10 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:15:10 xeon-dt kernel: Free pages:      140120kB (0kB HighMem)
May 31 08:15:10 xeon-dt kernel: Active:104009 inactive:64399 dirty:96 writeback:0 unstable:0 free:35030 slab:306067 mapped:13243 pagetables:238
May 31 08:15:10 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:102 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:10 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:10 xeon-dt kernel: Normal free:131976kB min:5744kB low:7180kB high:8616kB active:415688kB inactive:257596kB present:2080704kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:10 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:10 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:10 xeon-dt kernel: DMA: 38*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:15:10 xeon-dt kernel: DMA32: empty
May 31 08:15:10 xeon-dt kernel: Normal: 31904*4kB 407*8kB 3*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 131976kB
May 31 08:15:10 xeon-dt kernel: HighMem: empty
May 31 08:15:10 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:15:10 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:15:10 xeon-dt kernel: Total swap = 2040244kB
May 31 08:15:10 xeon-dt kernel: Free swap:       2040244kB
May 31 08:15:10 xeon-dt kernel: 524272 pages of RAM
May 31 08:15:10 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:15:10 xeon-dt kernel: 7484 reserved pages
May 31 08:15:10 xeon-dt kernel: 144992 pages shared
May 31 08:15:10 xeon-dt kernel: 0 pages swap cached
May 31 08:15:10 xeon-dt kernel: 96 pages dirty
May 31 08:15:10 xeon-dt kernel: 0 pages writeback
May 31 08:15:10 xeon-dt kernel: 13243 pages mapped
May 31 08:15:11 xeon-dt kernel: 306067 pages slab
May 31 08:15:11 xeon-dt kernel: 238 pages pagetables
May 31 08:15:52 xeon-dt kernel: find_dflt_route: page allocation failure. order:1, mode:0x20
May 31 08:15:52 xeon-dt kernel:  [<78147393>] __alloc_pages+0x1d8/0x2b8
May 31 08:15:52 xeon-dt kernel:  [<7815c525>] kmem_getpages+0x2f/0x8c
May 31 08:15:52 xeon-dt kernel:  [<7815d297>] cache_grow+0xb1/0x14e
May 31 08:15:52 xeon-dt kernel:  [<7815d48e>] cache_alloc_refill+0x15a/0x206
May 31 08:15:52 xeon-dt kernel:  [<7815d7c5>] __kmalloc+0x68/0x80
May 31 08:15:52 xeon-dt kernel:  [<782b3ba2>] __alloc_skb+0x4c/0xf6
May 31 08:15:52 xeon-dt kernel:  [<782e63af>] tcp_collapse+0xe9/0x34e
May 31 08:15:52 xeon-dt kernel:  [<782e6726>] tcp_prune_queue+0x97/0x1db
May 31 08:15:52 xeon-dt kernel:  [<782e5e5e>] tcp_data_queue+0x2ba/0x722
May 31 08:15:52 xeon-dt kernel:  [<7831af17>] _read_lock+0x24/0x8c
May 31 08:15:52 xeon-dt kernel:  [<782e6eb7>] tcp_rcv_established+0x1dc/0x6cf
May 31 08:15:52 xeon-dt kernel:  [<782e7210>] tcp_rcv_established+0x535/0x6cf
May 31 08:15:52 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:15:52 xeon-dt kernel:  [<782ee2b8>] tcp_v4_do_rcv+0xe5/0xea
May 31 08:15:52 xeon-dt kernel:  [<782eea45>] tcp_v4_rcv+0x788/0x9b0
May 31 08:15:52 xeon-dt kernel:  [<7831b18a>] _spin_unlock+0xf/0x23
May 31 08:15:52 xeon-dt kernel:  [<7815d312>] cache_grow+0x12c/0x14e
May 31 08:15:52 xeon-dt kernel:  [<782d48fe>] ip_local_deliver+0x109/0x287
May 31 08:15:52 xeon-dt kernel:  [<782d4d1f>] ip_rcv+0x2a3/0x577
May 31 08:15:52 xeon-dt kernel:  [<f898c6c2>] e1000_alloc_rx_buffers+0x22a/0x418 [e1000]
May 31 08:15:52 xeon-dt kernel:  [<782b9841>] netif_receive_skb+0x2b8/0x36d
May 31 08:15:52 xeon-dt kernel:  [<782b3eab>] __kfree_skb+0x4d/0x102
May 31 08:15:52 xeon-dt kernel:  [<f898bb26>] e1000_clean_rx_irq+0x1cb/0x5c6 [e1000]
May 31 08:15:52 xeon-dt kernel:  [<f898bba4>] e1000_clean_rx_irq+0x249/0x5c6 [e1000]
May 31 08:15:52 xeon-dt kernel:  [<f898b546>] e1000_clean+0xa6/0x18d [e1000]
May 31 08:15:52 xeon-dt kernel:  [<782b9a92>] net_rx_action+0x99/0x1ae
May 31 08:15:52 xeon-dt kernel:  [<78125733>] __do_softirq+0xbb/0xd0
May 31 08:15:52 xeon-dt kernel:  [<78125790>] do_softirq+0x48/0x4a
May 31 08:15:52 xeon-dt kernel:  [<78125879>] irq_exit+0x42/0x44
May 31 08:15:52 xeon-dt kernel:  [<781050e7>] do_IRQ+0x37/0x62
May 31 08:15:52 xeon-dt kernel:  [<781036ba>] common_interrupt+0x1a/0x20
May 31 08:15:52 xeon-dt kernel:  [<7814007b>] audit_filter_user_rules+0x89/0xb9
May 31 08:15:52 xeon-dt kernel:  [<781db83c>] _raw_spin_trylock+0x7/0x28
May 31 08:15:52 xeon-dt kernel:  [<7831add1>] _spin_lock+0x24/0x8e
May 31 08:15:52 xeon-dt kernel:  [<78150ec7>] unlink_file_vma+0x2b/0x62
May 31 08:15:52 xeon-dt kernel:  [<7814dc6b>] free_pgtables+0x77/0x90
May 31 08:15:52 xeon-dt kernel:  [<78152cec>] exit_mmap+0xa0/0x11d
May 31 08:15:52 xeon-dt kernel:  [<7811db29>] mmput+0x33/0x94
May 31 08:15:52 xeon-dt kernel:  [<7816ac1b>] exec_mmap+0xf4/0x213
May 31 08:15:52 xeon-dt kernel:  [<7816b489>] flush_old_exec+0x43/0x1f9
May 31 08:15:52 xeon-dt kernel:  [<7816ab14>] kernel_read+0x40/0x53
May 31 08:15:52 xeon-dt kernel:  [<7818b108>] load_elf_binary+0x2d4/0xc14
May 31 08:15:52 xeon-dt kernel:  [<781daeaf>] copy_from_user+0x58/0x91
May 31 08:15:52 xeon-dt kernel:  [<7818ae34>] load_elf_binary+0x0/0xc14
May 31 08:15:52 xeon-dt kernel:  [<7816b9a7>] search_binary_handler+0x17d/0x2c9
May 31 08:15:52 xeon-dt kernel:  [<7816bc58>] do_execve+0x165/0x203
May 31 08:15:52 xeon-dt kernel:  [<78101a70>] sys_execve+0x39/0x85
May 31 08:15:52 xeon-dt kernel:  [<78102c93>] sysenter_past_esp+0x54/0x75
May 31 08:15:52 xeon-dt kernel: Mem-info:
May 31 08:15:52 xeon-dt kernel: DMA per-cpu:
May 31 08:15:52 xeon-dt kernel: cpu 0 hot: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 0 cold: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 1 hot: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 1 cold: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 2 hot: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 2 cold: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 3 hot: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: cpu 3 cold: high 0, batch 1 used:0
May 31 08:15:52 xeon-dt kernel: DMA32 per-cpu: empty
May 31 08:15:52 xeon-dt kernel: Normal per-cpu:
May 31 08:15:52 xeon-dt kernel: cpu 0 hot: high 186, batch 31 used:158
May 31 08:15:52 xeon-dt kernel: cpu 0 cold: high 62, batch 15 used:51
May 31 08:15:52 xeon-dt kernel: cpu 1 hot: high 186, batch 31 used:93
May 31 08:15:52 xeon-dt kernel: cpu 1 cold: high 62, batch 15 used:47
May 31 08:15:52 xeon-dt kernel: cpu 2 hot: high 186, batch 31 used:180
May 31 08:15:52 xeon-dt kernel: cpu 2 cold: high 62, batch 15 used:59
May 31 08:15:52 xeon-dt kernel: cpu 3 hot: high 186, batch 31 used:21
May 31 08:15:52 xeon-dt kernel: cpu 3 cold: high 62, batch 15 used:8
May 31 08:15:52 xeon-dt kernel: HighMem per-cpu: empty
May 31 08:15:52 xeon-dt kernel: Free pages:      160616kB (0kB HighMem)
May 31 08:15:52 xeon-dt kernel: Active:102218 inactive:65424 dirty:93 writeback:0 unstable:0 free:40154 slab:301671 mapped:13504 pagetables:253
May 31 08:15:52 xeon-dt kernel: DMA free:8144kB min:44kB low:52kB high:64kB active:348kB inactive:0kB present:16384kB pages_scanned:68 all_unreclaimable? no
May 31 08:15:52 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:52 xeon-dt kernel: DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:52 xeon-dt kernel: lowmem_reserve[]: 0 0 2031 2031
May 31 08:15:52 xeon-dt kernel: Normal free:152472kB min:5744kB low:7180kB high:8616kB active:408524kB inactive:261696kB present:2080704kB pages_scanned:19 all_unreclaimable? no
May 31 08:15:52 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:52 xeon-dt kernel: HighMem free:0kB min:128kB low:128kB high:128kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
May 31 08:15:53 xeon-dt kernel: lowmem_reserve[]: 0 0 0 0
May 31 08:15:53 xeon-dt kernel: DMA: 42*4kB 1*8kB 0*16kB 1*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 8144kB
May 31 08:15:53 xeon-dt kernel: DMA32: empty
May 31 08:15:53 xeon-dt kernel: Normal: 37032*4kB 407*8kB 2*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 152472kB
May 31 08:15:53 xeon-dt kernel: HighMem: empty
May 31 08:15:53 xeon-dt kernel: Swap cache: add 0, delete 0, find 0/0, race 0+0
May 31 08:15:53 xeon-dt kernel: Free swap  = 2040244kB
May 31 08:15:53 xeon-dt kernel: Total swap = 2040244kB
May 31 08:15:53 xeon-dt kernel: Free swap:       2040244kB
May 31 08:15:53 xeon-dt kernel: 524272 pages of RAM
May 31 08:15:53 xeon-dt kernel: 0 pages of HIGHMEM
May 31 08:15:53 xeon-dt kernel: 7484 reserved pages
May 31 08:15:53 xeon-dt kernel: 144659 pages shared
May 31 08:15:53 xeon-dt kernel: 0 pages swap cached
May 31 08:15:53 xeon-dt kernel: 93 pages dirty
May 31 08:15:53 xeon-dt kernel: 0 pages writeback
May 31 08:15:53 xeon-dt kernel: 13504 pages mapped
May 31 08:15:53 xeon-dt kernel: 301671 pages slab
May 31 08:15:53 xeon-dt kernel: 253 pages pagetables

--------------040706040606070706010006
Content-Type: text/x-patch;
 name="sts.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sts.patch"

diff --git a/include/linux/if.h b/include/linux/if.h
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -52,6 +52,11 @@
 /* Private (from user) interface flags (netdevice->priv_flags). */
 #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.          */
 #define IFF_EBRIDGE	0x2		/* Ethernet bridging device.	*/
+#define IFF_ACCEPT_LOCAL_ADDRS  0x8     /**  Accept pkts even if they come from a local
+                                         * address.  This lets use send pkts to ourselves
+                                         * over external interfaces (when used in conjunction
+                                         * with SO_BINDTODEVICE
+                                         */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -122,6 +122,14 @@
 #define SIOCBRADDIF	0x89a2		/* add interface to bridge      */
 #define SIOCBRDELIF	0x89a3		/* remove interface from bridge */
 
+/* Ben's little hack land */
+#define SIOCSACCEPTLOCALADDRS  0x89ba   /*  Allow interfaces to accept pkts from
+                                         * local interfaces...use with SO_BINDTODEVICE
+                                         */
+#define SIOCGACCEPTLOCALADDRS  0x89bb   /*  Allow interfaces to accept pkts from
+                                         * local interfaces...use with SO_BINDTODEVICE
+                                         */
+
 /* Device private ioctl calls */
 
 /*
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2375,6 +2375,24 @@ static int dev_ifsioc(struct ifreq *ifr,
 		case SIOCSIFNAME:
 			ifr->ifr_newname[IFNAMSIZ-1] = '\0';
 			return dev_change_name(dev, ifr->ifr_newname);
+			
+	        case SIOCSACCEPTLOCALADDRS:
+                        if (ifr->ifr_flags) {
+				dev->priv_flags |= IFF_ACCEPT_LOCAL_ADDRS;
+			}
+			else {
+				dev->priv_flags &= ~IFF_ACCEPT_LOCAL_ADDRS;
+			}
+			return 0;
+
+	        case SIOCGACCEPTLOCALADDRS:
+			if (dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS) {
+				ifr->ifr_flags = 1;
+			}
+			else {
+				ifr->ifr_flags = 0;
+			}
+			return 0;
 
 		/*
 		 *	Unknown or private ioctl
@@ -2474,6 +2492,7 @@ int dev_ioctl(unsigned int cmd, void __u
 		case SIOCGIFMAP:
 		case SIOCGIFINDEX:
 		case SIOCGIFTXQLEN:
+	        case SIOCGACCEPTLOCALADDRS:
 			dev_load(ifr.ifr_name);
 			read_lock(&dev_base_lock);
 			ret = dev_ifsioc(&ifr, cmd);
@@ -2550,6 +2569,7 @@ int dev_ioctl(unsigned int cmd, void __u
 		case SIOCBONDCHANGEACTIVE:
 		case SIOCBRADDIF:
 		case SIOCBRDELIF:
+		case SIOCSACCEPTLOCALADDRS:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			dev_load(ifr.ifr_name);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -419,6 +419,27 @@ static int arp_ignore(struct in_device *
 	return !inet_confirm_addr(dev, sip, tip, scope);
 }
 
+
+static int is_ip_on_dev(struct net_device* dev, __u32 ip) {
+	int rv = 0;
+	struct in_device* in_dev = in_dev_get(dev);
+	if (in_dev) {
+		struct in_ifaddr *ifa;
+
+		rcu_read_lock();
+		for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
+			if (ifa->ifa_address == ip) {
+				/* match */
+				rv = 1;
+				break;
+			}
+		}
+		rcu_read_unlock();
+		in_dev_put(in_dev);
+	}
+	return rv;
+}
+
 static int arp_filter(__u32 sip, __u32 tip, struct net_device *dev)
 {
 	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = sip,
@@ -429,10 +450,36 @@ static int arp_filter(__u32 sip, __u32 t
 
 	if (ip_route_output_key(&rt, &fl) < 0) 
 		return 1;
-	if (rt->u.dst.dev != dev) { 
-		NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
-		flag = 1;
-	} 
+	if (rt->u.dst.dev != dev) {
+		if ((dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS) &&
+		    (rt->u.dst.dev == &loopback_dev))  {
+ 			/* Accept these IFF target-ip == dev's IP */
+ 			/* TODO:  Need to force the ARP response back out the interface
+ 			 * instead of letting it route locally.
+ 			 */
+ 			
+ 			if (is_ip_on_dev(dev, tip)) {
+ 				/* OK, we'll let this special case slide, so that we can
+ 				 * arp from one local interface to another.  This seems
+ 				 * to work, but could use some review. --Ben
+ 				 */
+ 				/*printk("arp_filter, sip: %x tip: %x  dev: %s, STS override (ip on dev)\n",
+				  sip, tip, dev->name);*/
+ 			}
+ 			else {
+ 				/*printk("arp_filter, sip: %x tip: %x  dev: %s, IP is NOT on dev\n",
+				  sip, tip, dev->name);*/
+				NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
+ 				flag = 1;
+ 			}
+		}
+		else {
+			/*printk("arp_filter, not lpbk  sip: %x tip: %x  dev: %s  flgs: %hx  dst.dev: %p  lbk: %p\n",
+			  sip, tip, dev->name, dev->priv_flags, rt->u.dst.dev, &loopback_dev);*/
+			NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
+			flag = 1;
+		}
+	}
 	ip_rt_put(rt); 
 	return flag; 
 } 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -185,8 +185,16 @@ int fib_validate_source(u32 src, u32 dst
 
 	if (fib_lookup(&fl, &res))
 		goto last_resort;
-	if (res.type != RTN_UNICAST)
-		goto e_inval_res;
+	if (res.type != RTN_UNICAST) {
+                if ((res.type == RTN_LOCAL) &&
+                    (dev->priv_flags & IFF_ACCEPT_LOCAL_ADDRS)) {
+                        /* All is OK */
+                }
+                else {
+                        goto e_inval_res;
+                }
+        }
+
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);
 #ifdef CONFIG_IP_ROUTE_MULTIPATH

--------------040706040606070706010006--
