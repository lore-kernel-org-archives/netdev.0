From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to protect forward path to use pmtu info
Date: Tue, 31 Dec 2013 08:02:23 +0100
Message-ID: <20131231070223.GE27636@order.stressinduktion.org>
References: <20131220130822.GD32129@order.stressinduktion.org> <20131230.222044.884570280065942449.davem@davemloft.net> <20131231035247.GA27636@order.stressinduktion.org> <20131231.010403.73052460631688921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.net
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59962 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3LaHCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 02:02:25 -0500
Content-Disposition: inline
In-Reply-To: <20131231.010403.73052460631688921.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[added John Heffner to the discussion]

* Context
> Provide a mode where the forwarding path does not use the protocol path
> MTU to calculate the maximum size for a forwarded packet but instead
> uses the interface or the per-route locked MTU.
> 
> It is easy to inject bogus or malicious path mtu information which
> will cause either unneeded fragmentation-needed icmp errors (in case
> of DF-bit set) or unnecessary fragmentation of packets (by default down
> to min_pmtu). This could be used to either create blackholes on routers
> (if the generated DF-bit gets dropped later on) or to leverage attacks
> on fragmentation.
> 
> Forwarded skbs are marked with IPSKB_FORWARDED in ip_forward. This flag
> was introduced for multicast forwarding, but as it does not conflict with
> our usage in the unicast code path it is perfect for reuse.
> 
> I moved the functions ip_sk_accept_pmtu, ip_sk_use_pmtu and ip_skb_dst_mtu
> along with the new ip_dst_mtu_secure to net/ip.h to fix circular
> dependencies because of IPSKB_FORWARDED.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>  
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> v2:
> * forwarding_uses_pmtu default to on
> * reworded documentation and changelog

On Tue, Dec 31, 2013 at 01:04:03AM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 31 Dec 2013 04:52:47 +0100
> 
> > I am still convinced we should suppress path mtu information in
> > forwarding path.
> 
> This is why it disappoints me that the person who felt differently,
> you left out of the CC: when you reposted your patches.  He's
> the person who made the code the way it is right now.

That was not on purpose. I am including him in the discussion right
now. I thought that after your last mail in the old thread you already
made a decision. I also failed to update the patch's cc list, I am sorry
for that.

So, I try again:

Jeff, I am sorry to not have included you in this resent. This resend patch
has as the only change that it enables forwarding_uses_pmtu by default.

I think we should find a consensus on this if it is reasonable to provide such
a knob or find a default mode the forwarding path always operates on.

In my opinion we must never use the path mtu to determine the size of packets
while forwarding as this would make it easier to try attacks on fragments. I
know we cannot fully prevent fragmentation but we should try as hard as
possible to prevent it.

Also, I don't see that anything should break because of this (with the
exception of user space daemons doing manually probing, that was the
only reason I included the knob). I also have an alternative to this. Like
multicast routing such a daemon could install a socket and set a specific
setsockopt. As long as this daemon is running and the socket is not closed we
use the path mtu. If the program exits and closes the socket we fall back to
just using the interface mtu.

Given the recent attention to a succesful implementation of an attack
on DNS using fragmentation as the root cause [1] I think this change is
justified. I also described another problem I thought about regarding
IPv6.  As we can shrink the path mtu the router would generate PtB errors
and would lead to fragmentation on the end system. Recent research [2]
showed that the failure rate of IPv6 fragments on the Alexa Top 1M sites
is about 40% or 47% depending on the test. If this is also true and one
can bring a host to fragment along such a path this could result in a
blackhole. It may cause struggle for some people. I don't think this
is as serious as the IPv4 problem. The problem could happen the other
way around, if the generated PtB errors get dropped back to the host,
which thus will never get informed about a mtu bottleneck on the path.

Given the problems with correctly filtering those icmp errors I propose
to always use the interface MTU for forwarding. In my understanding this
is also in consent with RFC 1191 "4. Router specification".

What do you think? I am looking forward to hear your opinion on that.

[1] <https://sites.google.com/site/hayashulman/files/fragmentation-poisoning.pdf>
[2] <http://www.iepg.org/2013-11-ietf88/fgont-iepg-ietf88-ipv6-frag-and-eh.pdf>

Greetings,

  Hannes
