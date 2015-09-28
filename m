From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH] Fix false positives in can_checksum_protocol()
Date: Mon, 28 Sep 2015 12:37:23 -0700
Message-ID: <CALx6S354aBCxosvvBFUFSparq981rPf-vAunwdKtUKZLNBxFmQ@mail.gmail.com>
References: <1443185758.4674.44.camel@infradead.org>
	<CALx6S34Bs8pOyGXEOvABdG16wyWZuhsg5G4sO_vJgCnz0xxi5A@mail.gmail.com>
	<1443464822.4674.109.camel@infradead.org>
	<CALx6S35VXGfCeYtXm9z2APgt=kAwR2qJ5v7psN+Pg17LcDKasw@mail.gmail.com>
	<1443468381.4674.115.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:33175 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbbI1ThY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 15:37:24 -0400
Received: by igbkq10 with SMTP id kq10so63919704igb.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 12:37:23 -0700 (PDT)
In-Reply-To: <1443468381.4674.115.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 12:26 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Mon, 2015-09-28 at 12:13 -0700, Tom Herbert wrote:
>>
>> > Perhaps a better solution would be a bit in the skbuff which indicates
>> > that it *is* a TCP or UDP checksum. That would be set by our UDP and
>> > TCP sockets, cleared by encapsulation, also set if appropriate by
>> > skb_partial_csum_set().
>> >
>> Yes I agree. What I have been thinking to do is steal two bits from
>> csum_offset that would indicate that the checksum is IPv4 or IPv6
>> (specifically that the checksum value is seeded with an IPv4 or IPv6
>> pseudo header). This information plus the csum_offset would be
>> sufficient for drivers to identify the checksum as UDP/TCP-IPv4/IPv6.
>
>> The other case that needs special handling is inner vs. outer
>> checksum, but that can be deduced by comparing (inner of outer)
>> transport offset to checksum start. With this and a couple of utility
>> functions we should be able to start deprecating NETIF_F_IP_CSUM and
>> NETIF_F_IPV6_CSUM.
>
> You mean drivers which currently set NETIF_F_IP_CSUM would need to
> provide a .ndo_features_check() which tolerates only the packets they
> can actually handle? And we'd just ensure that the bits are there for
> them to use, in the skbuff? That seems reasonable.
>
I think it's easier to just call skb_checksum_help from the driver
when the packet is actually sent to the device (should be no cost for
late binding).

> Note that 'seeded with an IPv[46] pseudo header' isn't quite
> sufficient. Some hardware like 8139cp is explicitly told to do a UDP or
> a TCP checksum with a bit in the descriptor, so any UDP-like or TCP
> -like checksum works out fine.
>
UDP or TCP can be determined from csum_offset, e.g. 16=>TCP 6=>UDP

> Other hardware works out whether to do a UDP or a TCP checksum for
> *itself*, so it *can't* cope with other protocols which just happen to
> look the same. For those it really *must* be IPPROTO_TCP or IPPROTO_UDP
> and they're going to be looking in the IP header for it.
>
In those cases driver can just look into the packet to determine the protocol.

> I do suspect we'll want a bit which says it's *actually* TCP or UDP,
> not just 'seeded with a pseudo-header'. That's the important
> distinction for NETIF_F_IP_CSUM vs. NETIF_F_HW_CSUM.
>
> --
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
>
