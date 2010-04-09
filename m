From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: add support for reporting 5GT/s during
	probe on PCIe Gen2
Date: Fri, 09 Apr 2010 12:52:47 -0700
Message-ID: <20100409195246.30654.40319.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:39517
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756572Ab0DITxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 15:53:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change corrects the fact that we were not reporting Gen2 link speeds
when we were in fact connected at Gen2 rates.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    3 +++
 drivers/net/igb/e1000_mac.c     |   19 ++++++++++++++++---
 drivers/net/igb/igb_main.c      |    1 +
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 31d24e0..8e440e8 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -615,6 +615,9 @@
 
 #define PCIE_LINK_WIDTH_MASK         0x3F0
 #define PCIE_LINK_WIDTH_SHIFT        4
+#define PCIE_LINK_SPEED_MASK         0x0F
+#define PCIE_LINK_SPEED_2500         0x01
+#define PCIE_LINK_SPEED_5000         0x02
 #define PCIE_DEVICE_CONTROL2_16ms    0x0005
 
 #define PHY_REVISION_MASK      0xFFFFFFF0
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index be8d010..4371835 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -53,17 +53,30 @@ s32 igb_get_bus_info_pcie(struct e1000_hw *hw)
 	u16 pcie_link_status;
 
 	bus->type = e1000_bus_type_pci_express;
-	bus->speed = e1000_bus_speed_2500;
 
 	ret_val = igb_read_pcie_cap_reg(hw,
 					  PCIE_LINK_STATUS,
 					  &pcie_link_status);
-	if (ret_val)
+	if (ret_val) {
 		bus->width = e1000_bus_width_unknown;
-	else
+		bus->speed = e1000_bus_speed_unknown;
+	} else {
+		switch (pcie_link_status & PCIE_LINK_SPEED_MASK) {
+		case PCIE_LINK_SPEED_2500:
+			bus->speed = e1000_bus_speed_2500;
+			break;
+		case PCIE_LINK_SPEED_5000:
+			bus->speed = e1000_bus_speed_5000;
+			break;
+		default:
+			bus->speed = e1000_bus_speed_unknown;
+			break;
+		}
+
 		bus->width = (enum e1000_bus_width)((pcie_link_status &
 						     PCIE_LINK_WIDTH_MASK) >>
 						     PCIE_LINK_WIDTH_SHIFT);
+	}
 
 	reg = rd32(E1000_STATUS);
 	bus->func = (reg & E1000_STATUS_FUNC_MASK) >> E1000_STATUS_FUNC_SHIFT;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 876a49b..a3c79ad 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1637,6 +1637,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
 		 netdev->name,
 		 ((hw->bus.speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
+		  (hw->bus.speed == e1000_bus_speed_5000) ? "5.0Gb/s" :
 		                                            "unknown"),
 		 ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
 		  (hw->bus.width == e1000_bus_width_pcie_x2) ? "Width x2" :

