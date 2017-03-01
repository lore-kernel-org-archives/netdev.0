From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Wed, 1 Mar 2017 10:47:26 +0100
Message-ID: <CACT4Y+bKrO1XMi=cqEmU-tFeNUHTSMexZQTx7Jvisr1+0uWjQQ@mail.gmail.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com> <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com> <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
 <20170228163833.GI31155@oracle.com> <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw@mail.gmail.com>
 <20170228222410.GA32635@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:33156 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751955AbdCAJrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 04:47:49 -0500
Received: by mail-ua0-f177.google.com with SMTP id x24so37570452uab.0
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 01:47:48 -0800 (PST)
In-Reply-To: <20170228222410.GA32635@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 11:24 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
> Actually, I'm not sure if I can assert that these are all manifestations
> of the same bug- was a netns-delete involved in this one as well?
>
> I see:
>
>> BUG: KASAN: use-after-free in memcmp+0xe3/0x160 lib/string.c:768 at
>     :
>>  memcmp+0xe3/0x160 lib/string.c:768
>     :
>>  rds_find_bound+0x4fe/0x8a0 net/rds/bind.c:63
>>  rds_recv_incoming+0x5f3/0x12c0 net/rds/recv.c:349
>>  rds_loop_xmit+0x1c5/0x490 net/rds/loop.c:82
>     :
> This appears to be for a looped back packet, and looks like there
> are problems with  some rds_sock that got removed from the bind_hash_table..
>
> According to the report, socket was created at
>> Allocated:
>> PID = 5235
>     :
>>  sk_prot_alloc+0x65/0x2a0 net/core/sock.c:1334
>>  sk_alloc+0x105/0x1010 net/core/sock.c:1396
>>  rds_create+0x11c/0x600 net/rds/af_rds.c:504
>
> and closed at some point:
>> Freed:
>> PID = 5235
>      :
>>  rds_release+0x3a1/0x4d0 net/rds/af_rds.c:89
>>  sock_release+0x8d/0x1e0 net/socket.c:599
>
> This is all uspace created rds sockets, and while there may be an
> unrelated bug here, I'm not sure I see  the netns/kernel-socket
> connection.. can you please clarify if this was also seen in some netns
> context?


Yes, these test processes run in private net namespaces.
