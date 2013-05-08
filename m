From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug cable many times
Date: Wed, 8 May 2013 08:08:44 +0800
Message-ID: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <romieu@fr.zoreil.com>, <r.schwebel@pengutronix.de>,
	<davem@davemloft.net>, <l.stach@pengutronix.de>,
	<netdev@vger.kernel.org>, <festevam@gmail.com>,
	<shawn.guo@linaro.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe004.messaging.microsoft.com ([216.32.180.187]:5338
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750833Ab3EHBdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 21:33:51 -0400
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
Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
Tested-by: Lucas Stach <l.stach@pengutronix.de>
---
Change from v1 to v2
 * Add netif_tx_lock(ndev) to avoid xmit runing when reset hardware
Change from v2 to v3
 * Move put real statements after function variable declarations according to David's comments
 * Remove lock in adjust_link according to Lucas Stach's comments
Change from v3 to v4
 * rebase to latest net/master
 * remove hw_lock because not used again
 * reduce delay work to 0
 * group delay work related feild to one structure
 * call netif_device_detach() in fec_restart
Change from v4 to v5
 * use true/false instead of 1/0

 drivers/net/ethernet/freescale/fec.h      |   10 ++++--
 drivers/net/ethernet/freescale/fec_main.c |   44 +++++++++++++++++++++-------
 2 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index d44f65b..afa7b5b 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -198,6 +198,11 @@ struct bufdesc_ex {
 #define FLAG_RX_CSUM_ENABLED	(BD_ENET_RX_ICE | BD_ENET_RX_PCR)
 #define FLAG_RX_CSUM_ERROR	(BD_ENET_RX_ICE | BD_ENET_RX_PCR)
 
+struct fec_enet_delayed_work {
+	struct delayed_work delay_work;
+	bool timeout;
+};
+
 /* The FEC buffer descriptors track the ring buffers.  The rx_bd_base and
  * tx_bd_base always point to the base of the buffer descriptors.  The
  * cur_rx and cur_tx point to the currently available buffer.
@@ -231,9 +236,6 @@ struct fec_enet_private {
 	/* The ring entries to be free()ed */
 	struct bufdesc	*dirty_tx;
 
-	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
-	spinlock_t hw_lock;
-
 	struct	platform_device *pdev;
 
 	int	opened;
@@ -268,7 +270,7 @@ struct fec_enet_private {
 	int hwts_rx_en;
 	int hwts_tx_en;
 	struct timer_list time_keep;
-
+	struct fec_enet_delayed_work delay_work;
 };
 
 void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index b9748f1..d028830 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -445,6 +445,13 @@ fec_restart(struct net_device *ndev, int duplex)
 	u32 rcntl = OPT_FRAME_SIZE | 0x04;
 	u32 ecntl = 0x2; /* ETHEREN */
 
+	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		napi_disable(&fep->napi);
+		netif_stop_queue(ndev);
+		netif_tx_lock(ndev);
+	}
+
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
 	udelay(10);
@@ -605,6 +612,13 @@ fec_restart(struct net_device *ndev, int duplex)
 
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+	if (netif_running(ndev)) {
+		netif_device_attach(ndev);
+		napi_enable(&fep->napi);
+		netif_wake_queue(ndev);
+		netif_tx_unlock(ndev);
+	}
 }
 
 static void
@@ -644,8 +658,22 @@ fec_timeout(struct net_device *ndev)
 
 	ndev->stats.tx_errors++;
 
-	fec_restart(ndev, fep->full_duplex);
-	netif_wake_queue(ndev);
+	fep->delay_work.timeout = true;
+	schedule_delayed_work(&(fep->delay_work.delay_work), 0);
+}
+
+static void fec_enet_work(struct work_struct *work)
+{
+	struct fec_enet_private *fep =
+		container_of(work,
+			     struct fec_enet_private,
+			     delay_work.delay_work.work);
+
+	if (fep->delay_work.timeout) {
+		fep->delay_work.timeout = false;
+		fec_restart(fep->netdev, fep->full_duplex);
+		netif_wake_queue(fep->netdev);
+	}
 }
 
 static void
@@ -1024,16 +1052,12 @@ static void fec_enet_adjust_link(struct net_device *ndev)
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
+		return;
 	}
 
 	if (phy_dev->link) {
@@ -1061,9 +1085,6 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 		}
 	}
 
-spin_unlock:
-	spin_unlock_irqrestore(&fep->hw_lock, flags);
-
 	if (status_change)
 		phy_print_status(phy_dev);
 }
@@ -1732,7 +1753,6 @@ static int fec_enet_init(struct net_device *ndev)
 		return -ENOMEM;
 
 	memset(cbd_base, 0, PAGE_SIZE);
-	spin_lock_init(&fep->hw_lock);
 
 	fep->netdev = ndev;
 
@@ -1947,6 +1967,7 @@ fec_probe(struct platform_device *pdev)
 	if (fep->bufdesc_ex && fep->ptp_clock)
 		netdev_info(ndev, "registered PHC device %d\n", fep->dev_id);
 
+	INIT_DELAYED_WORK(&(fep->delay_work.delay_work), fec_enet_work);
 	return 0;
 
 failed_register:
@@ -1979,6 +2000,7 @@ fec_drv_remove(struct platform_device *pdev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int i;
 
+	cancel_delayed_work_sync(&(fep->delay_work.delay_work));
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
 	del_timer_sync(&fep->time_keep);
-- 
1.7.1
