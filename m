From: Laura Abbott <labbott@redhat.com>
Subject: Lockdep splat with tc filter on 4.11
Date: Tue, 13 Jun 2017 10:28:16 -0700
Message-ID: <d1a11d1e-c167-3bab-7b82-10932dedfb1d@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        nicholashuber@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Fedora got a bug report https://bugzilla.redhat.com/show_bug.cgi?id=1459626
of a hang on 4.11.3 with lockdep splat:

[  129.100206] BUG: sleeping function called from invalid context at mm/slab.h:432
[  129.100237] in_atomic(): 1, irqs_disabled(): 0, pid: 1793, name: tc
[  129.100239] 2 locks held by tc/1793:
[  129.100241]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8c826217>] rtnl_lock+0x17/0x20
[  129.100250]  #1:  (&(&p->tcfa_lock)->rlock){+...+.}, at: [<ffffffffc08ba22d>] tcf_act_police_init+0x22d/0x580 [act_police]
[  129.100259] CPU: 2 PID: 1793 Comm: tc Not tainted 4.11.3-202.fc25.x86_64+debug #1
[  129.100261] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
[  129.100262] Call Trace:
[  129.100270]  dump_stack+0x86/0xc3
[  129.100274]  ___might_sleep+0x17d/0x250
[  129.100277]  __might_sleep+0x4a/0x80
[  129.100280]  kmem_cache_alloc_trace+0x1e6/0x2d0
[  129.100284]  ? gen_new_estimator+0x76/0x1d0
[  129.100288]  gen_new_estimator+0x76/0x1d0
[  129.100293]  gen_replace_estimator+0xe/0x10
[  129.100296]  tcf_act_police_init+0x255/0x580 [act_police]
[  129.100304]  tcf_action_init_1+0xb9/0x340
[  129.100316]  tcf_exts_validate+0x52/0x110
[  129.100320]  fw_change_attrs+0xbb/0x2b0 [cls_fw]
[  129.100324]  ? rcu_read_lock_sched_held+0x4a/0x80
[  129.100329]  fw_change+0x3ad/0x4bb [cls_fw]
[  129.100338]  tc_ctl_tfilter+0x470/0xa80
[  129.100350]  rtnetlink_rcv_msg+0xe6/0x210
[  129.100354]  ? sched_clock+0x9/0x10
[  129.100358]  ? sched_clock_cpu+0x11/0xc0
[  129.100360]  ? netlink_unicast+0x1cd/0x2f0
[  129.100363]  ? rtnl_newlink+0x8e0/0x8e0
[  129.100366]  netlink_rcv_skb+0xa4/0xc0
[  129.100369]  rtnetlink_rcv+0x2a/0x40
[  129.100371]  netlink_unicast+0x1f5/0x2f0
[  129.100375]  netlink_sendmsg+0x302/0x3c0
[  129.100382]  sock_sendmsg+0x38/0x50
[  129.100385]  ___sys_sendmsg+0x2f6/0x310
[  129.100392]  ? _raw_spin_unlock+0x27/0x40
[  129.100396]  ? __handle_mm_fault+0x539/0x1170
[  129.100401]  ? __do_page_fault+0x28e/0x520
[  129.100405]  ? kvm_sched_clock_read+0x25/0x40
[  129.100407]  ? sched_clock+0x9/0x10
[  129.100409]  ? sched_clock_cpu+0x11/0xc0
[  129.100411]  ? __do_page_fault+0x28e/0x520
[  129.100420]  __sys_sendmsg+0x54/0x90
[  129.100422]  ? __sys_sendmsg+0x54/0x90
[  129.100430]  SyS_sendmsg+0x12/0x20
[  129.100432]  entry_SYSCALL_64_fastpath+0x1f/0xc2
[  129.100434] RIP: 0033:0x7f50dffca037
[  129.100436] RSP: 002b:00007ffe99d12698 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[  129.100438] RAX: ffffffffffffffda RBX: 00007ffe99d1e7e0 RCX: 00007f50dffca037
[  129.100439] RDX: 0000000000000000 RSI: 00007ffe99d126e0 RDI: 0000000000000003
[  129.100441] RBP: 00007ffe99d126e0 R08: 0000000000000001 R09: 0000000000000000
[  129.100442] R10: 00000000000005eb R11: 0000000000000246 R12: 00007ffe99d12720
[  129.100443] R13: 0000000000668060 R14: 00007ffe99d1a7b0 R15: 0000000000000000

[  129.100454] =============================================
[  129.100455] [ INFO: possible recursive locking detected ]
[  129.100456] 4.11.3-202.fc25.x86_64+debug #1 Tainted: G        W      
[  129.100456] ---------------------------------------------
[  129.100457] tc/1793 is trying to acquire lock:
[  129.100457]  (&(&p->tcfa_lock)->rlock){+...+.}, at: [<ffffffff8c802d93>] est_fetch_counters+0x23/0x50
[  129.100460] 
               but task is already holding lock:
[  129.100460]  (&(&p->tcfa_lock)->rlock){+...+.}, at: [<ffffffffc08ba22d>] tcf_act_police_init+0x22d/0x580 [act_police]
[  129.100463] 
               other info that might help us debug this:
[  129.100463]  Possible unsafe locking scenario:

[  129.100464]        CPU0
[  129.100465]        ----
[  129.100465]   lock(&(&p->tcfa_lock)->rlock);
[  129.100466]   lock(&(&p->tcfa_lock)->rlock);
[  129.100467] 
                *** DEADLOCK ***

[  129.100468]  May be due to missing lock nesting notation

[  129.100469] 2 locks held by tc/1793:
[  129.100470]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8c826217>] rtnl_lock+0x17/0x20
[  129.100472]  #1:  (&(&p->tcfa_lock)->rlock){+...+.}, at: [<ffffffffc08ba22d>] tcf_act_police_init+0x22d/0x580 [act_police]
[  129.100474] 
               stack backtrace:
[  129.100475] CPU: 2 PID: 1793 Comm: tc Tainted: G        W       4.11.3-202.fc25.x86_64+debug #1
[  129.100476] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
[  129.100477] Call Trace:
[  129.100478]  dump_stack+0x86/0xc3
[  129.100480]  __lock_acquire+0x858/0x1450
[  129.100481]  ? ___slab_alloc+0x2a9/0x5f0
[  129.100483]  lock_acquire+0xe3/0x1d0
[  129.100484]  ? gen_new_estimator+0x76/0x1d0
[  129.100486]  ? lock_acquire+0xe3/0x1d0
[  129.100487]  ? est_fetch_counters+0x23/0x50
[  129.100488]  _raw_spin_lock+0x34/0x70
[  129.100489]  ? est_fetch_counters+0x23/0x50
[  129.100491]  est_fetch_counters+0x23/0x50
[  129.100492]  gen_new_estimator+0xdf/0x1d0
[  129.100493]  gen_replace_estimator+0xe/0x10
[  129.100495]  tcf_act_police_init+0x255/0x580 [act_police]
[  129.100496]  tcf_action_init_1+0xb9/0x340
[  129.100499]  tcf_exts_validate+0x52/0x110
[  129.100537]  fw_change_attrs+0xbb/0x2b0 [cls_fw]
[  129.100539]  ? rcu_read_lock_sched_held+0x4a/0x80
[  129.100540]  fw_change+0x3ad/0x4bb [cls_fw]
[  129.100543]  tc_ctl_tfilter+0x470/0xa80
[  129.100545]  rtnetlink_rcv_msg+0xe6/0x210
[  129.100547]  ? sched_clock+0x9/0x10
[  129.100548]  ? sched_clock_cpu+0x11/0xc0
[  129.100549]  ? netlink_unicast+0x1cd/0x2f0
[  129.100551]  ? rtnl_newlink+0x8e0/0x8e0
[  129.100552]  netlink_rcv_skb+0xa4/0xc0
[  129.100553]  rtnetlink_rcv+0x2a/0x40
[  129.100554]  netlink_unicast+0x1f5/0x2f0
[  129.100556]  netlink_sendmsg+0x302/0x3c0
[  129.100557]  sock_sendmsg+0x38/0x50
[  129.100558]  ___sys_sendmsg+0x2f6/0x310
[  129.100560]  ? _raw_spin_unlock+0x27/0x40
[  129.100562]  ? __handle_mm_fault+0x539/0x1170
[  129.100564]  ? __do_page_fault+0x28e/0x520
[  129.100565]  ? kvm_sched_clock_read+0x25/0x40
[  129.100566]  ? sched_clock+0x9/0x10
[  129.100568]  ? sched_clock_cpu+0x11/0xc0
[  129.100569]  ? __do_page_fault+0x28e/0x520
[  129.100571]  __sys_sendmsg+0x54/0x90
[  129.100572]  ? __sys_sendmsg+0x54/0x90
[  129.100574]  SyS_sendmsg+0x12/0x20
[  129.100575]  entry_SYSCALL_64_fastpath+0x1f/0xc2
[  129.100576] RIP: 0033:0x7f50dffca037
[  129.100578] RSP: 002b:00007ffe99d12698 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[  129.100579] RAX: ffffffffffffffda RBX: 00007ffe99d1e7e0 RCX: 00007f50dffca037
[  129.100580] RDX: 0000000000000000 RSI: 00007ffe99d126e0 RDI: 0000000000000003
[  129.100581] RBP: 00007ffe99d126e0 R08: 0000000000000001 R09: 0000000000000000
[  129.100581] R10: 00000000000005eb R11: 0000000000000246 R12: 00007ffe99d12720
[  129.100582] R13: 0000000000668060 R14: 00007ffe99d1a7b0 R15: 0000000000000000
[  155.156414] NMI watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [tc:1793]
[  155.156418] Modules linked in: act_police cls_fw sch_htb uinput ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables sunrpc snd_hda_codec_generic snd_hda_intel crct10dif_pclmul crc32_pclmul snd_hda_codec snd_hda_core snd_hwdep ghash_clmulni_intel snd_seq snd_seq_device ppdev snd_pcm joydev snd_timer snd virtio_balloon soundcore i2c_piix4 parport_pc parport acpi_cpufreq tpm_tis tpm_tis_core qemu_fw_cfg tpm xfs libcrc32c virtio_rng virtio_console virtio_blk 
 virtio_net
[  155.156465]  crc32c_intel qxl drm_kms_helper ttm serio_raw drm virtio_pci virtio_ring virtio ata_generic pata_acpi
[  155.156474] irq event stamp: 3596
[  155.156477] hardirqs last  enabled at (3596): [<ffffffff8c296dee>] __slab_alloc+0x5e/0x90
[  155.156479] hardirqs last disabled at (3595): [<ffffffff8c296dcc>] __slab_alloc+0x3c/0x90
[  155.156482] softirqs last  enabled at (3508): [<ffffffff8c84db6c>] tcf_hash_lookup+0x6c/0x80
[  155.156485] softirqs last disabled at (3510): [<ffffffffc08ba22d>] tcf_act_police_init+0x22d/0x580 [act_police]
[  155.156487] CPU: 2 PID: 1793 Comm: tc Tainted: G        W       4.11.3-202.fc25.x86_64+debug #1
[  155.156488] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-1.fc25 04/01/2014
[  155.156489] task: ffff98a803f5b240 task.stack: ffffb21b41b24000
[  155.156492] RIP: 0010:queued_spin_lock_slowpath+0x25/0x1a0
[  155.156493] RSP: 0018:ffffb21b41b27720 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
[  155.156495] RAX: 0000000000000001 RBX: ffff98a83a7a4298 RCX: 0000000000000002
[  155.156496] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff98a83a7a4298
[  155.156498] RBP: ffffb21b41b27720 R08: 000000345deae54f R09: 0000000000000000
[  155.156499] R10: ffffb21b41b276d0 R11: 0000000000000000 R12: ffff98a83a7a4298
[  155.156500] R13: ffff98a8395da474 R14: ffff98a82789c200 R15: ffff98a83a7a4270
[  155.156501] FS:  00007f50e0bbd500(0000) GS:ffff98a83d400000(0000) knlGS:0000000000000000
[  155.156502] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  155.156504] CR2: 00007ffe99d18000 CR3: 000000003c549000 CR4: 00000000001406e0
[  155.156507] Call Trace:
[  155.156510]  do_raw_spin_lock+0xb2/0xc0
[  155.156513]  _raw_spin_lock+0x55/0x70
[  155.156515]  est_fetch_counters+0x23/0x50
[  155.156517]  gen_new_estimator+0xdf/0x1d0
[  155.156520]  gen_replace_estimator+0xe/0x10
[  155.156522]  tcf_act_police_init+0x255/0x580 [act_police]
[  155.156525]  tcf_action_init_1+0xb9/0x340
[  155.156530]  tcf_exts_validate+0x52/0x110
[  155.156532]  fw_change_attrs+0xbb/0x2b0 [cls_fw]
[  155.156535]  ? rcu_read_lock_sched_held+0x4a/0x80
[  155.156537]  fw_change+0x3ad/0x4bb [cls_fw]
[  155.156541]  tc_ctl_tfilter+0x470/0xa80
[  155.156546]  rtnetlink_rcv_msg+0xe6/0x210
[  155.156549]  ? sched_clock+0x9/0x10
[  155.156551]  ? sched_clock_cpu+0x11/0xc0
[  155.156553]  ? netlink_unicast+0x1cd/0x2f0
[  155.156555]  ? rtnl_newlink+0x8e0/0x8e0
[  155.156557]  netlink_rcv_skb+0xa4/0xc0
[  155.156559]  rtnetlink_rcv+0x2a/0x40
[  155.156560]  netlink_unicast+0x1f5/0x2f0
[  155.156563]  netlink_sendmsg+0x302/0x3c0
[  155.156566]  sock_sendmsg+0x38/0x50
[  155.156568]  ___sys_sendmsg+0x2f6/0x310
[  155.156571]  ? _raw_spin_unlock+0x27/0x40
[  155.156573]  ? __handle_mm_fault+0x539/0x1170
[  155.156576]  ? __do_page_fault+0x28e/0x520
[  155.156578]  ? kvm_sched_clock_read+0x25/0x40
[  155.156580]  ? sched_clock+0x9/0x10
[  155.156581]  ? sched_clock_cpu+0x11/0xc0
[  155.156583]  ? __do_page_fault+0x28e/0x520
[  155.156587]  __sys_sendmsg+0x54/0x90
[  155.156588]  ? __sys_sendmsg+0x54/0x90
[  155.156592]  SyS_sendmsg+0x12/0x20
[  155.156594]  entry_SYSCALL_64_fastpath+0x1f/0xc2
[  155.156595] RIP: 0033:0x7f50dffca037
[  155.156596] RSP: 002b:00007ffe99d12698 EFLAGS: 00000246 ORIG_RAX: 000000000000002e
[  155.156598] RAX: ffffffffffffffda RBX: 00007ffe99d1e7e0 RCX: 00007f50dffca037
[  155.156599] RDX: 0000000000000000 RSI: 00007ffe99d126e0 RDI: 0000000000000003
[  155.156600] RBP: 00007ffe99d126e0 R08: 0000000000000001 R09: 0000000000000000
[  155.156601] R10: 00000000000005eb R11: 0000000000000246 R12: 00007ffe99d12720
[  155.156602] R13: 0000000000668060 R14: 00007ffe99d1a7b0 R15: 0000000000000000
[  155.156606] Code: 1f 80 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 0f 1f 44 00 00 ba 01 00 00 00 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00 00 b9

I haven't seen anything queued up for this yet.

Thanks,
Laura
