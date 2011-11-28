From: Vincent Blut <vincent.debian@free.fr>
Subject: sky2: hw csum failure
Date: Mon, 28 Nov 2011 12:10:20 +0000
Message-ID: <4ED37A2C.5040608@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com,
	Debian Bug Tracking System <609994@bugs.debian.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:55945 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab1K1LJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 06:09:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

[reference: http://bugs.debian.org/609994]

I have a Marvell ethernet controller which presents some failures when
'rx checksumming' is enabled,
here is the model:

$ lspci -vvs 03:00.0
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
Gigabit Ethernet Controller (rev 15)
        Subsystem: Micro-Star International Co., Ltd. Marvell 88E8053
Gigabit Ethernet Controller (MSI)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 44
        Region 0: Memory at fdbfc000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at 7c00 [size=256]
        [virtual] Expansion ROM at fda00000 [disabled] [size=128K]
        Capabilities: <access denied>
        Kernel driver in use: sky2

At first I thought it was due to the MTU size, so I tested different
values but unfortunately without positive effect.
Overall this issue appears randomly when the incoming traffic is high. I
tested 2.6.32, 3.1.1, and 3.2-rc3, sadly
all are affected. Finally, the only way to avoid those failures is to
disabled 'rx checksumming' (ethtool -K ethX rx off).

Here is the stack trace:

[   14.615648] sky2 0000:03:00.0: eth1: enabling interface
[   14.616452] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   17.094194] sky2 0000:03:00.0: eth1: Link is up at 1000 Mbps, full
duplex, flow control both
[   17.094887] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   28.080018] eth1: no IPv6 routers present
[  563.816032] sky2 0000:03:00.0: eth1: hung mac 124:22 fifo 195 (150:145)
[  563.816036] sky2 0000:03:00.0: eth1: receiver hang detected
[  567.005422] sky2 0000:03:00.0: eth1: Link is up at 1000 Mbps, full
duplex, flow control both
[ 1040.816314] sky2 0000:03:00.0: eth1: rx error, status 0x7ffc0001
length 1004
[ 2097.401616] sky2 0000:03:00.0: eth1: rx error, status 0x39a339a3 length 0
[ 2097.536950] <unknown>: hw csum failure.
[ 2097.536956] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.536959] Call Trace:
[ 2097.536961]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.536972]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.536976]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.536980]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.536984]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.536987]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.536991]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.536995]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.536999]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.537003]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.537007]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.537011]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.537014]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.537031]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.537035]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.537040]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.537044]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.537048]  [<ffffffff8104e01f>] ? __do_softirq+0x13d/0x1a0
[ 2097.537051]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.537056]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.537059]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.537063]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.537066]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.537068]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.537075]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.537078]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.537082]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.537086]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.537841] <unknown>: hw csum failure.
[ 2097.537844] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.537845] Call Trace:
[ 2097.537847]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.537854]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.537857]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.537861]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.537864]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.537868]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.537872]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.537875]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.537879]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.537883]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.537887]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.537890]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.537894]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.537900]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.537905]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.537909]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.537912]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.537916]  [<ffffffff8104e01f>] ? __do_softirq+0x13d/0x1a0
[ 2097.537919]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.537923]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.537926]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.537930]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.537933]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.537935]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.537941]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.537944]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.537947]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.537951]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.539549] <unknown>: hw csum failure.
[ 2097.539552] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.539553] Call Trace:
[ 2097.539555]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.539561]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.539565]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.539568]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.539572]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.539576]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.539579]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.539583]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.539587]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.539591]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.539594]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.539598]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.539604]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.539608]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.539612]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.539616]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.539619]  [<ffffffff8104e01f>] ? __do_softirq+0x13d/0x1a0
[ 2097.539623]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.539626]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.539630]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.539633]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.539637]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.539639]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.539644]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.539648]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.539651]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.539655]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.540329] <unknown>: hw csum failure.
[ 2097.540332] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.540333] Call Trace:
[ 2097.540335]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.540341]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.540345]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.540349]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.540352]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.540356]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.540360]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.540364]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.540367]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.540371]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.540375]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.540379]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.540385]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.540389]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.540393]  [<ffffffff8106e080>] ? clockevents_program_event+0x99/0xb8
[ 2097.540398]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2097.540402]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.540405]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.540409]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.540413]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.540416]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.540420]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.540423]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.540425]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.540431]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.540434]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.540437]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.540441]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.542248] <unknown>: hw csum failure.
[ 2097.542251] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.542252] Call Trace:
[ 2097.542254]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.542260]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.542264]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.542267]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.542271]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.542275]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.542279]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.542283]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.542286]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.542290]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.542294]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.542298]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.542304]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.542308]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.542312]  [<ffffffff8106e080>] ? clockevents_program_event+0x99/0xb8
[ 2097.542316]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2097.542320]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.542323]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.542326]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.542330]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.542334]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.542337]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.542341]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.542343]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.542348]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.542352]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.542355]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.542359]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.543036] <unknown>: hw csum failure.
[ 2097.543038] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.543040] Call Trace:
[ 2097.543041]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.543048]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.543052]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.543055]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.543059]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.543063]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.543066]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.543070]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.543074]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.543078]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.543082]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.543085]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.543091]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.543096]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.543099]  [<ffffffff8106e080>] ? clockevents_program_event+0x99/0xb8
[ 2097.543103]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2097.543107]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.543111]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.543114]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.543118]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.543122]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.543125]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.543128]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.543130]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.543136]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.543139]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.543143]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.543146]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.795913] <unknown>: hw csum failure.
[ 2097.795919] Pid: 2311, comm: xulrunner-stub Not tainted 3.2.0-rc3 #1
[ 2097.795922] Call Trace:
[ 2097.795924]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.795935]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.795940]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.795943]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.795947]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.795951]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.795955]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.795959]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.795962]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.795967]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.795970]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.795974]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.795990]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.795995]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.796000]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.796032]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.796036]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.796041]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.796044]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.796048]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.796051]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.796053]  <EOI>  [<ffffffff813548d2>] ? system_call_fastpath+0x16/0x1b
[ 2097.803096] <unknown>: hw csum failure.
[ 2097.803102] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.803104] Call Trace:
[ 2097.803106]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.803117]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.803121]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.803125]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.803129]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.803132]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.803136]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.803140]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.803144]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.803148]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.803152]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.803156]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.803172]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.803176]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.803181]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.803185]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.803189]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.803193]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.803197]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.803200]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.803204]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.803206]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.803212]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.803216]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.803220]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.803223]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2097.865904] <unknown>: hw csum failure.
[ 2097.865910] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2097.865912] Call Trace:
[ 2097.865914]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2097.865925]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2097.865930]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2097.865933]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2097.865937]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.865941]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2097.865945]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2097.865948]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.865952]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2097.865956]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2097.865960]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2097.865964]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2097.865967]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2097.865984]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2097.865988]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2097.865993]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2097.865997]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2097.866001]  [<ffffffff8104e01f>] ? __do_softirq+0x13d/0x1a0
[ 2097.866004]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2097.866009]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2097.866012]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2097.866016]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2097.866019]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2097.866021]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2097.866028]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2097.866031]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2097.866035]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2097.866039]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2105.784575] net_ratelimit: 14 callbacks suppressed
[ 2105.784579] <unknown>: hw csum failure.
[ 2105.784582] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2105.784585] Call Trace:
[ 2105.784586]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2105.784598]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2105.784602]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2105.784606]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2105.784611]  [<ffffffff8110f916>] ? send_sigio_to_task+0xe0/0xed
[ 2105.784615]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2105.784620]  [<ffffffff811ba489>] ? delay_tsc+0x2d/0x74
[ 2105.784624]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2105.784628]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2105.784631]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2105.784636]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2105.784639]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2105.784643]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2105.784660]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2105.784664]  [<ffffffff8126bed0>] ? input_event+0x5c/0x80
[ 2105.784670]  [<ffffffffa022de6b>] ? psmouse_interrupt+0x2a3/0x2c0
[psmouse]
[ 2105.784674]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2105.784679]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2105.784683]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2105.784687]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2105.784692]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2105.784695]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2105.784699]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2105.784702]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2105.784704]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2105.784711]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2105.784714]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2105.784718]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2105.784722]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2105.809944] <unknown>: hw csum failure.
[ 2105.809950] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2105.809953] Call Trace:
[ 2105.809955]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2105.809966]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2105.809970]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2105.809973]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2105.809978]  [<ffffffff8110f916>] ? send_sigio_to_task+0xe0/0xed
[ 2105.809982]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2105.809987]  [<ffffffff811ba489>] ? delay_tsc+0x2d/0x74
[ 2105.809991]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2105.809995]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2105.809998]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2105.810003]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2105.810006]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2105.810010]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2105.810026]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2105.810031]  [<ffffffff8126bed0>] ? input_event+0x5c/0x80
[ 2105.810035]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2105.810040]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2105.810043]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2105.810047]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2105.810056]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2105.810060]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2105.810063]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2105.810067]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2105.810069]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2105.810075]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2105.810079]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2105.810083]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2105.810087]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2114.099063] <unknown>: hw csum failure.
[ 2114.099069] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2114.099072] Call Trace:
[ 2114.099074]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2114.099085]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2114.099089]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2114.099094]  [<ffffffff810142aa>] ? native_sched_clock+0x28/0x5a
[ 2114.099097]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2114.099102]  [<ffffffff8110f916>] ? send_sigio_to_task+0xe0/0xed
[ 2114.099106]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2114.099110]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2114.099114]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2114.099117]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2114.099122]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2114.099125]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2114.099129]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2114.099145]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2114.099149]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2114.099154]  [<ffffffff81065401>] ? enqueue_hrtimer+0x43/0x6a
[ 2114.099157]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2114.099162]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2114.099166]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2114.099170]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2114.099174]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2114.099178]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2114.099181]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2114.099184]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2114.099186]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2114.099193]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2114.099196]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2114.099200]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2114.099204]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2114.297922] <unknown>: hw csum failure.
[ 2114.297928] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2114.297930] Call Trace:
[ 2114.297932]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2114.297943]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2114.297948]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2114.297951]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2114.297956]  [<ffffffff8110f916>] ? send_sigio_to_task+0xe0/0xed
[ 2114.297960]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2114.297964]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2114.297968]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2114.297972]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2114.297976]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2114.297980]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2114.297983]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2114.298000]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2114.298004]  [<ffffffff8126bed0>] ? input_event+0x5c/0x80
[ 2114.298008]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2114.298013]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2114.298017]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2114.298021]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2114.298025]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2114.298029]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2114.298032]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2114.298036]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2114.298038]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2114.298044]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2114.298048]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2114.298052]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2114.298055]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2124.098727] <unknown>: hw csum failure.
[ 2124.098733] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2124.098735] Call Trace:
[ 2124.098738]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2124.098749]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2124.098753]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2124.098757]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2124.098762]  [<ffffffff81037f3d>] ? check_preempt_curr+0x25/0x62
[ 2124.098767]  [<ffffffff8104314c>] ? ttwu_do_wakeup+0x51/0xc8
[ 2124.098771]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2124.098775]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2124.098779]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2124.098782]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2124.098787]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2124.098790]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2124.098794]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2124.098811]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2124.098815]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2124.098820]  [<ffffffff81065401>] ? enqueue_hrtimer+0x43/0x6a
[ 2124.098823]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2124.098828]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2124.098832]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2124.098836]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2124.098840]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2124.098844]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2124.098847]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2124.098851]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2124.098853]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2124.098859]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2124.098863]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2124.098867]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2124.098870]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2124.297980] <unknown>: hw csum failure.
[ 2124.297987] Pid: 0, comm: swapper Not tainted 3.2.0-rc3 #1
[ 2124.297989] Call Trace:
[ 2124.297991]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2124.298002]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2124.298006]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2124.298010]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2124.298015]  [<ffffffff81037f3d>] ? check_preempt_curr+0x25/0x62
[ 2124.298020]  [<ffffffff8104314c>] ? ttwu_do_wakeup+0x51/0xc8
[ 2124.298023]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2124.298027]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2124.298031]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2124.298035]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2124.298039]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2124.298043]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2124.298047]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2124.298063]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2124.298067]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2124.298072]  [<ffffffff81065401>] ? enqueue_hrtimer+0x43/0x6a
[ 2124.298075]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2124.298080]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2124.298084]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2124.298088]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2124.298092]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2124.298096]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2124.298099]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2124.298103]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2124.298105]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2124.298111]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2124.298115]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2124.298119]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2124.298122]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2132.893546] general protection fault: 0000 [#1] SMP
[ 2132.893592] CPU 0
[ 2132.893607] Modules linked in: fuse firewire_sbp2 loop radeon
snd_ca0106 snd_seq_midi snd_seq_midi_event snd_rawmidi rtl8192cu ttm
arc4 snd_ac97_codec rt2500pci rt2x00pci rt2x00lib ac97_bus snd_pcm
rtl8192c_common drm_kms_helper drm rtlwifi mac80211 snd_seq snd_timer
snd_seq_device cfg80211 tpm_tis tpm tpm_bios snd psmouse i2c_algo_bit
power_supply k8temp edac_core evdev eeprom_93cx6 edac_mce_amd pcspkr
serio_raw rfkill soundcore snd_page_alloc i2c_nforce2 processor button
i2c_core ext4 mbcache jbd2 crc16 usbhid sg sr_mod sd_mod hid crc_t10dif
cdrom ohci_hcd sata_sil pata_amd ata_generic sata_nv libata ehci_hcd
usbcore firewire_ohci scsi_mod firewire_core crc_itu_t forcedeth sky2
thermal fan thermal_sys usb_common [last unloaded: scsi_wait_scan]
[ 2132.894174]
[ 2132.894187] Pid: 2641, comm: bash Not tainted 3.2.0-rc3 #1 MICRO-STAR
INTERNATIONAL CO., LTD MS-7125/MS-7125
[ 2132.894258] RIP: 0010:[<ffffffff81117c5b>]  [<ffffffff81117c5b>]
dup_fd+0x1cf/0x285
[ 2132.894317] RSP: 0018:ffff8800b0245df0  EFLAGS: 00010206
[ 2132.894354] RAX: 0000000000000040 RBX: ffff8800ba68e8c0 RCX:
ffffffffffffff7f
[ 2132.894403] RDX: 21a08abfd7091100 RSI: 0000000000000008 RDI:
00000000000000f8
[ 2132.894451] RBP: ffff880036696580 R08: ffff8800366967c0 R09:
ffff8800b02d1000
[ 2132.894500] R10: ffff8800368ad000 R11: 0000000000000000 R12:
0000000000000100
[ 2132.894548] R13: ffff8800377f16c0 R14: 0000000000000001 R15:
0000000000000080
[ 2132.894597] FS:  00007f199e9d6700(0000) GS:ffff8800bfc00000(0000)
knlGS:0000000000000000
[ 2132.894652] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2132.894692] CR2: 0000000000468000 CR3: 0000000037ef0000 CR4:
00000000000006f0
[ 2132.894740] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 2132.894789] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[ 2132.894838] Process bash (pid: 2641, threadinfo ffff8800b0244000,
task ffff88003736c3c0)
[ 2132.894892] Stack:
[ 2132.894907]  ffff880037c46720 ffff8800377f1740 ffff8800377f1740
ffff8800377f16c8
[ 2132.894964]  ffff880037c46720 0000000001200011 ffff880037c46720
0000000000000000
[ 2132.895020]  0000000000000000 ffff880037c46930 00007f199e9d69d0
ffffffff81047326
[ 2132.895077] Call Trace:
[ 2132.895098]  [<ffffffff81047326>] ? copy_process+0x59f/0x10ca
[ 2132.895139]  [<ffffffff81048021>] ? do_fork+0xda/0x219
[ 2132.895177]  [<ffffffff8110183d>] ? fd_install+0x27/0x4e
[ 2132.895216]  [<ffffffff81354bf3>] ? stub_clone+0x13/0x20
[ 2132.895254]  [<ffffffff813548d2>] ? system_call_fastpath+0x16/0x1b
[ 2132.895296] Code: 89 d7 48 98 48 89 c1 f3 a4 48 89 c1 31 c0 48 8b 55
10 49 8b 70 10 48 89 d7 f3 a4 44 89 e7 31 f6 eb 3d 49 8b 14 02 48 85 d2
74 07 <3e> 48 ff 42 30 eb 21 48 63 ce 4c 8b 45 18 4d 89 f7 49 89 cb 83
[ 2132.895527] RIP  [<ffffffff81117c5b>] dup_fd+0x1cf/0x285
[ 2132.895567]  RSP <ffff8800b0245df0>
[ 2132.915113] ---[ end trace 3541bcacd8b98988 ]---
[ 2134.302779] <unknown>: hw csum failure.
[ 2134.302785] Pid: 0, comm: swapper Tainted: G      D      3.2.0-rc3 #1
[ 2134.302788] Call Trace:
[ 2134.302790]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2134.302801]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2134.302805]  [<ffffffff812cb3da>] ? tcp_checksum_complete_user+0x40/0x4e
[ 2134.302809]  [<ffffffff812cdcbf>] ? tcp_rcv_established+0x56f/0x683
[ 2134.302814]  [<ffffffff81044050>] ? enqueue_task_fair+0x129/0x262
[ 2134.302818]  [<ffffffff812d50bc>] ? tcp_v4_do_rcv+0x1bd/0x3eb
[ 2134.302823]  [<ffffffff811ba489>] ? delay_tsc+0x2d/0x74
[ 2134.302827]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2134.302831]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2134.302834]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2134.302839]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2134.302843]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2134.302846]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2134.302863]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2134.302867]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2134.302871]  [<ffffffff81065401>] ? enqueue_hrtimer+0x43/0x6a
[ 2134.302875]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2134.302880]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2134.302883]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2134.302887]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2134.302892]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2134.302895]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2134.302899]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2134.302902]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2134.302904]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2134.302911]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2134.302914]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2134.302918]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2134.302922]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f
[ 2181.645236] <unknown>: hw csum failure.
[ 2181.645243] Pid: 0, comm: swapper Tainted: G      D      3.2.0-rc3 #1
[ 2181.645245] Call Trace:
[ 2181.645247]  <IRQ>  [<ffffffff8128f5d9>] ? netdev_rx_csum_fault+0x29/0x31
[ 2181.645259]  [<ffffffff8128ae7e>] ?
__skb_checksum_complete_head+0x44/0x56
[ 2181.645263]  [<ffffffff812d50f6>] ? tcp_v4_do_rcv+0x1f7/0x3eb
[ 2181.645267]  [<ffffffff812d6708>] ? tcp_v4_rcv+0x449/0x6f5
[ 2181.645272]  [<ffffffff810376d8>] ? __wake_up_common+0x41/0x78
[ 2181.645276]  [<ffffffff812b9d1a>] ? ip_local_deliver_finish+0x13d/0x1aa
[ 2181.645280]  [<ffffffff8128ee04>] ? __netif_receive_skb+0x44c/0x490
[ 2181.645284]  [<ffffffff81293800>] ? netif_receive_skb+0x67/0x6d
[ 2181.645288]  [<ffffffff81293d03>] ? napi_gro_receive+0x1f/0x2c
[ 2181.645292]  [<ffffffff812938d5>] ? napi_skb_finish+0x1c/0x31
[ 2181.645309]  [<ffffffffa0029ab6>] ? sky2_poll+0x76c/0xa0a [sky2]
[ 2181.645313]  [<ffffffff81293e2e>] ? net_rx_action+0xa8/0x207
[ 2181.645317]  [<ffffffff81065401>] ? enqueue_hrtimer+0x43/0x6a
[ 2181.645321]  [<ffffffff810656fb>] ? __hrtimer_start_range_ns+0x2d3/0x2e6
[ 2181.645326]  [<ffffffff8104dfa6>] ? __do_softirq+0xc4/0x1a0
[ 2181.645330]  [<ffffffff8109666d>] ? handle_irq_event_percpu+0x166/0x184
[ 2181.645333]  [<ffffffff81356b2c>] ? call_softirq+0x1c/0x30
[ 2181.645338]  [<ffffffff8100f9f7>] ? do_softirq+0x3f/0x79
[ 2181.645342]  [<ffffffff8104dd76>] ? irq_exit+0x44/0xb5
[ 2181.645345]  [<ffffffff8100f342>] ? do_IRQ+0x94/0xaa
[ 2181.645349]  [<ffffffff8134f62e>] ? common_interrupt+0x6e/0x6e
[ 2181.645351]  <EOI>  [<ffffffff8102b850>] ? native_safe_halt+0x2/0x3
[ 2181.645357]  [<ffffffff81015039>] ? default_idle+0x4b/0x84
[ 2181.645361]  [<ffffffff8100ddcb>] ? cpu_idle+0xb9/0xef
[ 2181.645365]  [<ffffffff816a9c3b>] ? start_kernel+0x3cc/0x3d7
[ 2181.645368]  [<ffffffff816a93c8>] ? x86_64_start_kernel+0x102/0x10f

Thanks,
Vincent
