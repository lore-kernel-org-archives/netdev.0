From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net v3 2/4] net/sched: Use action array instead of action
 list as parameter
Date: Wed, 18 Oct 2017 09:32:34 -0700
Message-ID: <CAM_iQpU4FRBNAwhN=AVqi44-h1mds7v6c4tK_e_q+xVC3A7D+g@mail.gmail.com>
References: <1508203218-17998-1-git-send-email-chrism@mellanox.com>
 <1508203218-17998-3-git-send-email-chrism@mellanox.com> <CAM_iQpUz4bKhb2uUiBBeXL6f6BfdAND7sW+az5MjbjbifRnmhw@mail.gmail.com>
 <VI1PR0501MB2143ABD1C4794B98468B42B7AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Lucas Bates <lucasb@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        David Miller <davem@davemloft.net>
To: Chris Mi <chrism@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:45264 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdJRQcz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 12:32:55 -0400
Received: by mail-pg0-f52.google.com with SMTP id b192so4705086pga.2
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 09:32:55 -0700 (PDT)
In-Reply-To: <VI1PR0501MB2143ABD1C4794B98468B42B7AB4D0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 5:58 PM, Chris Mi <chrism@mellanox.com> wrote:
>
>
>> -----Original Message-----
>> From: Cong Wang [mailto:xiyou.wangcong@gmail.com]
>> Sent: Wednesday, October 18, 2017 12:56 AM
>> To: Chris Mi <chrism@mellanox.com>
>> Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>; Jamal Hadi
>> Salim <jhs@mojatatu.com>; Lucas Bates <lucasb@mojatatu.com>; Jiri Pirko
>> <jiri@resnulli.us>; David Miller <davem@davemloft.net>
>> Subject: Re: [patch net v3 2/4] net/sched: Use action array instead of action
>> list as parameter
>>
>> On Mon, Oct 16, 2017 at 6:20 PM, Chris Mi <chrism@mellanox.com> wrote:
>> > When destroying filters, actions should be destroyed first.
>> > The pointers of each action are saved in an array. TC doesn't use the
>> > array directly, but put all actions in a doubly linked list and use
>> > that list as parameter.
>> >
>> > There is no problem if each filter has its own actions. But if some
>> > filters share the same action, when these filters are destroyed, RCU
>> > callback fl_destroy_filter() may be called at the same time. That
>> > means the same action's 'struct list_head list'
>> > could be manipulated at the same time. It may point to an invalid
>> > address so that system will panic.
>>
>> So if we remove these RCU callbacks (by adding a sychronize_rcu) this is not a
>> problem, right?
> Maybe you are right. But do you think it will cause performance issue, I mean it takes
> longer time to destroy filters if using synchronize_rcu()?

Yeah, this is why I said it is arguable, this is slow path anyway,
and RTNL lock is already a bottleneck. ;)


> Or is there any other races than RCU callbacks?
> We haven't found them.  This is the only one we found.

I wouldn't complain if this were the only case, however we already
fixed at least 2 race-condition bugs because of these rcu callbacks...

Take a look at this commit, all of its complexity is because of
rcu callback:

commit 1697c4bb5245649a23f06a144cc38c06715e1b65
Author: Cong Wang <xiyou.wangcong@gmail.com>
Date:   Mon Sep 11 16:33:32 2017 -0700

    net_sched: carefully handle tcf_block_put()


Also this one:

commit c78e1746d3ad7d548bdf3fe491898cc453911a49
Author: Daniel Borkmann <daniel@iogearbox.net>
Date:   Wed May 20 17:13:33 2015 +0200

    net: sched: fix call_rcu() race on classifier module unloads
