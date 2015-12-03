From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 14:45:43 +0100
Message-ID: <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
 <20151203130525.GB4164@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:32953 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbLCNqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 08:46:04 -0500
Received: by wmec201 with SMTP id c201so27687683wme.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 05:46:03 -0800 (PST)
In-Reply-To: <20151203130525.GB4164@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 2:05 PM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
> Hi,
>
> On Tue, Nov 24, 2015 at 10:15:57AM +0100, Dmitry Vyukov wrote:
>>
>> Call Trace:
>>  [<ffffffff8162131e>] __asan_report_load4_noabort+0x3e/0x40
>>  [<ffffffff8475ac76>] sctp_do_sm+0x42f6/0x4f60
>>  [<ffffffff847b50e9>] sctp_primitive_SHUTDOWN+0xa9/0xd0
>>  [<ffffffff847a1426>] sctp_close+0x616/0x790
>>  [<ffffffff8409bb0d>] inet_release+0xed/0x1c0 ./net/ipv4/af_inet.c:471
>>  [<ffffffff84192cc0>] inet6_release+0x50/0x70 ./net/ipv6/af_inet6.c:416
>>  [<     inline     >] constant_test_bit ././arch/x86/include/asm/bitops.h:321
>>  [<ffffffff83dc78cd>] sock_release+0x8d/0x200 ./net/socket.c:601
>>  [<ffffffff83dc7a56>] sock_close+0x16/0x20 ./net/socket.c:1188
>>  [<ffffffff81662f5d>] __fput+0x21d/0x6e0 ./fs/file_table.c:265
>>  [<ffffffff816634a5>] ____fput+0x15/0x20 ./fs/file_table.c:84
>>  [<ffffffff812a33d3>] task_work_run+0x163/0x1f0 ./include/trace/events/rcu.h:20
>>  [<     inline     >] __list_add ./include/linux/list.h:42
>
> By any chance, did you have the pr_debug()s enabled?
> Because that would trigger a use-after-free on debug_post_sfx()
> macro expansion when the asoc is freed:
>
> #define debug_post_sfx() \
>         pr_debug("%s[post-sfx]: error:%d, asoc:%p[%s]\n", __func__, error, \
>                  asoc, sctp_state_tbl[(asoc && sctp_id2assoc(ep->base.sk, \
>                  sctp_assoc2id(asoc))) ? asoc->state : SCTP_STATE_CLOSED])


No, I don't. But pr_debug always computes its arguments. See no_printk
in printk.h. So this use-after-free happens for all users.
