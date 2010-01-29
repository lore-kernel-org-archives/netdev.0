From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/13] tulip/pnic.c: Use dev_<level> and pr_<level>
Date: Thu, 28 Jan 2010 22:59:24 -0800
Message-ID: <d955a935834b094ffd9f73a1a0b5b129102056a0.1264747118.git.joe@perches.com>
References: <cover.1264747118.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1593 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074Ab0A2G7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 01:59:32 -0500
In-Reply-To: <cover.1264747118.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert printks to dev_<level> where a dev is available
Convert printks to pr_<level> where not
Coalesce format strings
Change print formats with %d.dx to %0dx

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/pnic.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tulip/pnic.c b/drivers/net/tulip/pnic.c
index d3253ed..966efa1 100644
--- a/drivers/net/tulip/pnic.c
+++ b/drivers/net/tulip/pnic.c
@@ -40,8 +40,8 @@ void pnic_do_nway(struct net_device *dev)
 			new_csr6 |= 0x00000200;
 		}
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: PNIC autonegotiated status %8.8x, %s.\n",
-				   dev->name, phy_reg, medianame[dev->if_port]);
+			printk(KERN_DEBUG "%s: PNIC autonegotiated status %08x, %s\n",
+			       dev->name, phy_reg, medianame[dev->if_port]);
 		if (tp->csr6 != new_csr6) {
 			tp->csr6 = new_csr6;
 			/* Restart Tx */
@@ -58,8 +58,8 @@ void pnic_lnk_change(struct net_device *dev, int csr5)
 	int phy_reg = ioread32(ioaddr + 0xB8);
 
 	if (tulip_debug > 1)
-		printk(KERN_DEBUG "%s: PNIC link changed state %8.8x, CSR5 %8.8x.\n",
-			   dev->name, phy_reg, csr5);
+		printk(KERN_DEBUG "%s: PNIC link changed state %08x, CSR5 %08x\n",
+		       dev->name, phy_reg, csr5);
 	if (ioread32(ioaddr + CSR5) & TPLnkFail) {
 		iowrite32((ioread32(ioaddr + CSR7) & ~TPLnkFail) | TPLnkPass, ioaddr + CSR7);
 		/* If we use an external MII, then we mustn't use the
@@ -114,9 +114,8 @@ void pnic_timer(unsigned long data)
 		int csr5 = ioread32(ioaddr + CSR5);
 
 		if (tulip_debug > 1)
-			printk(KERN_DEBUG "%s: PNIC timer PHY status %8.8x, %s "
-				   "CSR5 %8.8x.\n",
-				   dev->name, phy_reg, medianame[dev->if_port], csr5);
+			printk(KERN_DEBUG "%s: PNIC timer PHY status %08x, %s CSR5 %08x\n",
+			       dev->name, phy_reg, medianame[dev->if_port], csr5);
 		if (phy_reg & 0x04000000) {	/* Remote link fault */
 			iowrite32(0x0201F078, ioaddr + 0xB8);
 			next_tick = 1*HZ;
@@ -126,10 +125,11 @@ void pnic_timer(unsigned long data)
 			next_tick = 60*HZ;
 		} else if (csr5 & TPLnkFail) { /* 100baseTx link beat */
 			if (tulip_debug > 1)
-				printk(KERN_DEBUG "%s: %s link beat failed, CSR12 %4.4x, "
-					   "CSR5 %8.8x, PHY %3.3x.\n",
-					   dev->name, medianame[dev->if_port], csr12,
-					   ioread32(ioaddr + CSR5), ioread32(ioaddr + 0xB8));
+				printk(KERN_DEBUG "%s: %s link beat failed, CSR12 %04x, CSR5 %08x, PHY %03x\n",
+				       dev->name, medianame[dev->if_port],
+				       csr12,
+				       ioread32(ioaddr + CSR5),
+				       ioread32(ioaddr + 0xB8));
 			next_tick = 3*HZ;
 			if (tp->medialock) {
 			} else if (tp->nwayset  &&  (dev->if_port & 1)) {
@@ -151,10 +151,11 @@ void pnic_timer(unsigned long data)
 				tulip_restart_rxtx(tp);
 				dev->trans_start = jiffies;
 				if (tulip_debug > 1)
-					printk(KERN_INFO "%s: Changing PNIC configuration to %s "
-						   "%s-duplex, CSR6 %8.8x.\n",
-						   dev->name, medianame[dev->if_port],
-						   tp->full_duplex ? "full" : "half", new_csr6);
+					dev_info(&dev->dev,
+						 "Changing PNIC configuration to %s %s-duplex, CSR6 %08x\n",
+						 medianame[dev->if_port],
+						 tp->full_duplex ? "full" : "half",
+						 new_csr6);
 			}
 		}
 	}
@@ -162,7 +163,7 @@ too_good_connection:
 	mod_timer(&tp->timer, RUN_AT(next_tick));
 	if(!ioread32(ioaddr + CSR7)) {
 		if (tulip_debug > 1)
-			printk(KERN_INFO "%s: sw timer wakeup.\n", dev->name);
+			dev_info(&dev->dev, "sw timer wakeup\n");
 		disable_irq(dev->irq);
 		tulip_refill_rx(dev);
 		enable_irq(dev->irq);
-- 
1.6.6.rc0.57.gad7a

