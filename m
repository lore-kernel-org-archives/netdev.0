From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Mon, 1 Feb 2016 10:18:23 -0800
Message-ID: <CAKgT0UfrMUFSZqKYdeLDjAmN5wf9YVw19XfCT_fkHvRzK9-XYA@mail.gmail.com>
References: <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
	<1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
	<20160130.194507.777391919166997236.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD25A8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sowmini.varadhan@oracle.com" <sowmini.varadhan@oracle.com>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tom@herbertland.com" <tom@herbertland.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34092 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbcBASSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 13:18:24 -0500
Received: by mail-io0-f174.google.com with SMTP id 9so88028687iom.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 10:18:23 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD25A8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 1, 2016 at 8:50 AM, David Laight <David.Laight@aculab.com> wrote:
> From: David Miller
>> Sent: 31 January 2016 03:45
>> To: alexander.duyck@gmail.com
> ...
>> > I would really prefer to keep the pages DMA aligned, and the skb->data
>> > IP aligned.  If nothing else it has the advantage of actually having
>> > the proper alignment on all the headers if I only pull the outer
>> > headers and leave the inner headers in the page.. :-/
>>
>> I am unconvinced by your arguments.  People getting hit by these
>> arguments don't care.  For those not hitting the problem, nothing is
>> going to change.
>>
>> x86 uses NET_IP_ALIGN==0, and therefore nothing will change for the
>> only platform people care a lot about.  PowerPC too.
>>
>> For platforms with NET_IP_ALIGN==2 or similar, all of these cases
>> where 1K extra buffer is allocator or _whatever_ other side effect you
>> think is such as huge deal...  trust me it's _nothing_ compared to the
>> alternative:
>>
>> 1) Unaligned accesses
>
> Remember the even if you do a 'realignment copy' of the IP header,
> at some point the 'userdata' of the packet has to be accessed.
> Mostly this will be with memcpy() and you want that copy to be aligned.

The problem is, aligned by what?  For x86 anything other than 16 byte
alignment will require some realignment anyway since internally it is
essentially doing some SSE style copy based on rep movsb.  I'm sure it
is similar for other architectures that have moved on from 32b to 64b
in that they want to move by the largest available data unit and 2
byte alignment vs 4 byte doesn't make that much difference anymore.

The thing you have to keep in mind is that your standard TCP frame has
66 bytes of headers(14 Ethernet, 20 IP, 20 TCP, 12 TCP options).  This
means that you are crossing over into the next cache line by either 2
or 4 bytes depending on NET_IP_ALIGN.  On a system with an 8 byte long
it doesn't really make a difference one way or the other since it is
still unaligned in terms of the fastest possible memcpy.

> I really can't believe just how many ethernet chips are now being designed
> that can't write received frames to '4n+2' boundaries.
> It isn't even a new problem. Sun fixed the sbus 'DMA' part so that it would
> to sbus burst transfers to 4n+2 aligned buffers a long time ago...

The problem here is motivation.  It makes sense that Sun would want
their headers to be IP aligned since a Sparc processor still needs
that.  Most NIC vendors don't really care about the more obscure
architectures, and even 32 bit is falling out of favor.  The market
share is just too small and in many cases customers don't run Linux
OSes on them anyway so even driver support is minimal.  They mostly
care about x86_64, PowerPC, and 64 bit ARM.  And all 3 of those
architectures have efficient unaligned accesses.
