From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 11:06:39 -0700
Message-ID: <CAKgT0Uei6YrWRPaov3LAFrOima=o4+V4mQcFih-rHZ+w-x4hwA@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<56F17A13.8090701@solarflare.com>
	<CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
	<56F19FAA.3090005@solarflare.com>
	<CAKgT0UcAuOrBTcmj1ue8mK=j4dCqr-0bydHhRb+ghS1cZaUqrw@mail.gmail.com>
	<56F2C3F8.8070308@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36379 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbcCWSGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 14:06:51 -0400
Received: by mail-io0-f170.google.com with SMTP id 124so54623416iov.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 11:06:50 -0700 (PDT)
In-Reply-To: <56F2C3F8.8070308@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 9:27 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 22/03/16 21:38, Alexander Duyck wrote:
>> On Tue, Mar 22, 2016 at 12:40 PM, Edward Cree <ecree@solarflare.com> wrote:
>>> But won't the tunnel dev have the feature flag for GSO_PARTIAL depending
>>> on what the underlying dev advertises?  (Or, at least, could we make it
>>> bethatway?)
>> This stuff doesn't work.  That is why tunnels now advertise all
>> available features that can be offloaded via software.  Basically if
>> we can advertise a feature we do, and then we sort things out in
>> software if we cannot actually do it in hardware.
> Fair enough; then go withthe other approach:
>>> Alternatively, have per-protocol GSO callbacks to do the fixup in the
>>> opposite direction to what you have now - in the long term we hope that
>>> hardware supporting GSO partial will become the common case, so that
>>> should be the fast path without bouncing backwards through GSO callbacks.
>>> Then, if you find out at GSO time that the hardware wants to do old-style
>>> TSO, you call those callbacks so as to give it a superframe with the long
>>> lengths filled in everywhere.
>> I thought about doing that but decided it was much simpler to simply
>> update all headers.  For now I want to keep this as simple as possible
>> while we get the first few drivers on board.  If we later want to
>> optimize and add complexity we can go that route, but for now this
>> change is more than fast enough as it allows me to push an i40e at
>> 20Gb/s while sending frames with outer checksums enabled.

> My belief is that my way is (in the long run) simpler: ultimately it gets
> rid of per-protocol GSO callbacks entirely.  Every header gets written
> correctly* when the packet initially traverses the stack, and then at
> transmit time you either hand that off to TSO, or do the equivalent thing
> in software: segment at the TCP layer while treating everything above it
> as an opaque pseudo-L2 header.

I'm pretty sure that isn't a safe approach to take.  With GSO we are
holding off until we are about to hand the packets off to the device
before we segment it.  If we do it earlier it will lead to more issues
as you could have the packet route off to somewhere you were not
expecting and having it already "soft segmented" could lead to issues
where the packet would no longer be coherent.

> *That is, correctly for a single segment, rather than correctly for the
> superframe.

Yes, but what about the cases where a packets gets switched from Tx
back to Rx?  How would you expect the stack to handle that then?

>>> Yes; it's a clever idea.  Only trouble is that we really want theinner IP
>>> header rather than the inner TCP header, so that we can (if we want to)
>>> increment the inner IP IDs.  Of course, if we Officially Don't Care about
>>> inner IP IDs that's not a problem.
>> The inner IP IDs are the ones that are guaranteed to be the ones we
>> can leave fixed since TCP will require that the DF bit be set.
> I was worrying about the SLHC stuff, I thought the inner ones were precisely
> the ones where that was a problem.  If we really don't care about it, then
> we do just need the inner TCP header, and we can stick with using your
> csum_start == gso_start trick :)
>> The
>> current VXLAN implementation does not set DF for the outer headers.
>> So really we don't have too many options right now if we are wanting
>> to support tunnels.
> I was predicating all this on the assumption that tunnels would be changed
> to set DF in their outer frames; I thought I saw a patch recently to do
> that, but maybe I was mistaken.  In any case I think that's the right thing
> to do, and it's a necessary prerequisite for truly tunnel-agnostic TSO.
>>> Iwonder if we could just always fill in inner_network_headereven if we're
>>> not doing encapsulation.  Or does it end up pointing to a 'middle' header
>>> in the case of nested encap?
>> Right now neseted encap is not supported because tunnels don't
>> advertise hw_encap_features.

> You mean not supported by offloads, right?  We can still _create_ a nested
> tunnel device, it just won't use hardware offloads.  And in the long run,
> if we can make tunnel-agnostic TSO as I'm proposing, we should be able to
> support it for nested tunnels too (the giant L2 header just gets more giant).

Right.  Basically what will currently happen is that if you were to
encapsulate an ipip tunnel inside of a VXLAN for instance the GSO
would kick in before the VXLAN tunnel has even added the outer headers
because the VXLAN netdev does not advertise NETIF_F_GSO_IPIP.  That is
the kind of thing we want to have happen though anyway since a
physical device wouldn't know how to deal with such a scenario anyway.

>>> Why not use the single-segment length in the pseudo-header, then the
>>> outer L4 checksum is already the right thing?  (And if yourhardware
>>> can't be told to leave the outer L4 checksum alone, then it's not worth
>>> the trouble of trying to support GSO partial for it, since it clearly
>>> wants to do old-style "NIC knows best" TSO.)
>> The problem then becomes that I needs special case code.  One for
>> standard TSO and one for this special case.  If I leave it as is I can
>> use the same code to cancel out the length in the TCP pseudo-header
>> checksum for either case.

> I don't think that's true.  Look at it this way: there are two choices.
> 1) The normal path builds things for standard TSO, and we have code to
>    fix it up for this new-style TSO.
> 2) The normal path builds things for new-style TSO, and we have code to
>    fix it up for standard TSO.
> Now the fix-up code should be of equal complexity in either case, because
> the two cases are inverses of each other.  So we should choose whichever
> approach makes the normal path simpler.  I think having TCP 'lie' to all
> the outer layers about the length of the packet is simpler, because then
> they don't even have to know that GSO is happening.  They just append a
> header appropriate for an MSS-sized packet, blissfully unaware that the
> payload data carries on for longer than that.
> Moreover, the fixup in (2) can sometimes be avoided...
> I don't know how your hardware does encapsulated TSO, but what ours does
> (in the old "I'm-a-smart-NIC-I-know-best" world) is that it computes both
> checksums itself from scratch.  So it doesn't care what it was given as
> the pre-seeded value, because it's reconstructing the pseudo-header and
> zeroing the checksum field to begin with.
> I would have expected this to be the common behaviour for "smart" NICs
> doing encap TSO, in which case (2) is a clear winner.  And, of course,
> once "less is more" hardware becomes common, we will want (2) anyway.

The argument for here is a matter of complexity.  I really don't think
we gain much by recomputing the pseudo-header with the segmented
length versus the entire packet length.  In the case of gso it is more
complicated to figure out the length if we are having to take gso_size
and add the size for a TCP header rather than just subtracting the
inner transport offset from skb->len.

>> The general idea to my approach is to treat the the UDP or GRE header
>> to the inner IP header as an IP header extension type value.  That
>> will allow us to trick most hardware into being able to accept it.
> I think an L2 header extension is a better semantic match for what's
> happening (the tunnel is an L2 device and we're sending L3 packets over
> it).  But why does it matter?  Are you giving the hardware the L2 and
> L3 headers in separate DMA descriptors or something?  The way I see it,
> all hardware needs to be told is "where to start TSO from", and how it
> thinks of the stuff before that doesn't matter, because it's not
> supposed to touch it anyway.

The problem is setups like VFs where they want to know where the
network header starts so they know where to insert a VLAN tag.  Most
hardware supports IP options or IPv6 extension headers.  What I am
doing is exploiting that in the case of the Intel hardware by telling
it the IP header is the outer IP header and the transport header is
the inner transport header.  Then all I have to deal with is the fact
that hardware will try to compute the entire IPv4 header checksum over
the range so I cancel that out by seeding the IP checksum with the
lco_csum added to the inner pseudo-header checksum.

>>> Again, the idea is that we optimise for GSO partial by making it a plain
>>> header copy everywhere, and put all the 'fix things up' on the _other_
>>> path.
>> That is what I went for.  The only part that isn't a plain header copy
>> is the TCP pseudo-header checksum.

> Right, but that means someone, somewhere, has to fix up the outer UDP
> checksum to account for that (because the TCP phdr sum leaks out of LCO).
> I realise that's a per-superframe job, rather than a per-segment job, but
> it still means that code at GSO time (when we decide whether to do GSO or
> GSO-partial) has to know enough about the tunnel headers to find the outer
> checksum and fix it up.

The fix-up already happens in the GSO code path I have coded up.  The
outer checksum already takes it into account.

If you look at my patches you should see a block in both the UDP
tunnel and GRE tunnel code that handles the "skb_is_gso()" case.  That
is where we deal with the checksum adjustment.  In the case of UDP
tunnels it actually requires very little work as the only field that
actually has to be updated is uh->len since the outer pseduo-header
checksum effectively cancels out the length for the inner anyway.  In
the case of GRE it took a bit more as I had to seed the checksum with
the delta of the length in order to correctly account for the change.

> And it's a question of who pays that cost, the old TSO or the new one; see
> above for why I think the old TSO should pay it.

Generally I don't agree with slowing down existing paths in order to
improve the performance for new ones.  One of my goals with this was
to keep the code minimally intrusive.  I would rather not have to
rewrite all driver TSO paths in order to support a new segmentation
approach.

>> The only issue I see is the expectation that the outer headers go
>> untouched is problematic.  The outer headers are where things like
>> fragmentation will occur in transit.

> Like I say, I'm assuming we'll start setting DF on outer frames.
> Besides, it doesn't matter what happens "in transit" - as long as the
> outer headers aren't touched by the transmitting NIC, the network can
> do what it likes to them afterwards, without it breaking our TSO code.

The IP ID bit is going to be something where I don't want to break
things.  One of the things I have seen is there ends up being a number
of occasions where VXLAN gets fragmented due to incorrectly configured
MTU.  I would rather not have it get completely screwed up when this
occurs.  A performance hit for fragmenting is one thing.  Having
people start complaining because previously working tunnels suddenly
stop functioning is another.  The fact is the whole point of VXLAN is
to support sending the tunneled frames between data centers.  With the
DF bit set on a tunnel header we end up making it so that frames get
dropped instead of fragmented which would be a change of behavior.

>> In addition I suspect a number
>> of devices other than the Intel NICs probably use the network header
>> to determine where to insert L2 tags such as VLAN.

> Ah, VLAN is interesting, because there's two things you might want:
> VLAN inside the tunnel, or outside of it.  Presumably if you're having
> the NIC insert the VLAN, you want it outside (e.g. you're doing SR-IOV
> and you're putting the VF on a VLAN).
> But then it doesn't make sense to work backwards from the network
> header, because that'll get confused by traffic that's already VLAN
> tagged - because again, you want to insert the new VLAN as the outer
> VLAN.  You need to find the Ethertype, as well; it just seems like
> working backwards from L3 is crazy.  Particularly when working forwards
> from L2 is so easy - you know your L2 header begins at the start of the
> packet, you (hopefully) know it's Ethernet, so you know where the VLAN
> tags and Ethertype go.  (Are you /sure/ Intel works backwards from the
> L3 header?  I'm pretty confident we don't.)

Yes, I am very confident of that.  For Intel hardware the outer VLAN
tag would be the one inserted via software, the inner VLAN tag is the
one inserted via hardware.

> Then of course this works fine with the 'giant L2 header', because the
> NIC just inserts the VLAN as normal in the outer Ethernet header and
> shunts the remaining headers along to make room for it.  In fact, in
> our NICs I think that's done by an entirely separate bit of hardware
> that doesn't even have to know that TSO was considering much more of
> the packet to be "L2 header".

Well the Intel hardware doesn't work that way.  It would be nice if it
did because then you could actually support Q-in-Q on the VFs without
much issue, but due to the limiting nature of a 64b transmit
descriptor they opted to insert the VLAN tags at the start of the
network header.

> _However_, if we don't need to update the IP IDs, then we can just take
> the offset of the inner L4 header, and it doesn't make any difference
> whether you choose to think of the stuff before that as L2 + giant L3
> or as giant L2 + normal L3, because it's not part of the OS->NIC
> interface (which is just "L4 starts here").  If your NIC needs to be
> told where the outer L3 starts as well, then, I guess that's just a
> wart you need in your drivers.  You have skb->network_header, so that
> shouldn't be difficult - that will always point to the outer one.

Right.  That is kind of what I was going for with this setup.  The
only issue is that the VXLAN tunnels not setting the DF bit kind of
get in the way of the giant L3 approach.

Dealing with the outer header needing the DF bit is something I have
left unaddressed at this point.  The question would be what is the
correct approach to take for all this.  I know RFC2003 for IPv4 in
IPv4 says you must set the DF bit if the inner header has the DF bit
set.  I'm just wondering if we can apply the same type of logic to GRE
and UDP tunnels.

>> Like I have said with the current solution I could probably update
>> igb, igbvf, fm10k, ixgbe, ixgbevf, i40e, and i40evf to support this.
>> That covers pretty much the entire Intel series of drivers in terms of
>> enterprise.  The question is what do I need to enable to support other
>> drivers.  It doesn't seem like there would be too much but the bit I
>> would need to know is what the expectations are when computing outer
>> IPv4 checksums.

> Like I say, the plan we had for Solarflare NICs before "less is more"
> happened was that the device would reconstruct the outer pseudo-header
> (same as it does with the inner) and ignore any pre-seeded value in the
> checksum field.  I'd expected other vendors to have gone down the same
> route, but if Intel didn't then maybe others didn't either.  It'd be
> nice if some of them would chime in and let us know what they want...

Right.  I added Or to the Cc.  Maybe we can get some input from
Mellanox on how they do TSO and what changes they would need in order
to support TSO for GRE or UDP tunnels with checksum.

My concern is that I am not sure how much value there is to add with
this type of code if the hardware is parsing headers.  In the case of
most of the Intel parts you specify offsets for the network and
transport headers so it gives you some degree of flexibility.  If
however the hardware parses headers it becomes problematic as we can
only support protocols that can be parsed by the hardware.  So for
example on the Intel parts using the drivers igb and ixgbe I will be
able to support VXLAN-GPE using a partial GSO approach.  However for
fm10k which does some parsing for the tunnel headers I probably won't
as it will not know what to do if there are any extra headers included
and won't be able to determine the offset of the inner transport
header.

- Alex
