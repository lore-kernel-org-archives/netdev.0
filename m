From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH] net: sh_eth: remove __flush_purge_region
Date: Fri, 01 Jul 2011 17:52:13 +0900
Message-ID: <4E0D8ABD.9030102@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:51949 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542Ab1GAIwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 04:52:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is a function of SuperH architecture. There is no good to use
the function on a driver generally. So, the driver uses
dma_map_single() instead of __flush_purge_region.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/sh_eth.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 8a72a97..09b5aa8 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -33,7 +33,6 @@
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/ethtool.h>
-#include <asm/cacheflush.h>

 #include "sh_eth.h"

@@ -864,6 +863,8 @@ static int sh_eth_txfree(struct net_device *ndev)
 			break;
 		/* Free the original skb. */
 		if (mdp->tx_skbuff[entry]) {
+			dma_unmap_single(&ndev->dev, txdesc->addr,
+					 txdesc->buffer_length, DMA_TO_DEVICE);
 			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
 			mdp->tx_skbuff[entry] = NULL;
 			freeNum++;
@@ -1487,13 +1488,12 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	entry = mdp->cur_tx % TX_RING_SIZE;
 	mdp->tx_skbuff[entry] = skb;
 	txdesc = &mdp->tx_ring[entry];
-	txdesc->addr = virt_to_phys(skb->data);
 	/* soft swap. */
 	if (!mdp->cd->hw_swap)
 		sh_eth_soft_swap(phys_to_virt(ALIGN(txdesc->addr, 4)),
 				 skb->len + 2);
-	/* write back */
-	__flush_purge_region(skb->data, skb->len);
+	txdesc->addr = dma_map_single(&ndev->dev, skb->data, skb->len,
+				      DMA_TO_DEVICE);
 	if (skb->len < ETHERSMALL)
 		txdesc->buffer_length = ETHERSMALL;
 	else
-- 
1.7.1
