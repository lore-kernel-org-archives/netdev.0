From: Tom Herbert <therbert@google.com>
Subject: Re: Does CHECKSUM_COMPLETE work at all?
Date: Sat, 22 Feb 2014 09:32:03 -0800
Message-ID: <CA+mtBx8xGmZvZU+P4Uy6q3TxWdOgK3-ke9Ccfx3=xRS2-ygSQA@mail.gmail.com>
References: <CA+mtBx8safaPpcntjqT+eUQBDEOxJBoVf-a9djX_qgYsSdACeA@mail.gmail.com>
	<CBA48B605613B640864883107238931C0F9077@nice.asicdesigners.com>
	<CA+mtBx97w02+6iVcDxsGh4-TzsnZcjRv0+jyD=qGrCPfcWNDqg@mail.gmail.com>
	<53089B34.5060504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dimitrios Michailidis <dm@chelsio.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:62858 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbaBVRcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 12:32:05 -0500
Received: by mail-ie0-f171.google.com with SMTP id to1so2284396ieb.30
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 09:32:04 -0800 (PST)
In-Reply-To: <53089B34.5060504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 22, 2014 at 4:42 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 02/22/2014 04:08 AM, Tom Herbert wrote:
> ...
>
>> Well..., I started trying to fix the UDP encapsulation code which we
>> agreed was broken for checksums. This also entails fixing the new UDP
>> GRO code to deal with checksums correctly when going through protocol
>> layers. But, just looking at CHECKSUM_COMPLETE it seems like it's
>> fundamentally broken even without encapsulation. Between GRO and HW
>> checksums, it seems like we have a pretty big mess! :-)
>
>
> Seems so, e.g. d97c00a32198 ("vxlan: fix receive checksum handling")
> had similar issues in that regard; maybe because there seems to be
> different consensus among drivers on setting CHECKSUM_COMPLETE?

There shouldn't be, the requirements are pretty clear in the
description of CHECKSUM_COMPLETE. However, the meaning of
CHECKSUM_UNNECESSARY is ambiguous. Checksum offload for simple TCP or
UDP packets is fairly straightforward, but as devices support other
protocols and combinations of encapsulations correctness becomes
suspect. The problem is that the host can't verify
CHECKSUM_UNNECESSARY, so if it's not right or there is not agreement
between host and device as to which checksums are covered, then
packets can received with bad checksums. This will be really hard to
debug! As the comments about CHECKSUM_UNNECESSARY say "It is a bad
option" :-)

I think the fix for CHECKSUM_COMPLETE is to hold the start and length
of the data pertaining skb->csum. This way we only need to pull the
checksum when actually verifying it (don't want to pull it at every
header pull). This also relaxes the requirement that the device
provides the checksum for the whole packet, it could instead provide
partial coverage (there's really no need to have Ethernet header
checksummed for instance). No where in the stack should we be changing
CHECKSUM_COMPLETE to CHECKSUM_UNNECESSARY (that is a demotion), also
we should never be folding pseudo header checksum into skb->csum.
