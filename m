From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v5 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 10:25:11 -0400
Message-ID: <67dc8e10-b0df-c0c5-7c46-ac4147c1c797@mojatatu.com>
References: <1492693582-26810-1-git-send-email-jhs@emojatatu.com>
 <1492693582-26810-2-git-send-email-jhs@emojatatu.com>
 <20170420135915.GE1886@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35694 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946258AbdDTOZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:25:16 -0400
Received: by mail-io0-f196.google.com with SMTP id d203so17008492iof.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:25:14 -0700 (PDT)
In-Reply-To: <20170420135915.GE1886@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 09:59 AM, Jiri Pirko wrote:
> Thu, Apr 20, 2017 at 03:06:21PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> When you dump hundreds of thousands of actions, getting only 32 per
>> dump batch even when the socket buffer and memory allocations allow
>> is inefficient.
>>
>> With this change, the user will get as many as possibly fitting
>> within the given constraints available to the kernel.
>>
>> A new top level TLV space is introduced. An attribute
>> TCAA_ACT_FLAGS is used to carry the flags indicating the user
>> is capable of processing these large dumps. Older user space which
>> doesn't set this flag doesn't get the large (than 32) batches.
>> The kernel uses the TCAA_ACT_COUNT attribute to tell the user how many
>> actions are put in a single batch. As such user space app knows how long
>> to iterate (independent of the type of action being dumped)
>> instead of hardcoded maximum of 32.
>>
>> Some results dumping 1.5M actions, first unpatched tc which the
>> kernel doesn't help:
>>
>> prompt$ time -p tc actions ls action gact | grep index | wc -l
>> 1500000
>> real 1388.43
>> user 2.07
>> sys 1386.79
>>
>> Now lets see a patched tc which sets the correct flags when requesting
>> a dump:
>>
>> prompt$ time -p updatedtc actions ls action gact | grep index | wc -l
>> 1500000
>> real 178.13
>> user 2.02
>> sys 176.96
>>
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>> ---
>> include/uapi/linux/rtnetlink.h | 21 +++++++++++++++++--
>> net/sched/act_api.c            | 46 +++++++++++++++++++++++++++++++++---------
>> 2 files changed, 55 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>> index cce0613..d7d28ec 100644
>> --- a/include/uapi/linux/rtnetlink.h
>> +++ b/include/uapi/linux/rtnetlink.h
>> @@ -674,10 +674,27 @@ struct tcamsg {
>> 	unsigned char	tca__pad1;
>> 	unsigned short	tca__pad2;
>> };
>> +
>> +enum {
>> +	TCAA_UNSPEC,
>
> TCAA stands for "traffic control action action". I don't get it :(

TC Action Attributes == TCAA.

> Prefix still sounds wrong to me, sorry :/
> Should be:
> TCA_SOMETHING_*
>

TCA_ATTR_XXX ?

I have another opportunity to make a change  where we should close
the discussion on this. We cant drag it forever.

cheers,
jamal
