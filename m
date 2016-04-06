From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Wed, 06 Apr 2016 08:39:18 -0700
Message-ID: <1459957158.6473.363.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	 <20160405043209.GA9822@gondor.apana.org.au>
	 <5703D4C5.9060305@solarflare.com>
	 <20160405.194517.431351466693438399.davem@davemloft.net>
	 <5704F156.8030804@solarflare.com>
	 <CALx6S34Sqp7tnmkPRWH0RF_CKrBLLNWFjHbr6Uq2r=6=scMMow@mail.gmail.com>
	 <57051C79.7010303@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alex Duyck <aduyck@mirantis.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33959 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcDFPjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:39:21 -0400
Received: by mail-pa0-f42.google.com with SMTP id fe3so35495117pab.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:39:21 -0700 (PDT)
In-Reply-To: <57051C79.7010303@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-06 at 15:26 +0100, Edward Cree wrote:
> On 06/04/16 14:53, Tom Herbert wrote:
> > But again, this scheme is optimizing for forwarding case and doesn't
> > help (and probably hurts) the use case of locally terminated
> > connections
> Not really.  I think this has a chance to outperform GRO for locally
> terminated connections, for a number of reasons:
> * Doesn't look at higher-layer or inner headers until later in packet
>   processing, for instance we (maybe) process every L3 header in a NAPI poll
>   before looking at a single L4.  This could delay touching the second
>   cacheline of some packets.
> * Doesn't have to re-write headers to produce a coherent superframe.
>   Instead, each segment carries its original headers around with it.  Also
>   means we can skip _checking_ some headers to see if we're 'allowed' to
>   coalesce (e.g. TCP TS differences, and the current fun with IP IDs).
> * Can be used for protocols like UDP where the original packet boundaries
>   are important (so you can't coalesce into a superframe).
> Really the last of those was the original reason for this idea, helping with
> forwarding is just another nice bonus that we (might) get from it.
> And it's all speculative and I don't know for sure what the performance
> would be like, but I won't know until I try it!

Look at the mess of some helpers in net/core/skbuff.c, and imagine the
super mess it would be if using a concept of 'super packet with various
headers on each segment'. netfilter is already complex, it would become
a nightmare.

GRO on the other hand presents one virtual set of headers, then the
payload in one or multiple frags.
