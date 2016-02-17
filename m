From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks
 for netdevs
Date: Wed, 17 Feb 2016 06:24:21 -0800
Message-ID: <56C48295.9030806@gmail.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810> <20160217051709.17139.88337.stgit@john-Precision-Tower-5810> <56C4528E.5090505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34990 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030330AbcBQOYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 09:24:34 -0500
Received: by mail-pf0-f174.google.com with SMTP id c10so12740223pfc.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 06:24:33 -0800 (PST)
In-Reply-To: <56C4528E.5090505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 02:59 AM, Jamal Hadi Salim wrote:
> On 16-02-17 12:17 AM, John Fastabend wrote:
>> This patch allows netdev drivers to consume cls_u32 offloads via
>> the ndo_setup_tc ndo op.
>>
>> This works aligns with how network drivers have been doing qdisc
>> offloads for mqprio.
>>
> 
> This one i have comments on.
> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>   include/linux/netdevice.h |    6 ++-
>>   include/net/pkt_cls.h     |   34 +++++++++++++++
>>   net/sched/cls_u32.c       |   99
>> ++++++++++++++++++++++++++++++++++++++++++++-

[...]

>>   #endif /* CONFIG_NET_CLS_IND */
>>
>> +struct tc_cls_u32_knode {
>> +    struct tcf_exts *exts;
>> +    u8 fshift;
>> +    u32 handle;
>> +    u32 val;
>> +    u32 mask;
>> +    u32 link_handle;
>> +    struct tc_u32_sel *sel;
>> +};
>>
> 
> Swapping sel and fshift would give better struct alignment.
> 

Makes sense I went ahead and did this.

>> +struct tc_cls_u32_hnode {
>> +    u32 handle;
>> +    u32 prio;
>> +    unsigned int divisor;
>> +};
> 
> 
> Assuming in the future "prio" would be moved to something that is more
> generic classifier specific?
> 

Sure in the future it can be moved up into a generic struct if
it becomes useful there.

>> +enum tc_clsu32_command {
>> +    TC_CLSU32_NEW_KNODE,
>> +    TC_CLSU32_REPLACE_KNODE,
>> +    TC_CLSU32_DELETE_KNODE,
>> +    TC_CLSU32_NEW_HNODE,
>> +    TC_CLSU32_REPLACE_HNODE,
>> +    TC_CLSU32_DELETE_HNODE,
>> +};
>> +
> 
> It seems to me commands should be generic which speak
> Netlinkism. A REPLACE is just a flag to NEW. You dont need
> a NEW_XXX for every object. switchdev got this right.
> If you use cmd + flags  then you can have all kinds of
> netlink semantics that relay user intent from user space. Example:
> Exclusivity where user says "create if it doesnt exist but dont replace
> if it does".
> At minimal add "flags" there.
> Maybe not this release - but it makes sense to move "command" into
> tc_to_netdev; a u16 cmd + u16 flags.
> 

Yep next set of patches add the specific hw/sw/both semantics
and specific error handling strategies. For this series we just
get the simplest one.

>> +struct tc_cls_u32_offload {
>> +    /* knode values */
>> +    enum tc_clsu32_command command;
>> +    union {
>> +        struct tc_cls_u32_knode knode;
>> +        struct tc_cls_u32_hnode hnode;
>> +    };
>> +};
>> +
>>   #endif
>> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>> index 4fbb674..d54bc94 100644
> 
>> +static void u32_replace_hw_hnode(struct tcf_proto *tp, struct
>> tc_u_hnode *h)
>> +{
>> +    struct net_device *dev = tp->q->dev_queue->dev;
>> +    struct tc_cls_u32_offload u32_offload = {0};
>> +    struct tc_to_netdev offload;
>> +
>> +    offload.type = TC_SETUP_CLSU32;
>> +    offload.cls_u32 = &u32_offload;
>> +
>> +    if (dev->netdev_ops->ndo_setup_tc) {
>> +        offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
> 
> TC_CLSU32_REPLACE_HNODE?
> 

Yep I made this change and will send out v4.

[...]

> 
> 
> You are unconditionally calling the _hw_ api. For someone not using _hw_
> offloads, there are a few more instructions. Maybe just do the
> dev->netdev_ops->ndo_setup_tc first?
> 

My simple add/rem stress test didn't seem to make any difference.
I think there is so much other stuff going on here this is in the
noise. I'll take a pass at optimizing this later for all
cases not just the hw loading ones.

> 
> And to Or's point: How do i distinguish s/w from h/w?

Next series handles this for now just enable the simplest case.

> 
> cheers,
> jamal
> 
