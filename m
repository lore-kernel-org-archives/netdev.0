From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH 2/2] rsi: fix memory leaks and error handling in rsi_91x_usb
Date: Fri, 27 Jun 2014 02:51:25 +0400
Message-ID: <1403823085-10464-2-git-send-email-khoroshilov@ispras.ru>
References: <1403823085-10464-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Fariya Fatima <fariyaf@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403823085-10464-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch fixes a couple of issues:
- absence of deallocation of rsi_dev->rx_usb_urb[0] in the driver;
- potential NULL pointer dereference because of lack of checks for memory
  allocation success in rsi_init_usb_interface().

By the way, it makes rsi_probe() returning error code instead of 1
and fixes comments regarding returning values.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/rsi/rsi_91x_usb.c | 58 ++++++++++++++++++++++------------
 1 file changed, 38 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_usb.c b/drivers/net/wireless/rsi/rsi_91x_usb.c
index 2e0254606e3d..de4d100b84dd 100644
--- a/drivers/net/wireless/rsi/rsi_91x_usb.c
+++ b/drivers/net/wireless/rsi/rsi_91x_usb.c
@@ -25,7 +25,7 @@
  * @len: Length to be written.
  * @endpoint: Type of endpoint.
  *
- * Return: status: 0 on success, -1 on failure.
+ * Return: status: 0 on success, a negative error code on failure.
  */
 static int rsi_usb_card_write(struct rsi_hw *adapter,
 			      void *buf,
@@ -60,7 +60,7 @@ static int rsi_usb_card_write(struct rsi_hw *adapter,
  * @data: Pointer to the data that has to be written.
  * @count: Number of multiple bytes to be written.
  *
- * Return: 0 on success, -1 on failure.
+ * Return: 0 on success, a negative error code on failure.
  */
 static int rsi_write_multiple(struct rsi_hw *adapter,
 			      u8 endpoint,
@@ -147,7 +147,7 @@ static int rsi_find_bulk_in_and_out_endpoints(struct usb_interface *interface,
  * @value: Value to be read.
  * @len: length of data to be read.
  *
- * Return: status: 0 on success, -1 on failure.
+ * Return: status: 0 on success, a negative error code on failure.
  */
 static int rsi_usb_reg_read(struct usb_device *usbdev,
 			    u32 reg,
@@ -189,7 +189,7 @@ static int rsi_usb_reg_read(struct usb_device *usbdev,
  * @value: Value to write.
  * @len: Length of data to be written.
  *
- * Return: status: 0 on success, -1 on failure.
+ * Return: status: 0 on success, a negative error code on failure.
  */
 static int rsi_usb_reg_write(struct usb_device *usbdev,
 			     u32 reg,
@@ -249,7 +249,7 @@ static void rsi_rx_done_handler(struct urb *urb)
  * rsi_rx_urb_submit() - This function submits the given URB to the USB stack.
  * @adapter: Pointer to the adapter structure.
  *
- * Return: 0 on success, -1 on failure.
+ * Return: 0 on success, a negative error code on failure.
  */
 static int rsi_rx_urb_submit(struct rsi_hw *adapter)
 {
@@ -281,7 +281,7 @@ static int rsi_rx_urb_submit(struct rsi_hw *adapter)
  * @data: Pointer to the data that has to be written.
  * @count: Number of multiple bytes to be written on to the registers.
  *
- * Return: status: 0 on success, -1 on failure.
+ * Return: status: 0 on success, a negative error code on failure.
  */
 int rsi_usb_write_register_multiple(struct rsi_hw *adapter,
 				    u32 addr,
@@ -331,7 +331,7 @@ int rsi_usb_write_register_multiple(struct rsi_hw *adapter,
  * @pkt: Pointer to the data to be written on to the card.
  * @len: Length of the data to be written on to the card.
  *
- * Return: 0 on success, -1 on failure.
+ * Return: 0 on success, a negative error code on failure.
  */
 static int rsi_usb_host_intf_write_pkt(struct rsi_hw *adapter,
 				       u8 *pkt,
@@ -359,6 +359,7 @@ static void rsi_deinit_usb_interface(struct rsi_hw *adapter)
 	struct rsi_91x_usbdev *dev = (struct rsi_91x_usbdev *)adapter->rsi_dev;
 
 	rsi_kill_thread(&dev->rx_thread);
+	usb_free_urb(dev->rx_usb_urb[0]);
 	kfree(adapter->priv->rx_data_pkt);
 	kfree(dev->tx_buffer);
 }
@@ -368,7 +369,7 @@ static void rsi_deinit_usb_interface(struct rsi_hw *adapter)
  * @adapter: Pointer to the adapter structure.
  * @pfunction: Pointer to USB interface structure.
  *
- * Return: 0 on success, -1 on failure.
+ * Return: 0 on success, a negative error code on failure.
  */
 static int rsi_init_usb_interface(struct rsi_hw *adapter,
 				  struct usb_interface *pfunction)
@@ -398,7 +399,15 @@ static int rsi_init_usb_interface(struct rsi_hw *adapter,
 	}
 
 	rsi_dev->tx_buffer = kmalloc(2048, GFP_KERNEL);
+	if (!rsi_dev->tx_buffer) {
+		status = -ENOMEM;
+		goto fail_tx;
+	}
 	rsi_dev->rx_usb_urb[0] = usb_alloc_urb(0, GFP_KERNEL);
+	if (!rsi_dev->rx_usb_urb[0]) {
+		status = -ENOMEM;
+		goto fail_rx;
+	}
 	rsi_dev->rx_usb_urb[0]->transfer_buffer = adapter->priv->rx_data_pkt;
 	rsi_dev->tx_blk_size = 252;
 
@@ -413,7 +422,7 @@ static int rsi_init_usb_interface(struct rsi_hw *adapter,
 				    rsi_usb_rx_thread, "RX-Thread");
 	if (status) {
 		rsi_dbg(ERR_ZONE, "%s: Unable to init rx thrd\n", __func__);
-		goto fail;
+		goto fail_thread;
 	}
 
 #ifdef CONFIG_RSI_DEBUGFS
@@ -424,8 +433,11 @@ static int rsi_init_usb_interface(struct rsi_hw *adapter,
 	rsi_dbg(INIT_ZONE, "%s: Enabled the interface\n", __func__);
 	return 0;
 
-fail:
+fail_thread:
+	usb_free_urb(rsi_dev->rx_usb_urb[0]);
+fail_rx:
 	kfree(rsi_dev->tx_buffer);
+fail_tx:
 	kfree(common->rx_data_pkt);
 	return status;
 }
@@ -437,7 +449,7 @@ fail:
  * @pfunction: Pointer to the USB interface structure.
  * @id: Pointer to the usb_device_id structure.
  *
- * Return: 0 on success, -1 on failure.
+ * Return: 0 on success, a negative error code on failure.
  */
 static int rsi_probe(struct usb_interface *pfunction,
 		     const struct usb_device_id *id)
@@ -445,6 +457,7 @@ static int rsi_probe(struct usb_interface *pfunction,
 	struct rsi_hw *adapter;
 	struct rsi_91x_usbdev *dev;
 	u16 fw_status;
+	int status;
 
 	rsi_dbg(INIT_ZONE, "%s: Init function called\n", __func__);
 
@@ -452,10 +465,11 @@ static int rsi_probe(struct usb_interface *pfunction,
 	if (!adapter) {
 		rsi_dbg(ERR_ZONE, "%s: Failed to init os intf ops\n",
 			__func__);
-		return 1;
+		return -ENOMEM;
 	}
 
-	if (rsi_init_usb_interface(adapter, pfunction)) {
+	status = rsi_init_usb_interface(adapter, pfunction);
+	if (status) {
 		rsi_dbg(ERR_ZONE, "%s: Failed to init usb interface\n",
 			__func__);
 		goto err;
@@ -465,26 +479,30 @@ static int rsi_probe(struct usb_interface *pfunction,
 
 	dev = (struct rsi_91x_usbdev *)adapter->rsi_dev;
 
-	if (rsi_usb_reg_read(dev->usbdev, FW_STATUS_REG, &fw_status, 2) < 0)
+	status = rsi_usb_reg_read(dev->usbdev, FW_STATUS_REG, &fw_status, 2);
+	if (status)
 		goto err1;
 	else
 		fw_status &= 1;
 
 	if (!fw_status) {
-		if (rsi_usb_device_init(adapter->priv)) {
+		status = rsi_usb_device_init(adapter->priv);
+		if (status) {
 			rsi_dbg(ERR_ZONE, "%s: Failed in device init\n",
 				__func__);
 			goto err1;
 		}
 
-		if (rsi_usb_reg_write(dev->usbdev,
-				      USB_INTERNAL_REG_1,
-				      RSI_USB_READY_MAGIC_NUM, 1) < 0)
+		status = rsi_usb_reg_write(dev->usbdev,
+					   USB_INTERNAL_REG_1,
+					   RSI_USB_READY_MAGIC_NUM, 1);
+		if (status)
 			goto err1;
 		rsi_dbg(INIT_ZONE, "%s: Performed device init\n", __func__);
 	}
 
-	if (rsi_rx_urb_submit(adapter))
+	status = rsi_rx_urb_submit(adapter);
+	if (status)
 		goto err1;
 
 	return 0;
@@ -493,7 +511,7 @@ err1:
 err:
 	rsi_91x_deinit(adapter);
 	rsi_dbg(ERR_ZONE, "%s: Failed in probe...Exiting\n", __func__);
-	return 1;
+	return status;
 }
 
 /**
-- 
1.9.1
