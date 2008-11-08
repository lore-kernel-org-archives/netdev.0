From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] e1000e: Use device_set_wakeup_enable
Date: Fri, 07 Nov 2008 22:30:00 -0800
Message-ID: <20081108063000.19150.42783.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:50431 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751587AbYKHGaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 01:30:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: \"Rafael J. Wysocki\" <rjw@sisk.pl>

Since dev->power.should_wakeup bit is used by the PCI core to
decide whether the device should wake up the system from sleep
states, set/unset this bit whenever WOL is enabled/disabled using
e1000_set_wol().  Accordingly, use device_can_wakeup() for checking
if wake-up is supported by the device.

Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    8 ++++++--
 drivers/net/e1000e/netdev.c  |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 70c11c8..bfa40d3 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1713,7 +1713,8 @@ static void e1000_get_wol(struct net_device *netdev,
 	wol->supported = 0;
 	wol->wolopts = 0;
 
-	if (!(adapter->flags & FLAG_HAS_WOL))
+	if (!(adapter->flags & FLAG_HAS_WOL) ||
+	    !device_can_wakeup(&adapter->pdev>dev))
 		return;
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
@@ -1751,7 +1752,8 @@ static int e1000_set_wol(struct net_device *netdev,
 	if (wol->wolopts & WAKE_MAGICSECURE)
 		return -EOPNOTSUPP;
 
-	if (!(adapter->flags & FLAG_HAS_WOL))
+	if (!(adapter->flags & FLAG_HAS_WOL) ||
+	    !device_can_wakeup(&adapter->pdev>dev))
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
 	/* these settings will always override what we currently have */
@@ -1770,6 +1772,8 @@ static int e1000_set_wol(struct net_device *netdev,
 	if (wol->wolopts & WAKE_ARP)
 		adapter->wol |= E1000_WUFC_ARP;
 
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+
 	return 0;
 }
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index abd492b..2c8dffd 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4970,6 +4970,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* reset the hardware with the new settings */
 	e1000e_reset(adapter);

