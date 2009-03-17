From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 03/30] solos: FPGA and firmware update support.
Date: Tue, 17 Mar 2009 21:29:11 +0000
Message-ID: <1237325351.27681.332.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37651 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433AbZCQV3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:15 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1LjgqX-0001ul-2S
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:13 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just a straight pull in of changes, syncing us up to 0.07 from
openadsl.sf.net

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: Simon Farnsworth <simon@farnz.org.uk>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |  171 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 169 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 3daa3a3..2b472c8 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -9,6 +9,7 @@
  *
  * Authors: Nathan Williams <nathan@traverse.com.au>
  *          David Woodhouse <dwmw2@infradead.org>
+ *          Treker Chen <treker@xrio.com>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -36,8 +37,9 @@
 #include <linux/sysfs.h>
 #include <linux/device.h>
 #include <linux/kobject.h>
+#include <linux/firmware.h>
 
-#define VERSION "0.04"
+#define VERSION "0.07"
 #define PTAG "solos-pci"
 
 #define CONFIG_RAM_SIZE	128
@@ -45,16 +47,27 @@
 #define IRQ_EN_ADDR	0x78
 #define FPGA_VER	0x74
 #define IRQ_CLEAR	0x70
-#define BUG_FLAG	0x6C
+#define WRITE_FLASH	0x6C
+#define PORTS		0x68
+#define FLASH_BLOCK	0x64
+#define FLASH_BUSY	0x60
+#define FPGA_MODE	0x5C
+#define FLASH_MODE	0x58
 
 #define DATA_RAM_SIZE	32768
 #define BUF_SIZE	4096
+#define FPGA_PAGE	528 /* FPGA flash page size*/
+#define SOLOS_PAGE	512 /* Solos flash page size*/
+#define FPGA_BLOCK	(FPGA_PAGE * 8) /* FPGA flash block size*/
+#define SOLOS_BLOCK	(SOLOS_PAGE * 8) /* Solos flash block size*/
 
 #define RX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2)
 #define TX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2 + BUF_SIZE)
 
 static int debug = 0;
 static int atmdebug = 0;
+static int firmware_upgrade = 0;
+static int fpga_upgrade = 0;
 
 struct pkt_hdr {
 	__le16 size;
@@ -80,6 +93,7 @@ struct solos_card {
 	spinlock_t cli_queue_lock;
 	struct sk_buff_head tx_queue[4];
 	struct sk_buff_head cli_queue[4];
+	int flash_chip;
 };
 
 #define SOLOS_CHAN(atmdev) ((int)(unsigned long)(atmdev)->phy_data)
@@ -90,11 +104,19 @@ MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL");
 MODULE_PARM_DESC(debug, "Enable Loopback");
 MODULE_PARM_DESC(atmdebug, "Print ATM data");
+MODULE_PARM_DESC(firmware_upgrade, "Initiate Solos firmware upgrade");
+MODULE_PARM_DESC(fpga_upgrade, "Initiate FPGA upgrade");
 module_param(debug, int, 0444);
 module_param(atmdebug, int, 0644);
+module_param(firmware_upgrade, int, 0444);
+module_param(fpga_upgrade, int, 0444);
 
 static int opens;
+static struct firmware *fw;
+static int flash_offset;
 
+void flash_upgrade(struct solos_card *);
+void flash_write(struct solos_card *);
 static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc);
 static int fpga_tx(struct solos_card *);
@@ -180,6 +202,131 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 
 static DEVICE_ATTR(console, 0644, console_show, console_store);
 
+void flash_upgrade(struct solos_card *card){
+	uint32_t data32 = 0;
+	int blocksize = 0;
+	int numblocks = 0;
+	dev_info(&card->dev->dev, "Flash upgrade started\n");
+	if (card->flash_chip == 0) {
+		if (request_firmware((const struct firmware **)&fw,
+				"solos-FPGA.bin",&card->dev->dev))
+		{
+			dev_info(&card->dev->dev,
+					"Failed to find firmware\n");
+			return;
+		}
+		blocksize = FPGA_BLOCK;
+	} else {
+		if (request_firmware((const struct firmware **)&fw,
+				"solos-Firmware.bin",&card->dev->dev))
+		{
+			dev_info(&card->dev->dev,
+					"Failed to find firmware\n");
+			return;
+		}
+		blocksize = SOLOS_BLOCK;
+	}
+	numblocks = fw->size/blocksize;
+	dev_info(&card->dev->dev, "Firmware size: %d\n", fw->size);
+	dev_info(&card->dev->dev, "Number of blocks: %d\n", numblocks);
+	
+		
+	dev_info(&card->dev->dev, "Changing FPGA to Update mode\n");
+	iowrite32(1, card->config_regs + FPGA_MODE);
+	data32 = ioread32(card->config_regs + FPGA_MODE); 
+	/*Set mode to Chip Erase*/
+	if (card->flash_chip == 0) {
+		dev_info(&card->dev->dev, 
+				"Set FPGA Flash mode to FPGA Chip Erase\n");
+	} else {
+		dev_info(&card->dev->dev, 
+				"Set FPGA Flash mode to Solos Chip Erase\n");
+	}
+	iowrite32((card->flash_chip * 2), card->config_regs + FLASH_MODE);
+	flash_offset = 0;
+	iowrite32(1, card->config_regs + WRITE_FLASH);
+	return;
+}
+
+void flash_write(struct solos_card *card){
+	int block;
+	int block_num;
+	int blocksize;
+	int i;
+	uint32_t data32 = 0;
+
+	/*Clear write flag*/
+	iowrite32(0, card->config_regs + WRITE_FLASH);
+	/*Set mode to Block Write*/
+	/*dev_info(&card->dev->dev, "Set FPGA Flash mode to Block Write\n");*/
+	iowrite32(((card->flash_chip * 2) + 1), card->config_regs + FLASH_MODE);
+
+	/*When finished programming flash, release firmware and exit*/
+	if (fw->size - flash_offset == 0) {
+		//release_firmware(fw); /* This crashes for some reason */
+		iowrite32(0, card->config_regs + WRITE_FLASH);
+		iowrite32(0, card->config_regs + FPGA_MODE);
+		iowrite32(0, card->config_regs + FLASH_MODE);
+		dev_info(&card->dev->dev, "Returning FPGA to Data mode\n");
+		return;
+	}
+	if (card->flash_chip == 0) {
+		blocksize = FPGA_BLOCK;
+	} else {
+		blocksize = SOLOS_BLOCK;
+	}
+	
+	/*Calculate block size*/
+	if ((fw->size - flash_offset) > blocksize) {
+		block = blocksize;
+	} else {
+		block = fw->size - flash_offset;
+	}
+	block_num = flash_offset / blocksize;
+	//dev_info(&card->dev->dev, "block %d/%d\n",block_num + 1,(fw->size/512/8));
+
+	/*Copy block into RAM*/
+	for(i=0;i<block;i++){
+		if(i%4 == 0){
+			//dev_info(&card->dev->dev, "i: %d\n", i);
+			data32=0x00000000;
+		}
+		
+		switch(i%4){
+		case 0:
+			data32 |= 0x0000FF00 & 
+				(*(fw->data + i + flash_offset)	<< 8);
+			break;
+		case 1:
+			data32 |= 0x000000FF & *(fw->data + i + flash_offset);
+			break;
+		case 2:
+			data32 |= 0xFF000000 &
+					(*(fw->data + i + flash_offset)	<< 24);
+			break;
+		case 3:
+			data32 |= 0x00FF0000 &
+					(*(fw->data + i + flash_offset)	<< 16);
+			break;
+		}
+
+		if (i%4 == 3) {
+			iowrite32(data32, RX_BUF(card, 3) + i - 3);
+		}
+	}
+	i--;
+	if (i%4 != 3) {
+		iowrite32(data32, RX_BUF(card, 3) + i - (i%4));
+	}
+
+	/*Specify block number and then trigger flash write*/
+	iowrite32(block_num, card->config_regs + FLASH_BLOCK);
+	iowrite32(1, card->config_regs + WRITE_FLASH);
+//	iowrite32(0, card->config_regs + WRITE_FLASH);
+	flash_offset += block;
+	return;
+}
+
 static irqreturn_t solos_irq(int irq, void *dev_id)
 {
 	struct solos_card *card = dev_id;
@@ -207,6 +354,17 @@ void solos_bh(unsigned long card_arg)
 	uint32_t card_flags;
 	uint32_t tx_mask;
 	uint32_t rx_done = 0;
+	uint32_t data32;
+
+	data32 = ioread32(card->config_regs + FPGA_MODE); 
+	if (data32 != 0) {
+		data32 = ioread32(card->config_regs + FLASH_BUSY); 
+		if (data32 == 0) {
+			flash_write(card);
+		}	
+		return;
+	}
+		
 
 	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
 
@@ -680,6 +838,15 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	// Enable IRQs
 	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
 
+	if(firmware_upgrade != 0){
+		card->flash_chip = 1;
+		flash_upgrade(card);
+	} else {
+		if(fpga_upgrade != 0){
+			card->flash_chip = 0;
+			flash_upgrade(card);
+		}
+	}
 	return 0;
 
  out_unmap_both:
-- 
1.6.0.6


