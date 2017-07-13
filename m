From: Dave Jones <davej@codemonkey.org.uk>
Subject: sctp refcount bug.
Date: Thu, 13 Jul 2017 10:36:39 -0400
Message-ID: <20170713143639.kbfqyasw4z4kjzsf@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:51820 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbdGMOgm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 10:36:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hit this on Linus' current tree.


refcount_t: underflow; use-after-free.
------------[ cut here ]------------
WARNING: CPU: 2 PID: 14455 at lib/refcount.c:186 refcount_sub_and_test+0x45/0x50
CPU: 2 PID: 14455 Comm: trinity-c46 Tainted: G      D         4.12.0-think+ #11 
task: ffff8804fc71b8c0 task.stack: ffffc90002328000
RIP: 0010:refcount_sub_and_test+0x45/0x50
RSP: 0018:ffffc9000232ba58 EFLAGS: 00010282
RAX: 0000000000000026 RBX: ffff88001db1d1c0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff88050a3ccca8 RDI: ffff88050a3ccca8
RBP: ffffc9000232ba58 R08: 0000000000000000 R09: 0000000000000001
R10: ffffc9000232ba88 R11: 0000000000000000 R12: ffff88000d3f9b40
R13: ffff880456948008 R14: ffff880456948870 R15: ffffc9000232bd10
FS:  00007f79b1032700(0000) GS:ffff88050a200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000008436726348 CR3: 000000022cc87000 CR4: 00000000001406e0
DR0: 00007f731068f000 DR1: 00007f2d83eb9000 DR2: 00007f302340e000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 sctp_wfree+0x5d/0x190 [sctp]
 skb_release_head_state+0x64/0xc0
 skb_release_all+0x12/0x30
 consume_skb+0x50/0x170
 sctp_chunk_put+0x59/0x80 [sctp]
 sctp_chunk_free+0x26/0x30 [sctp]
 __sctp_outq_teardown+0x1d8/0x270 [sctp]
 sctp_outq_free+0xe/0x10 [sctp]
 sctp_association_free+0x92/0x220 [sctp]
 sctp_do_sm+0x12a6/0x1920 [sctp]
 ? __get_user_4+0x18/0x20
 ? no_context+0x3f/0x360
 ? lock_acquire+0xe7/0x1e0
 ? skb_dequeue+0x1d/0x70
 sctp_primitive_SHUTDOWN+0x33/0x40 [sctp]
 sctp_close+0x26e/0x2a0 [sctp]
 inet_release+0x3c/0x60
 sock_release+0x1f/0x80
 sock_close+0x12/0x20
 __fput+0xf8/0x200
 ____fput+0xe/0x10
 task_work_run+0x85/0xc0
 exit_to_usermode_loop+0xa8/0xb0
 do_syscall_64+0x151/0x190
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f79b095b1e9
RSP: 002b:00007ffc5eca3088 EFLAGS: 00000246
 ORIG_RAX: 0000000000000120
RAX: fffffffffffffff2 RBX: 0000000000000120 RCX: 00007f79b095b1e9
RDX: 000000000000006e RSI: 0000008436738120 RDI: 0000000000000130
RBP: 00007ffc5eca3130 R08: 0000000000000000 R09: 0000000000000ff0
R10: 0000000000080800 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f79b0ee9058 R14: 00007f79b1032698 R15: 00007f79b0ee9000
Code: 75 e6 85 d2 0f 94 c0 c3 31 c0 c3 80 3d ce 95 bc 00 00 75 f4 55 48 c7 c7 00 d9 ee 81 48 89 e5 c6 05 ba 95 bc 00 01 e8 fc 2c c0 ff <0f> ff 31 c0 5d c3 0f 1f 44 00 00 55 48 89 fe bf 01 00 00 00 48 
---[ end trace 19b7bd878c0f56fd ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 14455 at net/ipv4/af_inet.c:154 inet_sock_destruct+0x1b8/0x1f0
CPU: 2 PID: 14455 Comm: trinity-c46 Tainted: G      D W       4.12.0-think+ #11 
task: ffff8804fc71b8c0 task.stack: ffffc90002328000
RIP: 0010:inet_sock_destruct+0x1b8/0x1f0
RSP: 0018:ffffc9000232bcf8 EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff88000d3f9b40 RCX: 0000000000000000
RDX: 00000000fffffd00 RSI: 0000000000000300 RDI: ffff88000d3f9ca8
RBP: ffffc9000232bd08 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88000d3f9ca8
R13: ffff88000d3f9b40 R14: ffff88000d3f9bc8 R15: ffff8801836e21d0
FS:  00007f79b1032700(0000) GS:ffff88050a200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000003b9ab732 CR3: 000000022cc87000 CR4: 00000000001406e0
DR0: 00007f731068f000 DR1: 00007f2d83eb9000 DR2: 00007f302340e000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 sctp_destruct_sock+0x25/0x30 [sctp]
 __sk_destruct+0x28/0x230
 sk_destruct+0x20/0x30
 __sk_free+0x43/0xa0
 sk_free+0x25/0x30
 sctp_close+0x218/0x2a0 [sctp]
 inet_release+0x3c/0x60
 sock_release+0x1f/0x80
 sock_close+0x12/0x20
 __fput+0xf8/0x200
 ____fput+0xe/0x10
 task_work_run+0x85/0xc0
 exit_to_usermode_loop+0xa8/0xb0
 do_syscall_64+0x151/0x190
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f79b095b1e9
RSP: 002b:00007ffc5eca3088 EFLAGS: 00000246
 ORIG_RAX: 0000000000000120
RAX: fffffffffffffff2 RBX: 0000000000000120 RCX: 00007f79b095b1e9
RDX: 000000000000006e RSI: 0000008436738120 RDI: 0000000000000130
RBP: 00007ffc5eca3130 R08: 0000000000000000 R09: 0000000000000ff0
R10: 0000000000080800 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f79b0ee9058 R14: 00007f79b1032698 R15: 00007f79b0ee9000
Code: df e8 bd 5f f4 ff e9 07 ff ff ff 0f ff 8b 83 8c 02 00 00 85 c0 0f 84 2d ff ff ff 0f ff 8b 93 88 02 00 00 85 d2 0f 84 2b ff ff ff <0f> ff 8b 83 40 02 00 00 85 c0 0f 84 29 ff ff ff 0f ff e9 22 ff 
---[ end trace 19b7bd878c0f56fe ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 14455 at net/ipv4/af_inet.c:155 inet_sock_destruct+0x1c8/0x1f0
CPU: 2 PID: 14455 Comm: trinity-c46 Tainted: G      D W       4.12.0-think+ #11 
task: ffff8804fc71b8c0 task.stack: ffffc90002328000
RIP: 0010:inet_sock_destruct+0x1c8/0x1f0
RSP: 0018:ffffc9000232bcf8 EFLAGS: 00010206
RAX: 0000000000000300 RBX: ffff88000d3f9b40 RCX: 0000000000000000
RDX: 00000000fffffd00 RSI: 0000000000000300 RDI: ffff88000d3f9ca8
RBP: ffffc9000232bd08 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff88000d3f9ca8
R13: ffff88000d3f9b40 R14: ffff88000d3f9bc8 R15: ffff8801836e21d0
FS:  00007f79b1032700(0000) GS:ffff88050a200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fdebc2fa000 CR3: 000000022cc87000 CR4: 00000000001406e0
DR0: 00007f731068f000 DR1: 00007f2d83eb9000 DR2: 00007f302340e000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 sctp_destruct_sock+0x25/0x30 [sctp]
 __sk_destruct+0x28/0x230
 sk_destruct+0x20/0x30
 __sk_free+0x43/0xa0
 sk_free+0x25/0x30
 sctp_close+0x218/0x2a0 [sctp]
 inet_release+0x3c/0x60
 sock_release+0x1f/0x80
 sock_close+0x12/0x20
 __fput+0xf8/0x200
 ____fput+0xe/0x10
 task_work_run+0x85/0xc0
 exit_to_usermode_loop+0xa8/0xb0
 do_syscall_64+0x151/0x190
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f79b095b1e9
RSP: 002b:00007ffc5eca3088 EFLAGS: 00000246
 ORIG_RAX: 0000000000000120
RAX: fffffffffffffff2 RBX: 0000000000000120 RCX: 00007f79b095b1e9
RDX: 000000000000006e RSI: 0000008436738120 RDI: 0000000000000130
RBP: 00007ffc5eca3130 R08: 0000000000000000 R09: 0000000000000ff0
R10: 0000000000080800 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f79b0ee9058 R14: 00007f79b1032698 R15: 00007f79b0ee9000
Code: 02 00 00 85 c0 0f 84 2d ff ff ff 0f ff 8b 93 88 02 00 00 85 d2 0f 84 2b ff ff ff 0f ff 8b 83 40 02 00 00 85 c0 0f 84 29 ff ff ff <0f> ff e9 22 ff ff ff 48 89 de 48 c7 c7 c8 7c f7 81 e8 73 f6 75 
---[ end trace 19b7bd878c0f56ff ]---
