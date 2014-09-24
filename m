From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 3/5] ARCNET: add com20020 PCI IDs with metadata
Date: Wed, 24 Sep 2014 13:02:01 +0200
Message-ID: <1411556523-28100-4-git-send-email-m.grzeschik@pengutronix.de>
References: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411556523-28100-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds metadata for the com20020 to prepare for devices with
multiple io address areas with multi card interfaces.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 216 ++++++++++++++++++++++++++++++++------
 include/linux/com20020.h          |  16 +++
 2 files changed, 197 insertions(+), 35 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index cbc44f5..d08d539 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -63,6 +63,8 @@ MODULE_LICENSE("GPL");
 
 static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
+	struct com20020_pci_channel_map *cm;
+	struct com20020_pci_card_info *ci;
 	struct net_device *dev;
 	struct arcnet_local *lp;
 	int ioaddr, err;
@@ -75,19 +77,15 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 
 	dev->netdev_ops = &com20020_netdev_ops;
 
+	ci = (struct com20020_pci_card_info *)id->driver_data;
+
 	lp = netdev_priv(dev);
 
 	pci_set_drvdata(pdev, dev);
 
-	// SOHARD needs PCI base addr 4
-	if (pdev->vendor==0x10B5) {
-		BUGMSG(D_NORMAL, "SOHARD\n");
-		ioaddr = pci_resource_start(pdev, 4);
-	}
-	else {
-		BUGMSG(D_NORMAL, "Contemporary Controls\n");
-		ioaddr = pci_resource_start(pdev, 2);
-	}
+	cm = &ci->chan_map_tbl[0];
+	BUGMSG(D_NORMAL, "%s Controls\n", ci->name);
+	ioaddr = pci_resource_start(pdev, cm->bar);
 
 	if (!request_region(ioaddr, ARCNET_TOTAL_SIZE, "com20020-pci")) {
 		BUGMSG(D_INIT, "IO region %xh-%xh already allocated.\n",
@@ -105,7 +103,7 @@ static int com20020pci_probe(struct pci_dev *pdev, const struct pci_device_id *i
 	dev->irq = pdev->irq;
 	dev->dev_addr[0] = node;
 	lp->card_name = "PCI COM20020";
-	lp->card_flags = id->driver_data;
+	lp->card_flags = ci->flags;
 	lp->backplane = backplane;
 	lp->clockp = clockp & 7;
 	lp->clockm = clockm & 3;
@@ -144,32 +142,180 @@ static void com20020pci_remove(struct pci_dev *pdev)
 	free_netdev(dev);
 }
 
+static struct com20020_pci_card_info card_info_10mbit = {
+	.name = "ARC-PCI",
+	.devcount = 1,
+	.chan_map_tbl = {
+		{ 2, 0x00, 0x08 },
+	},
+	.flags = ARC_CAN_10MBIT,
+};
+
+static struct com20020_pci_card_info card_info_5mbit = {
+	.name = "ARC-PCI",
+	.devcount = 1,
+	.chan_map_tbl = {
+		{ 2, 0x00, 0x08 },
+	},
+	.flags = ARC_IS_5MBIT,
+};
+
+static struct com20020_pci_card_info card_info_sohard = {
+	.name = "PLX-PCI",
+	.devcount = 1,
+	/* SOHARD needs PCI base addr 4 */
+	.chan_map_tbl = {
+		{4, 0x00, 0x08},
+	},
+	.flags = ARC_CAN_10MBIT,
+};
+
 static DEFINE_PCI_DEVICE_TABLE(com20020pci_id_table) = {
-	{ 0x1571, 0xa001, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa003, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa004, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa006, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa007, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa008, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
-	{ 0x1571, 0xa009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
-	{ 0x1571, 0xa00a, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
-	{ 0x1571, 0xa00b, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
-	{ 0x1571, 0xa00c, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
-	{ 0x1571, 0xa00d, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
-	{ 0x1571, 0xa00e, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_IS_5MBIT },
-	{ 0x1571, 0xa201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x1571, 0xa202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x1571, 0xa203, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x1571, 0xa204, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x1571, 0xa205, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x1571, 0xa206, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x9030, 0x10B5,     0x2978,     0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x9050, 0x10B5,     0x2273,     0, 0, ARC_CAN_10MBIT },
-	{ 0x14BA, 0x6000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x2200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{0,}
+	{
+		0x1571, 0xa001,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0,
+	},
+	{
+		0x1571, 0xa002,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0,
+	},
+	{
+		0x1571, 0xa003,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0
+	},
+	{
+		0x1571, 0xa004,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0,
+	},
+	{
+		0x1571, 0xa005,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0
+	},
+	{
+		0x1571, 0xa006,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0
+	},
+	{
+		0x1571, 0xa007,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0
+	},
+	{
+		0x1571, 0xa008,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		0
+	},
+	{
+		0x1571, 0xa009,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_5mbit
+	},
+	{
+		0x1571, 0xa00a,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_5mbit
+	},
+	{
+		0x1571, 0xa00b,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_5mbit
+	},
+	{
+		0x1571, 0xa00c,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_5mbit
+	},
+	{
+		0x1571, 0xa00d,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_5mbit
+	},
+	{
+		0x1571, 0xa00e,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_5mbit
+	},
+	{
+		0x1571, 0xa201,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x1571, 0xa202,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x1571, 0xa203,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x1571, 0xa204,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x1571, 0xa205,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x1571, 0xa206,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x10B5, 0x9030,
+		0x10B5, 0x2978,
+		0, 0,
+		(kernel_ulong_t)&card_info_sohard
+	},
+	{
+		0x10B5, 0x9050,
+		0x10B5, 0x2273,
+		0, 0,
+		(kernel_ulong_t)&card_info_sohard
+	},
+	{
+		0x14BA, 0x6000,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{
+		0x10B5, 0x2200,
+		PCI_ANY_ID, PCI_ANY_ID,
+		0, 0,
+		(kernel_ulong_t)&card_info_10mbit
+	},
+	{ 0, }
 };
 
 MODULE_DEVICE_TABLE(pci, com20020pci_id_table);
diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 5dcfb94..6a1ceca 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -41,6 +41,22 @@ extern const struct net_device_ops com20020_netdev_ops;
 #define BUS_ALIGN  1
 #endif
 
+#define PLX_PCI_MAX_CARDS 1
+
+struct com20020_pci_channel_map {
+	u32 bar;
+	u32 offset;
+	u32 size;               /* 0x00 - auto, e.g. length of entire bar */
+};
+
+struct com20020_pci_card_info {
+	const char *name;
+	int devcount;
+
+	struct com20020_pci_channel_map chan_map_tbl[PLX_PCI_MAX_CARDS];
+
+	unsigned int flags;
+};
 
 #define _INTMASK  (ioaddr+BUS_ALIGN*0)	/* writable */
 #define _STATUS   (ioaddr+BUS_ALIGN*0)	/* readable */
-- 
2.1.0
