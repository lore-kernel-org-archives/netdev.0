From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv6: null-ptr-deref in inet6_bind
Date: Thu, 3 Nov 2016 08:39:44 -0700
Message-ID: <CANn89i+YLvnFZFQTQyUA_jxYtZ1RE1NCCb3F4gqdia+w8wuK8A@mail.gmail.com>
References: <CAAeHK+y8AEQ7dM6GQa5fezgaQK+arqAfRjyVafq-K0+nqgUvGg@mail.gmail.com>
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
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+y8AEQ7dM6GQa5fezgaQK+arqAfRjyVafq-K0+nqgUvGg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 2, 2016 at 2:14 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while running the syzkaller fuzzer:
>
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<          (null)>]           (null)
> PGD 66b6f067 [  102.549865] PUD 66c6e067
> PMD 0 [  102.549865]
> Oops: 0010 [#1] SMP KASAN
> Modules linked in:
> CPU: 0 PID: 4143 Comm: a.out Not tainted 4.9.0-rc3+ #336
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880066b1c200 task.stack: ffff880065b58000
> RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
> RSP: 0018:ffff880065b5fbc0  EFLAGS: 00010246
> RAX: ffff880066b1c200 RBX: ffff88006873864a RCX: 0000000000000000
> RDX: 0000000000000001 RSI: ffff880068738640 RDI: ffff880063bd3200
> RBP: ffff880065b5fd20 R08: 1ffff1000c77a713 R09: dffffc0000000000
> R10: ffffffff844fc800 R11: 1ffff1000d0e70c9 R12: ffffffff84e7e040
> R13: ffff880068738640 R14: ffff880063bd3200 R15: ffffffff86836380
> FS:  00007f40b7acf700(0000) GS:ffff88006cc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000000 CR3: 000000006bb28000 CR4: 00000000000006f0
> Stack:
>  ffffffff83099988 ffffffff8479f7e8 ffffffff81208580 1ffff1000000000c
>  0000000041b58ab3 ffffffff8479f7e8 ffffffff81208580 ffffffff812506ed
>  0000000000000007 ffff880065b5fc18 ffffffff812506ed ffff880065b5fcd0
> Call Trace:
>  [<ffffffff832cf4fc>] inet6_bind+0x8ec/0x1020 net/ipv6/af_inet6.c:384
>  [<ffffffff82b7033c>] SYSC_bind+0x1ec/0x250 net/socket.c:1367
>  [<ffffffff82b72ae4>] SyS_bind+0x24/0x30 net/socket.c:1353
>  [<ffffffff83fc0401>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> Code:  Bad RIP value.
> RIP  [<          (null)>]           (null)
>  RSP <ffff880065b5fbc0>
> CR2: 0000000000000000
> ---[ end trace b5ec698ae4926a97 ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Kernel Offset: disabled
> ---[ end Kernel panic - not syncing: Fatal exception in interrupt
>
> On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
>
> I'm able to reproduce it with the attached program by running it as:
> $ gcc -lpthread inet6-bind-poc.c
> $ while true; do ./a.out; done
>
> Thanks!

Looks like this patch should fix it ?

Thanks !

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3828f94b234c..95353bdbfa7b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -956,6 +956,7 @@ static const struct inet_connection_sock_af_ops
dccp_ipv6_mapped = {
        .getsockopt        = ipv6_getsockopt,
        .addr2sockaddr     = inet6_csk_addr2sockaddr,
        .sockaddr_len      = sizeof(struct sockaddr_in6),
+       .bind_conflict     = inet6_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
        .compat_setsockopt = compat_ipv6_setsockopt,
        .compat_getsockopt = compat_ipv6_getsockopt,
