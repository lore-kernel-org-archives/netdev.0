From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2] typhoon: Use request_firmware()
Date: Thu, 26 Feb 2009 13:49:51 +0000
Message-ID: <20090226134950.GA975@decadentplace.org.uk>
References: <1235324217.2832.49.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:1635 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbZBZNt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:49:56 -0500
Content-Disposition: inline
In-Reply-To: <1235324217.2832.49.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on a patch by Jaswinder Singh <jaswinder@infradead.org>.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This should address the issues raised in
<http://thread.gmane.org/gmane.linux.kernel/712328>, which I had not
previously read.  I have also simplified the DMA-mapping as hinted by
the existing comment in typhoon_download_firmware().

This should be sent without MIME encoding this time.

This copy sent *without* the firmware format changes so it's under
netdev's size limit.

Ben.

 drivers/net/typhoon-firmware.h | 3778 ----------------------------------------
 drivers/net/typhoon.c          |  131 +-
 firmware/3com/typhoon.bin.ihex | 2819 ++++++++++++++++++++++++++++++
 firmware/Makefile              |    1 +
 firmware/WHENCE                |   42 +
 5 files changed, 2936 insertions(+), 3835 deletions(-)
 delete mode 100644 drivers/net/typhoon-firmware.h
 create mode 100644 firmware/3com/typhoon.bin.ihex

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index a8e5651..cd3283f 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -129,16 +129,18 @@ static const int multicast_filter_limit = 32;
 #include <asm/uaccess.h>
 #include <linux/in6.h>
 #include <linux/dma-mapping.h>
+#include <linux/firmware.h>
 
 #include "typhoon.h"
-#include "typhoon-firmware.h"
 
 static char version[] __devinitdata =
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
+#define FIRMWARE_NAME		"3com/typhoon.bin"
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE(FIRMWARE_NAME);
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
 MODULE_PARM_DESC(rx_copybreak, "Packets smaller than this are copied and "
 			       "the buffer given back to the NIC. Default "
@@ -1344,45 +1346,61 @@ typhoon_init_rings(struct typhoon *tp)
 	tp->txHiRing.lastRead = 0;
 }
 
+static const struct firmware *typhoon_fw;
+
+static int
+typhoon_request_firmware(struct typhoon *tp)
+{
+	int err;
+
+	if (typhoon_fw)
+		return 0;
+
+	err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &tp->pdev->dev);
+	if (err) {
+		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
+		       tp->name, FIRMWARE_NAME);
+		return err;
+	}
+
+	if (typhoon_fw->size < sizeof(struct typhoon_file_header) ||
+	    memcmp(typhoon_fw->data, "TYPHOON", 8)) {
+		printk(KERN_ERR "%s: Invalid firmware image\n",
+		       tp->name);
+		release_firmware(typhoon_fw);
+		typhoon_fw = NULL;
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int
 typhoon_download_firmware(struct typhoon *tp)
 {
 	void __iomem *ioaddr = tp->ioaddr;
 	struct pci_dev *pdev = tp->pdev;
-	struct typhoon_file_header *fHdr;
-	struct typhoon_section_header *sHdr;
-	u8 *image_data;
-	void *dpage;
-	dma_addr_t dpage_dma;
+	const struct typhoon_file_header *fHdr;
+	const struct typhoon_section_header *sHdr;
+	const u8 *image_data;
+	dma_addr_t image_dma;
 	__sum16 csum;
 	u32 irqEnabled;
 	u32 irqMasked;
 	u32 numSections;
 	u32 section_len;
-	u32 len;
 	u32 load_addr;
 	u32 hmac;
 	int i;
 	int err;
 
-	err = -EINVAL;
-	fHdr = (struct typhoon_file_header *) typhoon_firmware_image;
-	image_data = (u8 *) fHdr;
-
-	if(memcmp(fHdr->tag, "TYPHOON", 8)) {
-		printk(KERN_ERR "%s: Invalid firmware image!\n", tp->name);
-		goto err_out;
-	}
+	image_data = typhoon_fw->data;
+	fHdr = (struct typhoon_file_header *) image_data;
 
-	/* Cannot just map the firmware image using pci_map_single() as
-	 * the firmware is part of the kernel/module image, so we allocate
-	 * some consistent memory to copy the sections into, as it is simpler,
-	 * and short-lived. If we ever split out and require a userland
-	 * firmware loader, then we can revisit this.
-	 */
 	err = -ENOMEM;
-	dpage = pci_alloc_consistent(pdev, PAGE_SIZE, &dpage_dma);
-	if(!dpage) {
+	image_dma = pci_map_single(pdev, (u8 *) typhoon_fw->data,
+				   typhoon_fw->size, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, image_dma)) {
 		printk(KERN_ERR "%s: no DMA mem for firmware\n", tp->name);
 		goto err_out;
 	}
@@ -1430,41 +1448,34 @@ typhoon_download_firmware(struct typhoon *tp)
 		load_addr = le32_to_cpu(sHdr->startAddr);
 		section_len = le32_to_cpu(sHdr->len);
 
-		while(section_len) {
-			len = min_t(u32, section_len, PAGE_SIZE);
+		if (typhoon_wait_interrupt(ioaddr) < 0 ||
+		    ioread32(ioaddr + TYPHOON_REG_STATUS) !=
+		    TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
+			printk(KERN_ERR "%s: segment ready timeout\n",
+			       tp->name);
+			goto err_out_irq;
+		}
 
-			if(typhoon_wait_interrupt(ioaddr) < 0 ||
-			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
-			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
-				printk(KERN_ERR "%s: segment ready timeout\n",
-				       tp->name);
-				goto err_out_irq;
-			}
+		/* Do an pseudo IPv4 checksum on the data -- first
+		 * need to convert each u16 to cpu order before
+		 * summing. Fortunately, due to the properties of
+		 * the checksum, we can do this once, at the end.
+		 */
+		csum = csum_fold(csum_partial(image_data, section_len, 0));
+
+		iowrite32(section_len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
+		iowrite32(le16_to_cpu((__force __le16)csum),
+			  ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
+		iowrite32(load_addr,
+			  ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
+		iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
+		iowrite32(image_dma + (image_data - typhoon_fw->data),
+			  ioaddr + TYPHOON_REG_BOOT_DATA_LO);
+		typhoon_post_pci_writes(ioaddr);
+		iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
+			  ioaddr + TYPHOON_REG_COMMAND);
 
-			/* Do an pseudo IPv4 checksum on the data -- first
-			 * need to convert each u16 to cpu order before
-			 * summing. Fortunately, due to the properties of
-			 * the checksum, we can do this once, at the end.
-			 */
-			csum = csum_fold(csum_partial_copy_nocheck(image_data,
-								  dpage, len,
-								  0));
-
-			iowrite32(len, ioaddr + TYPHOON_REG_BOOT_LENGTH);
-			iowrite32(le16_to_cpu((__force __le16)csum),
-					ioaddr + TYPHOON_REG_BOOT_CHECKSUM);
-			iowrite32(load_addr,
-					ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
-			iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
-			iowrite32(dpage_dma, ioaddr + TYPHOON_REG_BOOT_DATA_LO);
-			typhoon_post_pci_writes(ioaddr);
-			iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
-			       ioaddr + TYPHOON_REG_COMMAND);
-
-			image_data += len;
-			load_addr += len;
-			section_len -= len;
-		}
+		image_data += section_len;
 	}
 
 	if(typhoon_wait_interrupt(ioaddr) < 0 ||
@@ -1488,7 +1499,7 @@ err_out_irq:
 	iowrite32(irqMasked, ioaddr + TYPHOON_REG_INTR_MASK);
 	iowrite32(irqEnabled, ioaddr + TYPHOON_REG_INTR_ENABLE);
 
-	pci_free_consistent(pdev, PAGE_SIZE, dpage, dpage_dma);
+	pci_unmap_single(pdev, image_dma,  typhoon_fw->size, PCI_DMA_TODEVICE);
 
 err_out:
 	return err;
@@ -2086,6 +2097,10 @@ typhoon_open(struct net_device *dev)
 	struct typhoon *tp = netdev_priv(dev);
 	int err;
 
+	err = typhoon_request_firmware(tp);
+	if (err)
+		goto out;
+
 	err = typhoon_wakeup(tp, WaitSleep);
 	if(err < 0) {
 		printk(KERN_ERR "%s: unable to wakeup device\n", dev->name);
@@ -2624,6 +2639,8 @@ typhoon_init(void)
 static void __exit
 typhoon_cleanup(void)
 {
+	if (typhoon_fw)
+		release_firmware(typhoon_fw);
 	pci_unregister_driver(&typhoon_driver);
 }
 
diff --git a/firmware/Makefile b/firmware/Makefile
index e1585f5..aa2e02d 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -52,6 +52,7 @@ fw-shipped-$(CONFIG_SND_YMFPCI) += yamaha/ds1_ctrl.fw yamaha/ds1_dsp.fw \
 fw-shipped-$(CONFIG_TEHUTI) += tehuti/bdx.bin
 fw-shipped-$(CONFIG_TIGON3) += tigon/tg3.bin tigon/tg3_tso.bin \
 			       tigon/tg3_tso5.bin
+fw-shipped-$(CONFIG_TYPHOON) += 3com/typhoon.bin
 fw-shipped-$(CONFIG_USB_DABUSB) += dabusb/firmware.fw dabusb/bitstream.bin
 fw-shipped-$(CONFIG_USB_EMI26) += emi26/loader.fw emi26/firmware.fw \
 				  emi26/bitstream.fw
diff --git a/firmware/WHENCE b/firmware/WHENCE
index e56aa48..ea4fc2e 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -451,3 +451,45 @@ Licence:
 Found in hex form in kernel source.
 
 --------------------------------------------------------------------------
+
+Driver: TYPHOON - 3cr990 series Typhoon
+
+File: 3com/typhoon.bin
+
+Licence:
+/*
+ * Copyright 1999-2004 3Com Corporation.  All Rights Reserved.
+ *
+ * Redistribution and use in source and binary forms of the 3c990img.h
+ * microcode software are permitted provided that the following conditions
+ * are met:
+ * 1. Redistribution of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistribution in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. The name of 3Com may not be used to endorse or promote products
+ *    derived from this software without specific prior written permission
+ *
+ * THIS SOFTWARE IS PROVIDED BY 3COM ``AS IS'' AND ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
+ * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
+ * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
+ * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
+ * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * USER ACKNOWLEDGES AND AGREES THAT PURCHASE OR USE OF THE 3c990img.h
+ * MICROCODE SOFTWARE WILL NOT CREATE OR GIVE GROUNDS FOR A LICENSE BY
+ * IMPLICATION, ESTOPPEL, OR OTHERWISE IN ANY INTELLECTUAL PROPERTY RIGHTS
+ * (PATENT, COPYRIGHT, TRADE SECRET, MASK WORK, OR OTHER PROPRIETARY RIGHT)
+ * EMBODIED IN ANY OTHER 3COM HARDWARE OR SOFTWARE EITHER SOLELY OR IN
+ * COMBINATION WITH THE 3c990img.h MICROCODE SOFTWARE
+ */
+
+Found in hex form in kernel source.
+
+--------------------------------------------------------------------------
-- 
1.6.1.3


