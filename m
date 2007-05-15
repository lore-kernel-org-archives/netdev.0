From: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when real-servers
 are removed
Date: Tue, 15 May 2007 11:46:52 +0200
Message-ID: <4649818C.5070903@tis.icnet.pl>
References: <200704271705.l3RH5Brw026873@hera.kernel.org> <4648382E.8030009@trash.net> <20070514.033504.48528120.davem@davemloft.net> <4648714E.9050200@tis.icnet.pl> <464872E2.2030502@trash.net> <464884EE.3030606@tis.icnet.pl> <46489F5C.4000801@trash.net> <20070515052608.GG13708@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d1.icnet.pl ([212.160.220.21]:40872 "EHLO d1.icnet.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759330AbXEOJrE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 05:47:04 -0400
In-Reply-To: <20070515052608.GG13708@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> On Mon, May 14, 2007 at 07:41:48PM +0200, Patrick McHardy wrote:
>> So you're adding a local route for non-local destination and the
>> address selection in icmp_send() uses the original destination
>> address as source because the route has RTCF_LOCAL set, resulting
>> in an error in ip_route_output_slow().
> 
> I'm not entirely sure that "adding a local route" is the right
> terminology, but then again, perhaps I'm missunderstanding exactly
> what that means.

What I do exactly is:
   ip rule add prio 1000 fwmark $IF_MARK_LVS lookup lvs
   ip route replace table lvs local default dev lo
> 
> My undersanding of the problem is that IPVS likes to send icmp to notify
> end-users when real-servers are down. 

Yes, there is one such place in IPVS code too, inside ip_vs_leave(),
used for notifying clients on service overload.

> The source ip of such icmp is the
> VIP, that is the IP address associated with the virtual service.
> However, it is quite valid for this VIP not to be configured on the
> machine that is running IPVS. Thus the machine in question wants to send
> icmp packets with a non-local source address.
> 
> http://archive.linuxvirtualserver.org/html/lvs-users/2007-01/msg00109.html
> 
>> If thats correct than this patch should also work, it changes
>> icmp_send() to check if the original destination address is
>> non-local when deciding whether to pick a new address (and
>> reverts the routing changes).
> I think that your patch looks good, assuming that inet_addr_type(VIP)
> is going to return RTN_LOCAL (except in the unlikely case that VIP is
> multicast or something silly like that.

For now, I have no place other than my production firewall cluster to
verify this patch. I will do it as soon as possible and give you some
feedback.
> 
> However, I wonder if efficiency or safety reasons it might
> be better for IPVS to pass some sort of OK_ITS_SUPPSED_TO_BE_NON_LOCAL
> flag into ip_route(). 

Do you mean packets that are passed through ip_vs_in()?. If not, please
remember that current IPVS code does not send any ICMP port unreachable
messages except for this rare overload case. I still have no idea how to
solve more common problem of notifying clients on dead real server
inside the IPVS code itself, to avoid my complicated tricks of marking
based on connection tracking.

On the other hand, I have to state that even if I can now send
notifications to clients using my method, this does not solve my real
problem of broken ipsec connections going through LVS director. Openswan
clients I use do not care about ICMP port unreachable messages an insist
on using connections that are invalid due to switched real server. So
maybe we should first verify if there are any real cases when notifying
udp clients with ICMP port unreachable may be realy usefull and then
decide if we do need this functionality.

Janusz


P.S. Simon, sorry for duplicated message.
