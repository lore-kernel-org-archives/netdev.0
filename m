From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Tue, 3 Jan 2012 14:45:59 -0500
Message-ID: <20120103194559.GB25184@hmsreliant.think-freely.org>
References: <20111228151928.GA12025@neilslaptop.think-freely.org>
 <20111228.133933.866545698956085305.davem@davemloft.net>
 <20111228192150.GA16499@neilslaptop.think-freely.org>
 <20111228.143812.206477268839022030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39579 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438Ab2ACTqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 14:46:03 -0500
Content-Disposition: inline
In-Reply-To: <20111228.143812.206477268839022030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 28, 2011 at 02:38:12PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 28 Dec 2011 14:21:50 -0500
> 
> > Clearly I misread the RFC the first time through and the test as it existed is
> > incorrect.  I'm wondering though if what we need is a way to lookup if we've
> > received a RA on the interface, and check to see if it has a source link layer
> > option attached to it.
> 
> Yes, we could implement this with a new neigh lookup routine, that allows
> keying on device pointer and flags.
> 
> So in this case we'd pass the device and NTF_ROUTER.  If the lookup returns
> non-NULL then we've seen an RA with SLLAO specified.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Dave, I've been looking at this for a bit, and I think the solution is even
easier than we first thought.  I'd forgotten two major items:

1) The optimistic flag rules only apply to SLAAC assigned addresses (section 3.1
of RFC 4429 specifically excludes manually address addresses from being flagged
as optimistic)

2) We only add SLAAC addresses to an interface after having received a router
solicitation containing a prefix and (possibly) a SLLAO option.

Because of the above, we can compeltely ignore the manual address add path as
far as the optimistic path is concerned.  Since we only call addrconf_prefix_rcv
(where we add the SLAAC address), from ndisc_router_discovery (where we receive
the new router advertisement, and parse its options), I think we can just
augment addrconf_prefix_rcv with an extra parameter (a bool flag), which is set
or cleared based on the value of the ND_OPT_SOURCE_LL_ADDR option in the ndopts
array.  addrconf_prefix_rcv can use that flag to set or clear the optimistic
flag.

Thoughts?
Neil
