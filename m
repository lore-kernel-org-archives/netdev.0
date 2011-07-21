From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 15:17:50 -0700 (PDT)
Message-ID: <20110721.151750.995903739612693126.davem@davemloft.net>
References: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E2781A2.8020905@gont.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, security@kernel.org, eugeneteo@kernel.sg,
	netdev@vger.kernel.org, mpm@selenic.com
To: fernando@gont.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab1GUWSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 18:18:38 -0400
In-Reply-To: <4E2781A2.8020905@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fernando Gont <fernando@gont.com.ar>
Date: Wed, 20 Jul 2011 22:32:18 -0300

> Does it make sense to go in this direction rather than simply randomize
> the IPv6 Fragment Identification?

We could, but that's actually a bit more work.

You have to avoid recycling IDs to the same destination host otherwise
a retransmit could use the same ID and overlap with a previous set of
frags, causing corruption.

This means if you go the "pure random" route, you have to make sure
that the 32-bit series produced by the random number generator is
maximally long.  This is why openbsd uses an ID generator based upon
skip32 etc.

And I cannot say that about our RNG infrastructure.

Also, 32-bits seems like a lot, but on a 40Gb link we can exhaust this
space in ~20 minutes (1554 byte packet over standard ethernet MTU at
40Gbit is ~3454767 ipv6 frag IDs per second).  So while maybe not a
serious issue right now, we seem to go up by a factor of 10 every few
years, therefore at ~400Gb it's down to 2 minutes.

So we have to look at it like a constrained resource, and therefore
doing it on a per-destination basis like ipv4 makes a lot of sense.

I think Eric's work is the way forward and I'll be applying his patches.
