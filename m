From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/tcp: null-ptr-deref in
 __inet_lookup_listener/inet_exact_dif_match
Date: Wed, 02 Nov 2016 10:21:45 -0700
Message-ID: <1478107305.7065.382.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+z9bqpWqONBBL1rztkY-+NdzY4jfCzNzfnm63psxbW-2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+z9bqpWqONBBL1rztkY-+NdzY4jfCzNzfnm63psxbW-2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-11-02 at 18:01 +0100, Andrey Konovalov wrote:
> Hi,
> 
> I've got the following error report while running the syzkaller fuzzer:
> 
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 648 Comm: syz-executor Not tainted 4.9.0-rc3+ #333
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff8800398c4480 task.stack: ffff88003b468000
> RIP: 0010:[<ffffffff83091106>]  [<     inline     >]
> inet_exact_dif_match include/net/tcp.h:808
> RIP: 0010:[<ffffffff83091106>]  [<ffffffff83091106>]
> __inet_lookup_listener+0xb6/0x500 net/ipv4/inet_hashtables.c:219
> RSP: 0018:ffff88003b46f270  EFLAGS: 00010202
> RAX: 0000000000000004 RBX: 0000000000004242 RCX: 0000000000000001
> RDX: 0000000000000000 RSI: ffffc90000e3c000 RDI: 0000000000000054
> RBP: ffff88003b46f2d8 R08: 0000000000004000 R09: ffffffff830910e7
> R10: 0000000000000000 R11: 000000000000000a R12: ffffffff867fa0c0
> R13: 0000000000004242 R14: 0000000000000003 R15: dffffc0000000000
> FS:  00007fb135881700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020cc3000 CR3: 000000006d56a000 CR4: 00000000000006f0
> Stack:
>  0000000000000000 000000000601a8c0 0000000000000000 ffffffff00004242
>  424200003b9083c2 ffff88003def4041 ffffffff84e7e040 0000000000000246
>  ffff88003a0911c0 0000000000000000 ffff88003a091298 ffff88003b9083ae
> Call Trace:
>  [<ffffffff831100f4>] tcp_v4_send_reset+0x584/0x1700 net/ipv4/tcp_ipv4.c:643
>  [<ffffffff83115b1b>] tcp_v4_rcv+0x198b/0x2e50 net/ipv4/tcp_ipv4.c:1718
>  [<ffffffff83069d22>] ip_local_deliver_finish+0x332/0xad0
> net/ipv4/ip_input.c:216
>  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:232
>  [<     inline     >] NF_HOOK include/linux/netfilter.h:255
>  [<ffffffff8306abd2>] ip_local_deliver+0x1c2/0x4b0 net/ipv4/ip_input.c:257
>  [<     inline     >] dst_input include/net/dst.h:507
>  [<ffffffff83068500>] ip_rcv_finish+0x750/0x1c40 net/ipv4/ip_input.c:396
>  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:232
>  [<     inline     >] NF_HOOK include/linux/netfilter.h:255
>  [<ffffffff8306b82f>] ip_rcv+0x96f/0x12f0 net/ipv4/ip_input.c:487
>  [<ffffffff82bd9fb7>] __netif_receive_skb_core+0x1897/0x2a50 net/core/dev.c:4213
>  [<ffffffff82bdb19a>] __netif_receive_skb+0x2a/0x170 net/core/dev.c:4251
>  [<ffffffff82bdb493>] netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4279
>  [<ffffffff82bdb6b8>] netif_receive_skb+0x48/0x250 net/core/dev.c:4303
>  [<ffffffff8241fc75>] tun_get_user+0xbd5/0x28a0 drivers/net/tun.c:1308
>  [<ffffffff82421b5a>] tun_chr_write_iter+0xda/0x190 drivers/net/tun.c:1332
>  [<     inline     >] new_sync_write fs/read_write.c:499
>  [<ffffffff8151bd44>] __vfs_write+0x334/0x570 fs/read_write.c:512
>  [<ffffffff8151f85b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>  [<     inline     >] SYSC_write fs/read_write.c:607
>  [<ffffffff81523184>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>  [<ffffffff83fc02c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> Code: 00 00 45 85 c9 75 46 e8 e9 65 29 fe 4c 8b 55 a8 49 bf 00 00 00
> 00 00 fc ff df 49 8d 7a 54 49 89 fb 48 89 f8 49 c1 eb 03 83 e0 07 <43>
> 0f b6 1c 3b 83 c0 01 38 d8 7c 08 84 db 0f 85 a9 03 00 00 48
> RIP  [<     inline     >] inet_exact_dif_match include/net/tcp.h:808
> RIP  [<ffffffff83091106>] __inet_lookup_listener+0xb6/0x500
> net/ipv4/inet_hashtables.c:219
>  RSP <ffff88003b46f270>
> ---[ end trace 351d030d30a11e1a ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> 
> On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
> 
> Thanks!

Thanks for your report.

David, please take a look.

TCP MD5 can call __inet_lookup_listener() with a NULL skb.

Bug added in commit a04a480d4392ea6efd117be2de564117b2a009c0
