From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: ptp: avoid register access when ipg clock is disabled
Date: Mon, 21 Jul 2014 10:35:55 +0800
Message-ID: <1405910155-29760-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>
To: <shawn.guo@linaro.org>, <b20596@freescale.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0141.outbound.protection.outlook.com ([207.46.163.141]:45972
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752326AbaGUCmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 22:42:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FEC ptp driver start one period timer to read 1588 counter register in the
ptp init function that is called after FEC driver is probed.

To save power, after FEC probe finish, FEC driver disable all clocks including
ipg clock that is needed for register access.

i.MX5x, i.MX6q/dl/sl FEC register access don't cause system hang when ipg clock
is disabled, just return zero value. But for i.MX6sx SOC, it cause system hang.

To avoid the issue, we need to check ptp stack is on, and then start to do ptp
init and start period timer to read 1588 timer counter. After FEC is stopped,
it needs to cancel the period timer.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |    1 +
 drivers/net/ethernet/freescale/fec_main.c |    5 ++++-
 drivers/net/ethernet/freescale/fec_ptp.c  |   21 ++++++++++++++++++++-
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index bd53caf..bca0f74 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -340,6 +340,7 @@ struct fec_enet_private {
 
 void fec_ptp_init(struct platform_device *pdev);
 void fec_ptp_start_cyclecounter(struct net_device *ndev);
+void fec_ptp_stop(struct net_device *ndev);
 int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);
 int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr);
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e0efb21..c4944e1 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -997,7 +997,7 @@ fec_restart(struct net_device *ndev)
 	writel(ecntl, fep->hwp + FEC_ECNTRL);
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 
-	if (fep->bufdesc_ex)
+	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
 		fec_ptp_start_cyclecounter(ndev);
 
 	/* Enable interrupts we wish to service */
@@ -1026,6 +1026,9 @@ fec_stop(struct net_device *ndev)
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 
+	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
+		fec_ptp_stop(ndev);
+
 	/* We have to keep ENET enabled to have MII interrupt stay working */
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
 		writel(2, fep->hwp + FEC_ECNTRL);
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 82386b2..b2e9eb4 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -128,6 +128,9 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
 	timecounter_init(&fep->tc, &fep->cc, ktime_to_ns(ktime_get_real()));
 
 	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
+
+	if (!timer_pending(&fep->time_keep))
+		add_timer(&fep->time_keep);
 }
 
 /**
@@ -390,7 +393,6 @@ void fec_ptp_init(struct platform_device *pdev)
 	fep->time_keep.data = (unsigned long)fep;
 	fep->time_keep.function = fec_time_keep;
 	fep->time_keep.expires = jiffies + HZ;
-	add_timer(&fep->time_keep);
 
 	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
 	if (IS_ERR(fep->ptp_clock)) {
@@ -398,3 +400,20 @@ void fec_ptp_init(struct platform_device *pdev)
 		pr_err("ptp_clock_register failed\n");
 	}
 }
+
+/*
+ * Cleanup routine for 1588 module.
+ * When FEC is stopped this routing is called
+ */
+void fec_ptp_stop(struct net_device *ndev)
+{
+	struct fec_enet_private *priv = netdev_priv(ndev);
+
+	writel(0, priv->hwp + FEC_ATIME_CTRL);
+	writel(FEC_T_CTRL_RESTART, priv->hwp + FEC_ATIME_CTRL);
+
+	priv->hwts_tx_en = 0;
+	priv->hwts_rx_en = 0;
+
+	del_timer_sync(&priv->time_keep);
+}
-- 
1.7.8
