From: Tom Herbert <therbert@google.com>
Subject: Re: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 07:59:54 -0700
Message-ID: <CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39468 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbaI3PXy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:23:54 -0400
Received: by mail-ie0-f174.google.com with SMTP id tr6so4041919ieb.19
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 08:23:54 -0700 (PDT)
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 5:51 AM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
> Hi,
>
> I was pondering what it would take for a network device support
> CHECKSUM_COMPLETE on its Rx path. And I simply failed to understand the
> specifics when using the napi_gro_receive() interface.
>
> Scenario 1 - TCP/IPv4 packet. This will eventually reach tcp4_gro_receive(), and from
> there into skb_gro_checksum_validate().
> Since this SKB is marked as COMPLETE, the pseudo TCP checksum will be computed
> and skb_gro_checksum_validate_complete() be called.
> Now, it seems to me as if the only way by which the flow won't actually try to
> re-calculate the checksum over TCP header and payload is if NAPI_GRO_CB(skb)->csum
> is actually the one's complement to the TCP pseudo header. But that sounds.... odd,
> since that's the csum that should have been listed on the SKB - and it doesn't protect
> any of the data, only the "metadata".
>
With CHECKSUM_COMPLETE, on entrance into GRO NAPI_GRO_CB(skb)->csum is
set to skb->csum. As the packet is parsed through various levels of
GRO the value is adjusted so that at any header level it is the
complete checksum starting from that header to the end of the packet.
So to validate a TCP checksum we just need to add the value of the
pseudo header checksum (a little computation) and compare to zero.

> Scenario 2 - IP-GRE packet, with CSUM option on the GRE header.
> This scenario will also eventually reach skb_gro_checksum_validate_complete(),
> this time via gre_gro_receive().
> This one is even odder, since in order for the flow not to re-calculate the checksum
> The driver should have set the SKB's csum to 0xffffffff [as it's using the
> null_compute_pseudo() which will return a pseudo_csum of 0].
>
> From the comment in skbuff.h regarding CHECKSUM_COMPLETE it looks as if all
> the HW needs to do is calculate the checksum over the entire data, starting at the
> network header.
>
GRE is actually simpler since there is no pseudo header. If a GRE
checksum bit is set then skb->csum (NAPI_GRO_CB(skb)->csum) must be
zero for a valid checksum at the time GRE header is processed and we
have CHECKSUM_COMPLETE.

> So, to summarize my questions -
> 1. What should a driver set as the SKBs csum value when passing CHECKSUM_COMPLETE?

This ones complete checksum of the Ethernet payload (start of IP
header to the end of the packet).

> 2. Does the GRO flow for non-encapsulated packets work for packets marked as
> CHECKSUM_COMPLETE? And by work, I obviously mean 'doesn't re-calculate checksums'.

Yes.

> 3. Same as question 2, but for encapsulated packets.
>
Yes.

Hope this helps,
Tom

> Thanks,
> Yuval
>
>
>
> ________________________________
>
> This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
