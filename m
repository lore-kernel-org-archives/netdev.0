From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/9] drivers/net: don't use flush_scheduled_work()
Date: Sun, 12 Dec 2010 16:52:58 +0100
Message-ID: <1292169185-10579-3-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Jay Cliburn <jcliburn@gmail.com>,
	Michael Chan <mchan@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	e1000-devel@lists.sourceforge.net,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56675 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632Ab0LLPy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 10:54:56 -0500
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flush_scheduled_work() is on its way out.  This patch contains simple
conversions to replace flush_scheduled_work() usage with direct
cancels and flushes.

Directly cancel the used works on driver detach and flush them in
other cases.

The conversions are mostly straight forward and the only dangers are,

* Forgetting to cancel/flush one or more used works.

* Cancelling when a work should be flushed (ie. the work must be
  executed once scheduled whether the driver is detaching or not).

I've gone over the changes multiple times but it would be much
appreciated if you can review with the above points in mind.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: Divy Le Ray <divy@chelsio.com>
Cc: e1000-devel@lists.sourceforge.net
Cc: Vasanthy Kolluri <vkolluri@cisco.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Andrew Gallatin <gallatin@myri.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: David Brownell <dbrownell@users.sourceforge.net>
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/8139too.c              |    3 ++-
 drivers/net/atlx/atl2.c            |    4 ++--
 drivers/net/bcm63xx_enet.c         |    2 +-
 drivers/net/bnx2.c                 |    4 ++--
 drivers/net/cassini.c              |    4 ++--
 drivers/net/cxgb3/cxgb3_main.c     |    3 ++-
 drivers/net/e1000e/netdev.c        |    6 +++---
 drivers/net/enic/enic_main.c       |    2 +-
 drivers/net/ibm_newemac/core.c     |    2 +-
 drivers/net/irda/mcs7780.c         |    2 +-
 drivers/net/ixgb/ixgb_main.c       |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    3 +--
 drivers/net/mv643xx_eth.c          |    2 +-
 drivers/net/myri10ge/myri10ge.c    |    2 +-
 drivers/net/niu.c                  |    2 +-
 drivers/net/pxa168_eth.c           |    2 +-
 drivers/net/r8169.c                |    2 +-
 drivers/net/s2io.c                 |    6 ++++--
 drivers/net/sis190.c               |    3 ++-
 drivers/net/tg3.c                  |    4 ++--
 drivers/net/usb/sierra_net.c       |    5 ++---
 drivers/net/usb/usbnet.c           |    3 +--
 drivers/net/vmxnet3/vmxnet3_drv.c  |    2 +-
 23 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index f5166dc..98517a3 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1092,10 +1092,11 @@ err_out:
 static void __devexit rtl8139_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
+	struct rtl8139_private *tp = netdev_priv(dev);
 
 	assert (dev != NULL);
 
-	flush_scheduled_work();
+	cancel_delayed_work_sync(&tp->thread);
 
 	unregister_netdev (dev);
 
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 35b14be..4e6f4e9 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1504,8 +1504,8 @@ static void __devexit atl2_remove(struct pci_dev *pdev)
 
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_config_timer);
-
-	flush_scheduled_work();
+	cancel_work_sync(&adapter->reset_task);
+	cancel_work_sync(&adapter->link_chg_task);
 
 	unregister_netdev(netdev);
 
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index ecfef24..e94a966 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -1097,7 +1097,7 @@ static int bcm_enet_stop(struct net_device *dev)
 	enet_dma_writel(priv, 0, ENETDMA_IRMASK_REG(priv->tx_chan));
 
 	/* make sure no mib update is scheduled */
-	flush_scheduled_work();
+	cancel_work_sync(&priv->mib_update_task);
 
 	/* disable dma & mac */
 	bcm_enet_disable_dma(priv, priv->tx_chan);
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 03209a3..5c811f3 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -8393,7 +8393,7 @@ bnx2_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct bnx2 *bp = netdev_priv(dev);
 
-	flush_scheduled_work();
+	cancel_work_sync(&bp->reset_task);
 
 	unregister_netdev(dev);
 
@@ -8431,7 +8431,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 
-	flush_scheduled_work();
+	cancel_work_sync(&bp->reset_task);
 	bnx2_netif_stop(bp, true);
 	netif_device_detach(dev);
 	del_timer_sync(&bp->timer);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index d6b6d6a..a8a32bc 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -3880,7 +3880,7 @@ static int cas_change_mtu(struct net_device *dev, int new_mtu)
 	schedule_work(&cp->reset_task);
 #endif
 
-	flush_scheduled_work();
+	flush_work_sync(&cp->reset_task);
 	return 0;
 }
 
@@ -5177,7 +5177,7 @@ static void __devexit cas_remove_one(struct pci_dev *pdev)
 		vfree(cp->fw_data);
 
 	mutex_lock(&cp->pm_mutex);
-	flush_scheduled_work();
+	cancel_work_sync(&cp->reset_task);
 	if (cp->hw_running)
 		cas_shutdown(cp);
 	mutex_unlock(&cp->pm_mutex);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 3864617..4d538a4 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1359,6 +1359,7 @@ out:
 static int offload_close(struct t3cdev *tdev)
 {
 	struct adapter *adapter = tdev2adap(tdev);
+	struct t3c_data *td = T3C_DATA(tdev);
 
 	if (!test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
 		return 0;
@@ -1369,7 +1370,7 @@ static int offload_close(struct t3cdev *tdev)
 	sysfs_remove_group(&tdev->lldev->dev.kobj, &offload_attr_group);
 
 	/* Flush work scheduled while releasing TIDs */
-	flush_scheduled_work();
+	flush_work_sync(&td->tid_release_task);
 
 	tdev->lldev = NULL;
 	cxgb3_set_dummy_ops(tdev);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5530d0b..02d093d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -6028,8 +6028,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	bool down = test_bit(__E1000_DOWN, &adapter->state);
 
 	/*
-	 * flush_scheduled work may reschedule our watchdog task, so
-	 * explicitly disable watchdog tasks from being rescheduled
+	 * The timers may be rescheduled, so explicitly disable them
+	 * from being rescheduled.
 	 */
 	if (!down)
 		set_bit(__E1000_DOWN, &adapter->state);
@@ -6040,8 +6040,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	cancel_work_sync(&adapter->watchdog_task);
 	cancel_work_sync(&adapter->downshift_task);
 	cancel_work_sync(&adapter->update_phy_task);
+	cancel_work_sync(&adapter->led_blink_task);
 	cancel_work_sync(&adapter->print_hang_task);
-	flush_scheduled_work();
 
 	if (!(netdev->flags & IFF_UP))
 		e1000_power_down_phy(adapter);
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 9befd54..77d9138 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2834,7 +2834,7 @@ static void __devexit enic_remove(struct pci_dev *pdev)
 	if (netdev) {
 		struct enic *enic = netdev_priv(netdev);
 
-		flush_scheduled_work();
+		cancel_work_sync(&enic->reset);
 		unregister_netdev(netdev);
 		enic_dev_deinit(enic);
 		vnic_dev_close(enic->vdev);
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 06bb9b7..8f11d29 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2950,7 +2950,7 @@ static int __devexit emac_remove(struct platform_device *ofdev)
 
 	unregister_netdev(dev->ndev);
 
-	flush_scheduled_work();
+	cancel_work_sync(&dev->reset_work);
 
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_detach(dev->tah_dev, dev->tah_port);
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 74b20f1..cc821de 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -959,7 +959,7 @@ static void mcs_disconnect(struct usb_interface *intf)
 	if (!mcs)
 		return;
 
-	flush_scheduled_work();
+	cancel_work_sync(&mcs->work);
 
 	unregister_netdev(mcs->netdev);
 	free_netdev(mcs->netdev);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 2e98506..b021798 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -527,7 +527,7 @@ ixgb_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	flush_scheduled_work();
+	cancel_work_sync(&adapter->tx_timeout_task);
 
 	unregister_netdev(netdev);
 
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 2216a3c..809e38c 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3484,10 +3484,9 @@ static void __devexit ixgbevf_remove(struct pci_dev *pdev)
 
 	del_timer_sync(&adapter->watchdog_timer);
 
+	cancel_work_sync(&adapter->reset_task);
 	cancel_work_sync(&adapter->watchdog_task);
 
-	flush_scheduled_work();
-
 	if (adapter->netdev_registered) {
 		unregister_netdev(netdev);
 		adapter->netdev_registered = false;
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index ce31e74..02076e1 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2978,7 +2978,7 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 	unregister_netdev(mp->dev);
 	if (mp->phy != NULL)
 		phy_detach(mp->phy);
-	flush_scheduled_work();
+	cancel_work_sync(&mp->tx_timeout_task);
 	free_netdev(mp->dev);
 
 	platform_set_drvdata(pdev, NULL);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 8524cc4..1ce0207 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -4067,7 +4067,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	if (mgp == NULL)
 		return;
 
-	flush_scheduled_work();
+	cancel_work_sync(&mgp->watchdog_work);
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 781e368..f64c424 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9917,7 +9917,7 @@ static int niu_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 
-	flush_scheduled_work();
+	flush_work_sync(&np->reset_task);
 	niu_netif_stop(np);
 
 	del_timer_sync(&np->timer);
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 04ed27d..1b63c8a 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1602,7 +1602,7 @@ static int pxa168_eth_remove(struct platform_device *pdev)
 	mdiobus_unregister(pep->smi_bus);
 	mdiobus_free(pep->smi_bus);
 	unregister_netdev(dev);
-	flush_scheduled_work();
+	cancel_work_sync(&pep->tx_timeout_task);
 	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
 	return 0;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d33ef4..98d792c 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3240,7 +3240,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	flush_scheduled_work();
+	cancel_delayed_work_sync(&tp->task);
 
 	unregister_netdev(dev);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 9a1e32f..39c17ce 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8341,9 +8341,11 @@ static void __devexit s2io_rem_nic(struct pci_dev *pdev)
 		return;
 	}
 
-	flush_scheduled_work();
-
 	sp = netdev_priv(dev);
+
+	cancel_work_sync(&sp->rst_timer_task);
+	cancel_work_sync(&sp->set_link_task);
+
 	unregister_netdev(dev);
 
 	free_shared_mem(sp);
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index a5d6a6b..3406ed8 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1915,9 +1915,10 @@ err_release_board:
 static void __devexit sis190_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct sis190_private *tp = netdev_priv(dev);
 
 	sis190_mii_remove(dev);
-	flush_scheduled_work();
+	cancel_work_sync(&tp->phy_task);
 	unregister_netdev(dev);
 	sis190_release_board(pdev);
 	pci_set_drvdata(pdev, NULL);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5faa87d..57e19fb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -15034,7 +15034,7 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 		if (tp->fw)
 			release_firmware(tp->fw);
 
-		flush_scheduled_work();
+		cancel_work_sync(&tp->reset_task);
 
 		if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
 			tg3_phy_fini(tp);
@@ -15073,7 +15073,7 @@ static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 
-	flush_scheduled_work();
+	flush_work_sync(&tp->reset_task);
 	tg3_phy_stop(tp);
 	tg3_netif_stop(tp);
 
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index d1ac15c..ed1b432 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -802,10 +802,9 @@ static void sierra_net_unbind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev_dbg(&dev->udev->dev, "%s", __func__);
 
-	/* Kill the timer then flush the work queue */
+	/* kill the timer and work */
 	del_timer_sync(&priv->sync_timer);
-
-	flush_scheduled_work();
+	cancel_work_sync(&priv->sierra_net_kevent);
 
 	/* tell modem we are going away */
 	status = sierra_net_send_cmd(dev, priv->shdwn_msg,
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index cff74b8..ed9a416 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1248,8 +1248,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	net = dev->net;
 	unregister_netdev (net);
 
-	/* we don't hold rtnl here ... */
-	flush_scheduled_work ();
+	cancel_work_sync(&dev->kevent);
 
 	if (dev->driver_info->unbind)
 		dev->driver_info->unbind (dev, intf);
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 65860a9..0169be7 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3069,7 +3069,7 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 #endif
 		num_rx_queues = 1;
 
-	flush_scheduled_work();
+	cancel_work_sync(&adapter->work);
 
 	unregister_netdev(netdev);
 
-- 
1.7.1

