From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1] net: fec: fix kernel oops when plug/unplug cable many times
Date: Sun, 28 Apr 2013 11:04:47 +0800
Message-ID: <1367118287-12175-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <romieu@fr.zoreil.com>, <r.schwebel@pengutronix.de>,
	<davem@davemloft.net>, <l.stach@pengutronix.de>,
	<netdev@vger.kernel.org>, <festevam@gmail.com>,
	<shawn.guo@linaro.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:25195
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750725Ab3D1E0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 00:26:45 -0400
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
 drivers/net/ethernet/freescale/fec.c |   39 ++++++++++++++++++++++++++++-----
 drivers/net/ethernet/freescale/fec.h |    3 +-
 2 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 73195f6..9128a3c 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -403,6 +403,11 @@ fec_restart(struct net_device *ndev, int duplex)
 	const struct platform_device_id *id_entry =
 				platform_get_device_id(fep->pdev);
 	int i;
+	if (netif_running(ndev)) {
+		napi_disable(&fep->napi);
+		netif_stop_queue(ndev);
+	}
+
 	u32 temp_mac[2];
 	u32 rcntl = OPT_FRAME_SIZE | 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
@@ -559,6 +564,11 @@ fec_restart(struct net_device *ndev, int duplex)
 
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+	if (netif_running(ndev)) {
+		napi_enable(&fep->napi);
+		netif_wake_queue(ndev);
+	}
 }
 
 static void
@@ -598,8 +608,20 @@ fec_timeout(struct net_device *ndev)
 
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
@@ -996,9 +1018,6 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 			status_change = 1;
 		}
 
-		/* if any of the above changed restart the FEC */
-		if (status_change)
-			fec_restart(ndev, phy_dev->duplex);
 	} else {
 		if (fep->link) {
 			fec_stop(ndev);
@@ -1010,8 +1029,14 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 spin_unlock:
 	spin_unlock_irqrestore(&fep->hw_lock, flags);
 
-	if (status_change)
+	if (status_change) {
+		/* if any of the above changed restart the FEC,
+		 * fec_restart may sleep. can't call it in spin_lock
+		 */
+		if (phy_dev->link)
+			fec_restart(ndev, phy_dev->duplex);
 		phy_print_status(phy_dev);
+	}
 }
 
 static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
@@ -1882,6 +1907,7 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
+	INIT_DELAYED_WORK(&fep->delay_work, fec_enet_work);
 	return 0;
 
 failed_register:
@@ -1918,6 +1944,7 @@ fec_drv_remove(struct platform_device *pdev)
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
