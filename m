From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP
 packets as mpls
Date: Wed, 3 Jun 2015 11:50:17 +0200
Message-ID: <20150603095017.GB19556@pox.localdomain>
References: <874mmpiv5y.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36466 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbFCJuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 05:50:21 -0400
Received: by wibdq8 with SMTP id dq8so84923968wib.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 02:50:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <874mmpiv5y.fsf@x220.int.ebiederm.org>
 <87vbf5g0e1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/15 at 06:23pm, Eric W. Biederman wrote:
> Thomas I may have misunderstood what you are trying to do.
> 
> Is what you were aiming for roughly the existing RTA_FLOW so you can
> transmit packets out one network device and have enough information to
> know which of a set of tunnels of a given type you want the packets go
> into?

The aim is to extend the existing the flow forwarding decisions
with the ability to attach encapsulation instructions to the
packet and allow flow forwarding and filtering decisions based
on encapsulation information such as outer & encap header fields.
On top of that, since we support various L2 in something encaps,
it must also be usable by bridges including OVS and Linux bridge.

So for a pure routing solution this would look like:

        ip route add 20.1.1.1/8 \
        via tunnel 10.1.1.1 id 20 dev vxlan0

Receive:

        ip route add 20.1.1.2/32 tunnel id 20 dev veth0
or:
        ip rule add from all tunnel-id 20 lookup 20


On 06/02/15 at 05:48pm, Eric W. Biederman wrote:
> Things I think xfrm does correct today:
> - Transmitting things when an appropriate dst has been found.
> 
> Things I think xfrm could do better:
> - Finding the dst entry.  Having to perform a separate lookup in a
>   second set of tables looks slow, and not much maintained.
> 
> So if we focus on the normal routing case where lookup works today (aka
> no source port or destination port based routing or any of the other
> weird things so we can use a standard fib lookup I think I can explain
> what I imagine things would look like.

Right. That's how I expect the routing transmit path for flow based
tunnels to look like. No modification to the FIB lookup logic.

> To be clear I am focusing on the very light weight tunnels and I am not
> certain vxlan applies.  It may be more reasonable to simply have a
> single ethernet looking device that does speaks vxlan behind the scenes.
> 
> If I look at vxlan as a set of ipv4 host routes (no arp, no unknown host
> support) it looks like the kind of light-weight tunnel that we are
> dealing with for mpls.
> 
> On the reception side packets that match the magic udp socket have their
> tunneling bits stripped off and pushed up to the ip layer.  Roughly
> equivalent to the current af_mpls code.

That's the easy part. Where do you match on the VNI? How do you handle
BUM traffic? The whole point here is to get rid of the requirement
to maintain a VXLAN net_device for every VNI, or more generally, a
virtual tunnel device for every virtual network. As we know, it's is
a non-scalable solution.

> On the transmit side there would be a host route for each remote host.
> In the fib we would store a pointer to a data structure that holds a
> precomputed header to be prepended to the packet (inner ethernet, vxlan,
> outer udp, outer ip).

So we need a FIB entry for each inner header L2 address pair? This
would duplicate the neighbour cache in each namespace. I don't think
this will scale, see a couple of paragraphs below.

I looked at getting rid of the VXLAN (or other encap) net_device but
this would require to store all parameters including all the
checksumming parameters, flags, ports, ... for each single route. This
will blow up the size of a route considerably. What is proposed instead
is that the parameters which are likely per flow are put in the route
while the parameters which are likely shared remain in the net_device.

> That data pointer would become dst->xfrm when the
> route lookup happens and we generate a route/dst entry.  There would
> also be an output function in the fib and that output function would
> be compue dst->output.  I would be more specific but I forget the
> details of the fib_trie data structures.

I assume you would propose something like a chained dst output so we
call the L2 dst output first which then in turn calls the vxlan dst
output to perform the encap and hooks it back into L3 for the outer
header? How would this work for bridges?

> The output function function in the dst entry in the ipv4 route would
> know how to interpret the pointer in the ipv4 routing table, append
> the precomputed headers, update the precomputed udp header's source port
> with the flow hash of the the inner packet, and have an inner dst
> so that would essentially call ip_finish_output2 again and sending
> the packet to it's destination.

What I don't understand is that exactly does this buy us? I understand
that you want to get rid of the net_device per netns in a VRF == netns
architecture. Let's think further:

Thinking outside of the actual implementation for a bit. I really
don't want to keep a full copy of the entire underlay L2/L3 state
in each namespace. I also don't want to keep a map of overlay ip to
tunnel endpoint in each namespace. I want to keep as little as
possible in the guest namespace, in particular if we are talking 4K
namespaces with up to 1M tunnel endpoints (dude, what kind of cluster
are you running? ;-)

My current thinking is to maintain a single namespace to perform
the FIB lookup which maps outer IPs to the tunnel endpoint and which
also contains the neighbour cache for the underlay. This requires a
single tunnel net_device or more generally, one shared net_device
per shared set of parameters. The namespacing of the routes occurs
through multiple routing tables or by using the mark to distinguish
between guest namespaces. My plan there is to extend veth with the
capability to set a mark value to all packets and thus extend the
namespaces into shared data structures as we typically already
support mark in all common networking data structures.

> There is some wiggle room but that is how I imagine things working, and
> that is what I think we want for the mpls case.  Adding two pointers to
> the fib could be interesting.  One pointer can be a union with the
> output network device, the other pointer I am not certain about.
> 
> And of course we get fun cases where we have tunnels running through
> other tunnels.  So there likely needs to be a bit of indirection going
> on.
> 
> The problem I think needs to be solved is how to make tunnels very light
> weight and cheap, so the can scale to 1million+.  Enough so that the
> kernel can hold a full routing table full of tunnels.

ACK. Although I don't want to hold 4K * full routing tables ;-)

> It looks like xfrm is almost there but it's data structures appear to be
> excessively complicated and inscrutible, and the require an extra lookup.

I'm still not fully understanding why do you want to keep the encap
information in a separate table? Or are you just talking about the use
of the dst field to attach the encap information to the packet?
