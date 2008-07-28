From: Jaswinder Singh <jaswinder@infradead.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Mon, 28 Jul 2008 19:24:20 +0530
Message-ID: <1217253260.17632.6.camel@jaswinder.satnam>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37955 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbYG1Nzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 09:55:43 -0400
In-Reply-To: <1217248585.22789.58.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On Mon, 2008-07-28 at 08:36 -0400, David Dillow wrote:

> Please re-read what I said -- you broke error handling and potentially
> resume. Previously, the firmware was available without a sleeping call
> to user space to get it. Now, it is not. You cannot sleep in
> typhoon_tx_timeout(), and trying to get a firmware image in resume is
> going to be a problem if your file system is NFS mounted over the NIC
> you're trying to resume.
> 
> http://marc.info/?l=linux-kernel&m=121608383506190&w=2
> http://marc.info/?l=linux-kernel&m=121608255704704&w=2
> 
> 

Here is patch for typhoon.c :

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index c0dd25b..c792741 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -130,9 +130,9 @@ static const int multicast_filter_limit = 32;
 #include <linux/in6.h>
 #include <linux/version.h>
 #include <linux/dma-mapping.h>
+#include <linux/firmware.h>
 
 #include "typhoon.h"
-#include "typhoon-firmware.h"
 
 static char version[] __devinitdata =
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
@@ -140,6 +140,7 @@ static char version[] __devinitdata =
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE("3com/typhoon.bin");
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
 MODULE_PARM_DESC(rx_copybreak, "Packets smaller than this are copied and "
 			       "the buffer given back to the NIC. Default "
@@ -307,6 +308,9 @@ struct typhoon {
 	/* unused stuff (future use) */
 	int			capabilities;
 	struct transmit_ring 	txHiRing;
+
+	/* firmware */
+	u8			*tp_fw_image;
 };
 
 enum completion_wait_values {
@@ -1347,6 +1351,32 @@ typhoon_init_rings(struct typhoon *tp)
 	tp->txHiRing.lastRead = 0;
 }
 
+static int typhoon_init_firmware(struct typhoon *tp)
+{
+	const struct firmware *fw;
+	const char fw_name[] = "3com/typhoon.bin";
+	int err;
+
+	err = request_firmware(&fw, fw_name, &tp->pdev->dev);
+	if (err) {
+		printk(KERN_ERR "%s: Failed to load firmware \"%s\"\n",
+		       tp->name, fw_name);
+		return err;
+	}
+	tp->tp_fw_image = vmalloc(fw->size);
+	if (!tp->tp_fw_image) {
+		err = -ENOMEM;
+		printk(KERN_ERR "%s: \"%s\" Failed %d\n",
+		       tp->name, fw_name, err);
+		goto out;
+	}
+
+	memcpy(tp->tp_fw_image, fw->data, fw->size);
+out:
+	release_firmware(fw);
+	return err;
+}
+
 static int
 typhoon_download_firmware(struct typhoon *tp)
 {
@@ -1369,7 +1399,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	int err;
 
 	err = -EINVAL;
-	fHdr = (struct typhoon_file_header *) typhoon_firmware_image;
+	fHdr = (struct typhoon_file_header *) tp->tp_fw_image;
 	image_data = (u8 *) fHdr;
 
 	if(memcmp(fHdr->tag, "TYPHOON", 8)) {
@@ -2102,6 +2132,10 @@ typhoon_open(struct net_device *dev)
 	if(err < 0)
 		goto out_sleep;
 
+	err = typhoon_init_firmware(tp);
+	if (err)
+		goto out_irq;
+
 	napi_enable(&tp->napi);
 
 	err = typhoon_start_runtime(tp);
@@ -2155,6 +2189,9 @@ typhoon_close(struct net_device *dev)
 	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0)
 		printk(KERN_ERR "%s: unable to put card to sleep\n", dev->name);
 
+	if (tp->tp_fw_image)
+		vfree(tp->tp_fw_image);
+
 	return 0;
 }
 
You can check complete patch from :-

http://git.infradead.org/users/jaswinder/firm-jsr-2.6.git

Thank you,

Jaswinder Singh.

