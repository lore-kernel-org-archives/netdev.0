From: Eric Dumazet <edumazet@google.com>
Subject: Re: net: cleanup_net is slow
Date: Fri, 21 Apr 2017 10:57:02 -0700
Message-ID: <CANn89i+iYtPLGDZpt3qk_cA-dq+004B=1qjP0ZygY3oREskQYA@mail.gmail.com>
References: <CAAeHK+yJXMo8kr_p8iM_dicVGQCtwQhdk=rdE+9dNbsoghAb6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:34073 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161124AbdDUSEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:04:21 -0400
Received: by mail-yw0-f170.google.com with SMTP id k11so9870243ywb.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:02:53 -0700 (PDT)
In-Reply-To: <CAAeHK+yJXMo8kr_p8iM_dicVGQCtwQhdk=rdE+9dNbsoghAb6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 10:50 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> Hi!
>
> We're investigating some approaches to improve isolation of syzkaller
> programs. One of the ideas is run each program in it's own user/net
> namespace. However, while I was experimenting with this, I stumbled
> upon a problem.
>
> It seems that cleanup_net() might take a very long time to execute.
>
> I've attached the reproducer and kernel .config that I used. Run as
> "./a.out 1". The reproducer just forks and does unshare(CLONE_NEWNET)
> in a loop. Note, that I have a lot of network-related configs enabled,
> which causes a few interfaces to be set up by default.
>
> What I see with this reproducer is that at first a huge number
> (~200-300) net namespaces are created without any contention. But then
> (probably when one of these namespaces gets destroyed) the program
> hangs for a considerable amount of time (~100 seconds in my vm).
> Nothing locks up inside the kernel and the CPU is mostly idle.
>
> Adding debug printfs showed that the part that takes almost all of
> that time is the lines between synchronize_rcu() and
> mutex_unlock(&net_mutex) in cleanup_net. Running perf showed that the
> cause of this might be a lot of calls to synchronize_net that happen
> while executing those lines.
>
> Is there any change that can be done to speed up the
> creation/destruction of a huge number of net namespaces?
>

We have batches, but fundamentally this is a hard problem to solve.

Every time we try, we add bugs :/

RTNL is the new BKL (Big Kernel Lock of early linux) of today.

Even the synchronize_rcu_expedited() done from synchronize_net() is a
serious issue on some platforms.
