From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] igb: Use device_set_wakeup_enable
Date: Fri, 07 Nov 2008 22:30:37 -0800
Message-ID: <20081108063037.19150.26825.stgit@gitlost.lost>
References: <20081108063000.19150.42783.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:54242 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751790AbYKHGaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 01:30:55 -0500
In-Reply-To: <20081108063000.19150.42783.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: \"Rafael J. Wysocki\" <rjw@sisk.pl>

Since dev->power.should_wakeup bit is used by the PCI core to
decide whether the device should wake up the system from sleep
states, set/unset this bit whenever WOL is enabled/disabled using
igb_set_wol().  Accordingly, use device_can_wakeup() for checking
if wake-up is supported by the device.

Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    8 ++++++--
 drivers/net/igb/igb_main.c    |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 58906c9..89964fa 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1776,7 +1776,8 @@ static void igb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 
 	/* this function will set ->supported = 0 and return 1 if wol is not
 	 * supported by this hardware */
-	if (igb_wol_exclusion(adapter, wol))
+	if (igb_wol_exclusion(adapter, wol) ||
+	    !device_can_wakeup(&adapter->pdev->dev))
 		return;
 
 	/* apply any specific unsupported masks here */
@@ -1805,7 +1806,8 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
 		return -EOPNOTSUPP;
 
-	if (igb_wol_exclusion(adapter, wol))
+	if (igb_wol_exclusion(adapter, wol) ||
+	    !device_can_wakeup(&adapter->pdev->dev))
 		return wol->wolopts ? -EOPNOTSUPP : 0;
 
 	switch (hw->device_id) {
@@ -1825,6 +1827,8 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= E1000_WUFC_MAG;
 
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
+
 	return 0;
 }
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1f397cd..0a98015 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1244,6 +1244,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* initialize the wol settings based on the eeprom settings */
 	adapter->wol = adapter->eeprom_wol;
+	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	/* reset the hardware with the new settings */
 	igb_reset(adapter);

