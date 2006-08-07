From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 18:29:15 +0200
Message-ID: <20060807162915.GN24653@edgar.underground.se.axis.com>
References: <1154819868.5517.34.camel@jzny2> <20060805231959.GA25768@gondor.apana.org.au> <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <1154867083.6269.35.camel@jzny2> <1154867589.6269.40.camel@jzny2> <4807377b0608061616p5731524fvb0612bdbc32e59b@mail.gmail.com> <1154955036.5246.32.camel@jzny2> <20060807152126.GL24653@edgar.underground.se.axis.com> <1154965249.5446.15.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:29099 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932208AbWHGQ3R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 12:29:17 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k77GTFP0006373
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 18:29:15 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154965249.5446.15.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 11:40:49AM -0400, jamal wrote:
> 
> On Mon, 2006-07-08 at 17:21 +0200, Edgar E. Iglesias wrote:
> [..]
> > I have a question regarding your patch. In clean_tx_irq, it seems you dont
> > clean the ring unless fdesc < tx_ring->prunet. Won't this cause deadlocks for
> > local TCP connections if transmit goes quiet?
> > 
> 
> I have not tested the TCP case; however, note that the specific part you
> reference is commented out. There are no deadlock issues in the case of
> forwarding (as in my testcases). 
> 
> I did not quiet follow the ensuing discussion after your post:
> These descriptors being pruned in the tx path happen only after the
> packets have been sent out on the wire. Why would this contribute to a
> deadlock but not when it happens on the receive path? It is true that
> tcp retransmit queue will still be referencing the skbs, but why is it
> any different because in one case it happens in the tx and in the other
> on the receive? Is there dependency on waking up the queue?
> 

Hi again Jamal,

Not sure if it is doable, but to I'll post the thoughts anyway.

Assuming you would get the code inside the jamal ifdefs working without
deadlocks, you now have a tx_irq function which if fdesc >= tx_ring->prunet
essentially just checks for hw lockups. Let's speculate and further assume you
could do the detect_tx_hung from some other context (timer or whatever) then
you end up having a tx_irq function which most of the time does nothing.

The next step could be to move the fdesc >= tx_ring->prunet logic into the
transmit path and completely disable the tx_irq when the condition is not met.

Now you end up not taking the irq at all as long as fdesc >= tx_ring->prunet.

This was the logic I tried on the cris driver but ended up with deadlocks :)

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
