From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/icmp: null-ptr-deref in icmp6_send
Date: Tue, 22 Nov 2016 11:23:01 +0100
Message-ID: <CAAeHK+wRE7y_0d7djWnq9S1O_w-1wQRq1g7VsAmzEAE+JY_v2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

It seems that skb_dst(skb) may end up being NULL.

As far as I can see the bug was introduced in commit 5d41ce29e ("net:
icmp6_send should use dst dev to determine L3 domain").
ICMP v4 probaly has similar issue due to 9d1a6c4ea ("net:
icmp_route_lookup should use rt dev to determine L3 domain").

On commit 9c763584b7c8911106bb77af7e648bef09af9d80 (4.9-rc6, Nov 20).

kasan: CONFIG_KASAN_INLINE enabled
kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 0 PID: 3859 Comm: a.out Not tainted 4.9.0-rc6+ #429
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8800666d4200 task.stack: ffff880067348000
RIP: 0010:[<ffffffff833617ec>]  [<ffffffff833617ec>]
icmp6_send+0x5fc/0x1e30 net/ipv6/icmp.c:451
RSP: 0018:ffff88006734f2c0  EFLAGS: 00010206
RAX: ffff8800666d4200 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: dffffc0000000000 RDI: 0000000000000018
RBP: ffff88006734f630 R08: ffff880064138418 R09: 0000000000000003
R10: dffffc0000000000 R11: 0000000000000005 R12: 0000000000000000
R13: ffffffff84e7e200 R14: ffff880064138484 R15: ffff8800641383c0
FS:  00007fb3887a07c0(0000) GS:ffff88006cc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020000000 CR3: 000000006b040000 CR4: 00000000000006f0
Stack:
 ffff8800666d4200 ffff8800666d49f8 ffff8800666d4200 ffffffff84c02460
 ffff8800666d4a1a 1ffff1000ccdaa2f ffff88006734f498 0000000000000046
 ffff88006734f440 ffffffff832f4269 ffff880064ba7456 0000000000000000
Call Trace:
 [<ffffffff83364ddc>] icmpv6_param_prob+0x2c/0x40 net/ipv6/icmp.c:557
 [<     inline     >] ip6_tlvopt_unknown net/ipv6/exthdrs.c:88
 [<ffffffff83394405>] ip6_parse_tlv+0x555/0x670 net/ipv6/exthdrs.c:157
 [<ffffffff8339a759>] ipv6_parse_hopopts+0x199/0x460 net/ipv6/exthdrs.c:663
 [<ffffffff832ee773>] ipv6_rcv+0xfa3/0x1dc0 net/ipv6/ip6_input.c:191
 [<ffffffff82bdc01b>] __netif_receive_skb_core+0x187b/0x2a10 net/core/dev.c:4208
 [<ffffffff82bdd1da>] __netif_receive_skb+0x2a/0x170 net/core/dev.c:4246
 [<ffffffff82bdd4d3>] netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4274
 [<ffffffff82bdd6f8>] netif_receive_skb+0x48/0x250 net/core/dev.c:4298
 [<ffffffff82420e7e>] tun_get_user+0xbde/0x2890 drivers/net/tun.c:1308
 [<ffffffff82422d4a>] tun_chr_write_iter+0xda/0x190 drivers/net/tun.c:1332
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff8151c234>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [<ffffffff8151fd4b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81523674>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [<ffffffff83fc4301>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
Code: 67 58 41 f6 c4 01 0f 85 d4 07 00 00 49 83 e4 fe e8 ea 5e fc fd
49 8d 7c 24 18 49 ba 00 00 00 00 00 fc ff df 49 89 f9 49 c1 e9 03 <43>
80 3c 11 00 0f 85 c5 17 00 00 4d 8b 64 24 18 65 ff 05 cd 3c
RIP  [<ffffffff833617ec>] icmp6_send+0x5fc/0x1e30 net/ipv6/icmp.c:451
 RSP <ffff88006734f2c0>
---[ end trace 12dd736536064d71 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: disabled
---[ end Kernel panic - not syncing: Fatal exception in interrupt
