From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg clock is disabled
Date: Wed, 13 Aug 2014 12:55:05 +0800
Message-ID: <1407905705-27984-2-git-send-email-b38611@freescale.com>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>,
	<richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0244.outbound.protection.outlook.com ([207.46.163.244]:9447
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750742AbaHMFJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 01:09:42 -0400
In-Reply-To: <1407905705-27984-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current kernel hang on i.MX6SX with rootfs mount from MMC.
The root cause is ptp rise up period timer to access enet register
even if ipg clock is disabled.

FEC ptp driver start one period timer to read 1588 counter register in the
ptp init function that is called after FEC driver is probed.

To save power, after FEC probe finish, FEC driver disable all clocks including
ipg clock that is needed for register access.

i.MX5x, i.MX6q/dl/sl FEC register access don't cause system hang when ipg clock
is disabled, just return zero value. But for i.MX6sx SOC, it cause system hang.

To avoid the issue, we need to check ptp stack running status. If ptp4l run up,
and then schdule one delayed work to read ptp counter register. If ptp4l stack
is down, cancel the period delayed work. For ethx interface open/close, fec
suspend/resume situations, schdule/cancel the delayed work.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    2 +-
 drivers/net/ethernet/freescale/fec_main.c |   12 +++++++++++-
 drivers/net/ethernet/freescale/fec_ptp.c  |   15 +++++++--------
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index bd53caf..03fad35 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -334,7 +334,7 @@ struct fec_enet_private {
 	u32 cycle_speed;
 	int hwts_rx_en;
 	int hwts_tx_en;
-	struct timer_list time_keep;
+	struct delayed_work time_keep;
 	struct regulator *reg_phy;
 };
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 66fe1f6..8befa2c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2198,6 +2198,8 @@ fec_enet_open(struct net_device *ndev)
 	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_start_queue(ndev);
+	if (fep->hwts_tx_en)
+		schedule_delayed_work(&fep->time_keep, HZ);
 	return 0;
 }
 
@@ -2206,6 +2208,9 @@ fec_enet_close(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	if (fep->hwts_tx_en)
+		cancel_delayed_work_sync(&fep->time_keep);
+
 	phy_stop(fep->phy_dev);
 
 	if (netif_device_present(ndev)) {
@@ -2682,10 +2687,11 @@ fec_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	if (fep->hwts_tx_en)
+		cancel_delayed_work_sync(&fep->time_keep);
 	cancel_work_sync(&fep->tx_timeout_work);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
-	del_timer_sync(&fep->time_keep);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 	if (fep->ptp_clock)
@@ -2703,6 +2709,8 @@ static int __maybe_unused fec_suspend(struct device *dev)
 
 	rtnl_lock();
 	if (netif_running(ndev)) {
+		if (fep->hwts_tx_en)
+			cancel_delayed_work_sync(&fep->time_keep);
 		phy_stop(fep->phy_dev);
 		napi_disable(&fep->napi);
 		netif_tx_lock_bh(ndev);
@@ -2746,6 +2754,8 @@ static int __maybe_unused fec_resume(struct device *dev)
 		netif_tx_unlock_bh(ndev);
 		napi_enable(&fep->napi);
 		phy_start(fep->phy_dev);
+		if (fep->hwts_tx_en)
+			schedule_delayed_work(&fep->time_keep, HZ);
 	}
 	rtnl_unlock();
 
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 82386b2..281f4f8 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -289,9 +289,11 @@ int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr)
 	switch (config.tx_type) {
 	case HWTSTAMP_TX_OFF:
 		fep->hwts_tx_en = 0;
+		cancel_delayed_work_sync(&fep->time_keep);
 		break;
 	case HWTSTAMP_TX_ON:
 		fep->hwts_tx_en = 1;
+		schedule_delayed_work(&fep->time_keep, HZ);
 		break;
 	default:
 		return -ERANGE;
@@ -338,9 +340,10 @@ int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr)
  * fec_time_keep - call timecounter_read every second to avoid timer overrun
  *                 because ENET just support 32bit counter, will timeout in 4s
  */
-static void fec_time_keep(unsigned long _data)
+static void fec_time_keep(struct work_struct *work)
 {
-	struct fec_enet_private *fep = (struct fec_enet_private *)_data;
+	struct delayed_work *dwork = to_delayed_work(work);
+	struct fec_enet_private *fep = container_of(dwork, struct fec_enet_private, time_keep);
 	u64 ns;
 	unsigned long flags;
 
@@ -348,7 +351,7 @@ static void fec_time_keep(unsigned long _data)
 	ns = timecounter_read(&fep->tc);
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
 
-	mod_timer(&fep->time_keep, jiffies + HZ);
+	schedule_delayed_work(&fep->time_keep, HZ);
 }
 
 /**
@@ -386,11 +389,7 @@ void fec_ptp_init(struct platform_device *pdev)
 
 	fec_ptp_start_cyclecounter(ndev);
 
-	init_timer(&fep->time_keep);
-	fep->time_keep.data = (unsigned long)fep;
-	fep->time_keep.function = fec_time_keep;
-	fep->time_keep.expires = jiffies + HZ;
-	add_timer(&fep->time_keep);
+	INIT_DELAYED_WORK(&fep->time_keep, fec_time_keep);
 
 	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
 	if (IS_ERR(fep->ptp_clock)) {
-- 
1.7.8
