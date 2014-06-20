From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 14/30] net: fec: improve safety of suspend/resume/transmit
 timeout paths
Date: Fri, 20 Jun 2014 13:12:54 +0100
Message-ID: <E1Wxxgc-0005Xk-NL@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36357 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S967259AbaFTMM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:12:57 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should hold the rtnl lock while suspending, resuming or processing
the transmit timeout to ensure that nothing will interfere while we
bring up, take down or restart the hardware.  The transmit timeout
could run if we're preempted during suspend.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5cc9eea6d8b3..caf0854b7e4f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1068,8 +1068,10 @@ static void fec_enet_work(struct work_struct *work)
 
 	if (fep->delay_work.timeout) {
 		fep->delay_work.timeout = false;
+		rtnl_lock();
 		fec_restart(fep->netdev, fep->full_duplex);
 		netif_wake_queue(fep->netdev);
+		rtnl_unlock();
 	}
 
 	if (fep->delay_work.trig_tx) {
@@ -2681,11 +2683,14 @@ fec_suspend(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	rtnl_lock();
 	if (netif_running(ndev)) {
 		phy_stop(fep->phy_dev);
 		fec_stop(ndev);
 		netif_device_detach(ndev);
 	}
+	rtnl_unlock();
+
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
 
@@ -2713,11 +2718,13 @@ fec_resume(struct device *dev)
 	if (ret)
 		goto failed_clk;
 
+	rtnl_lock();
 	if (netif_running(ndev)) {
 		fec_restart(ndev, fep->full_duplex);
 		netif_device_attach(ndev);
 		phy_start(fep->phy_dev);
 	}
+	rtnl_unlock();
 
 	return 0;
 
-- 
1.8.3.1
