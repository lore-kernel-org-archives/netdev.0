From: Tom Herbert <tom@herbertland.com>
Subject: Re: CHECKSUM_UNNECESSARY semantics with driver modified.created packets
Date: Fri, 17 Feb 2017 13:29:39 -0800
Message-ID: <CALx6S37+Ce792ps+OByobMPf54qCFj8jAi2dcG5jwr7sdwufKw@mail.gmail.com>
References: <CALx6S37uukN4gALxFxYJ3Syq=+53RUNpLNbNHwBrSc=jf5PcFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:36142 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934963AbdBQV3l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 16:29:41 -0500
Received: by mail-qt0-f179.google.com with SMTP id k15so51115548qtg.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 13:29:41 -0800 (PST)
In-Reply-To: <CALx6S37uukN4gALxFxYJ3Syq=+53RUNpLNbNHwBrSc=jf5PcFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 1:04 PM, Tom Herbert <tom@herbertland.com> wrote:
> Alexei and I were looking at the mlx5 LRO code this morning. One
> discrepancy I noticed with GRO is that CHECKSUM_UNNECESSARY is set for
> the assembled packet whereas in GRO we use CHECKSUM_PARTIAL. The
> effect of using checksum-unnecessary is that the actual TCP checksum
> in the packet is not correct for the packet. Since gso_type set this
> probably is okay when packet is forwarding (checksums recomputed), but
> this seems to make some assumptions about the meaning of
> checksum-unnecessary. Looking if the rules of checksum in skbuff.h
> we're no explicit in saying whether the checksum actually in the
> packet must be correct.
>
> I think there's some possible ways to address this:
>
> 1) Allow actual checksum to be incorrect in packet when the packet is
> gso. On TX checksum must always be computed then.
> 2) Change the instances where driving is modifying a packet or
> creating a new one as in LRO case to use CHECKSUM_PARTIAL.
> 3) Modify the checksum in the packet so that it is correct. We do this
> in nearly all other cases where we modify the packet (e.g. NAT). Would
> be hard to do in LRO though.
>
On second thought, I don't think #1 is correct. For instance, if we
ever applied this to UDP that would break checksum-unnecessary
conversion. Also, the stack should always have the prerogative to not
trust checksum-unnecessary mark and do the calculation itself.
checksum-unnecessary should mean the checksum has been verified to be
correct and it is correct in the packet.

For LRO, drivers should use checksum-partial I think.

Tom

> In any case, I think we need to update sk_buff.h to clarify what the
> semantics are.
>
> Tom
