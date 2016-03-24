From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Thu, 24 Mar 2016 14:50:50 -0700
Message-ID: <CAKgT0Uc083WTmag4_B5LkVvi+iDoFtEjB0Xx4u92-Wu5S=6mzw@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36562 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbcCXVuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 17:50:52 -0400
Received: by mail-ig0-f171.google.com with SMTP id nk17so1707296igb.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 14:50:51 -0700 (PDT)
In-Reply-To: <56F44B56.9070206@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 1:17 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 24/03/16 18:43, Alexander Duyck wrote:
>> On Thu, Mar 24, 2016 at 10:12 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> For UDP header, we look to see if the current checksum field is zero.  If
>>> so, we leave it as zero, fold our edits into csum_edit and return the
>>> result.  Otherwise, we fold our edits and csum_edit into our checksum
>>> field, and return zero.
>> This would require changing how we handle partial checksums so that in
>> the case of UDP we don't allow 0 as a valid value.  Currently we do.
>> It isn't till we get to the final checksum that we take care of the
>> bit flip in the case of 0.

> No, the UDP checksum will have been filled in by LCO and thus have been bit-
> flipped already if it was zero.  Only the innermost L4 header will have a
> partial checksum, and that's TCP so the checksum is required.  (Alternatively:
> whichever header has the partial checksum - and there is at most one - is
> identified by skb->csum_start, and by definition the checksum must be enabled
> for that header, so we can skip the 'check for zero' heuristic there.)

No, recheck the code.  If the skb is GSO when we call udp_set_csum()
we only have populated the partial checksum in the UDP header.  It
isn't until we actually perform the segmentation that we call
lco_csum().

> (Besides, I thought it was impossible for the partial checksum to be zero
> anyway because at least one of the inputs must be nonzero, and the end-
> around carry can never produce a zero.  But maybe I'm getting confused here.)

I forgot about that bit.  I think you are right.  We end up inverting
the output from csum fold so we are back to 0x1 - 0xFFFF as possible
values.

>>> This should even be a worthwhile simplification of the non-nested case,
>>> because (if I understand correctly) it means GSO partial doesn't need the
>>> various gso_type flags we already have to specify tunnel type and checksum
>>> status; it just figures it out as it goes.
>> Yes, but doing packet inspection can get to be expensive as we crawl
>> through the headers.  In addition it gets into the whole software
>> versus hardware offloads thing.

> The headers should already be in cache, I thought, and this is only happening
> once per superframe.  We're already going to have to crawl through the headers
> anyway to edit the lengths, I don't think it should cost much more to also
> inspect things like GRE csum bit or the UDP checksum field.  And by
> identifying the 'next header' from this method as well, we don't need to add a
> new SKB_GSO_FOO bit or two every time we add another kind of encapsulation to
> the kernel.

Right, but this gets back into the hardware flags issue.  The whole
reason for SKB_GSO_FOO and SKB_GSO_FOO_CSUM is because hardware
typically supports one but not the other.

The other thing to keep in mind is it is much easier to figure out
what offloads we can make use of when we are only dealing with at most
1 layer of tunnels.  When we start getting into stacked tunnels it
really becomes impossible to figure out what features in the hardware
we can still make use of.  You throw everything and the kitchen sink
on it and we have to give up and would be doing everything in
software.  At least if we restrict the features being requested the
hardware has a chance to perhaps be useful.

> (And remember that this is separate from - and doesn't impact - the existing
> GSO code; this is a bunch of new foo_gso_partial() callbacks, distinct from
> the foo_gso_segment() ones; and it's about preparing a superframe for hardware
> offload rather than doing the segmentation in software.  I think it's
> preferable to have some preparation happen in software if that allows hardware
> to be totally dumb.  (Apologies if that was already all obvious.))

This is where you and I differ.  I think there are things you are overlooking.

For example one of the reasons why I know the outer UDP checksum works
the way it does with tunnel GSO is because the i40e and i40evf drivers
already have hardware that supports UDP_TUNNEL_CSUM.  As such in order
to do what you are proposing we would likely have to rip that code out
and completely rewrite it since it would change out the checksum value
given to the device.

>> Honestly I think tunnel-in-tunnel is not going to be doable due to the
>> fact that we would have to increment multiple layers of IP ID in order
>> to do it correctly.  The more I look into the whole DF on outer
>> headers thing the more I see RFCs such as RFC 2784 that say not to do
>> it unless you want to implement PMTU discovery, and PMTU discovery is
>> inherently flawed since it would require ICMP messages to be passed
>> which may be filtered out by firewalls.

> If PMTU discovery really is "inherently flawed", then TCP is broken and so
> is IPv6.  I think the Right Thing here is for us to translate and forward
> ICMP errors to the originator of the traffic, as RFC 2784 vaguely suggests.
> It should also be possible to configure the tunnel endpoint's MTU to a
> sufficiently low value that in practice it will fit within the path MTU;
> then the sender will discover the tunnel's MTU restriction and stay within
> that.  (I am assuming here that ICMP won't be filtered on the overlay
> network - which should be under the control of the tunnel administrator -
> even if it might be on the underlay network.)

I'm not going to get into an argument over the merits of PMTU.  The
fact is I don't believe it is worth the effort in order to enable the
tunnel-in-tunnel case you envision.

Also another thing to keep in mind is you would have to find a way to
identify that a tunnel requesting to be segmented is setting the DF
bit in the outer headers.

>> On top of that it occurred to me that GRE cannot be screened in GRO
>> for the outer-IP-ID check.  Basically what can happen is on devices
>> that don't parse inner headers for GRE we can end up with two TCP
>> flows from the same tunnel essentially stomping on each other and
>> causing one another to get evicted for having an outer IP-ID that
>> doesn't match up with the expected value.

> Yes, that does seem problematic - you'd need to save away the IPID check
> result and only evict once you'd ascertained they were the same flow.  All
> the more reason to try to make your tunnels use DF *grin*.

Feel free to solve the problem if you believe it is that easy.  There
is nothing in my patches to prevent that.

> On the subject of GRO, I was wondering - it seems like the main reason why
> drivers have LRO is so they can be more permissive than GRO's "must be
> reversible" rules.  (At least, that seems to be the case for sfc's LRO,
> which is only in our out-of-tree driver.)  Maybe instead of each driver
> having its own LRO code (with hacks to avoid breaking Slow Start and
> suchlike by breaking ACK stats), there should be per-device options to
> control how permissive GRO is (e.g. don't check IP IDs), so that a user who
> wants LRO-like behaviour can get it from GRO.

I don't really see the point.  Odds are the LRO in the driver isn't
too much more efficient than the in-kernel GRO.  If anything I would
think the main motivation for maintaining LRO in your out-of-tree
driver is to support kernels prior to GRO.

> Any obvious reason why I couldn't do such a thing?
>
> (I realise LRO might not go away entirely, if other drivers are doing
> various hardware-assisted things.  But in our case it really is all in
> software.)

I don't know.  I'm thinking it all depends on what kind of stuff you
are talking about trying to change.  Most of the flush conditions in
GRO have very good reasons for being there.  I know in the case of the
Intel drivers I actually found that by copying most of the conditions
into the out-of-tree driver LRO code we had I saw improvements.  More
often then not the more aggressive LRO can end up causing more harm
than good because what ends up happening is that it spends too much
time aggregating and starves the other side by witholding acks.

- Alex
