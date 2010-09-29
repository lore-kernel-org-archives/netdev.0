From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] drivers/net/usb/qcusbnet: Checkpatch cleanups
Date: Tue, 28 Sep 2010 19:39:57 -0700
Message-ID: <0aa502d0e385f2333f8bc12dafdcde88e5ca0262.1285727642.git.joe@perches.com>
References: <20100928171026.GB6083@google.com> <cover.1285727642.git.joe@perches.com>
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2513 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab0I2CkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 22:40:01 -0400
In-Reply-To: <cover.1285727642.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whitespace and removal of KERNEL_VERSION tests
Neaten DBG macro

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/qcusbnet/qcusbnet.c  |  201 ++++++-----------
 drivers/net/usb/qcusbnet/qmi.c       |   32 ++--
 drivers/net/usb/qcusbnet/qmidevice.c |  421 ++++++++++++++++-----------------
 drivers/net/usb/qcusbnet/structs.h   |   25 +--
 4 files changed, 301 insertions(+), 378 deletions(-)

diff --git a/drivers/net/usb/qcusbnet/qcusbnet.c b/drivers/net/usb/qcusbnet/qcusbnet.c
index a075b55..54a354e 100644
--- a/drivers/net/usb/qcusbnet/qcusbnet.c
+++ b/drivers/net/usb/qcusbnet/qcusbnet.c
@@ -30,42 +30,33 @@ static struct class *devclass;
 
 int qc_suspend(struct usb_interface *iface, pm_message_t event)
 {
-	struct usbnet * usbnet;
-	struct qcusbnet * dev;
-	
+	struct usbnet *usbnet;
+	struct qcusbnet *dev;
+
 	if (!iface)
 		return -ENOMEM;
-	
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
+
 	usbnet = usb_get_intfdata(iface);
-#else
-	usbnet = iface->dev.platform_data;
-#endif
 
 	if (!usbnet || !usbnet->net) {
 		DBG("failed to get netdevice\n");
 		return -ENXIO;
 	}
-	
+
 	dev = (struct qcusbnet *)usbnet->data[0];
 	if (!dev) {
 		DBG("failed to get QMIDevice\n");
 		return -ENXIO;
 	}
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
-	if (!usbnet->udev->auto_pm)
-#else
-	if (!(event.event & PM_EVENT_AUTO))
-#endif
-	{
-		DBG("device suspended to power level %d\n", 
-			  event.event);
+	if (!(event.event & PM_EVENT_AUTO)) {
+		DBG("device suspended to power level %d\n",
+		    event.event);
 		qc_setdown(dev, DOWN_DRIVER_SUSPENDED);
 	} else {
 		DBG("device autosuspend\n");
 	}
-	  
+
 	if (event.event & PM_EVENT_SUSPEND) {
 		qc_stopread(dev);
 		usbnet->udev->reset_resume = 0;
@@ -73,31 +64,27 @@ int qc_suspend(struct usb_interface *iface, pm_message_t event)
 	} else {
 		usbnet->udev->reset_resume = 1;
 	}
-	
+
 	return usbnet_suspend(iface, event);
 }
 
-static int qc_resume(struct usb_interface * iface)
+static int qc_resume(struct usb_interface *iface)
 {
 	struct usbnet *usbnet;
 	struct qcusbnet *dev;
 	int ret;
 	int oldstate;
-	
+
 	if (iface == 0)
 		return -ENOMEM;
-	
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
+
 	usbnet = usb_get_intfdata(iface);
-#else
-	usbnet = iface->dev.platform_data;
-#endif
 
 	if (!usbnet || !usbnet->net) {
 		DBG("failed to get netdevice\n");
 		return -ENXIO;
 	}
-	
+
 	dev = (struct qcusbnet *)usbnet->data[0];
 	if (!dev) {
 		DBG("failed to get QMIDevice\n");
@@ -110,7 +97,7 @@ static int qc_resume(struct usb_interface * iface)
 
 	if (oldstate & PM_EVENT_SUSPEND) {
 		qc_cleardown(dev, DOWN_DRIVER_SUSPENDED);
-	
+
 		ret = usbnet_resume(iface);
 		if (ret) {
 			DBG("usbnet_resume error %d\n", ret);
@@ -128,7 +115,7 @@ static int qc_resume(struct usb_interface * iface)
 		DBG("nothing to resume\n");
 		return 0;
 	}
-	
+
 	return ret;
 }
 
@@ -139,18 +126,18 @@ static int qcnet_bind(struct usbnet *usbnet, struct usb_interface *iface)
 	struct usb_host_endpoint *endpoint = NULL;
 	struct usb_host_endpoint *in = NULL;
 	struct usb_host_endpoint *out = NULL;
-	
+
 	if (iface->num_altsetting != 1) {
 		DBG("invalid num_altsetting %u\n", iface->num_altsetting);
 		return -EINVAL;
 	}
 
 	if (iface->cur_altsetting->desc.bInterfaceNumber != 0) {
-		DBG("invalid interface %d\n", 
+		DBG("invalid interface %d\n",
 			  iface->cur_altsetting->desc.bInterfaceNumber);
 		return -EINVAL;
 	}
-	
+
 	numends = iface->cur_altsetting->desc.bNumEndpoints;
 	for (i = 0; i < numends; i++) {
 		endpoint = iface->cur_altsetting->endpoint + i;
@@ -158,7 +145,7 @@ static int qcnet_bind(struct usbnet *usbnet, struct usb_interface *iface)
 			DBG("invalid endpoint %u\n", i);
 			return -EINVAL;
 		}
-		
+
 		if (usb_endpoint_dir_in(&endpoint->desc)
 		&&  !usb_endpoint_xfer_int(&endpoint->desc)) {
 			in = endpoint;
@@ -166,14 +153,14 @@ static int qcnet_bind(struct usbnet *usbnet, struct usb_interface *iface)
 			out = endpoint;
 		}
 	}
-	
+
 	if (!in || !out) {
 		DBG("invalid endpoints\n");
 		return -EINVAL;
 	}
 
 	if (usb_set_interface(usbnet->udev,
-	                      iface->cur_altsetting->desc.bInterfaceNumber, 0))	{
+			      iface->cur_altsetting->desc.bInterfaceNumber, 0))	{
 		DBG("unable to set interface\n");
 		return -EINVAL;
 	}
@@ -182,12 +169,9 @@ static int qcnet_bind(struct usbnet *usbnet, struct usb_interface *iface)
 	usbnet->out = usb_sndbulkpipe(usbnet->udev, out->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
 
 	DBG("in %x, out %x\n",
-	    in->desc.bEndpointAddress, 
+	    in->desc.bEndpointAddress,
 	    out->desc.bEndpointAddress);
 
-#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,23)
-	iface->dev.platform_data = usbnet;
-#endif
 	return 0;
 }
 
@@ -197,23 +181,17 @@ static void qcnet_unbind(struct usbnet *usbnet, struct usb_interface *iface)
 
 	netif_carrier_off(usbnet->net);
 	qc_deregister(dev);
-	
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
+
 	kfree(usbnet->net->netdev_ops);
 	usbnet->net->netdev_ops = NULL;
-#endif
-
-#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,23)
-	iface->dev.platform_data = NULL;
-#endif
 
 	kfree(dev);
 }
 
-static void qcnet_urbhook(struct urb * urb)
+static void qcnet_urbhook(struct urb *urb)
 {
 	unsigned long flags;
-	struct worker * worker = urb->context;
+	struct worker *worker = urb->context;
 	if (!worker) {
 		DBG("bad context\n");
 		return;
@@ -244,7 +222,7 @@ static void qcnet_txtimeout(struct net_device *netdev)
 		DBG("failed to get usbnet device\n");
 		return;
 	}
-	
+
 	dev = (struct qcusbnet *)usbnet->data[0];
 	if (!dev) {
 		DBG("failed to get QMIDevice\n");
@@ -283,7 +261,7 @@ static int qcnet_worker(void *arg)
 		DBG("passed null pointer\n");
 		return -EINVAL;
 	}
-	
+
 	usbdev = interface_to_usbdev(worker->iface);
 
 	DBG("traffic thread started\n");
@@ -309,7 +287,7 @@ static int qcnet_worker(void *arg)
 
 			break;
 		}
-		
+
 		spin_lock_irqsave(&worker->active_lock, activeflags);
 		if (IS_ERR(worker->active) && PTR_ERR(worker->active) == -EAGAIN) {
 			worker->active = NULL;
@@ -322,7 +300,7 @@ static int qcnet_worker(void *arg)
 			spin_unlock_irqrestore(&worker->active_lock, activeflags);
 			continue;
 		}
-		
+
 		spin_lock_irqsave(&worker->urbs_lock, listflags);
 		if (list_empty(&worker->urbs)) {
 			spin_unlock_irqrestore(&worker->urbs_lock, listflags);
@@ -340,22 +318,18 @@ static int qcnet_worker(void *arg)
 		status = usb_autopm_get_interface(worker->iface);
 		if (status < 0) {
 			DBG("unable to autoresume interface: %d\n", status);
-			if (status == -EPERM)
-			{
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
-				usbdev->auto_pm = 0;
-#endif
+			if (status == -EPERM) {
 				qc_suspend(worker->iface, PMSG_SUSPEND);
 			}
 
 			spin_lock_irqsave(&worker->urbs_lock, listflags);
 			list_add(&req->node, &worker->urbs);
 			spin_unlock_irqrestore(&worker->urbs_lock, listflags);
-			
+
 			spin_lock_irqsave(&worker->active_lock, activeflags);
 			worker->active = NULL;
 			spin_unlock_irqrestore(&worker->active_lock, activeflags);
-			
+
 			continue;
 		}
 
@@ -369,10 +343,10 @@ static int qcnet_worker(void *arg)
 			usb_autopm_put_interface(worker->iface);
 			complete(&worker->work);
 		}
-		
+
 		kfree(req);
-	}	
-	
+	}
+
 	DBG("traffic thread exiting\n");
 	worker->thread = NULL;
 	return 0;
@@ -386,27 +360,27 @@ static int qcnet_startxmit(struct sk_buff *skb, struct net_device *netdev)
 	struct urbreq *req;
 	void *data;
 	struct usbnet *usbnet = netdev_priv(netdev);
-	
+
 	DBG("\n");
-	
+
 	if (!usbnet || !usbnet->net) {
 		DBG("failed to get usbnet device\n");
 		return NETDEV_TX_BUSY;
 	}
-	
+
 	dev = (struct qcusbnet *)usbnet->data[0];
 	if (!dev) {
 		DBG("failed to get QMIDevice\n");
 		return NETDEV_TX_BUSY;
 	}
 	worker = &dev->worker;
-	
+
 	if (qc_isdown(dev, DOWN_DRIVER_SUSPENDED)) {
 		DBG("device is suspended\n");
 		dump_stack();
 		return NETDEV_TX_BUSY;
 	}
-	
+
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req) {
 		DBG("unable to allocate URBList memory\n");
@@ -431,8 +405,8 @@ static int qcnet_startxmit(struct sk_buff *skb, struct net_device *netdev)
 	memcpy(data, skb->data, skb->len);
 
 	usb_fill_bulk_urb(req->urb, dev->usbnet->udev, dev->usbnet->out,
-	                  data, skb->len, qcnet_urbhook, worker);
-	
+			  data, skb->len, qcnet_urbhook, worker);
+
 	spin_lock_irqsave(&worker->urbs_lock, listflags);
 	list_add_tail(&req->node, &worker->urbs);
 	spin_unlock_irqrestore(&worker->urbs_lock, listflags);
@@ -450,12 +424,12 @@ static int qcnet_open(struct net_device *netdev)
 	int status = 0;
 	struct qcusbnet *dev;
 	struct usbnet *usbnet = netdev_priv(netdev);
-	
+
 	if (!usbnet) {
 		DBG("failed to get usbnet device\n");
 		return -ENXIO;
 	}
-	
+
 	dev = (struct qcusbnet *)usbnet->data[0];
 	if (!dev) {
 		DBG("failed to get QMIDevice\n");
@@ -470,30 +444,23 @@ static int qcnet_open(struct net_device *netdev)
 	spin_lock_init(&dev->worker.urbs_lock);
 	spin_lock_init(&dev->worker.active_lock);
 	init_completion(&dev->worker.work);
-	
+
 	dev->worker.thread = kthread_run(qcnet_worker, &dev->worker, "qcnet_worker");
-	if (IS_ERR(dev->worker.thread))
-	{
+	if (IS_ERR(dev->worker.thread)) {
 		DBG("AutoPM thread creation error\n");
 		return PTR_ERR(dev->worker.thread);
 	}
 
 	qc_cleardown(dev, DOWN_NET_IFACE_STOPPED);
-	if (dev->open)
-	{
+	if (dev->open) {
 		status = dev->open(netdev);
-		if (status == 0)
-		{
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
-			usb_autopm_enable(dev->iface);
-#else
+		if (status == 0) {
 			usb_autopm_put_interface(dev->iface);
-#endif
 		}
 	} else {
 		DBG("no USBNetOpen defined\n");
 	}
-	
+
 	return status;
 }
 
@@ -506,7 +473,7 @@ int qcnet_stop(struct net_device *netdev)
 		DBG("failed to get netdevice\n");
 		return -ENXIO;
 	}
-	
+
 	dev = (struct qcusbnet *)usbnet->data[0];
 	if (!dev) {
 		DBG("failed to get QMIDevice\n");
@@ -523,23 +490,21 @@ int qcnet_stop(struct net_device *netdev)
 	return 0;
 }
 
-static const struct driver_info qc_netinfo = 
-{
-   .description   = "QCUSBNet Ethernet Device",
-   .flags         = FLAG_ETHER,
-   .bind          = qcnet_bind,
-   .unbind        = qcnet_unbind,
-   .data          = 0,
+static const struct driver_info qc_netinfo = {
+	.description   = "QCUSBNet Ethernet Device",
+	.flags         = FLAG_ETHER,
+	.bind          = qcnet_bind,
+	.unbind        = qcnet_unbind,
+	.data          = 0,
 };
 
-#define MKVIDPID(v,p) \
-	{ \
-		USB_DEVICE(v,p), \
-		.driver_info = (unsigned long)&qc_netinfo, \
-	}
+#define MKVIDPID(v, p)					\
+{							\
+	USB_DEVICE(v, p),				\
+	.driver_info = (unsigned long)&qc_netinfo,	\
+}
 
-static const struct usb_device_id qc_vidpids [] =
-{
+static const struct usb_device_id qc_vidpids[] = {
 	MKVIDPID(0x05c6, 0x9215),	/* Acer Gobi 2000 */
 	MKVIDPID(0x05c6, 0x9265),	/* Asus Gobi 2000 */
 	MKVIDPID(0x16d8, 0x8002),	/* CMOTech Gobi 2000 */
@@ -556,7 +521,7 @@ static const struct usb_device_id qc_vidpids [] =
 	MKVIDPID(0x1199, 0x9001),	/* Sierra Wireless Gobi 2000 */
 	MKVIDPID(0x1199, 0x9002),	/* Sierra Wireless Gobi 2000 */
 	MKVIDPID(0x1199, 0x9003),	/* Sierra Wireless Gobi 2000 */
-	MKVIDPID(0x1199, 0x9004),	/* Sierra Wireless Gobi 2000 */ 
+	MKVIDPID(0x1199, 0x9004),	/* Sierra Wireless Gobi 2000 */
 	MKVIDPID(0x1199, 0x9005),	/* Sierra Wireless Gobi 2000 */
 	MKVIDPID(0x1199, 0x9006),	/* Sierra Wireless Gobi 2000 */
 	MKVIDPID(0x1199, 0x9007),	/* Sierra Wireless Gobi 2000 */
@@ -576,9 +541,7 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 	int status;
 	struct usbnet *usbnet;
 	struct qcusbnet *dev;
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
 	struct net_device_ops *netdevops;
-#endif
 
 	status = usbnet_probe(iface, vidpids);
 	if (status < 0) {
@@ -586,11 +549,7 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 		return status;
 	}
 
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
 	usbnet = usb_get_intfdata(iface);
-#else
-	usbnet = iface->dev.platform_data;
-#endif
 
 	if (!usbnet || !usbnet->net) {
 		DBG("failed to get netdevice\n");
@@ -602,26 +561,18 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 		DBG("falied to allocate device buffers");
 		return -ENOMEM;
 	}
-	
+
 	usbnet->data[0] = (unsigned long)dev;
-	
+
 	dev->usbnet = usbnet;
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29)
-	dev->open = usbnet->net->open;
-	usbnet->net->open = qcnet_open;
-	dev->stop = usbnet->net->stop;
-	usbnet->net->stop = qcnet_stop;
-	usbnet->net->hard_start_xmit = qcnet_startxmit;
-	usbnet->net->tx_timeout = qcnet_txtimeout;
-#else
 	netdevops = kmalloc(sizeof(struct net_device_ops), GFP_KERNEL);
 	if (!netdevops) {
 		DBG("falied to allocate net device ops");
 		return -ENOMEM;
 	}
 	memcpy(netdevops, usbnet->net->netdev_ops, sizeof(struct net_device_ops));
-	
+
 	dev->open = netdevops->ndo_open;
 	netdevops->ndo_open = qcnet_open;
 	dev->stop = netdevops->ndo_stop;
@@ -630,25 +581,19 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 	netdevops->ndo_tx_timeout = qcnet_txtimeout;
 
 	usbnet->net->netdev_ops = netdevops;
-#endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,31)
-	memset(&(dev->usbnet->stats), 0, sizeof(struct net_device_stats));
-#else
 	memset(&(dev->usbnet->net->stats), 0, sizeof(struct net_device_stats));
-#endif
 
 	dev->iface = iface;
 	memset(&(dev->meid), '0', 14);
-	
-	DBG("Mac Address:\n");
-	printhex(&dev->usbnet->net->dev_addr[0], 6);
+
+	DBG("Mac Address: %pM\n", dev->usbnet->net->dev_addr);
 
 	dev->valid = false;
 	memset(&dev->qmi, 0, sizeof(struct qmidev));
 
 	dev->qmi.devclass = devclass;
-	
+
 	INIT_LIST_HEAD(&dev->qmi.clients);
 	init_completion(&dev->worker.work);
 	spin_lock_init(&dev->qmi.clients_lock);
@@ -661,14 +606,12 @@ int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids
 	if (status) {
 		qc_deregister(dev);
 	}
-	
+
 	return status;
 }
-
 EXPORT_SYMBOL_GPL(qcnet_probe);
 
-static struct usb_driver qcusbnet =
-{
+static struct usb_driver qcusbnet = {
 	.name       = "QCUSBNet2k",
 	.id_table   = qc_vidpids,
 	.probe      = qcnet_probe,
diff --git a/drivers/net/usb/qcusbnet/qmi.c b/drivers/net/usb/qcusbnet/qmi.c
index 2fc8ce8..cdbdbaf 100755
--- a/drivers/net/usb/qcusbnet/qmi.c
+++ b/drivers/net/usb/qcusbnet/qmi.c
@@ -177,7 +177,7 @@ void *qmidms_new_getmeid(u8 tid, size_t *size)
 int qmux_parse(u16 *cid, void *buf, size_t size)
 {
 	struct qmux *qmux = buf;
-   
+
 	if (!buf || size < 12)
 		return -ENOMEM;
 
@@ -203,13 +203,14 @@ int qmux_fill(u16 cid, void *buf, size_t size)
 	return 0;
 }
 
-static u16 tlv_get(void *msg, u16 msgsize, u8 type, void *buf, u16 bufsize) {
+static u16 tlv_get(void *msg, u16 msgsize, u8 type, void *buf, u16 bufsize)
+{
 	u16 pos;
 	u16 msize = 0;
-	
+
 	if (!msg || !buf)
 		return -ENOMEM;
-	
+
 	for (pos = 4;  pos + 3 < msgsize; pos += msize + 3) {
 		msize = *(u16 *)(msg + pos + 1);
 		if (*(u8 *)(msg + pos) == type) {
@@ -220,7 +221,7 @@ static u16 tlv_get(void *msg, u16 msgsize, u8 type, void *buf, u16 bufsize) {
 			return msize;
 		}
 	}
-	
+
 	return -ENOMSG;
 }
 
@@ -305,21 +306,21 @@ int qmiwds_event_resp(void *buf, u16 size, struct qmiwds_stats *stats)
 
 	result = qmi_msgid(buf, size);
 	if (result == 0x01) {
-		tlv_get(buf, size, 0x10, (void*)&stats->txok, 4);
-		tlv_get(buf, size, 0x11, (void*)&stats->rxok, 4);
-		tlv_get(buf, size, 0x12, (void*)&stats->txerr, 4);
-		tlv_get(buf, size, 0x13, (void*)&stats->rxerr, 4);
-		tlv_get(buf, size, 0x14, (void*)&stats->txofl, 4);
-		tlv_get(buf, size, 0x15, (void*)&stats->rxofl, 4);
-		tlv_get(buf, size, 0x19, (void*)&stats->txbytesok, 8);
-		tlv_get(buf, size, 0x1A, (void*)&stats->rxbytesok, 8);
+		tlv_get(buf, size, 0x10, &stats->txok, 4);
+		tlv_get(buf, size, 0x11, &stats->rxok, 4);
+		tlv_get(buf, size, 0x12, &stats->txerr, 4);
+		tlv_get(buf, size, 0x13, &stats->rxerr, 4);
+		tlv_get(buf, size, 0x14, &stats->txofl, 4);
+		tlv_get(buf, size, 0x15, &stats->rxofl, 4);
+		tlv_get(buf, size, 0x19, &stats->txbytesok, 8);
+		tlv_get(buf, size, 0x1A, &stats->rxbytesok, 8);
 	} else if (result == 0x22) {
 		result = tlv_get(buf, size, 0x01, &status[0], 2);
 		if (result >= 1)
 			stats->linkstate = status[0] == 0x02;
 		if (result == 2)
 			stats->reconfigure = status[1] == 0x01;
-		
+
 		if (result < 0)
 			return result;
 	} else {
@@ -349,10 +350,9 @@ int qmidms_meid_resp(void *buf,	u16 size, char *meid, int meidsize)
 	if (result)
 		return -EFAULT;
 
-	result = tlv_get(buf, size, 0x12, (void*)meid, 14);
+	result = tlv_get(buf, size, 0x12, meid, 14);
 	if (result != 14)
 		return -EFAULT;
 
 	return 0;
 }
-
diff --git a/drivers/net/usb/qcusbnet/qmidevice.c b/drivers/net/usb/qcusbnet/qmidevice.c
index b5006be..da7e42d 100755
--- a/drivers/net/usb/qcusbnet/qmidevice.c
+++ b/drivers/net/usb/qcusbnet/qmidevice.c
@@ -28,7 +28,7 @@ struct readreq {
 
 struct notifyreq {
 	struct list_head node;
-	void (* func)(struct qcusbnet *, u16, void *);
+	void (*func)(struct qcusbnet *, u16, void *);
 	u16  tid;
 	void *data;
 };
@@ -55,15 +55,15 @@ struct qmihandle {
 };
 
 extern int debug;
-static int qcusbnet2k_fwdelay = 0;
+static int qcusbnet2k_fwdelay;
 
 static bool device_valid(struct qcusbnet *dev);
 static struct client *client_bycid(struct qcusbnet *dev, u16 cid);
 static bool client_addread(struct qcusbnet *dev, u16 cid, u16 tid, void *data, u16 size);
 static bool client_delread(struct qcusbnet *dev, u16 cid, u16 tid, void **data, u16 *size);
 static bool client_addnotify(struct qcusbnet *dev, u16 cid, u16 tid,
-                             void (*hook)(struct qcusbnet *, u16 cid, void *),
-                             void *data);
+			     void (*hook)(struct qcusbnet *, u16 cid, void *),
+			     void *data);
 static bool client_notify(struct qcusbnet *dev, u16 cid, u16 tid);
 static bool client_addurb(struct qcusbnet *dev, u16 cid, struct urb *urb);
 static struct urb *client_delurb(struct qcusbnet *dev, u16 cid);
@@ -72,23 +72,22 @@ static int devqmi_open(struct inode *inode, struct file *file);
 static long devqmi_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 static int devqmi_close(struct file *file, fl_owner_t ftable);
 static ssize_t devqmi_read(struct file *file, char __user *buf, size_t size,
-                           loff_t *pos);
+			   loff_t *pos);
 static ssize_t devqmi_write(struct file *file, const char __user *buf,
-                            size_t size, loff_t *pos);
+			    size_t size, loff_t *pos);
 
 static bool qmi_ready(struct qcusbnet *dev, u16 timeout);
 static void wds_callback(struct qcusbnet *dev, u16 cid, void *data);
 static int setup_wds_callback(struct qcusbnet *dev);
 static int qmidms_getmeid(struct qcusbnet *dev);
 
-#define IOCTL_QMI_GET_SERVICE_FILE 0x8BE0 + 1
-#define IOCTL_QMI_GET_DEVICE_VIDPID 0x8BE0 + 2
-#define IOCTL_QMI_GET_DEVICE_MEID 0x8BE0 + 3
-#define CDC_GET_ENCAPSULATED_RESPONSE 0x01A1ll
-#define CDC_CONNECTION_SPEED_CHANGE 0x08000000002AA1ll
+#define IOCTL_QMI_GET_SERVICE_FILE	(0x8BE0 + 1)
+#define IOCTL_QMI_GET_DEVICE_VIDPID	(0x8BE0 + 2)
+#define IOCTL_QMI_GET_DEVICE_MEID	(0x8BE0 + 3)
+#define CDC_GET_ENCAPSULATED_RESPONSE	0x01A1ll
+#define CDC_CONNECTION_SPEED_CHANGE	0x08000000002AA1ll
 
-struct file_operations devqmi_fops = 
-{
+static const struct file_operations devqmi_fops = {
 	.owner = THIS_MODULE,
 	.read  = devqmi_read,
 	.write = devqmi_write,
@@ -112,7 +111,7 @@ static inline void assert_locked(struct qcusbnet *dev)
 static bool device_valid(struct qcusbnet *dev)
 {
 	return dev && dev->valid;
-} 
+}
 
 void printhex(const void *data, size_t size)
 {
@@ -132,7 +131,7 @@ void printhex(const void *data, size_t size)
 		snprintf(buf + (pos * 3), 4, "%02X ", cdata[pos]);
 	}
 
-	DBG( "   : %s\n", buf);
+	DBG("   : %s\n", buf);
 
 	kfree(buf);
 }
@@ -203,9 +202,9 @@ static void read_callback(struct urb *urb)
 	}
 
 	if (cid == QMICTL)
-		tid = *(u8*)(data + result + 1);
+		tid = *(u8 *)(data + result + 1);
 	else
-		tid = *(u16*)(data + result + 1);
+		tid = *(u16 *)(data + result + 1);
 	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
 
 	list_for_each(node, &dev->qmi.clients) {
@@ -230,7 +229,7 @@ static void read_callback(struct urb *urb)
 				break;
 		}
 	}
-	
+
 	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 }
 
@@ -250,25 +249,25 @@ static void int_callback(struct urb *urb)
 		if (urb->status != -EOVERFLOW)
 			return;
 	} else {
-		if ((urb->actual_length == 8)
-		&&  (*(u64*)urb->transfer_buffer == CDC_GET_ENCAPSULATED_RESPONSE)) {
+		if ((urb->actual_length == 8) &&
+		    (*(u64 *)urb->transfer_buffer == CDC_GET_ENCAPSULATED_RESPONSE)) {
 			usb_fill_control_urb(dev->qmi.readurb, dev->usbnet->udev,
-			                     usb_rcvctrlpipe(dev->usbnet->udev, 0),
-			                     (unsigned char *)dev->qmi.readsetup,
-			                     dev->qmi.readbuf,
-			                     DEFAULT_READ_URB_LENGTH,
-			                     read_callback, dev);
+					     usb_rcvctrlpipe(dev->usbnet->udev, 0),
+					     (unsigned char *)dev->qmi.readsetup,
+					     dev->qmi.readbuf,
+					     DEFAULT_READ_URB_LENGTH,
+					     read_callback, dev);
 			status = usb_submit_urb(dev->qmi.readurb, GFP_ATOMIC);
 			if (status) {
 				DBG("Error submitting Read URB %d\n", status);
 				return;
 			}
-		} else if ((urb->actual_length == 16)
-		&& (*(u64*)urb->transfer_buffer == CDC_CONNECTION_SPEED_CHANGE)) {
+		} else if ((urb->actual_length == 16) &&
+			   (*(u64 *)urb->transfer_buffer == CDC_CONNECTION_SPEED_CHANGE)) {
 			/* if upstream or downstream is 0, stop traffic.
 			 * Otherwise resume it */
-			if ((*(u32*)(urb->transfer_buffer + 8) == 0)
-			||  (*(u32*)(urb->transfer_buffer + 12) == 0)) {
+			if ((*(u32 *)(urb->transfer_buffer + 8) == 0) ||
+			    (*(u32 *)(urb->transfer_buffer + 12) == 0)) {
 				qc_setdown(dev, DOWN_CDC_CONNECTION_SPEED);
 				DBG("traffic stopping due to CONNECTION_SPEED_CHANGE\n");
 			} else {
@@ -284,8 +283,8 @@ static void int_callback(struct urb *urb)
 	interval = (dev->usbnet->udev->speed == USB_SPEED_HIGH) ? 7 : 3;
 
 	usb_fill_int_urb(urb, urb->dev,	urb->pipe, urb->transfer_buffer,
-	                 urb->transfer_buffer_length, urb->complete,
-	                 urb->context, interval);
+			 urb->transfer_buffer_length, urb->complete,
+			 urb->context, interval);
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status)
 		DBG("Error re-submitting Int URB %d\n", status);
@@ -300,13 +299,13 @@ int qc_startread(struct qcusbnet *dev)
 		DBG("Invalid device!\n");
 		return -ENXIO;
 	}
-	
+
 	dev->qmi.readurb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!dev->qmi.readurb) {
 		DBG("Error allocating read urb\n");
 		return -ENOMEM;
 	}
-	
+
 	dev->qmi.inturb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!dev->qmi.inturb) {
 		usb_free_urb(dev->qmi.readurb);
@@ -321,7 +320,7 @@ int qc_startread(struct qcusbnet *dev)
 		DBG("Error allocating read buffer\n");
 		return -ENOMEM;
 	}
-	
+
 	dev->qmi.intbuf = kmalloc(DEFAULT_READ_URB_LENGTH, GFP_KERNEL);
 	if (!dev->qmi.intbuf) {
 		usb_free_urb(dev->qmi.readurb);
@@ -329,8 +328,8 @@ int qc_startread(struct qcusbnet *dev)
 		kfree(dev->qmi.readbuf);
 		DBG("Error allocating int buffer\n");
 		return -ENOMEM;
-	}		
-	
+	}
+
 	dev->qmi.readsetup = kmalloc(sizeof(*dev->qmi.readsetup), GFP_KERNEL);
 	if (!dev->qmi.readsetup) {
 		usb_free_urb(dev->qmi.readurb);
@@ -348,15 +347,15 @@ int qc_startread(struct qcusbnet *dev)
 	dev->qmi.readsetup->len = DEFAULT_READ_URB_LENGTH;
 
 	interval = (dev->usbnet->udev->speed == USB_SPEED_HIGH) ? 7 : 3;
-	
+
 	usb_fill_int_urb(dev->qmi.inturb, dev->usbnet->udev,
-	                 usb_rcvintpipe(dev->usbnet->udev, 0x81),
-	                 dev->qmi.intbuf, DEFAULT_READ_URB_LENGTH,
-	                 int_callback, dev, interval);
+			 usb_rcvintpipe(dev->usbnet->udev, 0x81),
+			 dev->qmi.intbuf, DEFAULT_READ_URB_LENGTH,
+			 int_callback, dev, interval);
 	return usb_submit_urb(dev->qmi.inturb, GFP_KERNEL);
 }
 
-void qc_stopread(struct qcusbnet * dev)
+void qc_stopread(struct qcusbnet *dev)
 {
 	if (dev->qmi.readurb) {
 		DBG("Killng read URB\n");
@@ -374,7 +373,7 @@ void qc_stopread(struct qcusbnet * dev)
 	dev->qmi.readbuf = NULL;
 	kfree(dev->qmi.intbuf);
 	dev->qmi.intbuf = NULL;
-	
+
 	usb_free_urb(dev->qmi.readurb);
 	dev->qmi.readurb = NULL;
 	usb_free_urb(dev->qmi.inturb);
@@ -382,12 +381,13 @@ void qc_stopread(struct qcusbnet * dev)
 }
 
 static int read_async(struct qcusbnet *dev, u16 cid, u16 tid,
-                      void (*hook)(struct qcusbnet*, u16, void *), void *data)
+		      void (*hook)(struct qcusbnet *, u16, void *),
+		      void *data)
 {
 	struct list_head *node;
 	struct client *client;
 	struct readreq *readreq;
-	
+
 	unsigned long flags;
 
 	if (!device_valid(dev)) {
@@ -420,7 +420,7 @@ static int read_async(struct qcusbnet *dev, u16 cid, u16 tid,
 	return 0;
 }
 
-static void upsem(struct qcusbnet *dev, u16 cid, void *data) 
+static void upsem(struct qcusbnet *dev, u16 cid, void *data)
 {
 	DBG("0x%04X\n", cid);
 	up((struct semaphore *)data);
@@ -430,10 +430,10 @@ static int read_sync(struct qcusbnet *dev, void **buf, u16 cid, u16 tid)
 {
 	struct list_head *node;
 	int result;
-	struct client * client;
+	struct client *client;
 	struct notifyreq *notify;
 	struct semaphore sem;
-	void * data;
+	void *data;
 	unsigned long flags;
 	u16 size;
 
@@ -441,7 +441,7 @@ static int read_sync(struct qcusbnet *dev, void **buf, u16 cid, u16 tid)
 		DBG("Invalid device!\n");
 		return -ENXIO;
 	}
-	
+
 	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
 
 	client = client_bycid(dev, cid);
@@ -450,7 +450,7 @@ static int read_sync(struct qcusbnet *dev, void **buf, u16 cid, u16 tid)
 		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 		return -ENXIO;
 	}
-	
+
 	while (!client_delread(dev, cid, tid, &data, &size)) {
 		sema_init(&sem, 0);
 		if (!client_addnotify(dev, cid, tid, upsem, &sem)) {
@@ -477,15 +477,15 @@ static int read_sync(struct qcusbnet *dev, void **buf, u16 cid, u16 tid)
 			spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 			return -EINTR;
 		}
-		
+
 		if (!device_valid(dev)) {
 			DBG("Invalid device!\n");
 			return -ENXIO;
 		}
-		
+
 		spin_lock_irqsave(&dev->qmi.clients_lock, flags);
 	}
-	
+
 	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 	*buf = data;
 	return size;
@@ -536,25 +536,22 @@ static int write_sync(struct qcusbnet *dev, char *buf, int size, u16 cid)
 	setup.len = size;
 
 	usb_fill_control_urb(urb, dev->usbnet->udev,
-	                     usb_sndctrlpipe(dev->usbnet->udev, 0),
-	                     (unsigned char *)&setup, (void*)buf, size,
-	                     NULL, dev);
+			     usb_sndctrlpipe(dev->usbnet->udev, 0),
+			     (unsigned char *)&setup, (void *)buf, size,
+			     NULL, dev);
 
 	DBG("Actual Write:\n");
 	printhex(buf, size);
 
 	sema_init(&sem, 0);
-	
+
 	urb->complete = write_callback;
 	urb->context = &sem;
-	
+
 	result = usb_autopm_get_interface(dev->iface);
 	if (result < 0) {
 		DBG("unable to resume interface: %d\n", result);
 		if (result == -EPERM) {
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
-			dev->usbnet->udev->auto_pm = 0;
-#endif
 			qc_suspend(dev->iface, PMSG_SUSPEND);
 		}
 		return result;
@@ -564,7 +561,7 @@ static int write_sync(struct qcusbnet *dev, char *buf, int size, u16 cid)
 
 	if (!client_addurb(dev, cid, urb)) {
 		usb_free_urb(urb);
-		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
+		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 		usb_autopm_put_interface(dev->iface);
 		return -EINVAL;
 	}
@@ -582,8 +579,8 @@ static int write_sync(struct qcusbnet *dev, char *buf, int size, u16 cid)
 		usb_autopm_put_interface(dev->iface);
 		return result;
 	}
-	
-	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
+
+	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 	result = down_interruptible(&sem);
 	if (!device_valid(dev)) {
 		DBG("Invalid device!\n");
@@ -592,13 +589,12 @@ static int write_sync(struct qcusbnet *dev, char *buf, int size, u16 cid)
 
 	usb_autopm_put_interface(dev->iface);
 	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
-	if (client_delurb(dev, cid) != urb)
-	{
+	if (client_delurb(dev, cid) != urb) {
 		DBG("Didn't get write URB back\n");
-		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
+		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 		return -EINVAL;
 	}
-	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
+	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 
 	if (!result) {
 		if (!urb->status) {
@@ -622,13 +618,13 @@ static int client_alloc(struct qcusbnet *dev, u8 type)
 	u16 cid;
 	struct client *client;
 	int result;
-	void * wbuf;
+	void *wbuf;
 	size_t wbufsize;
-	void * rbuf;
+	void *rbuf;
 	u16 rbufsize;
 	unsigned long flags;
 	u8 tid;
-	
+
 	if (!device_valid(dev)) {
 		DBG("Invalid device!\n");
 		return -ENXIO;
@@ -691,12 +687,12 @@ static void client_free(struct qcusbnet *dev, u16 cid)
 	struct list_head *node, *tmp;
 	int result;
 	struct client *client;
-	struct urb * urb;
-	void * data;
+	struct urb *urb;
+	void *data;
 	u16 size;
-	void * wbuf;
+	void *wbuf;
 	size_t wbufsize;
-	void * rbuf;
+	void *rbuf;
 	u16 rbufsize;
 	unsigned long flags;
 	u8 tid;
@@ -705,11 +701,10 @@ static void client_free(struct qcusbnet *dev, u16 cid)
 		DBG("invalid device\n");
 		return;
 	}
-	
+
 	DBG("releasing 0x%04X\n", cid);
 
-	if (cid != QMICTL)
-	{
+	if (cid != QMICTL) {
 		tid = atomic_add_return(1, &dev->qmi.qmitid);
 		if (!tid)
 			tid = atomic_add_return(1, &dev->qmi.qmitid);
@@ -741,7 +736,9 @@ static void client_free(struct qcusbnet *dev, u16 cid)
 	list_for_each_safe(node, tmp, &dev->qmi.clients) {
 		client = list_entry(node, struct client, node);
 		if (client->cid == cid) {
-			while (client_notify(dev, cid, 0));
+			while (client_notify(dev, cid, 0)) {
+				;
+			}
 
 			urb = client_delurb(dev, cid);
 			while (urb != NULL) {
@@ -757,7 +754,7 @@ static void client_free(struct qcusbnet *dev, u16 cid)
 			kfree(client);
 		}
 	}
-	
+
 	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
 }
 
@@ -765,14 +762,14 @@ struct client *client_bycid(struct qcusbnet *dev, u16 cid)
 {
 	struct list_head *node;
 	struct client *client;
-	
+
 	if (!device_valid(dev))	{
 		DBG("Invalid device\n");
 		return NULL;
 	}
 
-	assert_locked(dev);	
-	
+	assert_locked(dev);
+
 	list_for_each(node, &dev->qmi.clients) {
 		client = list_entry(node, struct client, node);
 		if (client->cid == cid)
@@ -784,7 +781,7 @@ struct client *client_bycid(struct qcusbnet *dev, u16 cid)
 }
 
 static bool client_addread(struct qcusbnet *dev, u16 cid, u16 tid, void *data,
-                           u16 size)
+			   u16 size)
 {
 	struct client *client;
 	struct readreq *req;
@@ -808,12 +805,12 @@ static bool client_addread(struct qcusbnet *dev, u16 cid, u16 tid, void *data,
 	req->tid = tid;
 
 	list_add_tail(&req->node, &client->reads);
-	
+
 	return true;
 }
 
 static bool client_delread(struct qcusbnet *dev, u16 cid, u16 tid, void **data,
-                           u16 *size)
+			   u16 *size)
 {
 	struct client *client;
 	struct readreq *req;
@@ -826,7 +823,7 @@ static bool client_delread(struct qcusbnet *dev, u16 cid, u16 tid, void **data,
 		DBG("Could not find this client's memory 0x%04X\n", cid);
 		return false;
 	}
-	
+
 	list_for_each(node, &client->reads) {
 		req = list_entry(node, struct readreq, node);
 		if (!tid || tid == req->tid) {
@@ -836,17 +833,17 @@ static bool client_delread(struct qcusbnet *dev, u16 cid, u16 tid, void **data,
 			kfree(req);
 			return true;
 		}
-		
+
 		DBG("skipping 0x%04X data TID = %x\n", cid, req->tid);
 	}
-	
+
 	DBG("No read memory to pop, Client 0x%04X, TID = %x\n", cid, tid);
 	return false;
 }
 
 static bool client_addnotify(struct qcusbnet *dev, u16 cid, u16 tid,
-                      void (*hook)(struct qcusbnet *, u16, void *),
-                      void *data)
+			     void (*hook)(struct qcusbnet *, u16, void *),
+			     void *data)
 {
 	struct client *client;
 	struct notifyreq *req;
@@ -895,10 +892,10 @@ static bool client_notify(struct qcusbnet *dev, u16 cid, u16 tid)
 			delnotify = notify;
 			break;
 		}
-		
+
 		DBG("skipping data TID = %x\n", notify->tid);
 	}
-	
+
 	if (delnotify) {
 		list_del(&delnotify->node);
 		if (delnotify->func) {
@@ -910,7 +907,7 @@ static bool client_notify(struct qcusbnet *dev, u16 cid, u16 tid)
 		return true;
 	}
 
-	DBG("no one to notify for TID %x\n", tid);	
+	DBG("no one to notify for TID %x\n", tid);
 	return false;
 }
 
@@ -931,11 +928,11 @@ static bool client_addurb(struct qcusbnet *dev, u16 cid, struct urb *urb)
 	if (!req) {
 		DBG("Mem error\n");
 		return false;
-	}	
+	}
 
 	req->urb = urb;
 	list_add_tail(&req->node, &client->urbs);
-	
+
 	return true;
 }
 
@@ -967,9 +964,9 @@ static struct urb *client_delurb(struct qcusbnet *dev, u16 cid)
 
 static int devqmi_open(struct inode *inode, struct file *file)
 {
-	struct qmihandle * handle;
+	struct qmihandle *handle;
 	struct qmidev *qmidev = container_of(inode->i_cdev, struct qmidev, cdev);
-	struct qcusbnet * dev = container_of(qmidev, struct qcusbnet, qmi);
+	struct qcusbnet *dev = container_of(qmidev, struct qcusbnet, qmi);
 
 	if (!device_valid(dev)) {
 		DBG("Invalid device\n");
@@ -981,11 +978,11 @@ static int devqmi_open(struct inode *inode, struct file *file)
 		DBG("Mem error\n");
 		return -ENOMEM;
 	}
-	
+
 	handle = (struct qmihandle *)file->private_data;
 	handle->cid = (u16)-1;
 	handle->dev = dev;
-	
+
 	return 0;
 }
 
@@ -993,14 +990,14 @@ static long devqmi_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	int result;
 	u32 vidpid;
-	
+
 	struct qmihandle *handle = (struct qmihandle *)file->private_data;
 
 	if (!handle) {
 		DBG("Bad file data\n");
 		return -EBADF;
 	}
-	
+
 	if (!device_valid(handle->dev)) {
 		DBG("Invalid device! Updating f_ops\n");
 		file->f_op = file->f_dentry->d_inode->i_fop;
@@ -1008,77 +1005,77 @@ static long devqmi_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	}
 
 	switch (cmd) {
-		case IOCTL_QMI_GET_SERVICE_FILE:
+	case IOCTL_QMI_GET_SERVICE_FILE:
 
-			DBG("Setting up QMI for service %lu\n", arg);
-			if (!(u8)arg) {
-				DBG("Cannot use QMICTL from userspace\n");
-				return -EINVAL;
-			}
+		DBG("Setting up QMI for service %lu\n", arg);
+		if (!(u8)arg) {
+			DBG("Cannot use QMICTL from userspace\n");
+			return -EINVAL;
+		}
 
-			if (handle->cid != (u16)-1) {
-				DBG("Close the current connection before opening a new one\n");
-				return -EBADR;
-			}
-			
-			result = client_alloc(handle->dev, (u8)arg);
-			if (result < 0)
-				return result;
-			handle->cid = result;
+		if (handle->cid != (u16)-1) {
+			DBG("Close the current connection before opening a new one\n");
+			return -EBADR;
+		}
 
-			return 0;
-			break;
+		result = client_alloc(handle->dev, (u8)arg);
+		if (result < 0)
+			return result;
+		handle->cid = result;
 
+		return 0;
+		break;
 
-		case IOCTL_QMI_GET_DEVICE_VIDPID:
-			if (!arg) {
-				DBG("Bad VIDPID buffer\n");
-				return -EINVAL;
-			}
-			
-			if (!handle->dev->usbnet) {
-				DBG("Bad usbnet\n");
-				return -ENOMEM;
-			}
 
-			if (!handle->dev->usbnet->udev) {
-				DBG("Bad udev\n");
-				return -ENOMEM;
-			}
+	case IOCTL_QMI_GET_DEVICE_VIDPID:
+		if (!arg) {
+			DBG("Bad VIDPID buffer\n");
+			return -EINVAL;
+		}
 
-			vidpid = ((le16_to_cpu(handle->dev->usbnet->udev->descriptor.idVendor) << 16)
-			       + le16_to_cpu(handle->dev->usbnet->udev->descriptor.idProduct));
+		if (!handle->dev->usbnet) {
+			DBG("Bad usbnet\n");
+			return -ENOMEM;
+		}
 
-			result = copy_to_user((unsigned int *)arg, &vidpid, 4);
-			if (result)
-				DBG("Copy to userspace failure\n");
+		if (!handle->dev->usbnet->udev) {
+			DBG("Bad udev\n");
+			return -ENOMEM;
+		}
 
-			return result;
-			break;
+		vidpid = ((le16_to_cpu(handle->dev->usbnet->udev->descriptor.idVendor) << 16)
+			  + le16_to_cpu(handle->dev->usbnet->udev->descriptor.idProduct));
 
-		case IOCTL_QMI_GET_DEVICE_MEID:
-			if (!arg) {
-				DBG("Bad MEID buffer\n");
-				return -EINVAL;
-			}
-			
-			result = copy_to_user((unsigned int *)arg, &handle->dev->meid[0], 14);
-			if (result)
-				DBG("copy to userspace failure\n");
+		result = copy_to_user((unsigned int *)arg, &vidpid, 4);
+		if (result)
+			DBG("Copy to userspace failure\n");
 
-			return result;
-			break;
-		default:
-			return -EBADRQC;		 
+		return result;
+		break;
+
+	case IOCTL_QMI_GET_DEVICE_MEID:
+		if (!arg) {
+			DBG("Bad MEID buffer\n");
+			return -EINVAL;
+		}
+
+		result = copy_to_user((unsigned int *)arg, &handle->dev->meid[0], 14);
+		if (result)
+			DBG("copy to userspace failure\n");
+
+		return result;
+		break;
+	default:
+		return -EBADRQC;
 	}
 }
 
 static int devqmi_close(struct file *file, fl_owner_t ftable)
 {
-	struct qmihandle * handle = (struct qmihandle *)file->private_data;
-	struct list_head * tasks;
-	struct task_struct * task;
-	struct fdtable * fdtable;
+	struct qmihandle *handle = (struct qmihandle *)file->private_data;
+	struct list_head *tasks;
+	struct task_struct *task;
+	struct fdtable *fdtable;
 	int count = 0;
 	int used = 0;
 	unsigned long flags;
@@ -1109,7 +1106,7 @@ static int devqmi_close(struct file *file, fl_owner_t ftable)
 			}
 			spin_unlock_irqrestore(&task->files->file_lock, flags);
 		}
-		
+
 		if (used > 0) {
 			DBG("not closing, as this FD is open by %d other process\n", used);
 			return 0;
@@ -1121,9 +1118,9 @@ static int devqmi_close(struct file *file, fl_owner_t ftable)
 		file->f_op = file->f_dentry->d_inode->i_fop;
 		return -ENXIO;
 	}
-	
+
 	DBG("0x%04X\n", handle->cid);
-	
+
 	file->private_data = NULL;
 
 	if (handle->cid != (u16)-1)
@@ -1134,12 +1131,12 @@ static int devqmi_close(struct file *file, fl_owner_t ftable)
 }
 
 static ssize_t devqmi_read(struct file *file, char __user *buf, size_t size,
-                           loff_t *pos)
+			   loff_t *pos)
 {
 	int result;
-	void * data = NULL;
-	void * smalldata;
-	struct qmihandle * handle = (struct qmihandle *)file->private_data;
+	void *data = NULL;
+	void *smalldata;
+	struct qmihandle *handle = (struct qmihandle *)file->private_data;
 
 	if (!handle) {
 		DBG("Bad file data\n");
@@ -1151,17 +1148,17 @@ static ssize_t devqmi_read(struct file *file, char __user *buf, size_t size,
 		file->f_op = file->f_dentry->d_inode->i_fop;
 		return -ENXIO;
 	}
-	
+
 	if (handle->cid == (u16)-1) {
 		DBG("Client ID must be set before reading 0x%04X\n",
 		    handle->cid);
 		return -EBADR;
 	}
-	
+
 	result = read_sync(handle->dev, &data, handle->cid, 0);
 	if (result <= 0)
 		return result;
-	
+
 	result -= qmux_size;
 	smalldata = data + qmux_size;
 
@@ -1175,13 +1172,13 @@ static ssize_t devqmi_read(struct file *file, char __user *buf, size_t size,
 		DBG("Error copying read data to user\n");
 		result = -EFAULT;
 	}
-	
+
 	kfree(data);
 	return result;
 }
 
-static ssize_t devqmi_write (struct file *file, const char __user * buf,
-                             size_t size, loff_t *pos)
+static ssize_t devqmi_write(struct file *file, const char __user * buf,
+			    size_t size, loff_t *pos)
 {
 	int status;
 	void *wbuf;
@@ -1203,7 +1200,7 @@ static ssize_t devqmi_write (struct file *file, const char __user * buf,
 			  handle->cid);
 		return -EBADR;
 	}
-	
+
 	wbuf = kmalloc(size + qmux_size, GFP_KERNEL);
 	if (!wbuf)
 		return -ENOMEM;
@@ -1215,7 +1212,7 @@ static ssize_t devqmi_write (struct file *file, const char __user * buf,
 	}
 
 	status = write_sync(handle->dev, wbuf, size + qmux_size,
-	                    handle->cid);
+			    handle->cid);
 
 	kfree(wbuf);
 	if (status == size + qmux_size)
@@ -1227,9 +1224,9 @@ int qc_register(struct qcusbnet *dev)
 {
 	int result;
 	int qmiidx = 0;
-	dev_t devno; 
-	char * name;
-	
+	dev_t devno;
+	char *name;
+
 	dev->valid = true;
 	result = client_alloc(dev, QMICTL);
 	if (result) {
@@ -1243,7 +1240,7 @@ int qc_register(struct qcusbnet *dev)
 		dev->valid = false;
 		return result;
 	}
-	
+
 	if (!qmi_ready(dev, 30000)) {
 		DBG("Device unresponsive to QMI\n");
 		return -ETIMEDOUT;
@@ -1288,12 +1285,8 @@ int qc_register(struct qcusbnet *dev)
 	}
 
 	printk(KERN_INFO "creating qcqmi%d\n", qmiidx);
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27)
 	device_create(dev->qmi.devclass, NULL, devno, NULL, "qcqmi%d", qmiidx);
-#else
-	device_create(dev->qmi.devclass, NULL, devno, "qcqmi%d", qmiidx);
-#endif
-	
+
 	dev->qmi.devnum = devno;
 	return 0;
 }
@@ -1302,12 +1295,12 @@ void qc_deregister(struct qcusbnet *dev)
 {
 	struct list_head *node;
 	struct client *client;
-	struct inode * inode;
-	struct list_head * inodes;
-	struct list_head * tasks;
-	struct task_struct * task;
-	struct fdtable * fdtable;
-	struct file * file;
+	struct inode *inode;
+	struct list_head *inodes;
+	struct list_head *tasks;
+	struct task_struct *task;
+	struct fdtable *fdtable;
+	struct file *file;
 	unsigned long flags;
 	int count = 0;
 
@@ -1337,7 +1330,7 @@ void qc_deregister(struct qcusbnet *dev)
 					file = fdtable->fd[count];
 					if (file != NULL &&  file->f_dentry != NULL) {
 						if (file->f_dentry->d_inode == inode) {
-							rcu_assign_pointer(fdtable->fd[count], NULL);	
+							rcu_assign_pointer(fdtable->fd[count], NULL);
 							spin_unlock_irqrestore(&task->files->file_lock, flags);
 							DBG("forcing close of open file handle\n");
 							filp_close(file, task->files);
@@ -1359,15 +1352,15 @@ void qc_deregister(struct qcusbnet *dev)
 static bool qmi_ready(struct qcusbnet *dev, u16 timeout)
 {
 	int result;
-	void * wbuf;
+	void *wbuf;
 	size_t wbufsize;
-	void * rbuf;
+	void *rbuf;
 	u16 rbufsize;
 	struct semaphore sem;
 	u16 now;
 	unsigned long flags;
 	u8 tid;
-	
+
 	if (!device_valid(dev)) {
 		DBG("Invalid device\n");
 		return -EFAULT;
@@ -1380,12 +1373,11 @@ static bool qmi_ready(struct qcusbnet *dev, u16 timeout)
 		tid = atomic_add_return(1, &dev->qmi.qmitid);
 		if (!tid)
 			tid = atomic_add_return(1, &dev->qmi.qmitid);
-		if (wbuf)
-			kfree(wbuf);
+		kfree(wbuf);
 		wbuf = qmictl_new_ready(tid, &wbufsize);
 		if (!wbuf)
 			return -ENOMEM;
-	
+
 		result = read_async(dev, QMICTL, tid, upsem, &sem);
 		if (result) {
 			kfree(wbuf);
@@ -1409,12 +1401,11 @@ static bool qmi_ready(struct qcusbnet *dev, u16 timeout)
 		}
 	}
 
-	if (wbuf)
-		kfree(wbuf);
+	kfree(wbuf);
 
 	if (now >= timeout)
 		return false;
-	
+
 	DBG("QMI Ready after %u milliseconds\n", now);
 
 	/* 3580 and newer doesn't need a delay; older needs 5000ms */
@@ -1428,14 +1419,10 @@ static void wds_callback(struct qcusbnet *dev, u16 cid, void *data)
 {
 	bool ret;
 	int result;
-	void * rbuf;
+	void *rbuf;
 	u16 rbufsize;
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,31)
-	struct net_device_stats * stats = &(dev->usbnet->stats);
-#else
-	struct net_device_stats * stats = &(dev->usbnet->net->stats);
-#endif
+	struct net_device_stats *stats = &(dev->usbnet->net->stats);
 
 	struct qmiwds_stats dstats = {
 		.txok = (u32)-1,
@@ -1448,7 +1435,7 @@ static void wds_callback(struct qcusbnet *dev, u16 cid, void *data)
 		.rxbytesok = (u64)-1,
 	};
 	unsigned long flags;
-	
+
 	if (!device_valid(dev)) {
 		DBG("Invalid device\n");
 		return;
@@ -1456,13 +1443,13 @@ static void wds_callback(struct qcusbnet *dev, u16 cid, void *data)
 
 	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
 	ret = client_delread(dev, cid, 0, &rbuf, &rbufsize);
-	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags); 
-	
+	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
+
 	if (!ret) {
 		DBG("WDS callback failed to get data\n");
 		return;
 	}
-	
+
 	dstats.linkstate = !qc_isdown(dev, DOWN_NO_NDIS_CONNECTION);
 	dstats.reconfigure = false;
 
@@ -1472,25 +1459,25 @@ static void wds_callback(struct qcusbnet *dev, u16 cid, void *data)
 	} else {
 		if (dstats.txofl != (u32)-1)
 			stats->tx_fifo_errors = dstats.txofl;
-		
+
 		if (dstats.rxofl != (u32)-1)
 			stats->rx_fifo_errors = dstats.rxofl;
 
 		if (dstats.txerr != (u32)-1)
 			stats->tx_errors = dstats.txerr;
-		
+
 		if (dstats.rxerr != (u32)-1)
 			stats->rx_errors = dstats.rxerr;
 
 		if (dstats.txok != (u32)-1)
 			stats->tx_packets = dstats.txok + stats->tx_errors;
-		
+
 		if (dstats.rxok != (u32)-1)
 			stats->rx_packets = dstats.rxok + stats->rx_errors;
 
 		if (dstats.txbytesok != (u64)-1)
 			stats->tx_bytes = dstats.txbytesok;
-		
+
 		if (dstats.rxbytesok != (u64)-1)
 			stats->rx_bytes = dstats.rxbytesok;
 
@@ -1516,7 +1503,7 @@ static void wds_callback(struct qcusbnet *dev, u16 cid, void *data)
 		DBG("unable to setup next async read\n");
 }
 
-static int setup_wds_callback(struct qcusbnet * dev)
+static int setup_wds_callback(struct qcusbnet *dev)
 {
 	int result;
 	void *buf;
@@ -1527,7 +1514,7 @@ static int setup_wds_callback(struct qcusbnet * dev)
 		DBG("Invalid device\n");
 		return -EFAULT;
 	}
-	
+
 	result = client_alloc(dev, QMIWDS);
 	if (result < 0)
 		return result;
@@ -1561,8 +1548,8 @@ static int setup_wds_callback(struct qcusbnet * dev)
 	}
 
 	result = usb_control_msg(dev->usbnet->udev,
-	                         usb_sndctrlpipe(dev->usbnet->udev, 0),
-	                         0x22, 0x21, 1, 0, NULL, 0, 100);
+				 usb_sndctrlpipe(dev->usbnet->udev, 0),
+				 0x22, 0x21, 1, 0, NULL, 0, 100);
 	if (result < 0) {
 		DBG("Bad SetControlLineState status %d\n", result);
 		return result;
@@ -1571,12 +1558,12 @@ static int setup_wds_callback(struct qcusbnet * dev)
 	return 0;
 }
 
-static int qmidms_getmeid(struct qcusbnet * dev)
+static int qmidms_getmeid(struct qcusbnet *dev)
 {
 	int result;
-	void * wbuf;
+	void *wbuf;
 	size_t wbufsize;
-	void * rbuf;
+	void *rbuf;
 	u16 rbufsize;
 	u16 cid;
 
diff --git a/drivers/net/usb/qcusbnet/structs.h b/drivers/net/usb/qcusbnet/structs.h
index 0f9f4eb..2999e62 100755
--- a/drivers/net/usb/qcusbnet/structs.h
+++ b/drivers/net/usb/qcusbnet/structs.h
@@ -27,22 +27,15 @@
 #include <linux/cdev.h>
 #include <linux/kthread.h>
 
-#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,24)
-	#include "usbnet.h"
-#else
-	#include <linux/usb/usbnet.h>
-#endif
-
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,25)
-	#include <linux/fdtable.h>
-#else
-	#include <linux/file.h>
-#endif
-
-#define DBG(format, arg...) \
-	if (debug == 1) { \
-		printk(KERN_INFO "QCUSBNet2k::%s " format, __FUNCTION__, ## arg); \
-	}
+#include <linux/usb/usbnet.h>
+
+#include <linux/fdtable.h>
+
+#define DBG(fmt, arg...)						\
+do {									\
+	if (debug == 1)							\
+		printk(KERN_INFO "QCUSBNet2k::%s " fmt, __func__, ##arg); \
+} while (0)
 
 struct qcusbnet;
 
-- 
1.7.3.1.g432b3.dirty

