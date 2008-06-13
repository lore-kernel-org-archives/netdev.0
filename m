From: Robert Stonehouse <rstonehouse@solarflare.com>
Subject: [RFC][PATCH 1/2] Making use of VNICs in the sfc driver
Date: Fri, 13 Jun 2008 21:12:52 +0100
Message-ID: <4852D4C4.4010004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:41644 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbYFMU1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 16:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/sfc/Makefile         |    4 +-
 drivers/net/sfc/driverlink.c     |  525 ++++++++++++++++++++++++++++++++
 drivers/net/sfc/driverlink.h     |   76 +++++
 drivers/net/sfc/driverlink_api.h |  614 ++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/efx.c            |   47 +++-
 drivers/net/sfc/falcon.c         |   88 ++++++-
 drivers/net/sfc/net_driver.h     |   15 +
 7 files changed, 1365 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/sfc/driverlink.c
 create mode 100644 drivers/net/sfc/driverlink.h
 create mode 100644 drivers/net/sfc/driverlink_api.h

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index c8f5704..aa3bff7 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_xmac.o \
 			   selftest.o ethtool.o xfp_phy.o \
-			   mdio_10g.o tenxpress.o boards.o sfe4001.o
-
+			   mdio_10g.o tenxpress.o boards.o sfe4001.o \
+			   driverlink.o
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/sfc/driverlink.c b/drivers/net/sfc/driverlink.c
new file mode 100644
index 0000000..93f29d5
--- /dev/null
+++ b/drivers/net/sfc/driverlink.c
@@ -0,0 +1,525 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005      Fen Systems Ltd.
+ * Copyright 2005-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/module.h>
+#include <linux/list.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "driverlink_api.h"
+#include "driverlink.h"
+
+/* Driverlink semaphore
+ * This semaphore must be held for any operation that modifies any of
+ * the driverlink lists.
+ */
+static DEFINE_MUTEX(efx_driverlink_lock);
+
+/* List of all registered drivers */
+static LIST_HEAD(efx_driver_list);
+
+/* List of all registered Efx ports */
+static LIST_HEAD(efx_port_list);
+
+/* Driver link handle used internally to track devices */
+struct efx_dl_handle {
+	/* The efx_dl_device consumers see */
+	struct efx_dl_device efx_dev;
+	/* The efx_nic providers provide */
+	struct efx_nic *efx;
+	/* Per-device list */
+	struct list_head port_node;
+	/* Per-driver list */
+	struct list_head driver_node;
+};
+
+/* Get the handle for an efx_dl_device */
+static struct efx_dl_handle *efx_dl_handle(struct efx_dl_device *efx_dev)
+{
+	return container_of(efx_dev, struct efx_dl_handle, efx_dev);
+}
+
+/* Remove an Efx device
+ * You must hold the efx_driverlink_lock before calling this
+ * function.
+ */
+static void efx_dl_del_device(struct efx_dl_device *efx_dev)
+{
+	struct efx_dl_handle *efx_handle = efx_dl_handle(efx_dev);
+
+	EFX_INFO(efx_handle->efx, "%s driverlink client unregistering\n",
+		 efx_dev->driver->name);
+
+	/* Call driver's remove() routine */
+	if (efx_dev->driver->remove)
+		efx_dev->driver->remove(efx_dev);
+
+	/* Remove handle from per-driver and per-NIC lists */
+	list_del(&efx_handle->driver_node);
+	list_del(&efx_handle->port_node);
+
+	/* Free efx_handle structure */
+	kfree(efx_handle);
+}
+
+/* Try to add an Efx device
+ * Attempt to probe the given device with the driver, creating a
+ * new efx_dl_device. If the probe routine fails, because the driver
+ * doesn't support this port, then the efx_dl_device is destroyed,
+ */
+static void efx_dl_try_add_device(struct efx_nic *efx,
+				  struct efx_dl_driver *driver)
+{
+	struct efx_dl_handle *efx_handle;
+	struct efx_dl_device *efx_dev;
+	int rc;
+
+	/* Allocate and initialise new efx_dl_device structure */
+	efx_handle = kzalloc(sizeof(*efx_handle), GFP_KERNEL);
+	if (!efx_handle)
+		goto fail;
+	efx_dev = &efx_handle->efx_dev;
+	efx_handle->efx = efx;
+	efx_dev->driver = driver;
+	efx_dev->pci_dev = efx->pci_dev;
+	INIT_LIST_HEAD(&efx_handle->port_node);
+	INIT_LIST_HEAD(&efx_handle->driver_node);
+
+	/* Attempt driver probe */
+	rc = driver->probe(efx_dev, efx->net_dev,
+			   efx->dl_info, efx->silicon_rev);
+	if (rc)
+		goto fail;
+
+	/* Add device to per-driver and per-NIC lists */
+	list_add_tail(&efx_handle->driver_node, &driver->device_list);
+	list_add_tail(&efx_handle->port_node, &efx->dl_device_list);
+
+	EFX_INFO(efx, "%s driverlink client registered\n", driver->name);
+	return;
+
+ fail:
+	EFX_INFO(efx, "%s driverlink client skipped\n", driver->name);
+
+	kfree(efx_handle);
+}
+
+/**
+ * efx_dl_unregister_driver - unregister an Efx device driver
+ * @driver:		Efx driverlink driver
+ *
+ * Unregisters an Efx driver.  The driver's remove() method will be
+ * called for all Efx devices currently claimed by the driver.
+ */
+void efx_dl_unregister_driver(struct efx_dl_driver *driver)
+{
+	struct efx_dl_handle *efx_handle, *efx_handle_n;
+
+	printk(KERN_INFO "Efx driverlink unregistering %s driver\n",
+		 driver->name);
+
+	/* Acquire lock.  We can't return failure */
+	mutex_lock(&efx_driverlink_lock);
+
+	list_for_each_entry_safe(efx_handle, efx_handle_n,
+				 &driver->device_list, driver_node)
+		efx_dl_del_device(&efx_handle->efx_dev);
+
+	list_del(&driver->node);
+
+	mutex_unlock(&efx_driverlink_lock);
+}
+EXPORT_SYMBOL(efx_dl_unregister_driver);
+
+/**
+ * efx_dl_register_driver - register an Efx device driver
+ * @driver:		Efx driverlink driver
+ *
+ * Registers a new Efx driver.  The driver's probe() method will be
+ * called for all Efx NICs currently registered.
+ *
+ * Return a negative error code or 0 on success.
+ */
+int efx_dl_register_driver(struct efx_dl_driver *driver)
+{
+	struct efx_nic *efx;
+	int rc;
+
+	printk(KERN_INFO "Efx driverlink registering %s driver\n",
+		 driver->name);
+
+	/* Initialise driver list structures */
+	INIT_LIST_HEAD(&driver->node);
+	INIT_LIST_HEAD(&driver->device_list);
+
+	/* Acquire lock */
+	rc = mutex_lock_interruptible(&efx_driverlink_lock);
+	if (rc)
+		return rc;
+
+	/* Add driver to driver list */
+	list_add_tail(&driver->node, &efx_driver_list);
+
+	/* Feed all existing devices to driver */
+	list_for_each_entry(efx, &efx_port_list, dl_node)
+		efx_dl_try_add_device(efx, driver);
+
+	/* Release locks */
+	mutex_unlock(&efx_driverlink_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(efx_dl_register_driver);
+
+void efx_dl_unregister_nic(struct efx_nic *efx)
+{
+	struct efx_dl_handle *efx_handle, *efx_handle_n;
+
+	if (!efx)
+		return;
+
+	/* Acquire lock.  We can't return failure, so have to use
+	 * down() instead of down_interruptible()
+	 */
+	mutex_lock(&efx_driverlink_lock);
+
+	/* Remove all devices related to this NIC */
+	list_for_each_entry_safe_reverse(efx_handle, efx_handle_n,
+					 &efx->dl_device_list,
+					 port_node)
+		efx_dl_del_device(&efx_handle->efx_dev);
+
+	/* Remove port from port list */
+	list_del(&efx->dl_node);
+
+	/* Release lock */
+	mutex_unlock(&efx_driverlink_lock);
+}
+
+int efx_dl_register_nic(struct efx_nic *efx)
+{
+	struct efx_dl_driver *driver;
+	int rc;
+
+	/* Acquire lock */
+	rc = mutex_lock_interruptible(&efx_driverlink_lock);
+	if (rc)
+		return rc;
+
+	/* Add port to port list */
+	list_add_tail(&efx->dl_node, &efx_port_list);
+
+	/* Feed port to all existing drivers */
+	list_for_each_entry(driver, &efx_driver_list, node)
+		efx_dl_try_add_device(efx, driver);
+
+	/* Release lock */
+	mutex_unlock(&efx_driverlink_lock);
+
+	return 0;
+}
+
+/*
+ * Dummy callback implementations.
+ *
+ * To avoid a branch point on the fast-path, the callbacks are always
+ * implemented - they are never NULL.
+ */
+#if defined(EFX_USE_KCOMPAT) && defined(EFX_USE_FASTCALL)
+static enum efx_veto fastcall
+#else
+static enum efx_veto
+#endif
+efx_dummy_tx_packet_callback(struct efx_dl_device *efx_dev, struct sk_buff *skb)
+{
+	/* Never veto the packet */
+	return EFX_ALLOW_PACKET;
+}
+
+#if defined(EFX_USE_KCOMPAT) && defined(EFX_USE_FASTCALL)
+static enum efx_veto fastcall
+#else
+static enum efx_veto
+#endif
+efx_dummy_rx_packet_callback(struct efx_dl_device *efx_dev,
+			     const char *pkt_buf, int len)
+{
+	/* Never veto the packet */
+	return EFX_ALLOW_PACKET;
+}
+
+static void
+efx_dummy_link_change_callback(struct efx_dl_device *efx_dev, int link_up)
+{
+}
+
+static int
+efx_dummy_request_mtu_callback(struct efx_dl_device *efx_dev, int new_mtu)
+{
+	/* Always allow */
+	return 0;
+}
+
+static void
+efx_dummy_mtu_changed_callback(struct efx_dl_device *efx_dev, int mtu)
+{
+	return;
+}
+
+static void efx_dummy_event_callback(struct efx_dl_device *efx_dev, void *event)
+{
+	return;
+}
+
+struct efx_dl_callbacks efx_default_callbacks = {
+	.tx_packet	= efx_dummy_tx_packet_callback,
+	.rx_packet	= efx_dummy_rx_packet_callback,
+	.link_change	= efx_dummy_link_change_callback,
+	.request_mtu	= efx_dummy_request_mtu_callback,
+	.mtu_changed	= efx_dummy_mtu_changed_callback,
+	.event		= efx_dummy_event_callback,
+};
+
+#define EFX_DL_UNREGISTER_CALLBACK(_port, _dev, _member)		\
+	do {								\
+		BUG_ON((_port)->dl_cb_dev._member != (_dev));		\
+		(_port)->dl_cb._member =				\
+			efx_default_callbacks._member;			\
+		(_port)->dl_cb_dev._member = NULL;			\
+	} while (0)
+
+
+#define EFX_DL_REGISTER_CALLBACK(_port, _dev, _from, _member)		\
+	if ((_from)->_member) {						\
+		BUG_ON((_port)->dl_cb_dev._member != NULL);		\
+		(_port)->dl_cb._member = (_from)->_member;		\
+		(_port)->dl_cb_dev._member = _dev;			\
+	}
+
+/**
+ * efx_dl_unregister_callbacks - unregister callbacks for an Efx NIC
+ * @efx_dev:		Efx driverlink device
+ * @callbacks:		Callback list
+ *
+ * This removes a set of callbacks registered with
+ * efx_dl_register_callbacks().  It should be called as part of the
+ * client's remove() method.
+ *
+ * The net driver will ensure that all callback functions have
+ * returned to the net driver before efx_dl_unregister_callbacks()
+ * returns.  Note that the device itself may still be running when the
+ * client's remove() method is called.  The client must therefore
+ * unhook its callbacks using efx_dl_unregister_callbacks() and only
+ * then ensure that any delayed tasks triggered by callback methods
+ * (e.g. scheduled tasklets) have completed.
+ */
+void efx_dl_unregister_callbacks(struct efx_dl_device *efx_dev,
+				 struct efx_dl_callbacks *callbacks)
+{
+	struct efx_dl_handle *efx_handle = efx_dl_handle(efx_dev);
+	struct efx_nic *efx = efx_handle->efx;
+
+	/* Suspend net driver operations */
+	efx_suspend(efx);
+
+	EFX_INFO(efx, "removing callback hooks into %s driver\n",
+		 efx_dev->driver->name);
+
+	if (callbacks->tx_packet)
+		EFX_DL_UNREGISTER_CALLBACK(efx, efx_dev, tx_packet);
+
+	if (callbacks->rx_packet)
+		EFX_DL_UNREGISTER_CALLBACK(efx, efx_dev, rx_packet);
+
+	if (callbacks->link_change)
+		EFX_DL_UNREGISTER_CALLBACK(efx, efx_dev, link_change);
+
+	if (callbacks->request_mtu)
+		EFX_DL_UNREGISTER_CALLBACK(efx, efx_dev, request_mtu);
+
+	if (callbacks->mtu_changed)
+		EFX_DL_UNREGISTER_CALLBACK(efx, efx_dev, mtu_changed);
+
+	if (callbacks->event)
+		EFX_DL_UNREGISTER_CALLBACK(efx, efx_dev, event);
+
+	/* Resume net driver operations */
+	efx_resume(efx);
+}
+EXPORT_SYMBOL(efx_dl_unregister_callbacks);
+
+/**
+ * efx_dl_register_callbacks - register callbacks for an Efx NIC
+ * @efx_dev:		Efx driverlink device
+ * @callbacks:		Callback list
+ *
+ * This registers a set of callback functions with the net driver.
+ * These functions will be called at various key points to allow
+ * external code to monitor and/or modify the behaviour of the network
+ * driver.  Any of the callback function pointers may be %NULL if a
+ * callback is not required.  The intended user of this mechanism is
+ * the SFC char driver.
+ *
+ * This client should call efx_dl_register_callbacks() during its
+ * probe() method.  The client must ensure that it also calls
+ * efx_dl_unregister_callbacks() as part of its remove() method.
+ *
+ * Only one function may be registered for each callback per NIC.
+ * If a requested callback is already registered for this NIC, this
+ * function will return -%EBUSY.
+ *
+ * The device may already be running, so the client must be prepared
+ * for callbacks to be triggered immediately after calling
+ * efx_dl_register_callbacks().
+ *
+ * Return a negative error code or 0 on success.
+ */
+int efx_dl_register_callbacks(struct efx_dl_device *efx_dev,
+			      struct efx_dl_callbacks *callbacks)
+{
+	struct efx_dl_handle *efx_handle = efx_dl_handle(efx_dev);
+	struct efx_nic *efx = efx_handle->efx;
+	int rc = 0;
+
+	/* Suspend net driver operations */
+	efx_suspend(efx);
+
+	/* Check that the requested callbacks are not already hooked. */
+	if ((callbacks->tx_packet && efx->dl_cb_dev.tx_packet) ||
+	    (callbacks->rx_packet && efx->dl_cb_dev.rx_packet) ||
+	    (callbacks->link_change && efx->dl_cb_dev.link_change) ||
+	    (callbacks->request_mtu && efx->dl_cb_dev.request_mtu) ||
+	    (callbacks->mtu_changed && efx->dl_cb_dev.mtu_changed) ||
+	    (callbacks->event && efx->dl_cb_dev.event)) {
+		rc = -EBUSY;
+		goto out;
+	}
+
+	EFX_INFO(efx, "adding callback hooks to %s driver\n",
+		 efx_dev->driver->name);
+
+	/* Hook in callbacks.  For maximum speed, we never check to
+	 * see whether these are NULL before calling; therefore we
+	 * must ensure that they are never NULL.  If the set we're
+	 * being asked to hook in is sparse, we leave the default
+	 * values in place for the empty hooks.
+	 */
+	EFX_DL_REGISTER_CALLBACK(efx, efx_dev, callbacks, tx_packet);
+	EFX_DL_REGISTER_CALLBACK(efx, efx_dev, callbacks, rx_packet);
+	EFX_DL_REGISTER_CALLBACK(efx, efx_dev, callbacks, link_change);
+	EFX_DL_REGISTER_CALLBACK(efx, efx_dev, callbacks, request_mtu);
+	EFX_DL_REGISTER_CALLBACK(efx, efx_dev, callbacks, mtu_changed);
+	EFX_DL_REGISTER_CALLBACK(efx, efx_dev, callbacks, event);
+
+ out:
+	/* Resume net driver operations */
+	efx_resume(efx);
+
+	return rc;
+}
+EXPORT_SYMBOL(efx_dl_register_callbacks);
+
+/**
+ * efx_dl_schedule_reset - schedule an Efx NIC reset
+ * @efx_dev:		Efx driverlink device
+ *
+ * This schedules a hardware reset for a short time in the future.  It
+ * can be called from any context, and so can be used when
+ * efx_dl_reset() cannot be called.
+ */
+void efx_dl_schedule_reset(struct efx_dl_device *efx_dev)
+{
+	struct efx_dl_handle *efx_handle = efx_dl_handle(efx_dev);
+	struct efx_nic *efx = efx_handle->efx;
+
+	efx_schedule_reset(efx, RESET_TYPE_ALL);
+}
+EXPORT_SYMBOL(efx_dl_schedule_reset);
+
+/*
+ * Lock the driverlink layer before a reset
+ * To avoid deadlock, efx_driverlink_lock needs to be acquired before
+ * efx->suspend_lock.
+ */
+void efx_dl_reset_lock(void)
+{
+	/* Acquire lock */
+	mutex_lock(&efx_driverlink_lock);
+}
+
+/*
+ * Unlock the driverlink layer after a reset
+ * This call must be matched against efx_dl_reset_lock.
+ */
+void efx_dl_reset_unlock(void)
+{
+	/* Acquire lock */
+	mutex_unlock(&efx_driverlink_lock);
+}
+
+/*
+ * Suspend ready for reset
+ * This calls the reset_suspend method of all drivers registered to
+ * the specified NIC.  It must only be called between
+ * efx_dl_reset_lock and efx_dl_reset_unlock.
+ */
+void efx_dl_reset_suspend(struct efx_nic *efx)
+{
+	struct efx_dl_handle *efx_handle;
+	struct efx_dl_device *efx_dev;
+
+	BUG_ON(!mutex_is_locked(&efx_driverlink_lock));
+
+	/* Call suspend method of each driver in turn */
+	list_for_each_entry_reverse(efx_handle,
+				    &efx->dl_device_list,
+				    port_node) {
+		efx_dev = &efx_handle->efx_dev;
+		if (efx_dev->driver->reset_suspend)
+			efx_dev->driver->reset_suspend(efx_dev);
+	}
+}
+
+/*
+ * Resume after a reset
+ * This calls the reset_resume method of all drivers registered to the
+ * specified NIC.  It must only be called between efx_dl_reset_lock
+ * and efx_dl_reset_unlock.
+ */
+void efx_dl_reset_resume(struct efx_nic *efx, int ok)
+{
+	struct efx_dl_handle *efx_handle;
+	struct efx_dl_device *efx_dev;
+
+	BUG_ON(!mutex_is_locked(&efx_driverlink_lock));
+
+	/* Call resume method of each driver in turn */
+	list_for_each_entry(efx_handle, &efx->dl_device_list,
+			    port_node) {
+		efx_dev = &efx_handle->efx_dev;
+		if (efx_dev->driver->reset_resume)
+			efx_dev->driver->reset_resume(efx_dev, ok);
+	}
+}
+
+/**
+ * efx_dl_get_nic - obtain the Efx NIC for the given driverlink device
+ * @efx_dev:		Efx driverlink device
+ *
+ * Get a pointer to the &struct efx_nic corresponding to
+ * @efx_dev.  This can be used by driverlink clients built along with
+ * the sfc driver, which may have intimate knowledge of its internals.
+ */
+struct efx_nic *efx_dl_get_nic(struct efx_dl_device *efx_dev)
+{
+	return efx_dl_handle(efx_dev)->efx;
+}
+EXPORT_SYMBOL(efx_dl_get_nic);
diff --git a/drivers/net/sfc/driverlink.h b/drivers/net/sfc/driverlink.h
new file mode 100644
index 0000000..889acf5
--- /dev/null
+++ b/drivers/net/sfc/driverlink.h
@@ -0,0 +1,76 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005      Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_DRIVERLINK_H
+#define EFX_DRIVERLINK_H
+
+/* Forward declarations */
+struct efx_dl_device;
+struct efx_nic;
+
+/*
+ * Efx driverlink
+ *
+ * This header file defines the portions of the Efx driverlink
+ * interface that are used only within the sfc module.  It also
+ * declares efx_dl_get_nic(), which may be used by sfc_mtd
+ * and any other module built along with sfc.
+ */
+
+
+/* Efx callback devices
+ *
+ * A list of the devices that own each callback. The partner to
+ * struct efx_dl_callbacks
+ */
+struct efx_dl_cb_devices {
+	/* Device owning the tx_packet callback */
+	struct efx_dl_device *tx_packet;
+	/* Device owning the rx_packet callback */
+	struct efx_dl_device *rx_packet;
+	/* Device owning the link_change callback. */
+	struct efx_dl_device *link_change;
+	/* Device owning the request_mtu callback. */
+	struct efx_dl_device *request_mtu;
+	/* Device owning the mtu_changed callback. */
+	struct efx_dl_device *mtu_changed;
+	/* Device owning the event callback. */
+	struct efx_dl_device *event;
+};
+
+/* No-op callbacks used for initialisation */
+extern struct efx_dl_callbacks efx_default_callbacks;
+
+/* Macro used to invoke callbacks */
+#define EFX_DL_CALLBACK(_port, _name, ...)				\
+	(_port)->dl_cb._name((_port)->dl_cb_dev._name, __VA_ARGS__)
+
+/* Register an Efx NIC */
+extern int efx_dl_register_nic(struct efx_nic *efx);
+
+/* Unregister an Efx NIC */
+extern void efx_dl_unregister_nic(struct efx_nic *efx);
+
+/* Lock the driverlink layer prior to a reset */
+extern void efx_dl_reset_lock(void);
+
+/* Unlock the driverlink layer following a reset */
+extern void efx_dl_reset_unlock(void);
+
+/* Suspend all drivers prior to a hardware reset */
+extern void efx_dl_reset_suspend(struct efx_nic *efx);
+
+/* Resume all drivers after a hardware reset */
+extern void efx_dl_reset_resume(struct efx_nic *efx, int ok);
+
+/* Obtain the Efx NIC for the given driverlink device. */
+extern struct efx_nic *efx_dl_get_nic(struct efx_dl_device *efx_dev);
+
+#endif /* EFX_DRIVERLINK_H */
diff --git a/drivers/net/sfc/driverlink_api.h b/drivers/net/sfc/driverlink_api.h
new file mode 100644
index 0000000..1dc6050
--- /dev/null
+++ b/drivers/net/sfc/driverlink_api.h
@@ -0,0 +1,614 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_DRIVERLINK_API_H
+#define EFX_DRIVERLINK_API_H
+
+#include <linux/list.h> /* for struct list_head */
+#if defined(EFX_USE_KCOMPAT) && !defined(EFX_USE_FASTCALL)
+	#include <linux/version.h>
+	#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,20)
+		#define EFX_USE_FASTCALL yes
+		#include <linux/linkage.h>
+	#endif
+#endif
+
+/**
+ * DOC: Efx driverlink API
+ *
+ * This file must be included by any driver that wishes to attach to
+ * devices claimed by the Solarflare NIC driver (sfc). It allows separate
+ * kernel modules to expose other functionality offered by the NIC, with
+ * the sfc driver remaining in overall control.
+ *
+ * Overview:
+ *
+ * Driverlink clients define a &struct efx_dl_driver, and register
+ * this structure with the driverlink layer using
+ * efx_dl_register_driver(), which is exported by the sfc driver.
+ *
+ * The probe() routine of each driverlink client driver is called by
+ * the driverlink layer for each physical port in the system, after
+ * the sfc driver has performed start-of-day hardware initialisation
+ * and self-test. If ports are added or removed via pci hotplug then
+ * the &struct efx_dl_driver probe() or remove() routines are called
+ * as appropriate.
+ *
+ * If the port doesn't provide the necessary hardware resources for a
+ * client, then that client can return failure from its probe()
+ * routine. Information provided to the client driver at probe time
+ * includes
+ *
+ * Each probe() routine is given a unique &struct efx_dl_device per
+ * port, which means it can safely use the @priv member to store any
+ * useful state it needs. The probe routine also has the opportunity
+ * to provide a &struct efx_dl_callbacks via
+ * efx_dl_register_callbacks(), which allows the client to intercept
+ * the sfc driver's operations at strategic points.
+ *
+ * Occasionally, the underlying Efx device may need to be reset to
+ * recover from an error condition.  The client's reset_suspend() and
+ * reset_resume() methods [if provided] will be called to enable the
+ * client to suspend operations and preserve any state before the
+ * reset.  The client can itself request a reset using efx_dl_reset()
+ * or efx_dl_schedule_reset(), should it detect an error condition
+ * necessitating a reset.
+ *
+ * Example:
+ *
+ * The MTD driver (mtd.c) uses the driverlink layer.
+ */
+#ifdef EFX_NOT_UPSTREAM
+/**
+ * DOC: Out-of-tree use of Efx driverlink API
+ *
+ * The file demo.c illustrates most aspects of using the
+ * driverlink API, and is well worth reading.
+ *
+ * By design, this file does *not* drag in any of the private header
+ * files used by the sfc driver.  In particular, this means that
+ * &struct efx_nic is not defined by including this header.  Include
+ * net_driver.h if you need access to the internals of &struct efx_nic.
+ * DO NOT use sfc driver internals in any driver that must work as an
+ * out-of-tree driver together with an in-tree (kernel.org or
+ * distribution) version of the sfc driver.  Changes in net_driver.h
+ * will NOT be reflected in %EFX_DRIVERLINK_API_VERSION, but the
+ * standard symbol versioning mechanism works between modules that are
+ * both built in-tree or both built in the v5 tree.
+ */
+#endif
+
+/* Forward declarations */
+struct pci_dev;
+struct net_device;
+struct sk_buff;
+struct efx_dl_device;
+struct efx_dl_device_info;
+
+/*
+ * This is used to guard against the registration of driverlink
+ * clients using an incorrect version of the API.
+ */
+#define EFX_DRIVERLINK_API_VERSION 1
+
+
+/**
+ * struct efx_dl_driver - An Efx driverlink device driver
+ *
+ * This is the analogue of a struct pci_driver for a normal PCI
+ * driver.  Driverlink clients should register themselves using
+ * efx_dl_register_driver() at module initialisation, and deregister
+ * themselves using efx_dl_unregister_driver() at module exit.
+ *
+ * All calls to members of efx_dl_driver are serialised by a single
+ * semaphore, so you are allowed to sleep in these functions. Take care
+ * to not call driverlink methods from within these callbacks, otherwise
+ * a deadlock is possible.
+ *
+ * @name: Name of the driver
+ * @probe: Called when device added
+ * @remove: Called when device removed
+ * @reset_suspend: Called before device is reset
+ * @reset_resume: Called after device is reset
+ */
+struct efx_dl_driver {
+	const char *name;
+
+	/*
+	 * probe - Handle device addition.
+	 * @efx_dev:		Efx driverlink device
+	 * @net_dev:		The net_dev relevant to this port
+	 * @dev_info:		A linked list of device information.
+	 * @silicon_rev:	Silicon revision name.
+	 *
+	 * This will be called after driverlink client registration for
+	 * every port on the system, and for every port that appears
+	 * thereafter via hotplug.
+	 *
+	 * The client may use either @efx_dev->pci_dev, the dev_info linked
+	 * list of available driver information, or the silicon revision
+	 * name to determine if they can support this port. If they can,
+	 * they should return 0 to indicate the probe was successful. Any
+	 * other return code indicates that the probe failed, and the
+	 * @efx_dl_dev will be invalidated.
+	 *
+	 * The client should perform whatever initialisation it
+	 * requires, and store a pointer to its private data in
+	 * @efx_dl_dev->priv (which is not shared between clients).
+	 * It may also wish to hook in a callbacks table using
+	 * efx_dl_register_callbacks().
+	 *
+	 * Return a negative error code or 0 on success.
+	 */
+	int (*probe) (struct efx_dl_device *efx_dl_dev,
+		      const struct net_device *net_dev,
+		      const struct efx_dl_device_info *dev_info,
+		      const char *silicon_rev);
+
+	/*
+	 * remove - Handle device removal.
+	 * @efx_dev:		Efx driverlink device
+	 *
+	 * This will be called at driver exit (or hotplug removal) for
+	 * each registered driverlink client.
+	 *
+	 * The client must ensure that it has finished all operations
+	 * using this device before returning from this method.  If it
+	 * has hooked in a callbacks table using
+	 * efx_dl_register_callbacks(), it must unhook it using
+	 * efx_dl_unregister_callbacks(), and then ensure that all
+	 * callback-triggered operations (e.g. scheduled tasklets)
+	 * have completed before returning.  (It does not need to
+	 * explicitly wait for callback methods to finish executing,
+	 * since efx_dl_unregister_callbacks() will sleep until all
+	 * callbacks have returned anyway.)
+	 *
+	 * Note that the device itself may not have been removed; it
+	 * may be simply that the client is being unloaded
+	 * via efx_dl_unregister_driver(). In this case other clients
+	 * (and the sfc driver itself) will still be using the device,
+	 * so the client cannot assume that the device itself is quiescent.
+	 * In particular, callbacks may continue to be triggered at any
+	 * point until efx_dl_unregister_callbacks() is called.
+	 */
+	void (*remove) (struct efx_dl_device *efx_dev);
+
+	/*
+	 * reset_suspend - Suspend ready for reset.
+	 * @efx_dev:		Efx driverlink device
+	 *
+	 * This method will be called immediately before a hardware
+	 * reset (which may or may not have been initiated by the
+	 * driverlink client).  This client must save any state that it
+	 * will need to restore after the reset, and suspend all
+	 * operations that might access the hardware.  It must not
+	 * return until the client can guarantee to have stopped
+	 * touching the hardware.
+	 *
+	 * It is guaranteed that callbacks will be inactive by the
+	 * time this method is called; the driverlink layer will
+	 * already have prevented new callbacks being made and waited
+	 * for all callbacks functions to return before calling
+	 * reset_suspend().  However, any delayed work scheduled by
+	 * the callback functions (e.g. tasklets) may not yet have
+	 * completed.
+	 *
+	 * This method is allowed to sleep, so waiting on tasklets,
+	 * work queues etc. is permitted.  There will always be a
+	 * corresponding call to the reset_resume() method, so it is
+	 * safe to e.g. down a semaphore within reset_suspend() and up
+	 * it within reset_resume().  (However, you obviously cannot
+	 * do the same with a spinlock).
+	 *
+	 * Note that the reset operation may be being carried out in
+	 * the context of scheduled work, so you cannot use
+	 * flush_scheduled_work() to ensure that any work you may have
+	 * scheduled has completed.
+	 *
+	 * During hardware reset, there is a chance of receiving
+	 * spurious interrupts, so the client's ISR (if any) should be
+	 * unhooked or otherwise disabled.
+	 */
+	void (*reset_suspend) (struct efx_dl_device *efx_dev);
+
+	/*
+	 * reset_resume - Restore after a reset.
+	 * @efx_dev:		Efx driverlink device
+	 * @ok:			Reset success indicator
+	 *
+	 * This method will be called after a hardware reset.  There
+	 * will always have been a corresponding call to the
+	 * reset_suspend() method beforehand.
+	 *
+	 * If @ok is non-zero, the client should restore the state
+	 * that it saved during the call to reset_suspend() and resume
+	 * normal operations.
+	 *
+	 * If @ok is zero, the reset operation has failed and the
+	 * hardware is currently in an unusable state.  In this case,
+	 * the client should release any locks taken out by
+	 * reset_suspend(), but should not take any other action; in
+	 * particular, it must not access the hardware, nor resume
+	 * normal operations.  The hardware is effectively dead at
+	 * this point, and our sole aim is to avoid deadlocking or
+	 * crashing the host.
+	 *
+	 * The driverlink layer will still be locked when
+	 * reset_resume() is called, so the client may not call
+	 * driverlink functions.  In particular, if the reset failed,
+	 * the client must not call efx_dl_unregister_callbacks() at
+	 * this point; it should wait until remove() is called.
+	 */
+	void (*reset_resume) (struct efx_dl_device *efx_dev, int ok);
+
+/* private: */
+	struct list_head node;
+	struct list_head device_list;
+};
+
+/**
+ * DOC: Efx driverlink device information
+ *
+ * Each &struct efx_dl_device makes certain hardware resources visible
+ * to driverlink clients, and they describe which resources are
+ * available by passing a linked list of &struct efx_dl_device_info
+ * into the probe() routine.
+ *
+ * The driverlink client's probe function can iterate through the linked list,
+ * and provided that it understands the resources that are exported, it can
+ * choose to make use of them through an external interface.
+ */
+
+/**
+ * enum efx_dl_device_info_type - Device information identifier.
+ *
+ * Each distinct hardware resource API will have a member in this
+ * enumeration.
+ *
+ * @EFX_DL_FALCON_RESOURCES: Information type is &struct efx_dl_falcon_resources
+ */
+enum efx_dl_device_info_type {
+	/** Falcon resources available for export */
+	EFX_DL_FALCON_RESOURCES = 0,
+};
+
+/**
+ * struct efx_dl_device_info - device information structure
+ * @next: Link to next structure, if any
+ * @type: Type code for this structure
+ *
+ * This structure is embedded in other structures provided by the
+ * driverlink device provider, and implements a linked list of
+ * resources pertinent to a driverlink client.
+ *
+ * Example: &struct efx_dl_falcon_resources
+ */
+struct efx_dl_device_info {
+	struct efx_dl_device_info *next;
+	enum efx_dl_device_info_type type;
+};
+
+/**
+ * enum efx_dl_falcon_resource_flags - Falcon resource information flags.
+ *
+ * Flags that describe hardware variations for the described Falcon based port.
+ *
+ * @EFX_DL_FALCON_DUAL_FUNC: Port is dual-function.
+ *	Certain silicon revisions have two pci functions, and require
+ *	certain hardware resources to be accessed via the secondary
+ *	function. See the discussion of @pci_dev in &struct efx_dl_device
+ *	below.
+ * @EFX_DL_FALCON_USE_MSI: Port is initialised to use MSI/MSI-X interrupts.
+ *	Falcon supports traditional legacy interrupts and MSI/MSI-X
+ *	interrupts. Since the sfc driver supports either, as a run
+ *	time configuration, driverlink drivers need to be aware of which
+ *	one to use for their interrupting resources.
+ */
+enum efx_dl_falcon_resource_flags {
+	EFX_DL_FALCON_DUAL_FUNC = 0x1,
+	EFX_DL_FALCON_USE_MSI = 0x2,
+};
+
+/**
+ * struct efx_dl_falcon_resources - Falcon resource information.
+ *
+ * This structure describes Falcon hardware resources available for
+ * use by a driverlink driver.
+ *
+ * @hdr: Resource linked list header
+ * @biu_lock: Register access lock.
+ *	Some Falcon revisions require register access for configuration
+ *	registers to be serialised between ports and PCI functions.
+ *	The sfc driver will provide the appropriate lock semantics for
+ *	the underlying hardware.
+ * @buffer_table_min: First available buffer table entry
+ * @buffer_table_lim: Last available buffer table entry + 1
+ * @evq_timer_min: First available event queue with timer
+ * @evq_timer_lim: Last available event queue with timer + 1
+ * @evq_int_min: First available event queue with interrupt
+ * @evq_int_lim: Last available event queue with interrupt + 1
+ * @rxq_min: First available RX queue
+ * @rxq_lim: Last available RX queue + 1
+ * @txq_min: First available TX queue
+ * @txq_lim: Last available TX queue + 1
+ * @flags: Hardware variation flags
+ */
+struct efx_dl_falcon_resources {
+	struct efx_dl_device_info hdr;
+	spinlock_t *biu_lock;
+	unsigned buffer_table_min, buffer_table_lim;
+	unsigned evq_timer_min, evq_timer_lim;
+	unsigned evq_int_min, evq_int_lim;
+	unsigned rxq_min, rxq_lim;
+	unsigned txq_min, txq_lim;
+	enum efx_dl_falcon_resource_flags flags;
+};
+
+/**
+ * struct efx_dl_device - An Efx driverlink device.
+ *
+ * @pci_dev: Underlying PCI device.
+ *	This is the PCI device used by the sfc driver.  It will
+ *	already have been enabled for bus-mastering DMA etc.
+ * @priv: Driver private data
+ *	Driverlink clients can use this to store a pointer to their
+ *	internal per-device data structure. Each (driver, device)
+ *	tuple has a separate &struct efx_dl_device, so clients can use
+ *	this @priv field independently.
+ * @driver: Efx driverlink driver for this device
+ */
+struct efx_dl_device {
+	struct pci_dev *pci_dev;
+	void *priv;
+	struct efx_dl_driver *driver;
+};
+
+/**
+ * enum efx_veto - Packet veto request flag.
+ *
+ * This is the return type for the rx_packet() and tx_packet() methods
+ * in &struct efx_dl_callbacks.
+ *
+ * @EFX_ALLOW_PACKET: Packet may be transmitted/received
+ * @EFX_VETO_PACKET: Packet must not be transmitted/received
+ */
+enum efx_veto {
+	EFX_ALLOW_PACKET = 0,
+	EFX_VETO_PACKET = 1,
+};
+
+/**
+ * struct efx_dl_callbacks - Efx callbacks
+ *
+ * These methods can be hooked in to the sfc driver via
+ * efx_dl_register_callbacks().  They allow clients to intercept and/or
+ * modify the behaviour of the sfc driver at predetermined points.
+ *
+ * For efficiency, only one client can hook each callback.
+ *
+ * Since these callbacks are called on packet transmit and reception
+ * paths, clients should avoid acquiring locks or allocating memory.
+ *
+ * @tx_packet: Called when packet is about to be transmitted
+ * @rx_packet: Called when packet is received
+ * @link_change: Called when link status has changed
+ * @request_mtu: Called to request MTU change
+ * @mtu_changed: Called when MTU has been changed
+ * @event: Called when NIC event is not handled by the sfc driver
+ */
+struct efx_dl_callbacks {
+	/*
+	 * tx_packet - Packet about to be transmitted.
+	 * @efx_dev:		Efx driverlink device
+	 * @skb:		Socket buffer containing the packet to be sent
+	 *
+	 * This method is called for every packet about to be
+	 * transmitted.  It allows the client to snoop on traffic sent
+	 * via the kernel queues.
+	 *
+	 * The method may return %EFX_VETO_PACKET in order to prevent
+	 * the sfc driver from transmitting the packet.  The net
+	 * driver will then discard the packet.  If the client wishes
+	 * to retain a reference to the packet data after returning
+	 * %EFX_VETO_PACKET, it must obtain its own copy of the
+	 * packet (e.g. by calling skb_get(), or by copying out the
+	 * packet data to an external buffer).
+	 *
+	 * This method must return quickly, since it will have a
+	 * direct performance impact upon the sfc driver.  It will be
+	 * called with interrupts disabled (and may be called in
+	 * interrupt context), so may not sleep. Since the sfc driver
+	 * may have multiple TX queues, running in parallel, please avoid
+	 * the need for locking if it all possible.
+	 */
+#if defined(EFX_USE_KCOMPAT) && defined(EFX_USE_FASTCALL)
+	enum efx_veto fastcall (*tx_packet) (struct efx_dl_device *efx_dev,
+					     struct sk_buff *skb);
+#else
+	enum efx_veto (*tx_packet) (struct efx_dl_device *efx_dev,
+				    struct sk_buff *skb);
+#endif
+
+	/*
+	 * rx_packet - Packet received.
+	 * @efx_dev:		Efx driverlink device
+	 * @pkt_hdr:		Pointer to received packet
+	 * @pkt_len:		Length of received packet
+	 *
+	 * This method is called for every received packet.  It allows
+	 * the client to snoop on traffic received by the kernel
+	 * queues.
+	 *
+	 * The method may return %EFX_VETO_PACKET in order to prevent
+	 * the sfc driver from passing the packet to the kernel.  The net
+	 * driver will then discard the packet.
+	 *
+	 * This method must return quickly, since it will have a
+	 * direct performance impact upon the sfc driver.  It is
+	 * called in tasklet context, so may not sleep.  Note that
+	 * there are per-channel tasklets in the sfc driver, so
+	 * rx_packet() may be called simultaneously on different CPUs
+	 * and must lock appropriately.  The design of the sfc driver
+	 * allows for lockless operation between receive channels, so
+	 * please avoid the need for locking if at all possible.
+	 */
+#if defined(EFX_USE_KCOMPAT) && defined(EFX_USE_FASTCALL)
+	enum efx_veto fastcall (*rx_packet) (struct efx_dl_device *efx_dev,
+					     const char *pkt_hdr, int pkt_len);
+#else
+	enum efx_veto (*rx_packet) (struct efx_dl_device *efx_dev,
+				    const char *pkt_hdr, int pkt_len);
+#endif
+
+	/*
+	 * link_change - Link status change.
+	 * @efx_dev:		Efx driverlink device
+	 * @link_up:		Link up indicator
+	 *
+	 * This method is called to inform the driverlink client
+	 * whenever the PHY link status changes.  By the time this
+	 * function is called, the MAC has already been reconfigured
+	 * with the new autonegotiation settings from the PHY.
+	 *
+	 * This method is called from tasklet context and may not
+	 * sleep.
+	 */
+	void (*link_change) (struct efx_dl_device *efx_dev, int link_up);
+
+	/*
+	 * request_mtu: Request MTU change.
+	 * @efx_dev:		Efx driverlink device
+	 * @new_mtu:		Requested new MTU
+	 *
+	 * This method is called whenever the user requests an MTU
+	 * change on an interface.  The client may return an error, in
+	 * which case the MTU change request will be denied.  If the
+	 * client returns success, the MAC will be reconfigured with a
+	 * new maxmimum frame length equal to
+	 * EFX_MAX_FRAME_LEN(new_mtu).  The client will be notified
+	 * via the mtu_changed() method once the MAC has been
+	 * reconfigured.
+	 *
+	 * The current MTU for the port can be obtained via
+	 * efx_dl_get_netdev(efx_dl_device)->mtu.
+	 *
+	 * The sfc driver guarantees that no other callback functions
+	 * are in progress when this method is called.  This function
+	 * is called in process context and may sleep.
+	 *
+	 * Return a negative error code or 0 on success.
+	 */
+	int (*request_mtu) (struct efx_dl_device *efx_dev, int new_mtu);
+
+	/*
+	 * mtu_changed - MTU has been changed.
+	 * @efx_dev:		Efx driverlink device
+	 * @mtu:		The new MTU
+	 *
+	 * This method is called once the MAC has been reconfigured
+	 * with a new MTU.  There will have been a preceding call to
+	 * request_mtu().
+	 *
+	 * The sfc driver guarantees that no other callback functions
+	 * are in progress when this method is called.  This function
+	 * is called in process context and may sleep.
+	 */
+	void (*mtu_changed) (struct efx_dl_device *efx_dev, int mtu);
+
+	/*
+	 * event - Event callback.
+	 * @efx_dev:		Efx driverlink device
+	 * @p_event:		Pointer to event
+	 *
+	 * This method is called for each event that is not handled by the
+	 * sfc driver.
+	 */
+	void (*event) (struct efx_dl_device *efx_dev, void *p_event);
+};
+
+/* Include API version number in symbol used for efx_dl_register_driver */
+#define efx_dl_stringify_1(x, y) x ## y
+#define efx_dl_stringify_2(x, y) efx_dl_stringify_1(x, y)
+#define efx_dl_register_driver					\
+	efx_dl_stringify_2(efx_dl_register_driver_api_ver_,	\
+			   EFX_DRIVERLINK_API_VERSION)
+
+extern int efx_dl_register_driver(struct efx_dl_driver *driver);
+
+extern void efx_dl_unregister_driver(struct efx_dl_driver *driver);
+
+extern int efx_dl_register_callbacks(struct efx_dl_device *efx_dev,
+				     struct efx_dl_callbacks *callbacks);
+
+extern void efx_dl_unregister_callbacks(struct efx_dl_device *efx_dev,
+					struct efx_dl_callbacks *callbacks);
+
+extern void efx_dl_schedule_reset(struct efx_dl_device *efx_dev);
+
+/**
+ * efx_dl_for_each_device_info_matching - iterate an efx_dl_device_info list
+ * @_dev_info: Pointer to first &struct efx_dl_device_info
+ * @_type: Type code to look for
+ * @_info_type: Structure type corresponding to type code
+ * @_field: Name of &struct efx_dl_device_info field in the type
+ * @_p: Iterator variable
+ *
+ * Example:
+ *
+ * static int driver_dl_probe(... const struct efx_dl_device_info *dev_info ...)
+ * {
+ *        struct efx_dl_falcon_resources *res;
+ *
+ *        efx_dl_for_each_device_info_matching(dev_info,EFX_DL_FALCON_RESOURCES,
+ *                                             struct efx_dl_falcon_resources,
+ *                                             hdr, res) {
+ *                if (res->flags & EFX_DL_FALCON_DUAL_FUNC) {
+ *                          .....
+ *                }
+ *        }
+ * }
+ */
+#define efx_dl_for_each_device_info_matching(_dev_info, _type,		\
+					     _info_type, _field, _p)	\
+	for ((_p) = container_of((_dev_info), _info_type, _field);	\
+	     (_p) != NULL;						\
+	     (_p) = container_of((_p)->_field.next, _info_type, _field))\
+		if ((_p)->_field.type != _type)				\
+			continue;					\
+		else
+
+/**
+ * efx_dl_search_device_info - search an efx_dl_device_info list
+ * @_dev_info: Pointer to first &struct efx_dl_device_info
+ * @_type: Type code to look for
+ * @_info_type: Structure type corresponding to type code
+ * @_field: Name of &struct efx_dl_device_info member in this type
+ * @_p: Result variable
+ *
+ * Example:
+ *
+ * static int driver_dl_probe(... const struct efx_dl_device_info *dev_info ...)
+ * {
+ *        struct efx_dl_falcon_resources *res;
+ *
+ *        efx_dl_search_device_info(dev_info, EFX_DL_FALCON_RESOURCES,
+ *                                  struct efx_dl_falcon_resources, hdr, res);
+ *        if (res != NULL) {
+ *                 ....
+ *        }
+ * }
+ */
+#define efx_dl_search_device_info(_dev_info, _type, _info_type,		\
+				  _field, _p)				\
+	efx_dl_for_each_device_info_matching((_dev_info), (_type),	\
+					     _info_type, _field, (_p))	\
+		break;
+
+#endif /* EFX_DRIVERLINK_API_H */
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 74265d8..0e153cb 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -544,6 +544,9 @@ static void efx_link_status_changed(struct efx_nic *efx)
 			netif_carrier_off(efx->net_dev);
 	}

+	/* Inform driverlink client */
+	EFX_DL_CALLBACK(efx, link_change, efx->link_up);
+
 	/* Status message for kernel log */
 	if (efx->link_up) {
 		struct mii_if_info *gmii = &efx->mii;
@@ -1410,6 +1413,8 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)

 	efx_stop_all(efx);

+	/* Ask driverlink client if we can change MTU */
+	rc = EFX_DL_CALLBACK(efx, request_mtu, new_mtu);
 	EFX_LOG(efx, "changing MTU to %d\n", new_mtu);

 	efx_fini_channels(efx);
@@ -1418,6 +1423,9 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	if (rc)
 		goto fail;

+	/* Notify driverlink client of new MTU */
+	EFX_DL_CALLBACK(efx, mtu_changed, new_mtu);
+
 	efx_start_all(efx);
 	return rc;

@@ -1570,6 +1578,23 @@ static void efx_unregister_netdev(struct efx_nic *efx)
  * Device reset and suspend
  *
  **************************************************************************/
+/* Serialise access to the driverlink callbacks, by quiescing event processing
+ * (without flushing the descriptor queues), and acquiring the rtnl_lock */
+void efx_suspend(struct efx_nic *efx)
+{
+	EFX_LOG(efx, "suspending operations\n");
+
+	rtnl_lock();
+	efx_stop_all(efx);
+}
+
+void efx_resume(struct efx_nic *efx)
+{
+	EFX_LOG(efx, "resuming operations\n");
+
+	efx_start_all(efx);
+	rtnl_unlock();
+}

 /* The final hardware and software finalisation before reset. */
 static int efx_reset_down(struct efx_nic *efx, struct ethtool_cmd *ecmd)
@@ -1632,6 +1657,10 @@ static int efx_reset(struct efx_nic *efx)
 	enum reset_type method = efx->reset_pending;
 	int rc;

+	/* Notify driverlink clients of imminent reset. */
+	efx_dl_reset_lock();
+	efx_dl_reset_suspend(efx);
+
 	/* Serialise with kernel interfaces */
 	rtnl_lock();

@@ -1701,8 +1730,9 @@ static int efx_reset(struct efx_nic *efx)

  unlock_rtnl:
 	rtnl_unlock();
+	efx_dl_reset_resume(efx, 1);
+	efx_dl_reset_unlock();
 	return 0;
-
  fail5:
  fail4:
  fail3:
@@ -1715,6 +1745,8 @@ static int efx_reset(struct efx_nic *efx)
 	rtnl_unlock();
 	efx_unregister_netdev(efx);
 	efx_fini_port(efx);
+	efx_dl_reset_resume(efx, 0);
+	efx_dl_reset_unlock();
 	return rc;
 }

@@ -1854,6 +1886,9 @@ static int efx_init_struct(struct efx_nic *efx, struct
efx_nic_type *type,
 	mutex_init(&efx->mac_lock);
 	efx->phy_op = &efx_dummy_phy_operations;
 	efx->mii.dev = net_dev;
+	INIT_LIST_HEAD(&efx->dl_node);
+	INIT_LIST_HEAD(&efx->dl_device_list);
+	efx->dl_cb = efx_default_callbacks;
 	INIT_WORK(&efx->reconfigure_work, efx_reconfigure_work);
 	atomic_set(&efx->netif_stop_count, 1);

@@ -1960,6 +1995,9 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	if (!efx)
 		return;

+	/* Unregister driver from driverlink layer */
+	efx_dl_unregister_nic(efx);
+
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
 	efx->state = STATE_FINI;
@@ -2126,8 +2164,15 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,

 	EFX_LOG(efx, "initialisation successful\n");

+	/* Register with driverlink layer */
+	rc = efx_dl_register_nic(efx);
+	if (rc)
+		goto fail6;
+
 	return 0;

+ fail6:
+	efx_unregister_netdev(efx);
  fail5:
 	efx_pci_remove_main(efx);
  fail4:
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 630406e..959e06a 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -36,14 +36,23 @@

 /**
  * struct falcon_nic_data - Falcon NIC state
+ * @tx_dc_entries: Number of entries in each TX queue descriptor cache
+ * @rx_dc_entries: Number of entries in each RX queue descriptor cache
+ * @tx_dc_base: Base address in SRAM of TX queue descriptor caches
+ * @rx_dc_base: Base address in SRAM of RX queue descriptor caches
  * @next_buffer_table: First available buffer table id
  * @pci_dev2: The secondary PCI device if present
  * @i2c_data: Operations and state for I2C bit-bashing algorithm
  */
 struct falcon_nic_data {
+	unsigned tx_dc_entries;
+	unsigned rx_dc_entries;
+	unsigned tx_dc_base;
+	unsigned rx_dc_base;
 	unsigned next_buffer_table;
 	struct pci_dev *pci_dev2;
 	struct i2c_algo_bit_data i2c_data;
+	struct efx_dl_falcon_resources resources;
 };

 /**************************************************************************
@@ -1120,10 +1129,12 @@ static void falcon_handle_driver_event(struct efx_channel
*channel,
 	case TX_DESCQ_FLS_DONE_EV_DECODE:
 		EFX_TRACE(efx, "channel %d TXQ %d flushed\n",
 			  channel->channel, ev_sub_data);
+		EFX_DL_CALLBACK(efx, event, event);
 		break;
 	case RX_DESCQ_FLS_DONE_EV_DECODE:
 		EFX_TRACE(efx, "channel %d RXQ %d flushed\n",
 			  channel->channel, ev_sub_data);
+		EFX_DL_CALLBACK(efx, event, event);
 		break;
 	case EVQ_INIT_DONE_EV_DECODE:
 		EFX_LOG(efx, "channel %d EVQ %d initialised\n",
@@ -1132,14 +1143,17 @@ static void falcon_handle_driver_event(struct efx_channel
*channel,
 	case SRM_UPD_DONE_EV_DECODE:
 		EFX_TRACE(efx, "channel %d SRAM update done\n",
 			  channel->channel);
+		EFX_DL_CALLBACK(efx, event, event);
 		break;
 	case WAKE_UP_EV_DECODE:
 		EFX_TRACE(efx, "channel %d RXQ %d wakeup event\n",
 			  channel->channel, ev_sub_data);
+		EFX_DL_CALLBACK(efx, event, event);
 		break;
 	case TIMER_EV_DECODE:
 		EFX_TRACE(efx, "channel %d RX queue %d timer expired\n",
 			  channel->channel, ev_sub_data);
+		EFX_DL_CALLBACK(efx, event, event);
 		break;
 	case RX_RECOVERY_EV_DECODE:
 		EFX_ERR(efx, "channel %d seen DRIVER RX_RESET event. "
@@ -1164,6 +1178,7 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 		EFX_TRACE(efx, "channel %d unknown driver event code %d "
 			  "data %04x\n", channel->channel, ev_sub_code,
 			  ev_sub_data);
+		EFX_DL_CALLBACK(efx, event, event);
 		break;
 	}
 }
@@ -2376,6 +2391,70 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	return rc;
 }

+/* Looks at available SRAM resources and silicon revision, and works out
+ * how many queues we can support, and where things like descriptor caches
+ * should live. */
+static int falcon_dimension_resources(struct efx_nic *efx)
+{
+	unsigned buffer_entry_bytes, internal_dcs_entries;
+	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct efx_dl_falcon_resources *res = &nic_data->resources;
+
+	/* Fill out the driverlink resource list */
+	res->hdr.type = EFX_DL_FALCON_RESOURCES;
+	res->biu_lock = &efx->biu_lock;
+	efx->dl_info = &res->hdr;
+	nic_data->tx_dc_entries = 16;
+
+	/* Set the RX descriptor cache size.  Values 16, 32 and 64 are
+	 * supported (8 won't work).  Bigger is better, especially on B
+	 * silicon.
+	 */
+	nic_data->rx_dc_entries = 64;
+
+	/* NB. The minimum values get increased as this driver initialises
+	 * its resources, so this should prevent any overlap.
+	 */
+	switch (falcon_rev(efx)) {
+	case FALCON_REV_A1:
+		res->rxq_min = 16;
+		res->txq_min = 16;
+		res->evq_int_min = 4;
+		res->evq_int_lim = 5;
+		res->evq_timer_min = 5;
+		res->evq_timer_lim = 4096;
+		internal_dcs_entries = 8192;
+		break;
+	case FALCON_REV_B0:
+	default:
+		res->rxq_min = 0;
+		res->txq_min = 0;
+		res->evq_int_min = 0;
+		res->evq_int_lim = 64;
+		res->evq_timer_min = 64;
+		res->evq_timer_lim = 4096;
+		internal_dcs_entries = 4096;
+		break;
+	}
+
+	buffer_entry_bytes = 8;
+
+	res->rxq_lim = internal_dcs_entries / nic_data->rx_dc_entries;
+	res->txq_lim = internal_dcs_entries / nic_data->tx_dc_entries;
+	/* Internal SRAM only for now */
+	res->buffer_table_lim = 8192;
+	nic_data->tx_dc_base = 0x130000;
+	nic_data->rx_dc_base = 0x100000;
+
+	if (FALCON_IS_DUAL_FUNC(efx))
+		res->flags |= EFX_DL_FALCON_DUAL_FUNC;
+
+	if (EFX_INT_MODE_USE_MSI(efx))
+		res->flags |= EFX_DL_FALCON_USE_MSI;
+
+	return 0;
+}
+
 /* Probe the NIC variant (revision, ASIC vs FPGA, function count, port
  * count, port speed).  Set workaround and feature flags accordingly.
  */
@@ -2477,6 +2556,10 @@ int falcon_probe_nic(struct efx_nic *efx)
 	if (rc)
 		goto fail5;

+	rc = falcon_dimension_resources(efx);
+	if (rc)
+		goto fail6;
+
 	/* Initialise I2C adapter */
  	efx->i2c_adap.owner = THIS_MODULE;
  	efx->i2c_adap.class = I2C_CLASS_HWMON;
@@ -2487,10 +2570,12 @@ int falcon_probe_nic(struct efx_nic *efx)
 	strcpy(efx->i2c_adap.name, "SFC4000 GPIO");
 	rc = i2c_bit_add_bus(&efx->i2c_adap);
 	if (rc)
-		goto fail5;
+		goto fail6;

 	return 0;

+ fail6:
+	efx->dl_info = NULL;
  fail5:
 	falcon_free_buffer(efx, &efx->irq_status);
  fail4:
@@ -2681,6 +2766,7 @@ void falcon_remove_nic(struct efx_nic *efx)
 	/* Tear down the private nic state */
 	kfree(efx->nic_data);
 	efx->nic_data = NULL;
+	efx->dl_info = NULL;
 }

 void falcon_update_nic_stats(struct efx_nic *efx)
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index d803b86..2a84468 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -30,6 +30,8 @@

 #include "enum.h"
 #include "bitfield.h"
+#include "driverlink_api.h"
+#include "driverlink.h"

 #define EFX_MAX_LRO_DESCRIPTORS 8
 #define EFX_MAX_LRO_AGGR MAX_SKB_FRAGS
@@ -674,6 +676,12 @@ union efx_multicast_hash {
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
  * @loopback_selftest: Offline self-test private state
+ * @silicon_rev: Silicon revision description for driverlink
+ * @dl_info: Linked list of hardware parameters exposed through driverlink
+ * @dl_node: Driverlink port list
+ * @dl_device_list: Driverlink device list
+ * @dl_cb: Driverlink callbacks table
+ * @dl_cb_dev: Driverlink callback owner devices
  *
  * The @priv field of the corresponding &struct net_device points to
  * this.
@@ -749,6 +757,13 @@ struct efx_nic {
 	unsigned int loopback_modes;

 	void *loopback_selftest;
+
+	const char *silicon_rev;
+	struct efx_dl_device_info *dl_info;
+	struct list_head dl_node;
+	struct list_head dl_device_list;
+	struct efx_dl_callbacks dl_cb;
+	struct efx_dl_cb_devices dl_cb_dev;
 };

 static inline int efx_dev_registered(struct efx_nic *efx)
-- 
1.5.3.7


