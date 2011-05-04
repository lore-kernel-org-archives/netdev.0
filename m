From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Tue, 03 May 2011 18:35:55 -0700
Message-ID: <4DC0AD7B.7070009@chelsio.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop> <4DC09DE0.8070102@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22025 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab1EDBgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 21:36:03 -0400
In-Reply-To: <4DC09DE0.8070102@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2011 05:29 PM, Alexander Duyck wrote:
> On 5/3/2011 4:34 PM, Ben Hutchings wrote:
>> On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
>>> On 05/03/2011 09:12 AM, Alexander Duyck wrote:
>> [...]
>>>> +int rxclass_rule_ins(int fd, struct ifreq *ifr,
>>>> +             struct ethtool_rx_flow_spec *fsp)
>>>> +{
>>>> +    struct ethtool_rxnfc nfccmd;
>>>> +    __u32 loc = fsp->location;
>>>> +    int err;
>>>> +
>>>> +    /*
>>>> +     * if location is unspecified pull rules from device
>>>> +     * and allocate a free rule for our use
>>>> +     */
>>>> +    if (loc == RX_CLS_LOC_UNSPEC) {
>>>> +        /* init table of available rules */
>>>> +        err = rmgr_init(fd, ifr);
>>>> +        if (err<  0)
>>>> +            return err;
>>>> +
>>>> +        /* verify rule location */
>>>> +        err = rmgr_add(fsp);
>>>> +        if (err<  0)
>>>> +            return err;
>>>> +
>>>> +        /* cleanup table and free resources */
>>>> +        rmgr_cleanup();
>>>> +    }
>>>
>>> This logic where ethtool tries to select a filter slot when a user 
>>> provides
>>> RX_CLS_LOC_UNSPEC does not work in general.  It assumes that all 
>>> slots are
>>> equal and a new filter can go into any available slot. But a device 
>>> may have
>>> restrictions on where a filter may go that ethtool doesn't know.
>>
>> I agree.  And if filter lookup is largely hash-based (as it is in
>> Solarflare hardware) the user will also find it very difficult to
>> specify the right location!
> 
> The thing to keep in mind is that the index doesn't have to be a 
> hardware index.  In ixgbe we have a field in the hardware which is meant 
> to just be a unique software index and that is what I am using as the 
> location field for our filters.  All the location information in the 
> rules really provides is a logical way of tracking rules.  It doesn't 
> necessarily have to represent the physical location of the rule in 
> hardware.

I appreciate the intent but there are couple problems.
a) ethtool.h documents location as

  * @location: Index of filter in hardware table

i.e., physical location.  But we could change that.

b) for TCAMs physical location is important and if ethtool offers to provide 
only a logical index and massages the original user input to do so where 
will a driver get the physical location it ultimately needs?  For a device 
with physical indices a multiple of 4 the logical index ethtool picks will 
very frequently be illegal as physical location.  E.g., if location 1 is 
available ethtool will keep selecting it and the driver will need to deal 
with these requests without the benefit of knowing what the user really 
asked for.

Another problem with ethtool selecting locations is it assumes it's the sole 
allocator (I think there's a comment in the code pointing this out).  But 
this isn't a valid assumption, e.g., HW RFS comes to mind as another allocator.
