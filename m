From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Thu, 27 Nov 2008 20:53:09 +0200
Message-ID: <200811272053.10009.opurdila@ixiacom.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com> <200811271602.16128.opurdila@ixiacom.com> <1227799867.16263.517.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:15919 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752295AbYK0S5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 13:57:41 -0500
In-Reply-To: <1227799867.16263.517.camel@ecld0pohly>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Thu, 27 Nov 2008 16:31:07 +0100

> On Thu, 2008-11-27 at 14:02 +0000, Octavian Purdila wrote:
> > From: Patrick Ohly <patrick.ohly@intel.com>
> > Date: Thu, 27 Nov 2008 11:07:07 +0100
> >
> > > To summarize, I see the following options at this time:
> >
> > [snip]
> >
> > > My personal preference is, in this order: 3, 4, 2b (current patch,
> > > but needs clean way to find network device), 1a.
> >
> > I also vote for 3 (storing hw timestamps in the skb).
> >
> > Let me throw in another idea: when enabling hw timestamps could we
> > allocate a bigger skb and store the hw timestamp somewhere in the skb
> > data buffer?
>
> How does the socket layer detect that the HW timestamp is available in
> the larger skb data buffer, and where?
>

It doesn't know, thats why we need help from the device (the new netdev 
method).

> > We can then modify sock_recv_timestamp to call a new netdev method which
> > should return the hw timestamp. This should take care of RX hw
> > timestamps.
>
> Finding the netdev is non-trivial, see David's comment about the current
> hacky approach via the route. 
>

OK I see now, it seems that we can't get to the device in a generic way. 

How about this twist: we add a new option at the socket level, to get the 
whole skb->head - skb->end data into a user buffer. Then, we call an device 
ioctl and pass this buffer. The device will extract the hw timestamp and give 
it to the user. 

We might not need to get the whole skb->head - skb->end buffer, maybe just skb-
>head - skb->mac if we know that skb->mac is sane at the socket level and we 
use the convention that the device driver must put the timestamp below the mac 
header.

One potential problem I see with this approach is leaking sensitive 
information into userspace, which means we will have to restrict this to 
privileged processes only.

tavi

