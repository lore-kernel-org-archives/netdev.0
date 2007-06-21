From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 3/4] [Net] Support accelerated network plugin modules
Date: Thu, 21 Jun 2007 14:17:25 +0100
Message-ID: <1182431845.5614.41.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6UITQ0NCmtaSZDtmPiiV"
Cc: netdev@vger.kernel.org
To: xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:15736 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754819AbXFUNR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 09:17:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6UITQ0NCmtaSZDtmPiiV
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Backend net driver acceleration

Signed-off-by: Kieran Mansley <kmansley@solarflare.com> 

diff -r 30c836e0575e drivers/xen/netback/Makefile
--- a/drivers/xen/netback/Makefile	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/Makefile	Fri Jun 15 15:37:41 2007 +0100
@@ -1,5 +1,5 @@ obj-$(CONFIG_XEN_NETDEV_BACKEND) := netb
 obj-$(CONFIG_XEN_NETDEV_BACKEND) := netbk.o
 obj-$(CONFIG_XEN_NETDEV_LOOPBACK) += netloop.o
 
-netbk-y   := netback.o xenbus.o interface.o
+netbk-y   := netback.o xenbus.o interface.o accel.o
 netloop-y := loopback.o
diff -r 30c836e0575e drivers/xen/netback/accel.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/xen/netback/accel.c	Wed Jun 20 14:58:09 2007 +0100
@@ -0,0 +1,207 @@
+/******************************************************************************
+ * drivers/xen/netback/accel.c
+ *
+ * Interface between backend virtual network device and accelerated plugin. 
+ * 
+ * Copyright (C) 2007 Solarflare Communications, Inc
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ * 
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ * 
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ * 
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include <linux/list.h>
+#include <asm/atomic.h>
+#include <xen/xenbus.h>
+
+#include "common.h"
+
+#if 0
+#undef DPRINTK
+#define DPRINTK(fmt, args...)						\
+	printk("netback/accel (%s:%d) " fmt ".\n", __FUNCTION__, __LINE__, ##args)
+#endif
+
+/* 
+ * A list of available netback accelerator plugin modules (each list
+ * entry is of type struct netback_accelerator) 
+ */ 
+static struct list_head accelerators_list;
+/* Lock used to protect access to accelerators_list */
+static spinlock_t accelerators_lock;
+
+/* 
+ * Compare a backend to an accelerator, and decide if they are
+ * compatible (i.e. if the accelerator should be used by the
+ * backend) 
+ */
+static int match_accelerator(struct backend_info *be, 
+			     struct netback_accelerator *accelerator)
+{
+	/*
+	 * This could do with being more sophisticated.  For example,
+	 * determine which hardware is being used by each backend from
+	 * the bridge and network topology of the domain
+	 */
+	return be->accelerator == NULL;
+}
+
+/*
+ * Notify all suitable backends that a new accelerator is available
+ * and connected.  This will also notify the accelerator plugin module
+ * that it is being used for a device through the probe hook.
+ */
+static int netback_accelerator_tell_backend(struct device *dev, void *arg)
+{
+	struct netback_accelerator *accelerator = 
+		(struct netback_accelerator *)arg;
+	struct xenbus_device *xendev = to_xenbus_device(dev);
+
+	if (!strcmp("vif", xendev->devicetype)) {
+		struct backend_info *be = xendev->dev.driver_data;
+
+		if (match_accelerator(be, accelerator)) {
+			be->accelerator = accelerator;
+			atomic_inc(&be->accelerator->use_count);
+			be->accelerator->hooks->probe(xendev);
+		}
+	}
+	return 0;
+}
+
+
+/*
+ * Entry point for an netback accelerator plugin module.  Called to
+ * advertise its presence, and connect to any suitable backends.
+ */
+void netback_connect_accelerator(int id, const char *frontend, 
+				 struct netback_accel_hooks *hooks)
+{
+	struct netback_accelerator *new_accelerator = 
+		kmalloc(sizeof(struct netback_accelerator), GFP_KERNEL);
+	unsigned frontend_len, flags;
+
+	if (!new_accelerator) {
+		DPRINTK("%s: failed to allocate memory for accelerator\n",
+			__FUNCTION__);
+		return;
+	}
+
+	new_accelerator->id = id;
+	
+	frontend_len = strlen(frontend)+1;
+	new_accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+	if (!new_accelerator->frontend) {
+		DPRINTK("%s: failed to allocate memory for frontend string\n",
+			__FUNCTION__);
+		kfree(new_accelerator);
+		return;
+	}
+	strlcpy(new_accelerator->frontend, frontend, frontend_len);
+	
+	new_accelerator->hooks = hooks;
+
+	atomic_set(&new_accelerator->use_count, 0);
+	
+	spin_lock_irqsave(&accelerators_lock, flags);
+	list_add(&new_accelerator->link, &accelerators_list);
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+	
+	/* tell existing backends about new plugin */
+	xenbus_for_each_backend(new_accelerator, 
+				netback_accelerator_tell_backend);
+
+}
+EXPORT_SYMBOL_GPL(netback_connect_accelerator);
+
+
+/* 
+ * Disconnect an accerator plugin module that has previously been
+ * connected.
+ *
+ * This should only be allowed when there are no remaining users -
+ * i.e. it is not necessary to go through and clear all the hooks, as
+ * they should have already been removed.  This is enforced through a
+ * usage count and BUG_ON(use!=0), but should be made more user-friendly
+ */
+void netback_disconnect_accelerator(int id, const char *frontend)
+{
+	struct netback_accelerator *accelerator, *next;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+	list_for_each_entry_safe(accelerator, next, &accelerators_list, link) {
+		if (strcmp(frontend, accelerator->frontend)) {
+			BUG_ON(atomic_read(&accelerator->use_count) != 0);
+			list_del(&accelerator->link);
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+			kfree(accelerator->frontend);
+			kfree(accelerator);
+			return;
+		}
+	}
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netback_disconnect_accelerator);
+
+
+void netback_probe_accelerators(struct backend_info *be,
+				struct xenbus_device *dev)
+{
+	struct netback_accelerator *accelerator;
+	unsigned flags;
+
+	/* 
+	 * Check list of accelerators to see if any is suitable, and
+	 * use it if it is.
+	 */
+	spin_lock_irqsave(&accelerators_lock, flags);
+	list_for_each_entry(accelerator, &accelerators_list, link) { 
+		if (match_accelerator(be, accelerator)) {
+			be->accelerator = accelerator;
+			atomic_inc(&be->accelerator->use_count);
+			be->accelerator->hooks->probe(dev);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+
+
+void netback_remove_accelerators(struct backend_info *be,
+				 struct xenbus_device *dev)
+{
+	/* Notify the accelerator (if any) of this device's removal */
+	if ( be->accelerator ) {
+		be->accelerator->hooks->remove(dev);
+		atomic_dec(&be->accelerator->use_count);
+	}
+	be->accelerator = NULL;
+}
+
+
+void netif_accel_init(void)
+{
+	INIT_LIST_HEAD(&accelerators_list);
+	spin_lock_init(&accelerators_lock);
+}
diff -r 30c836e0575e drivers/xen/netback/common.h
--- a/drivers/xen/netback/common.h	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/common.h	Mon Jun 18 09:30:21 2007 +0100
@@ -45,6 +45,7 @@
 #include <xen/interface/grant_table.h>
 #include <xen/gnttab.h>
 #include <xen/driver_util.h>
+#include <xen/xenbus.h>
 
 #define DPRINTK(_f, _a...)			\
 	pr_debug("(file=%s, line=%d) " _f,	\
@@ -122,6 +123,49 @@ enum {
 
 extern int netbk_copy_skb_mode;
 
+/* Function pointers into netback accelerator plugin modules */
+struct netback_accel_hooks {
+	int  (*probe)(struct xenbus_device *dev);
+	int (*remove)(struct xenbus_device *dev);
+};
+
+/* Structure to track the state of a netback accelerator plugin */
+struct netback_accelerator {
+	struct list_head link;
+	int id;
+	char *frontend;
+	atomic_t use_count;
+	struct netback_accel_hooks *hooks;
+};
+
+struct backend_info {
+	struct xenbus_device *dev;
+	netif_t *netif;
+	enum xenbus_state frontend_state;
+
+	/* State relating to the netback accelerator */
+	void *netback_accel_priv;
+	/* The accelerator that this backend is currently using */
+	struct netback_accelerator *accelerator;
+};
+
+/* Connect an accelerator plugin module to netback */
+extern void netback_connect_accelerator(int id, const char *frontend, 
+					struct netback_accel_hooks *hooks);
+/* Disconnect a previously connected accelerator pluging module */
+extern void netback_disconnect_accelerator(int id, const char *frontend);
+
+
+extern
+void netback_probe_accelerators(struct backend_info *be,
+				struct xenbus_device *dev);
+extern
+void netback_remove_accelerators(struct backend_info *be,
+				 struct xenbus_device *dev);
+extern
+void netif_accel_init(void);
+
+
 #define NET_TX_RING_SIZE __RING_SIZE((netif_tx_sring_t *)0, PAGE_SIZE)
 #define NET_RX_RING_SIZE __RING_SIZE((netif_rx_sring_t *)0, PAGE_SIZE)
 
diff -r 30c836e0575e drivers/xen/netback/netback.c
--- a/drivers/xen/netback/netback.c	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/netback.c	Mon Jun 18 09:30:21 2007 +0100
@@ -1587,6 +1587,8 @@ static int __init netback_init(void)
 			netbk_copy_skb_mode = NETBK_DELAYED_COPY_SKB;
 	}
 
+	netif_accel_init();
+
 	netif_xenbus_init();
 
 #ifdef NETBE_DEBUG_INTERRUPT
diff -r 30c836e0575e drivers/xen/netback/xenbus.c
--- a/drivers/xen/netback/xenbus.c	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/xenbus.c	Wed Jun 20 14:58:20 2007 +0100
@@ -28,11 +28,6 @@
     printk("netback/xenbus (%s:%d) " fmt ".\n", __FUNCTION__, __LINE__, ##args)
 #endif
 
-struct backend_info {
-	struct xenbus_device *dev;
-	netif_t *netif;
-	enum xenbus_state frontend_state;
-};
 
 static int connect_rings(struct backend_info *);
 static void connect(struct backend_info *);
@@ -41,6 +36,8 @@ static int netback_remove(struct xenbus_
 static int netback_remove(struct xenbus_device *dev)
 {
 	struct backend_info *be = dev->dev.driver_data;
+
+	netback_remove_accelerators(be, dev);
 
 	if (be->netif) {
 		netif_disconnect(be->netif);
@@ -125,6 +122,8 @@ static int netback_probe(struct xenbus_d
 		goto fail;
 	}
 
+	netback_probe_accelerators(be, dev);
+
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
 		goto fail;


--=-6UITQ0NCmtaSZDtmPiiV
Content-Disposition: attachment; filename=backend_accel
Content-Type: text/plain; name=backend_accel; charset=UTF-8
Content-Transfer-Encoding: 7bit

Backend net driver acceleration

diff -r 30c836e0575e drivers/xen/netback/Makefile
--- a/drivers/xen/netback/Makefile	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/Makefile	Fri Jun 15 15:37:41 2007 +0100
@@ -1,5 +1,5 @@ obj-$(CONFIG_XEN_NETDEV_BACKEND) := netb
 obj-$(CONFIG_XEN_NETDEV_BACKEND) := netbk.o
 obj-$(CONFIG_XEN_NETDEV_LOOPBACK) += netloop.o
 
-netbk-y   := netback.o xenbus.o interface.o
+netbk-y   := netback.o xenbus.o interface.o accel.o
 netloop-y := loopback.o
diff -r 30c836e0575e drivers/xen/netback/accel.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/xen/netback/accel.c	Wed Jun 20 14:58:09 2007 +0100
@@ -0,0 +1,207 @@
+/******************************************************************************
+ * drivers/xen/netback/accel.c
+ *
+ * Interface between backend virtual network device and accelerated plugin. 
+ * 
+ * Copyright (C) 2007 Solarflare Communications, Inc
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ * 
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ * 
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ * 
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include <linux/list.h>
+#include <asm/atomic.h>
+#include <xen/xenbus.h>
+
+#include "common.h"
+
+#if 0
+#undef DPRINTK
+#define DPRINTK(fmt, args...)						\
+	printk("netback/accel (%s:%d) " fmt ".\n", __FUNCTION__, __LINE__, ##args)
+#endif
+
+/* 
+ * A list of available netback accelerator plugin modules (each list
+ * entry is of type struct netback_accelerator) 
+ */ 
+static struct list_head accelerators_list;
+/* Lock used to protect access to accelerators_list */
+static spinlock_t accelerators_lock;
+
+/* 
+ * Compare a backend to an accelerator, and decide if they are
+ * compatible (i.e. if the accelerator should be used by the
+ * backend) 
+ */
+static int match_accelerator(struct backend_info *be, 
+			     struct netback_accelerator *accelerator)
+{
+	/*
+	 * This could do with being more sophisticated.  For example,
+	 * determine which hardware is being used by each backend from
+	 * the bridge and network topology of the domain
+	 */
+	return be->accelerator == NULL;
+}
+
+/*
+ * Notify all suitable backends that a new accelerator is available
+ * and connected.  This will also notify the accelerator plugin module
+ * that it is being used for a device through the probe hook.
+ */
+static int netback_accelerator_tell_backend(struct device *dev, void *arg)
+{
+	struct netback_accelerator *accelerator = 
+		(struct netback_accelerator *)arg;
+	struct xenbus_device *xendev = to_xenbus_device(dev);
+
+	if (!strcmp("vif", xendev->devicetype)) {
+		struct backend_info *be = xendev->dev.driver_data;
+
+		if (match_accelerator(be, accelerator)) {
+			be->accelerator = accelerator;
+			atomic_inc(&be->accelerator->use_count);
+			be->accelerator->hooks->probe(xendev);
+		}
+	}
+	return 0;
+}
+
+
+/*
+ * Entry point for an netback accelerator plugin module.  Called to
+ * advertise its presence, and connect to any suitable backends.
+ */
+void netback_connect_accelerator(int id, const char *frontend, 
+				 struct netback_accel_hooks *hooks)
+{
+	struct netback_accelerator *new_accelerator = 
+		kmalloc(sizeof(struct netback_accelerator), GFP_KERNEL);
+	unsigned frontend_len, flags;
+
+	if (!new_accelerator) {
+		DPRINTK("%s: failed to allocate memory for accelerator\n",
+			__FUNCTION__);
+		return;
+	}
+
+	new_accelerator->id = id;
+	
+	frontend_len = strlen(frontend)+1;
+	new_accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+	if (!new_accelerator->frontend) {
+		DPRINTK("%s: failed to allocate memory for frontend string\n",
+			__FUNCTION__);
+		kfree(new_accelerator);
+		return;
+	}
+	strlcpy(new_accelerator->frontend, frontend, frontend_len);
+	
+	new_accelerator->hooks = hooks;
+
+	atomic_set(&new_accelerator->use_count, 0);
+	
+	spin_lock_irqsave(&accelerators_lock, flags);
+	list_add(&new_accelerator->link, &accelerators_list);
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+	
+	/* tell existing backends about new plugin */
+	xenbus_for_each_backend(new_accelerator, 
+				netback_accelerator_tell_backend);
+
+}
+EXPORT_SYMBOL_GPL(netback_connect_accelerator);
+
+
+/* 
+ * Disconnect an accerator plugin module that has previously been
+ * connected.
+ *
+ * This should only be allowed when there are no remaining users -
+ * i.e. it is not necessary to go through and clear all the hooks, as
+ * they should have already been removed.  This is enforced through a
+ * usage count and BUG_ON(use!=0), but should be made more user-friendly
+ */
+void netback_disconnect_accelerator(int id, const char *frontend)
+{
+	struct netback_accelerator *accelerator, *next;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+	list_for_each_entry_safe(accelerator, next, &accelerators_list, link) {
+		if (strcmp(frontend, accelerator->frontend)) {
+			BUG_ON(atomic_read(&accelerator->use_count) != 0);
+			list_del(&accelerator->link);
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+			kfree(accelerator->frontend);
+			kfree(accelerator);
+			return;
+		}
+	}
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netback_disconnect_accelerator);
+
+
+void netback_probe_accelerators(struct backend_info *be,
+				struct xenbus_device *dev)
+{
+	struct netback_accelerator *accelerator;
+	unsigned flags;
+
+	/* 
+	 * Check list of accelerators to see if any is suitable, and
+	 * use it if it is.
+	 */
+	spin_lock_irqsave(&accelerators_lock, flags);
+	list_for_each_entry(accelerator, &accelerators_list, link) { 
+		if (match_accelerator(be, accelerator)) {
+			be->accelerator = accelerator;
+			atomic_inc(&be->accelerator->use_count);
+			be->accelerator->hooks->probe(dev);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+
+
+void netback_remove_accelerators(struct backend_info *be,
+				 struct xenbus_device *dev)
+{
+	/* Notify the accelerator (if any) of this device's removal */
+	if ( be->accelerator ) {
+		be->accelerator->hooks->remove(dev);
+		atomic_dec(&be->accelerator->use_count);
+	}
+	be->accelerator = NULL;
+}
+
+
+void netif_accel_init(void)
+{
+	INIT_LIST_HEAD(&accelerators_list);
+	spin_lock_init(&accelerators_lock);
+}
diff -r 30c836e0575e drivers/xen/netback/common.h
--- a/drivers/xen/netback/common.h	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/common.h	Mon Jun 18 09:30:21 2007 +0100
@@ -45,6 +45,7 @@
 #include <xen/interface/grant_table.h>
 #include <xen/gnttab.h>
 #include <xen/driver_util.h>
+#include <xen/xenbus.h>
 
 #define DPRINTK(_f, _a...)			\
 	pr_debug("(file=%s, line=%d) " _f,	\
@@ -122,6 +123,49 @@ enum {
 
 extern int netbk_copy_skb_mode;
 
+/* Function pointers into netback accelerator plugin modules */
+struct netback_accel_hooks {
+	int  (*probe)(struct xenbus_device *dev);
+	int (*remove)(struct xenbus_device *dev);
+};
+
+/* Structure to track the state of a netback accelerator plugin */
+struct netback_accelerator {
+	struct list_head link;
+	int id;
+	char *frontend;
+	atomic_t use_count;
+	struct netback_accel_hooks *hooks;
+};
+
+struct backend_info {
+	struct xenbus_device *dev;
+	netif_t *netif;
+	enum xenbus_state frontend_state;
+
+	/* State relating to the netback accelerator */
+	void *netback_accel_priv;
+	/* The accelerator that this backend is currently using */
+	struct netback_accelerator *accelerator;
+};
+
+/* Connect an accelerator plugin module to netback */
+extern void netback_connect_accelerator(int id, const char *frontend, 
+					struct netback_accel_hooks *hooks);
+/* Disconnect a previously connected accelerator pluging module */
+extern void netback_disconnect_accelerator(int id, const char *frontend);
+
+
+extern
+void netback_probe_accelerators(struct backend_info *be,
+				struct xenbus_device *dev);
+extern
+void netback_remove_accelerators(struct backend_info *be,
+				 struct xenbus_device *dev);
+extern
+void netif_accel_init(void);
+
+
 #define NET_TX_RING_SIZE __RING_SIZE((netif_tx_sring_t *)0, PAGE_SIZE)
 #define NET_RX_RING_SIZE __RING_SIZE((netif_rx_sring_t *)0, PAGE_SIZE)
 
diff -r 30c836e0575e drivers/xen/netback/netback.c
--- a/drivers/xen/netback/netback.c	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/netback.c	Mon Jun 18 09:30:21 2007 +0100
@@ -1587,6 +1587,8 @@ static int __init netback_init(void)
 			netbk_copy_skb_mode = NETBK_DELAYED_COPY_SKB;
 	}
 
+	netif_accel_init();
+
 	netif_xenbus_init();
 
 #ifdef NETBE_DEBUG_INTERRUPT
diff -r 30c836e0575e drivers/xen/netback/xenbus.c
--- a/drivers/xen/netback/xenbus.c	Fri Jun 15 15:35:17 2007 +0100
+++ b/drivers/xen/netback/xenbus.c	Wed Jun 20 14:58:20 2007 +0100
@@ -28,11 +28,6 @@
     printk("netback/xenbus (%s:%d) " fmt ".\n", __FUNCTION__, __LINE__, ##args)
 #endif
 
-struct backend_info {
-	struct xenbus_device *dev;
-	netif_t *netif;
-	enum xenbus_state frontend_state;
-};
 
 static int connect_rings(struct backend_info *);
 static void connect(struct backend_info *);
@@ -41,6 +36,8 @@ static int netback_remove(struct xenbus_
 static int netback_remove(struct xenbus_device *dev)
 {
 	struct backend_info *be = dev->dev.driver_data;
+
+	netback_remove_accelerators(be, dev);
 
 	if (be->netif) {
 		netif_disconnect(be->netif);
@@ -125,6 +122,8 @@ static int netback_probe(struct xenbus_d
 		goto fail;
 	}
 
+	netback_probe_accelerators(be, dev);
+
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
 		goto fail;

--=-6UITQ0NCmtaSZDtmPiiV--

