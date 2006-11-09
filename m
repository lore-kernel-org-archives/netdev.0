From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCHSET] packet mark & fib rules work
Date: Thu, 9 Nov 2006 14:55:03 +0000
Message-ID: <20061109145503.GA1546@fogou.chygwyn.com>
References: <20061109112735.577771022@lsx.localdomain> <20061109114604.GA32395@fogou.chygwyn.com> <20061109124911.GB8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:25574 "EHLO fogou.chygwyn.com")
	by vger.kernel.org with ESMTP id S1423876AbWKIPB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 10:01:58 -0500
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20061109124911.GB8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Nov 09, 2006 at 01:49:11PM +0100, Thomas Graf wrote:
> * Steven Whitehouse <steve@chygwyn.com> 2006-11-09 11:46
> > 
> > so far as all the DECnet bits go. One question though... will you
> > be adding later (as your slide #5 and #11 from your netconf presentation
> > appear to imply) a way to set the mark from the routing table (presumably
> > included in the nexthop info) ?
> 
> So far I haven't planned this, slide #11 describes that if I add an
> address with a given mark the corresponding route will only apply
> to packets with a matching mark. Slide #5 shows the idea of an ingress
> classifier/action setting the mark field based on iif. I focus on
> selecting routes based on marks, not the other way around but its
> certainly a intersting idea if you can elaborate it further.

So here is roughly what I was thinking... this comes from having
spent a little while thinking about the best way to integrate
MPLS into the network stack. An MPLS label is 32 bits in size
which conviently matches the size of the packet mark.

So one thought was this (for MPLS edge routers). Add the ability to
set a mark to the IP routing table. Something along the lines of:

/sbin/ip route add 10.1.0.0/16 via 10.2.1.1 dev eth0 setmark 6

and then use the mark as the FEC (forwarding equivalence class)
for MPLS (which is just an index, but in simple cases could
contain a whole MPLS label). I was hoping that it might be possible
to use the xfrm infrastructure to deal with the actual application
of MPLS labels, but I'm not yet 100% certain that its a good fit.

Either way, MPLS will require some kind of way to indicate the FEC
for each route, so using the generic mark like this seems to me
a reasonable solution on the basis that other uses might then be found for
it as well.

Since MPLS labels are only a subset of the full 32 bits, being able
to use a mask in conjunction with setting the mark might also be
a useful feature, so that the logic (pseudo code) after route lookup
might look something like:

skb->mark &= ~nh->nh_setmask;
skb->mark |= nh->nh_setmark; /* Assume mark only sets bits allowed by mask */

The big question being, is this going to be a problem bearing in mind
it would appear in the routing fast path?

On the MPLS input side, packet marks would be set according to the
incoming MPLS label and then work in just the same way that you propose
using the marks to create separate routing for different VLANs for
example.

If people are generally happy with the idea, and since its not already
part of your plans, then I'll try and put a patch together for it
in the not too distant future,

Steve.

