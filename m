From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Thu, 31 Oct 2013 10:42:26 +0100
Message-ID: <20131031094226.GB17210@order.stressinduktion.org>
References: <20131030200725.GB9093@order.stressinduktion.org> <20131030.173608.2156276556221568210.davem@davemloft.net> <20131030225851.GB13902@order.stressinduktion.org> <20131031.002911.1316728367651608156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40619 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3JaJm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 05:42:28 -0400
Content-Disposition: inline
In-Reply-To: <20131031.002911.1316728367651608156.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 31, 2013 at 12:29:11AM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 30 Oct 2013 23:58:51 +0100
> 
> > DNS resolver can fallback to TCP for querying where we can honour the
> > path MTU because it won't do any harm and ensures connectivity.
> > 
> > Also for TCP the socket is matched on the whole 4-tuple and we may
> > fallback to a 2-tuple lookup on unconnected UDP sockets. The new socket
> > option would let an application programmer choose to do path mtu discovery
> > because it knows it will only use a connected socket. On unconnected
> > sockets one can specify IP_PMTUDISC_INTERFACE to suppress the path MTU
> > updates and always use the interface MTU without the DF-bit set.
> 
> This still sounds like a route scope policy with two binary states,
> one for connected sockets and one for unconnected ones.

Orthogonally a user may want to decide per protocol. Path MTU discovery
may happen on protocols where I have protection against fragment poisoning
because of the TCP 3-WHS and want to drop path mtu discovery information
on simple UDP request-response protocols even if they are used in
connected state (this is the specific case I want to protect in DNS).

Do we accept path MTU information if we just send a spoofed TCP SYN
request and then just fire a spoofed ICMP path mtu packet afterwards? I
guess (I really have not checked), yes. If the UDP stack would use this
information we again generate fragments and are vulnerable to UDP based
cache poisoning attacks. So when can we really say we can match and
trust the full socket ID?

Please note, dropping the path MTU on those sockets is merely an
optimization.  All I care about is that we don't fragment packets locally
and have the possibility to not set the DF-bit (so IP_PMTUDISC_PROBE
without DF). I could very well remove the ip_sk_accept_pmtu logic from
the patch.

I still think this patch is the reasonable way to solve this problem. If
you still think it should be on a per-route basis I will look down on
how this can be achieved but would focus on multiplexing the MTU per
protocol somehow.

Please let me know!

Thank you,

  Hannes
