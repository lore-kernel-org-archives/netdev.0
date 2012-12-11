From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH v2 1/1] net: ethernet: davinci_cpdma: Add boundary for
 rx and tx descriptors
Date: Tue, 11 Dec 2012 10:54:56 -0800
Message-ID: <1355252096.27891.130.camel@edumazet-glaptop>
References: <1355197433-7492-1-git-send-email-mugunthanvnm@ti.com>
	 <20121211.133058.2238010228178961245.davem@davemloft.net>
	 <20121211.133426.484976995112519196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49676 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505Ab2LKSy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:54:59 -0500
In-Reply-To: <20121211.133426.484976995112519196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 13:34 -0500, David Miller wrote:

> 
> You can't signal "out of descriptors" and stop the queue after the
> fact.  NETDEV_TX_BUSY is for handling exceptional and extraordinary
> conditions, not for the normal queue full handling.

This reminds me an idea I had about MQ/MQPRIO qdisc and BQL interaction

(BQL btw makes less probable a NETDEV_TX_BUSY event or
__QUEUE_STATE_DRV_XOFF state, but more probable a
__QUEUE_STATE_STACK_XOFF)

We dequeue a packet from qdisc, then we realize tx queue is in XOFF
state, and we have to hold the skb into gso_skb for later.

This shows in stats (tc -s qdisc dev eth0) as requeues.

Problem of these requeues is that high priority packets can not be
dequeued as long as this (possibly low prio and big TSO packet) is not
removed from gso_skb.

At 1Gbps speed, a full size TSO packet is 500 us of extra latency.

Suggested fix : add a TCQ_F_MQSLAVE flag to allow dequeue_skb() to test
the netif_xmit_frozen_or_stopped() status _before_ dequeing packet from
qdisc.

(For other qdiscs, we dont really know which tx queue will use the next
packet before dequeueing it)
