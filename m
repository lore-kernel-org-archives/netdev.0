From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] tcp: delack_timer expiration changes for every frame
Date: Thu, 20 May 2010 22:47:19 +0200
Message-ID: <1274388439.2508.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:57197 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590Ab0ETUyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 16:54:06 -0400
Received: by fg-out-1718.google.com with SMTP id 22so134637fge.1
        for <netdev@vger.kernel.org>; Thu, 20 May 2010 13:54:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While oprofiling net-next-2.6 during tcp workloads I found
mod_timer(delack_timer) was used too much, even if we receive/send more
than one frame per jiffie.

Something seems wrong, since we should try to change this timer only
when jiffies changes. mod_timer() has a special optimization for this,
but something is broken in our tcp stack ?

I added some logs in mod_timer() :

HZ = 250

results for one socket shown :

[  392.116735] timer->expires=22997, expires=23024(37) diff=-27 timer=e5ecb754
[  392.120627] timer->expires=23024, expires=22998(10) diff=26 timer=e5ecb754
[  392.123245] timer->expires=22998, expires=23025(37) diff=-27 timer=e5ecb754
[  392.133688] timer->expires=23025, expires=23001(10) diff=24 timer=e5ecb754
[  392.136502] timer->expires=23001, expires=23029(37) diff=-28 timer=e5ecb754
[  392.140392] timer->expires=23029, expires=23003(10) diff=26 timer=e5ecb754
[  392.143142] timer->expires=23003, expires=23030(37) diff=-27 timer=e5ecb754
[  392.153812] timer->expires=23030, expires=23006(10) diff=24 timer=e5ecb754
[  392.156658] timer->expires=23006, expires=23034(37) diff=-28 timer=e5ecb754
[  392.160474] timer->expires=23034, expires=23008(10) diff=26 timer=e5ecb754
[  392.163317] timer->expires=23008, expires=23035(37) diff=-27 timer=e5ecb754
[  392.167176] timer->expires=23035, expires=23009(10) diff=26 timer=e5ecb754
[  392.176963] timer->expires=23009, expires=23039(37) diff=-30 timer=e5ecb754
[  392.180863] timer->expires=23039, expires=23013(10) diff=26 timer=e5ecb754
[  392.183577] timer->expires=23013, expires=23040(37) diff=-27 timer=e5ecb754
[  392.187537] timer->expires=23040, expires=23014(10) diff=26 timer=e5ecb754
[  392.197286] timer->expires=23014, expires=23044(37) diff=-30 timer=e5ecb754
[  392.201047] timer->expires=23044, expires=23018(10) diff=26 timer=e5ecb754
[  392.203761] timer->expires=23018, expires=23045(37) diff=-27 timer=e5ecb754
[  392.207721] timer->expires=23045, expires=23019(10) diff=26 timer=e5ecb754
[  392.217454] timer->expires=23019, expires=23049(37) diff=-30 timer=e5ecb754

So we change the delack_timer by a positive delta (~ HZ/10) and a
 negative delta (~HZ/10), on the typical netperf TCP_RR workload.



Here, the incoming frame is handled by netperf, doing a recvmsg().
tcp_send_delayed_ack() sets the delack_timer to jiffies + HZ/25

[  392.207721] timer->expires=23045, new expires=23019(10) diff=26 timer=e5ecb754
[  392.207785] ------------[ cut here ]------------
[  392.207846] WARNING: at kernel/timer.c:753 mod_timer+0x55/0x18e()
[  392.207908] Hardware name: ProLiant BL460c G6
[  392.207965] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler ipv6 dm_mod button battery ac ehci_hcd uhci_hcd tg3 libphy bnx2x crc32c libcrc32c mdio [last unloaded: x_tables]
[  392.208900] Pid: 5320, comm: netperf Tainted: G        W  2.6.34-06175-g801cae3-dirty #33
[  392.208979] Call Trace:
[  392.209036]  [<c102df55>] ? warn_slowpath_common+0x5d/0x70
[  392.209098]  [<c102df73>] ? warn_slowpath_null+0xb/0xd
[  392.209159]  [<c10388de>] ? mod_timer+0x55/0x18e
[  392.209221]  [<c1279ce7>] ? tcp_send_delayed_ack+0xb5/0xc1
[  392.209282]  [<c1276d26>] ? tcp_rcv_established+0x39f/0x4f7
[  392.209345]  [<c127bae5>] ? tcp_v4_do_rcv+0x22/0x161
[  392.209406]  [<c126d6b4>] ? tcp_prequeue_process+0x47/0x5b
[  392.209468]  [<c12701d2>] ? tcp_recvmsg+0x371/0x691
[  392.209529]  [<c12b8c91>] ? _raw_spin_lock_bh+0x8/0x1e
[  392.209590]  [<c1240bcd>] ? release_sock+0x10/0xc9
[  392.216514]  [<c1285bad>] ? inet_recvmsg+0x5d/0x72
[  392.216575]  [<c123e725>] ? sock_recvmsg+0xb4/0xd1
[  392.216636]  [<c1032ace>] ? irq_exit+0x39/0x5b
[  392.216696]  [<c123fab5>] ? sys_recvfrom+0xb4/0x117
[  392.216757]  [<c10483be>] ? ktime_get+0x61/0xe8
[  392.216817]  [<c1016431>] ? lapic_next_event+0x13/0x16
[  392.216878]  [<c104ba9d>] ? clockevents_program_event+0xac/0xbc
[  392.216940]  [<c104c6cc>] ? tick_dev_program_event+0x34/0x138
[  392.217002]  [<c104c7ed>] ? tick_program_event+0x1d/0x21
[  392.217064]  [<c1044da0>] ? hrtimer_interrupt+0x10b/0x1c1
[  392.217126]  [<c123fb31>] ? sys_recv+0x19/0x1d
[  392.217186]  [<c12401dc>] ? sys_socketcall+0x120/0x1c6
[  392.217303]  [<c100268c>] ? sysenter_do_call+0x12/0x22
[  392.217364] ---[ end trace e9475c06f1d49408 ]---

Here, the incoming frame is handled by the other side (netserver),
but still for the netperf socket, (softirq handling)
tcp_v4_rcv() sets the delack timer to 37 ticks, so mod_timer() optimizations is not
working at all.

[  392.217454] timer->expires=23019, new expires=23049(37) diff=-30 timer=e5ecb754
[  392.217518] ------------[ cut here ]------------
[  392.217578] WARNING: at kernel/timer.c:753 mod_timer+0x55/0x18e()
[  392.217639] Hardware name: ProLiant BL460c G6
[  392.217697] Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler ipv6 dm_mod button battery ac ehci_hcd uhci_hcd tg3 libphy bnx2x crc32c libcrc32c mdio [last unloaded: x_tables]
[  392.218439] Pid: 5321, comm: netserver Tainted: G        W  2.6.34-06175-g801cae3-dirty #33
[  392.218526] Call Trace:
[  392.218582]  [<c102df55>] ? warn_slowpath_common+0x5d/0x70
[  392.218644]  [<c102df73>] ? warn_slowpath_null+0xb/0xd
[  392.218705]  [<c10388de>] ? mod_timer+0x55/0x18e
[  392.218765]  [<c127cf56>] ? tcp_v4_rcv+0x41c/0x6b7
[  392.218826]  [<c1265832>] ? ip_local_deliver_finish+0xe9/0x178
[  392.218888]  [<c126572a>] ? ip_rcv_finish+0x262/0x281
[  392.218949]  [<c1249986>] ? __netif_receive_skb+0x267/0x282
[  392.219011]  [<c1249a0d>] ? process_backlog+0x6c/0x113
[  392.219072]  [<c124a2e6>] ? net_rx_action+0x8a/0x15a
[  392.219133]  [<c106234e>] ? __rcu_process_callbacks+0xb9/0x1d1
[  392.219195]  [<c1032910>] ? __do_softirq+0x0/0x13a
[  392.219255]  [<c10329b5>] ? __do_softirq+0xa5/0x13a
[  392.219316]  [<c1032910>] ? __do_softirq+0x0/0x13a
[  392.219375]  <IRQ>  [<c1032449>] ? local_bh_enable+0x5f/0x6a
[  392.219474]  [<c124c0be>] ? dev_queue_xmit+0x34d/0x37a
[  392.219536]  [<c1268115>] ? ip_finish_output+0x1c7/0x1ff
[  392.219610]  [<c1268255>] ? ip_local_out+0x18/0x1a
[  392.219670]  [<c12684f4>] ? ip_queue_xmit+0x29d/0x2d5
[  392.219731]  [<c1293e89>] ? bictcp_acked+0x4f/0x139
[  392.219791]  [<c1275ee8>] ? tcp_ack+0x155b/0x16e9
[  392.219851]  [<c127851a>] ? tcp_transmit_skb+0x62a/0x65f
[  392.219912]  [<c1038a03>] ? mod_timer+0x17a/0x18e
[  392.219972]  [<c127900a>] ? tcp_write_xmit+0x73a/0x81c
[  392.220033]  [<c109e487>] ? __kmalloc_node+0x30/0x76
[  392.220095]  [<c1279127>] ? __tcp_push_pending_frames+0x15/0x6c
[  392.220159]  [<c126f214>] ? tcp_sendmsg+0x7ee/0x8c5
[  392.220223]  [<c123e823>] ? sock_sendmsg+0xa7/0xc1
[  392.220284]  [<c1044da0>] ? hrtimer_interrupt+0x10b/0x1c1
[  392.220346]  [<c1032ace>] ? irq_exit+0x39/0x5b
[  392.220406]  [<c1016811>] ? smp_apic_timer_interrupt+0x6b/0x75
[  392.220468]  [<c102007b>] ? pud_huge+0x1/0x9
[  392.220536]  [<c123f9b9>] ? sys_sendto+0xfc/0x127
[  392.220599]  [<c1044bd4>] ? hrtimer_start_range_ns+0xf/0x13
[  392.220661]  [<c1023848>] ? update_curr+0x60/0xdf
[  392.220722]  [<c1044871>] ? hrtimer_forward+0x10f/0x123
[  392.220784]  [<c10483be>] ? ktime_get+0x61/0xe8
[  392.220844]  [<c123f9fd>] ? sys_send+0x19/0x1d
[  392.220903]  [<c12401af>] ? sys_socketcall+0xf3/0x1c6
[  392.220964]  [<c1032ace>] ? irq_exit+0x39/0x5b
[  392.221024]  [<c1016811>] ? smp_apic_timer_interrupt+0x6b/0x75
[  392.221086]  [<c100268c>] ? sysenter_do_call+0x12/0x22
[  392.221147] ---[ end trace e9475c06f1d49409 ]---

Its a bit late here to investigate, maybe one of you guys have an idea about this...



