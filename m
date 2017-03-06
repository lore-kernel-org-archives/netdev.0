From: Dmitry Vyukov <dvyukov@google.com>
Subject: netlink: GPF in netlink_unicast
Date: Mon, 6 Mar 2017 11:54:51 +0100
Message-ID: <CACT4Y+bmJpMCcbKZqdp_jvhS=K3O2rBPrPD-b1F_WqRLS9Y=0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:36349 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753225AbdCFK4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 05:56:05 -0500
Received: by mail-ua0-f180.google.com with SMTP id 72so163779165uaf.3
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 02:55:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've got the following crash while running syzkaller fuzzer on
net-next/8d70eeb84ab277377c017af6a21d0a337025dede:

kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 883 Comm: kauditd Not tainted 4.10.0+ #6
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
task: ffff8801d79f0240 task.stack: ffff8801d7a20000
RIP: 0010:sock_sndtimeo include/net/sock.h:2162 [inline]
RIP: 0010:netlink_unicast+0xdd/0x730 net/netlink/af_netlink.c:1249
RSP: 0018:ffff8801d7a27c38 EFLAGS: 00010206
RAX: 0000000000000056 RBX: ffff8801d7a27cd0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000000002b0
RBP: ffff8801d7a27cf8 R08: ffffed00385cf286 R09: ffffed00385cf286
R10: 0000000000000006 R11: ffffed00385cf285 R12: 0000000000000000
R13: dffffc0000000000 R14: ffff8801c2fc3c80 R15: 00000000014000c0
FS:  0000000000000000(0000) GS:ffff8801dbe00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020cfd000 CR3: 00000001c758f000 CR4: 00000000001406f0
Call Trace:
 kauditd_send_unicast_skb+0x3c/0x70 kernel/audit.c:482
 kauditd_thread+0x174/0xb00 kernel/audit.c:599
 kthread+0x326/0x3f0 kernel/kthread.c:229
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Code: 44 89 fe e8 56 15 ff ff 8b 8d 70 ff ff ff 49 89 c6 31 c0 85 c9
75 27 e8 b2 b2 f4 fd 49 8d bc 24 b0 02 00 00 48 89 f8 48 c1 e8 03 <42>
80 3c 28 00 0f 85 37 06 00 00 49 8b 84 24 b0 02 00 00 4c 8d
RIP: sock_sndtimeo include/net/sock.h:2162 [inline] RSP: ffff8801d7a27c38
RIP: netlink_unicast+0xdd/0x730 net/netlink/af_netlink.c:1249 RSP:
ffff8801d7a27c38
---[ end trace ad1bba9d457430b6 ]---
Kernel panic - not syncing: Fatal exception


This is not reproducible and seems to be caused by an elusive race.
However, looking at the code I don't see any proper protection of
audit_sock (other than the if (!audit_pid) which is obviously not
enough to protect against races).
