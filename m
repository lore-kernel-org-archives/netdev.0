From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: GPF in eth_header
Date: Sat, 26 Nov 2016 18:30:03 +0100
Message-ID: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>, aduyck@mirantis.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        jbenc@redhat.com, Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35180 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752245AbcKZRa0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 12:30:26 -0500
Received: by mail-lf0-f45.google.com with SMTP id b14so69352398lfg.2
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 09:30:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The following program triggers GPF in eth_header:

https://gist.githubusercontent.com/dvyukov/613cadf05543b55a419f237e419cd495/raw/5471231523d1a07c3de55f11f87472c2816ee06c/gistfile1.txt

On commit 16ae16c6e5616c084168740990fc508bda6655d4 (Nov 24).

BUG: unable to handle kernel paging request at ffffed002d14d74a
IP: [<ffffffff86be3295>] eth_header+0x75/0x260 net/ethernet/eth.c:88
PGD 7fff6067 [   50.787819] PUD 7fff5067
PMD 0 [   50.787819]
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Modules linked in:
CPU: 2 PID: 6712 Comm: a.out Not tainted 4.9.0-rc6+ #55
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003a1841c0 task.stack: ffff880034d08000
RIP: 0010:[<ffffffff86be3295>]  [<ffffffff86be3295>]
eth_header+0x75/0x260 net/ethernet/eth.c:88
RSP: 0018:ffff880034d0eb68  EFLAGS: 00010a03
RAX: 1ffff1002d14d74a RBX: ffff880168a6ba4a RCX: ffff88006a9c7858
RDX: 000000000000dd86 RSI: dffffc0000000000 RDI: ffff880168a6ba56
RBP: ffff880034d0eb98 R08: 0000000000000000 R09: 0000000000000031
R10: 0000000000000002 R11: 0000000000000000 R12: 0000000000000000
R13: ffff88006c208d80 R14: 00000000000086dd R15: ffff88006a9c7858
FS:  0000000001a02940(0000) GS:ffff88006d000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffed002d14d74a CR3: 0000000037373000 CR4: 00000000000006e0
Stack:
 000000316881ab40 ffff88006a9c76c0 ffff88006881ab40 ffff88006a9c77f8
 0000000000000000 dffffc0000000000 ffff880034d0ee98 ffffffff86b31af9
 ffffffff8719605c ffff880034d0f0f8 ffffffff000086dd ffffffff86be3220
Call Trace:
 [<     inline     >] dev_hard_header ./include/linux/netdevice.h:2762
 [<ffffffff86b31af9>] neigh_resolve_output+0x659/0xb20 net/core/neighbour.c:1302
 [<     inline     >] dst_neigh_output ./include/net/dst.h:464
 [<ffffffff8719605c>] ip6_finish_output2+0xb3c/0x2500 net/ipv6/ip6_output.c:121
 [<ffffffff871a0b0b>] ip6_finish_output+0x2eb/0x760 net/ipv6/ip6_output.c:139
 [<     inline     >] NF_HOOK_COND ./include/linux/netfilter.h:246
 [<ffffffff871a1157>] ip6_output+0x1d7/0x9a0 net/ipv6/ip6_output.c:153
 [<     inline     >] dst_output ./include/net/dst.h:501
 [<ffffffff873312ea>] ip6_local_out+0x9a/0x180 net/ipv6/output_core.c:170
 [<ffffffff871a3886>] ip6_send_skb+0xa6/0x340 net/ipv6/ip6_output.c:1712
 [<ffffffff871a3bd8>] ip6_push_pending_frames+0xb8/0xe0
net/ipv6/ip6_output.c:1732
 [<     inline     >] rawv6_push_pending_frames net/ipv6/raw.c:607
 [<ffffffff8722acfb>] rawv6_sendmsg+0x250b/0x2c20 net/ipv6/raw.c:920
 [<ffffffff8701c4f5>] inet_sendmsg+0x385/0x590 net/ipv4/af_inet.c:734
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff86a6ea9f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
 [<ffffffff86a6ee0b>] sock_write_iter+0x32b/0x620 net/socket.c:829
 [<ffffffff81a6f153>] do_iter_readv_writev+0x363/0x670 fs/read_write.c:695
 [<ffffffff81a71ba1>] do_readv_writev+0x431/0x9b0 fs/read_write.c:872
 [<ffffffff81a726dc>] vfs_writev+0x8c/0xc0 fs/read_write.c:911
 [<ffffffff81a72825>] do_writev+0x115/0x2d0 fs/read_write.c:944
 [<     inline     >] SYSC_writev fs/read_write.c:1017
 [<ffffffff81a75fdc>] SyS_writev+0x2c/0x40 fs/read_write.c:1014
 [<ffffffff8814cf85>] entry_SYSCALL_64_fastpath+0x23/0xc6
arch/x86/entry/entry_64.S:209
Code: 41 83 fe 04 0f 84 aa 00 00 00 e8 17 4e b0 fa 48 8d 7b 0c 48 be
00 00 00 00 00 fc ff df 44 89 f2 66 c1 c2 08 48 89 f8 48 c1 e8 03 <0f>
b6 0c 30 48 8d 43 0d 49 89 c0 49 c1 e8 03 41 0f b6 34 30 49
RIP  [<ffffffff86be3295>] eth_header+0x75/0x260 net/ethernet/eth.c:88
 RSP <ffff880034d0eb68>
CR2: ffffed002d14d74a
---[ end trace a73fedfdc11bd60c ]---
