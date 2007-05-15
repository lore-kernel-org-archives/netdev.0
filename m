From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Wed, 16 May 2007 02:41:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>
References: <200704271705.l3RH5Brw026873@hera.kernel.org> <4648382E.8030009@trash.net>
 <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl>
 <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl>
 <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au>
 <4649DBB7.3070608@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <horms@verge.net.au>,
	Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:3994 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757600AbXEOXuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 19:50:37 -0400
In-Reply-To: <4649DBB7.3070608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 15 May 2007, Patrick McHardy wrote:

> Simon Horman wrote:
> > On Mon, May 14, 2007 at 07:41:48PM +0200, Patrick McHardy wrote:
> > 
> >>So you're adding a local route for non-local destination and the
> >>address selection in icmp_send() uses the original destination
> >>address as source because the route has RTCF_LOCAL set, resulting
> >>in an error in ip_route_output_slow().
> > 
> > I'm not entirely sure that "adding a local route" is the right
> > terminology, but then again, perhaps I'm missunderstanding exactly
> > what that means.
> 
> It means adding a route to the local table, which causes the
> resulting dst_entry to be marked with RTCF_LOCAL.

	IPVS users add local route to user-defined (not "local") routing
table to deliver locally only selected traffic, eg. by fwmark. The use
is just like for transparent proxy, deliver port X for VIP locally,
other traffic for VIP is forwarded (hits unicast route).

	And it seems the idea is ICMP still to work for such scenarios,
icmp_send should know that this is authorized operation that can
avoid the source address check (saddr=VIP) in ip_route_output_slow.
If icmp_send is changed to use inet_addr_type() then ICMP will leave
with saddr != VIP and that is not nice.

	I think, icmp_send is fine as is, the main problem is how
to differentiate the ip_route_output_slow users to ones that need
the check for valid source address and others (eg. NAT) that expect
and allow source address to be non-local.

	It is interesting, what happens when some NAT rule maps
multiple internal addresses (one to one) to multiple non-local public
addresses, may be if packet from world is rejected we don't send ICMP
from the right public address? For example, if we are NAT router
with such rules:

internal 192.168.0.1 is mapped to public 10.0.0.1
internal 192.168.0.2 is mapped to public 10.0.0.2
...

where 10.0.0.0/16 are not configured as local IPs on the NAT router,
eg. when we don't want to add thousands of IPs.

World sends to 10.0.0.1 but the NAT router wants to send ICMP with
saddr=10.0.0.1 which is not local IP.

	So, the rule here is that NAT allows ICMP to use 10.0.0.0/16
as source address, even if such IPs are not configured. Of course,
one may use ip addr add 10.0.0.0/16 dev lo for such case and may be all
such examples can be solved somehow, i simply didn't tried such setups.

	 To summarize, what can help is a flag (eg. RT_ANYSRC) to
ip_route_output* that all special users can provide to skip the
check, for example:
	- RTCF_LOCAL packets in icmp_send() can avoid the check
	- NAT can avoid the check (ip_route_me_harder can be simplified?)

	 Currently, all callers use the check, so may be the goal can be
to start with small set of callers that can set the new flag. It looks
like we can save some CPU cycles too, ip_route_me_harder looks too
overloaded.

> > I think that your patch looks good, assuming that inet_addr_type(VIP)
> > is going to return RTN_LOCAL (except in the unlikely case that VIP is
> > multicast or something silly like that.
> 
> I'm not familiar with the IPVS terms, but as far as I understand,
> it is _not_ going to return RTN_LOCAL, so we get the desired
> behaviour of selecting a local address as source.

	But what is preferred is to use VIP in ICMP.

ip route add local VIP dev lo table user_defined

	returns RTCF_LOCAL but inet_addr_type() does not return RTN_LOCAL,
we fix one thing but break another :)

Regards

--
Julian Anastasov <ja@ssi.bg>
