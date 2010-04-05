From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/12] tg3: netdev_err() => dev_err()
Date: Mon, 5 Apr 2010 13:19:22 -0700
Message-ID: <1270498770-23765-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2386 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756444Ab0DEUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some uses of netdev_err() happen before the device has been registered.
This will cause the messages to be prepended with "(unregistered
net_device)" strings.  We can clean up the message by using dev_err()
instead.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 73006aa..80d3f15 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1098,7 +1098,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 
 	i = mdiobus_register(tp->mdio_bus);
 	if (i) {
-		netdev_warn(tp->dev, "mdiobus_reg failed (0x%x)\n", i);
+		dev_warn(&tp->pdev->dev, "mdiobus_reg failed (0x%x)\n", i);
 		mdiobus_free(tp->mdio_bus);
 		return i;
 	}
@@ -1106,7 +1106,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
 
 	if (!phydev || !phydev->drv) {
-		netdev_warn(tp->dev, "No PHY devices\n");
+		dev_warn(&tp->pdev->dev, "No PHY devices\n");
 		mdiobus_unregister(tp->mdio_bus);
 		mdiobus_free(tp->mdio_bus);
 		return -ENODEV;
@@ -1464,7 +1464,7 @@ static int tg3_phy_init(struct tg3 *tp)
 	phydev = phy_connect(tp->dev, dev_name(&phydev->dev), tg3_adjust_link,
 			     phydev->dev_flags, phydev->interface);
 	if (IS_ERR(phydev)) {
-		netdev_err(tp->dev, "Could not attach to PHY\n");
+		dev_err(&tp->pdev->dev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -6481,8 +6481,9 @@ static int tg3_abort_hw(struct tg3 *tp, int silent)
 			break;
 	}
 	if (i >= MAX_WAIT_CNT) {
-		netdev_err(tp->dev, "%s timed out, TX_MODE_ENABLE will not clear MAC_TX_MODE=%08x\n",
-			   __func__, tr32(MAC_TX_MODE));
+		dev_err(&tp->pdev->dev,
+			"%s timed out, TX_MODE_ENABLE will not clear "
+			"MAC_TX_MODE=%08x\n", __func__, tr32(MAC_TX_MODE));
 		err |= -ENODEV;
 	}
 
@@ -14514,7 +14515,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	tp->regs = pci_ioremap_bar(pdev, BAR_0);
 	if (!tp->regs) {
-		netdev_err(dev, "Cannot map device registers, aborting\n");
+		dev_err(&pdev->dev, "Cannot map device registers, aborting\n");
 		err = -ENOMEM;
 		goto err_out_free_dev;
 	}
@@ -14530,7 +14531,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	err = tg3_get_invariants(tp);
 	if (err) {
-		netdev_err(dev, "Problem fetching invariants of chip, aborting\n");
+		dev_err(&pdev->dev,
+			"Problem fetching invariants of chip, aborting\n");
 		goto err_out_iounmap;
 	}
 
@@ -14565,7 +14567,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 			err = pci_set_consistent_dma_mask(pdev,
 							  persist_dma_mask);
 			if (err < 0) {
-				netdev_err(dev, "Unable to obtain 64 bit DMA for consistent allocations\n");
+				dev_err(&pdev->dev, "Unable to obtain 64 bit "
+					"DMA for consistent allocations\n");
 				goto err_out_iounmap;
 			}
 		}
@@ -14573,7 +14576,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	if (err || dma_mask == DMA_BIT_MASK(32)) {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			netdev_err(dev, "No usable DMA configuration, aborting\n");
+			dev_err(&pdev->dev,
+				"No usable DMA configuration, aborting\n");
 			goto err_out_iounmap;
 		}
 	}
@@ -14622,14 +14626,16 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	err = tg3_get_device_address(tp);
 	if (err) {
-		netdev_err(dev, "Could not obtain valid ethernet address, aborting\n");
+		dev_err(&pdev->dev,
+			"Could not obtain valid ethernet address, aborting\n");
 		goto err_out_iounmap;
 	}
 
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
 		tp->aperegs = pci_ioremap_bar(pdev, BAR_2);
 		if (!tp->aperegs) {
-			netdev_err(dev, "Cannot map APE registers, aborting\n");
+			dev_err(&pdev->dev,
+				"Cannot map APE registers, aborting\n");
 			err = -ENOMEM;
 			goto err_out_iounmap;
 		}
@@ -14653,7 +14659,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	err = tg3_test_dma(tp);
 	if (err) {
-		netdev_err(dev, "DMA engine test failed, aborting\n");
+		dev_err(&pdev->dev, "DMA engine test failed, aborting\n");
 		goto err_out_apeunmap;
 	}
 
@@ -14714,7 +14720,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	err = register_netdev(dev);
 	if (err) {
-		netdev_err(dev, "Cannot register net device, aborting\n");
+		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
 		goto err_out_apeunmap;
 	}
 
-- 
1.6.4.4


