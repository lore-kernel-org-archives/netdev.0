From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Tue, 03 May 2011 17:29:20 -0700
Message-ID: <4DC09DE0.8070102@intel.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27044 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754766Ab1EDA3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 20:29:23 -0400
In-Reply-To: <1304465684.2873.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/2011 4:34 PM, Ben Hutchings wrote:
> On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
>> On 05/03/2011 09:12 AM, Alexander Duyck wrote:
> [...]
>>> +int rxclass_rule_ins(int fd, struct ifreq *ifr,
>>> +		     struct ethtool_rx_flow_spec *fsp)
>>> +{
>>> +	struct ethtool_rxnfc nfccmd;
>>> +	__u32 loc = fsp->location;
>>> +	int err;
>>> +
>>> +	/*
>>> +	 * if location is unspecified pull rules from device
>>> +	 * and allocate a free rule for our use
>>> +	 */
>>> +	if (loc == RX_CLS_LOC_UNSPEC) {
>>> +		/* init table of available rules */
>>> +		err = rmgr_init(fd, ifr);
>>> +		if (err<  0)
>>> +			return err;
>>> +
>>> +		/* verify rule location */
>>> +		err = rmgr_add(fsp);
>>> +		if (err<  0)
>>> +			return err;
>>> +
>>> +		/* cleanup table and free resources */
>>> +		rmgr_cleanup();
>>> +	}
>>
>> This logic where ethtool tries to select a filter slot when a user provides
>> RX_CLS_LOC_UNSPEC does not work in general.  It assumes that all slots are
>> equal and a new filter can go into any available slot. But a device may have
>> restrictions on where a filter may go that ethtool doesn't know.
>
> I agree.  And if filter lookup is largely hash-based (as it is in
> Solarflare hardware) the user will also find it very difficult to
> specify the right location!

The thing to keep in mind is that the index doesn't have to be a 
hardware index.  In ixgbe we have a field in the hardware which is meant 
to just be a unique software index and that is what I am using as the 
location field for our filters.  All the location information in the 
rules really provides is a logical way of tracking rules.  It doesn't 
necessarily have to represent the physical location of the rule in hardware.

>> I mentioned during a previous review that for cxgb4 some filters require a
>> slot number that is a multiple of 4.  There are some other constraints as
>> well depending on the type of filter being added. For such a device ethtool
>> doesn't know enough to handle RX_CLS_LOC_UNSPEC correctly.
>>
>> I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is
>> enough knowledge to pick an appropriate slot.  So I'd remove the
>>
>>       if (loc == RX_CLS_LOC_UNSPEC)
>>
>> block above, let the driver pick a slot, and then pass the selected location
>> back for ethtool to report.
>
> But first we have to specify this in the ethtool API.  So please propose
> a patch to ethtool.h.
>
> Ben.

The other thing to keep in mind with this is that it doesn't lock you 
into the network flow classifier configuration.  If you want to be able 
to specify a rule without having any location information included there 
is always the option of ntuple which accepts almost all the same fields 
but doesn't include any specific location information.

Thanks,

Alex

