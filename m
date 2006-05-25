From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 4/4] [IrDA] ali-ircc: using device model power management
Date: Thu, 25 May 2006 06:20:52 +0000
Message-ID: <20060525062052.GD24611@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:32727 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932231AbWEXXKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 19:10:47 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch gets rid of the old power management code and now uses the
device model for the ali-ircc driver.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>


---

 drivers/net/irda/ali-ircc.c |  106 +++++++++++++++++++++----------------------
 1 files changed, 51 insertions(+), 55 deletions(-)

3e4b76aae7a8b088e1c8724aaedc1e63eae589a2
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 2e7882e..bf1fca5 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -34,14 +34,12 @@ #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/serial_reg.h>
 #include <linux/dma-mapping.h>
+#include <linux/platform_device.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
 
-#include <linux/pm.h>
-#include <linux/pm_legacy.h>
-
 #include <net/irda/wrapper.h>
 #include <net/irda/irda.h>
 #include <net/irda/irda_device.h>
@@ -51,7 +49,19 @@ #include "ali-ircc.h"
 #define CHIP_IO_EXTENT 8
 #define BROKEN_DONGLE_ID
 
-static char *driver_name = "ali-ircc";
+#define ALI_IRCC_DRIVER_NAME "ali-ircc"
+
+/* Power Management */
+static int ali_ircc_suspend(struct platform_device *dev, pm_message_t state);
+static int ali_ircc_resume(struct platform_device *dev);
+
+static struct platform_driver ali_ircc_driver = {
+	.suspend	= ali_ircc_suspend,
+	.resume		= ali_ircc_resume,
+	.driver		= {
+		.name	= ALI_IRCC_DRIVER_NAME,
+	},
+};
 
 /* Module parameters */
 static int qos_mtt_bits = 0x07;  /* 1 ms or more */
@@ -97,10 +107,7 @@ static int  ali_ircc_is_receiving(struct
 static int  ali_ircc_net_open(struct net_device *dev);
 static int  ali_ircc_net_close(struct net_device *dev);
 static int  ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
-static int  ali_ircc_pmproc(struct pm_dev *dev, pm_request_t rqst, void *data);
 static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud);
-static void ali_ircc_suspend(struct ali_ircc_cb *self);
-static void ali_ircc_wakeup(struct ali_ircc_cb *self);
 static struct net_device_stats *ali_ircc_net_get_stats(struct net_device *dev);
 
 /* SIR function */
@@ -145,6 +152,14 @@ static int __init ali_ircc_init(void)
 	int i = 0;
 	
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+
+	ret = platform_driver_register(&ali_ircc_driver);
+        if (ret) {
+                IRDA_ERROR("%s, Can't register driver!\n",
+			   ALI_IRCC_DRIVER_NAME);
+                return ret;
+        }
+
 	
 	/* Probe for all the ALi chipsets we know about */
 	for (chip= chips; chip->name; chip++, i++) 
@@ -214,6 +229,10 @@ static int __init ali_ircc_init(void)
 	}		
 		
 	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);					   		
+
+	if (ret)
+		platform_driver_unregister(&ali_ircc_driver);
+
 	return ret;
 }
 
@@ -228,14 +247,14 @@ static void __exit ali_ircc_cleanup(void
 	int i;
 
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);	
-	
-	pm_unregister_all(ali_ircc_pmproc);
 
 	for (i=0; i < 4; i++) {
 		if (dev_self[i])
 			ali_ircc_close(dev_self[i]);
 	}
 	
+	platform_driver_unregister(&ali_ircc_driver);
+
 	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
 }
 
@@ -249,7 +268,6 @@ static int ali_ircc_open(int i, chipio_t
 {
 	struct net_device *dev;
 	struct ali_ircc_cb *self;
-	struct pm_dev *pmdev;
 	int dongle_id;
 	int err;
 			
@@ -284,7 +302,8 @@ static int ali_ircc_open(int i, chipio_t
         self->io.fifo_size = 16;		/* SIR: 16, FIR: 32 Benjamin 2000/11/1 */
 	
 	/* Reserve the ioports that we need */
-	if (!request_region(self->io.fir_base, self->io.fir_ext, driver_name)) {
+	if (!request_region(self->io.fir_base, self->io.fir_ext,
+			    ALI_IRCC_DRIVER_NAME)) {
 		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n", __FUNCTION__,
 			self->io.fir_base);
 		err = -ENODEV;
@@ -354,13 +373,10 @@ static int ali_ircc_open(int i, chipio_t
 
 	/* Check dongle id */
 	dongle_id = ali_ircc_read_dongle_id(i, info);
-	IRDA_MESSAGE("%s(), %s, Found dongle: %s\n", __FUNCTION__, driver_name, dongle_types[dongle_id]);
+	IRDA_MESSAGE("%s(), %s, Found dongle: %s\n", __FUNCTION__,
+		     ALI_IRCC_DRIVER_NAME, dongle_types[dongle_id]);
 		
 	self->io.dongle_id = dongle_id;
-	
-        pmdev = pm_register(PM_SYS_DEV, PM_SYS_IRDA, ali_ircc_pmproc);
-        if (pmdev)
-                pmdev->data = self;
 
 	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
 	
@@ -548,12 +564,11 @@ static int ali_ircc_setup(chipio_t *info
 	/* Should be 0x00 in the M1535/M1535D */
 	if(version != 0x00)
 	{
-		IRDA_ERROR("%s, Wrong chip version %02x\n", driver_name, version);
+		IRDA_ERROR("%s, Wrong chip version %02x\n",
+			   ALI_IRCC_DRIVER_NAME, version);
 		return -1;
 	}
 	
-	// IRDA_MESSAGE("%s, Found chip at base=0x%03x\n", driver_name, info->cfg_base);
-	
 	/* Set FIR FIFO Threshold Register */
 	switch_bank(iobase, BANK1);
 	outb(RX_FIFO_Threshold, iobase+FIR_FIFO_TR);
@@ -583,7 +598,8 @@ static int ali_ircc_setup(chipio_t *info
 	/* Switch to SIR space */
 	FIR2SIR(iobase);
 	
-	IRDA_MESSAGE("%s, driver loaded (Benjamin Kong)\n", driver_name);
+	IRDA_MESSAGE("%s, driver loaded (Benjamin Kong)\n",
+		     ALI_IRCC_DRIVER_NAME);
 	
 	/* Enable receive interrupts */ 
 	// outb(UART_IER_RDI, iobase+UART_IER); //benjamin 2000/11/23 01:25PM
@@ -647,7 +663,8 @@ static irqreturn_t ali_ircc_interrupt(in
 	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
 		
  	if (!dev) {
-		IRDA_WARNING("%s: irq %d for unknown device.\n", driver_name, irq);
+		IRDA_WARNING("%s: irq %d for unknown device.\n",
+			     ALI_IRCC_DRIVER_NAME, irq);
 		return IRQ_NONE;
 	}	
 	
@@ -1328,7 +1345,8 @@ static int ali_ircc_net_open(struct net_
 	/* Request IRQ and install Interrupt Handler */
 	if (request_irq(self->io.irq, ali_ircc_interrupt, 0, dev->name, dev)) 
 	{
-		IRDA_WARNING("%s, unable to allocate irq=%d\n", driver_name,
+		IRDA_WARNING("%s, unable to allocate irq=%d\n",
+			     ALI_IRCC_DRIVER_NAME,
 			     self->io.irq);
 		return -EAGAIN;
 	}
@@ -1338,7 +1356,8 @@ static int ali_ircc_net_open(struct net_
 	 * failure.
 	 */
 	if (request_dma(self->io.dma, dev->name)) {
-		IRDA_WARNING("%s, unable to allocate dma=%d\n", driver_name,
+		IRDA_WARNING("%s, unable to allocate dma=%d\n",
+			     ALI_IRCC_DRIVER_NAME,
 			     self->io.dma);
 		free_irq(self->io.irq, self);
 		return -EAGAIN;
@@ -2108,61 +2127,38 @@ static struct net_device_stats *ali_ircc
 	return &self->stats;
 }
 
-static void ali_ircc_suspend(struct ali_ircc_cb *self)
+static int ali_ircc_suspend(struct platform_device *dev, pm_message_t state)
 {
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	struct ali_ircc_cb *self = platform_get_drvdata(dev);
 	
-	IRDA_MESSAGE("%s, Suspending\n", driver_name);
+	IRDA_MESSAGE("%s, Suspending\n", ALI_IRCC_DRIVER_NAME);
 
 	if (self->io.suspended)
-		return;
+		return 0;
 
 	ali_ircc_net_close(self->netdev);
 
 	self->io.suspended = 1;
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	return 0;
 }
 
-static void ali_ircc_wakeup(struct ali_ircc_cb *self)
+static int ali_ircc_resume(struct platform_device *dev)
 {
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	struct ali_ircc_cb *self = platform_get_drvdata(dev);
 	
 	if (!self->io.suspended)
-		return;
+		return 0;
 	
 	ali_ircc_net_open(self->netdev);
 	
-	IRDA_MESSAGE("%s, Waking up\n", driver_name);
+	IRDA_MESSAGE("%s, Waking up\n", ALI_IRCC_DRIVER_NAME);
 
 	self->io.suspended = 0;
-	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
-}
 
-static int ali_ircc_pmproc(struct pm_dev *dev, pm_request_t rqst, void *data)
-{
-        struct ali_ircc_cb *self = (struct ali_ircc_cb*) dev->data;
-        
-        IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
-	
-        if (self) {
-                switch (rqst) {
-                case PM_SUSPEND:
-                        ali_ircc_suspend(self);
-                        break;
-                case PM_RESUME:
-                        ali_ircc_wakeup(self);
-                        break;
-                }
-        }
-        
-        IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
-        
 	return 0;
 }
 
-
 /* ALi Chip Function */
 
 static void SetCOMInterrupts(struct ali_ircc_cb *self , unsigned char enable)
-- 
1.3.2

