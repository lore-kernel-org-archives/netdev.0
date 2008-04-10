From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 2/6] tc35815: Use print_mac() helper
Date: Fri, 11 Apr 2008 00:24:24 +0900 (JST)
Message-ID: <20080411.002424.130850795.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:65047 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758118AbYDJPXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 11:23:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use print_mac() and DECLARE_MAC_BUF().

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/tc35815.c |   36 ++++++++++++++----------------------
 1 files changed, 14 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index f0e9566..1f623e5 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -664,6 +664,7 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 	struct tc35815_local *lp;
 	int rc;
 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
+	DECLARE_MAC_BUF(mac);
 
 	static int printed_version;
 	if (!printed_version++) {
@@ -770,15 +771,11 @@ static int __devinit tc35815_init_one (struct pci_dev *pdev,
 		goto err_out_unmap;
 
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-	printk(KERN_INFO "%s: %s at 0x%lx, "
-		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-		"IRQ %d\n",
+	printk(KERN_INFO "%s: %s at 0x%lx, %s, IRQ %d\n",
 		dev->name,
 		board_info[ent->driver_data].name,
 		dev->base_addr,
-		dev->dev_addr[0], dev->dev_addr[1],
-		dev->dev_addr[2], dev->dev_addr[3],
-		dev->dev_addr[4], dev->dev_addr[5],
+		print_mac(mac, dev->dev_addr),
 		dev->irq);
 
 	setup_timer(&lp->timer, tc35815_timer, (unsigned long) dev);
@@ -1127,17 +1124,14 @@ panic_queues(struct net_device *dev)
 }
 #endif
 
-static void print_eth(char *add)
+static void print_eth(const u8 *add)
 {
-	int i;
+	DECLARE_MAC_BUF(mac);
 
-	printk("print_eth(%p)\n", add);
-	for (i = 0; i < 6; i++)
-		printk(" %2.2X", (unsigned char) add[i + 6]);
-	printk(" =>");
-	for (i = 0; i < 6; i++)
-		printk(" %2.2X", (unsigned char) add[i]);
-	printk(" : %2.2X%2.2X\n", (unsigned char) add[12], (unsigned char) add[13]);
+	printk(KERN_DEBUG "print_eth(%p)\n", add);
+	printk(KERN_DEBUG " %s =>", print_mac(mac, add + 6));
+	printk(KERN_CONT " %s : %02x%02x\n",
+		print_mac(mac, add), add[12], add[13]);
 }
 
 static int tc35815_tx_full(struct net_device *dev)
@@ -1992,15 +1986,13 @@ static void tc35815_set_cam_entry(struct net_device *dev, int index, unsigned ch
 	int cam_index = index * 6;
 	u32 cam_data;
 	u32 saved_addr;
+	DECLARE_MAC_BUF(mac);
+
 	saved_addr = tc_readl(&tr->CAM_Adr);
 
-	if (netif_msg_hw(lp)) {
-		int i;
-		printk(KERN_DEBUG "%s: CAM %d:", dev->name, index);
-		for (i = 0; i < 6; i++)
-			printk(" %02x", addr[i]);
-		printk("\n");
-	}
+	if (netif_msg_hw(lp))
+		printk(KERN_DEBUG "%s: CAM %d: %s\n",
+			dev->name, index, print_mac(mac, addr));
 	if (index & 1) {
 		/* read modify write */
 		tc_writel(cam_index - 2, &tr->CAM_Adr);
