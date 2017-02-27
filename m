From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [RFC PATCH net-next 2/5] net: split skb_checksum_help
Date: Mon, 27 Feb 2017 14:39:43 +0100
Message-ID: <1488202783.2713.67.camel@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
         <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
         <CALx6S37E=OEkRego_u=oDuUgQUn9-NZLpupvbN_dge1rqF92CQ@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DB026CEA4@AcuExch.aculab.com>
         <1486048043.2556.4.camel@redhat.com>
         <CALx6S34KvvLYo_wrnX-da5ok3Z4pcdyJxiLi63iHzno9j9L4Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "'Tom Herbert'" <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751391AbdB0PfO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 10:35:14 -0500
In-Reply-To: <CALx6S34KvvLYo_wrnX-da5ok3Z4pcdyJxiLi63iHzno9j9L4Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-23 at 12:59 -0800, Tom Herbert wrote:
> > > > It might make sense to create some CRC helper functions, but last time
> > > > I checked there are so few users of CRC in skbufs I'm not even sure
> > > > that would make sense.

hello Tom and David,

after some (thinking + testing) time, I'm going to re-post this RFC as v2 with
some feedbacks. Thank you in advance for looking at it!

On Thu, 2017-02-02 at 10:08 -0800, Tom Herbert wrote:
> On Thu, 2017-02-02 at 16:07 +0100, Davide Caratti wrote:
> > This is exactly the cause of issues I see with SCTP. These packets can be
> > wrongly checksummed using skb_checksum_help, or simply not checksummed at
> > all; and in both cases, the packet goes out from the NIC with wrong L4
> > checksum.
> > 
> Okay, makes sense. Please consider doing the following:
> 
> - Add a bit to skbuf called something like "csum_not_inet". When
> ip_summed == CHECKSUM_PARTIAL and this bit is set that means we are
> dealing with something other than an Internet checksum.

Ok, done. Another solution would be to extend possible values of
skb->ip_summed, and define a new value suitable for identifying
not-yet-checksummed SCTP packets (something like CRC32C_PARTIAL). Since
skb->ip_summed is 2-bit wide, the overall effect on skb metadata is the
same as adding skb->csum_not_inet [1].

> - At the top of skb_checksum_help (or maybe before the point where the
> inet specific checksum start begins do something like:
> 
>    if (unlikely(skb->csum_not_inet))
>        return skb_checksum_help_not_inet(...);
> 
>    The rest of skb_checksum_help should remained unchanged.

According to documentation [2], validate_xmit_skb() is a good place where
the if() statement above can be done, to preserve the possibility of having
the CRC32c computation offloaded by the NIC hardware:

if (unlikely(skb->csum_not_inet && !(features & NETIF_F_SCTP_CRC))
	       return skb_checksum_help_not_inet(...);

On Thu, 2017-02-02 at 16:55 +0000, David Laight wrote:
> 
> I'd put the onus on any such interface to perform the checksum (and
> set CHECKSUM_COMPLETE (or is it UNNECESSARY?) before passing the 
> message onto an interface that doesn't advertise CRC32 support.
> 
> You certainly don't want to have to go through all the ethernet drivers!

Ideally, a driver not able to offload checksum computation should call
skb_checksum_help() or skb_sctp_csum_help() to resolve CHECKSUM_PARTIAL
and turn it to CHECKSUM_NONE.
But this wouldn't solve all possible setups: there can be scenarios
where the NIC is configured with NETIF_F_SCTP_CRC set and NETIF_F_CSUM_HW
cleared (it's evil, but possible). In this situation, non-GSO SCTP packets
having CHECKSUM_PARTIAL will be systematically corrupted when they are
processed by validate_xmit_skb().

On Thu, 2017-02-02 at 10:08 -0800, Tom Herbert wrote:

> 
> - Add a description of the new bit and how skb_checksum_help can work
> to the comments for CHECKSUM_PARTIAL in skbuff.h

Done.

> 
> - Add FCOE to the list of protocol that can set CHECKSUM_UNNECESSARY
> for a CRC/csum

Done.

> 
> - Add a note to CHECKSUM_COMPLETE section that it can only refer to an
> Internet checksum

Done.

/* references + notes */

[1] ... this recalls to latest comment from David Laight:
On Thu, 2017-02-02 at 16:55 +0000, David Laight wrote:
> 
> I have to admit to not knowing exactly what the CHECKSUM_xxx flags
> actually mean. I have a good idea about what the intention is though.

According to domumentation, CHECKSUM_COMPLETE and CHECKSUM_UNNECESSARY are
not used for SCTP (nor in the TX path at all); nevertheless, IPVS snat/dnat
actually set CHECKSUM_UNNECESSARY on SCTP packets after the checksum is
updated (see 97203abe6bc4 "net: ipvs: sctp: do not recalc...).

I'm not sure if setting CHECKSUM_UNNECESSARY fits my case, because this would
implicitly skip RX validation when using devices like veth or loopback.

[2] Documentation/networking/checksum_offloads.txt

regards,
