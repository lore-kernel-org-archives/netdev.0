From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: gpf in sock_alloc_file
Date: Sun, 10 Jan 2016 13:44:09 -0500
Message-ID: <5692A679.8010905@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest, running the latest -next
kernel, I've hit the following gpf:

[  165.249639] general protection fault: 0000 [#1] PREEMPT SMP KASAN
[  165.253839] Modules linked in:
[  165.254279] CPU: 1 PID: 14411 Comm: trinity-c4 Not tainted 4.4.0-rc8-next-20160108-sasha-00024-gaaecb9a #2779
[  165.255468] task: ffff880374540000 ti: ffff8800c7b80000 task.ti: ffff8800c7b80000
[  165.256370] RIP: strlen (lib/string.c:481 (discriminator 1))
[  165.257395] RSP: 0018:ffff8800c7b87c10  EFLAGS: 00010202
[  165.258028] RAX: 0000000000000028 RBX: 0000000000000147 RCX: 1ffff100191e5ac2
[  165.258888] RDX: 0000000000000007 RSI: 0000000000000800 RDI: 0000000000000147
[  165.259711] RBP: ffff8800c7b87c30 R08: 0000000000000001 R09: 0000000000000001
[  165.260552] R10: 0000000000000000 R11: 0000000000000001 R12: dffffc0000000000
[  165.261371] R13: 0000000000000147 R14: 1ffff10018f70f89 R15: 0000000000000147
[  165.262196] FS:  00007f6e3ad2e700(0000) GS:ffff88038bb00000(0000) knlGS:0000000000000000
[  165.263113] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  165.263825] CR2: 0000000000711000 CR3: 000000037c2a9000 CR4: 00000000000406e0
[  165.264670] Stack:
[  165.264936]  ffff8800c7b87ce8 ffff8800c7b87ce8 ffff88038a2b3200 1ffff10018f70faa
[  165.265892]  ffff8800c7b87d10 ffffffffa96170d2 00000800710005aa 0000000041b58ab3
[  165.266914]  ffffffffad344c36 ffffffffa9617010 ffffffffad1b37ee 0000000000000000
[  165.267872] Call Trace:
[  165.268265] sock_alloc_file (net/socket.c:363)
[  165.270518] SYSC_accept4 (net/socket.c:1464)
[  165.275726] SyS_accept4 (net/socket.c:1425)
[  165.276171] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:186)
[ 165.276749] Code: 56 fe 48 83 c3 01 e8 f3 e6 56 fe 48 85 db 75 0e 31 f6 48 c7 c7 20 04 e0 b0 e8 63 ac 0d 00 48 89 d8 48 89 da 48 c1 e8 03 83 e2 07 <42> 0f b6 04 20 38 d0 7f 0c 84 c0 74 08 48 89 df e8 3e a0 74 fe
All code
========
   0:   56                      push   %rsi
   1:   fe 48 83                decb   -0x7d(%rax)
   4:   c3                      retq
   5:   01 e8                   add    %ebp,%eax
   7:   f3 e6 56                repz out %al,$0x56
   a:   fe 48 85                decb   -0x7b(%rax)
   d:   db 75 0e                (bad)  0xe(%rbp)
  10:   31 f6                   xor    %esi,%esi
  12:   48 c7 c7 20 04 e0 b0    mov    $0xffffffffb0e00420,%rdi
  19:   e8 63 ac 0d 00          callq  0xdac81
  1e:   48 89 d8                mov    %rbx,%rax
  21:   48 89 da                mov    %rbx,%rdx
  24:   48 c1 e8 03             shr    $0x3,%rax
  28:   83 e2 07                and    $0x7,%edx
  2b:*  42 0f b6 04 20          movzbl (%rax,%r12,1),%eax               <-- trapping instruction
  30:   38 d0                   cmp    %dl,%al
  32:   7f 0c                   jg     0x40
  34:   84 c0                   test   %al,%al
  36:   74 08                   je     0x40
  38:   48 89 df                mov    %rbx,%rdi
  3b:   e8 3e a0 74 fe          callq  0xfffffffffe74a07e
        ...

Code starting with the faulting instruction
===========================================
   0:   42 0f b6 04 20          movzbl (%rax,%r12,1),%eax
   5:   38 d0                   cmp    %dl,%al
   7:   7f 0c                   jg     0x15
   9:   84 c0                   test   %al,%al
   b:   74 08                   je     0x15
   d:   48 89 df                mov    %rbx,%rdi
  10:   e8 3e a0 74 fe          callq  0xfffffffffe74a053
        ...
[  165.279614] RIP strlen (lib/string.c:481 (discriminator 1))
[  165.280096]  RSP <ffff8800c7b87c10>


Thanks,
Sasha
