From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/2] tg3: 5701 DMA corruption fix
Date: Fri, 18 Apr 2008 10:45:35 -0700
Message-ID: <1208540735.16633.102.camel@dell>
References: <20080416222741.GA20272@localdomain>
 <20080417.232612.04456205.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, netdev <netdev@vger.kernel.org>,
	andy@greyhouse.net, tonyb@cybernetics.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1602 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398AbYDRQmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 12:42:37 -0400
In-Reply-To: <20080417.232612.04456205.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-04-17 at 23:26 -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Wed, 16 Apr 2008 15:27:41 -0700
> 
> > +		while (pci_id->vendor != 0) {
> > +			bridge = pci_get_device(pci_id->vendor,
> > +						pci_id->device,
> > +						bridge);
> > +			if (!bridge) {
> > +				pci_id++;
> > +				continue;
> > +			}
> > +			if (bridge->subordinate &&
> > +			    (bridge->subordinate->number <=
> > +			     tp->pdev->bus->number) &&
> > +			    (bridge->subordinate->subordinate >=
> > +			     tp->pdev->bus->number)) {
> > +				tp->tg3_flags3 |= TG3_FLG3_5701_DMA_BUG;
> > +				pci_dev_put(bridge);
> > +				break;
> > +			}
> > +		}
> > +	}
> 
> This code block will leak bridge device objects when the table
> comparison check fails.

Do you mean having undecremented reference count on the bridge when it
doesn't match?

I think it is ok, because when we call pci_get_device() next time, we'll
pass in the old bridge so that it can find the next one.  pci_get_device
() will automatically decrement the reference count on the old bridge.

> 
> Probably the best thing to do is seperate the boolean check
> from the other operations:
> 
> 	bool match = false;
>  ...
> 	if (bridge->subordinate &&
> 	    (bridge->subordinate->number <=
> 	     tp->pdev->bus->number) &&
> 	    (bridge->subordinate->subordinate >=
> 	     tp->pdev->bus->number))
> 		match = true;
> 
> 	pci_dev_put_bridge(bridge);
> 
> 	if (match) {
> 		tp->tg3_flags |= TG3_FLG3_5701_DMA_BUG;
> 		pci_dev_put(bridge);
> 	}
> 
> Please fix this up, and combine the version bump into this patch.
> 
> Thank you!
> 

