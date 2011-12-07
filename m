From: Florian Fainelli <ffainelli@freebox.fr>
Subject: [PATCH 2/2] e1000: cleanup CE4100 MDIO registers access
Date: Wed,  7 Dec 2011 17:41:02 +0100
Message-ID: <1323276062-10906-2-git-send-email-ffainelli@freebox.fr>
References: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Florian Fainelli <ffainelli@freebox.fr>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:33745 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754256Ab1LGQvb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 11:51:31 -0500
In-Reply-To: <1323276062-10906-1-git-send-email-ffainelli@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A global variable is currently used to hold the virtual address of the
CE4100 MDIO base register address. Store the address in the e1000_hw
structure and update macros accordingly.

Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.h   |    4 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c |   14 ++++----------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.h b/drivers/net/ethernet/intel/e1000/e1000_hw.h
index cf7e3c0..f6c4d7e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.h
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.h
@@ -812,8 +812,7 @@ struct e1000_ffvt_entry {
 #define E1000_FLA      0x0001C	/* Flash Access - RW */
 #define E1000_MDIC     0x00020	/* MDI Control - RW */
 
-extern void __iomem *ce4100_gbe_mdio_base_virt;
-#define INTEL_CE_GBE_MDIO_RCOMP_BASE    (ce4100_gbe_mdio_base_virt)
+#define INTEL_CE_GBE_MDIO_RCOMP_BASE    (hw->ce4100_gbe_mdio_base_virt)
 #define E1000_MDIO_STS  (INTEL_CE_GBE_MDIO_RCOMP_BASE + 0)
 #define E1000_MDIO_CMD  (INTEL_CE_GBE_MDIO_RCOMP_BASE + 4)
 #define E1000_MDIO_DRV  (INTEL_CE_GBE_MDIO_RCOMP_BASE + 8)
@@ -1343,6 +1342,7 @@ struct e1000_hw_stats {
 struct e1000_hw {
 	u8 __iomem *hw_addr;
 	u8 __iomem *flash_address;
+	void __iomem *ce4100_gbe_mdio_base_virt;
 	e1000_mac_type mac_type;
 	e1000_phy_type phy_type;
 	u32 phy_init_script;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7bb3337..39d3178 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -33,11 +33,6 @@
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
 
-/* Intel Media SOC GbE MDIO physical base address */
-static unsigned long ce4100_gbe_mdio_base_phy;
-/* Intel Media SOC GbE MDIO virtual base address */
-void __iomem *ce4100_gbe_mdio_base_virt;
-
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #define DRV_VERSION "7.3.21-k8-NAPI"
@@ -1054,11 +1049,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	err = -EIO;
 	if (hw->mac_type == e1000_ce4100) {
-		ce4100_gbe_mdio_base_phy = pci_resource_start(pdev, BAR_1);
-		ce4100_gbe_mdio_base_virt = ioremap(ce4100_gbe_mdio_base_phy,
+		hw->ce4100_gbe_mdio_base_virt = ioremap(pci_resource_start(pdev, BAR_1),
 		                                pci_resource_len(pdev, BAR_1));
 
-		if (!ce4100_gbe_mdio_base_virt)
+		if (!hw->ce4100_gbe_mdio_base_virt)
 			goto err_mdio_ioremap;
 	}
 
@@ -1249,7 +1243,7 @@ err_eeprom:
 err_dma:
 err_sw_init:
 err_mdio_ioremap:
-	iounmap(ce4100_gbe_mdio_base_virt);
+	iounmap(hw->ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
@@ -1287,7 +1281,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	kfree(adapter->rx_ring);
 
 	if (hw->mac_type == e1000_ce4100)
-		iounmap(ce4100_gbe_mdio_base_virt);
+		iounmap(hw->ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-- 
1.7.5.4
