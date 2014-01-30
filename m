From: dormando <dormando@rydia.net>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Wed, 29 Jan 2014 23:05:39 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401292301070.5905@dtop>
References: <alpine.DEB.2.10.1401180036020.18419@dinf> <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com> <alpine.DEB.2.02.1401181101220.579@dtop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1401181101220.579@dtop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > On Sat, 2014-01-18 at 00:44 -0800, dormando wrote:
> > > Hello again!
> > >
> > > We've had a rare crash that's existed between 3.10.0 and 3.10.15 at least
> > > (trying newer stables now, but I can't tell if it was fixed, and it takes
> > > weeks to reproduce).
> > >
> > > Unfortunately I can only get 8k back from pstore. The panic looks a bit
> > > longer than that is caught in the log, but the bottom part is almost
> > > always this same trace as this one:
> > >
> > > Panic#6 Part1
> > > <4>[1197485.199166]  [<ffffffff81611e8c>] tcp_push+0x6c/0x90
> > > <4>[1197485.199171]  [<ffffffff816160a9>] tcp_sendmsg+0x109/0xd40
> > > <4>[1197485.199179]  [<ffffffff81114b65>] ? put_page+0x35/0x40
> > > <4>[1197485.199185]  [<ffffffff8163bf75>] inet_sendmsg+0x45/0xb0
> > > <4>[1197485.199191]  [<ffffffff8159da7e>] sock_aio_write+0x11e/0x130
> > > <4>[1197485.199196]  [<ffffffff8163b83f>] ? inet_recvmsg+0x4f/0x80
> > > <4>[1197485.199203]  [<ffffffff811558ad>] do_sync_readv_writev+0x6d/0xa0
> > > <4>[1197485.199209]  [<ffffffff8115722b>] do_readv_writev+0xfb/0x2f0
> > > <4>[1197485.199215]  [<ffffffff8110fda5>] ? __free_pages+0x35/0x40
> > > <4>[1197485.199220]  [<ffffffff8110fe56>] ? free_pages+0x46/0x50
> > > <4>[1197485.199226]  [<ffffffff8112f9e2>] ? SyS_mincore+0x152/0x690
> > > <4>[1197485.199231]  [<ffffffff81157468>] vfs_writev+0x48/0x60
> > > <4>[1197485.199236]  [<ffffffff811575af>] SyS_writev+0x5f/0xd0
> > > <4>[1197485.199243]  [<ffffffff816cf942>] system_call_fastpath+0x16/0x1b
> > > <4>[1197485.199247] Code: 65 4c 03 04 25 c8 cb 00 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 84 00 00 00 48 85 c0 74 7f 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c
> > > <1>[1197485.199290] RIP  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> > > <4>[1197485.199296]  RSP <ffff883171211868>
> > > <4>[1197485.199299] CR2: 0000000100000000
> > > <4>[1197485.199343] ---[ end trace 90fee06aa40b7304 ]---
> > > <1>[1197485.263911] BUG: unable to handle kernel paging request at 0000000100000000
> > > <1>[1197485.263923] IP: [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> > > <4>[1197485.263932] PGD 3f43e5c067 PUD 0
> > > <4>[1197485.263937] Oops: 0000 [#5] SMP
> > > <4>[1197485.263941] Modules linked in: ntfs vfat msdos fat macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode sb_edac edac_core lpc_ich mfd_core ixgbe igb i2c_algo_bit mdio ptp pps_core
> > > <4>[1197485.263966] CPU: 0 PID: 233846 Comm: cache-worker Tainted: G      D      3.10.15 #1
> > > <4>[1197485.263972] Hardware name: Supermicro X9DR3-F/X9DR3-F, BIOS 2.0a 03/07/2013
> > > <4>[1197485.263976] task: ffff883427f9dc00 ti: ffff8830d4312000 task.ti: ffff8830d4312000
> > > <4>[1197485.263982] RIP: 0010:[<ffffffff811476da>]  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> > > <4>[1197485.263990] RSP: 0018:ffff881fffc038c8  EFLAGS: 00010286
> > > <4>[1197485.263994] RAX: 0000000000000000 RBX: ffffffff81c8c740 RCX: 00000000ffffffff
> > > <4>[1197485.263999] RDX: 0000000029273024 RSI: 0000000000000020 RDI: 0000000000015680
> > > <4>[1197485.264004] RBP: ffff881fffc03908 R08: ffff881fffc15680 R09: ffffffff815bdd4b
> > > <4>[1197485.264009] R10: ffff881c65d21800 R11: 0000000000000000 R12: ffff881fff803800
> > > <4>[1197485.264014] R13: 0000000100000000 R14: 00000000ffffffff R15: 0000000000000000
> > > <4>[1197485.264019] FS:  00007f8d855eb700(0000) GS:ffff881fffc00000(0000) knlGS:0000000000000000
> > > <4>[1197485.264024] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > <4>[1197485.264028] CR2: 0000000100000000 CR3: 000000308f258000 CR4: 00000000000407f0
> > > <4>[1197485.264032] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > <4>[1197485.264037] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > <4>[1197485.264041] Stack:
> > > <4>[1197485.264044]  ffff881fffc03928 00000020815d0d95 ffff881fffc03938 ffffffff81c8c740
> > > <4>[1197485.264050]  ffff881fce210000 0000000000000001 00000000ffffffff 0000000000000000
> > > <4>[1197485.264056]  ffff881fffc03958 ffffffff815bdd4b ffff881fffc039a8 0000000000000000
> > > <4>[1197485.264063] Call Trace:
> > > <4>[1197485.264066]  <IRQ>
> > > <4>[1197485.264069]  [<ffffffff815bdd4b>] dst_alloc+0x5b/0x190
> > > <4>[1197485.264080]  [<ffffffff8160068c>] rt_dst_alloc+0x4c/0x50
> > > <4>[1197485.264085]  [<ffffffff81602a30>] __ip_route_output_key+0x270/0x880
> > > <4>[1197485.264092]  [<ffffffff8107ee7e>] ? try_to_wake_up+0x23e/0x2b0
> > > <4>[1197485.264097]  [<ffffffff81603067>] ip_route_output_flow+0x27/0x60
> > > <4>[1197485.264102]  [<ffffffff8160ab8a>] ip_queue_xmit+0x36a/0x390
> > > <4>[1197485.264108]  [<ffffffff816207c5>] tcp_transmit_skb+0x485/0x890
> > > <4>[1197485.264113]  [<ffffffff81621aa1>] tcp_send_ack+0xf1/0x130
> > > <4>[1197485.264118]  [<ffffffff81618d7e>] __tcp_ack_snd_check+0x5e/0xa0
> > > <4>[1197485.264123]  [<ffffffff8161f2c2>] tcp_rcv_state_process+0x8b2/0xb20
> > > <4>[1197485.264128]  [<ffffffff81627e61>] tcp_v4_do_rcv+0x191/0x4f0
> > > <4>[1197485.264133]  [<ffffffff8162984c>] tcp_v4_rcv+0x5fc/0x750
> > > <4>[1197485.264138]  [<ffffffff81604c80>] ? ip_rcv+0x350/0x350
> > > <4>[1197485.264143]  [<ffffffff815e45cd>] ? nf_hook_slow+0x7d/0x160
> > > <4>[1197485.264147]  [<ffffffff81604c80>] ? ip_rcv+0x350/0x350
> > > <4>[1197485.264152]  [<ffffffff81604d4e>] ip_local_deliver_finish+0xce/0x250
> > > <4>[1197485.264156]  [<ffffffff81604f1c>] ip_local_deliver+0x4c/0x80
> > > <4>[1197485.264161]  [<ffffffff816045a9>] ip_rcv_finish+0x119/0x360
> > > <4>[1197485.264165]  [<ffffffff81604b60>] ip_rcv+0x230/0x350
> > > <4>[1197485.264170]  [<ffffffff815b89f7>] __netif_receive_skb_core+0x477/0x600
> > > <4>[1197485.264175]  [<ffffffff815b8ba7>] __netif_receive_skb+0x27/0x70
> > > <4>[1197485.264180]  [<ffffffff815b8ce4>] process_backlog+0xf4/0x1e0
> > > <4>[1197485.264184]  [<ffffffff815b94e5>] net_rx_action+0xf5/0x250
> > > <4>[1197485.264190]  [<ffffffff81053b7f>] __do_softirq+0xef/0x270
> > > <4>[1197485.264196]  [<ffffffff816d0b7c>] call_softirq+0x1c/0x30
> > > <4>[1197485.264199]  <EOI>
> > > <4>[1197485.264201]  [<ffffffff81004495>] do_softirq+0x55/0x90
> > > <4>[1197485.264209]  [<ffffffff81053a84>] local_bh_enable+0x94/0xa0
> > > <4>[1197485.264215]  [<ffffffff8165567a>] ipt_do_table+0x22a/0x680
> > > <4>[1197485.264221]  [<ffffffff815d39c1>] ? skb_clone_tx_timestamp+0x31/0x110
> > > <4>[1197485.264231]  [<ffffffffa00ae840>] ? ixgbe_xmit_frame_ring+0x4c0/0xd40 [ixgbe]
> > > <4>[1197485.264239]  [<ffffffffa00af103>] ? ixgbe_xmit_frame+0x43/0x90 [ixgbe]
> > > <4>[1197485.264245]  [<ffffffff81657a23>] iptable_raw_hook+0x33/0x70
> > > <4>[1197485.264252]  [<ffffffff815e43a7>] nf_iterate+0x87/0xb0
> > > <4>[1197485.264256]  [<ffffffff81607e20>] ? ip_options_echo+0x420/0x420
> > > <4>[1197485.264261]  [<ffffffff815e45cd>] nf_hook_slow+0x7d/0x160
> > > <4>[1197485.264266]  [<ffffffff81607e20>] ? ip_options_echo+0x420/0x420
> > > <4>[1197485.264270]  [<ffffffff8160a430>] __ip_local_out+0xa0/0xb0
> > > <4>[1197485.264275]  [<ffffffff8160a456>] ip_local_out+0x16/0x30
> > > <4>[1197485.264280]  [<ffffffff8160a97a>] ip_queue_xmit+0x15a/0x390
> > > <4>[1197485.264286]  [<ffffffff81625e73>] ? tcp_v4_md5_lookup+0x13/0x20
> > > <4>[1197485.264290]  [<ffffffff816207c5>] tcp_transmit_skb+0x485/0x890
> > > <4>[1197485.264295]  [<ffffffff81622e08>] tcp_write_xmit+0x1b8/0xa50
> > > <4>[1197485.264300]  [<ffffffff815a7e28>] ? __alloc_skb+0xa8/0x1f0
> > > <4>[1197485.264304]  [<ffffffff816236d0>] tcp_push_one+0x30/0x40
> > > <4>[1197485.264309]  [<ffffffff81616b84>] tcp_sendmsg+0xbe4/0xd40
> > > <4>[1197485.264315]  [<ffffffff81114b65>] ? put_page+0x35/0x40
> > > <4>[1197485.264321]  [<ffffffff8163bf75>] inet_sendmsg+0x45/0xb0
> > > <4>[1197485.264326]  [<ffffffff8159da7e>] sock_aio_write+0x11e/0x130
> > > <4>[1197485.264331]  [<ffffffff8163b83f>] ? inet_recvmsg+0x4f/0x80
> > > <4>[1197485.264337]  [<ffffffff811558ad>] do_sync_readv_writev+0x6d/0xa0
> > > <4>[1197485.264343]  [<ffffffff8115722b>] do_readv_writev+0xfb/0x2f0
> > > <4>[1197485.264347]  [<ffffffff8110fda5>] ? __free_pages+0x35/0x40
> > > <4>[1197485.264352]  [<ffffffff8110fe56>] ? free_pages+0x46/0x50
> > > <4>[1197485.264357]  [<ffffffff8112f9e2>] ? SyS_mincore+0x152/0x690
> > > <4>[1197485.264363]  [<ffffffff81157468>] vfs_writev+0x48/0x60
> > > <4>[1197485.264367]  [<ffffffff811575af>] SyS_writev+0x5f/0xd0
> > > <4>[1197485.264373]  [<ffffffff816cf942>] system_call_fastpath+0x16/0x1b
> > > <4>[1197485.264377] Code: 65 4c 03 04 25 c8 cb 00 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 84 00 00 00 48 85 c0 74 7f 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c
> > > <1>[1197485.264417] RIP  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
> > > <4>[1197485.264424]  RSP <ffff881fffc038c8>
> > > <4>[1197485.264427] CR2: 0000000100000000
> > > <4>[1197485.264431] ---[ end trace 90fee06aa40b7305 ]---
> > > <0>[1197485.325141] Kernel panic - not syncing: Fatal exception in interrupt
> > >
> > > ... way down in the tcp code.
> > >
> > > Any help would be appreciated :) I'll do what I can to help, but iterating
> > > this particular crash is very hard due to the amount of time it takes to
> > > reproduce. Since we have a large number of machines they're always
> > > crashing here and there, but once they do it's not going to happen again
> > > for a while.
> > >
> > > Thanks!
> > > -Dormando
> > > --
> >
>
> Forgot to note: This crash appeared after 3.9 (and not in any of 3.9's
> -stable updates). We had to abandon 3.9 in a hurry due to a bizarre tcp
> corruption bug. Otherwise 3.9 never crashed on us :) 3.10 lacks the
> corruption bug, adds this rare panic.
>

Two fresh traces:

Panic#2 Part1
<1>[6707639.294029] BUG: unable to handle kernel paging request at 0000000100000000
<1>[6707639.294039] IP: [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
<4>[6707639.294050] PGD 618c91a067 PUD 0
<4>[6707639.294053] Oops: 0000 [#1] SMP
<4>[6707639.294057] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan ntfs vfat msdos fat bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich ipmi_watchdog ipmi_devintf microcode sb_edac edac_core isci igb lpc_ich i2c_algo_bit mfd_core libsas ixgbe tpm_tis ptp pps_core tpm mdio tpm_bios ipmi_si ipmi_msghandler
<4>[6707639.294085] CPU: 11 PID: 107657 Comm: sed Tainted: G        W    3.10.15 #1
<4>[6707639.294089] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[6707639.294093] task: ffff88bd4fa5ae00 ti: ffff88614bb7c000 task.ti: ffff88614bb7c000
<4>[6707639.294096] RIP: 0010:[<ffffffff811476da>]  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
<4>[6707639.294101] RSP: 0000:ffff88c07fc63b68  EFLAGS: 00010286
<4>[6707639.294103] RAX: 0000000000000000 RBX: ffffffff81c8c740 RCX: 00000000ffffffff
<4>[6707639.294106] RDX: 0000000266ceed70 RSI: 0000000000000020 RDI: 0000000000015680
<4>[6707639.294110] RBP: ffff88c07fc63ba8 R08: ffff88c07fc75680 R09: ffffffff815bdd4b
<4>[6707639.294113] R10: ffff8801d167de00 R11: 0000000000000000 R12: ffff885eff803800
<4>[6707639.294116] R13: 0000000100000000 R14: 00000000ffffffff R15: 0000000000000000
<4>[6707639.294119] FS:  00007f65232637c0(0000) GS:ffff88c07fc60000(0000) knlGS:0000000000000000
<4>[6707639.294122] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[6707639.294125] CR2: 0000000100000000 CR3: 000000618cce7000 CR4: 00000000000407e0
<4>[6707639.294128] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[6707639.294131] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[6707639.294133] Stack:
<4>[6707639.294135]  ffff88c07fc63bc8 00000020815d0d95 ffff88c07fc63bd8 ffffffff81c8c740
<4>[6707639.294139]  ffff88be6b380000 0000000000000001 00000000ffffffff 0000000000000000
<4>[6707639.294143]  ffff88c07fc63bf8 ffffffff815bdd4b ffff88c07fc63c48 ffff886100000000
<4>[6707639.294147] Call Trace:
<4>[6707639.294149]  <IRQ>
<4>[6707639.294151]  [<ffffffff815bdd4b>] dst_alloc+0x5b/0x190
<4>[6707639.294161]  [<ffffffff8160068c>] rt_dst_alloc+0x4c/0x50
<4>[6707639.294165]  [<ffffffff81602a30>] __ip_route_output_key+0x270/0x880
<4>[6707639.294168]  [<ffffffff81603067>] ip_route_output_flow+0x27/0x60
<4>[6707639.294174]  [<ffffffff8163cf29>] inet_sk_rebuild_header+0x139/0x320
<4>[6707639.294179]  [<ffffffff81622690>] __tcp_retransmit_skb+0xa0/0x550
<4>[6707639.294186]  [<ffffffff810919c6>] ? ktime_get_real+0x16/0x50
<4>[6707639.294191]  [<ffffffff8165f5ad>] ? bictcp_state+0xad/0x110
<4>[6707639.294195]  [<ffffffff81622b6b>] tcp_retransmit_skb+0x2b/0x110
<4>[6707639.294198]  [<ffffffff81625581>] tcp_retransmit_timer+0x261/0x680
<4>[6707639.294201]  [<ffffffff81625b70>] ? tcp_write_timer_handler+0x1d0/0x1d0
<4>[6707639.294205]  [<ffffffff81625a50>] tcp_write_timer_handler+0xb0/0x1d0
<4>[6707639.294208]  [<ffffffff81625b70>] ? tcp_write_timer_handler+0x1d0/0x1d0
<4>[6707639.294211]  [<ffffffff81625bd8>] tcp_write_timer+0x68/0x70
<4>[6707639.294217]  [<ffffffff8105afa9>] call_timer_fn+0x49/0x120
<4>[6707639.294220]  [<ffffffff8105b594>] run_timer_softirq+0x224/0x290
<4>[6707639.294223]  [<ffffffff81625b70>] ? tcp_write_timer_handler+0x1d0/0x1d0
<4>[6707639.294227]  [<ffffffff81053b7f>] __do_softirq+0xef/0x270
<4>[6707639.294230]  [<ffffffff81053dd5>] irq_exit+0x95/0xa0
<4>[6707639.294236]  [<ffffffff816d12ee>] smp_apic_timer_interrupt+0x6e/0x99
<4>[6707639.294242]  [<ffffffff816d050a>] apic_timer_interrupt+0x6a/0x70
<4>[6707639.294244]  <EOI>
<4>[6707639.294246] Code: 65 4c 03 04 25 c8 cb 00 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 84 00 00 00 48 85 c0 74 7f 49 63 44 24 20 49 8b 3c 24 <49> 8b 5c 05 00 48 8d 4a 01 4c 89 e8 65 48 0f c7 0f 0f 94 c0 3c
<1>[6707639.294272] RIP  [<ffffffff811476da>] kmem_cache_alloc+0x5a/0x130
<4>[6707639.294275]  RSP <ffff88c07fc63b68>
<4>[6707639.294277] CR2: 0000000100000000
<4>[6707639.294284] ---[ end trace 566552bed9fa5ac5 ]---
<0>[6707639.355743] Kernel panic - not syncing: Fatal exception in interrupt

.. and...

Panic#3 Part1
<4>[7359072.926954] CPU: 11 PID: 234126 Comm: gmond Tainted: G        W    3.10.15 #1
<4>[7359072.926969] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[7359072.926988] task: ffff8803f0c0c500 ti: ffff88017f40a000 task.ti: ffff88017f40a000
<4>[7359072.927002] RIP: 0010:[<ffffffff8114106b>]  [<ffffffff8114106b>] kmem_cache_alloc_trace+0x5b/0x140
<4>[7359072.927024] RSP: 0018:ffff88017f40be38  EFLAGS: 00010282
<4>[7359072.927034] RAX: 0000000000000000 RBX: ffff88b7aabd8230 RCX: 000000016c1d572d
<4>[7359072.927049] RDX: 000000016c1d572c RSI: 00000000000080d0 RDI: 00000000000156c0
<4>[7359072.927079] RBP: ffff88017f40be88 R08: ffff88c07fc756c0 R09: ffffffff81159904
<4>[7359072.927122] R10: 00007fe2ae0f9300 R11: 0000000000000206 R12: ffff885eff803800
<4>[7359072.927165] R13: 0000000100000000 R14: 0000000000000000 R15: 00007fe2b0e8e0e0
<4>[7359072.927208] FS:  00007fe2b0f02740(0000) GS:ffff88c07fc60000(0000) knlGS:0000000000000000
<4>[7359072.927253] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[7359072.927280] CR2: 0000000100000000 CR3: 00000001c1860000 CR4: 00000000000407e0
<4>[7359072.927323] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[7359072.927367] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[7359072.927410] Stack:
<4>[7359072.927432]  ffffffff81169052 0000000000000088 ffff88be6df50000 000080d0aabd8230
<4>[7359072.927483]  ffff88be6df50000 ffff88b7aabd8230 ffff88017f40bf40 00000000ffffffe9
<4>[7359072.927535]  0000000000000000 00007fe2b0e8e0e0 ffff88017f40bea8 ffffffff81159904
<4>[7359072.927586] Call Trace:
<4>[7359072.927613]  [<ffffffff81169052>] ? inode_init_always+0xf2/0x1b0
<4>[7359072.927643]  [<ffffffff81159904>] alloc_pipe_info+0x24/0xb0
<4>[7359072.927671]  [<ffffffff81159e8c>] create_pipe_files+0x4c/0x200
<4>[7359072.927699]  [<ffffffff8115a082>] __do_pipe_flags+0x42/0xf0
<4>[7359072.927726]  [<ffffffff8115a1a0>] SyS_pipe2+0x20/0xa0
<4>[7359072.927757]  [<ffffffff816c7f4e>] ? do_page_fault+0xe/0x10
<4>[7359072.927787]  [<ffffffff816c46b2>] ? page_fault+0x22/0x30
<4>[7359072.927814]  [<ffffffff8115a230>] SyS_pipe+0x10/0x20
<4>[7359072.927842]  [<ffffffff816cc702>] system_call_fastpath+0x16/0x1b
<4>[7359072.927869] Code: 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 d3 00 00 00 48 85 c0 0f 84 ca 00 00 00 49 63 44 24 20 48 8d 4a 01 49 8b 3c 24 <49> 8b 5c 05 00 4c 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 b5 49
<1>[7359072.928084] RIP  [<ffffffff8114106b>] kmem_cache_alloc_trace+0x5b/0x140
<4>[7359072.928115]  RSP <ffff88017f40be38>
<4>[7359072.928138] CR2: 0000000100000000
<4>[7359072.928477] ---[ end trace 83220393c4cb24ac ]---
<1>[7359072.999784] BUG: unable to handle kernel paging request at 0000000100000000
<1>[7359072.999928] IP: [<ffffffff811421e7>] kmem_cache_alloc+0x57/0x150
<4>[7359073.000032] PGD be41868067 PUD 0
<4>[7359073.000167] Oops: 0000 [#2] SMP
<4>[7359073.000301] Modules linked in: nls_cp437 isofs xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich ipmi_watchdog ipmi_devintf ixgbe microcode igb sb_edac edac_core lpc_ich i2c_algo_bit mfd_core ptp tpm_tis pps_core tpm mdio tpm_bios ipmi_si ipmi_msghandler
<4>[7359073.001557] CPU: 11 PID: 72986 Comm: cache-worker Tainted: G      D W    3.10.15 #1
<4>[7359073.001637] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[7359073.001718] task: ffff8801c07a5c00 ti: ffff88016e9b8000 task.ti: ffff88016e9b8000
<4>[7359073.001797] RIP: 0010:[<ffffffff811421e7>]  [<ffffffff811421e7>] kmem_cache_alloc+0x57/0x150
<4>[7359073.001916] RSP: 0018:ffff88c07fc638f8  EFLAGS: 00010282
<4>[7359073.001977] RAX: 0000000000000000 RBX: ffffffff81c8c1c0 RCX: 000000016c1d572d
<4>[7359073.002055] RDX: 000000016c1d572c RSI: 0000000000000020 RDI: 00000000000156c0
<4>[7359073.002133] RBP: ffff88c07fc63948 R08: ffff88c07fc756c0 R09: ffffffff815b672a
<4>[7359073.002211] R10: ffff88bc97207000 R11: 00000000a2d52a83 R12: ffff885eff803800
<4>[7359073.002289] R13: 0000000100000000 R14: 00000000ffffffff R15: 0000000000000000
<4>[7359073.002367] FS:  00007f0d36755700(0000) GS:ffff88c07fc60000(0000) knlGS:0000000000000000
<4>[7359073.002447] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[7359073.002508] CR2: 0000000100000000 CR3: 000000bc22187000 CR4: 00000000000407e0
<4>[7359073.002586] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[7359073.002664] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[7359073.002741] Stack:
<4>[7359073.002796]  ffff885e6e67ee40 ffff88c07fc63ac8 ffff88c07fc63968 00000020815c9145
<4>[7359073.003020]  c71b4c1400000001 ffffffff81c8c1c0 ffff885e6c890000 0000000000000001
<4>[7359073.003243]  00000000ffffffff 0000000000000000 ffff88c07fc63998 ffffffff815b672a
<4>[7359073.003466] Call Trace:
<4>[7359073.003522]  <IRQ>
<4>[7359073.003563]  [<ffffffff815b672a>] dst_alloc+0x5a/0x180
<4>[7359073.003720]  [<ffffffff815f78bc>] rt_dst_alloc+0x4c/0x50
<4>[7359073.003783]  [<ffffffff815f8861>] __ip_route_output_key+0x281/0x860
<4>[7359073.003846]  [<ffffffff815f8e67>] ip_route_output_flow+0x27/0x70
<4>[7359073.003910]  [<ffffffff81606fee>] inet_csk_route_req+0xce/0x130
<4>[7359073.003974]  [<ffffffff8161fda3>] tcp_v4_conn_request+0x463/0xb10
<4>[7359073.004038]  [<ffffffff81616144>] tcp_rcv_state_process+0x1c4/0xd10
<4>[7359073.004101]  [<ffffffff8161f457>] tcp_v4_do_rcv+0x257/0x4a0
<4>[7359073.004163]  [<ffffffff816215d6>] tcp_v4_rcv+0x6f6/0x870
<4>[7359073.004226]  [<ffffffff815fbff0>] ? ip_rcv_finish+0x360/0x360
<4>[7359073.004289]  [<ffffffff815fc0be>] ip_local_deliver_finish+0xce/0x250
<4>[7359073.004352]  [<ffffffff815fc3ca>] ip_local_deliver+0x4a/0x90
<4>[7359073.004415]  [<ffffffff815fbda9>] ip_rcv_finish+0x119/0x360
<4>[7359073.004477]  [<ffffffff815fc63b>] ip_rcv+0x22b/0x340
<4>[7359073.004539]  [<ffffffff815af002>] __netif_receive_skb_core+0x512/0x640
<4>[7359073.004603]  [<ffffffff815af151>] __netif_receive_skb+0x21/0x70
<4>[7359073.004666]  [<ffffffff815af23b>] process_backlog+0x9b/0x170
<4>[7359073.004729]  [<ffffffff815afa49>] net_rx_action+0x119/0x220
<4>[7359073.004794]  [<ffffffff81080f0b>] ? check_preempt_wakeup+0x14b/0x230
<4>[7359073.004860]  [<ffffffff81051970>] __do_softirq+0xd0/0x270
<4>[7359073.004921]  [<ffffffff81051c25>] irq_exit+0x55/0x60
<4>[7359073.004983]  [<ffffffff8107a5b5>] scheduler_ipi+0x35/0x40
<4>[7359073.005049]  [<ffffffff81023bda>] smp_reschedule_interrupt+0x2a/0x30
<4>[7359073.005115]  [<ffffffff816cd5da>] reschedule_interrupt+0x6a/0x70
<4>[7359073.005176]  <EOI>
<4>[7359073.005217]  [<ffffffff816c41f5>] ? _raw_spin_lock+0x25/0x30
<4>[7359073.005370]  [<ffffffff81098629>] futex_wait_setup+0x69/0xf0
<4>[7359073.005433]  [<ffffffff81098836>] futex_wait+0x186/0x2c0
<4>[7359073.005495]  [<ffffffff810508c6>] ? current_fs_time+0x16/0x60
<4>[7359073.005559]  [<ffffffff81159123>] ? pipe_write+0x2f3/0x590
<4>[7359073.005625]  [<ffffffff8118e8c2>] ? fsnotify+0x1d2/0x2b0
<4>[7359073.005687]  [<ffffffff81099e04>] do_futex+0x334/0xb20
<4>[7359073.005751]  [<ffffffff8115021a>] ? do_sync_write+0x7a/0xb0
<4>[7359073.005813]  [<ffffffff8118e8c2>] ? fsnotify+0x1d2/0x2b0
<4>[7359073.005875]  [<ffffffff8109a732>] SyS_futex+0x142/0x1a0
<4>[7359073.005939]  [<ffffffff8115148b>] ? SyS_write+0x6b/0xa0
<4>[7359073.006001]  [<ffffffff816cc702>] system_call_fastpath+0x16/0x1b
<4>[7359073.006063] Code: 00 49 8b 50 08 4d 8b 28 49 8b 40 10 4d 85 ed 0f 84 e7 00 00 00 48 85 c0 0f 84 de 00 00 00 49 63 44 24 20 48 8d 4a 01 49 8b 3c 24 <49> 8b 5c 05 00 4c 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 b5 49
<1>[7359073.008543] RIP  [<ffffffff811421e7>] kmem_cache_alloc+0x57/0x150
<4>[7359073.008642]  RSP <ffff88c07fc638f8>
<4>[7359073.008700] CR2: 0000000100000000
<4>[7359073.008767] ---[ end trace 83220393c4cb24ad ]---
<0>[7359073.072455] Kernel panic - not syncing: Fatal exception in interrupt

We hit the routing code fairly hard. Any hints for what to look at or how
to instrument it? Or if it's fixed already? It's a real pain to iterate
since it takes ~30 days to crash, usually. Sometimes.

Thanks!
