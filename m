From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv1] e1000e: Allow ethtool to enable/disable loopback.
Date: Wed, 11 May 2011 12:03:45 -0700
Message-ID: <1305140625-25888-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21182 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab1EKTEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 15:04:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds e1000_set_features() to handle loopback mode. When loopback
is enabled, it enables internal-MAC loopback.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |   34 ++++++++++++++++++++++++++++++++++
 drivers/net/e1000e/netdev.c  |   21 +++++++++++++++++++++
 drivers/net/e1000e/phy.c     |   19 +++++++++++++++----
 4 files changed, 71 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 9549879..9db3037 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -640,6 +640,7 @@ extern s32 e1000_check_polarity_ife(struct e1000_hw *hw);
 extern s32 e1000_phy_force_speed_duplex_ife(struct e1000_hw *hw);
 extern s32 e1000_check_polarity_igp(struct e1000_hw *hw);
 extern bool e1000_check_phy_82574(struct e1000_hw *hw);
+extern int e1000_set_loopback(struct net_device *dev, u32 features);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 859d0d3..9c26b42 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -2027,6 +2027,40 @@ static int e1000e_set_flags(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+int e1000_set_loopback(struct net_device *netdev, u32 features)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	uint16_t reg = 0;
+	int retval = 0;
+
+	if ((retval = e1e_rphy(hw, PHY_CONTROL, &reg)) > 0)
+		return retval;
+
+	if (features & NETIF_F_LOOPBACK) {
+		if (reg & MII_CR_LOOPBACK)
+			return 0;
+
+		retval = e1000_setup_loopback_test(adapter);
+		if (retval)
+			return retval;
+
+		netdev_info(netdev,
+			"e1000e: Internal PHY loopback mode enabled.\n");
+	} else {
+		if (!(reg & MII_CR_LOOPBACK))
+			return 0;
+
+		e1000_loopback_cleanup(adapter);
+		e1000e_down(adapter);
+		e1000e_up(adapter);
+		netdev_info(netdev,
+			"e1000e: Internal PHY loopback mode disabled.\n");
+	}
+
+	return retval;
+}
+
 static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_settings		= e1000_get_settings,
 	.set_settings		= e1000_set_settings,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0939040..6aee9b19 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3688,6 +3688,13 @@ static int e1000_open(struct net_device *netdev)
 	else
 		ew32(ICS, E1000_ICS_LSC);
 
+	/*
+	 * If loopback was enabled while the device was down,
+	 * make sure it gets installed properly now.
+	 */
+	if (netdev->features & NETIF_F_LOOPBACK)
+		e1000_set_loopback(netdev, netdev->features);
+
 	return 0;
 
 err_req_irq:
@@ -5623,6 +5630,16 @@ static void e1000_netpoll(struct net_device *netdev)
 }
 #endif
 
+static int e1000_set_features(struct net_device *dev, u32 features)
+{
+	u32 changed = dev->features ^ features;
+
+	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev))
+		e1000_set_loopback(dev, features);
+
+	return 0;
+}
+
 /**
  * e1000_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
@@ -5789,6 +5806,7 @@ static const struct net_device_ops e1000e_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= e1000_netpoll,
 #endif
+	.ndo_set_features	= e1000_set_features,
 };
 
 /**
@@ -6093,6 +6111,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	e1000_print_device_info(adapter);
 
+	/* Add loopback capability to the device. */
+	netdev->hw_features |= NETIF_F_LOOPBACK;
+
 	if (pci_dev_run_wake(pdev))
 		pm_runtime_put_noidle(&pdev->dev);
 
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 484774c..9bc5df3 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1758,7 +1758,7 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			       u32 usec_interval, bool *success)
 {
 	s32 ret_val = 0;
-	u16 i, phy_status;
+	u16 i, reg;
 
 	for (i = 0; i < iterations; i++) {
 		/*
@@ -1766,7 +1766,7 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 		 * twice due to the link bit being sticky.  No harm doing
 		 * it across the board.
 		 */
-		ret_val = e1e_rphy(hw, PHY_STATUS, &phy_status);
+		ret_val = e1e_rphy(hw, PHY_STATUS, &reg);
 		if (ret_val)
 			/*
 			 * If the first read fails, another entity may have
@@ -1774,10 +1774,10 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 			 * see if they have relinquished the resources yet.
 			 */
 			udelay(usec_interval);
-		ret_val = e1e_rphy(hw, PHY_STATUS, &phy_status);
+		ret_val = e1e_rphy(hw, PHY_STATUS, &reg);
 		if (ret_val)
 			break;
-		if (phy_status & MII_SR_LINK_STATUS)
+		if (reg & MII_SR_LINK_STATUS)
 			break;
 		if (usec_interval >= 1000)
 			mdelay(usec_interval/1000);
@@ -1787,6 +1787,17 @@ s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
 
 	*success = (i < iterations);
 
+	/*
+	 * If the device is in loopback mode, we have to fake
+	 * link up. Try this only if link isn't present.
+	 */
+	if (!(*success) && !e1e_rphy(hw, PHY_CONTROL, &reg) &&
+		(reg & MII_CR_LOOPBACK)) {
+		/* Fake link up. */
+		*success = true;
+		ret_val = 0;
+	}
+
 	return ret_val;
 }
 
-- 
1.7.3.1

