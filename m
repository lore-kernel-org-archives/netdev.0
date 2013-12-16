From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [BUG] New lockdep trace: v3.13-rc4
Date: Mon, 16 Dec 2013 00:07:14 +0000
Message-ID: <20131216000714.GN4360@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just booted 3.13-rc4 on one of my ARM platforms and was greeted by this
trace.  Maybe caused by 975022310233 which appears to take this lock in
softirq context.

=================================
[ INFO: inconsistent lock state ]
3.13.0-rc4+ #387 Not tainted
---------------------------------
inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
 (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<c056f544>] __udp4_lib_rcv+0x91c/0x980
{SOFTIRQ-ON-W} state was registered at:
  [<c0063034>] mark_lock+0x15c/0x704
  [<c0063c78>] __lock_acquire+0x69c/0x1e14
  [<c00659bc>] lock_acquire+0xa4/0x114
  [<c0688488>] _raw_spin_lock+0x34/0x44
  [<c0578f3c>] inet_bind+0x1ac/0x20c
  [<c0502548>] SyS_bind+0x6c/0x94
  [<c000e980>] ret_fast_syscall+0x0/0x48
irq event stamp: 423350
hardirqs last  enabled at (423350): [<c050a8a8>] __netdev_alloc_frag+0x118/0x14c
hardirqs last disabled at (423349): [<c050a7b4>] __netdev_alloc_frag+0x24/0x14c
softirqs last  enabled at (423342): [<c0028f74>] _local_bh_enable+0x2c/0x60
softirqs last disabled at (423343): [<c0029678>] irq_exit+0xc0/0x110

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(&(&sk->sk_dst_lock)->rlock);
  <Interrupt>
    lock(&(&sk->sk_dst_lock)->rlock);

 *** DEADLOCK ***

2 locks held by swapper/0/0:
 #0:  (rcu_read_lock){.+.+..}, at: [<c0513404>] __netif_receive_skb_core+0x3c/0x5f0
 #1:  (rcu_read_lock){.+.+..}, at: [<c053f9fc>] ip_local_deliver_finish+0x3c/0x428

stack backtrace:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-rc4+ #387
Backtrace: 
[<c0012640>] (dump_backtrace) from [<c00127dc>] (show_stack+0x18/0x1c)
 r6:c0a7d150 r5:c0959c30 r4:00000000 r3:00000000
[<c00127c4>] (show_stack) from [<c0683a18>] (dump_stack+0x70/0x90)
[<c06839a8>] (dump_stack) from [<c0062dd4>] (print_usage_bug+0x1dc/0x2e0)
 r4:c0a7d150 r3:c0959c30
[<c0062bf8>] (print_usage_bug) from [<c006335c>] (mark_lock+0x484/0x704)
 r10:00000006 r9:c0062208 r8:c0959c30 r7:00001054 r6:c0a7d150 r5:c095a000
 r4:00000004
[<c0062ed8>] (mark_lock) from [<c0063b90>] (__lock_acquire+0x5b4/0x1e14)
 r10:da82c134 r9:00000004 r8:000002b3 r7:00000002 r6:c0e9fbbc r5:c0959c30
 r4:00000002
[<c00635dc>] (__lock_acquire) from [<c00659bc>] (lock_acquire+0xa4/0x114)
 r10:00000000 r9:00000002 r8:00000000 r7:00000000 r6:da82c134 r5:c094e000
 r4:00000000
[<c0065918>] (lock_acquire) from [<c0688488>] (_raw_spin_lock+0x34/0x44)
 r10:00000199 r9:dab02b00 r8:c095880c r7:da82c000 r6:dbafd6e4 r5:00000002
 r4:da82c124
[<c0688454>] (_raw_spin_lock) from [<c056f544>] (__udp4_lib_rcv+0x91c/0x980)
 r5:da82c124 r4:dab05600
[<c056ec28>] (__udp4_lib_rcv) from [<c056fb3c>] (udp_rcv+0x18/0x20)
 r10:c0999280 r9:db83e000 r8:c053ffbc r7:c0958308 r6:c0999280 r5:c078494c
 r4:dab05600
[<c056fb24>] (udp_rcv) from [<c053fa6c>] (ip_local_deliver_finish+0xac/0x428)
[<c053f9c0>] (ip_local_deliver_finish) from [<c053ffbc>] (ip_local_deliver+0xb8/0xc4)
 r10:c0999280 r9:db83e000 r8:c05136b8 r7:00000050 r6:dab05600 r5:dbafd6d0
 r4:dab05600
[<c053ff04>] (ip_local_deliver) from [<c053f5a4>] (ip_rcv_finish+0x1c8/0x5e4)
 r4:c0540438
[<c053f3dc>] (ip_rcv_finish) from [<c0540438>] (ip_rcv+0x470/0x6ec)
 r10:c0999280 r9:db83e000 r8:c05136b8 r7:00000050 r6:dab05600 r5:dbafd680
 r4:00000050
[<c053ffc8>] (ip_rcv) from [<c05136b8>] (__netif_receive_skb_core+0x2f0/0x5f0)
 r10:dab05600 r9:00000000 r8:00000008 r7:c0957628 r6:db83e000 r5:c095887c
 r4:c0957614
[<c05133c8>] (__netif_receive_skb_core) from [<c05139e4>] (__netif_receive_skb+0x2c/0x88)
 r10:00000001 r9:c0956490 r8:dab05600 r7:00000800 r6:dc040080 r5:c0957620
 r4:dab05600
[<c05139b8>] (__netif_receive_skb) from [<c05158d4>] (netif_receive_skb+0x38/0x118)
 r5:c0957620 r4:dab05600
[<c051589c>] (netif_receive_skb) from [<c05185f4>] (napi_gro_receive+0x7c/0xa8)
 r6:dc040080 r5:00000003 r4:dab05600
[<c0518578>] (napi_gro_receive) from [<c040b0ec>] (fec_enet_rx_napi+0x38c/0x7ac)
 r5:db83e000 r4:db83e600
[<c040ad60>] (fec_enet_rx_napi) from [<c0517894>] (net_rx_action+0xbc/0x1e4)
 r10:c1356440 r9:c09500c0 r8:00000003 r7:0000012c r6:00000040 r5:00000001
 r4:db83e760
[<c05177d8>] (net_rx_action) from [<c00290c4>] (__do_softirq+0x11c/0x2e4)
 r10:0000000c r9:00000100 r8:00000003 r7:f4000100 r6:c094e000 r5:c095008c
 r4:00000001
[<c0028fa8>] (__do_softirq) from [<c0029678>] (irq_exit+0xc0/0x110)
 r10:c09ac810 r9:c09ac810 r8:c0956528 r7:f4000100 r6:00000000 r5:00000096
 r4:c094e000
[<c00295b8>] (irq_exit) from [<c000f298>] (handle_IRQ+0x44/0x98)
 r4:c094b084 r3:00000182
[<c000f254>] (handle_IRQ) from [<c0008548>] (gic_handle_irq+0x30/0x64)
 r6:c094ff00 r5:c0956c70 r4:f400010c r3:000000a0
[<c0008518>] (gic_handle_irq) from [<c00132c4>] (__irq_svc+0x44/0x58)
Exception stack(0xc094ff00 to 0xc094ff48)
ff00: 00000001 00000001 00000000 c0959c30 c094e000 00000001 c06915f8 c1350c40
ff20: c0956528 c09ac810 c09ac810 c094ff54 c094ff18 c094ff48 c006643c c000f668
ff40: 20000113 ffffffff
 r7:c094ff34 r6:ffffffff r5:20000113 r4:c000f668
[<c000f630>] (arch_cpu_idle) from [<c006f404>] (cpu_startup_entry+0xa4/0x200)
[<c006f360>] (cpu_startup_entry) from [<c06819ec>] (rest_init+0xcc/0xdc)
 r10:c0956480 r9:412fc09a r8:c093d2d8 r7:c1350c40 r6:00000002 r5:00000001
 r4:c0960d8c r3:00000000
[<c0681920>] (rest_init) from [<c08e9b1c>] (start_kernel+0x308/0x358)
 r6:c09afcc0 r5:00000001 r4:c0956828
[<c08e9814>] (start_kernel) from [<10008074>] (0x10008074)
