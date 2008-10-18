From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Sat, 18 Oct 2008 22:37:01 +0300
Message-ID: <200810182237.02373.opurdila@ixiacom.com>
References: <1224253423.17450.211.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [92.87.192.98] ([92.87.192.98]:12528 "EHLO ixro-ex1.ixiacom.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750958AbYJRT5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 15:57:16 -0400
In-Reply-To: <1224253423.17450.211.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date:	Fri, 17 Oct 2008 16:23:43 +0200

> The only solution that I see is to use one bit as flag to distinguish
> between hardware and software time stamps, as Octavian originally
> suggested. 

There is one more approach that I think it could work.

Once hardware times-tamping has been enabled, the driver will:
a) compute the delta between the system time and the hardware time
b) store in the skb the hardware timestamp + delta (thus effectively using an 
approximation of system time which I think it should be OK since system time 
is not that precise anyway)

This is the approach that Stephen used in his patch for sky2. But we need 
more, we need to get the "untainted" hardware timestamps to userspace.

And we can to that through a driver specific ioctl (or maybe via a new ethtool 
method?):

hwtimestamp htimestamp_ioctl(timestamp)
{
	return timestamp - delta;
}

There are some corner cases with this approach: 

1. Reseting hardware timestamps. Our devices do that when the hardware 
timestamps are synchronized across different cards, in which case hardware 
timestamps are all reseted to zero. 

We can easily detect this condition (current hardware timestamp < hardware 
timestamp at the moment at which we computed the delta) and update the delta.

2. When the hardware is unable to generate a hardware timestamps (Patrick 
mentioned that this may occur with certain hardware).

In that case the driver should generate a system time timestamp. 

The problem here is that we want to distinguish between system and hardware 
timestamps. A possible approach would be to use a slightly coarser precision 
(say Xns instead of 1ns) and then use the modulo X to encode state into the 
timestamp.

For example, we could say that hardware timestamp = (hwtimestamp/X)*X and 
software timestamp = ((system time/X)*X) +1

Than, in the hwtimestamp_ioctl we can check if a received time is software or 
hardware, and we can let the application know.

We can even compute the delta periodically now, to maintain better system - 
hardware timestamps synchronization, as we can keep and multiple deltas (each 
one associated with a modulo number).

Thanks,
tavi

