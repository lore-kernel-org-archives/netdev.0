From: Anton Blanchard <anton@samba.org>
Subject: network lockup with latest BK (LLTX?)
Date: Wed, 15 Sep 2004 00:24:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914142447.GA5615@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

I have a machine with a number of e1000 adapters in it. It locked up
while I was bringing up the network interfaces. I have attached
backtraces of all relevant cpus.

There are a bunch of cpus in arp_xmit -> dev_queue_xmit, these all
appear to be stuck on the dev->queue_lock. Looking closer, all cpus
other than cpu 4 are stuck on the same spinlock. And since we store the
cpu number in our spinlocks, we know that this lock is owned by cpu4.

Looking at cpu4:

pfifo_fast_dequeue+0x58/0x78
qdisc_restart+0x5c/0x340
net_tx_action+0x144/0x248
__do_softirq+0xc4/0x198
call_do_softirq+0x14/0x28
do_softirq+0x90/0xa4
local_bh_enable+0x70/0x78
dev_queue_xmit+0x2c0/0x364
ip_finish_output+0x114/0x2e0
ip_queue_xmit+0x390/0x67c
tcp_transmit_skb+0x410/0xa2c
tcp_write_xmit+0x1dc/0x3f4
tcp_sendmsg+0x143c/0x147c
inet_sendmsg+0x80/0xac
sock_aio_write+0x13c/0x170
do_sync_write+0xac/0x118
vfs_write+0xb8/0x188
sys_write+0x4c/0x90

I had a look at qdisc_restart and it looks like we can return from
it with the queue_lock dropped if we hit the following:

if (ret == NETDEV_TX_LOCKED && nolock)
	goto collision;

Also I wonder why the collision case loops back to check
xmit_lock_owner since in the nolock case xmit_lock_owner isnt
initialized. Even so, Im not sure it explains why the cpu is stuck
where it is.

Anton

--

0:mon> c 0
0:mon> e
cpu 0x0: Vector: 100 (System Reset) at [c000000ffec8b080]
    pc: c0000000003ea260: ._spin_lock+0x28/0x3c
    lr: c00000000036cee0: .qdisc_restart+0x2b8/0x340
    sp: c000000ffec8b300
   msr: 9000000000089032
  current = 0xc000000ffea80d40
  paca    = 0xc000000000541980
    pid   = 1708, comm = sshd
0:mon> t
[link register   ] c00000000036cee0 .qdisc_restart+0x2b8/0x340
[c000000ffec8b300] c00000000036cde8 .qdisc_restart+0x1c0/0x340 (unreliable)
[c000000ffec8b3a0] c00000000035ebb8 .dev_queue_xmit+0x294/0x364
[c000000ffec8b430] c00000000037a7f4 .ip_finish_output+0x114/0x2e0
[c000000ffec8b4e0] c00000000037ad50 .ip_queue_xmit+0x390/0x67c
[c000000ffec8b670] c00000000038f5c4 .tcp_transmit_skb+0x410/0xa2c
[c000000ffec8b790] c000000000390438 .tcp_write_xmit+0x1dc/0x3f4
[c000000ffec8b870] c000000000381f04 .tcp_sendmsg+0x143c/0x147c
[c000000ffec8b9e0] c0000000003ab85c .inet_sendmsg+0x80/0xac
[c000000ffec8ba70] c0000000003520f4 .sock_aio_write+0x13c/0x170
[c000000ffec8bb90] c00000000009fc3c .do_sync_write+0xac/0x118
[c000000ffec8bcf0] c00000000009fd60 .vfs_write+0xb8/0x188
[c000000ffec8bd90] c00000000009ff0c .sys_write+0x4c/0x90
[c000000ffec8be30] c000000000010508 system_call+0x40/0x44
--- Exception: c01 (System Call) at 000000000fcba3dc
SP (ffffe3f0) is in userspace
0:mon> c 2
2:mon> e
cpu 0x2: Vector: 501 (Hardware Interrupt) at [c00000000ffef800]
    pc: c0000000003ea25c: ._spin_lock+0x24/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffefa80
   msr: 9000000000009032
  current = 0xc0000032fff64040
  paca    = 0xc000000000542280
    pid   = 0, comm = swapper
2:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffefa80] 0000000000000000 (unreliable)
[c00000000ffefb10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffefb80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffefcc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffefd60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffefe30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffefee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffeff90] c000000000017688 .call_do_softirq+0x14/0x28
[c000001e313dfa70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000001e313dfb00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c000000000013990 .default_idle+0x7c/0xdc
[c000001e313dfe90] c000000000013c68 .cpu_idle+0x38/0x50
[c000001e313dff00] c000000000037320 .start_secondary+0x128/0x17c
[c000001e313dff90] c00000000000cc2c start_secondary_prolog+0xc/0x10
2:mon> c 3
3:mon> e
cpu 0x3: Vector: 501 (Hardware Interrupt) at [c00000000ffe7800]
    pc: c0000000003ea25c: ._spin_lock+0x24/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffe7a80
   msr: 9000000000009032
  current = 0xc0000032fff611c0
  paca    = 0xc000000000542700
    pid   = 0, comm = swapper
3:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffe7a80] 0000000000000000 (unreliable)
[c00000000ffe7b10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffe7b80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffe7cc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffe7d60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffe7e30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffe7ee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffe7f90] c000000000017688 .call_do_softirq+0x14/0x28
[c000002c34b6ba70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000002c34b6bb00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c000000000013988 .default_idle+0x74/0xdc
[c000002c34b6be90] c000000000013c68 .cpu_idle+0x38/0x50
[c000002c34b6bf00] c000000000037320 .start_secondary+0x128/0x17c
[c000002c34b6bf90] c00000000000cc2c start_secondary_prolog+0xc/0x10
3:mon> c 4
4:mon> e
cpu 0x4: Vector: 501 (Hardware Interrupt) at [c00000000ffdfb10]
    pc: c00000000036d3a0: .pfifo_fast_dequeue+0x58/0x78
    lr: c00000000036cc84: .qdisc_restart+0x5c/0x340
    sp: c00000000ffdfd90
   msr: 9000000000009032
  current = 0xc000002c361113c0
  paca    = 0xc000000000542b80
    pid   = 3700, comm = ssh
4:mon> t
[link register   ] c00000000036cc84 .qdisc_restart+0x5c/0x340
[c00000000ffdfd90] c00000000036ce6c .qdisc_restart+0x244/0x340 (unreliable)
[c00000000ffdfe30] c00000000035f114 .net_tx_action+0x144/0x248
[c00000000ffdfee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffdff90] c000000000017688 .call_do_softirq+0x14/0x28
[c00000000119f2a0] c0000000000137e8 .do_softirq+0x90/0xa4
[c00000000119f330] c000000000056668 .local_bh_enable+0x70/0x78
[c00000000119f3a0] c00000000035ebe4 .dev_queue_xmit+0x2c0/0x364
[c00000000119f430] c00000000037a7f4 .ip_finish_output+0x114/0x2e0
[c00000000119f4e0] c00000000037ad50 .ip_queue_xmit+0x390/0x67c
[c00000000119f670] c00000000038f5c4 .tcp_transmit_skb+0x410/0xa2c
[c00000000119f790] c000000000390438 .tcp_write_xmit+0x1dc/0x3f4
[c00000000119f870] c000000000381f04 .tcp_sendmsg+0x143c/0x147c
[c00000000119f9e0] c0000000003ab85c .inet_sendmsg+0x80/0xac
[c00000000119fa70] c0000000003520f4 .sock_aio_write+0x13c/0x170
[c00000000119fb90] c00000000009fc3c .do_sync_write+0xac/0x118
[c00000000119fcf0] c00000000009fd60 .vfs_write+0xb8/0x188
[c00000000119fd90] c00000000009ff0c .sys_write+0x4c/0x90
[c00000000119fe30] c000000000010508 system_call+0x40/0x44
--- Exception: c01 (System Call) at 000000000fd313dc
SP (ffffe980) is in userspace
4:mon> c 5
5:mon> e
cpu 0x5: Vector: 501 (Hardware Interrupt) at [c00000000ffd7800]
    pc: c0000000003ea260: ._spin_lock+0x28/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffd7a80
   msr: 9000000000009032
  current = 0xc0000032fff600c0
  paca    = 0xc000000000543000
    pid   = 0, comm = swapper
5:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffd7a80] 0000000000000000 (unreliable)
[c00000000ffd7b10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffd7b80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffd7cc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffd7d60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffd7e30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffd7ee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffd7f90] c000000000017688 .call_do_softirq+0x14/0x28
[c000001dfff93a70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000001dfff93b00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c00000000001398c .default_idle+0x78/0xdc
[c000001dfff93e90] c000000000013c68 .cpu_idle+0x38/0x50
[c000001dfff93f00] c000000000037320 .start_secondary+0x128/0x17c
[c000001dfff93f90] c00000000000cc2c start_secondary_prolog+0xc/0x10
5:mon> c 6
6:mon> e
cpu 0x6: Vector: 501 (Hardware Interrupt) at [c00000000ffcf800]
    pc: c0000000003ea25c: ._spin_lock+0x24/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffcfa80
   msr: 9000000000009032
  current = 0xc000002bfff91240
  paca    = 0xc000000000543480
    pid   = 0, comm = swapper
6:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffcfa80] 0000000000000000 (unreliable)
[c00000000ffcfb10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffcfb80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffcfcc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffcfd60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffcfe30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffcfee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffcff90] c000000000017688 .call_do_softirq+0x14/0x28
[c000002bfff97a70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000002bfff97b00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c00000000001398c .default_idle+0x78/0xdc
[c000002bfff97e90] c000000000013c68 .cpu_idle+0x38/0x50
[c000002bfff97f00] c000000000037320 .start_secondary+0x128/0x17c
[c000002bfff97f90] c00000000000cc2c start_secondary_prolog+0xc/0x10
6:mon> c 7
7:mon> e
cpu 0x7: Vector: 501 (Hardware Interrupt) at [c00000000ffc7800]
    pc: c0000000003ea260: ._spin_lock+0x28/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffc7a80
   msr: 9000000000009032
  current = 0xc000002bfff909c0
  paca    = 0xc000000000543900
    pid   = 0, comm = swapper
7:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffc7a80] 0000000000000000 (unreliable)
[c00000000ffc7b10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffc7b80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffc7cc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffc7d60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffc7e30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffc7ee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffc7f90] c000000000017688 .call_do_softirq+0x14/0x28
[c000002c34b6fa70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000002c34b6fb00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c000000000013984 .default_idle+0x70/0xdc
[c000002c34b6fe90] c000000000013c68 .cpu_idle+0x38/0x50
[c000002c34b6ff00] c000000000037320 .start_secondary+0x128/0x17c
[c000002c34b6ff90] c00000000000cc2c start_secondary_prolog+0xc/0x10
7:mon> c 8
8:mon> e
cpu 0x8: Vector: 501 (Hardware Interrupt) at [c00000000ffbf800]
    pc: c0000000003ea260: ._spin_lock+0x28/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffbfa80
   msr: 9000000000009032
  current = 0xc000002bfff90140
  paca    = 0xc000000000543d80
    pid   = 0, comm = swapper
8:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffbfa80] 0000000000000000 (unreliable)
[c00000000ffbfb10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffbfb80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffbfcc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffbfd60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffbfe30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffbfee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffbff90] c000000000017688 .call_do_softirq+0x14/0x28
[c000000ffff8ba70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000000ffff8bb00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c00000000001398c .default_idle+0x78/0xdc
[c000000ffff8be90] c000000000013c68 .cpu_idle+0x38/0x50
[c000000ffff8bf00] c000000000037320 .start_secondary+0x128/0x17c
[c000000ffff8bf90] c00000000000cc2c start_secondary_prolog+0xc/0x10
8:mon> c 9
9:mon> e
cpu 0x9: Vector: 501 (Hardware Interrupt) at [c00000000ffb7800]
    pc: c0000000003ea260: ._spin_lock+0x28/0x3c
    lr: c00000000035eb68: .dev_queue_xmit+0x244/0x364
    sp: c00000000ffb7a80
   msr: 9000000000009032
  current = 0xc000001dfff952c0
  paca    = 0xc000000000544200
    pid   = 0, comm = swapper
9:mon> t
[link register   ] c00000000035eb68 .dev_queue_xmit+0x244/0x364
[c00000000ffb7a80] 0000000000000000 (unreliable)
[c00000000ffb7b10] c0000000003a476c .arp_xmit+0x10/0x24
[c00000000ffb7b80] c0000000003a5084 .arp_process+0x640/0x6d0
[c00000000ffb7cc0] c00000000035f4f4 .netif_receive_skb+0x2dc/0x374
[c00000000ffb7d60] c00000000035f698 .process_backlog+0x10c/0x264
[c00000000ffb7e30] c00000000035f8cc .net_rx_action+0xdc/0x230
[c00000000ffb7ee0] c000000000056524 .__do_softirq+0xc4/0x198
[c00000000ffb7f90] c000000000017688 .call_do_softirq+0x14/0x28
[c000001dfff83a70] c0000000000137e8 .do_softirq+0x90/0xa4
[c000001dfff83b00] c00000000000be34 HardwareInterrupt_entry+0x8/0x54
--- Exception: 501 (Hardware Interrupt) at c000000000013988 .default_idle+0x74/0xdc
[c000001dfff83e90] c000000000013c68 .cpu_idle+0x38/0x50
[c000001dfff83f00] c000000000037320 .start_secondary+0x128/0x17c
[c000001dfff83f90] c00000000000cc2c start_secondary_prolog+0xc/0x10
