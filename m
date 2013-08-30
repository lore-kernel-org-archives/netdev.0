From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net] net: fec: fix time stamping logic after napi conversion
Date: Fri, 30 Aug 2013 20:28:10 +0200
Message-ID: <22741489040b99d0c1025dcbf993fd5cfd859123.1377887138.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:35753 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3H3S2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:28:34 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so1083259ead.21
        for <netdev@vger.kernel.org>; Fri, 30 Aug 2013 11:28:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit dc975382 "net: fec: add napi support to improve proformance"
converted the fec driver to the napi model. However, that commit
forgot to remove the call to skb_defer_rx_timestamp which is only
needed in non-napi drivers.

(The function napi_gro_receive eventually calls netif_receive_skb,
which in turn calls skb_defer_rx_timestamp.)

This patch should also be applied to the 3.9 and 3.10 kernels.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 77ea0db..c610a27 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -971,8 +971,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 						       htons(ETH_P_8021Q),
 						       vlan_tag);
 
-			if (!skb_defer_rx_timestamp(skb))
-				napi_gro_receive(&fep->napi, skb);
+			napi_gro_receive(&fep->napi, skb);
 		}
 
 		bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, data,
-- 
1.7.10.4
