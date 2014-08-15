From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg clock is disabled
Date: Fri, 15 Aug 2014 13:52:55 +0800
Message-ID: <1408081975-15087-2-git-send-email-b38611@freescale.com>
References: <1408081975-15087-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<b38611@freescale.com>
To: <richardcochran@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0211.outbound.protection.outlook.com ([207.46.163.211]:55298
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751729AbaHOGI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 02:08:28 -0400
In-Reply-To: <1408081975-15087-1-git-send-email-b38611@freescale.com>
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

To avoid the issue, we need to check ptp clock status before ptp timer count access.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    3 ++-
 drivers/net/ethernet/freescale/fec_main.c |    8 ++++++--
 drivers/net/ethernet/freescale/fec_ptp.c  |   27 ++++++++++++++++-----------
 3 files changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index bd53caf..ee0879f 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -274,6 +274,7 @@ struct fec_enet_private {
 	struct clk *clk_ahb;
 	struct clk *clk_enet_out;
 	struct clk *clk_ptp;
+	bool ptp_clk_on;
 
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). */
 	unsigned char *tx_bounce[TX_RING_SIZE];
@@ -334,7 +335,7 @@ struct fec_enet_private {
 	u32 cycle_speed;
 	int hwts_rx_en;
 	int hwts_tx_en;
-	struct timer_list time_keep;
+	struct delayed_work time_keep;
 	struct regulator *reg_phy;
 };
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 66fe1f6..ba35994 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1613,14 +1613,18 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
 			ret = clk_prepare_enable(fep->clk_ptp);
 			if (ret)
 				goto failed_clk_ptp;
+			else
+				fep->ptp_clk_on = true;
 		}
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
 		clk_disable_unprepare(fep->clk_ipg);
 		if (fep->clk_enet_out)
 			clk_disable_unprepare(fep->clk_enet_out);
-		if (fep->clk_ptp)
+		if (fep->clk_ptp) {
 			clk_disable_unprepare(fep->clk_ptp);
+			fep->ptp_clk_on = false;
+		}
 	}
 
 	return 0;
@@ -2682,10 +2686,10 @@ fec_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	cancel_delayed_work_sync(&fep->time_keep);
 	cancel_work_sync(&fep->tx_timeout_work);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
-	del_timer_sync(&fep->time_keep);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 	if (fep->ptp_clock)
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 82386b2..8084aaf 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -245,6 +245,10 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
 	u64 ns;
 	unsigned long flags;
 
+	/* Check the ptp clock */
+	if (!fep->ptp_clk_on)
+		return -EINVAL;
+
 	ns = ts->tv_sec * 1000000000ULL;
 	ns += ts->tv_nsec;
 
@@ -338,17 +342,20 @@ int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr)
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
 
-	spin_lock_irqsave(&fep->tmreg_lock, flags);
-	ns = timecounter_read(&fep->tc);
-	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+	if (fep->ptp_clk_on) {
+		spin_lock_irqsave(&fep->tmreg_lock, flags);
+		ns = timecounter_read(&fep->tc);
+		spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+	}
 
-	mod_timer(&fep->time_keep, jiffies + HZ);
+	schedule_delayed_work(&fep->time_keep, HZ);
 }
 
 /**
@@ -386,15 +393,13 @@ void fec_ptp_init(struct platform_device *pdev)
 
 	fec_ptp_start_cyclecounter(ndev);
 
-	init_timer(&fep->time_keep);
-	fep->time_keep.data = (unsigned long)fep;
-	fep->time_keep.function = fec_time_keep;
-	fep->time_keep.expires = jiffies + HZ;
-	add_timer(&fep->time_keep);
+	INIT_DELAYED_WORK(&fep->time_keep, fec_time_keep);
 
 	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
 	if (IS_ERR(fep->ptp_clock)) {
 		fep->ptp_clock = NULL;
 		pr_err("ptp_clock_register failed\n");
 	}
+
+	schedule_delayed_work(&fep->time_keep, HZ);
 }
-- 
1.7.8
