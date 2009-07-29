From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Thu, 30 Jul 2009 07:17:35 +0800
Message-ID: <20090729231735.GB14066@gondor.apana.org.au>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <1248904097.4545.2934.camel@calx> <20090729231517.GA32670@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39016 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753965AbZG2XRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 19:17:45 -0400
Content-Disposition: inline
In-Reply-To: <20090729231517.GA32670@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 07:15:17PM -0400, Neil Horman wrote:
>
> Not quite.  I agree private locking in a driver is a pain when you consider
> netpoll clients, its not the tx/tx recursion you need to worry about though, its
> shared locking between the tx and rx path that you need to be worried about.
> We should be protected against deadlock on the _xmit_lock from what we discussed
> above, but if you take a lock in the driver, then call printk, its possible that
> you'll go down the ->poll routine path in the driver.  If there you try to take
> the same private lock, the result is then deadlock.

xmit_lock suffers from exactly the same problem in ->poll.

> I was thinking that perhaps what we should do is simply not call netpoll_poll
> from within netpoll_send_skb.  That breaks the only spot that I see in which we
> call a receive code from within the tx path, breaking the deadlock possibilty.
> Perhaps instead we can call netif_rx_schedule on the network interfaces napi
> struct.  We already queue the frames and set a timer to try sending again later.
> By calling netif_rx_schedule, we move the receive work to the net_rx_action
> softirq (where it really should be).
> 
> Thoughts?

Alternatively we can modify the drivers to use try lock or other
mechanisms that do not result in a dead-lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
