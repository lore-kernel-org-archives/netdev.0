From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Tue, 8 Dec 2015 09:04:06 -0800
Message-ID: <CALx6S36aMvroE0mWz9+9EU+newrfkUqqFO+6T5YZVh_9xrMJLg@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34160 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbLHREG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 12:04:06 -0500
Received: by igvg19 with SMTP id g19so105653485igv.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 09:04:06 -0800 (PST)
In-Reply-To: <5666EC4B.40800@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 6:42 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 07/12/15 19:38, David Miller wrote:
>> No, it is better to universally provide the 1's complement sum for
>> all receive packets.  This allows the stack more flexibility in
>> checksum handling.
> I'm afraid I still don't see it.  If a device can both provide the 1's complement sum _and_ validate some of the checksums in the packet, that should be strictly better than just providing the 1's complement sum - the stack has at least as much information, and less work to do.  And while there is no general way at present for a driver to tell the stack it has done both (and in my opinion there should be such a way), it _is_ possible in the specific case of a UDP packet with the checksum filled in, thanks to CHECKSUM_UNNECESSARY conversion.  So why shouldn't a device (that otherwise gives the full ones complement sum with CHECKSUM_COMPLETE) use CHECKSUM_UNNECESSARY in this specific case?  Is there a flaw in my logic, or is it just that this would be a hack and the Right Thing is to chang
 e the interface to let a driver report both pieces of information *directly*?  Or am I wrong for some other reason?

The overhead of the stack to process CHECKSUM_COMPLETE is negligible,
we need to pull the checksum in protocol headers as they are process
which means the data is in cache any way (also IPv4 headers don't
needed to be pulled). In my testing I see CPU utilization csum_partial
drop from >6% to <0.5% in comparing computing csum on host and
CHECKSUM_COMPLETE.

There are other reasons why CHECKSUM_COMPLETE is preferable:

- CHECKSUM_COMPLETE  is more robust. We have no way to validate that
the device is actually correct in CHECKSUM_UNNECESSARY. For instance,
how do we know that there isn't some failure in the device where
everything is being marked as good even if it's not. With
CHECKSUM_COMPLETE it is the host that actually makes the decision of
whether the checksum is correct it is highly unlikely that failing
checksum calculation on the device won't be detected. HW failures and
bugs are real concern.
-  CHECKSUM_UNNECESSARY does not report bad checksums. There is a
csum_bad flag in the sk_buff that could be set if the driver detects a
bad checksum in the packet, but no drivers seem to be setting that
currently. So for any packets with bad checksums the stack will need
to compute the checksum itself, so this potentially becomes the basis
of a DDOS attack. CHECKSUM_COMPLETE does not have this problem, we get
the checksum of the packet rather the checksum is correct or not.

Tom
