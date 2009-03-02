From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] typhoon: Use request_firmware()
Date: Sun, 01 Mar 2009 20:29:29 -0800 (PST)
Message-ID: <20090301.202929.81587113.davem@davemloft.net>
References: <20090301.174433.258919971.davem@davemloft.net>
	<1235963807.27973.1.camel@localhost.localdomain>
	<20090301.201123.112634333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754259AbZCBE3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 23:29:47 -0500
In-Reply-To: <20090301.201123.112634333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 01 Mar 2009 20:11:23 -0800 (PST)

> Give me a fix so I don't have to revert.

Nevermind, I checked in a fix myself.

I cared enough to fix this, maybe one of you will care enough
to test it.

typhoon: Need non-vmalloc memory to DMA firmware to the card.

request_firmware() gives vmalloc'd memory, which is not suitable
for pci_map_single() and friends.

Use a kmalloc()'d copy of the firmware for this DMA operation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/typhoon.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index cd3283f..ec2541c 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1347,6 +1347,7 @@ typhoon_init_rings(struct typhoon *tp)
 }
 
 static const struct firmware *typhoon_fw;
+static u8 *typhoon_fw_image;
 
 static int
 typhoon_request_firmware(struct typhoon *tp)
@@ -1367,12 +1368,22 @@ typhoon_request_firmware(struct typhoon *tp)
 	    memcmp(typhoon_fw->data, "TYPHOON", 8)) {
 		printk(KERN_ERR "%s: Invalid firmware image\n",
 		       tp->name);
-		release_firmware(typhoon_fw);
-		typhoon_fw = NULL;
-		return -EINVAL;
+		err = -EINVAL;
+		goto out_err;
+	}
+
+	typhoon_fw_image = kmalloc(typhoon_fw->size, GFP_KERNEL);
+	if (!typhoon_fw_image) {
+		err = -ENOMEM;
+		goto out_err;
 	}
 
 	return 0;
+
+out_err:
+	release_firmware(typhoon_fw);
+	typhoon_fw = NULL;
+	return err;
 }
 
 static int
@@ -1394,11 +1405,11 @@ typhoon_download_firmware(struct typhoon *tp)
 	int i;
 	int err;
 
-	image_data = typhoon_fw->data;
+	image_data = typhoon_fw_image;
 	fHdr = (struct typhoon_file_header *) image_data;
 
 	err = -ENOMEM;
-	image_dma = pci_map_single(pdev, (u8 *) typhoon_fw->data,
+	image_dma = pci_map_single(pdev, (u8 *) image_data,
 				   typhoon_fw->size, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(pdev, image_dma)) {
 		printk(KERN_ERR "%s: no DMA mem for firmware\n", tp->name);
@@ -1469,7 +1480,7 @@ typhoon_download_firmware(struct typhoon *tp)
 		iowrite32(load_addr,
 			  ioaddr + TYPHOON_REG_BOOT_DEST_ADDR);
 		iowrite32(0, ioaddr + TYPHOON_REG_BOOT_DATA_HI);
-		iowrite32(image_dma + (image_data - typhoon_fw->data),
+		iowrite32(image_dma + (image_data - typhoon_fw_image),
 			  ioaddr + TYPHOON_REG_BOOT_DATA_LO);
 		typhoon_post_pci_writes(ioaddr);
 		iowrite32(TYPHOON_BOOTCMD_SEG_AVAILABLE,
@@ -2639,8 +2650,10 @@ typhoon_init(void)
 static void __exit
 typhoon_cleanup(void)
 {
-	if (typhoon_fw)
+	if (typhoon_fw) {
+		kfree(typhoon_fw_image);
 		release_firmware(typhoon_fw);
+	}
 	pci_unregister_driver(&typhoon_driver);
 }
 
-- 
1.6.1.2.253.ga34a

