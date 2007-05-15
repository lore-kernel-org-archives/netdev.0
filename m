From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers
 are removed
Date: Tue, 15 May 2007 18:11:35 +0200
Message-ID: <4649DBB7.3070608@trash.net>
References: <200704271705.l3RH5Brw026873@hera.kernel.org> <4648382E.8030009@trash.net> <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl> <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl> <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39485 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757347AbXEOQM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 12:12:26 -0400
In-Reply-To: <20070515052608.GG13708@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> On Mon, May 14, 2007 at 07:41:48PM +0200, Patrick McHardy wrote:
> 
>>So you're adding a local route for non-local destination and the
>>address selection in icmp_send() uses the original destination
>>address as source because the route has RTCF_LOCAL set, resulting
>>in an error in ip_route_output_slow().
> 
> 
> I'm not entirely sure that "adding a local route" is the right
> terminology, but then again, perhaps I'm missunderstanding exactly
> what that means.

It means adding a route to the local table, which causes the
resulting dst_entry to be marked with RTCF_LOCAL.

> My undersanding of the problem is that IPVS likes to send icmp to notify
> end-users when real-servers are down. The source ip of such icmp is the
> VIP, that is the IP address associated with the virtual service.
> However, it is quite valid for this VIP not to be configured on the
> machine that is running IPVS. Thus the machine in question wants to send
> icmp packets with a non-local source address.
> 
> http://archive.linuxvirtualserver.org/html/lvs-users/2007-01/msg00109.html
> 
> I think that your patch looks good, assuming that inet_addr_type(VIP)
> is going to return RTN_LOCAL (except in the unlikely case that VIP is
> multicast or something silly like that.

I'm not familiar with the IPVS terms, but as far as I understand,
it is _not_ going to return RTN_LOCAL, so we get the desired
behaviour of selecting a local address as source.

> However, I wonder if efficiency or safety reasons it might
> be better for IPVS to pass some sort of OK_ITS_SUPPSED_TO_BE_NON_LOCAL
> flag into ip_route(). 
> 
> Just a thought.

I'm not too thrilled about adding a route flag when it really is
ICMP address selection that is the problem here.

The patch should be completely safe since multicast and broadcast
packets are already filtered out earlier and the RTN_LOCAL test
matches exactly what ip_route_output_slow does.
