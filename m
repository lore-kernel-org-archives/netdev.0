From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] net: can: peak_usb: Do not do dma on the stack
Date: Mon,  3 Jun 2013 14:15:33 +0200
Message-ID: <1370261733-22935-4-git-send-email-mkl@pengutronix.de>
References: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, davem@davemloft.net,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Stephane Grosjean <s.grosjean@peak-system.com>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

smatch reports the following warnings:
drivers/net/can/usb/peak_usb/pcan_usb_pro.c:514 pcan_usb_pro_drv_loaded() error: doing dma on the stack (buffer)
drivers/net/can/usb/peak_usb/pcan_usb_pro.c:878 pcan_usb_pro_init() error: doing dma on the stack (&fi)
drivers/net/can/usb/peak_usb/pcan_usb_pro.c:889 pcan_usb_pro_init() error: doing dma on the stack (&bi)

See "Documentation/DMA-API-HOWTO.txt" section "What memory is DMA'able?"

Cc: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c | 61 +++++++++++++++++++----------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h |  1 +
 2 files changed, 41 insertions(+), 21 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index 30d79bf..8ee9d15 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -504,15 +504,24 @@ static int pcan_usb_pro_restart_async(struct peak_usb_device *dev,
 	return usb_submit_urb(urb, GFP_ATOMIC);
 }
 
-static void pcan_usb_pro_drv_loaded(struct peak_usb_device *dev, int loaded)
+static int pcan_usb_pro_drv_loaded(struct peak_usb_device *dev, int loaded)
 {
-	u8 buffer[16];
+	u8 *buffer;
+	int err;
+
+	buffer = kmalloc(PCAN_USBPRO_FCT_DRVLD_REQ_LEN, GFP_KERNEL);
+	if (!buffer)
+		return -ENOMEM;
 
 	buffer[0] = 0;
 	buffer[1] = !!loaded;
 
-	pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_FCT,
-			      PCAN_USBPRO_FCT_DRVLD, buffer, sizeof(buffer));
+	err = pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_FCT,
+				    PCAN_USBPRO_FCT_DRVLD, buffer,
+				    PCAN_USBPRO_FCT_DRVLD_REQ_LEN);
+	kfree(buffer);
+
+	return err;
 }
 
 static inline
@@ -851,21 +860,24 @@ static int pcan_usb_pro_stop(struct peak_usb_device *dev)
  */
 static int pcan_usb_pro_init(struct peak_usb_device *dev)
 {
-	struct pcan_usb_pro_interface *usb_if;
 	struct pcan_usb_pro_device *pdev =
 			container_of(dev, struct pcan_usb_pro_device, dev);
+	struct pcan_usb_pro_interface *usb_if = NULL;
+	struct pcan_usb_pro_fwinfo *fi = NULL;
+	struct pcan_usb_pro_blinfo *bi = NULL;
+	int err;
 
 	/* do this for 1st channel only */
 	if (!dev->prev_siblings) {
-		struct pcan_usb_pro_fwinfo fi;
-		struct pcan_usb_pro_blinfo bi;
-		int err;
-
 		/* allocate netdevices common structure attached to first one */
 		usb_if = kzalloc(sizeof(struct pcan_usb_pro_interface),
 				 GFP_KERNEL);
-		if (!usb_if)
-			return -ENOMEM;
+		fi = kmalloc(sizeof(struct pcan_usb_pro_fwinfo), GFP_KERNEL);
+		bi = kmalloc(sizeof(struct pcan_usb_pro_blinfo), GFP_KERNEL);
+		if (!usb_if || !fi || !bi) {
+			err = -ENOMEM;
+			goto err_out;
+		}
 
 		/* number of ts msgs to ignore before taking one into account */
 		usb_if->cm_ignore_count = 5;
@@ -877,34 +889,34 @@ static int pcan_usb_pro_init(struct peak_usb_device *dev)
 		 */
 		err = pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_INFO,
 					    PCAN_USBPRO_INFO_FW,
-					    &fi, sizeof(fi));
+					    fi, sizeof(*fi));
 		if (err) {
-			kfree(usb_if);
 			dev_err(dev->netdev->dev.parent,
 				"unable to read %s firmware info (err %d)\n",
 				pcan_usb_pro.name, err);
-			return err;
+			goto err_out;
 		}
 
 		err = pcan_usb_pro_send_req(dev, PCAN_USBPRO_REQ_INFO,
 					    PCAN_USBPRO_INFO_BL,
-					    &bi, sizeof(bi));
+					    bi, sizeof(*bi));
 		if (err) {
-			kfree(usb_if);
 			dev_err(dev->netdev->dev.parent,
 				"unable to read %s bootloader info (err %d)\n",
 				pcan_usb_pro.name, err);
-			return err;
+			goto err_out;
 		}
 
+		/* tell the device the can driver is running */
+		err = pcan_usb_pro_drv_loaded(dev, 1);
+		if (err)
+			goto err_out;
+
 		dev_info(dev->netdev->dev.parent,
 		     "PEAK-System %s hwrev %u serial %08X.%08X (%u channels)\n",
 		     pcan_usb_pro.name,
-		     bi.hw_rev, bi.serial_num_hi, bi.serial_num_lo,
+		     bi->hw_rev, bi->serial_num_hi, bi->serial_num_lo,
 		     pcan_usb_pro.ctrl_count);
-
-		/* tell the device the can driver is running */
-		pcan_usb_pro_drv_loaded(dev, 1);
 	} else {
 		usb_if = pcan_usb_pro_dev_if(dev->prev_siblings);
 	}
@@ -916,6 +928,13 @@ static int pcan_usb_pro_init(struct peak_usb_device *dev)
 	pcan_usb_pro_set_led(dev, 0, 1);
 
 	return 0;
+
+ err_out:
+	kfree(bi);
+	kfree(fi);
+	kfree(usb_if);
+
+	return err;
 }
 
 static void pcan_usb_pro_exit(struct peak_usb_device *dev)
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.h b/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
index a869918..32275af 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.h
@@ -29,6 +29,7 @@
 
 /* Vendor Request value for XXX_FCT */
 #define PCAN_USBPRO_FCT_DRVLD		5 /* tell device driver is loaded */
+#define PCAN_USBPRO_FCT_DRVLD_REQ_LEN	16
 
 /* PCAN_USBPRO_INFO_BL vendor request record type */
 struct __packed pcan_usb_pro_blinfo {
-- 
1.8.2.rc2

