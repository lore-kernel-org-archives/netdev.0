From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 19/19] virtio: add a vbus transport
Date: Thu, 09 Apr 2009 12:32:21 -0400
Message-ID: <20090409163221.32740.38373.stgit@dev.haskins.net>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:46030 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935572AbZDIQaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 12:30:14 -0400
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add a new virtio transport for accessing backends located on vbus.  This
complements the existing transports for virtio-pci, virtio-s390, and
virtio-lguest that already exist.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 drivers/virtio/Kconfig       |   15 +
 drivers/virtio/Makefile      |    1 
 drivers/virtio/virtio_vbus.c |  496 +++++++++++++++++++++++++++++++++
 include/linux/virtio_vbus.h  |  163 +++++++++++
 kernel/vbus/Kconfig          |    7 
 kernel/vbus/Makefile         |    3 
 kernel/vbus/virtio.c         |  628 ++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1313 insertions(+), 0 deletions(-)
 create mode 100644 drivers/virtio/virtio_vbus.c
 create mode 100644 include/linux/virtio_vbus.h
 create mode 100644 kernel/vbus/virtio.c

diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index 3dd6294..e8562ee 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -23,6 +23,21 @@ config VIRTIO_PCI
 
 	  If unsure, say M.
 
+config VIRTIO_VBUS
+	tristate "VBUS driver for virtio devices (EXPERIMENTAL)"
+	depends on VBUS_DRIVERS && EXPERIMENTAL
+	select VIRTIO
+	select VIRTIO_RING
+	---help---
+	  This drivers provides support for virtio based paravirtual device
+	  drivers over VBUS.  This requires that your VMM has appropriate VBUS
+	  virtio backends.
+
+	  Currently, the ABI is not considered stable so there is no guarantee
+	  that this version of the driver will work with your VMM.
+
+	  If unsure, say M.
+
 config VIRTIO_BALLOON
 	tristate "Virtio balloon driver (EXPERIMENTAL)"
 	select VIRTIO
diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
index 6738c44..0342e42 100644
--- a/drivers/virtio/Makefile
+++ b/drivers/virtio/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_VIRTIO) += virtio.o
 obj-$(CONFIG_VIRTIO_RING) += virtio_ring.o
 obj-$(CONFIG_VIRTIO_PCI) += virtio_pci.o
+obj-$(CONFIG_VIRTIO_VBUS) += virtio_vbus.o
 obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
diff --git a/drivers/virtio/virtio_vbus.c b/drivers/virtio/virtio_vbus.c
new file mode 100644
index 0000000..ebefcf2
--- /dev/null
+++ b/drivers/virtio/virtio_vbus.c
@@ -0,0 +1,496 @@
+/*
+ * Virtio VBUS driver
+ *
+ * This module allows virtio devices to be used over a virtual-bus device.
+ *
+ * Copyright: Novell, 2009
+ *
+ * Authors:
+ *  Gregory Haskins <ghaskins@novell.com>
+ *
+ * Derived from virtio-pci, written by
+ *  Anthony Liguori  <aliguori@us.ibm.com>
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2 or later.
+ * See the COPYING file in the top-level directory.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/virtio.h>
+#include <linux/virtio_config.h>
+#include <linux/virtio_ring.h>
+#include <linux/virtio_vbus.h>
+#include <linux/vbus_driver.h>
+#include <linux/spinlock.h>
+
+MODULE_AUTHOR("Gregory Haskins <ghaskins@novell.com>");
+MODULE_DESCRIPTION("virtio-vbus");
+MODULE_LICENSE("GPL");
+MODULE_VERSION("1");
+
+struct virtio_vbus_priv {
+	struct virtio_device                   virtio_dev;
+	struct vbus_device_proxy              *vbus_dev;
+	struct {
+		struct virtio_vbus_shm        *shm;
+		struct shm_signal             *signal;
+		struct shm_signal_notifier     notifier;
+	} config;
+};
+
+struct vbus_virtqueue {
+	struct virtqueue           *vq;
+	u64                         index;
+	int                         num;
+	struct virtio_vbus_shm     *shm;
+	size_t                      size;
+	struct shm_signal          *signal;
+	struct shm_signal_notifier  notifier;
+};
+
+static struct virtio_vbus_priv *
+virtio_to_priv(struct virtio_device *virtio_dev)
+{
+	return container_of(virtio_dev, struct virtio_vbus_priv, virtio_dev);
+}
+
+static int
+devcall(struct virtio_vbus_priv *priv, u32 func, void *data, size_t len)
+{
+	struct vbus_device_proxy *dev = priv->vbus_dev;
+
+	return dev->ops->call(dev, func, data, len, 0);
+}
+
+/*
+ * This is called whenever the host signals our config-space shm
+ */
+static void
+config_isr(struct shm_signal_notifier *notifier)
+{
+	struct virtio_vbus_priv *priv = container_of(notifier,
+						     struct virtio_vbus_priv,
+						     config.notifier);
+	struct virtio_driver *drv = container_of(priv->virtio_dev.dev.driver,
+						 struct virtio_driver, driver);
+
+	if (drv && drv->config_changed)
+		drv->config_changed(&priv->virtio_dev);
+}
+
+/*
+ * ------------------
+ * virtio config ops
+ * ------------------
+ */
+
+static u32
+_virtio_get_features(struct virtio_device *dev)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(dev);
+	u32 features;
+	int ret;
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_GET_FEATURES,
+		      &features, sizeof(features));
+	BUG_ON(ret < 0);
+
+	/*
+	 * When someone needs more than 32 feature bits, we'll need to
+	 * steal a bit to indicate that the rest are somewhere else.
+	 */
+	return features;
+}
+
+static void
+_virtio_finalize_features(struct virtio_device *dev)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(dev);
+	int ret;
+
+	/* Give virtio_ring a chance to accept features. */
+	vring_transport_features(dev);
+
+	/* We only support 32 feature bits. */
+	BUILD_BUG_ON(ARRAY_SIZE(dev->features) != 1);
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_FINALIZE_FEATURES,
+		      &dev->features[0], sizeof(dev->features[0]));
+	BUG_ON(ret < 0);
+}
+
+static void
+_virtio_get(struct virtio_device *vdev, unsigned offset,
+	    void *buf, unsigned len)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vdev);
+
+	BUG_ON((offset + len) > VIRTIO_VBUS_CONFIGSPACE_LEN);
+	memcpy(buf, &priv->config.shm->data[offset], len);
+}
+
+static void
+_virtio_set(struct virtio_device *vdev, unsigned offset,
+	    const void *buf, unsigned len)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vdev);
+	int ret;
+
+	BUG_ON((offset + len) > VIRTIO_VBUS_CONFIGSPACE_LEN);
+	memcpy(&priv->config.shm->data[offset], buf, len);
+
+	ret = shm_signal_inject(priv->config.signal, 0);
+	BUG_ON(ret < 0);
+}
+
+static u8
+_virtio_get_status(struct virtio_device *vdev)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vdev);
+	u8 data;
+	int ret;
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_GET_STATUS, &data, sizeof(data));
+	BUG_ON(ret < 0);
+
+	return data;
+}
+
+static void
+_virtio_set_status(struct virtio_device *vdev, u8 status)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vdev);
+	int ret;
+
+	/* We should never be setting status to 0. */
+	BUG_ON(status == 0);
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_SET_STATUS, &status,
+		      sizeof(status));
+	BUG_ON(ret < 0);
+}
+
+static void
+_virtio_reset(struct virtio_device *vdev)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vdev);
+	int ret;
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_RESET, NULL, 0);
+	BUG_ON(ret < 0);
+}
+
+/*
+ * ------------------
+ * virtqueue ops
+ * ------------------
+ */
+
+static int
+_vq_getlen(struct virtio_vbus_priv *priv, int index)
+{
+	struct virtio_vbus_queryqueue query = {
+		.index = index,
+	};
+	int ret;
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_QUERY_QUEUE,
+		      &query, sizeof(query));
+	if (ret < 0)
+		return ret;
+
+	return query.num;
+}
+
+static void
+_vq_kick(struct virtqueue *vq)
+{
+	struct vbus_virtqueue *_vq = vq->priv;
+	int ret;
+
+	ret = shm_signal_inject(_vq->signal, 0);
+	BUG_ON(ret < 0);
+}
+
+/*
+ * This is called whenever the host signals our virtqueue
+ */
+static void
+_vq_isr(struct shm_signal_notifier *notifier)
+{
+	struct vbus_virtqueue *_vq = container_of(notifier,
+						  struct vbus_virtqueue,
+						  notifier);
+	vring_interrupt(0, _vq->vq);
+}
+
+static struct virtqueue *
+_virtio_find_vq(struct virtio_device *vdev, unsigned index,
+	 void (*callback)(struct virtqueue *vq))
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vdev);
+	struct vbus_device_proxy *dev = priv->vbus_dev;
+	struct vbus_virtqueue *_vq;
+	struct virtqueue *vq;
+	unsigned long ringsize;
+	int num;
+	int ret;
+
+	num = _vq_getlen(priv, index);
+	if (num < 0)
+		return ERR_PTR(num);
+
+	_vq = kmalloc(sizeof(struct vbus_virtqueue), GFP_KERNEL);
+	if (!_vq)
+		return ERR_PTR(-ENOMEM);
+
+	ringsize = vring_size(num, PAGE_SIZE);
+
+	_vq->index = index;
+	_vq->num   = num;
+	_vq->size  = PAGE_ALIGN(sizeof(struct virtio_vbus_shm) + ringsize - 1);
+
+	_vq->shm = alloc_pages_exact(_vq->size, GFP_KERNEL|__GFP_ZERO);
+	if (!_vq->shm) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	/* initialize the shm with a ring */
+	vq = vring_new_virtqueue(_vq->num, PAGE_SIZE, vdev,
+				 &_vq->shm->data[0],
+				 _vq_kick,
+				 callback);
+	if (!vq) {
+		ret = -ENOMEM;
+		goto out_free;
+	}
+
+	/* register the shm with an id of the vq index + RING_OFFSET */
+	ret = dev->ops->shm(dev, index + VIRTIO_VBUS_RING_OFFSET, 0,
+			    _vq->shm, _vq->size,
+			    &_vq->shm->signal, &_vq->signal, 0);
+	if (ret < 0)
+		goto out_free;
+
+	_vq->notifier.signal = &_vq_isr;
+	_vq->signal->notifier = &_vq->notifier;
+
+	shm_signal_enable(_vq->signal, 0);
+
+	vq->priv = _vq;
+	_vq->vq = vq;
+
+	return vq;
+
+out_free:
+	free_pages_exact(_vq->shm, _vq->size);
+out:
+	if (_vq && _vq->signal)
+		shm_signal_put(_vq->signal);
+	kfree(_vq);
+	return ERR_PTR(ret);
+}
+
+/* the config->del_vq() implementation */
+static void
+_virtio_del_vq(struct virtqueue *vq)
+{
+	struct virtio_vbus_priv *priv = virtio_to_priv(vq->vdev);
+	struct vbus_virtqueue *_vq = vq->priv;
+
+	devcall(priv, VIRTIO_VBUS_FUNC_DEL_QUEUE,
+		&_vq->index, sizeof(_vq->index));
+
+	vring_del_virtqueue(vq);
+
+	shm_signal_put(_vq->signal);
+	free_pages_exact(_vq->shm, _vq->size);
+	kfree(_vq);
+}
+
+/*
+ * ------------------
+ * general setup
+ * ------------------
+ */
+
+static struct virtio_config_ops virtio_vbus_config_ops = {
+	.get		   = _virtio_get,
+	.set		   = _virtio_set,
+	.get_status	   = _virtio_get_status,
+	.set_status	   = _virtio_set_status,
+	.reset		   = _virtio_reset,
+	.find_vq	   = _virtio_find_vq,
+	.del_vq		   = _virtio_del_vq,
+	.get_features	   = _virtio_get_features,
+	.finalize_features = _virtio_finalize_features,
+};
+
+/*
+ * Negotiate vbus transport features.  This is not to be confused with the
+ * higher-level function FUNC_GET/FINALIZE_FEATURES, which is specifically
+ * for the virtio transport
+ */
+static void
+virtio_vbus_negcap(struct virtio_vbus_priv *priv)
+{
+	u64 features = 0; /* We do not have any advanced features to enable */
+	int ret;
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_NEG_CAP,
+		      &features, sizeof(features));
+	BUG_ON(ret < 0);
+}
+
+static void
+virtio_vbus_getid(struct virtio_vbus_priv *priv)
+{
+	struct virtio_vbus_id id;
+	int ret;
+
+	ret = devcall(priv, VIRTIO_VBUS_FUNC_GET_ID, &id, sizeof(id));
+	BUG_ON(ret < 0);
+
+	priv->virtio_dev.id.vendor = id.vendor;
+	priv->virtio_dev.id.device = id.device;
+}
+
+static int
+virtio_vbus_initconfig(struct virtio_vbus_priv *priv)
+{
+	struct vbus_device_proxy *vdev = priv->vbus_dev;
+	size_t len;
+	int ret;
+
+	len = sizeof(struct virtio_vbus_shm) + VIRTIO_VBUS_CONFIGSPACE_LEN - 1;
+
+	priv->config.shm = kzalloc(len, GFP_KERNEL);
+	if (!priv->config.shm)
+		return -ENOMEM;
+
+	ret = vdev->ops->shm(vdev, 0, 0,
+			     &priv->config.shm, len,
+			     &priv->config.shm->signal, &priv->config.signal,
+			     0);
+	BUG_ON(ret < 0);
+
+	priv->config.notifier.signal = &config_isr;
+	priv->config.signal->notifier = &priv->config.notifier;
+
+	shm_signal_enable(priv->config.signal, 0);
+
+	return 0;
+}
+
+/* the VBUS probing function */
+static int
+virtio_vbus_probe(struct vbus_device_proxy *vdev)
+{
+	struct virtio_vbus_priv *priv;
+	int ret;
+
+	printk(KERN_INFO "VIRTIO-VBUS: Found new device at %lld\n", vdev->id);
+
+	ret = vdev->ops->open(vdev, VIRTIO_VBUS_ABI_VERSION, 0);
+	if (ret < 0) {
+		printk(KERN_ERR "virtio_vbus: ABI version %d failed with: %d\n",
+		       VIRTIO_VBUS_ABI_VERSION, ret);
+		return ret;
+	}
+
+	priv = kzalloc(sizeof(struct virtio_vbus_priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->virtio_dev.config = &virtio_vbus_config_ops;
+	priv->vbus_dev = vdev;
+
+	/*
+	 * Negotiate for any vbus specific features
+	 */
+	virtio_vbus_negcap(priv);
+
+	/*
+	 * This probe occurs for any "virtio" device on the vbus, so we need
+	 * to hypercall the host to figure out what specific PCI-ID type
+	 * device this is
+	 */
+	virtio_vbus_getid(priv);
+
+	/*
+	 * Map our config-space to the device, and establish a signal-path
+	 * for config-space updates
+	 */
+	virtio_vbus_initconfig(priv);
+
+	/* finally register the virtio device */
+	ret = register_virtio_device(&priv->virtio_dev);
+	if (ret)
+		goto out;
+
+	vdev->priv = priv;
+
+	return 0;
+
+out:
+	kfree(priv);
+	return ret;
+}
+
+#ifdef NOTYET
+/* FIXME: wire this up */
+static void
+virtio_vbus_release(struct virtio_vbus_priv *priv)
+{
+	shm_signal_put(priv->config.signal);
+	kfree(priv->config.shm);
+	kfree(priv);
+}
+
+#endif
+
+static int
+virtio_vbus_remove(struct vbus_device_proxy *vdev)
+{
+	struct virtio_vbus_priv *priv = vdev->priv;
+
+	unregister_virtio_device(&priv->virtio_dev);
+
+	return 0;
+}
+
+/*
+ * Finally, the module stuff
+ */
+
+static struct vbus_driver_ops virtio_vbus_driver_ops = {
+	.probe  = virtio_vbus_probe,
+	.remove = virtio_vbus_remove,
+};
+
+static struct vbus_driver virtio_vbus_driver = {
+	.type   = "virtio",
+	.owner  = THIS_MODULE,
+	.ops    = &virtio_vbus_driver_ops,
+};
+
+static __init int
+virtio_vbus_init_module(void)
+{
+	printk(KERN_INFO "Virtio-VBUS: Copyright (C) 2009 Novell, Gregory Haskins\n");
+	return vbus_driver_register(&virtio_vbus_driver);
+}
+
+static __exit void
+virtio_vbus_cleanup(void)
+{
+	vbus_driver_unregister(&virtio_vbus_driver);
+}
+
+module_init(virtio_vbus_init_module);
+module_exit(virtio_vbus_cleanup);
+
diff --git a/include/linux/virtio_vbus.h b/include/linux/virtio_vbus.h
new file mode 100644
index 0000000..05791bf
--- /dev/null
+++ b/include/linux/virtio_vbus.h
@@ -0,0 +1,163 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Virtio VBUS driver
+ *
+ * This module allows virtio devices to be used over a VBUS interface
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#ifndef _LINUX_VIRTIO_VBUS_H
+#define _LINUX_VIRTIO_VBUS_H
+
+#include <linux/shm_signal.h>
+
+#define VIRTIO_VBUS_ABI_VERSION 1
+
+enum {
+	VIRTIO_VBUS_FUNC_NEG_CAP,
+	VIRTIO_VBUS_FUNC_GET_ID,
+	VIRTIO_VBUS_FUNC_GET_FEATURES,
+	VIRTIO_VBUS_FUNC_FINALIZE_FEATURES,
+	VIRTIO_VBUS_FUNC_GET_STATUS,
+	VIRTIO_VBUS_FUNC_SET_STATUS,
+	VIRTIO_VBUS_FUNC_RESET,
+	VIRTIO_VBUS_FUNC_QUERY_QUEUE,
+	VIRTIO_VBUS_FUNC_DEL_QUEUE,
+};
+
+struct virtio_vbus_id {
+	u16 vendor;
+	u16 device;
+};
+
+struct virtio_vbus_queryqueue {
+	u64 index;  /* in: queue index */
+	u32 num;    /* out: number of entries */
+	u32 pad[0];
+};
+
+#define VIRTIO_VBUS_CONFIGSPACE_LEN 1024
+#define VIRTIO_VBUS_RING_OFFSET     10000 /* shm-index where rings start */
+
+struct virtio_vbus_shm {
+	struct shm_signal_desc signal;
+	char                   data[1];
+};
+
+/*
+ * --------------------------------------------------
+ * Backend support - These components are only needed
+ * for interfacing a virtio-backend to the vbus-backend
+ * --------------------------------------------------
+ */
+
+#include <linux/vbus_device.h>
+
+struct virtio_device_interface;
+struct virtio_connection;
+
+struct virtio_queue_def {
+	int index;
+	int entries;
+};
+
+/*
+ * ----------------------
+ * interface
+ * ----------------------
+ */
+
+struct virtio_device_interface_ops {
+	int (*open)(struct virtio_device_interface *intf,
+		    struct vbus_memctx *ctx,
+		    struct virtio_connection **conn);
+	void (*release)(struct virtio_device_interface *intf);
+};
+
+struct virtio_device_interface {
+	struct virtio_vbus_id id;
+	struct virtio_device_interface_ops *ops;
+	struct virtio_queue_def *queues;
+	struct vbus_device_interface *parent;
+};
+
+/**
+ * virtio_device_interface_register() - register an interface with a bus
+ * @dev:        The device context of the caller
+ * @vbus:       The bus context to register with
+ * @intf:       The interface context to register
+ *
+ * This function is invoked (usually in the context of a device::bus_connect()
+ * callback) to register a interface on a bus.  We make this an explicit
+ * operation instead of implicit on the bus_connect() to facilitate devices
+ * that may present multiple interfaces to a bus.  In those cases, a device
+ * may invoke this function multiple times (one per supported interface).
+ *
+ * Returns: success = 0, <0 = ERRNO
+ *
+ **/
+int virtio_device_interface_register(struct vbus_device *dev,
+				   struct vbus *vbus,
+				   struct virtio_device_interface *intf);
+
+/**
+ * virtio_device_interface_unregister() - unregister an interface with a bus
+ * @intf:       The interface context to unregister
+ *
+ * This function is the converse of interface_register.  It is typically
+ * invoked in the context of a device::bus_disconnect().
+ *
+ * Returns: success = 0, <0 = ERRNO
+ *
+ **/
+int virtio_device_interface_unregister(struct virtio_device_interface *intf);
+
+/*
+ * ----------------------
+ * connection
+ * ----------------------
+ */
+struct virtqueue;
+
+struct virtio_connection_ops {
+	void (*config_changed)(struct virtio_connection *vconn);
+	u8 (*get_status)(struct virtio_connection *vconn);
+	void (*set_status)(struct virtio_connection *vconn, u8 status);
+	void (*reset)(struct virtio_connection *vconn);
+	u32 (*get_features)(struct virtio_connection *vconn);
+	void (*finalize_features)(struct virtio_connection *vconn);
+	void (*add_vq)(struct virtio_connection *vconn, int index,
+		       struct virtqueue *vq);
+	void (*del_vq)(struct virtio_connection *vconn, int index);
+	void (*notify_vq)(struct virtio_connection *vconn, int index);
+	void (*release)(struct virtio_connection *conn);
+};
+
+struct virtio_connection {
+	struct virtio_connection_ops *ops;
+	struct vbus_connection *parent;
+};
+
+int virtio_connection_config_get(struct virtio_connection *vconn,
+				 int offset, void *buf, size_t len);
+
+int virtio_connection_config_set(struct virtio_connection *vconn,
+				 int offset, void *buf, size_t len);
+
+#endif /* _LINUX_VIRTIO_VBUS_H */
diff --git a/kernel/vbus/Kconfig b/kernel/vbus/Kconfig
index b894dd1..5eeced2 100644
--- a/kernel/vbus/Kconfig
+++ b/kernel/vbus/Kconfig
@@ -14,6 +14,13 @@ config VBUS
 
 	If unsure, say N
 
+config VBUS_VIRTIO_BACKEND
+       tristate "Virtio VBUS Backend"
+       depends on VBUS
+       default n
+       help
+        Provides backend support for virtio devices over vbus
+
 config VBUS_DEVICES
        bool "Virtual-Bus Devices"
        depends on VBUS
diff --git a/kernel/vbus/Makefile b/kernel/vbus/Makefile
index 61d0371..c2bd140 100644
--- a/kernel/vbus/Makefile
+++ b/kernel/vbus/Makefile
@@ -1,6 +1,9 @@
 obj-$(CONFIG_VBUS) += core.o devclass.o config.o attribute.o map.o client.o
 obj-$(CONFIG_VBUS) += shm-ioq.o
 
+virtio-backend-objs += virtio.o
+obj-$(CONFIG_VBUS_VIRTIO_BACKEND) += virtio-backend.o
+
 vbus-proxy-objs += proxy.o
 obj-$(CONFIG_VBUS_DRIVERS) += vbus-proxy.o
 
diff --git a/kernel/vbus/virtio.c b/kernel/vbus/virtio.c
new file mode 100644
index 0000000..dac5cd4
--- /dev/null
+++ b/kernel/vbus/virtio.c
@@ -0,0 +1,628 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/virtio.h>
+#include <linux/virtio_ring.h>
+#include <linux/virtio_vbus.h>
+
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+
+#undef PDEBUG
+#ifdef VENETTAP_DEBUG
+#  define PDEBUG(fmt, args...) printk(KERN_DEBUG "virtio-vbus: " fmt, ## args)
+#else
+#  define PDEBUG(fmt, args...)
+#endif
+
+struct _virtio_device_interface {
+	struct virtio_device_interface *vintf;
+	struct vbus_device_interface    intf;
+};
+
+struct _virtio_connection {
+	struct _virtio_device_interface *_vintf;
+	struct virtio_connection        *vconn;
+	struct vbus_connection           conn;
+	struct vbus_memctx              *ctx;
+	struct list_head                 queues;
+
+	struct {
+		struct vbus_shm            *shm;
+		struct shm_signal          *signal;
+		struct shm_signal_notifier  notifier;
+	} config;
+
+	int running:1;
+};
+
+struct _virtio_queue {
+	int                         index;
+	int                         num;
+	struct _virtio_connection  *_vconn;
+	struct virtqueue           *vq;
+
+	struct vbus_shm            *shm;
+	struct shm_signal          *signal;
+	struct shm_signal_notifier  notifier;
+
+	struct list_head            node;
+};
+
+static struct _virtio_device_interface *
+to_vintf(struct vbus_device_interface *intf)
+{
+	return container_of(intf, struct _virtio_device_interface, intf);
+}
+
+static struct _virtio_connection *
+to_vconn(struct vbus_connection *conn)
+{
+	return container_of(conn, struct _virtio_connection, conn);
+}
+
+int virtio_connection_config_get(struct virtio_connection *vconn,
+				 int offset, void *buf, size_t len)
+{
+	struct _virtio_connection *_vconn = to_vconn(vconn->parent);
+	char *data;
+
+	if (!_vconn->config.shm)
+		return -EINVAL;
+
+	if (offset + len > _vconn->config.shm->len)
+		return -EINVAL;
+
+	data = _vconn->config.shm->ptr;
+
+	memcpy(buf, &data[offset], len);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_connection_config_get);
+
+int virtio_connection_config_set(struct virtio_connection *vconn,
+				 int offset, void *buf, size_t len)
+{
+	struct _virtio_connection *_vconn = to_vconn(vconn->parent);
+	char *data;
+
+	if (!_vconn->config.shm)
+		return -EINVAL;
+
+	if (offset + len > _vconn->config.shm->len)
+		return -EINVAL;
+
+	data = _vconn->config.shm->ptr;
+
+	memcpy(&data[offset], buf, len);
+
+	if (_vconn->config.signal)
+		shm_signal_inject(_vconn->config.signal, 0);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(virtio_connection_config_set);
+
+/*
+ * Negotiate Capabilities - This function is provided so that the
+ * interface may be extended without breaking ABI compatability
+ *
+ * The caller is expected to send down any capabilities they would like
+ * to enable, and the device will OR them with capabilities that it
+ * supports.  This value is then returned so that both sides may
+ * ascertain the lowest-common-denominator of features to enable
+ */
+static int
+_virtio_connection_negcap(struct _virtio_connection *_vconn,
+			  void *data, unsigned long len)
+{
+	struct vbus_memctx *ctx = _vconn->ctx;
+	u64 features;
+	int ret;
+
+	if (len != sizeof(features))
+		return -EINVAL;
+
+	if (_vconn->running)
+		return -EINVAL;
+
+#ifdef NOTYET
+	ret = ctx->ops->copy_from(ctx, &features, data, sizeof(features));
+	if (ret)
+		return -EFAULT;
+#endif
+
+	/*
+	 * right now we dont support any advanced features, so just clear all
+	 * bits
+	 */
+	features = 0;
+
+	ret = ctx->ops->copy_to(ctx, data, &features, sizeof(features));
+	if (ret)
+		return -EFAULT;
+
+	return 0;
+}
+
+static int
+_virtio_connection_getid(struct _virtio_connection *_vconn,
+			 void *data, unsigned long len)
+{
+	struct vbus_memctx *ctx = _vconn->ctx;
+	struct virtio_vbus_id *id = &_vconn->_vintf->vintf->id;
+	int ret;
+
+	if (len != sizeof(*id))
+		return -EINVAL;
+
+	ret = ctx->ops->copy_to(ctx, data, id, sizeof(*id));
+	if (ret)
+		return -EFAULT;
+
+	return 0;
+}
+
+static int
+_virtio_connection_getstatus(struct _virtio_connection *_vconn,
+			     void *data, unsigned long len)
+{
+	struct virtio_connection *vconn = _vconn->vconn;
+	struct vbus_memctx *ctx = _vconn->ctx;
+	u8 val = 0;
+	int ret;
+
+	if (len != sizeof(val))
+		return -EINVAL;
+
+	if (vconn->ops->get_status)
+		val = vconn->ops->get_status(vconn);
+
+	ret = ctx->ops->copy_to(ctx, data, &val, sizeof(val));
+	if (ret)
+		return -EFAULT;
+
+	return 0;
+}
+
+static int
+_virtio_connection_setstatus(struct _virtio_connection *_vconn,
+			     void *data, unsigned long len)
+{
+	struct virtio_connection *vconn = _vconn->vconn;
+	struct vbus_memctx *ctx = _vconn->ctx;
+	u8 val;
+	int ret;
+
+	if (len != sizeof(val))
+		return -EINVAL;
+
+	if (!vconn->ops->set_status)
+		return 0;
+
+	ret = ctx->ops->copy_from(ctx, &val, data, sizeof(val));
+	if (ret)
+		return -EFAULT;
+
+	vconn->ops->set_status(vconn, val);
+
+	return 0;
+}
+
+static int
+_virtio_connection_getfeatures(struct _virtio_connection *_vconn,
+			       void *data, unsigned long len)
+{
+	struct virtio_connection *vconn = _vconn->vconn;
+	struct vbus_memctx *ctx = _vconn->ctx;
+	u32 val = 0;
+	int ret;
+
+	if (len != sizeof(val))
+		return -EINVAL;
+
+	if (vconn->ops->get_features)
+		val = vconn->ops->get_features(vconn);
+
+	ret = ctx->ops->copy_to(ctx, data, &val, sizeof(val));
+	if (ret)
+		return -EFAULT;
+
+	return 0;
+}
+
+static int
+_virtio_connection_finalizefeatures(struct _virtio_connection *_vconn)
+{
+	struct virtio_connection *vconn = _vconn->vconn;
+
+	if (vconn->ops->finalize_features)
+		vconn->ops->finalize_features(vconn);
+
+	return 0;
+}
+
+static int
+_virtio_connection_reset(struct _virtio_connection *_vconn)
+{
+	struct virtio_connection *vconn = _vconn->vconn;
+
+	if (vconn->ops->reset)
+		vconn->ops->reset(vconn);
+
+	return 0;
+}
+
+static struct _virtio_queue *
+_virtio_find_queue(struct _virtio_connection *_vconn, int index)
+{
+	struct _virtio_queue *vq;
+
+	list_for_each_entry(vq, &_vconn->queues, node) {
+		if (vq->index == index)
+			return vq;
+	}
+
+	return NULL;
+}
+
+static int
+_virtio_connection_queryqueue(struct _virtio_connection *_vconn,
+			      void *data, unsigned long len)
+{
+	struct vbus_memctx *ctx = _vconn->ctx;
+	struct virtio_vbus_queryqueue val;
+	struct _virtio_queue *vq;
+	int ret;
+
+	if (len != sizeof(val))
+		return -EINVAL;
+
+	ret = ctx->ops->copy_from(ctx, &val, data, sizeof(val));
+	if (ret)
+		return -EFAULT;
+
+	vq = _virtio_find_queue(_vconn, val.index);
+
+	if (!vq)
+		return -EINVAL;
+
+	if (vq->shm)
+		return -EEXIST;
+
+	val.num = vq->num;
+
+	ret = ctx->ops->copy_to(ctx, data, &val, sizeof(val));
+	if (ret)
+		return -EFAULT;
+
+	return 0;
+}
+
+static int
+_virtio_connection_call(struct vbus_connection *conn,
+		    unsigned long func,
+		    void *data,
+		    unsigned long len,
+		    unsigned long flags)
+{
+	struct _virtio_connection *_vconn = to_vconn(conn);
+	int ret = 0;
+
+	PDEBUG("call -> %d with %p/%d\n", func, data, len);
+
+	switch (func) {
+	case VIRTIO_VBUS_FUNC_NEG_CAP:
+		ret = _virtio_connection_negcap(_vconn, data, len);
+		break;
+	case VIRTIO_VBUS_FUNC_GET_ID:
+		ret = _virtio_connection_getid(_vconn, data, len);
+		break;
+	case VIRTIO_VBUS_FUNC_GET_FEATURES:
+		ret = _virtio_connection_getfeatures(_vconn, data, len);
+		break;
+	case VIRTIO_VBUS_FUNC_FINALIZE_FEATURES:
+		_virtio_connection_finalizefeatures(_vconn);
+		break;
+	case VIRTIO_VBUS_FUNC_GET_STATUS:
+		ret = _virtio_connection_getstatus(_vconn, data, len);
+		break;
+	case VIRTIO_VBUS_FUNC_SET_STATUS:
+		ret = _virtio_connection_setstatus(_vconn, data, len);
+		break;
+	case VIRTIO_VBUS_FUNC_RESET:
+		_virtio_connection_reset(_vconn);
+		break;
+	case VIRTIO_VBUS_FUNC_QUERY_QUEUE:
+		ret = _virtio_connection_queryqueue(_vconn, data, len);
+		break;
+	case VIRTIO_VBUS_FUNC_DEL_QUEUE:
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static void _virtio_config_isr(struct shm_signal_notifier *notifier)
+{
+	struct _virtio_connection *_vconn;
+	struct virtio_connection *vconn;
+
+	_vconn = container_of(notifier, struct _virtio_connection,
+			      config.notifier);
+
+	vconn = _vconn->vconn;
+
+	if (vconn->ops->config_changed)
+		vconn->ops->config_changed(vconn);
+}
+
+static int
+_virtio_connection_open(struct _virtio_connection *_vconn)
+
+{
+	struct virtio_device_interface *vintf = _vconn->_vintf->vintf;
+	struct virtio_connection *vconn;
+	struct virtio_queue_def *def = vintf->queues;
+	int ret;
+
+	ret = vintf->ops->open(vintf, _vconn->ctx, &vconn);
+	if (ret < 0)
+		return ret;
+
+	while (def && def->index != -1) {
+		struct _virtio_queue *vq;
+
+		vq = kzalloc(sizeof(*vq), GFP_KERNEL);
+		if (!vq)
+			return -ENOMEM;
+
+		vq->index  = def->index;
+		vq->num    = def->entries;
+		vq->_vconn = _vconn;
+
+		list_add_tail(&vq->node, &_vconn->queues);
+
+		def++;
+	}
+
+	_vconn->vconn  = vconn;
+	vconn->parent  = &_vconn->conn;
+
+	return 0;
+}
+
+static int
+_virtio_connection_initconfig(struct _virtio_connection *_vconn,
+			      struct vbus_shm *shm,
+			      struct shm_signal *signal)
+{
+	int ret;
+
+	if (_vconn->running)
+		return -EINVAL;
+
+	_vconn->config.signal = signal;
+	_vconn->config.shm = shm;
+	_vconn->config.notifier.signal = &_virtio_config_isr;
+	signal->notifier = &_vconn->config.notifier;
+
+	shm_signal_enable(signal, 0);
+
+	ret = _virtio_connection_open(_vconn);
+	if (ret < 0)
+		return ret;
+
+	_vconn->running = 1;
+
+	return 0;
+}
+
+static void _vq_isr(struct shm_signal_notifier *notifier)
+{
+	struct _virtio_queue *vq;
+
+	vq = container_of(notifier, struct _virtio_queue, notifier);
+
+	vring_interrupt(0, vq->vq);
+}
+
+static void _vq_notify(struct virtqueue *vq)
+{
+	struct _virtio_queue *_vq = vq->priv;
+
+	shm_signal_inject(_vq->signal, 0);
+}
+
+static void _vq_callback(struct virtqueue *vq)
+{
+	struct _virtio_queue *_vq = vq->priv;
+	struct virtio_connection *vconn = _vq->_vconn->vconn;
+
+	vconn->ops->notify_vq(vconn, _vq->index);
+}
+
+static int
+_virtio_connection_shm(struct vbus_connection *conn,
+		   unsigned long id,
+		   struct vbus_shm *shm,
+		   struct shm_signal *signal,
+		   unsigned long flags)
+{
+	struct _virtio_connection *_vconn = to_vconn(conn);
+	struct virtio_connection *vconn = _vconn->vconn;
+	struct _virtio_queue *vq;
+	struct virtio_vbus_shm *_shm = shm->ptr;
+
+	/* All shm connections that we support require a signal */
+	if (!signal)
+		return -EINVAL;
+
+	if (!id)
+		return _virtio_connection_initconfig(_vconn, shm, signal);
+
+	vq = _virtio_find_queue(_vconn, id - VIRTIO_VBUS_RING_OFFSET);
+	if (!vq)
+		return -EINVAL;
+
+	if (vq->shm)
+		return -EEXIST;
+
+	vq->shm = shm;
+	vq->signal = signal;
+
+	vq->notifier.signal = &_vq_isr;
+	signal->notifier = &vq->notifier;
+
+	shm_signal_enable(signal, 0);
+
+	vq->vq = vring_new_virtqueue(vq->num, PAGE_SIZE, NULL,
+				     &_shm->data[0],
+				     _vq_notify, _vq_callback);
+
+	vq->vq->priv = vq;
+
+	vconn->ops->add_vq(vconn, vq->index, vq->vq);
+
+	return 0;
+}
+
+static void
+_virtio_connection_release(struct vbus_connection *conn)
+{
+	struct _virtio_connection *_vconn = to_vconn(conn);
+	struct virtio_connection *vconn = _vconn->vconn;
+	struct _virtio_queue *vq, *tmp;
+
+	vconn->ops->release(vconn);
+
+	list_for_each_entry_safe(vq, tmp, &_vconn->queues, node) {
+		if (vq->vq)
+			vring_del_virtqueue(vq->vq);
+
+		if (vq->shm)
+			vbus_shm_put(vq->shm);
+
+		if (vq->signal)
+			shm_signal_put(vq->signal);
+
+		list_del(&vq->node);
+		kfree(vq);
+	}
+
+	if (_vconn->config.signal)
+		shm_signal_put(_vconn->config.signal);
+
+	if (_vconn->config.shm)
+		vbus_shm_put(_vconn->config.shm);
+
+	kobject_put(&_vconn->_vintf->intf.kobj);
+	vbus_memctx_put(_vconn->ctx);
+
+	kfree(_vconn);
+}
+
+static struct vbus_connection_ops _virtio_connection_ops = {
+	.call    = _virtio_connection_call,
+	.shm     = _virtio_connection_shm,
+	.release = _virtio_connection_release,
+};
+
+static int
+_virtio_intf_open(struct vbus_device_interface *intf,
+		  struct vbus_memctx *ctx,
+		  int version,
+		  struct vbus_connection **conn)
+{
+	struct _virtio_device_interface *_vintf = to_vintf(intf);
+	struct _virtio_connection *_vconn;
+	int ret;
+
+	if (version != VIRTIO_VBUS_ABI_VERSION)
+		return -EINVAL;
+
+	_vconn = kzalloc(sizeof(*_vconn), GFP_KERNEL);
+	if (!_vconn)
+		return -ENOMEM;
+
+	vbus_connection_init(&_vconn->conn, &_virtio_connection_ops);
+	_vconn->_vintf = _vintf;
+	_vconn->ctx    = ctx;
+	INIT_LIST_HEAD(&_vconn->queues);
+
+	vbus_memctx_get(ctx);
+	kobject_get(&intf->kobj);
+
+	*conn         = &_vconn->conn;
+
+	return 0;
+}
+
+static void
+_virtio_intf_release(struct vbus_device_interface *intf)
+{
+	struct _virtio_device_interface *_vintf = to_vintf(intf);
+	struct virtio_device_interface *vintf = _vintf->vintf;
+
+	if (vintf && vintf->ops->release)
+		vintf->ops->release(vintf);
+	kfree(_vintf);
+}
+
+static struct vbus_device_interface_ops _virtio_device_interface_ops = {
+	.open    = _virtio_intf_open,
+	.release = _virtio_intf_release,
+};
+
+int
+virtio_device_interface_register(struct vbus_device *dev,
+				 struct vbus *vbus,
+				 struct virtio_device_interface *vintf)
+{
+	struct _virtio_device_interface *_vintf;
+	struct vbus_device_interface *intf;
+
+	_vintf = kzalloc(sizeof(*_vintf), GFP_KERNEL);
+	if (!_vintf)
+		return -ENOMEM;
+
+	_vintf->vintf = vintf;
+
+	intf = &_vintf->intf;
+
+	intf->name = "0"; /* FIXME */
+	intf->type = "virtio";
+	intf->ops  = &_virtio_device_interface_ops;
+
+	return vbus_device_interface_register(dev, vbus, intf);
+}
+EXPORT_SYMBOL_GPL(virtio_device_interface_register);
+
+int
+virtio_device_interface_unregister(struct virtio_device_interface *intf)
+{
+	return vbus_device_interface_unregister(intf->parent);
+}
+EXPORT_SYMBOL_GPL(virtio_device_interface_unregister);

