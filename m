From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH 1/2] net: udp: local checksum offload for encapsulation
Date: Tue, 15 Dec 2015 18:07:48 +0000
Message-ID: <567056F4.1050107@solarflare.com>
References: <566EDC16.1060706@solarflare.com>
 <566EDC85.6060101@solarflare.com>
 <CALx6S34pyayogC3ZrifL9TGCzQbu_sC9R2Xtp8GsnybbZ9Ve6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:20434 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753528AbbLOSH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 13:07:57 -0500
In-Reply-To: <CALx6S34pyayogC3ZrifL9TGCzQbu_sC9R2Xtp8GsnybbZ9Ve6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/12/15 17:16, Tom Herbert wrote:
> It's clever, but I'm not sure this saves much. The outer checksum
> could still be offloaded to the device without the extra work.
The main thing it saves you is having to fit a second csum_start/offset pair
 into (a) the SKB and (b) the TX descriptor.  Also, it will (at least in
 principle) support arbitrarily deep nesting of encapsulation.  (Whether
 that's a remotely sensible thing to do is another matter!)

Also, local checksum offload probably helps by simplifying TSO.
I've just been talking to our firmware team and we concluded that if the
 outer checksum (of the superpacket) is filled in by the stack, datapath
 firmware on the sfc 8000 series could fold appropriate corrections (to
 account for changes in outer length and the length fields in both pseudo
 headers) into the outer checksum when performing TSO, which may (we
 haven't benchmarked it yet!) improve performance, compared to computing the
 whole outer checksum from scratch.
> Where
> this technique would be nice is if the device doesn't support checksum
> offload at all, then we would definitely avoid doing multiple
> checksums. That's going to be harder since we won't see
> CHECKSUM_PARTIAL in that case for the inner checksum, but it would get
> us to the principle that we only ever calculate the packet checksum
> once or zero times.
Presumably in that case the inner checksum would be marked as
 CHECKSUM_UNNECESSARY, and the code that fills in the inner checksum could
 also fill in skb->csum_start and skb->csum_offset.  Then in udp_set_csum()
 we could just treat it exactly the same as CHECKSUM_PARTIAL.  Then we could
 update start and offset to refer to the checksum we've just filled in, so
 that any nested encap doesn't have to re-checksum our header.
I have no objections to that, but I don't think I grok the rest of the stack
 deeply enough to implement it.

In the meantime, it seems worthwhile getting the CHECKSUM_PARTIAL version
 in, and working any bugs out of it; do you have any objections to my patch
 series as it stands or should I repost without RFC tags?  I notice it's
 marked "Changes Requested" in patchwork but it's not entirely clear to me
 what changes are wanted.
