From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 11:21:06 -0700
Message-ID: <4DC19912.3000803@intel.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>	 <4DC18DF8.3090707@chelsio.com>  <4DC18FB2.8060604@intel.com> <1304532342.2926.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44216 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153Ab1EDSVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 14:21:07 -0400
In-Reply-To: <1304532342.2926.46.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/2011 11:05 AM, Ben Hutchings wrote:
> On Wed, 2011-05-04 at 10:41 -0700, Alexander Duyck wrote:
>> On 5/4/2011 10:33 AM, Dimitris Michailidis wrote:
>>> On 05/04/2011 10:24 AM, Ben Hutchings wrote:
>>>> On Wed, 2011-05-04 at 10:09 -0700, Dimitris Michailidis wrote:
>>>>> On 05/03/2011 04:34 PM, Ben Hutchings wrote:
>>>>>> On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
>>>>>>> I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is
>>>>>>> enough knowledge to pick an appropriate slot.  So I'd remove the
>>>>>>>
>>>>>>>        if (loc == RX_CLS_LOC_UNSPEC)
>>>>>>>
>>>>>>> block above, let the driver pick a slot, and then pass the selected location
>>>>>>> back for ethtool to report.
>>>>>> But first we have to specify this in the ethtool API.  So please propose
>>>>>> a patch to ethtool.h.
>>>>> In the past we discussed that being able to specify the first available slot or
>>>>> the last available would be useful, so something like the below?
>>>>>
>>>>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>>>>> index 4194a20..909ef79 100644
>>>>> --- a/include/linux/ethtool.h
>>>>> +++ b/include/linux/ethtool.h
>>>>> @@ -442,7 +442,8 @@ struct ethtool_flow_ext {
>>>>>      *	includes the %FLOW_EXT flag.
>>>>>      * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
>>>>>      *	if packets should be discarded
>>>>> - * @location: Index of filter in hardware table
>>>>> + * @location: Index of filter in hardware table, or %RX_CLS_FLOW_FIRST_LOC for
>>>>> + *	first available index, or %RX_CLS_FLOW_LAST_LOC for last available
>>>> [...]
>>>>
>>>> I think that's reasonable.  We should also explicitly state that
>>>> location determines priority, i.e. if a packet matches two filters then
>>>> the one with the lower location wins.
>>>
>>> Easy and true for a TCAM.  For hashing would you use the location to decide how
>>> to order filters that fall in the same bucket?
>>>
>>
>> The problem is none of this is backwards compatible.  The niu driver has
>> supported the network flow classifier rules since 2.6.30.  Adding this
>> would cause all rule setups for niu to fail because these locations
>> would have to exist outside of the current rule locations.
>
> Those rule setups would have to be using some unofficial patched
> ethtool.  I don't think that should be a major concern for us.
> However...

No, what I am saying is that if we were to add those locations to the 
ETHTOOL_SRXCLSRLINS then niu would not work anymore as it would treat 
them as invalid locations.  This existing setup will at least work with 
the existing niu from what I can tell.  If we were to try adding rules 
with locations outside of actual allowable rules then we would likely 
receive an indication that we provided an invalid argument.

>> This is why I was suggesting that the best approach would be to update
>> the kernel to add a separate ioctl for letting the driver setup the
>> location.
>>
>> We can just attempt to make that call and when we get the
>> EOPNOTSUPP errno we know the device driver doesn't support it and can
>> then let the rule manager take over.
>
> How about having ETHTOOL_GRXCLSRLCNT set a flag in the 'data' field to
> indicate that the driver can assign locations?  (We would have to
> specify that for compatibility with older kernels the application must
> initialise this filed to 0.)
>
> rmgr_init() would then check for this flag.
>
> I hope someone is actually going to test this on niu, as it sounds like
> that will be the only driver using a TCAM... David?
>
> Ben.
>

Honestly what I would prefer to see is a seperate call added such as an 
ETHTOOL_GRSCLSRLLOC that we could pass the flow specifier to and perhaps 
include first/last location call in that and then let the driver return 
where it wants to drop the rule.  That way we can avoid having to create 
an overly complicated rule manager that can handle all the bizarre rule 
ordering options that I am sure all the different network devices support.

The only reason I am not implementing this now is because there aren't 
any drivers in place that would currently use it.  I figure once cxgb 
has a means in place of supporting flow classifier rules then Dimitris 
can add the necessary code to ethtool and the kernel to allow the driver 
to specify rule locations.  I would prefer to avoid adding features 
based on speculation of what will be needed and would like to be able to 
actually see how the features will be used.

Thanks,

Alex

