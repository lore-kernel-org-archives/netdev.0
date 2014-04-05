From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: pptp: bad RCU usage and use after free
Date: Sat, 05 Apr 2014 11:52:41 -0400
Message-ID: <534026C9.5010201@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: xeb@mail.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I've stumbled on the following spew:

[ 2513.440938] BUG: unable to handle kernel paging request at ffff88006dca0e78
[ 2513.442119] IP: pptp_connect (drivers/net/ppp/pptp.c:125 drivers/net/ppp/pptp.c:447)
[ 2513.443062] PGD 3c91c067 PUD 102fc82067 PMD 102fb13067 PTE 800000006dca0060
[ 2513.444528] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 2513.445288] Dumping ftrace buffer:
[ 2513.445690]    (ftrace buffer empty)
[ 2513.446082] Modules linked in:
[ 2513.446463] CPU: 8 PID: 26834 Comm: trinity-c27 Not tainted 3.14.0-next-20140403-sas
ha-00019-g7474aa9-dirty #376
[ 2513.447770] task: ffff88061287b000 ti: ffff880623ba6000 task.ti: ffff880623ba6000
[ 2513.448564] RIP: pptp_connect (drivers/net/ppp/pptp.c:125 drivers/net/ppp/pptp.c:447)
0x3f0
[ 2513.449456] RSP: 0018:ffff880623ba7e38  EFLAGS: 00010286
[ 2513.450019] RAX: 0000000000000001 RBX: 0000000000000001 RCX: 0000000000000001
[ 2513.450049] RDX: 0000000000000001 RSI: ffffffffb9e88100 RDI: 0000000000000282
[ 2513.450049] RBP: ffff880623ba7ea8 R08: ffffffffbc7cb980 R09: 0000000000000000
[ 2513.450049] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000050
[ 2513.450049] R13: 000000003fb518d9 R14: ffff88006dca0948 R15: ffff880623ba7ec0
[ 2513.450049] FS:  00007fd118f90700(0000) GS:ffff8804abc00000(0000) knlGS:000000000000
0000
[ 2513.450049] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2513.450049] CR2: ffff88006dca0e78 CR3: 00000006176ba000 CR4: 00000000000006a0
[ 2513.450049] DR0: 0000000000696000 DR1: 0000000000696000 DR2: 0000000000000000
[ 2513.450049] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
[ 2513.450049] Stack:
[ 2513.450049]  ffffffffb6b92031 000000000000002a ffff880623ba7e78 ffff880424966f60
[ 2513.450049]  ffffffffb52aa08a ffffffff00004000 ffff880623ba7eb8 0000000000000010
[ 2513.450049]  ffff880623ba7ea8 ffff880071391600 0000000000000010 0000000001d7f740
[ 2513.450049] Call Trace:
[ 2513.450049] ? pptp_connect (drivers/net/ppp/pptp.c:447)
[ 2513.450049] ? might_fault (mm/memory.c:4327)
[ 2513.450049] SYSC_connect (net/socket.c:1701)
[ 2513.450049] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
[ 2513.450049] ? trace_hardirqs_on (kernel/locking/lockdep.c:2607)
[ 2513.450049] ? syscall_trace_enter (include/linux/context_tracking.h:27 arch/x86/kernel/ptrace.c:1461)
[ 2513.450049] SyS_connect (net/socket.c:1683)
[ 2513.450049] tracesys (arch/x86/kernel/entry_64.S:749)
[ 2513.450049] Code: 1f 80 00 00 00 00 48 c7 c2 68 bf 69 b9 be 79 00 00 00 48 c7 c7 0e d2 84 b9 c6 05 ee 4f 3f 04 01 e8 e1 dc 62 fe 90 4d 85 f6 74 13 <66> 45 3b a6 30 05 00 00 75 09 45 3b ae 34 05 00 00 74 10 83 c3
[ 2513.450049] RIP pptp_connect (drivers/net/ppp/pptp.c:125 drivers/net/ppp/pptp.c:447)
[ 2513.450049]  RSP <ffff880623ba7e38>
[ 2513.450049] CR2: ffff88006dca0e78

My guess is that we're racing the synchronize_rcu() in del_chan() with
the RCU protected read in lookup_chan_dst():

pptp_release()
	del_chan()				lookup_chan_dst()
		enter synchronize_rcu()
							sock = rcu_dereference(...)
		exit synchronize_rcu()
	release_sock()
	sock_put()
							opt = &sock->proto.pptp;
							[ boom ]


"Guess" because I couldn't properly reproduce the issue to confirm it,
however - I don't have a different guess at what might be off and I'd like
someone to confirm that guess before I go ahead and send patches out.


Thanks,
Sasha
