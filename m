From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: WARNING in tcp_recvmsg
Date: Tue, 12 Jan 2016 11:54:19 +0100
Message-ID: <CACT4Y+bkc46p7wgGsDwxAqpBRvObbWQ5wD-1r1h58D4yByrDJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've hit the WARNING in tcp_recvmsg again while running syzkaller fuzzer:
  WARN_ON(tp->copied_seq != tp->rcv_nxt &&
                      !(flags & (MSG_PEEK | MSG_TRUNC)));
Now on commit afd2ff9b7e1b367172f18ba7f693dfb62bdcb2dc (Jan 10). This
is with https://groups.google.com/d/msg/syzkaller/vlk-2b1hAVQ/JpkM7K36DQAJ
fixed. But unfortunately I cannot reproduce it. The program that
triggered it was something along the lines of (but with syscalls
executed chaotically concurrently):
https://gist.githubusercontent.com/dvyukov/0bfc7714a09769ed80c0/raw/b3e9aacac6386b08c2096b5121a3b56d8204a1d9/gistfile1.txt
So maybe if you see something obvious in the code...

------------[ cut here ]------------
WARNING: CPU: 1 PID: 30853 at net/ipv4/tcp.c:1728 tcp_recvmsg+0x1a9f/0x2c50()
Modules linked in:
CPU: 1 PID: 30853 Comm: syz-executor Not tainted 4.4.0-rc8+ #218
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff8800515776e0 ffffffff82904c8d 0000000000000000
 ffff88006248af00 ffffffff868d3940 ffff880051577720 ffffffff8133e979
 ffffffff850c663f ffffffff868d3940 00000000000006c0 00000000054cf464
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82904c8d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<ffffffff8133e979>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:483
 [<ffffffff8133eba9>] warn_slowpath_null+0x29/0x30 kernel/panic.c:516
 [<ffffffff850c663f>] tcp_recvmsg+0x1a9f/0x2c50 net/ipv4/tcp.c:1727
 [<ffffffff85184d89>] inet_recvmsg+0x2f9/0x4a0 net/ipv4/af_inet.c:767
 [<     inline     >] sock_recvmsg_nosec net/socket.c:713
 [<ffffffff84d3a85d>] sock_recvmsg+0x9d/0xb0 net/socket.c:721
 [<ffffffff84d3db89>] ___sys_recvmsg+0x259/0x540 net/socket.c:2099
 [<ffffffff84d40039>] __sys_recvmmsg+0x219/0x7b0 net/socket.c:2205
 [<     inline     >] SYSC_recvmmsg net/socket.c:2279
 [<ffffffff84d4073f>] SyS_recvmmsg+0x16f/0x180 net/socket.c:2268
 [<ffffffff85e745b6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
---[ end trace 3a67e167dc3f4872 ]---
