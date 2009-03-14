From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 8/8] igb: add support for 82576 quad copper adapter
Date: Fri, 13 Mar 2009 23:42:35 -0700
Message-ID: <20090314064235.4052.4340.stgit@lost.foo-projects.org>
References: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:34273
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752438AbZCNGq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:46:29 -0400
In-Reply-To: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add support for 82576 copper adapter and necessary code to restrict wol for
quad port adapter to first port.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    1 +
 drivers/net/igb/e1000_hw.h    |    1 +
 drivers/net/igb/igb_ethtool.c |    9 +++++++++
 drivers/net/igb/igb_main.c    |   11 +++++++++++
 4 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index adfe2e1..efd9be2 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -83,6 +83,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	case E1000_DEV_ID_82576_NS:
 	case E1000_DEV_ID_82576_FIBER:
 	case E1000_DEV_ID_82576_SERDES:
+	case E1000_DEV_ID_82576_QUAD_COPPER:
 		mac->type = e1000_82576;
 		break;
 	default:
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 4db3602..68aac20 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -40,6 +40,7 @@ struct e1000_hw;
 #define E1000_DEV_ID_82576                    0x10C9
 #define E1000_DEV_ID_82576_FIBER              0x10E6
 #define E1000_DEV_ID_82576_SERDES             0x10E7
+#define E1000_DEV_ID_82576_QUAD_COPPER        0x10E8
 #define E1000_DEV_ID_82576_NS                 0x150A
 #define E1000_DEV_ID_82575EB_COPPER           0x10A7
 #define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 34a8a0f..fb09c8a 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1779,6 +1779,15 @@ static int igb_wol_exclusion(struct igb_adapter *adapter,
 		/* return success for non excluded adapter ports */
 		retval = 0;
 		break;
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		/* quad port adapters only support WoL on port A */
+		if (!(adapter->flags & IGB_FLAG_QUAD_PORT_A)) {
+			wol->supported = 0;
+			break;
+		}
+		/* return success for non excluded adapter ports */
+		retval = 0;
+		break;
 	default:
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0997370..7c4481b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -65,6 +65,7 @@ static struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_NS), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_SERDES), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_QUAD_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575EB_FIBER_SERDES), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82575GB_QUAD_COPPER), board_82575 },
@@ -1353,6 +1354,16 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		if (rd32(E1000_STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol = 0;
 		break;
+	case E1000_DEV_ID_82576_QUAD_COPPER:
+		/* if quad port adapter, disable WoL on all but port A */
+		if (global_quad_port_a != 0)
+			adapter->eeprom_wol = 0;
+		else
+			adapter->flags |= IGB_FLAG_QUAD_PORT_A;
+		/* Reset for multiple quad port adapters */
+		if (++global_quad_port_a == 4)
+			global_quad_port_a = 0;
+		break;
 	}
 
 	/* initialize the wol settings based on the eeprom settings */

