From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net] dwc_eth_qos: fix interrupt enable race
Date: Tue, 23 Aug 2016 16:31:28 +0200
Message-ID: <1471962688-9226-1-git-send-email-larper@axis.com>
Cc: linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>,
        Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rabin Vincent <rabinv@axis.com>

We currently enable interrupts before we enable NAPI. If an RX interrupt
hits before we enabled NAPI then the NAPI callback is never called and
we leave the hardware with RX interrupts disabled, which of course leads
us to never handling received packets.  Fix this by moving the interrupt
enable to after we've enable NAPI and the reclaim tasklet.

Fixes: cd5e41234729 ("dwc_eth_qos: do phy_start before resetting hardware")
Signed-off-by: Rabin Vincent <rabinv@axis.com>
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 9f159a7..5a3941b 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -1622,13 +1622,7 @@ static void dwceqos_init_hw(struct net_local *lp)
 		DWCEQOS_MMC_CTRL_RSTONRD);
 	dwceqos_enable_mmc_interrupt(lp);
 
-	/* Enable Interrupts */
-	dwceqos_write(lp, REG_DWCEQOS_DMA_CH0_IE,
-		      DWCEQOS_DMA_CH0_IE_NIE |
-		      DWCEQOS_DMA_CH0_IE_RIE | DWCEQOS_DMA_CH0_IE_TIE |
-		      DWCEQOS_DMA_CH0_IE_AIE |
-		      DWCEQOS_DMA_CH0_IE_FBEE);
-
+	dwceqos_write(lp, REG_DWCEQOS_DMA_CH0_IE, 0);
 	dwceqos_write(lp, REG_DWCEQOS_MAC_IE, 0);
 
 	dwceqos_write(lp, REG_DWCEQOS_MAC_CFG, DWCEQOS_MAC_CFG_IPC |
@@ -1905,6 +1899,15 @@ static int dwceqos_open(struct net_device *ndev)
 	netif_start_queue(ndev);
 	tasklet_enable(&lp->tx_bdreclaim_tasklet);
 
+	/* Enable Interrupts -- do this only after we enable NAPI and the
+	 * tasklet.
+	 */
+	dwceqos_write(lp, REG_DWCEQOS_DMA_CH0_IE,
+		      DWCEQOS_DMA_CH0_IE_NIE |
+		      DWCEQOS_DMA_CH0_IE_RIE | DWCEQOS_DMA_CH0_IE_TIE |
+		      DWCEQOS_DMA_CH0_IE_AIE |
+		      DWCEQOS_DMA_CH0_IE_FBEE);
+
 	return 0;
 }
 
-- 
2.1.4
