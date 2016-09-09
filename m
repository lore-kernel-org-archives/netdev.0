From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Thu, 8 Sep 2016 22:49:42 -0700
Message-ID: <CAM_iQpXyj9s=3UhKOWNKG5i2c2a62WVohE508-EQWHFtc4fPSQ@mail.gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com> <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33732 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbcIIFuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:50:03 -0400
Received: by mail-oi0-f66.google.com with SMTP id y2so4210314oie.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:50:03 -0700 (PDT)
In-Reply-To: <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 7:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-09-01 at 22:57 -0700, Cong Wang wrote:
>
>
>
> Missing changelog ?

I was too lazy to write a changelog for this RFC patch, surely
it will be added when removing RFC.


>
> Here I have no idea what you want to fix, since John already took care
> all this infra.
>
> Adding extra rcu_dereference() and rcu_read_lock() while the critical
> RCU dereferences already happen in callers is not needed.


Of course it is, TX and RX both have rcu read lock held.


>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/sched/act_api.c | 6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 2f8db3c..fb6ff52 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -470,10 +470,14 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
>>               goto exec_done;
>>       }
>>       for (i = 0; i < nr_actions; i++) {
>> -             const struct tc_action *a = actions[i];
>> +             const struct tc_action *a;
>>
>> +             rcu_read_lock();
>
> But the caller already has rcu_read_lock() or rcu_read_lock_bh()
>
> This was done in commit 25d8c0d55f241ce2 ("net: rcu-ify tcf_proto")

More precisely, it is __dev_queue_xmit() or netif_receive_skb_internal().
Not directly related to John.

The reason why I made it is to make it explicit that I take rcu_read_lock()
for tc action fast path, since it can be called recursively.

>
>> +             a = rcu_dereference(actions[i]);
>
>
> Add in your .config :
> CONFIG_SPARSE_RCU_POINTER=y
> make C=2 M=net/sched
>

Yeah, kbuild-robot already reported this to me, no worries,
fixing it is already in my TODO list.



>>  repeat:
>>               ret = a->ops->act(skb, a, res);
>> +             rcu_read_unlock();
>> +
>>               if (ret == TC_ACT_REPEAT)
>>                       goto repeat;    /* we need a ttl - JHS */
>>               if (ret != TC_ACT_PIPE)
>
>
>
> I do not believe this patch is necessary.
>
> Please add John as reviewer next time.
>

You missed the rcu_dereference() part.
