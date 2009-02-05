From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbe: Display EEPROM version in ethtool -i
	queries
Date: Wed, 04 Feb 2009 17:39:43 -0800
Message-ID: <20090205013943.29241.71108.stgit@lost.foo-projects.org>
References: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:36350 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757141AbZBEBkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 20:40:04 -0500
In-Reply-To: <20090205013900.29241.77746.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Currently ixgbe does not display the EEPROM version in ethtool -i, where
other drivers do.  The EEPROM version is located at offset 0x29.  This
patch adds support to display it.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    2 ++
 drivers/net/ixgbe/ixgbe_ethtool.c |    9 ++++++++-
 drivers/net/ixgbe/ixgbe_main.c    |    3 +++
 3 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 0ea791a..e98ace8 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -310,6 +310,8 @@ struct ixgbe_adapter {
 	struct work_struct watchdog_task;
 	struct work_struct sfp_task;
 	struct timer_list sfp_timer;
+
+	u16 eeprom_version;
 };
 
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 14e661e..54d96cb 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -679,10 +679,17 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
                               struct ethtool_drvinfo *drvinfo)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	char firmware_version[32];
 
 	strncpy(drvinfo->driver, ixgbe_driver_name, 32);
 	strncpy(drvinfo->version, ixgbe_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
+
+	sprintf(firmware_version, "%d.%d-%d",
+	        (adapter->eeprom_version & 0xF000) >> 12,
+	        (adapter->eeprom_version & 0x0FF0) >> 4,
+	        adapter->eeprom_version & 0x000F);
+
+	strncpy(drvinfo->fw_version, firmware_version, 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
 	drvinfo->n_stats = IXGBE_STATS_LEN;
 	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5db82b5..dceae37 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4191,6 +4191,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		         "PCI-Express slot is required.\n");
 	}
 
+	/* save off EEPROM version number */
+	hw->eeprom.ops.read(hw, 0x29, &adapter->eeprom_version);
+
 	/* reset the hardware with the new settings */
 	hw->mac.ops.start_hw(hw);
 

