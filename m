From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Sat, 20 Dec 2008 06:59:54 +1100
Message-ID: <20081219195954.GA11899@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217221637.GA27811@gondor.apana.org.au> <20081219134644.GA30788@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54095 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752426AbYLSUAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 15:00:18 -0500
Content-Disposition: inline
In-Reply-To: <20081219134644.GA30788@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2008 at 04:46:44PM +0300, Alexey Kuznetsov wrote:
>
> BSD snd_nxt points to current transmission head,
> which is rewinded to snd_una when it starts to retransmit.

Right, but it would seem that it's broken for sack retransmits
at least.  This is from NetBSD but the others are similar:

	/*
	 * If we are doing retransmissions, then snd_nxt will
	 * not reflect the first unsent octet.  For ACK only
	 * packets, we do not want the sequence number of the
	 * retransmitted packet, we want the sequence number
	 * of the next unsent octet.  So, if there is no data
	 * (and no SYN or FIN), use snd_max instead of snd_nxt
	 * when filling in ti_seq.  But if we are in persist
	 * state, snd_max might reflect one byte beyond the
	 * right edge of the window, so use snd_nxt in that
	 * case, since we know we aren't doing a retransmission.
	 * (retransmit and persist are mutually exclusive...)
	 */
	if (TCP_SACK_ENABLED(tp) && sack_rxmit) {
		th->th_seq = htonl(p->rxmit);
		p->rxmit += len;
	} else {
		if (len || (flags & (TH_SYN|TH_FIN)) ||
		    TCP_TIMER_ISARMED(tp, TCPT_PERSIST))
			th->th_seq = htonl(tp->snd_nxt);
		else
			th->th_seq = htonl(tp->snd_max);
	}
 
> BTW, that line of code which I sent was logically (not practically) wrong,
> Dave spotted this instantly. :-) Logically correct way would be
> to check against future snd_nxt which will be advanced
> after the packet is submitted. Practically, it does not matter,
> the difference is only for jumbo frames, which are inhibited
> for tcp.

Actually I think the unadvanced snd_nxt makes sense too.  What we're
asking there is has the urgent data been transmitted before, i.e.,
is the current skb a retransmit (since we've already established
that the urgent pointer is forward of the current packet).

Yes this would be broken if we ever do jumbo frames, but it'd
be broken for the same reason that the current test'd be brokens,
that is, we need to split the packet in urgent mode.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
