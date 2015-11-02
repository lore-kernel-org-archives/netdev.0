From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: lockdep warning in ip_mc_msfget (net/ipv4/igmp.c:2400)
Date: Mon, 2 Nov 2015 10:22:49 -0500
Message-ID: <56377FC9.90601@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com,
	Dmitry Vyukov <dvyukov@google.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with syzkaller inside a KVM tools guest running the latest -next, I saw
the following warning:

[ 2391.993558] ======================================================
[ 2391.995441] [ INFO: possible circular locking dependency detected ]
[ 2391.995771] 4.3.0-rc6-next-20151022-sasha-00042-g2b253a1-dirty #2618 Not tainted
[ 2391.995771] -------------------------------------------------------
[ 2391.995771] syzkaller_execu/14105 is trying to acquire lock:
[ 2391.995771] (rtnl_mutex){+.+.+.}, at: rtnl_lock (net/core/rtnetlink.c:71)
[ 2391.995771] Mutex: counter: 1 owner: None
[ 2391.995771]
[ 2391.995771] but task is already holding lock:
[ 2391.995771] (sk_lock-AF_INET){+.+.+.}, at: do_ip_getsockopt (net/ipv4/ip_sockglue.c:1274)
[ 2391.995771]
[ 2391.995771] which lock already depends on the new lock.
[ 2391.995771]
[ 2391.995771]
[ 2391.995771] the existing dependency chain (in reverse order) is:
[ 2391.995771] -> #1 (sk_lock-AF_INET){+.+.+.}:
[ 2391.995771] lock_acquire (kernel/locking/lockdep.c:3620)
[ 2391.995771] lock_sock_nested (include/linux/bottom_half.h:31 net/core/sock.c:2411)
[ 2391.995771] do_ip_setsockopt.isra.9 (net/ipv4/ip_sockglue.c:623)
[ 2391.995771] ip_setsockopt (net/ipv4/ip_sockglue.c:1202)
[ 2391.995771]        ffffffffffffff, 0x0)
[ 2391.995771] sock_common_setsockopt (net/core/sock.c:2610)
[ 2391.995771] SyS_setsockopt (net/socket.c:1756 net/socket.c:1736)
[ 2391.995771] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)
[ 2391.995771] -> #0 (rtnl_mutex){+.+.+.}:
[ 2391.995771] __lock_acquire (kernel/locking/lockdep.c:1877 kernel/locking/lockdep.c:1982 kernel/locking/lockdep.c:2168 kernel/locking/lockdep.c:3239)
[ 2391.995771] lock_acquire (kernel/locking/lockdep.c:3620)
[ 2391.995771] mutex_lock_nested (kernel/locking/mutex.c:526 kernel/locking/mutex.c:618)
[ 2391.995771] rtnl_lock (net/core/rtnetlink.c:71)
[ 2391.995771] ip_mc_msfget (net/ipv4/igmp.c:2400)
[ 2391.995771] do_ip_getsockopt (net/ipv4/ip_sockglue.c:1401)
[ 2391.995771] ip_getsockopt (net/ipv4/ip_sockglue.c:1498)
[ 2391.995771] raw_getsockopt (net/ipv4/raw.c:851)
[ 2391.995771] sock_common_getsockopt (net/core/sock.c:2569)
[ 2391.995771] SyS_getsockopt (net/socket.c:1787 net/socket.c:1770)
[ 2391.995771] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)
[ 2391.995771]
[ 2391.995771] other info that might help us debug this:
[ 2391.995771]
[ 2391.995771]  Possible unsafe locking scenario:
[ 2391.995771]
[ 2391.995771]        CPU0                    CPU1
[ 2391.995771]        ----                    ----
[ 2391.995771]   lock(sk_lock-AF_INET);
[ 2391.995771]                                lock(rtnl_mutex);
[ 2391.995771]                                lock(sk_lock-AF_INET);
[ 2391.995771]   lock(rtnl_mutex);
[ 2391.995771]
[ 2391.995771]  *** DEADLOCK ***
[ 2391.995771]
[ 2391.995771] 1 lock held by syzkaller_execu/14105:
[ 2391.995771] #0: (sk_lock-AF_INET){+.+.+.}, at: do_ip_getsockopt (net/ipv4/ip_sockglue.c:1274)
[ 2391.995771]
[ 2391.995771] stack backtrace:
[ 2391.995771] CPU: 1 PID: 14105 Comm: syzkaller_execu Not tainted 4.3.0-rc6-next-20151022-sasha-00042-g2b253a1-dirty #2618
[ 2391.995771]  0000000000000001 00000000c179c8c9 ffff8800a403f550 ffffffffade32a2b
[ 2391.995771]  ffffffffbb7f5a50 ffffffffbb84a4a0 ffffffffbb7f5a50 ffff8800a403f5a0
[ 2391.995771]  ffffffffac43fca8 ffff8800a403f690 00000000a3e18000 ffff8800a3e18000
[ 2391.995771] Call Trace:
[ 2391.995771] dump_stack (lib/dump_stack.c:52)
[ 2391.995771] print_circular_bug (kernel/locking/lockdep.c:1250)
[ 2391.995771] __lock_acquire (kernel/locking/lockdep.c:1877 kernel/locking/lockdep.c:1982 kernel/locking/lockdep.c:2168 kernel/locking/lockdep.c:3239)
[ 2391.995771] lock_acquire (kernel/locking/lockdep.c:3620)
[ 2391.995771] mutex_lock_nested (kernel/locking/mutex.c:526 kernel/locking/mutex.c:618)
[ 2391.995771] rtnl_lock (net/core/rtnetlink.c:71)
[ 2391.995771] ip_mc_msfget (net/ipv4/igmp.c:2400)
[ 2391.995771] do_ip_getsockopt (net/ipv4/ip_sockglue.c:1401)
[ 2391.995771] ip_getsockopt (net/ipv4/ip_sockglue.c:1498)
[ 2391.995771] raw_getsockopt (net/ipv4/raw.c:851)
[ 2391.995771] sock_common_getsockopt (net/core/sock.c:2569)
[ 2391.995771] SyS_getsockopt (net/socket.c:1787 net/socket.c:1770)
[ 2391.995771] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)


Thanks,
Sasha
