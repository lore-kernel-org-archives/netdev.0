From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 3/4] solos-pci: add firmware upgrade support for new models
Date: Wed, 19 Dec 2012 21:01:20 +0000
Message-ID: <1355950881-31550-3-git-send-email-dwmw2@infradead.org>
References: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Cc: Nathan Williams <nathan@traverse.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:34934
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093Ab2LSVBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 16:01:36 -0500
In-Reply-To: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Williams <nathan@traverse.com.au>

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 53 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 11 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 50e5c56..aa4f35d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -42,7 +42,8 @@
 #include <linux/swab.h>
 #include <linux/slab.h>
 
-#define VERSION "0.07"
+#define VERSION "1.04"
+#define DRIVER_VERSION 0x01
 #define PTAG "solos-pci"
 
 #define CONFIG_RAM_SIZE	128
@@ -57,16 +58,20 @@
 #define FPGA_MODE	0x5C
 #define FLASH_MODE	0x58
 #define GPIO_STATUS	0x54
+#define DRIVER_VER	0x50
 #define TX_DMA_ADDR(port)	(0x40 + (4 * (port)))
 #define RX_DMA_ADDR(port)	(0x30 + (4 * (port)))
 
 #define DATA_RAM_SIZE	32768
 #define BUF_SIZE	2048
 #define OLD_BUF_SIZE	4096 /* For FPGA versions <= 2*/
-#define FPGA_PAGE	528 /* FPGA flash page size*/
-#define SOLOS_PAGE	512 /* Solos flash page size*/
-#define FPGA_BLOCK	(FPGA_PAGE * 8) /* FPGA flash block size*/
-#define SOLOS_BLOCK	(SOLOS_PAGE * 8) /* Solos flash block size*/
+/* Old boards use ATMEL AD45DB161D flash */
+#define ATMEL_FPGA_PAGE	528 /* FPGA flash page size*/
+#define ATMEL_SOLOS_PAGE	512 /* Solos flash page size*/
+#define ATMEL_FPGA_BLOCK	(ATMEL_FPGA_PAGE * 8) /* FPGA block size*/
+#define ATMEL_SOLOS_BLOCK	(ATMEL_SOLOS_PAGE * 8) /* Solos block size*/
+/* Current boards use M25P/M25PE SPI flash */
+#define SPI_FLASH_BLOCK	(256 * 64)
 
 #define RX_BUF(card, nr) ((card->buffers) + (nr)*(card->buffer_size)*2)
 #define TX_BUF(card, nr) ((card->buffers) + (nr)*(card->buffer_size)*2 + (card->buffer_size))
@@ -128,6 +133,7 @@ struct solos_card {
 	int using_dma;
 	int fpga_version;
 	int buffer_size;
+	int atmel_flash;
 };
 
 
@@ -630,16 +636,25 @@ static int flash_upgrade(struct solos_card *card, int chip)
 	switch (chip) {
 	case 0:
 		fw_name = "solos-FPGA.bin";
-		blocksize = FPGA_BLOCK;
+		if (card->atmel_flash)
+			blocksize = ATMEL_FPGA_BLOCK;
+		else
+			blocksize = SPI_FLASH_BLOCK;
 		break;
 	case 1:
 		fw_name = "solos-Firmware.bin";
-		blocksize = SOLOS_BLOCK;
+		if (card->atmel_flash)
+			blocksize = ATMEL_SOLOS_BLOCK;
+		else
+			blocksize = SPI_FLASH_BLOCK;
 		break;
 	case 2:
 		if (card->fpga_version > LEGACY_BUFFERS){
 			fw_name = "solos-db-FPGA.bin";
-			blocksize = FPGA_BLOCK;
+			if (card->atmel_flash)
+				blocksize = ATMEL_FPGA_BLOCK;
+			else
+				blocksize = SPI_FLASH_BLOCK;
 		} else {
 			dev_info(&card->dev->dev, "FPGA version doesn't support"
 					" daughter board upgrades\n");
@@ -649,7 +664,10 @@ static int flash_upgrade(struct solos_card *card, int chip)
 	case 3:
 		if (card->fpga_version > LEGACY_BUFFERS){
 			fw_name = "solos-Firmware.bin";
-			blocksize = SOLOS_BLOCK;
+			if (card->atmel_flash)
+				blocksize = ATMEL_SOLOS_BLOCK;
+			else
+				blocksize = SPI_FLASH_BLOCK;
 		} else {
 			dev_info(&card->dev->dev, "FPGA version doesn't support"
 					" daughter board upgrades\n");
@@ -665,6 +683,9 @@ static int flash_upgrade(struct solos_card *card, int chip)
 
 	dev_info(&card->dev->dev, "Flash upgrade starting\n");
 
+	/* New FPGAs require driver version before permitting flash upgrades */
+	iowrite32(DRIVER_VERSION, card->config_regs + DRIVER_VER);
+
 	numblocks = fw->size / blocksize;
 	dev_info(&card->dev->dev, "Firmware size: %zd\n", fw->size);
 	dev_info(&card->dev->dev, "Number of blocks: %d\n", numblocks);
@@ -694,9 +715,13 @@ static int flash_upgrade(struct solos_card *card, int chip)
 		/* dev_info(&card->dev->dev, "Set FPGA Flash mode to Block Write\n"); */
 		iowrite32(((chip * 2) + 1), card->config_regs + FLASH_MODE);
 
-		/* Copy block to buffer, swapping each 16 bits */
+		/* Copy block to buffer, swapping each 16 bits for Atmel flash */
 		for(i = 0; i < blocksize; i += 4) {
-			uint32_t word = swahb32p((uint32_t *)(fw->data + offset + i));
+			uint32_t word;
+			if (card->atmel_flash)
+				word = swahb32p((uint32_t *)(fw->data + offset + i));
+			else
+				word = *(uint32_t *)(fw->data + offset + i);
 			if(card->fpga_version > LEGACY_BUFFERS)
 				iowrite32(word, FLASH_BUF + i);
 			else
@@ -1230,6 +1255,12 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		db_fpga_upgrade = db_firmware_upgrade = 0;
 	}
 
+	/* Stopped using Atmel flash after 0.03-38 */
+	if (fpga_ver < 39)
+		card->atmel_flash = 1;
+	else
+		card->atmel_flash = 0;
+
 	if (card->fpga_version >= DMA_SUPPORTED) {
 		pci_set_master(dev);
 		card->using_dma = 1;
-- 
1.8.0.1
