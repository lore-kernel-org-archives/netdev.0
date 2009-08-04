From: David Miller <davem@davemloft.net>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Mon, 03 Aug 2009 21:19:05 -0700 (PDT)
Message-ID: <20090803.211905.100178246.davem@davemloft.net>
References: <1249301157.2893.11.camel@achroite>
	<20090803.121512.75779533.davem@davemloft.net>
	<1249329581.3703.122.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, mcarlson@broadcom.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37612
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751508AbZHDES4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 00:18:56 -0400
In-Reply-To: <1249329581.3703.122.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Mon, 03 Aug 2009 14:59:41 -0500

> First, I don't think we can solve the problem of 'reliably deliver
> printks inside the TX path'. If the driver needs to printk here, odds
> are good that sending isn't possible.

Agreed.

> So I think we should be clear up front that the solution we're looking
> for is 'don't crash the box when trying to printk from the tx path'.
> 
> I think the most straightforward, driver-agnostic way to do this
> is to have netpoll wrap a driver's TX entrypoint such that recursion is
> disabled while in that path. This might actually simplify netpoll's
> internal locking ugliness. Something like:
> 
> int netpoll_xmit_wrapper(struct sk_buff *skb, struct net_device *dev)
> {
> 	struct netpoll_info *npinfo = dev->npinfo;
> 	int ret;
> 
> 	npinfo->recurse += 1; /* add appropriate locking */
> 	ret = npinfo->orig_tx(skb, dev);
> 	npinfo->recurse -= 1;
> 	
> 	return ret;
> }

Looks workable.  Probably we even hold the netpoll lock here so
no additional protection would even be needed.
