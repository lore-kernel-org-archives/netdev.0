From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] IPv6: Use a 16 bit length field when computing a
 IPv6 UDP checksum
Date: Tue, 1 Mar 2016 14:26:36 -0800
Message-ID: <CAKgT0UdNJLmNqpYir0mNkS560zwc7UJU1ciiTPNU3JfoQNWB2A@mail.gmail.com>
References: <20160226025738.16760.41163.stgit@localhost.localdomain>
	<20160301.150902.257372984527759080.davem@davemloft.net>
	<CAKgT0Ue-OGtHy4=f7mYRxLntgj1rgGpyD2ZojvULY_7EXykhKA@mail.gmail.com>
	<20160301.163544.1175023538158578123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Duyck <aduyck@mirantis.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36414 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcCAW0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:26:37 -0500
Received: by mail-io0-f176.google.com with SMTP id l127so239556072iof.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 14:26:36 -0800 (PST)
In-Reply-To: <20160301.163544.1175023538158578123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 1:35 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Tue, 1 Mar 2016 13:19:28 -0800
>
>> I was wondering what your thoughts would be about widening the size of
>> the length field that we pass into csum_tcpudp_magic from a 16 bit to
>> a 24 or 32 bit value?  The general idea would be to shift tunnels over
>> to uniformly using skb->len instead of a mix of 16 bit or 32 bit
>> lengths.  My thought is it might add a bit of security since it would
>> invalidate the outer header checksum for the case where length has
>> exceeded 65535 resulting in uh->len field being invalid anyway.
>
> Hmmm, but wait, what is uh->len supposed to be for an ipv6 jumbogram
> anyways?

In a true UDP jumbogram the value for uh->len and ipv6->paylen should
be 0 and the length should be derived based on the actual payload
length which is placed in an IPv6 hop-by-hop extension header with a
jumbo payload option present since paylen is only a 16 bit field in
the IPv6 header.

> It just gets truncated and the the ipv6 header payload length field
> trumps whatever is in the UDP header length field right?

Right.  The RFC 2675 says the value for uh->len should be set to 0 and
instead the total payload length should be used.

> If that's what happens then we should uniformly use the truncated
> length for the pseudo-header calculations as you originally suggested.
>
> How UDP jumbograms as supposed to be handled wrt. udp_hdr->len should
> guide our implementation.

That is kind of what I was thinking.  The only problem is I also have
to sort out IPv4 and IPv6 and hopefully do so in such a way that I
don't end up having to impact the drivers too much.  That is why I was
wondering if we could look at widening out the approach so that it
could be applied to IPv4 as well as IPv6.

One other thought I am having is that maybe I should take a look at
the true scope of this.  For example I know Windows allows for doing
TSO with frames larger than 64K.  Should we maybe start looking at
supporting something like that as well for GRO/GSO?

- Alex
