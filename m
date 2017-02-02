From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/tcp: warning in tcp_try_coalesce/skb_try_coalesce
Date: Thu, 2 Feb 2017 10:05:39 +0100
Message-ID: <CACT4Y+Yw8_ZkjajkGdZ=71Mo83O+K=NJTZO+cM-+8UzTzHC-=A@mail.gmail.com>
References: <CAAeHK+xaFar2pj1xkbkhfjN+3ucLsfMpoHWFAKcHq3-F_Zm+mw@mail.gmail.com>
 <CANn89iKSSmaSHJGfgR4AkRgMRfYx+52XXjWsxZovUzorpneL=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iKSSmaSHJGfgR4AkRgMRfYx+52XXjWsxZovUzorpneL=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2017 at 3:27 PM, 'Eric Dumazet' via syzkaller
<syzkaller@googlegroups.com> wrote:
> On Tue, Jan 31, 2017 at 5:17 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer.
>>
>> On commit 566cf877a1fcb6d6dc0126b076aad062054c2637 (4.10-rc6).
>>
>> The fuzzer hits this issue quite often, but I don't have a working reproducer.
>>
>> WARNING: CPU: 3 PID: 7091 at net/core/skbuff.c:4331
>> skb_try_coalesce+0x14b1/0x1f80 net/core/skbuff.c:4331
>> Kernel panic - not syncing: panic_on_warn set ...
...
> Have you tried the patch we added recently into net-next ?
>
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=158f323b9868b59967ad96957c4ca388161be321


I've tried this patch, and it does _not_ help.
I am currently on a2ca3d617944417e9dd5f09fc8a4549cda115f4f, and I
applied the patch on top (had to do a little merging in af_netlink.c):
https://gist.githubusercontent.com/dvyukov/b4fd206f7dde763b3113a4543c57e7bb/raw/784c5b1bcb06f2a22c55eb4c4f8f83d627cd1ab9/gistfile1.txt
Still getting the same warning.

But now I have a repro:
https://gist.githubusercontent.com/dvyukov/88fdb6d93507b36f81377191b0694f9b/raw/81cc11e8b78b6bbc5cffc79b442ce998c49af226/gistfile1.txt


WARNING: CPU: 2 PID: 2958 at net/core/skbuff.c:4339
skb_try_coalesce+0x154c/0x2020 net/core/skbuff.c:4339
Kernel panic - not syncing: panic_on_warn set ...
CPU: 2 PID: 2958 Comm: a.out Not tainted 4.10.0-rc6+ #206
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 panic+0x1fb/0x412 kernel/panic.c:179
 __warn+0x1c4/0x1e0 kernel/panic.c:539
 warn_slowpath_null+0x2c/0x40 kernel/panic.c:582
 skb_try_coalesce+0x154c/0x2020 net/core/skbuff.c:4339
 tcp_try_coalesce+0x16f/0x560 net/ipv4/tcp_input.c:4337
 tcp_queue_rcv+0x12d/0x790 net/ipv4/tcp_input.c:4572
 tcp_data_queue+0x96f/0x46b0 net/ipv4/tcp_input.c:4681
 tcp_rcv_state_process+0xd92/0x42c0 net/ipv4/tcp_input.c:6130
 tcp_v4_do_rcv+0x56b/0x940 net/ipv4/tcp_ipv4.c:1426
 sk_backlog_rcv include/net/sock.h:893 [inline]
 __release_sock+0x126/0x3a0 net/core/sock.c:2053
 release_sock+0xa5/0x2b0 net/core/sock.c:2540
 inet_shutdown+0x1a8/0x350 net/ipv4/af_inet.c:833
 SYSC_shutdown net/socket.c:1840 [inline]
 SyS_shutdown+0x23d/0x2d0 net/socket.c:1831
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x443b39
RSP: 002b:00007ffcfd0814f8 EFLAGS: 00000206 ORIG_RAX: 0000000000000030
RAX: ffffffffffffffda RBX: 00000000004031d0 RCX: 0000000000443b39
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000003
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000206 R12: 00000000004002b0
R13: 00000000004031d0 R14: 0000000000403260 R15: 0000000000000000
Kernel Offset: disabled
Rebooting in 86400 seconds..
