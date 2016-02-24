From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify software
 only rules
Date: Tue, 23 Feb 2016 23:24:09 -0800
Message-ID: <56CD5A99.6070009@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810> <20160223190321.5970.58924.stgit@john-Precision-Tower-5810> <20160224061128.GB12134@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36009 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756813AbcBXHYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 02:24:23 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so7875157pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 23:24:22 -0800 (PST)
In-Reply-To: <20160224061128.GB12134@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 10:11 PM, Simon Horman wrote:
> On Tue, Feb 23, 2016 at 11:03:21AM -0800, John Fastabend wrote:
>> In the initial implementation the only way to stop a rule from being
>> inserted into the hardware table was via the device feature flag.
>> However this doesn't work well when working on an end host system
>> where packets are expect to hit both the hardware and software
>> datapaths.
>>
>> For example we can imagine a rule that will match an IP address and
>> increment a field. If we install this rule in both hardware and
>> software we may increment the field twice. To date we have only
>> added support for the drop action so we have been able to ignore
>> these cases. But as we extend the action support we will hit this
>> example plus more such cases. Arguably these are not even corner
>> cases in many working systems these cases will be common.
>>
>> To avoid forcing the driver to always abort (i.e. the above example)
>> this patch adds a flag to add a rule in software only. A careful
>> user can use this flag to build software and hardware datapaths
>> that work together. One example we have found particularly useful
>> is to use hardware resources to set the skb->mark on the skb when
>> the match may be expensive to run in software but a mark lookup
>> in a hash table is cheap. The idea here is hardware can do in one
>> lookup what the u32 classifier may need to traverse multiple lists
>> and hash tables to compute. The flag is only passed down on inserts
>> on deletion to avoid stale references in hardware we always try
>> to remove a rule if it exists.
>>
>> Notice we do not add a hardware only case here. If you were to
>> add a hardware only case then you are stuck with the problem
>> of where to stick the software representation of that filter
>> rule. If its stuck on the same filter list as the software only and
>> software/hardware rules it then has to be walked over and ignored
>> in the classify path. The overhead is not huge but is measurable.
>> And with so much work being invested in speeding up rx/tx of
>> pkt processing this is unacceptable IMO. The other option is to
>> have a special hook just for hardware only resources. This is
>> implemented in the next patch.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> [snip]
> 
>> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
>> index f766bcb..c509fc8 100644
>> --- a/net/sched/cls_u32.c
>> +++ b/net/sched/cls_u32.c
>> @@ -59,6 +59,7 @@ struct tc_u_knode {
>>  #ifdef CONFIG_CLS_U32_PERF
>>  	struct tc_u32_pcnt __percpu *pf;
>>  #endif
>> +	u32			flags;
>>  #ifdef CONFIG_CLS_U32_MARK
>>  	u32			val;
>>  	u32			mask;
>> @@ -425,12 +426,18 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
>>  	return 0;
>>  }
>>  
>> -static bool u32_should_offload(struct net_device *dev)
>> +static bool u32_should_offload(struct net_device *dev, u32 flags)
>>  {
>>  	if (!(dev->features & NETIF_F_HW_TC))
>>  		return false;
>>  
>> -	return dev->netdev_ops->ndo_setup_tc;
>> +	if (flags & TCA_U32_FLAGS_SOFTWARE)
>> +		return false;
>> +
>> +	if (!dev->netdev_ops->ndo_setup_tc)
>> +		return false;
>> +
>> +	return true;
>>  }
>>  
>>  static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
>> @@ -442,7 +449,7 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
>>  	offload.type = TC_SETUP_CLSU32;
>>  	offload.cls_u32 = &u32_offload;
>>  
>> -	if (u32_should_offload(dev)) {
>> +	if (u32_should_offload(dev, 0)) {
>>  		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
>>  		offload.cls_u32->knode.handle = handle;
>>  		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
> 
> Here a request is made to delete the classifier from hardware regardless
> of if TCA_U32_FLAGS_SOFTWARE is set or not. This seems sensible to me.
> 
> 
>> @@ -450,7 +457,9 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
>>  	}
>>  }
>>  
>> -static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>> +static void u32_replace_hw_hnode(struct tcf_proto *tp,
>> +				 struct tc_u_hnode *h,
>> +				 u32 flags)
>>  {
>>  	struct net_device *dev = tp->q->dev_queue->dev;
>>  	struct tc_cls_u32_offload u32_offload = {0};
>> @@ -459,7 +468,7 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>>  	offload.type = TC_SETUP_CLSU32;
>>  	offload.cls_u32 = &u32_offload;
>>  
>> -	if (u32_should_offload(dev)) {
>> +	if (u32_should_offload(dev, flags)) {
>>  		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
>>  		offload.cls_u32->hnode.divisor = h->divisor;
>>  		offload.cls_u32->hnode.handle = h->handle;
> 
> But here an update is only made if flag is TCA_U32_FLAGS_SOFTWARE.
> 
> I wonder if this means we can get into a situation where the classifier
> present in software and hardware differ. Something like this.
> 
> 1. classifier is added to software and hardware (TCA_U32_FLAGS_SOFTWARE is set)
> 2. classifier is updated in software only (TCA_U32_FLAGS_SOFTWARE is not set)
> 

So the update will only update the software copy in this case but the
handle wont change so when the delete eventually does come it will
delete both the software copy and hardware copy but they will be out
of sync.

It does seem better if we do not let the flags get changed and if a
rule is created with SOFTWARE only require it to stay SOFTWARE only
for the duration of the rule. And going the other way if a rule is
configured in both hardware/software do not let it get changed to
SOFTWARE only.

I'll send a v2 with this change.

>> @@ -479,7 +488,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>>  	offload.type = TC_SETUP_CLSU32;
>>  	offload.cls_u32 = &u32_offload;
>>  
>> -	if (u32_should_offload(dev)) {
>> +	if (u32_should_offload(dev, 0)) {
>>  		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
>>  		offload.cls_u32->hnode.divisor = h->divisor;
>>  		offload.cls_u32->hnode.handle = h->handle;
>> @@ -490,7 +499,9 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>>  	}
>>  }
>>  
>> -static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
>> +static void u32_replace_hw_knode(struct tcf_proto *tp,
>> +				 struct tc_u_knode *n,
>> +				 u32 flags)
>>  {
>>  	struct net_device *dev = tp->q->dev_queue->dev;
>>  	struct tc_cls_u32_offload u32_offload = {0};
>> @@ -499,7 +510,7 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
>>  	offload.type = TC_SETUP_CLSU32;
>>  	offload.cls_u32 = &u32_offload;
>>  
>> -	if (u32_should_offload(dev)) {
>> +	if (u32_should_offload(dev, flags)) {
>>  		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
>>  		offload.cls_u32->knode.handle = n->handle;
>>  		offload.cls_u32->knode.fshift = n->fshift;
> 
> [snip]
> 
