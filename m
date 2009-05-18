From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tx scalability works : trans_start
Date: Sun, 17 May 2009 20:57:10 -0700 (PDT)
Message-ID: <20090517.205710.137526481.davem@davemloft.net>
References: <4A09D269.60703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47389
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755221AbZERD5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 23:57:12 -0400
In-Reply-To: <4A09D269.60703@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 12 May 2009 21:47:53 +0200

> struct net_device trans_start field is a hot spot on SMP and high performance
> devices, particularly multi queues ones, because every transmitter dirties
> it. Is main use is tx watchdog and bonding alive checks.
> 
> But as most devices dont use NETIF_F_LLTX, we have to lock
> a netdev_queue before calling their ndo_start_xmit(). So it makes
> sense to move trans_start from net_device to netdev_queue. Its update
> will occur on a already present (and in exclusive state) cache line, for
> free.
> 
> We can do this transition smoothly. An old driver continue to
> update dev->trans_start, while an updated one updates txq->trans_start.
> 
> Further patches could also put tx_bytes/tx_packets counters in 
> netdev_queue to avoid dirtying dev->stats (vlan device comes to mind)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I like this patch so I'm adding it to net-next-2.6

But you can go one step further and untangle what is arguably
a huge mess.  There is no reason for the driver to set
->trans_start.

The driver gives us a success indication from ->hard_start_xmit()
and we can use that to set txq->trans_start.

Then you can kill the driver code that sets dev->trans_start and
then kill the netdev struct member as well.

Could you please do this work, thanks?
