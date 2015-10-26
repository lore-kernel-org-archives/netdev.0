From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCHv2 net-next 4/6] arcnet: com20020-pci: add rotary index support
Date: Mon, 26 Oct 2015 09:23:18 +0100
Message-ID: <1445847800-13975-5-git-send-email-m.grzeschik@pengutronix.de>
References: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:59994 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbbJZIXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 04:23:32 -0400
In-Reply-To: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EAE PLX-PCI card has a special rotary encoder
to configure the address of every card individually.
We take this information for the initial setup of
the cards dev_id.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
v1 -> v2: kbuild test robot: fixed type of misc variable to resource_size_t

 drivers/net/arcnet/com20020-pci.c | 33 +++++++++++++++++++++++++++++++++
 drivers/net/arcnet/com20020.h     |  4 ++++
 2 files changed, 37 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index e3b7c14e..637a611 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -68,6 +68,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 			     const struct pci_device_id *id)
 {
 	struct com20020_pci_card_info *ci;
+	struct com20020_pci_channel_map *mm;
 	struct net_device *dev;
 	struct arcnet_local *lp;
 	struct com20020_priv *priv;
@@ -84,9 +85,22 @@ static int com20020pci_probe(struct pci_dev *pdev,
 
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
+
 	for (i = 0; i < ci->devcount; i++) {
 		struct com20020_pci_channel_map *cm = &ci->chan_map_tbl[i];
 		struct com20020_dev *card;
@@ -132,6 +146,13 @@ static int com20020pci_probe(struct pci_dev *pdev,
 		lp->timeout = timeout;
 		lp->hw.owner = THIS_MODULE;
 
+		/* Get the dev_id from the PLX rotary coder */
+		if (!strncmp(ci->name, "EAE PLX-PCI MA1", 15))
+			dev->dev_id = 0xc;
+		dev->dev_id ^= inb(priv->misc + ci->rotary) >> 4;
+
+		snprintf(dev->name, sizeof(dev->name), "arc%d-%d", dev->dev_id, i);
+
 		if (arcnet_inb(ioaddr, COM20020_REG_R_STATUS) == 0xFF) {
 			pr_err("IO address %Xh is empty!\n", ioaddr);
 			ret = -EIO;
@@ -235,6 +256,12 @@ static struct com20020_pci_card_info card_info_eae_arc1 = {
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
 
@@ -252,6 +279,12 @@ static struct com20020_pci_card_info card_info_eae_ma1 = {
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
 
diff --git a/drivers/net/arcnet/com20020.h b/drivers/net/arcnet/com20020.h
index 22a460f..f2ed2ef 100644
--- a/drivers/net/arcnet/com20020.h
+++ b/drivers/net/arcnet/com20020.h
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
+	resource_size_t misc;
 };
 
 struct com20020_dev {
-- 
2.6.1
