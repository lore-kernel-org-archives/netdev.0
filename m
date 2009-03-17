From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 04/30] solos: Clean up firmware loading code
Date: Tue, 17 Mar 2009 21:29:12 +0000
Message-ID: <1237325352.27681.333.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37652 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757014AbZCQV3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:17 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1LjgqY-0001uo-Ld
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:15 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We no longer try to load firmware while the ATM is up and running.
However, this means that we _do_ make init_module() wait for it, and it
takes a long time for now (since we're using ultra-conservative code in
the FPGA for that too).

The inner loop which uses swahb32p() was by Simon Farnsworth.

Simon has patches which migrate us to request_firmware_nowait(), for
which we'll actually need to take down the ATM devices, do the upgrade,
then reregister them.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |  209 ++++++++++++++++------------------------------
 1 files changed, 73 insertions(+), 136 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 2b472c8..89bdf73 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -93,7 +93,7 @@ struct solos_card {
 	spinlock_t cli_queue_lock;
 	struct sk_buff_head tx_queue[4];
 	struct sk_buff_head cli_queue[4];
-	int flash_chip;
+	wait_queue_head_t fw_wq;
 };
 
 #define SOLOS_CHAN(atmdev) ((int)(unsigned long)(atmdev)->phy_data)
@@ -112,11 +112,7 @@ module_param(firmware_upgrade, int, 0444);
 module_param(fpga_upgrade, int, 0444);
 
 static int opens;
-static struct firmware *fw;
-static int flash_offset;
 
-void flash_upgrade(struct solos_card *);
-void flash_write(struct solos_card *);
 static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc);
 static int fpga_tx(struct solos_card *);
@@ -202,129 +198,73 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 
 static DEVICE_ATTR(console, 0644, console_show, console_store);
 
-void flash_upgrade(struct solos_card *card){
+static int flash_upgrade(struct solos_card *card, int chip)
+{
+	const struct firmware *fw;
+	const char *fw_name;
 	uint32_t data32 = 0;
 	int blocksize = 0;
 	int numblocks = 0;
-	dev_info(&card->dev->dev, "Flash upgrade started\n");
-	if (card->flash_chip == 0) {
-		if (request_firmware((const struct firmware **)&fw,
-				"solos-FPGA.bin",&card->dev->dev))
-		{
-			dev_info(&card->dev->dev,
-					"Failed to find firmware\n");
-			return;
-		}
+	int offset;
+
+	if (chip == 0) {
+		fw_name = "solos-FPGA.bin";
 		blocksize = FPGA_BLOCK;
 	} else {
-		if (request_firmware((const struct firmware **)&fw,
-				"solos-Firmware.bin",&card->dev->dev))
-		{
-			dev_info(&card->dev->dev,
-					"Failed to find firmware\n");
-			return;
-		}
+		fw_name = "solos-Firmware.bin";
 		blocksize = SOLOS_BLOCK;
 	}
-	numblocks = fw->size/blocksize;
-	dev_info(&card->dev->dev, "Firmware size: %d\n", fw->size);
+
+	if (request_firmware(&fw, fw_name, &card->dev->dev))
+		return -ENOENT;
+
+	dev_info(&card->dev->dev, "Flash upgrade starting\n");
+
+	numblocks = fw->size / blocksize;
+	dev_info(&card->dev->dev, "Firmware size: %zd\n", fw->size);
 	dev_info(&card->dev->dev, "Number of blocks: %d\n", numblocks);
 	
-		
 	dev_info(&card->dev->dev, "Changing FPGA to Update mode\n");
 	iowrite32(1, card->config_regs + FPGA_MODE);
 	data32 = ioread32(card->config_regs + FPGA_MODE); 
-	/*Set mode to Chip Erase*/
-	if (card->flash_chip == 0) {
-		dev_info(&card->dev->dev, 
-				"Set FPGA Flash mode to FPGA Chip Erase\n");
-	} else {
-		dev_info(&card->dev->dev, 
-				"Set FPGA Flash mode to Solos Chip Erase\n");
-	}
-	iowrite32((card->flash_chip * 2), card->config_regs + FLASH_MODE);
-	flash_offset = 0;
-	iowrite32(1, card->config_regs + WRITE_FLASH);
-	return;
-}
 
-void flash_write(struct solos_card *card){
-	int block;
-	int block_num;
-	int blocksize;
-	int i;
-	uint32_t data32 = 0;
+	/* Set mode to Chip Erase */
+	dev_info(&card->dev->dev, "Set FPGA Flash mode to %s Chip Erase\n",
+		 chip?"Solos":"FPGA");
+	iowrite32((chip * 2), card->config_regs + FLASH_MODE);
 
-	/*Clear write flag*/
-	iowrite32(0, card->config_regs + WRITE_FLASH);
-	/*Set mode to Block Write*/
-	/*dev_info(&card->dev->dev, "Set FPGA Flash mode to Block Write\n");*/
-	iowrite32(((card->flash_chip * 2) + 1), card->config_regs + FLASH_MODE);
 
-	/*When finished programming flash, release firmware and exit*/
-	if (fw->size - flash_offset == 0) {
-		//release_firmware(fw); /* This crashes for some reason */
+	iowrite32(1, card->config_regs + WRITE_FLASH);
+	wait_event(card->fw_wq, !ioread32(card->config_regs + FLASH_BUSY));
+
+	for (offset = 0; offset < fw->size; offset += blocksize) {
+		int i;
+
+		/* Clear write flag */
 		iowrite32(0, card->config_regs + WRITE_FLASH);
-		iowrite32(0, card->config_regs + FPGA_MODE);
-		iowrite32(0, card->config_regs + FLASH_MODE);
-		dev_info(&card->dev->dev, "Returning FPGA to Data mode\n");
-		return;
-	}
-	if (card->flash_chip == 0) {
-		blocksize = FPGA_BLOCK;
-	} else {
-		blocksize = SOLOS_BLOCK;
-	}
-	
-	/*Calculate block size*/
-	if ((fw->size - flash_offset) > blocksize) {
-		block = blocksize;
-	} else {
-		block = fw->size - flash_offset;
-	}
-	block_num = flash_offset / blocksize;
-	//dev_info(&card->dev->dev, "block %d/%d\n",block_num + 1,(fw->size/512/8));
-
-	/*Copy block into RAM*/
-	for(i=0;i<block;i++){
-		if(i%4 == 0){
-			//dev_info(&card->dev->dev, "i: %d\n", i);
-			data32=0x00000000;
-		}
-		
-		switch(i%4){
-		case 0:
-			data32 |= 0x0000FF00 & 
-				(*(fw->data + i + flash_offset)	<< 8);
-			break;
-		case 1:
-			data32 |= 0x000000FF & *(fw->data + i + flash_offset);
-			break;
-		case 2:
-			data32 |= 0xFF000000 &
-					(*(fw->data + i + flash_offset)	<< 24);
-			break;
-		case 3:
-			data32 |= 0x00FF0000 &
-					(*(fw->data + i + flash_offset)	<< 16);
-			break;
-		}
 
-		if (i%4 == 3) {
-			iowrite32(data32, RX_BUF(card, 3) + i - 3);
+		/* Set mode to Block Write */
+		/* dev_info(&card->dev->dev, "Set FPGA Flash mode to Block Write\n"); */
+		iowrite32(((chip * 2) + 1), card->config_regs + FLASH_MODE);
+
+		/* Copy block to buffer, swapping each 16 bits */
+		for(i = 0; i < blocksize; i += 4) {
+			uint32_t word = swahb32p((uint32_t *)(fw->data + offset + i));
+			iowrite32(word, RX_BUF(card, 3) + i);
 		}
-	}
-	i--;
-	if (i%4 != 3) {
-		iowrite32(data32, RX_BUF(card, 3) + i - (i%4));
+
+		/* Specify block number and then trigger flash write */
+		iowrite32(offset / blocksize, card->config_regs + FLASH_BLOCK);
+		iowrite32(1, card->config_regs + WRITE_FLASH);
+		wait_event(card->fw_wq, !ioread32(card->config_regs + FLASH_BUSY));
 	}
 
-	/*Specify block number and then trigger flash write*/
-	iowrite32(block_num, card->config_regs + FLASH_BLOCK);
-	iowrite32(1, card->config_regs + WRITE_FLASH);
-//	iowrite32(0, card->config_regs + WRITE_FLASH);
-	flash_offset += block;
-	return;
+	release_firmware(fw);
+	iowrite32(0, card->config_regs + WRITE_FLASH);
+	iowrite32(0, card->config_regs + FPGA_MODE);
+	iowrite32(0, card->config_regs + FLASH_MODE);
+	dev_info(&card->dev->dev, "Returning FPGA to Data mode\n");
+	return 0;
 }
 
 static irqreturn_t solos_irq(int irq, void *dev_id)
@@ -337,10 +277,10 @@ static irqreturn_t solos_irq(int irq, void *dev_id)
 	//Disable IRQs from FPGA
 	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 
-	/* If we only do it when the device is open, we lose console
-	   messages */
-	if (1 || opens)
+	if (card->atmdev[0])
 		tasklet_schedule(&card->tlet);
+	else
+		wake_up(&card->fw_wq);
 
 	//Enable IRQs from FPGA
 	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
@@ -354,17 +294,6 @@ void solos_bh(unsigned long card_arg)
 	uint32_t card_flags;
 	uint32_t tx_mask;
 	uint32_t rx_done = 0;
-	uint32_t data32;
-
-	data32 = ioread32(card->config_regs + FPGA_MODE); 
-	if (data32 != 0) {
-		data32 = ioread32(card->config_regs + FLASH_BUSY); 
-		if (data32 == 0) {
-			flash_write(card);
-		}	
-		return;
-	}
-		
 
 	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
 
@@ -749,6 +678,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		return -ENOMEM;
 
 	card->dev = dev;
+	init_waitqueue_head(&card->fw_wq);
 
 	err = pci_enable_device(dev);
 	if (err) {
@@ -794,15 +724,13 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	card->nr_ports = 2; /* FIXME: Detect daughterboard */
 
-	err = atm_init(card);
-	if (err)
-		goto out_unmap_both;
-
 	pci_set_drvdata(dev, card);
+
 	tasklet_init(&card->tlet, solos_bh, (unsigned long)card);
 	spin_lock_init(&card->tx_lock);
 	spin_lock_init(&card->tx_queue_lock);
 	spin_lock_init(&card->cli_queue_lock);
+
 /*
 	// Set Loopback mode
 	data32 = 0x00010000;
@@ -832,24 +760,33 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	//dev_dbg(&card->dev->dev, "Requesting IRQ: %d\n",dev->irq);
 	err = request_irq(dev->irq, solos_irq, IRQF_DISABLED|IRQF_SHARED,
 			  "solos-pci", card);
-	if (err)
+	if (err) {
 		dev_dbg(&card->dev->dev, "Failed to request interrupt IRQ: %d\n", dev->irq);
+		goto out_unmap_both;
+	}
 
 	// Enable IRQs
 	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
 
-	if(firmware_upgrade != 0){
-		card->flash_chip = 1;
-		flash_upgrade(card);
-	} else {
-		if(fpga_upgrade != 0){
-			card->flash_chip = 0;
-			flash_upgrade(card);
-		}
-	}
+	if (fpga_upgrade)
+		flash_upgrade(card, 0);
+
+	if (firmware_upgrade)
+		flash_upgrade(card, 1);
+
+	err = atm_init(card);
+	if (err)
+		goto out_free_irq;
+
 	return 0;
 
+ out_free_irq:
+	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
+	free_irq(dev->irq, card);
+	tasklet_kill(&card->tlet);
+	
  out_unmap_both:
+	pci_set_drvdata(dev, NULL);
 	pci_iounmap(dev, card->config_regs);
  out_unmap_config:
 	pci_iounmap(dev, card->buffers);
-- 
1.6.0.6


