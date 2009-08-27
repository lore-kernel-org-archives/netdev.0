From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 5/5] ucc_geth: Implement suspend/resume and Wake-On-LAN
 support
Date: Thu, 27 Aug 2009 21:35:57 +0400
Message-ID: <20090827173557.GE1580@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Timur Tabi <timur@freescale.com>,
	Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:17562 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751717AbZH0Rf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 13:35:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements suspend/resume and WOL support for UCC Ethernet
driver.

We support two wake up events: wake on PHY/link changes and wake
on magic packet.

In some CPUs (like MPC8569) QE shuts down during sleep, so magic packet
detection is unusable, and also on resume we should fully reinitialize
UCC structures.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c         |   85 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/ucc_geth.h         |    1 +
 drivers/net/ucc_geth_ethtool.c |   40 +++++++++++++++++++
 3 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d4e51ee..33ed69e 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3481,6 +3481,10 @@ static int ucc_geth_open(struct net_device *dev)
 	napi_enable(&ugeth->napi);
 	netif_start_queue(dev);
 
+	device_set_wakeup_capable(&dev->dev,
+			qe_alive_during_sleep() || ugeth->phydev->irq);
+	device_set_wakeup_enable(&dev->dev, ugeth->wol_en);
+
 	return err;
 
 err:
@@ -3545,6 +3549,85 @@ static void ucc_geth_timeout(struct net_device *dev)
 	schedule_work(&ugeth->timeout_work);
 }
 
+
+#ifdef CONFIG_PM
+
+static int ucc_geth_suspend(struct of_device *ofdev, pm_message_t state)
+{
+	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+	struct ucc_geth_private *ugeth = netdev_priv(ndev);
+
+	if (!netif_running(ndev))
+		return 0;
+
+	napi_disable(&ugeth->napi);
+
+	/*
+	 * Disable the controller, otherwise we'll wakeup on any network
+	 * activity.
+	 */
+	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
+
+	if (ugeth->wol_en & WAKE_MAGIC) {
+		setbits32(ugeth->uccf->p_uccm, UCC_GETH_UCCE_MPD);
+		setbits32(&ugeth->ug_regs->maccfg2, MACCFG2_MPE);
+		ucc_fast_enable(ugeth->uccf, COMM_DIR_RX_AND_TX);
+	} else if (!(ugeth->wol_en & WAKE_PHY)) {
+		phy_stop(ugeth->phydev);
+	}
+
+	return 0;
+}
+
+static int ucc_geth_resume(struct of_device *ofdev)
+{
+	struct net_device *ndev = dev_get_drvdata(&ofdev->dev);
+	struct ucc_geth_private *ugeth = netdev_priv(ndev);
+	int err;
+
+	if (!netif_running(ndev))
+		return 0;
+
+	if (qe_alive_during_sleep()) {
+		if (ugeth->wol_en & WAKE_MAGIC) {
+			ucc_fast_disable(ugeth->uccf, COMM_DIR_RX_AND_TX);
+			clrbits32(&ugeth->ug_regs->maccfg2, MACCFG2_MPE);
+			clrbits32(ugeth->uccf->p_uccm, UCC_GETH_UCCE_MPD);
+		}
+		ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
+	} else {
+		/*
+		 * Full reinitialization is required if QE shuts down
+		 * during sleep.
+		 */
+		ucc_geth_memclean(ugeth);
+
+		err = ucc_geth_init_mac(ugeth);
+		if (err) {
+			ugeth_err("%s: Cannot initialize MAC, aborting.",
+				  ndev->name);
+			return err;
+		}
+	}
+
+	ugeth->oldlink = 0;
+	ugeth->oldspeed = 0;
+	ugeth->oldduplex = -1;
+
+	phy_stop(ugeth->phydev);
+	phy_start(ugeth->phydev);
+
+	napi_enable(&ugeth->napi);
+	netif_start_queue(ndev);
+
+	return 0;
+}
+
+#else
+#define ucc_geth_suspend NULL
+#define ucc_geth_resume NULL
+#endif
+
 static phy_interface_t to_phy_interface(const char *phy_connection_type)
 {
 	if (strcasecmp(phy_connection_type, "mii") == 0)
@@ -3836,6 +3919,8 @@ static struct of_platform_driver ucc_geth_driver = {
 	.match_table	= ucc_geth_match,
 	.probe		= ucc_geth_probe,
 	.remove		= ucc_geth_remove,
+	.suspend	= ucc_geth_suspend,
+	.resume		= ucc_geth_resume,
 };
 
 static int __init ucc_geth_init(void)
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 195ab26..fee97ee 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -1220,6 +1220,7 @@ struct ucc_geth_private {
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
+	int wol_en;
 
 	struct device_node *node;
 };
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index 304128f..7075f26 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -359,6 +359,44 @@ uec_get_drvinfo(struct net_device *netdev,
 	drvinfo->regdump_len = uec_get_regs_len(netdev);
 }
 
+#ifdef CONFIG_PM
+
+static void uec_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct phy_device *phydev = ugeth->phydev;
+
+	if (phydev && phydev->irq)
+		wol->supported |= WAKE_PHY;
+	if (qe_alive_during_sleep())
+		wol->supported |= WAKE_MAGIC;
+
+	wol->wolopts = ugeth->wol_en;
+}
+
+static int uec_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct phy_device *phydev = ugeth->phydev;
+
+	if (wol->wolopts & ~(WAKE_PHY | WAKE_MAGIC))
+		return -EINVAL;
+	else if (wol->wolopts & WAKE_PHY && (!phydev || !phydev->irq))
+		return -EINVAL;
+	else if (wol->wolopts & WAKE_MAGIC && !qe_alive_during_sleep())
+		return -EINVAL;
+
+	ugeth->wol_en = wol->wolopts;
+	device_set_wakeup_enable(&netdev->dev, ugeth->wol_en);
+
+	return 0;
+}
+
+#else
+#define uec_get_wol NULL
+#define uec_set_wol NULL
+#endif /* CONFIG_PM */
+
 static const struct ethtool_ops uec_ethtool_ops = {
 	.get_settings           = uec_get_settings,
 	.set_settings           = uec_set_settings,
@@ -377,6 +415,8 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_sset_count		= uec_get_sset_count,
 	.get_strings            = uec_get_strings,
 	.get_ethtool_stats      = uec_get_ethtool_stats,
+	.get_wol		= uec_get_wol,
+	.set_wol		= uec_set_wol,
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev)
-- 
1.6.3.3
