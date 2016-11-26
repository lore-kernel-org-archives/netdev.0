From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: BUG in unix_notinflight
Date: Sat, 26 Nov 2016 19:05:23 +0100
Message-ID: <CACT4Y+b5_zcRVrq5yRmtkVUgnzOmq55upA_QCoLrkSDnT0cLHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am hitting the following BUG while running syzkaller fuzzer:

kernel BUG at net/unix/garbage.c:149!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 23491 Comm: syz-executor Not tainted 4.9.0-rc5+ #41
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
task: ffff8801c16b06c0 task.stack: ffff8801c2928000
RIP: 0010:[<ffffffff8717ebf4>]  [<ffffffff8717ebf4>]
unix_notinflight+0x3b4/0x490 net/unix/garbage.c:149
RSP: 0018:ffff8801c292ea40  EFLAGS: 00010297
RAX: ffff8801c16b06c0 RBX: 1ffff10038525d4a RCX: dffffc0000000000
RDX: 0000000000000000 RSI: 1ffff10038525d4e RDI: ffffffff8a6e9d84
RBP: ffff8801c292eb18 R08: 0000000000000000 R09: 0000000000000000
R10: cdca594876e035a1 R11: 0000000000000005 R12: 1ffff10038525d4e
R13: ffffffff899156e0 R14: ffff8801c292eaf0 R15: ffff88018b7cd780
FS:  00007f10420fa700(0000) GS:ffff8801d9800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000002000a000 CR3: 00000001c2ecc000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000400 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Stack:
 dffffc0000000000 ffff88019f036970 0000000041b58ab3 ffffffff894c5120
 ffffffff8717e840 ffff8801c16b06c0 ffff88018b7cdcf0 ffffffff894c51e2
 ffffffff81576d50 0000000000000000 ffffffff00000000 1ffff10000000000
Call Trace:
 [<ffffffff8716cfbf>] unix_detach_fds.isra.19+0xff/0x170 net/unix/af_unix.c:1487
 [<ffffffff8716f6a9>] unix_destruct_scm+0xf9/0x210 net/unix/af_unix.c:1496
 [<ffffffff86a90a01>] skb_release_head_state+0x101/0x200 net/core/skbuff.c:655
 [<ffffffff86a9808a>] skb_release_all+0x1a/0x60 net/core/skbuff.c:668
 [<ffffffff86a980ea>] __kfree_skb+0x1a/0x30 net/core/skbuff.c:684
 [<ffffffff86a98284>] kfree_skb+0x184/0x570 net/core/skbuff.c:705
 [<ffffffff871789d5>] unix_release_sock+0x5b5/0xbd0 net/unix/af_unix.c:559
 [<ffffffff87179039>] unix_release+0x49/0x90 net/unix/af_unix.c:836
 [<ffffffff86a694b2>] sock_release+0x92/0x1f0 net/socket.c:570
 [<ffffffff86a6962b>] sock_close+0x1b/0x20 net/socket.c:1017
 [<ffffffff81a76b8e>] __fput+0x34e/0x910 fs/file_table.c:208
 [<ffffffff81a771da>] ____fput+0x1a/0x20 fs/file_table.c:244
 [<ffffffff81483ab0>] task_work_run+0x1a0/0x280 kernel/task_work.c:116
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff8141287a>] do_exit+0x183a/0x2640 kernel/exit.c:828
 [<ffffffff8141383e>] do_group_exit+0x14e/0x420 kernel/exit.c:931
 [<ffffffff814429d3>] get_signal+0x663/0x1880 kernel/signal.c:2307
 [<ffffffff81239b45>] do_signal+0xc5/0x2190 arch/x86/kernel/signal.c:807
 [<ffffffff8100666a>] exit_to_usermode_loop+0x1ea/0x2d0
arch/x86/entry/common.c:156
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
 [<ffffffff81009693>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
 [<ffffffff881478e6>] entry_SYSCALL_64_fastpath+0xc4/0xc6
Code: df 49 89 87 70 05 00 00 41 c6 04 14 f8 48 89 f9 48 c1 e9 03 80
3c 11 00 75 64 49 89 87 78 05 00 00 e9 65 ff ff ff e8 ac 94 56 fa <0f>
0b 48 89 d7 48 89 95 30 ff ff ff e8 bb 22 87 fa 48 8b 95 30
RIP  [<ffffffff8717ebf4>] unix_notinflight+0x3b4/0x490 net/unix/garbage.c:149
 RSP <ffff8801c292ea40>
---[ end trace 4cbbd52674b68dab ]---


On commit 16ae16c6e5616c084168740990fc508bda6655d4 (Nov 24).
Unfortunately this is not reproducible outside of syzkaller.
But easily reproducible with syzkaller. If you need to reproduce it,
follow instructions described here:
https://github.com/google/syzkaller/wiki/How-to-execute-syzkaller-programs
With the following as the program:

mmap(&(0x7f0000000000/0xdd5000)=nil, (0xdd5000), 0x3, 0x32,
0xffffffffffffffff, 0x0)
socketpair$unix(0x1, 0x5, 0x0, &(0x7f0000dc7000-0x8)={<r0=>0x0, <r1=>0x0})
sendmmsg$unix(r1,
&(0x7f0000dbf000-0xa8)=[{&(0x7f0000dbe000)=@file={0x1, ""}, 0x2,
&(0x7f0000dbe000)=[], 0x0, &(0x7f0000dc4000)=[@rights={0x20, 0x1, 0x1,
[r0, r0, r0, r1]}, @rights={0x14, 0x1, 0x1, [0xffffffffffffffff]},
@cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}, @cred={0x20, 0x1, 0x2, 0x0,
0x0, 0x0}, @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}], 0x5, 0x800},
{&(0x7f0000dbf000-0x7d)=@file={0x1, ""}, 0x2, &(0x7f0000dbe000)=[],
0x0, &(0x7f0000dbf000-0x80)=[@rights={0x20, 0x1, 0x1,
[0xffffffffffffffff, r1, 0xffffffffffffffff, r0]}, @cred={0x20, 0x1,
0x2, 0x0, 0x0, 0x0}, @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0},
@cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}], 0x4, 0x4},
{&(0x7f0000dbf000-0x8)=@abs={0x0, 0x0, 0x8}, 0x8,
&(0x7f0000dbe000)=[{&(0x7f0000dc0000-0x27)="", 0x0},
{&(0x7f0000dc1000-0xb0)="", 0x0}, {&(0x7f0000dc2000-0xc4)="", 0x0},
{&(0x7f0000dc2000)="", 0x0}, {&(0x7f0000dc3000)="", 0x0}], 0x5,
&(0x7f0000dbe000)=[@cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0},
@rights={0x14, 0x1, 0x1, [r1]}, @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0},
@cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}], 0x4, 0x4}], 0x3, 0x800)
dup3(r1, r0, 0x80000)
close(r1)
