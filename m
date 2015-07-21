From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V3 4/7] Drivers: hv: vmbus: add APIs to register callbacks to process hvsock connection
Date: Tue, 21 Jul 2015 03:58:27 -0700
Message-ID: <1437476307-6871-1-git-send-email-decui@microsoft.com>
To: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	pebolle@tiscali.nl, stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the 2 APIs supplied by the VMBus driver, the coming net/hvsock driver
can register 2 callbacks and can know when a new hvsock connection is
offered by the host, and when a hvsock connection is being closed by the
host.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/Makefile           |  4 ++-
 drivers/hv/channel_mgmt.c     |  9 ++++++
 drivers/hv/hvsock_callbacks.c | 71 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/hyperv.h        | 10 ++++++
 4 files changed, 93 insertions(+), 1 deletion(-)
 create mode 100644 drivers/hv/hvsock_callbacks.c

diff --git a/drivers/hv/Makefile b/drivers/hv/Makefile
index 39c9b2c..ef6f8a8 100644
--- a/drivers/hv/Makefile
+++ b/drivers/hv/Makefile
@@ -4,5 +4,7 @@ obj-$(CONFIG_HYPERV_BALLOON)	+= hv_balloon.o
 
 hv_vmbus-y := vmbus_drv.o \
 		 hv.o connection.o channel.o \
-		 channel_mgmt.o ring_buffer.o
+		 channel_mgmt.o ring_buffer.o \
+		 hvsock_callbacks.o
+
 hv_utils-y := hv_util.o hv_kvp.o hv_snapshot.o hv_fcopy.o hv_utils_transport.o
diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index 7018c53..a8b1e61 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -300,6 +300,12 @@ static void vmbus_process_offer(struct vmbus_channel *newchannel)
 		return;
 	}
 
+	if (is_hvsock_channel(newchannel)) {
+		if (hvsock_process_offer(newchannel) != 0)
+			goto err_deq_chan;
+		return;
+	}
+
 	/*
 	 * Start the process of binding this offer to the driver
 	 * We need to set the DeviceObject field before calling
@@ -564,7 +570,10 @@ static void vmbus_onoffer_rescind(struct vmbus_channel_message_header *hdr)
 			vmbus_device_unregister(channel->device_obj);
 			put_device(dev);
 		}
+	} else if (is_hvsock_channel(channel)) {
+		hvsock_process_offer_rescind(channel);
 	} else {
+		/* it is a sub-channel. */
 		hv_process_channel_removal(channel,
 			channel->offermsg.child_relid);
 	}
diff --git a/drivers/hv/hvsock_callbacks.c b/drivers/hv/hvsock_callbacks.c
new file mode 100644
index 0000000..28f7b75
--- /dev/null
+++ b/drivers/hv/hvsock_callbacks.c
@@ -0,0 +1,71 @@
+/*
+ * Copyright (c) 2015, Microsoft Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/hyperv.h>
+
+/* We should hold the mutex when getting/setting the function pointers */
+static DEFINE_MUTEX(hvsock_cb_mutex);
+static int (*__process_offer)(struct vmbus_channel *channel);
+static void (*__process_offer_rescind)(struct vmbus_channel *channel);
+
+int hvsock_process_offer(struct vmbus_channel *channel)
+{
+	int ret = -ENODEV;
+
+	mutex_lock(&hvsock_cb_mutex);
+
+	if (__process_offer != NULL)
+		ret = __process_offer(channel);
+
+	mutex_unlock(&hvsock_cb_mutex);
+
+	return ret;
+}
+
+void hvsock_process_offer_rescind(struct vmbus_channel *channel)
+{
+	mutex_lock(&hvsock_cb_mutex);
+
+	if (__process_offer_rescind != NULL)
+		__process_offer_rescind(channel);
+	else
+		hv_process_channel_removal(channel,
+			channel->offermsg.child_relid);
+
+	mutex_unlock(&hvsock_cb_mutex);
+}
+
+void vmbus_register_hvsock_callbacks(
+	int (*process_offer)(struct vmbus_channel *),
+	void (*process_offer_rescind)(struct vmbus_channel *))
+{
+	mutex_lock(&hvsock_cb_mutex);
+
+	__process_offer = process_offer;
+	__process_offer_rescind = process_offer_rescind;
+
+	mutex_unlock(&hvsock_cb_mutex);
+}
+EXPORT_SYMBOL_GPL(vmbus_register_hvsock_callbacks);
+
+void vmbus_unregister_hvsock_callbacks(void)
+{
+	mutex_lock(&hvsock_cb_mutex);
+
+	__process_offer = NULL;
+	__process_offer_rescind = NULL;
+
+	mutex_unlock(&hvsock_cb_mutex);
+}
+EXPORT_SYMBOL_GPL(vmbus_unregister_hvsock_callbacks);
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index c8e27da..fda9790 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -1269,6 +1269,16 @@ extern __u32 vmbus_proto_version;
 
 int vmbus_send_tl_connect_request(const uuid_le *shv_guest_servie_id,
 				  const uuid_le *shv_host_servie_id);
+
+extern int hvsock_process_offer(struct vmbus_channel *channel);
+extern void hvsock_process_offer_rescind(struct vmbus_channel *channel);
+
+extern void vmbus_register_hvsock_callbacks(
+	int (*process_offer)(struct vmbus_channel *),
+	void (*process_offer_rescind)(struct vmbus_channel *));
+
+void vmbus_unregister_hvsock_callbacks(void);
+
 struct vmpipe_proto_header {
 	u32 pkt_type;
 
-- 
2.1.0
