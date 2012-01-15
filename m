From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 2/3] net: usb: cdc_enc: New driver exposing USB CDC encapsulated protocols
Date: Sun, 15 Jan 2012 07:40:36 +0100
Message-ID: <d11888532ee381806b35974e71af4c0122255c05.1326607234.git.bjorn@mork.no>
References: <cover.1326607234.git.bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
In-Reply-To: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
References: <cover.1326607234.git.bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

USB CDC Ethernet devices may encapsulate vendor specific protocols insi=
de
USB_CDC_SEND_ENCAPSULATED_COMMAND +USB_CDC_GET_ENCAPSULATED_RESPONSE
control messages. Devices based on Qualcomm MSM
chipsets are known to use this for exporting the Qualcomm
MSM Interface (QMI) protocol. Examples of such devices are
the Huawei E392 and E398 LTE modems.

This is only a subdriver which needs to be linked from a real CDC
ethernet driver like the QMI WWAN driver.  The basic idea is that
the USB ethernet driver will know what protocol, if any, the
devices supports cia CDC encapsulated commands.  It calls this
driver to register it, naming the protocol, while this driver
is completely protocol agnostic.

The encapsulated protocol is exported as a character device, and
the protocol name is made available to userspace as a sysfs=20
attribute.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Changes from v1: Completely rewritten and this generic part has been=20
split out as a separate subdriver.  It currently needs to be called
from another usbnet based driver, and will abuse the status
interrupt part of that for its own needs.


 drivers/net/usb/Kconfig   |   14 ++
 drivers/net/usb/Makefile  |    1 +
 drivers/net/usb/cdc_enc.c |  452 +++++++++++++++++++++++++++++++++++++=
++++++++
 drivers/net/usb/cdc_enc.h |   77 ++++++++
 4 files changed, 544 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/cdc_enc.c
 create mode 100644 drivers/net/usb/cdc_enc.h

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 2335761..1425b08 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -461,4 +461,18 @@ config USB_VL600
=20
 	  http://ubuntuforums.org/showpost.php?p=3D10589647&postcount=3D17
=20
+config USB_NET_CDC_ENC
+	tristate "CDC encapsulated command helper"
+	help
+	  USB CDC Ethernet devices may encapsulate vendor specific
+	  protocols inside CDC commands. Devices based on Qualcomm MSM
+	  chipsets are known to use this for exporting the Qualcomm
+	  MSM Interface (QMI) protocol. Examples of such devices are
+	  the Huawei E392 and E398 LTE modems.
+
+	  This is only a subdriver which needs to be linked from a
+	  real CDC Ethernet driver like the QMI WWAN driver.
+
+	  The encapsulated protocol is exported as a character device.
+
 endmenu
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index c203fa2..1edfc1b 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -29,4 +29,5 @@ obj-$(CONFIG_USB_SIERRA_NET)	+=3D sierra_net.o
 obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
+obj-$(CONFIG_USB_NET_CDC_ENC)	+=3D cdc_enc.o
=20
diff --git a/drivers/net/usb/cdc_enc.c b/drivers/net/usb/cdc_enc.c
new file mode 100644
index 0000000..c3bff289
--- /dev/null
+++ b/drivers/net/usb/cdc_enc.c
@@ -0,0 +1,452 @@
+/*
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/cdev.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/completion.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include "cdc_enc.h"
+
+/* copy data to the client local buffer */
+static void cdc_enc_copy_to_client(struct cdc_enc_client *client, void=
 *data, size_t len)
+{
+	/* someone is using the RX buffer - ignore data */
+	if (test_and_set_bit(CDC_ENC_CLIENT_BUSY, &client->flags))
+		return;
+
+	/* refusing to overwrite unread data */
+	if (test_and_set_bit(CDC_ENC_CLIENT_RX, &client->flags))
+		goto err_oflow;
+
+	memcpy(client->buf, data, len);
+	client->len =3D len;
+
+err_oflow:
+	clear_bit(CDC_ENC_CLIENT_BUSY, &client->flags);
+	schedule_work(&client->work);
+}
+
+/* copy data to all clients */
+static void cdc_enc_copy_to_all(struct cdc_enc_state *cdc_enc, void *d=
ata, size_t len)
+{
+	struct cdc_enc_client *tmp;
+
+	list_for_each_entry(tmp, &cdc_enc->clients, list)
+		cdc_enc_copy_to_client(tmp, data, len);
+}
+
+/* URB callback, copying common recv buffer to all clients */
+static void cdc_enc_read_callback(struct urb *urb)
+{
+	/* silently ignoring any errors */
+	if (urb->status =3D=3D 0 && urb->actual_length > 0)
+		cdc_enc_copy_to_all((struct cdc_enc_state *)urb->context, urb->trans=
fer_buffer, urb->actual_length);
+}
+
+/* make sure the interrupt URB is queued by forcibly resubmitting it *=
/
+static void cdc_enc_status_urb(struct cdc_enc_state *cdc_enc, int kmal=
loc_flags)
+{
+	if (cdc_enc->interrupt)
+		usb_submit_urb(cdc_enc->interrupt, kmalloc_flags);
+}
+
+/* submit a command */
+int cdc_enc_send_sync(struct cdc_enc_client *client, unsigned char *ms=
g, size_t len)
+{
+	int status;
+	struct cdc_enc_state *cdc_enc =3D client->cdc_enc;
+	struct usb_device *udev =3D interface_to_usbdev(cdc_enc->intf);
+
+	/* enable status even if networking is down */
+	cdc_enc_status_urb(cdc_enc, GFP_KERNEL);
+
+	status =3D usb_control_msg(udev,
+				usb_sndctrlpipe(udev, 0),
+				USB_CDC_SEND_ENCAPSULATED_COMMAND, USB_DIR_OUT|USB_TYPE_CLASS|USB_=
RECIP_INTERFACE,
+				0, cdc_enc->intf->cur_altsetting->desc.bInterfaceNumber,
+				msg, len, 1000);
+
+	/* copy successfully transmitted data to all clients, including ourse=
lves */
+	if (status =3D=3D len)
+		cdc_enc_copy_to_all(cdc_enc, msg, len);
+
+	return status;
+}
+EXPORT_SYMBOL_GPL(cdc_enc_send_sync);
+
+struct cdc_enc_client *cdc_enc_add_client(struct cdc_enc_state *cdc_en=
c, work_func_t recv_callback)
+{
+	struct cdc_enc_client *client;
+
+	client =3D kzalloc(sizeof(struct cdc_enc_client), GFP_KERNEL);
+	if (!client)
+		goto done;
+
+	client->cdc_enc =3D cdc_enc;
+	init_completion(&client->ready);
+
+	/* setup callback */
+	INIT_WORK(&client->work, recv_callback);
+
+	mutex_lock(&cdc_enc->clients_lock);
+	list_add(&client->list, &cdc_enc->clients);
+	mutex_unlock(&cdc_enc->clients_lock);
+
+done:
+	return client;
+}
+EXPORT_SYMBOL_GPL(cdc_enc_add_client);
+
+void cdc_enc_destroy_client(struct cdc_enc_client *client)
+{
+	struct cdc_enc_state *cdc_enc =3D client->cdc_enc;
+
+	mutex_lock(&cdc_enc->clients_lock);
+	cancel_work_sync(&client->work);
+	list_del(&client->list);
+	kfree(client);
+	mutex_unlock(&cdc_enc->clients_lock);
+
+	wake_up(&cdc_enc->waitq);
+}
+EXPORT_SYMBOL_GPL(cdc_enc_destroy_client);
+
+static ssize_t cdc_enc_fops_read(struct file *file, char __user *buf, =
size_t size, loff_t *pos)
+{
+	struct cdc_enc_client *client =3D file->private_data;
+	int ret =3D -EFAULT;
+
+	if (!client || !client->cdc_enc)
+		return -ENODEV;
+
+	while (!test_bit(CDC_ENC_CLIENT_RX, &client->flags)) {/* no data */
+		if (file->f_flags & O_NONBLOCK)
+			return -EAGAIN;
+
+		if (wait_for_completion_interruptible(&client->ready) < 0)
+			return -EINTR;
+
+		/* shutdown requested? */
+		if (test_bit(CDC_ENC_CLIENT_SHUTDOWN, &client->flags))
+			return -ENXIO;
+	}
+
+	/* someone else is using our buffer */
+	if (test_and_set_bit(CDC_ENC_CLIENT_BUSY, &client->flags))
+		return -ERESTARTSYS;
+
+	/* must read a complete packet */
+	if (client->len > size || copy_to_user(buf, client->buf, client->len)=
) {
+		ret =3D -EFAULT;
+		goto err;
+	}
+	ret =3D client->len;
+
+err:
+	/* order is important! */
+	clear_bit(CDC_ENC_CLIENT_RX, &client->flags);
+	clear_bit(CDC_ENC_CLIENT_BUSY, &client->flags);
+
+	return ret;
+}
+
+static ssize_t cdc_enc_fops_write(struct file *file, const char __user=
 *buf, size_t size, loff_t *pos)
+{
+	struct cdc_enc_client *client =3D file->private_data;
+	int ret =3D -EFAULT;
+
+	if (!client || !client->cdc_enc)
+		return -ENODEV;
+
+	/* shutdown requested? */
+	if (test_bit(CDC_ENC_CLIENT_SHUTDOWN, &client->flags))
+		return -ENXIO;
+
+	/* no meaning in attempting to send an incomplete packet */
+	if (size > sizeof(client->tx_buf))
+		return -EFAULT;
+
+	/* are someone else using our buffer? */
+	if (test_and_set_bit(CDC_ENC_CLIENT_TX, &client->flags))
+		return -ERESTARTSYS;
+
+	if (size > sizeof(client->tx_buf) || copy_from_user(client->tx_buf, b=
uf, size))
+		goto err;
+
+	/* send to the device */
+	ret =3D cdc_enc_send_sync(client, client->tx_buf, size);
+	if (ret < 0)
+		return -EFAULT;
+
+err:
+	clear_bit(CDC_ENC_CLIENT_TX, &client->flags);
+	return ret;
+}
+
+/* receive callback for character device */
+static void cdc_enc_newdata_rcvd(struct work_struct *work)
+{
+	struct cdc_enc_client *client =3D container_of(work, struct cdc_enc_c=
lient, work);
+
+	/* signal new data available to any waiting reader */
+	complete(&client->ready);
+}
+
+static int cdc_enc_fops_open(struct inode *inode, struct file *file)
+{
+	struct cdc_enc_state *cdc_enc;
+	struct cdc_enc_client *client;
+
+	/* associate the file with our backing CDC_ENC device */
+	cdc_enc =3D container_of(inode->i_cdev, struct cdc_enc_state, cdev);
+	if (!cdc_enc)
+		return -ENODEV;
+
+	/* don't allow interface to sleep while we are using it */
+	usb_autopm_get_interface(cdc_enc->intf);
+
+	/* enable status URB even if networking is down */
+	cdc_enc_status_urb(cdc_enc, GFP_KERNEL);
+
+	/* set up a ring buffer to receive our readable data? */
+	client =3D cdc_enc_add_client(cdc_enc, cdc_enc_newdata_rcvd);
+
+	if (!client)
+		return -ENOMEM;
+
+	file->private_data =3D client;
+	return 0;
+}
+
+static int cdc_enc_fops_release(struct inode *inode, struct file *file=
)
+{
+	struct cdc_enc_client *client =3D file->private_data;
+	struct cdc_enc_state *cdc_enc =3D client->cdc_enc;
+
+	if (!client || !cdc_enc)
+		return -ENODEV;
+
+	/* allow interface to sleep again */
+	usb_autopm_put_interface(cdc_enc->intf);
+
+	cdc_enc_destroy_client(client);
+	file->private_data =3D NULL;
+	return 0;
+}
+
+static const struct file_operations cdc_enc_fops =3D {
+	.owner   =3D THIS_MODULE,
+	.read    =3D cdc_enc_fops_read,
+	.write   =3D cdc_enc_fops_write,
+	.open    =3D cdc_enc_fops_open,
+	.release =3D cdc_enc_fops_release,
+	.llseek  =3D noop_llseek,
+};
+
+/* submit read URB */
+int cdc_enc_submit_readurb(struct cdc_enc_state *cdc_enc, int kmalloc_=
flags)
+{
+	return usb_submit_urb(cdc_enc->urb, kmalloc_flags);
+
+}
+EXPORT_SYMBOL_GPL(cdc_enc_submit_readurb);
+
+/* kill the read URB */
+void cdc_enc_kill_readurb(struct cdc_enc_state *cdc_enc)
+{
+	usb_kill_urb(cdc_enc->urb);
+}
+EXPORT_SYMBOL_GPL(cdc_enc_kill_readurb);
+
+/* call this to enable interrupt processing when netif is down */
+int cdc_enc_set_interrupt(struct cdc_enc_state *cdc_enc, struct urb *u=
rb)
+{
+	/* save URB once */
+	if (urb && !cdc_enc->interrupt) {
+		cdc_enc->interrupt =3D urb;
+		/* and submit immediately in case we have clients waiting */
+		cdc_enc_status_urb(cdc_enc, GFP_KERNEL);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cdc_enc_set_interrupt);
+
+/* global state relating to the character device */
+static struct class *cdc_enc_class;	/* registered device class */
+static dev_t cdc_enc_dev0;		/* our allocated major/minor range */
+static unsigned long cdc_enc_minor;	/* bitmap of minors in use */
+
+static ssize_t protocol_show(struct device *dev, struct device_attribu=
te *attr, char *buf)
+{
+	struct cdc_enc_state *cdc_enc =3D dev_get_drvdata(dev);
+
+	return sprintf(buf, "%s\n", cdc_enc->protocol ? cdc_enc->protocol : "=
none");
+}
+static struct device_attribute cdc_enc_dev_attrs[] =3D {
+	__ATTR_RO(protocol),
+	__ATTR_NULL
+};
+
+/* allocate and initiate a CDC_ENC state device */
+struct cdc_enc_state *cdc_enc_init_one(struct usb_interface *intf, con=
st char *protocol)
+{
+	struct cdc_enc_state *cdc_enc;
+	dev_t devno;
+	int i, ret;
+	struct usb_device *udev =3D interface_to_usbdev(intf);
+
+	/* find an unused minor */
+	for (i =3D 0; i < CDC_ENC_MAX_MINOR; i++)
+		if (!test_and_set_bit(i, &cdc_enc_minor))
+			break;
+
+	/* no free devices */
+	if (i =3D=3D CDC_ENC_MAX_MINOR)
+		goto err_nodev;
+
+	cdc_enc =3D kzalloc(sizeof(struct cdc_enc_state), GFP_KERNEL);
+	if (!cdc_enc)
+		goto err_nodev;
+
+	/* save protocol name */
+	cdc_enc->protocol =3D protocol;
+
+	/* make device number */
+	devno =3D cdc_enc_dev0 + i;
+
+	/*
+	 * keep track of the device receiving the control messages and the
+	 * number of the CDC (like) control interface which is our target.
+	 * Note that the interface might be disguised as vendor specific,
+	 * and be a combined CDC control/data interface
+	 */
+	cdc_enc->intf =3D intf;
+	/* FIXME: it would be useful to verify that this interface actually t=
alks CDC */
+
+	/* create async receive URB */
+	cdc_enc->urb =3D usb_alloc_urb(0, GFP_KERNEL);
+	if (!cdc_enc->urb)
+		goto err_urb;
+
+	/* usb control setup */
+	cdc_enc->setup.bRequestType =3D USB_DIR_IN|USB_TYPE_CLASS|USB_RECIP_I=
NTERFACE;
+	cdc_enc->setup.bRequest =3D USB_CDC_GET_ENCAPSULATED_RESPONSE;
+	cdc_enc->setup.wValue =3D 0; /* zero */
+	cdc_enc->setup.wIndex =3D intf->cur_altsetting->desc.bInterfaceNumber=
;
+	cdc_enc->setup.wLength =3D CDC_ENC_BUFLEN;
+
+	/* prepare the async receive URB */
+	usb_fill_control_urb(cdc_enc->urb, udev,
+			usb_rcvctrlpipe(udev, 0),
+			(char *)&cdc_enc->setup,
+			cdc_enc->rcvbuf,
+			CDC_ENC_BUFLEN,
+			cdc_enc_read_callback, cdc_enc);
+
+	init_waitqueue_head(&cdc_enc->waitq);
+
+	/* initialize client list */
+	INIT_LIST_HEAD(&cdc_enc->clients);
+	mutex_init(&cdc_enc->clients_lock);
+
+	/* finally, create the character device, using the interface as a par=
ent dev */
+	cdev_init(&cdc_enc->cdev, &cdc_enc_fops);
+	ret =3D cdev_add(&cdc_enc->cdev, devno, 1);
+	if (ret < 0)
+		goto err_cdev;
+
+	device_create(cdc_enc_class, &intf->dev, devno, cdc_enc, "cdc-enc%d",=
 i);
+	dev_info(&intf->dev, "attached to cdc-enc%d using protocol '%s'\n", i=
, protocol);
+
+	/* this must be set later by calling cdc_enc_set_interrupt() */
+	cdc_enc->interrupt =3D NULL;
+
+
+	return cdc_enc;
+
+err_cdev:
+	usb_free_urb(cdc_enc->urb);
+err_urb:
+	kfree(cdc_enc);
+err_nodev:
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(cdc_enc_init_one);
+
+/* disable and free a CDC_ENC state device */
+int cdc_enc_free_one(struct cdc_enc_state *cdc_enc)
+{
+	struct cdc_enc_client *tmp;
+
+	/* kill any pending recv urb */
+	cdc_enc_kill_readurb(cdc_enc);
+
+	/* wait for all clients to exit first ... */
+	list_for_each_entry(tmp, &cdc_enc->clients, list) {
+		dev_dbg(&cdc_enc->intf->dev, "waiting for client %p to die\n", tmp);
+		set_bit(CDC_ENC_CLIENT_SHUTDOWN, &tmp->flags);
+		complete(&tmp->ready);
+	}
+	wait_event_interruptible(cdc_enc->waitq, list_empty(&cdc_enc->clients=
));
+
+	/* delete character device */
+	device_destroy(cdc_enc_class, cdc_enc->cdev.dev);
+	cdev_del(&cdc_enc->cdev);
+
+	/* free URB */
+	usb_free_urb(cdc_enc->urb);
+
+	/* mark minor available again */
+	clear_bit(MINOR(cdc_enc->cdev.dev) - MINOR(cdc_enc_dev0), &cdc_enc_mi=
nor);
+
+	/* release this slot */
+	kfree(cdc_enc);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(cdc_enc_free_one);
+
+static int __init cdc_enc_init(void)
+{
+	int ret;
+
+	ret =3D alloc_chrdev_region(&cdc_enc_dev0, 0, CDC_ENC_MAX_MINOR, "cdc=
_enc");
+	if (ret < 0)
+		goto err_region;
+
+	/* create a chardev class */
+	cdc_enc_class =3D class_create(THIS_MODULE, "cdc_enc");
+	if (IS_ERR(cdc_enc_class)) {
+		ret =3D PTR_ERR(cdc_enc_class);
+		goto err_class;
+	}
+	cdc_enc_class->dev_attrs =3D cdc_enc_dev_attrs;
+
+	return 0;
+
+err_class:
+	unregister_chrdev_region(cdc_enc_dev0, CDC_ENC_MAX_MINOR);
+err_region:
+	return ret;
+}
+module_init(cdc_enc_init);
+
+static void __exit cdc_enc_exit(void)
+{
+	class_destroy(cdc_enc_class);
+	unregister_chrdev_region(cdc_enc_dev0, CDC_ENC_MAX_MINOR);
+}
+module_exit(cdc_enc_exit);
+
+MODULE_AUTHOR("Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>");
+MODULE_DESCRIPTION("CDC Encapsulated Command Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/usb/cdc_enc.h b/drivers/net/usb/cdc_enc.h
new file mode 100644
index 0000000..44bffff
--- /dev/null
+++ b/drivers/net/usb/cdc_enc.h
@@ -0,0 +1,77 @@
+/*
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#ifndef _CDC_ENC_H_
+#define _CDC_ENC_H_
+
+#include <linux/cdev.h>
+#include <linux/list.h>
+#include <linux/usb.h>
+
+#define CDC_ENC_BUFLEN 512
+#define CDC_ENC_MAX_MINOR 16
+
+enum cdc_enc_client_flag {
+	CDC_ENC_CLIENT_BUSY =3D 0,	/* RX buffer is in use */
+	CDC_ENC_CLIENT_TX,		/* TX buffer is in use */
+	CDC_ENC_CLIENT_RX,		/* new data available */
+	CDC_ENC_CLIENT_SHUTDOWN,	/* shutdown requested */
+};
+
+/* per client data */
+struct cdc_enc_client {
+	unsigned char buf[CDC_ENC_BUFLEN];	/* rx buffer */
+	unsigned char tx_buf[CDC_ENC_BUFLEN];	/* tx buffer */
+	size_t len;			/* length of data in rx buffer */
+	unsigned long flags;
+	struct cdc_enc_state *cdc_enc;	/* CDC_ENC instance owning the client =
*/
+	struct completion ready;
+	struct list_head list;		/* linux/list.h pointers */
+	struct work_struct work;	/* task to call when new data is recvd */
+	unsigned long priv;		/* client specific data */
+};
+
+/* per CDC_ENC interface state */
+struct cdc_enc_state {
+	struct usb_interface *intf;
+	struct urb *urb;		/* receive urb */
+	struct urb *interrupt;		/* interrupt urb */
+	unsigned char rcvbuf[CDC_ENC_BUFLEN];     /* receive buffer */
+	struct usb_ctrlrequest setup;	/* the receive setup - 8 bytes */
+	struct list_head clients;	/* list of clients - first entry is wwan cl=
ient */
+	struct mutex clients_lock;
+	struct cdev cdev;		/* registered character device */
+	const char *protocol;
+	wait_queue_head_t waitq;	/* so we can wait for all clients on exit */
+};
+
+/* submit the read URB immediately - can be called in interrupt contex=
t */
+extern int cdc_enc_submit_readurb(struct cdc_enc_state *cdc_enc, int k=
malloc_flags);
+
+/* kill the read URB */
+extern void cdc_enc_kill_readurb(struct cdc_enc_state *cdc_enc);
+
+/* call this to enable cdc_enc to submit the interrupt URB when it nee=
ds to */
+extern int cdc_enc_set_interrupt(struct cdc_enc_state *cdc_enc, struct=
 urb *urb);
+
+/* initialize */
+extern struct cdc_enc_state *cdc_enc_init_one(struct usb_interface *in=
tf, const char *protocol);
+
+/* clean up */
+extern int cdc_enc_free_one(struct cdc_enc_state *cdc_enc);
+
+/* send a synchronous message from client */
+extern int cdc_enc_send_sync(struct cdc_enc_client *client, unsigned c=
har *msg, size_t len);
+
+/* get a new client */
+extern struct cdc_enc_client *cdc_enc_add_client(struct cdc_enc_state =
*cdc_enc, work_func_t recv_callback);
+
+/* destroy client */
+extern void cdc_enc_destroy_client(struct cdc_enc_client *client);
+
+#endif /* _CDC_ENC_H_ */
--=20
1.7.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
