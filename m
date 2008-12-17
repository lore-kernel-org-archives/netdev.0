From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 15:17:13 -0800 (PST)
Message-ID: <20081217.151713.90960645.davem@davemloft.net>
References: <20081217114138.GA20976@gondor.apana.org.au>
	<20081217125505.GA8379@ms2.inr.ac.ru>
	<20081217221637.GA27811@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751523AbYLQXRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:17:12 -0500
In-Reply-To: <20081217221637.GA27811@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Dec 2008 09:16:37 +1100

> However, for retransmissions the urgent pointer is comletely
> bogus!
> 
> Again this shows that any application that's relying on the urgent
> data to be out-of-band is just broken.  The only sane way to use
> urgent mode is as a notification.

I don't think this is a completely fair assesment, to be
honest.

Showing that the BSD guys have some half-working hacks in
this area is pretty immaterial, in the grand scheme of things.
The fact that retransmits will corrupt the URG pointer is
merely an indication of how few people use BSD and URG in
this combination of circumstances.

Nothing more.

And it also shows that our strange scheme, where we don't
signal URG until it's within the 16-bit sequence offset
limit, at least reports an accurate URG value.

Also, what if we're using IPV6 jumbo frames and we advertise this
special 0xffff URG offset turd?  That points to a real byte in the
packet, but it might not be the right one since we can only accurately
point up to 0xffff into there.

In TCP/IP Volume 2, the original BSD code is even more ignorant of
this situation, it simply sets the difference into the field as-is,
not being mindful at all of overflow:

	ti->ti_urp = htons((u_short) (tp->snd_up - tp->snd_nxt));

which probably prompted the workaround you see in the BSD code these
days.  Which, as we've seen, it buggy.

Given all of this I still think our current compromise is likely the
best one.  We never will advertise an URG pointer that is not pointing
to where the URG data will be in the sequence space.
