From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH] net: fec: fix unbalanced clk disable on driver unbind
Date: Thu,  5 Mar 2015 15:09:29 +0100
Message-ID: <1425564569-12184-1-git-send-email-stefan@agner.ch>
Cc: B38611@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefan@agner.ch
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the driver is removed (e.g. using unbind through sysfs), the
clocks get disabled twice, once on fec_enet_close and once on
fec_drv_remove. Since the clocks are enabled only once, this leads
to a warning:

WARNING: CPU: 0 PID: 402 at drivers/clk/clk.c:992 clk_core_disable+0x64/0x68()

Remove the call to fec_enet_clk_enable in fec_drv_remove to balance
the clock enable/disable calls again. This has been introduce by
e8fcfcd5684a ("net: fec: optimize the clock management to save power").

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9bb6220..5fbdf72 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3383,7 +3383,6 @@ fec_drv_remove(struct platform_device *pdev)
 		regulator_disable(fep->reg_phy);
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
-	fec_enet_clk_enable(ndev, false);
 	of_node_put(fep->phy_node);
 	free_netdev(ndev);
 
-- 
2.3.0
