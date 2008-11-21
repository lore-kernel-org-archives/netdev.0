From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 12/14] e1000e: store EEPROM version number to prevent
	unnecessary NVM reads
Date: Fri, 21 Nov 2008 11:02:21 -0800
Message-ID: <20081121190221.32313.93452.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:59822 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754489AbYKUTCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:02:41 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Rather than reading the NVM to get the EEPROM version number everytime the
ethool get_drvinfo function is called, read it once during probe and save
it for future reference.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ethtool.c |    8 +++-----
 drivers/net/e1000e/netdev.c  |    3 +++
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index e09a181..ec94991 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -191,6 +191,7 @@ struct e1000_adapter {
 	u16 mng_vlan_id;
 	u16 link_speed;
 	u16 link_duplex;
+	u16 eeprom_vers;
 
 	spinlock_t tx_queue_lock; /* prevent concurrent tail updates */
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 875d769..840e8c4 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -588,7 +588,6 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
-	u16 eeprom_data;
 
 	strncpy(drvinfo->driver,  e1000e_driver_name, 32);
 	strncpy(drvinfo->version, e1000e_driver_version, 32);
@@ -597,11 +596,10 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 	 * EEPROM image version # is reported as firmware version # for
 	 * PCI-E controllers
 	 */
-	e1000_read_nvm(&adapter->hw, 5, 1, &eeprom_data);
 	sprintf(firmware_version, "%d.%d-%d",
-		(eeprom_data & 0xF000) >> 12,
-		(eeprom_data & 0x0FF0) >> 4,
-		eeprom_data & 0x000F);
+		(adapter->eeprom_vers & 0xF000) >> 12,
+		(adapter->eeprom_vers & 0x0FF0) >> 4,
+		(adapter->eeprom_vers & 0x000F));
 
 	strncpy(drvinfo->fw_version, firmware_version, 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f10252b..b3f0b47 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5025,6 +5025,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->wol = adapter->eeprom_wol;
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
+	/* save off EEPROM version number */
+	e1000_read_nvm(&adapter->hw, 5, 1, &adapter->eeprom_vers);
+
 	/* reset the hardware with the new settings */
 	e1000e_reset(adapter);
 

