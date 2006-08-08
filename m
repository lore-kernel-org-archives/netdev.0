From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Tue, 08 Aug 2006 15:06:07 -0700 (PDT)
Message-ID: <20060808.150607.10247901.davem@davemloft.net>
References: <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	<20060804.163111.85390037.davem@davemloft.net>
	<20060808170432.GD27383@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mchan@broadcom.com,
	herbert@gondor.apana.org.au, hadi@cyberus.ca,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53401
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030308AbWHHWGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 18:06:02 -0400
To: bcrl@kvack.org
In-Reply-To: <20060808170432.GD27383@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 8 Aug 2006 13:04:32 -0400

> Maybe the way NETDEV_TX_BUSY is implemented is wrong -- that is, it should 
> be possible to return a result saying "we sent the packet, but the queue is 
> now full".  That would eliminate the atomic op that netif_queue_stop() 
> performs and allow higher layers to merge the necessary barrier on the full 
> case with the op on the tx lock.  That way we could have lockless queue 
> handling within the driver.  This might need start/stop sequence counters, 
> though.

The driver ->hard_start_xmit() method is invoked with the queue
unlocked, so this kind of scheme would not be workable.

While the queue is unlocked, another cpu could empty entries in the
TX queue making it not-full, which invalidates this "queue is now
full" return value the driver just gave.

We don't do things the way we do it now for fun, it's just the most
reasonable scheme we've come up with given the locking constraints.
