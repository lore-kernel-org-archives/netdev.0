From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP packets as mpls
Date: Tue, 02 Jun 2015 17:48:25 -0500
Message-ID: <874mmpiv5y.fsf@x220.int.ebiederm.org>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<1433177175-16775-4-git-send-email-rshearma@brocade.com>
	<87a8wivue4.fsf@x220.int.ebiederm.org>
	<20150602213738.GA5842@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59393 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbbFBWx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 18:53:29 -0400
In-Reply-To: <20150602213738.GA5842@pox.localdomain> (Thomas Graf's message of
	"Tue, 2 Jun 2015 23:37:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> writes:

> On 06/02/15 at 01:26pm, Eric W. Biederman wrote:
>> What we really want here is xfrm-lite.  By lite I mean the tunnel
>> selection criteria is simple enough that it fits into the normal
>> routing table instead of having to do weird flow based magic that
>> is rarely needed.
>> 
>> I believe what we want are the xfrm stacking of dst entries.
>
> I assume you are referring to reusing the selector and stacked
> dst. I considered that for the transmit side.
>
> Can you elaborate on this some more? How would this look like
> for the specific case of VXLAN? Any thoughts on the receive
> side? You also mention that you dislike the net_device approach.
> What do you suggest instead? The encapsulation is often postponed
> to after the packet is fully constructed. Where should it get
> hooked into?

Things I think xfrm does correct today:
- Transmitting things when an appropriate dst has been found.

Things I think xfrm could do better:
- Finding the dst entry.  Having to perform a separate lookup in a
  second set of tables looks slow, and not much maintained.

So if we focus on the normal routing case where lookup works today (aka
no source port or destination port based routing or any of the other
weird things so we can use a standard fib lookup I think I can explain
what I imagine things would look like.

To be clear I am focusing on the very light weight tunnels and I am not
certain vxlan applies.  It may be more reasonable to simply have a
single ethernet looking device that does speaks vxlan behind the scenes.

If I look at vxlan as a set of ipv4 host routes (no arp, no unknown host
support) it looks like the kind of light-weight tunnel that we are
dealing with for mpls.

On the reception side packets that match the magic udp socket have their
tunneling bits stripped off and pushed up to the ip layer.  Roughly
equivalent to the current af_mpls code.

On the transmit side there would be a host route for each remote host.
In the fib we would store a pointer to a data structure that holds a
precomputed header to be prepended to the packet (inner ethernet, vxlan,
outer udp, outer ip).  That data pointer would become dst->xfrm when the
route lookup happens and we generate a route/dst entry.  There would
also be an output function in the fib and that output function would
be compue dst->output.  I would be more specific but I forget the
details of the fib_trie data structures.

The output function function in the dst entry in the ipv4 route would
know how to interpret the pointer in the ipv4 routing table, append
the precomputed headers, update the precomputed udp header's source port
with the flow hash of the the inner packet, and have an inner dst
so that would essentially call ip_finish_output2 again and sending
the packet to it's destination.

There is some wiggle room but that is how I imagine things working, and
that is what I think we want for the mpls case.  Adding two pointers to
the fib could be interesting.  One pointer can be a union with the
output network device, the other pointer I am not certain about.

And of course we get fun cases where we have tunnels running through
other tunnels.  So there likely needs to be a bit of indirection going
on.

The problem I think needs to be solved is how to make tunnels very light
weight and cheap, so the can scale to 1million+.  Enough so that the
kernel can hold a full routing table full of tunnels.

It looks like xfrm is almost there but it's data structures appear to be
excessively complicated and inscrutible, and the require an extra lookup.

Eric
