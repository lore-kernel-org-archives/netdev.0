From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: [PATCH net-next] myri_sbus: use request_firmware
Date: Fri, 03 Apr 2009 01:22:40 +0530
Message-ID: <1238701960.3099.87.camel@ht.satnam>
References: <1238701097.3099.82.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:59095 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757843AbZDBTww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 15:52:52 -0400
In-Reply-To: <1238701097.3099.82.camel@ht.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-04-03 at 01:09 +0530, Jaswinder Singh Rajput wrote:
> Hello David,
> 
> I do not have any machine to test this patch. If you find any issues
> then let me know.
> 
> Thanks,
> 
> From: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
> Subject: [PATCH] myri_sbus: use request_firmware
> 
> ---
> Firmware blob looks like this...
> 
>         __be16 lanai4_data_size
>         unsigned char lanai4_code[]
> 
> Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>

It seems LKML rejected this email because of big size, so CC LKML after
deleting firmware blob:

From: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
Subject: [PATCH] myri_sbus: use request_firmware

Firmware blob looks like this...

        __be16 lanai4_data_size
        unsigned char lanai4_code[]

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/myri_code.h         | 5006 ---------------------------------------
 drivers/net/myri_sbus.c         |   37 +-
 firmware/Makefile               |    1 +
 firmware/WHENCE                 |   10 +
 firmware/myricom/lanai.bin.ihex | 4771 +++++++++++++++++++++++++++++++++++++
 5 files changed, 4812 insertions(+), 5013 deletions(-)
 delete mode 100644 drivers/net/myri_code.h
 create mode 100644 firmware/myricom/lanai.bin.ihex

diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 08534c0..9a802ad 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -25,6 +25,7 @@ static char version[] =
 #include <linux/dma-mapping.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/firmware.h>
 
 #include <net/dst.h>
 #include <net/arp.h>
@@ -43,7 +44,6 @@ static char version[] =
 #include <asm/irq.h>
 
 #include "myri_sbus.h"
-#include "myri_code.h"
 
 /* #define DEBUG_DETECT */
 /* #define DEBUG_IRQ */
@@ -81,6 +81,9 @@ static char version[] =
 #define DHDR(x)
 #endif
 
+/* Firmware name */
+#define FWNAME		"myricom/lanai.bin"
+
 static void myri_reset_off(void __iomem *lp, void __iomem *cregs)
 {
 	/* Clear IRQ mask. */
@@ -171,10 +174,11 @@ static int myri_do_handshake(struct myri_eth *mp)
 
 static int __devinit myri_load_lanai(struct myri_eth *mp)
 {
+	const struct firmware	*fw;
 	struct net_device	*dev = mp->dev;
 	struct myri_shmem __iomem *shmem = mp->shmem;
 	void __iomem		*rptr;
-	int 			i;
+	int 			i, lanai4_data_size;
 
 	myri_disable_irq(mp->lregs, mp->cregs);
 	myri_reset_on(mp->cregs);
@@ -186,13 +190,27 @@ static int __devinit myri_load_lanai(struct myri_eth *mp)
 	if (mp->eeprom.cpuvers >= CPUVERS_3_0)
 		sbus_writel(mp->eeprom.cval, mp->lregs + LANAI_CVAL);
 
+	i = request_firmware(&fw, FWNAME, &mp->myri_op->dev);
+	if (i) {
+		printk(KERN_ERR "Failed to load image \"%s\" err %d\n",
+		       FWNAME, i);
+		return i;
+	}
+	if (fw->size < 2) {
+		printk(KERN_ERR "Bogus length %zu in image \"%s\"\n",
+		       fw->size, FWNAME);
+		release_firmware(fw);
+		return -EINVAL;
+	}
+	lanai4_data_size = fw->data[0] << 8 | fw->data[1];
+
 	/* Load executable code. */
-	for (i = 0; i < sizeof(lanai4_code); i++)
-		sbus_writeb(lanai4_code[i], rptr + (lanai4_code_off * 2) + i);
+	for (i = 2; i < fw->size; i++)
+		sbus_writeb(fw->data[i], rptr++);
 
 	/* Load data segment. */
-	for (i = 0; i < sizeof(lanai4_data); i++)
-		sbus_writeb(lanai4_data[i], rptr + (lanai4_data_off * 2) + i);
+	for (i = 0; i < lanai4_data_size; i++)
+		sbus_writeb(0, rptr++);
 
 	/* Set device address. */
 	sbus_writeb(0, &shmem->addr[0]);
@@ -228,6 +246,7 @@ static int __devinit myri_load_lanai(struct myri_eth *mp)
 	if (mp->eeprom.cpuvers == CPUVERS_4_0)
 		sbus_writel(0, mp->lregs + LANAI_VERS);
 
+	release_firmware(fw);
 	return i;
 }
 
@@ -1078,7 +1097,10 @@ static int __devinit myri_sbus_probe(struct of_device *op, const struct of_devic
 
 	/* Load code onto the LANai. */
 	DET(("Loading LANAI firmware\n"));
-	myri_load_lanai(mp);
+	if (myri_load_lanai(mp)) {
+		printk(KERN_ERR "MyriCOM: Cannot Load LANAI firmware.\n");
+		goto err_free_irq;
+	}
 
 	if (register_netdev(dev)) {
 		printk("MyriCOM: Cannot register device.\n");
@@ -1159,3 +1181,4 @@ module_init(myri_sbus_init);
 module_exit(myri_sbus_exit);
 
 MODULE_LICENSE("GPL");
+MODULE_FIRMWARE(FWNAME);
diff --git a/firmware/Makefile b/firmware/Makefile
index baf5ae4..e6c0fd1 100644
--- a/firmware/Makefile
+++ b/firmware/Makefile
@@ -40,6 +40,7 @@ fw-shipped-$(CONFIG_CHELSIO_T3) += cxgb3/t3b_psram-1.1.0.bin \
 fw-shipped-$(CONFIG_DVB_TTUSB_BUDGET) += ttusb-budget/dspbootcode.bin
 fw-shipped-$(CONFIG_E100) += e100/d101m_ucode.bin e100/d101s_ucode.bin \
 			     e100/d102e_ucode.bin
+fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
 fw-shipped-$(CONFIG_PCMCIA_SMC91C92) += ositech/Xilinx7OD.bin
 fw-shipped-$(CONFIG_SMCTR) += tr_smctr.bin
 fw-shipped-$(CONFIG_SND_KORG1212) += korg/k1212.dsp
diff --git a/firmware/WHENCE b/firmware/WHENCE
index 3814d7d..1b340c1 100644
--- a/firmware/WHENCE
+++ b/firmware/WHENCE
@@ -543,3 +543,13 @@ Licence: Allegedly GPL, but no source visible. Marked:
 Found in hex form in kernel source.
 
 --------------------------------------------------------------------------
+
+Driver: MYRI_SBUS - MyriCOM Gigabit Ethernet
+
+File: myricom/lanai.bin
+
+Licence: Unknown
+
+Found in hex form in kernel source.
+
+--------------------------------------------------------------------------


