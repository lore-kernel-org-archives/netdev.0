From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Fri, 26 Dec 2008 12:47:39 +1100
Message-ID: <20081226014739.GA11880@gondor.apana.org.au>
References: <20081217212907.GA27243@gondor.apana.org.au> <20081217225231.GA28052@gondor.apana.org.au> <Pine.LNX.4.64.0812182040120.11995@wrl-59.cs.helsinki.fi> <20081225.171146.208898156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru, ptesarik@suse.cz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50510 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752188AbYLZBsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 20:48:03 -0500
Content-Disposition: inline
In-Reply-To: <20081225.171146.208898156.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 25, 2008 at 05:11:46PM -0800, David Miller wrote:
>
> Hmmm, since URG is relative it means that GSO (or in-hardware TSO)
> would need to adjust the URG offset for each segment.
> 
> But if we stick this 0xffff thing there, it _can't_ do that properly
> because it cannot know where the correct URG pointer actually is.
> 
> In fact, the straightforward URG offset adjust one would expect a TSO
> engine to make would corrupt the URG pointer when we put this
> "infinity" value there.

With Alexey's proposal 0xffff is not infinity, what it is is a
position that we have not yet transmited.  The point is that due
to the way urgent mode works, the remote side will not exit urgent
mode or elide the data until it sees the actual data pointed to
by the urgent pointer.

When we do finally transmit the data pointed to by 0xffff, it'll
be accompanied with a new urgent pointer either pointing to the real
urgent data or 0xffff (which is again untransmitted).

> The URG pointer might be >= 0xffff from the initial sequence number
> of the starting TSO segment, but the URG offset might be in range
> of one of the non-initial MSS segmented frames.

It doesn't really matter if it's in range or not, the point is that
whether we point to the 0xffff point or the real urgent data, the
data at that sequence number is yet to be transmitted.  So by the
time the remote peer actually gets to that point, it would have
received an updated urgent pointer.

If you're talking about the case where we didn't set the urgent
pointer on the TSO packet, but we should set it on the final
segment generated from it, then that can't happen because we
don't do TSO on retransmissions.

Here's an example, we have a TSO packet with 1440 * 45 = 64800 bytes
of data, the MSS is 1440, let the initial sequence number be zero
Let's assume that the urgent data is at 66240.

So the TCP stack will send the TSO packet with urgent pointer set
to 65535.  The first segmented TCP packet will also have 65535 as
the urgent pointer, the one after it will have 65535 - 1440 = 64095,
etc.  The final one will have 65535 - 1440 * 44 = 2175.

The TCP stack then transmits the next packet (let's assume it's 1440
bytes long for the sake of simplicity), which has the urgent pointer
set to 66240 - 64800 = 1440.

If all these packets are delivered in order, then what'll happen
is that RCV.UP starts out at 65535, and once the final segment is
delivered it'll be updated to 66240.

If out-of-order delivery occurs and the final segment arrives earlier,
then all that'll happen is that RCV.UP will hit 66240 earlier, which
is not an issue since all subsequent urgent pointers will be less and
hence ignored.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
