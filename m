From: akpm@osdl.org
Subject: [patch 08/10] smc91x: power down PHY on suspend
Date: Mon, 24 Jan 2005 18:57:20 -0800
Message-ID: <200501250257.j0P2vml20294@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, icampbell@arcom.com,
        nico@cam.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Ian Campbell <icampbell@arcom.com>

Powering down the PHY saves something like 100mA at 5V on my platform. 
Currently it is only done when the interface is brought down but it makes
sense to do it on suspend as well.  

Signed-off-by: Ian Campbell <icampbell@arcom.com>
Signed-off-by: Nicolas Pitre <nico@cam.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/smc91x.c |   37 ++++++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 17 deletions(-)

diff -puN drivers/net/smc91x.c~smc91x-power-down-phy-on-suspend drivers/net/smc91x.c
--- 25/drivers/net/smc91x.c~smc91x-power-down-phy-on-suspend	2005-01-24 18:55:47.702045024 -0800
+++ 25-akpm/drivers/net/smc91x.c	2005-01-24 18:55:47.707044264 -0800
@@ -1017,13 +1017,29 @@ static int smc_phy_reset(struct net_devi
 /*
  * smc_phy_powerdown - powerdown phy
  * @dev: net device
- * @phy: phy address
  *
  * Power down the specified PHY
  */
-static void smc_phy_powerdown(struct net_device *dev, int phy)
+static void smc_phy_powerdown(struct net_device *dev)
 {
+	struct smc_local *lp = netdev_priv(dev);
 	unsigned int bmcr;
+	int phy = lp->mii.phy_id;
+
+	if (lp->phy_type == 0)
+		return;
+
+	/* We need to ensure that no calls to smc_phy_configure are
+	   pending.
+
+	   flush_scheduled_work() cannot be called because we are
+	   running with the netlink semaphore held (from
+	   devinet_ioctl()) and the pending work queue contains
+	   linkwatch_event() (scheduled by netif_carrier_off()
+	   above). linkwatch_event() also wants the netlink semaphore.
+	*/
+	while(lp->work_pending)
+		schedule();
 
 	bmcr = smc_phy_read(dev, phy, MII_BMCR);
 	smc_phy_write(dev, phy, MII_BMCR, bmcr | BMCR_PDOWN);
@@ -1561,21 +1577,7 @@ static int smc_close(struct net_device *
 	/* clear everything */
 	smc_shutdown(dev);
 
-	if (lp->phy_type != 0) {
-		/* We need to ensure that no calls to
-		   smc_phy_configure are pending.
-
-		   flush_scheduled_work() cannot be called because we
-		   are running with the netlink semaphore held (from
-		   devinet_ioctl()) and the pending work queue
-		   contains linkwatch_event() (scheduled by
-		   netif_carrier_off() above). linkwatch_event() also
-		   wants the netlink semaphore.
-		*/
-		while(lp->work_pending)
-			schedule();
-		smc_phy_powerdown(dev, lp->mii.phy_id);
-	}
+	smc_phy_powerdown(dev);
 
 	if (lp->pending_tx_skb) {
 		dev_kfree_skb(lp->pending_tx_skb);
@@ -2196,6 +2198,7 @@ static int smc_drv_suspend(struct device
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
 			smc_shutdown(ndev);
+			smc_phy_powerdown(ndev);
 		}
 	}
 	return 0;
_
