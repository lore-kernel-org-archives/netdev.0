From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv4: null-ptr-deref in udp_rmem_release/sk_memory_allocated_sub
Date: Thu, 9 Feb 2017 05:50:30 -0800
Message-ID: <CANn89iL-aTXDSFhG+SfwdpjS-wjPWpmhhxYAuOpG0Rmu_zX1fA@mail.gmail.com>
References: <CAAeHK+xYy8RRi1UbS99fy63BWuFpixo6D=_KDsaW2MM7Huk2hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
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
In-Reply-To: <CAAeHK+xYy8RRi1UbS99fy63BWuFpixo6D=_KDsaW2MM7Huk2hA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 4:28 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>
> A reproducer and .config are attached.
>
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: sk_memory_allocated_sub include/net/sock.h:1214 [inline]
> IP: __sk_mem_reduce_allocated+0xa9/0x390 net/core/sock.c:2215
> PGD 3aa86067
> PUD 33243067
> PMD 0
>
> Oops: 0002 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 3 PID: 13215 Comm: syz-executor5 Not tainted 4.10.0-rc7+ #126
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006bf59700 task.stack: ffff88005e0a8000
> RIP: 0010:sk_memory_allocated_sub include/net/sock.h:1214 [inline]
> RIP: 0010:__sk_mem_reduce_allocated+0xa9/0x390 net/core/sock.c:2215
> RSP: 0018:ffff88005e0afa48 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: 1ffff1000bc15f4a RCX: 1ffffffff0bc7d8e
> RDX: dffffc0000000000 RSI: ffffffff83343399 RDI: ffffffff85e3ec70
> RBP: ffff88005e0afad8 R08: 0000000000000090 R09: 0000000000000000
> R10: 0000000000000002 R11: 0000000000000000 R12: ffff88003dfb3c40
> R13: 000000000003dfb4 R14: ffff88003dfb3c68 R15: ffffffff85e3eba0
> FS:  00007f71b9ba9700(0000) GS:ffff88006df00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000000 CR3: 00000000393b8000 CR4: 00000000000006e0
> Call Trace:
>  udp_rmem_release+0x14f/0x180 net/ipv4/udp.c:1199
>  first_packet_length+0x215/0x6e0 net/ipv4/udp.c:1380
>  udp_ioctl+0x13f/0x2c0 net/ipv4/udp.c:1401
>  inet6_ioctl+0x19e/0x1e0 net/ipv6/af_inet6.c:530
>  sock_do_ioctl+0x65/0xb0 net/socket.c:897
>  sock_ioctl+0x28f/0x440 net/socket.c:995
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458b9
> RSP: 002b:00007f71b9ba8b58 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458b9
> RDX: 0000000020005f3e RSI: 000000000000541b RDI: 0000000000000005
> RBP: 00000000006e0cc0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 00000000007080a8
> R13: 0000000000000000 R14: 00007f71b9ba99c0 R15: 00007f71b9ba9700
> Code: 24 28 48 ba 00 00 00 00 00 fc ff df 49 8d bf d0 00 00 00 48 89
> f9 48 c1 e9 03 80 3c 11 00 0f 85 8b 02 00 00 49 8b 87 d0 00 00 00 <f0>
> 4c 29 28 4d 8b 7c 24 28 48 ba 00 00 00 00 00 fc ff df 49 8d
> RIP: sk_memory_allocated_sub include/net/sock.h:1214 [inline] RSP:
> ffff88005e0afa48
> RIP: __sk_mem_reduce_allocated+0xa9/0x390 net/core/sock.c:2215 RSP:
> ffff88005e0afa48
> CR2: 0000000000000000
> ---[ end trace 8b75e9ae315695b0 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

Thanks for the report.  L2TP needs a patch that will follow shortly.
