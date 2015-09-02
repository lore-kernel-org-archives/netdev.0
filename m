From: Shaun Crampton <Shaun.Crampton@metaswitch.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Wed, 2 Sep 2015 16:39:51 +0000
Message-ID: <D20CE2AD.43744%Shaun.Crampton@metaswitch.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
 <20150826074959.48aea34c@as>
 <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
 <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Chuck Ebbert <cebbert.lkml@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Peter White <Peter.White@metaswitch.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Marineau <michael.marineau@coreos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <DA7E82CC6BE8D94C98CB65E4B91B7A44@metaswitch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Make sure you backported commit
> 10e2eb878f3ca07ac2f05fa5ca5e6c4c9174a27a
> ("udp: fix dst races with multicast early demux")


I just tried the latest CoreOS alpha, which had that patch.  Sadly, I saw
just as many reboots.  Here's a sample of the different types of Oopses I
see (I've put the rest up in a gist:
https://gist.github.com/fasaxc/d801ced5608f2657abd8):

[ 4024.564479] BUG: unable to handle kernel NULL pointer dereference at
       (null)
[ 4024.565452] IP: [<          (null)>]           (null)
[ 4024.565452] PGD 2297067 PUD 2296067 PMD 0
[ 4024.565452] Oops: 0010 [#1] SMP
[ 4024.565452] Modules linked in: xt_mac xt_mark veth ip_set_hash_net
nf_conntrack_ipv6 nf_defrag_ipv6 xt_comment xt_set ip_set_hash_ip ip_set
nfnetlink ipip tunnel4 ip_tunnel ip6table_filter ip6_tables xt_conntrack
ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter br_netfilter nf_nat
nf_conntrack bridge stp llc overlay nls_ascii nls_cp437 vfat fat ext4
crc16 mbcache jbd2 sd_mod crc32c_intel virtio_scsi scsi_mod aesni_intel
virtio_net mousedev aes_x86_64 glue_helper lrw gf128mul ablk_helper cryptd
microcode firmware_class virtio_pci virtio_ring psmouse virtio i2c_piix4
i2c_core acpi_cpufreq button evdev sch_fq_codel ip_tables autofs4
[ 4024.565452] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.1.6-coreos-r1 #2
[ 4024.565452] Hardware name: Google Google, BIOS Google 01/01/2011
[ 4024.565452] task: ffffffff81a154c0 ti: ffffffff81a00000 task.ti:
ffffffff81a00000
[ 4024.565452] RIP: 0010:[<0000000000000000>]  [<          (null)>]
   (null)
[ 4024.565452] RSP: 0018:ffff88021fc03c00  EFLAGS: 00010246
[ 4024.565452] RAX: ffff880003375d00 RBX: ffff880003375d00 RCX:
0000000000000001
[ 4024.565452] RDX: ffff88000306c000 RSI: 0000000000000000 RDI:
ffff880003375d00
[ 4024.565452] RBP: ffff88021fc03c28 R08: 0000000000005608 R09:
000000000000bb84
[ 4024.565452] R10: 0000000000000003 R11: ffff880215a30dc0 R12:
ffff880214bfb000
[ 4024.565452] R13: ffff88000306c000 R14: ffff88000306c000 R15:
0000000000000008
[ 4024.565452] FS:  0000000000000000(0000) GS:ffff88021fc00000(0000)
knlGS:0000000000000000
[ 4024.565452] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4024.565452] CR2: 0000000000000000 CR3: 0000000001d92000 CR4:
00000000001406f0
[ 4024.600761] Stack:
[ 4024.601081]  ffffffff814ac9dc ffff880000000002 ffff88000306c000
ffff880003375d00
[ 4024.601081]  ffff88008cbba84e ffff88021fc03c58 ffffffff81486628
ffff88021690a000
[ 4024.601081]  ffff88008cbba84e ffff880003375d00 ffff88000306c000
ffff88021fc03cb8
[ 4024.601081] Call Trace:
[ 4024.601081]  <IRQ>
[ 4024.601081]  [<ffffffff814ac9dc>] ? tcp_v4_early_demux+0x11c/0x160
[ 4024.601081]  [<ffffffff81486628>] ip_rcv_finish+0xb8/0x360
[ 4024.601081]  [<ffffffff81486f84>] ip_rcv+0x2a4/0x400
[ 4024.601081]  [<ffffffff81486570>] ? inet_del_offload+0x40/0x40
[ 4024.601081]  [<ffffffff81449053>] __netif_receive_skb_core+0x6c3/0x9a0
[ 4024.601081]  [<ffffffff8143b507>] ? build_skb+0x17/0x90
[ 4024.601081]  [<ffffffff81449348>] __netif_receive_skb+0x18/0x60
[ 4024.601081]  [<ffffffff814493c3>] netif_receive_skb_internal+0x33/0xa0
[ 4024.601081]  [<ffffffff8144944c>] netif_receive_skb_sk+0x1c/0x70
[ 4024.601081]  [<ffffffffa008772b>] 0xffffffffa008772b
[ 4024.601081]  [<ffffffff81096cb0>] ? check_preempt_curr+0x80/0xa0
[ 4024.601081]  [<ffffffffa0087d81>] 0xffffffffa0087d81
[ 4024.601081]  [<ffffffff81449819>] net_rx_action+0x159/0x340
[ 4024.601081]  [<ffffffff810715f4>] __do_softirq+0xf4/0x290
[ 4024.601081]  [<ffffffff810719fd>] irq_exit+0xad/0xc0
[ 4024.601081]  [<ffffffff815527fa>] do_IRQ+0x5a/0xf0
[ 4024.601081]  [<ffffffff815506ae>] common_interrupt+0x6e/0x6e
[ 4024.601081]  <EOI>
[ 4024.601081]  [<ffffffff81059bd6>] ? native_safe_halt+0x6/0x10
[ 4024.601081]  [<ffffffff8101f17e>] default_idle+0x1e/0xc0
[ 4024.601081]  [<ffffffff8101fc5f>] arch_cpu_idle+0xf/0x20
[ 4024.601081]  [<ffffffff810b0ab4>] cpu_startup_entry+0x314/0x3e0
[ 4024.601081]  [<ffffffff8153bbec>] rest_init+0x7c/0x80
[ 4024.601081]  [<ffffffff81b130e0>] start_kernel+0x483/0x490
[ 4024.601081]  [<ffffffff81b12a4d>] ? set_init_arg+0x55/0x55
[ 4024.601081]  [<ffffffff81b12120>] ? early_idt_handler_array+0x120/0x120
[ 4024.601081]  [<ffffffff81b125ee>] x86_64_start_reservations+0x2a/0x2c
[ 4024.601081]  [<ffffffff81b12728>] x86_64_start_kernel+0x138/0x147
[ 4024.601081] Code:  Bad RIP value.
[ 4024.601081] RIP  [<          (null)>]           (null)
[ 4024.601081]  RSP <ffff88021fc03c00>
[ 4024.601081] CR2: 0000000000000000
[ 4024.601081] ---[ end trace cdabfe9d7380aaab ]---
[ 4024.601081] Kernel panic - not syncing: Fatal exception in interrupt
[ 4024.601081] Kernel Offset: disabled
[ 4024.601081] Rebooting in 60 seconds..
[ 4024.601081] ACPI MEMORY or I/O RESET_REG.




[ 4811.261621] NULL pointer dereference at 0000000000000020
[ 4811.261621] IP: [<ffffffff814a3c2a>] tcp_current_mss+0x2a/0x80
[ 4811.261621] PGD 214af5067 PUD 210de8067 PMD 0
[ 4811.261621] Oops: 0000 [#2] SMP
[ 4811.261621] Modules linked in: xt_mac xt_mark veth ip_set_hash_net
nf_conntrack_ipv6 nf_defrag_ipv6 xt_comment xt_set ip_set_hash_ip ip_set
nfnetlink ipip tunnel4 ip_tunnel ip6table_filter ip6_tables xt_conntrack
ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter br_netfilter nf_nat
nf_conntrack bridge stp llc overlay nls_ascii nls_cp437 vfat fat ext4
crc16 mbcache jbd2 sd_mod virtio_scsi scsi_mod virtio_net mousedev
crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper
cryptd microcode firmware_class acpi_cpufreq virtio_pci virtio_ring virtio
i2c_piix4 i2c_core psmouse button evdev sch_fq_codel ip_tables autofs4
[ 4811.261621] CPU: 1 PID: 770 Comm: etcd2 Tainted: G      D W
4.1.6-coreos-r1 #2
[ 4811.261621] Hardware name: Google Google, BIOS Google 01/01/2011
[ 4811.261621] task: ffff88021427b240 ti: ffff880215438000 task.ti:
ffff880215438000
[ 4811.261621] RIP: 0010:[<ffffffff814a3c2a>]  [<ffffffff814a3c2a>]
tcp_current_mss+0x2a/0x80
[ 4811.261621] RSP: 0018:ffff88021543bc48  EFLAGS: 00010286
[ 4811.261621] RAX: 0000000000000000 RBX: ffff8800bafb5800 RCX:
0000000000000000
[ 4811.261621] RDX: 0000000000000040 RSI: ffff88021543bd18 RDI:
ffff8801d6185600
[ 4811.261621] RBP: ffff88021543bc88 R08: 0000000000000000 R09:
ffff880211480b70
[ 4811.261621] R10: ffff88021427b240 R11: 0000000000000246 R12:
0000000000000580
[ 4811.261621] R13: ffff88021543bd18 R14: ffff88021543bdc0 R15:
0000000000000010
[ 4811.261621] FS:  00007f99058c4700(0000) GS:ffff88021fd00000(0000)
knlGS:0000000000000000
[ 4811.261621] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4811.261621] CR2: 0000000000000020 CR3: 00000000ba159000 CR4:
00000000001406e0
[ 4811.261621] Stack:
[ 4811.261621]  ffff88021fd16040 ffff88021fd16040 ffff880215458000
ffff88021fd16040
[ 4811.261621]  0000000000000001 ffff88021fd16040 ffff8800bafb5800
0000000000000040
[ 4811.261621]  ffff88021543bcb8 ffffffff81494330 ffff88021543bcb8
00000000000000ba
[ 4811.261621] Call Trace:
[ 4811.261621]  [<ffffffff81494330>] tcp_send_mss+0x20/0xe0
[ 4811.261621]  [<ffffffff81497bbb>] tcp_sendmsg+0x12b/0xb20
[ 4811.261621]  [<ffffffff81096e4d>] ?
ttwu_do_activate.constprop.100+0x5d/0x70
[ 4811.261621]  [<ffffffff81099df1>] ? try_to_wake_up+0x1f1/0x340
[ 4811.261621]  [<ffffffff814c2c04>] inet_sendmsg+0x64/0xa0
[ 4811.261621]  [<ffffffff81265ec3>] ? selinux_socket_sendmsg+0x23/0x30
[ 4811.261621]  [<ffffffff8142d5ed>] sock_sendmsg+0x3d/0x50
[ 4811.261621]  [<ffffffff8142d678>] sock_write_iter+0x78/0xe0
[ 4811.261621]  [<ffffffff811cba11>] __vfs_write+0xb1/0xf0
[ 4811.261621]  [<ffffffff811cc079>] vfs_write+0xa9/0x1b0
[ 4811.261621]  [<ffffffff811cce46>] SyS_write+0x46/0xb0
[ 4811.261621]  [<ffffffff810240c3>] ? syscall_trace_leave+0x93/0xf0
[ 4811.261621]  [<ffffffff8154fb6e>] system_call_fastpath+0x12/0x71
[ 4811.261621] Code: 00 0f 1f 44 00 00 55 48 89 e5 41 54 53 48 89 fb 48 83
ec 30 48 8b bf 18 01 00 00 44 8b a3 14 06 00 00 48 85 ff 74 1c 48 8b 47 20
<ff> 50 20 39 83 b4 04 00 00 74 0d 89 c6 48 89 df e8 01 f9 ff ff
[ 4811.261621] RIP  [<ffffffff814a3c2a>] tcp_current_mss+0x2a/0x80
[ 4811.261621]  RSP <ffff88021543bc48>
[ 4811.261621] CR2: 0000000000000020
[ 4811.332025] Kernel Offset: disabled
[ 4811.332025] Rebooting in 60 seconds..
[ 4811.332025] ACPI MEMORY or I/O RESET_REG.




[ 4577.655038] general protection fault: 0000 [#1] SMP
[ 4577.656128] Modules linked in: xt_mac xt_mark veth ip_set_hash_net
nf_conntrack_ipv6 nf_defrag_ipv6 xt_comment xt_set ip_set_hash_ip ip_set
nfnetlink ipip tunnel4 ip_tunnel ip6table_filter ip6_tables xt_conntrack
ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype iptable_filter br_netfilter nf_nat
nf_conntrack bridge stp llc overlay nls_ascii nls_cp437 vfat fat ext4
crc16 mbcache jbd2 sd_mod virtio_scsi scsi_mod virtio_net mousedev
crc32c_intel aesni_intel aes_x86_64 glue_helper lrw gf128mul ablk_helper
cryptd microcode firmware_class acpi_cpufreq button virtio_pci virtio_ring
i2c_piix4 i2c_core psmouse virtio evdev sch_fq_codel ip_tables autofs4
[ 4577.665603] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.1.6-coreos-r1 #2
[ 4577.671664] Hardware name: Google Google, BIOS Google 01/01/2011
[ 4577.672534] task: ffffffff81a154c0 ti: ffffffff81a00000 task.ti:
ffffffff81a00000
[ 4577.672534] RIP: 0010:[<ffffffff8148177f>]  [<ffffffff8148177f>]
ipv4_dst_destroy+0x3f/0x80
[ 4577.672534] RSP: 0018:ffff88021fc03e58  EFLAGS: 00010246
[ 4577.672534] RAX: dead000000200200 RBX: ffff8800ba655200 RCX:
0000000000000020
[ 4577.672534] RDX: dead000000100100 RSI: 00000000fffffe01 RDI:
ffff88021fc17180
[ 4577.672534] RBP: ffff88021fc03e68 R08: ffff88021515e700 R09:
000000018010000f
[ 4577.672534] R10: ffffffff81451fc5 R11: ffffea0008545780 R12:
ffff88021fc17180
[ 4577.672534] R13: 0000000000000000 R14: 0000000000000002 R15:
ffff88021fc16d80
[ 4577.672534] FS:  0000000000000000(0000) GS:ffff88021fc00000(0000)
knlGS:0000000000000000
[ 4577.672534] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 4577.672534] CR2: 0000000002d6a130 CR3: 00000000b9e5e000 CR4:
00000000001406f0
[ 4577.672534] Stack:
[ 4577.672534]  ffff8800ba655200 0000000000000000 ffff88021fc03e88
ffffffff81451fa2
[ 4577.672534]  ffffffff81a50f80 000000000000000a ffff88021fc03e98
ffffffff8145227e
[ 4577.672534]  ffff88021fc03f08 ffffffff810d04b6 ffff88021fc03f08
ffff880002906300
[ 4577.672534] Call Trace:
[ 4577.672534]  <IRQ>
[ 4577.672534]  [<ffffffff81451fa2>] dst_destroy+0x32/0xe0
[ 4577.672534]  [<ffffffff8145227e>] dst_destroy_rcu+0xe/0x20
[ 4577.672534]  [<ffffffff810d04b6>] rcu_process_callbacks+0x226/0x5d0
[ 4577.672534]  [<ffffffff810715f4>] __do_softirq+0xf4/0x290
[ 4577.672534]  [<ffffffff810719fd>] irq_exit+0xad/0xc0
[ 4577.672534]  [<ffffffff815528da>] smp_apic_timer_interrupt+0x4a/0x60
[ 4577.672534]  [<ffffffff8155095e>] apic_timer_interrupt+0x6e/0x80
[ 4577.672534]  <EOI>
[ 4577.672534]  [<ffffffff81059bd6>] ? native_safe_halt+0x6/0x10
[ 4577.672534]  [<ffffffff8101f17e>] default_idle+0x1e/0xc0
[ 4577.672534]  [<ffffffff8101fc5f>] arch_cpu_idle+0xf/0x20
[ 4577.672534]  [<ffffffff810b0ab4>] cpu_startup_entry+0x314/0x3e0
[ 4577.672534]  [<ffffffff8153bbec>] rest_init+0x7c/0x80
[ 4577.672534]  [<ffffffff81b130e0>] start_kernel+0x483/0x490
[ 4577.672534]  [<ffffffff81b12a4d>] ? set_init_arg+0x55/0x55
[ 4577.672534]  [<ffffffff81b12120>] ? early_idt_handler_array+0x120/0x120
[ 4577.672534]  [<ffffffff81b125ee>] x86_64_start_reservations+0x2a/0x2c
[ 4577.672534]  [<ffffffff81b12728>] x86_64_start_kernel+0x138/0x147
[ 4577.672534] Code: 39 87 b0 00 00 00 48 89 fb 74 4e 4c 8b a7 c0 00 00 00
4c 89 e7 e8 52 e1 0c 00 48 8b 83 b8 00 00 00 48 8b 93 b0 00 00 00 4c 89 e7
<48> 89 42 08 48 89 10 48 b8 00 01 10 00 00 00 ad de 48 89 83 b0
[ 4577.672534] RIP  [<ffffffff8148177f>] ipv4_dst_destroy+0x3f/0x80
[ 4577.672534]  RSP <ffff88021fc03e58>
[ 4577.711597] ---[ end trace e70e62d7a8434649 ]---
[ 4577.712768] Kernel panic - not syncing: Fatal exception in interrupt
[ 4577.713761] Kernel Offset: disabled
[ 4577.713761] Rebooting in 60 seconds..
[ 4577.713761] ACPI MEMORY or I/O RESET_REG.
