From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add Qualcomm Gobi 2000/3000 driver.
Date: Wed, 13 Apr 2011 13:37:23 -0700 (PDT)
Message-ID: <20110413.133723.70211873.davem@davemloft.net>
References: <20110413190023.GC1652@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dcbw@redhat.com, mjg59@redhat.com,
	jglasgow@google.com, trond@google.com
To: ellyjones@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32788
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932296Ab1DMUh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 16:37:59 -0400
In-Reply-To: <20110413190023.GC1652@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elly Jones <ellyjones@google.com>
Date: Wed, 13 Apr 2011 15:00:24 -0400

> +void qcusbnet_put(struct qcusbnet *dev)
> +{
> +	mutex_lock(&qcusbnet_lock);
> +	kref_put(&dev->refcount, free_dev);
> +	mutex_unlock(&qcusbnet_lock);
> +}

This locking looks excessive, and shouldn't be needed simply to
release a reference to an object.

> +int qc_suspend(struct usb_interface *iface, pm_message_t event)
> +{
> +	struct usbnet *usbnet;
> +	struct qcusbnet *dev;
> +
> +	if (!iface)
> +		return -ENOMEM;

When is qc_suspend() called with a NULL iface arguemnt?

> +static int qc_resume(struct usb_interface *iface)
> +{
> +	struct usbnet *usbnet;
> +	struct qcusbnet *dev;
> +	int ret;
> +	int oldstate;
> +
> +	if (iface == 0)
> +		return -ENOMEM;

Likewise, and if it is needed use consistent tests for NULL.  Testing
against the integer "0" is definitely the wrong way.

> +		if (usb_endpoint_dir_in(&endpoint->desc)
> +		&&  !usb_endpoint_xfer_int(&endpoint->desc)) {

Please do it like this:

	if (A &&
	    B) {

Not like:

	if (A
	&&  B

the latter looks awful at best.

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

These NULL checks are everywhere!  Do we really _ever_ create a full
registered netdev with any of these things being NULL?  I severely
doubt it.

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

This NULL check is impossible, you register the worker function with an
explicit &dev->worker argument, so seeing NULL here is impossible.

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

Again, kill this NULL check noise, all of it can't be necessary.

> +	netdev->trans_start = jiffies;

Setting netdev->trans_start in drivers is expensive and deprecated,
please set netdev_queue->trans_start instead.

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

Again, excessive NULL checks.

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

Here too.

> +static u8 nibble(unsigned char c)
> +{
> +	if (likely(isdigit(c)))
> +		return c - '0';
> +	c = toupper(c);
> +	if (likely(isxdigit(c)))
> +		return 10 + c - 'A';
> +	return 0;
> +}

Remove this function and use hex_to_bin() instead.
