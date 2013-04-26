From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 3/3] drivers: net: usb: pegasus: fix control urb submission
Date: Fri, 26 Apr 2013 09:57:34 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1304260950350.3746@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

Pegasus driver used single callback for sync and async control URBs. 
Special flags were employed to distinguish between both, but due to flawed 
logic it didn't always work.  As a result of this change 
[get|set]_registers() are now much simpler.  Async write is also leaner 
and does not use single, statically allocated memory for usb_ctrlrequest, 
which is another potential race when asynchronously submitting URBs.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
 pegasus.c |  284 +++++++++++++--------------------------------------
 pegasus.h |    4 +-
 2 files changed, 75 insertions(+), 213 deletions(-)

diff --git a/pegasus.c b/pegasus.c
index 5eefb27..2221c40 100644
--- a/pegasus.c
+++ b/pegasus.c
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
+ *		v0.9.3	simplified [get|set]_register(s), async update registers
+ *			logic revisited, receive skb_pool removed.
  */
 
 #include <linux/sched.h>
@@ -45,7 +48,7 @@
 /*
  * Version Information
  */
-#define DRIVER_VERSION "v0.6.14 (2006/09/27)"
+#define DRIVER_VERSION "v0.9.3 (2013/04/25)"
 #define DRIVER_AUTHOR "Petko Manolov <petkan@users.sourceforge.net>"
 #define DRIVER_DESC "Pegasus/Pegasus II USB Ethernet driver"
 
@@ -108,220 +111,90 @@ MODULE_PARM_DESC(msg_level, "Override default message level");
 MODULE_DEVICE_TABLE(usb, pegasus_ids);
 static const struct net_device_ops pegasus_netdev_ops;
 
-static int update_eth_regs_async(pegasus_t *);
-/* Aargh!!! I _really_ hate such tweaks */
-static void ctrl_callback(struct urb *urb)
+/*****/
+
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
-	if (!buffer) {
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
+	int ret = -ENOMEM;
+	struct urb *async_urb;
+	struct usb_ctrlrequest *req;
 
-	usb_fill_control_urb(pegasus->ctrl_urb, pegasus->usb,
-			     usb_sndctrlpipe(pegasus->usb, 0),
-			     (char *) &pegasus->dr,
-			     pegasus->eth_regs, 3, ctrl_callback, pegasus);
+	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
+	if (req == NULL)
+		return ret;
 
-	if ((ret = usb_submit_urb(pegasus->ctrl_urb, GFP_ATOMIC))) {
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
 
@@ -901,7 +774,6 @@ static void free_all_urbs(pegasus_t *pegasus)
 	usb_free_urb(pegasus->intr_urb);
 	usb_free_urb(pegasus->tx_urb);
 	usb_free_urb(pegasus->rx_urb);
-	usb_free_urb(pegasus->ctrl_urb);
 }
 
 static void unlink_all_urbs(pegasus_t *pegasus)
@@ -909,47 +781,42 @@ static void unlink_all_urbs(pegasus_t *pegasus)
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
+	int res = -ENOMEM;
+
 	pegasus->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!pegasus->rx_urb) {
-		usb_free_urb(pegasus->ctrl_urb);
-		return 0;
+		return res;
 	}
 	pegasus->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!pegasus->tx_urb) {
 		usb_free_urb(pegasus->rx_urb);
-		usb_free_urb(pegasus->ctrl_urb);
-		return 0;
+		return res;
 	}
 	pegasus->intr_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!pegasus->intr_urb) {
 		usb_free_urb(pegasus->tx_urb);
 		usb_free_urb(pegasus->rx_urb);
-		usb_free_urb(pegasus->ctrl_urb);
-		return 0;
+		return res;
 	}
 
-	return 1;
+	return 0;
 }
 
 static int pegasus_open(struct net_device *net)
 {
 	pegasus_t *pegasus = netdev_priv(net);
-	int res;
+	int res=-ENOMEM;
 
 	if (pegasus->rx_skb == NULL)
 		pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net,
 							      PEGASUS_MTU,
 							      GFP_KERNEL);
 	if (!pegasus->rx_skb)
-		return -ENOMEM;
+		goto exit;
 
 	res = set_registers(pegasus, EthID, 6, net->dev_addr);
 
@@ -975,7 +842,8 @@ static int pegasus_open(struct net_device *net)
 		usb_kill_urb(pegasus->rx_urb);
 		goto exit;
 	}
-	if ((res = enable_net_traffic(net, pegasus->usb))) {
+	res = enable_net_traffic(net, pegasus->usb);
+	if (res < 0) {
 		netif_dbg(pegasus, ifup, net,
 			  "can't enable_net_traffic() - %d\n", res);
 		res = -EIO;
@@ -1148,11 +1016,7 @@ static void pegasus_set_multicast(struct net_device *net)
 		pegasus->eth_regs[EthCtrl0] &= ~RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 	}
-
-	pegasus->ctrl_urb->status = 0;
-
-	pegasus->flags |= ETH_REGS_CHANGE;
-	ctrl_callback(pegasus->ctrl_urb);
+	update_eth_regs_async(pegasus);
 }
 
 static __u8 mii_phy_probe(pegasus_t *pegasus)
@@ -1271,7 +1135,8 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->dev_index = dev_index;
 	init_waitqueue_head(&pegasus->ctrl_wait);
 
-	if (!alloc_urbs(pegasus)) {
+	res = alloc_urbs(pegasus);
+	if (res < 0) {
 		dev_err(&intf->dev, "can't allocate %s\n", "urbs");
 		goto out1;
 	}
@@ -1321,12 +1186,9 @@ static int pegasus_probe(struct usb_interface *intf,
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
+	dev_info(&intf->dev, "%s, %s, %pM\n", net->name,
+		 usb_dev_id[dev_index].name, net->dev_addr);
 	return 0;
 
 out3:
diff --git a/pegasus.h b/pegasus.h
index 00d44e3..4d835fc 100644
--- a/pegasus.h
+++ b/pegasus.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 1999-2003 Petko Manolov - Petkan (petkan@users.sourceforge.net)
+ * Copyright (c) 1999-2013 Petko Manolov (petkan@nucleusys.com)
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as published
@@ -95,7 +95,7 @@ typedef struct pegasus {
 	int			intr_interval;
 	struct tasklet_struct	rx_tl;
 	struct delayed_work	carrier_check;
-	struct urb		*ctrl_urb, *rx_urb, *tx_urb, *intr_urb;
+	struct urb		*rx_urb, *tx_urb, *intr_urb;
 	struct sk_buff		*rx_skb;
 	struct usb_ctrlrequest	dr;
 	wait_queue_head_t	ctrl_wait;
