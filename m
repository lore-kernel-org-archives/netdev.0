From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 8 Mar 2016 08:49:55 -0800
Message-ID: <CALx6S35bpBZ-cVPjMiKBE978sGt1_5+bgwLDRfgR+ZumhBf8YA@mail.gmail.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
	<CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
	<CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41116831@AcuExch.aculab.com>
	<CALx6S35h+oSCKsaEotah30tspZPdp3GZThrN8=cLbE2O7nhU2g@mail.gmail.com>
	<CAKgT0UfKA=ugpxuUYmv_DaEErRvEDFbGkhHDaFCxDM9C5YzeCQ@mail.gmail.com>
	<CALx6S378j3WKvHc6_NQ1544gjSu7mp_OsE9xGzXnCrBCusNjOw@mail.gmail.com>
	<CA+55aFwvjK16LDhztbmkvLe2wm=G5MXA2_rC=CksUgbTcvb-pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Laight <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:36440 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932144AbcCHQt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 11:49:56 -0500
Received: by mail-io0-f181.google.com with SMTP id z76so33033835iof.3
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 08:49:55 -0800 (PST)
In-Reply-To: <CA+55aFwvjK16LDhztbmkvLe2wm=G5MXA2_rC=CksUgbTcvb-pA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 5:39 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Mar 7, 2016 at 4:07 PM, Tom Herbert <tom@herbertland.com> wrote:
>>
>> As I said previously, if alignment really is a factor then we can
>> check up front if a buffer crosses a page boundary and call the slow
>> path function (original code). I'm seeing a 1 nsec hit to add this
>> check.
>
> It shouldn't be a factor, and you shouldn't check for it. My code was
> self-aligning, and had at most one unaligned access at the beginnig
> (the data of which was then used to align the rest).
>
Yes, but the logic to do the alignment does not come for free. The
intent of these patches is really to speed up checksums over small
buffers (like the checksum over the IP header or pulling up checksums
over protocol headers for dealing with checksum-complete). For
checksum over larger buffers, e.g. TCP/UDP checksums we are depending
on checksum offload (there are still some case where the host will
need to a packet checksum, but as vendors move to providing up
protocol agnostic checksum those should go away). In the VXLAN GRO
path for instance, we do a checksum pull over both the UDP header and
VLXAN headers each of which are 8 bytes. csum_partial can be trivially
implemented for a buffer of length 8 with three adcq instructions (as
in my patch). When we're using VXLAN in IPv4 both the VLXAN headers
and UDP will likely not be eight byte aligned, but alignment seems to
only be an issue when crossing a page boundary. The probability that
an 8 byte header crosses a page boundary is already very low, and
probably with a little bit code drivers could pretty much guarantee
that packet headers don't straddle page boundaries. So it seems like
the effort to align small buffers, assuming they don't straddle page
boundaries, provides little or no value.

Tom

> Tom had a version that used that. Although now that I look back at it,
> it seems to be broken by some confusion about the one-byte alignment
> vs 8-byte alignment.
>
>              Linus
