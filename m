From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix refcnt when GETing of
 action after bind
Date: Wed, 18 Jan 2017 06:33:52 -0500
Message-ID: <7a55a129-1e96-80f7-373d-1ff6a95b5269@mojatatu.com>
References: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpURppLMupbxCSqmZe866APGrcYficzaOTFNyzheQrrePg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33870 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752870AbdARLnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:43:25 -0500
Received: by mail-qt0-f195.google.com with SMTP id a29so1219949qtb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:41:59 -0800 (PST)
In-Reply-To: <CAM_iQpURppLMupbxCSqmZe866APGrcYficzaOTFNyzheQrrePg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 01:17 PM, Cong Wang wrote:
> On Sun, Jan 15, 2017 at 7:14 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index 2095c83..e10456ef6f 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -900,8 +900,6 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>>                         goto err;
>>                 }
>>                 act->order = i;
>> -               if (event == RTM_GETACTION)
>> -                       act->tcfa_refcnt++;
>>                 list_add_tail(&act->list, &actions);
>>         }
>>
>> @@ -914,7 +912,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>>                 return ret;
>>         }
>>  err:
>> -       tcf_action_destroy(&actions, 0);
>> +       if (event != RTM_GETACTION)
>> +               tcf_action_destroy(&actions, 0);
>
> Why this check for RTM_GETACTION? It does not make sense
> at least for the error case, that is, when tcf_action_get_1() fails
> in the middle of the loop, all the previous ones should be destroyed
> no matter it's GETACTION or DELACTION...
>
> Also, for the non-error case of GETACTION, they should be
> destroyed too after dumping to user-space, otherwise there is no
> way to use them since 'actions' is local to that function.
>
> I thought in commit aecc5cefc389 you grab that refcnt on purpose.
>

I did.
The issue there (after your original patch) was destroy() would
decrement the refcount to zero and a GET was essentially translated
to a DEL. Incrementing the refcount earlier protected against that
assuming destroy was going to decrement it.
However, when an action is bound the destroy() doesnt decrement
the refcnt. So the refcnt keeps going up forever (and therefore
deleting fails in the future). So we cant use destroy() as is.

We need another function to cover the scenario you are
describing. I had thought of using cleanup_a() for GET and leave
the refcount alone. But that is insufficient incase the module
refcounts went up. Maybe it is better to refactor get/del
to have different code paths (instead of the clever code reuse).


cheers,
jamal
