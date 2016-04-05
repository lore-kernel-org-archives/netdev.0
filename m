From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Mon, 4 Apr 2016 21:26:55 -0700
Message-ID: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
	<20160404162818.14332.1076.stgit@localhost.localdomain>
	<20160405034437.GA9322@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33993 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbcDEE04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 00:26:56 -0400
Received: by mail-ig0-f170.google.com with SMTP id gy3so55754350igb.1
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 21:26:56 -0700 (PDT)
In-Reply-To: <20160405034437.GA9322@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 4, 2016 at 8:44 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Mon, Apr 04, 2016 at 09:31:21AM -0700, Alexander Duyck wrote:
>> RFC 6864 states that the IPv4 ID field MUST NOT be used for purposes other
>> than fragmentation and reassembly.  Currently we are looking at this field
>> as a way of identifying what frames can be aggregated and  which cannot for
>> GRO.  While this is valid for frames that do not have DF set, it is invalid
>> to do so if the bit is set.
>
> This justification is bogus.  GRO is a completely local optimisation
> that should have zero visibility to third parties.  So it makes no
> sense to talk about RFC compliance of GRO.  The Linux network stack
> as a whole is subject to RFC compliance, but not GRO per se.

The problem is right now we are mangling the IP ID for outer headers
on tunnels.  We end up totally ignoring the delta between the values
so if you have two flows that get interleaved over the same tunnel GRO
will currently mash the IP IDs for the two tunnels so that they end up
overlapping.

The reason why I keep referencing RFC 6864 is because it specifies
that the IP ID field must not be read if the DF bit is set, and that
if we are manipulating headers we can handle the IP ID as though we
are the transmitting station.  What this means is that if DF is not
set we have to have unique values per packet, otherwise we can ignore
the values if DF is set.

>> In the case of the non-incrementing IP ID we will end up losing the data
>> that the IP ID is fixed.  However as per RFC 6864 we should be able to
>> write any value into the IP ID when the DF bit is set so this should cause
>> minimal harm.
>
> No we should not do that, at least not by default.  GRO was designed
> to be completely lossless, that is its main advantage of the various
> forms of LRO which preceded it.

Well the problem is it isn't right now.  Instead in the case of
tunnels it allows you to generate overlapping sequences of IP IDs.

> If you lose that people will start asking it to be disabled for
> routers/bridges and we'll be back in the same old mess that we
> had with LRO.

The question I would have is what are you really losing with increment
from 0 versus fixed 0?  From what I see it is essentially just garbage
in/garbage out.

> So please do this properly and preserve the information in the packet.
> As I said earlier all it takes is one single bit, like we do with ECN.
> If you put it in the feature bit you'll also allow us to distinguish
> between TSO drivers that produce fixed IDs vs. incrementing IDs.

Actually it will take at least 2.  One for the outer headers and one
for the inner headers.  I'll also have to add tracking for each to the
GRO code so that we don't merge frames that go from a fixed ID to
incrementing one or visa-versa since I suspect that is probably
floating around out there too as my GSO partial code was going to end
up doing some of that.

- Alex
