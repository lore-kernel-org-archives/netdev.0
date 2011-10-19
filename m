From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:25:38 +0200
Message-ID: <1319030738.4424.39.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4) <1319029101.4424.36.camel@jlt3.sipsolutions.net>
	 <1319030503.8416.11.camel@edumazet-laptop>
	 (sfid-20111019_152225_494986_6CAEF901)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34141 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab1JSNZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:25:43 -0400
In-Reply-To: <1319030503.8416.11.camel@edumazet-laptop> (sfid-20111019_152225_494986_6CAEF901)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 15:21 +0200, Eric Dumazet wrote:

> > Not disputing this either. But you said sk_refcnt can be 0, so why can't
> > the following happen:
> > 
> > /* skb; skb->sk = sk; skb->destructor = sock_wfree; */
> > 
> > /* skb is on qdisc, some time passes */
> > 
> > sk_free(sk); /* user closed socket,
> >                 sk->sk_refcnt reaches 0,
> > 		sk->sk_wmem_alloc == skb->truesize,
> > 		__sk_free not called, socket still lives,
> > 		but no more +1 in sk_wmem_alloc */
> > 
> > /* some more time passes */
> > 
> > /* ethernet hard_start_xmit calls skb_clone_tx_timestamp() */
> > skb2 = skb_clone(skb);
> > skb2->sk = skb->sk;
> > sock_hold(skb->sk);
> > 
> > /* ethernet TX completion calls skb_free(skb) */
> > skb_free(skb):
> >   sock_wfree(skb); /* sk_wmem_alloc reaches 0,
> >                       __sk_free called DESPITE sk_refcnt > 0 */
> > 
> > /* later, in skb_complete_tx_timestamp() */
> > sock_put(sk);	/* KABOOM */
> > 
> > 
> > I just want to understand why this can't happen :-)
> 
> Since you answer your own question :)

Did I?

> Hmm, oh well, sk_refcnt is/should not be changed if a xmit packet is
> duped, but sk_wmem_alloc should be, exactly paired with skb->truesize

Well, yeah, ok, but Richard's patches do modify sk_refcnt, and can't
modify sk_wmem_alloc as discussed upthread.

I'll admit that I don't really trust the whole thing anyway -- it seems
rather error prone to forbid you from doing sock_hold() on a socket you
obtained from a TX packet.

johannes
