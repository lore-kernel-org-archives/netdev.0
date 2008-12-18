From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 21:45:13 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812182040120.11995@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
 <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au>
 <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz>
 <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au>
 <20081217125505.GA8379@ms2.inr.ac.ru> <20081217153015.GA17903@ms2.inr.ac.ru>
 <20081217212907.GA27243@gondor.apana.org.au> <20081217225231.GA28052@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Petr Tesarik <ptesarik@suse.cz>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39114 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbYLRTpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 14:45:15 -0500
In-Reply-To: <20081217225231.GA28052@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2008, Herbert Xu wrote:

> On Thu, Dec 18, 2008 at 08:29:07AM +1100, Herbert Xu wrote:
> >
> > > I.e. we set URG and urg_ptr to fake scb->seq + 0xFFFF only when:
> > > 
> > > 	after(scb->seq + 0xFFFF, tp->snd_nxt)
> > > 
> > > My brains are rusty, so take this critically. :-)
> > 
> > Indeed that's a great idea!
> 
> OK, I think this is what we should do:
> 
> 1) Fix fresh transmissions of urgent mode as Alexey suggested.
> 
> This is the safest way of ensuring that the urgent notification
> is not delayed.  This is still not as "fast" as the BSD behaviour
> but it is much safer with respect to broken^H^H^H^H^H^Hlegacy
> applications.
> 
> 2) Continue to use the current test for retransmissions.
> 
> 3) Apply my original GSO patch and revert the existing URG fixes.
> 
> With Alexey's fix, the scenario that Ilpo identified would only
> occur on retransmissions.  As we disable TSO on retransmissions,
> it no longer affects my patch.

No, would you use that 0xffff hack with gso you would create even worse 
problem in case of reordering / losses. And that's just because the very 
scenario still remains fully unsolved. I'm not sure if you understood my 
scenario at all (I was hopeful that you did :-))? It's basically that 
(with the terms of this hack) some segments in a super-skb would need to 
set 0xffff while some < 0xffff. ...But you just can't send too large urg 
ptr in any segment or you're asking for trouble.

Also, I think even without gso but with reordering / enough losses will 
make it possible that not-yet-sent condition of Alexey's proposal (it's 
techically not-yet-received) will no longer hold from _the receiver's_ 
point of view and havoc breaks loose.


-- 
 i.
