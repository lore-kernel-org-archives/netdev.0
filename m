From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: non contiguous allocations passed to build_skb
Date: Fri, 24 Apr 2015 17:28:15 -0400
Message-ID: <553AB56F.4000600@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Eric,

Your commit 79930f5892e ("net: do not deplete pfmemalloc reserve") assumes that
build_skb() will only handle contiguous allocations because of the
virt_to_head_page().

However, netlink_sendmsg() calls build_skb() with vmalloc()ed memory, causing:

[ 1567.700067] kernel BUG at arch/x86/mm/physaddr.c:26!
[ 1567.700067] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
[ 1567.700067] Dumping ftrace buffer:
[ 1567.700067]    (ftrace buffer empty)
[ 1567.700067] Modules linked in:
[ 1567.700067] CPU: 9 PID: 16186 Comm: trinity-c182 Not tainted 4.0.0-next-20150424-sasha-00037-g4796e21 #2167
[ 1567.700067] task: ffff880127efb000 ti: ffff880246770000 task.ti: ffff880246770000
[ 1567.700067] RIP: __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 3))
[ 1567.700067] RSP: 0018:ffff8802467779d8  EFLAGS: 00010202
[ 1567.700067] RAX: 000041000ed8e000 RBX: ffffc9008ed8e000 RCX: 000000000000002c
[ 1567.700067] RDX: 0000000000000004 RSI: 0000000000000000 RDI: ffffffffb3fd6049
[ 1567.700067] RBP: ffff8802467779f8 R08: 0000000000000019 R09: ffff8801d0168000
[ 1567.700067] R10: ffff8801d01680c7 R11: ffffed003a02d019 R12: ffffc9000ed8e000
[ 1567.700067] R13: 0000000000000f40 R14: 0000000000001180 R15: ffffc9000ed8e000
[ 1567.700067] FS:  00007f2a7da3f700(0000) GS:ffff8801d1000000(0000) knlGS:0000000000000000
[ 1567.700067] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1567.700067] CR2: 0000000000738308 CR3: 000000022e329000 CR4: 00000000000007e0
[ 1567.700067] Stack:
[ 1567.700067]  ffffc9000ed8e000 ffff8801d0168000 ffffc9000ed8e000 ffff8801d0168000
[ 1567.700067]  ffff880246777a28 ffffffffad7c0a21 0000000000001080 ffff880246777c08
[ 1567.700067]  ffff88060d302e68 ffff880246777b58 ffff880246777b88 ffffffffad9a6821
[ 1567.700067] Call Trace:
[ 1567.700067] build_skb (include/linux/mm.h:508 net/core/skbuff.c:316)
[ 1567.700067] netlink_sendmsg (net/netlink/af_netlink.c:1633 net/netlink/af_netlink.c:2329)
[ 1567.774369] ? sched_clock_cpu (kernel/sched/clock.c:311)
[ 1567.774369] ? netlink_unicast (net/netlink/af_netlink.c:2273)
[ 1567.774369] ? netlink_unicast (net/netlink/af_netlink.c:2273)
[ 1567.774369] sock_sendmsg (net/socket.c:614 net/socket.c:623)
[ 1567.774369] sock_write_iter (net/socket.c:823)
[ 1567.774369] ? sock_sendmsg (net/socket.c:806)
[ 1567.774369] __vfs_write (fs/read_write.c:479 fs/read_write.c:491)
[ 1567.774369] ? get_lock_stats (kernel/locking/lockdep.c:249)
[ 1567.774369] ? default_llseek (fs/read_write.c:487)
[ 1567.774369] ? vtime_account_user (kernel/sched/cputime.c:701)
[ 1567.774369] ? rw_verify_area (fs/read_write.c:406 (discriminator 4))
[ 1567.774369] vfs_write (fs/read_write.c:539)
[ 1567.774369] SyS_write (fs/read_write.c:586 fs/read_write.c:577)
[ 1567.774369] ? SyS_read (fs/read_write.c:577)
[ 1567.774369] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1567.774369] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2594 kernel/locking/lockdep.c:2636)
[ 1567.774369] ? trace_hardirqs_on_thunk (arch/x86/lib/thunk_64.S:42)
[ 1567.774369] system_call_fastpath (arch/x86/kernel/entry_64.S:261)
[ 1567.774369] Code: 0f b6 14 11 48 89 f9 83 e1 07 38 ca 7f 04 84 d2 75 54 0f b6 0d 8b 0b ec 0f 48 89 c2 48 d3 ea 48 85 d2 75 07 48 83 c4 18 5b 5d c3 <0f> 0b 66 0f 1f 44 00 00 48 c7 c7 10 20 63 b1 48 b8 00 00 00 00
All code
========
   0:   0f b6 14 11             movzbl (%rcx,%rdx,1),%edx
   4:   48 89 f9                mov    %rdi,%rcx
   7:   83 e1 07                and    $0x7,%ecx
   a:   38 ca                   cmp    %cl,%dl
   c:   7f 04                   jg     0x12
   e:   84 d2                   test   %dl,%dl
  10:   75 54                   jne    0x66
  12:   0f b6 0d 8b 0b ec 0f    movzbl 0xfec0b8b(%rip),%ecx        # 0xfec0ba4
  19:   48 89 c2                mov    %rax,%rdx
  1c:   48 d3 ea                shr    %cl,%rdx
  1f:   48 85 d2                test   %rdx,%rdx
  22:   75 07                   jne    0x2b
  24:   48 83 c4 18             add    $0x18,%rsp
  28:   5b                      pop    %rbx
  29:   5d                      pop    %rbp
  2a:   c3                      retq
  2b:*  0f 0b                   ud2             <-- trapping instruction
  2d:   66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
  33:   48 c7 c7 10 20 63 b1    mov    $0xffffffffb1632010,%rdi
  3a:   48                      rex.W
  3b:   b8 00 00 00 00          mov    $0x0,%eax
        ...

Code starting with the faulting instruction
===========================================
   0:   0f 0b                   ud2
   2:   66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
   8:   48 c7 c7 10 20 63 b1    mov    $0xffffffffb1632010,%rdi
   f:   48                      rex.W
  10:   b8 00 00 00 00          mov    $0x0,%eax
        ...
[ 1567.774369] RIP __phys_addr (arch/x86/mm/physaddr.c:26 (discriminator 3))
[ 1567.774369]  RSP <ffff8802467779d8>


Thanks,
Sasha
