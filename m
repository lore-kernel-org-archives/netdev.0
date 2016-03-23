From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 23:00:28 +0000
Message-ID: <56F3200C.20200@solarflare.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Tom Herbert" <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:63359 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751477AbcCWXAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 19:00:35 -0400
In-Reply-To: <CAKgT0UfgKwSRjMwRHbDNawAyJ3jvz937j1jxGvJWRaD39bSSeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/03/16 22:36, Alexander Duyck wrote:
> On Wed, Mar 23, 2016 at 2:05 PM, Edward Cree <ecree@solarflare.com> wrote:
>> I disagree.  Surely we should be able to "soft segment" the packet just
>> before we give it to the physical device, and then tell it to do dumb copying
>> of both the VXLAN and IPIP headers?  At this point, we don't have the problem
>> you identified above, because we've arrived at the device now.
> One issue here is that all levels of IP headers would have to have the
> DF bit set.  I don't think that happens right now.
Yes, that's still a requirement.  (Well, except for the outermost IP header.)
>> So we can chase through some per-protocol callbacks to shorten all the outer
>> lengths and adjust all the outer checksums, then hand it to the device for
>> TSO.  The device is treating the extra headers as an opaque blob, so it
>> doesn't know or care whether it's one layer of encapsulation or forty-two.
> So if we do pure software offloads this is doable.  However the GSO
> flags are meant to have hardware feature equivalents.  The problem is
> if you combine an IPIP and VXLAN header how do you know what header is
> what and which order things are in, and what is the likelihood of
> having a device that would get things right when dealing with 3 levels
> of IP headers.  This is one of the reasons why we don't support
> multiple levels of tunnels in the GSO code.  GSO is just meant to be a
> fall-back for hardware offloads.
Right, but if the hardware does things "the new way" it should work fine:
Packet still starts with Eth + IP.  Packet still has TCP headers at some
specified offset.  So it all works, as long as you don't have to update
any IP IDs except possibly the outermost one.
>> Ok, it sounds like the interface to Intel hardware is just Very Different
>> to Solarflare hardware on this point: we don't tell our hardware anything
>> about where the various headers start, it just parses them to figure it
>> out.  (And for new-style TSO we'd tell it where the TCP header starts, as
>> I described before.)
> That is kind of what I figured.  So does that mean for IPv6 you guys
> are parsing through extension headers?  I believe that is one of the
> reasons why Intel did things the way they did is to avoid having to
> parse through any IPv4 options or IPv6 extension headers.
I believe so, but I'd have to check with our firmware team to be sure.
The hardware needs to have that capability for RX processing, where it
wants to figure out things like the l4proto for IPv6: you have to walk
the extension headers until you get a layer 4 nexthdr.  I wonder how
Intel manage without that?
>> I agree this isn't something we can do silently.  But we _can_ make it a
>> condition for enabling gso-partial.  And I think it's a necessary
>> condition for truly generic TSO.  Sure, your 'L3 extension header' works
>> fine for a single tunnel.  But if you nest tunnels, you now need to
>> update the outer _and_ middle IP IDs, and you can't do that because you
>> only have one L3 header pointer.
> This is getting away from the 'less is more' concept.  If we are doing
> multiple levels of tunnels we have already made things far too
> complicated and it is unlikely hardware will ever support anything
> like that.
That's not how I understood the concept.  I parsed it as "if hardware knows
less, we can get more out of it", i.e. by having the hardware blithely paste
together whatever headers you give it, you can support things like nested
tunnels.  As long as your 'middle' IP header has DF set, this can be done
without the hardware needing to know a thing about it.  And while we don't
need to implement that straight away, we should care to design our
interfaces to ensure we can do that in the future without too much trouble.
>> Of course, that means changing the firmware; luckily we haven't got any
>> parts in the wild doing tunnel offloads yet, so we still have a chance
>> to do that without needing driver code to work around our past
>> mistakes...
>>
>> But this stuff does definitely add value for us, it means we could TSO
>> any tunnel type whatsoever; even nested tunnels as long as only the
>> outermost IP ID needs to change.
> Right.  In your case it sounds like you would have the advantage of
> just having to run essentially two counters, one increments the IPv4
> ID and the other decrements the IPv4 checksum.  Beyond that the outer
> headers wouldn't need to change at all.
Exactly.
> The only other issue would be determining how the inner pseudo-header
> checksum is updated.  If you were parsing out header fields from the
> IP header previously to generate it you would instead need to update
> things so that you could use the partial checksum that is already
> stored in the TCP header checksum field.
Right, but again that's sufficiently under firmware control (AFAIK) that
that should just be a SMOP for the firmware.  Though I will ask about
that tomorrow, just in case.

-Ed
