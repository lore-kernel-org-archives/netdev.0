From: Dmitry Vyukov <dvyukov@google.com>
Subject: Use-after-free in selinux_ip_postroute_compat
Date: Thu, 5 Nov 2015 20:36:30 +0100
Message-ID: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Eric Dumazet <edumazet@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've updated from bcee19f424a0d8c26ecf2607b73c690802658b29 (Sep 21) to
8e483ed1342a4ea45b70f0f33ac54eff7a33d918 (Nov 4) and start seeing the
following use-after-free reports:


BUG: KASan: use after free in selinux_ip_postroute_compat+0x2af/0x2d0
at addr ffff88003dbdc148
Read of size 8 by task swapper/1/0
=============================================================================
BUG kmalloc-512 (Tainted: G    B          ): kasan: bad access detected
-----------------------------------------------------------------------------
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G    B           4.3.0+ #29
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88003ed06970 ffffffff81aab806 ffff88003e804b40
 ffff88003dbdc000 ffff88003dbdc000 ffff88003ed069a0 ffffffff814a4b34
 ffff88003e804b40 ffffea0000f6f700 ffff88003dbdc000 ffff88003ed06bd0
Call Trace:
 <IRQ>  [<     inline     >] __dump_stack lib/dump_stack.c:15
 <IRQ>  [<ffffffff81aab806>] dump_stack+0x68/0x92 lib/dump_stack.c:50
 [<ffffffff814a4b34>] print_trailer+0xf4/0x150 mm/slub.c:650
 [<ffffffff814aa44f>] object_err+0x2f/0x40 mm/slub.c:657
 [<     inline     >] print_address_description mm/kasan/report.c:120
 [<ffffffff814ac976>] kasan_report_error+0x1d6/0x3c0 mm/kasan/report.c:193
 [<     inline     >] kasan_report mm/kasan/report.c:230
 [<ffffffff814acc5e>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:251
 [<ffffffff819614cf>] selinux_ip_postroute_compat+0x2af/0x2d0
security/selinux/hooks.c:4947
 [<ffffffff819619af>] selinux_ip_postroute+0x4bf/0xb70
security/selinux/hooks.c:4986
 [<ffffffff819620ee>] selinux_ipv4_postroute+0x3e/0x50
security/selinux/hooks.c:5110
 [<ffffffff8287918d>] nf_iterate+0x15d/0x250 net/netfilter/core.c:274
 [<ffffffff82879421>] nf_hook_slow+0x1a1/0x300 net/netfilter/core.c:306
 [<     inline     >] nf_hook_thresh include/linux/netfilter.h:187
 [<     inline     >] NF_HOOK_COND include/linux/netfilter.h:238
 [<ffffffff829072c5>] ip_output+0x2b5/0x460 net/ipv4/ip_output.c:358
 [<     inline     >] dst_output include/net/dst.h:459
 [<ffffffff82904528>] ip_local_out+0xd8/0x1c0 net/ipv4/ip_output.c:116
 [<ffffffff82904bb6>] ip_build_and_send_pkt+0x5a6/0xa40 net/ipv4/ip_output.c:171
 [<ffffffff8299183d>] tcp_v4_send_synack+0x18d/0x270 net/ipv4/tcp_ipv4.c:841
 [<ffffffff8294beeb>] tcp_conn_request+0x1f3b/0x2750 net/ipv4/tcp_input.c:6273
 [<ffffffff8298b4be>] tcp_v4_conn_request+0x17e/0x240 net/ipv4/tcp_ipv4.c:1234
 [<ffffffff8296012e>] tcp_rcv_state_process+0x6ae/0x4130
net/ipv4/tcp_input.c:5750
 [<ffffffff8298f7db>] tcp_v4_do_rcv+0x2fb/0x9f0 net/ipv4/tcp_ipv4.c:1405
 [<ffffffff82994952>] tcp_v4_rcv+0x2872/0x2f80 net/ipv4/tcp_ipv4.c:1630
 [<ffffffff828eb0c9>] ip_local_deliver_finish+0x2a9/0xa30
net/ipv4/ip_input.c:216
 [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
 [<     inline     >] NF_HOOK include/linux/netfilter.h:249
 [<ffffffff828ed124>] ip_local_deliver+0x1c4/0x2f0 net/ipv4/ip_input.c:257
 [<     inline     >] dst_input include/net/dst.h:465
 [<ffffffff828ebe64>] ip_rcv_finish+0x614/0x11d0 net/ipv4/ip_input.c:365
 [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
 [<     inline     >] NF_HOOK include/linux/netfilter.h:249
 [<ffffffff828edcc6>] ip_rcv+0xa76/0x1470 net/ipv4/ip_input.c:455
 [<ffffffff827c50d9>] __netif_receive_skb_core+0x1cb9/0x38e0 net/core/dev.c:3940
 [<ffffffff827c6d2a>] __netif_receive_skb+0x2a/0x160 net/core/dev.c:3975
 [<ffffffff827c9405>] netif_receive_skb_internal+0xe5/0x360 net/core/dev.c:4003
 [<     inline     >] napi_skb_finish net/core/dev.c:4328
 [<ffffffff827cd9d0>] napi_gro_receive+0x1c0/0x260 net/core/dev.c:4357
 [<     inline     >] e1000_receive_skb
drivers/net/ethernet/intel/e1000/e1000_main.c:4007
 [<ffffffff8232012c>] e1000_clean_rx_irq+0x4ec/0x10c0
drivers/net/ethernet/intel/e1000/e1000_main.c:4459
 [<ffffffff8231dd46>] e1000_clean+0xa56/0x2520
drivers/net/ethernet/intel/e1000/e1000_main.c:3814
 [<     inline     >] napi_poll net/core/dev.c:4793
 [<ffffffff827ca73d>] net_rx_action+0x74d/0xc70 net/core/dev.c:4858
 [<ffffffff8110fdae>] __do_softirq+0x2ae/0x710 kernel/softirq.c:273
 [<     inline     >] invoke_softirq kernel/softirq.c:350
 [<ffffffff811104ad>] irq_exit+0x15d/0x190 kernel/softirq.c:391
 [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:653
 [<ffffffff81013256>] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
 [<ffffffff82f23387>] common_interrupt+0x87/0x87 arch/x86/entry/entry_64.S:545
 <EOI>  [<ffffffff810d0706>] ? native_safe_halt+0x6/0x10
./arch/x86/include/asm/irqflags.h:49
 [<     inline     >] arch_safe_halt ./arch/x86/include/asm/paravirt.h:111
 [<ffffffff81026e42>] default_idle+0x22/0x1e0 arch/x86/kernel/process.c:304
 [<ffffffff81027f7a>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:295
 [<ffffffff811d9b98>] default_idle_call+0x48/0x70 kernel/sched/idle.c:92
 [<     inline     >] cpuidle_idle_call kernel/sched/idle.c:156
 [<     inline     >] cpu_idle_loop kernel/sched/idle.c:251
 [<ffffffff811da0bd>] cpu_startup_entry+0x41d/0x570 kernel/sched/idle.c:299
 [<ffffffff810ac8b3>] start_secondary+0x243/0x2d0 arch/x86/kernel/smpboot.c:251

INFO: Allocated in __alloc_skb+0xf0/0x5f0 age=20059 cpu=1 pid=1248
[<      none      >] __slab_alloc+0x23a/0x560 mm/slub.c:2402
[<     inline     >] slab_alloc_node mm/slub.c:2470
[<      none      >] __kmalloc_node_track_caller+0xa4/0x230 mm/slub.c:3956
[<      none      >] __kmalloc_reserve.isra.33+0x41/0xe0 net/core/skbuff.c:135
[<      none      >] __alloc_skb+0xf0/0x5f0 net/core/skbuff.c:228
[<     inline     >] alloc_skb include/linux/skbuff.h:814
[<      none      >] kobject_uevent_env+0x5b0/0xbc0 lib/kobject_uevent.c:300
[<      none      >] kobject_uevent+0x1f/0x30 lib/kobject_uevent.c:374
[<      none      >] uevent_store+0xc9/0xd0 drivers/base/bus.c:655
[<      none      >] dev_attr_store+0x5c/0x90 drivers/base/core.c:137
[<      none      >] sysfs_kf_write+0x121/0x180 fs/sysfs/file.c:133
[<      none      >] kernfs_fop_write+0x2b0/0x3f0 fs/kernfs/file.c:312
[<      none      >] __vfs_write+0x10e/0x3d0 fs/read_write.c:489
[<      none      >] vfs_write+0x16e/0x490 fs/read_write.c:538
[<     inline     >] SYSC_write fs/read_write.c:585
[<      none      >] SyS_write+0x111/0x220 fs/read_write.c:577
[<      none      >] entry_SYSCALL_64_fastpath+0x31/0x9a
arch/x86/entry/entry_64.S:187

INFO: Freed in skb_release_data+0x300/0x3c0 age=19765 cpu=2 pid=1219
[<      none      >] __slab_free+0x1ec/0x350 mm/slub.c:2587 (discriminator 1)
[<     inline     >] slab_free mm/slub.c:2736
[<      none      >] kfree+0x1ab/0x1c0 mm/slub.c:3522
[<     inline     >] skb_free_head net/core/skbuff.c:569
[<      none      >] skb_release_data+0x300/0x3c0 net/core/skbuff.c:600
[<      none      >] skb_release_all+0x4a/0x60 net/core/skbuff.c:659
[<     inline     >] __kfree_skb net/core/skbuff.c:673
[<      none      >] consume_skb+0xb1/0x1e0 net/core/skbuff.c:746
[<      none      >] skb_free_datagram+0x1a/0xe0 net/core/datagram.c:280
[<      none      >] netlink_recvmsg+0x536/0xd20 net/netlink/af_netlink.c:2590
[<     inline     >] sock_recvmsg_nosec net/socket.c:712
[<      none      >] sock_recvmsg+0x9d/0xb0 net/socket.c:720
[<      none      >] ___sys_recvmsg+0x259/0x540 net/socket.c:2104
[<      none      >] __sys_recvmsg+0xce/0x170 net/socket.c:2150
[<     inline     >] SYSC_recvmsg net/socket.c:2162
[<      none      >] SyS_recvmsg+0x2d/0x50 net/socket.c:2157
[<      none      >] entry_SYSCALL_64_fastpath+0x31/0x9a
arch/x86/entry/entry_64.S:187
INFO: Slab 0xffffea0000f6f700 objects=19 used=0 fp=0xffff88003dbdf0c0
flags=0x100000000004080
INFO: Object 0xffff88003dbdc000 @offset=0 fp=0xffff88003dbdc340
