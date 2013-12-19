From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 13:17:57 +0100
Message-ID: <20131219121757.GD14429@order.stressinduktion.org>
References: <20131218.173442.336109133942416102.davem@davemloft.net> <CABrhC0nG8Z01G-zVtObe40OuyDo0Jm5y+Lzy_r-zr2zmjfaKjQ@mail.gmail.com> <20131219000759.GF3505@order.stressinduktion.org> <20131219.001203.1942468169345523058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39232 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756228Ab3LSMR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:17:58 -0500
Content-Disposition: inline
In-Reply-To: <20131219.001203.1942468169345523058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 12:12:03AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 19 Dec 2013 01:07:59 +0100
> 
> > On Wed, Dec 18, 2013 at 06:55:13PM -0500, John Heffner wrote:
> >> On using the interface MTU for all forwarded packets, I have a similar
> >> reaction as David.  And why are forwarded packets more special than
> >> local ones, from the routing code's point of view?  It seems like
> >> there could be other ways to harden a router, like firewall rules.
> > 
> > I doubt it is trivial to set up such a filter as we have to inspect
> > the payload of the icmp error. I played with it and it is certainly
> > possible, but my intention was that the networking stack does try to
> > prevent fragmentation and delay generation of fragments to the last
> > router on the path where it is necessary.
> 
> John's more important point is why treat forwarded traffic specially
> from that which is locally generated?

Routers don't receive ICMP frag-needed packets at all for forwarded
traffic but only for locally generated packets. As we can't be very
strict with payload tag checking because we often don't have enough
information from the returned payload, we cannot easily distinguish
between ICMP packets sent because of local traffic or for forwarded
traffic. All frag-needed notifications sent in return of forwarded traffic
are inherently bogus or have a malicious background and should not be
handled.  Becasue we cannot harden the receive handler in all cases,
we need to protect the forwarding path to use such information.

Networking software on the end system which wants to guard against
that kind of fragmentation can do so by using the various knobs to
limit pmtu notification processing or use IP_PMTUDISC_INTERFACE to
protect itself from sending fragments. (Note, all other methods but
IP_PMTUDISC_INTERFACE have impact on all protocols, which could also
break other services on that box). But if one has a linux router without
complex icmp payload checking firewall enabled, the packets send without
DF-bit will get fragmented at the next hops if an attacker managed to
send such a spoofed pmtu notification to that router. They simply need to
traceroute the path. We should avoid that!

It would be great if we could use IP_PMTUDISC_PROBE (so setting DF-flag)
for DNS packets but it could break stuff for sub-dns-max-size mtu links.

Thanks,

  Hannes
