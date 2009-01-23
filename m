From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] ixgbe: add support KX/KX4 device
Date: Fri, 23 Jan 2009 00:37:55 -0800
Message-ID: <20090123083755.20920.14.stgit@lost.foo-projects.org>
References: <20090123083733.20920.86146.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:33560
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752750AbZAWIiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 03:38:17 -0500
In-Reply-To: <20090123083733.20920.86146.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

And support for the KX/KX4 mezzanine card.  Device id 0x10B6.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c   |    9 +++++++++
 drivers/net/ixgbe/ixgbe_ethtool.c |   12 ++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |    2 ++
 drivers/net/ixgbe/ixgbe_type.h    |    1 +
 4 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index ad5699d..6c7ddb9 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -213,6 +213,10 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 
 	/* Media type for I82598 is based on device ID */
 	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598:
+		/* Default device ID is mezzanine card KX/KX4 */
+		media_type = ixgbe_media_type_backplane;
+		break;
 	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
 	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
 	case IXGBE_DEV_ID_82598EB_CX4:
@@ -1002,6 +1006,11 @@ static s32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 	s32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 
 	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598:
+		/* Default device ID is mezzanine card KX/KX4 */
+		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_KX4 |
+				  IXGBE_PHYSICAL_LAYER_1000BASE_KX);
+		break;
 	case IXGBE_DEV_ID_82598EB_CX4:
 	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
 		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 4f6b5df..444200f 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -130,6 +130,18 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			ecmd->advertising |= ADVERTISED_1000baseT_Full;
 
 		ecmd->port = PORT_TP;
+	} else if (hw->phy.media_type == ixgbe_media_type_backplane) {
+		/* Set as FIBRE until SERDES defined in kernel */
+		switch (hw->device_id) {
+		case IXGBE_DEV_ID_82598:
+			ecmd->supported |= (SUPPORTED_1000baseT_Full |
+				SUPPORTED_FIBRE);
+			ecmd->advertising = (ADVERTISED_10000baseT_Full |
+				ADVERTISED_1000baseT_Full |
+				ADVERTISED_FIBRE);
+			ecmd->port = PORT_FIBRE;
+			break;
+		}
 	} else {
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising = (ADVERTISED_10000baseT_Full |
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 18d4353..43980dc 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -64,6 +64,8 @@ static const struct ixgbe_info *ixgbe_info_tbl[] = {
  *   Class, Class Mask, private data (not used) }
  */
 static struct pci_device_id ixgbe_pci_tbl[] = {
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598),
+	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT),
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT),
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index f011c57..e43f0c7 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -34,6 +34,7 @@
 #define IXGBE_INTEL_VENDOR_ID   0x8086
 
 /* Device IDs */
+#define IXGBE_DEV_ID_82598               0x10B6
 #define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
 #define IXGBE_DEV_ID_82598EB_SFP_LOM     0x10DB

