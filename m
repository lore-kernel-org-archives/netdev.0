From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 4/5] ARCNET: add support for multi interfaces on com20020
Date: Wed, 24 Sep 2014 13:02:02 +0200
Message-ID: <1411556523-28100-5-git-send-email-m.grzeschik@pengutronix.de>
References: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The com20020-pci driver is currently designed to instance
one netdev with one pci device. This patch adds support to
instance many cards with one pci device, depending on the device
data in the private data.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 149 ++++++++++++++++++++++++--------------
 include/linux/com20020.h          |  15 +++-
 2 files changed, 109 insertions(+), 55 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index d08d539..7437174c 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -38,6 +38,7 @@
 #include <linux/pci.h>
 #include <linux/arcdevice.h>
 #include <linux/com20020.h>
+#include <linux/list.h>
 
 #include <asm/io.h>
 
@@ -61,85 +62,125 @@ module_param(clockp, int, 0);
 module_param(clockm, int, 0);
 MODULE_LICENSE("GPL");
 
+static void com20020pci_remove(struct pci_dev *pdev);
+
 static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
-	struct com20020_pci_channel_map *cm;
 	struct com20020_pci_card_info *ci;
 	struct net_device *dev;
 	struct arcnet_local *lp;
-	int ioaddr, err;
+	struct com20020_priv *priv;
+	int i, ioaddr, ret;
+	struct resource *r;
 
 	if (pci_enable_device(pdev))
 		return -EIO;
-	dev = alloc_arcdev(device);
-	if (!dev)
-		return -ENOMEM;
-
-	dev->netdev_ops = &com20020_netdev_ops;
 
+	priv = devm_kzalloc(&pdev->dev, sizeof(struct com20020_priv),
+			    GFP_KERNEL);
 	ci = (struct com20020_pci_card_info *)id->driver_data;
+	priv->ci = ci;
 
-	lp = netdev_priv(dev);
+	INIT_LIST_HEAD(&priv->list_dev);
 
-	pci_set_drvdata(pdev, dev);
 
-	cm = &ci->chan_map_tbl[0];
-	BUGMSG(D_NORMAL, "%s Controls\n", ci->name);
-	ioaddr = pci_resource_start(pdev, cm->bar);
+	for (i = 0; i < ci->devcount; i++) {
+		struct com20020_pci_channel_map *cm = &ci->chan_map_tbl[i];
+		struct com20020_dev *card;
 
-	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "com20020-pci")) {
-		BUGMSG(D_INIT, "IO region %xh-%xh already allocated.\n",
-		       ioaddr, ioaddr + ARCNET_TOTAL_SIZE - 1);
-		err = -EBUSY;
-		goto out_dev;
-	}
+		dev = alloc_arcdev(device);
+		if (!dev) {
+			ret = -ENOMEM;
+			goto out_port;
+		}
 
-	// Dummy access after Reset
-	// ARCNET controller needs this access to detect bustype
-	outb(0x00,ioaddr+1);
-	inb(ioaddr+1);
-
-	dev->base_addr = ioaddr;
-	dev->irq = pdev->irq;
-	dev->dev_addr[0] = node;
-	lp->card_name = "PCI COM20020";
-	lp->card_flags = ci->flags;
-	lp->backplane = backplane;
-	lp->clockp = clockp & 7;
-	lp->clockm = clockm & 3;
-	lp->timeout = timeout;
-	lp->hw.owner = THIS_MODULE;
-
-	if (ASTATUS() == 0xFF) {
-		BUGMSG(D_NORMAL, "IO address %Xh was reported by PCI BIOS, "
-		       "but seems empty!\n", ioaddr);
-		err = -EIO;
-		goto out_port;
-	}
-	if (com20020_check(dev)) {
-		err = -EIO;
-		goto out_port;
+		dev->netdev_ops = &com20020_netdev_ops;
+
+		lp = netdev_priv(dev);
+
+		BUGMSG(D_NORMAL, "%s Controls\n", ci->name);
+		ioaddr = pci_resource_start(pdev, cm->bar) + cm->offset;
+
+		r = devm_request_region(&pdev->dev, ioaddr, cm->size,
+					"com20020-pci");
+		if (!r) {
+			pr_err("IO region %xh-%xh already allocated.\n",
+			       ioaddr, ioaddr + cm->size - 1);
+			ret = -EBUSY;
+			goto out_port;
+		}
+
+		/* Dummy access after Reset
+		 * ARCNET controller needs
+		 * this access to detect bustype
+		 */
+		outb(0x00, ioaddr + 1);
+		inb(ioaddr + 1);
+
+		dev->base_addr = ioaddr;
+		dev->dev_addr[0] = node;
+		dev->irq = pdev->irq;
+		lp->card_name = "PCI COM20020";
+		lp->card_flags = ci->flags;
+		lp->backplane = backplane;
+		lp->clockp = clockp & 7;
+		lp->clockm = clockm & 3;
+		lp->timeout = timeout;
+		lp->hw.owner = THIS_MODULE;
+
+		if (ASTATUS() == 0xFF) {
+			pr_err("IO address %Xh is empty!\n", ioaddr);
+			ret = -EIO;
+			goto out_port;
+		}
+		if (com20020_check(dev)) {
+			ret = -EIO;
+			goto out_port;
+		}
+
+		card = devm_kzalloc(&pdev->dev, sizeof(struct com20020_dev),
+				    GFP_KERNEL);
+		if (!card) {
+			pr_err("%s out of memory!\n", __func__);
+			return -ENOMEM;
+		}
+
+		card->index = i;
+		card->pci_priv = priv;
+		card->dev = dev;
+
+		dev_set_drvdata(&dev->dev, card);
+
+		ret = com20020_found(dev, IRQF_SHARED);
+		if (ret)
+			goto out_port;
+
+		list_add(&card->list, &priv->list_dev);
 	}
 
-	if ((err = com20020_found(dev, IRQF_SHARED)) != 0)
-	        goto out_port;
+	pci_set_drvdata(pdev, priv);
 
 	return 0;
 
 out_port:
-	release_region(ioaddr, ARCNET_TOTAL_SIZE);
-out_dev:
-	free_netdev(dev);
-	return err;
+	com20020pci_remove(pdev);
+	return ret;
 }
 
 static void com20020pci_remove(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
-	free_netdev(dev);
+	struct com20020_dev *card, *tmpcard;
+	struct com20020_priv *priv;
+
+	priv = pci_get_drvdata(pdev);
+
+	list_for_each_entry_safe(card, tmpcard, &priv->list_dev, list) {
+		struct net_device *dev = card->dev;
+
+		unregister_netdev(dev);
+		free_irq(dev->irq, dev);
+		free_netdev(dev);
+	}
 }
 
 static struct com20020_pci_card_info card_info_10mbit = {
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 6a1ceca..8589899 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -41,7 +41,7 @@ extern const struct net_device_ops com20020_netdev_ops;
 #define BUS_ALIGN  1
 #endif
 
-#define PLX_PCI_MAX_CARDS 1
+#define PLX_PCI_MAX_CARDS 2
 
 struct com20020_pci_channel_map {
 	u32 bar;
@@ -58,6 +58,19 @@ struct com20020_pci_card_info {
 	unsigned int flags;
 };
 
+struct com20020_priv {
+	struct com20020_pci_card_info *ci;
+	struct list_head list_dev;
+};
+
+struct com20020_dev {
+	struct list_head list;
+	struct net_device *dev;
+
+	struct com20020_priv *pci_priv;
+	int index;
+};
+
 #define _INTMASK  (ioaddr+BUS_ALIGN*0)	/* writable */
 #define _STATUS   (ioaddr+BUS_ALIGN*0)	/* readable */
 #define _COMMAND  (ioaddr+BUS_ALIGN*1)	/* standard arcnet commands */
-- 
2.1.0
