From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Add Qualcomm Gobi 2000 driver.
Date: Tue, 28 Sep 2010 16:23:03 -0500
Message-ID: <1285708983.4378.48.camel@dcbw.foobar.com>
References: <20100928171026.GB6083@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	mjg59@srcf.ucam.org, jglasgow@google.com, msb@google.com,
	olofj@google.com
To: Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237Ab0I1VUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 17:20:31 -0400
In-Reply-To: <20100928171026.GB6083@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-28 at 13:10 -0400, Elly Jones wrote:
> From: Elizabeth Jones <ellyjones@google.com>
> 
> This driver is a rewrite of the original Qualcomm GPL driver, released as part
> of Qualcomm's "Code Aurora" initiative. The driver has been transformed into
> Linux kernel style and made to use kernel APIs where appropriate; some bugs have
> also been fixed. Note that the device in question requires firmware and a
> firmware loader; the latter has been written by mjg (see
> http://www.codon.org.uk/~mjg59/gobi_loader/).

Also, is there any way you can wrangle Gobi 1000 support out of
Qualcomm?  I tried the driver with a 1000 part when Qualcomm originally
posted the 2K net driver back in June and it resulted in a panic when
the driver didn't get the response it expected.  I suppose I can try
again with this code too, but getting some feedback from Qualcomm that
1K parts might work here would be nice too.

Also, are 3K devices supported by this code?  The 3K net and serial
driver was recently posted on codeaurora.

Dan


> Signed-Off-By: Elizabeth Jones <ellyjones@google.com>
> Signed-Off-By: Jason Glasgow <jglasgow@google.com>
> ---
>  drivers/net/usb/Kconfig              |    6 +
>  drivers/net/usb/Makefile             |    2 +-
>  drivers/net/usb/qcusbnet/Makefile    |    2 +
>  drivers/net/usb/qcusbnet/qcusbnet.c  |  706 +++++++++++++++
>  drivers/net/usb/qcusbnet/qcusbnet.h  |   24 +
>  drivers/net/usb/qcusbnet/qmi.c       |  358 ++++++++
>  drivers/net/usb/qcusbnet/qmi.h       |   67 ++
>  drivers/net/usb/qcusbnet/qmidevice.c | 1621 ++++++++++++++++++++++++++++++++++
>  drivers/net/usb/qcusbnet/qmidevice.h |   36 +
>  drivers/net/usb/qcusbnet/readme.txt  |  118 +++
>  drivers/net/usb/qcusbnet/structs.h   |   99 ++
>  11 files changed, 3038 insertions(+), 1 deletions(-)
>  create mode 100755 drivers/net/usb/qcusbnet/Makefile
>  create mode 100644 drivers/net/usb/qcusbnet/qcusbnet.c
>  create mode 100644 drivers/net/usb/qcusbnet/qcusbnet.h
>  create mode 100755 drivers/net/usb/qcusbnet/qmi.c
>  create mode 100755 drivers/net/usb/qcusbnet/qmi.h
>  create mode 100755 drivers/net/usb/qcusbnet/qmidevice.c
>  create mode 100755 drivers/net/usb/qcusbnet/qmidevice.h
>  create mode 100755 drivers/net/usb/qcusbnet/readme.txt
>  create mode 100755 drivers/net/usb/qcusbnet/structs.h
> 
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index d7b7018..8a210d9 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -406,4 +406,10 @@ config USB_SIERRA_NET
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called sierra_net.
>  
> +config USB_NET_GOBI
> +	tristate "Qualcomm Gobi"
> +	depends on USB_USBNET
> +	help
> +	  Choose this option if you have a Qualcomm Gobi 2000 cellular modem.
> +
>  endmenu
> diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
> index b13a279..f3f702f 100644
> --- a/drivers/net/usb/Makefile
> +++ b/drivers/net/usb/Makefile
> @@ -25,4 +25,4 @@ obj-$(CONFIG_USB_NET_INT51X1)	+= int51x1.o
>  obj-$(CONFIG_USB_CDC_PHONET)	+= cdc-phonet.o
>  obj-$(CONFIG_USB_IPHETH)	+= ipheth.o
>  obj-$(CONFIG_USB_SIERRA_NET)	+= sierra_net.o
> -
> +obj-$(CONFIG_USB_NET_GOBI)      += qcusbnet/
> diff --git a/drivers/net/usb/qcusbnet/Makefile b/drivers/net/usb/qcusbnet/Makefile
> new file mode 100755
> index 0000000..a186c19
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/Makefile
> @@ -0,0 +1,2 @@
> +obj-$(CONFIG_USB_NET_GOBI) += qcusbnet2k.o
> +qcusbnet2k-objs += qcusbnet.o qmidevice.o qmi.o
> diff --git a/drivers/net/usb/qcusbnet/qcusbnet.c b/drivers/net/usb/qcusbnet/qcusbnet.c
> new file mode 100644
> index 0000000..a075b55
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/qcusbnet.c
> @@ -0,0 +1,706 @@
> +/* qcusbnet.c - gobi network device
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#include "structs.h"
> +#include "qmidevice.h"
> +#include "qmi.h"
> +#include "qcusbnet.h"
> +
> +#define DRIVER_VERSION "1.0.110"
> +#define DRIVER_AUTHOR "Qualcomm Innovation Center"
> +#define DRIVER_DESC "QCUSBNet2k"
> +
> +int debug;
> +static struct class *devclass;
> +
> +int qc_suspend(struct usb_interface *iface, pm_message_t event)
> +{
> +	struct usbnet * usbnet;
> +	struct qcusbnet * dev;
> +	
> +	if (!iface)
> +		return -ENOMEM;
> +	
> +#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
> +	usbnet = usb_get_intfdata(iface);
> +#else
> +	usbnet = iface->dev.platform_data;
> +#endif
> +
> +	if (!usbnet || !usbnet->net) {
> +		DBG("failed to get netdevice\n");
> +		return -ENXIO;
> +	}
> +	
> +	dev = (struct qcusbnet *)usbnet->data[0];
> +	if (!dev) {
> +		DBG("failed to get QMIDevice\n");
> +		return -ENXIO;
> +	}
> +
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
> +	if (!usbnet->udev->auto_pm)
> +#else
> +	if (!(event.event & PM_EVENT_AUTO))
> +#endif
> +	{
> +		DBG("device suspended to power level %d\n", 
> +			  event.event);
> +		qc_setdown(dev, DOWN_DRIVER_SUSPENDED);
> +	} else {
> +		DBG("device autosuspend\n");
> +	}
> +	  
> +	if (event.event & PM_EVENT_SUSPEND) {
> +		qc_stopread(dev);
> +		usbnet->udev->reset_resume = 0;
> +		iface->dev.power.power_state.event = event.event;
> +	} else {
> +		usbnet->udev->reset_resume = 1;
> +	}
> +	
> +	return usbnet_suspend(iface, event);
> +}
> +
> +static int qc_resume(struct usb_interface * iface)
> +{
> +	struct usbnet *usbnet;
> +	struct qcusbnet *dev;
> +	int ret;
> +	int oldstate;
> +	
> +	if (iface == 0)
> +		return -ENOMEM;
> +	
> +#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
> +	usbnet = usb_get_intfdata(iface);
> +#else
> +	usbnet = iface->dev.platform_data;
> +#endif
> +
> +	if (!usbnet || !usbnet->net) {
> +		DBG("failed to get netdevice\n");
> +		return -ENXIO;
> +	}
> +	
> +	dev = (struct qcusbnet *)usbnet->data[0];
> +	if (!dev) {
> +		DBG("failed to get QMIDevice\n");
> +		return -ENXIO;
> +	}
> +
> +	oldstate = iface->dev.power.power_state.event;
> +	iface->dev.power.power_state.event = PM_EVENT_ON;
> +	DBG("resuming from power mode %d\n", oldstate);
> +
> +	if (oldstate & PM_EVENT_SUSPEND) {
> +		qc_cleardown(dev, DOWN_DRIVER_SUSPENDED);
> +	
> +		ret = usbnet_resume(iface);
> +		if (ret) {
> +			DBG("usbnet_resume error %d\n", ret);
> +			return ret;
> +		}
> +
> +		ret = qc_startread(dev);
> +		if (ret) {
> +			DBG("qc_startread error %d\n", ret);
> +			return ret;
> +		}
> +
> +		complete(&dev->worker.work);
> +	} else {
> +		DBG("nothing to resume\n");
> +		return 0;
> +	}
> +	
> +	return ret;
> +}
> +
> +static int qcnet_bind(struct usbnet *usbnet, struct usb_interface *iface)
> +{
> +	int numends;
> +	int i;
> +	struct usb_host_endpoint *endpoint = NULL;
> +	struct usb_host_endpoint *in = NULL;
> +	struct usb_host_endpoint *out = NULL;
> +	
> +	if (iface->num_altsetting != 1) {
> +		DBG("invalid num_altsetting %u\n", iface->num_altsetting);
> +		return -EINVAL;
> +	}
> +
> +	if (iface->cur_altsetting->desc.bInterfaceNumber != 0) {
> +		DBG("invalid interface %d\n", 
> +			  iface->cur_altsetting->desc.bInterfaceNumber);
> +		return -EINVAL;
> +	}
> +	
> +	numends = iface->cur_altsetting->desc.bNumEndpoints;
> +	for (i = 0; i < numends; i++) {
> +		endpoint = iface->cur_altsetting->endpoint + i;
> +		if (!endpoint) {
> +			DBG("invalid endpoint %u\n", i);
> +			return -EINVAL;
> +		}
> +		
> +		if (usb_endpoint_dir_in(&endpoint->desc)
> +		&&  !usb_endpoint_xfer_int(&endpoint->desc)) {
> +			in = endpoint;
> +		} else if (!usb_endpoint_dir_out(&endpoint->desc)) {
> +			out = endpoint;
> +		}
> +	}
> +	
> +	if (!in || !out) {
> +		DBG("invalid endpoints\n");
> +		return -EINVAL;
> +	}
> +
> +	if (usb_set_interface(usbnet->udev,
> +	                      iface->cur_altsetting->desc.bInterfaceNumber, 0))	{
> +		DBG("unable to set interface\n");
> +		return -EINVAL;
> +	}
> +
> +	usbnet->in = usb_rcvbulkpipe(usbnet->udev, in->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
> +	usbnet->out = usb_sndbulkpipe(usbnet->udev, out->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
> +
> +	DBG("in %x, out %x\n",
> +	    in->desc.bEndpointAddress, 
> +	    out->desc.bEndpointAddress);
> +
> +#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,23)
> +	iface->dev.platform_data = usbnet;
> +#endif
> +	return 0;
> +}
> +
> +static void qcnet_unbind(struct usbnet *usbnet, struct usb_interface *iface)
> +{
> +	struct qcusbnet *dev = (struct qcusbnet *)usbnet->data[0];
> +
> +	netif_carrier_off(usbnet->net);
> +	qc_deregister(dev);
> +	
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
> +	kfree(usbnet->net->netdev_ops);
> +	usbnet->net->netdev_ops = NULL;
> +#endif
> +
> +#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,23)
> +	iface->dev.platform_data = NULL;
> +#endif
> +
> +	kfree(dev);
> +}
> +
> +static void qcnet_urbhook(struct urb * urb)
> +{
> +	unsigned long flags;
> +	struct worker * worker = urb->context;
> +	if (!worker) {
> +		DBG("bad context\n");
> +		return;
> +	}
> +
> +	if (urb->status) {
> +		DBG("urb finished with error %d\n", urb->status);
> +	}
> +
> +	spin_lock_irqsave(&worker->active_lock, flags);
> +	worker->active = ERR_PTR(-EAGAIN);
> +	spin_unlock_irqrestore(&worker->active_lock, flags);
> +	/* XXX-fix race against qcnet_stop()? */
> +	complete(&worker->work);
> +	usb_free_urb(urb);
> +}
> +
> +static void qcnet_txtimeout(struct net_device *netdev)
> +{
> +	struct list_head *node, *tmp;
> +	struct qcusbnet *dev;
> +	struct worker *worker;
> +	struct urbreq *req;
> +	unsigned long activeflags, listflags;
> +	struct usbnet *usbnet = netdev_priv(netdev);
> +
> +	if (!usbnet || !usbnet->net) {
> +		DBG("failed to get usbnet device\n");
> +		return;
> +	}
> +	
> +	dev = (struct qcusbnet *)usbnet->data[0];
> +	if (!dev) {
> +		DBG("failed to get QMIDevice\n");
> +		return;
> +	}
> +	worker = &dev->worker;
> +
> +	DBG("\n");
> +
> +	spin_lock_irqsave(&worker->active_lock, activeflags);
> +	if (worker->active)
> +		usb_kill_urb(worker->active);
> +	spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +
> +	spin_lock_irqsave(&worker->urbs_lock, listflags);
> +	list_for_each_safe(node, tmp, &worker->urbs) {
> +		req = list_entry(node, struct urbreq, node);
> +		usb_free_urb(req->urb);
> +		list_del(&req->node);
> +		kfree(req);
> +	}
> +	spin_unlock_irqrestore(&worker->urbs_lock, listflags);
> +
> +	complete(&worker->work);
> +}
> +
> +static int qcnet_worker(void *arg)
> +{
> +	struct list_head *node, *tmp;
> +	unsigned long activeflags, listflags;
> +	struct urbreq *req;
> +	int status;
> +	struct usb_device *usbdev;
> +	struct worker *worker = arg;
> +	if (!worker) {
> +		DBG("passed null pointer\n");
> +		return -EINVAL;
> +	}
> +	
> +	usbdev = interface_to_usbdev(worker->iface);
> +
> +	DBG("traffic thread started\n");
> +
> +	while (!kthread_should_stop()) {
> +		wait_for_completion_interruptible(&worker->work);
> +
> +		if (kthread_should_stop()) {
> +			spin_lock_irqsave(&worker->active_lock, activeflags);
> +			if (worker->active) {
> +				usb_kill_urb(worker->active);
> +			}
> +			spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +
> +			spin_lock_irqsave(&worker->urbs_lock, listflags);
> +			list_for_each_safe(node, tmp, &worker->urbs) {
> +				req = list_entry(node, struct urbreq, node);
> +				usb_free_urb(req->urb);
> +				list_del(&req->node);
> +				kfree(req);
> +			}
> +			spin_unlock_irqrestore(&worker->urbs_lock, listflags);
> +
> +			break;
> +		}
> +		
> +		spin_lock_irqsave(&worker->active_lock, activeflags);
> +		if (IS_ERR(worker->active) && PTR_ERR(worker->active) == -EAGAIN) {
> +			worker->active = NULL;
> +			spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +			usb_autopm_put_interface(worker->iface);
> +			spin_lock_irqsave(&worker->active_lock, activeflags);
> +		}
> +
> +		if (worker->active) {
> +			spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +			continue;
> +		}
> +		
> +		spin_lock_irqsave(&worker->urbs_lock, listflags);
> +		if (list_empty(&worker->urbs)) {
> +			spin_unlock_irqrestore(&worker->urbs_lock, listflags);
> +			spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +			continue;
> +		}
> +
> +		req = list_first_entry(&worker->urbs, struct urbreq, node);
> +		list_del(&req->node);
> +		spin_unlock_irqrestore(&worker->urbs_lock, listflags);
> +
> +		worker->active = req->urb;
> +		spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +
> +		status = usb_autopm_get_interface(worker->iface);
> +		if (status < 0) {
> +			DBG("unable to autoresume interface: %d\n", status);
> +			if (status == -EPERM)
> +			{
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
> +				usbdev->auto_pm = 0;
> +#endif
> +				qc_suspend(worker->iface, PMSG_SUSPEND);
> +			}
> +
> +			spin_lock_irqsave(&worker->urbs_lock, listflags);
> +			list_add(&req->node, &worker->urbs);
> +			spin_unlock_irqrestore(&worker->urbs_lock, listflags);
> +			
> +			spin_lock_irqsave(&worker->active_lock, activeflags);
> +			worker->active = NULL;
> +			spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +			
> +			continue;
> +		}
> +
> +		status = usb_submit_urb(worker->active, GFP_KERNEL);
> +		if (status < 0) {
> +			DBG("Failed to submit URB: %d.  Packet dropped\n", status);
> +			spin_lock_irqsave(&worker->active_lock, activeflags);
> +			usb_free_urb(worker->active);
> +			worker->active = NULL;
> +			spin_unlock_irqrestore(&worker->active_lock, activeflags);
> +			usb_autopm_put_interface(worker->iface);
> +			complete(&worker->work);
> +		}
> +		
> +		kfree(req);
> +	}	
> +	
> +	DBG("traffic thread exiting\n");
> +	worker->thread = NULL;
> +	return 0;
> +}
> +
> +static int qcnet_startxmit(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	unsigned long listflags;
> +	struct qcusbnet *dev;
> +	struct worker *worker;
> +	struct urbreq *req;
> +	void *data;
> +	struct usbnet *usbnet = netdev_priv(netdev);
> +	
> +	DBG("\n");
> +	
> +	if (!usbnet || !usbnet->net) {
> +		DBG("failed to get usbnet device\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +	
> +	dev = (struct qcusbnet *)usbnet->data[0];
> +	if (!dev) {
> +		DBG("failed to get QMIDevice\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +	worker = &dev->worker;
> +	
> +	if (qc_isdown(dev, DOWN_DRIVER_SUSPENDED)) {
> +		DBG("device is suspended\n");
> +		dump_stack();
> +		return NETDEV_TX_BUSY;
> +	}
> +	
> +	req = kmalloc(sizeof(*req), GFP_ATOMIC);
> +	if (!req) {
> +		DBG("unable to allocate URBList memory\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	req->urb = usb_alloc_urb(0, GFP_ATOMIC);
> +
> +	if (!req->urb) {
> +		kfree(req);
> +		DBG("unable to allocate URB\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	data = kmalloc(skb->len, GFP_ATOMIC);
> +	if (!data) {
> +		usb_free_urb(req->urb);
> +		kfree(req);
> +		DBG("unable to allocate URB data\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +	memcpy(data, skb->data, skb->len);
> +
> +	usb_fill_bulk_urb(req->urb, dev->usbnet->udev, dev->usbnet->out,
> +	                  data, skb->len, qcnet_urbhook, worker);
> +	
> +	spin_lock_irqsave(&worker->urbs_lock, listflags);
> +	list_add_tail(&req->node, &worker->urbs);
> +	spin_unlock_irqrestore(&worker->urbs_lock, listflags);
> +
> +	complete(&worker->work);
> +
> +	netdev->trans_start = jiffies;
> +	dev_kfree_skb_any(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int qcnet_open(struct net_device *netdev)
> +{
> +	int status = 0;
> +	struct qcusbnet *dev;
> +	struct usbnet *usbnet = netdev_priv(netdev);
> +	
> +	if (!usbnet) {
> +		DBG("failed to get usbnet device\n");
> +		return -ENXIO;
> +	}
> +	
> +	dev = (struct qcusbnet *)usbnet->data[0];
> +	if (!dev) {
> +		DBG("failed to get QMIDevice\n");
> +		return -ENXIO;
> +	}
> +
> +	DBG("\n");
> +
> +	dev->worker.iface = dev->iface;
> +	INIT_LIST_HEAD(&dev->worker.urbs);
> +	dev->worker.active = NULL;
> +	spin_lock_init(&dev->worker.urbs_lock);
> +	spin_lock_init(&dev->worker.active_lock);
> +	init_completion(&dev->worker.work);
> +	
> +	dev->worker.thread = kthread_run(qcnet_worker, &dev->worker, "qcnet_worker");
> +	if (IS_ERR(dev->worker.thread))
> +	{
> +		DBG("AutoPM thread creation error\n");
> +		return PTR_ERR(dev->worker.thread);
> +	}
> +
> +	qc_cleardown(dev, DOWN_NET_IFACE_STOPPED);
> +	if (dev->open)
> +	{
> +		status = dev->open(netdev);
> +		if (status == 0)
> +		{
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
> +			usb_autopm_enable(dev->iface);
> +#else
> +			usb_autopm_put_interface(dev->iface);
> +#endif
> +		}
> +	} else {
> +		DBG("no USBNetOpen defined\n");
> +	}
> +	
> +	return status;
> +}
> +
> +int qcnet_stop(struct net_device *netdev)
> +{
> +	struct qcusbnet *dev;
> +	struct usbnet *usbnet = netdev_priv(netdev);
> +
> +	if (!usbnet || !usbnet->net) {
> +		DBG("failed to get netdevice\n");
> +		return -ENXIO;
> +	}
> +	
> +	dev = (struct qcusbnet *)usbnet->data[0];
> +	if (!dev) {
> +		DBG("failed to get QMIDevice\n");
> +		return -ENXIO;
> +	}
> +
> +	qc_setdown(dev, DOWN_NET_IFACE_STOPPED);
> +	complete(&dev->worker.work);
> +	kthread_stop(dev->worker.thread);
> +	DBG("thread stopped\n");
> +
> +	if (dev->stop != NULL)
> +		return dev->stop(netdev);
> +	return 0;
> +}
> +
> +static const struct driver_info qc_netinfo = 
> +{
> +   .description   = "QCUSBNet Ethernet Device",
> +   .flags         = FLAG_ETHER,
> +   .bind          = qcnet_bind,
> +   .unbind        = qcnet_unbind,
> +   .data          = 0,
> +};
> +
> +#define MKVIDPID(v,p) \
> +	{ \
> +		USB_DEVICE(v,p), \
> +		.driver_info = (unsigned long)&qc_netinfo, \
> +	}
> +
> +static const struct usb_device_id qc_vidpids [] =
> +{
> +	MKVIDPID(0x05c6, 0x9215),	/* Acer Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x9265),	/* Asus Gobi 2000 */
> +	MKVIDPID(0x16d8, 0x8002),	/* CMOTech Gobi 2000 */
> +	MKVIDPID(0x413c, 0x8186),	/* Dell Gobi 2000 */
> +	MKVIDPID(0x1410, 0xa010),	/* Entourage Gobi 2000 */
> +	MKVIDPID(0x1410, 0xa011),	/* Entourage Gobi 2000 */
> +	MKVIDPID(0x1410, 0xa012),	/* Entourage Gobi 2000 */
> +	MKVIDPID(0x1410, 0xa013),	/* Entourage Gobi 2000 */
> +	MKVIDPID(0x03f0, 0x251d),	/* HP Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x9205),	/* Lenovo Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x920b),	/* Generic Gobi 2000 */
> +	MKVIDPID(0x04da, 0x250f),	/* Panasonic Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x9245),	/* Samsung Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9001),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9002),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9003),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9004),	/* Sierra Wireless Gobi 2000 */ 
> +	MKVIDPID(0x1199, 0x9005),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9006),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9007),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9008),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x9009),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x1199, 0x900a),	/* Sierra Wireless Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x9225),	/* Sony Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x9235),	/* Top Global Gobi 2000 */
> +	MKVIDPID(0x05c6, 0x9275),	/* iRex Technologies Gobi 2000 */
> +	{ }
> +};
> +
> +MODULE_DEVICE_TABLE(usb, qc_vidpids);
> +
> +int qcnet_probe(struct usb_interface *iface, const struct usb_device_id *vidpids)
> +{
> +	int status;
> +	struct usbnet *usbnet;
> +	struct qcusbnet *dev;
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29)
> +	struct net_device_ops *netdevops;
> +#endif
> +
> +	status = usbnet_probe(iface, vidpids);
> +	if (status < 0) {
> +		DBG("usbnet_probe failed %d\n", status);
> +		return status;
> +	}
> +
> +#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,23)
> +	usbnet = usb_get_intfdata(iface);
> +#else
> +	usbnet = iface->dev.platform_data;
> +#endif
> +
> +	if (!usbnet || !usbnet->net) {
> +		DBG("failed to get netdevice\n");
> +		return -ENXIO;
> +	}
> +
> +	dev = kmalloc(sizeof(struct qcusbnet), GFP_KERNEL);
> +	if (!dev) {
> +		DBG("falied to allocate device buffers");
> +		return -ENOMEM;
> +	}
> +	
> +	usbnet->data[0] = (unsigned long)dev;
> +	
> +	dev->usbnet = usbnet;
> +
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29)
> +	dev->open = usbnet->net->open;
> +	usbnet->net->open = qcnet_open;
> +	dev->stop = usbnet->net->stop;
> +	usbnet->net->stop = qcnet_stop;
> +	usbnet->net->hard_start_xmit = qcnet_startxmit;
> +	usbnet->net->tx_timeout = qcnet_txtimeout;
> +#else
> +	netdevops = kmalloc(sizeof(struct net_device_ops), GFP_KERNEL);
> +	if (!netdevops) {
> +		DBG("falied to allocate net device ops");
> +		return -ENOMEM;
> +	}
> +	memcpy(netdevops, usbnet->net->netdev_ops, sizeof(struct net_device_ops));
> +	
> +	dev->open = netdevops->ndo_open;
> +	netdevops->ndo_open = qcnet_open;
> +	dev->stop = netdevops->ndo_stop;
> +	netdevops->ndo_stop = qcnet_stop;
> +	netdevops->ndo_start_xmit = qcnet_startxmit;
> +	netdevops->ndo_tx_timeout = qcnet_txtimeout;
> +
> +	usbnet->net->netdev_ops = netdevops;
> +#endif
> +
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,31)
> +	memset(&(dev->usbnet->stats), 0, sizeof(struct net_device_stats));
> +#else
> +	memset(&(dev->usbnet->net->stats), 0, sizeof(struct net_device_stats));
> +#endif
> +
> +	dev->iface = iface;
> +	memset(&(dev->meid), '0', 14);
> +	
> +	DBG("Mac Address:\n");
> +	printhex(&dev->usbnet->net->dev_addr[0], 6);
> +
> +	dev->valid = false;
> +	memset(&dev->qmi, 0, sizeof(struct qmidev));
> +
> +	dev->qmi.devclass = devclass;
> +	
> +	INIT_LIST_HEAD(&dev->qmi.clients);
> +	init_completion(&dev->worker.work);
> +	spin_lock_init(&dev->qmi.clients_lock);
> +
> +	dev->down = 0;
> +	qc_setdown(dev, DOWN_NO_NDIS_CONNECTION);
> +	qc_setdown(dev, DOWN_NET_IFACE_STOPPED);
> +
> +	status = qc_register(dev);
> +	if (status) {
> +		qc_deregister(dev);
> +	}
> +	
> +	return status;
> +}
> +
> +EXPORT_SYMBOL_GPL(qcnet_probe);
> +
> +static struct usb_driver qcusbnet =
> +{
> +	.name       = "QCUSBNet2k",
> +	.id_table   = qc_vidpids,
> +	.probe      = qcnet_probe,
> +	.disconnect = usbnet_disconnect,
> +	.suspend    = qc_suspend,
> +	.resume     = qc_resume,
> +	.supports_autosuspend = true,
> +};
> +
> +static int __init modinit(void)
> +{
> +	devclass = class_create(THIS_MODULE, "QCQMI");
> +	if (IS_ERR(devclass)) {
> +		DBG("error at class_create %ld\n", PTR_ERR(devclass));
> +		return -ENOMEM;
> +	}
> +	printk(KERN_INFO "%s: %s\n", DRIVER_DESC, DRIVER_VERSION);
> +	return usb_register(&qcusbnet);
> +}
> +module_init(modinit);
> +
> +static void __exit modexit(void)
> +{
> +	usb_deregister(&qcusbnet);
> +	class_destroy(devclass);
> +}
> +module_exit(modexit);
> +
> +MODULE_VERSION(DRIVER_VERSION);
> +MODULE_AUTHOR(DRIVER_AUTHOR);
> +MODULE_DESCRIPTION(DRIVER_DESC);
> +MODULE_LICENSE("Dual BSD/GPL");
> +
> +module_param(debug, bool, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(debug, "Debuging enabled or not");
> diff --git a/drivers/net/usb/qcusbnet/qcusbnet.h b/drivers/net/usb/qcusbnet/qcusbnet.h
> new file mode 100644
> index 0000000..2f20868
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/qcusbnet.h
> @@ -0,0 +1,24 @@
> +/* qcusbnet.h - gobi network device header
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#ifndef QCUSBNET_QCUSBNET_H
> +#define QCUSBNET_QCUSBNET_H
> +
> +extern int qc_suspend(struct usb_interface *iface, pm_message_t event);
> +
> +#endif /* !QCUSBNET_QCUSBNET_H */
> diff --git a/drivers/net/usb/qcusbnet/qmi.c b/drivers/net/usb/qcusbnet/qmi.c
> new file mode 100755
> index 0000000..2fc8ce8
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/qmi.c
> @@ -0,0 +1,358 @@
> +/* qmi.c - QMI protocol implementation
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#include "qmi.h"
> +
> +#include <linux/slab.h>
> +
> +struct qmux {
> +	u8 tf;	/* always 1 */
> +	u16 len;
> +	u8 ctrl;
> +	u8 service;
> +	u8 qmicid;
> +} __attribute__((__packed__));
> +
> +struct getcid_req {
> +	struct qmux header;
> +	u8 req;
> +	u8 tid;
> +	u16 msgid;
> +	u16 tlvsize;
> +	u8 service;
> +	u16 size;
> +	u8 qmisvc;
> +} __attribute__((__packed__));
> +
> +struct releasecid_req {
> +	struct qmux header;
> +	u8 req;
> +	u8 tid;
> +	u16 msgid;
> +	u16 tlvsize;
> +	u8 rlscid;
> +	u16 size;
> +	u16 cid;
> +} __attribute__((__packed__));
> +
> +struct ready_req {
> +	struct qmux header;
> +	u8 req;
> +	u8 tid;
> +	u16 msgid;
> +	u16 tlvsize;
> +} __attribute__((__packed__));
> +
> +struct seteventreport_req {
> +	struct qmux header;
> +	u8 req;
> +	u16 tid;
> +	u16 msgid;
> +	u16 tlvsize;
> +	u8 reportchanrate;
> +	u16 size;
> +	u8 period;
> +	u32 mask;
> +} __attribute__((__packed__));
> +
> +struct getpkgsrvcstatus_req {
> +	struct qmux header;
> +	u8 req;
> +	u16 tid;
> +	u16 msgid;
> +	u16 tlvsize;
> +} __attribute__((__packed__));
> +
> +struct getmeid_req {
> +	struct qmux header;
> +	u8 req;
> +	u16 tid;
> +	u16 msgid;
> +	u16 tlvsize;
> +} __attribute__((__packed__));
> +
> +const size_t qmux_size = sizeof(struct qmux);
> +
> +void *qmictl_new_getcid(u8 tid, u8 svctype, size_t *size)
> +{
> +	struct getcid_req *req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		return NULL;
> +	req->req = 0x00;
> +	req->tid = tid;
> +	req->msgid = 0x0022;
> +	req->tlvsize = 0x0004;
> +	req->service = 0x01;
> +	req->size = 0x0001;
> +	req->qmisvc = svctype;
> +	*size = sizeof(*req);
> +	return req;
> +}
> +
> +void *qmictl_new_releasecid(u8 tid, u16 cid, size_t *size)
> +{
> +	struct releasecid_req *req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		return NULL;
> +	req->req = 0x00;
> +	req->tid = tid;
> +	req->msgid = 0x0023;
> +	req->tlvsize = 0x05;
> +	req->rlscid = 0x01;
> +	req->size = 0x0002;
> +	req->cid = cid;
> +	*size = sizeof(*req);
> +	return req;
> +}
> +
> +void *qmictl_new_ready(u8 tid, size_t *size)
> +{
> +	struct ready_req *req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		return NULL;
> +	req->req = 0x00;
> +	req->tid = tid;
> +	req->msgid = 0x21;
> +	req->tlvsize = 0;
> +	*size = sizeof(*req);
> +	return req;
> +}
> +
> +void *qmiwds_new_seteventreport(u8 tid, size_t *size)
> +{
> +	struct seteventreport_req *req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	req->req = 0x00;
> +	req->tid = tid;
> +	req->msgid = 0x0001;
> +	req->tlvsize = 0x0008;
> +	req->reportchanrate = 0x11;
> +	req->size = 0x0005;
> +	req->period = 0x01;
> +	req->mask = 0x000000ff;
> +	*size = sizeof(*req);
> +	return req;
> +}
> +
> +void *qmiwds_new_getpkgsrvcstatus(u8 tid, size_t *size)
> +{
> +	struct getpkgsrvcstatus_req *req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		return NULL;
> +	req->req = 0x00;
> +	req->tid = tid;
> +	req->msgid = 0x22;
> +	req->tlvsize = 0x0000;
> +	*size = sizeof(*req);
> +	return req;
> +}
> +
> +void *qmidms_new_getmeid(u8 tid, size_t *size)
> +{
> +	struct getmeid_req *req = kmalloc(sizeof(*req), GFP_KERNEL);
> +	if (!req)
> +		return NULL;
> +	req->req = 0x00;
> +	req->tid = tid;
> +	req->msgid = 0x25;
> +	req->tlvsize = 0x0000;
> +	*size = sizeof(*req);
> +	return req;
> +}
> +
> +int qmux_parse(u16 *cid, void *buf, size_t size)
> +{
> +	struct qmux *qmux = buf;
> +   
> +	if (!buf || size < 12)
> +		return -ENOMEM;
> +
> +	if (qmux->tf != 1 || qmux->len != size - 1 || qmux->ctrl != 0x80)
> +		return -EINVAL;
> +
> +	*cid = (qmux->qmicid << 8) + qmux->service;
> +	return sizeof(*qmux);
> +}
> +
> +int qmux_fill(u16 cid, void *buf, size_t size)
> +{
> +	struct qmux *qmux = buf;
> +
> +	if (!buf || size < sizeof(*qmux))
> +		return -ENOMEM;
> +
> +	qmux->tf = 1;
> +	qmux->len = size - 1;
> +	qmux->ctrl = 0;
> +	qmux->service = cid & 0xff;
> +	qmux->qmicid = cid >> 8;
> +	return 0;
> +}
> +
> +static u16 tlv_get(void *msg, u16 msgsize, u8 type, void *buf, u16 bufsize) {
> +	u16 pos;
> +	u16 msize = 0;
> +	
> +	if (!msg || !buf)
> +		return -ENOMEM;
> +	
> +	for (pos = 4;  pos + 3 < msgsize; pos += msize + 3) {
> +		msize = *(u16 *)(msg + pos + 1);
> +		if (*(u8 *)(msg + pos) == type) {
> +			if (bufsize < msize)
> +				return -ENOMEM;
> +
> +			memcpy(buf, msg + pos + 3, msize);
> +			return msize;
> +		}
> +	}
> +	
> +	return -ENOMSG;
> +}
> +
> +int qmi_msgisvalid(void *msg, u16 size)
> +{
> +	char tlv[4];
> +
> +	if (tlv_get(msg, size, 2, &tlv[0], 4) == 4) {
> +		if (*(u16 *)&tlv[0] != 0)
> +			return *(u16 *)&tlv[2];
> +		else
> +			return 0;
> +	}
> +	return -ENOMSG;
> +}
> +
> +int qmi_msgid(void *msg, u16 size)
> +{
> +	return size < 2 ? -ENODATA : *(u16 *)msg;
> +}
> +
> +int qmictl_alloccid_resp(void *buf, u16 size, u16 *cid)
> +{
> +	int result;
> +	u8 offset = sizeof(struct qmux) + 2;
> +
> +	if (!buf || size < offset)
> +		return -ENOMEM;
> +
> +	buf = buf + offset;
> +	size -= offset;
> +
> +	result = qmi_msgid(buf, size);
> +	if (result != 0x22)
> +		return -EFAULT;
> +
> +	result = qmi_msgisvalid(buf, size);
> +	if (result != 0)
> +		return -EFAULT;
> +
> +	result = tlv_get(buf, size, 0x01, cid, 2);
> +	if (result != 2)
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
> +int qmictl_freecid_resp(void *buf, u16 size)
> +{
> +	int result;
> +	u8 offset = sizeof(struct qmux) + 2;
> +
> +	if (!buf || size < offset)
> +		return -ENOMEM;
> +
> +	buf = buf + offset;
> +	size -= offset;
> +
> +	result = qmi_msgid(buf, size);
> +	if (result != 0x23)
> +		return -EFAULT;
> +
> +	result = qmi_msgisvalid(buf, size);
> +	if (result != 0)
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
> +int qmiwds_event_resp(void *buf, u16 size, struct qmiwds_stats *stats)
> +{
> +	int result;
> +	u8 status[2];
> +
> +	u8 offset = sizeof(struct qmux) + 3;
> +
> +	if (!buf || size < offset || !stats)
> +		return -ENOMEM;
> +
> +	buf = buf + offset;
> +	size -= offset;
> +
> +	result = qmi_msgid(buf, size);
> +	if (result == 0x01) {
> +		tlv_get(buf, size, 0x10, (void*)&stats->txok, 4);
> +		tlv_get(buf, size, 0x11, (void*)&stats->rxok, 4);
> +		tlv_get(buf, size, 0x12, (void*)&stats->txerr, 4);
> +		tlv_get(buf, size, 0x13, (void*)&stats->rxerr, 4);
> +		tlv_get(buf, size, 0x14, (void*)&stats->txofl, 4);
> +		tlv_get(buf, size, 0x15, (void*)&stats->rxofl, 4);
> +		tlv_get(buf, size, 0x19, (void*)&stats->txbytesok, 8);
> +		tlv_get(buf, size, 0x1A, (void*)&stats->rxbytesok, 8);
> +	} else if (result == 0x22) {
> +		result = tlv_get(buf, size, 0x01, &status[0], 2);
> +		if (result >= 1)
> +			stats->linkstate = status[0] == 0x02;
> +		if (result == 2)
> +			stats->reconfigure = status[1] == 0x01;
> +		
> +		if (result < 0)
> +			return result;
> +	} else {
> +		return -EFAULT;
> +	}
> +
> +	return 0;
> +}
> +
> +int qmidms_meid_resp(void *buf,	u16 size, char *meid, int meidsize)
> +{
> +	int result;
> +
> +	u8 offset = sizeof(struct qmux) + 3;
> +
> +	if (!buf || size < offset || meidsize < 14)
> +		return -ENOMEM;
> +
> +	buf = buf + offset;
> +	size -= offset;
> +
> +	result = qmi_msgid(buf, size);
> +	if (result != 0x25)
> +		return -EFAULT;
> +
> +	result = qmi_msgisvalid(buf, size);
> +	if (result)
> +		return -EFAULT;
> +
> +	result = tlv_get(buf, size, 0x12, (void*)meid, 14);
> +	if (result != 14)
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
> diff --git a/drivers/net/usb/qcusbnet/qmi.h b/drivers/net/usb/qcusbnet/qmi.h
> new file mode 100755
> index 0000000..7954790
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/qmi.h
> @@ -0,0 +1,67 @@
> +/* qmi.h - QMI protocol header
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#ifndef QCUSBNET_QMI_H
> +#define QCUSBNET_QMI_H
> +
> +#include <linux/types.h>
> +
> +#define QMICTL 0
> +#define QMIWDS 1
> +#define QMIDMS 2
> +
> +#define true      1
> +#define false     0
> +
> +#define ENOMEM    12
> +#define EFAULT    14
> +#define EINVAL    22
> +#define ENOMSG    42
> +#define ENODATA   61
> +
> +int qmux_parse(u16 *cid, void *buf, size_t size);
> +int qmux_fill(u16 cid, void *buf, size_t size);
> +
> +extern const size_t qmux_size;
> +
> +void *qmictl_new_getcid(u8 tid, u8 svctype, size_t *size);
> +void *qmictl_new_releasecid(u8 tid, u16 cid, size_t *size);
> +void *qmictl_new_ready(u8 tid, size_t *size);
> +void *qmiwds_new_seteventreport(u8 tid, size_t *size);
> +void *qmiwds_new_getpkgsrvcstatus(u8 tid, size_t *size);
> +void *qmidms_new_getmeid(u8 tid, size_t *size);
> +
> +struct qmiwds_stats {
> +	u32 txok;
> +	u32 rxok;
> +	u32 txerr;
> +	u32 rxerr;
> +	u32 txofl;
> +	u32 rxofl;
> +	u64 txbytesok;
> +	u64 rxbytesok;
> +	bool linkstate;
> +	bool reconfigure;
> +};
> +
> +int qmictl_alloccid_resp(void *buf, u16 size, u16 *cid);
> +int qmictl_freecid_resp(void *buf, u16 size);
> +int qmiwds_event_resp(void *buf, u16 size, struct qmiwds_stats *stats);
> +int qmidms_meid_resp(void *buf, u16 size, char *meid, int meidsize);
> +
> +#endif /* !QCUSBNET_QMI_H */
> diff --git a/drivers/net/usb/qcusbnet/qmidevice.c b/drivers/net/usb/qcusbnet/qmidevice.c
> new file mode 100755
> index 0000000..b5006be
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/qmidevice.c
> @@ -0,0 +1,1621 @@
> +/* qmidevice.c - gobi QMI device
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#include "qmidevice.h"
> +#include "qcusbnet.h"
> +
> +struct readreq {
> +	struct list_head node;
> +	void *data;
> +	u16 tid;
> +	u16 size;
> +};
> +
> +struct notifyreq {
> +	struct list_head node;
> +	void (* func)(struct qcusbnet *, u16, void *);
> +	u16  tid;
> +	void *data;
> +};
> +
> +struct client {
> +	struct list_head node;
> +	u16 cid;
> +	struct list_head reads;
> +	struct list_head notifies;
> +	struct list_head urbs;
> +};
> +
> +struct urbsetup {
> +	u8 type;
> +	u8 code;
> +	u16 value;
> +	u16 index;
> +	u16 len;
> +};
> +
> +struct qmihandle {
> +	u16 cid;
> +	struct qcusbnet *dev;
> +};
> +
> +extern int debug;
> +static int qcusbnet2k_fwdelay = 0;
> +
> +static bool device_valid(struct qcusbnet *dev);
> +static struct client *client_bycid(struct qcusbnet *dev, u16 cid);
> +static bool client_addread(struct qcusbnet *dev, u16 cid, u16 tid, void *data, u16 size);
> +static bool client_delread(struct qcusbnet *dev, u16 cid, u16 tid, void **data, u16 *size);
> +static bool client_addnotify(struct qcusbnet *dev, u16 cid, u16 tid,
> +                             void (*hook)(struct qcusbnet *, u16 cid, void *),
> +                             void *data);
> +static bool client_notify(struct qcusbnet *dev, u16 cid, u16 tid);
> +static bool client_addurb(struct qcusbnet *dev, u16 cid, struct urb *urb);
> +static struct urb *client_delurb(struct qcusbnet *dev, u16 cid);
> +
> +static int devqmi_open(struct inode *inode, struct file *file);
> +static long devqmi_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
> +static int devqmi_close(struct file *file, fl_owner_t ftable);
> +static ssize_t devqmi_read(struct file *file, char __user *buf, size_t size,
> +                           loff_t *pos);
> +static ssize_t devqmi_write(struct file *file, const char __user *buf,
> +                            size_t size, loff_t *pos);
> +
> +static bool qmi_ready(struct qcusbnet *dev, u16 timeout);
> +static void wds_callback(struct qcusbnet *dev, u16 cid, void *data);
> +static int setup_wds_callback(struct qcusbnet *dev);
> +static int qmidms_getmeid(struct qcusbnet *dev);
> +
> +#define IOCTL_QMI_GET_SERVICE_FILE 0x8BE0 + 1
> +#define IOCTL_QMI_GET_DEVICE_VIDPID 0x8BE0 + 2
> +#define IOCTL_QMI_GET_DEVICE_MEID 0x8BE0 + 3
> +#define CDC_GET_ENCAPSULATED_RESPONSE 0x01A1ll
> +#define CDC_CONNECTION_SPEED_CHANGE 0x08000000002AA1ll
> +
> +struct file_operations devqmi_fops = 
> +{
> +	.owner = THIS_MODULE,
> +	.read  = devqmi_read,
> +	.write = devqmi_write,
> +	.unlocked_ioctl = devqmi_ioctl,
> +	.open  = devqmi_open,
> +	.flush = devqmi_close,
> +};
> +
> +#ifdef CONFIG_SMP
> +static inline void assert_locked(struct qcusbnet *dev)
> +{
> +	BUG_ON(!spin_is_locked(&dev->qmi.clients_lock));
> +}
> +#else
> +static inline void assert_locked(struct qcusbnet *dev)
> +{
> +
> +}
> +#endif
> +
> +static bool device_valid(struct qcusbnet *dev)
> +{
> +	return dev && dev->valid;
> +} 
> +
> +void printhex(const void *data, size_t size)
> +{
> +	const u8 *cdata = data;
> +	char *buf;
> +	size_t pos;
> +
> +	buf = kmalloc(size * 3 + 1, GFP_ATOMIC);
> +	if (!buf) {
> +		DBG("Unable to allocate buffer\n");
> +		return;
> +	}
> +
> +	memset(buf, 0 , size * 3 + 1);
> +
> +	for (pos = 0; pos < size; pos++) {
> +		snprintf(buf + (pos * 3), 4, "%02X ", cdata[pos]);
> +	}
> +
> +	DBG( "   : %s\n", buf);
> +
> +	kfree(buf);
> +}
> +
> +void qc_setdown(struct qcusbnet *dev, u8 reason)
> +{
> +	set_bit(reason, &dev->down);
> +	netif_carrier_off(dev->usbnet->net);
> +}
> +
> +void qc_cleardown(struct qcusbnet *dev, u8 reason)
> +{
> +	clear_bit(reason, &dev->down);
> +	if (!dev->down)
> +		netif_carrier_on(dev->usbnet->net);
> +}
> +
> +bool qc_isdown(struct qcusbnet *dev, u8 reason)
> +{
> +	return test_bit(reason, &dev->down);
> +}
> +
> +static void read_callback(struct urb *urb)
> +{
> +	struct list_head *node;
> +	int result;
> +	u16 cid;
> +	struct client *client;
> +	void *data;
> +	void *copy;
> +	u16 size;
> +	struct qcusbnet *dev;
> +	unsigned long flags;
> +	u16 tid;
> +
> +	if (!urb) {
> +		DBG("bad read URB\n");
> +		return;
> +	}
> +
> +	dev = urb->context;
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return;
> +	}
> +
> +	if (urb->status) {
> +		DBG("Read status = %d\n", urb->status);
> +		return;
> +	}
> +
> +	DBG("Read %d bytes\n", urb->actual_length);
> +
> +	data = urb->transfer_buffer;
> +	size = urb->actual_length;
> +
> +	printhex(data, size);
> +
> +	result = qmux_parse(&cid, data, size);
> +	if (result < 0) {
> +		DBG("Read error parsing QMUX %d\n", result);
> +		return;
> +	}
> +
> +	if (size < result + 3) {
> +		DBG("Data buffer too small to parse\n");
> +		return;
> +	}
> +
> +	if (cid == QMICTL)
> +		tid = *(u8*)(data + result + 1);
> +	else
> +		tid = *(u16*)(data + result + 1);
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +
> +	list_for_each(node, &dev->qmi.clients) {
> +		client = list_entry(node, struct client, node);
> +		if (client->cid == cid || (client->cid | 0xff00) == cid) {
> +			copy = kmalloc(size, GFP_ATOMIC);
> +			memcpy(copy, data, size);
> +			if (!client_addread(dev, client->cid, tid, copy, size)) {
> +				DBG("Error allocating pReadMemListEntry "
> +					  "read will be discarded\n");
> +				kfree(copy);
> +				spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +				return;
> +			}
> +
> +			DBG("Creating new readListEntry for client 0x%04X, TID %x\n",
> +			    cid, tid);
> +
> +			client_notify(dev, client->cid, tid);
> +
> +			if (cid >> 8 != 0xff)
> +				break;
> +		}
> +	}
> +	
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +}
> +
> +static void int_callback(struct urb *urb)
> +{
> +	int status;
> +	int interval;
> +	struct qcusbnet *dev = (struct qcusbnet *)urb->context;
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return;
> +	}
> +
> +	if (urb->status) {
> +		DBG("Int status = %d\n", urb->status);
> +		if (urb->status != -EOVERFLOW)
> +			return;
> +	} else {
> +		if ((urb->actual_length == 8)
> +		&&  (*(u64*)urb->transfer_buffer == CDC_GET_ENCAPSULATED_RESPONSE)) {
> +			usb_fill_control_urb(dev->qmi.readurb, dev->usbnet->udev,
> +			                     usb_rcvctrlpipe(dev->usbnet->udev, 0),
> +			                     (unsigned char *)dev->qmi.readsetup,
> +			                     dev->qmi.readbuf,
> +			                     DEFAULT_READ_URB_LENGTH,
> +			                     read_callback, dev);
> +			status = usb_submit_urb(dev->qmi.readurb, GFP_ATOMIC);
> +			if (status) {
> +				DBG("Error submitting Read URB %d\n", status);
> +				return;
> +			}
> +		} else if ((urb->actual_length == 16)
> +		&& (*(u64*)urb->transfer_buffer == CDC_CONNECTION_SPEED_CHANGE)) {
> +			/* if upstream or downstream is 0, stop traffic.
> +			 * Otherwise resume it */
> +			if ((*(u32*)(urb->transfer_buffer + 8) == 0)
> +			||  (*(u32*)(urb->transfer_buffer + 12) == 0)) {
> +				qc_setdown(dev, DOWN_CDC_CONNECTION_SPEED);
> +				DBG("traffic stopping due to CONNECTION_SPEED_CHANGE\n");
> +			} else {
> +				qc_cleardown(dev, DOWN_CDC_CONNECTION_SPEED);
> +				DBG("resuming traffic due to CONNECTION_SPEED_CHANGE\n");
> +			}
> +		} else {
> +			DBG("ignoring invalid interrupt in packet\n");
> +			printhex(urb->transfer_buffer, urb->actual_length);
> +		}
> +	}
> +
> +	interval = (dev->usbnet->udev->speed == USB_SPEED_HIGH) ? 7 : 3;
> +
> +	usb_fill_int_urb(urb, urb->dev,	urb->pipe, urb->transfer_buffer,
> +	                 urb->transfer_buffer_length, urb->complete,
> +	                 urb->context, interval);
> +	status = usb_submit_urb(urb, GFP_ATOMIC);
> +	if (status)
> +		DBG("Error re-submitting Int URB %d\n", status);
> +	return;
> +}
> +
> +int qc_startread(struct qcusbnet *dev)
> +{
> +	int interval;
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return -ENXIO;
> +	}
> +	
> +	dev->qmi.readurb = usb_alloc_urb(0, GFP_KERNEL);
> +	if (!dev->qmi.readurb) {
> +		DBG("Error allocating read urb\n");
> +		return -ENOMEM;
> +	}
> +	
> +	dev->qmi.inturb = usb_alloc_urb(0, GFP_KERNEL);
> +	if (!dev->qmi.inturb) {
> +		usb_free_urb(dev->qmi.readurb);
> +		DBG("Error allocating int urb\n");
> +		return -ENOMEM;
> +	}
> +
> +	dev->qmi.readbuf = kmalloc(DEFAULT_READ_URB_LENGTH, GFP_KERNEL);
> +	if (!dev->qmi.readbuf) {
> +		usb_free_urb(dev->qmi.readurb);
> +		usb_free_urb(dev->qmi.inturb);
> +		DBG("Error allocating read buffer\n");
> +		return -ENOMEM;
> +	}
> +	
> +	dev->qmi.intbuf = kmalloc(DEFAULT_READ_URB_LENGTH, GFP_KERNEL);
> +	if (!dev->qmi.intbuf) {
> +		usb_free_urb(dev->qmi.readurb);
> +		usb_free_urb(dev->qmi.inturb);
> +		kfree(dev->qmi.readbuf);
> +		DBG("Error allocating int buffer\n");
> +		return -ENOMEM;
> +	}		
> +	
> +	dev->qmi.readsetup = kmalloc(sizeof(*dev->qmi.readsetup), GFP_KERNEL);
> +	if (!dev->qmi.readsetup) {
> +		usb_free_urb(dev->qmi.readurb);
> +		usb_free_urb(dev->qmi.inturb);
> +		kfree(dev->qmi.readbuf);
> +		kfree(dev->qmi.intbuf);
> +		DBG("Error allocating setup packet buffer\n");
> +		return -ENOMEM;
> +	}
> +
> +	dev->qmi.readsetup->type = 0xA1;
> +	dev->qmi.readsetup->code = 1;
> +	dev->qmi.readsetup->value = 0;
> +	dev->qmi.readsetup->index = 0;
> +	dev->qmi.readsetup->len = DEFAULT_READ_URB_LENGTH;
> +
> +	interval = (dev->usbnet->udev->speed == USB_SPEED_HIGH) ? 7 : 3;
> +	
> +	usb_fill_int_urb(dev->qmi.inturb, dev->usbnet->udev,
> +	                 usb_rcvintpipe(dev->usbnet->udev, 0x81),
> +	                 dev->qmi.intbuf, DEFAULT_READ_URB_LENGTH,
> +	                 int_callback, dev, interval);
> +	return usb_submit_urb(dev->qmi.inturb, GFP_KERNEL);
> +}
> +
> +void qc_stopread(struct qcusbnet * dev)
> +{
> +	if (dev->qmi.readurb) {
> +		DBG("Killng read URB\n");
> +		usb_kill_urb(dev->qmi.readurb);
> +	}
> +
> +	if (dev->qmi.inturb) {
> +		DBG("Killng int URB\n");
> +		usb_kill_urb(dev->qmi.inturb);
> +	}
> +
> +	kfree(dev->qmi.readsetup);
> +	dev->qmi.readsetup = NULL;
> +	kfree(dev->qmi.readbuf);
> +	dev->qmi.readbuf = NULL;
> +	kfree(dev->qmi.intbuf);
> +	dev->qmi.intbuf = NULL;
> +	
> +	usb_free_urb(dev->qmi.readurb);
> +	dev->qmi.readurb = NULL;
> +	usb_free_urb(dev->qmi.inturb);
> +	dev->qmi.inturb = NULL;
> +}
> +
> +static int read_async(struct qcusbnet *dev, u16 cid, u16 tid,
> +                      void (*hook)(struct qcusbnet*, u16, void *), void *data)
> +{
> +	struct list_head *node;
> +	struct client *client;
> +	struct readreq *readreq;
> +	
> +	unsigned long flags;
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return -ENXIO;
> +	}
> +
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find matching client ID 0x%04X\n", cid);
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +		return -ENXIO;
> +	}
> +
> +	list_for_each(node, &client->reads) {
> +		readreq = list_entry(node, struct readreq, node);
> +		if (!tid || tid == readreq->tid) {
> +			spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +			hook(dev, cid, data);
> +			return 0;
> +		}
> +	}
> +
> +	if (!client_addnotify(dev, cid, tid, hook, data))
> +		DBG("Unable to register for notification\n");
> +
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +	return 0;
> +}
> +
> +static void upsem(struct qcusbnet *dev, u16 cid, void *data) 
> +{
> +	DBG("0x%04X\n", cid);
> +	up((struct semaphore *)data);
> +}
> +
> +static int read_sync(struct qcusbnet *dev, void **buf, u16 cid, u16 tid)
> +{
> +	struct list_head *node;
> +	int result;
> +	struct client * client;
> +	struct notifyreq *notify;
> +	struct semaphore sem;
> +	void * data;
> +	unsigned long flags;
> +	u16 size;
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return -ENXIO;
> +	}
> +	
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find matching client ID 0x%04X\n", cid);
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +		return -ENXIO;
> +	}
> +	
> +	while (!client_delread(dev, cid, tid, &data, &size)) {
> +		sema_init(&sem, 0);
> +		if (!client_addnotify(dev, cid, tid, upsem, &sem)) {
> +			DBG("unable to register for notification\n");
> +			spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +			return -EFAULT;
> +		}
> +
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +
> +		result = down_interruptible(&sem);
> +		if (result) {
> +			DBG("Interrupted %d\n", result);
> +			spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +			list_for_each(node, &client->notifies) {
> +				notify = list_entry(node, struct notifyreq, node);
> +				if (notify->data == &sem) {
> +					list_del(&notify->node);
> +					kfree(notify);
> +					break;
> +				}
> +			}
> +
> +			spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +			return -EINTR;
> +		}
> +		
> +		if (!device_valid(dev)) {
> +			DBG("Invalid device!\n");
> +			return -ENXIO;
> +		}
> +		
> +		spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +	}
> +	
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +	*buf = data;
> +	return size;
> +}
> +
> +static void write_callback(struct urb *urb)
> +{
> +	if (!urb) {
> +		DBG("null urb\n");
> +		return;
> +	}
> +
> +	DBG("Write status/size %d/%d\n", urb->status, urb->actual_length);
> +	up((struct semaphore *)urb->context);
> +}
> +
> +static int write_sync(struct qcusbnet *dev, char *buf, int size, u16 cid)
> +{
> +	int result;
> +	struct semaphore sem;
> +	struct urb *urb;
> +	struct urbsetup setup;
> +	unsigned long flags;
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return -ENXIO;
> +	}
> +
> +	urb = usb_alloc_urb(0, GFP_KERNEL);
> +	if (!urb) {
> +		DBG("URB mem error\n");
> +		return -ENOMEM;
> +	}
> +
> +	result = qmux_fill(cid, buf, size);
> +	if (result < 0) {
> +		usb_free_urb(urb);
> +		return result;
> +	}
> +
> +	/* CDC Send Encapsulated Request packet */
> +	setup.type = 0x21;
> +	setup.code = 0;
> +	setup.value = 0;
> +	setup.index = 0;
> +	setup.len = 0;
> +	setup.len = size;
> +
> +	usb_fill_control_urb(urb, dev->usbnet->udev,
> +	                     usb_sndctrlpipe(dev->usbnet->udev, 0),
> +	                     (unsigned char *)&setup, (void*)buf, size,
> +	                     NULL, dev);
> +
> +	DBG("Actual Write:\n");
> +	printhex(buf, size);
> +
> +	sema_init(&sem, 0);
> +	
> +	urb->complete = write_callback;
> +	urb->context = &sem;
> +	
> +	result = usb_autopm_get_interface(dev->iface);
> +	if (result < 0) {
> +		DBG("unable to resume interface: %d\n", result);
> +		if (result == -EPERM) {
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,33)
> +			dev->usbnet->udev->auto_pm = 0;
> +#endif
> +			qc_suspend(dev->iface, PMSG_SUSPEND);
> +		}
> +		return result;
> +	}
> +
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +
> +	if (!client_addurb(dev, cid, urb)) {
> +		usb_free_urb(urb);
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
> +		usb_autopm_put_interface(dev->iface);
> +		return -EINVAL;
> +	}
> +
> +	result = usb_submit_urb(urb, GFP_KERNEL);
> +	if (result < 0)	{
> +		DBG("submit URB error %d\n", result);
> +		if (client_delurb(dev, cid) != urb) {
> +			DBG("Didn't get write URB back\n");
> +		}
> +
> +		usb_free_urb(urb);
> +
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +		usb_autopm_put_interface(dev->iface);
> +		return result;
> +	}
> +	
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
> +	result = down_interruptible(&sem);
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return -ENXIO;
> +	}
> +
> +	usb_autopm_put_interface(dev->iface);
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +	if (client_delurb(dev, cid) != urb)
> +	{
> +		DBG("Didn't get write URB back\n");
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
> +		return -EINVAL;
> +	}
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);	
> +
> +	if (!result) {
> +		if (!urb->status) {
> +			result = size;
> +		} else {
> +			DBG("bad status = %d\n", urb->status);
> +			result = urb->status;
> +		}
> +	} else {
> +		DBG("Interrupted %d !!!\n", result);
> +		DBG("Device may be in bad state and need reset !!!\n");
> +		usb_kill_urb(urb);
> +	}
> +
> +	usb_free_urb(urb);
> +	return result;
> +}
> +
> +static int client_alloc(struct qcusbnet *dev, u8 type)
> +{
> +	u16 cid;
> +	struct client *client;
> +	int result;
> +	void * wbuf;
> +	size_t wbufsize;
> +	void * rbuf;
> +	u16 rbufsize;
> +	unsigned long flags;
> +	u8 tid;
> +	
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device!\n");
> +		return -ENXIO;
> +	}
> +
> +	if (type) {
> +		tid = atomic_add_return(1, &dev->qmi.qmitid);
> +		if (!tid)
> +			atomic_add_return(1, &dev->qmi.qmitid);
> +		wbuf = qmictl_new_getcid(tid, type, &wbufsize);
> +		if (!wbuf)
> +			return -ENOMEM;
> +		result = write_sync(dev, wbuf, wbufsize, QMICTL);
> +		kfree(wbuf);
> +
> +		if (result < 0)
> +			return result;
> +
> +		result = read_sync(dev, &rbuf, QMICTL, tid);
> +		if (result < 0) {
> +			DBG("bad read data %d\n", result);
> +			return result;
> +		}
> +		rbufsize = result;
> +
> +		result = qmictl_alloccid_resp(rbuf, rbufsize, &cid);
> +		kfree(rbuf);
> +
> +		if (result < 0)
> +			return result;
> +	} else {
> +		cid = 0;
> +	}
> +
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +	if (client_bycid(dev, cid)) {
> +		DBG("Client memory already exists\n");
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +		return -ETOOMANYREFS;
> +	}
> +
> +	client = kmalloc(sizeof(*client), GFP_ATOMIC);
> +	if (!client) {
> +		DBG("Error allocating read list\n");
> +		spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +		return -ENOMEM;
> +	}
> +
> +	list_add_tail(&client->node, &dev->qmi.clients);
> +	client->cid = cid;
> +	INIT_LIST_HEAD(&client->reads);
> +	INIT_LIST_HEAD(&client->notifies);
> +	INIT_LIST_HEAD(&client->urbs);
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +	return cid;
> +}
> +
> +static void client_free(struct qcusbnet *dev, u16 cid)
> +{
> +	struct list_head *node, *tmp;
> +	int result;
> +	struct client *client;
> +	struct urb * urb;
> +	void * data;
> +	u16 size;
> +	void * wbuf;
> +	size_t wbufsize;
> +	void * rbuf;
> +	u16 rbufsize;
> +	unsigned long flags;
> +	u8 tid;
> +
> +	if (!device_valid(dev)) {
> +		DBG("invalid device\n");
> +		return;
> +	}
> +	
> +	DBG("releasing 0x%04X\n", cid);
> +
> +	if (cid != QMICTL)
> +	{
> +		tid = atomic_add_return(1, &dev->qmi.qmitid);
> +		if (!tid)
> +			tid = atomic_add_return(1, &dev->qmi.qmitid);
> +		wbuf = qmictl_new_releasecid(tid, cid, &wbufsize);
> +		if (!wbuf) {
> +			DBG("memory error\n");
> +		} else {
> +			result = write_sync(dev, wbuf, wbufsize, QMICTL);
> +			kfree(wbuf);
> +
> +			if (result < 0) {
> +				DBG("bad write status %d\n", result);
> +			} else {
> +				result = read_sync(dev, &rbuf, QMICTL, tid);
> +				if (result < 0) {
> +					DBG("bad read status %d\n", result);
> +				} else {
> +					rbufsize = result;
> +					result = qmictl_freecid_resp(rbuf, rbufsize);
> +					kfree(rbuf);
> +					if (result < 0)
> +						DBG("error %d parsing response\n", result);
> +				}
> +			}
> +		}
> +	}
> +
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +	list_for_each_safe(node, tmp, &dev->qmi.clients) {
> +		client = list_entry(node, struct client, node);
> +		if (client->cid == cid) {
> +			while (client_notify(dev, cid, 0));
> +
> +			urb = client_delurb(dev, cid);
> +			while (urb != NULL) {
> +				usb_kill_urb(urb);
> +				usb_free_urb(urb);
> +				urb = client_delurb(dev, cid);
> +			}
> +
> +			while (client_delread(dev, cid, 0, &data, &size))
> +				kfree(data);
> +
> +			list_del(&client->node);
> +			kfree(client);
> +		}
> +	}
> +	
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +}
> +
> +struct client *client_bycid(struct qcusbnet *dev, u16 cid)
> +{
> +	struct list_head *node;
> +	struct client *client;
> +	
> +	if (!device_valid(dev))	{
> +		DBG("Invalid device\n");
> +		return NULL;
> +	}
> +
> +	assert_locked(dev);	
> +	
> +	list_for_each(node, &dev->qmi.clients) {
> +		client = list_entry(node, struct client, node);
> +		if (client->cid == cid)
> +			return client;
> +	}
> +
> +	DBG("Could not find client mem 0x%04X\n", cid);
> +	return NULL;
> +}
> +
> +static bool client_addread(struct qcusbnet *dev, u16 cid, u16 tid, void *data,
> +                           u16 size)
> +{
> +	struct client *client;
> +	struct readreq *req;
> +
> +	assert_locked(dev);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find this client's memory 0x%04X\n", cid);
> +		return false;
> +	}
> +
> +	req = kmalloc(sizeof(*req), GFP_ATOMIC);
> +	if (!req) {
> +		DBG("Mem error\n");
> +		return false;
> +	}
> +
> +	req->data = data;
> +	req->size = size;
> +	req->tid = tid;
> +
> +	list_add_tail(&req->node, &client->reads);
> +	
> +	return true;
> +}
> +
> +static bool client_delread(struct qcusbnet *dev, u16 cid, u16 tid, void **data,
> +                           u16 *size)
> +{
> +	struct client *client;
> +	struct readreq *req;
> +	struct list_head *node;
> +
> +	assert_locked(dev);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find this client's memory 0x%04X\n", cid);
> +		return false;
> +	}
> +	
> +	list_for_each(node, &client->reads) {
> +		req = list_entry(node, struct readreq, node);
> +		if (!tid || tid == req->tid) {
> +			*data = req->data;
> +			*size = req->size;
> +			list_del(&req->node);
> +			kfree(req);
> +			return true;
> +		}
> +		
> +		DBG("skipping 0x%04X data TID = %x\n", cid, req->tid);
> +	}
> +	
> +	DBG("No read memory to pop, Client 0x%04X, TID = %x\n", cid, tid);
> +	return false;
> +}
> +
> +static bool client_addnotify(struct qcusbnet *dev, u16 cid, u16 tid,
> +                      void (*hook)(struct qcusbnet *, u16, void *),
> +                      void *data)
> +{
> +	struct client *client;
> +	struct notifyreq *req;
> +
> +	assert_locked(dev);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find this client's memory 0x%04X\n", cid);
> +		return false;
> +	}
> +
> +	req = kmalloc(sizeof(*req), GFP_ATOMIC);
> +	if (!req) {
> +		DBG("Mem error\n");
> +		return false;
> +	}
> +
> +	list_add_tail(&req->node, &client->notifies);
> +	req->func = hook;
> +	req->data = data;
> +	req->tid = tid;
> +
> +	return true;
> +}
> +
> +static bool client_notify(struct qcusbnet *dev, u16 cid, u16 tid)
> +{
> +	struct client *client;
> +	struct notifyreq *delnotify, *notify;
> +	struct list_head *node;
> +
> +	assert_locked(dev);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find this client's memory 0x%04X\n", cid);
> +		return false;
> +	}
> +
> +	delnotify = NULL;
> +
> +	list_for_each(node, &client->notifies) {
> +		notify = list_entry(node, struct notifyreq, node);
> +		if (!tid || !notify->tid || tid == notify->tid) {
> +			delnotify = notify;
> +			break;
> +		}
> +		
> +		DBG("skipping data TID = %x\n", notify->tid);
> +	}
> +	
> +	if (delnotify) {
> +		list_del(&delnotify->node);
> +		if (delnotify->func) {
> +			spin_unlock(&dev->qmi.clients_lock);
> +			delnotify->func(dev, cid, delnotify->data);
> +			spin_lock(&dev->qmi.clients_lock);
> +		}
> +		kfree(delnotify);
> +		return true;
> +	}
> +
> +	DBG("no one to notify for TID %x\n", tid);	
> +	return false;
> +}
> +
> +static bool client_addurb(struct qcusbnet *dev, u16 cid, struct urb *urb)
> +{
> +	struct client *client;
> +	struct urbreq *req;
> +
> +	assert_locked(dev);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find this client's memory 0x%04X\n", cid);
> +		return false;
> +	}
> +
> +	req = kmalloc(sizeof(*req), GFP_ATOMIC);
> +	if (!req) {
> +		DBG("Mem error\n");
> +		return false;
> +	}	
> +
> +	req->urb = urb;
> +	list_add_tail(&req->node, &client->urbs);
> +	
> +	return true;
> +}
> +
> +static struct urb *client_delurb(struct qcusbnet *dev, u16 cid)
> +{
> +	struct client *client;
> +	struct urbreq *req;
> +	struct urb *urb;
> +
> +	assert_locked(dev);
> +
> +	client = client_bycid(dev, cid);
> +	if (!client) {
> +		DBG("Could not find this client's memory 0x%04X\n", cid);
> +		return NULL;
> +	}
> +
> +	if (list_empty(&client->urbs)) {
> +		DBG("No URB's to pop\n");
> +		return NULL;
> +	}
> +
> +	req = list_first_entry(&client->urbs, struct urbreq, node);
> +	list_del(&req->node);
> +	urb = req->urb;
> +	kfree(req);
> +	return urb;
> +}
> +
> +static int devqmi_open(struct inode *inode, struct file *file)
> +{
> +	struct qmihandle * handle;
> +	struct qmidev *qmidev = container_of(inode->i_cdev, struct qmidev, cdev);
> +	struct qcusbnet * dev = container_of(qmidev, struct qcusbnet, qmi);
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device\n");
> +		return -ENXIO;
> +	}
> +
> +	file->private_data = kmalloc(sizeof(struct qmihandle), GFP_KERNEL);
> +	if (!file->private_data) {
> +		DBG("Mem error\n");
> +		return -ENOMEM;
> +	}
> +	
> +	handle = (struct qmihandle *)file->private_data;
> +	handle->cid = (u16)-1;
> +	handle->dev = dev;
> +	
> +	return 0;
> +}
> +
> +static long devqmi_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> +{
> +	int result;
> +	u32 vidpid;
> +	
> +	struct qmihandle *handle = (struct qmihandle *)file->private_data;
> +
> +	if (!handle) {
> +		DBG("Bad file data\n");
> +		return -EBADF;
> +	}
> +	
> +	if (!device_valid(handle->dev)) {
> +		DBG("Invalid device! Updating f_ops\n");
> +		file->f_op = file->f_dentry->d_inode->i_fop;
> +		return -ENXIO;
> +	}
> +
> +	switch (cmd) {
> +		case IOCTL_QMI_GET_SERVICE_FILE:
> +
> +			DBG("Setting up QMI for service %lu\n", arg);
> +			if (!(u8)arg) {
> +				DBG("Cannot use QMICTL from userspace\n");
> +				return -EINVAL;
> +			}
> +
> +			if (handle->cid != (u16)-1) {
> +				DBG("Close the current connection before opening a new one\n");
> +				return -EBADR;
> +			}
> +			
> +			result = client_alloc(handle->dev, (u8)arg);
> +			if (result < 0)
> +				return result;
> +			handle->cid = result;
> +
> +			return 0;
> +			break;
> +
> +
> +		case IOCTL_QMI_GET_DEVICE_VIDPID:
> +			if (!arg) {
> +				DBG("Bad VIDPID buffer\n");
> +				return -EINVAL;
> +			}
> +			
> +			if (!handle->dev->usbnet) {
> +				DBG("Bad usbnet\n");
> +				return -ENOMEM;
> +			}
> +
> +			if (!handle->dev->usbnet->udev) {
> +				DBG("Bad udev\n");
> +				return -ENOMEM;
> +			}
> +
> +			vidpid = ((le16_to_cpu(handle->dev->usbnet->udev->descriptor.idVendor) << 16)
> +			       + le16_to_cpu(handle->dev->usbnet->udev->descriptor.idProduct));
> +
> +			result = copy_to_user((unsigned int *)arg, &vidpid, 4);
> +			if (result)
> +				DBG("Copy to userspace failure\n");
> +
> +			return result;
> +			break;
> +
> +		case IOCTL_QMI_GET_DEVICE_MEID:
> +			if (!arg) {
> +				DBG("Bad MEID buffer\n");
> +				return -EINVAL;
> +			}
> +			
> +			result = copy_to_user((unsigned int *)arg, &handle->dev->meid[0], 14);
> +			if (result)
> +				DBG("copy to userspace failure\n");
> +
> +			return result;
> +			break;
> +		default:
> +			return -EBADRQC;		 
> +	}
> +}
> +
> +static int devqmi_close(struct file *file, fl_owner_t ftable)
> +{
> +	struct qmihandle * handle = (struct qmihandle *)file->private_data;
> +	struct list_head * tasks;
> +	struct task_struct * task;
> +	struct fdtable * fdtable;
> +	int count = 0;
> +	int used = 0;
> +	unsigned long flags;
> +
> +	if (!handle) {
> +		DBG("bad file data\n");
> +		return -EBADF;
> +	}
> +
> +	if (file_count(file) != 1) {
> +		/* XXX: This can't possibly be safe. We don't hold any sort of
> +		 * lock here, and we're walking a list of threads... */
> +		list_for_each(tasks, &current->group_leader->tasks) {
> +			task = container_of(tasks, struct task_struct, tasks);
> +			if (!task || !task->files)
> +				continue;
> +			spin_lock_irqsave(&task->files->file_lock, flags);
> +			fdtable = files_fdtable(task->files);
> +			for (count = 0; count < fdtable->max_fds; count++) {
> +				/* Before this function was called, this file was removed
> +				 * from our task's file table so if we find it in a file
> +				 * table then it is being used by another task
> +				 */
> +				if (fdtable->fd[count] == file) {
> +					used++;
> +					break;
> +				}
> +			}
> +			spin_unlock_irqrestore(&task->files->file_lock, flags);
> +		}
> +		
> +		if (used > 0) {
> +			DBG("not closing, as this FD is open by %d other process\n", used);
> +			return 0;
> +		}
> +	}
> +
> +	if (!device_valid(handle->dev)) {
> +		DBG("Invalid device! Updating f_ops\n");
> +		file->f_op = file->f_dentry->d_inode->i_fop;
> +		return -ENXIO;
> +	}
> +	
> +	DBG("0x%04X\n", handle->cid);
> +	
> +	file->private_data = NULL;
> +
> +	if (handle->cid != (u16)-1)
> +		client_free(handle->dev, handle->cid);
> +
> +	kfree(handle);
> +	return 0;
> +}
> +
> +static ssize_t devqmi_read(struct file *file, char __user *buf, size_t size,
> +                           loff_t *pos)
> +{
> +	int result;
> +	void * data = NULL;
> +	void * smalldata;
> +	struct qmihandle * handle = (struct qmihandle *)file->private_data;
> +
> +	if (!handle) {
> +		DBG("Bad file data\n");
> +		return -EBADF;
> +	}
> +
> +	if (!device_valid(handle->dev)) {
> +		DBG("Invalid device! Updating f_ops\n");
> +		file->f_op = file->f_dentry->d_inode->i_fop;
> +		return -ENXIO;
> +	}
> +	
> +	if (handle->cid == (u16)-1) {
> +		DBG("Client ID must be set before reading 0x%04X\n",
> +		    handle->cid);
> +		return -EBADR;
> +	}
> +	
> +	result = read_sync(handle->dev, &data, handle->cid, 0);
> +	if (result <= 0)
> +		return result;
> +	
> +	result -= qmux_size;
> +	smalldata = data + qmux_size;
> +
> +	if (result > size) {
> +		DBG("Read data is too large for amount user has requested\n");
> +		kfree(data);
> +		return -EOVERFLOW;
> +	}
> +
> +	if (copy_to_user(buf, smalldata, result)) {
> +		DBG("Error copying read data to user\n");
> +		result = -EFAULT;
> +	}
> +	
> +	kfree(data);
> +	return result;
> +}
> +
> +static ssize_t devqmi_write (struct file *file, const char __user * buf,
> +                             size_t size, loff_t *pos)
> +{
> +	int status;
> +	void *wbuf;
> +	struct qmihandle *handle = (struct qmihandle *)file->private_data;
> +
> +	if (!handle) {
> +		DBG("Bad file data\n");
> +		return -EBADF;
> +	}
> +
> +	if (!device_valid(handle->dev)) {
> +		DBG("Invalid device! Updating f_ops\n");
> +		file->f_op = file->f_dentry->d_inode->i_fop;
> +		return -ENXIO;
> +	}
> +
> +	if (handle->cid == (u16)-1) {
> +		DBG("Client ID must be set before writing 0x%04X\n",
> +			  handle->cid);
> +		return -EBADR;
> +	}
> +	
> +	wbuf = kmalloc(size + qmux_size, GFP_KERNEL);
> +	if (!wbuf)
> +		return -ENOMEM;
> +	status = copy_from_user(wbuf + qmux_size, buf, size);
> +	if (status) {
> +		DBG("Unable to copy data from userspace %d\n", status);
> +		kfree(wbuf);
> +		return status;
> +	}
> +
> +	status = write_sync(handle->dev, wbuf, size + qmux_size,
> +	                    handle->cid);
> +
> +	kfree(wbuf);
> +	if (status == size + qmux_size)
> +		return size;
> +	return status;
> +}
> +
> +int qc_register(struct qcusbnet *dev)
> +{
> +	int result;
> +	int qmiidx = 0;
> +	dev_t devno; 
> +	char * name;
> +	
> +	dev->valid = true;
> +	result = client_alloc(dev, QMICTL);
> +	if (result) {
> +		dev->valid = false;
> +		return result;
> +	}
> +	atomic_set(&dev->qmi.qmitid, 1);
> +
> +	result = qc_startread(dev);
> +	if (result) {
> +		dev->valid = false;
> +		return result;
> +	}
> +	
> +	if (!qmi_ready(dev, 30000)) {
> +		DBG("Device unresponsive to QMI\n");
> +		return -ETIMEDOUT;
> +	}
> +
> +	result = setup_wds_callback(dev);
> +	if (result) {
> +		dev->valid = false;
> +		return result;
> +	}
> +
> +	result = qmidms_getmeid(dev);
> +	if (result) {
> +		dev->valid = false;
> +		return result;
> +	}
> +
> +	result = alloc_chrdev_region(&devno, 0, 1, "qcqmi");
> +	if (result < 0)
> +		return result;
> +
> +	cdev_init(&dev->qmi.cdev, &devqmi_fops);
> +	dev->qmi.cdev.owner = THIS_MODULE;
> +	dev->qmi.cdev.ops = &devqmi_fops;
> +
> +	result = cdev_add(&dev->qmi.cdev, devno, 1);
> +	if (result) {
> +		DBG("error adding cdev\n");
> +		return result;
> +	}
> +
> +	name = strstr(dev->usbnet->net->name, "usb");
> +	if (!name) {
> +		DBG("Bad net name: %s\n", dev->usbnet->net->name);
> +		return -ENXIO;
> +	}
> +	name += strlen("usb");
> +	qmiidx = simple_strtoul(name, NULL, 10);
> +	if (qmiidx < 0) {
> +		DBG("Bad minor number\n");
> +		return -ENXIO;
> +	}
> +
> +	printk(KERN_INFO "creating qcqmi%d\n", qmiidx);
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27)
> +	device_create(dev->qmi.devclass, NULL, devno, NULL, "qcqmi%d", qmiidx);
> +#else
> +	device_create(dev->qmi.devclass, NULL, devno, "qcqmi%d", qmiidx);
> +#endif
> +	
> +	dev->qmi.devnum = devno;
> +	return 0;
> +}
> +
> +void qc_deregister(struct qcusbnet *dev)
> +{
> +	struct list_head *node;
> +	struct client *client;
> +	struct inode * inode;
> +	struct list_head * inodes;
> +	struct list_head * tasks;
> +	struct task_struct * task;
> +	struct fdtable * fdtable;
> +	struct file * file;
> +	unsigned long flags;
> +	int count = 0;
> +
> +	if (!device_valid(dev)) {
> +		DBG("wrong device\n");
> +		return;
> +	}
> +
> +	list_for_each(node, &dev->qmi.clients) {
> +		client = list_entry(node, struct client, node);
> +		DBG("release 0x%04X\n", client->cid);
> +		client_free(dev, client->cid);
> +	}
> +
> +	qc_stopread(dev);
> +	dev->valid = false;
> +	list_for_each(inodes, &dev->qmi.cdev.list) {
> +		inode = container_of(inodes, struct inode, i_devices);
> +		if (inode != NULL && !IS_ERR(inode)) {
> +			list_for_each(tasks, &current->group_leader->tasks) {
> +				task = container_of(tasks, struct task_struct, tasks);
> +				if (!task || !task->files)
> +					continue;
> +				spin_lock_irqsave(&task->files->file_lock, flags);
> +				fdtable = files_fdtable(task->files);
> +				for (count = 0; count < fdtable->max_fds; count++) {
> +					file = fdtable->fd[count];
> +					if (file != NULL &&  file->f_dentry != NULL) {
> +						if (file->f_dentry->d_inode == inode) {
> +							rcu_assign_pointer(fdtable->fd[count], NULL);	
> +							spin_unlock_irqrestore(&task->files->file_lock, flags);
> +							DBG("forcing close of open file handle\n");
> +							filp_close(file, task->files);
> +							spin_lock_irqsave(&task->files->file_lock, flags);
> +						}
> +					}
> +				}
> +				spin_unlock_irqrestore(&task->files->file_lock, flags);
> +			}
> +		}
> +	}
> +
> +	if (!IS_ERR(dev->qmi.devclass))
> +		device_destroy(dev->qmi.devclass, dev->qmi.devnum);
> +	cdev_del(&dev->qmi.cdev);
> +	unregister_chrdev_region(dev->qmi.devnum, 1);
> +}
> +
> +static bool qmi_ready(struct qcusbnet *dev, u16 timeout)
> +{
> +	int result;
> +	void * wbuf;
> +	size_t wbufsize;
> +	void * rbuf;
> +	u16 rbufsize;
> +	struct semaphore sem;
> +	u16 now;
> +	unsigned long flags;
> +	u8 tid;
> +	
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device\n");
> +		return -EFAULT;
> +	}
> +
> +
> +	for (now = 0; now < timeout; now += 100) {
> +		sema_init(&sem, 0);
> +
> +		tid = atomic_add_return(1, &dev->qmi.qmitid);
> +		if (!tid)
> +			tid = atomic_add_return(1, &dev->qmi.qmitid);
> +		if (wbuf)
> +			kfree(wbuf);
> +		wbuf = qmictl_new_ready(tid, &wbufsize);
> +		if (!wbuf)
> +			return -ENOMEM;
> +	
> +		result = read_async(dev, QMICTL, tid, upsem, &sem);
> +		if (result) {
> +			kfree(wbuf);
> +			return false;
> +		}
> +
> +		write_sync(dev, wbuf, wbufsize, QMICTL);
> +
> +		msleep(100);
> +		if (!down_trylock(&sem)) {
> +			spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +			if (client_delread(dev,	QMICTL,	tid, &rbuf, &rbufsize)) {
> +				spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +				kfree(rbuf);
> +				break;
> +			}
> +		} else {
> +			spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +			client_notify(dev, QMICTL, tid);
> +			spin_unlock_irqrestore(&dev->qmi.clients_lock, flags);
> +		}
> +	}
> +
> +	if (wbuf)
> +		kfree(wbuf);
> +
> +	if (now >= timeout)
> +		return false;
> +	
> +	DBG("QMI Ready after %u milliseconds\n", now);
> +
> +	/* 3580 and newer doesn't need a delay; older needs 5000ms */
> +	if (qcusbnet2k_fwdelay)
> +		msleep(qcusbnet2k_fwdelay * 1000);
> +
> +	return true;
> +}
> +
> +static void wds_callback(struct qcusbnet *dev, u16 cid, void *data)
> +{
> +	bool ret;
> +	int result;
> +	void * rbuf;
> +	u16 rbufsize;
> +
> +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,31)
> +	struct net_device_stats * stats = &(dev->usbnet->stats);
> +#else
> +	struct net_device_stats * stats = &(dev->usbnet->net->stats);
> +#endif
> +
> +	struct qmiwds_stats dstats = {
> +		.txok = (u32)-1,
> +		.rxok = (u32)-1,
> +		.txerr = (u32)-1,
> +		.rxerr = (u32)-1,
> +		.txofl = (u32)-1,
> +		.rxofl = (u32)-1,
> +		.txbytesok = (u64)-1,
> +		.rxbytesok = (u64)-1,
> +	};
> +	unsigned long flags;
> +	
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device\n");
> +		return;
> +	}
> +
> +	spin_lock_irqsave(&dev->qmi.clients_lock, flags);
> +	ret = client_delread(dev, cid, 0, &rbuf, &rbufsize);
> +	spin_unlock_irqrestore(&dev->qmi.clients_lock, flags); 
> +	
> +	if (!ret) {
> +		DBG("WDS callback failed to get data\n");
> +		return;
> +	}
> +	
> +	dstats.linkstate = !qc_isdown(dev, DOWN_NO_NDIS_CONNECTION);
> +	dstats.reconfigure = false;
> +
> +	result = qmiwds_event_resp(rbuf, rbufsize, &dstats);
> +	if (result < 0) {
> +		DBG("bad WDS packet\n");
> +	} else {
> +		if (dstats.txofl != (u32)-1)
> +			stats->tx_fifo_errors = dstats.txofl;
> +		
> +		if (dstats.rxofl != (u32)-1)
> +			stats->rx_fifo_errors = dstats.rxofl;
> +
> +		if (dstats.txerr != (u32)-1)
> +			stats->tx_errors = dstats.txerr;
> +		
> +		if (dstats.rxerr != (u32)-1)
> +			stats->rx_errors = dstats.rxerr;
> +
> +		if (dstats.txok != (u32)-1)
> +			stats->tx_packets = dstats.txok + stats->tx_errors;
> +		
> +		if (dstats.rxok != (u32)-1)
> +			stats->rx_packets = dstats.rxok + stats->rx_errors;
> +
> +		if (dstats.txbytesok != (u64)-1)
> +			stats->tx_bytes = dstats.txbytesok;
> +		
> +		if (dstats.rxbytesok != (u64)-1)
> +			stats->rx_bytes = dstats.rxbytesok;
> +
> +		if (dstats.reconfigure) {
> +			DBG("Net device link reset\n");
> +			qc_setdown(dev, DOWN_NO_NDIS_CONNECTION);
> +			qc_cleardown(dev, DOWN_NO_NDIS_CONNECTION);
> +		} else {
> +			if (dstats.linkstate) {
> +				DBG("Net device link is connected\n");
> +				qc_cleardown(dev, DOWN_NO_NDIS_CONNECTION);
> +			} else {
> +				DBG("Net device link is disconnected\n");
> +				qc_setdown(dev, DOWN_NO_NDIS_CONNECTION);
> +			}
> +		}
> +	}
> +
> +	kfree(rbuf);
> +
> +	result = read_async(dev, cid, 0, wds_callback, data);
> +	if (result != 0)
> +		DBG("unable to setup next async read\n");
> +}
> +
> +static int setup_wds_callback(struct qcusbnet * dev)
> +{
> +	int result;
> +	void *buf;
> +	size_t size;
> +	u16 cid;
> +
> +	if (!device_valid(dev)) {
> +		DBG("Invalid device\n");
> +		return -EFAULT;
> +	}
> +	
> +	result = client_alloc(dev, QMIWDS);
> +	if (result < 0)
> +		return result;
> +	cid = result;
> +
> +	buf = qmiwds_new_seteventreport(1, &size);
> +	if (!buf)
> +		return -ENOMEM;
> +
> +	result = write_sync(dev, buf, size, cid);
> +	kfree(buf);
> +
> +	if (result < 0) {
> +		return result;
> +	}
> +
> +	buf = qmiwds_new_getpkgsrvcstatus(2, &size);
> +	if (buf == NULL)
> +		return -ENOMEM;
> +
> +	result = write_sync(dev, buf, size, cid);
> +	kfree(buf);
> +
> +	if (result < 0)
> +		return result;
> +
> +	result = read_async(dev, cid, 0, wds_callback, NULL);
> +	if (result) {
> +		DBG("unable to setup async read\n");
> +		return result;
> +	}
> +
> +	result = usb_control_msg(dev->usbnet->udev,
> +	                         usb_sndctrlpipe(dev->usbnet->udev, 0),
> +	                         0x22, 0x21, 1, 0, NULL, 0, 100);
> +	if (result < 0) {
> +		DBG("Bad SetControlLineState status %d\n", result);
> +		return result;
> +	}
> +
> +	return 0;
> +}
> +
> +static int qmidms_getmeid(struct qcusbnet * dev)
> +{
> +	int result;
> +	void * wbuf;
> +	size_t wbufsize;
> +	void * rbuf;
> +	u16 rbufsize;
> +	u16 cid;
> +
> +	if (!device_valid(dev))	{
> +		DBG("Invalid device\n");
> +		return -EFAULT;
> +	}
> +
> +	result = client_alloc(dev, QMIDMS);
> +	if (result < 0)
> +		return result;
> +	cid = result;
> +
> +	wbuf = qmidms_new_getmeid(1, &wbufsize);
> +	if (!wbuf)
> +		return -ENOMEM;
> +
> +	result = write_sync(dev, wbuf, wbufsize, cid);
> +	kfree(wbuf);
> +
> +	if (result < 0)
> +		return result;
> +
> +	result = read_sync(dev, &rbuf, cid, 1);
> +	if (result < 0)
> +		return result;
> +	rbufsize = result;
> +
> +	result = qmidms_meid_resp(rbuf, rbufsize, &dev->meid[0], 14);
> +	kfree(rbuf);
> +
> +	if (result < 0) {
> +		DBG("bad get MEID resp\n");
> +		memset(&dev->meid[0], '0', 14);
> +	}
> +
> +	client_free(dev, cid);
> +	return 0;
> +}
> +
> +module_param(qcusbnet2k_fwdelay, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(qcusbnet2k_fwdelay, "Delay for old firmware");
> diff --git a/drivers/net/usb/qcusbnet/qmidevice.h b/drivers/net/usb/qcusbnet/qmidevice.h
> new file mode 100755
> index 0000000..39a4b7f
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/qmidevice.h
> @@ -0,0 +1,36 @@
> +/* qmidevice.h - gobi QMI device header
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#ifndef QCUSBNET_QMIDEVICE_H
> +#define QCUSBNET_QMIDEVICE_H
> +
> +#include "structs.h"
> +#include "qmi.h"
> +
> +void printhex(const void *data, size_t size);
> +void qc_setdown(struct qcusbnet *dev, u8 reason);
> +void qc_cleardown(struct qcusbnet *dev, u8 reason);
> +bool qc_isdown(struct qcusbnet *dev, u8 reason);
> +
> +int qc_startread(struct qcusbnet *dev);
> +void qc_stopread(struct qcusbnet *dev);
> +
> +int qc_register(struct qcusbnet *dev);
> +void qc_deregister(struct qcusbnet *dev);
> +
> +#endif /* !QCUSBNET_QMIDEVICE_H */
> diff --git a/drivers/net/usb/qcusbnet/readme.txt b/drivers/net/usb/qcusbnet/readme.txt
> new file mode 100755
> index 0000000..cec6790
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/readme.txt
> @@ -0,0 +1,118 @@
> +Gobi2000 network driver for HP 1.0.110
> +06/18/2010
> +
> +This readme covers important information concerning 
> +the QCUSBNet2kHP driver, provided in correlation with
> +the Gobi2000-Linux-Package.
> +
> +Table of Contents
> +
> +1. Prerequisites
> +2. Installation instructions
> +3. What's new in this release
> +4. Notes
> +5. Known issues
> +
> +-------------------------------------------------------------------------------
> +
> +1. PREREQUISITES
> +
> +a. Kernel headers or full kernel source installed for the currently 
> +   running kernel.  There must be a link "/lib/modules/<uname -r>/build"
> +   that points to these kernel headers or sources.
> +b. The kernel must support the usbcore and usbnet drivers, either as
> +   modules or built into the kernel.
> +c. Tools required for building the kernel.  These tools usually come in a 
> +   package called "kernel-devel".
> +d. "gcc" compiler
> +e. "make" tool
> +
> +-------------------------------------------------------------------------------
> +
> +2. INSTALLATION INSTRUCTIONS
> +
> +a. Navigate to the folder "QCUSBNet2k" that contains:
> +      Makefile
> +      QCUSBNetHP.c
> +      QMIDevice.c
> +      qmidevice.h
> +      structs.h
> +      QMI.c
> +      qmi.h
> +b. (only required for kernels prior to 2.6.25) Create a symbolic link 
> +   to the usbnet.h file in your kernel sources:
> +      ln -s <linux sources>/drivers/net/usb/usbnet.h ./
> +c. Run the command:
> +      make
> +d. Copy the newly created QCUSBNet2kHP.ko into the directory
> +   /lib/modules/`uname -r`/kernel/drivers/net/usb/
> +e. Run the command:
> +      depmod
> +f. (Optional) Load the driver manually with the command:
> +      modprobe QCUSBNet2kHP
> +   - This is only required the first time after you install the
> +     drivers.  If you restart or plug the Gobi device in the drivers 
> +     will be automatically loaded.
> +
> +-------------------------------------------------------------------------------
> +
> +3. WHAT'S NEW
> +
> +This Release (Gobi2000 network driver for HP 1.0.110) 06/18/2010
> +a. Correctly initialize semaphore during probe function.
> +
> +Prior Release (Gobi2000 network driver for HP 1.0.100) 06/02/2010
> +a. Merge QCQMI driver into QCUSBNet2k driver, removing dependency.
> +
> +Prior Release (Gobi2000 network driver for HP 1.0.90) 05/13/2010
> +a. Fix devqmi_close() from a thread
> +b. Add 2.6.33 kernel support
> +
> +Prior Release (Gobi2000 network driver for HP 1.0.80) 04/19/2010
> +a. Add support to check for duplicate or out of sequence QMI messages.
> +
> +Prior Release (Gobi2000 network driver for HP 1.0.70) 03/15/2010
> +a. Added support for CDC CONNECTION_SPEED_CHANGE indication.
> +b. Modified device cleanup function to better handle the device
> +   losing power during suspend or hibernate.
> +c. Replaced autosuspend feature with more aggressive "Selective suspend"
> +   style power management.  Even if QCWWAN2k or Network connections are
> +   active the device will still enter autosuspend after the delay time,
> +   and wake on remote wakeup or new data being sent.
> +
> +Prior Release (Gobi2000 Serial driver for HP 1.0.60) 02/16/2010
> +a. Fix to allow proper fork() functionality
> +b. Add supports_autosuspend flag
> +c. Ignore EOVERFLOW errors on interrupt endpoint and resubmit URB
> +d. Change driver versions to match installer package
> +e. Minor update for 2.6.23 kernel compatibility
> +
> +Prior Release (in correlation with Gobi2000-Linux-Package 1.0.30) 12/04/2009
> +a. Modify ioctl numbering to avoid conflict in 2.6.31 kernel
> +   This release is only compatible with GOBI2000_LINUX_SDK 1.0.30 and newer.
> +b. Made minor compatibility changes for 2.6.31 kernel
> +
> +Prior Release (in correlation with Gobi2000-Linux-Package 1.0.20) 11/20/2009
> +a. Initial release
> +
> +-------------------------------------------------------------------------------
> +
> +4. NOTES
> +
> +a. In Composite mode, the Gobi device will enumerate a network interface
> +   usb<#> where <#> signifies the next available USB network interface.
> +b. In Composite mode, the Gobi device will enumerate a device node
> +   /dev/qcqmi<#>.  This device node is for use by the QCWWANCMAPI2k.
> +c. Ownership, group, and permissions are managed by your system 
> +   configuration.
> +
> +-------------------------------------------------------------------------------
> +
> +5. KNOWN ISSUES
> +
> +No known issues.
> +         
> +-------------------------------------------------------------------------------
> +
> +
> +
> diff --git a/drivers/net/usb/qcusbnet/structs.h b/drivers/net/usb/qcusbnet/structs.h
> new file mode 100755
> index 0000000..0f9f4eb
> --- /dev/null
> +++ b/drivers/net/usb/qcusbnet/structs.h
> @@ -0,0 +1,99 @@
> +/* structs.h - shared structures
> + * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
> +
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> +
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> +
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + */
> +
> +#ifndef QCUSBNET_STRUCTS_H
> +#define QCUSBNET_STRUCTS_H
> +
> +#include <linux/etherdevice.h>
> +#include <linux/ethtool.h>
> +#include <linux/mii.h>
> +#include <linux/usb.h>
> +#include <linux/version.h>
> +#include <linux/cdev.h>
> +#include <linux/kthread.h>
> +
> +#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,6,24)
> +	#include "usbnet.h"
> +#else
> +	#include <linux/usb/usbnet.h>
> +#endif
> +
> +#if LINUX_VERSION_CODE > KERNEL_VERSION(2,6,25)
> +	#include <linux/fdtable.h>
> +#else
> +	#include <linux/file.h>
> +#endif
> +
> +#define DBG(format, arg...) \
> +	if (debug == 1) { \
> +		printk(KERN_INFO "QCUSBNet2k::%s " format, __FUNCTION__, ## arg); \
> +	}
> +
> +struct qcusbnet;
> +
> +struct urbreq {
> +	struct list_head node;
> +	struct urb *urb;
> +};
> +
> +#define DEFAULT_READ_URB_LENGTH 0x1000
> +
> +struct worker {
> +	struct task_struct *thread;
> +	struct completion work;
> +	struct list_head urbs;
> +	spinlock_t urbs_lock;
> +	struct urb *active;
> +	spinlock_t active_lock;
> +	struct usb_interface *iface;
> +};
> +
> +struct qmidev {
> +	dev_t devnum;
> +	struct class *devclass;
> +	struct cdev cdev;
> +	struct urb *readurb;
> +	struct urbsetup *readsetup;
> +	void *readbuf;
> +	struct urb *inturb;
> +	void *intbuf;
> +	struct list_head clients;
> +	spinlock_t clients_lock;
> +	atomic_t qmitid;
> +};
> +
> +enum {
> +	DOWN_NO_NDIS_CONNECTION = 0,
> +	DOWN_CDC_CONNECTION_SPEED = 1,
> +	DOWN_DRIVER_SUSPENDED = 2,
> +	DOWN_NET_IFACE_STOPPED = 3,
> +};
> +
> +struct qcusbnet {
> +	struct usbnet *usbnet;
> +	struct usb_interface *iface;
> +	int (*open)(struct net_device *);
> +	int (*stop)(struct net_device *);
> +	unsigned long down;
> +	bool valid;
> +	struct qmidev qmi;
> +	char meid[14];
> +	struct worker worker;
> +};
> +
> +#endif /* !QCUSBNET_STRUCTS_H */


