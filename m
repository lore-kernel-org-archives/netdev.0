From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: add WOL support for SFP+ subdevice
Date: Fri, 03 Dec 2010 05:32:13 -0800
Message-ID: <20101203133212.21637.12387.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:38103
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754392Ab0LCNi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:38:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch will add wake on LAN support to the dev/sub_dev 10FB 11A9.  This
will also include ixgbe ethtool support for this device.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   11 +++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |   15 ++++++++++-----
 drivers/net/ixgbe/ixgbe_type.h    |    1 +
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index f9b5839..ef3f910 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1879,7 +1879,16 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 	struct ixgbe_hw *hw = &adapter->hw;
 	int retval = 1;
 
+	/* WOL not supported except for the following */
 	switch(hw->device_id) {
+	case IXGBE_DEV_ID_82599_SFP:
+		/* Only this subdevice supports WOL */
+		if (hw->subsystem_device_id != IXGBE_SUBDEV_ID_82599_SFP) {
+			wol->supported = 0;
+			break;
+		}
+		retval = 0;
+		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
 		if (hw->subsystem_device_id ==
@@ -1887,6 +1896,8 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 			wol->supported = 0;
 			break;
 		}
+		retval = 0;
+		break;
 	case IXGBE_DEV_ID_82599_KX4:
 		retval = 0;
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fb81418..c876a69 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7226,13 +7226,18 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 
 	switch (pdev->device) {
+	case IXGBE_DEV_ID_82599_SFP:
+		/* Only this subdevice supports WOL */
+		if (pdev->subsystem_device == IXGBE_SUBDEV_ID_82599_SFP)
+			adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
+			                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
-		if (pdev->subsystem_device ==
-		    IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ) {
-			adapter->wol = 0;
-			break;
-		}
+		if (pdev->subsystem_device != IXGBE_SUBDEV_ID_82599_KX4_KR_MEZZ)
+			adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
+			                IXGBE_WUFC_MC | IXGBE_WUFC_BC);
+		break;
 	case IXGBE_DEV_ID_82599_KX4:
 		adapter->wol = (IXGBE_WUFC_MAG | IXGBE_WUFC_EX |
 				IXGBE_WUFC_MC | IXGBE_WUFC_BC);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 20e1f03..bbcfafc 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -54,6 +54,7 @@
 #define IXGBE_DEV_ID_82599_T3_LOM        0x151C
 #define IXGBE_DEV_ID_82599_CX4           0x10F9
 #define IXGBE_DEV_ID_82599_SFP           0x10FB
+#define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_XAUI_LOM      0x10FC
 #define IXGBE_DEV_ID_82599_COMBO_BACKPLANE 0x10F8

