From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC net 1/1] net: sched: act: fix rcu race in dump
Date: Tue, 10 Oct 2017 09:40:12 -0700
Message-ID: <CAM_iQpVVqFUpeYc-b4bzc2=L-O7h0z3bbSLOaAoQ17h1jcrdCw@mail.gmail.com>
References: <20171010123218.5251-1-aring@mojatatu.com> <20171010123218.5251-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        kurup.manish@gmail.com, Brenda Butler <bjb@mojatatu.com>
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37582 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932075AbdJJQkd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:40:33 -0400
Received: by mail-pf0-f194.google.com with SMTP id z80so18342933pff.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:40:33 -0700 (PDT)
In-Reply-To: <20171010123218.5251-2-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 5:32 AM, Alexander Aring <aring@mojatatu.com> wrote:
> This patch fixes an issue with kfree_rcu which is not protected by RTNL
> lock. It could be that the current assigned rcu pointer will be freed by
> kfree_rcu while dump callback is running.

Why? kfree_rcu() respects existing readers, so why this could happen?


>
> To prevent this, we call rcu_synchronize at first. Then we are sure all
> latest rcu functions e.g. rcu_assign_pointer and kfree_rcu in init are
> done. After rcu_synchronize we dereference under RTNL lock which is also
> held in init function, which means no other rcu_assign_pointer or
> kfree_rcu will occur.

If you really want to wait for kfree_rcu(), rcu_barrier() is the one
instead of rcu_synchronize(). Just FYI.


>
> To call rcu_synchronize will also prevent weird behaviours by doing over
> netlink:
>
>  - set params A
>  - set params B
>  - dump params
>   \--> will dump params A


What's wrong with this? Existing readers could still read old data,
which is _perfectly_ fine as long as we don't free the old data before
they are gone.
