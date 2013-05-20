From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH] drivers: net: usb: rtl8150: concurrent URB bugfix
Date: Mon, 20 May 2013 12:08:47 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305201152001.11943@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

This patch fixes a potential race with concurrently running asynchronous 
write requests.  The values for device's RX control register are now 
stored in dynamically allocated buffers so each URB submission has it's 
own copy.  Doing it the old way is data clobbering prone.

This patch is against latest 'net' tree.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
 drivers/net/usb/rtl8150.c |  100 ++++++++++++++++-------------------
 1 file changed, 46 insertions(+), 54 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index a491d3a..6cbdac6 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -130,19 +130,23 @@ struct rtl8150 {
 	struct usb_device *udev;
 	struct tasklet_struct tl;
 	struct net_device *netdev;
-	struct urb *rx_urb, *tx_urb, *intr_urb, *ctrl_urb;
+	struct urb *rx_urb, *tx_urb, *intr_urb;
 	struct sk_buff *tx_skb, *rx_skb;
 	struct sk_buff *rx_skb_pool[RX_SKB_POOL_SIZE];
 	spinlock_t rx_pool_lock;
 	struct usb_ctrlrequest dr;
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
 static const char driver_name [] = "rtl8150";
 
 /*
@@ -164,51 +168,47 @@ static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 			       indx, 0, data, size, 500);
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
+	int res = -ENOMEM;
+	struct urb *async_urb;
+	struct async_req *req;
 
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
+	                     usb_sndctrlpipe(dev->udev, 0), (void *)&req->dr,
+			     &req->rx_creg, size, async_set_reg_cb, req);
+	res = usb_submit_urb(async_urb, GFP_ATOMIC);
+	if (res) {
+		if (res == -ENODEV)
 			netif_device_detach(dev->netdev);
-		dev_err(&dev->udev->dev,
-			"control request submission failed: %d\n", ret);
-	} else
-		set_bit(RX_REG_SET, &dev->flags);
-
-	return ret;
+		dev_err(&dev->udev->dev, "%s failed with %d\n", __func__, res);
+	}
+	return res;
 }
 
 static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
@@ -330,13 +330,6 @@ static int alloc_all_urbs(rtl8150_t * dev)
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
 
 	return 1;
 }
@@ -346,7 +339,6 @@ static void free_all_urbs(rtl8150_t * dev)
 	usb_free_urb(dev->rx_urb);
 	usb_free_urb(dev->tx_urb);
 	usb_free_urb(dev->intr_urb);
-	usb_free_urb(dev->ctrl_urb);
 }
 
 static void unlink_all_urbs(rtl8150_t * dev)
@@ -354,7 +346,6 @@ static void unlink_all_urbs(rtl8150_t * dev)
 	usb_kill_urb(dev->rx_urb);
 	usb_kill_urb(dev->tx_urb);
 	usb_kill_urb(dev->intr_urb);
-	usb_kill_urb(dev->ctrl_urb);
 }
 
 static inline struct sk_buff *pull_skb(rtl8150_t *dev)
@@ -629,7 +620,6 @@ static int enable_net_traffic(rtl8150_t * dev)
 	}
 	/* RCR bit7=1 attach Rx info at the end;  =0 HW CRC (which is broken) */
 	rcr = 0x9e;
-	dev->rx_creg = cpu_to_le16(rcr);
 	tcr = 0xd8;
 	cr = 0x0c;
 	if (!(rcr & 0x80))
@@ -662,20 +652,22 @@ static void rtl8150_tx_timeout(struct net_device *netdev)
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
 	} else if (!netdev_mc_empty(netdev) ||
 		   (netdev->flags & IFF_ALLMULTI)) {
-		dev->rx_creg &= cpu_to_le16(0xfffe);
-		dev->rx_creg |= cpu_to_le16(0x0002);
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
 
