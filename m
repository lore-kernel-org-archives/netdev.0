From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 8 Aug 2006 19:21:08 -0400
Message-ID: <20060808232108.GA16059@kvack.org>
References: <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <20060808170432.GD27383@kvack.org> <20060808.150607.10247901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, mchan@broadcom.com,
	herbert@gondor.apana.org.au, hadi@cyberus.ca,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:13770 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S965071AbWHHXVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 19:21:22 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.150607.10247901.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 03:06:07PM -0700, David Miller wrote:
> The driver ->hard_start_xmit() method is invoked with the queue
> unlocked, so this kind of scheme would not be workable.

Looking at e1000, NETIF_F_LLTX is a waste -- the driver takes a spinlock 
almost immediately after entering.  Taking the spinlock higher up in the 
network stack, preferably for multiple packets, would at least let the 
CPU deal with things sooner.  tg3 doesn't use LLTX and thus holds the lock 
over hard_start_xmit().  bonding is atrocious and uses a read lock and unlock 
in many of the xmit routines.  The only true lockless tx seems to be 
loopback.

> While the queue is unlocked, another cpu could empty entries in the
> TX queue making it not-full, which invalidates this "queue is now
> full" return value the driver just gave.
> 
> We don't do things the way we do it now for fun, it's just the most
> reasonable scheme we've come up with given the locking constraints.

Given that the vast majority of drivers are locked during their xmit 
routine, it is probably worth implementing at some point.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
