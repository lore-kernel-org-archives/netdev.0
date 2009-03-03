From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Tue, 03 Mar 2009 00:44:22 -0500
Message-ID: <1236059062.4207.11.camel@localhost.localdomain>
References: <20090301.201123.112634333.davem@davemloft.net>
	 <20090301.202929.81587113.davem@davemloft.net>
	 <1235980579.23967.2.camel@localhost.localdomain>
	 <20090302.015315.181629191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:57787 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbZCCFo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 00:44:26 -0500
In-Reply-To: <20090302.015315.181629191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

typhoon: repair firmware loading

The conversion to avoid using pci_alloc_consistent() broke the firmware
load process, as well as added an order-4 kmalloc and doubled the memory
usage of the firmware image. Go back to loading a page at a time.

Also, since the user can now give us utter garbage for firmware, do a
cursory validation so we don't try to load just anything.

Signed-off-by: David Dillow <dave@thedillows.org>
---
 MAINTAINERS           |    2 
 drivers/net/typhoon.c |  137 +++++++++++++++++++++++++-----------------
 2 files changed, 84 insertions(+), 55 deletions(-)

I tested the version in net-next-2.6 and it wouldn't load the firmware,
so here's my fix. It has been tested to work, and to reject images that
fail it's cursory tests.

Also, I added typhoon to the existing MAINTAINERS entry, since it is
apparently too much trouble to Cc: the email address in the source file.

diff --git a/MAINTAINERS b/MAINTAINERS
index e74a133..617a397 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -97,7 +97,7 @@ M:	klassert@mathematik.tu-chemnitz.de
 L:	netdev@vger.kernel.org
 S:	Maintained
 
-3CR990 NETWORK DRIVER
+3CR990 (typhoon) NETWORK DRIVER
 P:	David Dillow
 M:	dave@thedillows.org
 L:	netdev@vger.kernel.org
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 9bba787..9dcd897 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -100,10 +100,11 @@ static const int multicast_filter_limit = 32;
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.8"
-#define DRV_MODULE_RELDATE	"06/11/09"
+#define DRV_MODULE_VERSION 	"1.5.9"
+#define DRV_MODULE_RELDATE	"Mar 2, 2009"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
+#define FIRMWARE_NAME		"3com/typhoon.bin"
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -136,7 +137,6 @@ static const int multicast_filter_limit = 32;
 static char version[] __devinitdata =
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
-#define FIRMWARE_NAME		"3com/typhoon.bin"
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_LICENSE("GPL");
@@ -1347,11 +1347,16 @@ typhoon_init_rings(struct typhoon *tp)
 }
 
 static const struct firmware *typhoon_fw;
-static u8 *typhoon_fw_image;
 
 static int
 typhoon_request_firmware(struct typhoon *tp)
 {
+	const struct typhoon_file_header *fHdr;
+	const struct typhoon_section_header *sHdr;
+	const u8 *image_data;
+	u32 numSections;
+	u32 section_len; 
+	u32 remaining; 
 	int err;
 
 	if (typhoon_fw)
@@ -1360,31 +1365,45 @@ typhoon_request_firmware(struct typhoon *tp)
 	err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
 	if (err) {
 		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
-		       tp->name, FIRMWARE_NAME);
+				tp->name, FIRMWARE_NAME);
 		return err;
 	}
 
-	if (typhoon_fw->size < sizeof(struct typhoon_file_header) ||
-	    memcmp(typhoon_fw->data, "TYPHOON", 8)) {
-		printk(KERN_ERR "%s: Invalid firmware image\n",
-		       tp->name);
-		err = -EINVAL;
-		goto out_err;
-	}
+	image_data = (u8 *) typhoon_fw->data;
+	remaining = typhoon_fw->size;
+	if (remaining < sizeof(struct typhoon_file_header))
+		goto invalid_fw;
 
-	typhoon_fw_image = kmalloc(typhoon_fw->size, GFP_KERNEL);
-	if (!typhoon_fw_image) {
-		err = -ENOMEM;
-		goto out_err;
+	fHdr = (struct typhoon_file_header *) image_data;
+	if (memcmp(fHdr->tag, "TYPHOON", 8))
+		goto invalid_fw;
+
+	numSections = le32_to_cpu(fHdr->numSections);
+	image_data += sizeof(struct typhoon_file_header);
+	remaining -= sizeof(struct typhoon_file_header);
+
+	while (numSections--) {
+		if (remaining < sizeof(struct typhoon_section_header))
+			goto invalid_fw;
+
+		sHdr = (struct typhoon_section_header *) image_data;
+		image_data += sizeof(struct typhoon_section_header);
+		section_len = le32_to_cpu(sHdr->len);
+
+		if (remaining < section_len)
+			goto invalid_fw;
+
+		image_data += section_len;
+		remaining -= section_len;
 	}
-	memcpy(typhoon_fw_image, typhoon_fw->data, typhoon_fw->size);
 
 	return 0;
 
-out_err:
+invalid_fw:
+	printk(KERN_ERR "%s: Invalid firmware image\n", tp->name);
 	release_firmware(typhoon_fw);
 	typhoon_fw = NULL;
-	return err;
+	return -EINVAL;
 }
 
 static int
@@ -1395,24 +1414,29 @@ typhoon_download_firmware(struct typhoon *tp)
 	const struct typhoon_file_header *fHdr;
 	const struct typhoon_section_header *sHdr;
 	const u8 *image_data;
-	dma_addr_t image_dma;
+	void *dpage;
+	dma_addr_t dpage_dma;
 	__sum16 csum;
 	u32 irqEnabled;
 	u32 irqMasked;
 	u32 numSections;
 	u32 section_len;
+	u32 len;
 	u32 load_addr;
 	u32 hmac;
 	int i;
 	int err;
 
-	image_data = typhoon_fw_image;
+	image_data = (u8 *) typhoon_fw->data;
 	fHdr = (struct typhoon_file_header *) image_data;
 
+	/* Cannot just map the firmware image using pci_map_single() as
+	 * the firmware is vmalloc()'d and may not be physically contiguous,
+	 * so we allocate some consistent memory to copy the sections into.
+	 */
 	err = -ENOMEM;
-	image_dma = pci_map_single(pdev, (u8 *) image_data,
-				   typhoon_fw->size, PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(pdev, image_dma)) {
+	dpage = pci_alloc_consistent(pdev, PAGE_SIZE, &dpage_dma);
+	if(!dpage) {
 		printk(KERN_ERR "%s: no DMA mem for firmware\n", tp->name);
 		goto err_out;
 	}
@@ -1460,34 +1484,41 @@ typhoon_download_firmware(struct typhoon *tp)
 		load_addr = le32_to_cpu(sHdr->startAddr);
 		section_len = le32_to_cpu(sHdr->len);
 
-		if (typhoon_wait_interrupt(ioaddr) < 0 ||
-		    ioread32(ioaddr + TYPHOON_REG_STATUS) !=
-		    TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-			printk(KERN_ERR "%s: segment ready timeout\n",
-			       tp->name);
-			goto err_out_irq;
-		}
+		while(section_len) {
+			len = min_t(u32, section_len, PAGE_SIZE);
 
-		/* Do an pseudo IPv4 checksum on the data -- first
-		 * need to convert each u16 to cpu order before
-		 * summing. Fortunately, due to the properties of
-		 * the checksum, we can do this once, at the end.
-		 */
-		csum = csum_fold(csum_partial(image_data, section_len, 0));
-
-		iowrite32(section_len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
-		iowrite32(le16_to_cpu((__force __le16)csum),
-			  ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
-		iowrite32(load_addr,
-			  ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
-		iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
-		iowrite32(image_dma + (image_data - typhoon_fw_image),
-			  ioaddr + TYPHOON_REG_BOOT_DATA_LO);
-		typhoon_post_pci_writes(ioaddr);
-		iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
-			  ioaddr + TYPHOON_REG_COMMAND);
+			if(typhoon_wait_interrupt(ioaddr) < 0 ||
+			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
+			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
+				printk(KERN_ERR "%s: segment ready timeout\n",
+				       tp->name);
+				goto err_out_irq;
+			}
 
-		image_data += section_len;
+			/* Do an pseudo IPv4 checksum on the data -- first
+			 * need to convert each u16 to cpu order before
+			 * summing. Fortunately, due to the properties of
+			 * the checksum, we can do this once, at the end.
+			 */
+			csum = csum_fold(csum_partial_copy_nocheck(image_data,
+								  dpage, len,
+								  0));
+
+			iowrite32(len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
+			iowrite32(le16_to_cpu((__force __le16)csum),
+					ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
+			iowrite32(load_addr,
+					ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
+			iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
+			iowrite32(dpage_dma, ioaddr + TYPHOON_REG_BOOT_DATA_LO);
+			typhoon_post_pci_writes(ioaddr);
+			iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
+			       ioaddr + TYPHOON_REG_COMMAND);
+
+			image_data += len;
+			load_addr += len;
+			section_len -= len;
+		}
 	}
 
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
@@ -1511,7 +1542,7 @@ err_out_irq:
 	iowrite32(irqMasked, ioaddr + TYPHOON_REG_INTR_MASK);
 	iowrite32(irqEnabled, ioaddr + TYPHOON_REG_INTR_ENABLE);
 
-	pci_unmap_single(pdev, image_dma,  typhoon_fw->size, PCI_DMA_TODEVICE);
+	pci_free_consistent(pdev, PAGE_SIZE, dpage, dpage_dma);
 
 err_out:
 	return err;
@@ -2651,10 +2682,8 @@ typhoon_init(void)
 static void __exit
 typhoon_cleanup(void)
 {
-	if (typhoon_fw) {
-		kfree(typhoon_fw_image);
+	if (typhoon_fw)
 		release_firmware(typhoon_fw);
-	}
 	pci_unregister_driver(&typhoon_driver);
 }
 


