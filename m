From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 22:06:26 +1000
Message-ID: <20060531120626.GA11925@gondor.apana.org.au>
References: <20060531051451.GA7110@gondor.apana.org.au> <20060530.232626.00456312.davem@davemloft.net> <20060531063152.GA8032@gondor.apana.org.au> <20060531.000818.78646242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33292 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964967AbWEaMHf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 08:07:35 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060531.000818.78646242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 12:08:18AM -0700, David Miller wrote:
> 
> I understand what you're saying.  What I'm talking about is that in
> net channel drivers we might go back to IRQ disabling locks again.

OK, let's assume that the TX completion will go back into the IRQ
handler.  I contend that we can still get by with a BH-disabling
xmit_lock.  This is how it would work:

The IRQ handler would look like

	if (!spin_trylock(&dev->xmit_lock)) {
		tasklet_schedule(&priv->tx_completion_tasklet);
		return;
	}

	handle_tx_completion();
	spin_unlock(&dev->xmit_lock);

Where the TX completion tasklet would simply do

	spin_lock(&dev->xmit_lock);
	handle_tx_completion();
	spin_unlock(&dev->xmit_lock);

What do you think?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
