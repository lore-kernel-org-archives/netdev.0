From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] net: ipv4: Multipath needs to handle unreachable
 nexthops
Date: Fri, 25 Mar 2016 11:05:38 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1603251024390.1896@ja.home.ssi.bg>
References: <1458833154-39091-1-git-send-email-dsa@cumulusnetworks.com> <alpine.LFD.2.11.1603242201200.1795@ja.home.ssi.bg> <56F49CD3.1060406@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55384 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751181AbcCYJFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 05:05:45 -0400
In-Reply-To: <56F49CD3.1060406@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 24 Mar 2016, David Ahern wrote:

> On 3/24/16 4:33 PM, Julian Anastasov wrote:
> > 	But for multipath routes we can also consider the
> > nexthops as "alternatives", so it depends on how one uses
> > the multipath mechanism. The ability to fallback to
> > another nexthop assumes one connection is allowed to
> > move from one ISP to another. What if the second ISP
> > decides to reject the connection? What we have is a
> > broken connection just because the retransmits
> > were diverted to wrong place in the hurry. So, the
> > nexthops can be compatible or incompatible. For your
> > setup they are, for others they are not.
> 
> I am not sure I completely understand your point. Are you saying that within a
> single multipath route some connections to nexthops are allowed and others are
> not?
> 
> So to put that paragraph into an example
> 
> 15.0.0.0/16
> 	nexthop via 12.0.0.2  dev swp1 weight 1
> 	nexthop via 12.0.0.3  dev swp1 weight 1
> 
> Hosts from 15.0/16 could have TCP connections use 12.0.0.2, but not 12.0.0.3
> because 12.0.0.3 could be a different ISP and not allow TCP connections from
> this address space?

	Yes. Two cases are possible:

1. ISP2 filters saddr, traffic with saddr from ISP1 is dropped.

2. ISP2 allows any saddr. But how the responses from
world with daddr=IP_from_ISP1 will come from ISP2 link?
If the nexthops are for different ISP the connection
can survive only if sticks to its ISP. An ISP will
not work as a backup link for another ISP.

	The hash-based algorithm does not move connections
from one nexthop to another. If you rearrange the nexthops
on failure, the binding is lost and connections can break.
A fallback from fragile wifi link can upset users and any
redirects will lead to bad experience with broken conns.
So only CONNMARK can help to stick connection to some path.
If this path has multiple simultaneous alternatives you can
again use multipath route reached from 'ip rule from PUBIP2 table ISP2'
but then we again are restricted from the hash-based alg
which is suitable only for default routes hit by saddr=0.0.0.0
lookups. In the common case when connection is created
there are two lookups:

1. TCP selects nexthop with a saddr=0.0.0.0 lookup.
ISP is selected based on the mp alg.

2. If one is lucky to reach ip_route_me_harder the
hash-based lookup is defeated because now lookup
uses saddr=iph->saddr, so it selects different nexthop.
It works while all packets for the connection reach
ip_route_me_harder.

> > 	So, if the kernel used a random selection
> > your fallback algorithm should help. But it is fragile
> > for the simple setup with single default multipath route.
> > May be what we miss is the ability to choose between
> > random and hash-based selection. Then your patch may be
> > useful but only for setup 2 (multipath route hit only by
> > first packet). So, your patch may come with a sysctl var
> > that explains your current patch logic: "avoid failed nexthops,
> > never probe them, wait their failed entry to be expired by
> > neigh_periodic_work and just then we can use the nexthop
> > by creating new entry to probe the GW". Who will trigger
> > probes often enough to maintain fresh state?
> 
> First packet out does the probe -- neigh lookup fails, kernel has no knowledge
> so can't reject the nexthop based on neighbor information.
> 
> After that if it has information that says that a nexthop is dead, why would
> it continue to try to probe? Any traffic that selects that nh is dead. That to

	If entry becomes FAILED this state is preserved
if we do not direct traffic to this entry. If there was a
single connection that was rejected after 3 failed probes
the next connection (with your patch) will fallback to
another neigh and the first entry will remain in FAILED
state until expiration. If one wants to refresh the state
often, a script/tool that pings all GWs is needed, so that
you can notice the available or failed paths faster.

> me defies the basis of having multiple paths.

	We do not know how long is the outage. Long living
connections may prefer to survive with retransmits.
Say you are using SSH via wifi link doing important work.
Do you want your connection to break just because link was
down for a while?

	Fallback to other ISP can be unwanted. If we do not
know if multipath route is used per-packet ot per-connection
we can not just apply a fallback to other nexthops.
We can do it only if user can configure the different
usages per multipath route:

1. hash-based or random

2. allow fallback or not. This config is not a MUST if users
can select random mode, it can imply that fallback is allowed.

Regards
