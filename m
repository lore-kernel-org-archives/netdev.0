From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 6 Apr 2016 10:53:52 -0300
Message-ID: <CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
References: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	<20160405043209.GA9822@gondor.apana.org.au>
	<5703D4C5.9060305@solarflare.com>
	<20160405.194517.431351466693438399.davem@davemloft.net>
	<5704F156.8030804@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37227 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbcDFNxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 09:53:54 -0400
Received: by mail-ig0-f171.google.com with SMTP id g8so42552468igr.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 06:53:53 -0700 (PDT)
In-Reply-To: <5704F156.8030804@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 8:21 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 06/04/16 00:45, David Miller wrote:
>> From: Edward Cree <ecree@solarflare.com>
>> Date: Tue, 5 Apr 2016 16:07:49 +0100
>>
>>> On the gripping hand, I feel like GRO+TSO is the wrong model for
>>> speeding up forwarding/routing workloads.  Instead we should be
>>> looking into having lists of SKBs traverse the stack together,
>>> splitting the list whenever e.g. the destination changes.
>> "Destination" is a very complicated beast.  It's not just a
>> destination IP address.
>>
>> It's not even just a full saddr/daddr/TOS triplet.
>>
>> Packets can be forwarded around based upon any key whatsoever in the
>> headers.  Netfilter can mangle them based upon arbitrary bits in the
>> packet, as can the packet scheduler classifier actions.
>>
>> It's therefore not profitable to try this at all, it's completely
>> pointless unless all the keys match up exactly.
> Possibly I wasn't completely clear (or maybe I was and I'm just
> wrong...), but I meant that _each layer_ in the stack would split the
> list whenever it wants to treat two packets differently.  Whether
> that's a protocol receive handler, or a netfilter or tc operation.
>
> Obviously if you want to decide at the _beginning_ whether "all the
> keys match", then you do essentially need GRO's flow-matching logic.
> But even then, I find myself wondering if having GRO coalesce the
> segments into a superpacket is really better than having it just make
> lists of segments, and have that list traverse the stack as a single
> entity.  That way lossless resegmentation remains easy.  But I suppose
> that could make life difficult for things like BPF, if they want to
> act upon the superframe (because we haven't built it).  If instead
> they act on each of the segments, we might get different actions for
> each segment and that might also be awkward; so you'd still need this
> concept of 'any layer in the stack can decide to split lists up'.
>
But again, this scheme is optimizing for forwarding case and doesn't
help (and probably hurts) the use case of locally terminated
connections which I would claim is more important. Packets that are
forwarded really should not be GRO'ed in the first place because of
the loss of information and added latency. The difficultly is that we
don't currently make the forwarding decision before GRO,  if we can
change this to decide whether packets are to be forwarded earlier then
we can avoid doing GRO for those.

Tom

> -Ed
