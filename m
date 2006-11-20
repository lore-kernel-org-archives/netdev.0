From: Ben Greear <greearb@candelatech.com>
Subject: Received zero-length skb from e1000 driver?
Date: Mon, 20 Nov 2006 08:35:51 -0800
Message-ID: <4561D967.5040108@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:32186 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S934261AbWKTQeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 11:34:19 -0500
Received: from [71.112.210.101] (pool-71-112-210-101.sttlwa.dsl-w.verizon.net [71.112.210.101])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id kAKGYIUe027589
	for <netdev@vger.kernel.org>; Mon, 20 Nov 2006 08:34:19 -0800
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We've been running a machine under load (bridging ~77kpps bi-directional 
for several days)
on kernel 2.6.18.2 plus our hacks.  In particular, we are using our wan 
emulator module which
is proprietary and taints the kernel.

After several days, there was the panic below due to a do_div error.  As 
far as I can tell, the
only do_div in the code path running for this test is where we use 
skb->len as the 'bottom'.
My assumption is that for some reason skb->len was zero.  Is this ever 
valid?

Please also note that the machine was under serious memory pressure, 
getting order 0 allocation
failures, etc.

I've added checks to our code to deal with zero-length skbs in the 
future, but I thought
the e1000 driver writers might be interested...

Thanks,
Ben

java: page allocation failure. order:0, mode:0x20
swapper: page allocation failure. order:0, mode:0x20
 [<78104252>]  [<78104252>] show_trace+0x12/0x20
show_trace+0x12/0x20
 [<78104929>]  [<78104929>] dump_stack+0x19/0x20
dump_stack+0x19/0x20
 [<78155520>]  [<78155520>] __alloc_pages+0x1e0/0x2e0
__alloc_pages+0x1e0/0x2e0
 [<7816c45f>]  [<7816c45f>] cache_alloc_refill+0x2cf/0x500
cache_alloc_refill+0x2cf/0x500
 [<7816c732>]  [<7816c732>] __kmalloc+0xa2/0xb0
 [<782e7e38>] __kmalloc+0xa2/0xb0
 [<782e7e38>] __alloc_skb+0x48/0x100
__alloc_skb+0x48/0x100
 [<782e8b1d>]  [<782e8b1d>] __netdev_alloc_skb+0x1d/0x40
__netdev_alloc_skb+0x1d/0x40
 [<b88f232f>]  [<b88f232f>] e1000_alloc_rx_buffers+0x14f/0x340 [e1000]
e1000_alloc_rx_buffers+0x14f/0x340 [e1000]
 [<b88f27e9>]  [<b88f27e9>] e1000_clean_rx_irq+0x2c9/0x4d0 [e1000]
e1000_clean_rx_irq+0x2c9/0x4d0 [e1000]
 [<b88f1850>]  [<b88f1850>] e1000_clean+0x120/0x170 [e1000]
e1000_clean+0x120/0x170 [e1000]
 [<782ee5b5>]  [<782ee5b5>] net_rx_action+0xc5/0x1f0
net_rx_action+0xc5/0x1f0
 [<78125e08>]  [<78125e08>] __do_softirq+0x88/0x110
__do_softirq+0x88/0x110
 [<78125f09>]  [<78125f09>] do_softirq+0x79/0x80
 [<7812609d>] do_softirq+0x79/0x80
 [<7812609d>] irq_exit+0x5d/0x60
irq_exit+0x5d/0x60
 [<78105a6d>]  [<78105a6d>] do_IRQ+0x4d/0xa0
do_IRQ+0x4d/0xa0
 [<78103ae9>]  [<78103ae9>] common_interrupt+0x25/0x2c
common_interrupt+0x25/0x2c
 [<7810185d>] <6>Mem-info:
cpu_idle+0x4d/0xb0
DMA per-cpu: [<781116f2>]
cpu 0 hot: high 0, batch 1 used:0
start_secondary+0x352/0x470
cpu 0 cold: high 0, batch 1 used:0
 [<00000000>] cpu 1 hot: high 0, batch 1 used:0
cpu 1 cold: high 0, batch 1 used:0
0x0
cpu 2 hot: high 0, batch 1 used:0
 [<79f25fb4>] cpu 2 cold: high 0, batch 1 used:0
0x79f25fb4
cpu 3 hot: high 0, batch 1 used:0
Mem-info:
cpu 3 cold: high 0, batch 1 used:0
DMA per-cpu:DMA32 per-cpu:
 empty
cpu 0 hot: high 0, batch 1 used:0
Normal per-cpu:cpu 0 cold: high 0, batch 1 used:0

cpu 1 hot: high 0, batch 1 used:0
cpu 0 hot: high 186, batch 31 used:1
cpu 1 cold: high 0, batch 1 used:0
cpu 0 cold: high 62, batch 15 used:56
cpu 2 hot: high 0, batch 1 used:0
cpu 1 hot: high 186, batch 31 used:30
cpu 2 cold: high 0, batch 1 used:0
cpu 1 cold: high 62, batch 15 used:55
cpu 3 hot: high 0, batch 1 used:0
cpu 2 hot: high 186, batch 31 used:23
cpu 3 cold: high 0, batch 1 used:0
cpu 2 cold: high 62, batch 15 used:61
DMA32 per-cpu:cpu 3 hot: high 186, batch 31 used:2
 empty
cpu 3 cold: high 62, batch 15 used:48
Normal per-cpu:HighMem per-cpu:
 empty
cpu 0 hot: high 186, batch 31 used:1
Free pages:        5524kB (0kB HighMem)
cpu 0 cold: high 62, batch 15 used:56
Active:159788 inactive:56563 dirty:4896 writeback:0 unstable:0 free:1381 
slab:30cpu 1 hot: high 186,
 batch 31 used:30
DMA free:4052kB min:60kB low:72kB high:88kB active:0kB inactive:0kB 
present:163scpu 1 cold: high 62,
 batch 15 used:55
lowmem_reserve[]:cpu 2 hot: high 186, batch 31 used:23
 0cpu 2 cold: high 62, batch 15 used:61
 0cpu 3 hot: high 186, batch 31 used:2
 1007cpu 3 cold: high 62, batch 15 used:48
 1007HighMem per-cpu:
 empty
DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB pagoFree pages:        5
524kB (0kB HighMem)
lowmem_reserve[]:Active:159788 inactive:56563 dirty:4896 writeback:0 
unstable:00 0DMA free:4052kB mi
n:60kB low:72kB high:88kB active:0kB inactive:0kB present:1s 
0lowmem_reserve[]: 1007 0 1007 0
 1007Normal free:1472kB min:4028kB low:5032kB high:6040kB 
active:639152kB inacto 1007lowmem_reserve[
]:
 0DMA32 free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB 
present:0kB po 0lowmem_reserve[]:
0 0 0 0
 1007HighMem free:0kB min:128kB low:128kB high:128kB active:0kB 
inactive:0kB pro 1007lowmem_reserve[
]:
 0Normal free:1472kB min:4028kB low:5032kB high:6040kB active:639152kB 
inactiveo 0lowmem_reserve[]:
0 0 0 0
 0DMA:  01*4kB
0*8kB HighMem free:0kB min:128kB low:128kB high:128kB active:0kB 
inactive:0kB po1*16kB lowmem_reserv
e[]:0*32kB  01*64kB  01*128kB  01*256kB  01*512kB
1*1024kB DMA: 1*2048kB 1*4kB 0*4096kB 0*8kB = 4052kB
1*16kB DMA32: 0*32kB empty
1*64kB Normal: 1*128kB 0*4kB 1*256kB 0*8kB 1*512kB 0*16kB 1*1024kB 
0*32kB 1*204B1*256kB DMA32: 0*512
kB empty
1*1024kB Normal: 0*2048kB 0*4kB 0*4096kB 0*8kB = 1472kB
0*16kB HighMem: 0*32kB empty
1*64kB Swap cache: add 0, delete 0, find 0/0, race 0+0
1*128kB Free swap  = 2031608kB
1*256kB Total swap = 2031608kB
0*512kB <6>Free swap:       2031608kB
1*1024kB 0*2048kB 0*4096kB = 1472kB
HighMem: empty
Swap cache: add 0, delete 0, find 0/0, race 0+0
Free swap  = 2031608kB
Total swap = 2031608kB
Free swap:       2031608kB
262112 pages of RAM
0 pages of HIGHMEM
5326 reserved pages
191261 pages shared
0 pages swap cached
4896 pages dirty
0 pages writeback
11927 pages mapped
35607 pages slab
600 pages pagetables
262112 pages of RAM
262112 pages of RAM
0 pages of HIGHMEM
0 pages of HIGHMEM
5326 reserved pages
5326 reserved pages
191261 pages shared
191261 pages shared
0 pages swap cached
0 pages swap cached
4896 pages dirty
4896 pages dirty
0 pages writeback
0 pages writeback
11927 pages mapped
11927 pages mapped
35607 pages slab
35607 pages slab
600 pages pagetables
600 pages pagetables
divide error: 0000 [#1]
PREEMPT SMP
Modules linked in: 8021q redirdev macvlan wanlink wlan_wep ath_pci 
ath_rate_onodCPU:    1
EIP:    0060:[<b89f267e>]    Tainted: P      VLI
EFLAGS: 00010046   (2.6.18 #3)
EIP is at handleRcvWlp+0xce/0x1a80 [wanlink]
eax: 07735940   ebx: 00000000   ecx: 00000000   edx: 00000000
esi: a50af430   edi: 00042286   ebp: b7fc5d64   esp: b7fc5ca0
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, ti=b7fc4000 task=b7fc0aa0 task.ti=b7fc4000)
Stack: 00000046 00000046 783c3c54 0000000a b7fc5cd0 00000046 07735940 
00000000
       00000001 783c3c40 00000001 00000000 00000000 783c3c54 b7fc0aa0 
7d513480
       783551c9 0c2351ca 7d5134b0 a65a1800 00000beb 783c3c54 0000000a 
b7fc5d1c
Call Trace:
 [<781041d1>] show_stack_log_lvl+0xb1/0xe0
 [<7810442e>] show_registers+0x1ce/0x260
 [<781045f1>] die+0x131/0x2d0
 [<7810480f>] do_trap+0x7f/0xb0
 [<78104ef4>] do_divide_error+0x94/0xa0
 [<78103c51>] error_code+0x39/0x40
 [<b89f4654>] wp_handle_rcv_pkt+0x504/0x6f0 [wanlink]
 [<b89f55c9>] handle_rcv+0xa9/0x180 [wanlink]
 [<782ec7ad>] netif_receive_skb+0x36d/0x3b0
 [<b88f2649>] e1000_clean_rx_irq+0x129/0x4d0 [e1000]
 [<b88f1850>] e1000_clean+0x120/0x170 [e1000]
 [<782ee5b5>] net_rx_action+0xc5/0x1f0
 [<78125e08>] __do_softirq+0x88/0x110
 [<78125f09>] do_softirq+0x79/0x80
 [<7812609d>] irq_exit+0x5d/0x60
 [<78105a6d>] do_IRQ+0x4d/0xa0
 [<78103ae9>] common_interrupt+0x25/0x2c
 [<7810185d>] cpu_idle+0x4d/0xb0
 [<781116f2>] start_secondary+0x352/0x470
 [<00000000>] 0x0
 [<b7fc5fb4>] 0xb7fc5fb4
Code: d0 89 95 54 ff ff ff 89 ca 89 8d 58 ff ff ff 89 d1 31 d2 85 c9 89 
85 54 f
EIP: [<b89f267e>] handleRcvWlp+0xce/0x1a80 [wanlink] SS:ESP 0068:b7fc5ca0
 <0>Kernel panic - not syncing: Fatal exception in interrupt
 BUG: warning at 
/home/greearb/git/linux-2.6.dev/arch/i386/kernel/smp.c:547/smp) 
[<78104252>] show_t
race+0x12/0x20
 [<78104929>] dump_stack+0x19/0x20
 [<78110be6>] smp_call_function+0x116/0x120
 [<78110c0e>] smp_send_stop+0x1e/0x40
 [<781205d7>] panic+0x57/0x110
 [<78104776>] die+0x2b6/0x2d0
 [<7810480f>] do_trap+0x7f/0xb0
 [<78104ef4>] do_divide_error+0x94/0xa0
 [<78103c51>] error_code+0x39/0x40
 [<b89f4654>] wp_handle_rcv_pkt+0x504/0x6f0 [wanlink]
 [<b89f55c9>] handle_rcv+0xa9/0x180 [wanlink]
 [<782ec7ad>] netif_receive_skb+0x36d/0x3b0
 [<b88f2649>] e1000_clean_rx_irq+0x129/0x4d0 [e1000]
 [<b88f1850>] e1000_clean+0x120/0x170 [e1000]
 [<782ee5b5>] net_rx_action+0xc5/0x1f0
 [<78125e08>] __do_softirq+0x88/0x110
 [<78125f09>] do_softirq+0x79/0x80
 [<7812609d>] irq_exit+0x5d/0x60
 [<78105a6d>] do_IRQ+0x4d/0xa0
 [<78103ae9>] common_interrupt+0x25/0x2c
 [<7810185d>] cpu_idle+0x4d/0xb0
 [<781116f2>] start_secondary+0x352/0x470
 [<00000000>] 0x0
 [<b7fc5fb4>] 0xb7fc5fb4

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


