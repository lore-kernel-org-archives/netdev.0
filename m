From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] net: llc: check for device before dereferencing
Date: Fri, 26 Sep 2014 21:41:43 -0400
Message-ID: <1411782103-3059-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: acme@ghostprotocols.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

llc_ui_sendmsg would not make sure that a device indeed exists before
dereferencing it. This caused a user triggerable NULL ptr deref:

[  430.542391] BUG: unable to handle kernel NULL pointer dereference at 000000000000021e
[  430.551939] IP: llc_ui_sendmsg (net/llc/af_llc.c:912)
[  430.551939] PGD 5edcd067 PUD 5edce067 PMD 0
[  430.551939] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[  430.551939] Dumping ftrace buffer:
[  430.551939]    (ftrace buffer empty)
[  430.551939] Modules linked in:
[  430.551939] CPU: 2 PID: 9395 Comm: trinity-c261 Not tainted 3.17.0-rc6-next-20140926-sasha-00050-g625a54d-dirty #1239
[  430.551939] task: ffff88005edc0000 ti: ffff88005edc8000 task.ti: ffff88005edc8000
[  430.551939] RIP: llc_ui_sendmsg (net/llc/af_llc.c:912)
[  430.551939] RSP: 0018:ffff88005edcbcd8  EFLAGS: 00010282
[  430.551939] RAX: 0000000000000000 RBX: ffff880239191148 RCX: 0000000000000000
[  430.551939] RDX: dfffe90000000000 RSI: ffffffff814471e1 RDI: ffffffff85f7a77f
[  430.551939] RBP: ffff88005edcbd18 R08: dfffe90000000001 R09: 0000000000000000
[  430.551939] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[  430.551939] R13: ffff880237160000 R14: ffff88005edcbeb0 R15: 0000000000000000
[  430.551939] FS:  00007fbcf9f6b700(0000) GS:ffff880111c00000(0000) knlGS:0000000000000000
[  430.551939] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  430.551939] CR2: 000000000000021e CR3: 000000005edcc000 CR4: 00000000000006a0
[  430.551939] DR0: 00000000006ef000 DR1: 0000000000000000 DR2: 0000000000000000
[  430.551939] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000010602
[  430.551939] Stack:
[  430.551939]  0000000000000000 0000000000000100 ffff88005edcbd18 ffff88005edcbd30
[  430.551939]  ffff880237160000 ffff88005edcbe78 0000000000000100 ffffffff86963ec0
[  430.551939]  ffff88005edcbe38 ffffffff85680290 ffff88005edcbd68 0000000000000000
[  430.551939] Call Trace:
[  430.551939] sock_sendmsg (net/socket.c:663)
[  430.551939] ? might_fault (mm/memory.c:3733)
[  430.551939] ? might_fault (./arch/x86/include/asm/current.h:14 mm/memory.c:3732)
[  430.551939] ? __fdget (fs/file.c:698)
[  430.551939] SYSC_sendto (net/socket.c:1818)
[  430.551939] ? do_audit_syscall_entry (include/linux/audit.h:153 arch/x86/kernel/ptrace.c:1448)
[  430.551939] ? syscall_trace_enter_phase2 (arch/x86/kernel/ptrace.c:1598 (discriminator 2))
[  430.551939] SyS_sendto (net/socket.c:1783)
[  430.551939] tracesys_phase2 (arch/x86/kernel/entry_64.S:529)
[ 430.551939] Code: 0f 85 b6 00 00 00 48 8d bb 38 05 00 00 e8 f2 01 d5 fb 4c 8b bb 38 05 00 00 49 8d bf 1e 02 00 00 e8 2f 01 d5 fb 66 41 83 7e 04 00 <45> 0f b7 af 1e 02 00 00 75 1a 48 8d bb d0 02 00 00 e8 53 00 d5

All code
========
   0:	0f 85 b6 00 00 00    	jne    0xbc
   6:	48 8d bb 38 05 00 00 	lea    0x538(%rbx),%rdi
   d:	e8 f2 01 d5 fb       	callq  0xfffffffffbd50204
  12:	4c 8b bb 38 05 00 00 	mov    0x538(%rbx),%r15
  19:	49 8d bf 1e 02 00 00 	lea    0x21e(%r15),%rdi
  20:	e8 2f 01 d5 fb       	callq  0xfffffffffbd50154
  25:	66 41 83 7e 04 00    	cmpw   $0x0,0x4(%r14)
  2b:*	45 0f b7 af 1e 02 00 	movzwl 0x21e(%r15),%r13d		<-- trapping instruction
  32:	00
  33:	75 1a                	jne    0x4f
  35:	48 8d bb d0 02 00 00 	lea    0x2d0(%rbx),%rdi
  3c:	e8 53 00 d5 00       	callq  0xd50094

Code starting with the faulting instruction
===========================================
   0:	45 0f b7 af 1e 02 00 	movzwl 0x21e(%r15),%r13d
   7:	00
   8:	75 1a                	jne    0x24
   a:	48 8d bb d0 02 00 00 	lea    0x2d0(%rbx),%rdi
  11:	e8 53 00 d5 00       	callq  0xd50069
[  430.551939] RIP llc_ui_sendmsg (net/llc/af_llc.c:912)
[  430.551939]  RSP <ffff88005edcbcd8>
[  430.551939] CR2: 000000000000021e

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/llc/af_llc.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c776ffb..c16e01a 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -909,6 +909,9 @@ static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
 		if (rc)
 			goto release;
 	}
+	rc = -ENODEV;
+	if (!llc->dev)
+		goto release;
 	hdrlen = llc->dev->hard_header_len + llc_ui_header_len(sk, addr);
 	size = hdrlen + len;
 	if (size > llc->dev->mtu)
-- 
1.7.10.4
