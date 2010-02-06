From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 6/6] DMFE: don't reinitialize the hardware if device wasn't open
Date: Sat,  6 Feb 2010 22:19:02 +0200
Message-ID: <1265487542-4447-7-git-send-email-maximlevitsky@gmail.com>
References: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:58911 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756018Ab0BFUTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2010 15:19:20 -0500
In-Reply-To: <1265487542-4447-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This cleans the .suspend/.resume functions and makes sure
we don't enable the device if it was down before the suspend
or disable it again if it was down in .suspend

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/net/tulip/dmfe.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 9cd6179..cf164de 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -1959,21 +1959,13 @@ static void __devexit dmfe_remove(struct pci_dev *pdev)
 static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
-	struct dmfe_board_info *db = netdev_priv(dev);
 
 	/* Disable upper layer interface */
 	netif_device_detach(dev);
 
-	/* Disable Tx/Rx */
-	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);
-	dmfe_update_cr6(db->cr6_data, dev->base_addr);
-
-	/* Disable Interrupt */
-	outl(0, dev->base_addr + DCR7);
-	outl(inl(dev->base_addr + DCR5), dev->base_addr + DCR5);
-
-	/* Fre RX buffers */
-	dmfe_free_rxbuffer(db);
+	/* Stop the hardware */
+	if (netif_running(dev))
+		dmfe_stop(dev);
 
 	/* Enable WOL */
 	dmfe_set_wol(dev, 1);
@@ -1992,12 +1984,13 @@ static int dmfe_resume(struct pci_dev *pci_dev)
 	pci_back_from_sleep(pci_dev);
 	pci_restore_state(pci_dev);
 
-	/* Re-initilize DM910X board */
-	dmfe_hardware_init(dev);
-
 	/* Disable WOL */
 	dmfe_set_wol(dev, 0);
 
+	/* Start the interace back */
+	if (netif_running(dev))
+		dmfe_open(dev);
+
 	/* Restart upper layer interface */
 	netif_device_attach(dev);
 
-- 
1.6.3.3

