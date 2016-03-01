From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] IPv6: Use a 16 bit length field when computing a
 IPv6 UDP checksum
Date: Tue, 1 Mar 2016 13:19:28 -0800
Message-ID: <CAKgT0Ue-OGtHy4=f7mYRxLntgj1rgGpyD2ZojvULY_7EXykhKA@mail.gmail.com>
References: <20160226025738.16760.41163.stgit@localhost.localdomain>
	<20160301.150902.257372984527759080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Duyck <aduyck@mirantis.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:35450 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbcCAVT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 16:19:29 -0500
Received: by mail-ig0-f169.google.com with SMTP id hb3so27811678igb.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 13:19:28 -0800 (PST)
In-Reply-To: <20160301.150902.257372984527759080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 12:09 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <aduyck@mirantis.com>
> Date: Thu, 25 Feb 2016 19:10:59 -0800
>
>> This change makes it so that we only use a 16 bit length field instead of a
>> 32 bit length field when computing a UDP checksum for IPv6.
>>
>> This fixes an issue found with UDP tunnels over IPv6 where the total size
>> exceeded 65536 for a frame that was to be segmented.  As a result the
>> checksum being computed didn't match the frame data so we ended up being
>> off by 1 for the final checksum value since we didn't cancel out the upper
>> 16 bits of the length.
>>
>> The reasoning behind this is that RFC2460 states that for protocols such as
>> UDP that carry their own length field we should use that when computing the
>> checksum for the pseudo-header.  As such we should be using a 16 bit value,
>> not a 32 bit as is currently occurring when computing the UDP checksum for
>> IPv6.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>
> What a can of worms. :-/
>
> Reading RFC2460 over a few times, indeed using the truncated 16-bit length
> is the thing to do for the pseudo-header checksum.
>
> We have this mistake in a few places, for example ip6_compute_pseudo()
> unconditionally uses skb->len, yet is used by UDP on receive.
>
> Can you do a little audit and fix as many of these cases as you can find
> and wrap them all into this patch?
>
> Thanks!

So I have been thinking about it and limiting the length to 16 bits
might restrict us in terms of ipv6 jumbograms (RFC 2675), though it
doesn't appear we support them but if we ever did then we might be
painted into a bit of a corner.  At the same time it isn't as if the
frames are exactly valid anyway since we have exceeded the 64K limit
without really taking any approach to resolve it as defined in RFC
2675.  In addition we have the same issue for IPv4 which isn't even
supposed to support frames larger than 64K.

I was wondering what your thoughts would be about widening the size of
the length field that we pass into csum_tcpudp_magic from a 16 bit to
a 24 or 32 bit value?  The general idea would be to shift tunnels over
to uniformly using skb->len instead of a mix of 16 bit or 32 bit
lengths.  My thought is it might add a bit of security since it would
invalidate the outer header checksum for the case where length has
exceeded 65535 resulting in uh->len field being invalid anyway.

- Alex
