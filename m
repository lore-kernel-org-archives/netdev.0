From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Tue, 22 Mar 2016 19:40:26 +0000
Message-ID: <56F19FAA.3090005@solarflare.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232522.14955.13475.stgit@localhost.localdomain>
 <56F17A13.8090701@solarflare.com>
 <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:61570 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbcCVTmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 15:42:46 -0400
In-Reply-To: <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/03/16 17:47, Alexander Duyck wrote:
> On Tue, Mar 22, 2016 at 10:00 AM, Edward Cree <ecree@solarflare.com> wrote:
>> On 18/03/16 23:25, Alexander Duyck wrote:
>>> This patch adds support for something I am referring to as GSO partial.
>>> The basic idea is that we can support a broader range of devices for
>>> segmentation if we use fixed outer headers and have the hardware only
>>> really deal with segmenting the inner header.  The idea behind the naming
>>> is due to the fact that everything before csum_start will be fixed headers,
>>> and everything after will be the region that is handled by hardware.
>>>
>>> With the current implementation it allows us to add support for the
>>> following GSO types with an inner TSO or TSO6 offload:
>>> NETIF_F_GSO_GRE
>>> NETIF_F_GSO_GRE_CSUM
>>> NETIF_F_UDP_TUNNEL
>>> NETIF_F_UDP_TUNNEL_CSUM
>>>
>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>> ---
>> If I'm correctly understanding what you're doing, you're building a large
>> TCP segment, feeding it through the encapsulation drivers as normal, then
>> at GSO time you're fixing up length fields, checksums etc. in the headers.
>> I think we can do this more simply, by making it so that at the time when
>> we _generate_ the TCP segment, we give it headers saying it's one MSS big,
>> but have several MSS of data.  Similarly when adding the encap headers,
>> they all need to get their lengths from what the layer below tells them,
>> rather than the current length of data in the SKB.  Then at GSO time all
>> the headers already have the right things in, and you don't need to call
>> any per-protocol GSO callbacks for them.
> One issue I have to deal with here is that we have no way of knowing
> what the underlying hardware can support at the time of segment being
> created.  You have to keep in mind that what we have access to is the
> tunnel dev in many cases, not the underlying dev so we don't know if
> things can be offloaded to hardware or not.  By pushing this logic
> into the GSO code we can actually implement it without much overhead
> since we either segment it into an MSS multiple, or into single MSS
> sized chunks.  This way we defer the decision until the very last
> moment when we actually know if we can offload some portion of this in
> hardware or not.
But won't the tunnel dev have the feature flag for GSO_PARTIAL depending
on what the underlying dev advertises?  (Or, at least, could we make it
bethatway?)
Alternatively, have per-protocol GSO callbacks to do the fixup in the
opposite direction to what you have now - in the long term we hope that
hardware supporting GSO partial will become the common case, so that
should be the fast path without bouncing backwards through GSO callbacks.
Then, if you find out at GSO time that the hardware wants to do old-style
TSO, you call those callbacks so as to give it a superframe with the long
lengths filled in everywhere.  (Even that might not be necessary; it's a
question of whether hardware makes assumptions about what those fields
contain when folding its packet edits into checksums.  Since this is
going to be driver-specific and drivers doing these things will have a
fixed list of what encaps they can parse and therefore do this for, maybe
all these fixups could be done by the driver - using common helper
functions, of course - in its TSO path.)
>> Any protocol that noticed it was putting something non-copyable in its
>> headers (e.g. GRE with the Counter field, or an outer IP layer without DF
>> set needing real IPIDs) would set a flag in the SKB to indicate that we
>> really do need to call through the per-protocol GSO stuff.  (Ideally, if
>> we had a separate skb->gso_start field rather than piggybacking on
>> csum_start, we could reset it to point just before us, so that any further
>> headers outside us still can be copied rather than taking callbacks.  But
>> I'm not sure whether that's worth using up sk_buff real estate for.)
> The idea behind piggybacking on csum_start was due to the fact that we
> cannot perform GSO/TSO unless CHECKSUM_PARTIAL is set.  As far as I
> know in the case of TCP offloads this always ends up being the
> inner-most L4 header so it works out in that it actually reduces code
> path as we were having to deal with all the skb->encapsulation checks.
> It was a relationship that already existed, I just decided to make use
> of it since it simplifies things pretty significantly.
Yes; it's a clever idea.  Only trouble is that we really want theinner IP
header rather than the inner TCP header, so that we can (if we want to)
increment the inner IP IDs.  Of course, if we Officially Don't Care about
inner IP IDs that's not a problem.
Iwonder if we could just always fill in inner_network_headereven if we're
not doing encapsulation.  Or does it end up pointing to a 'middle' header
in the case of nested encap?
> As far as retreating I don't really see how that would work. In most
> cases it is an all-or-nothing proposition to setup these outer
> headers.  Either we can segment the frame with the outer headers
> replicated or we cannot.  I suspect it would end up being a common
> case where the hardware will update the outer IP and inner TCP
> headers, but I think the outer L4 and inner IP headers will be the
> ones that most likely always end up being static.
Having thought a bit more about this, I think supporting anything other
than "hardware updates inner [IP and] TCPheaders" is needlessly complex
(well, we still have to handle "hardware updates everything 'cos it
thinks it knows best", because that already exists in the wild in
hardware that might not support the new way).  I don't think there's
likely to be a case where hardware can do half of the segmentation at
the same time as copying headers for the other half.
I also still don't see why hardware would want to update the outer IP
header - can you explain?

> Also we already
> have code paths in place in the GRE driver for instance that prevent
> us from using GSO in the case of TUNNEL_SEQ being enabled.
Oh good, one less thing to worry about.

>> (It might still be necessary to put the true length in the TCP header, if
>> hardware is using that as an input to segmentation.  I think sfc hardware
>> just uses 'total length of all payload DMA descriptors', but others might
>> behave differently.)
> That is what most drivers do.  The way I kind of retained that is that
> the TCP header doesn't include an actual length field, but I left the
> pseudo-header using the full length of all data.
But then you're guaranteed to have to update the outer L4 checksum when
yousegment (because outer LCO reads the inner pseudo-header checksum).
Why not use the single-segment length in the pseudo-header, then the
outer L4 checksum is already the right thing?  (And if yourhardware
can't be told to leave the outer L4 checksum alone, then it's not worth
the trouble of trying to support GSO partial for it, since it clearly
wants to do old-style "NIC knows best" TSO.)
Then if the hardware is assuming the (inner) pseudo is using the full
length, and is going to include that edit in its checksum calculation,
you can just do the opposite edit in the driver, just before handing
the packet off to the hardware.
Again, the idea is that we optimise for GSO partial by making it a plain
header copy everywhere, and put all the 'fix things up' on the _other_
path.
And yes, I forgot (and keep forgetting) that the TCP header doesn't have
an explicit length field.
> My thought was to
> end up using something like the ixgbe approach for most devices.  What
> I did there was replicate the tunnel headers and inner IPv4 or IPv6
> header.  In the case of ixgbe and i40e I can throw away the checksum
> and length values for the outer IP header, one thing I was curious
> about is if I really needed to retain the full packet size for those.
Again, the outer IP header should be computed for a single segment
rather than for the superframe, so that it doesn't need to be edited
later.  It should be possible to send a "GSO partial" frame to TSO
withouta single GSO callback needing to be called; similarly,
software GSO should be able to just copy the outer headers, and only
need to know how to update the TCP header.  (See below for my "what
a NIC should do" TSO design, which software can easily emulate.)
>> However, I haven't yet had the time to attempt to implement this, so there
>> might be some obvious reason I'm missing why this is impossible.
>> Also, it's possible that I've completely misunderstood your patch and it's
>> orthogonal to and can coexist with what I'm suggesting.
> The one piece I could really use would be an understanding of what
> inputs your hardware is expecting in order for us to extend TSO to
> support this kind of approach.  Then I could start tailoring the
> output generated so that we had something that would work with more
> devices.  I was thinking the approach I have taken is fairly generic
> since essentially it allows us to get away with TSO as long as we are
> allowed to provide the offsets for the IP header and the TCP header.
> From what I can tell it looks like the Solarflare drivers do something
> similar so you might even try making changes similar to what I did for
> ixgbe to see if you can get a proof of concept working for sfc.
So, this is all still slightly speculative because while I've talked to
some of our firmware developers, we haven't got as far as actually writing
the new firmware.  I'd also like to make clear that this isn't "what
Solarflare has officially decided to do"; rather it's "what I'm currently
trying to convince people at Solarflare to do".
But what I think we're going to end up with is this:

The kernel will give us a packet that looks like a single MSS-sized segment
except that the payload is too long; the length fields in all the headers
are for an MSS-sized segment, and the checksums are correct for that
(except that the inner TCP checksum is, of course, the pseudo-header sum
rather than a sum over the whole payload).  The kernel will also tell us
where in the packet the inner IP header begins.  The driver will then give
the following descriptors to the hardware:
* A TSO descriptor, containing the offset of the inner IP header, and the
  MSS to use for segmentation.
* A DMA descriptor containing all the headers (i.e. up to the end of the
  inner TCP header).
* A series of DMA descriptors containing the payload, with a total length
  divisible by the MSS we thought of earlier.
The NIC can now read IHL from the inner IP header, and thereby compute the
offset of the inner TCP header, and the csum_start/offset values.
Then for each MSS-sized block of payload, the NIC will do the following:
* transmit header + payload block
* increment inner IP ID, and decrement inner IP checksum (ones-complement)
* add MSS to TCP sequence number

I believe this is something thatany NIC with TSO support should be able to
learn to do, with appropriate firmware changes.  It might be a while before
there are NICs in the wild that can do this,though.

-Ed
