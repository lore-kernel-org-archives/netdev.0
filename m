From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 12:51:09 +0300
Message-ID: <20070221095109.GA308@2ka.mipt.ru>
References: <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com> <f2b55d220702201209m6d6a276fj75f3462cdf6daeb@mail.gmail.com> <20070221085608.GC1903@2ka.mipt.ru> <20070221.013440.39157749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: medwards.linux@gmail.com, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39538 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161156AbXBUJwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 04:52:09 -0500
Content-Disposition: inline
In-Reply-To: <20070221.013440.39157749.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 21, 2007 at 01:34:40AM -0800, David Miller (davem@davemloft.net) wrote:
> > I repeat again - add your salt into jenkins hash and I will show you
> > that it has the same problems.
> > So, I'm waiting for your patch for jhash_*_words().
> 
> The problem is that whilst XOR, with arbitrary random input
> seed, can be forced to use choosen hash chains easily, with
> jenkins this is not the case.
> 
> The reason is that, due to jenkin's sophisticated mixing, each
> random input produces unique "pattern" of hash chains even for
> the most carefully crafted inputs.
> 
> It is not trivial to target matching hash chains even with known
> input seed, and it is impossible with unknown seed such as that
> which we use in routing cache.

Routing cache is safe in that regard, that found problem seems to only
affect the case, when $c parameter is specially crafted - at least I
can not reproduce distribution problem with first two parameters
changed.

But having different initial value, i.e. 
hash(const, const, random_from_attacker, random_per_boot) instead of 
hash(const, const, random_from_attacker, 0) ends up in the same problem.
Attacker will not know which chain is selected, but changing that
parameter will only change chain position, but distribution will be 
still broken.

> I do not talk about distribution characteristics here, only about
> attackability.

It _seems_ (no full analysis) that problem is in the nature of jenkins 
hash - no matter how $initval is selected, its third parameter should 
_not_ be changed to data controlled by attacker, otherwise result is 
reproduced pretty easy.

Linux route cache does not change $c (third parameter), and it _seems_
that distribution for the random $a and $b is fair, while when $c is
formed over attacker's data, random per-boot $initval does not help.

In that regard jhash_2/1words() are only safe - they have $c as zero,
jhash_3words() with attackers $c and random per-boot $initval is
trivially attackable.

-- 
	Evgeniy Polyakov
