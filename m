From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/netlink: null-ptr-deref in netlink_dump/lock_acquire
Date: Thu, 3 Nov 2016 01:15:30 +0100
Message-ID: <CAAeHK+xCmN7n1MTocLK9A864YGkq-7a-1NESYkWyLYgLRScF=Q@mail.gmail.com>
References: <CAAeHK+wM9yG3c9AksSyj7jYSY4ujssH+vTuV2nyz=-0enLrB8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Andrew Morton <akpm@linux-foundation.org>,
        David Decotigny <decot@googlers.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dmitry Ivanov <dmitrijs.ivanovs@ubnt.com>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>,
        Greg Rose <grose@lightfleet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Johannes Berg <johannes.berg@intel.com>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wM9yG3c9AksSyj7jYSY4ujssH+vTuV2nyz=-0enLrB8w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2016 at 4:13 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while running the syzkaller fuzzer:
>
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 3933 Comm: syz-executor Not tainted 4.9.0-rc1+ #230
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006b79d800 task.stack: ffff88006bbc0000
> RIP: 0010:[<ffffffff8120872d>]  [<ffffffff8120872d>]
> __lock_acquire+0x12d/0x3450 kernel/locking/lockdep.c:3221
> RSP: 0018:ffff88006bbc7420  EFLAGS: 00010006
> RAX: 0000000000000046 RBX: dffffc0000000000 RCX: 0000000000000000
> RDX: 000000000000000c RSI: 0000000000000000 RDI: 0000000000000003
> RBP: ffff88006bbc75c0 R08: 0000000000000001 R09: 0000000000000000
> R10: 0000000000000000 R11: ffffffff85f42240 R12: ffff88006b79d800
> R13: ffffffff84bfe4e0 R14: 0000000000000001 R15: 0000000000000060
> FS:  00007fd9c41cc700(0000) GS:ffff88006cd00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000451f80 CR3: 00000000638f0000 CR4: 00000000000006e0
> Stack:
>  0000000000000000 ffff88006bbc0000 ffff88006bbc8000 0000000000000000
>  0000000000000002 ffff88006b79d800 0000000000000000 ffff88006bbc7f48
>  ffffffff852adc60 0000000000000000 ffffffff852adc64 1ffffffff0b40135
> Call Trace:
>  [<ffffffff8120c5ae>] lock_acquire+0x17e/0x340 kernel/locking/lockdep.c:3746
>  [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
>  [<ffffffff83fb6fe1>] mutex_lock_nested+0xb1/0x890 kernel/locking/mutex.c:621
>  [<ffffffff82db6fd0>] netlink_dump+0x50/0xac0 net/netlink/af_netlink.c:2067
>  [<ffffffff82dba381>] __netlink_dump_start+0x501/0x770
> net/netlink/af_netlink.c:2200
>  [<ffffffff82dc35b2>] genl_family_rcv_msg+0xa02/0xc80
> net/netlink/genetlink.c:595
>  [<ffffffff82dc39e6>] genl_rcv_msg+0x1b6/0x270 net/netlink/genetlink.c:658
>  [<ffffffff82dc1a70>] netlink_rcv_skb+0x2c0/0x3b0 net/netlink/af_netlink.c:2281
>  [<ffffffff82dc2b98>] genl_rcv+0x28/0x40 net/netlink/genetlink.c:669
>  [<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1214
>  [<ffffffff82dc0329>] netlink_unicast+0x5a9/0x880 net/netlink/af_netlink.c:1240
>  [<ffffffff82dc0fb7>] netlink_sendmsg+0x9b7/0xce0 net/netlink/af_netlink.c:1786
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:606
>  [<ffffffff82b7075c>] sock_sendmsg+0xcc/0x110 net/socket.c:616
>  [<ffffffff82b709c1>] sock_write_iter+0x221/0x3b0 net/socket.c:814
>  [<     inline     >] new_sync_write fs/read_write.c:499
>  [<ffffffff8151c944>] __vfs_write+0x334/0x570 fs/read_write.c:512
>  [<ffffffff8152045b>] vfs_write+0x17b/0x500 fs/read_write.c:560
>  [<     inline     >] SYSC_write fs/read_write.c:607
>  [<ffffffff81523d84>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
>  [<ffffffff83fc0141>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> arch/x86/entry/entry_64.S:209
> Code: 0f 1f 44 00 00 f6 c4 02 0f 85 24 0a 00 00 44 8b 35 c9 61 8b 03
> 45 85 f6 74 2c 4c 89 fa 48 bb 00 00 00 00 00 fc ff df 48 c1 ea 03 <80>
> 3c 1a 00 0f 85 04 2f 00 00 49 81 3f a0 dc 2a 85 41 be 00 00
> RIP  [<ffffffff8120872d>] __lock_acquire+0x12d/0x3450
> kernel/locking/lockdep.c:3221
>  RSP <ffff88006bbc7420>
> ---[ end trace 685b3c182bf7f25c ]---
>
> The reproducer is attached.
>
> On commit 1a1891d762d6e64daf07b5be4817e3fbb29e3c59 (Oct 18).

(Adding more maintainers)

Still seeing this on 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
