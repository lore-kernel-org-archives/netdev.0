From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2.6.20-rc5 1/4] atl1: unconditionally enable MSI
Date: Sat, 27 Jan 2007 18:10:04 -0600
Message-ID: <20070128001004.GA10269@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	randy.dunlap@oracle.com, kronos.it@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:58288 "EHLO
	imf21aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932154AbXA1AKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 19:10:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Luca Tettamanti <kronos.it@gmail.com>

Unconditionally enable MSI in atl1 driver. Also remove some useless
#ifdef since pci_{en,dis}able_msi() are no-op when MSI support is not
configured in.

Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1.h       |    1 -
 drivers/net/atl1/atl1_main.c  |   22 +++++++---------------
 drivers/net/atl1/atl1_param.c |   13 -------------
 3 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index 1d13e8f..0b30e1c 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -281,7 +281,6 @@ struct atl1_adapter {
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
 
-	int enable_msi;
 	u32 pci_state[16];
 };
 
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index c0b1555..68e6cd1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1793,18 +1793,12 @@ s32 atl1_up(struct atl1_adapter *adapter)
 		goto err_up;
 	}
 
-#ifdef CONFIG_PCI_MSI
-	if (adapter->enable_msi) {
-		err = pci_enable_msi(adapter->pdev);
-		if (err) {
-			dev_info(&adapter->pdev->dev, "Unable to enable MSI: %d\n", err);
-			adapter->enable_msi = 0;
-		}
-	}
-#endif
-	if (!adapter->enable_msi)
+	err = pci_enable_msi(adapter->pdev);
+	if (err) {
+		dev_info(&adapter->pdev->dev, "Unable to enable MSI: %d\n", err);
 		irq_flags |= IRQF_SHARED;
-
+	}
+	
 	err = request_irq(adapter->pdev->irq, &atl1_intr, irq_flags,
 			netdev->name, netdev);
 	if (unlikely(err))
@@ -1821,6 +1815,7 @@ s32 atl1_up(struct atl1_adapter *adapter)
 	free_irq(adapter->pdev->irq, netdev);
 
 err_up:
+	pci_disable_msi(adapter->pdev);
 	/* free rx_buffers */
 	atl1_clean_rx_ring(adapter);
 	return err;
@@ -1836,10 +1831,7 @@ void atl1_down(struct atl1_adapter *adapter)
 
 	atl1_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
-#ifdef CONFIG_PCI_MSI
-	if (adapter->enable_msi)
-		pci_disable_msi(adapter->pdev);
-#endif
+	pci_disable_msi(adapter->pdev);
 	atl1_reset_hw(&adapter->hw);
 	adapter->cmb.cmb->int_stats = 0;
 
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atl1/atl1_param.c
index 4732f43..caa2d83 100644
--- a/drivers/net/atl1/atl1_param.c
+++ b/drivers/net/atl1/atl1_param.c
@@ -68,10 +68,6 @@ static int num_flash_vendor = 0;
 module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_vendor, 0);
 MODULE_PARM_DESC(flash_vendor, "SPI flash vendor");
 
-int enable_msi;
-module_param(enable_msi, int, 0444);
-MODULE_PARM_DESC(enable_msi, "Enable PCI MSI");
-
 #define DEFAULT_INT_MOD_CNT	100	/* 200us */
 #define MAX_INT_MOD_CNT		65000
 #define MIN_INT_MOD_CNT		50
@@ -211,13 +207,4 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 			adapter->hw.flash_vendor = (u8) (opt.def);
 		}
 	}
-
-	{			/* PCI MSI usage */
-
-#ifdef CONFIG_PCI_MSI
-		adapter->enable_msi = enable_msi;
-#else
-		adapter->enable_msi = 0;
-#endif
-	}
 }



Luca
-- 
Inquietudine sintetica
Solo, davanti all'ignoto
Tienimi stretto a te
