From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 1 Apr 2016 12:58:41 -0700
Message-ID: <CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
References: <20160401175741.13882.24175.stgit@localhost.localdomain>
	<20160401180531.13882.44793.stgit@localhost.localdomain>
	<1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160401.152405.915323132719949585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36560 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246AbcDAT6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 15:58:43 -0400
Received: by mail-io0-f175.google.com with SMTP id q128so161279108iof.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 12:58:42 -0700 (PDT)
In-Reply-To: <20160401.152405.915323132719949585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016 at 12:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 01 Apr 2016 11:49:03 -0700
>
>> For example, TCP stack tracks per socket ID generation, even if it
>> sends DF=1 frames. Damn useful for tcpdump analysis and drop
>> inference.
>
> Thanks for mentioning this, I never considered this use case.

RFC 6864 is pretty explicit about this, IPv4 ID used only for
fragmentation.  https://tools.ietf.org/html/rfc6864#section-4.1

The goal with this change is to try and keep most of the existing
behavior in tact without violating this rule?  I would think the
sequence number should give you the ability to infer a drop in the
case of TCP.  In the case of UDP tunnels we are now getting a bit more
data since we were ignoring the outer IP header ID before.

>> With your change, the resulting GRO packet would propagate the ID of
>> first frag. Most GSO/GSO engines will then provide a ID sequence,
>> which might not match original packets.

Right.  But that is only in the case where the IP IDs did not already
increment or were left uninitialized meaning the transmitter was
probably already following RFC 6864 and chose a fixed value.  Odds are
in such a case we end up improving the performance if anything as
there are plenty of legacy systems out there that still require the
IPv4 ID increment in order to get LRO/GRO.

>> I do not particularly care, but it is worth mentioning that GRO+TSO
>> would not be idempotent anymore.

In the patch I mentioned we had already broken that.  I'm basically
just going through and fixing the cases for tunnels where we were
doing the outer header wrong while at the same time relaxing the
requirements for the inner header if DF is set.  I'll probably add
some documentation do the Documentation folder about it as well.  I'm
currently in the process of writing up documentation for GSO and GSO
partial for the upcoming patchset.  I can pretty easily throw in a few
comments about GRO as well.

> Our eventual plan was to start emitting zero in the ID field for
> outgoing TCP datagrams with DF set, since the issue that caused us to
> generate incrementing IDs in the first place (buggy Microsoft SLHC
> compression) we decided is not relevant and important enough to
> accommodate any more.

For the GSO partial stuff I was probably just going to have the IP ID
on the inner headers lurch forward in chunks equal to gso_segs when we
are doing the segmentation.  I didn't want to use a fixed value just
because that would likely make it easy to identify Linux devices being
a bump in the wire.  I figure if there are already sources that
weren't updating IP ID for their segmentation offloads then if we just
take that approach odds are we will blend in with the other devices
and be more difficult to single out.

Another reason for doing it this way is that different devices are
going to have different behaviors with GSO partial.  In the case of
the i40e driver it recognizes both inner and outer network headers so
it can increment both correctly.  In the case of igb and ixgbe they
only can support the outer header so the inner IP ID value would be
lurching by gso_size every time we move from one GSO frame to the
next.

> So outside of your TCP behavior analysis case, there isn't a
> compelling argument to keeping that code around any more, rather than
> just put zero in the ID field.
>
> I suppose we could keep the counter code around and allow it to be
> enabled using a sysctl or socket option, but how strongly do you
> really feel about this?

I'm not suggesting we drop the counter code for transmit.  What RFC
6864 says is "Originating sources MAY set the IPv4 ID field of atomic
datagrams to any value."

For transmit we can leave the IP ID code as is.  For receive we should
not be snooping into the IP ID for any frames that have the DF bit set
as devices that have adopted RFC 6864 on their transmit path will end
up causing issues.

- Alex
