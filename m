From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Wed, 30 Jul 2008 23:37:46 -0400
Message-ID: <1217475466.16202.15.camel@obelisk.thedillows.org>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
	 <1217253260.17632.6.camel@jaswinder.satnam>
	 <1217295498.28682.16.camel@obelisk.thedillows.org>
	 <1217347786.2885.11.camel@jaswinder.satnam>
	 <1217395511.31350.6.camel@obelisk.thedillows.org>
	 <1217400251.2595.3.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: Jaswinder Singh <jaswinder@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:53504 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053AbYGaDht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 23:37:49 -0400
In-Reply-To: <1217400251.2595.3.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 12:14 +0530, Jaswinder Singh wrote:
> On Wed, 2008-07-30 at 01:25 -0400, David Dillow wrote:
> > Also, if not adding a mutex, then this can be folded into
> > typhoon_init_one(), rather than living in a separate function.  
> 
> request_firmware is using mutex.

request_firmware()'s mutex is protecting against things inside of that
subsystem, but offers no protection between the test on typhoon_fw !=
NULL and the setting of it inside of the firmware loader. That requires
locking at a higher level.

Anyways, probing is single threaded and I seem to recall it being
unlikely to be made parallel due to the number issues exposed last time,
so a minimal comment is fine.

I finally got a few minutes to look at the patch as a whole and apply a
little polish. Here's my version, compile tested but it hasn't seen
actual hardware yet. Hopefully this weekend.

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 8549f11..e9f7c5d 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -63,6 +63,10 @@ static unsigned int use_mmio = 2;
  */
 static const int multicast_filter_limit = 32;
 
+/* Pointer to the firmware loaded from userspace.
+ */
+static const struct firmware *typhoon_fw;
+
 /* Operational parameters that are set at compile time. */
 
 /* Keep the ring sizes a power of two for compile efficiency.
@@ -100,11 +104,13 @@ static const int multicast_filter_limit = 32;
 #define PKT_BUF_SZ		1536
 
 #define DRV_MODULE_NAME		"typhoon"
-#define DRV_MODULE_VERSION 	"1.5.8"
-#define DRV_MODULE_RELDATE	"06/11/09"
+#define DRV_MODULE_VERSION 	"1.6.0"
+#define DRV_MODULE_RELDATE	"31 Jul 2008"
 #define PFX			DRV_MODULE_NAME ": "
 #define ERR_PFX			KERN_ERR PFX
 
+#define FIRMWARE_NAME		"3com/typhoon.bin"
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -130,9 +136,9 @@ static const int multicast_filter_limit = 32;
 #include <linux/in6.h>
 #include <linux/version.h>
 #include <linux/dma-mapping.h>
+#include <linux/firmware.h>
 
 #include "typhoon.h"
-#include "typhoon-firmware.h"
 
 static char version[] __devinitdata =
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
@@ -140,6 +146,7 @@ static char version[] __devinitdata =
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE(FIRMWARE_NAME);
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
 MODULE_PARM_DESC(rx_copybreak, "Packets smaller than this are copied and "
 			       "the buffer given back to the NIC. Default "
@@ -1350,9 +1357,9 @@ typhoon_download_firmware(struct typhoon *tp)
 {
 	void __iomem *ioaddr = tp->ioaddr;
 	struct pci_dev *pdev = tp->pdev;
-	struct typhoon_file_header *fHdr;
-	struct typhoon_section_header *sHdr;
-	u8 *image_data;
+	const struct typhoon_file_header *fHdr;
+	const struct typhoon_section_header *sHdr;
+	const u8 *image_data;
 	void *dpage;
 	dma_addr_t dpage_dma;
 	__sum16 csum;
@@ -1367,7 +1374,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	int err;
 
 	err = -EINVAL;
-	fHdr = (struct typhoon_file_header *) typhoon_firmware_image;
+	fHdr = (struct typhoon_file_header *) typhoon_fw->data;
 	image_data = (u8 *) fHdr;
 
 	if(memcmp(fHdr->tag, "TYPHOON", 8)) {
@@ -2317,6 +2324,19 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if(!did_version++)
 		printk(KERN_INFO "%s", version);
 
+	/* Only load the firmware once; if bus probing ever becomes
+	 * multi-threaded, we'll need a mutex here to prevent a race
+	 * condition that will leak memory.
+	 */
+	if(!typhoon_fw) {
+		err = request_firmware(&typhoon_fw, FIRMWARE_NAME, &pdev->dev);
+		if(err) {
+			printk(ERR_PFX "%s: Failed to load firmware \"%s\"\n",
+			       pci_name(pdev), FIRMWARE_NAME);
+			goto error_out;
+		}
+	}
+
 	dev = alloc_etherdev(sizeof(*tp));
 	if(dev == NULL) {
 		printk(ERR_PFX "%s: unable to alloc new net device\n",
@@ -2579,6 +2599,7 @@ error_out_disable:
 error_out_dev:
 	free_netdev(dev);
 error_out:
+	/* Module unload will free firmware if needed */
 	return err;
 }
 
@@ -2623,6 +2644,9 @@ static void __exit
 typhoon_cleanup(void)
 {
 	pci_unregister_driver(&typhoon_driver);
+
+	if(typhoon_fw)
+		release_firmware(typhoon_fw);
 }
 
 module_init(typhoon_init);



