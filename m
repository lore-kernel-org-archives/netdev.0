From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 09:05:17 +1000
Message-ID: <20060805230517.GA25468@gondor.apana.org.au>
References: <20060804101017.GA17393@gondor.apana.org.au> <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <1154797002.5081.21.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12808 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751416AbWHEXGQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 19:06:16 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154797002.5081.21.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 12:56:42PM -0400, jamal wrote:
>
> > > The real risk is that the transmit routine will decide it's busy, but
> > > at the same time an IRQ on another CPU will clean up the whole ring
> > > and make the queue available again. Then the transmit routine exits and
> > > says its busy, and the higher level will decide it is permanently stopped.

This is exactly the scenario where the current code can fail.  It is
also exactly the one that my patch addresses.
 
> I noticed that the e1000 in some cases returns NETDEV_TX_OK even when it
> has stopped the queue. This results in wasted calls into the qdisc.

Actually it's OK.  qdisc_restart will return after each NETDEV_TX_OK and
its caller will check netif_queue_stopped before calling it again.
 
> > If we could avoid NETDEV_TX_BUSY et al. from happening, the idea is
> > that we could eliminate all of the requeueing logic in the packet
> > scheduler layer.  It is a pipe dream from many years ago.
> 
> Still doable IMO - maybe a motivation for something to experiment with
> this long weekend. 

A precondition to eliminating it altogether is to eliminate lockless
drivers which would be a very good thing :)

In fact that reminds me, because tg3 is no longer lockless, we can do
a nicer bug fix for it than e1000 (it has the same bug).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
