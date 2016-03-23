From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 7/9] GSO: Support partial segmentation offload
Date: Wed, 23 Mar 2016 16:15:49 -0700
Message-ID: <CAKgT0UfyOc4tYhZq7CC5G4S5HdzPW3iSifdcwe20Vxsqu8C3LQ@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36408 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbcCWXPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 19:15:50 -0400
Received: by mail-ig0-f178.google.com with SMTP id nk17so102016143igb.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 16:15:50 -0700 (PDT)
In-Reply-To: <56F3200C.20200@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 4:00 PM, Edward Cree <ecree@solarflare.com> wrote:
> On 23/03/16 22:36, Alexander Duyck wrote:
>> On Wed, Mar 23, 2016 at 2:05 PM, Edward Cree <ecree@solarflare.com> wrote:
>>> I disagree.  Surely we should be able to "soft segment" the packet just
>>> before we give it to the physical device, and then tell it to do dumb copying
>>> of both the VXLAN and IPIP headers?  At this point, we don't have the problem
>>> you identified above, because we've arrived at the device now.
>> One issue here is that all levels of IP headers would have to have the
>> DF bit set.  I don't think that happens right now.
> Yes, that's still a requirement.  (Well, except for the outermost IP header.)
>>> So we can chase through some per-protocol callbacks to shorten all the outer
>>> lengths and adjust all the outer checksums, then hand it to the device for
>>> TSO.  The device is treating the extra headers as an opaque blob, so it
>>> doesn't know or care whether it's one layer of encapsulation or forty-two.
>> So if we do pure software offloads this is doable.  However the GSO
>> flags are meant to have hardware feature equivalents.  The problem is
>> if you combine an IPIP and VXLAN header how do you know what header is
>> what and which order things are in, and what is the likelihood of
>> having a device that would get things right when dealing with 3 levels
>> of IP headers.  This is one of the reasons why we don't support
>> multiple levels of tunnels in the GSO code.  GSO is just meant to be a
>> fall-back for hardware offloads.

> Right, but if the hardware does things "the new way" it should work fine:
> Packet still starts with Eth + IP.  Packet still has TCP headers at some
> specified offset.  So it all works, as long as you don't have to update
> any IP IDs except possibly the outermost one.

Right, but the problem becomes how do you identify what tunnel wants
what.  So for example we could theoretically have a UDP tunnel in a
UDP with checksum.  How would we tell which one want to have the
checksum set and which one doesn't?  The fact is we cannot.  You are
looking too far ahead.  We haven't gotten to tunnel in tunnel yet.
The approach as it stands doesn't have any issues that necessarily
prevent that as long as the outer is the only IP ID that has to
increment, but we don't support anything like that now so we don't
need to worry about it too much.

>>> Ok, it sounds like the interface to Intel hardware is just Very Different
>>> to Solarflare hardware on this point: we don't tell our hardware anything
>>> about where the various headers start, it just parses them to figure it
>>> out.  (And for new-style TSO we'd tell it where the TCP header starts, as
>>> I described before.)
>> That is kind of what I figured.  So does that mean for IPv6 you guys
>> are parsing through extension headers?  I believe that is one of the
>> reasons why Intel did things the way they did is to avoid having to
>> parse through any IPv4 options or IPv6 extension headers.

> I believe so, but I'd have to check with our firmware team to be sure.
> The hardware needs to have that capability for RX processing, where it
> wants to figure out things like the l4proto for IPv6: you have to walk
> the extension headers until you get a layer 4 nexthdr.  I wonder how
> Intel manage without that?

They have some parsing in the Rx.  That is one of the reasons why
there was all the arguing about adding GENEVE port numbers a few
months ago.  They just don't make use of it in the Tx path with the
exception of the fm10k parts.

>>> I agree this isn't something we can do silently.  But we _can_ make it a
>>> condition for enabling gso-partial.  And I think it's a necessary
>>> condition for truly generic TSO.  Sure, your 'L3 extension header' works
>>> fine for a single tunnel.  But if you nest tunnels, you now need to
>>> update the outer _and_ middle IP IDs, and you can't do that because you
>>> only have one L3 header pointer.
>> This is getting away from the 'less is more' concept.  If we are doing
>> multiple levels of tunnels we have already made things far too
>> complicated and it is unlikely hardware will ever support anything
>> like that.

> That's not how I understood the concept.  I parsed it as "if hardware knows
> less, we can get more out of it", i.e. by having the hardware blithely paste
> together whatever headers you give it, you can support things like nested
> tunnels.  As long as your 'middle' IP header has DF set, this can be done
> without the hardware needing to know a thing about it.  And while we don't
> need to implement that straight away, we should care to design our
> interfaces to ensure we can do that in the future without too much trouble.

The design as is does nothing to prevent that.  One of the reasons why
I prefer to keep the outer IP ID incrementing is in order to support
that kind of concept.  Also it shields us a bit as we usually cannot
control the network between the tunnel endpoints since it is usually
traversing a WAN.  What we need to do though is go through and see if
we can get away with something like "if inner IP DF is set the outer
IP DF bit must be set" kind of logic for GRE and UDP tunnels.  If we
can push that then it will allow us to essentially fix all the tunnel
logic in one shot since TCP requires DF bit be set so all levels of
headers would have the DF bit set.

>>> Of course, that means changing the firmware; luckily we haven't got any
>>> parts in the wild doing tunnel offloads yet, so we still have a chance
>>> to do that without needing driver code to work around our past
>>> mistakes...
>>>
>>> But this stuff does definitely add value for us, it means we could TSO
>>> any tunnel type whatsoever; even nested tunnels as long as only the
>>> outermost IP ID needs to change.
>> Right.  In your case it sounds like you would have the advantage of
>> just having to run essentially two counters, one increments the IPv4
>> ID and the other decrements the IPv4 checksum.  Beyond that the outer
>> headers wouldn't need to change at all.
> Exactly.
>> The only other issue would be determining how the inner pseudo-header
>> checksum is updated.  If you were parsing out header fields from the
>> IP header previously to generate it you would instead need to update
>> things so that you could use the partial checksum that is already
>> stored in the TCP header checksum field.
> Right, but again that's sufficiently under firmware control (AFAIK) that
> that should just be a SMOP for the firmware.  Though I will ask about
> that tomorrow, just in case.

There shouldn't be much to it.  In the case of the Intel parts they
want the length cancelled out of the checksum by the driver and they
they fold it back in via hardware.  I would imagine that your hardware
could probably do something similar or may already be doing it since
the length has to be handled differently for IPv4 vs IPv6.

- Alex
