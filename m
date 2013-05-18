From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 4/5] drivers: net: usb: rtl8150: avoid potential race in
 async registers write
Date: Sat, 18 May 2013 23:21:29 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305182313050.16874@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:49124 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753157Ab3ERUVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 16:21:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petko Manolov <petkan@nucleusys.com>

[get|set]_registers() will now display a message in case of error condition
and if DEBUG is enabled.  All resources required for asynchronous control URB
submission are being dynamically (de)allocated.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
 drivers/net/usb/rtl8150.c |  129 +++++++++++++++++------------------
 drivers/net/usb/rtl8150.h |    9 ++-
 2 files changed, 68 insertions(+), 70 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index fd4bc2a..0e226d8 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -15,7 +15,6 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/usb.h>
-#include <asm/uaccess.h>
 
 #include "rtl8150.h"
 
@@ -29,69 +28,75 @@ MODULE_DEVICE_TABLE(usb, rtl8150_table);
 static const char driver_name [] = "rtl8150";
 
 /*
-**
-**	device related part of the code
-**
-*/
+ *
+ * device related part of the code
+ *
+ */
 static int get_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 {
-	return usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
-			       RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
-			       indx, 0, data, size, 500);
+	int res;
+
+	res = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
+			      RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
+			      indx, 0, data, size, 500);
+	if (res < 0)
+		dev_dbg(&dev->udev->dev, "%s returned %d\n", __func__, res);
+	return res;
 }
 
 static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 {
-	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-			       RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
-			       indx, 0, data, size, 500);
+	int res;
+
+	res = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
+			      RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
+			      indx, 0, data, size, 500);
+	if (res < 0)
+		dev_dbg(&dev->udev->dev, "%s returned %d\n", __func__, res);
+	return res;
 }
 
-static void ctrl_callback(struct urb *urb)
+static void async_set_reg_cb(struct urb *urb)
 {
-	rtl8150_t *dev;
+	struct async_req *req = (struct async_req *)urb->context;
 	int status = urb->status;
 
-	switch (status) {
-	case 0:
-		break;
-	case -EINPROGRESS:
-		break;
-	case -ENOENT:
-		break;
-	default:
-		if (printk_ratelimit())
-			dev_warn(&urb->dev->dev, "ctrl urb status %d\n", status);
-	}
-	dev = urb->context;
-	clear_bit(RX_REG_SET, &dev->flags);
+	if (status < 0)
+		dev_dbg(&urb->dev->dev, "%s failed with %d", __func__, status);
+	kfree(req);
+	usb_free_urb(urb);
 }
 
-static int async_set_registers(rtl8150_t * dev, u16 indx, u16 size)
+static int async_set_registers(rtl8150_t *dev, u16 indx, u16 size, u16 reg)
 {
-	int ret;
-
-	if (test_bit(RX_REG_SET, &dev->flags))
-		return -EAGAIN;
-
-	dev->dr.bRequestType = RTL8150_REQT_WRITE;
-	dev->dr.bRequest = RTL8150_REQ_SET_REGS;
-	dev->dr.wValue = cpu_to_le16(indx);
-	dev->dr.wIndex = 0;
-	dev->dr.wLength = cpu_to_le16(size);
-	dev->ctrl_urb->transfer_buffer_length = size;
-	usb_fill_control_urb(dev->ctrl_urb, dev->udev,
-			 usb_sndctrlpipe(dev->udev, 0), (char *) &dev->dr,
-			 &dev->rx_creg, size, ctrl_callback, dev);
-	if ((ret = usb_submit_urb(dev->ctrl_urb, GFP_ATOMIC))) {
-		if (ret == -ENODEV)
-			netif_device_detach(dev->netdev);
-		dev_err(&dev->udev->dev,
-			"control request submission failed: %d\n", ret);
-	} else
-		set_bit(RX_REG_SET, &dev->flags);
+	int res = -ENOMEM;
+	struct urb *async_urb;
+	struct async_req *req;
 
-	return ret;
+	req = kmalloc(sizeof(struct async_req), GFP_ATOMIC);
+	if (req == NULL)
+		return res;
+	async_urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (async_urb == NULL) {
+		kfree(req);
+		return res;
+	}
+	req->rx_creg = cpu_to_le16(reg);
+	req->dr.bRequestType = RTL8150_REQT_WRITE;
+	req->dr.bRequest = RTL8150_REQ_SET_REGS;
+	req->dr.wIndex = 0;
+	req->dr.wValue = cpu_to_le16(indx);
+	req->dr.wLength = cpu_to_le16(size);
+	usb_fill_control_urb(async_urb, dev->udev,
+	                     usb_sndctrlpipe(dev->udev, 0), (void *) &req->dr,
+			     &req->rx_creg, size, async_set_reg_cb, req);
+	res = usb_submit_urb(async_urb, GFP_ATOMIC);
+	if (res) {
+		if (res == -ENODEV)
+			netif_device_detach(dev->netdev);
+		dev_err(&dev->udev->dev, "%s failed with %d\n", __func__, res);
+	}
+	return res;
 }
 
 static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
@@ -213,14 +218,6 @@ static int alloc_all_urbs(rtl8150_t * dev)
 		usb_free_urb(dev->tx_urb);
 		return 0;
 	}
-	dev->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!dev->ctrl_urb) {
-		usb_free_urb(dev->rx_urb);
-		usb_free_urb(dev->tx_urb);
-		usb_free_urb(dev->intr_urb);
-		return 0;
-	}
-
 	return 1;
 }
 
@@ -229,7 +226,6 @@ static void free_all_urbs(rtl8150_t * dev)
 	usb_free_urb(dev->rx_urb);
 	usb_free_urb(dev->tx_urb);
 	usb_free_urb(dev->intr_urb);
-	usb_free_urb(dev->ctrl_urb);
 }
 
 static void unlink_all_urbs(rtl8150_t * dev)
@@ -237,7 +233,6 @@ static void unlink_all_urbs(rtl8150_t * dev)
 	usb_kill_urb(dev->rx_urb);
 	usb_kill_urb(dev->tx_urb);
 	usb_kill_urb(dev->intr_urb);
-	usb_kill_urb(dev->ctrl_urb);
 }
 
 static void read_bulk_callback(struct urb *urb)
@@ -464,7 +459,6 @@ static int enable_net_traffic(rtl8150_t * dev)
 	}
 	/* RCR bit7=1 attach Rx info at the end;  =0 HW CRC (which is broken) */
 	rcr = 0x9e;
-	dev->rx_creg = cpu_to_le16(rcr);
 	tcr = 0xd8;
 	cr = 0x0c;
 	if (!(rcr & 0x80))
@@ -497,20 +491,21 @@ static void rtl8150_tx_timeout(struct net_device *netdev)
 static void rtl8150_set_multicast(struct net_device *netdev)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
+	u16 rx_creg = 0x9e;
+
 	netif_stop_queue(netdev);
 	if (netdev->flags & IFF_PROMISC) {
-		dev->rx_creg |= cpu_to_le16(0x0001);
+		rx_creg |= 0x0001;
 		dev_info(&netdev->dev, "%s: promiscuous mode\n", netdev->name);
-	} else if (!netdev_mc_empty(netdev) ||
-		   (netdev->flags & IFF_ALLMULTI)) {
-		dev->rx_creg &= cpu_to_le16(0xfffe);
-		dev->rx_creg |= cpu_to_le16(0x0002);
+	} else if (!netdev_mc_empty(netdev) || (netdev->flags & IFF_ALLMULTI)) {
+		rx_creg &= 0xfffe;
+		rx_creg |= 0x0002;
 		dev_info(&netdev->dev, "%s: allmulti set\n", netdev->name);
 	} else {
 		/* ~RX_MULTICAST, ~RX_PROMISCUOUS */
-		dev->rx_creg &= cpu_to_le16(0x00fc);
+		rx_creg &= 0x00fc;
 	}
-	async_set_registers(dev, RCR, 2);
+	async_set_registers(dev, RCR, sizeof(rx_creg), rx_creg);
 	netif_wake_queue(netdev);
 }
 
diff --git a/drivers/net/usb/rtl8150.h b/drivers/net/usb/rtl8150.h
index a29410c..2dff8f4 100644
--- a/drivers/net/usb/rtl8150.h
+++ b/drivers/net/usb/rtl8150.h
@@ -114,15 +114,18 @@ struct rtl8150 {
 	struct usb_device *udev;
 	struct tasklet_struct tl;
 	struct net_device *netdev;
-	struct urb *rx_urb, *tx_urb, *intr_urb, *ctrl_urb;
+	struct urb *rx_urb, *tx_urb, *intr_urb;
 	struct sk_buff *tx_skb, *rx_skb;
-	struct usb_ctrlrequest dr;
 	int intr_interval;
-	__le16 rx_creg;
 	u8 *intr_buff;
 	u8 phy;
 };
 
 typedef struct rtl8150 rtl8150_t;
 
+struct async_req {
+	struct usb_ctrlrequest dr;
+	u16 rx_creg;
+};
+
 #endif	/* __rtl8150_h__ */
