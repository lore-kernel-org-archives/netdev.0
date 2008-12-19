From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Fri, 19 Dec 2008 16:46:44 +0300
Message-ID: <20081219134644.GA30788@ms2.inr.ac.ru>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217221637.GA27811@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:53034 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753211AbYLSNrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 08:47:14 -0500
Content-Disposition: inline
In-Reply-To: <20081217221637.GA27811@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Indeed they do have more quirks.  I only saw it after reading it
> again, but they always use snd_nxt instead of the current sequence
> number:

Their snd_nxt and our snd_nxt are different things.
Analog of our snd_nxt used to be called snd_max.

BSD snd_nxt points to current transmission head,
which is rewinded to snd_una when it starts to retransmit.


> 	if (SEQ_GT(tp->snd_up, tp->snd_nxt)) {
> 		u_int32_t urp = tp->snd_up - tp->snd_nxt;
> 		if (urp > IP_MAXPACKET)
> 			urp = IP_MAXPACKET;
> 		th->th_urp = htons((u_int16_t)urp);
> 		th->th_flags |= TH_URG;

Obviously, somewhere around this place they do th->th_seq = tp->snd_nxt.


BTW, that line of code which I sent was logically (not practically) wrong,
Dave spotted this instantly. :-) Logically correct way would be
to check against future snd_nxt which will be advanced
after the packet is submitted. Practically, it does not matter,
the difference is only for jumbo frames, which are inhibited
for tcp.

Alexey
