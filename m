From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: pretty odd panic in netfilter
Date: Tue, 01 Jul 2014 23:24:17 -0400
Message-ID: <53B37B61.3020901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on a pretty odd corruption(?) in the code - a pretty odd
one.

Here's the issue I've hit:

[ 3640.805823] BUG: unable to handle kernel paging request at ffffffffffffff84
[ 3640.808115] IP: nf_nat_packet (net/netfilter/nf_nat_core.c:482)
[ 3640.810049] PGD 22031067 PUD 22033067 PMD 0
[ 3640.810120] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 3640.810120] Dumping ftrace buffer:
[ 3640.810120]    (ftrace buffer empty)
[ 3640.810120] Modules linked in:
[ 3640.810120] CPU: 4 PID: 5017 Comm: trinity-c192 Tainted: G        W      3.16.0-rc3-next-20140701-sasha-00023-g4eb2544-dirty #759
[ 3640.810120] task: ffff88014d5a3000 ti: ffff880146088000 task.ti: ffff880146088000
[ 3640.810120] RIP: nf_nat_packet (net/netfilter/nf_nat_core.c:482)
[ 3640.810120] RSP: 0018:ffff88014608b958  EFLAGS: 00010206
[ 3640.810120] RAX: 0000000000000001 RBX: 0000000000000001 RCX: ffff8801548a7a00
[ 3640.810120] RDX: 0000000000000003 RSI: 0000000000000002 RDI: ffff880131080000
[ 3640.810120] RBP: ffff88014608b9a8 R08: 0000000000000000 R09: 0000000000000002
[ 3640.810120] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801548a7a80
[ 3640.810120] R13: ffff880131080000 R14: ffffffffa32e8d50 R15: ffff8803346b1160
[ 3640.810120] FS:  00007f7e56497700(0000) GS:ffff880144e00000(0000) knlGS:0000000000000000
[ 3640.810120] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3640.840752] CR2: ffffffffffffff84 CR3: 000000016a997000 CR4: 00000000000006a0
[ 3640.840752] Stack:
[ 3640.840752]  0000000000000000 ffff8803346b1160 0000001400000000 0000000019e906c0
[ 3640.840752]  0000000000000002 0000000019e906c0 ffff8801548a7a80 0000000000000001
[ 3640.840752]  ffff880131080000 ffffffffa32e8d50 ffff88014608ba28 ffffffffa00ffb7e
[ 3640.840752] Call Trace:
[ 3640.840752] nf_nat_ipv4_fn (net/ipv4/netfilter/iptable_nat.c:136)
[ 3640.840752] nf_nat_ipv4_local_fn (net/ipv4/netfilter/iptable_nat.c:219)
[ 3640.840752] ? __ip_append_data.isra.33 (include/net/dst.h:461)
[ 3640.840752] nf_iterate (net/netfilter/core.c:150)
[ 3640.840752] ? __ip_append_data.isra.33 (include/net/dst.h:461)
[ 3640.840752] nf_hook_slow (net/netfilter/core.c:185)
[ 3640.840752] ? __ip_append_data.isra.33 (include/net/dst.h:461)
[ 3640.840752] __ip_local_out (net/ipv4/ip_output.c:102)
[ 3640.840752] ip_local_out_sk (net/ipv4/ip_output.c:109)
[ 3640.840752] ip_send_skb (net/ipv4/ip_output.c:1411)
[ 3640.840752] ip_push_pending_frames (net/ipv4/ip_output.c:1431)
[ 3640.840752] raw_sendmsg (net/ipv4/raw.c:619)
[ 3640.840752] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[ 3640.840752] ? get_parent_ip (kernel/sched/core.c:2550)
[ 3640.840752] ? get_parent_ip (kernel/sched/core.c:2550)
[ 3640.840752] ? inet_sendmsg (include/linux/rcupdate.h:906 include/net/sock.h:833 include/net/sock.h:852 net/ipv4/af_inet.c:730)
[ 3640.840752] ? inet_sendmsg (include/linux/rcupdate.h:906 include/net/sock.h:833 include/net/sock.h:852 net/ipv4/af_inet.c:730)
[ 3640.840752] inet_sendmsg (net/ipv4/af_inet.c:737)
[ 3640.840752] sock_sendmsg (net/socket.c:654)
[ 3640.840752] ? might_fault (mm/memory.c:3741)
[ 3640.840752] ? might_fault (mm/memory.c:3740)
[ 3640.840752] ? vtime_account_user (kernel/sched/cputime.c:687)
[ 3640.840752] ? move_addr_to_kernel (./arch/x86/include/asm/uaccess.h:713 net/socket.c:197)
[ 3640.840752] SYSC_sendto (net/socket.c:1812)
[ 3640.840752] ? vtime_account_user (kernel/sched/cputime.c:687)
[ 3640.840752] ? check_preemption_disabled (lib/smp_processor_id.c:42)
[ 3640.840752] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
[ 3640.840752] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 3640.840752] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 3640.840752] SyS_sendto (net/socket.c:1779)
[ 3640.840752] tracesys (arch/x86/kernel/entry_64.S:542)
[ 3640.840752] Code: 4c 89 65 e8 49 89 cc 0f 97 c1 83 fa 01 0f 95 c0 48 89 5d e0 31 db 83 fa 04 4c 89 6d f0 0f 95 c3 4c 89 75 f8 21 55 55 fb 01 48 19 <d2> 48 83 e2 f0 48 83 c2 20 48 89 d0 48 83 f0 30 84 c9 48 0f 45
[ 3640.840752] RIP nf_nat_packet (net/netfilter/nf_nat_core.c:482)
[ 3640.840752]  RSP <ffff88014608b958>
[ 3640.840752] CR2: ffffffffffffff84

Two odd things here:

1. The code section seems to point mid-instruction:

    19dc:       0f 95 c3                setne  %bl
    19df:       4c 89 75 f8             mov    %r14,-0x8(%rbp)
    19e3:       21 c3                   and    %eax,%ebx
    19e5:       83 fb 01                cmp    $0x1,%ebx
    19e8:       48 19 d2                sbb    %rdx,%rdx  <=== The end of this (0xd2)
    19eb:       48 83 e2 f0             and    $0xfffffffffffffff0,%rdx
    19ef:       48 83 c2 20             add    $0x20,%rdx
    19f3:       48 89 d0                mov    %rdx,%rax
    19f6:       48 83 f0 30             xor    $0x30,%rax

2. There isn't anything in that area that dereferences memory:

        enum nf_nat_manip_type mtype = HOOK2MANIP(hooknum);

        if (mtype == NF_NAT_MANIP_SRC)
                statusbit = IPS_SRC_NAT;
        else
                statusbit = IPS_DST_NAT;


Help?


Thanks,
Sasha
