From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Get rid of RCU callbacks in TC filters?
Date: Fri, 20 Oct 2017 13:52:05 -0700
Message-ID: <CAM_iQpUbPro-qauH-R5e6vBVMuOcC+qxSvRwkH69XjVK0Uau5g@mail.gmail.com>
References: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
 <20171018193548.GM3521@linux.vnet.ibm.com> <CAM_iQpWwaQuxZMidkVXsjDVwGcW+u-h5rczG2CO0s1RamRVUYQ@mail.gmail.com>
 <20171020165623.GM3521@linux.vnet.ibm.com> <CAM_iQpUL9xCrZCjCpcaBMyjSWEJ+1DsFMO6dwJVtVvz=zKJDxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Chris Mi <chrism@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:49890 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdJTUw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 16:52:26 -0400
Received: by mail-pf0-f173.google.com with SMTP id i5so12655646pfe.6
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 13:52:26 -0700 (PDT)
In-Reply-To: <CAM_iQpUL9xCrZCjCpcaBMyjSWEJ+1DsFMO6dwJVtVvz=zKJDxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 1:31 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Actually, I just tried this approach, this way makes the core tc filter
> code harder to wait for flying callbacks, currently rcu_barrier() is
> enough, with one more schedule_work() added we probably
> need flush_workqueue()... Huh, this also means I can't use the
> global workqueue so should add a new workqueue for tc filters.
>
> Good news is I seem to make it work without adding much code.
> Stay tuned. ;)

Hmm, lockdep already complains I have a deadlock when flushing
workqueue while hodling RTNL lock, because callbacks need RTNL
too... See the rcu_barrier() in tcf_block_put().

So this approach seems to be a dead end. Is there any way out?

Probably we have to convert call_rcu() to synchronize_rcu(),
but with batching of course.
