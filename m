From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Correctly report Wake On LAN for 82599
	KX4 devices
Date: Thu, 19 Mar 2009 04:23:46 -0700
Message-ID: <20090319112346.11957.71479.stgit@lost.foo-projects.org>
References: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:60423 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754903AbZCSLYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:24:05 -0400
In-Reply-To: <20090319112328.11957.63213.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

ethtool isn't reporting the support level of WoL for 82599 KX4 devices.
While the device does support WoL, ethtool was never updated to properly
report the level of support, nor will it allow ethtool to modify the type
of packets to listen for.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   41 ++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3a99781..18ecba7 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -909,12 +909,50 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 static void ixgbe_get_wol(struct net_device *netdev,
                           struct ethtool_wolinfo *wol)
 {
-	wol->supported = 0;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	wol->supported = WAKE_UCAST | WAKE_MCAST |
+	                 WAKE_BCAST | WAKE_MAGIC;
 	wol->wolopts = 0;
 
+	if (!device_can_wakeup(&adapter->pdev->dev))
+		return;
+
+	if (adapter->wol & IXGBE_WUFC_EX)
+		wol->wolopts |= WAKE_UCAST;
+	if (adapter->wol & IXGBE_WUFC_MC)
+		wol->wolopts |= WAKE_MCAST;
+	if (adapter->wol & IXGBE_WUFC_BC)
+		wol->wolopts |= WAKE_BCAST;
+	if (adapter->wol & IXGBE_WUFC_MAG)
+		wol->wolopts |= WAKE_MAGIC;
+
 	return;
 }
 
+static int ixgbe_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+		return -EOPNOTSUPP;
+
+	adapter->wol = 0;
+
+	if (wol->wolopts & WAKE_UCAST)
+		adapter->wol |= IXGBE_WUFC_EX;
+	if (wol->wolopts & WAKE_MCAST)
+		adapter->wol |= IXGBE_WUFC_MC;
+	if (wol->wolopts & WAKE_BCAST)
+		adapter->wol |= IXGBE_WUFC_BC;
+	if (wol->wolopts & WAKE_MAGIC)
+		adapter->wol |= IXGBE_WUFC_MAG;
+
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+
+	return 0;
+}
+
 static int ixgbe_nway_reset(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -1031,6 +1069,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_regs_len           = ixgbe_get_regs_len,
 	.get_regs               = ixgbe_get_regs,
 	.get_wol                = ixgbe_get_wol,
+	.set_wol                = ixgbe_set_wol,
 	.nway_reset             = ixgbe_nway_reset,
 	.get_link               = ethtool_op_get_link,
 	.get_eeprom_len         = ixgbe_get_eeprom_len,

