From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: integer overflow in ip_idents_reserve
Date: Tue, 16 Dec 2014 16:19:52 -0500
Message-ID: <5490A1F8.6020207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrey Ryabinin <a.ryabinin@samsung.com>,
	Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

While fuzzing with trinity on a -next kernel with the undefined behaviour
sanitizer path, I've observed the following warning in code which was
introduced in 04ca6973f7 ("ip: make IP identifiers less predictable"):

[  234.317163] ================================================================================
[  234.320001] UBSan: Undefined behaviour in ./arch/x86/include/asm/atomic.h:157:9
[  234.321568] signed integer overflow:
[  234.322772] 1678406574 + 641542997 cannot be represented in type 'int'
[  234.324316] CPU: 2 PID: 16819 Comm: trinity-c537 Not tainted 3.18.0-next-20141216-sasha-00065-g3c56201-dirty #1609
[  234.326548]  0000000000000000 0000000000000000 ffffffffbc2e4e10 ffff8802e63137e8
[  234.327837]  ffffffffb126bd68 1ffffffff7aa2c03 ffffffffbc2e5c34 ffff8802e6313808
[  234.329117]  ffffffffb126df6f 1ffffffff7aa2c03 ffffffffbc2e5c34 ffff8802e63138c8
[  234.330755] Call Trace:
[  234.331213] dump_stack (lib/dump_stack.c:52)
[  234.332025] ubsan_epilogue (lib/ubsan.c:159)
[  234.332986] handle_overflow (lib/ubsan.c:191)
[  234.334022] ? preempt_schedule (./arch/x86/include/asm/preempt.h:77 (discriminator 1) kernel/sched/core.c:2898 (discriminator 1))
[  234.334945] ? ___preempt_schedule (arch/x86/lib/thunk_64.S:42)
[  234.335919] __ubsan_handle_add_overflow (lib/ubsan.c:200)
[  234.337211] ip_idents_reserve (./arch/x86/include/asm/atomic.h:157 net/ipv4/route.c:482)
[  234.338935] __ip_select_ident (include/uapi/linux/swab.h:49 (discriminator 3) net/ipv4/route.c:498 (discriminator 3))
[  234.340773] __ip_make_skb (include/net/ip.h:339 include/net/ip.h:345 net/ipv4/ip_output.c:1386)
[  234.342736] ip_push_pending_frames (include/net/ip.h:148 net/ipv4/ip_output.c:1430)
[  234.344707] raw_sendmsg (net/ipv4/raw.c:644)
[  234.346537] ? system_call_fastpath (arch/x86/kernel/entry_64.S:423)
[  234.348431] ? get_parent_ip (kernel/sched/core.c:2564)
[  234.350259] ? preempt_count_sub (kernel/sched/core.c:2620)
[  234.352170] inet_sendmsg (net/ipv4/af_inet.c:734)
[  234.354107] do_sock_sendmsg (net/socket.c:646 (discriminator 4))
[  234.355947] ? retint_restore_args (arch/x86/kernel/entry_64.S:844)
[  234.357962] ___sys_sendmsg (net/socket.c:653 net/socket.c:2094)
[  234.359545] ? sched_clock (./arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:304)
[  234.361182] ? __acct_update_integrals (kernel/tsacct.c:147)
[  234.363394] ? acct_account_cputime (kernel/tsacct.c:168)
[  234.365417] __sys_sendmsg (net/socket.c:2131)
[  234.367248] SyS_sendmsg (net/socket.c:2136)
[  234.368925] system_call_fastpath (arch/x86/kernel/entry_64.S:423)
[  234.371038] ================================================================================


Thanks,
Sasha
