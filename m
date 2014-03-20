From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] [PATCH v2] sh_eth: ensure pm_runtime cannot suspend the device during init
Date: Thu, 20 Mar 2014 10:33:27 +0100
Message-ID: <1395308007-13956-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: linux-sh@vger.kernel.org, davem@davemloft.net,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	sergei.shtylyov@cogentembedded.com,
	laurent.pinchart+renesas@ideasonboard.com
To: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pm_rumtime work queue is causing the device to be suspended during
initialisation, thus the initialisation may not be able to access registers
properly. As the code is called from a work queue, it is possible that this
is not seen from certain configurations/builds due to the asynchronos
nature of the code.

Another issue has also been found where the network device registration
calls back into the driver thus causing further pm_runtime calls that
also caused issues with the MDIO bus code.

Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
pm system does not suspend it during the probe() call and remove the
now unnecessary pm_runtime_resume() call.

This fixes the external abort that can cause /sbin/init or other such
init processed to die.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>

---
Cc: sergei.shtylyov@cogentembedded.com
Cc: laurent.pinchart+renesas@ideasonboard.com
cc: netdev@vger.kernel.org

Note, Laurent this should probably be applied before your
current series as it may require changes to the exit sequence.

Fixes from v1:
	- use pm_runtime_put() over pm_runtime_put_sync() as
	  we do not need to guaranteed the device has powered
          off after probe.
---
 drivers/net/ethernet/renesas/sh_eth.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4f76b5e..955e422 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2869,7 +2869,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	spin_lock_init(&mdp->lock);
 	mdp->pdev = pdev;
 	pm_runtime_enable(&pdev->dev);
-	pm_runtime_resume(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
 
 	if (pdev->dev.of_node)
 		pd = sh_eth_parse_dt(&pdev->dev);
@@ -2961,6 +2961,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
 		(u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
 
+	pm_runtime_put(&pdev->dev);
 	platform_set_drvdata(pdev, ndev);
 
 	return ret;
-- 
1.9.0

