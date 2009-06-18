From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Thu, 18 Jun 2009 15:34:22 +0800
Message-ID: <20090618073422.GA4087@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906132200.38034.rusty@rustcorp.com.au> <20090614064528.GA29130@gondor.apana.org.au> <200906181647.51045.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42794 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752751AbZFRHeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:34:22 -0400
Content-Disposition: inline
In-Reply-To: <200906181647.51045.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2009 at 04:47:50PM +0930, Rusty Russell wrote:
> 
> One question: can netif_queue_stopped() ever be true inside start_xmit?  Some 
> drivers test that, like sun3lance.c.

The driver should never test that because even if it is true
due to driver shutdown the xmit function should ignore it as
the upper layer will wait for it anyway.

> Summary: we still have about 54 in-tree drivers which actually use 
> NETDEV_TX_BUSY for normal paths.  Can I fix it now?

You can fix it but I don't quite understand your results below :)

> sungem.c: Y, N

This driver does the bug check in addition to a race check that
should simply drop the packet instead of queueing.  In fact chances
are the race check is unnecessary anyway.

> fs_enet: N

This is either just a bug check or the driver is broken in that
it should stop the queue when the said condition can be true.

> mace.c: N

Just a bug check.

> sh_eth.c: Y

This driver should check the queue after transmitting, just like
virtio-net :)

So from a totally non-representative sample of 4, my conclusion
is that none of them need TX_BUSY.  Do you have an example that
really needs it?

Anyway, I don't think we should reshape our APIs based on how
broken the existing users are.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
