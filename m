From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net 2/5] dwc_eth_qos: release descriptors outside netif_tx_lock
Date: Mon, 29 Feb 2016 16:22:31 +0100
Message-ID: <405b7bbe8cceacc7edea2f415b7fbb21aa16ea6f.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:53867 "EHLO bes.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633AbcB2PXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 10:23:48 -0500
In-Reply-To: <cover.1456756740.git.larper@axis.com>
In-Reply-To: <cover.1456756740.git.larper@axis.com>
References: <cover.1456756740.git.larper@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prepare for using the CMA, we can not be in atomic context when
de-allocating DMA buffers.

The tx lock was needed only to protect the hw reset against the xmit
handler. Now we briefly grab the tx lock while stopping the queue to
make sure no thread is inside or will enter the xmit handler.

Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 926db2d..53d48c0 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -1918,15 +1918,17 @@ static int dwceqos_stop(struct net_device *ndev)
 	phy_stop(lp->phy_dev);
 
 	tasklet_disable(&lp->tx_bdreclaim_tasklet);
-	netif_stop_queue(ndev);
 	napi_disable(&lp->napi);
 
-	dwceqos_drain_dma(lp);
+	/* Stop all tx before we drain the tx dma. */
+	netif_tx_lock_bh(lp->ndev);
+	netif_stop_queue(ndev);
+	netif_tx_unlock_bh(lp->ndev);
 
-	netif_tx_lock(lp->ndev);
+	dwceqos_drain_dma(lp);
 	dwceqos_reset_hw(lp);
+
 	dwceqos_descriptor_free(lp);
-	netif_tx_unlock(lp->ndev);
 
 	return 0;
 }
-- 
2.1.4
