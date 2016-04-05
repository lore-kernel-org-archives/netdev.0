From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 5 Apr 2016 18:06:46 +0100
Message-ID: <5703F0A6.5010201@solarflare.com>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
 <20160404162818.14332.1076.stgit@localhost.localdomain>
 <20160405034437.GA9322@gondor.apana.org.au>
 <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
 <20160405043209.GA9822@gondor.apana.org.au> <5703D4C5.9060305@solarflare.com>
 <CALx6S37p7sBZ_=xDpmW90-Aqs2sgnOjcjdvYJhEGZ7Y2=6+gcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:36227 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752116AbcDERG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 13:06:57 -0400
In-Reply-To: <CALx6S37p7sBZ_=xDpmW90-Aqs2sgnOjcjdvYJhEGZ7Y2=6+gcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/16 16:36, Tom Herbert wrote:
> I thought about that some. It seems like we would want to do both GRO
> and retain all the individual packets in the skb so that we could use
> those for forwarding instead of GSO as I think you're saying.
I didn't quite mean that, I meant just pass around the skb list, don't
do GRO at all.  The receiving TCP stack ends up just getting called
several times, in quick succession, without I$ loss from network stack
traversal in between.

> This
> would would work great in the plain forwarding case, but one problem
> is what to do if the host modifies the super packet (for instance when
> forwarding over a tunnel we might add encapsulation header). This
> should work in GSO (although we need to address the limitations around
> 1 encap level), not sure this is easy if we need to add a header to
> each packet in a batch.
This is indeed a problem with what I was proposing; perhaps the answer
is that as you process these SKB lists you also update something like a
GRO CB, then if you do decide to transform the packets you can coalesce
them at that point.  But doing 'the rest' of GRO might cost as much as
just transforming all the packets, in which case you only win if you want
to transform them multiple times.
And if we assume that we're going to be touching all the headers anyway,
it probably doesn't cost us much to transform all the packets in the list
since our code and data are both hot in cache.  Well, the code is cold
for the first packet in the list, but equally it's cold for the
superpacket in the current approach.

If this is as performant as GRO in the normal (non-forwarding) receive
case (and that's a *big* if, which can only be resolved by trying it), it
might make sense to just not have GRO, while TSO only gets used for
locally-generated sends, and for the case where you're forwarding between
networks with different MTUs (e.g. from a 64k VM netdevice to the wire).

What do you think?  Am I crazy?  (More than my usual?)

-Ed
