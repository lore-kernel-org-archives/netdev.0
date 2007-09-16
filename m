From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH|[NET]: migrate HARD_TX_LOCK to header file
Date: Sun, 16 Sep 2007 12:28:42 -0700 (PDT)
Message-ID: <20070916.122842.59467739.davem@davemloft.net>
References: <1189957725.4241.4.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36711
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751429AbXIPT2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 15:28:43 -0400
In-Reply-To: <1189957725.4241.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sun, 16 Sep 2007 11:48:45 -0400

> I wanted to get rid of the extrenous cpu arguement and ended moving this
> to the header files since it looks common enough an operation that could
> be used elsewhere.
> It is a trivial change - i could resend with leaving it in dev.c and
> just getting rid of the cpu arguement.

The only reason the cpu argument is superfluous is because
we don't provide a way to pass it on down to netif_tx_lock().

So instead netif_tx_lock() recomputes that value in this case which is
extra unnecessary work.

I would instead suggest, in netdevice.h:

static inline void __netif_tx_lock(struct net_device *dev, int cpu)
{
	spin_lock(&dev->_xmit_lock);
	dev->xmit_lock_owner = cpu;
}

static inline void netif_tx_lock(struct net_device *dev)
{
	__netif_tx_lock(dev, smp_processor_id());
}

And make the HARD_TX_LOCK() call __netif_tx_lock() and pass in
the already computed 'cpu' parameter.

Thanks.
