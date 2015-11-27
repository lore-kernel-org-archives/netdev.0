From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: Use after free in dst_release on boot
Date: Fri, 27 Nov 2015 15:48:08 -0500
Message-ID: <5658C188.4050708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
	kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've observed the following use-after-free on boot with the latest -next. It seems to
reproduce once in a while, doesn't seem to be deterministic.

[  112.353948] Sending DHCP requests .

[  115.375304] IP-Config: Got DHCP answer from 192.168.33.1, my address is 192.168.33.15

[  117.056357] ==================================================================

[  117.057618] BUG: KASAN: use-after-free in dst_release+0x9a/0xc0 at addr ffff8806cf7c7560

[  117.058566] Read of size 2 by task swapper/0/1

[  117.059192] =============================================================================

[  117.059939] BUG ip6_dst_cache (Not tainted): kasan: bad access detected

[  117.060965] -----------------------------------------------------------------------------

[  117.060965]

[  117.062445] Disabling lock debugging due to kernel taint

[  117.063230] INFO: Allocated in dst_alloc+0x88/0x190 age=4846 cpu=1 pid=1

[  117.064287] 	___slab_alloc+0x434/0x5b0

[  117.064878] 	__slab_alloc.isra.37+0x79/0xd0

[  117.065539] 	kmem_cache_alloc+0xf3/0x330

[  117.066123] 	dst_alloc+0x88/0x190

[  117.066667] 	__ip6_dst_alloc+0x36/0x120

[  117.067258] 	ip6_dst_alloc+0x32/0x290

[  117.067810] 	addrconf_dst_alloc+0xa8/0x510

[  117.068335] 	ipv6_add_addr+0x47c/0xe30

[  117.068924] 	addrconf_add_linklocal+0x14f/0x200

[  117.069631] 	addrconf_addr_gen+0x1c9/0x260

[  117.070190] 	addrconf_notify+0x1365/0x19a0

[  117.070669] 	notifier_call_chain+0x10f/0x190

[  117.071107] 	raw_notifier_call_chain+0x32/0x40

[  117.071623] 	call_netdevice_notifiers_info+0x80/0x90

[  117.072146] 	__dev_notify_flags+0x154/0x250

[  117.072562] 	dev_change_flags+0x110/0x130

[  117.072956] INFO: Freed in dst_destroy+0x268/0x300 age=14 cpu=2 pid=22

[  117.073620] 	__slab_free+0x5c/0x2b0

[  117.073946] 	kmem_cache_free+0x1e1/0x3a0

[  117.074522] 	dst_destroy+0x268/0x300

[  117.074937] 	dst_rcu_free+0x91/0xb0

[  117.075281] 	rcu_do_batch.isra.16+0x78d/0x11c0

[  117.075720] 	rcu_cpu_kthread+0x400/0x5b0

[  117.076122] 	smpboot_thread_fn+0x8e5/0x930

[  117.076661] 	kthread+0x290/0x2b0

[  117.077173] 	ret_from_fork+0x3f/0x70

[  117.077658] INFO: Slab 0xffffea001b3df000 objects=42 used=4 fp=0xffff8806cf7c7500 flags=0x2fffff80004080

[  117.079007] INFO: Object 0xffff8806cf7c7500 @offset=29952 fp=0xffff8806cf7c0600

[  117.079007]

[  117.080132] Bytes b4 ffff8806cf7c74f0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

[  117.081049] Object ffff8806cf7c7500: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.082272] Object ffff8806cf7c7510: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.083701] Object ffff8806cf7c7520: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.084584] Object ffff8806cf7c7530: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.085407] Object ffff8806cf7c7540: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.086302] Object ffff8806cf7c7550: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.087222] Object ffff8806cf7c7560: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.088319] Object ffff8806cf7c7570: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.089415] Object ffff8806cf7c7580: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.090656] Object ffff8806cf7c7590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.091924] Object ffff8806cf7c75a0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.093187] Object ffff8806cf7c75b0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.094495] Object ffff8806cf7c75c0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.095848] Object ffff8806cf7c75d0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.096969] Object ffff8806cf7c75e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.097873] Object ffff8806cf7c75f0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.098947] Object ffff8806cf7c7600: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.105064] Object ffff8806cf7c7610: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.114118] Object ffff8806cf7c7620: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.115562] Object ffff8806cf7c7630: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.116985] Object ffff8806cf7c7640: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.118314] Object ffff8806cf7c7650: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.119926] Object ffff8806cf7c7660: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk

[  117.121106] Object ffff8806cf7c7670: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.

[  117.122043] Redzone ffff8806cf7c7680: bb bb bb bb bb bb bb bb                          ........

[  117.123256] Padding ffff8806cf7c77c0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

[  117.124652] Padding ffff8806cf7c77d0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

[  117.126039] Padding ffff8806cf7c77e0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

[  117.127447] Padding ffff8806cf7c77f0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ

[  117.128860] CPU: 2 PID: 1 Comm: swapper/0 Tainted: G    B           4.4.0-rc2-next-20151126-sasha-00005-g00d303e-dirty #2654

[  117.130536]  0000000000000002 00000000d71d8911 ffff8806e42f76c0 ffffffff9be6b5bb

[  117.131733]  ffff8806e573a700 ffff8806cf7c7500 ffff8806cf7c0000 ffff8806e42f76f0

[  117.132917]  ffffffff9a7a3aba ffff8806e573a700 ffffea001b3df000 ffff8806cf7c7500

[  117.134096] Call Trace:

[  117.134510] dump_stack (lib/dump_stack.c:52)
[  117.135305] print_trailer (mm/slub.c:655)
[  117.136109] object_err (mm/slub.c:662)
[  117.136887] kasan_report_error (mm/kasan/report.c:138 mm/kasan/report.c:236)
[  117.137791] ? retint_kernel (arch/x86/entry/entry_64.S:590)
[  117.138630] __asan_report_load2_noabort (mm/kasan/report.c:278)
[  117.139631] ? __dst_free (net/core/dst.c:245)
[  117.140457] ? dst_release (net/core/dst.c:309 (discriminator 1))
[  117.141272] dst_release (net/core/dst.c:309 (discriminator 1))
[  117.142067] inet6_ifa_finish_destroy (net/ipv6/addrconf.c:862)
[  117.143059] addrconf_ifdown (include/net/addrconf.h:317 net/ipv6/addrconf.c:3410)
[  117.143929] addrconf_notify (net/ipv6/addrconf.c:3271)
[  117.144822] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  117.145806] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2614 (discriminator 22))
[  117.146822] ? fib6_run_gc (include/linux/spinlock.h:352 net/ipv6/ip6_fib.c:1805)
[  117.147679] ? trace_hardirqs_on (kernel/locking/lockdep.c:2620)
[  117.148582] ? __local_bh_enable_ip (./arch/x86/include/asm/paravirt.h:807 kernel/softirq.c:175)
[  117.149535] ? inet6_ifinfo_notify (net/ipv6/addrconf.c:3136)
[  117.150484] ? _raw_spin_unlock_bh (kernel/locking/spinlock.c:208)
[  117.151410] ? fib6_run_gc (net/ipv6/ip6_fib.c:1806)
[  117.152245] notifier_call_chain (kernel/notifier.c:95)
[  117.153158] raw_notifier_call_chain (kernel/notifier.c:402)
[  117.154094] call_netdevice_notifiers_info (net/core/dev.c:1643)
[  117.155119] __dev_notify_flags (net/core/dev.c:1658 net/core/dev.c:6035)
[  117.156025] ? dev_change_name (net/core/dev.c:6025)
[  117.156914] ? dev_close (drivers/media/usb/gspca/gspca.c:1305)
[  117.157729] ? _raw_spin_unlock_bh (kernel/locking/spinlock.c:208)
[  117.158653] ? dev_close (drivers/media/usb/gspca/gspca.c:1305)
[  117.159480] ? __dev_change_flags (net/core/dev.c:6021)
[  117.160415] dev_change_flags (net/core/dev.c:6066)
[  117.161307] ic_close_devs (net/ipv4/ipconfig.c:308)
[  117.162150] ip_auto_config (net/ipv4/ipconfig.c:368 net/ipv4/ipconfig.c:1502)
[  117.163047] ? root_nfs_parse_addr (net/ipv4/ipconfig.c:1398)
[  117.163984] ? __debug_object_init (lib/debugobjects.c:667)
[  117.164924] ? check_preemption_disabled (lib/smp_processor_id.c:52)
[  117.165934] ? root_nfs_parse_addr (net/ipv4/ipconfig.c:1398)
[  117.166890] do_one_initcall (init/main.c:794)
[  117.167755] ? do_one_initcall (init/main.c:794)
[  117.168648] ? try_to_run_init_process (init/main.c:783)
[  117.169623] ? parse_args (kernel/params.c:269)
[  117.170469] kernel_init_freeable (init/main.c:859 init/main.c:867 init/main.c:885 init/main.c:1008)
[  117.171415] ? start_kernel (init/main.c:978)
[  117.172269] ? mark_held_locks (kernel/locking/lockdep.c:2541)
[  117.173160] ? _raw_spin_unlock_irq (kernel/locking/spinlock.c:200)
[  117.174092] ? finish_task_switch (./arch/x86/include/asm/current.h:14 kernel/sched/core.c:2567)
[  117.175028] ? finish_task_switch (kernel/sched/sched.h:1082 kernel/sched/core.c:2564)
[  117.175959] ? rest_init (init/main.c:933)
[  117.176763] kernel_init (init/main.c:938)
[  117.177561] ? rest_init (init/main.c:933)
[  117.178378] ret_from_fork (arch/x86/entry/entry_64.S:472)
[  117.179154] ? rest_init (init/main.c:933)
[  117.179991] Memory state around the buggy address:

[  117.180724]  ffff8806cf7c7400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[  117.181728]  ffff8806cf7c7480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[  117.182448] >ffff8806cf7c7500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[  117.183246]                                                        ^

[  117.183852]  ffff8806cf7c7580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[  117.184553]  ffff8806cf7c7600: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[  117.185276] ==================================================================

[  117.530380] IP-Config: Complete:

[  117.534895]      device=eth0, hwaddr=02:15:15:15:15:15, ipaddr=192.168.33.15, mask=255.255.255.0, gw=192.168.33.1

[  117.537142]      host=192.168.33.15, domain=, nis-domain=(none)

[  117.538412]      bootserver=192.168.33.1, rootserver=0.0.0.0, rootpath=     nameserver0=144.20.190.70


Thanks,
Sasha
