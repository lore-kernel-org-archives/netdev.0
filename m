From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 14:07:36 -0700
Message-ID: <4DC1C018.5090709@intel.com>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>	 <4DC18DF8.3090707@chelsio.com>  <4DC18FB2.8060604@intel.com>	 <1304532342.2926.46.camel@bwh-desktop>  <4DC19912.3000803@intel.com> <1304534738.2926.74.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32548 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755754Ab1EDVHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 17:07:51 -0400
In-Reply-To: <1304534738.2926.74.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/2011 11:45 AM, Ben Hutchings wrote:
> On Wed, 2011-05-04 at 11:21 -0700, Alexander Duyck wrote:
> [...]
>> Honestly what I would prefer to see is a seperate call added such as an
>> ETHTOOL_GRSCLSRLLOC that we could pass the flow specifier to and perhaps
>> include first/last location call in that and then let the driver return
>> where it wants to drop the rule.
>
> This must not be done as a separate operation because it's racy (in fact
> that's an inherent problem with the rule manager).  In the sfc driver
> (and probably others in future) filters could be inserted for RFS at any
> time.
>
>> That way we can avoid having to create
>> an overly complicated rule manager that can handle all the bizarre rule
>> ordering options that I am sure all the different network devices support.
>
> Right, the rule manager can't implement that.
>
>> The only reason I am not implementing this now is because there aren't
>> any drivers in place that would currently use it.  I figure once cxgb
>> has a means in place of supporting flow classifier rules then Dimitris
>> can add the necessary code to ethtool and the kernel to allow the driver
>> to specify rule locations.  I would prefer to avoid adding features
>> based on speculation of what will be needed and would like to be able to
>> actually see how the features will be used.
>
> If you are going to implement the same interface in ixgbe as in niu
> (modulo bugs), then I have no objection to going ahead with this and
> then adding the option for driver-assigned locations later.
>
> Please can you confirm that the location specified for
> ETHTOOL_SRXCLSRLINS will indeed be used as a priority in case of
> overlapping filters?
>
> Ben.
>

The ixgbe approach should be nearly identical in terms of how the 
priorities are based on the location of the filters.  The original 
version from Santwona had the rule manager breaking the rules up into 7 
sections so that rules that specified fewer fields would be near the end 
of the list.  I'm pretty sure that was all due to priorities from what I 
could see in the niu driver since the filters that covered wider ranges 
were being made lower priority to be matched last.

In terms of overloading the get count call, that probably would be the 
best route in terms of changing rule manager behavior.  The only thing I 
am having a hard time seeing is how the rule manager would be able to 
distinguish between low priority and high priority filter rules, or is 
this something that new keywords would be added to the parser for?

I just put out version 6 of the patches.  Essentially I have reduced the 
size of the rule manager to being used only on insertion without any 
rule location specified.  The one thing to keep in mind with this rule 
manager is that the rule at table size - 1 is always going to be the 
lowest priority rule.  So if it was reserved for unspecified rules it 
would be easy to use something like that to achieve an "auto-select" 
location that the driver could then reassign as rules were added to it.

Thanks,

Alex

