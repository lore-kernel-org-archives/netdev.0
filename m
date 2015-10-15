From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 1/4] net_sched: introduce qdisc_replace() helper
Date: Wed, 14 Oct 2015 21:13:21 -0700
Message-ID: <CAM_iQpW5r=nY889aiu53_CBPxNyMWQzQG53f5Ouhm+B1Njh7Pw@mail.gmail.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
	<1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
	<20151013.185448.842417293758576210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33343 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbbJOENW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 00:13:22 -0400
Received: by oiar126 with SMTP id r126so39597505oia.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 21:13:22 -0700 (PDT)
In-Reply-To: <20151013.185448.842417293758576210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 6:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon, 12 Oct 2015 11:38:00 -0700
>
>> Remove nearly duplicated code and prepare for the following patch.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> This isn't an equivalent transformation:
>
>> +static inline struct Qdisc *qdisc_replace(struct Qdisc *sch, struct Qdisc *new,
>> +                                       struct Qdisc **pold)
>> +{
>> +     struct Qdisc *old;
>> +
>> +     sch_tree_lock(sch);
>> +     old = *pold;
>> +     *pold = new;
>> +     if (old != NULL) {
>> +             qdisc_tree_decrease_qlen(old, old->q.qlen);
>> +             qdisc_reset(old);
>> +     }
>> +     sch_tree_unlock(sch);
>> +
>> +     return old;
>> +}
>> +
>
> Is not the same as:
>
>> diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
>> index f26bdea..c76cdd4 100644
>> --- a/net/sched/sch_drr.c
>> +++ b/net/sched/sch_drr.c
>> @@ -226,11 +226,7 @@ static int drr_graft_class(struct Qdisc *sch, unsigned long arg,
>>                       new = &noop_qdisc;
>>       }
>>
>> -     sch_tree_lock(sch);
>> -     drr_purge_queue(cl);
>> -     *old = cl->qdisc;
>> -     cl->qdisc = new;
>> -     sch_tree_unlock(sch);
>> +     *old = qdisc_replace(sch, new, &cl->qdisc);
>>       return 0;
>>  }
>>
>
> This.
>
> If you want to change semantics, you must do it explicitly in a separate
> commit with a detailed commit message explaining how and why.

If you meant drr_purge_queue(),  it is same:

static void drr_purge_queue(struct drr_class *cl)
{
        unsigned int len = cl->qdisc->q.qlen;

        qdisc_reset(cl->qdisc);
        qdisc_tree_decrease_qlen(cl->qdisc, len);
}

Or if you mean the 'if', always having one if doesn't harm, do it?
