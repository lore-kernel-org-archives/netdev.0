From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 21/21] ARCNET: com20020-pci: add rotary index support
Date: Fri, 24 Apr 2015 19:20:55 +0200
Message-ID: <1429896055-31680-22-git-send-email-m.grzeschik@pengutronix.de>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The EAE PLX-PCI card has a special rotary encoder
to configure the address of every card individually.
We take this information for the initial setup of
the cards dev_id.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 28 ++++++++++++++++++++++++++++
 include/linux/com20020.h          |  4 ++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index de8c894..308adb9 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -67,6 +67,7 @@ static void com20020pci_remove(struct pci_dev *pdev);
 static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct com20020_pci_card_info *ci;
+	struct com20020_pci_channel_map *mm;
 	struct net_device *dev;
 	struct arcnet_local *lp;
 	struct com20020_priv *priv;
@@ -83,9 +84,21 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 	ci = (struct com20020_pci_card_info *)id->driver_data;
 	priv->ci = ci;
+	mm = &ci->misc_map;
 
 	INIT_LIST_HEAD(&priv->list_dev);
 
+	if (mm->size) {
+		ioaddr = pci_resource_start(pdev, mm->bar) + mm->offset;
+		r = devm_request_region(&pdev->dev, ioaddr, mm->size,
+					"com20020-pci");
+		if (!r) {
+			pr_err("IO region %xh-%xh already allocated.\n",
+			       ioaddr, ioaddr + mm->size - 1);
+			return -EBUSY;
+		}
+		priv->misc = ioaddr;
+	}
 
 	for (i = 0; i < ci->devcount; i++) {
 		struct com20020_pci_channel_map *cm = &ci->chan_map_tbl[i];
@@ -132,6 +145,9 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 		lp->timeout = timeout;
 		lp->hw.owner = THIS_MODULE;
 
+		/* Get the dev_id from the PLX rotary coder */
+		dev->dev_id = inb(priv->misc + ci->rotary) >> 4;
+
 		if (inb(_STATUS) == 0xFF) {
 			pr_err("IO address %Xh is empty!\n", ioaddr);
 			ret = -EIO;
@@ -237,6 +253,12 @@ static struct com20020_pci_card_info card_info_eae_arc1 = {
 			.size = 0x08,
 		},
 	},
+	.misc_map = {
+		.bar = 2,
+		.offset = 0x10,
+		.size = 0x04,
+	},
+	.rotary = 0x0,
 	.flags = ARC_CAN_10MBIT,
 };
 
@@ -254,6 +276,12 @@ static struct com20020_pci_card_info card_info_eae_ma1 = {
 			.size = 0x08,
 		}
 	},
+	.misc_map = {
+		.bar = 2,
+		.offset = 0x10,
+		.size = 0x04,
+	},
+	.rotary = 0x0,
 	.flags = ARC_CAN_10MBIT,
 };
 
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 939d69d..8028ef8 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -47,6 +47,9 @@ struct com20020_pci_card_info {
 	int devcount;
 
 	struct com20020_pci_channel_map chan_map_tbl[PLX_PCI_MAX_CARDS];
+	struct com20020_pci_channel_map misc_map;
+
+	int rotary;
 
 	unsigned int flags;
 };
@@ -54,6 +57,7 @@ struct com20020_pci_card_info {
 struct com20020_priv {
 	struct com20020_pci_card_info *ci;
 	struct list_head list_dev;
+	int __iomem misc;
 };
 
 struct com20020_dev {
-- 
2.1.4
