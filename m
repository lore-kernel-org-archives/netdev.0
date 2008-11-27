From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Thu, 27 Nov 2008 16:02:15 +0200
Message-ID: <200811271602.16128.opurdila@ixiacom.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com> <492E3AAE.3000709@hartkopp.net> <1227780427.16263.468.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1544 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751125AbYK0OGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 09:06:47 -0500
In-Reply-To: <1227780427.16263.468.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Thu, 27 Nov 2008 11:07:07 +0100

> It certainly would be sufficient for PTP with the "assisted" PTP mode of
> synchronizing system time. But my understanding is that Octavian and
> possibly others want to have access to the raw, unmodified hardware time
> stamps. Octavian, perhaps you can confirm/elaborate what your use case
> is?

We use the hardware timestamp to determine one-way delay:
- hardware synchronize the NIC clocks (20ns resolution)
- insert the hw timestamp in the packet as its going out the wire (this is 
done in hw)
- received packets will be tagged with a hardware timestamp

One way delay is computed by subtracting the TX hw timestamp from the RX hw 
timestamp.

> To summarize, I see the following options at this time:
[snip]
> My personal preference is, in this order: 3, 4, 2b (current patch,
> but needs clean way to find network device), 1a.

I also vote for 3 (storing hw timestamps in the skb). 

Let me throw in another idea: when enabling hw timestamps could we allocate a 
bigger skb and store the hw timestamp somewhere in the skb data buffer? 

We can then modify sock_recv_timestamp to call a new netdev method which 
should return the hw timestamp. This should take care of RX hw timestamps.

For TX, we can we get a new skb with skb_copy_expand  to make room for the TX 
timestamp, and queue that in the error socket. 

There is still the problem of requesting TX timestamps per packets. At this 
point it seems that on the TX path the tstamp field is not used, so we could 
use that space. 

Or, maybe we can use the same dynamic approach: can we modify the 
hard_header_len after device registration (e.g. when TX timestamps are 
enabled)?

Thanks,
tavi





