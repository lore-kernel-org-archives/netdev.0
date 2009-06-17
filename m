From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix multi-ring polling [V2]
Date: Wed, 17 Jun 2009 04:40:26 -0700 (PDT)
Message-ID: <20090617.044026.244800766.davem@davemloft.net>
References: <alpine.WNT.2.00.0906161400001.6404@jbrandeb-MOBL3.amr.corp.intel.com>
	<20090616214213.GC8515@gospo.rdu.redhat.com>
	<alpine.WNT.2.00.0906161458590.6404@jbrandeb-MOBL3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751793AbZFQLkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 07:40:24 -0400
In-Reply-To: <alpine.WNT.2.00.0906161458590.6404@jbrandeb-MOBL3.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Tue, 16 Jun 2009 15:02:24 -0700 (Pacific Daylight Time)

> On Tue, 16 Jun 2009, Andy Gospodarek wrote:
>> Adding a check is no problem, but that means we need to save the
>> original budget.  It would be good to do that to avoid the WARN_ON_ONCE
>> in net_rx_action as well, but should we be cheating like that?  Here's
>> the new patch:
> 
> I hope davem can comment on that.
> 
>> [PATCH net-next-2.6] ixgbe: fix multi-ring polling V2
> 
> I think technically I'm okay with V2, the outstanding questions about what 
> exactly we should return need to be answered.

If you aren't going to complete the NAPI run, you must indicate
to the caller of ->poll() that you've consumed the entire budget.

This is the second driver where the multi-queue-in-one-irq "issue"
has been noticed.  Eric Dumazet posted a similar patch for NIU.

There are a few other ways to approach this problem, now that I've
thought about it for some time:

1) Use multiple NAPI contexts to represent the queues even if
   they are backed by a single interrupt.

2) Use only "1" queue if you only have "1" interrupt.  (replace
   "1" with "N" for all valid values of "N" :-)

Those approaches are a lot cleaner and keeps us from needing all
of this gross starvation-avoidance and budget faking code.
