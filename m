From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: llc: skb_panic in llc_sap_action_send_xid_cmd
Date: Tue, 01 Jul 2014 18:17:37 -0400
Message-ID: <53B33381.3010702@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: acme@ghostprotocols.net, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[ 1307.646561] kernel BUG at net/core/skbuff.c:99!
[ 1307.647152] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1307.648080] Dumping ftrace buffer:
[ 1307.648632]    (ftrace buffer empty)
[ 1307.649287] Modules linked in:
[ 1307.649832] CPU: 8 PID: 16428 Comm: trinity-c172 Not tainted 3.16.0-rc3-next-20140630-sasha-00023-g44434d4-dirty #758
[ 1307.651669] task: ffff880361ef8000 ti: ffff880350c78000 task.ti: ffff880350c78000
[ 1307.653824] RIP: skb_panic (net/core/skbuff.c:99)
[ 1307.654677] RSP: 0018:ffff880350c7bbe8  EFLAGS: 00010296
[ 1307.654677] RAX: 0000000000000083 RBX: ffff8802212661c0 RCX: 00000000e776e776
[ 1307.654677] RDX: 0000000000000001 RSI: ffffffff9552561a RDI: ffffffff921e0537
[ 1307.654677] RBP: ffff880350c7bc08 R08: 0000000000000000 R09: 0000000000000000
[ 1307.662705] R10: 0000000000000001 R11: 65743a7665642030 R12: 00000000000000c8
[ 1307.662705] R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
[ 1307.662705] FS:  00007f5622bc7700(0000) GS:ffff880224e00000(0000) knlGS:0000000000000000
[ 1307.662705] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1307.662705] CR2: 00007f56213a6000 CR3: 0000000361ea6000 CR4: 00000000000006a0
[ 1307.662705] Stack:
[ 1307.662705]  ffff880210802498 00000000000000c2 00000000000000c0 ffff880224768000
[ 1307.662705]  ffff880350c7bc18 ffffffff94f963d7 ffff880350c7bc48 ffffffff94fdc0d5
[ 1307.662705]  ffff88021080249b ffffffff98141880 ffff8802212661c0 ffff88039fe537b0
[ 1307.662705] Call Trace:
[ 1307.662705] skb_put (net/core/skbuff.c:104 net/core/skbuff.c:1278)
[ 1307.662705] llc_sap_action_send_xid_c (net/llc/llc_s_ac.c:83)
[ 1307.662705] llc_sap_state_process (net/llc/llc_sap.c:153 net/llc/llc_sap.c:181 net/llc/llc_sap.c:212)
[ 1307.662705] llc_build_and_send_xid_pkt (net/llc/llc_sap.c:277)
[ 1307.662705] llc_ui_sendmsg (net/llc/af_llc.c:939)
[ 1307.662705] ? lock_release_holdtime (kernel/locking/lockdep.c:273)
[ 1307.662705] ? might_fault (mm/memory.c:3740)
[ 1307.662705] ? lock_release_non_nested (kernel/locking/lockdep.c:3397)
[ 1307.662705] sock_sendmsg (net/socket.c:654)
[ 1307.662705] ? might_fault (mm/memory.c:3741)
[ 1307.662705] ? might_fault (mm/memory.c:3740)
[ 1307.662705] ? move_addr_to_kernel (./arch/x86/include/asm/uaccess.h:713 net/socket.c:197)
[ 1307.662705] SYSC_sendto (net/socket.c:1812)
[ 1307.662705] ? vtime_account_user (kernel/sched/cputime.c:687)
[ 1307.662705] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 1307.662705] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 1307.662705] SyS_sendto (net/socket.c:1779)
[ 1307.662705] tracesys (arch/x86/kernel/entry_64.S:542)
[ 1307.662705] Code: 00 00 48 89 44 24 10 8b 87 c8 00 00 00 48 89 44 24 08 48 8b 87 d8 00 00 00 48 c7 c7 e8 4d cd 96 48 89 04 24 31 c0 e8 e2 4a fb ff <0f> 0b 66 66 66 66 90 55 48 89 e5 41 57 41 56 41 55 41 54 41 89
All code
========
   0:	00 00                	add    %al,(%rax)
   2:	48 89 44 24 10       	mov    %rax,0x10(%rsp)
   7:	8b 87 c8 00 00 00    	mov    0xc8(%rdi),%eax
   d:	48 89 44 24 08       	mov    %rax,0x8(%rsp)
  12:	48 8b 87 d8 00 00 00 	mov    0xd8(%rdi),%rax
  19:	48 c7 c7 e8 4d cd 96 	mov    $0xffffffff96cd4de8,%rdi
  20:	48 89 04 24          	mov    %rax,(%rsp)
  24:	31 c0                	xor    %eax,%eax
  26:	e8 e2 4a fb ff       	callq  0xfffffffffffb4b0d
  2b:*	0f 0b                	ud2    		<-- trapping instruction
  2d:	66 66 66 66 90       	data32 data32 data32 xchg %ax,%ax
  32:	55                   	push   %rbp
  33:	48 89 e5             	mov    %rsp,%rbp
  36:	41 57                	push   %r15
  38:	41 56                	push   %r14
  3a:	41 55                	push   %r13
  3c:	41 54                	push   %r12
  3e:	41 89 00             	mov    %eax,(%r8)

Code starting with the faulting instruction
===========================================
   0:	0f 0b                	ud2
   2:	66 66 66 66 90       	data32 data32 data32 xchg %ax,%ax
   7:	55                   	push   %rbp
   8:	48 89 e5             	mov    %rsp,%rbp
   b:	41 57                	push   %r15
   d:	41 56                	push   %r14
   f:	41 55                	push   %r13
  11:	41 54                	push   %r12
  13:	41 89 00             	mov    %eax,(%r8)
[ 1307.662705] RIP skb_panic (net/core/skbuff.c:99)
[ 1307.662705]  RSP <ffff880350c7bbe8>


Thanks,
sasha
