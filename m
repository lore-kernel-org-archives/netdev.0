From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH net-next v2 0/4] net: support MPLS in IPv4 and UDP
Date: Fri, 8 Jul 2016 11:25:04 +0000
Message-ID: <CY1PR11MB041028C21370053AA7E63140933C0@CY1PR11MB0410.namprd11.prod.outlook.com>
References: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Tom Herbert <tom@herbertland.com>, netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0101.outbound.protection.outlook.com ([104.47.37.101]:18800
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755174AbcGHNEj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 09:04:39 -0400
In-Reply-To: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Simon Horman
> Sent: Thursday, July 07, 2016 11:26 AM
> To: David Miller <davem@davemloft.net>
> Cc: Tom Herbert <tom@herbertland.com>; netdev <netdev@vger.kernel.org>;
> Simon Horman <simon.horman@netronome.com>
> Subject: [PATCH net-next v2 0/4] net: support MPLS in IPv4 and UDP
> 
> This short series provides support for MPLS in IPv4 (RFC4023), and by
> virtue of FOU, MPLS in UDP (RFC7510).
> 
> The changes are as follows:
> 1. Teach tunnel4.c about AF_MPLS, it already understands AF_INET and
>    AF_INET6
> 2. Enhance IPIP and SIT to handle MPLS. Both already handle IPv4.
>    SIT also already handles IPv6.
> 3. Trivially enhance MPLS to allow routes over SIT and IPIP tunnels.
> 
> A corresponding patch set for iproute2 has also been provided.
> 
> 
> Changes since v1
> * Correct inverted IPIP protocol logic in SIT patch
> * Provide usage example below
> 
> 
> Sample configuration follows:
> 
> * The following creates a tunnel and routes MPLS packets whose outermost
>   label is 100 over it. The forwarded packets will have the outermost label
>   stack entry, 100, removed and two label stack entries added, the
>   outermost having label 200 and the next having label 300.
> 
>   The local end-point for the tunnel is 10.0.99.192 and the remote
>   endpoint is 10.0.99.193.
> 
>   The local address for encapsulated packets is 10.0.98.192 and the
>   remote address is 10.0.98.193.
> 
>   # Create an MPLS over IPv4 tunnel using the IPIP driver
>   ip link add name tun1 type ipip remote 10.0.99.193 local 10.0.99.192 \
> 	ttl 225 mode mplsip
> 
>   # Bring the tunnel up and an add an IPv4 address and route
>   ip link set up dev tun1
>   ip addr add 10.0.98.192/24 dev tun1
> 
>   # Set MPLS route
>   # Allow MPLS forwarding of packets recieved on eth0
>   echo 1 > /proc/sys/net/mpls/conf/eth0/input
>   # Larger than label to be routed (100)
>   echo 101 > /proc/sys/net/mpls/platform_labels
>   ip -f mpls route add 100 as 200/300 via inet 10.0.98.193
> 
> 
> * For FOU (in this case MPLS over UDP) a tunnel may created using:
> 
>   # Packets recieved on UDP port 6635 are MPLS over UDP (IP proto 137)
>   ip fou add port 6635 ipproto 137
>   # Create the tunnel netdev
>   ip link add name tun1 type ipip remote 10.0.99.193 local 10.0.99.192 \
> 	ttl 225 mode mplsip encap fou encap-sport auto encap-dport 6635
> 
>   IPv4 address, link and route, and MPLS routing commands are as per
>   the MPLS over IPv4 example
> 
> * To use the SIT driver instead of the IPIP driver "ipip" may be substituted
>   for "sit" in the above examples.
> 
> * To create a tunnel that forwards and receives all supported
>   inner-protocols "mplsip" may be substituted for "any" in the above
>   examples.
> 
>   For the IPIP driver this configures both IPv4 and MPLS over IPv4.
>   For the SIT driver this configures IPv6, IPv4 and MPLS over IPv4.
> 
> 

Hi Simon, I have questions in general for how to test MPLS in Linux [Earlier, I have asked the same on this forum but unfortunately, no one responded :-( ]
Saw your patches on MPLS with tunnels and hope that you might be the one to ask regarding this :-)

As I see usage examples above - I think this can be tested using just two linux hosts connected back to back [without any router/switch being present in between]. Right ?
Basically, In similar context, I want to test MPLS packets/traffic between just two base NIC driver interfaces connected back to back [Please see below configuration I have],
but so far I am not able to achieve such configuration which can drive MPLS traffic through the hardware [I don't even know if it's possible to achieve or not in this topology,
couldn't find anything related to this ].

Host A                                     Host B
########|                 	|########
        Eth0  <===========> Eth1
########|                	|########
IP: 192.168.44.20           IP: 192.168.44.21    

If there is such possible configuration using iproute2 , please let me know. I appreciate your help for this.

Thanks,
Manish
