From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] sky2: cleanup restart operations
Date: Fri, 14 Aug 2009 08:15:17 -0700
Message-ID: <20090814151608.358192621@vyatta.com>
References: <20090814151511.992669598@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44118 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932519AbZHNPTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 11:19:51 -0400
Content-Disposition: inline; filename=sky2-tx4a.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This unifies the places that bounce the device (suspend/resume
and restart). And makes the operations have the same semantics
as normal dev_open/dev_stop.

This also avoids setting the multicast addresses twice when
device is brought up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |  120 +++++++++++++++++++++++++----------------------------
 1 file changed, 57 insertions(+), 63 deletions(-)

--- a/drivers/net/sky2.c	2009-08-14 07:58:47.421479764 -0700
+++ b/drivers/net/sky2.c	2009-08-14 07:58:48.448220547 -0700
@@ -1498,10 +1498,9 @@ static int sky2_up(struct net_device *de
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
 
-	sky2_set_multicast(dev);
-
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
+
 	return 0;
 
 err_out:
@@ -3076,18 +3075,46 @@ static void sky2_reset(struct sky2_hw *h
 	sky2_write8(hw, STAT_ISR_TIMER_CTRL, TIM_START);
 }
 
+/* Take device down (offline).
+ * Equivalent to doing dev_stop() but this does not
+ * inform upper layers of the transistion.
+ */
+static void sky2_detach(struct net_device *dev)
+{
+	if (netif_running(dev)) {
+		netif_device_detach(dev);	/* stop txq */
+		sky2_down(dev);
+	}
+}
+
+/* Bring device back after doing sky2_detach */
+static int sky2_reattach(struct net_device *dev)
+{
+	int err = 0;
+
+	if (netif_running(dev)) {
+		err = sky2_up(dev);
+		if (err) {
+			printk(KERN_INFO PFX "%s: could not restart %d\n",
+			       dev->name, err);
+			dev_close(dev);
+		} else {
+			netif_device_attach(dev);
+			sky2_set_multicast(dev);
+		}
+	}
+
+	return err;
+}
+
 static void sky2_restart(struct work_struct *work)
 {
 	struct sky2_hw *hw = container_of(work, struct sky2_hw, restart_work);
-	struct net_device *dev;
-	int i, err;
+	int i;
 
 	rtnl_lock();
-	for (i = 0; i < hw->ports; i++) {
-		dev = hw->dev[i];
-		if (netif_running(dev))
-			sky2_down(dev);
-	}
+	for (i = 0; i < hw->ports; i++)
+		sky2_detach(hw->dev[i]);
 
 	napi_disable(&hw->napi);
 	sky2_write32(hw, B0_IMSK, 0);
@@ -3095,17 +3122,8 @@ static void sky2_restart(struct work_str
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
 
-	for (i = 0; i < hw->ports; i++) {
-		dev = hw->dev[i];
-		if (netif_running(dev)) {
-			err = sky2_up(dev);
-			if (err) {
-				printk(KERN_INFO PFX "%s: could not restart %d\n",
-				       dev->name, err);
-				dev_close(dev);
-			}
-		}
-	}
+	for (i = 0; i < hw->ports; i++)
+		sky2_reattach(hw->dev[i]);
 
 	rtnl_unlock();
 }
@@ -3694,7 +3712,6 @@ static int sky2_set_ringparam(struct net
 			      struct ethtool_ringparam *ering)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	int err = 0;
 
 	if (ering->rx_pending > RX_MAX_PENDING ||
 	    ering->rx_pending < 8 ||
@@ -3702,19 +3719,12 @@ static int sky2_set_ringparam(struct net
 	    ering->tx_pending > TX_RING_SIZE - 1)
 		return -EINVAL;
 
-	if (netif_running(dev))
-		sky2_down(dev);
+	sky2_detach(dev);
 
 	sky2->rx_pending = ering->rx_pending;
 	sky2->tx_pending = ering->tx_pending;
 
-	if (netif_running(dev)) {
-		err = sky2_up(dev);
-		if (err)
-			dev_close(dev);
-	}
-
-	return err;
+	return sky2_reattach(dev);
 }
 
 static int sky2_get_regs_len(struct net_device *dev)
@@ -4636,9 +4646,7 @@ static int sky2_suspend(struct pci_dev *
 		struct net_device *dev = hw->dev[i];
 		struct sky2_port *sky2 = netdev_priv(dev);
 
-		netif_device_detach(dev);
-		if (netif_running(dev))
-			sky2_down(dev);
+		sky2_detach(dev);
 
 		if (sky2->wol)
 			sky2_wol_init(sky2);
@@ -4686,25 +4694,18 @@ static int sky2_resume(struct pci_dev *p
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
 
+	rtnl_lock();
 	for (i = 0; i < hw->ports; i++) {
-		struct net_device *dev = hw->dev[i];
-
-		netif_device_attach(dev);
-		if (netif_running(dev)) {
-			err = sky2_up(dev);
-			if (err) {
-				printk(KERN_ERR PFX "%s: could not up: %d\n",
-				       dev->name, err);
-				rtnl_lock();
-				dev_close(dev);
-				rtnl_unlock();
-				goto out;
-			}
-		}
+		err = sky2_reattach(hw->dev[i]);
+		if (err)
+			goto out;
 	}
+	rtnl_unlock();
 
 	return 0;
 out:
+	rtnl_unlock();
+
 	dev_err(&pdev->dev, "resume failed (%d)\n", err);
 	pci_disable_device(pdev);
 	return err;

-- 

