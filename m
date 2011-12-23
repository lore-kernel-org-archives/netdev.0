From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: add support for new 82599 device.
Date: Fri, 23 Dec 2011 01:09:17 -0800
Message-ID: <1324631357-31789-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9686 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031Ab1LWJJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 04:09:24 -0500
In-Reply-To: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This device uses an already existing DevID but since it supports
WoL we need to add the Sub DevID.  It's support of WoL is limited
to the first port.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   15 ++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   11 +++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    1 +
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 91f871b..da7e580 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1955,12 +1955,21 @@ static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
 	/* WOL not supported except for the following */
 	switch(hw->device_id) {
 	case IXGBE_DEV_ID_82599_SFP:
-		/* Only this subdevice supports WOL */
-		if (hw->subsystem_device_id != IXGBE_SUBDEV_ID_82599_SFP) {
+		/* Only these subdevices could supports WOL */
+		switch (hw->subsystem_device_id) {
+		case IXGBE_SUBDEV_ID_82599_560FLR:
+			/* only support first port */
+			if (hw->bus.func != 0) {
+				wol->supported = 0;
+				break;
+			}
+		case IXGBE_SUBDEV_ID_82599_SFP:
+			retval = 0;
+			break;
+		default:
 			wol->supported = 0;
 			break;
 		}
-		retval = 0;
 		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b5cef7e..492396a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7605,9 +7605,16 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	adapter->wol = 0;
 	switch (pdev->device) {
 	case IXGBE_DEV_ID_82599_SFP:
-		/* Only this subdevice supports WOL */
-		if (pdev->subsystem_device == IXGBE_SUBDEV_ID_82599_SFP)
+		/* Only these subdevice supports WOL */
+		switch (pdev->subsystem_device) {
+		case IXGBE_SUBDEV_ID_82599_560FLR:
+			/* only support first port */
+			if (hw->bus.func != 0)
+				break;
+		case IXGBE_SUBDEV_ID_82599_SFP:
 			adapter->wol = IXGBE_WUFC_MAG;
+			break;
+		}
 		break;
 	case IXGBE_DEV_ID_82599_COMBO_BACKPLANE:
 		/* All except this subdevice support WOL */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index c5fba00..03b1ecf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -57,6 +57,7 @@
 #define IXGBE_DEV_ID_82599_BACKPLANE_FCOE       0x152a
 #define IXGBE_DEV_ID_82599_SFP_FCOE      0x1529
 #define IXGBE_SUBDEV_ID_82599_SFP        0x11A9
+#define IXGBE_SUBDEV_ID_82599_560FLR     0x17D0
 #define IXGBE_DEV_ID_82599_SFP_EM        0x1507
 #define IXGBE_DEV_ID_82599_SFP_SF2       0x154D
 #define IXGBE_DEV_ID_82599EN_SFP         0x1557
-- 
1.7.7.4
