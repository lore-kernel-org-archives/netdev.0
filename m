From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: llc: NULL ptr deref in llc_ui_sendmsg
Date: Fri, 06 Jun 2014 11:08:33 -0400
Message-ID: <5391D971.4030001@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28642 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaFFPIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[  269.531162] BUG: unable to handle kernel NULL pointer dereference at 000000000000021e
[  269.531217] IP: llc_ui_sendmsg (net/llc/af_llc.c:912)
[  269.531232] PGD b6584067 PUD b6585067 PMD 0
[  269.531246] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  269.531287] Dumping ftrace buffer:
[  269.531451]    (ftrace buffer empty)
[  269.531472] Modules linked in:
[  269.531483] CPU: 10 PID: 9450 Comm: trinity-c77 Not tainted 3.15.0-rc8-next-20140605-sasha-00021-ga95d8d2 #593
[  269.531487] task: ffff8800b6563000 ti: ffff8800b659c000 task.ti: ffff8800b659c000
[  269.531498] RIP: llc_ui_sendmsg (net/llc/af_llc.c:912)
[  269.531501] RSP: 0018:ffff8800b659fcb8  EFLAGS: 00010286
[  269.531505] RAX: 0000000000000000 RBX: ffff88006b5b8000 RCX: 0000000000000006
[  269.531510] RDX: 0000000000007110 RSI: ffffffff9584f0f3 RDI: ffffffff957e75bd
[  269.531515] RBP: ffff8800b659fd38 R08: 0000000000000000 R09: 0000000000000000
[  269.531519] R10: 0000000000000001 R11: 0000000000000000 R12: ffff88006e177900
[  269.531521] R13: ffff8800b659feb0 R14: 00000000007ffff7 R15: ffff8800b659fe78
[  269.531524] FS:  00007f2b119bb700(0000) GS:ffff880292e00000(0000) knlGS:0000000000000000
[  269.531528] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  269.531530] CR2: 000000000000021e CR3: 00000000b6583000 CR4: 00000000000006a0
[  269.531610] DR0: 00000000006d6000 DR1: 0000000000000000 DR2: 0000000000000000
[  269.531612] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000070602
[  269.531616] Stack:
[  269.531686]  ffff8800b659fcc8 ffffffff911c488e ffff8800b659fce8 ffffffff00004002
[  269.531695]  00000000b648d118 ffffffff912b923a ffff8800b659fd88 ffffffff911cb5be
[  269.531709]  ffff880000000000 ffffffff911a6ba8 000000000049c24f ffff8800b659fd48
[  269.531712] Call Trace:
[  269.531730] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  269.531746] ? might_fault (mm/memory.c:3735)
[  269.531755] ? lock_release_non_nested (kernel/locking/lockdep.c:3397)
[  269.531771] ? sched_clock_cpu (kernel/sched/clock.c:311)
[  269.531779] sock_sendmsg (net/socket.c:654)
[  269.531787] ? might_fault (mm/memory.c:3736)
[  269.531793] ? might_fault (mm/memory.c:3735)
[  269.531800] ? move_addr_to_kernel (./arch/x86/include/asm/uaccess.h:713 net/socket.c:197)
[  269.531805] SYSC_sendto (net/socket.c:1812)
[  269.531819] ? syscall_trace_enter (include/trace/events/syscalls.h:16 arch/x86/kernel/ptrace.c:1488)
[  269.531827] SyS_sendto (net/socket.c:1779)
[  269.531837] tracesys (arch/x86/kernel/entry_64.S:542)
[ 269.532403] Code: c6 c0 37 b2 98 4c 89 ef e8 95 a5 b6 fd 85 c0 74 d5 90 48 8b 83 f8 01 00 00 f6 c4 01 75 1c 48 8b 83 28 05 00 00 66 41 83 7d 04 00 <0f> b7 90 1e 02 00 00 75 1e eb 24 0f 1f 40 00 49 8b 7c 24 20 4c
All code
========
   0:	c6 c0 37             	mov    $0x37,%al
   3:	b2 98                	mov    $0x98,%dl
   5:	4c 89 ef             	mov    %r13,%rdi
   8:	e8 95 a5 b6 fd       	callq  0xfffffffffdb6a5a2
   d:	85 c0                	test   %eax,%eax
   f:	74 d5                	je     0xffffffffffffffe6
  11:	90                   	nop
  12:	48 8b 83 f8 01 00 00 	mov    0x1f8(%rbx),%rax
  19:	f6 c4 01             	test   $0x1,%ah
  1c:	75 1c                	jne    0x3a
  1e:	48 8b 83 28 05 00 00 	mov    0x528(%rbx),%rax
  25:	66 41 83 7d 04 00    	cmpw   $0x0,0x4(%r13)
  2b:*	0f b7 90 1e 02 00 00 	movzwl 0x21e(%rax),%edx		<-- trapping instruction
  32:	75 1e                	jne    0x52
  34:	eb 24                	jmp    0x5a
  36:	0f 1f 40 00          	nopl   0x0(%rax)
  3a:	49 8b 7c 24 20       	mov    0x20(%r12),%rdi
  3f:	4c                   	rex.WR
	...

Code starting with the faulting instruction
===========================================
   0:	0f b7 90 1e 02 00 00 	movzwl 0x21e(%rax),%edx
   7:	75 1e                	jne    0x27
   9:	eb 24                	jmp    0x2f
   b:	0f 1f 40 00          	nopl   0x0(%rax)
   f:	49 8b 7c 24 20       	mov    0x20(%r12),%rdi
  14:	4c                   	rex.WR
	...
[  269.532565] RIP llc_ui_sendmsg (net/llc/af_llc.c:912)
[  269.532572]  RSP <ffff8800b659fcb8>
[  269.532575] CR2: 000000000000021e


Thanks,
Sasha
