From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify software
 only rules
Date: Wed, 24 Feb 2016 00:55:55 -0800
Message-ID: <56CD701B.8070308@gmail.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810> <20160223190321.5970.58924.stgit@john-Precision-Tower-5810> <20160224080440.GA26500@office.Home> <20160224084057.GC2151@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>, "Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36769 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbcBXI4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 03:56:10 -0500
Received: by mail-pa0-f49.google.com with SMTP id yy13so9214450pab.3
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 00:56:09 -0800 (PST)
In-Reply-To: <20160224084057.GC2151@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 12:40 AM, Jiri Pirko wrote:
> Wed, Feb 24, 2016 at 09:04:40AM CET, amir@vadai.me wrote:
>> On Tue, Feb 23, 2016 at 11:03:21AM -0800, John Fastabend wrote:
>>> In the initial implementation the only way to stop a rule from being
>>> inserted into the hardware table was via the device feature flag.
>>> However this doesn't work well when working on an end host system
>>> where packets are expect to hit both the hardware and software
>>> datapaths.
>>>
>>> For example we can imagine a rule that will match an IP address and
>>> increment a field. If we install this rule in both hardware and
>>> software we may increment the field twice. To date we have only
>>> added support for the drop action so we have been able to ignore
>>> these cases. But as we extend the action support we will hit this
>>> example plus more such cases. Arguably these are not even corner
>>> cases in many working systems these cases will be common.
>>>
>>> To avoid forcing the driver to always abort (i.e. the above example)
>>> this patch adds a flag to add a rule in software only. A careful
>>> user can use this flag to build software and hardware datapaths
>>> that work together. One example we have found particularly useful
>>> is to use hardware resources to set the skb->mark on the skb when
>>> the match may be expensive to run in software but a mark lookup
>>> in a hash table is cheap. The idea here is hardware can do in one
>>> lookup what the u32 classifier may need to traverse multiple lists
>>> and hash tables to compute. The flag is only passed down on inserts
>>> on deletion to avoid stale references in hardware we always try
>>> to remove a rule if it exists.
>>>
>>> Notice we do not add a hardware only case here. If you were to
>>> add a hardware only case then you are stuck with the problem
>>> of where to stick the software representation of that filter
>>> rule. If its stuck on the same filter list as the software only and
>>> software/hardware rules it then has to be walked over and ignored
>>> in the classify path. The overhead is not huge but is measurable.
>>> And with so much work being invested in speeding up rx/tx of
>>> pkt processing this is unacceptable IMO. The other option is to
>>> have a special hook just for hardware only resources. This is
>>> implemented in the next patch.
>>>
>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> [...]
>>
>>>  
>>> -static bool u32_should_offload(struct net_device *dev)
>>> +static bool u32_should_offload(struct net_device *dev, u32 flags)
>>>  {
>>>  	if (!(dev->features & NETIF_F_HW_TC))
>>>  		return false;
>>>  
>>> -	return dev->netdev_ops->ndo_setup_tc;
>>> +	if (flags & TCA_U32_FLAGS_SOFTWARE)
>>> +		return false;
>>> +
>>> +	if (!dev->netdev_ops->ndo_setup_tc)
>>> +		return false;
>>> +
>>> +	return true;
>>>  }
>> This function and flag should be a generic filter attribute - not just
>> u32.
> 
> I agree, this should be generic.
> 
> Regarding flags attr, we have the same situation as with other common
> attrs:
> TCA_U32_POLICE
> TCA_FLOW_POLICE
> TCA_CGROUP_POLICE
> TCA_BPF_POLICE
> 
> TCA_U32_ACT
> TCA_FLOW_ACT
> TCA_CGROUP_ACT
> TCA_BPF_ACT
> TCA_FLOWER_ACT
> 
> I guess we have no other choice then to have
> TCA_U32_FLAGS
> TCA_FLOWER_FLAGS etc :(
> 

Sure if you want to lift it out of u32 I can do that. Seeing there are
no other users I planned to do it when I added the next hardware
classifier. But sure I can do it now and save a patch later.

The flags however likely stays with with TCA_U32_FLAGS until there is
some better way to group common attributes in 'tc' framework.

.John
