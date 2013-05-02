From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v3 1/1 net] net: fec: fix kernel oops when plug/unplug cable many times
Date: Thu, 2 May 2013 08:55:38 +0800
Message-ID: <1367456138-27172-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <romieu@fr.zoreil.com>, <r.schwebel@pengutronix.de>,
	<davem@davemloft.net>, <l.stach@pengutronix.de>,
	<netdev@vger.kernel.org>, <festevam@gmail.com>,
	<shawn.guo@linaro.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:57048
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752282Ab3EBCTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 22:19:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reproduce steps
 1. flood ping from other machine
 	ping -f -s 41000 IP
 2. run below script
    while [ 1 ]; do ethtool -s eth0 autoneg off;
    sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;

You can see oops in one hour.

The reason is fec_restart clear BD but NAPI may use it.
The solution is disable NAPI and stop xmit when reset BD.
disable NAPI may sleep, so fec_restart can't be call in
atomic context.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
Change from v1 to v2
 * Add netif_tx_lock(ndev) to avoid xmit runing when reset hardware
Change from v2 to v3
 * Move put real statements after function variable declarations according to David's comments
 * Remove lock in adjust_link according to Lucas Stach's comments
 
 drivers/net/ethernet/freescale/fec.c |   42 +++++++++++++++++++++++++---------
 drivers/net/ethernet/freescale/fec.h |    3 +-
 2 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 73195f6..5a9345c 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -407,6 +407,12 @@ fec_restart(struct net_device *ndev, int duplex)
 	u32 rcntl = OPT_FRAME_SIZE | 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
 
+	if (netif_running(ndev)) {
+		napi_disable(&fep->napi);
+		netif_stop_queue(ndev);
+		netif_tx_lock(ndev);
+	}
+
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
@@ -559,6 +565,12 @@ fec_restart(struct net_device *ndev, int duplex)
 
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+	if (netif_running(ndev)) {
+		napi_enable(&fep->napi);
+		netif_wake_queue(ndev);
+		netif_tx_unlock(ndev);
+	}
 }
 
 static void
@@ -598,8 +610,20 @@ fec_timeout(struct net_device *ndev)
 
 	ndev->stats.tx_errors++;
 
-	fec_restart(ndev, fep->full_duplex);
-	netif_wake_queue(ndev);
+	fep->timeout = 1;
+	schedule_delayed_work(&fep->delay_work, msecs_to_jiffies(1));
+}
+
+static void fec_enet_work(struct work_struct *work)
+{
+	struct fec_enet_private *fep =
+		container_of(work, struct fec_enet_private, delay_work.work);
+
+	if (fep->timeout) {
+		fep->timeout = 0;
+		fec_restart(fep->netdev, fep->full_duplex);
+		netif_wake_queue(fep->netdev);
+	}
 }
 
 static void
@@ -970,16 +994,12 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct phy_device *phy_dev = fep->phy_dev;
-	unsigned long flags;
-
 	int status_change = 0;
 
-	spin_lock_irqsave(&fep->hw_lock, flags);
-
 	/* Prevent a state halted on mii error */
 	if (fep->mii_timeout && phy_dev->state == PHY_HALTED) {
 		phy_dev->state = PHY_RESUMING;
-		goto spin_unlock;
+		goto exit;
 	}
 
 	if (phy_dev->link) {
@@ -995,7 +1015,6 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 			fep->speed = phy_dev->speed;
 			status_change = 1;
 		}
-
 		/* if any of the above changed restart the FEC */
 		if (status_change)
 			fec_restart(ndev, phy_dev->duplex);
@@ -1007,11 +1026,10 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		}
 	}
 
-spin_unlock:
-	spin_unlock_irqrestore(&fep->hw_lock, flags);
-
+exit:
 	if (status_change)
 		phy_print_status(phy_dev);
+
 }
 
 static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
@@ -1882,6 +1900,7 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
+	INIT_DELAYED_WORK(&fep->delay_work, fec_enet_work);
 	return 0;
 
 failed_register:
@@ -1918,6 +1937,7 @@ fec_drv_remove(struct platform_device *pdev)
 	struct resource *r;
 	int i;
 
+	cancel_delayed_work_sync(&fep->delay_work);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
 	del_timer_sync(&fep->time_keep);
diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index eb43729..a367b21 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -260,7 +260,8 @@ struct fec_enet_private {
 	int hwts_rx_en;
 	int hwts_tx_en;
 	struct timer_list time_keep;
-
+	struct delayed_work delay_work;
+	int timeout;
 };
 
 void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
-- 
1.7.1
