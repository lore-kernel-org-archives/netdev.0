From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 2/2] igb: Add messaging for thermal sensor events on i350 devices
Date: Mon, 14 Mar 2011 22:54:24 -0700
Message-ID: <1300168464-29546-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60787 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265Ab1COFy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 01:54:29 -0400
In-Reply-To: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This feature adds messaging to the link status change to notify
the user if the device returned from a downshift or power off
event due to the Thermal Sensor feature in i350 parts. Feature
is only available on internal copper ports.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_defines.h |    5 +++++
 drivers/net/igb/e1000_regs.h    |    3 +++
 drivers/net/igb/igb_main.c      |   37 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 9bb1928..6b80d40 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -51,6 +51,7 @@
 #define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
 #define E1000_CTRL_EXT_LINK_MODE_1000BASE_KX  0x00400000
 #define E1000_CTRL_EXT_LINK_MODE_SGMII   0x00800000
+#define E1000_CTRL_EXT_LINK_MODE_GMII   0x00000000
 #define E1000_CTRL_EXT_EIAME          0x01000000
 #define E1000_CTRL_EXT_IRCA           0x00000001
 /* Interrupt delay cancellation */
@@ -788,6 +789,10 @@
 #define E1000_MDIC_ERROR     0x40000000
 #define E1000_MDIC_DEST      0x80000000
 
+/* Thermal Sensor */
+#define E1000_THSTAT_PWR_DOWN       0x00000001 /* Power Down Event */
+#define E1000_THSTAT_LINK_THROTTLE  0x00000002 /* Link Speed Throttle Event */
+
 /* Energy Efficient Ethernet */
 #define E1000_IPCNFG_EEE_1G_AN       0x00000008  /* EEE Enable 1G AN */
 #define E1000_IPCNFG_EEE_100M_AN     0x00000004  /* EEE Enable 100M AN */
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index ad77ed5..958ca3b 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -342,6 +342,9 @@
 #define E1000_IPCNFG  0x0E38  /* Internal PHY Configuration */
 #define E1000_EEER    0x0E30  /* Energy Efficient Ethernet */
 
+/* Thermal Sensor Register */
+#define E1000_THSTAT    0x08110 /* Thermal Sensor Status */
+
 /* OS2BMC Registers */
 #define E1000_B2OSPC    0x08FE0 /* BMC2OS packets sent by BMC */
 #define E1000_B2OGPRC   0x04158 /* BMC2OS packets received by host */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 5366f2a..3d850af 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3550,7 +3550,7 @@ static void igb_watchdog_task(struct work_struct *work)
                                                    watchdog_task);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	u32 link;
+	u32 link, ctrl_ext, thstat;
 	int i;
 
 	link = igb_has_link(adapter);
@@ -3574,6 +3574,25 @@ static void igb_watchdog_task(struct work_struct *work)
 			       ((ctrl & E1000_CTRL_RFCE) ?  "RX" :
 			       ((ctrl & E1000_CTRL_TFCE) ?  "TX" : "None")));
 
+			/* check for thermal sensor event on i350,
+			 * copper only */
+			if (hw->mac.type == e1000_i350) {
+				thstat = rd32(E1000_THSTAT);
+				ctrl_ext = rd32(E1000_CTRL_EXT);
+				if ((hw->phy.media_type ==
+				     e1000_media_type_copper) && !(ctrl_ext &
+				     E1000_CTRL_EXT_LINK_MODE_SGMII)) {
+					if (thstat &
+					    E1000_THSTAT_LINK_THROTTLE) {
+						printk(KERN_INFO "igb: %s The "
+						       "network adapter link "
+						       "speed was downshifted "
+						       "because it "
+						       "overheated.\n",
+						       netdev->name);
+					}
+				}
+			}
 			/* adjust timeout factor according to speed/duplex */
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
@@ -3599,6 +3618,22 @@ static void igb_watchdog_task(struct work_struct *work)
 		if (netif_carrier_ok(netdev)) {
 			adapter->link_speed = 0;
 			adapter->link_duplex = 0;
+			/* check for thermal sensor event on i350
+			 * copper only*/
+			if (hw->mac.type == e1000_i350) {
+				thstat = rd32(E1000_THSTAT);
+				ctrl_ext = rd32(E1000_CTRL_EXT);
+				if ((hw->phy.media_type ==
+				     e1000_media_type_copper) && !(ctrl_ext &
+				     E1000_CTRL_EXT_LINK_MODE_SGMII)) {
+					if (thstat & E1000_THSTAT_PWR_DOWN) {
+						printk(KERN_ERR "igb: %s The "
+						"network adapter was stopped "
+						"because it overheated.\n",
+						netdev->name);
+					}
+				}
+			}
 			/* Links status message must follow this format */
 			printk(KERN_INFO "igb: %s NIC Link is Down\n",
 			       netdev->name);
-- 
1.7.4

