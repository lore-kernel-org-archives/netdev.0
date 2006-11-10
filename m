From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHSET] packet mark & fib rules work
Date: Fri, 10 Nov 2006 15:30:14 +0100
Message-ID: <20061110143014.GK8693@postel.suug.ch>
References: <20061109112735.577771022@lsx.localdomain> <20061109114604.GA32395@fogou.chygwyn.com> <20061109124911.GB8693@postel.suug.ch> <20061109145503.GA1546@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:34021 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1753611AbWKJO3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 09:29:54 -0500
To: Steven Whitehouse <steve@chygwyn.com>
Content-Disposition: inline
In-Reply-To: <20061109145503.GA1546@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steven Whitehouse <steve@chygwyn.com> 2006-11-09 14:55
> So here is roughly what I was thinking... this comes from having
> spent a little while thinking about the best way to integrate
> MPLS into the network stack. An MPLS label is 32 bits in size
> which conviently matches the size of the packet mark.
> 
> So one thought was this (for MPLS edge routers). Add the ability to
> set a mark to the IP routing table. Something along the lines of:
> 
> /sbin/ip route add 10.1.0.0/16 via 10.2.1.1 dev eth0 setmark 6
> 
> and then use the mark as the FEC (forwarding equivalence class)
> for MPLS (which is just an index, but in simple cases could
> contain a whole MPLS label). I was hoping that it might be possible
> to use the xfrm infrastructure to deal with the actual application
> of MPLS labels, but I'm not yet 100% certain that its a good fit.
> 
> Either way, MPLS will require some kind of way to indicate the FEC
> for each route, so using the generic mark like this seems to me
> a reasonable solution on the basis that other uses might then be found for
> it as well.

Using tc_index might work as well. Anyways, having a route metric
which influences the mark and tc_index for packets being routed via
said route is certainly a good thing.

> Since MPLS labels are only a subset of the full 32 bits, being able
> to use a mask in conjunction with setting the mark might also be
> a useful feature, so that the logic (pseudo code) after route lookup
> might look something like:
> 
> skb->mark &= ~nh->nh_setmask;
> skb->mark |= nh->nh_setmark; /* Assume mark only sets bits allowed by mask */
> 
> The big question being, is this going to be a problem bearing in mind
> it would appear in the routing fast path?

We probably don't know until we try it. IMHO fast path thoughts
should never be a reason to not try and implement something in
a clean fashion. There is always ways to optimize things.

> On the MPLS input side, packet marks would be set according to the
> incoming MPLS label and then work in just the same way that you propose
> using the marks to create separate routing for different VLANs for
> example.

An ingress action which can both translate MPLS labels into a mark
or tc_index value should suit us fine. This could be a simple 1:1
mapping or a more complex translation table which can be managed
by userspace via netlink.


