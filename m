From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 04/19] vbus: add bus-registration notifiers
Date: Thu, 09 Apr 2009 12:31:02 -0400
Message-ID: <20090409163102.32740.76404.stgit@dev.haskins.net>
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
Received: from victor.provo.novell.com ([137.65.250.26]:42434 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934675AbZDIQ2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 12:28:54 -0400
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to get hotswap events in environments which cannot use existing
facilities (e.g. inotify).  So we add a notifier-chain to allow client
callbacks whenever an interface is {un}registered.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 include/linux/vbus.h |   15 +++++++++++++
 kernel/vbus/core.c   |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/vbus/vbus.h   |    1 +
 3 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/include/linux/vbus.h b/include/linux/vbus.h
index 5f0566c..04db4ff 100644
--- a/include/linux/vbus.h
+++ b/include/linux/vbus.h
@@ -29,6 +29,7 @@
 #include <linux/sched.h>
 #include <linux/rcupdate.h>
 #include <linux/vbus_device.h>
+#include <linux/notifier.h>
 
 struct vbus;
 struct task_struct;
@@ -137,6 +138,20 @@ static inline void task_vbus_disassociate(struct task_struct *p)
 	}
 }
 
+enum {
+	VBUS_EVENT_DEVADD,
+	VBUS_EVENT_DEVDROP,
+};
+
+struct vbus_event_devadd {
+	const char   *type;
+	unsigned long id;
+};
+
+int vbus_notifier_register(struct vbus *vbus, struct notifier_block *nb);
+int vbus_notifier_unregister(struct vbus *vbus, struct notifier_block *nb);
+
+
 #else /* CONFIG_VBUS */
 
 #define fork_vbus(p) do { } while (0)
diff --git a/kernel/vbus/core.c b/kernel/vbus/core.c
index 033999f..b6df487 100644
--- a/kernel/vbus/core.c
+++ b/kernel/vbus/core.c
@@ -89,6 +89,7 @@ int vbus_device_interface_register(struct vbus_device *dev,
 {
 	int ret;
 	struct vbus_devshell *ds = to_devshell(dev->kobj);
+	struct vbus_event_devadd ev;
 
 	mutex_lock(&vbus->lock);
 
@@ -124,6 +125,14 @@ int vbus_device_interface_register(struct vbus_device *dev,
 	if (ret)
 		goto error;
 
+	ev.type = intf->type;
+	ev.id   = intf->id;
+
+	/* and let any clients know about the new device */
+	ret = raw_notifier_call_chain(&vbus->notifier, VBUS_EVENT_DEVADD, &ev);
+	if (ret < 0)
+		goto error;
+
 	mutex_unlock(&vbus->lock);
 
 	return 0;
@@ -144,6 +153,7 @@ int vbus_device_interface_unregister(struct vbus_device_interface *intf)
 
 	mutex_lock(&vbus->lock);
 	_interface_unregister(intf);
+	raw_notifier_call_chain(&vbus->notifier, VBUS_EVENT_DEVDROP, &intf->id);
 	mutex_unlock(&vbus->lock);
 
 	kobject_put(&intf->kobj);
@@ -346,6 +356,8 @@ int vbus_create(const char *name, struct vbus **bus)
 
 	_bus->next_id = 0;
 
+	RAW_INIT_NOTIFIER_HEAD(&_bus->notifier);
+
 	mutex_lock(&vbus_root.lock);
 
 	ret = map_add(&vbus_root.buses.map, &_bus->node);
@@ -358,6 +370,53 @@ int vbus_create(const char *name, struct vbus **bus)
 	return 0;
 }
 
+#define for_each_rbnode(node, root) \
+	for (node = rb_first(root); node != NULL; node = rb_next(node))
+
+int vbus_notifier_register(struct vbus *vbus, struct notifier_block *nb)
+{
+	int ret;
+	struct rb_node *node;
+
+	mutex_lock(&vbus->lock);
+
+	/*
+	 * resync the client for any devices we might already have
+	 */
+	for_each_rbnode(node, &vbus->devices.map.root) {
+		struct vbus_device_interface *intf = node_to_intf(node);
+		struct vbus_event_devadd ev = {
+			.type = intf->type,
+			.id   = intf->id,
+		};
+
+		ret = nb->notifier_call(nb, VBUS_EVENT_DEVADD, &ev);
+		if (ret & NOTIFY_STOP_MASK) {
+			mutex_unlock(&vbus->lock);
+			return -EPERM;
+		}
+	}
+
+	ret = raw_notifier_chain_register(&vbus->notifier, nb);
+
+	mutex_unlock(&vbus->lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(vbus_notifier_register);
+
+int vbus_notifier_unregister(struct vbus *vbus, struct notifier_block *nb)
+{
+	int ret;
+
+	mutex_lock(&vbus->lock);
+	ret = raw_notifier_chain_unregister(&vbus->notifier, nb);
+	mutex_unlock(&vbus->lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(vbus_notifier_unregister);
+
 static void devshell_release(struct kobject *kobj)
 {
 	struct vbus_devshell *ds = container_of(kobj,
diff --git a/kernel/vbus/vbus.h b/kernel/vbus/vbus.h
index 1266d69..cd2676b 100644
--- a/kernel/vbus/vbus.h
+++ b/kernel/vbus/vbus.h
@@ -51,6 +51,7 @@ struct vbus {
 	struct vbus_subdir members;
 	unsigned long next_id;
 	struct rb_node node;
+	struct raw_notifier_head notifier;
 };
 
 struct vbus_member {

