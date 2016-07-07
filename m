From: Thomas Morin <thomas.morin@orange.com>
Subject: Re: [PATCH net-next v2 0/4] net: support MPLS in IPv4 and UDP
Date: Thu, 7 Jul 2016 11:30:59 +0200
Message-ID: <e55e4b30-a569-44a6-cc1a-4d65030c1798@orange.com>
References: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r-mail1.rd.orange.com ([217.108.152.41]:57900 "EHLO
	r-mail1.rd.orange.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbcGGJsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 05:48:51 -0400
In-Reply-To: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

Great to see this being supported!

Something that would be a nice improvement would be a way to control the 
outer IP destination in the route nexthop, rather than via a tunnel 
interface remote IP which has the drawback of requiring one tunnel per 
remote endpoint, with the associated scaling issue and the book-keeping 
related to creating/deleting them.

Tom had suggested to me that it could be done in the lwtunnel framework, 
which seems indeed to make sense.

Best,

-Thomas

PS: two side notes on your sample configuration:
- I guess it should be "echo 1 > /proc/sys/net/mpls/conf/tun1/input" 
instead of "echo 1 > /proc/sys/net/mpls/conf/eth0/input"
- couldn't you skip "ip addr .. dev tun1", and just do "ip -f mpls route 
add 100 as 200/300 dev tun1" ?


2016-07-07, Simon Horman:
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
> Simon Horman (4):
>   tunnels: support MPLS over IPv4 tunnels
>   sit: support MPLS over IPv4
>   ipip: support MPLS over IPv4
>   mpls: allow routes on ipip and sit devices
>
>  net/ipv4/ipip.c    | 137 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  net/ipv4/tunnel4.c |  77 ++++++++++++++++++++++++++----
>  net/ipv6/sit.c     |  93 +++++++++++++++++++++++++++++-------
>  net/mpls/af_mpls.c |   6 ++-
>  4 files changed, 269 insertions(+), 44 deletions(-)
>
