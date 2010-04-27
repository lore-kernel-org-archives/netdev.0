From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: add support for reporting 5GT/s during
	probe on PCIe Gen2
Date: Tue, 27 Apr 2010 04:02:40 -0700
Message-ID: <20100427110238.23921.24825.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:40142 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754919Ab0D0LC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 07:02:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects the fact that we were not reporting Gen2 link speeds
when we were in fact connected at Gen2 rates.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    4 ----
 drivers/net/igb/e1000_mac.c     |   27 ++++++++++++++++++++-------
 drivers/net/igb/igb_main.c      |    1 +
 include/linux/pci_regs.h        |    3 +++
 4 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 31d24e0..24d9be6 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -610,11 +610,7 @@
 #define IGP_LED3_MODE           0x07000000
 
 /* PCI/PCI-X/PCI-EX Config space */
-#define PCIE_LINK_STATUS             0x12
 #define PCIE_DEVICE_CONTROL2         0x28
-
-#define PCIE_LINK_WIDTH_MASK         0x3F0
-#define PCIE_LINK_WIDTH_SHIFT        4
 #define PCIE_DEVICE_CONTROL2_16ms    0x0005
 
 #define PHY_REVISION_MASK      0xFFFFFFF0
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index be8d010..90c5e01 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -53,17 +53,30 @@ s32 igb_get_bus_info_pcie(struct e1000_hw *hw)
 	u16 pcie_link_status;
 
 	bus->type = e1000_bus_type_pci_express;
-	bus->speed = e1000_bus_speed_2500;
 
 	ret_val = igb_read_pcie_cap_reg(hw,
-					  PCIE_LINK_STATUS,
-					  &pcie_link_status);
-	if (ret_val)
+					PCI_EXP_LNKSTA,
+					&pcie_link_status);
+	if (ret_val) {
 		bus->width = e1000_bus_width_unknown;
-	else
+		bus->speed = e1000_bus_speed_unknown;
+	} else {
+		switch (pcie_link_status & PCI_EXP_LNKSTA_CLS) {
+		case PCI_EXP_LNKSTA_CLS_2_5GB:
+			bus->speed = e1000_bus_speed_2500;
+			break;
+		case PCI_EXP_LNKSTA_CLS_5_0GB:
+			bus->speed = e1000_bus_speed_5000;
+			break;
+		default:
+			bus->speed = e1000_bus_speed_unknown;
+			break;
+		}
+
 		bus->width = (enum e1000_bus_width)((pcie_link_status &
-						     PCIE_LINK_WIDTH_MASK) >>
-						     PCIE_LINK_WIDTH_SHIFT);
+						     PCI_EXP_LNKSTA_NLW) >>
+						     PCI_EXP_LNKSTA_NLW_SHIFT);
+	}
 
 	reg = rd32(E1000_STATUS);
 	bus->func = (reg & E1000_STATUS_FUNC_MASK) >> E1000_STATUS_FUNC_SHIFT;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a14303a..919e363 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1638,6 +1638,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
 		 netdev->name,
 		 ((hw->bus.speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
+		  (hw->bus.speed == e1000_bus_speed_5000) ? "5.0Gb/s" :
 		                                            "unknown"),
 		 ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
 		  (hw->bus.width == e1000_bus_width_pcie_x2) ? "Width x2" :
diff --git a/include/linux/pci_regs.h b/include/linux/pci_regs.h
index c8f3029..c4c3d68 100644
--- a/include/linux/pci_regs.h
+++ b/include/linux/pci_regs.h
@@ -442,7 +442,10 @@
 #define  PCI_EXP_LNKCTL_LABIE	0x0800	/* Lnk Autonomous Bandwidth Interrupt Enable */
 #define PCI_EXP_LNKSTA		18	/* Link Status */
 #define  PCI_EXP_LNKSTA_CLS	0x000f	/* Current Link Speed */
+#define  PCI_EXP_LNKSTA_CLS_2_5GB 0x01	/* Current Link Speed 2.5GT/s */
+#define  PCI_EXP_LNKSTA_CLS_5_0GB 0x02	/* Current Link Speed 5.0GT/s */
 #define  PCI_EXP_LNKSTA_NLW	0x03f0	/* Nogotiated Link Width */
+#define  PCI_EXP_LNKSTA_NLW_SHIFT 4	/* start of NLW mask in link status */
 #define  PCI_EXP_LNKSTA_LT	0x0800	/* Link Training */
 #define  PCI_EXP_LNKSTA_SLC	0x1000	/* Slot Clock Configuration */
 #define  PCI_EXP_LNKSTA_DLLLA	0x2000	/* Data Link Layer Link Active */

