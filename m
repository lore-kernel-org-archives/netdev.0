From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 3/4] [Net] Support accelerated network plugin modules
Date: Fri, 15 Jun 2007 11:46:32 +0100
Message-ID: <1181904392.4121.54.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xQw+1Zp1jy80juf+uNRg"
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:8426 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752479AbXFOKqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 06:46:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xQw+1Zp1jy80juf+uNRg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Backend net driver acceleration

Signed-off-by: Kieran Mansley <kmansley@solarflare.com>

diff -r fd61ea65cba3 drivers/xen/netback/common.h
--- a/drivers/xen/netback/common.h	Thu Jun 14 14:51:20 2007 +0100
+++ b/drivers/xen/netback/common.h	Thu Jun 14 14:56:41 2007 +0100
@@ -122,6 +122,41 @@ enum {
 
 extern int netbk_copy_skb_mode;
 
+
+#include <xen/xenbus.h>
+
+/* Function pointers into netback accelerator plugin modules */
+struct netback_accel_hooks {
+        int  (*probe)(struct xenbus_device *dev);
+        int (*remove)(struct xenbus_device *dev);
+};
+
+/* Structure to track the state of a netback accelerator plugin */
+struct netback_accelerator {
+        struct list_head link;
+        int id;
+        char *frontend;
+        struct netback_accel_hooks *hooks;
+};
+
+/* Connect an accelerator plugin module to netback */
+extern void netback_connect_accelerator(int id, const char *frontend, 
+                                        struct netback_accel_hooks *hooks);
+/* Disconnect a previously connected accelerator pluging module */
+extern void netback_disconnect_accelerator(int id, const char *frontend);
+
+struct backend_info {
+	struct xenbus_device *dev;
+	netif_t *netif;
+	enum xenbus_state frontend_state;
+
+        /* State relating to the netback accelerator */
+        void *netback_accel_priv;
+        /* The accelerator that this backend is currently using */
+        struct netback_accelerator *accelerator;
+};
+
+
 #define NET_TX_RING_SIZE __RING_SIZE((netif_tx_sring_t *)0, PAGE_SIZE)
 #define NET_RX_RING_SIZE __RING_SIZE((netif_rx_sring_t *)0, PAGE_SIZE)
 
diff -r fd61ea65cba3 drivers/xen/netback/xenbus.c
--- a/drivers/xen/netback/xenbus.c	Thu Jun 14 14:51:20 2007 +0100
+++ b/drivers/xen/netback/xenbus.c	Thu Jun 14 14:56:41 2007 +0100
@@ -1,6 +1,7 @@
 /*  Xenbus code for netif backend
     Copyright (C) 2005 Rusty Russell <rusty@rustcorp.com.au>
     Copyright (C) 2005 XenSource Ltd
+    Copyright (c) 2007 Solarflare Communications, Inc.
 
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
@@ -28,11 +29,126 @@
     printk("netback/xenbus (%s:%d) " fmt ".\n", __FUNCTION__, __LINE__, ##args)
 #endif
 
-struct backend_info {
-	struct xenbus_device *dev;
-	netif_t *netif;
-	enum xenbus_state frontend_state;
-};
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
+                             struct netback_accelerator *accelerator)
+{
+        /*
+         * This could do with being more sophisticated.  For example,
+         * determine which hardware is being used by each backend from
+         * the bridge and network topology of the domain
+         */
+        if ( be->accelerator == NULL )
+                return 1;
+        else
+                return 0;
+}
+
+/*
+ * Notify all suitable backends that a new accelerator is available
+ * and connected.  This will also notify the accelerator plugin module
+ * that it is being used for a device through the probe hook.
+ */
+static int netback_accelerator_tell_backend(struct device *dev, void *arg)
+{
+        struct netback_accelerator *accelerator = 
+                (struct netback_accelerator *)arg;
+        struct xenbus_device *xendev = to_xenbus_device(dev);
+
+        if( !strcmp("vif", xendev->devicetype) ) {
+                struct backend_info *be = xendev->dev.driver_data;
+
+                if ( match_accelerator(be, accelerator) ) {
+                             be->accelerator = accelerator;
+                             be->accelerator->hooks->probe(xendev);
+                }
+        }
+        return 0;
+}
+
+
+/*
+ * Entry point for an netback accelerator plugin module.  Called to
+ * advertise its presence, and connect to any suitable backends.
+ */
+void netback_connect_accelerator(int id, const char *frontend, 
+                                 struct netback_accel_hooks *hooks)
+{
+        struct netback_accelerator *new_accelerator = 
+                kmalloc(sizeof(struct netback_accelerator), GFP_KERNEL);
+        unsigned frontend_len, flags;
+
+        if ( new_accelerator ) {
+                new_accelerator->id = id;
+
+                frontend_len = strlen(frontend)+1;
+                new_accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+                if ( !new_accelerator->frontend ) {
+                        DPRINTK("%s: failed to allocate memory for frontend string\n",
+                                __FUNCTION__);
+                        kfree(new_accelerator);
+                        return;
+                }
+                strlcpy(new_accelerator->frontend, frontend, frontend_len);
+
+                new_accelerator->hooks = hooks;
+                
+                spin_lock_irqsave(&accelerators_lock, flags);
+                list_add(&new_accelerator->link, &accelerators_list);
+                spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                /* tell existing backends about new plugin */
+                xenbus_for_each_backend(new_accelerator, 
+                                        netback_accelerator_tell_backend);
+        } else {
+                DPRINTK("%s: failed to allocate memory for accelerator\n",
+                        __FUNCTION__);
+                return;  
+        }
+}
+EXPORT_SYMBOL_GPL(netback_connect_accelerator);
+
+
+/* 
+ * Disconnect an accelerator plugin module that has previously been
+ * connected.
+ *
+ * This should only be allowed when there are no remaining users -
+ * i.e. it is not necessary to go through and clear all the hooks, as
+ * they should have already been removed.  However, this isn't
+ * currently enforced.
+ */
+void netback_disconnect_accelerator(int id, const char *frontend)
+{
+        struct netback_accelerator *accelerator, *next;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+        list_for_each_entry_safe(accelerator, next, &accelerators_list, link) {
+                if ( strcmp(frontend, accelerator->frontend) ) {
+                        list_del(&accelerator->link);
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+                        kfree(accelerator->frontend);
+                        kfree(accelerator);
+                        return;
+                }
+        }
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netback_disconnect_accelerator);
+
 
 static int connect_rings(struct backend_info *);
 static void connect(struct backend_info *);
@@ -42,6 +158,11 @@ static int netback_remove(struct xenbus_
 {
 	struct backend_info *be = dev->dev.driver_data;
 
+        /* Notify the accelerator (if any) of this device's removal */
+        if ( be->accelerator ) 
+                be->accelerator->hooks->remove(dev);
+        be->accelerator = NULL;
+
 	if (be->netif) {
 		netif_disconnect(be->netif);
 		be->netif = NULL;
@@ -61,6 +182,8 @@ static int netback_probe(struct xenbus_d
 {
 	const char *message;
 	struct xenbus_transaction xbt;
+        struct netback_accelerator *accelerator;
+        unsigned flags;
 	int err;
 	int sg;
 	struct backend_info *be = kzalloc(sizeof(struct backend_info),
@@ -124,6 +247,20 @@ static int netback_probe(struct xenbus_d
 		xenbus_dev_fatal(dev, err, "completing transaction");
 		goto fail;
 	}
+
+        /* 
+         * Check list of accelerators to see if any is suitable, and
+         * use it if it is.
+         */
+        spin_lock_irqsave(&accelerators_lock, flags);
+        list_for_each_entry( accelerator, &accelerators_list, link ) { 
+                if ( match_accelerator(be, accelerator) ) {
+                        be->accelerator = accelerator;
+                        be->accelerator->hooks->probe(dev);
+                        break;
+                }
+        }
+        spin_unlock_irqrestore(&accelerators_lock, flags);
 
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
@@ -449,5 +586,8 @@ static struct xenbus_driver netback = {
 
 void netif_xenbus_init(void)
 {
+        INIT_LIST_HEAD(&accelerators_list);
+        spin_lock_init(&accelerators_lock);
+
 	xenbus_register_backend(&netback);
 }


--=-xQw+1Zp1jy80juf+uNRg
Content-Disposition: attachment; filename=backend_accel
Content-Type: text/plain; name=backend_accel; charset=UTF-8
Content-Transfer-Encoding: 7bit

Backend net driver acceleration

diff -r fd61ea65cba3 drivers/xen/netback/common.h
--- a/drivers/xen/netback/common.h	Thu Jun 14 14:51:20 2007 +0100
+++ b/drivers/xen/netback/common.h	Thu Jun 14 14:56:41 2007 +0100
@@ -122,6 +122,41 @@ enum {
 
 extern int netbk_copy_skb_mode;
 
+
+#include <xen/xenbus.h>
+
+/* Function pointers into netback accelerator plugin modules */
+struct netback_accel_hooks {
+        int  (*probe)(struct xenbus_device *dev);
+        int (*remove)(struct xenbus_device *dev);
+};
+
+/* Structure to track the state of a netback accelerator plugin */
+struct netback_accelerator {
+        struct list_head link;
+        int id;
+        char *frontend;
+        struct netback_accel_hooks *hooks;
+};
+
+/* Connect an accelerator plugin module to netback */
+extern void netback_connect_accelerator(int id, const char *frontend, 
+                                        struct netback_accel_hooks *hooks);
+/* Disconnect a previously connected accelerator pluging module */
+extern void netback_disconnect_accelerator(int id, const char *frontend);
+
+struct backend_info {
+	struct xenbus_device *dev;
+	netif_t *netif;
+	enum xenbus_state frontend_state;
+
+        /* State relating to the netback accelerator */
+        void *netback_accel_priv;
+        /* The accelerator that this backend is currently using */
+        struct netback_accelerator *accelerator;
+};
+
+
 #define NET_TX_RING_SIZE __RING_SIZE((netif_tx_sring_t *)0, PAGE_SIZE)
 #define NET_RX_RING_SIZE __RING_SIZE((netif_rx_sring_t *)0, PAGE_SIZE)
 
diff -r fd61ea65cba3 drivers/xen/netback/xenbus.c
--- a/drivers/xen/netback/xenbus.c	Thu Jun 14 14:51:20 2007 +0100
+++ b/drivers/xen/netback/xenbus.c	Thu Jun 14 14:56:41 2007 +0100
@@ -1,6 +1,7 @@
 /*  Xenbus code for netif backend
     Copyright (C) 2005 Rusty Russell <rusty@rustcorp.com.au>
     Copyright (C) 2005 XenSource Ltd
+    Copyright (c) 2007 Solarflare Communications, Inc.
 
     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
@@ -28,11 +29,126 @@
     printk("netback/xenbus (%s:%d) " fmt ".\n", __FUNCTION__, __LINE__, ##args)
 #endif
 
-struct backend_info {
-	struct xenbus_device *dev;
-	netif_t *netif;
-	enum xenbus_state frontend_state;
-};
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
+                             struct netback_accelerator *accelerator)
+{
+        /*
+         * This could do with being more sophisticated.  For example,
+         * determine which hardware is being used by each backend from
+         * the bridge and network topology of the domain
+         */
+        if ( be->accelerator == NULL )
+                return 1;
+        else
+                return 0;
+}
+
+/*
+ * Notify all suitable backends that a new accelerator is available
+ * and connected.  This will also notify the accelerator plugin module
+ * that it is being used for a device through the probe hook.
+ */
+static int netback_accelerator_tell_backend(struct device *dev, void *arg)
+{
+        struct netback_accelerator *accelerator = 
+                (struct netback_accelerator *)arg;
+        struct xenbus_device *xendev = to_xenbus_device(dev);
+
+        if( !strcmp("vif", xendev->devicetype) ) {
+                struct backend_info *be = xendev->dev.driver_data;
+
+                if ( match_accelerator(be, accelerator) ) {
+                             be->accelerator = accelerator;
+                             be->accelerator->hooks->probe(xendev);
+                }
+        }
+        return 0;
+}
+
+
+/*
+ * Entry point for an netback accelerator plugin module.  Called to
+ * advertise its presence, and connect to any suitable backends.
+ */
+void netback_connect_accelerator(int id, const char *frontend, 
+                                 struct netback_accel_hooks *hooks)
+{
+        struct netback_accelerator *new_accelerator = 
+                kmalloc(sizeof(struct netback_accelerator), GFP_KERNEL);
+        unsigned frontend_len, flags;
+
+        if ( new_accelerator ) {
+                new_accelerator->id = id;
+
+                frontend_len = strlen(frontend)+1;
+                new_accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+                if ( !new_accelerator->frontend ) {
+                        DPRINTK("%s: failed to allocate memory for frontend string\n",
+                                __FUNCTION__);
+                        kfree(new_accelerator);
+                        return;
+                }
+                strlcpy(new_accelerator->frontend, frontend, frontend_len);
+
+                new_accelerator->hooks = hooks;
+                
+                spin_lock_irqsave(&accelerators_lock, flags);
+                list_add(&new_accelerator->link, &accelerators_list);
+                spin_unlock_irqrestore(&accelerators_lock, flags);
+
+                /* tell existing backends about new plugin */
+                xenbus_for_each_backend(new_accelerator, 
+                                        netback_accelerator_tell_backend);
+        } else {
+                DPRINTK("%s: failed to allocate memory for accelerator\n",
+                        __FUNCTION__);
+                return;  
+        }
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
+ * they should have already been removed.  However, this isn't
+ * currently enforced.
+ */
+void netback_disconnect_accelerator(int id, const char *frontend)
+{
+        struct netback_accelerator *accelerator, *next;
+        unsigned flags;
+
+        spin_lock_irqsave(&accelerators_lock, flags);
+        list_for_each_entry_safe(accelerator, next, &accelerators_list, link) {
+                if ( strcmp(frontend, accelerator->frontend) ) {
+                        list_del(&accelerator->link);
+                        spin_unlock_irqrestore(&accelerators_lock, flags);
+                        kfree(accelerator->frontend);
+                        kfree(accelerator);
+                        return;
+                }
+        }
+        spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netback_disconnect_accelerator);
+
 
 static int connect_rings(struct backend_info *);
 static void connect(struct backend_info *);
@@ -42,6 +158,11 @@ static int netback_remove(struct xenbus_
 {
 	struct backend_info *be = dev->dev.driver_data;
 
+        /* Notify the accelerator (if any) of this device's removal */
+        if ( be->accelerator ) 
+                be->accelerator->hooks->remove(dev);
+        be->accelerator = NULL;
+
 	if (be->netif) {
 		netif_disconnect(be->netif);
 		be->netif = NULL;
@@ -61,6 +182,8 @@ static int netback_probe(struct xenbus_d
 {
 	const char *message;
 	struct xenbus_transaction xbt;
+        struct netback_accelerator *accelerator;
+        unsigned flags;
 	int err;
 	int sg;
 	struct backend_info *be = kzalloc(sizeof(struct backend_info),
@@ -124,6 +247,20 @@ static int netback_probe(struct xenbus_d
 		xenbus_dev_fatal(dev, err, "completing transaction");
 		goto fail;
 	}
+
+        /* 
+         * Check list of accelerators to see if any is suitable, and
+         * use it if it is.
+         */
+        spin_lock_irqsave(&accelerators_lock, flags);
+        list_for_each_entry( accelerator, &accelerators_list, link ) { 
+                if ( match_accelerator(be, accelerator) ) {
+                        be->accelerator = accelerator;
+                        be->accelerator->hooks->probe(dev);
+                        break;
+                }
+        }
+        spin_unlock_irqrestore(&accelerators_lock, flags);
 
 	err = xenbus_switch_state(dev, XenbusStateInitWait);
 	if (err)
@@ -449,5 +586,8 @@ static struct xenbus_driver netback = {
 
 void netif_xenbus_init(void)
 {
+        INIT_LIST_HEAD(&accelerators_list);
+        spin_lock_init(&accelerators_lock);
+
 	xenbus_register_backend(&netback);
 }

--=-xQw+1Zp1jy80juf+uNRg--

