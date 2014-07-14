From: Karl Heiss <kheiss@gmail.com>
Subject: Re: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Mon, 14 Jul 2014 07:52:23 -0400
Message-ID: <CAGugRbWL8Orkobwt4FENyswLsm1jWLBMdr-WJ6mCBhVn-xGwXw@mail.gmail.com>
References: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
	<20140711110035.GB6633@secunet.com>
	<CAGugRbWPOyWLrdiTqtScWi2JTKeyEEjOLRvDUqx20SG7uXifLw@mail.gmail.com>
	<20140714093345.GC6633@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:45584 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbaGNLwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 07:52:24 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so3158356iec.12
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 04:52:23 -0700 (PDT)
In-Reply-To: <20140714093345.GC6633@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 5:33 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Fri, Jul 11, 2014 at 08:51:14AM -0400, Karl Heiss wrote:
>> On Fri, Jul 11, 2014 at 7:00 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>>
>> >
>> > If this happens just with fragmented packets, I'd guess there is a
>> > problem when packets get fragmented after IPsec and reassembled
>> > before IPsec processing.
>> >
>>
>> If I am reading the tcpdump correctly, the issue is that the packets
>> are getting fragmented after IPsec processing.
>>
>>     10.240.34.75.35689 > linux.local.60000: sctp (1) [COOKIE ECHO]
>> 08:23:05.821858 IP (tos 0x2,ECT(0), ttl 64, id 0, offset 0, flags
>> [DF], proto ESP (50), length 104)
>>     linux.local > 10.240.34.75: ESP(spi=0x0d34ea75,seq=0x44be), length 84
>> 08:23:06.823989 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 0, flags [+],
>> proto ESP (50), length 1500)
>>     10.240.34.75 > linux.local: ESP(spi=0xedc4a797,seq=0x89b5), length 1480
>> 08:23:06.824001 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 1480, flags
>> [none], proto ESP (50), length 32)
>>     10.240.34.75 > linux.local: esp
>> 08:23:06.824030 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 0, flags [+],
>> proto ESP (50), length 1500)
>>     10.240.34.75 > linux.local: ESP(spi=0xedc4a797,seq=0x89b6), length 1480
>> 08:23:06.824035 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 1480, flags
>> [none], proto ESP (50), length 32)
>>     10.240.34.75 > linux.local: esp
>> 08:23:06.824057 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 0, flags [+],
>> proto ESP (50), length 1500)
>>     10.240.34.75 > linux.local: ESP(spi=0xedc4a797,seq=0x89b7), length 1480
>> 08:23:06.824060 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 1480, flags
>> [none], proto ESP (50), length 32)
>
> Your tcpdump looks interesting. Is it possible that all your
> fragmented packets have the id field set to 'id 0'? This should
> be only the case if the DF flag is set on that packet, but this
> is apparently not the case here. If all the fragmented packets
> have id 0, it is not possible to determine the correct fragment
> chain. If only one fragment gets lost, all further packets might
> be reassembled wrong.
>

Yes, all fragments have 'id 0'.

> When looking at the code, is seems that sctp sets the DF flag
> on packets as the default. The IPsec encapsulation code copies
> the DF bit from the inner header and sets 'id 0' in this case.
> A first guess would be that someone removes the DF flag after
> the IPsec encapsulation.
>
> Is the DF flag set on your inner sctp packets?
>

Yes, the inner packets have DF set, but the outer do not.

>> >
>> > Do you have some odd MTU/PMTU value on this route? If so, you might
>> > get post IPsec fragmented packets without that commit.
>> >
>>
>> The MTU for this path is 1500 all the way through.
>>
>> Yes, this commit most likely fixes the post IPsec fragmentation, as
>> SCTP was not previously accounting for the IPsec headers when sizing
>> chunks.  However, if the traffic worked in this case without
>> reordering, wouldn't we hope it could handle the reordered case, even
>> with the post IPsec fragmentation?
>
> Sure, I just wanted to know whether I look into the right direction :)
>

Karl
