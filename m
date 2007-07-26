From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Odd behaviour of proxy_arp (although I solved part of it and think I figured out what stupid thing it is doing)
Date: Thu, 26 Jul 2007 13:58:20 -0400
Message-ID: <20070726175820.GA28183@csclub.uwaterloo.ca>
References: <20070723203622.GA15500@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:42391 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763547AbXGZR6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 13:58:21 -0400
Received: from caffeine.csclub.uwaterloo.ca (localhost [127.0.0.1])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id 7E3F2740F2
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 13:58:20 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20070723203622.GA15500@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 23, 2007 at 04:36:22PM -0400, Lennart Sorensen wrote:
> I have been seeing some occasional strange behavior when using
> proxy_arp.  I have a router running with an ADSL PPPoE link to the
> Internet, and an Ethernet link to a local network.  It has proxy_arp
> enabled on the internal Ethernet port since I sometimes have ipsec
> tunnels running where I use proxy_arp to proxy for the IP assigned to
> the other end of the tunnel so that local machines can find and reach
> it.  I run two independent subnets on the local network (one with fixed
> IPs for my machines here, and another with DHCP addresses for guest
> machines that visit occasionally just to give them Internet access).
> 
> I run 10.0.0.0/8 and 192.168.254.0/24 on the local network with the
> router having an IP in each subnet.
> 
> The strangeness that occurs is that once in a while there is a 10
> second period where the system will answer all arp requests for all IPs
> on the local network, with it's own MAC address, which is clearly wrong
> since it doesn't have any of those IP addresses.  It seems to happen
> every couple of days or so on average, although not at any specific
> time.  One day it happened at 11:32:30 to 11:32:39, and a few days later
> it happened at 12:08:38 to 12:08:48.  If I disable proxy_arp, it never
> happens at all, but then I loose the ability to do what I have proxy_arp
> enabled for in the first place.

It turns out the reason for the 10 seconds or so, was to do with running
VRRP and how I handle routes in that situation, so I fixed that.  It
still doesn't solve the annoyance below.

> Related to that problem, there is also the annoyance that any IP that
> isn't part of either of the two subnets the router belongs to, have arp
> requests answered by the router all the time, which it also should not
> be answering, since it doesn't actually have a clue what those IP
> addresses belong to and certainly has no idea where it should forward to
> to reach them.  I occasionally have other random subnets in use on the
> network for running local test networks separate from everything else.
> It would be great if the kernel would keep its nose out of those subnets
> too.
> 
> So far I have seen this behavior with 2.6.8, 2.6.16, and 2.6.18 (being
> the kernels I have run on this router).
> 
> So have I misunderstood something about what proxy_arp is supposed to
> do, or is proxy_arp in the kernel simply broken, or is it perhaps
> mis-designed?  Are there some tuning parameters that could perhaps make
> it actually do what one would expect it to be doing?

So I found out part of the problem.

If ip forwarding is enabled (and why ever would it not be) and proxy_arp
is enabled, and you have a default route set, then the kernel will
answer arp requests for any IP address that it doesn't think is local to
a given interface.  So if the system has an ip of 10.0.0.254/8 on eth1,
and an arp request arrives for 192.168.1.1 it will answer the arp
request with the MAC of eth1 just because it thinks it could forwards
the packet through the default route.

Now the reason for having proxy_arp enabled in the first place, is to
allow ipsec connections to use 10.x.x.x/8 addresses for the remote
client, to make them appear local.  This of course does not mean I want
to screw up life for people doing a small test on the local network with
192.168.x.x addresses on their own devices.

So the question is, can one make the kernel only answer arp requests for
target IPs that belong to a given network interface?  It looks like
arp_filter or arp_ignore should do such a thing, but no matter what I
set that to, it still answers all arp requests for IPs it doesn't think
are local to the network as far as I can tell (I was doing arping for
random addresses from a client on the network, although the source IP
would have been considered local so maybe that doesn't count).  I do see
arp requests show up occationally from other clients on the network
which get answered by the router when they shouldn't have though, so I
don't think the source IP has anything to do with it.  Perhaps there is
a mistake in the filter/ignore code making it not filter requests
correctly.

Of course overall I am finding it hard to understand when anyone would
ever want to answer arp requests for any IP that shouldn't exist on the
network the request comes from and which the router doesn't explicitly
have an arp entry for (such as the ipsec case).  I especially don't see
when you would ever want the default route to be considered for matching
to determine if it could forward the packet and should answer the arp
request.

Is it incorrect to enable proxy_arp in the case where I want to answer
arp requests for IPs that should be local but which I have to tunnel to
reach?  Is there a better solution?

--
Len Sorensen
