From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: Byte queue limit patch series
Date: Fri, 29 Apr 2011 11:54:43 -0700 (PDT)
Message-ID: <20110429.115443.28811990.davem@davemloft.net>
References: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760457Ab1D2SzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 14:55:16 -0400
In-Reply-To: <alpine.DEB.2.00.1104252128001.5889@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 25 Apr 2011 21:38:06 -0700 (PDT)

> This patch series implements byte queue limits (bql) for NIC TX queues.

I like the idea, I don't like how much drivers have to be involved
in this.

TX queue handling is already too involved for driver writers, so
having them need to get all of these new hooks right is a non-starter.

I don't even think it's necessary to be honest, I think you can hide
to bulk of it.

alloc_etherdev_mq() can initialize the per-txq bql instances.

Add new interface, netdev_free_tx_skb(txq, skb) which can do the
completion accounting.  Actually the 'txq' argument is probably
superfluous as it can be obtained from the skb itself.

dev_hard_start_xmit() can do the "sent" processing.

Then the only thing you're doing is replacing dev_kfree_skb*()
in the TX path of the driver with the new netdev_free_tx_skb()
thing.

Maybe you can add a "netdev_tx_queue_reset()" hook for asynchronous
device resets.  Otherwise the bql reset can occur in generic code
right at ->ndo_open().

Finally, you manage the bql limit logic in the existing generic netdev
TX start/stop interfaces.  If the user asks for "start" but the bql
is overlimit, simply ignore the request.  The driver will just signal
another "start" when the next TX packet completes.

Similarly, when the qdisc is queuing up a packet to
dev_hard_start_xmit() you can, for example, preemptively do a "stop"
on the queue if you find bql is overlimit.

Thanks Tom.

