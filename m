From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH v4] sh_eth: ensure pm_runtime cannot suspend the device during init
Date: Fri, 21 Mar 2014 11:14:48 +0100
Message-ID: <1395396888-24306-1-git-send-email-ben.dooks@codethink.co.uk>
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
also caused issues with the MDIO bus code. This has now been checked
and is the only place the MDIO can be called without the device open.

Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
pm system does not suspend it during the probe() call and remove the
now unnecessary pm_runtime_resume() call. Also add a call in the error
path to call pm_runtime_disable().

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

Fixed from v2:
	- call pm_runtime_put() in error path

Fixed from v3:
	- call pm_runtime_disable() in error path
---
 drivers/net/ethernet/renesas/sh_eth.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4f76b5e..b908507 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2841,6 +2841,9 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 		goto out;
 	}
 
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
+
 	/* The sh Ether-specific entries in the device structure. */
 	ndev->base_addr = res->start;
 	devno = pdev->id;
@@ -2868,8 +2871,6 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	spin_lock_init(&mdp->lock);
 	mdp->pdev = pdev;
-	pm_runtime_enable(&pdev->dev);
-	pm_runtime_resume(&pdev->dev);
 
 	if (pdev->dev.of_node)
 		pd = sh_eth_parse_dt(&pdev->dev);
@@ -2961,6 +2962,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
 		(u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
 
+	pm_runtime_put(&pdev->dev);
 	platform_set_drvdata(pdev, ndev);
 
 	return ret;
@@ -2976,6 +2978,8 @@ out_release:
 	if (ndev)
 		free_netdev(ndev);
 
+	pm_runtime_put(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
 out:
 	return ret;
 }
-- 
1.9.0

