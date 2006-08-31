From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 6/7] 8139cp: pci_get_drvdata(pdev) can not be NULL in suspend handler
Date: Thu, 31 Aug 2006 22:52:36 +0200
Message-ID: <20060831205236.GF14181@electric-eye.fr.zoreil.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:64901 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750858AbWHaU4R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:56:17 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1) pci_set_drvdata() is used in cp_{init/remove}_one to initialize/reset
   driver_data to the relevant value (resp. net_device * and NULL).

2) each of the 3 relevant functions is issued under (device *)->sem:
   2.1) pci_unregister_driver
        -> driver_unregister
           -> bus_remove_driver
              -> driver_detach (takes (device *)->sem)
                 -> __device_release_driver(dev)
                    -> dev->bus-remove(dev) (== pci_device_remove)
                       -> drv->remove(pdev) (== cp_remove_one)
                       [...]
                       pci_dev->driver = NULL;

   2.2) pci_register_driver
        -> __pci_register_driver
           -> driver_register
              -> bus_add_driver
                 -> driver_attach
                    -> __driver_attach (takes (device *)->sem)
                       -> driver_probe_device(drv, dev)
                          -> dev->bus->probe(dev) (== pci_device_probe)
                             -> _pci_device_probe(drv, pci_dev)
                                -> pci_call_probe(drv, pci_dev, id)
                                   -> drv->probe(dev, id) (== cp_init_one)
                                [...]
                                pci_dev->driver = drv;

   2.3) suspend_device (takes (device *)->sem)
        -> dev->bus->suspend(dev) (== pci_device_suspend)
           checking for drv = pci_dev->driver != NULL
           [...]
           -> drv->suspend(pci_dev, state) (== cp_suspend)

dev->sem and the state of pci_dev->driver provide the expected result.

St Mary's day was a bit rainy here.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

---

 drivers/net/8139cp.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

7668a4945ba0e17a61e535a6c67aa64a319a03b4
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 94ab3c3..a123d28 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -2023,14 +2023,12 @@ static void cp_remove_one (struct pci_de
 #ifdef CONFIG_PM
 static int cp_suspend (struct pci_dev *pdev, pm_message_t state)
 {
-	struct net_device *dev;
-	struct cp_private *cp;
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
 
-	dev = pci_get_drvdata (pdev);
-	cp  = netdev_priv(dev);
-
-	if (!dev || !netif_running (dev)) return 0;
+	if (!netif_running(dev))
+		return 0;
 
 	netif_device_detach (dev);
 	netif_stop_queue (dev);
-- 
1.3.1

