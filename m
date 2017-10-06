From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH net v2 9/9] net/mac8390: Fix log messages
Date: Thu,  5 Oct 2017 21:11:05 -0400 (EDT)
Message-ID: <ae1c04acf9d2770e397f8ee01f3ef2bbecd444d3.1507211120.git.fthain@telegraphics.com.au>
References: <cover.1507211120.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507211120.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before expansion, dev->name is "eth%d", so log the slot number instead.
Log the MAC address after the interface gets a meaningful name.
Disambiguate the two identical "Card type %s is unsupported" messages.
Fix the duplicated driver name in the pr_warn() message.

Fixes: 3a3a7f3b7fbd ("net: mac8390: Allow modular build")
Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
Tested-by: Stan Johnson <userm57@yahoo.com>
---
 drivers/net/ethernet/8390/mac8390.c | 35 ++++++++++++++++++-----------------
 1 file changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index 1bfc66f37971..45d724d8333a 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -307,14 +307,15 @@ static bool __init mac8390_init(struct net_device *dev, struct nubus_dev *ndev,
 	 */
 
 	if (nubus_get_func_dir(ndev, &dir) == -1) {
-		pr_err("%s: Unable to get Nubus functional directory for slot %X!\n",
-		       dev->name, ndev->board->slot);
+		pr_err("Unable to get Nubus functional directory for slot %X!\n",
+		       ndev->board->slot);
 		return false;
 	}
 
 	/* Get the MAC address */
 	if (nubus_find_rsrc(&dir, NUBUS_RESID_MAC_ADDRESS, &ent) == -1) {
-		pr_info("%s: Couldn't get MAC address!\n", dev->name);
+		pr_info("MAC address resource for slot %X not found!\n",
+		        ndev->board->slot);
 		return false;
 	}
 
@@ -324,8 +325,8 @@ static bool __init mac8390_init(struct net_device *dev, struct nubus_dev *ndev,
 		nubus_rewinddir(&dir);
 		if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_BASEOS,
 				    &ent) == -1) {
-			pr_err("%s: Memory offset resource for slot %X not found!\n",
-			       dev->name, ndev->board->slot);
+			pr_err("Memory offset resource for slot %X not found!\n",
+			       ndev->board->slot);
 			return false;
 		}
 		nubus_get_rsrc_mem(&offset, &ent, 4);
@@ -335,8 +336,8 @@ static bool __init mac8390_init(struct net_device *dev, struct nubus_dev *ndev,
 		nubus_rewinddir(&dir);
 		if (nubus_find_rsrc(&dir, NUBUS_RESID_MINOR_LENGTH,
 				    &ent) == -1) {
-			pr_info("%s: Memory length resource for slot %X not found, probing\n",
-				dev->name, ndev->board->slot);
+			pr_info("Memory length resource for slot %X not found, probing\n",
+				ndev->board->slot);
 			offset = mac8390_memsize(dev->mem_start);
 		} else {
 			nubus_get_rsrc_mem(&offset, &ent, 4);
@@ -379,8 +380,8 @@ static bool __init mac8390_init(struct net_device *dev, struct nubus_dev *ndev,
 			break;
 
 		default:
-			pr_err("Card type %s is unsupported, sorry\n",
-			       ndev->board->name);
+			pr_err("No known base address for %s card in slot %X\n",
+			       ndev->board->name, ndev->board->slot);
 			return false;
 		}
 	}
@@ -435,6 +436,9 @@ struct net_device * __init mac8390_probe(int unit)
 	err = register_netdev(dev);
 	if (err)
 		goto out;
+
+	netdev_info(dev, "MAC %pM, IRQ %d\n", dev->dev_addr, dev->irq);
+
 	return dev;
 
 out:
@@ -453,7 +457,7 @@ int __init init_module(void)
 {
 	dev_mac8390 = mac8390_probe(-1);
 	if (IS_ERR(dev_mac8390)) {
-		pr_warn("mac8390: No card found\n");
+		pr_warn("No card found\n");
 		return PTR_ERR(dev_mac8390);
 	}
 	return 0;
@@ -600,19 +604,16 @@ static int __init mac8390_initdev(struct net_device *dev,
 		break;
 
 	default:
-		pr_err("Card type %s is unsupported, sorry\n",
-		       ndev->board->name);
+		pr_err("%s card in slot %X is unsupported, sorry\n",
+		       ndev->board->name, ndev->board->slot);
 		return -ENODEV;
 	}
 
 	__NS8390_init(dev, 0);
 
 	/* Good, done, now spit out some messages */
-	pr_info("%s: %s in slot %X (type %s)\n",
-		dev->name, ndev->board->name, ndev->board->slot,
-		cardname[type]);
-	pr_info("MAC %pM IRQ %d, %d KB shared memory at %#lx, %d-bit access.\n",
-		dev->dev_addr, dev->irq,
+	pr_info("%s in slot %X has type %s, %d KB shared memory at %#lx, %d-bit access\n",
+		ndev->board->name, ndev->board->slot, cardname[type],
 		(unsigned int)(dev->mem_end - dev->mem_start) >> 10,
 		dev->mem_start, access_bitmode ? 32 : 16);
 	return 0;
-- 
2.13.5
