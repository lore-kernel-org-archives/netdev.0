From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: decnet: NULL ptr deref on connect()
Date: Sun, 06 Apr 2014 14:58:09 -0400
Message-ID: <5341A3C1.9060101@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-decnet-user@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel, I've stumbled on the following:

[  279.107409] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  279.108676] IP: dnet_select_source.isra.25 (net/decnet/dn_route.c:926)
[  279.109876] PGD 19dd92067 PUD 1a25ab067 PMD 0
[  279.110186] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  279.110186] Dumping ftrace buffer:
[  279.110186]    (ftrace buffer empty)
[  279.110186] Modules linked in:
[  279.110186] CPU: 1 PID: 17317 Comm: trinity-c78 Not tainted 3.14.0-next-20140403-sasha-00022-g10224c0 #377
[  279.110186] task: ffff880196c60000 ti: ffff8801b6e8a000 task.ti: ffff8801b6e8a000
[  279.110186] RIP: dnet_select_source.isra.25 (net/decnet/dn_route.c:926)
[  279.110186] RSP: 0018:ffff8801b6e8bc88  EFLAGS: 00010202
[  279.110186] RAX: 0000000000000001 RBX: 0000000000000000 RCX: 0000000000000001
[  279.110186] RDX: 0000000000000001 RSI: ffffffffa9e88100 RDI: 0000000000000282
[  279.110186] RBP: ffff8801b6e8bcb8 R08: 0000000000000001 R09: ffff880196c60cf0
[  279.110186] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8801b6e8be18
[  279.110186] R13: 0000000000000000 R14: 00000000000000fe R15: 0000000000000000
[  279.110186] FS:  00007f333a961700(0000) GS:ffff880063000000(0000) knlGS:0000000000000000
[  279.110186] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  279.110186] CR2: 0000000000000000 CR3: 000000019cc2d000 CR4: 00000000000006a0
[  279.110186] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000696000
[  279.110186] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[  279.110186] Stack:
[  279.110186]  ffffffffa82c3225 ffffffffa507aac5 ffff880436a39160 ffff8801b6e8be18
[  279.110186]  0000000000000000 ffff8800c5dc7408 ffff8801b6e8bd68 ffffffffa82c5803
[  279.110186]  ffff880196c60000 0000000000000007 0000000000000006 0000000000000082
[  279.110186] Call Trace:
[  279.110186] ? dnet_select_source.isra.25 (net/decnet/dn_route.c:916)
[  279.110186] ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[  279.110186] dn_route_output_slow (net/decnet/dn_route.c:1042)
[  279.110186] __dn_route_output_key (net/decnet/dn_route.c:1267)
[  279.110186] ? __dn_route_output_key (include/linux/bottom_half.h:19 include/linux/rcupdate.h:850 net/decnet/dn_route.c:1249)
[  279.110186] dn_route_output_sock (net/decnet/dn_route.c:1290)
[  279.110186] __dn_connect (net/decnet/af_decnet.c:954)
[  279.110186] ? __local_bh_enable_ip (arch/x86/include/asm/paravirt.h:819 kernel/softirq.c:171)
[  279.110186] ? dn_connect (net/decnet/af_decnet.c:979)
[  279.110186] dn_connect (net/decnet/af_decnet.c:980)
[  279.110186] SYSC_connect (net/socket.c:1701)
[  279.110186] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[  279.110186] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[  279.110186] SyS_connect (net/socket.c:1683)
[  279.110186] tracesys (arch/x86/kernel/entry_64.S:749)
[  279.110186] Code: fc 85 c0 75 26 48 c7 c2 68 bf 69 a9 be 9d 03 00 00 48 c7 c7 b7 61 c7 a9 c6 05 42 4c cc 02 01 e8 1f cb ef fc 0f 1f 80 00 00 00 00 <48> 8b 1b e8 60 84 f1 fc 85 c0 74 5c 80 3d 24 4c cc 02 00 75 53
[  279.110186] RIP dnet_select_source.isra.25 (net/decnet/dn_route.c:926)
[  279.110186]  RSP <ffff8801b6e8bc88>


Thanks,
Sasha
