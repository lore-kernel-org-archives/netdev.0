From: Nathan Williams <nathan@traverse.com.au>
Subject: [PATCH 4/4] atm: solos-pci: M25P/M25PE SPI flash support
Date: Wed, 05 Oct 2011 15:46:08 +1100
Message-ID: <1317789968.2424.91.camel@dualcore.traverse>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net,
	David Woodhouse <dwmw2@infradead.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Newer Geos ADSL2+ routers have different SPI flash.
The FPGA on these boards require driver version = 1 to enable
flash upgrades so old drivers can't corrupt new boards.

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
---
 drivers/atm/solos-pci.c |   51 ++++++++++++++++++++++++++++++++++++----------
 1 files changed, 40 insertions(+), 11 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 33c0c2b..2a75bf7 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -42,7 +42,8 @@
 #include <linux/swab.h>
 #include <linux/slab.h>
 
-#define VERSION "0.07"
+#define VERSION "1.0"
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
 
 
@@ -631,16 +637,25 @@ static int flash_upgrade(struct solos_card *card, int chip)
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
@@ -650,7 +665,10 @@ static int flash_upgrade(struct solos_card *card, int chip)
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
@@ -695,9 +713,13 @@ static int flash_upgrade(struct solos_card *card, int chip)
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
@@ -1249,6 +1271,11 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		db_fpga_upgrade = db_firmware_upgrade = 0;
 	}
 
+	/* Stopped using Atmel flash after 0.03-38 */
+	if (fpga_ver < 39)
+		card->atmel_flash = 1;
+	else
+		card->atmel_flash = 0;
 	if (card->fpga_version >= DMA_SUPPORTED){
 		card->using_dma = 1;
 	} else {
@@ -1256,6 +1283,8 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		/* Set RX empty flag for all ports */
 		iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
 	}
+	/* New FPGAs require driver version before permitting flash upgrades */
+	iowrite32(DRIVER_VERSION, card->config_regs + DRIVER_VER);
 
 	data32 = ioread32(card->config_regs + PORTS);
 	card->nr_ports = (data32 & 0x000000FF);
-- 
1.7.2.5
