From: Karl Heiss <kheiss@gmail.com>
Subject: Re: IPSEC: tunnel breakage with out-of-order IPv4 fragments
Date: Fri, 11 Jul 2014 08:51:14 -0400
Message-ID: <CAGugRbWPOyWLrdiTqtScWi2JTKeyEEjOLRvDUqx20SG7uXifLw@mail.gmail.com>
References: <CAGugRbVWyTM2J0Fyw1Cq1byqfjZBy_EFLSShqVdzxYZmmUWK_g@mail.gmail.com>
	<20140711110035.GB6633@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:43247 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbaGKMvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 08:51:15 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so847011iec.10
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 05:51:15 -0700 (PDT)
In-Reply-To: <20140711110035.GB6633@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2014 at 7:00 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Jul 10, 2014 at 10:57:21AM -0400, Karl Heiss wrote:
>> I believe I have found an issue whereby IPv4 fragments arriving
>> out-of-order will cause an IPSEC tunnel to stop passing any traffic
>> which arrived fragmented, citing 'SA-icv-failure'.
>
> Why do you think the arriving order causes our problems? SA-icv-failure
> means that the integrity check failed and this is independent of the
> packet order, unless you use 64 bit extended sequence numbers (ESN).
> I would guess you don't use ESN because you noticed these problems
> already with v2.6.32 and this had no ESN support.

Because using a simple scapy script (from a 3rd host with readily
available information), I can kill an existing IPsec connection which
is passing fragmented traffic 100% of the time.  Once the failure
occurs, every subsequent fragmented packet causes an audit entry
citing SA-icv-failure.

>
> If this happens just with fragmented packets, I'd guess there is a
> problem when packets get fragmented after IPsec and reassembled
> before IPsec processing.
>

If I am reading the tcpdump correctly, the issue is that the packets
are getting fragmented after IPsec processing.

    10.240.34.75.35689 > linux.local.60000: sctp (1) [COOKIE ECHO]
08:23:05.821858 IP (tos 0x2,ECT(0), ttl 64, id 0, offset 0, flags
[DF], proto ESP (50), length 104)
    linux.local > 10.240.34.75: ESP(spi=0x0d34ea75,seq=0x44be), length 84
08:23:06.823989 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 0, flags [+],
proto ESP (50), length 1500)
    10.240.34.75 > linux.local: ESP(spi=0xedc4a797,seq=0x89b5), length 1480
08:23:06.824001 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 1480, flags
[none], proto ESP (50), length 32)
    10.240.34.75 > linux.local: esp
08:23:06.824030 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 0, flags [+],
proto ESP (50), length 1500)
    10.240.34.75 > linux.local: ESP(spi=0xedc4a797,seq=0x89b6), length 1480
08:23:06.824035 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 1480, flags
[none], proto ESP (50), length 32)
    10.240.34.75 > linux.local: esp
08:23:06.824057 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 0, flags [+],
proto ESP (50), length 1500)
    10.240.34.75 > linux.local: ESP(spi=0xedc4a797,seq=0x89b7), length 1480
08:23:06.824060 IP (tos 0x2,ECT(0), ttl 60, id 0, offset 1480, flags
[none], proto ESP (50), length 32)

>> Packets which were
>> not fragmented will validate and pass successfully, even once the
>> condition has been triggered.  I have decrypted the traffic and have
>> verified that the traffic is arriving correctly.  It appears as if the
>> condition persists until all connections are closed.
>>
>> The issue was originally discovered in RHEL 6.5 (2.6.32-431.11.2.el6)
>> kernel and verified with Fedora 20 running 3.15.0-rc8-nn on x86_64.
>>
>> The easiest way I have found to reproduce the issue is to use a kernel
>> without commit c08751c851b78514f6ec5 (Fix data chunk fragmentation for
>> MTU values which are not multiple of 4) to generate fragmented SCTP
>> traffic using multiple single-homed connections.
>
> Do you have some odd MTU/PMTU value on this route? If so, you might
> get post IPsec fragmented packets without that commit.
>

The MTU for this path is 1500 all the way through.

Yes, this commit most likely fixes the post IPsec fragmentation, as
SCTP was not previously accounting for the IPsec headers when sizing
chunks.  However, if the traffic worked in this case without
reordering, wouldn't we hope it could handle the reordered case, even
with the post IPsec fragmentation?

> I have a lot of testcases where I test PMTU discovery and fragmentation
> with IPsec. I've never seen such problems, but I don't use sctp. Is there
> any chance to reproduce this with another protocol?
>

I can try to reproduce this with TCP, but I think I would have to
specially craft post IPsec fragments since I don't think the stack
would let me fragment them (DF set, TCP takes IPsec headers into
account).  The un-patched SCTP is what specifically allows this.

Karl
