From: Stephen Warren <swarren@wwwdotorg.org>
Subject: 1f324e3 ipv6: Don't depend on per socket memory for neighbour discovery
 messages
Date: Fri, 30 Aug 2013 13:46:25 -0600
Message-ID: <5220F691.4020808@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 1f324e3 "ipv6: Don't depend on per socket memory for neighbour
discovery messages" appears to cause issues for me. If I run
next-20130830, I see the issue, but if I then just revert that one
patch, I don't see any problem, and can use the network without issue.

The problem is: with a network device enabled (in my case, a USB
Ethernet dongle, although I don't know if the type is relevant), then
the system appears to hang soon after enabling the interface; neither
the serial console nor the framebuffer echo my typing, and the cursor on
the framebuffer stops flashing. After a short delay, I see the following
kernel spew:

> localhost login: [   14.390206] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [   14.409459] asix 1-1:1.0 eth0: link up, 100Mbps, full-duplex, lpa 0x41E1
> [   43.172240] INFO: rcu_preempt self-detected stall on CPU
> [   43.172256] INFO: rcu_preempt self-detected stall on CPU { 0}  (t=2100 jiffies g=262 c=261 q=1)
> [   43.172265] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.11.0-rc7-next-20130830-00020-gf47ee2e #152
> [   43.172305] [<c00165bc>] (unwind_backtrace+0x0/0x138) from [<c00122cc>] (show_stack+0x10/0x14)
> [   43.172329] [<c00122cc>] (show_stack+0x10/0x14) from [<c0569af8>] (dump_stack+0x80/0xc4)
> [   43.172350] [<c0569af8>] (dump_stack+0x80/0xc4) from [<c008997c>] (rcu_check_callbacks+0x35c/0x818)
> [   43.172367] [<c008997c>] (rcu_check_callbacks+0x35c/0x818) from [<c002fc20>] (update_process_times+0x38/0x64)
> [   43.172378] [<c002fc20>] (update_process_times+0x38/0x64) from [<c006bcc4>] (tick_sched_timer+0x44/0x74)
> [   43.172397] [<c006bcc4>] (tick_sched_timer+0x44/0x74) from [<c0042978>] (__run_hrtimer.isra.15+0x58/0x114)
> [   43.172409] [<c0042978>] (__run_hrtimer.isra.15+0x58/0x114) from [<c00432d0>] (hrtimer_interrupt+0x108/0x2c4)
> [   43.172420] [<c00432d0>] (hrtimer_interrupt+0x108/0x2c4) from [<c0015934>] (twd_handler+0x2c/0x40)
> [   43.172429] [<c0015934>] (twd_handler+0x2c/0x40) from [<c0084488>] (handle_percpu_devid_irq+0x68/0x84)
> [   43.172447] [<c0084488>] (handle_percpu_devid_irq+0x68/0x84) from [<c0080db8>] (generic_handle_irq+0x20/0x30)
> [   43.172460] [<c0080db8>] (generic_handle_irq+0x20/0x30) from [<c000f914>] (handle_IRQ+0x38/0x94)
> [   43.172470] [<c000f914>] (handle_IRQ+0x38/0x94) from [<c00086d8>] (gic_handle_irq+0x28/0x5c)
> [   43.172481] [<c00086d8>] (gic_handle_irq+0x28/0x5c) from [<c0012de0>] (__irq_svc+0x40/0x70)
> [   43.172485] Exception stack(0xc07c5d20 to 0xc07c5d68)
> [   43.172492] 5d20: eeb070c8 ee465838 00000303 80000001 eeb070c8 00000000 ee465828 eeb070c8
> [   43.172500] 5d40: ee465838 00000001 eeb07000 eeb7b480 ee465820 c07c5d68 c056fe34 c056fe5c
> [   43.172503] 5d60: 80000113 ffffffff
> [   43.172518] [<c0012de0>] (__irq_svc+0x40/0x70) from [<c056fe5c>] (_raw_read_lock_bh+0x34/0x44)
> [   43.172539] [<c056fe5c>] (_raw_read_lock_bh+0x34/0x44) from [<c04aa2f4>] (ipv6_chk_mcast_addr+0x2c/0x1b0)
> [   43.172555] [<c04aa2f4>] (ipv6_chk_mcast_addr+0x2c/0x1b0) from [<c048b130>] (ip6_finish_output2+0x240/0x4fc)
> [   43.172566] [<c048b130>] (ip6_finish_output2+0x240/0x4fc) from [<c049d724>] (ndisc_send_skb+0x1c8/0x2d8)
> [   43.172578] [<c049d724>] (ndisc_send_skb+0x1c8/0x2d8) from [<c0490f68>] (addrconf_rs_timer+0x108/0x134)
> [   43.172589] [<c0490f68>] (addrconf_rs_timer+0x108/0x134) from [<c002f0d4>] (call_timer_fn.isra.20+0x24/0x84)
> [   43.172598] [<c002f0d4>] (call_timer_fn.isra.20+0x24/0x84) from [<c002f2c8>] (run_timer_softirq+0x194/0x244)
> [   43.172616] [<c002f2c8>] (run_timer_softirq+0x194/0x244) from [<c0029818>] (__do_softirq+0xe8/0x1d0)
> [   43.172627] [<c0029818>] (__do_softirq+0xe8/0x1d0) from [<c0029c38>] (irq_exit+0x98/0xe4)
> [   43.172637] [<c0029c38>] (irq_exit+0x98/0xe4) from [<c000f918>] (handle_IRQ+0x3c/0x94)
> [   43.172646] [<c000f918>] (handle_IRQ+0x3c/0x94) from [<c00086d8>] (gic_handle_irq+0x28/0x5c)
> [   43.172655] [<c00086d8>] (gic_handle_irq+0x28/0x5c) from [<c0012de0>] (__irq_svc+0x40/0x70)
> [   43.172658] Exception stack(0xc07c5f28 to 0xc07c5f70)
> [   43.172664] 5f20:                   c07c5f70 3b9aca00 b665e400 00000004 b63d5530 00000004
> [   43.172671] 5f40: c10880e0 00000000 00000000 c07cc3d4 c0573354 00000000 00000015 c07c5f70
> [   43.172676] 5f60: c0063658 c038edac 60000113 ffffffff
> [   43.172696] [<c0012de0>] (__irq_svc+0x40/0x70) from [<c038edac>] (cpuidle_enter_state+0x50/0xe8)
> [   43.172709] [<c038edac>] (cpuidle_enter_state+0x50/0xe8) from [<c038eefc>] (cpuidle_idle_call+0xb8/0x168)
> [   43.172719] [<c038eefc>] (cpuidle_idle_call+0xb8/0x168) from [<c000fc60>] (arch_cpu_idle+0x8/0x38)
> [   43.172730] [<c000fc60>] (arch_cpu_idle+0x8/0x38) from [<c0062924>] (cpu_startup_entry+0x60/0x134)
> [   43.172750] [<c0062924>] (cpu_startup_entry+0x60/0x134) from [<c0789a28>] (start_kernel+0x2b8/0x30c)
> [   43.765722]  { 1}  (t=2159 jiffies g=262 c=261 q=1)
> [   43.778002] CPU: 1 PID: 539 Comm: NetworkManager Not tainted 3.11.0-rc7-next-20130830-00020-gf47ee2e #152
> [   43.795156] [<c00165bc>] (unwind_backtrace+0x0/0x138) from [<c00122cc>] (show_stack+0x10/0x14)
> [   43.811442] [<c00122cc>] (show_stack+0x10/0x14) from [<c0569af8>] (dump_stack+0x80/0xc4)
> [   43.827204] [<c0569af8>] (dump_stack+0x80/0xc4) from [<c008997c>] (rcu_check_callbacks+0x35c/0x818)
> [   43.843896] [<c008997c>] (rcu_check_callbacks+0x35c/0x818) from [<c002fc20>] (update_process_times+0x38/0x64)
> [   43.861541] [<c002fc20>] (update_process_times+0x38/0x64) from [<c006bcc4>] (tick_sched_timer+0x44/0x74)
> [   43.878779] [<c006bcc4>] (tick_sched_timer+0x44/0x74) from [<c0042978>] (__run_hrtimer.isra.15+0x58/0x114)
> [   43.896302] [<c0042978>] (__run_hrtimer.isra.15+0x58/0x114) from [<c00432d0>] (hrtimer_interrupt+0x108/0x2c4)
> [   43.914085] [<c00432d0>] (hrtimer_interrupt+0x108/0x2c4) from [<c0015934>] (twd_handler+0x2c/0x40)
> [   43.930903] [<c0015934>] (twd_handler+0x2c/0x40) from [<c0084488>] (handle_percpu_devid_irq+0x68/0x84)
> [   43.948107] [<c0084488>] (handle_percpu_devid_irq+0x68/0x84) from [<c0080db8>] (generic_handle_irq+0x20/0x30)
> [   43.966008] [<c0080db8>] (generic_handle_irq+0x20/0x30) from [<c000f914>] (handle_IRQ+0x38/0x94)
> [   43.982745] [<c000f914>] (handle_IRQ+0x38/0x94) from [<c00086d8>] (gic_handle_irq+0x28/0x5c)
> [   43.999123] [<c00086d8>] (gic_handle_irq+0x28/0x5c) from [<c0012de0>] (__irq_svc+0x40/0x70)
> [   44.015380] Exception stack(0xedc35be8 to 0xedc35c30)
> [   44.028267] 5be0:                   eeb070c8 00000000 00000201 80000001 eeb070c8 eeb070c8
> [   44.044329] 5c00: eeb07000 eeb071b4 ee4336c0 00000000 edc80a38 00000000 edc80b90 edc35c30
> [   44.060321] 5c20: c056fe34 c056fe5c 800f0013 ffffffff
> [   44.073089] [<c0012de0>] (__irq_svc+0x40/0x70) from [<c056fe5c>] (_raw_read_lock_bh+0x34/0x44)
> [   44.089495] [<c056fe5c>] (_raw_read_lock_bh+0x34/0x44) from [<c049037c>] (inet6_fill_ifla6_attrs+0x300/0x358)
> [   44.107263] [<c049037c>] (inet6_fill_ifla6_attrs+0x300/0x358) from [<c0490578>] (inet6_fill_ifinfo+0x178/0x1a0)
> [   44.125244] [<c0490578>] (inet6_fill_ifinfo+0x178/0x1a0) from [<c0490628>] (inet6_dump_ifinfo+0x88/0xe0)
> [   44.142605] [<c0490628>] (inet6_dump_ifinfo+0x88/0xe0) from [<c042f318>] (netlink_dump+0xa0/0x1d8)
> [   44.159411] [<c042f318>] (netlink_dump+0xa0/0x1d8) from [<c04300b4>] (__netlink_dump_start+0x100/0x158)
> [   44.176711] [<c04300b4>] (__netlink_dump_start+0x100/0x158) from [<c0425b90>] (rtnetlink_rcv_msg+0x110/0x1f4)
> [   44.194593] [<c0425b90>] (rtnetlink_rcv_msg+0x110/0x1f4) from [<c04318c4>] (netlink_rcv_skb+0xac/0xc0)
> [   44.211854] [<c04318c4>] (netlink_rcv_skb+0xac/0xc0) from [<c04248b8>] (rtnetlink_rcv+0x1c/0x24)
> [   44.228576] [<c04248b8>] (rtnetlink_rcv+0x1c/0x24) from [<c04312bc>] (netlink_unicast+0x158/0x1b8)
> [   44.245451] [<c04312bc>] (netlink_unicast+0x158/0x1b8) from [<c0431668>] (netlink_sendmsg+0x2ac/0x360)
> [   44.262719] [<c0431668>] (netlink_sendmsg+0x2ac/0x360) from [<c04018b4>] (sock_sendmsg+0x88/0xa8)
> [   44.279477] [<c04018b4>] (sock_sendmsg+0x88/0xa8) from [<c0401c7c>] (___sys_sendmsg+0x2a8/0x2c0)
> [   44.296134] [<c0401c7c>] (___sys_sendmsg+0x2a8/0x2c0) from [<c0403840>] (__sys_sendmsg+0x3c/0x68)
> [   44.312870] [<c0403840>] (__sys_sendmsg+0x3c/0x68) from [<c000f060>] (ret_fast_syscall+0x0/0x30)

This repeats every minute.
