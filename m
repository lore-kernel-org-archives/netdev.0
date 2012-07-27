From: Andy Gospodarek <gospo@redhat.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for
 loadbalancing too?
Date: Fri, 27 Jul 2012 10:55:14 -0400
Message-ID: <20120727145514.GB7323@quad.redhat.com>
References: <500EC5CF.3080400@genband.com>
 <20120724164220.GA1721@minipsycho.orion>
 <21683.1343153629@death.nxdomain>
 <500F032D.3070104@genband.com>
 <24104.1343162975@death.nxdomain>
 <500F15C3.4090906@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>, andy@greyhouse.net
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab2G0PV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 11:21:28 -0400
Content-Disposition: inline
In-Reply-To: <500F15C3.4090906@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 24, 2012 at 03:38:11PM -0600, Chris Friesen wrote:
> On 07/24/2012 02:49 PM, Jay Vosburgh wrote:
> >Chris Friesen<chris.friesen@genband.com>  wrote:
> >
> >>In loadbalance mode wouldn't it just work similar to active-backup?  If
> >>it's a reply then verify that it came from the arp target, if it's a
> >>request then check to see if it came from one of the other slaves.
> >
> >	The problem isn't verifying the requests or replies, it's that
> >the ARP packets are not distributed across all slaves (because the
> >switch ports are in a channel group / aggregator), so some slaves do not
> >receive any ARPs.
> 
> Yeah, okay.  And if we turn on arp validation then we ignore all the
> other packets and so they looks dead.  Got it.
If you wanted to make this work, I think it could pretty easily be done
if it isn't working right now.  Did you try arp_validate=all in your
setup?

> In our environment (ATCA shelf) the switches have been customized to
> handle some of this stuff so arpmon does work reliably with xor.
Good.

> In the general case it sounds like the "PF bonding ignores packets
> from VFs" is a better bet then.
It really might be.  There are some registers in the 82599 datasheets
that are not used by the ixgbe driver, but might help you in this area.

If you take a look at PFVML2FLT and PFUTA and their current status on
your system you might be able to put something together that gives you
what you want.

It would likely mean you have to run a custom ixgbe-driver, but that
doesn't sound like much of an issue.

> 
> 
> >>On 07/24/2012 02:18 PM, Chris Friesen wrote:
> >>>A more general solution might be to have the device driver also track
> >>>the time of the last incoming packet that came from the external network
> >>>(rather than a VF) and having the bond driver ignore those packets for
> >>>the purpose of link health.  Doing this efficiently would likely require
> >>>some kind of hardware support though--as an example the 82599 seems to
> >>>support this with the "LB" bit in the rx descriptor.
> >>
> >>That should of course be reversed.  We want the bond driver to only use
> >>the packets from the external network for the purpose of link health.
> >>
> >>Does anyone other than bonding actually care about dev->last_rx?  If not
> >>then we could just change the drivers to only set it for external packets.
> >That should of course be reversed.  We want the bond driver to only use
> >>the packets from the external network for the purpose of link health.
> >>
> >	I believe bonding is the main user of last_rx (a search shows a
> >couple of drivers using it internally).  For bonding use, in current
> >mainline last_rx is set by bonding itself, not in the network device
> >driver.
> 
> Right, I was looking at older code.  In that case presumably the
> driver could set an skb flag (external vs VF loopback) that the
> bonding code could check?
> 
> Chris
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
