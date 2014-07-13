From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: socket: NULL ptr deref in sendmsg
Date: Sun, 13 Jul 2014 17:50:53 -0400
Message-ID: <53C2FF3D.4030201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>,
	Andrey Ryabinin <a.ryabinin@samsung.com>
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel with the KASAN patchset, I've stumbled on the following spew:

[ 4448.949424] ==================================================================
[ 4448.951737] AddressSanitizer: user-memory-access on address 0
[ 4448.952988] Read of size 2 by thread T19638:
[ 4448.954510] CPU: 28 PID: 19638 Comm: trinity-c76 Not tainted 3.16.0-rc4-next-20140711-sasha-00046-g07d3099-dirty #813
[ 4448.956823]  ffff88046d86ca40 0000000000000000 ffff880082f37e78 ffff880082f37a40
[ 4448.958233]  ffffffffb6e47068 ffff880082f37a68 ffff880082f37a58 ffffffffb242708d
[ 4448.959552]  0000000000000000 ffff880082f37a88 ffffffffb24255b1 0000000000000000
[ 4448.961266] Call Trace:
[ 4448.963158] dump_stack (lib/dump_stack.c:52)
[ 4448.964244] kasan_report_user_access (mm/kasan/report.c:184)
[ 4448.965507] __asan_load2 (mm/kasan/kasan.c:352)
[ 4448.966482] ? netlink_sendmsg (net/netlink/af_netlink.c:2339)
[ 4448.967541] netlink_sendmsg (net/netlink/af_netlink.c:2339)
[ 4448.968537] ? get_parent_ip (kernel/sched/core.c:2555)
[ 4448.970103] sock_sendmsg (net/socket.c:654)
[ 4448.971584] ? might_fault (mm/memory.c:3741)
[ 4448.972526] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3740)
[ 4448.973596] ? verify_iovec (net/core/iovec.c:64)
[ 4448.974522] ___sys_sendmsg (net/socket.c:2096)
[ 4448.975797] ? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[ 4448.977030] ? lock_release_holdtime (kernel/locking/lockdep.c:273)
[ 4448.978197] ? lock_release_non_nested (kernel/locking/lockdep.c:3434 (discriminator 1))
[ 4448.979346] ? check_chain_key (kernel/locking/lockdep.c:2188)
[ 4448.980535] __sys_sendmmsg (net/socket.c:2181)
[ 4448.981592] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2600)
[ 4448.982773] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 4448.984458] ? syscall_trace_enter (arch/x86/kernel/ptrace.c:1500 (discriminator 2))
[ 4448.985621] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2600)
[ 4448.986754] SyS_sendmmsg (net/socket.c:2201)
[ 4448.987708] tracesys (arch/x86/kernel/entry_64.S:542)
[ 4448.988929] ==================================================================

It's similar to another variation:

[ 2918.108434] ==================================================================
[ 2918.109923] AddressSanitizer: user-memory-access on address 4
[ 2918.111600] Read of size 4 by thread T5793:
[ 2918.112867] CPU: 4 PID: 5793 Comm: trinity-c4 Not tainted 3.16.0-rc4-next-20140711-sasha-00046-g07d3099-dirty #813
[ 2918.114335]  ffff8805da310700 0000000000000000 0000000000000000 ffff880458b239b0
[ 2918.115632]  ffffffff85e47068 ffff880458b239d8 ffff880458b239c8 ffffffff8142708d
[ 2918.116904]  ffff880458b23e78 ffff880458b239f8 ffffffff81425811 0000000000000004
[ 2918.118075] Call Trace:
[ 2918.118583] dump_stack (lib/dump_stack.c:52)
[ 2918.119449] kasan_report_user_access (mm/kasan/report.c:184)
[ 2918.120928] __asan_load4 (mm/kasan/kasan.c:358)
[ 2918.121916] ? raw_sendmsg (net/ipv4/raw.c:507)
[ 2918.122893] raw_sendmsg (net/ipv4/raw.c:507)
[ 2918.124048] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 2918.124895] ? sched_clock_local (kernel/sched/clock.c:214)
[ 2918.125901] ? get_parent_ip (kernel/sched/core.c:2555)
[ 2918.126741] ? check_chain_key (kernel/locking/lockdep.c:2188)
[ 2918.127657] ? put_lock_stats.isra.13 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[ 2918.128617] inet_sendmsg (net/ipv4/af_inet.c:738)
[ 2918.129546] ? inet_sendmsg (net/ipv4/af_inet.c:727)
[ 2918.130886] ? lock_release_non_nested (kernel/locking/lockdep.c:3434 (discriminator 1))
[ 2918.132088] sock_sendmsg (net/socket.c:654)
[ 2918.132891] ? might_fault (mm/memory.c:3741)
[ 2918.133765] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3740)
[ 2918.134626] ? verify_iovec (net/core/iovec.c:64)
[ 2918.135654] ___sys_sendmsg (net/socket.c:2096)
[ 2918.136649] ? pvclock_clocksource_read (arch/x86/kernel/pvclock.c:83)
[ 2918.137792] ? kvm_clock_read (./arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[ 2918.138682] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[ 2918.139686] ? __lock_is_held (kernel/locking/lockdep.c:3513)
[ 2918.140907] ? sockfd_lookup_light (net/socket.c:461)
[ 2918.141862] __sys_sendmmsg (net/socket.c:2181)
[ 2918.142744] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2600)
[ 2918.144719] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 2918.146433] ? syscall_trace_enter (arch/x86/kernel/ptrace.c:1500 (discriminator 2))
[ 2918.148317] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2600)
[ 2918.150321] SyS_sendmmsg (net/socket.c:2201)
[ 2918.151971] tracesys (arch/x86/kernel/entry_64.S:542)
[ 2918.153398] ==================================================================

I've tried debugging it, but I don't see a code path that could lead to that.


Thanks,
Sasha
