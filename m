From: Edward Cree <ecree@solarflare.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 6 Apr 2016 12:21:58 +0100
Message-ID: <5704F156.8030804@solarflare.com>
References: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
 <20160405043209.GA9822@gondor.apana.org.au> <5703D4C5.9060305@solarflare.com>
 <20160405.194517.431351466693438399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <alexander.duyck@gmail.com>,
	<aduyck@mirantis.com>, <tom@herbertland.com>, <jesse@kernel.org>,
	<edumazet@google.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:23492 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932356AbcDFLYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 07:24:14 -0400
In-Reply-To: <20160405.194517.431351466693438399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/16 00:45, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Tue, 5 Apr 2016 16:07:49 +0100
>
>> On the gripping hand, I feel like GRO+TSO is the wrong model for
>> speeding up forwarding/routing workloads.  Instead we should be
>> looking into having lists of SKBs traverse the stack together,
>> splitting the list whenever e.g. the destination changes.
> "Destination" is a very complicated beast.  It's not just a
> destination IP address.
>
> It's not even just a full saddr/daddr/TOS triplet.
>
> Packets can be forwarded around based upon any key whatsoever in the
> headers.  Netfilter can mangle them based upon arbitrary bits in the
> packet, as can the packet scheduler classifier actions.
>
> It's therefore not profitable to try this at all, it's completely
> pointless unless all the keys match up exactly.
Possibly I wasn't completely clear (or maybe I was and I'm just
wrong...), but I meant that _each layer_ in the stack would split the
list whenever it wants to treat two packets differently.  Whether
that's a protocol receive handler, or a netfilter or tc operation.

Obviously if you want to decide at the _beginning_ whether "all the
keys match", then you do essentially need GRO's flow-matching logic.
But even then, I find myself wondering if having GRO coalesce the
segments into a superpacket is really better than having it just make
lists of segments, and have that list traverse the stack as a single
entity.  That way lossless resegmentation remains easy.  But I suppose
that could make life difficult for things like BPF, if they want to
act upon the superframe (because we haven't built it).  If instead
they act on each of the segments, we might get different actions for
each segment and that might also be awkward; so you'd still need this
concept of 'any layer in the stack can decide to split lists up'.

-Ed
