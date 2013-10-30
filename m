From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Wed, 30 Oct 2013 23:58:51 +0100
Message-ID: <20131030225851.GB13902@order.stressinduktion.org>
References: <20131029.000844.1092862708536984032.davem@davemloft.net> <20131029120424.GD26185@order.stressinduktion.org> <20131030200725.GB9093@order.stressinduktion.org> <20131030.173608.2156276556221568210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39870 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979Ab3J3W6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 18:58:53 -0400
Content-Disposition: inline
In-Reply-To: <20131030.173608.2156276556221568210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 05:36:08PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 30 Oct 2013 21:07:25 +0100
> 
> > On Tue, Oct 29, 2013 at 01:04:25PM +0100, Hannes Frederic Sowa wrote:
> >> I really tried hard to find alternatives or even a way to enable
> >> the protection automatically given that at least unbound does apply
> >> IP_PMTUDISC_DONT to its sockets already. These are the reasons why I
> >> came up with the new IP_PMTUDISC_INTERFACE value:
> > 
> > Sorry to bother you but I would really love to hear your feedback on my
> > reasoning so I can try to come up with a solution you would be happy with.

Thanks for the answer but I still tend to disagree:

> All I've read is that administrators cannot be relied upon to
> configure their systems properly for the requirements they have.
> 
> And that is a non-argument for adding this new socket option as far as
> I'm concerned.

First of, it is pretty hard to do it correct. Before writing this patch I
thought that ip_no_pmtu_disc does not honour pmtu updates at all. But as
soon as one fragmentation needed ICMP enters the box the mtu is reduced
to pmin_mtu. This was very counterintuitive for me (I don't know if this is
actually intended). Also we honour per application settings for TCP and DCCP
sockets, but I totally understand if you take this as a non-argument.

But that is not that important. Documentation can fix this.

> "I strongly do not trust path MTU information" has a scope as small as
> a route or an interface, it doesn't go down to the socket or
> application level at all.

I still disagree here. We can prevent generating UDP fragments if we
lock the mtu on the route, I agree and somehow missed that before (even
though I already used that myself once).

DNS resolver can fallback to TCP for querying where we can honour the
path MTU because it won't do any harm and ensures connectivity.

Also for TCP the socket is matched on the whole 4-tuple and we may
fallback to a 2-tuple lookup on unconnected UDP sockets. The new socket
option would let an application programmer choose to do path mtu discovery
because it knows it will only use a connected socket. On unconnected
sockets one can specify IP_PMTUDISC_INTERFACE to suppress the path MTU
updates and always use the interface MTU without the DF-bit set.

I really am open to suggestions. The socket option could be renamed or
we can transform IP_PMTUDISC_DONT to what I think it actually should
do. Per route or interface settings to enable the acceptance of path
MTU updates per protocol would be ok, too, but more complex.

Greetings,

  Hannes
