From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2x: use pcie_get_minimum_link()
Date: Sat, 28 Sep 2013 08:46:12 +0300
Message-ID: <1380347172-16670-7-git-send-email-yuvalmin@broadcom.com>
References: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4278 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751509Ab3I1Fqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 01:46:44 -0400
In-Reply-To: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use common code for getting the pcie link speed/width for debug printing.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  6 ----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 45 +++++++-----------------
 2 files changed, 12 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index a38d049..8fe4bcb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2491,11 +2491,5 @@ enum {
 
 #define NUM_MACS	8
 
-enum bnx2x_pci_bus_speed {
-	BNX2X_PCI_LINK_SPEED_2500 = 2500,
-	BNX2X_PCI_LINK_SPEED_5000 = 5000,
-	BNX2X_PCI_LINK_SPEED_8000 = 8000
-};
-
 void bnx2x_set_local_cmng(struct bnx2x *bp);
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 467689f..654680d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12274,28 +12274,6 @@ err_out:
 	return rc;
 }
 
-static void bnx2x_get_pcie_width_speed(struct bnx2x *bp, int *width,
-				       enum bnx2x_pci_bus_speed *speed)
-{
-	u32 link_speed, val = 0;
-
-	pci_read_config_dword(bp->pdev, PCICFG_LINK_CONTROL, &val);
-	*width = (val & PCICFG_LINK_WIDTH) >> PCICFG_LINK_WIDTH_SHIFT;
-
-	link_speed = (val & PCICFG_LINK_SPEED) >> PCICFG_LINK_SPEED_SHIFT;
-
-	switch (link_speed) {
-	case 3:
-		*speed = BNX2X_PCI_LINK_SPEED_8000;
-		break;
-	case 2:
-		*speed = BNX2X_PCI_LINK_SPEED_5000;
-		break;
-	default:
-		*speed = BNX2X_PCI_LINK_SPEED_2500;
-	}
-}
-
 static int bnx2x_check_firmware(struct bnx2x *bp)
 {
 	const struct firmware *firmware = bp->firmware;
@@ -12652,8 +12630,8 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 {
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
-	int pcie_width;
-	enum bnx2x_pci_bus_speed pcie_speed;
+	enum pcie_link_width pcie_width;
+	enum pci_bus_speed pcie_speed;
 	int rc, max_non_def_sbs;
 	int rx_count, tx_count, rss_count, doorbell_size;
 	int max_cos_est;
@@ -12802,18 +12780,19 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 		dev_addr_add(bp->dev, bp->fip_mac, NETDEV_HW_ADDR_T_SAN);
 		rtnl_unlock();
 	}
-
-	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
-	BNX2X_DEV_INFO("got pcie width %d and speed %d\n",
-		       pcie_width, pcie_speed);
-
-	BNX2X_DEV_INFO("%s (%c%d) PCI-E x%d %s found at mem %lx, IRQ %d, node addr %pM\n",
+	if (pcie_get_minimum_link(bp->pdev, &pcie_speed, &pcie_width) ||
+	    pcie_speed == PCI_SPEED_UNKNOWN ||
+	    pcie_width == PCIE_LNK_WIDTH_UNKNOWN)
+		BNX2X_DEV_INFO("Failed to determine PCI Express Bandwidth\n");
+	else
+		BNX2X_DEV_INFO(
+		       "%s (%c%d) PCI-E x%d %s found at mem %lx, IRQ %d, node addr %pM\n",
 		       board_info[ent->driver_data].name,
 		       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
 		       pcie_width,
-		       pcie_speed == BNX2X_PCI_LINK_SPEED_2500 ? "2.5GHz" :
-		       pcie_speed == BNX2X_PCI_LINK_SPEED_5000 ? "5.0GHz" :
-		       pcie_speed == BNX2X_PCI_LINK_SPEED_8000 ? "8.0GHz" :
+		       pcie_speed == PCIE_SPEED_2_5GT ? "2.5GHz" :
+		       pcie_speed == PCIE_SPEED_5_0GT ? "5.0GHz" :
+		       pcie_speed == PCIE_SPEED_8_0GT ? "8.0GHz" :
 		       "Unknown",
 		       dev->base_addr, bp->pdev->irq, dev->dev_addr);
 
-- 
1.8.1.227.g44fe835
