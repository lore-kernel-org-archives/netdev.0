From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc2-mm1 1/1] 3c59x: missing pci_disable_device
Date: Sun, 19 Sep 2004 00:01:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918220122.GA15528@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobom.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It is possible to remove the device without calling pci_disable_device().
A leak can take place during the init as well.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/3c59x.c~3c59x-00 drivers/net/3c59x.c
--- linux-2.6.9-rc2/drivers/net/3c59x.c~3c59x-00	2004-09-18 22:20:43.000000000 +0200
+++ linux-2.6.9-rc2-fr/drivers/net/3c59x.c	2004-09-18 22:20:43.000000000 +0200
@@ -1075,14 +1075,20 @@ static int __devinit vortex_init_one (st
 	int rc;
 
 	/* wake up and enable device */		
-	if (pci_enable_device (pdev)) {
-		rc = -EIO;
-	} else {
-		rc = vortex_probe1 (&pdev->dev, pci_resource_start (pdev, 0),
-							pdev->irq, ent->driver_data, vortex_cards_found);
-		if (rc == 0)
-			vortex_cards_found++;
+	rc = pci_enable_device (pdev);
+	if (rc < 0)
+		goto out;
+
+	rc = vortex_probe1 (&pdev->dev, pci_resource_start (pdev, 0),
+						pdev->irq, ent->driver_data, vortex_cards_found);
+	if (rc < 0) {
+		pci_disable_device (pdev);
+		goto out;
 	}
+
+	vortex_cards_found++;
+
+out:
 	return rc;
 }
 
@@ -3163,6 +3169,7 @@ static void __devexit vortex_remove_one 
 		pci_set_power_state(VORTEX_PCI(vp), 0);	/* Go active */
 		if (vp->pm_state_valid)
 			pci_restore_state(VORTEX_PCI(vp), vp->power_state);
+		pci_disable_device(VORTEX_PCI(vp));
 	}
 	/* Should really use issue_and_wait() here */
 	outw(TotalReset|0x14, dev->base_addr + EL3_CMD);

_
