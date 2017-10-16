From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v2 1/4] net/sched: Change tc_action refcnt and bindcnt
 to atomic
Date: Mon, 16 Oct 2017 10:06:28 -0700
Message-ID: <CAM_iQpXA5y8nqCRAxy-9VJTSf3Z7g-6pL1PL1omcwkZn1apFUw@mail.gmail.com>
References: <1508152718-28726-1-git-send-email-chrism@mellanox.com> <1508152718-28726-2-git-send-email-chrism@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:53296 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbdJPRGu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 13:06:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id t188so13754966pfd.10
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 10:06:50 -0700 (PDT)
In-Reply-To: <1508152718-28726-2-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 4:18 AM, Chris Mi <chrism@mellanox.com> wrote:
> If many filters share the same action. That action's refcnt and bindcnt
> could be manipulated by many RCU callbacks at the same time. This patch
> makes these operations atomic.

Actually I have been thinking about removing these RCU callbacks,
they are not necessary AFAIK, callers hold RTNL lock so they are
allowed to block. The only drawback is that adding a synchronize_rcu(),
but these are slow paths anyway...

I am not sure, it is arguable anyway, essentially it is:

synchronize_rcu() in slow path vs.  multiple RCU callback races


>
> Fixes commit in pre-git era.
>
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")

This is not true, the action RCU callbacks were introduced
by:

commit c7de2cf053420d63bac85133469c965d4b1083e1
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Jun 9 02:09:23 2010 +0000

    pkt_sched: gen_kill_estimator() rcu fixes


and the filter RCU callbacks were introduced by the
patchset like this one:


commit 1ce87720d456e471de0fbd814dc5d1fe10fc1c44
Author: John Fastabend <john.fastabend@gmail.com>
Date:   Fri Sep 12 20:09:16 2014 -0700

    net: sched: make cls_u32 lockless
