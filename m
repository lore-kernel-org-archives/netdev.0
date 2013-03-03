From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: mac80211: use spin_lock_bh() for tim_lock
Date: Sun, 03 Mar 2013 21:07:27 +0000
Message-ID: <5133BB8F.6050008@simon.arlott.org.uk>
References: <20130221033317.057EA6607E4@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130221033317.057EA6607E4@gitolite.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/02/13 03:33, Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/linus/;a=commit;h=65f704a52ec5db356c58f8ba53a31d3aef02737f
> Commit:     65f704a52ec5db356c58f8ba53a31d3aef02737f
> Parent:     441a33baf1805861354fb9e3149c000311b6996f
> Author:     Johannes Berg <johannes.berg@intel.com>
> AuthorDate: Wed Feb 13 17:39:53 2013 +0100
> Committer:  Johannes Berg <johannes.berg@intel.com>
> CommitDate: Fri Feb 15 09:41:12 2013 +0100
> 
>     mac80211: use spin_lock_bh() for tim_lock
>     
>     There's no need to use _irqsave() as the lock
>     is never used in interrupt context.

Yes it is, when bridging rt2x00 and forcedeth devices:
[   77.287586] =================================

[   77.291959] [ INFO: inconsistent lock state ]

[   77.296348] 3.8.0+ #09508-g307934e Not tainted

[   77.300802] ---------------------------------

[   77.305165] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.

[   77.311183] swapper/3/0 [HC0[0]:SC1[5]:HE1:SE0] takes:

[   77.316335]  (&(&local->tim_lock)->rlock){+.?...}, at: [<ffffffffa0064d71>] sta_info_recalc_tim+0x1c1/0x1f0 [mac80211]

[   77.327179] {SOFTIRQ-ON-W} state was registered at:

[   77.332066]   [<ffffffff81098008>] __lock_acquire+0x638/0x1d90

[   77.337935]   [<ffffffff81099cb5>] lock_acquire+0x55/0x70

[   77.343370]   [<ffffffff81706a60>] _raw_spin_lock+0x40/0x80

[   77.348977]   [<ffffffffa0080119>] ieee80211_beacon_get_tim+0x2a9/0x380 [mac80211]

[   77.356606]   [<ffffffffa00ac4f0>] rt2x00queue_update_beacon_locked+0x40/0xe0 [rt2x00lib]

[   77.364831]   [<ffffffffa00ac5c6>] rt2x00queue_update_beacon+0x36/0x60 [rt2x00lib]

[   77.372447]   [<ffffffffa00aa2cb>] rt2x00mac_bss_info_changed+0x1ab/0x1e0 [rt2x00lib]

[   77.380310]   [<ffffffffa00629cc>] ieee80211_bss_info_change_notify+0xdc/0x150 [mac80211]

[   77.388523]   [<ffffffffa00799e9>] ieee80211_start_ap+0x229/0x2c0 [mac80211]

[   77.395610]   [<ffffffffa0015f90>] nl80211_start_ap+0x3a0/0x5a0 [cfg80211]

[   77.402553]   [<ffffffff81635bd4>] genl_rcv_msg+0x1e4/0x260

[   77.408169]   [<ffffffff81634fb1>] netlink_rcv_skb+0xa1/0xc0

[   77.413860]   [<ffffffff816359e1>] genl_rcv+0x21/0x30

[   77.418952]   [<ffffffff81634919>] netlink_unicast+0x1a9/0x220

[   77.424832]   [<ffffffff81634d96>] netlink_sendmsg+0x346/0x3b0

[   77.430697]   [<ffffffff815f6afa>] sock_sendmsg+0xca/0xe0

[   77.436132]   [<ffffffff815f6ec2>] __sys_sendmsg+0x362/0x370

[   77.441814]   [<ffffffff815f9cc4>] sys_sendmsg+0x44/0x80

[   77.447161]   [<ffffffff81708416>] system_call_fastpath+0x1a/0x1f

[   77.453296] irq event stamp: 1412834

[   77.456896] hardirqs last  enabled at (1412834): [<ffffffff8170758d>] _raw_spin_unlock_irqrestore+0x5d/0x70

[   77.466695] hardirqs last disabled at (1412833): [<ffffffff81706bc0>] _raw_spin_lock_irqsave+0x20/0x90

[   77.476038] softirqs last  enabled at (1412824): [<ffffffff81050dee>] _local_bh_enable+0xe/0x10

[   77.484782] softirqs last disabled at (1412825): [<ffffffff8170980c>] call_softirq+0x1c/0x30

[   77.493279] 

[   77.493279] other info that might help us debug this:

[   77.499832]  Possible unsafe locking scenario:

[   77.499832] 

[   77.505778]        CPU0

[   77.508237]        ----

[   77.510696]   lock(&(&local->tim_lock)->rlock);

[   77.515293]   <Interrupt>

[   77.517924]     lock(&(&local->tim_lock)->rlock);

[   77.522680] 

[   77.522680]  *** DEADLOCK ***

[   77.522680] 

[   77.528635] 5 locks held by swapper/3/0:

[   77.532570]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8160d9aa>] __netif_receive_skb_core+0x5a/0x740

[   77.542114]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8160d9aa>] __netif_receive_skb_core+0x5a/0x740

[   77.551625]  #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff8160ffd0>] dev_queue_xmit+0x0/0x5f0

[   77.560457]  #3:  (_xmit_ETHER#2){+.-...}, at: [<ffffffff81629d07>] sch_direct_xmit+0xb7/0x280

[   77.569238]  #4:  (rcu_read_lock){.+.+..}, at: [<ffffffffa00822db>] ieee80211_subif_start_xmit+0x2b/0xb60 [mac80211]

[   77.579879] 

[   77.579879] stack backtrace:

[   77.584272] Pid: 0, comm: swapper/3 Not tainted 3.8.0+ #09508-g307934e

[   77.590818] Call Trace:

[   77.593289]  <IRQ>  [<ffffffff816f80ef>] print_usage_bug.part.39+0x271/0x280

[   77.600411]  [<ffffffff8100f7ca>] ? save_stack_trace+0x2a/0x50

[   77.606252]  [<ffffffff8109790f>] mark_lock+0x54f/0x610

[   77.611492]  [<ffffffff81096880>] ? print_irq_inversion_bug.part.36+0x1f0/0x1f0

[   77.618815]  [<ffffffff81097fab>] __lock_acquire+0x5db/0x1d90

[   77.624565]  [<ffffffff810945dd>] ? trace_hardirqs_off+0xd/0x10

[   77.630488]  [<ffffffff81079f05>] ? sched_clock_cpu+0xc5/0x120

[   77.636331]  [<ffffffff81079f05>] ? sched_clock_cpu+0xc5/0x120

[   77.642167]  [<ffffffff81099cb5>] lock_acquire+0x55/0x70

[   77.647506]  [<ffffffffa0064d71>] ? sta_info_recalc_tim+0x1c1/0x1f0 [mac80211]

[   77.654763]  [<ffffffff81706f05>] _raw_spin_lock_bh+0x45/0x80

[   77.660525]  [<ffffffffa0064d71>] ? sta_info_recalc_tim+0x1c1/0x1f0 [mac80211]

[   77.667777]  [<ffffffff8109a72d>] ? trace_hardirqs_on+0xd/0x10

[   77.673634]  [<ffffffffa0064d71>] sta_info_recalc_tim+0x1c1/0x1f0 [mac80211]

[   77.680689]  [<ffffffffa0081737>] invoke_tx_handlers+0x1547/0x15b0 [mac80211]

[   77.687834]  [<ffffffffa00aa84a>] ? rt2x00mac_tx+0xea/0x380 [rt2x00lib]

[   77.694466]  [<ffffffff81079f05>] ? sched_clock_cpu+0xc5/0x120

[   77.700313]  [<ffffffff810945dd>] ? trace_hardirqs_off+0xd/0x10

[   77.706250]  [<ffffffffa007f952>] ? ieee80211_tx_prepare+0x202/0x470 [mac80211]

[   77.713580]  [<ffffffffa0081cd6>] ieee80211_tx+0x86/0x100 [mac80211]

[   77.719942]  [<ffffffffa0081e91>] ieee80211_xmit+0x91/0xc0 [mac80211]

[   77.726392]  [<ffffffffa0082747>] ieee80211_subif_start_xmit+0x497/0xb60 [mac80211]

[   77.734083]  [<ffffffffa00822db>] ? ieee80211_subif_start_xmit+0x2b/0xb60 [mac80211]

[   77.741860]  [<ffffffff8160bd80>] ? __skb_gso_segment+0xb0/0xb0

[   77.747792]  [<ffffffff8160fd89>] dev_hard_start_xmit+0x229/0x470

[   77.753904]  [<ffffffff81629d46>] sch_direct_xmit+0xf6/0x280

[   77.759574]  [<ffffffff81610196>] dev_queue_xmit+0x1c6/0x5f0

[   77.765248]  [<ffffffff8160ffd0>] ? dev_hard_start_xmit+0x470/0x470

[   77.771534]  [<ffffffffa027fef7>] br_dev_queue_push_xmit+0x97/0x130 [bridge]

[   77.778589]  [<ffffffffa027ffe8>] br_forward_finish+0x58/0x60 [bridge]

[   77.785127]  [<ffffffffa0280080>] __br_forward+0x90/0xc0 [bridge]

[   77.791243]  [<ffffffffa02801c5>] br_forward+0x55/0x60 [bridge]

[   77.797175]  [<ffffffffa0280db9>] br_handle_frame_finish+0x179/0x290 [bridge]

[   77.804317]  [<ffffffffa02810a0>] br_handle_frame+0x1d0/0x280 [bridge]

[   77.810854]  [<ffffffffa0280ed0>] ? br_handle_frame_finish+0x290/0x290 [bridge]

[   77.818186]  [<ffffffff8160db26>] __netif_receive_skb_core+0x1d6/0x740

[   77.824713]  [<ffffffff8160d9aa>] ? __netif_receive_skb_core+0x5a/0x740

[   77.831334]  [<ffffffff8160e290>] ? process_backlog+0x190/0x190

[   77.837263]  [<ffffffff8160e0b1>] __netif_receive_skb+0x21/0x70

[   77.843192]  [<ffffffff8160e2b8>] netif_receive_skb+0x28/0xf0

[   77.848955]  [<ffffffffa0280e30>] br_handle_frame_finish+0x1f0/0x290 [bridge]

[   77.856106]  [<ffffffffa02810a0>] br_handle_frame+0x1d0/0x280 [bridge]

[   77.862643]  [<ffffffffa0280ed0>] ? br_handle_frame_finish+0x290/0x290 [bridge]

[   77.869980]  [<ffffffff8160db26>] __netif_receive_skb_core+0x1d6/0x740

[   77.876510]  [<ffffffff8160d9aa>] ? __netif_receive_skb_core+0x5a/0x740

[   77.883123]  [<ffffffff81094863>] ? lock_release_holdtime.part.22+0x103/0x1a0

[   77.890258]  [<ffffffff8160e0b1>] __netif_receive_skb+0x21/0x70

[   77.896180]  [<ffffffff8160e2b8>] netif_receive_skb+0x28/0xf0

[   77.901929]  [<ffffffff810945dd>] ? trace_hardirqs_off+0xd/0x10

[   77.907850]  [<ffffffff8160f1f0>] napi_gro_receive+0xd0/0x120

[   77.913601]  [<ffffffff8141e695>] nv_rx_process_optimized+0x135/0x270

[   77.920042]  [<ffffffff814221c4>] nv_napi_poll+0x84/0x5f0

[   77.925444]  [<ffffffff8160e634>] ? net_rx_action+0x84/0x170

[   77.931107]  [<ffffffff8160e64e>] net_rx_action+0x9e/0x170

[   77.936596]  [<ffffffff810513c8>] __do_softirq+0xd8/0x1b0

[   77.941999]  [<ffffffff8170980c>] call_softirq+0x1c/0x30

[   77.947319]  [<ffffffff81004355>] do_softirq+0x85/0xc0

[   77.952464]  [<ffffffff81051656>] irq_exit+0xb6/0xe0

[   77.957434]  [<ffffffff81003e4e>] do_IRQ+0x5e/0xd0

[   77.962231]  [<ffffffff81707b6f>] common_interrupt+0x6f/0x6f

[   77.967892]  <EOI>  [<ffffffff8100ac59>] ? default_idle+0x29/0x50

[   77.974026]  [<ffffffff8100ac57>] ? default_idle+0x27/0x50

[   77.979960]  [<ffffffff8100ad0b>] amd_e400_idle+0x8b/0x100

[   77.985450]  [<ffffffff810ba490>] ? rcu_idle_enter+0x80/0xc0

[   77.991112]  [<ffffffff8100b626>] cpu_idle+0x96/0xd0

[   77.996082]  [<ffffffff816f1ce1>] start_secondary+0x1bb/0x1bf

This results in a deadlock with enough forwarded traffic:
[  300.574982] BUG: soft lockup - CPU#3 stuck for 22s! [kworker/u:6:1568]

[  300.582689] Modules linked in: 8021q garp bnep rfcomm bridge stp ext4 jbd2 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 ipt_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state ip6t_REJECT iptable_filter xt_tcpudp ip6table_filter xt_dscp xt_string xt_owner xt_NFQUEUE xt_multiport xt_mark xt_iprange xt_hashlimit xt_conntrack xt_connmark nf_conntrack ip6_tables ip_tables x_tables fuse arc4 btusb rt2800usb rt2800lib crc_ccitt rt2x00usb rt2x00lib bluetooth mac80211 kvm_amd kvm crc16 cfg80211 zaurus cdc_ether usbnet

[  300.635281] CPU 3 

[  300.637135] Pid: 1568, comm: kworker/u:6 Not tainted 3.8.0+ #09507-g19cd6a2 empty empty/S2932/S2932-E

[  300.649029] RIP: 0010:[<ffffffff817538a8>]  [<ffffffff817538a8>] _raw_spin_lock_bh+0x38/0x50

[  300.658817] RSP: 0018:ffff88047fc83670  EFLAGS: 00000287

[  300.665476] RAX: 000000000000008f RBX: 0000000000000282 RCX: 0000000000000001

[  300.673976] RDX: 0000000000000090 RSI: ffff8802722f6948 RDI: ffff8802745bc850

[  300.682505] RBP: ffff88047fc83680 R08: 0000000000000002 R09: ffff880475c987c0

[  300.691064] R10: 000000000000ffff R11: 0000000000000000 R12: ffff88047fc835e8

[  300.699605] R13: ffffffff8175514a R14: ffff88047fc83680 R15: ffff8802745bc850

[  300.708164] FS:  00007f24d623a700(0000) GS:ffff88047fc80000(0000) knlGS:0000000000000000

[  300.717704] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b

[  300.724931] CR2: 0000000000c480c8 CR3: 0000000475047000 CR4: 00000000000007e0

[  300.733577] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

[  300.733578] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

[  300.733580] Process kworker/u:6 (pid: 1568, threadinfo ffff880275d9e000, task ffff880276440000)

[  300.733580] Stack:

[  300.733587]  ffff88047fc83680 ffff8802745bc620 ffff88047fc836e0 ffffffffa00728b1

[  300.733590]  ffff88047fc837d8 0000000000000000 0000000000000001 0000000000000286

[  300.733591]  ffff88047fc836e0 ffff88047fc837d8 ffff8802722f68e8 ffff880273e22f00

[  300.733592] Call Trace:

[  300.733597]  <IRQ> 

[  300.733611]  [<ffffffffa00728b1>] sta_info_recalc_tim+0x1c1/0x1f0 [mac80211]

[  300.733622]  [<ffffffffa008d147>] invoke_tx_handlers+0x1527/0x1590 [mac80211]

[  300.733630]  [<ffffffffa00fc70d>] ? rt2x00mac_tx+0xdd/0x370 [rt2x00lib]

[  300.733635]  [<ffffffff8106f70c>] ? complete+0x4c/0x60

[  300.733642]  [<ffffffffa008d3ca>] ? __ieee80211_tx.isra.28+0xfa/0x340 [mac80211]

[  300.733650]  [<ffffffffa008b3fa>] ? ieee80211_tx_prepare+0x1fa/0x460 [mac80211]

[  300.733657]  [<ffffffffa008d68d>] ieee80211_tx+0x7d/0x100 [mac80211]

[  300.733665]  [<ffffffffa008d851>] ieee80211_xmit+0x91/0xc0 [mac80211]

[  300.733672]  [<ffffffffa008e077>] ieee80211_subif_start_xmit+0x457/0xb10 [mac80211]

[  300.733677]  [<ffffffff8166ced9>] dev_hard_start_xmit+0x229/0x470

[  300.733682]  [<ffffffff81685f26>] sch_direct_xmit+0xf6/0x1c0

[  300.733683]  [<ffffffff8166d291>] dev_queue_xmit+0x171/0x460

[  300.733692]  [<ffffffffa02b4d9b>] br_dev_queue_push_xmit+0x8b/0xc0 [bridge]

[  300.733695]  [<ffffffffa02b4e28>] br_forward_finish+0x58/0x60 [bridge]

[  300.733699]  [<ffffffffa02b4ec0>] __br_forward+0x90/0xc0 [bridge]

[  300.733702]  [<ffffffffa02b5005>] br_forward+0x55/0x60 [bridge]

[  300.733706]  [<ffffffffa02b5bf9>] br_handle_frame_finish+0x179/0x290 [bridge]

[  300.733709]  [<ffffffffa02b5ee0>] br_handle_frame+0x1d0/0x280 [bridge]

[  300.733713]  [<ffffffffa02b5d10>] ? br_handle_frame_finish+0x290/0x290 [bridge]

[  300.733717]  [<ffffffff8166aaff>] __netif_receive_skb_core+0x18f/0x6d0

[  300.733719]  [<ffffffff8166b220>] ? process_backlog+0x170/0x170

[  300.733721]  [<ffffffff8166b061>] __netif_receive_skb+0x21/0x70

[  300.733723]  [<ffffffff8166b248>] netif_receive_skb+0x28/0xa0

[  300.733727]  [<ffffffffa02b5c70>] br_handle_frame_finish+0x1f0/0x290 [bridge]

[  300.733730]  [<ffffffffa02b5ee0>] br_handle_frame+0x1d0/0x280 [bridge]

[  300.733734]  [<ffffffffa02b5d10>] ? br_handle_frame_finish+0x290/0x290 [bridge]

[  300.733736]  [<ffffffff8166aaff>] __netif_receive_skb_core+0x18f/0x6d0

[  300.733738]  [<ffffffff8166b061>] __netif_receive_skb+0x21/0x70

[  300.733741]  [<ffffffff8166b248>] netif_receive_skb+0x28/0xa0

[  300.733743]  [<ffffffff8165e8df>] ? build_skb+0x2f/0x1c0

[  300.733745]  [<ffffffff8166b33b>] napi_gro_complete+0x7b/0xf0

[  300.733747]  [<ffffffff81662228>] ? __netdev_alloc_skb+0x68/0x110

[  300.733749]  [<ffffffff8166b415>] napi_gro_flush+0x65/0x80

[  300.733751]  [<ffffffff8166b452>] napi_complete+0x22/0x40

[  300.733754]  [<ffffffff81485ead>] nv_napi_poll+0x39d/0x5f0

[  300.733756]  [<ffffffff8106c68c>] ? notifier_call_chain+0x4c/0x70

[  300.733758]  [<ffffffff8166b4f9>] net_rx_action+0x89/0x150

[  300.733762]  [<ffffffff810a4e2a>] ? handle_irq_event_percpu+0x8a/0x150

[  300.733766]  [<ffffffff81050080>] __do_softirq+0xc0/0x190

[  300.733769]  [<ffffffff8175574c>] call_softirq+0x1c/0x30

[  300.733772]  [<ffffffff810042ad>] do_softirq+0x4d/0x80

[  300.733774]  [<ffffffff810502c6>] irq_exit+0xa6/0xc0

[  300.733776]  [<ffffffff81003dde>] do_IRQ+0x5e/0xd0

[  300.733778]  [<ffffffff81753d6a>] common_interrupt+0x6a/0x6a

[  300.733781]  <EOI> 

[  300.733787]  [<ffffffffa008b800>] ? __ieee80211_beacon_add_tim.isra.26+0x100/0x1d0 [mac80211]

[  300.733794]  [<ffffffffa008b765>] ? __ieee80211_beacon_add_tim.isra.26+0x65/0x1d0 [mac80211]

[  300.733802]  [<ffffffffa008bb62>] ieee80211_beacon_get_tim+0x292/0x350 [mac80211]

[  300.733804]  [<ffffffff8165f5b8>] ? consume_skb+0x18/0x40

[  300.733806]  [<ffffffff8166a905>] ? dev_kfree_skb_any+0x35/0x40

[  300.733812]  [<ffffffffa0143cb1>] ? rt2800_write_beacon+0x111/0x1d0 [rt2800lib]

[  300.733817]  [<ffffffffa00fe330>] rt2x00queue_update_beacon_locked+0x40/0xe0 [rt2x00lib]

[  300.733821]  [<ffffffffa00fa810>] ? rt2x00lib_suspend+0xd0/0xd0 [rt2x00lib]

[  300.733825]  [<ffffffffa00fe402>] rt2x00queue_update_beacon+0x32/0x50 [rt2x00lib]

[  300.733829]  [<ffffffffa00fa838>] rt2x00lib_intf_scheduled_iter+0x28/0x30 [rt2x00lib]

[  300.733837]  [<ffffffffa008fecb>] ieee80211_iterate_active_interfaces+0x9b/0xf0 [mac80211]

[  300.733841]  [<ffffffffa00fa0c3>] rt2x00lib_intf_scheduled+0x23/0x30 [rt2x00lib]

[  300.733844]  [<ffffffff81061331>] process_one_work+0x141/0x390

[  300.733846]  [<ffffffff81061918>] worker_thread+0x118/0x390

[  300.733847]  [<ffffffff81061800>] ? rescuer_thread+0x240/0x240

[  300.733850]  [<ffffffff81066a4b>] kthread+0xbb/0xc0

[  300.733853]  [<ffffffff81066990>] ? kthread_freezable_should_stop+0x70/0x70

[  300.733855]  [<ffffffff8175442c>] ret_from_fork+0x7c/0xb0

[  300.733857]  [<ffffffff81066990>] ? kthread_freezable_should_stop+0x70/0x70

[  300.733876] Code: df c2 8f ff 65 48 8b 04 25 b0 b8 00 00 ff 80 44 e0 ff ff b8 00 01 00 00 f0 66 0f c1 03 0f b6 d4 38 c2 74 10 0f 1f 80 00 00 00 00 <f3> 90 0f b6 03 38 d0 75 f7 48 83 c4 08 5b 5d c3 0f 1f 84 00 00 

>     This also fixes a problem in the iwlwifi MVM
>     driver that calls spin_unlock_bh() within its
>     set_tim() callback.
>     
>     Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  net/mac80211/sta_info.c |    5 ++---
>  net/mac80211/tx.c       |    6 ++----
>  2 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
> index fb3b586..0794b90 100644
> --- a/net/mac80211/sta_info.c
> +++ b/net/mac80211/sta_info.c
> @@ -571,7 +571,6 @@ void sta_info_recalc_tim(struct sta_info *sta)
>  {
>  	struct ieee80211_local *local = sta->local;
>  	struct ps_data *ps;
> -	unsigned long flags;
>  	bool indicate_tim = false;
>  	u8 ignore_for_tim = sta->sta.uapsd_queues;
>  	int ac;
> @@ -628,7 +627,7 @@ void sta_info_recalc_tim(struct sta_info *sta)
>  	}
>  
>   done:
> -	spin_lock_irqsave(&local->tim_lock, flags);
> +	spin_lock_bh(&local->tim_lock);
>  
>  	if (indicate_tim)
>  		__bss_tim_set(ps->tim, id);
> @@ -641,7 +640,7 @@ void sta_info_recalc_tim(struct sta_info *sta)
>  		local->tim_in_locked_section = false;
>  	}
>  
> -	spin_unlock_irqrestore(&local->tim_lock, flags);
> +	spin_unlock_bh(&local->tim_lock);
>  }
>  
>  static bool sta_info_buffer_expired(struct sta_info *sta, struct sk_buff *skb)
> diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
> index f4c89f5..7d8c629 100644
> --- a/net/mac80211/tx.c
> +++ b/net/mac80211/tx.c
> @@ -2364,11 +2364,9 @@ static int ieee80211_beacon_add_tim(struct ieee80211_sub_if_data *sdata,
>  	if (local->tim_in_locked_section) {
>  		__ieee80211_beacon_add_tim(sdata, ps, skb);
>  	} else {
> -		unsigned long flags;
> -
> -		spin_lock_irqsave(&local->tim_lock, flags);
> +		spin_lock(&local->tim_lock);
>  		__ieee80211_beacon_add_tim(sdata, ps, skb);
> -		spin_unlock_irqrestore(&local->tim_lock, flags);
> +		spin_unlock(&local->tim_lock);
>  	}
>  
>  	return 0;
> --
> To unsubscribe from this list: send the line "unsubscribe git-commits-head" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Simon Arlott
