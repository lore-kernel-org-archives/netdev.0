From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: unix: lockdep warning in unix_stream_sendpage
Date: Sun, 09 Aug 2015 11:09:39 -0400
Message-ID: <55C76D33.9080607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27710 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbHIPJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 11:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm seeing a lockdep warning that was introduced in 869e7c624 ("net: af_unix:
implement stream sendpage support"):

[377296.160447] ======================================================
[377296.160449] [ INFO: possible circular locking dependency detected ]
[377296.160455] 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2417 Not tainted
[377296.160459] -------------------------------------------------------
[377296.160462] trinity-c377/13508 is trying to acquire lock:
[377296.160488] (&u->readlock){+.+.+.}, at: unix_stream_sendpage (net/unix/af_unix.c:1767)
[377296.160492] Mutex: counter: 1 owner: None
[377296.160493]
[377296.160493] but task is already holding lock:
[377296.160515] (&pipe->mutex/1){+.+.+.}, at: pipe_lock (fs/pipe.c:68)
[377296.160519] Mutex: counter: 0 owner: trinity-c377
[377296.160521]
[377296.160521] which lock already depends on the new lock.
[377296.160521]
[377296.160524]
[377296.160524] the existing dependency chain (in reverse order) is:
[377296.160538]
[377296.160538] -> #2 (&pipe->mutex/1){+.+.+.}:
[377296.160551] lock_acquire (kernel/locking/lockdep.c:3620)
[377296.160566] mutex_lock_nested (kernel/locking/mutex.c:526 kernel/locking/mutex.c:617)
[377296.160573] pipe_lock (fs/pipe.c:68)
[377296.160588] splice_from_pipe (fs/splice.c:924)
[377296.160598] default_file_splice_write (fs/splice.c:1075)
[377296.160606] SyS_splice (fs/splice.c:1116 fs/splice.c:1392 fs/splice.c:1695 fs/splice.c:1678)
[377296.160616] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
[377296.160631]
[377296.160631] -> #1 (sb_writers#4){.+.+.+}:
[377296.160638] lock_acquire (kernel/locking/lockdep.c:3620)
[377296.160645] __sb_start_write (fs/super.c:1205)
[377296.160656] mnt_want_write (fs/namespace.c:387)
[377296.160669] filename_create (fs/namei.c:3479)
[377296.160676] kern_path_create (fs/namei.c:3523)
[377296.160682] unix_bind (net/unix/af_unix.c:850 net/unix/af_unix.c:916)
[377296.160693] SYSC_bind (net/socket.c:1383)
[377296.160700] SyS_bind (net/socket.c:1369)
[377296.160711] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
[377296.160722]
[377296.160722] -> #0 (&u->readlock){+.+.+.}:
[377296.160729] __lock_acquire (kernel/locking/lockdep.c:1877 kernel/locking/lockdep.c:1982 kernel/locking/lockdep.c:2168 kernel/locking/lockdep.c:3239)
[377296.160735] lock_acquire (kernel/locking/lockdep.c:3620)
[377296.160744] mutex_lock_interruptible_nested (kernel/locking/mutex.c:526 kernel/locking/mutex.c:646)
[377296.160756] unix_stream_sendpage (net/unix/af_unix.c:1767)
[377296.160762] kernel_sendpage (net/socket.c:3281)
[377296.160770] sock_sendpage (net/socket.c:766)
[377296.160781] pipe_to_sendpage (fs/splice.c:707)
[377296.160789] __splice_from_pipe (fs/splice.c:773 fs/splice.c:889)
[377296.160797] splice_from_pipe (fs/splice.c:925)
[377296.160806] generic_splice_sendpage (fs/splice.c:1098)
[377296.160817] SyS_splice (fs/splice.c:1116 fs/splice.c:1392 fs/splice.c:1695 fs/splice.c:1678)
[377296.160828] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
[377296.160833]
[377296.160833] other info that might help us debug this:
[377296.160833]
[377296.160853] Chain exists of:
[377296.160853]   &u->readlock --> sb_writers#4 --> &pipe->mutex/1
[377296.160853]
[377296.160855]  Possible unsafe locking scenario:
[377296.160855]
[377296.160859]        CPU0                    CPU1
[377296.160860]        ----                    ----
[377296.160866]   lock(&pipe->mutex/1);
[377296.160873]                                lock(sb_writers#4);
[377296.160878]                                lock(&pipe->mutex/1);
[377296.160889]   lock(&u->readlock);
[377296.160891]
[377296.160891]  *** DEADLOCK ***
[377296.160891]
[377296.160894] 1 lock held by trinity-c377/13508:
[377296.160911] #0: (&pipe->mutex/1){+.+.+.}, at: pipe_lock (fs/pipe.c:68)
[377296.160915] Mutex: counter: 0 owner: trinity-c377
[377296.160918]
[377296.160918] stack backtrace:
[377296.160927] CPU: 1 PID: 13508 Comm: trinity-c377 Not tainted 4.2.0-rc5-next-20150806-sasha-00040-g1b47b00-dirty #2417
[377296.160942]  ffffffffbcb0f170 ffff88054d5cf760 ffffffffb6e89dfc ffffffffbcb0c6d0
[377296.160956]  ffff88054d5cf7b0 ffffffffad421062 ffff88054d5cf880 dffffc0000000000
[377296.160969]  ffff88054d5cf8c0 ffff880509958ca0 ffff880509958cd2 ffff880509958000
[377296.160971] Call Trace:
[377296.160986] dump_stack (lib/dump_stack.c:52)
[377296.160995] print_circular_bug (kernel/locking/lockdep.c:1252)
[377296.161008] __lock_acquire (kernel/locking/lockdep.c:1877 kernel/locking/lockdep.c:1982 kernel/locking/lockdep.c:2168 kernel/locking/lockdep.c:3239)
[377296.161014] ? lockdep_reset_lock (kernel/locking/lockdep.c:3105)
[377296.161023] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[377296.161036] ? lockdep_reset_lock (kernel/locking/lockdep.c:3105)
[377296.161050] ? debug_smp_processor_id (lib/smp_processor_id.c:57)
[377296.161056] ? get_lock_stats (kernel/locking/lockdep.c:249)
[377296.161073] lock_acquire (kernel/locking/lockdep.c:3620)
[377296.161080] ? unix_stream_sendpage (net/unix/af_unix.c:1767)
[377296.161087] mutex_lock_interruptible_nested (kernel/locking/mutex.c:526 kernel/locking/mutex.c:646)
[377296.161092] ? unix_stream_sendpage (net/unix/af_unix.c:1767)
[377296.161100] ? unix_stream_sendpage (net/unix/af_unix.c:1767)
[377296.161110] ? mutex_lock_nested (kernel/locking/mutex.c:644)
[377296.161118] ? __lock_acquire (kernel/locking/lockdep.c:3246)
[377296.161124] ? lockdep_reset_lock (kernel/locking/lockdep.c:3105)
[377296.161130] ? __lock_acquire (kernel/locking/lockdep.c:3246)
[377296.161136] unix_stream_sendpage (net/unix/af_unix.c:1767)
[377296.161146] ? skb_unix_socket_splice (net/unix/af_unix.c:1741)
[377296.161155] ? get_lock_stats (kernel/locking/lockdep.c:249)
[377296.161163] ? _raw_spin_unlock_irqrestore (include/linux/spinlock_api_smp.h:162 kernel/locking/spinlock.c:191)
[377296.161170] ? lockdep_init (kernel/locking/lockdep.c:3298)
[377296.161177] ? kernel_sendpage (net/socket.c:755)
[377296.161183] kernel_sendpage (net/socket.c:3281)
[377296.161192] sock_sendpage (net/socket.c:766)
[377296.161202] pipe_to_sendpage (fs/splice.c:707)
[377296.161211] ? preempt_count_sub (kernel/sched/core.c:2852)
[377296.161219] ? direct_splice_actor (fs/splice.c:707)
[377296.161225] ? pipe_lock (fs/pipe.c:68)
[377296.161236] __splice_from_pipe (fs/splice.c:773 fs/splice.c:889)
[377296.161244] ? direct_splice_actor (fs/splice.c:707)
[377296.161256] ? direct_splice_actor (fs/splice.c:707)
[377296.161262] splice_from_pipe (fs/splice.c:925)
[377296.161268] ? vmsplice_to_pipe (fs/splice.c:914)
[377296.161276] ? __raw_callee_save___pv_queued_spin_unlock (??:?)
[377296.161288] generic_splice_sendpage (fs/splice.c:1098)
[377296.161294] SyS_splice (fs/splice.c:1116 fs/splice.c:1392 fs/splice.c:1695 fs/splice.c:1678)
[377296.161306] ? compat_SyS_vmsplice (fs/splice.c:1678)
[377296.161318] ? lockdep_sys_exit_thunk (arch/x86/entry/thunk_64.S:44)


Thanks,
Sasha
