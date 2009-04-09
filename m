From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 07/19] ioq: add vbus helpers
Date: Thu, 09 Apr 2009 12:31:18 -0400
Message-ID: <20090409163118.32740.85447.stgit@dev.haskins.net>
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
Received: from victor.provo.novell.com ([137.65.250.26]:40439 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933803AbZDIQ3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 12:29:10 -0400
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be common to map an IOQ over the VBUS shared-memory interfaces,
so lets generalize their setup so we can reuse the pattern.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 include/linux/vbus_device.h |    7 +++
 include/linux/vbus_driver.h |    7 +++
 kernel/vbus/Kconfig         |    2 +
 kernel/vbus/Makefile        |    1 
 kernel/vbus/proxy.c         |   64 +++++++++++++++++++++++++++++++
 kernel/vbus/shm-ioq.c       |   89 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 170 insertions(+), 0 deletions(-)
 create mode 100644 kernel/vbus/shm-ioq.c

diff --git a/include/linux/vbus_device.h b/include/linux/vbus_device.h
index f73cd86..c91bce4 100644
--- a/include/linux/vbus_device.h
+++ b/include/linux/vbus_device.h
@@ -102,6 +102,7 @@
 #include <linux/configfs.h>
 #include <linux/rbtree.h>
 #include <linux/shm_signal.h>
+#include <linux/ioq.h>
 #include <linux/vbus.h>
 #include <asm/atomic.h>
 
@@ -414,4 +415,10 @@ static inline void vbus_connection_put(struct vbus_connection *conn)
 		conn->ops->release(conn);
 }
 
+/*
+ * device-side IOQ helper - dereferences device-shm as an IOQ
+ */
+int vbus_shm_ioq_attach(struct vbus_shm *shm, struct shm_signal *signal,
+			int maxcount, struct ioq **ioq);
+
 #endif /* _LINUX_VBUS_DEVICE_H */
diff --git a/include/linux/vbus_driver.h b/include/linux/vbus_driver.h
index c53e13f..9cfbf60 100644
--- a/include/linux/vbus_driver.h
+++ b/include/linux/vbus_driver.h
@@ -26,6 +26,7 @@
 
 #include <linux/device.h>
 #include <linux/shm_signal.h>
+#include <linux/ioq.h>
 
 struct vbus_device_proxy;
 struct vbus_driver;
@@ -70,4 +71,10 @@ struct vbus_driver {
 int vbus_driver_register(struct vbus_driver *drv);
 void vbus_driver_unregister(struct vbus_driver *drv);
 
+/*
+ * driver-side IOQ helper - allocates device-shm and maps an IOQ on it
+ */
+int vbus_driver_ioq_alloc(struct vbus_device_proxy *dev, int id, int prio,
+			  size_t ringsize, struct ioq **ioq);
+
 #endif /* _LINUX_VBUS_DRIVER_H */
diff --git a/kernel/vbus/Kconfig b/kernel/vbus/Kconfig
index 3aaa085..71acd6f 100644
--- a/kernel/vbus/Kconfig
+++ b/kernel/vbus/Kconfig
@@ -6,6 +6,7 @@ config VBUS
        bool "Virtual Bus"
        select CONFIGFS_FS
        select SHM_SIGNAL
+       select IOQ
        default n
        help
         Provides a mechansism for declaring virtual-bus objects and binding
@@ -15,6 +16,7 @@ config VBUS
 
 config VBUS_DRIVERS
        tristate "VBUS Driver support"
+       select IOQ
        default n
        help
         Adds support for a virtual bus model for proxying drivers.
diff --git a/kernel/vbus/Makefile b/kernel/vbus/Makefile
index d028ece..45f6503 100644
--- a/kernel/vbus/Makefile
+++ b/kernel/vbus/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_VBUS) += core.o devclass.o config.o attribute.o map.o client.o
+obj-$(CONFIG_VBUS) += shm-ioq.o
 
 vbus-proxy-objs += proxy.o
 obj-$(CONFIG_VBUS_DRIVERS) += vbus-proxy.o
diff --git a/kernel/vbus/proxy.c b/kernel/vbus/proxy.c
index ea48f00..75b0cb1 100644
--- a/kernel/vbus/proxy.c
+++ b/kernel/vbus/proxy.c
@@ -150,3 +150,67 @@ void vbus_driver_unregister(struct vbus_driver *drv)
 }
 EXPORT_SYMBOL_GPL(vbus_driver_unregister);
 
+/*
+ *---------------------------------
+ * driver-side IOQ helper
+ *---------------------------------
+ */
+static void
+vbus_driver_ioq_release(struct ioq *ioq)
+{
+	kfree(ioq->head_desc);
+	kfree(ioq);
+}
+
+static struct ioq_ops vbus_driver_ioq_ops = {
+	.release = vbus_driver_ioq_release,
+};
+
+
+int vbus_driver_ioq_alloc(struct vbus_device_proxy *dev, int id, int prio,
+			  size_t count, struct ioq **ioq)
+{
+	struct ioq           *_ioq;
+	struct ioq_ring_head *head = NULL;
+	struct shm_signal    *signal = NULL;
+	size_t                len = IOQ_HEAD_DESC_SIZE(count);
+	int                   ret = -ENOMEM;
+
+	_ioq = kzalloc(sizeof(*_ioq), GFP_KERNEL);
+	if (!_ioq)
+		goto error;
+
+	head = kzalloc(len, GFP_KERNEL | GFP_DMA);
+	if (!head)
+		goto error;
+
+	head->magic     = IOQ_RING_MAGIC;
+	head->ver	= IOQ_RING_VER;
+	head->count     = count;
+
+	ret = dev->ops->shm(dev, id, prio, head, len,
+			    &head->signal, &signal, 0);
+	if (ret < 0)
+		goto error;
+
+	ioq_init(_ioq,
+		 &vbus_driver_ioq_ops,
+		 ioq_locality_north,
+		 head,
+		 signal,
+		 count);
+
+	*ioq = _ioq;
+
+	return 0;
+
+ error:
+	kfree(_ioq);
+	kfree(head);
+
+	if (signal)
+		shm_signal_put(signal);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(vbus_driver_ioq_alloc);
diff --git a/kernel/vbus/shm-ioq.c b/kernel/vbus/shm-ioq.c
new file mode 100644
index 0000000..a627337
--- /dev/null
+++ b/kernel/vbus/shm-ioq.c
@@ -0,0 +1,89 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * IOQ helper for devices - This module implements an IOQ which has
+ * been shared with a device via a vbus_shm segment.
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
+#include <linux/ioq.h>
+#include <linux/vbus_device.h>
+
+struct _ioq {
+	struct vbus_shm *shm;
+	struct ioq ioq;
+};
+
+static void
+_shm_ioq_release(struct ioq *ioq)
+{
+	struct _ioq *_ioq = container_of(ioq, struct _ioq, ioq);
+
+	/* the signal is released by the IOQ infrastructure */
+	vbus_shm_put(_ioq->shm);
+	kfree(_ioq);
+}
+
+static struct ioq_ops _shm_ioq_ops = {
+	.release = _shm_ioq_release,
+};
+
+int vbus_shm_ioq_attach(struct vbus_shm *shm, struct shm_signal *signal,
+			int maxcount, struct ioq **ioq)
+{
+	struct _ioq *_ioq;
+	struct ioq_ring_head *head = NULL;
+	size_t ringcount;
+
+	if (!signal)
+		return -EINVAL;
+
+	_ioq = kzalloc(sizeof(*_ioq), GFP_KERNEL);
+	if (!_ioq)
+		return -ENOMEM;
+
+	head = (struct ioq_ring_head *)shm->ptr;
+
+	if (head->magic != IOQ_RING_MAGIC)
+		return -EINVAL;
+
+	if (head->ver != IOQ_RING_VER)
+		return -EINVAL;
+
+	ringcount = head->count;
+
+	if ((maxcount != -1) && (ringcount > maxcount))
+		return -EINVAL;
+
+	/*
+	 * Sanity check the ringcount against the actual length of the segment
+	 */
+	if (IOQ_HEAD_DESC_SIZE(ringcount) != shm->len)
+		return -EINVAL;
+
+	_ioq->shm = shm;
+
+	ioq_init(&_ioq->ioq, &_shm_ioq_ops, ioq_locality_south, head,
+		 signal, ringcount);
+
+	*ioq = &_ioq->ioq;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vbus_shm_ioq_attach);
+

