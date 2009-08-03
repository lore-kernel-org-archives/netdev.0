From: Matt Mackall <mpm@selenic.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Mon, 03 Aug 2009 14:59:41 -0500
Message-ID: <1249329581.3703.122.camel@calx>
References: <20090729073523.GA4515@gondor.apana.org.au>
	 <20090802.130704.133993421.davem@davemloft.net>
	 <1249301157.2893.11.camel@achroite>
	 <20090803.121512.75779533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, mcarlson@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:52519 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755117AbZHCUAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2009 16:00:11 -0400
In-Reply-To: <20090803.121512.75779533.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-03 at 12:15 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 03 Aug 2009 13:05:57 +0100
> 
> > On Sun, 2009-08-02 at 13:07 -0700, David Miller wrote:
> >> My position has always been that such printk's are simply
> >> not allowed.  (check archives if you don't believe me :-)
> >>
> >> The locking is going to get rediculious if we start having
> >> to account for this.
> > 
> > I agree with that, but this does seem quite restrictive.  How can we be
> > sure that none of the kernel functions used by a driver's TX path (e.g.
> > kmalloc or DMA-mapping) will print debug or warning messages?  If such
> > guarantees exist, they do not seem to be documented.
> 
> Indeed, that's a good counter-argument.
> 
> Ho hum... so someone show me how ugly the locking is going
> to get :-)

First, I don't think we can solve the problem of 'reliably deliver
printks inside the TX path'. If the driver needs to printk here, odds
are good that sending isn't possible.

So I think we should be clear up front that the solution we're looking
for is 'don't crash the box when trying to printk from the tx path'.

I think the most straightforward, driver-agnostic way to do this
is to have netpoll wrap a driver's TX entrypoint such that recursion is
disabled while in that path. This might actually simplify netpoll's
internal locking ugliness. Something like:

int netpoll_xmit_wrapper(struct sk_buff *skb, struct net_device *dev)
{
	struct netpoll_info *npinfo = dev->npinfo;
	int ret;

	npinfo->recurse += 1; /* add appropriate locking */
	ret = npinfo->orig_tx(skb, dev);
	npinfo->recurse -= 1;
	
	return ret;
}

-- 
http://selenic.com : development and support for Mercurial and Linux


