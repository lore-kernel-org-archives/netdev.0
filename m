From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Get rid of RCU callbacks in TC filters?
Date: Fri, 20 Oct 2017 13:31:43 -0700
Message-ID: <CAM_iQpUL9xCrZCjCpcaBMyjSWEJ+1DsFMO6dwJVtVvz=zKJDxA@mail.gmail.com>
References: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
 <20171018193548.GM3521@linux.vnet.ibm.com> <CAM_iQpWwaQuxZMidkVXsjDVwGcW+u-h5rczG2CO0s1RamRVUYQ@mail.gmail.com>
 <20171020165623.GM3521@linux.vnet.ibm.com>
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
Received: from mail-pf0-f195.google.com ([209.85.192.195]:49330 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbdJTUcE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 16:32:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id i5so12594848pfe.6
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 13:32:04 -0700 (PDT)
In-Reply-To: <20171020165623.GM3521@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 9:56 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Thu, Oct 19, 2017 at 08:26:01PM -0700, Cong Wang wrote:
>> On Wed, Oct 18, 2017 at 12:35 PM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>> > 5) Keep call_rcu(), but have the RCU callback schedule a workqueue.
>> > The workqueue could then use blocking primitives, for example, acquiring
>> > RTNL.
>>
>> Yeah, this could work too but we would get one more async...
>>
>> filter delete -> call_rcu() -> schedule_work() -> action destroy
>
> True, but on the other hand you get to hold RTNL.

I can get RTNL too with converting call_rcu() to synchronize_rcu().
;)

So this turns into the question again: if we mind synchronize_rcu()
on slow paths or not?

Actually, I just tried this approach, this way makes the core tc filter
code harder to wait for flying callbacks, currently rcu_barrier() is
enough, with one more schedule_work() added we probably
need flush_workqueue()... Huh, this also means I can't use the
global workqueue so should add a new workqueue for tc filters.

Good news is I seem to make it work without adding much code.
Stay tuned. ;)

>
>> > 6) As with #5, have the RCU callback schedule a workqueue, but aggregate
>> > workqueue scheduling using a timer.  This would reduce the number of
>> > RTNL acquisitions.
>>
>> Ouch, sounds like even one more async:
>>
>> filter delete -> call_rcu() -> schedule_work() -> timer -> flush_work()
>> -> action destroy
>>
>> :-(
>
> Indeed, the price of scalability and performance is often added
> asynchronous action at a distance.  But sometimes you can have
> scalability, performance, -and- synchronous action.  Not sure that this
> is one of those cases, but perhaps someone will come up with some trick
> that we are not yet seeing.
>
> And again, one benefit you get from the added asynchrony is the ability
> to acquire RTNL.  Another is increased batching, allowing the overhead
> of acquiring RTNL to be amortized over a larger number of updates.

Understood, my point is it might not be worthy to optimize a slow path
which already has RTNL lock...


>
>> > 7) As with #5, have the RCU callback schedule a workqueue, but have each
>> > iterator accumulate a list of things removed and do call_rcu() on the
>> > list.  This is an alternative way of aggregating to reduce the number
>> > of RTNL acquisitions.
>>
>> Yeah, this seems working too.
>>
>> > There are many other ways to skin this cat.
>>
>> We still have to pick one. :) Any preference? I want to keep it as simple
>> as possible, otherwise some day I would not understand it either.
>
> I must defer to the people who actually fully understand this code.

I understand that code, just not sure about which approach I should
pick.

I will keep you Cc'ed for any further change I make.

Thanks!
