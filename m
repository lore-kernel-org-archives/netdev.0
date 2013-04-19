From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] net: usb: active URB submitted multiple times
Date: Fri, 19 Apr 2013 11:21:49 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1304191115230.4161@fry.nucleusys.com>
References: <20130410.232241.1038793023507666278.davem@davemloft.net> <alpine.DEB.2.02.1304110956110.4237@fry> <alpine.DEB.2.02.1304112156520.4309@fry> <20130412.151824.2029469075886743722.davem@davemloft.net>
 <alpine.DEB.2.02.1304151017230.3010@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304151017230.3010@bender.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

(For inclusion in 3.10, diff against latest net-next.)

Pegasus driver used single callback for sync and async control URBs. 
Special flags were employed to distinguish between both, but due to flawed 
logic (as Sarah Sharp spotted) it didn't always work.  As a result of this 
change [get|set]_registers() are now much simpler.  Async write is also 
leaner and does not use single, statically allocated memory for 
usb_ctrlrequest, which is another potential race when asynchronously 
submitting URBs.

The socket buffer pool for the receive path is now gone.  It's existence 
didn't make much difference (performance-wise) and the code is better off 
without the spinlocks protecting it.

Largely duplicated code in routines reading and writing MII registers is 
now packed in __mii_op().

Adding URL for the public pegasus git repository.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
Project website and public git repository moved to Github.

Some more formatting.  Sigh, somebody ought to keep checkpatch.pl and 
Lindent in sync.  The former seems a bit off.

 MAINTAINERS               |   10 +-
 drivers/net/usb/pegasus.c |  575 ++++++++++-------------------------
 drivers/net/usb/pegasus.h |   10 +-
 3 files changed, 169 insertions(+), 426 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c39bdc3..82ce7eb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8358,10 +8358,11 @@ S:	Maintained
 F:	drivers/usb/serial/option.c
 
 USB PEGASUS DRIVER
-M:	Petko Manolov <petkan@users.sourceforge.net>
+M:	Petko Manolov <petkan@nucleusys.com>
 L:	linux-usb@vger.kernel.org
 L:	netdev@vger.kernel.org
-W:	http://pegasus2.sourceforge.net/
+T:	git git://github.com/petkan/pegasus.git
+W:	https://github.com/petkan
 S:	Maintained
 F:	drivers/net/usb/pegasus.*
 
@@ -8380,10 +8381,11 @@ S:	Supported
 F:	drivers/usb/class/usblp.c
 
 USB RTL8150 DRIVER
-M:	Petko Manolov <petkan@users.sourceforge.net>
+M:	Petko Manolov <petkan@nucleusys.com>
 L:	linux-usb@vger.kernel.org
 L:	netdev@vger.kernel.org
-W:	http://pegasus2.sourceforge.net/
+T:	git git://github.com/petkan/rtl8150.git
+W:	https://github.com/petkan
 S:	Maintained
 F:	drivers/net/usb/rtl8150.c
 
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 73051d1..0f54976 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1,5 +1,5 @@
 /*
- *  Copyright (c) 1999-2005 Petko Manolov (petkan@users.sourceforge.net)
+ *  Copyright (c) 1999-2013 Petko Manolov (petkan@nucleusys.com)
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -26,6 +26,9 @@
  *		v0.5.1	ethtool support added
  *		v0.5.5	rx socket buffers are in a pool and the their allocation
  *			is out of the interrupt routine.
+ *		...
+ *		v0.9.1	simplified [get|set]_register(s), async update registers
+ *			logic revisited, receive skb_pool removed.
  */
 
 #include <linux/sched.h>
@@ -45,8 +48,8 @@
 /*
  * Version Information
  */
-#define DRIVER_VERSION "v0.6.14 (2006/09/27)"
-#define DRIVER_AUTHOR "Petko Manolov <petkan@users.sourceforge.net>"
+#define DRIVER_VERSION "v0.9.3 (2013/04/09)"
+#define DRIVER_AUTHOR "Petko Manolov <petkan@nucleusys.com>"
 #define DRIVER_DESC "Pegasus/Pegasus II USB Ethernet driver"
 
 static const char driver_name[] = "pegasus";
@@ -108,296 +111,150 @@ MODULE_PARM_DESC(msg_level, "Override default message level");
 MODULE_DEVICE_TABLE(usb, pegasus_ids);
 static const struct net_device_ops pegasus_netdev_ops;
 
-static int update_eth_regs_async(pegasus_t *);
-/* Aargh!!! I _really_ hate such tweaks */
-static void ctrl_callback(struct urb *urb)
+static void async_ctrl_callback(struct urb *urb)
 {
-	pegasus_t *pegasus = urb->context;
+	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
 	int status = urb->status;
 
-	if (!pegasus)
-		return;
-
-	switch (status) {
-	case 0:
-		if (pegasus->flags & ETH_REGS_CHANGE) {
-			pegasus->flags &= ~ETH_REGS_CHANGE;
-			pegasus->flags |= ETH_REGS_CHANGED;
-			update_eth_regs_async(pegasus);
-			return;
-		}
-		break;
-	case -EINPROGRESS:
-		return;
-	case -ENOENT:
-		break;
-	default:
-		if (net_ratelimit())
-			netif_dbg(pegasus, drv, pegasus->net,
-				  "%s, status %d\n", __func__, status);
-		break;
-	}
-	pegasus->flags &= ~ETH_REGS_CHANGED;
-	wake_up(&pegasus->ctrl_wait);
+	if (status < 0)
+		dev_dbg(&urb->dev->dev, "%s failed with %d", __func__, status);
+	kfree(req);
+	usb_free_urb(urb);
 }
 
-static int get_registers(pegasus_t *pegasus, __u16 indx, __u16 size,
-			 void *data)
+static int get_registers(pegasus_t *pegasus, __u16 indx, __u16 size, void *data)
 {
 	int ret;
-	char *buffer;
-	DECLARE_WAITQUEUE(wait, current);
-
-	buffer = kmalloc(size, GFP_KERNEL);
-	if (!buffer)
-		return -ENOMEM;
-
-	add_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	while (pegasus->flags & ETH_REGS_CHANGED)
-		schedule();
-	remove_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_RUNNING);
-
-	pegasus->dr.bRequestType = PEGASUS_REQT_READ;
-	pegasus->dr.bRequest = PEGASUS_REQ_GET_REGS;
-	pegasus->dr.wValue = cpu_to_le16(0);
-	pegasus->dr.wIndex = cpu_to_le16(indx);
-	pegasus->dr.wLength = cpu_to_le16(size);
-	pegasus->ctrl_urb->transfer_buffer_length = size;
-
-	usb_fill_control_urb(pegasus->ctrl_urb, pegasus->usb,
-			     usb_rcvctrlpipe(pegasus->usb, 0),
-			     (char *) &pegasus->dr,
-			     buffer, size, ctrl_callback, pegasus);
-
-	add_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-
-	/* using ATOMIC, we'd never wake up if we slept */
-	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
-		set_current_state(TASK_RUNNING);
-		if (ret == -ENODEV)
-			netif_device_detach(pegasus->net);
-		if (net_ratelimit())
-			netif_err(pegasus, drv, pegasus->net,
-				  "%s, status %d\n", __func__, ret);
-		goto out;
-	}
-
-	schedule();
-out:
-	remove_wait_queue(&pegasus->ctrl_wait, &wait);
-	memcpy(data, buffer, size);
-	kfree(buffer);
 
+	ret = usb_control_msg(pegasus->usb, usb_rcvctrlpipe(pegasus->usb, 0),
+			      PEGASUS_REQ_GET_REGS, PEGASUS_REQT_READ, 0,
+			      indx, data, size, 1000);
+	if (ret < 0)
+		netif_dbg(pegasus, drv, pegasus->net,
+			  "%s returned %d\n", __func__, ret);
 	return ret;
 }
 
-static int set_registers(pegasus_t *pegasus, __u16 indx, __u16 size,
-			 void *data)
+static int set_registers(pegasus_t *pegasus, __u16 indx, __u16 size, void *data)
 {
 	int ret;
-	char *buffer;
-	DECLARE_WAITQUEUE(wait, current);
-
-	buffer = kmemdup(data, size, GFP_KERNEL);
-	if (!buffer) {
-		netif_warn(pegasus, drv, pegasus->net,
-			   "out of memory in %s\n", __func__);
-		return -ENOMEM;
-	}
-
-	add_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	while (pegasus->flags & ETH_REGS_CHANGED)
-		schedule();
-	remove_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_RUNNING);
-
-	pegasus->dr.bRequestType = PEGASUS_REQT_WRITE;
-	pegasus->dr.bRequest = PEGASUS_REQ_SET_REGS;
-	pegasus->dr.wValue = cpu_to_le16(0);
-	pegasus->dr.wIndex = cpu_to_le16(indx);
-	pegasus->dr.wLength = cpu_to_le16(size);
-	pegasus->ctrl_urb->transfer_buffer_length = size;
-
-	usb_fill_control_urb(pegasus->ctrl_urb, pegasus->usb,
-			     usb_sndctrlpipe(pegasus->usb, 0),
-			     (char *) &pegasus->dr,
-			     buffer, size, ctrl_callback, pegasus);
-
-	add_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-
-	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
-		if (ret == -ENODEV)
-			netif_device_detach(pegasus->net);
-		netif_err(pegasus, drv, pegasus->net,
-			  "%s, status %d\n", __func__, ret);
-		goto out;
-	}
-
-	schedule();
-out:
-	remove_wait_queue(&pegasus->ctrl_wait, &wait);
-	kfree(buffer);
 
+	ret = usb_control_msg(pegasus->usb, usb_sndctrlpipe(pegasus->usb, 0),
+			      PEGASUS_REQ_SET_REGS, PEGASUS_REQT_WRITE, 0,
+			      indx, data, size, 100);
+	if (ret < 0)
+		netif_dbg(pegasus, drv, pegasus->net,
+			  "%s returned %d\n", __func__, ret);
 	return ret;
 }
 
 static int set_register(pegasus_t *pegasus, __u16 indx, __u8 data)
 {
 	int ret;
-	char *tmp;
-	DECLARE_WAITQUEUE(wait, current);
-
-	tmp = kmemdup(&data, 1, GFP_KERNEL);
-	if (!tmp) {
-		netif_warn(pegasus, drv, pegasus->net,
-			   "out of memory in %s\n", __func__);
-		return -ENOMEM;
-	}
-	add_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	while (pegasus->flags & ETH_REGS_CHANGED)
-		schedule();
-	remove_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_RUNNING);
-
-	pegasus->dr.bRequestType = PEGASUS_REQT_WRITE;
-	pegasus->dr.bRequest = PEGASUS_REQ_SET_REG;
-	pegasus->dr.wValue = cpu_to_le16(data);
-	pegasus->dr.wIndex = cpu_to_le16(indx);
-	pegasus->dr.wLength = cpu_to_le16(1);
-	pegasus->ctrl_urb->transfer_buffer_length = 1;
-
-	usb_fill_control_urb(pegasus->ctrl_urb, pegasus->usb,
-			     usb_sndctrlpipe(pegasus->usb, 0),
-			     (char *) &pegasus->dr,
-			     tmp, 1, ctrl_callback, pegasus);
-
-	add_wait_queue(&pegasus->ctrl_wait, &wait);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-
-	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
-		if (ret == -ENODEV)
-			netif_device_detach(pegasus->net);
-		if (net_ratelimit())
-			netif_err(pegasus, drv, pegasus->net,
-				  "%s, status %d\n", __func__, ret);
-		goto out;
-	}
-
-	schedule();
-out:
-	remove_wait_queue(&pegasus->ctrl_wait, &wait);
-	kfree(tmp);
 
+	ret = usb_control_msg(pegasus->usb, usb_sndctrlpipe(pegasus->usb, 0),
+			      PEGASUS_REQ_SET_REG, PEGASUS_REQT_WRITE, data,
+			      indx, &data, 1, 1000);
+	if (ret < 0)
+		netif_dbg(pegasus, drv, pegasus->net,
+			  "%s returned %d\n", __func__, ret);
 	return ret;
 }
 
 static int update_eth_regs_async(pegasus_t *pegasus)
 {
-	int ret;
-
-	pegasus->dr.bRequestType = PEGASUS_REQT_WRITE;
-	pegasus->dr.bRequest = PEGASUS_REQ_SET_REGS;
-	pegasus->dr.wValue = cpu_to_le16(0);
-	pegasus->dr.wIndex = cpu_to_le16(EthCtrl0);
-	pegasus->dr.wLength = cpu_to_le16(3);
-	pegasus->ctrl_urb->transfer_buffer_length = 3;
-
-	usb_fill_control_urb(pegasus->ctrl_urb, pegasus->usb,
-			     usb_sndctrlpipe(pegasus->usb, 0),
-			     (char *) &pegasus->dr,
-			     pegasus->eth_regs, 3, ctrl_callback, pegasus);
-
-	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
+	int ret = -ENOMEM;
+	struct urb *async_urb;
+	struct usb_ctrlrequest *req;
+
+	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
+	if (req == NULL)
+		return ret;
+	async_urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (async_urb == NULL) {
+		kfree(req);
+		return ret;
+	}
+	req->bRequestType = PEGASUS_REQT_WRITE;
+	req->bRequest = PEGASUS_REQ_SET_REGS;
+	req->wValue = cpu_to_le16(0);
+	req->wIndex = cpu_to_le16(EthCtrl0);
+	req->wLength = cpu_to_le16(3);
+
+	usb_fill_control_urb(async_urb, pegasus->usb,
+			     usb_sndctrlpipe(pegasus->usb, 0), (void *)req,
+			     pegasus->eth_regs, 3, async_ctrl_callback, req);
+
+	ret = usb_submit_urb(async_urb, GFP_ATOMIC);
+	if (ret) {
 		if (ret == -ENODEV)
 			netif_device_detach(pegasus->net);
 		netif_err(pegasus, drv, pegasus->net,
-			  "%s, status %d\n", __func__, ret);
+			  "%s returned %d\n", __func__, ret);
 	}
-
 	return ret;
 }
 
-/* Returns 0 on success, error on failure */
-static int read_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
+static int __mii_op(pegasus_t *p, __u8 phy, __u8 indx, __u16 *regd, __u8 cmd)
 {
 	int i;
 	__u8 data[4] = { phy, 0, 0, indx };
 	__le16 regdi;
-	int ret;
+	int ret = -ETIMEDOUT;
 
-	set_register(pegasus, PhyCtrl, 0);
-	set_registers(pegasus, PhyAddr, sizeof(data), data);
-	set_register(pegasus, PhyCtrl, (indx | PHY_READ));
+	if (cmd & PHY_WRITE) {
+		__le16 *t = (__le16 *)&data[1];
+		*t = cpu_to_le16(*regd);
+	}
+	set_register(p, PhyCtrl, 0);
+	set_registers(p, PhyAddr, sizeof(data), data);
+	set_register(p, PhyCtrl, (indx | cmd));
 	for (i = 0; i < REG_TIMEOUT; i++) {
-		ret = get_registers(pegasus, PhyCtrl, 1, data);
-		if (ret == -ESHUTDOWN)
+		ret = get_registers(p, PhyCtrl, 1, data);
+		if (ret < 0)
 			goto fail;
 		if (data[0] & PHY_DONE)
 			break;
 	}
-
 	if (i >= REG_TIMEOUT)
 		goto fail;
-
-	ret = get_registers(pegasus, PhyData, 2, &regdi);
-	*regd = le16_to_cpu(regdi);
+	if (cmd & PHY_READ) {
+		ret = get_registers(p, PhyData, 2, &regdi);
+		*regd = le16_to_cpu(regdi);
+		return ret;
+	}
+	return 0;
+fail:
+	netif_dbg(p, drv, p->net, "%s failed\n", __func__);
 	return ret;
+}
 
-fail:
-	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
+/* Returns non-negative int on success, error on failure */
+static int read_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
+{
+	return __mii_op(pegasus, phy, indx, regd, PHY_READ);
+}
 
-	return ret;
+/* Returns zero on success, error on failure */
+static int write_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
+{
+	return __mii_op(pegasus, phy, indx, regd, PHY_WRITE);
 }
 
 static int mdio_read(struct net_device *dev, int phy_id, int loc)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
-	u16 res;
+	__u16 res;
 
 	read_mii_word(pegasus, phy_id, loc, &res);
 	return (int)res;
 }
 
-static int write_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 regd)
-{
-	int i;
-	__u8 data[4] = { phy, 0, 0, indx };
-	int ret;
-
-	data[1] = (u8) regd;
-	data[2] = (u8) (regd >> 8);
-	set_register(pegasus, PhyCtrl, 0);
-	set_registers(pegasus, PhyAddr, sizeof(data), data);
-	set_register(pegasus, PhyCtrl, (indx | PHY_WRITE));
-	for (i = 0; i < REG_TIMEOUT; i++) {
-		ret = get_registers(pegasus, PhyCtrl, 1, data);
-		if (ret == -ESHUTDOWN)
-			goto fail;
-		if (data[0] & PHY_DONE)
-			break;
-	}
-
-	if (i >= REG_TIMEOUT)
-		goto fail;
-
-	return ret;
-
-fail:
-	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
-	return -ETIMEDOUT;
-}
-
 static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
 
-	write_mii_word(pegasus, phy_id, loc, val);
+	write_mii_word(pegasus, phy_id, loc, (__u16 *)&val);
 }
 
 static int read_eprom_word(pegasus_t *pegasus, __u8 index, __u16 *retdata)
@@ -420,11 +277,9 @@ static int read_eprom_word(pegasus_t *pegasus, __u8 index, __u16 *retdata)
 	}
 	if (i >= REG_TIMEOUT)
 		goto fail;
-
 	ret = get_registers(pegasus, EpromData, 2, &retdatai);
 	*retdata = le16_to_cpu(retdatai);
 	return ret;
-
 fail:
 	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
 	return -ETIMEDOUT;
@@ -473,14 +328,12 @@ static int write_eprom_word(pegasus_t *pegasus, __u8 index, __u16 data)
 	disable_eprom_write(pegasus);
 	if (i >= REG_TIMEOUT)
 		goto fail;
-
 	return ret;
-
 fail:
 	netif_warn(pegasus, drv, pegasus->net, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
-#endif				/* PEGASUS_WRITE_EEPROM */
+#endif /* PEGASUS_WRITE_EEPROM */
 
 static inline void get_node_id(pegasus_t *pegasus, __u8 *id)
 {
@@ -528,7 +381,6 @@ static inline int reset_mac(pegasus_t *pegasus)
 	}
 	if (i == REG_TIMEOUT)
 		return -ETIMEDOUT;
-
 	if (usb_dev_id[pegasus->dev_index].vendor == VENDOR_LINKSYS ||
 	    usb_dev_id[pegasus->dev_index].vendor == VENDOR_DLINK) {
 		set_register(pegasus, Gpio0, 0x24);
@@ -537,18 +389,17 @@ static inline int reset_mac(pegasus_t *pegasus)
 	if (usb_dev_id[pegasus->dev_index].vendor == VENDOR_ELCON) {
 		__u16 auxmode;
 		read_mii_word(pegasus, 3, 0x1b, &auxmode);
-		write_mii_word(pegasus, 3, 0x1b, auxmode | 4);
+		auxmode |= 4;
+		write_mii_word(pegasus, 3, 0x1b, &auxmode);
 	}
-
 	return 0;
 }
 
-static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
+static void enable_net_traffic(struct net_device *dev, struct usb_device *usb)
 {
 	__u16 linkpart;
 	__u8 data[4];
 	pegasus_t *pegasus = netdev_priv(dev);
-	int ret;
 
 	read_mii_word(pegasus, pegasus->phy, MII_LPA, &linkpart);
 	data[0] = 0xc9;
@@ -562,64 +413,18 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
 	data[2] = loopback ? 0x09 : 0x01;
 
 	memcpy(pegasus->eth_regs, data, sizeof(data));
-	ret = set_registers(pegasus, EthCtrl0, 3, data);
+	set_registers(pegasus, EthCtrl0, 3, data);
 
 	if (usb_dev_id[pegasus->dev_index].vendor == VENDOR_LINKSYS ||
 	    usb_dev_id[pegasus->dev_index].vendor == VENDOR_LINKSYS2 ||
 	    usb_dev_id[pegasus->dev_index].vendor == VENDOR_DLINK) {
-		u16 auxmode;
+		__u16 auxmode;
 		read_mii_word(pegasus, 0, 0x1b, &auxmode);
-		write_mii_word(pegasus, 0, 0x1b, auxmode | 4);
-	}
-
-	return ret;
-}
-
-static void fill_skb_pool(pegasus_t *pegasus)
-{
-	int i;
-
-	for (i = 0; i < RX_SKBS; i++) {
-		if (pegasus->rx_pool[i])
-			continue;
-		pegasus->rx_pool[i] = dev_alloc_skb(PEGASUS_MTU + 2);
-		/*
-		 ** we give up if the allocation fail. the tasklet will be
-		 ** rescheduled again anyway...
-		 */
-		if (pegasus->rx_pool[i] == NULL)
-			return;
-		skb_reserve(pegasus->rx_pool[i], 2);
-	}
-}
-
-static void free_skb_pool(pegasus_t *pegasus)
-{
-	int i;
-
-	for (i = 0; i < RX_SKBS; i++) {
-		if (pegasus->rx_pool[i]) {
-			dev_kfree_skb(pegasus->rx_pool[i]);
-			pegasus->rx_pool[i] = NULL;
-		}
+		auxmode |= 4;
+		write_mii_word(pegasus, 0, 0x1b, &auxmode);
 	}
 }
 
-static inline struct sk_buff *pull_skb(pegasus_t * pegasus)
-{
-	int i;
-	struct sk_buff *skb;
-
-	for (i = 0; i < RX_SKBS; i++) {
-		if (likely(pegasus->rx_pool[i] != NULL)) {
-			skb = pegasus->rx_pool[i];
-			pegasus->rx_pool[i] = NULL;
-			return skb;
-		}
-	}
-	return NULL;
-}
-
 static void read_bulk_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
@@ -643,7 +448,7 @@ static void read_bulk_callback(struct urb *urb)
 		netif_dbg(pegasus, rx_err, net, "reset MAC\n");
 		pegasus->flags &= ~PEGASUS_RX_BUSY;
 		break;
-	case -EPIPE:		/* stall, or disconnect from TT */
+	case -EPIPE:	/* stall, or disconnect from TT */
 		/* FIXME schedule work to clear the halt */
 		netif_warn(pegasus, rx_err, net, "no rx stall recovery\n");
 		return;
@@ -665,11 +470,11 @@ static void read_bulk_callback(struct urb *urb)
 		netif_dbg(pegasus, rx_err, net,
 			  "RX packet error %x\n", rx_status);
 		pegasus->stats.rx_errors++;
-		if (rx_status & 0x06)	/* long or runt	*/
+		if (rx_status & 0x06)	/* long or runt */
 			pegasus->stats.rx_length_errors++;
 		if (rx_status & 0x08)
 			pegasus->stats.rx_crc_errors++;
-		if (rx_status & 0x10)	/* extra bits	*/
+		if (rx_status & 0x10)	/* extra bits */
 			pegasus->stats.rx_frame_errors++;
 		goto goon;
 	}
@@ -683,14 +488,12 @@ static void read_bulk_callback(struct urb *urb)
 		pkt_len &= 0xfff;
 		pkt_len -= 8;
 	}
-
 	/*
 	 * If the packet is unreasonably long, quietly drop it rather than
 	 * kernel panicing by calling skb_put.
 	 */
 	if (pkt_len > PEGASUS_MTU)
 		goto goon;
-
 	/*
 	 * at this point we are sure pegasus->rx_skb != NULL
 	 * so we go ahead and pass up the packet.
@@ -704,10 +507,8 @@ static void read_bulk_callback(struct urb *urb)
 	if (pegasus->flags & PEGASUS_UNPLUG)
 		return;
 
-	spin_lock(&pegasus->rx_pool_lock);
-	pegasus->rx_skb = pull_skb(pegasus);
-	spin_unlock(&pegasus->rx_pool_lock);
-
+	pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net,
+						      PEGASUS_MTU, GFP_ATOMIC);
 	if (pegasus->rx_skb == NULL)
 		goto tl_sched;
 goon:
@@ -724,9 +525,7 @@ goon:
 	} else {
 		pegasus->flags &= ~PEGASUS_RX_URB_FAIL;
 	}
-
 	return;
-
 tl_sched:
 	tasklet_schedule(&pegasus->rx_tl);
 }
@@ -734,24 +533,22 @@ tl_sched:
 static void rx_fixup(unsigned long data)
 {
 	pegasus_t *pegasus;
-	unsigned long flags;
 	int status;
 
 	pegasus = (pegasus_t *) data;
 	if (pegasus->flags & PEGASUS_UNPLUG)
 		return;
-
-	spin_lock_irqsave(&pegasus->rx_pool_lock, flags);
-	fill_skb_pool(pegasus);
 	if (pegasus->flags & PEGASUS_RX_URB_FAIL)
 		if (pegasus->rx_skb)
 			goto try_again;
 	if (pegasus->rx_skb == NULL)
-		pegasus->rx_skb = pull_skb(pegasus);
+		pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net,
+							      PEGASUS_MTU,
+							      GFP_ATOMIC);
 	if (pegasus->rx_skb == NULL) {
 		netif_warn(pegasus, rx_err, pegasus->net, "low on memory\n");
 		tasklet_schedule(&pegasus->rx_tl);
-		goto done;
+		return;
 	}
 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
 			  usb_rcvbulkpipe(pegasus->usb, 1),
@@ -767,8 +564,6 @@ try_again:
 	} else {
 		pegasus->flags &= ~PEGASUS_RX_URB_FAIL;
 	}
-done:
-	spin_unlock_irqrestore(&pegasus->rx_pool_lock, flags);
 }
 
 static void write_bulk_callback(struct urb *urb)
@@ -779,12 +574,9 @@ static void write_bulk_callback(struct urb *urb)
 
 	if (!pegasus)
 		return;
-
 	net = pegasus->net;
-
 	if (!netif_device_present(net) || !netif_running(net))
 		return;
-
 	switch (status) {
 	case -EPIPE:
 		/* FIXME schedule_work() to clear the tx halt */
@@ -802,8 +594,7 @@ static void write_bulk_callback(struct urb *urb)
 	case 0:
 		break;
 	}
-
-	net->trans_start = jiffies; /* prevent tx timeout */
+	net->trans_start = jiffies;	/* prevent tx timeout */
 	netif_wake_queue(net);
 }
 
@@ -816,7 +607,6 @@ static void intr_callback(struct urb *urb)
 	if (!pegasus)
 		return;
 	net = pegasus->net;
-
 	switch (status) {
 	case 0:
 		break;
@@ -830,13 +620,12 @@ static void intr_callback(struct urb *urb)
 		 */
 		netif_dbg(pegasus, timer, net, "intr status %d\n", status);
 	}
-
 	if (urb->actual_length >= 6) {
 		u8 *d = urb->transfer_buffer;
 
 		/* byte 0 == tx_status1, reg 2B */
-		if (d[0] & (TX_UNDERRUN|EXCESSIVE_COL
-					|LATE_COL|JABBER_TIMEOUT)) {
+		if (d[0] & (TX_UNDERRUN | EXCESSIVE_COL
+			    | LATE_COL | JABBER_TIMEOUT)) {
 			pegasus->stats.tx_errors++;
 			if (d[0] & TX_UNDERRUN)
 				pegasus->stats.tx_fifo_errors++;
@@ -854,7 +643,6 @@ static void intr_callback(struct urb *urb)
 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
 	}
-
 	res = usb_submit_urb(urb, GFP_ATOMIC);
 	if (res == -ENODEV)
 		netif_device_detach(pegasus->net);
@@ -871,8 +659,7 @@ static void pegasus_tx_timeout(struct net_device *net)
 	pegasus->stats.tx_errors++;
 }
 
-static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
-					    struct net_device *net)
+static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	pegasus_t *pegasus = netdev_priv(net);
 	int count = ((skb->len + 2) & 0x3f) ? skb->len + 2 : skb->len + 3;
@@ -890,10 +677,10 @@ static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
 	if ((res = usb_submit_urb(pegasus->tx_urb, GFP_ATOMIC))) {
 		netif_warn(pegasus, tx_err, net, "fail tx, %d\n", res);
 		switch (res) {
-		case -EPIPE:		/* stall, or disconnect from TT */
+		case -EPIPE:	/* stall, or disconnect from TT */
 			/* cleanup should already have been scheduled */
 			break;
-		case -ENODEV:		/* disconnect() upcoming */
+		case -ENODEV:	/* disconnect() upcoming */
 		case -EPERM:
 			netif_device_detach(pegasus->net);
 			break;
@@ -935,7 +722,7 @@ static inline void get_interrupt_interval(pegasus_t *pegasus)
 				   "intr interval changed from %ums to %ums\n",
 				   interval, 0x80);
 			interval = 0x80;
-			data = (data & 0x00FF) | ((u16)interval << 8);
+			data = (data & 0x00FF) | ((u16) interval << 8);
 #ifdef PEGASUS_WRITE_EEPROM
 			write_eprom_word(pegasus, 4, data);
 #endif
@@ -951,7 +738,6 @@ static void set_carrier(struct net_device *net)
 
 	if (read_mii_word(pegasus, pegasus->phy, MII_BMSR, &tmp))
 		return;
-
 	if (tmp & BMSR_LSTATUS)
 		netif_carrier_on(net);
 	else
@@ -963,7 +749,6 @@ static void free_all_urbs(pegasus_t *pegasus)
 	usb_free_urb(pegasus->intr_urb);
 	usb_free_urb(pegasus->tx_urb);
 	usb_free_urb(pegasus->rx_urb);
-	usb_free_urb(pegasus->ctrl_urb);
 }
 
 static void unlink_all_urbs(pegasus_t *pegasus)
@@ -971,51 +756,40 @@ static void unlink_all_urbs(pegasus_t *pegasus)
 	usb_kill_urb(pegasus->intr_urb);
 	usb_kill_urb(pegasus->tx_urb);
 	usb_kill_urb(pegasus->rx_urb);
-	usb_kill_urb(pegasus->ctrl_urb);
 }
 
 static int alloc_urbs(pegasus_t *pegasus)
 {
-	pegasus->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!pegasus->ctrl_urb)
-		return 0;
 	pegasus->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!pegasus->rx_urb) {
-		usb_free_urb(pegasus->ctrl_urb);
 		return 0;
 	}
 	pegasus->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!pegasus->tx_urb) {
 		usb_free_urb(pegasus->rx_urb);
-		usb_free_urb(pegasus->ctrl_urb);
 		return 0;
 	}
 	pegasus->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!pegasus->intr_urb) {
 		usb_free_urb(pegasus->tx_urb);
 		usb_free_urb(pegasus->rx_urb);
-		usb_free_urb(pegasus->ctrl_urb);
 		return 0;
 	}
-
 	return 1;
 }
 
 static int pegasus_open(struct net_device *net)
 {
 	pegasus_t *pegasus = netdev_priv(net);
-	int res;
+	int res = -ENOMEM;
 
 	if (pegasus->rx_skb == NULL)
-		pegasus->rx_skb = pull_skb(pegasus);
-	/*
-	 ** Note: no point to free the pool.  it is empty :-)
-	 */
+		pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net,
+							      PEGASUS_MTU,
+							      GFP_KERNEL);
 	if (!pegasus->rx_skb)
-		return -ENOMEM;
-
+		goto exit;
 	res = set_registers(pegasus, EthID, 6, net->dev_addr);
-
 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
 			  usb_rcvbulkpipe(pegasus->usb, 1),
 			  pegasus->rx_skb->data, PEGASUS_MTU + 8,
@@ -1026,7 +800,6 @@ static int pegasus_open(struct net_device *net)
 		netif_dbg(pegasus, ifup, net, "failed rx_urb, %d\n", res);
 		goto exit;
 	}
-
 	usb_fill_int_urb(pegasus->intr_urb, pegasus->usb,
 			 usb_rcvintpipe(pegasus->usb, 3),
 			 pegasus->intr_buff, sizeof(pegasus->intr_buff),
@@ -1038,18 +811,9 @@ static int pegasus_open(struct net_device *net)
 		usb_kill_urb(pegasus->rx_urb);
 		goto exit;
 	}
-	if ((res = enable_net_traffic(net, pegasus->usb))) {
-		netif_dbg(pegasus, ifup, net,
-			  "can't enable_net_traffic() - %d\n", res);
-		res = -EIO;
-		usb_kill_urb(pegasus->rx_urb);
-		usb_kill_urb(pegasus->intr_urb);
-		free_skb_pool(pegasus);
-		goto exit;
-	}
+	enable_net_traffic(net, pegasus->usb);
 	set_carrier(net);
 	netif_start_queue(net);
-	netif_dbg(pegasus, ifup, net, "open\n");
 	res = 0;
 exit:
 	return res;
@@ -1081,25 +845,22 @@ static void pegasus_get_drvinfo(struct net_device *dev,
 /* also handles three patterns of some kind in hardware */
 #define	WOL_SUPPORTED	(WAKE_MAGIC|WAKE_PHY)
 
-static void
-pegasus_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+static void pegasus_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	pegasus_t	*pegasus = netdev_priv(dev);
+	pegasus_t *pegasus = netdev_priv(dev);
 
 	wol->supported = WAKE_MAGIC | WAKE_PHY;
 	wol->wolopts = pegasus->wolopts;
 }
 
-static int
-pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+static int pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	pegasus_t	*pegasus = netdev_priv(dev);
-	u8		reg78 = 0x04;
-	int		ret;
+	pegasus_t *pegasus = netdev_priv(dev);
+	u8 reg78 = 0x04;
+	int r;
 
 	if (wol->wolopts & ~WOL_SUPPORTED)
 		return -EINVAL;
-
 	if (wol->wolopts & WAKE_MAGIC)
 		reg78 |= 0x80;
 	if (wol->wolopts & WAKE_PHY)
@@ -1111,11 +872,10 @@ pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		pegasus->eth_regs[0] &= ~0x10;
 	pegasus->wolopts = wol->wolopts;
 
-	ret = set_register(pegasus, WakeupControl, reg78);
-	if (!ret)
-		ret = device_set_wakeup_enable(&pegasus->usb->dev,
-						wol->wolopts);
-	return ret;
+	r = set_register(pegasus, WakeupControl, reg78);
+	if (!r)
+		r = device_set_wakeup_enable(&pegasus->usb->dev, wol->wolopts);
+	return r;
 }
 
 static inline void pegasus_reset_wol(struct net_device *dev)
@@ -1123,7 +883,7 @@ static inline void pegasus_reset_wol(struct net_device *dev)
 	struct ethtool_wolinfo wol;
 
 	memset(&wol, 0, sizeof wol);
-	(void) pegasus_set_wol(dev, &wol);
+	(void)pegasus_set_wol(dev, &wol);
 }
 
 static int
@@ -1133,6 +893,7 @@ pegasus_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 	pegasus = netdev_priv(dev);
 	mii_ethtool_gset(&pegasus->mii, ecmd);
+
 	return 0;
 }
 
@@ -1140,30 +901,35 @@ static int
 pegasus_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
+
 	return mii_ethtool_sset(&pegasus->mii, ecmd);
 }
 
 static int pegasus_nway_reset(struct net_device *dev)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
+
 	return mii_nway_restart(&pegasus->mii);
 }
 
 static u32 pegasus_get_link(struct net_device *dev)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
+
 	return mii_link_ok(&pegasus->mii);
 }
 
 static u32 pegasus_get_msglevel(struct net_device *dev)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
+
 	return pegasus->msg_enable;
 }
 
 static void pegasus_set_msglevel(struct net_device *dev, u32 v)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
+
 	pegasus->msg_enable = v;
 }
 
@@ -1181,7 +947,7 @@ static const struct ethtool_ops ops = {
 
 static int pegasus_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 {
-	__u16 *data = (__u16 *) &rq->ifr_ifru;
+	__u16 *data = (__u16 *)&rq->ifr_ifru;
 	pegasus_t *pegasus = netdev_priv(net);
 	int res;
 
@@ -1195,7 +961,7 @@ static int pegasus_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 	case SIOCDEVPRIVATE + 2:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		write_mii_word(pegasus, pegasus->phy, data[1] & 0x1f, data[2]);
+		write_mii_word(pegasus, pegasus->phy, data[1] & 0x1f, &data[2]);
 		res = 0;
 		break;
 	default:
@@ -1218,12 +984,9 @@ static void pegasus_set_multicast(struct net_device *net)
 	} else {
 		pegasus->eth_regs[EthCtrl0] &= ~RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
+		netif_dbg(pegasus, link, net, "general mode\n");
 	}
-
-	pegasus->ctrl_urb->status = 0;
-
-	pegasus->flags |= ETH_REGS_CHANGE;
-	ctrl_callback(pegasus->ctrl_urb);
+	update_eth_regs_async(pegasus);
 }
 
 static __u8 mii_phy_probe(pegasus_t *pegasus)
@@ -1238,7 +1001,6 @@ static __u8 mii_phy_probe(pegasus_t *pegasus)
 		else
 			return i;
 	}
-
 	return 0xff;
 }
 
@@ -1253,26 +1015,21 @@ static inline void setup_pegasus_II(pegasus_t *pegasus)
 		set_register(pegasus, Reg7b, 0);
 	else
 		set_register(pegasus, Reg7b, 2);
-
 	set_register(pegasus, 0x83, data);
 	get_registers(pegasus, 0x83, 1, &data);
-
 	if (data == 0xa5)
 		pegasus->chip = 0x8513;
 	else
 		pegasus->chip = 0;
-
 	set_register(pegasus, 0x80, 0xc0);
 	set_register(pegasus, 0x83, 0xff);
 	set_register(pegasus, 0x84, 0x01);
-
 	if (pegasus->features & HAS_HOME_PNA && mii_mode)
 		set_register(pegasus, Reg81, 6);
 	else
 		set_register(pegasus, Reg81, 2);
 }
 
-
 static int pegasus_count;
 static struct workqueue_struct *pegasus_workqueue;
 #define CARRIER_CHECK_DELAY (2 * HZ)
@@ -1281,10 +1038,9 @@ static void check_carrier(struct work_struct *work)
 {
 	pegasus_t *pegasus = container_of(work, pegasus_t, carrier_check.work);
 	set_carrier(pegasus->net);
-	if (!(pegasus->flags & PEGASUS_UNPLUG)) {
+	if (!(pegasus->flags & PEGASUS_UNPLUG))
 		queue_delayed_work(pegasus_workqueue, &pegasus->carrier_check,
-			CARRIER_CHECK_DELAY);
-	}
+				   CARRIER_CHECK_DELAY);
 }
 
 static int pegasus_blacklisted(struct usb_device *udev)
@@ -1299,11 +1055,11 @@ static int pegasus_blacklisted(struct usb_device *udev)
 	    (udd->bDeviceClass == USB_CLASS_WIRELESS_CONTROLLER) &&
 	    (udd->bDeviceProtocol == 1))
 		return 1;
-
 	return 0;
 }
 
-/* we rely on probe() and remove() being serialized so we
+/*
+ * we rely on probe() and remove() being serialized so we
  * don't need extra locking on pegasus_count.
  */
 static void pegasus_dec_workqueue(void)
@@ -1340,14 +1096,13 @@ static int pegasus_probe(struct usb_interface *intf,
 
 	pegasus = netdev_priv(net);
 	pegasus->dev_index = dev_index;
-	init_waitqueue_head(&pegasus->ctrl_wait);
 
 	if (!alloc_urbs(pegasus)) {
 		dev_err(&intf->dev, "can't allocate %s\n", "urbs");
 		goto out1;
 	}
 
-	tasklet_init(&pegasus->rx_tl, rx_fixup, (unsigned long) pegasus);
+	tasklet_init(&pegasus->rx_tl, rx_fixup, (unsigned long)pegasus);
 
 	INIT_DELAYED_WORK(&pegasus->carrier_check, check_carrier);
 
@@ -1355,7 +1110,6 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->usb = dev;
 	pegasus->net = net;
 
-
 	net->watchdog_timeo = PEGASUS_TX_TIMEOUT;
 	net->netdev_ops = &pegasus_netdev_ops;
 	SET_ETHTOOL_OPS(net, &ops);
@@ -1364,9 +1118,9 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->mii.mdio_write = mdio_write;
 	pegasus->mii.phy_id_mask = 0x1f;
 	pegasus->mii.reg_num_mask = 0x1f;
-	spin_lock_init(&pegasus->rx_pool_lock);
 	pegasus->msg_enable = netif_msg_init(msg_level, NETIF_MSG_DRV
-				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
+					     | NETIF_MSG_PROBE
+					     | NETIF_MSG_LINK);
 
 	pegasus->features = usb_dev_id[dev_index].private;
 	get_interrupt_interval(pegasus);
@@ -1376,7 +1130,6 @@ static int pegasus_probe(struct usb_interface *intf,
 		goto out2;
 	}
 	set_ethernet_addr(pegasus);
-	fill_skb_pool(pegasus);
 	if (pegasus->features & PEGASUS_II) {
 		dev_info(&intf->dev, "setup Pegasus II specific registers\n");
 		setup_pegasus_II(pegasus);
@@ -1394,17 +1147,12 @@ static int pegasus_probe(struct usb_interface *intf,
 	if (res)
 		goto out3;
 	queue_delayed_work(pegasus_workqueue, &pegasus->carrier_check,
-				CARRIER_CHECK_DELAY);
-
-	dev_info(&intf->dev, "%s, %s, %pM\n",
-		 net->name,
-		 usb_dev_id[dev_index].name,
-		 net->dev_addr);
+			   CARRIER_CHECK_DELAY);
+	dev_info(&intf->dev, "%s, %s: %pM\n", net->name,
+		 usb_dev_id[dev_index].name, net->dev_addr);
 	return 0;
-
 out3:
 	usb_set_intfdata(intf, NULL);
-	free_skb_pool(pegasus);
 out2:
 	free_all_urbs(pegasus);
 out1:
@@ -1429,7 +1177,6 @@ static void pegasus_disconnect(struct usb_interface *intf)
 	unregister_netdev(pegasus->net);
 	unlink_all_urbs(pegasus);
 	free_all_urbs(pegasus);
-	free_skb_pool(pegasus);
 	if (pegasus->rx_skb != NULL) {
 		dev_kfree_skb(pegasus->rx_skb);
 		pegasus->rx_skb = NULL;
@@ -1466,21 +1213,21 @@ static int pegasus_resume(struct usb_interface *intf)
 		intr_callback(pegasus->intr_urb);
 	}
 	queue_delayed_work(pegasus_workqueue, &pegasus->carrier_check,
-				CARRIER_CHECK_DELAY);
+			   CARRIER_CHECK_DELAY);
 	return 0;
 }
 
 static const struct net_device_ops pegasus_netdev_ops = {
-	.ndo_open =			pegasus_open,
-	.ndo_stop =			pegasus_close,
-	.ndo_do_ioctl =			pegasus_ioctl,
-	.ndo_start_xmit =		pegasus_start_xmit,
-	.ndo_set_rx_mode =		pegasus_set_multicast,
-	.ndo_get_stats =		pegasus_netdev_stats,
-	.ndo_tx_timeout =		pegasus_tx_timeout,
-	.ndo_change_mtu =		eth_change_mtu,
-	.ndo_set_mac_address =		eth_mac_addr,
-	.ndo_validate_addr =		eth_validate_addr,
+	.ndo_open = pegasus_open,
+	.ndo_stop = pegasus_close,
+	.ndo_do_ioctl = pegasus_ioctl,
+	.ndo_start_xmit = pegasus_start_xmit,
+	.ndo_set_rx_mode = pegasus_set_multicast,
+	.ndo_get_stats = pegasus_netdev_stats,
+	.ndo_tx_timeout = pegasus_tx_timeout,
+	.ndo_change_mtu = eth_change_mtu,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_validate_addr = eth_validate_addr,
 };
 
 static struct usb_driver pegasus_driver = {
@@ -1500,7 +1247,7 @@ static void __init parse_id(char *id)
 
 	if ((token = strsep(&id, ":")) != NULL)
 		name = token;
-	/* name now points to a null terminated string*/
+	/* name now points to a null terminated string */
 	if ((token = strsep(&id, ":")) != NULL)
 		vendor_id = simple_strtoul(token, NULL, 16);
 	if ((token = strsep(&id, ":")) != NULL)
diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
index 65b78b3..809e560 100644
--- a/drivers/net/usb/pegasus.h
+++ b/drivers/net/usb/pegasus.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 1999-2003 Petko Manolov - Petkan (petkan@users.sourceforge.net)
+ * Copyright (c) 1999-2013 Petko Manolov - Petkan (petkan@nucleusys.com)
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as published
@@ -34,8 +34,6 @@
 #define	CTRL_URB_SLEEP		0x00000020
 #define	PEGASUS_UNPLUG		0x00000040
 #define	PEGASUS_RX_URB_FAIL	0x00000080
-#define	ETH_REGS_CHANGE		0x40000000
-#define	ETH_REGS_CHANGED	0x80000000
 
 #define	RX_MULTICAST		2
 #define	RX_PROMISCUOUS		4
@@ -96,12 +94,8 @@ typedef struct pegasus {
 	int			intr_interval;
 	struct tasklet_struct	rx_tl;
 	struct delayed_work	carrier_check;
-	struct urb		*ctrl_urb, *rx_urb, *tx_urb, *intr_urb;
-	struct sk_buff		*rx_pool[RX_SKBS];
+	struct urb		*rx_urb, *tx_urb, *intr_urb;
 	struct sk_buff		*rx_skb;
-	struct usb_ctrlrequest	dr;
-	wait_queue_head_t	ctrl_wait;
-	spinlock_t		rx_pool_lock;
 	int			chip;
 	unsigned char		intr_buff[8];
 	__u8			tx_buff[PEGASUS_MTU];
