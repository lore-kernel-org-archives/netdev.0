From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH v2] net/gianfar: drop recycled skbs on MTU change
Date: Wed, 5 May 2010 10:30:47 +0200
Message-ID: <20100505083047.GA4398@Chamillionaire.breakpoint.cc>
References: <20100503151745.GA17997@Chamillionaire.breakpoint.cc>
 <o2g2acbd3e41005040829rc5bf7e0dwee8419b2b65e5468@mail.gmail.com>
 <20100505.005704.115933493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: afleming@gmail.com, afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:48730 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932104Ab0EEIax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 04:30:53 -0400
Content-Disposition: inline
In-Reply-To: <20100505.005704.115933493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

The size for skbs which is added to the recycled list is using the
current descriptor size which is current MTU. gfar_new_skb() is also
using this size. So after changing or alteast increasing the MTU all
recycled skbs should be dropped.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
>> I think we should probably do this in free_skb_resources.  And remove
>> the call from gfar_close().
>
>Ok, Sebastian please rework your patch as requested by Andy.

This has the side effect of dropping them on reset which is not
required.

 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4e97ca1..5d3763f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1649,6 +1649,7 @@ static void free_skb_resources(struct gfar_private *priv)
 			sizeof(struct rxbd8) * priv->total_rx_ring_size,
 			priv->tx_queue[0]->tx_bd_base,
 			priv->tx_queue[0]->tx_bd_dma_base);
+	skb_queue_purge(&priv->rx_recycle);
 }
 
 void gfar_start(struct net_device *dev)
@@ -2088,7 +2089,6 @@ static int gfar_close(struct net_device *dev)
 
 	disable_napi(priv);
 
-	skb_queue_purge(&priv->rx_recycle);
 	cancel_work_sync(&priv->reset_task);
 	stop_gfar(dev);
 
-- 
1.6.6.1

