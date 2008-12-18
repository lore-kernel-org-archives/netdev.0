From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [patch]prepare usb net drivers for addition of status as a parameter
Date: Thu, 18 Dec 2008 16:29:51 +0100
Message-ID: <200812181629.52574.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

USB is going to switch the signature of the callbacks to
void callback(struct urb *urb, int status)
This patch will ease the transition.

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

Hi Jeff,

we are doing this subsequently to all USB drivers. Please
apply. The patch is a simple search and replace operation.

	Regards
		Oliver

---

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index de57490..e009481 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -246,10 +246,11 @@ out:
 static void asix_async_cmd_callback(struct urb *urb)
 {
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
+	int status = urb->status;
 
-	if (urb->status < 0)
+	if (status < 0)
 		printk(KERN_DEBUG "asix_async_cmd_callback() failed with %d",
-			urb->status);
+			status);
 
 	kfree(req);
 	usb_free_urb(urb);
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 466a89e..cdbbc0e 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -229,14 +229,15 @@ static void catc_rx_done(struct urb *urb)
 	u8 *pkt_start = urb->transfer_buffer;
 	struct sk_buff *skb;
 	int pkt_len, pkt_offset = 0;
+	int status = urb->status;
 
 	if (!catc->is_f5u011) {
 		clear_bit(RX_RUNNING, &catc->flags);
 		pkt_offset = 2;
 	}
 
-	if (urb->status) {
-		dbg("rx_done, status %d, length %d", urb->status, urb->actual_length);
+	if (status) {
+		dbg("rx_done, status %d, length %d", status, urb->actual_length);
 		return;
 	}
 
@@ -275,12 +276,12 @@ static void catc_rx_done(struct urb *urb)
 
 	if (catc->is_f5u011) {
 		if (atomic_read(&catc->recq_sz)) {
-			int status;
+			int state;
 			atomic_dec(&catc->recq_sz);
 			dbg("getting extra packet");
 			urb->dev = catc->usbdev;
-			if ((status = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
-				dbg("submit(rx_urb) status %d", status);
+			if ((state = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
+				dbg("submit(rx_urb) status %d", state);
 			}
 		} else {
 			clear_bit(RX_RUNNING, &catc->flags);
@@ -292,8 +293,9 @@ static void catc_irq_done(struct urb *urb)
 {
 	struct catc *catc = urb->context;
 	u8 *data = urb->transfer_buffer;
-	int status;
+	int status = urb->status;
 	unsigned int hasdata = 0, linksts = LinkNoChange;
+	int res;
 
 	if (!catc->is_f5u011) {
 		hasdata = data[1] & 0x80;
@@ -309,7 +311,7 @@ static void catc_irq_done(struct urb *urb)
 			linksts = LinkBad;
 	}
 
-	switch (urb->status) {
+	switch (status) {
 	case 0:			/* success */
 		break;
 	case -ECONNRESET:	/* unlink */
@@ -318,7 +320,7 @@ static void catc_irq_done(struct urb *urb)
 		return;
 	/* -EPIPE:  should clear the halt */
 	default:		/* error */
-		dbg("irq_done, status %d, data %02x %02x.", urb->status, data[0], data[1]);
+		dbg("irq_done, status %d, data %02x %02x.", status, data[0], data[1]);
 		goto resubmit;
 	}
 
@@ -338,17 +340,17 @@ static void catc_irq_done(struct urb *urb)
 				atomic_inc(&catc->recq_sz);
 		} else {
 			catc->rx_urb->dev = catc->usbdev;
-			if ((status = usb_submit_urb(catc->rx_urb, GFP_ATOMIC)) < 0) {
-				err("submit(rx_urb) status %d", status);
+			if ((res = usb_submit_urb(catc->rx_urb, GFP_ATOMIC)) < 0) {
+				err("submit(rx_urb) status %d", res);
 			}
 		} 
 	}
 resubmit:
-	status = usb_submit_urb (urb, GFP_ATOMIC);
-	if (status)
+	res = usb_submit_urb (urb, GFP_ATOMIC);
+	if (res)
 		err ("can't resubmit intr, %s-%s, status %d",
 				catc->usbdev->bus->bus_name,
-				catc->usbdev->devpath, status);
+				catc->usbdev->devpath, res);
 }
 
 /*
@@ -380,9 +382,9 @@ static void catc_tx_done(struct urb *urb)
 {
 	struct catc *catc = urb->context;
 	unsigned long flags;
-	int r;
+	int r, status = urb->status;
 
-	if (urb->status == -ECONNRESET) {
+	if (status == -ECONNRESET) {
 		dbg("Tx Reset.");
 		urb->status = 0;
 		catc->netdev->trans_start = jiffies;
@@ -392,8 +394,8 @@ static void catc_tx_done(struct urb *urb)
 		return;
 	}
 
-	if (urb->status) {
-		dbg("tx_done, status %d, length %d", urb->status, urb->actual_length);
+	if (status) {
+		dbg("tx_done, status %d, length %d", status, urb->actual_length);
 		return;
 	}
 
@@ -504,9 +506,10 @@ static void catc_ctrl_done(struct urb *urb)
 	struct catc *catc = urb->context;
 	struct ctrl_queue *q;
 	unsigned long flags;
+	int status = urb->status;
 
-	if (urb->status)
-		dbg("ctrl_done, status %d, len %d.", urb->status, urb->actual_length);
+	if (status)
+		dbg("ctrl_done, status %d, len %d.", status, urb->actual_length);
 
 	spin_lock_irqsave(&catc->ctrl_lock, flags);
 
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index db3377d..edd244f 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -123,10 +123,11 @@ static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
 static void dm_write_async_callback(struct urb *urb)
 {
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
+	int status = urb->status;
 
-	if (urb->status < 0)
+	if (status < 0)
 		printk(KERN_DEBUG "dm_write_async_callback() failed with %d\n",
-		       urb->status);
+		       status);
 
 	kfree(req);
 	usb_free_urb(urb);
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index fdbf3be..2ee034f 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -516,8 +516,9 @@ static void int_callback(struct urb *u)
 {
 	struct kaweth_device *kaweth = u->context;
 	int act_state;
+	int status = u->status;
 
-	switch (u->status) {
+	switch (status) {
 	case 0:			/* success */
 		break;
 	case -ECONNRESET:	/* unlink */
@@ -598,6 +599,7 @@ static void kaweth_usb_receive(struct urb *urb)
 {
 	struct kaweth_device *kaweth = urb->context;
 	struct net_device *net = kaweth->net;
+	int status = urb->status;
 
 	int count = urb->actual_length;
 	int count2 = urb->transfer_buffer_length;
@@ -606,7 +608,7 @@ static void kaweth_usb_receive(struct urb *urb)
 
 	struct sk_buff *skb;
 
-	if(unlikely(urb->status == -ECONNRESET || urb->status == -ESHUTDOWN))
+	if(unlikely(status == -ECONNRESET || status == -ESHUTDOWN))
 	/* we are killed - set a flag and wake the disconnect handler */
 	{
 		kaweth->end = 1;
@@ -621,10 +623,10 @@ static void kaweth_usb_receive(struct urb *urb)
 	}
 	spin_unlock(&kaweth->device_lock);
 
-	if(urb->status && urb->status != -EREMOTEIO && count != 1) {
+	if(status && status != -EREMOTEIO && count != 1) {
 		err("%s RX status: %d count: %d packet_len: %d",
                            net->name,
-			   urb->status,
+			   status,
 			   count,
 			   (int)pkt_len);
 		kaweth_resubmit_rx_urb(kaweth, GFP_ATOMIC);
@@ -775,10 +777,11 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
 {
 	struct kaweth_device *kaweth = urb->context;
 	struct sk_buff *skb = kaweth->tx_skb;
+	int status = urb->status;
 
-	if (unlikely(urb->status != 0))
-		if (urb->status != -ENOENT)
-			dbg("%s: TX status %d.", kaweth->net->name, urb->status);
+	if (unlikely(status != 0))
+		if (status != -ENOENT)
+			dbg("%s: TX status %d.", kaweth->net->name, status);
 
 	netif_wake_queue(kaweth->net);
 	dev_kfree_skb_irq(skb);
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index b514350..c6b60d6 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -115,10 +115,11 @@ static int mcs7830_set_reg(struct usbnet *dev, u16 index, u16 size, void *data)
 static void mcs7830_async_cmd_callback(struct urb *urb)
 {
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
+	int status = urb->status;
 
-	if (urb->status < 0)
+	if (status < 0)
 		printk(KERN_DEBUG "%s() failed with %d\n",
-		       __func__, urb->status);
+		       __func__, status);
 
 	kfree(req);
 	usb_free_urb(urb);
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 7914867..c72bb8f 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -99,11 +99,12 @@ static int update_eth_regs_async(pegasus_t *);
 static void ctrl_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
+	int status = urb->status;
 
 	if (!pegasus)
 		return;
 
-	switch (urb->status) {
+	switch (status) {
 	case 0:
 		if (pegasus->flags & ETH_REGS_CHANGE) {
 			pegasus->flags &= ~ETH_REGS_CHANGE;
@@ -119,7 +120,7 @@ static void ctrl_callback(struct urb *urb)
 	default:
 		if (netif_msg_drv(pegasus) && printk_ratelimit())
 			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
-				__func__, urb->status);
+				__func__, status);
 	}
 	pegasus->flags &= ~ETH_REGS_CHANGED;
 	wake_up(&pegasus->ctrl_wait);
@@ -611,6 +612,7 @@ static void read_bulk_callback(struct urb *urb)
 	pegasus_t *pegasus = urb->context;
 	struct net_device *net;
 	int rx_status, count = urb->actual_length;
+	int status = urb->status;
 	u8 *buf = urb->transfer_buffer;
 	__u16 pkt_len;
 
@@ -621,7 +623,7 @@ static void read_bulk_callback(struct urb *urb)
 	if (!netif_device_present(net) || !netif_running(net))
 		return;
 
-	switch (urb->status) {
+	switch (status) {
 	case 0:
 		break;
 	case -ETIME:
@@ -639,11 +641,11 @@ static void read_bulk_callback(struct urb *urb)
 	case -ECONNRESET:
 	case -ESHUTDOWN:
 		if (netif_msg_ifdown(pegasus))
-			pr_debug("%s: rx unlink, %d\n", net->name, urb->status);
+			pr_debug("%s: rx unlink, %d\n", net->name, status);
 		return;
 	default:
 		if (netif_msg_rx_err(pegasus))
-			pr_debug("%s: RX status %d\n", net->name, urb->status);
+			pr_debug("%s: RX status %d\n", net->name, status);
 		goto goon;
 	}
 
@@ -769,6 +771,7 @@ static void write_bulk_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
 	struct net_device *net;
+	int status = urb->status;
 
 	if (!pegasus)
 		return;
@@ -778,7 +781,7 @@ static void write_bulk_callback(struct urb *urb)
 	if (!netif_device_present(net) || !netif_running(net))
 		return;
 
-	switch (urb->status) {
+	switch (status) {
 	case -EPIPE:
 		/* FIXME schedule_work() to clear the tx halt */
 		netif_stop_queue(net);
@@ -790,11 +793,11 @@ static void write_bulk_callback(struct urb *urb)
 	case -ECONNRESET:
 	case -ESHUTDOWN:
 		if (netif_msg_ifdown(pegasus))
-			pr_debug("%s: tx unlink, %d\n", net->name, urb->status);
+			pr_debug("%s: tx unlink, %d\n", net->name, status);
 		return;
 	default:
 		if (netif_msg_tx_err(pegasus))
-			pr_info("%s: TX status %d\n", net->name, urb->status);
+			pr_info("%s: TX status %d\n", net->name, status);
 		/* FALL THROUGH */
 	case 0:
 		break;
@@ -808,13 +811,13 @@ static void intr_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
 	struct net_device *net;
-	int status;
+	int res, status = urb->status;
 
 	if (!pegasus)
 		return;
 	net = pegasus->net;
 
-	switch (urb->status) {
+	switch (status) {
 	case 0:
 		break;
 	case -ECONNRESET:	/* unlink */
@@ -827,7 +830,7 @@ static void intr_callback(struct urb *urb)
 		 */
 		if (netif_msg_timer(pegasus))
 			pr_debug("%s: intr status %d\n", net->name,
-					urb->status);
+					status);
 	}
 
 	if (urb->actual_length >= 6) {
@@ -854,12 +857,12 @@ static void intr_callback(struct urb *urb)
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
 	}
 
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status == -ENODEV)
+	res = usb_submit_urb(urb, GFP_ATOMIC);
+	if (res == -ENODEV)
 		netif_device_detach(pegasus->net);
-	if (status && netif_msg_timer(pegasus))
+	if (res && netif_msg_timer(pegasus))
 		printk(KERN_ERR "%s: can't resubmit interrupt urb, %d\n",
-				net->name, status);
+				net->name, res);
 }
 
 static void pegasus_tx_timeout(struct net_device *net)
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 6133401..d8664bf 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -212,8 +212,9 @@ static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 static void ctrl_callback(struct urb *urb)
 {
 	rtl8150_t *dev;
+	int status = urb->status;
 
-	switch (urb->status) {
+	switch (status) {
 	case 0:
 		break;
 	case -EINPROGRESS:
@@ -221,7 +222,7 @@ static void ctrl_callback(struct urb *urb)
 	case -ENOENT:
 		break;
 	default:
-		dev_warn(&urb->dev->dev, "ctrl urb status %d\n", urb->status);
+		dev_warn(&urb->dev->dev, "ctrl urb status %d\n", status);
 	}
 	dev = urb->context;
 	clear_bit(RX_REG_SET, &dev->flags);
@@ -424,7 +425,8 @@ static void read_bulk_callback(struct urb *urb)
 	struct sk_buff *skb;
 	struct net_device *netdev;
 	u16 rx_stat;
-	int status;
+	int status = urb->status;
+	int result;
 
 	dev = urb->context;
 	if (!dev)
@@ -435,7 +437,7 @@ static void read_bulk_callback(struct urb *urb)
 	if (!netif_device_present(netdev))
 		return;
 
-	switch (urb->status) {
+	switch (status) {
 	case 0:
 		break;
 	case -ENOENT:
@@ -444,7 +446,7 @@ static void read_bulk_callback(struct urb *urb)
 		dev_warn(&urb->dev->dev, "may be reset is needed?..\n");
 		goto goon;
 	default:
-		dev_warn(&urb->dev->dev, "Rx status %d\n", urb->status);
+		dev_warn(&urb->dev->dev, "Rx status %d\n", status);
 		goto goon;
 	}
 
@@ -474,10 +476,10 @@ static void read_bulk_callback(struct urb *urb)
 goon:
 	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
 		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
-	status = usb_submit_urb(dev->rx_urb, GFP_ATOMIC);
-	if (status == -ENODEV)
+	result = usb_submit_urb(dev->rx_urb, GFP_ATOMIC);
+	if (result == -ENODEV)
 		netif_device_detach(dev->netdev);
-	else if (status) {
+	else if (result) {
 		set_bit(RX_URB_FAIL, &dev->flags);
 		goto resched;
 	} else {
@@ -530,6 +532,7 @@ tlsched:
 static void write_bulk_callback(struct urb *urb)
 {
 	rtl8150_t *dev;
+	int status = urb->status;
 
 	dev = urb->context;
 	if (!dev)
@@ -537,9 +540,9 @@ static void write_bulk_callback(struct urb *urb)
 	dev_kfree_skb_irq(dev->tx_skb);
 	if (!netif_device_present(dev->netdev))
 		return;
-	if (urb->status)
+	if (status)
 		dev_info(&urb->dev->dev, "%s: Tx status %d\n",
-			 dev->netdev->name, urb->status);
+			 dev->netdev->name, status);
 	dev->netdev->trans_start = jiffies;
 	netif_wake_queue(dev->netdev);
 }
@@ -548,12 +551,13 @@ static void intr_callback(struct urb *urb)
 {
 	rtl8150_t *dev;
 	__u8 *d;
-	int status;
+	int status = urb->status;
+	int res;
 
 	dev = urb->context;
 	if (!dev)
 		return;
-	switch (urb->status) {
+	switch (status) {
 	case 0:			/* success */
 		break;
 	case -ECONNRESET:	/* unlink */
@@ -563,7 +567,7 @@ static void intr_callback(struct urb *urb)
 	/* -EPIPE:  should clear the halt */
 	default:
 		dev_info(&urb->dev->dev, "%s: intr status %d\n",
-			 dev->netdev->name, urb->status);
+			 dev->netdev->name, status);
 		goto resubmit;
 	}
 
@@ -591,13 +595,13 @@ static void intr_callback(struct urb *urb)
 	}
 
 resubmit:
-	status = usb_submit_urb (urb, GFP_ATOMIC);
-	if (status == -ENODEV)
+	res = usb_submit_urb (urb, GFP_ATOMIC);
+	if (res == -ENODEV)
 		netif_device_detach(dev->netdev);
-	else if (status)
+	else if (res)
 		err ("can't resubmit intr, %s-%s/input0, status %d",
 				dev->udev->bus->bus_name,
-				dev->udev->devpath, status);
+				dev->udev->devpath, res);
 }
 
 static int rtl8150_suspend(struct usb_interface *intf, pm_message_t message)
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 51e2f5d..bbcde0f 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -310,9 +310,10 @@ static void smsc95xx_async_cmd_callback(struct urb *urb, struct pt_regs *regs)
 {
 	struct usb_context *usb_context = urb->context;
 	struct usbnet *dev = usb_context->dev;
+	int status = urb->status;
 
-	if (urb->status < 0)
-		devwarn(dev, "async callback failed with %d", urb->status);
+	if (status < 0)
+		devwarn(dev, "async callback failed with %d", status);
 
 	complete(&usb_context->notify);
 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
