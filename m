From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 2/12][BNX2X]: Correct init_one()
Date: Wed, 27 Feb 2008 14:24:27 +0200
Message-ID: <1204115067.8232.356.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2197 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754718AbYB0Mlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:41:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: Correct init_one()

Correct PCI-E info printed by init_one()
In one case it failed to free the netdev. 

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |   41 ++++++++++++++++++++++++++---------------
 drivers/net/bnx2x.h |    5 +++++
 2 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index 7b2d789..7786716 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -8873,14 +8873,32 @@ err_out:
 	return rc;
 }
 
+static int __devinit bnx2x_get_pcie_width(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
+
+	val = (val & PCICFG_LINK_WIDTH) >> PCICFG_LINK_WIDTH_SHIFT;
+	return val;
+}
+
+/* return value of 1=2.5GHz 2=5GHz */
+static int __devinit bnx2x_get_pcie_speed(struct bnx2x *bp)
+{
+	u32 val = REG_RD(bp, PCICFG_OFFSET + PCICFG_LINK_CONTROL);
+
+	val = (val & PCICFG_LINK_SPEED) >> PCICFG_LINK_SPEED_SHIFT;
+	return val;
+}
+
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
 	static int version_printed;
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
-	int rc, i;
+	int rc;
 	int port = PCI_FUNC(pdev->devfn);
+	DECLARE_MAC_BUF(mac);
 
 	if (version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -8897,6 +8915,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	if (port && onefunc) {
 		printk(KERN_ERR PFX "second function disabled. exiting\n");
+		free_netdev(dev);
 		return 0;
 	}
 
@@ -8950,22 +8969,14 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, dev);
 
 	bp->name = board_info[ent->driver_data].name;
-	printk(KERN_INFO "%s: %s (%c%d) PCI%s %s %dMHz "
-	       "found at mem %lx, IRQ %d, ",
-	       dev->name, bp->name,
+	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
+	       " IRQ %d, ", dev->name, bp->name,
 	       ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
 	       ((CHIP_ID(bp) & 0x0ff0) >> 4),
-	       ((bp->flags & PCIX_FLAG) ? "-X" : ""),
-	       ((bp->flags & PCI_32BIT_FLAG) ? "32-bit" : "64-bit"),
-	       bp->bus_speed_mhz,
-	       dev->base_addr,
-	       bp->pdev->irq);
-
-	printk("node addr ");
-	for (i = 0; i < 6; i++)
-		printk("%2.2x", dev->dev_addr[i]);
-	printk("\n");
-
+	       bnx2x_get_pcie_width(bp),
+	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
+	       dev->base_addr, bp->pdev->irq);
+	printk(KERN_CONT "node addr %s\n", print_mac(mac, dev->dev_addr));
 	return 0;
 }
 
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 7a01668..ea91008 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -867,6 +867,11 @@ struct bnx2x {
 		       DPM_TRIGER_TYPE); \
 	} while (0)
 
+/* PCIE link and speed */
+#define PCICFG_LINK_WIDTH		0x1f00000
+#define PCICFG_LINK_WIDTH_SHIFT		20
+#define PCICFG_LINK_SPEED		0xf0000
+#define PCICFG_LINK_SPEED_SHIFT		16
 
 /* stuff added to make the code fit 80Col */
 
-- 
1.5.3.2




