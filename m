From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Wed, 28 Dec 2011 14:21:50 -0500
Message-ID: <20111228192150.GA16499@neilslaptop.think-freely.org>
References: <20111227.140652.1729386263761283235.davem@davemloft.net>
 <20111227.145305.229364634255751368.davem@davemloft.net>
 <20111228151928.GA12025@neilslaptop.think-freely.org>
 <20111228.133933.866545698956085305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38665 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463Ab1L1TWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 14:22:02 -0500
Content-Disposition: inline
In-Reply-To: <20111228.133933.866545698956085305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 28, 2011 at 01:39:33PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 28 Dec 2011 10:19:28 -0500
> 
> > Yeah, If the premise that the test never triggers is true (and it seems like
> > you've confirmed that), then theres no harm in removing it.  It still
> > seems like we might still need the test somewhere (maybe on a manual route add).
> > I've family in town, so I'm not able to look at this closely today, but I'd say this
> > is at least a harmless change right now.  Lets take this change, and I'll
> > re-read the RFC and look for appropriate code paths where we may need this
> > test in a few days.  Thanks Dave!
> > 
> > Acked-By: Neil Horman <nhorman@tuxdriver.com>
> 
> Thanks for reviewing Neil, I've applied this patch to net-next.
No problem, I got some time this afternoon, and I've reread the relevant section
of RFC 4429, and clearly I made a mistake in the above test, but I'm a little
confused over what the test should be.  The relevant language from the RFC is:

3.3 Modifications to RFC 2462 Stateless Address Autoconfiguration

   * (modifies section 5.5) A host MAY choose to configure a new address
        as an Optimistic Address.  A host that does not know the SLLAO
        of its router SHOULD NOT configure a new address as Optimistic.
        A router SHOULD NOT configure an Optimistic Address.

So my read of that is that, when we are adding a new address to the host, we
should not make the address optimistic if:

1) The interface is acting as a router - We catch this with the !forwarding
check in addrconf_prefix_rcv, although we should perhaps move that to a common
code path, as we won't catch that if we manually add an ipv6 address via
inet6_rtm_newaddr

2) If the interface has not recieved a router advertizement, and that
solicitation did not contain a source link layer option in it.

Clearly I misread the RFC the first time through and the test as it existed is
incorrect.  I'm wondering though if what we need is a way to lookup if we've
received a RA on the interface, and check to see if it has a source link layer
option attached to it.

Thoughts?
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
