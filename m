From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 03/15] drivers/net/b44.c: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:50 -0800
Message-ID: <7a017bb331cad42caded56b3ea7d9242ecb6eacb.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: Gary Zambrano <zambrano@broadcom.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1055 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484Ab0BRBCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:02:08 -0500
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level>
Remove periods from formats
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/b44.c |   72 ++++++++++++++++++++++------------------------------
 1 files changed, 31 insertions(+), 41 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index f21cbe6..180510e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -10,6 +10,8 @@
  * Distribute under GPL.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
@@ -34,7 +36,6 @@
 #include "b44.h"
 
 #define DRV_MODULE_NAME		"b44"
-#define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"2.0"
 
 #define B44_DEF_MSG_ENABLE	  \
@@ -190,12 +191,9 @@ static int b44_wait_bit(struct b44 *bp, unsigned long reg,
 	}
 	if (i == timeout) {
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: BUG!  Timeout waiting for bit "
-			       "%08x of register "
-			       "%lx to %s.\n",
-			       bp->dev->name,
-			       bit, reg,
-			       (clear ? "clear" : "set"));
+			netdev_err(bp->dev, "BUG!  Timeout waiting for bit %08x of register %lx to %s\n",
+				   bit, reg, clear ? "clear" : "set");
+
 		return -ENODEV;
 	}
 	return 0;
@@ -335,8 +333,7 @@ static int b44_phy_reset(struct b44 *bp)
 	err = b44_readphy(bp, MII_BMCR, &val);
 	if (!err) {
 		if (val & BMCR_RESET) {
-			printk(KERN_ERR PFX "%s: PHY Reset would not complete.\n",
-			       bp->dev->name);
+			netdev_err(bp->dev, "PHY Reset would not complete\n");
 			err = -ENODEV;
 		}
 	}
@@ -415,7 +412,7 @@ static void b44_wap54g10_workaround(struct b44 *bp)
 	}
 	return;
 error:
-	printk(KERN_WARNING PFX "PHY: cannot reset MII transceiver isolate bit.\n");
+	pr_warning("PHY: cannot reset MII transceiver isolate bit\n");
 }
 #else
 static inline void b44_wap54g10_workaround(struct b44 *bp)
@@ -508,18 +505,15 @@ static void b44_stats_update(struct b44 *bp)
 static void b44_link_report(struct b44 *bp)
 {
 	if (!netif_carrier_ok(bp->dev)) {
-		printk(KERN_INFO PFX "%s: Link is down.\n", bp->dev->name);
+		netdev_info(bp->dev, "Link is down\n");
 	} else {
-		printk(KERN_INFO PFX "%s: Link is up at %d Mbps, %s duplex.\n",
-		       bp->dev->name,
-		       (bp->flags & B44_FLAG_100_BASE_T) ? 100 : 10,
-		       (bp->flags & B44_FLAG_FULL_DUPLEX) ? "full" : "half");
-
-		printk(KERN_INFO PFX "%s: Flow control is %s for TX and "
-		       "%s for RX.\n",
-		       bp->dev->name,
-		       (bp->flags & B44_FLAG_TX_PAUSE) ? "on" : "off",
-		       (bp->flags & B44_FLAG_RX_PAUSE) ? "on" : "off");
+		netdev_info(bp->dev, "Link is up at %d Mbps, %s duplex\n",
+			    (bp->flags & B44_FLAG_100_BASE_T) ? 100 : 10,
+			    (bp->flags & B44_FLAG_FULL_DUPLEX) ? "full" : "half");
+
+		netdev_info(bp->dev, "Flow control is %s for TX and %s for RX\n",
+			    (bp->flags & B44_FLAG_TX_PAUSE) ? "on" : "off",
+			    (bp->flags & B44_FLAG_RX_PAUSE) ? "on" : "off");
 	}
 }
 
@@ -578,11 +572,9 @@ static void b44_check_phy(struct b44 *bp)
 		}
 
 		if (bmsr & BMSR_RFAULT)
-			printk(KERN_WARNING PFX "%s: Remote fault detected in PHY\n",
-			       bp->dev->name);
+			netdev_warn(bp->dev, "Remote fault detected in PHY\n");
 		if (bmsr & BMSR_JCD)
-			printk(KERN_WARNING PFX "%s: Jabber detected in PHY\n",
-			       bp->dev->name);
+			netdev_warn(bp->dev, "Jabber detected in PHY\n");
 	}
 }
 
@@ -903,7 +895,7 @@ static irqreturn_t b44_interrupt(int irq, void *dev_id)
 		handled = 1;
 
 		if (unlikely(!netif_running(dev))) {
-			printk(KERN_INFO "%s: late interrupt.\n", dev->name);
+			netdev_info(dev, "late interrupt\n");
 			goto irq_ack;
 		}
 
@@ -928,8 +920,7 @@ static void b44_tx_timeout(struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	printk(KERN_ERR PFX "%s: transmit timed out, resetting\n",
-	       dev->name);
+	netdev_err(dev, "transmit timed out, resetting\n");
 
 	spin_lock_irq(&bp->lock);
 
@@ -958,8 +949,7 @@ static netdev_tx_t b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(bp) < 1)) {
 		netif_stop_queue(dev);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
+		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_out;
 	}
 
@@ -1335,7 +1325,7 @@ static void b44_halt(struct b44 *bp)
 	/* reset PHY */
 	b44_phy_reset(bp);
 	/* power down PHY */
-	printk(KERN_INFO PFX "%s: powering down PHY\n", bp->dev->name);
+	netdev_info(bp->dev, "powering down PHY\n");
 	bw32(bp, B44_MAC_CTRL, MAC_CTRL_PHY_PDOWN);
 	/* now reset the chip, but without enabling the MAC&PHY
 	 * part of it. This has to be done _after_ we shut down the PHY */
@@ -1526,7 +1516,7 @@ static void b44_setup_pseudo_magicp(struct b44 *bp)
 
 	pwol_pattern = kzalloc(B44_PATTERN_SIZE, GFP_KERNEL);
 	if (!pwol_pattern) {
-		printk(KERN_ERR PFX "Memory not available for WOL\n");
+		pr_err("Memory not available for WOL\n");
 		return;
 	}
 
@@ -2099,7 +2089,7 @@ static int __devinit b44_get_invariants(struct b44 *bp)
 	memcpy(bp->dev->dev_addr, addr, 6);
 
 	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){
-		printk(KERN_ERR PFX "Invalid MAC address found in EEPROM\n");
+		pr_err("Invalid MAC address found in EEPROM\n");
 		return -EINVAL;
 	}
 
@@ -2144,12 +2134,12 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 	instance++;
 
 	if (b44_version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
+		pr_info("%s", version);
 
 
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev) {
-		dev_err(sdev->dev, "Etherdev alloc failed, aborting.\n");
+		dev_err(sdev->dev, "Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto out;
 	}
@@ -2188,13 +2178,13 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 	err = ssb_dma_set_mask(sdev, DMA_BIT_MASK(30));
 	if (err) {
 		dev_err(sdev->dev,
-			"Required 30BIT DMA mask unsupported by the system.\n");
+			"Required 30BIT DMA mask unsupported by the system\n");
 		goto err_out_powerdown;
 	}
 	err = b44_get_invariants(bp);
 	if (err) {
 		dev_err(sdev->dev,
-			"Problem fetching invariants of chip, aborting.\n");
+			"Problem fetching invariants of chip, aborting\n");
 		goto err_out_powerdown;
 	}
 
@@ -2214,7 +2204,7 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 
 	err = register_netdev(dev);
 	if (err) {
-		dev_err(sdev->dev, "Cannot register net device, aborting.\n");
+		dev_err(sdev->dev, "Cannot register net device, aborting\n");
 		goto err_out_powerdown;
 	}
 
@@ -2225,8 +2215,8 @@ static int __devinit b44_init_one(struct ssb_device *sdev,
 	 */
 	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
 
-	printk(KERN_INFO "%s: Broadcom 44xx/47xx 10/100BaseT Ethernet %pM\n",
-	       dev->name, dev->dev_addr);
+	netdev_info(dev, "Broadcom 44xx/47xx 10/100BaseT Ethernet %pM\n",
+		    dev->dev_addr);
 
 	return 0;
 
@@ -2299,7 +2289,7 @@ static int b44_resume(struct ssb_device *sdev)
 
 	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
-		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
+		netdev_err(dev, "request_irq failed\n");
 		return rc;
 	}
 
-- 
1.7.0.14.g7e948

