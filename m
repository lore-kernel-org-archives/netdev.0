From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Mon, 07 Mar 2011 09:04:56 -0800
Message-ID: <4D751038.9040804@intel.com>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>	 <20110211011838.23554.3735.stgit@gitlad.jf.intel.com>	 <1298302841.2608.35.camel@bwh-desktop>  <4D642222.6050202@intel.com>	 <1298939712.2569.43.camel@bwh-desktop>  <4D7138EF.7050606@intel.com> <1299513430.2522.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60429 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889Ab1CGRFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 12:05:05 -0500
In-Reply-To: <1299513430.2522.9.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2011 7:57 AM, Ben Hutchings wrote:
> On Fri, 2011-03-04 at 11:09 -0800, Alexander Duyck wrote:
>> On 2/28/2011 4:35 PM, Ben Hutchings wrote:
>>> On Tue, 2011-02-22 at 12:52 -0800, Alexander Duyck wrote:
>>
>> [...]
>>
>>>>>>                                  } else
>>>>>>                                          show_usage(1);
>>>>>>                                  break;
>>>>>
>>>>> I don't think the same options (-n, -N) should be used both for flow
>>>>> hashing and n-tuple flow steering/filtering.  This command-line
>>>>> interface and the structure used in the ethtool API just seem to reflect
>>>>> the implementation in the niu driver.
>>>>>
>>>>> (In fact I would much prefer it if the -u and -U options could be used
>>>>> for both the rxnfc and rxntuple interfaces.  But I haven't thought about
>>>>> how the differences in functionality would be exposed to or hidden from
>>>>> the user.)
>>>>
>>>> I was kind of thinking about merging the two interfaces too, but I was
>>>> looking at it more from the perspective of moving away from ntuple more
>>>> towards this newer interface.  My main motivation being that the filter
>>>> display option is so badly broken for ntuple that it would be easier to
>>>> make ntuple a subset of the flow classifier instead of the other way around.
>>>>
>>>> What would you think of using the "flow-type" keyword to indicate legacy
>>>> ntuple support, and then adding something like "class-rule-add", and
>>>> "class-rule-del" to add support for the network flow classifier calls?
>>>
>>> I really don't want to introduce different syntax for functionality that
>>> is common between the two command sets.  The user should not have to
>>> know that driver A implements interface I and driver B implements
>>> interface J, except that since version 2.6.y driver A implements
>>> interface J too.
>>>
>>> Surely it is possible to try one interface, then the other, when the
>>> requested filter can be implemented either way?
>>
>> The problem is that the interfaces are different in the way they
>> implement their masks.  N-tuple defines the mask as 0s mean inclusion,
>> 1s, mean exclusion.
>
> You have got to be kidding me!
>
> If this is the case, then the current kernel-doc for
> ethtool_rx_flow_spec::m_u is incorrect.

That would be the case.  The m_u for ethtool_rx_flow_spec is 0 for bits 
to be ignored.  It is one of the things I really liked about that since 
in combination with the way the original patch generated the masks it 
would mean no goofy bit setting workarounds.

I think the documentation was added after the ethtool_rx_flow_spec and 
ethtool_rx_ntuple_flow_spec were and it looks like whoever added it 
probably assumed it worked the same way as ntuple.  I can probably 
submit an updated patch to correct the kernel-doc for that.

>> The network flow classifier filters are the exact
>> opposite.  As such we really need to know which type of filter we are
>> dealing with before we start setting up values.
>
> This is nonsense; it's not hard to flip the bits later.

Sorry about that I was probably thinking a bit too literally.  So what 
you are suggesting is that I store the values as a 1's compliment of 
what the user set as input for ethtool_rx_flow_spec.  I think I can 
manage that.

>> In addition there are
>> options such as location which exist in network flow classifier rules,
>> but not in ntuple rules.
>
> Sure, and when those are specified then there can be no fallback.
>
> Ben.
>

Actually now that I am thinking about it I could probably just ignore 
location for rules that end up being processed via ntuple.

The only time where location really matters is if you are attempting to 
overwrite an existing rule and I am not sure how that would be handled 
in ntuple anyway since right now adding additional rules via ntuple for 
ixgbe just results in duplicate rules being defined.

The idea I have for this now is to just record everything using the 
ethtool_rx_flow_spec.  With it extended to support VLAN and 64 bytes of 
data we should be able to just store everything in the one structure, 
try recording it to the hardware via the nfc interface, if that fails 
then copy the values except for location into a ntuple structure, and 
attempt to write it via the ntuple interface.

Thanks,

Alex
