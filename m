From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 4/4] [Net] Support accelerated network plugin modules
Date: Thu, 21 Jun 2007 14:17:27 +0100
Message-ID: <1182431847.5614.42.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-SxNQuJ+cDz4lxMBECvsD"
Cc: netdev@vger.kernel.org
To: xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:15739 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754945AbXFUNRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 09:17:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SxNQuJ+cDz4lxMBECvsD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Frontend net driver acceleration

Signed-off-by: Kieran Mansley <kmansley@solarflare.com> 

diff -r 82196b117a5b drivers/xen/netfront/Makefile
--- a/drivers/xen/netfront/Makefile	Wed Jun 20 17:01:02 2007 +0100
+++ b/drivers/xen/netfront/Makefile	Wed Jun 20 17:01:07 2007 +0100
@@ -1,4 +1,4 @@
 
 obj-$(CONFIG_XEN_NETDEV_FRONTEND)	:= xennet.o
 
-xennet-objs := netfront.o
+xennet-objs := netfront.o accel.o
diff -r 82196b117a5b drivers/xen/netfront/accel.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/xen/netfront/accel.c	Thu Jun 21 13:47:33 2007 +0100
@@ -0,0 +1,773 @@
+/******************************************************************************
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (C) 2007 Solarflare Communications, Inc.
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
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/list.h>
+#include <linux/kref.h>
+
+#include <xen/xenbus.h>
+
+#include "netfront.h"
+
+#define DPRINTK(fmt, args...)				\
+	pr_debug("netfront/accel (%s:%d) " fmt,		\
+		 __FUNCTION__, __LINE__, ##args)
+#define IPRINTK(fmt, args...)				\
+	printk(KERN_INFO "netfront/accel: " fmt, ##args)
+#define WPRINTK(fmt, args...)				\
+	printk(KERN_WARNING "netfront/accel: " fmt, ##args)
+
+/*
+ * List of all netfront accelerator plugin modules available.  Each
+ * list entry is of type struct netfront_accelerator.
+ */ 
+static struct list_head accelerators_list;
+
+/*
+ * Lock to protect access to accelerators_list
+ */
+static spinlock_t accelerators_lock;
+
+/* Forward declaration of kref cleanup functions */
+static void accel_kref_release(struct kref *ref);
+static void vif_kref_release(struct kref *ref);
+
+
+void netif_init_accel(void)
+{
+	INIT_LIST_HEAD(&accelerators_list);
+	spin_lock_init(&accelerators_lock);
+}
+
+
+/* 
+ * Initialise the accel_vif_state field in the netfront state
+ */ 
+void init_accelerator_vif(struct netfront_info *np,
+			  struct xenbus_device *dev)
+{
+	np->accelerator = NULL;
+
+	/* It's assumed that these things don't change */
+	np->accel_vif_state.np = np;
+	np->accel_vif_state.dev = dev;
+
+	np->accel_vif_state.ready_for_probe = 1;
+	np->accel_vif_state.need_probe = NULL;
+}
+
+
+/*
+ * Compare a frontend description string against an accelerator to see
+ * if they match.  Would ultimately be nice to replace the string with
+ * a unique numeric identifier for each accelerator.
+ */
+static int match_accelerator(const char *frontend, 
+			     struct netfront_accelerator *accelerator)
+{
+	return strcmp(frontend, accelerator->frontend) == 0;
+}
+
+
+/* 
+ * Add a frontend vif to the list of vifs that is using a netfront
+ * accelerator plugin module.
+ */
+static void add_accelerator_vif(struct netfront_accelerator *accelerator,
+				struct netfront_info *np)
+{
+	np->accelerator = accelerator;
+
+	list_add(&np->accel_vif_state.link, &accelerator->vif_states);
+}
+
+
+/*
+ * Initialise the state to track an accelerator plugin module.
+ */ 
+static int init_accelerator(const char *frontend, 
+			    struct netfront_accelerator **result)
+{
+	struct netfront_accelerator *accelerator = 
+		kmalloc(sizeof(struct netfront_accelerator), GFP_KERNEL);
+	int frontend_len;
+
+	if (!accelerator) {
+		DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+		return -ENOMEM;
+	}
+
+	frontend_len = strlen(frontend) + 1;
+	accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+	if (!accelerator->frontend) {
+		DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+		kfree(accelerator);
+		return -ENOMEM;
+	}
+	strlcpy(accelerator->frontend, frontend, frontend_len);
+	
+	INIT_LIST_HEAD(&accelerator->vif_states);
+	spin_lock_init(&accelerator->vif_states_lock);
+
+	accelerator->hooks = NULL;
+
+	accelerator->ready_for_probe = 1;
+	accelerator->need_probe = NULL;
+
+	list_add(&accelerator->link, &accelerators_list);
+
+	*result = accelerator;
+
+	return 0;
+}					
+
+
+/* 
+ * Modify the hooks stored in the per-vif state to match that in the
+ * netfront accelerator's state.
+ */
+static void 
+accelerator_set_vif_state_hooks(struct netfront_accel_vif_state *vif_state)
+{
+	/* This function must be called with the vif_state_lock held */
+
+	/*
+	 * Take references to stop hooks disappearing.
+	 * This persists until vif_kref gets to zero.
+	 */
+	kref_get(&vif_state->np->accelerator->accel_kref);
+	/* This persists until vif_state->hooks are cleared */
+	kref_init(&vif_state->vif_kref);
+
+	/* Make sure there are no data path operations going on */
+	netif_poll_disable(vif_state->np->netdev);
+	netif_tx_lock_bh(vif_state->np->netdev);
+
+	vif_state->hooks = vif_state->np->accelerator->hooks;
+
+	netif_tx_unlock_bh(vif_state->np->netdev);
+	netif_poll_enable(vif_state->np->netdev);
+}
+
+
+static void accelerator_probe_new_vif(struct netfront_info *np,
+				      struct xenbus_device *dev, 
+				      struct netfront_accelerator *accelerator)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+	
+	DPRINTK("%s\n", __FUNCTION__);
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	
+	/*
+	 * Include this frontend device on the accelerator's list
+	 */
+	add_accelerator_vif(accelerator, np);
+	
+	hooks = accelerator->hooks;
+	
+	if (hooks) {
+		if (np->accel_vif_state.ready_for_probe) {
+			np->accel_vif_state.ready_for_probe = 0;
+			
+			kref_get(&accelerator->accel_kref);
+			
+			spin_unlock_irqrestore(&accelerator->vif_states_lock,
+					       flags);
+			
+			hooks->new_device(np->netdev, dev);
+			
+			kref_put(&accelerator->accel_kref,
+				 accel_kref_release);
+			/* 
+			 * Hooks will get linked into vif_state by a
+			 * future call by the accelerator to
+			 * netfront_accelerator_ready()
+			 */
+			return;
+		} else {
+			if (np->accel_vif_state.need_probe != NULL)
+				DPRINTK("Probe request on vif awaiting probe\n");
+			np->accel_vif_state.need_probe = hooks;
+		}
+	}
+		
+	spin_unlock_irqrestore(&accelerator->vif_states_lock,
+			       flags);
+	return;
+}
+
+/*  
+ * Request that a particular netfront accelerator plugin is loaded.
+ * Usually called as a result of the vif configuration specifying
+ * which one to use.
+ */
+int netfront_load_accelerator(struct netfront_info *np, 
+			      struct xenbus_device *dev, 
+			      const char *frontend)
+{
+	struct netfront_accelerator *accelerator;
+	int rc;
+	unsigned flags;
+
+	DPRINTK("%s: %s\n", __FUNCTION__, frontend);
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	/* 
+	 * Look at list of loaded accelerators to see if the requested
+	 * one is already there 
+	 */
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+
+			accelerator_probe_new_vif(np, dev, accelerator);
+
+			return 0;
+		}
+	}
+
+	/* Couldn't find it, so create a new one and load the module */
+	if ((rc = init_accelerator(frontend, &accelerator)) < 0) {
+		spin_unlock_irqrestore(&accelerators_lock, flags);
+		return rc;
+	}
+
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+
+	/* Include this frontend device on the accelerator's list */
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	add_accelerator_vif(accelerator, np);
+	spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+
+	DPRINTK("%s: loading module %s\n", __FUNCTION__, frontend);
+
+	/* load module */
+	request_module("%s", frontend);
+
+	/*
+	 * Module should now call netfront_accelerator_loaded() once
+	 * it's up and running, and we can continue from there 
+	 */
+
+	return 0;
+}
+
+
+/*
+ * Go through all the netfront vifs and see if they have requested
+ * this accelerator.  Notify the accelerator plugin of the relevant
+ * device if so.  Called when an accelerator plugin module is first
+ * loaded and connects to netfront.
+ */
+static void 
+accelerator_probe_vifs(struct netfront_accelerator *accelerator,
+		       struct netfront_accel_hooks *hooks,
+		       unsigned lock_flags)
+{
+	struct netfront_accel_vif_state *vif_state, *tmp;
+
+	/* Calling function must have taken the vif_states_lock */
+
+	DPRINTK("%s: %p\n", __FUNCTION__, accelerator);
+
+	/* 
+	 * kref_init() takes a single reference to the hooks that will
+	 * persist until the accelerator hooks are removed (e.g. by
+	 * accelerator module unload)
+	 */
+	kref_init(&accelerator->accel_kref);
+
+	/* 
+	 * Store the hooks for future calls to probe a new device, and
+	 * to wire into the vif_state once the accelerator plugin is
+	 * ready to accelerate each vif
+	 */
+	BUG_ON(hooks == NULL);
+	accelerator->hooks = hooks;
+	
+	list_for_each_entry_safe(vif_state, tmp, &accelerator->vif_states,
+				 link) {
+		struct netfront_info *np = vif_state->np;
+
+		if (vif_state->ready_for_probe) {
+			vif_state->ready_for_probe = 0;
+			kref_get(&accelerator->accel_kref);
+
+			/* 
+			 * drop lock before calling hook.  hooks are
+			 * protected by the kref
+			 */
+			spin_unlock_irqrestore(&accelerator->vif_states_lock,
+					       lock_flags);
+			
+			hooks->new_device(np->netdev, vif_state->dev);
+			
+			kref_put(&accelerator->accel_kref, accel_kref_release);
+
+			/* Retake lock for next go round the loop */
+			spin_lock_irqsave(&accelerator->vif_states_lock, lock_flags);
+			
+			/*
+			 * Hooks will get linked into vif_state by a call to
+			 * netfront_accelerator_ready() once accelerator
+			 * plugin is ready for action
+			 */
+		} else {
+			if (vif_state->need_probe != NULL)
+				DPRINTK("Probe request on vif awaiting probe\n");
+			vif_state->need_probe = hooks;
+		}
+	}
+	
+	/* Return with vif_states_lock held, as on entry */
+}
+
+
+/* 
+ * Wrapper for accelerator_probe_vifs that checks now is a good time
+ * to do the probe, and postpones till previous state cleared up if
+ * necessary
+ */
+static void 
+accelerator_probe_vifs_on_load(struct netfront_accelerator *accelerator,
+			       struct netfront_accel_hooks *hooks)
+{
+	unsigned flags;
+
+	DPRINTK("%s\n", __FUNCTION__);
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	
+	if (accelerator->ready_for_probe) {
+		accelerator->ready_for_probe = 0;
+		accelerator_probe_vifs(accelerator, hooks, flags);
+	} else {
+		if (accelerator->need_probe)
+			DPRINTK("Probe request on accelerator awaiting probe\n");
+		accelerator->need_probe = hooks;
+	}
+
+	spin_unlock_irqrestore(&accelerator->vif_states_lock,
+			       flags);
+}
+
+
+/* 
+ * Called by the netfront accelerator plugin module when it has loaded 
+ */
+int netfront_accelerator_loaded(const char *frontend, 
+				struct netfront_accel_hooks *hooks)
+{
+	struct netfront_accelerator *accelerator;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	/* 
+	 * Look through list of accelerators to see if it has already
+	 * been requested
+	 */
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+
+			accelerator_probe_vifs_on_load(accelerator, hooks);
+
+			return 0;
+		}
+	}
+
+	/*
+	 * If it wasn't in the list, add it now so that when it is
+	 * requested the caller will find it
+	 */
+	DPRINTK("%s: Couldn't find matching accelerator (%s)\n",
+		__FUNCTION__, frontend);
+
+	init_accelerator(frontend, &accelerator);
+
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_loaded);
+
+
+/* 
+ * Called by the accelerator module after it has been probed with a
+ * network device to say that it is ready to start accelerating
+ * traffic on that device
+ */
+void netfront_accelerator_ready(const char *frontend,
+				struct xenbus_device *dev)
+{
+	struct netfront_accelerator *accelerator;
+	struct netfront_accel_vif_state *accel_vif_state;
+	unsigned flags, flags1;
+
+	DPRINTK("%s: %s %p\n", __FUNCTION__, frontend, dev);
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_lock_irqsave
+				(&accelerator->vif_states_lock, flags1);
+
+			list_for_each_entry(accel_vif_state,
+					    &accelerator->vif_states, link) {
+				if (accel_vif_state->dev == dev)
+					accelerator_set_vif_state_hooks
+						(accel_vif_state);
+			}
+
+			spin_unlock_irqrestore
+				(&accelerator->vif_states_lock, flags1);
+			goto done;
+		}
+	}
+
+ done:
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_ready);
+
+
+/* 
+ * Safely remove the accelerator function hooks from a netfront state.
+ */
+static void accelerator_remove_hooks(struct netfront_accelerator *accelerator)
+{
+	struct netfront_accel_vif_state *vif_state, *tmp;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+
+	list_for_each_entry_safe(vif_state, tmp,
+				 &accelerator->vif_states,
+				 link) {
+		/* Make sure there are no data path operations going on */
+		netif_poll_disable(vif_state->np->netdev);
+		netif_tx_lock_bh(vif_state->np->netdev);
+
+		/* 
+		 * Remove the hooks, but leave the vif_state on the
+		 * accelerator's list as that signifies this vif is
+		 * interested in using that accelerator if it becomes
+		 * available again
+		 */
+		vif_state->hooks = NULL;
+		
+		netif_tx_unlock_bh(vif_state->np->netdev);
+		netif_poll_enable(vif_state->np->netdev);
+
+		/* 
+		 * Remove the reference taken when the vif_state hooks
+		 * were set, must be called without lock held
+		 */
+		spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+		kref_put(&vif_state->vif_kref, vif_kref_release);
+		spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	}
+	
+	accelerator->hooks = NULL;
+
+	spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+
+	/* Remove the reference taken when module loaded */ 
+	kref_put(&accelerator->accel_kref, accel_kref_release);
+}
+
+
+/* 
+ * Called by a netfront accelerator when it is unloaded.  This safely
+ * removes the hooks into the plugin and blocks until all devices have
+ * finished using it, so on return it is safe to unload.
+ */
+void netfront_accelerator_unloaded(const char *frontend)
+{
+	struct netfront_accelerator *accelerator;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+
+			/* 
+			 * Use semaphore to ensure we know when all
+			 * uses of hooks are complete
+			 */
+			sema_init(&accelerator->exit_semaphore, 0);
+
+			accelerator_remove_hooks(accelerator);
+
+			/* Wait for hooks to be unused, then return */
+			down(&accelerator->exit_semaphore);
+			
+			return;
+		}
+	}
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_unloaded);
+
+
+int netfront_check_accelerator_queue_busy(struct net_device *dev,
+					  struct netfront_info *np)
+{
+	struct netfront_accel_hooks *hooks;
+	int rc = 1;
+	unsigned flags;
+
+	/*
+	 * Call the check busy accelerator hook. The use count for the
+	 * accelerator's hooks is incremented for the duration of the
+	 * call to prevent the accelerator being able to modify the
+	 * hooks in the middle (by, for example, unloading)
+	 */ 
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			rc = np->accel_vif_state.hooks->check_busy(dev);
+			
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+
+	return rc;
+}
+
+
+int netfront_accelerator_call_remove(struct netfront_info *np,
+				     struct xenbus_device *dev)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+	int rc = 0;
+
+	/* 
+	 * Call the remove accelerator hook. The use count for the
+	 * accelerator's hooks is incremented for the duration of the
+	 * call to prevent the accelerator being able to modify the
+	 * hooks in the middle (by, for example, unloading)
+	 */ 
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			rc = np->accel_vif_state.hooks->remove(dev);
+
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+	return rc;
+}
+
+
+int netfront_accelerator_call_resume(struct netfront_info *np,
+				     struct xenbus_device *dev)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+	int rc = 0;
+
+	/* 
+	 *  Call the resume accelerator hook.  The use count for the
+	 *  accelerator's hooks is incremented for the duration of
+	 *  the call to prevent the accelerator being able to modify
+	 *  the hooks in the middle (by, for example, unloading)
+	 */
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			rc = np->accel_vif_state.hooks->resume(dev);
+
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+	return rc;
+}
+
+
+void netfront_accelerator_call_backend_changed(struct netfront_info *np,
+					       struct xenbus_device *dev,
+					       enum xenbus_state backend_state)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* 
+	 * Call the backend_changed accelerator hook. The use count
+	 * for the accelerator's hooks is incremented for the duration
+	 * of the call to prevent the accelerator being able to modify
+	 * the hooks in the middle (by, for example, unloading)
+	 */
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			np->accel_vif_state.hooks->backend_changed
+				(dev, backend_state);
+
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+}
+
+
+void netfront_accelerator_call_stop_napi_irq(struct netfront_info *np,
+					     struct net_device *dev)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* 
+	 * Call the stop_napi_interrupts accelerator hook.  The use
+	 * count for the accelerator's hooks is incremented for the
+	 * duration of the call to prevent the accelerator being able
+	 * to modify the hooks in the middle (by, for example,
+	 * unloading)
+	 */
+
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			np->accel_vif_state.hooks->stop_napi_irq(dev);
+		
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+}
+
+
+/* 
+ * Once all users of hooks have kref_put()'d we can signal that it's
+ * safe to unload
+ */ 
+static void accel_kref_release(struct kref *ref)
+{
+	struct netfront_accelerator *accelerator =
+		container_of(ref, struct netfront_accelerator, accel_kref);
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* Signal that all users of hooks are done */
+	up(&accelerator->exit_semaphore);
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	if (accelerator->need_probe) {
+		hooks = accelerator->need_probe;
+		accelerator->need_probe = NULL;
+		accelerator_probe_vifs(accelerator, hooks, flags);
+	} 
+	else
+		accelerator->ready_for_probe = 1;
+
+	spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+}
+
+
+static void vif_kref_release(struct kref *ref)
+{
+	struct netfront_accel_vif_state *vif_state = 
+		container_of(ref, struct netfront_accel_vif_state, vif_kref);
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* 
+	 * Now that this vif has finished using the hooks, it can
+	 * decrement the accelerator's global copy ref count 
+	 */
+	kref_put(&vif_state->np->accelerator->accel_kref, accel_kref_release);
+
+	spin_lock_irqsave(&vif_state->np->accelerator->vif_states_lock, flags);
+	if (vif_state->need_probe) {
+		hooks = vif_state->need_probe;
+		vif_state->need_probe = NULL;
+		spin_unlock_irqrestore
+			(&vif_state->np->accelerator->vif_states_lock, flags);
+		hooks->new_device(vif_state->np->netdev, vif_state->dev);
+	} else {
+		vif_state->ready_for_probe = 1;
+		spin_unlock_irqrestore
+			(&vif_state->np->accelerator->vif_states_lock, flags);
+	}
+}
+
diff -r 82196b117a5b drivers/xen/netfront/netfront.c
--- a/drivers/xen/netfront/netfront.c	Wed Jun 20 17:01:02 2007 +0100
+++ b/drivers/xen/netfront/netfront.c	Wed Jun 20 17:01:07 2007 +0100
@@ -3,6 +3,7 @@
  *
  * Copyright (c) 2002-2005, K A Fraser
  * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -74,6 +75,8 @@ struct netfront_cb {
 
 #define NETFRONT_SKB_CB(skb)	((struct netfront_cb *)((skb)->cb))
 
+#include "netfront.h"
+
 /*
  * Mutually-exclusive module options to select receive data path:
  *  rx_copy : Packets are copied by network backend into local memory
@@ -144,57 +147,6 @@ static inline int netif_needs_gso(struct
 
 #define GRANT_INVALID_REF	0
 
-#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
-#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
-
-struct netfront_info {
-	struct list_head list;
-	struct net_device *netdev;
-
-	struct net_device_stats stats;
-
-	struct netif_tx_front_ring tx;
-	struct netif_rx_front_ring rx;
-
-	spinlock_t   tx_lock;
-	spinlock_t   rx_lock;
-
-	unsigned int irq;
-	unsigned int copying_receiver;
-	unsigned int carrier;
-
-	/* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	unsigned rx_min_target, rx_max_target, rx_target;
-	struct sk_buff_head rx_batch;
-
-	struct timer_list rx_refill_timer;
-
-	/*
-	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
-	 * is an index into a chain of free entries.
-	 */
-	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
-	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
-
-#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	grant_ref_t gref_tx_head;
-	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
-	grant_ref_t gref_rx_head;
-	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
-
-	struct xenbus_device *xbdev;
-	int tx_ring_ref;
-	int rx_ring_ref;
-	u8 mac[ETH_ALEN];
-
-	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
-	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
-	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
-};
-
 struct netfront_rx_info {
 	struct netif_rx_response rx;
 	struct netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
@@ -334,6 +286,8 @@ static int __devexit netfront_remove(str
 
 	DPRINTK("%s\n", dev->nodename);
 
+	netfront_accelerator_call_remove(info, dev);
+
 	netif_disconnect_backend(info);
 
 	del_timer_sync(&info->rx_refill_timer);
@@ -358,6 +312,8 @@ static int netfront_resume(struct xenbus
 	struct netfront_info *info = dev->dev.driver_data;
 
 	DPRINTK("%s\n", dev->nodename);
+
+	netfront_accelerator_call_resume(info, dev);
 
 	netif_disconnect_backend(info);
 	return 0;
@@ -577,6 +533,8 @@ static void backend_changed(struct xenbu
 		xenbus_frontend_closed(dev);
 		break;
 	}
+
+	netfront_accelerator_call_backend_changed(np, dev, backend_state);
 }
 
 /** Send a packet on a net device to encourage switches to learn the
@@ -613,15 +571,29 @@ static inline int netfront_tx_slot_avail
 		(TX_MAX_TARGET - MAX_SKB_FRAGS - 2));
 }
 
+
 static inline void network_maybe_wake_tx(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
 
 	if (unlikely(netif_queue_stopped(dev)) &&
 	    netfront_tx_slot_available(np) &&
-	    likely(netif_running(dev)))
+	    likely(netif_running(dev)) &&
+	    netfront_check_accelerator_queue_busy(dev, np))
 		netif_wake_queue(dev);
 }
+
+
+int netfront_check_queue_busy(struct net_device *dev)
+{
+	struct netfront_info *np = netdev_priv(dev);
+
+	return unlikely(netif_queue_stopped(dev)) &&
+		netfront_tx_slot_available(np) &&
+		likely(netif_running(dev));
+}
+EXPORT_SYMBOL(netfront_check_queue_busy);
+
 
 static int network_open(struct net_device *dev)
 {
@@ -633,8 +605,11 @@ static int network_open(struct net_devic
 	if (netfront_carrier_ok(np)) {
 		network_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)){
+			netfront_accelerator_call_stop_napi_irq(np, dev);
+
 			netif_rx_schedule(dev);
+		}
 	}
 	spin_unlock_bh(&np->rx_lock);
 
@@ -702,6 +677,10 @@ static void rx_refill_timeout(unsigned l
 static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
+	struct netfront_info *np = netdev_priv(dev);
+
+	netfront_accelerator_call_stop_napi_irq(np, dev);
+
 	netif_rx_schedule(dev);
 }
 
@@ -941,6 +920,13 @@ static int network_start_xmit(struct sk_
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 
+	/* Check the fast path, if hooks are available */
+	if (np->accel_vif_state.hooks &&
+	    np->accel_vif_state.hooks->start_xmit(skb, dev)) {
+		/* Fast path has sent this packet */
+		return 0;
+	}
+
 	frags += (offset + len + PAGE_SIZE - 1) / PAGE_SIZE;
 	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
 		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
@@ -1044,8 +1030,11 @@ static irqreturn_t netif_int(int irq, vo
 	if (likely(netfront_carrier_ok(np))) {
 		network_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)) {
+			netfront_accelerator_call_stop_napi_irq(np, dev);
+
 			netif_rx_schedule(dev);
+		}
 	}
 
 	spin_unlock_irqrestore(&np->tx_lock, flags);
@@ -1305,7 +1294,7 @@ static int netif_poll(struct net_device 
 	struct netif_extra_info *extras = rinfo.extras;
 	RING_IDX i, rp;
 	struct multicall_entry *mcl;
-	int work_done, budget, more_to_do = 1;
+	int work_done, budget, more_to_do = 1, accel_more_to_do = 1;
 	struct sk_buff_head rxq;
 	struct sk_buff_head errq;
 	struct sk_buff_head tmpq;
@@ -1472,6 +1461,20 @@ err:
 
 	network_alloc_rx_buffers(dev);
 
+	if (work_done < budget) {
+		/* there's some spare capacity, try the accelerated path */
+		int accel_budget = budget - work_done;
+		int accel_budget_start = accel_budget;
+
+		if (np->accel_vif_state.hooks) {
+			accel_more_to_do = 
+				np->accel_vif_state.hooks->netdev_poll
+				(dev, &accel_budget);
+			work_done += (accel_budget_start - accel_budget);
+		} else 
+			accel_more_to_do = 0;
+	}
+
 	*pbudget   -= work_done;
 	dev->quota -= work_done;
 
@@ -1479,15 +1482,26 @@ err:
 		local_irq_save(flags);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
-		if (!more_to_do)
+
+		if (!more_to_do && !accel_more_to_do && 
+		    np->accel_vif_state.hooks) {
+			/* 
+			 *  Slow path has nothing more to do, see if
+			 *  fast path is likewise
+			 */
+			accel_more_to_do = 
+				np->accel_vif_state.hooks->start_napi_irq(dev);
+		}
+
+		if (!more_to_do && !accel_more_to_do)
 			__netif_rx_complete(dev);
 
 		local_irq_restore(flags);
 	}
 
 	spin_unlock(&np->rx_lock);
-
-	return more_to_do;
+	
+	return more_to_do | accel_more_to_do;
 }
 
 static void netif_release_tx_bufs(struct netfront_info *np)
@@ -1687,7 +1701,9 @@ static int network_connect(struct net_de
 	struct sk_buff *skb;
 	grant_ref_t ref;
 	netif_rx_request_t *req;
-	unsigned int feature_rx_copy, feature_rx_flip;
+	unsigned int feature_rx_copy, feature_rx_flip, feature_accel;
+	char *accel_frontend;
+	int accel_len;
 
 	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
 			   "feature-rx-copy", "%u", &feature_rx_copy);
@@ -1698,6 +1714,12 @@ static int network_connect(struct net_de
 	if (err != 1)
 		feature_rx_flip = 1;
 
+	feature_accel = 1;
+	accel_frontend = xenbus_read(XBT_NIL, np->xbdev->otherend, 
+				     "accel", &accel_len);
+	if (IS_ERR(accel_frontend)) 
+		feature_accel = 0;
+
 	/*
 	 * Copy packets on receive path if:
 	 *  (a) This was requested by user, and the backend supports it; or
@@ -1709,6 +1731,11 @@ static int network_connect(struct net_de
 	err = talk_to_backend(np->xbdev, np);
 	if (err)
 		return err;
+
+	if (feature_accel) {
+		netfront_load_accelerator(np, np->xbdev, accel_frontend);
+		kfree(accel_frontend);
+	}
 
 	xennet_set_features(dev);
 
@@ -1956,6 +1983,8 @@ static struct net_device * __devinit cre
 	spin_lock_init(&np->tx_lock);
 	spin_lock_init(&np->rx_lock);
 
+	init_accelerator_vif(np, dev);
+
 	skb_queue_head_init(&np->rx_batch);
 	np->rx_target     = RX_DFL_MIN_TARGET;
 	np->rx_min_target = RX_DFL_MIN_TARGET;
@@ -2110,6 +2139,8 @@ static int __init netif_init(void)
 	if (is_initial_xendomain())
 		return 0;
 
+	netif_init_accel();
+
 	IPRINTK("Initialising virtual ethernet driver.\n");
 
 	(void)register_inetaddr_notifier(&notifier_inetdev);
diff -r 82196b117a5b drivers/xen/netfront/netfront.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/xen/netfront/netfront.h	Wed Jun 20 17:01:07 2007 +0100
@@ -0,0 +1,287 @@
+/******************************************************************************
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
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
+#ifndef NETFRONT_H
+#define NETFRONT_H
+
+#include <xen/interface/io/netif.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/list.h>
+#include <linux/kref.h>
+
+#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
+#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
+
+#include <xen/xenbus.h>
+
+/* 
+ * Function pointer table for hooks into a network acceleration
+ * plugin.  These are called at appropriate points from the netfront
+ * driver 
+ */
+struct netfront_accel_hooks {
+	/* 
+	 * new_device: Accelerator hook to ask the plugin to support a
+	 * new network interface
+	 */
+	int (*new_device)(struct net_device *net_dev, struct xenbus_device *dev);
+	/*
+	 * suspend, resume, remove: Equivalent to the normal xenbus_*
+	 * callbacks 
+	 */
+	int (*suspend)(struct xenbus_device *dev);
+	int (*resume)(struct xenbus_device *dev);
+	int (*remove)(struct xenbus_device *dev);
+	/* 
+	 * backend_changed: Callback from watch based on backend's
+	 * xenbus state changing
+	 */
+	void (*backend_changed)(struct xenbus_device *dev,
+				enum xenbus_state backend_state);
+	/*
+	 * The net_device is being polled, check the accelerated
+	 * hardware for any pending packets
+	 */
+	int (*netdev_poll)(struct net_device *dev, int *pbudget);
+	/*
+	 * start_xmit: Used to give the accelerated plugin the option
+	 * of sending a packet.  Returns non-zero if has done so, or
+	 * zero to decline and force the packet onto normal send
+	 * path
+	 */
+	int (*start_xmit)(struct sk_buff *skb, struct net_device *dev);
+	/* 
+	 * start/stop_napi_interrupts Used by netfront to indicate
+	 * when napi interrupts should be enabled or disabled 
+	 */
+	int (*start_napi_irq)(struct net_device *dev);
+	void (*stop_napi_irq)(struct net_device *dev);
+	/* 
+	 * Called before re-enabling the TX queue to check the fast
+	 * path has slots too
+	 */
+	int (*check_busy)(struct net_device *dev);
+};
+
+/* 
+ * Per-netfront device state for the accelerator.  This is used to
+ * allow efficient per-netfront device access to the accelerator
+ * hooks 
+ */
+struct netfront_accel_vif_state {
+	struct list_head link;
+
+	struct xenbus_device *dev;
+	struct netfront_info *np;
+	struct netfront_accel_hooks *hooks;
+
+	/* 
+	 * Protect against removal of hooks while in use.  
+	 */
+	struct kref vif_kref;
+
+	unsigned ready_for_probe;
+	struct netfront_accel_hooks *need_probe;
+}; 
+
+/* 
+ * Per-accelerator state stored in netfront.  These form a list that
+ * is used to track which devices are accelerated by which plugins,
+ * and what plugins are available/have been requested 
+ */
+struct netfront_accelerator {
+	/* Used to make a list */
+	struct list_head link;
+	/* ID of the accelerator */
+	int id;
+	/*
+	 * String describing the accelerator.  Currently this is the
+	 * name of the accelerator module.  This is provided by the
+	 * backend accelerator through xenstore 
+	 */
+	char *frontend;
+	/* The hooks into the accelerator plugin module */
+	struct netfront_accel_hooks *hooks;
+	/* 
+	 * Protect against removal of hooks while in use.  
+	 */
+	struct kref accel_kref;
+	/* 
+	 * List of per-netfront device state (struct
+	 * netfront_accel_vif_state) for each netfront device that is
+	 * using this accelerator
+	 */
+	struct list_head vif_states;
+	spinlock_t vif_states_lock;
+	/* 
+	 * Semaphore to signal that all users of this accelerator have
+	 * finished using it before module is unloaded
+	 */
+	struct semaphore exit_semaphore; 
+
+	unsigned ready_for_probe;
+	struct netfront_accel_hooks *need_probe;
+};
+
+struct netfront_info {
+	struct list_head list;
+	struct net_device *netdev;
+
+	struct net_device_stats stats;
+
+	struct netif_tx_front_ring tx;
+	struct netif_rx_front_ring rx;
+
+	spinlock_t   tx_lock;
+	spinlock_t   rx_lock;
+
+	unsigned int irq;
+	unsigned int copying_receiver;
+	unsigned int carrier;
+
+	/* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	unsigned rx_min_target, rx_max_target, rx_target;
+	struct sk_buff_head rx_batch;
+
+	struct timer_list rx_refill_timer;
+
+	/*
+	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
+	 * is an index into a chain of free entries.
+	 */
+	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
+	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
+
+#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	grant_ref_t gref_tx_head;
+	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
+	grant_ref_t gref_rx_head;
+	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
+
+	struct xenbus_device *xbdev;
+	int tx_ring_ref;
+	int rx_ring_ref;
+	u8 mac[ETH_ALEN];
+
+	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
+	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
+	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+
+	/* Private pointer to state internal to accelerator module */
+	void *accel_priv;
+	/* The accelerator used by this netfront device */
+	struct netfront_accelerator *accelerator;
+	/* The accelerator state for this netfront device */
+	struct netfront_accel_vif_state accel_vif_state;
+};
+
+
+/* Exported Functions */
+
+/*
+ * Called by an accelerator plugin module when it has loaded.
+ *
+ * frontend: the string describing the accelerator, currently the module name 
+ * hooks: the hooks for netfront to use to call into the accelerator
+ */
+extern int netfront_accelerator_loaded(const char *frontend, 
+				       struct netfront_accel_hooks *hooks);
+
+/* 
+ * Called when an accelerator plugin is ready to accelerate a device *
+ * that has been passed to it from netfront using the "new_device"
+ * hook.
+ *
+ * frontend: the string describing the accelerator. Must match the
+ * one passed to netfront_accelerator_loaded()
+ * dev: the xenbus device the plugin was asked to accelerate
+ */
+extern void netfront_accelerator_ready(const char *frontend,
+				       struct xenbus_device *dev);
+
+/* 
+ * Called by an accelerator plugin module when it is about to unload.
+ *
+ * frontend: the string describing the accelerator.  Must match the
+ * one passed to netfront_accelerator_loaded()
+ */ 
+extern void netfront_accelerator_unloaded(const char *frontend);
+
+/* 
+ * Called by an accelerator before waking the net device's TX queue to
+ * ensure the slow path has available slots.  Returns true if OK to
+ * wake, false if still busy 
+ */
+extern int netfront_check_queue_busy(struct net_device *net_dev);
+
+
+
+/* Internal-to-netfront Functions */
+
+/* 
+ * Call into accelerator and check to see if it has tx space before we
+ * wake the net device's TX queue.  Returns true if OK to wake, false
+ * if still busy
+ */ 
+extern 
+int netfront_check_accelerator_queue_busy(struct net_device *dev,
+					  struct netfront_info *np);
+extern
+int netfront_accelerator_call_remove(struct netfront_info *np,
+				     struct xenbus_device *dev);
+extern
+int netfront_accelerator_call_resume(struct netfront_info *np,
+				     struct xenbus_device *dev);
+extern
+void netfront_accelerator_call_backend_changed(struct netfront_info *np,
+					       struct xenbus_device *dev,
+					       enum xenbus_state backend_state);
+extern
+void netfront_accelerator_call_stop_napi_irq(struct netfront_info *np,
+					     struct net_device *dev);
+
+extern
+int netfront_load_accelerator(struct netfront_info *np, 
+			      struct xenbus_device *dev, 
+			      const char *frontend);
+
+extern
+void netif_init_accel(void);
+
+extern
+void init_accelerator_vif(struct netfront_info *np,
+			  struct xenbus_device *dev);
+#endif /* NETFRONT_H */


--=-SxNQuJ+cDz4lxMBECvsD
Content-Disposition: attachment; filename=frontend_accel
Content-Type: text/plain; name=frontend_accel; charset=UTF-8
Content-Transfer-Encoding: 7bit

Frontend net driver acceleration

diff -r 82196b117a5b drivers/xen/netfront/Makefile
--- a/drivers/xen/netfront/Makefile	Wed Jun 20 17:01:02 2007 +0100
+++ b/drivers/xen/netfront/Makefile	Wed Jun 20 17:01:07 2007 +0100
@@ -1,4 +1,4 @@
 
 obj-$(CONFIG_XEN_NETDEV_FRONTEND)	:= xennet.o
 
-xennet-objs := netfront.o
+xennet-objs := netfront.o accel.o
diff -r 82196b117a5b drivers/xen/netfront/accel.c
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/xen/netfront/accel.c	Thu Jun 21 13:47:33 2007 +0100
@@ -0,0 +1,773 @@
+/******************************************************************************
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (C) 2007 Solarflare Communications, Inc.
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
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/list.h>
+#include <linux/kref.h>
+
+#include <xen/xenbus.h>
+
+#include "netfront.h"
+
+#define DPRINTK(fmt, args...)				\
+	pr_debug("netfront/accel (%s:%d) " fmt,		\
+		 __FUNCTION__, __LINE__, ##args)
+#define IPRINTK(fmt, args...)				\
+	printk(KERN_INFO "netfront/accel: " fmt, ##args)
+#define WPRINTK(fmt, args...)				\
+	printk(KERN_WARNING "netfront/accel: " fmt, ##args)
+
+/*
+ * List of all netfront accelerator plugin modules available.  Each
+ * list entry is of type struct netfront_accelerator.
+ */ 
+static struct list_head accelerators_list;
+
+/*
+ * Lock to protect access to accelerators_list
+ */
+static spinlock_t accelerators_lock;
+
+/* Forward declaration of kref cleanup functions */
+static void accel_kref_release(struct kref *ref);
+static void vif_kref_release(struct kref *ref);
+
+
+void netif_init_accel(void)
+{
+	INIT_LIST_HEAD(&accelerators_list);
+	spin_lock_init(&accelerators_lock);
+}
+
+
+/* 
+ * Initialise the accel_vif_state field in the netfront state
+ */ 
+void init_accelerator_vif(struct netfront_info *np,
+			  struct xenbus_device *dev)
+{
+	np->accelerator = NULL;
+
+	/* It's assumed that these things don't change */
+	np->accel_vif_state.np = np;
+	np->accel_vif_state.dev = dev;
+
+	np->accel_vif_state.ready_for_probe = 1;
+	np->accel_vif_state.need_probe = NULL;
+}
+
+
+/*
+ * Compare a frontend description string against an accelerator to see
+ * if they match.  Would ultimately be nice to replace the string with
+ * a unique numeric identifier for each accelerator.
+ */
+static int match_accelerator(const char *frontend, 
+			     struct netfront_accelerator *accelerator)
+{
+	return strcmp(frontend, accelerator->frontend) == 0;
+}
+
+
+/* 
+ * Add a frontend vif to the list of vifs that is using a netfront
+ * accelerator plugin module.
+ */
+static void add_accelerator_vif(struct netfront_accelerator *accelerator,
+				struct netfront_info *np)
+{
+	np->accelerator = accelerator;
+
+	list_add(&np->accel_vif_state.link, &accelerator->vif_states);
+}
+
+
+/*
+ * Initialise the state to track an accelerator plugin module.
+ */ 
+static int init_accelerator(const char *frontend, 
+			    struct netfront_accelerator **result)
+{
+	struct netfront_accelerator *accelerator = 
+		kmalloc(sizeof(struct netfront_accelerator), GFP_KERNEL);
+	int frontend_len;
+
+	if (!accelerator) {
+		DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+		return -ENOMEM;
+	}
+
+	frontend_len = strlen(frontend) + 1;
+	accelerator->frontend = kmalloc(frontend_len, GFP_KERNEL);
+	if (!accelerator->frontend) {
+		DPRINTK("%s: no memory for accelerator", __FUNCTION__);
+		kfree(accelerator);
+		return -ENOMEM;
+	}
+	strlcpy(accelerator->frontend, frontend, frontend_len);
+	
+	INIT_LIST_HEAD(&accelerator->vif_states);
+	spin_lock_init(&accelerator->vif_states_lock);
+
+	accelerator->hooks = NULL;
+
+	accelerator->ready_for_probe = 1;
+	accelerator->need_probe = NULL;
+
+	list_add(&accelerator->link, &accelerators_list);
+
+	*result = accelerator;
+
+	return 0;
+}					
+
+
+/* 
+ * Modify the hooks stored in the per-vif state to match that in the
+ * netfront accelerator's state.
+ */
+static void 
+accelerator_set_vif_state_hooks(struct netfront_accel_vif_state *vif_state)
+{
+	/* This function must be called with the vif_state_lock held */
+
+	/*
+	 * Take references to stop hooks disappearing.
+	 * This persists until vif_kref gets to zero.
+	 */
+	kref_get(&vif_state->np->accelerator->accel_kref);
+	/* This persists until vif_state->hooks are cleared */
+	kref_init(&vif_state->vif_kref);
+
+	/* Make sure there are no data path operations going on */
+	netif_poll_disable(vif_state->np->netdev);
+	netif_tx_lock_bh(vif_state->np->netdev);
+
+	vif_state->hooks = vif_state->np->accelerator->hooks;
+
+	netif_tx_unlock_bh(vif_state->np->netdev);
+	netif_poll_enable(vif_state->np->netdev);
+}
+
+
+static void accelerator_probe_new_vif(struct netfront_info *np,
+				      struct xenbus_device *dev, 
+				      struct netfront_accelerator *accelerator)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+	
+	DPRINTK("%s\n", __FUNCTION__);
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	
+	/*
+	 * Include this frontend device on the accelerator's list
+	 */
+	add_accelerator_vif(accelerator, np);
+	
+	hooks = accelerator->hooks;
+	
+	if (hooks) {
+		if (np->accel_vif_state.ready_for_probe) {
+			np->accel_vif_state.ready_for_probe = 0;
+			
+			kref_get(&accelerator->accel_kref);
+			
+			spin_unlock_irqrestore(&accelerator->vif_states_lock,
+					       flags);
+			
+			hooks->new_device(np->netdev, dev);
+			
+			kref_put(&accelerator->accel_kref,
+				 accel_kref_release);
+			/* 
+			 * Hooks will get linked into vif_state by a
+			 * future call by the accelerator to
+			 * netfront_accelerator_ready()
+			 */
+			return;
+		} else {
+			if (np->accel_vif_state.need_probe != NULL)
+				DPRINTK("Probe request on vif awaiting probe\n");
+			np->accel_vif_state.need_probe = hooks;
+		}
+	}
+		
+	spin_unlock_irqrestore(&accelerator->vif_states_lock,
+			       flags);
+	return;
+}
+
+/*  
+ * Request that a particular netfront accelerator plugin is loaded.
+ * Usually called as a result of the vif configuration specifying
+ * which one to use.
+ */
+int netfront_load_accelerator(struct netfront_info *np, 
+			      struct xenbus_device *dev, 
+			      const char *frontend)
+{
+	struct netfront_accelerator *accelerator;
+	int rc;
+	unsigned flags;
+
+	DPRINTK("%s: %s\n", __FUNCTION__, frontend);
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	/* 
+	 * Look at list of loaded accelerators to see if the requested
+	 * one is already there 
+	 */
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+
+			accelerator_probe_new_vif(np, dev, accelerator);
+
+			return 0;
+		}
+	}
+
+	/* Couldn't find it, so create a new one and load the module */
+	if ((rc = init_accelerator(frontend, &accelerator)) < 0) {
+		spin_unlock_irqrestore(&accelerators_lock, flags);
+		return rc;
+	}
+
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+
+	/* Include this frontend device on the accelerator's list */
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	add_accelerator_vif(accelerator, np);
+	spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+
+	DPRINTK("%s: loading module %s\n", __FUNCTION__, frontend);
+
+	/* load module */
+	request_module("%s", frontend);
+
+	/*
+	 * Module should now call netfront_accelerator_loaded() once
+	 * it's up and running, and we can continue from there 
+	 */
+
+	return 0;
+}
+
+
+/*
+ * Go through all the netfront vifs and see if they have requested
+ * this accelerator.  Notify the accelerator plugin of the relevant
+ * device if so.  Called when an accelerator plugin module is first
+ * loaded and connects to netfront.
+ */
+static void 
+accelerator_probe_vifs(struct netfront_accelerator *accelerator,
+		       struct netfront_accel_hooks *hooks,
+		       unsigned lock_flags)
+{
+	struct netfront_accel_vif_state *vif_state, *tmp;
+
+	/* Calling function must have taken the vif_states_lock */
+
+	DPRINTK("%s: %p\n", __FUNCTION__, accelerator);
+
+	/* 
+	 * kref_init() takes a single reference to the hooks that will
+	 * persist until the accelerator hooks are removed (e.g. by
+	 * accelerator module unload)
+	 */
+	kref_init(&accelerator->accel_kref);
+
+	/* 
+	 * Store the hooks for future calls to probe a new device, and
+	 * to wire into the vif_state once the accelerator plugin is
+	 * ready to accelerate each vif
+	 */
+	BUG_ON(hooks == NULL);
+	accelerator->hooks = hooks;
+	
+	list_for_each_entry_safe(vif_state, tmp, &accelerator->vif_states,
+				 link) {
+		struct netfront_info *np = vif_state->np;
+
+		if (vif_state->ready_for_probe) {
+			vif_state->ready_for_probe = 0;
+			kref_get(&accelerator->accel_kref);
+
+			/* 
+			 * drop lock before calling hook.  hooks are
+			 * protected by the kref
+			 */
+			spin_unlock_irqrestore(&accelerator->vif_states_lock,
+					       lock_flags);
+			
+			hooks->new_device(np->netdev, vif_state->dev);
+			
+			kref_put(&accelerator->accel_kref, accel_kref_release);
+
+			/* Retake lock for next go round the loop */
+			spin_lock_irqsave(&accelerator->vif_states_lock, lock_flags);
+			
+			/*
+			 * Hooks will get linked into vif_state by a call to
+			 * netfront_accelerator_ready() once accelerator
+			 * plugin is ready for action
+			 */
+		} else {
+			if (vif_state->need_probe != NULL)
+				DPRINTK("Probe request on vif awaiting probe\n");
+			vif_state->need_probe = hooks;
+		}
+	}
+	
+	/* Return with vif_states_lock held, as on entry */
+}
+
+
+/* 
+ * Wrapper for accelerator_probe_vifs that checks now is a good time
+ * to do the probe, and postpones till previous state cleared up if
+ * necessary
+ */
+static void 
+accelerator_probe_vifs_on_load(struct netfront_accelerator *accelerator,
+			       struct netfront_accel_hooks *hooks)
+{
+	unsigned flags;
+
+	DPRINTK("%s\n", __FUNCTION__);
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	
+	if (accelerator->ready_for_probe) {
+		accelerator->ready_for_probe = 0;
+		accelerator_probe_vifs(accelerator, hooks, flags);
+	} else {
+		if (accelerator->need_probe)
+			DPRINTK("Probe request on accelerator awaiting probe\n");
+		accelerator->need_probe = hooks;
+	}
+
+	spin_unlock_irqrestore(&accelerator->vif_states_lock,
+			       flags);
+}
+
+
+/* 
+ * Called by the netfront accelerator plugin module when it has loaded 
+ */
+int netfront_accelerator_loaded(const char *frontend, 
+				struct netfront_accel_hooks *hooks)
+{
+	struct netfront_accelerator *accelerator;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	/* 
+	 * Look through list of accelerators to see if it has already
+	 * been requested
+	 */
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+
+			accelerator_probe_vifs_on_load(accelerator, hooks);
+
+			return 0;
+		}
+	}
+
+	/*
+	 * If it wasn't in the list, add it now so that when it is
+	 * requested the caller will find it
+	 */
+	DPRINTK("%s: Couldn't find matching accelerator (%s)\n",
+		__FUNCTION__, frontend);
+
+	init_accelerator(frontend, &accelerator);
+
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_loaded);
+
+
+/* 
+ * Called by the accelerator module after it has been probed with a
+ * network device to say that it is ready to start accelerating
+ * traffic on that device
+ */
+void netfront_accelerator_ready(const char *frontend,
+				struct xenbus_device *dev)
+{
+	struct netfront_accelerator *accelerator;
+	struct netfront_accel_vif_state *accel_vif_state;
+	unsigned flags, flags1;
+
+	DPRINTK("%s: %s %p\n", __FUNCTION__, frontend, dev);
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_lock_irqsave
+				(&accelerator->vif_states_lock, flags1);
+
+			list_for_each_entry(accel_vif_state,
+					    &accelerator->vif_states, link) {
+				if (accel_vif_state->dev == dev)
+					accelerator_set_vif_state_hooks
+						(accel_vif_state);
+			}
+
+			spin_unlock_irqrestore
+				(&accelerator->vif_states_lock, flags1);
+			goto done;
+		}
+	}
+
+ done:
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_ready);
+
+
+/* 
+ * Safely remove the accelerator function hooks from a netfront state.
+ */
+static void accelerator_remove_hooks(struct netfront_accelerator *accelerator)
+{
+	struct netfront_accel_vif_state *vif_state, *tmp;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+
+	list_for_each_entry_safe(vif_state, tmp,
+				 &accelerator->vif_states,
+				 link) {
+		/* Make sure there are no data path operations going on */
+		netif_poll_disable(vif_state->np->netdev);
+		netif_tx_lock_bh(vif_state->np->netdev);
+
+		/* 
+		 * Remove the hooks, but leave the vif_state on the
+		 * accelerator's list as that signifies this vif is
+		 * interested in using that accelerator if it becomes
+		 * available again
+		 */
+		vif_state->hooks = NULL;
+		
+		netif_tx_unlock_bh(vif_state->np->netdev);
+		netif_poll_enable(vif_state->np->netdev);
+
+		/* 
+		 * Remove the reference taken when the vif_state hooks
+		 * were set, must be called without lock held
+		 */
+		spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+		kref_put(&vif_state->vif_kref, vif_kref_release);
+		spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	}
+	
+	accelerator->hooks = NULL;
+
+	spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+
+	/* Remove the reference taken when module loaded */ 
+	kref_put(&accelerator->accel_kref, accel_kref_release);
+}
+
+
+/* 
+ * Called by a netfront accelerator when it is unloaded.  This safely
+ * removes the hooks into the plugin and blocks until all devices have
+ * finished using it, so on return it is safe to unload.
+ */
+void netfront_accelerator_unloaded(const char *frontend)
+{
+	struct netfront_accelerator *accelerator;
+	unsigned flags;
+
+	spin_lock_irqsave(&accelerators_lock, flags);
+
+	list_for_each_entry(accelerator, &accelerators_list, link) {
+		if (match_accelerator(frontend, accelerator)) {
+			spin_unlock_irqrestore(&accelerators_lock, flags);
+
+			/* 
+			 * Use semaphore to ensure we know when all
+			 * uses of hooks are complete
+			 */
+			sema_init(&accelerator->exit_semaphore, 0);
+
+			accelerator_remove_hooks(accelerator);
+
+			/* Wait for hooks to be unused, then return */
+			down(&accelerator->exit_semaphore);
+			
+			return;
+		}
+	}
+	spin_unlock_irqrestore(&accelerators_lock, flags);
+}
+EXPORT_SYMBOL_GPL(netfront_accelerator_unloaded);
+
+
+int netfront_check_accelerator_queue_busy(struct net_device *dev,
+					  struct netfront_info *np)
+{
+	struct netfront_accel_hooks *hooks;
+	int rc = 1;
+	unsigned flags;
+
+	/*
+	 * Call the check busy accelerator hook. The use count for the
+	 * accelerator's hooks is incremented for the duration of the
+	 * call to prevent the accelerator being able to modify the
+	 * hooks in the middle (by, for example, unloading)
+	 */ 
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			rc = np->accel_vif_state.hooks->check_busy(dev);
+			
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+
+	return rc;
+}
+
+
+int netfront_accelerator_call_remove(struct netfront_info *np,
+				     struct xenbus_device *dev)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+	int rc = 0;
+
+	/* 
+	 * Call the remove accelerator hook. The use count for the
+	 * accelerator's hooks is incremented for the duration of the
+	 * call to prevent the accelerator being able to modify the
+	 * hooks in the middle (by, for example, unloading)
+	 */ 
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			rc = np->accel_vif_state.hooks->remove(dev);
+
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+	return rc;
+}
+
+
+int netfront_accelerator_call_resume(struct netfront_info *np,
+				     struct xenbus_device *dev)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+	int rc = 0;
+
+	/* 
+	 *  Call the resume accelerator hook.  The use count for the
+	 *  accelerator's hooks is incremented for the duration of
+	 *  the call to prevent the accelerator being able to modify
+	 *  the hooks in the middle (by, for example, unloading)
+	 */
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			rc = np->accel_vif_state.hooks->resume(dev);
+
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+	return rc;
+}
+
+
+void netfront_accelerator_call_backend_changed(struct netfront_info *np,
+					       struct xenbus_device *dev,
+					       enum xenbus_state backend_state)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* 
+	 * Call the backend_changed accelerator hook. The use count
+	 * for the accelerator's hooks is incremented for the duration
+	 * of the call to prevent the accelerator being able to modify
+	 * the hooks in the middle (by, for example, unloading)
+	 */
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			np->accel_vif_state.hooks->backend_changed
+				(dev, backend_state);
+
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+}
+
+
+void netfront_accelerator_call_stop_napi_irq(struct netfront_info *np,
+					     struct net_device *dev)
+{
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* 
+	 * Call the stop_napi_interrupts accelerator hook.  The use
+	 * count for the accelerator's hooks is incremented for the
+	 * duration of the call to prevent the accelerator being able
+	 * to modify the hooks in the middle (by, for example,
+	 * unloading)
+	 */
+
+	if (np->accel_vif_state.hooks) {
+		spin_lock_irqsave(&np->accelerator->vif_states_lock, flags); 
+		hooks = np->accel_vif_state.hooks;
+		if (hooks) {
+			kref_get(&np->accel_vif_state.vif_kref);
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+
+			np->accel_vif_state.hooks->stop_napi_irq(dev);
+		
+			kref_put(&np->accel_vif_state.vif_kref,
+				 vif_kref_release);
+		} else {
+			spin_unlock_irqrestore
+				(&np->accelerator->vif_states_lock, flags);
+		}
+	}
+}
+
+
+/* 
+ * Once all users of hooks have kref_put()'d we can signal that it's
+ * safe to unload
+ */ 
+static void accel_kref_release(struct kref *ref)
+{
+	struct netfront_accelerator *accelerator =
+		container_of(ref, struct netfront_accelerator, accel_kref);
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* Signal that all users of hooks are done */
+	up(&accelerator->exit_semaphore);
+
+	spin_lock_irqsave(&accelerator->vif_states_lock, flags);
+	if (accelerator->need_probe) {
+		hooks = accelerator->need_probe;
+		accelerator->need_probe = NULL;
+		accelerator_probe_vifs(accelerator, hooks, flags);
+	} 
+	else
+		accelerator->ready_for_probe = 1;
+
+	spin_unlock_irqrestore(&accelerator->vif_states_lock, flags);
+}
+
+
+static void vif_kref_release(struct kref *ref)
+{
+	struct netfront_accel_vif_state *vif_state = 
+		container_of(ref, struct netfront_accel_vif_state, vif_kref);
+	struct netfront_accel_hooks *hooks;
+	unsigned flags;
+
+	/* 
+	 * Now that this vif has finished using the hooks, it can
+	 * decrement the accelerator's global copy ref count 
+	 */
+	kref_put(&vif_state->np->accelerator->accel_kref, accel_kref_release);
+
+	spin_lock_irqsave(&vif_state->np->accelerator->vif_states_lock, flags);
+	if (vif_state->need_probe) {
+		hooks = vif_state->need_probe;
+		vif_state->need_probe = NULL;
+		spin_unlock_irqrestore
+			(&vif_state->np->accelerator->vif_states_lock, flags);
+		hooks->new_device(vif_state->np->netdev, vif_state->dev);
+	} else {
+		vif_state->ready_for_probe = 1;
+		spin_unlock_irqrestore
+			(&vif_state->np->accelerator->vif_states_lock, flags);
+	}
+}
+
diff -r 82196b117a5b drivers/xen/netfront/netfront.c
--- a/drivers/xen/netfront/netfront.c	Wed Jun 20 17:01:02 2007 +0100
+++ b/drivers/xen/netfront/netfront.c	Wed Jun 20 17:01:07 2007 +0100
@@ -3,6 +3,7 @@
  *
  * Copyright (c) 2002-2005, K A Fraser
  * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License version 2
@@ -74,6 +75,8 @@ struct netfront_cb {
 
 #define NETFRONT_SKB_CB(skb)	((struct netfront_cb *)((skb)->cb))
 
+#include "netfront.h"
+
 /*
  * Mutually-exclusive module options to select receive data path:
  *  rx_copy : Packets are copied by network backend into local memory
@@ -144,57 +147,6 @@ static inline int netif_needs_gso(struct
 
 #define GRANT_INVALID_REF	0
 
-#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
-#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
-
-struct netfront_info {
-	struct list_head list;
-	struct net_device *netdev;
-
-	struct net_device_stats stats;
-
-	struct netif_tx_front_ring tx;
-	struct netif_rx_front_ring rx;
-
-	spinlock_t   tx_lock;
-	spinlock_t   rx_lock;
-
-	unsigned int irq;
-	unsigned int copying_receiver;
-	unsigned int carrier;
-
-	/* Receive-ring batched refills. */
-#define RX_MIN_TARGET 8
-#define RX_DFL_MIN_TARGET 64
-#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	unsigned rx_min_target, rx_max_target, rx_target;
-	struct sk_buff_head rx_batch;
-
-	struct timer_list rx_refill_timer;
-
-	/*
-	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
-	 * is an index into a chain of free entries.
-	 */
-	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
-	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
-
-#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
-	grant_ref_t gref_tx_head;
-	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
-	grant_ref_t gref_rx_head;
-	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
-
-	struct xenbus_device *xbdev;
-	int tx_ring_ref;
-	int rx_ring_ref;
-	u8 mac[ETH_ALEN];
-
-	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
-	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
-	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
-};
-
 struct netfront_rx_info {
 	struct netif_rx_response rx;
 	struct netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
@@ -334,6 +286,8 @@ static int __devexit netfront_remove(str
 
 	DPRINTK("%s\n", dev->nodename);
 
+	netfront_accelerator_call_remove(info, dev);
+
 	netif_disconnect_backend(info);
 
 	del_timer_sync(&info->rx_refill_timer);
@@ -358,6 +312,8 @@ static int netfront_resume(struct xenbus
 	struct netfront_info *info = dev->dev.driver_data;
 
 	DPRINTK("%s\n", dev->nodename);
+
+	netfront_accelerator_call_resume(info, dev);
 
 	netif_disconnect_backend(info);
 	return 0;
@@ -577,6 +533,8 @@ static void backend_changed(struct xenbu
 		xenbus_frontend_closed(dev);
 		break;
 	}
+
+	netfront_accelerator_call_backend_changed(np, dev, backend_state);
 }
 
 /** Send a packet on a net device to encourage switches to learn the
@@ -613,15 +571,29 @@ static inline int netfront_tx_slot_avail
 		(TX_MAX_TARGET - MAX_SKB_FRAGS - 2));
 }
 
+
 static inline void network_maybe_wake_tx(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
 
 	if (unlikely(netif_queue_stopped(dev)) &&
 	    netfront_tx_slot_available(np) &&
-	    likely(netif_running(dev)))
+	    likely(netif_running(dev)) &&
+	    netfront_check_accelerator_queue_busy(dev, np))
 		netif_wake_queue(dev);
 }
+
+
+int netfront_check_queue_busy(struct net_device *dev)
+{
+	struct netfront_info *np = netdev_priv(dev);
+
+	return unlikely(netif_queue_stopped(dev)) &&
+		netfront_tx_slot_available(np) &&
+		likely(netif_running(dev));
+}
+EXPORT_SYMBOL(netfront_check_queue_busy);
+
 
 static int network_open(struct net_device *dev)
 {
@@ -633,8 +605,11 @@ static int network_open(struct net_devic
 	if (netfront_carrier_ok(np)) {
 		network_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)){
+			netfront_accelerator_call_stop_napi_irq(np, dev);
+
 			netif_rx_schedule(dev);
+		}
 	}
 	spin_unlock_bh(&np->rx_lock);
 
@@ -702,6 +677,10 @@ static void rx_refill_timeout(unsigned l
 static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
+	struct netfront_info *np = netdev_priv(dev);
+
+	netfront_accelerator_call_stop_napi_irq(np, dev);
+
 	netif_rx_schedule(dev);
 }
 
@@ -941,6 +920,13 @@ static int network_start_xmit(struct sk_
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 
+	/* Check the fast path, if hooks are available */
+	if (np->accel_vif_state.hooks &&
+	    np->accel_vif_state.hooks->start_xmit(skb, dev)) {
+		/* Fast path has sent this packet */
+		return 0;
+	}
+
 	frags += (offset + len + PAGE_SIZE - 1) / PAGE_SIZE;
 	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
 		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
@@ -1044,8 +1030,11 @@ static irqreturn_t netif_int(int irq, vo
 	if (likely(netfront_carrier_ok(np))) {
 		network_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx)) {
+			netfront_accelerator_call_stop_napi_irq(np, dev);
+
 			netif_rx_schedule(dev);
+		}
 	}
 
 	spin_unlock_irqrestore(&np->tx_lock, flags);
@@ -1305,7 +1294,7 @@ static int netif_poll(struct net_device 
 	struct netif_extra_info *extras = rinfo.extras;
 	RING_IDX i, rp;
 	struct multicall_entry *mcl;
-	int work_done, budget, more_to_do = 1;
+	int work_done, budget, more_to_do = 1, accel_more_to_do = 1;
 	struct sk_buff_head rxq;
 	struct sk_buff_head errq;
 	struct sk_buff_head tmpq;
@@ -1472,6 +1461,20 @@ err:
 
 	network_alloc_rx_buffers(dev);
 
+	if (work_done < budget) {
+		/* there's some spare capacity, try the accelerated path */
+		int accel_budget = budget - work_done;
+		int accel_budget_start = accel_budget;
+
+		if (np->accel_vif_state.hooks) {
+			accel_more_to_do = 
+				np->accel_vif_state.hooks->netdev_poll
+				(dev, &accel_budget);
+			work_done += (accel_budget_start - accel_budget);
+		} else 
+			accel_more_to_do = 0;
+	}
+
 	*pbudget   -= work_done;
 	dev->quota -= work_done;
 
@@ -1479,15 +1482,26 @@ err:
 		local_irq_save(flags);
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
-		if (!more_to_do)
+
+		if (!more_to_do && !accel_more_to_do && 
+		    np->accel_vif_state.hooks) {
+			/* 
+			 *  Slow path has nothing more to do, see if
+			 *  fast path is likewise
+			 */
+			accel_more_to_do = 
+				np->accel_vif_state.hooks->start_napi_irq(dev);
+		}
+
+		if (!more_to_do && !accel_more_to_do)
 			__netif_rx_complete(dev);
 
 		local_irq_restore(flags);
 	}
 
 	spin_unlock(&np->rx_lock);
-
-	return more_to_do;
+	
+	return more_to_do | accel_more_to_do;
 }
 
 static void netif_release_tx_bufs(struct netfront_info *np)
@@ -1687,7 +1701,9 @@ static int network_connect(struct net_de
 	struct sk_buff *skb;
 	grant_ref_t ref;
 	netif_rx_request_t *req;
-	unsigned int feature_rx_copy, feature_rx_flip;
+	unsigned int feature_rx_copy, feature_rx_flip, feature_accel;
+	char *accel_frontend;
+	int accel_len;
 
 	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
 			   "feature-rx-copy", "%u", &feature_rx_copy);
@@ -1698,6 +1714,12 @@ static int network_connect(struct net_de
 	if (err != 1)
 		feature_rx_flip = 1;
 
+	feature_accel = 1;
+	accel_frontend = xenbus_read(XBT_NIL, np->xbdev->otherend, 
+				     "accel", &accel_len);
+	if (IS_ERR(accel_frontend)) 
+		feature_accel = 0;
+
 	/*
 	 * Copy packets on receive path if:
 	 *  (a) This was requested by user, and the backend supports it; or
@@ -1709,6 +1731,11 @@ static int network_connect(struct net_de
 	err = talk_to_backend(np->xbdev, np);
 	if (err)
 		return err;
+
+	if (feature_accel) {
+		netfront_load_accelerator(np, np->xbdev, accel_frontend);
+		kfree(accel_frontend);
+	}
 
 	xennet_set_features(dev);
 
@@ -1956,6 +1983,8 @@ static struct net_device * __devinit cre
 	spin_lock_init(&np->tx_lock);
 	spin_lock_init(&np->rx_lock);
 
+	init_accelerator_vif(np, dev);
+
 	skb_queue_head_init(&np->rx_batch);
 	np->rx_target     = RX_DFL_MIN_TARGET;
 	np->rx_min_target = RX_DFL_MIN_TARGET;
@@ -2110,6 +2139,8 @@ static int __init netif_init(void)
 	if (is_initial_xendomain())
 		return 0;
 
+	netif_init_accel();
+
 	IPRINTK("Initialising virtual ethernet driver.\n");
 
 	(void)register_inetaddr_notifier(&notifier_inetdev);
diff -r 82196b117a5b drivers/xen/netfront/netfront.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/drivers/xen/netfront/netfront.h	Wed Jun 20 17:01:07 2007 +0100
@@ -0,0 +1,287 @@
+/******************************************************************************
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ * Copyright (c) 2005, XenSource Ltd
+ * Copyright (C) 2007 Solarflare Communications, Inc.
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
+#ifndef NETFRONT_H
+#define NETFRONT_H
+
+#include <xen/interface/io/netif.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/list.h>
+#include <linux/kref.h>
+
+#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
+#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
+
+#include <xen/xenbus.h>
+
+/* 
+ * Function pointer table for hooks into a network acceleration
+ * plugin.  These are called at appropriate points from the netfront
+ * driver 
+ */
+struct netfront_accel_hooks {
+	/* 
+	 * new_device: Accelerator hook to ask the plugin to support a
+	 * new network interface
+	 */
+	int (*new_device)(struct net_device *net_dev, struct xenbus_device *dev);
+	/*
+	 * suspend, resume, remove: Equivalent to the normal xenbus_*
+	 * callbacks 
+	 */
+	int (*suspend)(struct xenbus_device *dev);
+	int (*resume)(struct xenbus_device *dev);
+	int (*remove)(struct xenbus_device *dev);
+	/* 
+	 * backend_changed: Callback from watch based on backend's
+	 * xenbus state changing
+	 */
+	void (*backend_changed)(struct xenbus_device *dev,
+				enum xenbus_state backend_state);
+	/*
+	 * The net_device is being polled, check the accelerated
+	 * hardware for any pending packets
+	 */
+	int (*netdev_poll)(struct net_device *dev, int *pbudget);
+	/*
+	 * start_xmit: Used to give the accelerated plugin the option
+	 * of sending a packet.  Returns non-zero if has done so, or
+	 * zero to decline and force the packet onto normal send
+	 * path
+	 */
+	int (*start_xmit)(struct sk_buff *skb, struct net_device *dev);
+	/* 
+	 * start/stop_napi_interrupts Used by netfront to indicate
+	 * when napi interrupts should be enabled or disabled 
+	 */
+	int (*start_napi_irq)(struct net_device *dev);
+	void (*stop_napi_irq)(struct net_device *dev);
+	/* 
+	 * Called before re-enabling the TX queue to check the fast
+	 * path has slots too
+	 */
+	int (*check_busy)(struct net_device *dev);
+};
+
+/* 
+ * Per-netfront device state for the accelerator.  This is used to
+ * allow efficient per-netfront device access to the accelerator
+ * hooks 
+ */
+struct netfront_accel_vif_state {
+	struct list_head link;
+
+	struct xenbus_device *dev;
+	struct netfront_info *np;
+	struct netfront_accel_hooks *hooks;
+
+	/* 
+	 * Protect against removal of hooks while in use.  
+	 */
+	struct kref vif_kref;
+
+	unsigned ready_for_probe;
+	struct netfront_accel_hooks *need_probe;
+}; 
+
+/* 
+ * Per-accelerator state stored in netfront.  These form a list that
+ * is used to track which devices are accelerated by which plugins,
+ * and what plugins are available/have been requested 
+ */
+struct netfront_accelerator {
+	/* Used to make a list */
+	struct list_head link;
+	/* ID of the accelerator */
+	int id;
+	/*
+	 * String describing the accelerator.  Currently this is the
+	 * name of the accelerator module.  This is provided by the
+	 * backend accelerator through xenstore 
+	 */
+	char *frontend;
+	/* The hooks into the accelerator plugin module */
+	struct netfront_accel_hooks *hooks;
+	/* 
+	 * Protect against removal of hooks while in use.  
+	 */
+	struct kref accel_kref;
+	/* 
+	 * List of per-netfront device state (struct
+	 * netfront_accel_vif_state) for each netfront device that is
+	 * using this accelerator
+	 */
+	struct list_head vif_states;
+	spinlock_t vif_states_lock;
+	/* 
+	 * Semaphore to signal that all users of this accelerator have
+	 * finished using it before module is unloaded
+	 */
+	struct semaphore exit_semaphore; 
+
+	unsigned ready_for_probe;
+	struct netfront_accel_hooks *need_probe;
+};
+
+struct netfront_info {
+	struct list_head list;
+	struct net_device *netdev;
+
+	struct net_device_stats stats;
+
+	struct netif_tx_front_ring tx;
+	struct netif_rx_front_ring rx;
+
+	spinlock_t   tx_lock;
+	spinlock_t   rx_lock;
+
+	unsigned int irq;
+	unsigned int copying_receiver;
+	unsigned int carrier;
+
+	/* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	unsigned rx_min_target, rx_max_target, rx_target;
+	struct sk_buff_head rx_batch;
+
+	struct timer_list rx_refill_timer;
+
+	/*
+	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
+	 * is an index into a chain of free entries.
+	 */
+	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
+	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
+
+#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	grant_ref_t gref_tx_head;
+	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
+	grant_ref_t gref_rx_head;
+	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
+
+	struct xenbus_device *xbdev;
+	int tx_ring_ref;
+	int rx_ring_ref;
+	u8 mac[ETH_ALEN];
+
+	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
+	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
+	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+
+	/* Private pointer to state internal to accelerator module */
+	void *accel_priv;
+	/* The accelerator used by this netfront device */
+	struct netfront_accelerator *accelerator;
+	/* The accelerator state for this netfront device */
+	struct netfront_accel_vif_state accel_vif_state;
+};
+
+
+/* Exported Functions */
+
+/*
+ * Called by an accelerator plugin module when it has loaded.
+ *
+ * frontend: the string describing the accelerator, currently the module name 
+ * hooks: the hooks for netfront to use to call into the accelerator
+ */
+extern int netfront_accelerator_loaded(const char *frontend, 
+				       struct netfront_accel_hooks *hooks);
+
+/* 
+ * Called when an accelerator plugin is ready to accelerate a device *
+ * that has been passed to it from netfront using the "new_device"
+ * hook.
+ *
+ * frontend: the string describing the accelerator. Must match the
+ * one passed to netfront_accelerator_loaded()
+ * dev: the xenbus device the plugin was asked to accelerate
+ */
+extern void netfront_accelerator_ready(const char *frontend,
+				       struct xenbus_device *dev);
+
+/* 
+ * Called by an accelerator plugin module when it is about to unload.
+ *
+ * frontend: the string describing the accelerator.  Must match the
+ * one passed to netfront_accelerator_loaded()
+ */ 
+extern void netfront_accelerator_unloaded(const char *frontend);
+
+/* 
+ * Called by an accelerator before waking the net device's TX queue to
+ * ensure the slow path has available slots.  Returns true if OK to
+ * wake, false if still busy 
+ */
+extern int netfront_check_queue_busy(struct net_device *net_dev);
+
+
+
+/* Internal-to-netfront Functions */
+
+/* 
+ * Call into accelerator and check to see if it has tx space before we
+ * wake the net device's TX queue.  Returns true if OK to wake, false
+ * if still busy
+ */ 
+extern 
+int netfront_check_accelerator_queue_busy(struct net_device *dev,
+					  struct netfront_info *np);
+extern
+int netfront_accelerator_call_remove(struct netfront_info *np,
+				     struct xenbus_device *dev);
+extern
+int netfront_accelerator_call_resume(struct netfront_info *np,
+				     struct xenbus_device *dev);
+extern
+void netfront_accelerator_call_backend_changed(struct netfront_info *np,
+					       struct xenbus_device *dev,
+					       enum xenbus_state backend_state);
+extern
+void netfront_accelerator_call_stop_napi_irq(struct netfront_info *np,
+					     struct net_device *dev);
+
+extern
+int netfront_load_accelerator(struct netfront_info *np, 
+			      struct xenbus_device *dev, 
+			      const char *frontend);
+
+extern
+void netif_init_accel(void);
+
+extern
+void init_accelerator_vif(struct netfront_info *np,
+			  struct xenbus_device *dev);
+#endif /* NETFRONT_H */

--=-SxNQuJ+cDz4lxMBECvsD--

