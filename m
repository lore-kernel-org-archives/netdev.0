From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Thu, 24 Mar 2016 23:00:01 +0000
Message-ID: <56F47171.4070003@solarflare.com>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
 <20160318232522.14955.13475.stgit@localhost.localdomain>
 <56F17A13.8090701@solarflare.com>
 <CAKgT0Ud9uPG+9AdT47Q1VygLBnjygyY29sRf=y4Pqe=f2e+bkw@mail.gmail.com>
 <56F19FAA.3090005@solarflare.com>
 <CAKgT0UcAuOrBTcmj1ue8mK=j4dCqr-0bydHhRb+ghS1cZaUqrw@mail.gmail.com>
 <56F2C3F8.8070308@solarflare.com>
 <CAKgT0Uei6YrWRPaov3LAFrOima=o4+V4mQcFih-rHZ+w-x4hwA@mail.gmail.com>
 <56F30523.8080108@solarflare.com>
 <CAKgT0UfgKwSRjMwRHbDNawAyJ3jvz937j1jxGvJWRaD39bSSeQ@mail.gmail.com>
 <56F3200C.20200@solarflare.com>
 <CAKgT0UfyOc4tYhZq7CC5G4S5HdzPW3iSifdcwe20Vxsqu8C3LQ@mail.gmail.com>
 <56F41FFF.7000508@solarflare.com>
 <CAKgT0UeW7A6cMRHm8_nEX=op_VAK5wcoYYRTNQVmMQWe02HdfA@mail.gmail.com>
 <56F44B56.9070206@solarflare.com>
 <CAKgT0Uc083WTmag4_B5LkVvi+iDoFtEjB0Xx4u92-Wu5S=6mzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:61712 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750870AbcCXXAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 19:00:09 -0400
In-Reply-To: <CAKgT0Uc083WTmag4_B5LkVvi+iDoFtEjB0Xx4u92-Wu5S=6mzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/03/16 21:50, Alexander Duyck wrote:
> On Thu, Mar 24, 2016 at 1:17 PM, Edward Cree <ecree@solarflare.com> wrote:
>> (Besides, I thought it was impossible for the partial checksum to be zero
>> anyway because at least one of the inputs must be nonzero, and the end-
>> around carry can never produce a zero.  But maybe I'm getting confused here.)
> 
> I forgot about that bit.  I think you are right.  We end up inverting
> the output from csum fold so we are back to 0x1 - 0xFFFF as possible
> values.
Yes, it seems csum_fold inverts it and then the relevant callers invert it
again.  (I hadn't spotted either inversion, so I panicked for a moment when
I thought it was getting inverted just once.)

>> The headers should already be in cache, I thought, and this is only happening
>> once per superframe.  We're already going to have to crawl through the headers
>> anyway to edit the lengths, I don't think it should cost much more to also
>> inspect things like GRE csum bit or the UDP checksum field.  And by
>> identifying the 'next header' from this method as well, we don't need to add a
>> new SKB_GSO_FOO bit or two every time we add another kind of encapsulation to
>> the kernel.
> 
> Right, but this gets back into the hardware flags issue.  The whole
> reason for SKB_GSO_FOO and SKB_GSO_FOO_CSUM is because hardware
> typically supports one but not the other.
Right, and for hardware supporting a specific GSO_FOO[_CSUM], we'll still
need the flags - but in that case we'll be doing "old style" TSO anyway.
GSO partial only really makes sense for a device that isn't (or at least can
be prevented from) parsing the tunnel headers, and such hardware will support
GSO_PARTIAL only, not a profusion of GSO_FOO (with or without _CSUM).

So: in the initial transmit path we build a coherent superframe; when we get
to the device, we say either "oh, device doesn't support offloads at all,
call GSO", or "oh, device supports this particular GSO type for TSO, so give
it the superframe SKB to do what it wants with", or "oh, device supports
GSO_PARTIAL, let's call skb_mac_gso_partial [i.e. chain of new callbacks I
was describing in previous email] and then give the non-coherent SKB to the
device".
And in that last case it doesn't matter what the GSO type is, because the
hardware can handle anything as long as we transform it into GSO partial.

> The other thing to keep in mind is it is much easier to figure out
> what offloads we can make use of when we are only dealing with at most
> 1 layer of tunnels.  When we start getting into stacked tunnels it
> really becomes impossible to figure out what features in the hardware
> we can still make use of.  You throw everything and the kitchen sink
> on it and we have to give up and would be doing everything in
> software.  At least if we restrict the features being requested the
> hardware has a chance to perhaps be useful.
I think all the protocol-specific offloads can just say "don't even try
if you've got stacked tunnels"; it's not something I expect current
hardware to support, and if GSO partial works out then a hw vendor would
have to be crazy to add such support in the future.  But GSO partial
doesn't care about stacked tunnels, it still works.  Unless of course
someone in the middle wants to change their IP IDs or GRE Counter or
whatever, in which case they can mark the skb as "not gso_partial-safe"
when they first build their header, or their gso_partial callback can
return "nope", and then we fall back on a protocol-specific offload (if
one's available, which it won't be for stacked tunnels) or software
segmentation.

>> (And remember that this is separate from - and doesn't impact - the existing
>> GSO code; this is a bunch of new foo_gso_partial() callbacks, distinct from
>> the foo_gso_segment() ones; and it's about preparing a superframe for hardware
>> offload rather than doing the segmentation in software.  I think it's
>> preferable to have some preparation happen in software if that allows hardware
>> to be totally dumb.  (Apologies if that was already all obvious.))
> 
> This is where you and I differ.  I think there are things you are overlooking.

> 
> For example one of the reasons why I know the outer UDP checksum works
> the way it does with tunnel GSO is because the i40e and i40evf drivers
> already have hardware that supports UDP_TUNNEL_CSUM.  As such in order
> to do what you are proposing we would likely have to rip that code out
> and completely rewrite it since it would change out the checksum value
> given to the device.
I'm not sure I understand, so bear with me.  AIUI, UDP_TUNNEL_CSUM means
that the device will fill in both inner and outer L4 checksums.  But it can
only do that if it knows where the inner and outer L4 headers *are*, and I
thought you were going to tell it not to treat it as a tunnel at all, but
instead as a giant L3 header.  So it won't touch the outer L4 checksum at
all (and, in the case of stacked tunnels, it wouldn't touch the 'middle'
one either - it only sees the innermost L4 header).
So while the driver would need to change to add GSO_partial support, the
hardware wouldn't.
Where am I going wrong?

> I'm not going to get into an argument over the merits of PMTU.  The
> fact is I don't believe it is worth the effort in order to enable the
> tunnel-in-tunnel case you envision.
I agree it's not worth the effort to implement it right now.  But some day
it will be, and at that point, if we've designed GSO partial the way I'm
arguing for, it will just magically start working when we disable
fragmentation on inner tunnels.  And in the meantime we'll be using a more
generic interface that hopefully won't encourage driver (and hardware)
designers to see the gso_type enum as a list of protocols to support.
Again, tunnel-in-tunnel isn't important in itself, but as a canary for
"can we support whatever encapsulation protocol comes down the pike";
arguing that you won't be able to set DF on your inner tunnel because
operational consideration XYZ is missing the point IMHO.

> Also another thing to keep in mind is you would have to find a way to
> identify that a tunnel requesting to be segmented is setting the DF
> bit in the outer headers.
But that's easy, as above: either foo_xmit sets a "don't GSO-partial me"
flag in the SKB, or foo_gso_partial returns -EMIGHTBEFRAGMENTED.  The
former is probably preferable for performance reasons.

>>> On top of that it occurred to me that GRE cannot be screened in GRO
>>> for the outer-IP-ID check.  Basically what can happen is on devices
>>> that don't parse inner headers for GRE we can end up with two TCP
>>> flows from the same tunnel essentially stomping on each other and
>>> causing one another to get evicted for having an outer IP-ID that
>>> doesn't match up with the expected value.
> 
>> Yes, that does seem problematic - you'd need to save away the IPID check
>> result and only evict once you'd ascertained they were the same flow.  All
>> the more reason to try to make your tunnels use DF *grin*.
> 
> Feel free to solve the problem if you believe it is that easy.  There
> is nothing in my patches to prevent that.
I'm not saying it's easy.  The GRO side of your patches look great to me
and I think you're more likely to solve it than I am.  But I will have a
go at it too, if I have time.

Though I must admit, I don't quite understand why we have to restrict to
(incrementing or constant) in GRO, rather than just saying "it's DF, we
can ignore the IP IDs and just aggregate it all together".  We won't be
producing the original IP IDs anyway if we resegment, because we don't
know whether they were originally incrementing or constant.  (In other
words, "RFC6864 compliant GRO" as you've defined it can reverse either
GSO or GSO partial, but GSO (in either form) can't always reverse
RFC6864 compliant GRO.)

-Ed
