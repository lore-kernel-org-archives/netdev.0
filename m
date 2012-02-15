From: Jan Weitzel <j.weitzel@phytec.de>
Subject: [PATCH] net/ethernet: ks8851_mll fix irq handling
Date: Wed, 15 Feb 2012 08:35:15 +0100
Message-ID: <1329291315-7973-1-git-send-email-j.weitzel@phytec.de>
Cc: Jan Weitzel <j.weitzel@phytec.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There a two different irq variables ks->irq and netdev->irq.
Only ks->irq is set on probe, so disabling irq in ks_start_xmit fails.

This patches remove ks->irq from private data and use only netdev->irq.

Tested on a kernel 3.0 based OMAP4430 SMP Board

Signed-off-by: Jan Weitzel <j.weitzel@phytec.de>
---
 drivers/net/ethernet/micrel/ks8851_mll.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..231176f 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -394,7 +394,6 @@ union ks_tx_hdr {
  * @msg_enable	: The message flags controlling driver output (see ethtool).
  * @frame_cnt  	: number of frames received.
  * @bus_width  	: i/o bus width.
- * @irq    	: irq number assigned to this device.
  * @rc_rxqcr	: Cached copy of KS_RXQCR.
  * @rc_txcr	: Cached copy of KS_TXCR.
  * @rc_ier	: Cached copy of KS_IER.
@@ -441,7 +440,6 @@ struct ks_net {
 	u32			msg_enable;
 	u32			frame_cnt;
 	int			bus_width;
-	int             	irq;
 
 	u16			rc_rxqcr;
 	u16			rc_txcr;
@@ -907,10 +905,10 @@ static int ks_net_open(struct net_device *netdev)
 	netif_dbg(ks, ifup, ks->netdev, "%s - entry\n", __func__);
 
 	/* reset the HW */
-	err = request_irq(ks->irq, ks_irq, KS_INT_FLAGS, DRV_NAME, netdev);
+	err = request_irq(netdev->irq, ks_irq, KS_INT_FLAGS, DRV_NAME, netdev);
 
 	if (err) {
-		pr_err("Failed to request IRQ: %d: %d\n", ks->irq, err);
+		pr_err("Failed to request IRQ: %d: %d\n", netdev->irq, err);
 		return err;
 	}
 
@@ -955,7 +953,7 @@ static int ks_net_stop(struct net_device *netdev)
 
 	/* set powermode to soft power down to save power */
 	ks_set_powermode(ks, PMECR_PM_SOFTDOWN);
-	free_irq(ks->irq, netdev);
+	free_irq(netdev->irq, netdev);
 	mutex_unlock(&ks->lock);
 	return 0;
 }
@@ -1545,10 +1543,10 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 	if (!ks->hw_addr_cmd)
 		goto err_ioremap1;
 
-	ks->irq = platform_get_irq(pdev, 0);
+	netdev->irq = platform_get_irq(pdev, 0);
 
-	if (ks->irq < 0) {
-		err = ks->irq;
+	if (netdev->irq < 0) {
+		err = netdev->irq;
 		goto err_get_irq;
 	}
 
-- 
1.7.0.4
