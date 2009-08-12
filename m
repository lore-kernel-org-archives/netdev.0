From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 20/36] bnx2x: Combine get_pcie_width and
 get_pcie_speed
Date: Wed, 12 Aug 2009 21:23:34 +0300
Message-ID: <1250101414.27379.172.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbZHLSYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions bnx2x_get_pcie_width() and bnx2x_get_pcie_speed() were
combined into bnx2x_get_pcie_width_speed() so that there is only
1 PCI read to PCICFG_OFFSET + PCICFG_LINK_CONTROL rather then 2 reads.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   34 ++++++++++++++++------------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 8e32134..5042109 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11670,31 +11670,26 @@ err_out:
 	return rc;
 }
 
-static int __devinit bnx2x_get_pcie_width(struct bnx2x *bp)
+static void __devinit bnx2x_get_pcie_width_speed(struct bnx2x *bp,
+						 int *width, int *speed)
 {
 	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
 
-	val = (val & PCICFG_LINK_WIDTH) >> PCICFG_LINK_WIDTH_SHIFT;
-	return val;
-}
-
-/* return value of 1=2.5GHz 2=5GHz */
-static int __devinit bnx2x_get_pcie_speed(struct bnx2x *bp)
-{
-	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
+	*width = (val & PCICFG_LINK_WIDTH) >> PCICFG_LINK_WIDTH_SHIFT;
 
-	val = (val & PCICFG_LINK_SPEED) >> PCICFG_LINK_SPEED_SHIFT;
-	return val;
+	/* return value of 1=2.5GHz 2=5GHz */
+	*speed = (val & PCICFG_LINK_SPEED) >> PCICFG_LINK_SPEED_SHIFT;
 }
+
 static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 {
+	const struct firmware *firmware = bp->firmware;
 	struct bnx2x_fw_file_hdr *fw_hdr;
 	struct bnx2x_fw_file_section *sections;
-	u16 *ops_offsets;
 	u32 offset, len, num_ops;
+	u16 *ops_offsets;
 	int i;
-	const struct firmware *firmware = bp->firmware;
-	const u8 * fw_ver;
+	const u8 *fw_ver;
 
 	if (firmware->size < sizeof(struct bnx2x_fw_file_hdr))
 		return -EINVAL;
@@ -11708,7 +11703,8 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 		offset = be32_to_cpu(sections[i].offset);
 		len = be32_to_cpu(sections[i].len);
 		if (offset + len > firmware->size) {
-			printk(KERN_ERR PFX "Section %d length is out of bounds\n", i);
+			printk(KERN_ERR PFX "Section %d length is out of "
+					    "bounds\n", i);
 			return -EINVAL;
 		}
 	}
@@ -11720,7 +11716,8 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 
 	for (i = 0; i < be32_to_cpu(fw_hdr->init_ops_offsets.len) / 2; i++) {
 		if (be16_to_cpu(ops_offsets[i]) > num_ops) {
-			printk(KERN_ERR PFX "Section offset %d is out of bounds\n", i);
+			printk(KERN_ERR PFX "Section offset %d is out of "
+					    "bounds\n", i);
 			return -EINVAL;
 		}
 	}
@@ -11877,6 +11874,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	static int version_printed;
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
+	int pcie_width, pcie_speed;
 	int rc;
 
 	if (version_printed++ == 0)
@@ -11917,11 +11915,11 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
+	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
 	       " IRQ %d, ", dev->name, board_info[ent->driver_data].name,
 	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
-	       bnx2x_get_pcie_width(bp),
-	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
+	       pcie_width, (pcie_speed == 2) ? "5GHz (Gen2)" : "2.5GHz",
 	       dev->base_addr, bp->pdev->irq);
 	printk(KERN_CONT "node addr %pM\n", dev->dev_addr);
 
-- 
1.5.4.3




