From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 22:28:26 +0200
Message-ID: <20060807202826.GC10909@edgar.underground.se.axis.com>
References: <20060807152126.GL24653@edgar.underground.se.axis.com> <1154965249.5446.15.camel@jzny2> <20060807155929.GM24653@edgar.underground.se.axis.com> <1154968319.5446.30.camel@jzny2> <20060807170403.GA10818@edgar.underground.se.axis.com> <1154973625.5446.56.camel@jzny2> <20060807184748.GA10909@edgar.underground.se.axis.com> <1154977413.5446.83.camel@jzny2> <20060807191413.GB10909@edgar.underground.se.axis.com> <1154979270.5446.97.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:55974 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP
	id S1751050AbWHGU23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 16:28:29 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k77KSQP0006445
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 22:28:26 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154979270.5446.97.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 03:34:30PM -0400, jamal wrote:
> On Mon, 2006-07-08 at 21:14 +0200, Edgar E. Iglesias wrote:
> 
> > > If yes, what is the likelihood they will sit there forever? I think
> > > perhaps some TX interupts will happen, no?
> > 
> > with jamal undefined, absolutely. With jamal defined, TX interrupts will come
> > but I couldnt find a way into e1000_prune_tx_ring unless fdesc met the 
> > conditions. Correct? 
> > 
> 
> Forgive me since i am still missing something ..
> 
> Observe that the same threshold used in two different ways:
> 
> 1) in tx path tx_ring->prunet is to check on when we should _start_ to
> prune.
> 2) on rx path tx_ring->prunet is to check when to _stop_ pruning.
> 

I can see two calls to e1000_prune_tx_ring with jamal _defined_.

1. tx path
+#ifdef jamal
+       {
+               int fdesc = E1000_DESC_UNUSED(tx_ring);
+               if (unlikely(fdesc < tx_ring->waket))
+                       e1000_prune_tx_ring(adapter,tx_ring);
+       }
+#endif

2. tx and rx path
+#ifdef jamal
+       spin_lock(&tx_ring->tx_lock);
+       {
+               int fdesc = E1000_DESC_UNUSED(tx_ring);
+               if (fdesc < tx_ring->prunet) {
+                       if (e1000_prune_tx_ring(adapter,tx_ring))
+                               cleaned = TRUE;
                }
        }
+       spin_unlock(&tx_ring->tx_lock);
+#else
+       if (e1000_prune_tx_ring(adapter,tx_ring))
+               cleaned = TRUE;
+#endif

Assume a ring of 64 entries, prunet of 16, waket of 8. Now host sends 40 skbs
and stops. tx-ring holds 40 skbs, has 24 free. TX interrupts hit you, you may
even be receiveing packets but I don't see how you enter prune_tx_ring without
more packets going out via hard_start_xmit? skb's will sit on the ring until 
more packets are sent from the quiet host.

As you can see, with jamal _undefined_ e1000_prune_tx_ring is called
unconditionally and I beleive things will work ok.

I am not familiar with this code nor the hw so I'm probably missing something
fundamental. 

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
