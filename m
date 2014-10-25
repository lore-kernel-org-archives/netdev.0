From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init() fails
Date: Fri, 24 Oct 2014 17:36:09 -0700
Message-ID: <CAHA+R7N3jJCgOJjnDUxsTaH7ZCvPydDT60qkcqSPsEyFbp=UQg@mail.gmail.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	<1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
	<1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Patrick McHardy <kaber@trash.net>, Terry Lam <vtlam@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:33930 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbaJYAgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:36:10 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so1695374qac.21
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:36:09 -0700 (PDT)
In-Reply-To: <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 5:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-24 at 16:55 -0700, Cong Wang wrote:
>> In qdisc_create(), when ->init() exists and it fails, we should
>> call ->destroy() to clean up the potentially partially initialized
>> qdisc's. This will also make the ->init() implementation easier.
>>
>
> Why is this patch needed ?
>
> You are adding bugs, its not clear what bug you are fixing.


You missed what Wang Bo reported, we could double free
mq qdisc on failure path, one in mq_init() and one in qdisc_create_dflt().


>
> I really do not like the idea of ->init() relying on a ->destroy() to
> cleanup a failed ->init().
>
> This is not what most management functions do in our stack.
>
> I very much prefer that a function returning an error has no side
> effect, like if it hadnt be called at all.


If you would like to fix all qdisc_create_dflt() callers, yes, and good
luck with even more complex error handling there.

Read the diffstat, if we could fix a bug with less code, why not....

>
>> qdisc_create_dflt() already does that. Most callers of qdisc_create_dflt()
>> simply use noop_qdisc when it fails.
>>
>> And, most of the ->destroy() implementations are already able to clean up
>> partially initialization, we don't need to worry.
>>
>> The following ->init()'s need to catch up:
>> fq_codel_init(), hhf_init(), multiq_init(),  sfq_init(), mq_init(),
>> mqprio_init().
>>
>
> ...
>
>>
>>  static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
>> diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
>> index 3ec7e88..55ac6a4 100644
>> --- a/net/sched/sch_qfq.c
>> +++ b/net/sched/sch_qfq.c
>> @@ -522,7 +522,6 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
>>       return 0;
>>
>>  destroy_class:
>> -     qdisc_destroy(cl->qdisc);
>>       kfree(cl);
>>       return err;
>>  }
>
>
> Really ? I am calling this a leak of cl->qdisc.
>
>

How? I already added a comment on qdisc_create_dflt(), callers don't
need to clean up
on failure path.
