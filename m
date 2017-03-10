From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: BUG in unix_notinflight
Date: Fri, 10 Mar 2017 09:46:51 -0800
Message-ID: <CAM_iQpUivn961fDXSSJzd2_i5ZTqu=NHdap8YNxYXMeo2hxjMg@mail.gmail.com>
References: <CACT4Y+b5_zcRVrq5yRmtkVUgnzOmq55upA_QCoLrkSDnT0cLHA@mail.gmail.com>
 <CACT4Y+bCvPdn3i-nuBCbPyHUuOjyh83KyLFzWR+8JDGqM0F2ww@mail.gmail.com>
 <CAM_iQpWePCJ3oyOf8xRdJ5CtPMR6UNvNKs7t=MabtL=obGoSxg@mail.gmail.com> <74aac97b-f779-1554-a34b-bca173ab0c8d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        syzkaller <syzkaller@googlegroups.com>
To: Nikolay Borisov <n.borisov.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38599 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755028AbdCJRrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 12:47:14 -0500
In-Reply-To: <74aac97b-f779-1554-a34b-bca173ab0c8d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 7, 2017 at 2:23 PM, Nikolay Borisov
<n.borisov.lkml@gmail.com> wrote:
>
>>>
>>>
>>> New report from linux-next/c0b7b2b33bd17f7155956d0338ce92615da686c9
>>>
>>> ------------[ cut here ]------------
>>> kernel BUG at net/unix/garbage.c:149!
>>> invalid opcode: 0000 [#1] SMP KASAN
>>> Dumping ftrace buffer:
>>>    (ftrace buffer empty)
>>> Modules linked in:
>>> CPU: 0 PID: 1806 Comm: syz-executor7 Not tainted 4.10.0-next-20170303+ #6
>>> Hardware name: Google Google Compute Engine/Google Compute Engine,
>>> BIOS Google 01/01/2011
>>> task: ffff880121c64740 task.stack: ffff88012c9e8000
>>> RIP: 0010:unix_notinflight+0x417/0x5d0 net/unix/garbage.c:149
>>> RSP: 0018:ffff88012c9ef0f8 EFLAGS: 00010297
>>> RAX: ffff880121c64740 RBX: 1ffff1002593de23 RCX: ffff8801c490c628
>>> RDX: 0000000000000000 RSI: 1ffff1002593de27 RDI: ffffffff8557e504
>>> RBP: ffff88012c9ef220 R08: 0000000000000001 R09: 0000000000000000
>>> R10: dffffc0000000000 R11: ffffed002593de55 R12: ffff8801c490c0c0
>>> R13: ffff88012c9ef1f8 R14: ffffffff85101620 R15: dffffc0000000000
>>> FS:  00000000013d3940(0000) GS:ffff8801dbe00000(0000) knlGS:0000000000000000
>>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> CR2: 0000000001fd8cd8 CR3: 00000001cce69000 CR4: 00000000001426f0
>>> Call Trace:
>>>  unix_detach_fds.isra.23+0xfa/0x170 net/unix/af_unix.c:1490
>>>  unix_destruct_scm+0xf4/0x200 net/unix/af_unix.c:1499
>>
>> The problem here is there is no lock protecting concurrent unix_detach_fds()
>> even though unix_notinflight() is already serialized, if we call
>> unix_notinflight()
>> twice on the same file pointer, we trigger this bug...
>>
>> I don't know what is the right lock here to serialize it.
>>
>
>
> I reported something similar a while ago
> https://lists.gt.net/linux/kernel/2534612
>
> And Miklos Szeredi then produced the following patch :
>
> https://patchwork.kernel.org/patch/9305121/
>
> However, this was never applied. I wonder if the patch makes sense?

I doubt it is the same case. According to Miklos' description,
the case he tried to fix is MSG_PEEK, but Dmitry's test case does not
set it... They are different problems probably.
