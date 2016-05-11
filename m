From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net-next 2/2] net: cls_u32: Add support for skip-sw flag
 to tc u32 classifier.
Date: Wed, 11 May 2016 16:44:55 -0700
Message-ID: <5733C3F7.1060800@intel.com>
References: <1462821524-2534-1-git-send-email-sridhar.samudrala@intel.com>	<1462821524-2534-2-git-send-email-sridhar.samudrala@intel.com> <20160511.192316.1290350535833930948.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:3440 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbcEKXpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 19:45:15 -0400
In-Reply-To: <20160511.192316.1290350535833930948.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 5/11/2016 4:23 PM, David Miller wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Date: Mon,  9 May 2016 12:18:44 -0700
>
>> On devices that support TC U32 offloads, this flag enables a filter to be
>> added only to HW. skip-sw and skip-hw are mutually exclusive flags. By
>> default without any flags, the filter is added to both HW and SW, but no
>> error checks are done in case of failure to add to HW. With skip-sw,
>> failure to add to HW is treated as an error.
> I really want you to provide a "[PATCH net-next 0/2]" header posting
> explaining what this series is doing, and why.

Sure. Will submit a v2 with a header patch in a day or so after waiting 
for any other comments.

>
> This is a core semantic issue, and we have to make sure all amongst us
> that we are all comfortable with exporting the offloadability controls
> in the way you are implementing them.

I tried to implement the semantics based on an earlier discussion about 
these flags in this
email thread.
     http://thread.gmane.org/gmane.linux.network/401733


>
> Also:
>
>> @@ -871,10 +889,15 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>>   			return err;
>>   		}
>>   
>> +		err = u32_replace_hw_knode(tp, new, flags);
>> +		if (err) {
>> +			u32_destroy_key(tp, new, false);
>> +			return err;
>> +		}
>> +
>>   		u32_replace_knode(tp, tp_c, new);
>>   		tcf_unbind_filter(tp, &n->res);
>>   		call_rcu(&n->rcu, u32_delete_key_rcu);
>> -		u32_replace_hw_knode(tp, new, flags);
>>   		return 0;
>>   	}
>>   
> Are you sure this reordering is OK?

I think so. This reordering is required to support skip-sw semantic of 
returning error in case of failure to add to hardware.
It doesn't break the default semantics of adding to both hw and sw as 
u32_replace_hw_knode() will not return err if skip-sw is not set.

Thanks
Sridhar
