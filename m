From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Tue, 4 Aug 2009 16:48:28 +1000
Message-ID: <20090804064828.GA32071@gondor.apana.org.au>
References: <1249301157.2893.11.camel@achroite> <20090803.121512.75779533.davem@davemloft.net> <1249329581.3703.122.camel@calx> <20090803.211905.100178246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, bhutchings@solarflare.com, netdev@vger.kernel.org,
	mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47665 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755005AbZHDGsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 02:48:38 -0400
Content-Disposition: inline
In-Reply-To: <20090803.211905.100178246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2009 at 09:19:05PM -0700, David Miller wrote:
>
> > So I think we should be clear up front that the solution we're looking
> > for is 'don't crash the box when trying to printk from the tx path'.
> > 
> > I think the most straightforward, driver-agnostic way to do this
> > is to have netpoll wrap a driver's TX entrypoint such that recursion is
> > disabled while in that path. This might actually simplify netpoll's
> > internal locking ugliness. Something like:
> > 
> > int netpoll_xmit_wrapper(struct sk_buff *skb, struct net_device *dev)
> > {
> > 	struct netpoll_info *npinfo = dev->npinfo;
> > 	int ret;
> > 
> > 	npinfo->recurse += 1; /* add appropriate locking */
> > 	ret = npinfo->orig_tx(skb, dev);
> > 	npinfo->recurse -= 1;
> > 	
> > 	return ret;
> > }
> 
> Looks workable.  Probably we even hold the netpoll lock here so
> no additional protection would even be needed.

Yes that should solve the xmit problem.  However, we could still
have similar issues with other parts of the driver.  For instance,
the driver may take a lock in one of the ethtool/control functions
that is also taken on either the xmit or poll path.  If you then
get a printk in the ethtool/control function then you'll be in the
same situation.

Basically anytime we're executing driver code we may be vulnerable
to a netpoll dead-lock.

So I think your suggestion should be extended to cover all entries
into the driver code, and not just the xmit function.  Perhaps
something like

#define netdev_driver_op(op, ...)				\
	({							\
		struct netpoll_info *npinfo = dev->npinfo;	\
		int ret; 					\
								\
		npinfo->recurse++;				\
		ret = op(__VA_ARGS__);				\
		npinfo->recurse--;
								\
		ret;						\
	})

This still leaves driver timers and other async driver code.  We
can add a similar marker for them but someone will have to audit
the drivers.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
