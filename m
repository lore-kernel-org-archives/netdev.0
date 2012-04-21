From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] macvlan/macvtap: Fix vlan tagging on user read
Date: Fri, 20 Apr 2012 18:49:27 -0700
Message-ID: <m1ipgtzwew.fsf@fess.ebiederm.org>
References: <1334774098-22886-1-git-send-email-basilgor@gmail.com>
	<m1hawglvk3.fsf@fess.ebiederm.org> <20120418193312.GA24516@nanobar>
	<20120420231128.GA2088@nanobar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Basil Gor <basil.gor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37846 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab2DUBp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 21:45:27 -0400
In-Reply-To: <20120420231128.GA2088@nanobar> (Basil Gor's message of "Sat, 21
	Apr 2012 03:11:28 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basil Gor <basil.gor@gmail.com> writes:

> I did some additional code review, and it's easier to show on stack traces and
> by comparing macvtap with tun/tap driver.
>
> tun/tap device does not need to care about vlan tag stuff, as it gets skb with
> vlan id in the header and vlan_tci is not used.
>
> [97493.070321] tun_net_xmit devname vnet0 vlan_tci 0 vlan 0 proto 8100 len 64
> [97493.070327] Pid: 0, comm: swapper/2 Tainted: G           O 3.3.1-3.fc16.x86_64 #1
> [97493.070331] Call Trace:
> [97493.070334]  <IRQ>  [<ffffffffa02c6827>] tun_net_xmit+0x47/0x260 [tun]
> [97493.070347]  [<ffffffff814e8072>] dev_hard_start_xmit+0x332/0x6d0 <------ __vlan_put_tag is called
> [97493.070355]  [<ffffffff81503f5a>] sch_direct_xmit+0xfa/0x1d0
> [97493.070364]  [<ffffffff814e85b5>] dev_queue_xmit+0x1a5/0x640
> [97493.070377]  [<ffffffffa057c180>] ? br_flood+0xc0/0xc0 [bridge]
> [97493.070395]  [<ffffffffa057c380>] ? __br_deliver+0x100/0x100 [bridge]
> [97493.070409]  [<ffffffffa057c380>] ? __br_deliver+0x100/0x100 [bridge]
> [97493.070423]  [<ffffffffa057c1ec>] br_dev_queue_push_xmit+0x6c/0xa0 [bridge]
> [97493.070438]  [<ffffffffa057c380>] ? __br_deliver+0x100/0x100 [bridge]
> [97493.070457]  [<ffffffffa057c242>] br_forward_finish+0x22/0x60 [bridge]
> [97493.070471]  [<ffffffffa057c380>] ? __br_deliver+0x100/0x100 [bridge]
> [97493.070485]  [<ffffffffa057c3dd>] __br_forward+0x5d/0xb0 [bridge]
> [97493.070495]  [<ffffffff814dafe4>] ? skb_clone+0x54/0xb0
> [97493.070508]  [<ffffffffa057bf1e>] deliver_clone+0x3e/0x60 [bridge]
> [97493.070523]  [<ffffffffa057c143>] br_flood+0x83/0xc0 [bridge]
> [97493.070534]  [<ffffffffa057c525>] br_flood_forward+0x15/0x20 [bridge]
> [97493.070544]  [<ffffffffa057d256>] br_handle_frame_finish+0x246/0x2a0 [bridge]
> [97493.070555]  [<ffffffffa057d444>] br_handle_frame+0x194/0x260 [bridge]
> [97493.070567]  [<ffffffffa057d2b0>] ? br_handle_frame_finish+0x2a0/0x2a0 [bridge]
> [97493.070581]  [<ffffffff814e56de>] __netif_receive_skb+0x1be/0x5c0  <------ vlan_untag is called
> [97493.070594]  [<ffffffff81088ba2>] ? default_wake_function+0x12/0x20
> [97493.070604]  [<ffffffff814e5ef1>] process_backlog+0xb1/0x170
> [97493.070613]  [<ffffffff814e718b>] net_rx_action+0x12b/0x270
> [97493.070623]  [<ffffffff8108daed>] ? sched_clock_cpu+0xbd/0x110
> [97493.070633]  [<ffffffff8105efb8>] __do_softirq+0xb8/0x230
> [97493.070644]  [<ffffffff810e3c30>] ? handle_irq_event+0x50/0x70
> [97493.070654]  [<ffffffff815fd49c>] call_softirq+0x1c/0x30
> [97493.070662]  [<ffffffff81016455>] do_softirq+0x65/0xa0
> [97493.070668]  [<ffffffff8105f3ce>] irq_exit+0x9e/0xc0
> [97493.070675]  [<ffffffff815fdd03>] do_IRQ+0x63/0xe0
> [97493.070682]  [<ffffffff815f42ae>] common_interrupt+0x6e/0x6e
> [97493.070686]  <EOI>  [<ffffffff8131b236>] ? intel_idle+0xe6/0x150
> [97493.070697]  [<ffffffff8131b218>] ? intel_idle+0xc8/0x150
> [97493.070705]  [<ffffffff814a4071>] cpuidle_idle_call+0xc1/0x280
> [97493.070713]  [<ffffffff8101322f>] cpu_idle+0xcf/0x120
> [97493.070720]  [<ffffffff815e3b1f>] start_secondary+0x282/0x284
>
> but macvtap device gets skb with vlan tag extacted in vlan_tci, and as original driver
> code was mostly based on tun/tap driver vlan thing was missed.
>
> [98143.863560] macvtap_receive devname macvtap0 vlan_tci 100a vlan 10 proto 0800 len 90
> [98143.863570] macvtap_forward devname macvtap0 vlan_tci 100a vlan 10 proto 0800 len 90
> [98143.863578] Pid: 0, comm: swapper/2 Tainted: G           O 3.3.1-3.fc16.x86_64 #1
> [98143.863583] Call Trace:
> [98143.863587]  <IRQ>  [<ffffffffa026819c>] macvtap_forward+0x8c/0x1b0 [macvtap]
> [98143.863606]  [<ffffffffa0268314>] macvtap_receive+0x54/0x60 [macvtap]
> [98143.863623]  [<ffffffffa02c05db>] macvlan_handle_frame+0xbb/0x2c0 [macvlan]
> [98143.863635]  [<ffffffffa02c0520>] ? macvlan_broadcast+0x160/0x160 [macvlan]
> [98143.863646]  [<ffffffff814e56de>] __netif_receive_skb+0x1be/0x5c0   <------ vlan_untag is called
> [98143.863653]  [<ffffffff814e67e3>] netif_receive_skb+0x23/0x90
> [98143.863660]  [<ffffffff814e6c09>] ? dev_gro_receive+0x1b9/0x2b0
> [98143.863667]  [<ffffffff814e6950>] napi_skb_finish+0x50/0x70
> [98143.863673]  [<ffffffff814e6f45>] napi_gro_receive+0xf5/0x140
> [98143.863697]  [<ffffffffa0241fab>] e1000_receive_skb+0x5b/0x70 [e1000e] 
Actually                                  __vlan_hwaccel_put_tag  is called here not vlan_untag
> [98143.863718]  [<ffffffffa0244b21>] e1000_clean_rx_irq+0x2f1/0x400 [e1000e]
> [98143.863737]  [<ffffffffa02432e8>] e1000_clean+0x78/0x2c0 [e1000e]
> [98143.863745]  [<ffffffff814e718b>] net_rx_action+0x12b/0x270
> [98143.863752]  [<ffffffff8108daed>] ? sched_clock_cpu+0xbd/0x110
> [98143.863759]  [<ffffffff8105efb8>] __do_softirq+0xb8/0x230
> [98143.863767]  [<ffffffff810e3c30>] ? handle_irq_event+0x50/0x70
> [98143.863775]  [<ffffffff815fd49c>] call_softirq+0x1c/0x30
> [98143.863782]  [<ffffffff81016455>] do_softirq+0x65/0xa0
> [98143.863788]  [<ffffffff8105f3ce>] irq_exit+0x9e/0xc0
> [98143.863796]  [<ffffffff815fdd03>] do_IRQ+0x63/0xe0
> [98143.863803]  [<ffffffff815f42ae>] common_interrupt+0x6e/0x6e
> [98143.863807]  <EOI>  [<ffffffff8131b236>] ? intel_idle+0xe6/0x150
> [98143.863818]  [<ffffffff8131b218>] ? intel_idle+0xc8/0x150
> [98143.863826]  [<ffffffff814a4071>] cpuidle_idle_call+0xc1/0x280
> [98143.863834]  [<ffffffff8101322f>] cpu_idle+0xcf/0x120
> [98143.863841]  [<ffffffff815e3b1f>] start_secondary+0x282/0x284
>
> and as Eric Biederman noted, why not add vlan header back at the last moment? in
> macvtap_put_user. And it would work for user space applications which read
> /dev/tapX, but in kvm case actual reading is done by vhost_net driver. And this
> driver actually does skb_peek on macvtap queue to get next packet size before
> reading (in handle_rx).
>
> [98143.863878] vhost peek_head_len devname macvtap0 vlan_tci 100a vlan 10 proto 0800 len 90
>
> so, it gets skb len without vlan tag and then performs read with buffer smaller then needed
>
> [98143.863885] macvtap_do_read buflen 102 <--- 90 + (vnet_hdr_sz 12 bytes)
> [98143.863889]  devname macvtap0 vlan_tci 100a vlan 10 proto 0800 len 90
> __vlan_put_tag is called here
> [98143.863894] macvtap_do_read reallen 106 <--- 90 + 4 + (vnet_hdr_sz 12)
> [98143.863898]  devname macvtap0 vlan_tci 0 vlan 0 proto 8100 len 94
> [98143.863904] Pid: 7289, comm: vhost-7236 Tainted: G           O 3.3.1-3.fc16.x86_64 #1
> [98143.863935] Call Trace:
> [98143.863944]  [<ffffffffa0268593>] macvtap_do_read+0x243/0x420 [macvtap]
> [98143.863954]  [<ffffffff81088b90>] ? try_to_wake_up+0x2b0/0x2b0
> [98143.863962]  [<ffffffffa02687ba>] macvtap_recvmsg+0x4a/0x70 [macvtap]
> [98143.863971]  [<ffffffffa02e149e>] handle_rx+0x39e/0x6e0 [vhost_net]
> [98143.863983]  [<ffffffffa02e17f5>] handle_rx_net+0x15/0x20 [vhost_net]
> [98143.863996]  [<ffffffffa02de84c>] vhost_worker+0xcc/0x150 [vhost_net]
> [98143.864008]  [<ffffffffa02de780>] ? __vhost_add_used_n+0x110/0x110 [vhost_net]
> [98143.864020]  [<ffffffff81079af3>] kthread+0x93/0xa0
> [98143.864032]  [<ffffffff815fd3a4>] kernel_thread_helper+0x4/0x10
> [98143.864044]  [<ffffffff81079a60>] ? kthread_freezable_should_stop+0x70/0x70
> [98143.864056]  [<ffffffff815fd3a0>] ? gs_change+0x13/0x13
>
> things get more interesting when we take another case in account. When one kvm guest sends
> packet on the same macvlan to another guest macvtap gets skb with vlan id in the header
> and vlan_tci is not used.
>
> [99564.523943] macvtap_forward devname (null) vlan_tci 0 vlan 0 proto 8100 len 94
> [99564.523946] Pid: 8849, comm: vhost-8797 Tainted: G           O 3.3.1-3.fc16.x86_64 #1
> [99564.523947] Call Trace:
> [99564.523952]  [<ffffffffa02de19c>] macvtap_forward+0x8c/0x1b0 [macvtap]
> [99564.523963]  [<ffffffffa02c0502>] macvlan_broadcast+0x142/0x160 [macvlan]
> [99564.523967]  [<ffffffffa02c146d>] macvlan_start_xmit+0x14d/0x178 [macvlan]
> [99564.523969]  [<ffffffffa02df378>] macvtap_get_user+0x388/0x420 [macvtap]
> [99564.523971]  [<ffffffffa02df43b>] macvtap_sendmsg+0x2b/0x30 [macvtap]
> [99564.523973]  [<ffffffffa026bb3d>] handle_tx+0x2dd/0x620 [vhost_net]
> [99564.523976]  [<ffffffffa026beb5>] handle_tx_kick+0x15/0x20 [vhost_net]
> [99564.523978]  [<ffffffffa026884c>] vhost_worker+0xcc/0x150 [vhost_net]
> [99564.523980]  [<ffffffffa0268780>] ? __vhost_add_used_n+0x110/0x110 [vhost_net]
> [99564.523984]  [<ffffffff81079af3>] kthread+0x93/0xa0
> [99564.523987]  [<ffffffff815fd3a4>] kernel_thread_helper+0x4/0x10
> [99564.523989]  [<ffffffff81079a60>] ? kthread_freezable_should_stop+0x70/0x70
> [99564.523991]  [<ffffffff815fd3a0>] ? gs_change+0x13/0x13
> [99564.523999] vhost peek_head_len devname (null) vlan_tci 0 vlan 0 proto 8100 len 94
> [99564.524003] macvtap_do_read buflen 106
> [99564.524004] macvtap_do_read reallen 106
>
> And we definitely want to have common rules for all cases. So we either
> 1. restore vlan headers from vlan_tci for any packets coming outside of macvlan in
> macvtap_receive and we don't need to fix vhost_net and we preserve same vlan id
> policy that tun/tap driver have. (my original patch)
> or

> 2. we extract vlan ids for packets coming from the same macvlan, fixing vhost_net to
> take vlan_tci into account and restoring vlan headers on
> macvtap_put_user

And 2 seems to be the right answer.

Not long ago we went a few rounds with this with the core parts of the
networking stack and the rule that evolved was that we always strip the
vlan tag.  Which is why we have the vlan_untag call in __netif_receive_skb()
to handle the small handful of networking devices that don't.

vhost/net.c is just buggy.  PF_PACKET sockets have been returning
the vlan_id in ancillary data from year hardware like the e1000 since
at least 2005.

So I agree that both macvtap and vhost/net.c both need to be fixed.

Eric
