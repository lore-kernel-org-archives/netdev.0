From: David Miller <davem@davemloft.net>
Subject: Re: [STRAW MAN PATCH] sch_teql doesn't load-balance ppp(oatm)
 slaves
Date: Sun, 25 Mar 2012 17:36:35 -0400 (EDT)
Message-ID: <20120325.173635.1909319488008466320.davem@davemloft.net>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	<20120322.230331.1623101647193498167.davem@davemloft.net>
	<1332672230.32446.160.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134Ab2CYVhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 17:37:43 -0400
In-Reply-To: <1332672230.32446.160.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 25 Mar 2012 11:43:50 +0100

> It's a bad idea to have huge hidden queues (a whole wmem_default worth
> of packets are in a hidden queue between ppp_generic and the ATM device,
> ffs!) anyway, so perhaps if we just fix *that* within PPP, it should
> work a bit better with TEQL?

Yes, the ATM devices deep transmit queue is quite undesirable.

But I actually don't see how the problem arises yet, I need more
details.

PPP itself will always stop the queue, and return NETDEV_TX_OK on a
transmit attempt.  It may wake the queue back up before returning if
the downstream device (such as pppoatm) accepted the packet.

But in either case NETDEV_TX_OK is returned and this is what the teql
master transmit sees, and this takes the code path which advances the
slave pointer to the next device.

Therefore the next teql master transmit should try the next device in
the slave list, not the PPP device used in the previous call.
