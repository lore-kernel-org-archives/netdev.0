From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] via-rhine: NOHZ: local_softirq_pending 08
Date: Tue, 29 Jan 2013 17:47:02 -0500 (EST)
Message-ID: <20130129.174702.196275387733819730.davem@davemloft.net>
References: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rl@hellgate.ch, romieu@fr.zoreil.com
To: jamie.gloudon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3A2WrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:47:08 -0500
In-Reply-To: <51007b84.03ab640a.1cde.fffff62a@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamie Gloudon <jamie.gloudon@gmail.com>
Date: Wed, 23 Jan 2013 20:08:29 -0400

>    While conducting some tests on a VT6105M card. I noticed this message:
> 
> kernel: [  160.311113] NOHZ: local_softirq_pending 08
> 
> I was able to reliably reproduce the error message by setting autoneg off and changing the interface speed from 100 to 10 with ethtool.

I wonder if this is due to some oversights during the NAPI changes
that went in about a year ago.

Francois, if you move rhine_tx() work into the driver's NAPI poll
routine, as you did in:

commit 7ab87ff4c770eed71e3777936299292739fcd0fe
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Fri Jan 6 21:42:26 2012 +0100

    via-rhine: move work from irq handler to softirq and beyond.

I don't think you can't keep using dev_kfree_skb_irq() there.

Francois any objections to this patch?

====================
via-rhine: Don't use dev_kfree_skb_irq() in softirq context.

When the TX reclaim of this driver was moved into NAPI poll,
using dev_kfree_skb_irq() stopped being appropriate.

Use plain dev_kfree_skb() instead.

Reported-by: Jamie Gloudon <jamie.gloudon@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 7992b3e..f08e970 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1801,7 +1801,7 @@ static void rhine_tx(struct net_device *dev)
 					 rp->tx_skbuff[entry]->len,
 					 PCI_DMA_TODEVICE);
 		}
-		dev_kfree_skb_irq(rp->tx_skbuff[entry]);
+		dev_kfree_skb(rp->tx_skbuff[entry]);
 		rp->tx_skbuff[entry] = NULL;
 		entry = (++rp->dirty_tx) % TX_RING_SIZE;
 	}
