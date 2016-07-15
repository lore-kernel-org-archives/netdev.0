From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: cavium: liquidio: Avoid dma_unmap_single on uninitialized ndata
Date: Fri, 15 Jul 2016 16:42:16 -0700
Message-ID: <1468626136-31783-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36159 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcGOXmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The label lio_xmit_failed is used 3 times through liquidio_xmit() but it
always makes a call to dma_unmap_single() using potentially
uninitialized variables from "ndata" variable. Out of the 3 gotos, 2 run
after ndata has been initialized, and had a prior dma_map_single() call.

Fix this by adding a new error label: lio_xmit_dma_failed which does
this dma_unmap_single() and then processed with the lio_xmit_failed
fallthrough.

Fixes: f21fb3ed364bb ("Add support of Cavium Liquidio ethernet adapters")
Reported-by: coverity (CID 1309740)
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 8de79ae63231..0e7e7da8d201 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2821,7 +2821,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		if (!g) {
 			netif_info(lio, tx_err, lio->netdev,
 				   "Transmit scatter gather: glist null!\n");
-			goto lio_xmit_failed;
+			goto lio_xmit_dma_failed;
 		}
 
 		cmdsetup.s.gather = 1;
@@ -2892,7 +2892,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	else
 		status = octnet_send_nic_data_pkt(oct, &ndata, xmit_more);
 	if (status == IQ_SEND_FAILED)
-		goto lio_xmit_failed;
+		goto lio_xmit_dma_failed;
 
 	netif_info(lio, tx_queued, lio->netdev, "Transmit queued successfully\n");
 
@@ -2906,12 +2906,13 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	return NETDEV_TX_OK;
 
+lio_xmit_dma_failed:
+	dma_unmap_single(&oct->pci_dev->dev, ndata.cmd.dptr,
+			 ndata.datasize, DMA_TO_DEVICE);
 lio_xmit_failed:
 	stats->tx_dropped++;
 	netif_info(lio, tx_err, lio->netdev, "IQ%d Transmit dropped:%llu\n",
 		   iq_no, stats->tx_dropped);
-	dma_unmap_single(&oct->pci_dev->dev, ndata.cmd.dptr,
-			 ndata.datasize, DMA_TO_DEVICE);
 	recv_buffer_free(skb);
 	return NETDEV_TX_OK;
 }
-- 
2.7.4
