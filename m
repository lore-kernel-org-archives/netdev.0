From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: BUG in unix_notinflight
Date: Mon, 6 Mar 2017 11:40:49 +0100
Message-ID: <CACT4Y+bCvPdn3i-nuBCbPyHUuOjyh83KyLFzWR+8JDGqM0F2ww@mail.gmail.com>
References: <CACT4Y+b5_zcRVrq5yRmtkVUgnzOmq55upA_QCoLrkSDnT0cLHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+b5_zcRVrq5yRmtkVUgnzOmq55upA_QCoLrkSDnT0cLHA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 26, 2016 at 7:05 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> I am hitting the following BUG while running syzkaller fuzzer:
>
> kernel BUG at net/unix/garbage.c:149!
> invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 23491 Comm: syz-executor Not tainted 4.9.0-rc5+ #41
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> task: ffff8801c16b06c0 task.stack: ffff8801c2928000
> RIP: 0010:[<ffffffff8717ebf4>]  [<ffffffff8717ebf4>]
> unix_notinflight+0x3b4/0x490 net/unix/garbage.c:149
> RSP: 0018:ffff8801c292ea40  EFLAGS: 00010297
> RAX: ffff8801c16b06c0 RBX: 1ffff10038525d4a RCX: dffffc0000000000
> RDX: 0000000000000000 RSI: 1ffff10038525d4e RDI: ffffffff8a6e9d84
> RBP: ffff8801c292eb18 R08: 0000000000000000 R09: 0000000000000000
> R10: cdca594876e035a1 R11: 0000000000000005 R12: 1ffff10038525d4e
> R13: ffffffff899156e0 R14: ffff8801c292eaf0 R15: ffff88018b7cd780
> FS:  00007f10420fa700(0000) GS:ffff8801d9800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000002000a000 CR3: 00000001c2ecc000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000400 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Stack:
>  dffffc0000000000 ffff88019f036970 0000000041b58ab3 ffffffff894c5120
>  ffffffff8717e840 ffff8801c16b06c0 ffff88018b7cdcf0 ffffffff894c51e2
>  ffffffff81576d50 0000000000000000 ffffffff00000000 1ffff10000000000
> Call Trace:
>  [<ffffffff8716cfbf>] unix_detach_fds.isra.19+0xff/0x170 net/unix/af_unix.c:1487
>  [<ffffffff8716f6a9>] unix_destruct_scm+0xf9/0x210 net/unix/af_unix.c:1496
>  [<ffffffff86a90a01>] skb_release_head_state+0x101/0x200 net/core/skbuff.c:655
>  [<ffffffff86a9808a>] skb_release_all+0x1a/0x60 net/core/skbuff.c:668
>  [<ffffffff86a980ea>] __kfree_skb+0x1a/0x30 net/core/skbuff.c:684
>  [<ffffffff86a98284>] kfree_skb+0x184/0x570 net/core/skbuff.c:705
>  [<ffffffff871789d5>] unix_release_sock+0x5b5/0xbd0 net/unix/af_unix.c:559
>  [<ffffffff87179039>] unix_release+0x49/0x90 net/unix/af_unix.c:836
>  [<ffffffff86a694b2>] sock_release+0x92/0x1f0 net/socket.c:570
>  [<ffffffff86a6962b>] sock_close+0x1b/0x20 net/socket.c:1017
>  [<ffffffff81a76b8e>] __fput+0x34e/0x910 fs/file_table.c:208
>  [<ffffffff81a771da>] ____fput+0x1a/0x20 fs/file_table.c:244
>  [<ffffffff81483ab0>] task_work_run+0x1a0/0x280 kernel/task_work.c:116
>  [<     inline     >] exit_task_work include/linux/task_work.h:21
>  [<ffffffff8141287a>] do_exit+0x183a/0x2640 kernel/exit.c:828
>  [<ffffffff8141383e>] do_group_exit+0x14e/0x420 kernel/exit.c:931
>  [<ffffffff814429d3>] get_signal+0x663/0x1880 kernel/signal.c:2307
>  [<ffffffff81239b45>] do_signal+0xc5/0x2190 arch/x86/kernel/signal.c:807
>  [<ffffffff8100666a>] exit_to_usermode_loop+0x1ea/0x2d0
> arch/x86/entry/common.c:156
>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>  [<ffffffff81009693>] syscall_return_slowpath+0x4d3/0x570
> arch/x86/entry/common.c:259
>  [<ffffffff881478e6>] entry_SYSCALL_64_fastpath+0xc4/0xc6
> Code: df 49 89 87 70 05 00 00 41 c6 04 14 f8 48 89 f9 48 c1 e9 03 80
> 3c 11 00 75 64 49 89 87 78 05 00 00 e9 65 ff ff ff e8 ac 94 56 fa <0f>
> 0b 48 89 d7 48 89 95 30 ff ff ff e8 bb 22 87 fa 48 8b 95 30
> RIP  [<ffffffff8717ebf4>] unix_notinflight+0x3b4/0x490 net/unix/garbage.c:149
>  RSP <ffff8801c292ea40>
> ---[ end trace 4cbbd52674b68dab ]---
>
>
> On commit 16ae16c6e5616c084168740990fc508bda6655d4 (Nov 24).
> Unfortunately this is not reproducible outside of syzkaller.
> But easily reproducible with syzkaller. If you need to reproduce it,
> follow instructions described here:
> https://github.com/google/syzkaller/wiki/How-to-execute-syzkaller-programs
> With the following as the program:
>
> mmap(&(0x7f0000000000/0xdd5000)=nil, (0xdd5000), 0x3, 0x32,
> 0xffffffffffffffff, 0x0)
> socketpair$unix(0x1, 0x5, 0x0, &(0x7f0000dc7000-0x8)={<r0=>0x0, <r1=>0x0})
> sendmmsg$unix(r1,
> &(0x7f0000dbf000-0xa8)=[{&(0x7f0000dbe000)=@file={0x1, ""}, 0x2,
> &(0x7f0000dbe000)=[], 0x0, &(0x7f0000dc4000)=[@rights={0x20, 0x1, 0x1,
> [r0, r0, r0, r1]}, @rights={0x14, 0x1, 0x1, [0xffffffffffffffff]},
> @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}, @cred={0x20, 0x1, 0x2, 0x0,
> 0x0, 0x0}, @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}], 0x5, 0x800},
> {&(0x7f0000dbf000-0x7d)=@file={0x1, ""}, 0x2, &(0x7f0000dbe000)=[],
> 0x0, &(0x7f0000dbf000-0x80)=[@rights={0x20, 0x1, 0x1,
> [0xffffffffffffffff, r1, 0xffffffffffffffff, r0]}, @cred={0x20, 0x1,
> 0x2, 0x0, 0x0, 0x0}, @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0},
> @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}], 0x4, 0x4},
> {&(0x7f0000dbf000-0x8)=@abs={0x0, 0x0, 0x8}, 0x8,
> &(0x7f0000dbe000)=[{&(0x7f0000dc0000-0x27)="", 0x0},
> {&(0x7f0000dc1000-0xb0)="", 0x0}, {&(0x7f0000dc2000-0xc4)="", 0x0},
> {&(0x7f0000dc2000)="", 0x0}, {&(0x7f0000dc3000)="", 0x0}], 0x5,
> &(0x7f0000dbe000)=[@cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0},
> @rights={0x14, 0x1, 0x1, [r1]}, @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0},
> @cred={0x20, 0x1, 0x2, 0x0, 0x0, 0x0}], 0x4, 0x4}], 0x3, 0x800)
> dup3(r1, r0, 0x80000)
> close(r1)



Now with a nice single-threaded C reproducer!

// autogenerated by syzkaller (http://github.com/google/syzkaller)
#define _GNU_SOURCE
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void test()
{
  long r[54];
  memset(r, -1, sizeof(r));
  syscall(__NR_mmap, 0x20000000ul, 0xfff000ul, 0x3ul, 0x32ul, -1, 0);
  r[1] = syscall(__NR_socketpair, 0x1ul, 0x5ul, 0x0ul, 0x20521ff8ul);
  r[2] = *(uint32_t*)0x20521ff8;
  r[3] = *(uint32_t*)0x20521ffc;
  r[5] = syscall(__NR_open, "/dev/net/tun", 0x200000ul);
  r[6] = syscall(__NR_socketpair, 0x1ul, 0x5ul, 0x0ul,
                         0x20d85000ul, 0, 0, 0, 0, 0);
  r[7] = *(uint32_t*)0x20d85000;
  (*(uint64_t*)0x20000fc8 = (uint64_t)0x20000000);
  (*(uint32_t*)0x20000fd0 = (uint32_t)0xa);
  (*(uint64_t*)0x20000fd8 = (uint64_t)0x2005d000);
  (*(uint64_t*)0x20000fe0 = (uint64_t)0x8);
  (*(uint64_t*)0x20000fe8 = (uint64_t)0x20000ff0);
  (*(uint64_t*)0x20000ff0 = (uint64_t)0x1);
  (*(uint32_t*)0x20000ff8 = (uint32_t)0x0);
  (*(uint16_t*)0x20000000 = (uint16_t)0x1);
  memcpy((void*)0x20000002, "\x2e\x2f\x66\x69\x6c\x65\x30\x00", 8);
  (*(uint64_t*)0x2005d000 = (uint64_t)0x20784f06);
  (*(uint64_t*)0x2005d008 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d010 = (uint64_t)0x209a5f78);
  (*(uint64_t*)0x2005d018 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d020 = (uint64_t)0x20ec3ffc);
  (*(uint64_t*)0x2005d028 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d030 = (uint64_t)0x2057e000);
  (*(uint64_t*)0x2005d038 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d040 = (uint64_t)0x200c9f9d);
  (*(uint64_t*)0x2005d048 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d050 = (uint64_t)0x20331000);
  (*(uint64_t*)0x2005d058 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d060 = (uint64_t)0x206a1f7b);
  (*(uint64_t*)0x2005d068 = (uint64_t)0x0);
  (*(uint64_t*)0x2005d070 = (uint64_t)0x20e7f000);
  (*(uint64_t*)0x2005d078 = (uint64_t)0x0);
  (*(uint64_t*)0x20000ff0 = (uint64_t)0x18);
  (*(uint32_t*)0x20000ff8 = (uint32_t)0x1);
  (*(uint32_t*)0x20000ffc = (uint32_t)0x1);
  (*(uint32_t*)0x20001000 = r[5]);
  (*(uint32_t*)0x20001004 = r[7]);
  syscall(__NR_sendmsg, r[7], 0x20000fc8ul, 0x0ul);
  (*(uint64_t*)0x20000fc8 = (uint64_t)0x20000000);
  (*(uint32_t*)0x20000fd0 = (uint32_t)0x8);
  (*(uint64_t*)0x20000fd8 = (uint64_t)0x20026000);
  (*(uint64_t*)0x20000fe0 = (uint64_t)0x0);
  (*(uint64_t*)0x20000fe8 = (uint64_t)0x20000ff0);
  (*(uint64_t*)0x20000ff0 = (uint64_t)0x1);
  (*(uint32_t*)0x20000ff8 = (uint32_t)0x0);
  (*(uint16_t*)0x20000000 = (uint16_t)0x0);
  (*(uint8_t*)0x20000002 = (uint8_t)0x0);
  (*(uint32_t*)0x20000004 = (uint32_t)0x4e20);
  (*(uint64_t*)0x20000ff0 = (uint64_t)0x18);
  (*(uint32_t*)0x20000ff8 = (uint32_t)0x1);
  (*(uint32_t*)0x20000ffc = (uint32_t)0x1);
  (*(uint32_t*)0x20001000 = r[2]);
  syscall(__NR_sendmsg, r[3], 0x20000fc8ul, 0x0ul);
}

int main()
{
  int i, pid, status;
  for (i = 0; i < 4; i++) {
    if (fork() == 0) {
      for (;;) {
        pid = fork();
        if (pid == 0) {
          test();
          exit(0);
        }
        while (waitpid(pid, &status, __WALL) != pid) {}
      }
    }
  }
  sleep(1000000);
  return 0;
}



New report from linux-next/c0b7b2b33bd17f7155956d0338ce92615da686c9

------------[ cut here ]------------
kernel BUG at net/unix/garbage.c:149!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 1806 Comm: syz-executor7 Not tainted 4.10.0-next-20170303+ #6
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
task: ffff880121c64740 task.stack: ffff88012c9e8000
RIP: 0010:unix_notinflight+0x417/0x5d0 net/unix/garbage.c:149
RSP: 0018:ffff88012c9ef0f8 EFLAGS: 00010297
RAX: ffff880121c64740 RBX: 1ffff1002593de23 RCX: ffff8801c490c628
RDX: 0000000000000000 RSI: 1ffff1002593de27 RDI: ffffffff8557e504
RBP: ffff88012c9ef220 R08: 0000000000000001 R09: 0000000000000000
R10: dffffc0000000000 R11: ffffed002593de55 R12: ffff8801c490c0c0
R13: ffff88012c9ef1f8 R14: ffffffff85101620 R15: dffffc0000000000
FS:  00000000013d3940(0000) GS:ffff8801dbe00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000001fd8cd8 CR3: 00000001cce69000 CR4: 00000000001426f0
Call Trace:
 unix_detach_fds.isra.23+0xfa/0x170 net/unix/af_unix.c:1490
 unix_destruct_scm+0xf4/0x200 net/unix/af_unix.c:1499
 skb_release_head_state+0xfc/0x200 net/core/skbuff.c:654
 skb_release_all+0x15/0x60 net/core/skbuff.c:667
 __kfree_skb+0x15/0x20 net/core/skbuff.c:683
 kfree_skb+0x16e/0x4c0 net/core/skbuff.c:704
 unix_release_sock+0x5b0/0xbb0 net/unix/af_unix.c:560
 unix_release+0x44/0x90 net/unix/af_unix.c:834
 sock_release+0x8d/0x1e0 net/socket.c:597
 sock_close+0x16/0x20 net/socket.c:1061
 __fput+0x332/0x7f0 fs/file_table.c:208
 ____fput+0x15/0x20 fs/file_table.c:244
 task_work_run+0x18a/0x260 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0x1956/0x2900 kernel/exit.c:873
 do_group_exit+0x149/0x420 kernel/exit.c:977
 SYSC_exit_group kernel/exit.c:988 [inline]
 SyS_exit_group+0x1d/0x20 kernel/exit.c:986
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x44fb79
RSP: 002b:0000000000a5fe20 EFLAGS: 00000216 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 000000000044fb79
RDX: 000000000044fb79 RSI: 0000000000753618 RDI: 0000000000000000
RBP: 0000000000002d2b R08: 0000000000708000 R09: 0000000000000000
R10: 0000000000753610 R11: 0000000000000216 R12: 00000000013d390c
R13: 0000000000000000 R14: 00000000000003aa R15: 000000000000001d
Code: 00 00 41 c6 04 07 f8 80 3c 01 00 75 70 49 89 94 24 70 05 00 00
e8 da ef c6 fd 83 2d 03 17 57 03 01 e9 db fc ff ff e8 c9 ef c6 fd <0f>
0b 4c 89 ff e8 5f a6 f7 fd e9 a4 fc ff ff e8 85 a6 f7 fd e9
RIP: unix_notinflight+0x417/0x5d0 net/unix/garbage.c:149 RSP: ffff88012c9ef0f8
---[ end trace db99655ac68455d5 ]---
