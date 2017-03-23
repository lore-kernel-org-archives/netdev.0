From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/sched: GPF in qdisc_hash_add
Date: Thu, 23 Mar 2017 20:06:03 +0100
Message-ID: <CACT4Y+ZBwr6CNr1j0Hx3ZptLePkbiGfws4q=uv=PFOYTkhcXuQ@mail.gmail.com>
References: <CACT4Y+bemisEVj1nFmyFPuJZxh3oa8QOf-qDZmjRyPZBG4y7ng@mail.gmail.com>
 <CAM_iQpWG78yjRAQ673NyiVBJZRfH7WMjbteRw7EfTkfH2tU2-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:35406 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755929AbdCWTGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:06:32 -0400
Received: by mail-ua0-f173.google.com with SMTP id q7so99903411uaf.2
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 12:06:31 -0700 (PDT)
In-Reply-To: <CAM_iQpWG78yjRAQ673NyiVBJZRfH7WMjbteRw7EfTkfH2tU2-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 8:00 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Mar 23, 2017 at 9:06 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> kasan: CONFIG_KASAN_INLINE enabled
>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>> general protection fault: 0000 [#1] SMP KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 2 PID: 12732 Comm: syz-executor6 Not tainted 4.11.0-rc3+ #365
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> task: ffff880062b7a2c0 task.stack: ffff880033480000
>> RIP: 0010:qdisc_hash_add.part.19+0xb6/0x3c0 net/sched/sch_api.c:280
>> RSP: 0018:ffff880033487820 EFLAGS: 00010202
>> RAX: dffffc0000000000 RBX: ffffffff85357e00 RCX: ffffc90002b24000
>> RDX: 000000000000007a RSI: ffffffff835a523a RDI: 00000000000003d0
>> RBP: ffff8800334878b8 R08: fffffbfff0a6afeb R09: fffffbfff0a6afeb
>> R10: 0000000000000001 R11: fffffbfff0a6afea R12: ffffffff85357e48
>> R13: 1ffff10006690f06 R14: ffff880033487890 R15: 0000000000000000
>> FS:  00007f68665d0700(0000) GS:ffff88006e200000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00000000004c2d44 CR3: 000000003c6f8000 CR4: 00000000000026e0
>> Call Trace:
>>  qdisc_hash_add+0x76/0x90 net/sched/sch_api.c:279
>>  attach_default_qdiscs net/sched/sch_generic.c:798 [inline]
>>  dev_activate+0x6ca/0x920 net/sched/sch_generic.c:829
>>  __dev_open+0x25b/0x360 net/core/dev.c:1348
>>  __dev_change_flags+0x159/0x3d0 net/core/dev.c:6460
>>  dev_change_flags+0x88/0x140 net/core/dev.c:6525
>>  dev_ifsioc+0x51f/0x9b0 net/core/dev_ioctl.c:254
>>  dev_ioctl+0x1fe/0x1030 net/core/dev_ioctl.c:532
>>  sock_do_ioctl+0x94/0xb0 net/socket.c:902
>>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>>  vfs_ioctl fs/ioctl.c:45 [inline]
>>  do_vfs_ioctl+0x1af/0x16d0 fs/ioctl.c:685
>>  SYSC_ioctl fs/ioctl.c:700 [inline]
>>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
>>  entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> The interesting part is why the NULL dereference is in
> qdisc_hash_add(), since we have a check before calling
> it:
>
> #ifdef CONFIG_NET_SCHED
>         if (dev->qdisc)
>                 qdisc_hash_add(dev->qdisc);
> #endif
>
>
> When attach_one_default_qdisc() fails, we should trigger
> the NULL pointer dereference bug at:
>
>     atomic_inc(&dev->qdisc->refcnt);

I think qdisc is not NULL, it's something _in_ qdisc that is NULL. The
crash happens here:

                struct Qdisc *root = qdisc_dev(q)->qdisc;

so it's probably device.
