From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 12/12] usbnet: make device out of suspend before calling usbnet_read/write_cmd
Date: Wed, 10 Oct 2012 10:33:17 +0800
Message-ID: <CACVXFVNb-APsJG=ejW+2jqxTfAFsGhHovpgpsyvk6wUoKn5TzA@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1349160684-6627-13-git-send-email-ming.lei@canonical.com>
	<2913414.gCAxlQ38lG@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2913414.gCAxlQ38lG-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 9, 2012 at 4:50 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> This is awkward to use in suspend()/resume()
> Could you make both versions available?

Good catch, thanks for your review.

As far as I can think of, the mutex_is_locked() trick can solve the problem.

How about the attached patch?

Thanks,
--
Ming Lei

--
>From 5c417db4ba2fd13091067104e5afe4554750be11 Mon Sep 17 00:00:00 2001
From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Tue, 2 Oct 2012 13:46:56 +0800
Subject: [PATCH] usbnet: make device out of suspend before calling
 usbnet_read/write_cmd

This patche gets the runtime PM reference count before calling
usb_control_msg, and puts it after completion of the
usb_control_msg, so that the usb control message can always be
sent to one active device.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/smsc75xx.c |    5 +++++
 drivers/net/usb/smsc95xx.c |    5 +++++
 drivers/net/usb/usbnet.c   |   16 ++++++++++++++++
 include/linux/usb/usbnet.h |    1 +
 4 files changed, 27 insertions(+)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1baa53a..3d43c4d 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1153,6 +1153,7 @@ static int smsc75xx_suspend(struct usb_interface
*intf, pm_message_t message)
 	ret = usbnet_suspend(intf, message);
 	check_warn_return(ret, "usbnet_suspend error");

+	mutex_lock(&dev->pm_mutex);
 	/* if no wol options set, enter lowest power SUSPEND2 mode */
 	if (!(pdata->wolopts & SUPPORTED_WAKE)) {
 		netdev_info(dev->net, "entering SUSPEND2 mode");
@@ -1183,6 +1184,7 @@ static int smsc75xx_suspend(struct usb_interface
*intf, pm_message_t message)

 		ret = smsc75xx_write_reg(dev, PMT_CTL, val);
 		check_warn_return(ret, "Error writing PMT_CTL");
+		mutex_unlock(&dev->pm_mutex);

 		return 0;
 	}
@@ -1254,6 +1256,7 @@ static int smsc75xx_suspend(struct usb_interface
*intf, pm_message_t message)
 	check_warn_return(ret, "Error reading PMT_CTL");

 	smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+	mutex_unlock(&dev->pm_mutex);

 	return 0;
 }
@@ -1265,6 +1268,7 @@ static int smsc75xx_resume(struct usb_interface *intf)
 	int ret;
 	u32 val;

+	mutex_lock(&dev->pm_mutex);
 	if (pdata->wolopts & WAKE_MAGIC) {
 		netdev_info(dev->net, "resuming from SUSPEND0");

@@ -1302,6 +1306,7 @@ static int smsc75xx_resume(struct usb_interface *intf)

 	ret = smsc75xx_wait_ready(dev);
 	check_warn_return(ret, "device not ready in smsc75xx_resume");
+	mutex_unlock(&dev->pm_mutex);

 	return usbnet_resume(intf);
 }
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 1730f75..5202e55e 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1015,6 +1015,7 @@ static int smsc95xx_suspend(struct usb_interface
*intf, pm_message_t message)
 	ret = usbnet_suspend(intf, message);
 	check_warn_return(ret, "usbnet_suspend error");

+	mutex_lock(&dev->pm_mutex);
 	/* if no wol options set, enter lowest power SUSPEND2 mode */
 	if (!(pdata->wolopts & SUPPORTED_WAKE)) {
 		netdev_info(dev->net, "entering SUSPEND2 mode");
@@ -1045,6 +1046,7 @@ static int smsc95xx_suspend(struct usb_interface
*intf, pm_message_t message)

 		ret = smsc95xx_write_reg(dev, PM_CTRL, val);
 		check_warn_return(ret, "Error writing PM_CTRL");
+		mutex_unlock(&dev->pm_mutex);

 		return 0;
 	}
@@ -1110,6 +1112,7 @@ static int smsc95xx_suspend(struct usb_interface
*intf, pm_message_t message)
 	check_warn_return(ret, "Error reading PM_CTRL");

 	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
+	mutex_unlock(&dev->pm_mutex);

 	return 0;
 }
@@ -1123,6 +1126,7 @@ static int smsc95xx_resume(struct usb_interface *intf)

 	BUG_ON(!dev);

+	mutex_lock(&dev->pm_mutex);
 	if (pdata->wolopts & WAKE_MAGIC) {
 		smsc95xx_clear_feature(dev, USB_DEVICE_REMOTE_WAKEUP);

@@ -1145,6 +1149,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
 		ret = smsc95xx_write_reg(dev, PM_CTRL, val);
 		check_warn_return(ret, "Error writing PM_CTRL");
 	}
+	mutex_unlock(&dev->pm_mutex);

 	return usbnet_resume(intf);
 	check_warn_return(ret, "usbnet_resume error");
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3b51554..9c872a0 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1401,6 +1401,7 @@ usbnet_probe (struct usb_interface *udev, const
struct usb_device_id *prod)
 	dev->delay.data = (unsigned long) dev;
 	init_timer (&dev->delay);
 	mutex_init (&dev->phy_mutex);
+	mutex_init (&dev->pm_mutex);

 	dev->net = net;
 	strcpy (net->name, "usb%d");
@@ -1516,11 +1517,13 @@ int usbnet_suspend (struct usb_interface
*intf, pm_message_t message)
 	struct usbnet		*dev = usb_get_intfdata(intf);

 	if (!dev->suspend_count++) {
+		mutex_lock(&dev->pm_mutex);
 		spin_lock_irq(&dev->txq.lock);
 		/* don't autosuspend while transmitting */
 		if (dev->txq.qlen && PMSG_IS_AUTO(message)) {
 			dev->suspend_count--;
 			spin_unlock_irq(&dev->txq.lock);
+			mutex_unlock(&dev->pm_mutex);
 			return -EBUSY;
 		} else {
 			set_bit(EVENT_DEV_ASLEEP, &dev->flags);
@@ -1539,6 +1542,7 @@ int usbnet_suspend (struct usb_interface *intf,
pm_message_t message)
 		 * wake the device
 		 */
 		netif_device_attach (dev->net);
+		mutex_unlock(&dev->pm_mutex);
 	}
 	return 0;
 }
@@ -1552,6 +1556,7 @@ int usbnet_resume (struct usb_interface *intf)
 	int                     retval;

 	if (!--dev->suspend_count) {
+		mutex_lock(&dev->pm_mutex);
 		/* resume interrupt URBs */
 		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
 			usb_submit_urb(dev->interrupt, GFP_NOIO);
@@ -1587,6 +1592,7 @@ int usbnet_resume (struct usb_interface *intf)
 				netif_tx_wake_all_queues(dev->net);
 			tasklet_schedule (&dev->bh);
 		}
+		mutex_unlock(&dev->pm_mutex);
 	}
 	return 0;
 }
@@ -1598,6 +1604,7 @@ int usbnet_read_cmd(struct usbnet *dev, u8 cmd,
u8 reqtype,
 {
 	void *buf = NULL;
 	int err = -ENOMEM;
+	int autopm = !mutex_is_locked(&dev->pm_mutex);

 	netdev_dbg(dev->net, "usbnet_read_cmd cmd=0x%02x reqtype=%02x"
 		   " value=0x%04x index=0x%04x size=%d\n",
@@ -1609,9 +1616,13 @@ int usbnet_read_cmd(struct usbnet *dev, u8 cmd,
u8 reqtype,
 			goto out;
 	}

+	if (autopm)
+		usb_autopm_get_interface(dev->intf);
 	err = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
 			      cmd, reqtype, value, index, buf, size,
 			      USB_CTRL_GET_TIMEOUT);
+	if (autopm)
+		usb_autopm_put_interface(dev->intf);
 	if (err > 0 && err <= size)
 		memcpy(data, buf, err);
 	kfree(buf);
@@ -1625,6 +1636,7 @@ int usbnet_write_cmd(struct usbnet *dev, u8 cmd,
u8 reqtype,
 {
 	void *buf = NULL;
 	int err = -ENOMEM;
+	int autopm = !mutex_is_locked(&dev->pm_mutex);

 	netdev_dbg(dev->net, "usbnet_write_cmd cmd=0x%02x reqtype=%02x"
 		   " value=0x%04x index=0x%04x size=%d\n",
@@ -1636,9 +1648,13 @@ int usbnet_write_cmd(struct usbnet *dev, u8
cmd, u8 reqtype,
 			goto out;
 	}

+	if (autopm)
+		usb_autopm_get_interface(dev->intf);
 	err = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
 			      cmd, reqtype, value, index, buf, size,
 			      USB_CTRL_SET_TIMEOUT);
+	if (autopm)
+		usb_autopm_put_interface(dev->intf);
 	kfree(buf);

 out:
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 32a57dd..3b56e5a 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -33,6 +33,7 @@ struct usbnet {
 	wait_queue_head_t	*wait;
 	struct mutex		phy_mutex;
 	unsigned char		suspend_count;
+	struct mutex		pm_mutex;

 	/* i/o info: pipes etc */
 	unsigned		in, out;
-- 
1.7.9.5
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
