From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 2/2] net/sched: fix filter flushing
Date: Mon, 22 May 2017 06:42:44 -0400
Message-ID: <ebf100e6-e927-35bd-3c3a-9bd481237979@mojatatu.com>
References: <20170520130132.1626-1-jiri@resnulli.us>
 <20170520130132.1626-2-jiri@resnulli.us>
 <CAM_iQpWha6aCV3kOfCEFsBLNiC7LFTh=K=QaL17rH4=PUoeUmQ@mail.gmail.com>
 <20170521055416.GA1848@nanopsycho>
 <CAM_iQpVPuC-FQ3R4QNDCBWxrX5s7Q4bENxMU7+1LooCdHdMZhw@mail.gmail.com>
 <20170521191941.GA4278@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com,
        Colin King <colin.king@canonical.com>
To: Jiri Pirko <jiri@resnulli.us>, Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35698 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbdEVKmq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 06:42:46 -0400
Received: by mail-qk0-f193.google.com with SMTP id k74so18298235qke.2
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 03:42:46 -0700 (PDT)
In-Reply-To: <20170521191941.GA4278@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-21 03:19 PM, Jiri Pirko wrote:
> Sun, May 21, 2017 at 08:27:21PM CEST, xiyou.wangcong@gmail.com wrote:
>> On Sat, May 20, 2017 at 10:54 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Sun, May 21, 2017 at 02:16:45AM CEST, xiyou.wangcong@gmail.com wrote:
>>>> On Sat, May 20, 2017 at 6:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> +static void tcf_chain_destroy(struct tcf_chain *chain)
>>>>> +{
>>>>> +       list_del(&chain->list);
>>>>> +       tcf_chain_flush(chain);
>>>>>          kfree(chain);
>>>>>   }
>>>>>
>>>>> @@ -510,7 +517,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>>>>>
>>>>>          if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
>>>>>                  tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
>>>>> -               tcf_chain_destroy(chain);
>>>>> +               tcf_chain_flush(chain);
>>>>
>>>>
>>>> I wonder if we should return EBUSY and do nothing in case of busy?
>>>> The chain is no longer visual to new actions after your list_del(), but
>>>> the old one could still use and see it.
>>>
>>> No. User request to flush the chain, that is what happens in the past
>>> and that is what should happen now.
>>> If there is still a reference, the chain_put will keep the empty chain.
>>
>> But if you dump the actions, this chain is still shown "goto chain"?
> 
> Yes, it will be shown there.
> 
> 
>> You can't claim you really delete it as long as actions can still
>> see it and dump it.
> 
> No, user just wants to delete all the filters. That is done. User does
> not care if the actual chain structure is there or not.
> 

I am trying to visualize a scenario where this is a problem.
Using gact action it may be  possible to cause issues (requires
validating - when i get time I will test).
Steps are something like:

1. create filter on chain 11 (refcnt = 1)
2. create gact action index 5 goto chain 11 (refcnt =2)
3'. create new filter on chain 0 ... action gact index 5
3''. create new filter on chain 0 ... action gact index 5


None of the #3 steps will increment the refcnt.
Delete the filter from #1 (refcnt becomes 1)
Delete the filter from #3'1 (refcnt = 0, destroy happens)
Filter #3'' is still hanging there. Dump that and strange things
happen.

cheers,
jamal
