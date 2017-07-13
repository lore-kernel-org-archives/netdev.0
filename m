From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [BUG]: NULL ptr dereference in xlog_cil_push+0x274/0x430
Date: Thu, 13 Jul 2017 18:16:59 +0300
Message-ID: <5b222419-b589-4597-e9f4-d4e415d0405e@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Vagin <avagin@virtuozzo.com>, netdev@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

We run CRIU tests on linux-next tree and today we found this issue.

CRIU tests are the set of small programs to check checkpoint/restore
of different primitives (files, sockets, signals, pipes, etc).
https://github.com/xemul/criu/tree/master/test

Each test is executed three times: without namespaces, in a set of all
namespaces except userns, in a set of all namespaces. When a test
passed the preparation tests, it sends a signal to an executer, and
then the executer dumps and restores tests processes, and sends a
signal to the test back to check that everything are restored
correctly.

===================== Run zdtm/transition/unix_sock in ns 
======================
Start test
./unix_sock --pidfile=unix_sock.pid --outfile=unix_sock.out 
--filename=unix_sock.test
Run criu dump
[   57.647284] writing to auto_msgmni has no effect
[   60.730380] criu (2023) used greatest stack depth: 11808 bytes left
Run criu restore
[   60.993529] BUG: unable to handle kernel NULL pointer dereference at 
          (null)
[   60.994221] IP: skb_queue_tail+0x2e/0x50
[   60.994589] PGD 71070067
[   60.994590] P4D 71070067
[   60.994854] PUD 71071067
[   60.995102] PMD 0
[   60.995352]
[   60.995694] Oops: 0002 [#1] SMP
[   60.996004] CPU: 0 PID: 2053 Comm: unix_sock Not tainted 
4.12.0-next-20170713 #6
[   60.996706] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.10.2-20170228_101828-anatol 04/01/2014
[   60.997657] task: ffff880074748c80 task.stack: ffffc90000594000
[   60.998208] RIP: 0010:skb_queue_tail+0x2e/0x50
[   60.998614] RSP: 0018:ffffc90000597cf8 EFLAGS: 00010046
[   60.999132] RAX: 0000000000000246 RBX: ffff88006f3fa0c8 RCX: 
0000000000000000
[   60.999797] RDX: 0000000000000000 RSI: 0000000000000246 RDI: 
ffff88006f3fa0dc
[   61.000455] RBP: ffffc90000597d10 R08: ffffc90000597e50 R09: 
0000000000000000
[   61.001114] R10: ffff880072daea00 R11: ffff88007d002d80 R12: 
ffff880072daea00
[   61.001772] R13: ffff88006f3fa0dc R14: ffff88006f3fa000 R15: 
0000000000000001
[   61.002451] FS:  0000000000000000(0000) GS:ffff88007fc00000(0063) 
knlGS:00000000f7f7b380
[   61.003198] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[   61.003735] CR2: 0000000000000000 CR3: 000000007106f000 CR4: 
00000000000006f0
[   61.004393] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[   61.005050] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[   61.005717] Call Trace:
[   61.005952]  unix_stream_sendmsg+0x1c1/0x380
[   61.006345]  sock_sendmsg+0x33/0x40
[   61.006667]  sock_write_iter+0x7d/0xc0
[   61.007032]  __vfs_write+0xcd/0x120
[   61.007353]  vfs_write+0xac/0x1a0
[   61.007677]  SyS_write+0x41/0xa0
[   61.007996]  do_fast_syscall_32+0x8b/0x15c
[   61.008371]  entry_SYSENTER_compat+0x4c/0x5b
[   61.008781] RIP: 0023:0xf7f7faf9
[   61.009082] RSP: 002b:00000000fffd62f8 EFLAGS: 00000246 ORIG_RAX: 
0000000000000004
[   61.009811] RAX: ffffffffffffffda RBX: 0000000000000004 RCX: 
00000000fffd6738
[   61.010453] RDX: 00000000000003e8 RSI: 00000000fffd63b8 RDI: 
00000000fffd6749
[   61.011116] RBP: 00000000fffd6b38 R08: 0000000000000000 R09: 
0000000000000000
[   61.011795] R10: 0000000000000000 R11: 0000000000000000 R12: 
0000000000000000
[   61.012378] R13: 0000000000000000 R14: 0000000000000000 R15: 
0000000000000000
[   61.013027] Code: e5 41 55 4c 8d 6f 14 41 54 53 48 89 fb 4c 89 ef 49 
89 f4 e8 85 d3 21 00 48 8b 53 08 49 89 1c 24 4c 89 ef 48 89 c6 49 89 54 
24 08 <4c> 89 22 83 43 10 01 4c 89 63 08 e8 22 d4 21 00 5b 41 5c 41 5d
[   61.014778] RIP: skb_queue_tail+0x2e/0x50 RSP: ffffc90000597cf8
[   61.015333] CR2: 0000000000000000
[   61.015639] ---[ end trace efd0a4201d4b29fc ]---

The bug is easily (5/5) reproduced on next-20170713 with the following:

git clone https://github.com/xemul/criu.git
cd criu && git checkout criu-dev
COMPAT_TEST=y make -j5 zdtm
for i in `seq 1 2`; do ./test/zdtm.py run -t zdtm/transition/unix_sock 
-f ns ; done

-- 
              Dmitry
