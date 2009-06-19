From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Fri, 19 Jun 2009 13:07:19 +0930
Message-ID: <200906191307.20360.rusty@rustcorp.com.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906181647.51045.rusty@rustcorp.com.au> <20090618073422.GA4087@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50523 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205AbZFSDhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 23:37:24 -0400
In-Reply-To: <20090618073422.GA4087@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Jun 2009 05:04:22 pm Herbert Xu wrote:
> On Thu, Jun 18, 2009 at 04:47:50PM +0930, Rusty Russell wrote:
> > Summary: we still have about 54 in-tree drivers which actually use
> > NETDEV_TX_BUSY for normal paths.  Can I fix it now?
>
> You can fix it but I don't quite understand your results below :)

You didn't comment on my patch which tried to fix NETDEV_TX_BUSY tho?

> > sungem.c: Y, N
>
> This driver does the bug check in addition to a race check that
> should simply drop the packet instead of queueing.  In fact chances
> are the race check is unnecessary anyway.

OK, "N" means "can be simply replaced with kfree_skb(skb); return 
NETDEV_TX_OK;".  "Y" means "driver will break if we do that, needs rewriting".
I didn't grade how hard or easy the rewrite would be, but later on I got more 
picky (I would have said this is N, N: the race can be replaced with a drop).

> > fs_enet: N
>
> This is either just a bug check or the driver is broken in that
> it should stop the queue when the said condition can be true.
>
> > mace.c: N
>
> Just a bug check.

Err, that's why they're N (ie. does not need TX_BUSY).

> > sh_eth.c: Y
>
> This driver should check the queue after transmitting, just like
> virtio-net :)
>
> So from a totally non-representative sample of 4, my conclusion
> is that none of them need TX_BUSY.  Do you have an example that
> really needs it?

First you asserted "Most of them just do this:... /* Never happens */".  Now 
I've found ~50 drivers which don't do that, it's "Do any of them really need 
it?".

So, now I'll look at that.  Some are just buggy (I'll send patches for those).  
Most I just have no idea what they're doing; they're pretty ugly.  These ones 
are interesting:

e1000/e1000_main.c: fifo bug workaround?
ehea/ehea_main.c: ?
starfire.c: "we may not have enough slots even when it seems we do."?
tg3.c: tg3_gso_bug

ISTR at least one driver claimed practice showed it was better to return 
TX_BUSY, and one insisted it wouldn't wasn't going to waste MAX_FRAGS on the 
stop-early scheme.

> Anyway, I don't think we should reshape our APIs based on how
> broken the existing users are.

We provided an API, people used it.  Constantly trying to disclaim our 
responsibility for the resulting mess makes me fucking ANGRY.

We either remove the API, or fix it.  I think fixing it is better, because my 
driver will be simpler and it's obvious noone wants to rewrite 50 drivers and 
break several of them.

I don't know how many times I can say the same thing...
Rusty.
