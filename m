From: Alexander Aring <aring@mojatatu.com>
Subject: Re: [RFC net 1/1] net: sched: act: fix rcu race in dump
Date: Tue, 10 Oct 2017 14:09:46 -0400
Message-ID: <CAOHTApjGc0OjS7pYE+D7y79AHYERg4oo7HhCm777YrAGBeVxPw@mail.gmail.com>
References: <20171010123218.5251-1-aring@mojatatu.com> <20171010123218.5251-2-aring@mojatatu.com>
 <1507644745.31614.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
        netdev@vger.kernel.org, Manish Kurup <kurup.manish@gmail.com>,
        Brenda Butler <bjb@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:35575 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932569AbdJJSJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 14:09:48 -0400
Received: by mail-vk0-f66.google.com with SMTP id h191so8024740vke.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 11:09:47 -0700 (PDT)
In-Reply-To: <1507644745.31614.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Oct 10, 2017 at 10:12 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-10-10 at 08:32 -0400, Alexander Aring wrote:
>> This patch fixes an issue with kfree_rcu which is not protected by RTNL
>> lock. It could be that the current assigned rcu pointer will be freed by
>> kfree_rcu while dump callback is running.
>>
>> To prevent this, we call rcu_synchronize at first. Then we are sure all
>> latest rcu functions e.g. rcu_assign_pointer and kfree_rcu in init are
>> done. After rcu_synchronize we dereference under RTNL lock which is also
>> held in init function, which means no other rcu_assign_pointer or
>> kfree_rcu will occur.
>>
>> To call rcu_synchronize will also prevent weird behaviours by doing over
>> netlink:
>>
>>  - set params A
>>  - set params B
>>  - dump params
>>   \--> will dump params A
>>
>> This could be a unlikely case that the last rcu_assign_pointer was not
>> happened before dump callback.
>>
>> Signed-off-by: Alexander Aring <aring@mojatatu.com>
>> ---
>>  net/sched/act_skbmod.c | 7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
>> index b642ad3d39dd..231e07bca384 100644
>> --- a/net/sched/act_skbmod.c
>> +++ b/net/sched/act_skbmod.c
>> @@ -198,7 +198,7 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>>  {
>>       struct tcf_skbmod *d = to_skbmod(a);
>>       unsigned char *b = skb_tail_pointer(skb);
>> -     struct tcf_skbmod_params  *p = rtnl_dereference(d->skbmod_p);
>> +     struct tcf_skbmod_params  *p;
>>       struct tc_skbmod opt = {
>>               .index   = d->tcf_index,
>>               .refcnt  = d->tcf_refcnt - ref,
>> @@ -207,6 +207,11 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>>       };
>>       struct tcf_t t;
>>
>> +     /* wait until last rcu_assign_pointer/kfree_rcu is done */
>> +     rcu_synchronize();
>> +     /* RTNL lock prevents another rcu_assign_pointer/kfree_rcu call */
>> +     p = rtnl_dereference(d->skbmod_p);
>> +
>>       opt.flags  = p->flags;
>>       if (nla_put(skb, TCA_SKBMOD_PARMS, sizeof(opt), &opt))
>>               goto nla_put_failure;
>
> Sorry but no. This is plainly wrong.
>
> We need to fix this without adding a _very_ expensive rcu_synchronize()
> on a path which does not need such thing.
>

I agree that a rcu synchronize is very expensive while holding RTNL.
Should be handled with rcu_read_lock as you suggested below, but this
will not prevent to show an user space behavior like:

 - set_params(A)
 - set_params(B)
  \---> dump - will dump values A

Because the rcu_read_lock will avoid rcu_assign_pointer to update the
pointer and not wait that the rcu_assign_pointer of set_params(B) is
done before calling dump.
Okay, this issue is maybe something we should not care about it so far
it's not an use after free issue.


> I am confused by this patch, please tell us more what the problem is.
>

The callback "init" is also called by updating parameters for an action.

It use rcu_assign_pointer [0], as well kfree_rcu [1] to swap the
pointers of parameter structures and free the old resource.
This is well protected by rcu_read_lock inside the "run" callback of
tc action, which runs in softirq context. But dump is only protected
by RTNL so far I see.

Sorry when I understood RCU wrong, but so far I understood RCU
handling, it _could_ be that returning of "init" the pointers are not
updated yet. After a "grace" period, which rcu synchronize waits for
it - we can be sure that it's assigned and kfree_rcu completes.

The problem is:
If the deference of parameters inside dump callback using still the
old structure (for my understanding, it can happened because this
callback do nothing against it to protect it) kfree_rcu can free the
resource during accessing this structure. A RCU read lock will of
course preventing RCU to update the pointers in this time (but not
RTNL, so far I understood).

> I suspect rcu_read_lock() is what you need, but isn't a writer supposed
> to hold RTNL in net/sched/* ???
>

Yes a writer holds RTNL, but these writers using RCU to write (as
shown in [0] and [1]). So far I know kfree_rcu: it can occur that
"init" returns and dump is called afterwards - during the dump RCU can
run and free/assign pointers in this time (while dump still holds
references). So far I understand a RTNL lock will not prevent RCU to
do that.

I wrote this mail also to get an answer if there exists a problem or
not. If you say me, the resource cannot be freed by kfree_rcu if RTNL
lock is hold, then I know more about how RCU is working now.

- Alex

[0] http://elixir.free-electrons.com/linux/latest/source/net/sched/act_skbmod.c#L177
[1] http://elixir.free-electrons.com/linux/latest/source/net/sched/act_skbmod.c#L182
