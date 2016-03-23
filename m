From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 15:36:45 -0700
Message-ID: <CAKgT0UfgKwSRjMwRHbDNawAyJ3jvz937j1jxGvJWRaD39bSSeQ@mail.gmail.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
	<20160318232522.14955.13475.stgit@localhost.localdomain>
	<56F17A13.8090701@solarflare.com>
	<CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
	<56F19FAA.3090005@solarflare.com>
	<CAKgT0UcAuOrBTcmj1ue8mK=j4dCqr-0bydHhRb+ghS1cZaUqrw@mail.gmail.com>
	<56F2C3F8.8070308@solarflare.com>
	<CAKgT0Uei6YrWRPaov3LAFrOima=o4+V4mQcFih-rHZ+w-x4hwA@mail.gmail.com>
	<56F30523.8080108@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34984 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbcCWWgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:36:46 -0400
Received: by mail-ig0-f173.google.com with SMTP id cl4so62811760igb.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:36:46 -0700 (PDT)
In-Reply-To: <56F30523.8080108@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 2:05 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 23/03/16 18:06, Alexander Duyck wrote:
>> On Wed, Mar 23, 2016 at 9:27 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> My belief is that my way is (in the long run) simpler: ultimately it gets
>>> rid of per-protocol GSO callbacks entirely.  Every header gets written
>>> correctly* when the packet initially traverses the stack, and then at
>>> transmit time you either hand that off to TSO, or do the equivalent thing
>>> in software: segment at the TCP layer while treating everything above it
>>> as an opaque pseudo-L2 header.
>> I'm pretty sure that isn't a safe approach to take.  With GSO we are
>> holding off until we are about to hand the packets off to the device
>> before we segment it.  If we do it earlier it will lead to more issues
>> as you could have the packet route off to somewhere you were not
>> expecting and having it already "soft segmented" could lead to issues
>> where the packet would no longer be coherent.

> Ah, yes, that is a potential problem.  And now that I think about it, we
> might not know what the MSS is until segmentation time, either, even if
> we did know for sure we would want to segment.
> So my approach doesn't work after all, the superframe has to be coherent
> when it traverses the stack.

Right.

>>> You mean not supported by offloads, right?  We can still _create_ a nested
>>> tunnel device, it just won't use hardware offloads.  And in the long run,
>>> if we can make tunnel-agnostic TSO as I'm proposing, we should be able to
>>> support it for nested tunnels too (the giant L2 header just gets more giant).
>> Right.  Basically what will currently happen is that if you were to
>> encapsulate an ipip tunnel inside of a VXLAN for instance the GSO
>> would kick in before the VXLAN tunnel has even added the outer headers
>> because the VXLAN netdev does not advertise NETIF_F_GSO_IPIP.  That is
>> the kind of thing we want to have happen though anyway since a
>> physical device wouldn't know how to deal with such a scenario anyway.

> I disagree.  Surely we should be able to "soft segment" the packet just
> before we give it to the physical device, and then tell it to do dumb copying
> of both the VXLAN and IPIP headers?  At this point, we don't have the problem
> you identified above, because we've arrived at the device now.

One issue here is that all levels of IP headers would have to have the
DF bit set.  I don't think that happens right now.

> So we can chase through some per-protocol callbacks to shorten all the outer
> lengths and adjust all the outer checksums, then hand it to the device for
> TSO.  The device is treating the extra headers as an opaque blob, so it
> doesn't know or care whether it's one layer of encapsulation or forty-two.

So if we do pure software offloads this is doable.  However the GSO
flags are meant to have hardware feature equivalents.  The problem is
if you combine an IPIP and VXLAN header how do you know what header is
what and which order things are in, and what is the likelihood of
having a device that would get things right when dealing with 3 levels
of IP headers.  This is one of the reasons why we don't support
multiple levels of tunnels in the GSO code.  GSO is just meant to be a
fall-back for hardware offloads.

>>> I think an L2 header extension is a better semantic match for what's
>>> happening (the tunnel is an L2 device and we're sending L3 packets over
>>> it).  But why does it matter?  Are you giving the hardware the L2 and
>>> L3 headers in separate DMA descriptors or something?  The way I see it,
>>> all hardware needs to be told is "where to start TSO from", and how it
>>> thinks of the stuff before that doesn't matter, because it's not
>>> supposed to touch it anyway.
>> The problem is setups like VFs where they want to know where the
>> network header starts so they know where to insert a VLAN tag.  Most
>> hardware supports IP options or IPv6 extension headers.  What I am
>> doing is exploiting that in the case of the Intel hardware by telling
>> it the IP header is the outer IP header and the transport header is
>> the inner transport header.  Then all I have to deal with is the fact
>> that hardware will try to compute the entire IPv4 header checksum over
>> the range so I cancel that out by seeding the IP checksum with the
>> lco_csum added to the inner pseudo-header checksum.

> Ok, it sounds like the interface to Intel hardware is just Very Different
> to Solarflare hardware on this point: we don't tell our hardware anything
> about where the various headers start, it just parses them to figure it
> out.  (And for new-style TSO we'd tell it where the TCP header starts, as
> I described before.)

That is kind of what I figured.  So does that mean for IPv6 you guys
are parsing through extension headers?  I believe that is one of the
reasons why Intel did things the way they did is to avoid having to
parse through any IPv4 options or IPv6 extension headers.

> But this sounds like a driver-level thing: you have to undo some of what
> your hardware will do because you're having to lie to it about what you're
> giving it.  So that all happens in the driver, the stack's GSO code isn't
> affected.  In which case I'm much less bothered by this; I thought it was
> an assumption you were baking into the stack.  As far as I'm concerned you
> can do whatever ugly hacks you like in Intel drivers, as long as I don't
> have to do them in sfc ;)

The thing is I have to have the hardware recompute the outer IPv4
checksum because it is updating the ID field.  If I were able to leave
the IP ID static then I wouldn't need to update the checksum.  The
only bit that makes it ugly is the fact that the hardware is being
misled so it thinks the IPv4 header has 50 bytes of options when those
actually represent the outer L4 through to the inner L3 headers.

> Although, why is your device computing the IPv4 header checksum?  Those
> aren't supposed to be offloaded, the stack always already filled them in
> in software.  (I think sfc makes the same mistake actually.)  Is there not
> a way for you to tell your device to skip IP header checksum offload?
> Then you wouldn't have this problem in the first place, and you could tell
> it the IP header was as big as you like without having to seed it with
> this correction value.

It is because we are rewriting the IP ID.  We cannot have a static
checksum if the IP ID is getting updated.

>>> Like I say, I'm assuming we'll start setting DF on outer frames.
>>> Besides, it doesn't matter what happens "in transit" - as long as the
>>> outer headers aren't touched by the transmitting NIC, the network can
>>> do what it likes to them afterwards, without it breaking our TSO code.
>> The IP ID bit is going to be something where I don't want to break
>> things.  One of the things I have seen is there ends up being a number
>> of occasions where VXLAN gets fragmented due to incorrectly configured
>> MTU.  I would rather not have it get completely screwed up when this
>> occurs.  A performance hit for fragmenting is one thing.  Having
>> people start complaining because previously working tunnels suddenly
>> stop functioning is another.  The fact is the whole point of VXLAN is
>> to support sending the tunneled frames between data centers.  With the
>> DF bit set on a tunnel header we end up making it so that frames get
>> dropped instead of fragmented which would be a change of behavior.

> I agree this isn't something we can do silently.  But we _can_ make it a
> condition for enabling gso-partial.  And I think it's a necessary
> condition for truly generic TSO.  Sure, your 'L3 extension header' works
> fine for a single tunnel.  But if you nest tunnels, you now need to
> update the outer _and_ middle IP IDs, and you can't do that because you
> only have one L3 header pointer.

This is getting away from the 'less is more' concept.  If we are doing
multiple levels of tunnels we have already made things far too
complicated and it is unlikely hardware will ever support anything
like that.

> OTOH, for a single tunnel I think we could implement your 'L3 extension
> header' trick in firmware, by making it always parse the outer packet up
> to the outer L3 header and increment the IP ID in that.  So I could live
> with that approach if necessary.

Good to hear.

>> Yes, I am very confident of that.  For Intel hardware the outer VLAN
>> tag would be the one inserted via software, the inner VLAN tag is the
>> one inserted via hardware.

> That's really weird; why does it do that?
> For sfc, the only reason we do hardware VLANs at all is to transparently
> tag a VF (or non-primary PF) that's being passed through into an
> (untrusted) VM.  For that use case you'd always want to insert the outer
> VLAN tag, because otherwise the VM can escape the isolation by inserting
> a different VLAN tag in software.

The problem is I think the feature was implemented long before any of
the SR-IOV stuff was added and it has been carried that way through
the igb and ixgbe drivers.  I haven't looked at i40e but it doesn't
report doing STAG so I don't know how it handles QinQ.

>>> _However_, if we don't need to update the IP IDs, then we can just take
>>> the offset of the inner L4 header, and it doesn't make any difference
>>> whether you choose to think of the stuff before that as L2 + giant L3
>>> or as giant L2 + normal L3, because it's not part of the OS->NIC
>>> interface (which is just "L4 starts here").  If your NIC needs to be
>>> told where the outer L3 starts as well, then, I guess that's just a
>>> wart you need in your drivers.  You have skb->network_header, so that
>>> shouldn't be difficult - that will always point to the outer one.
>> Right.  That is kind of what I was going for with this setup.  The
>> only issue is that the VXLAN tunnels not setting the DF bit kind of
>> get in the way of the giant L3 approach.

Sorry meant giant L2 approach here, not L3.

> On the contrary; your giant L3 approach is exactly what solves this case
> (for non-nested tunnels) - the hardware has the outer IP and inner TCP
> header offsets, which are exactly the two headers it needs to alter.
> And if the hardware is sensible, it won't try to re-checksum the whole
> giant L3 header, it'll just decrement the (outer) IP checksum to account
> for incrementing the (outer) IP ID.  If the hardware isn't sensible,
> then you have to play games like you are doing in the Intel drivers ;)

Agreed.

>> Dealing with the outer header needing the DF bit is something I have
>> left unaddressed at this point.  The question would be what is the
>> correct approach to take for all this.  I know RFC2003 for IPv4 in
>> IPv4 says you must set the DF bit if the inner header has the DF bit
>> set.  I'm just wondering if we can apply the same type of logic to GRE
>> and UDP tunnels.

> I wonder if _not_ setting the DF bit in the outer header can harm TCP
> congestion control at all?  If so, then we'd pretty much have to set it
> in that case.

Really the only concern with DF based on RFC 2003 is for path MTU
discovery.  What happens right now if you set the VXLAN MTU
incorrectly is you end up taking a performance hit as the tunneled
frames are fragmented and have to be reassembled on the other end.  It
ends up being a performance hit due to the fragmentation.  I might
need to look into this.  It is possible that we are already doing the
wrong stuff anyway with this and might need to look at setting the DF
bit anyway.

>> My concern is that I am not sure how much value there is to add with
>> this type of code if the hardware is parsing headers.  In the case of
>> most of the Intel parts you specify offsets for the network and
>> transport headers so it gives you some degree of flexibility.  If
>> however the hardware parses headers it becomes problematic as we can
>> only support protocols that can be parsed by the hardware.

> Solarflare parts will _normally_ parse headers to get that information.
> But, when doing TSO, we do get a chance to specify some extra
> information, in the TSO option descriptor.  Enough of the datapath is
> under firmware control that that should be enough; as long as the outer
> frame is IP over Ethernet, the hardware will parse that fine, and we
> *should* be able to make it just accept that it doesn't know what's
> going on between that and the start of the TCP header.  And, it
> shouldn't matter that the hardware can parse some types of tunnel
> headers, because we'll just tell it to ignore that.

Right.  Just skipping the tunnel headers makes it quite a bit easier.

> Of course, that means changing the firmware; luckily we haven't got any
> parts in the wild doing tunnel offloads yet, so we still have a chance
> to do that without needing driver code to work around our past
> mistakes...
>
> But this stuff does definitely add value for us, it means we could TSO
> any tunnel type whatsoever; even nested tunnels as long as only the
> outermost IP ID needs to change.

Right.  In your case it sounds like you would have the advantage of
just having to run essentially two counters, one increments the IPv4
ID and the other decrements the IPv4 checksum.  Beyond that the outer
headers wouldn't need to change at all.

The only other issue would be determining how the inner pseudo-header
checksum is updated.  If you were parsing out header fields from the
IP header previously to generate it you would instead need to update
things so that you could use the partial checksum that is already
stored in the TCP header checksum field.

- Alex
