From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/udp: bug in skb_pull_rcsum
Date: Tue, 22 Nov 2016 08:41:33 -0800
Message-ID: <CANn89iKewy1iMa=dUGpE=8UjHUi4o=s=6P_-ngLr_S_ZDByTwg@mail.gmail.com>
References: <CAAeHK+zZSc28e4LMg-YvEztKO4X0VVxqCStkZW8LL4ZA_rYyMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: samanthakumar <samanthakumar@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+zZSc28e4LMg-YvEztKO4X0VVxqCStkZW8LL4ZA_rYyMQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 3:58 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> A reproducer is attached.
>
> On commit 9c763584b7c8911106bb77af7e648bef09af9d80 (4.9-rc6, Nov 20).
>
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:3029!
> invalid opcode: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 3854 Comm: a.out Not tainted 4.9.0-rc6+ #431
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880068472c00 task.stack: ffff880063ec8000
> RIP: 0010:[<ffffffff82b8fd85>]  [<ffffffff82b8fd85>]
> skb_pull_rcsum+0x255/0x350 net/core/skbuff.c:3029
> RSP: 0018:ffff880063ecf660  EFLAGS: 00010297
> RAX: ffff880068472c00 RBX: ffff880065a2da00 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 000000000000000d RDI: ffffed000c7d9ec0
> RBP: ffff880063ecf690 R08: 1ffff1000d08e67e R09: 1ffff1000cb45b50
> R10: dffffc0000000000 R11: 0000000000000000 R12: ffff880065a2da80
> R13: 0000000000000008 R14: ffff880065a2dad8 R15: 0000000000000001
> FS:  00007fbb006497c0(0000) GS:ffff88006cd00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020032fe0 CR3: 00000000636d9000 CR4: 00000000000006e0
> Stack:
>  ffff88006bfbb948 ffff880065a2da00 ffff880064160000 1ffff1000cb45b52
>  0000000000000000 1ffff1000d4d3933 ffff880063ecf6f8 ffffffff83354ced
>  00000000fffffe00 ffff880065a2da90 ffff880063ecf6c0 ffffffff00000001
> Call Trace:
>  [<     inline     >] udp_csum_pull_header ./include/net/udp.h:166
>  [<ffffffff83354ced>] udpv6_queue_rcv_skb+0x37d/0x17b0 net/ipv6/udp.c:625
>  [<     inline     >] sk_backlog_rcv ./include/net/sock.h:874
>  [<ffffffff82b7eec6>] __release_sock+0x126/0x3a0 net/core/sock.c:2046
>  [<ffffffff82b7f199>] release_sock+0x59/0x1c0 net/core/sock.c:2504
>  [<ffffffff8334fc50>] udpv6_sendmsg+0x1310/0x24a0 net/ipv6/udp.c:1273
>  [<ffffffff83174fa7>] inet_sendmsg+0x317/0x4e0 net/ipv4/af_inet.c:734
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:621
>  [<ffffffff82b7176c>] sock_sendmsg+0xcc/0x110 net/socket.c:631
>  [<ffffffff82b719d1>] sock_write_iter+0x221/0x3b0 net/socket.c:829
>  [<ffffffff8151e69b>] do_iter_readv_writev+0x2bb/0x3f0 fs/read_write.c:695
>  [<ffffffff81520501>] do_readv_writev+0x431/0x730 fs/read_write.c:872
>  [<ffffffff81520d2f>] vfs_writev+0x8f/0xc0 fs/read_write.c:911
>  [<ffffffff81520e41>] do_writev+0xe1/0x240 fs/read_write.c:944
>  [<     inline     >] SYSC_writev fs/read_write.c:1017
>  [<ffffffff81523ca7>] SyS_writev+0x27/0x30 fs/read_write.c:1014
>  [<ffffffff83fc4381>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> Code: 89 f8 49 c1 e8 03 47 0f b6 14 08 45 84 d2 74 0a 41 80 fa 03 0f
> 8e cf 00 00 00 80 a3 91 00 00 00 f9 e9 43 ff ff ff e8 3b 79 79 fe <0f>
> 0b e8 34 79 79 fe 0f 0b e8 2d 79 79 fe 48 8b 7d d0 31 d2 44
> RIP  [<ffffffff82b8fd85>] skb_pull_rcsum+0x255/0x350 net/core/skbuff.c:3029
>  RSP <ffff880063ecf660>
> ---[ end trace a5d5d2cef6a25ecb ]---
> ==================================================================


Thanks for the report.

It seems bug was added in commit f7ad74fef3af6c6e2ef7f01c5589d77fe7db3d7c

I will cook a fix (Note that bug is no longer present in net-next and
linux-4.10+ kernels)
