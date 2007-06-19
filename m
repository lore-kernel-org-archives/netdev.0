From: Zhang Rui <rui.zhang@intel.com>
Subject: [PATCH] ACPI: export acpi events via generic netlink
Date: Tue, 19 Jun 2007 11:40:03 +0800
Message-ID: <1182224403.5411.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-VWQkQiUag6eZeYAjMsLE"
Cc: lenb@kernel.org, hadi@cyberus.ca
To: linux-acpi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44661 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763435AbXFSDio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 23:38:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VWQkQiUag6eZeYAjMsLE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

From: Zhang Rui <rui.zhang@intel.com>

Export ACPI events via Generic Netlink.
An "acpi_event" genetlink family message is sent
when an ACPI event is generated.

Note:	The behavior of how ACPI event works nowadays is not changed.
	Use genetlink to export ACPI event instead of
	/proc/acpi/event someday, but not now.
	This patch only adds the function of sending genetlink messages
	when an ACPI event is generated.
Attachment is a simple user space utility which can be used to receive
acpi event notifications via netlink.

Thanks to Jamal for his great help.

Signed-off-by: Zhang Rui <rui.zhang@intel.com>
---
 drivers/acpi/bus.c      |    4 +
 drivers/acpi/event.c    |  166 +++++++++++++++++++++++++++++++++++++++++++++---
 include/acpi/acpi_bus.h |    3 
 3 files changed, 165 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc5/drivers/acpi/bus.c
===================================================================
--- linux-2.6.22-rc5.orig/drivers/acpi/bus.c	2007-06-18 13:44:18.000000000 +0800
+++ linux-2.6.22-rc5/drivers/acpi/bus.c	2007-06-19 10:02:33.000000000 +0800
@@ -292,6 +292,10 @@
 	if (!device)
 		return -EINVAL;
 
+	if (acpi_bus_generate_genetlink_event(device, type, data))
+		printk(KERN_WARNING PREFIX
+			"Failed to generate an ACPI event via genetlink!\n");
+
 	/* drop event on the floor if no one's listening */
 	if (!event_is_open)
 		return 0;
Index: linux-2.6.22-rc5/drivers/acpi/event.c
===================================================================
--- linux-2.6.22-rc5.orig/drivers/acpi/event.c	2007-06-18 13:42:17.000000000 +0800
+++ linux-2.6.22-rc5/drivers/acpi/event.c	2007-06-19 11:07:15.000000000 +0800
@@ -11,6 +11,8 @@
 #include <linux/init.h>
 #include <linux/poll.h>
 #include <acpi/acpi_drivers.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
 
 #define _COMPONENT		ACPI_SYSTEM_COMPONENT
 ACPI_MODULE_NAME("event");
@@ -48,7 +50,6 @@
 	static int chars_remaining = 0;
 	static char *ptr;
 
-
 	if (!chars_remaining) {
 		memset(&event, 0, sizeof(struct acpi_bus_event));
 
@@ -106,23 +107,174 @@
 	.poll = acpi_system_poll_event,
 };
 
+#ifdef CONFIG_NET
+unsigned int acpi_event_seqnum;
+struct acpi_genl_event {
+	acpi_device_class device_class;
+	char bus_id[15];
+	u32 type;
+	u32 data;
+};
+
+/* attributes of acpi_genl_family */
+enum {
+	ACPI_GENL_ATTR_UNSPEC,
+	ACPI_GENL_ATTR_EVENT,	/* ACPI event info needed by user space */
+	__ACPI_GENL_ATTR_MAX,
+};
+#define ACPI_GENL_ATTR_MAX (__ACPI_GENL_ATTR_MAX - 1)
+
+/* commands supported by the acpi_genl_family */
+enum {
+	ACPI_GENL_CMD_UNSPEC,
+	ACPI_GENL_CMD_EVENT,	/* kernel->user notifications for ACPI events */
+	__ACPI_GENL_CMD_MAX,
+};
+#define ACPI_GENL_CMD_MAX (__ACPI_GENL_CMD_MAX - 1)
+
+#define ACPI_GENL_NAME		"acpi_event"
+#define ACPI_GENL_VERSION	0x01
+
+static struct genl_family acpi_event_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = ACPI_GENL_NAME,
+	.version = ACPI_GENL_VERSION,
+	.maxattr = ACPI_GENL_ATTR_MAX,
+};
+
+/* .doit: standard command callback */
+static int acpi_genl_cmd_event(struct sk_buff *skb, struct genl_info *info)
+{
+	struct acpi_genl_event *event = info->userhdr;
+
+	if (!event)
+		ACPI_DEBUG_PRINT((ACPI_DB_WARN, "ACPI event: NULL\n"));
+
+	return 0;
+}
+
+static struct genl_ops acpi_event_genl_ops = {
+	.cmd = ACPI_GENL_CMD_EVENT,
+	.doit = acpi_genl_cmd_event,
+};
+
+int acpi_bus_generate_genetlink_event(struct acpi_device *device,
+				      u8 type, int data)
+{
+	struct sk_buff *skb;
+	struct nlattr *attr;
+	struct acpi_genl_event *event;
+	void *msg_header;
+	int size;
+	int result;
+
+	/* allocate memory */
+	size = nla_total_size(sizeof(struct acpi_genl_event)) +
+	    nla_total_size(0);
+
+	skb = genlmsg_new(size, GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	/* add the genetlink message header */
+	msg_header = genlmsg_put(skb, 0, acpi_event_seqnum++,
+				 &acpi_event_genl_family, 0,
+				 ACPI_GENL_CMD_EVENT);
+	if (!msg_header) {
+		nlmsg_free(skb);
+		return -ENOMEM;
+	}
+
+	/* fill the data */
+	attr =
+	    nla_reserve(skb, ACPI_GENL_ATTR_EVENT,
+			sizeof(struct acpi_genl_event));
+	if (!attr) {
+		nlmsg_free(skb);
+		return -EINVAL;
+	}
+
+	event = nla_data(attr);
+	if (!event) {
+		nlmsg_free(skb);
+		return -EINVAL;
+	}
+
+	memset(event, 0, sizeof(struct acpi_genl_event));
+
+	strcpy(event->device_class, device->pnp.device_class);
+	strcpy(event->bus_id, device->dev.bus_id);
+	event->type = type;
+	event->data = data;
+
+	/* send multicast genetlink message */
+	result = genlmsg_end(skb, msg_header);
+	if (result < 0) {
+		nlmsg_free(skb);
+		return result;
+	}
+
+	result =
+	    genlmsg_multicast(skb, 0, acpi_event_genl_family.id, GFP_ATOMIC);
+	if (result)
+		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
+				  "Failed to send a Genetlink message!\n"));
+	return 0;
+}
+EXPORT_SYMBOL(acpi_bus_generate_genetlink_event);
+
+static int acpi_event_genetlink_init(void)
+{
+	int result;
+
+	result = genl_register_family(&acpi_event_genl_family);
+	if (result)
+		return result;
+
+	result =
+	    genl_register_ops(&acpi_event_genl_family, &acpi_event_genl_ops);
+	if (result)
+		genl_unregister_family(&acpi_event_genl_family);
+
+	return result;
+}
+
+#else
+int acpi_bus_generate_genetlink_event(struct acpi_device *device, u8 type,
+				      int data)
+{
+	return 0;
+}
+EXPORT_SYMBOL(acpi_bus_generate_genetlink_event);
+
+static int acpi_event_genetlink_init(void)
+{
+	return -ENODEV;
+}
+#endif
+
 static int __init acpi_event_init(void)
 {
 	struct proc_dir_entry *entry;
 	int error = 0;
 
-
 	if (acpi_disabled)
 		return 0;
 
+	/* create genetlink for acpi event */
+	error = acpi_event_genetlink_init();
+	if (error)
+		printk(KERN_WARNING PREFIX
+		       "Failed to create genetlink family for ACPI event\n");
+
 	/* 'event' [R] */
 	entry = create_proc_entry("event", S_IRUSR, acpi_root_dir);
 	if (entry)
 		entry->proc_fops = &acpi_system_event_ops;
-	else {
-		error = -ENODEV;
-	}
-	return error;
+	else
+		return -ENODEV;
+
+	return 0;
 }
 
-subsys_initcall(acpi_event_init);
+fs_initcall(acpi_event_init);
Index: linux-2.6.22-rc5/include/acpi/acpi_bus.h
===================================================================
--- linux-2.6.22-rc5.orig/include/acpi/acpi_bus.h	2007-06-18 13:44:19.000000000 +0800
+++ linux-2.6.22-rc5/include/acpi/acpi_bus.h	2007-06-19 09:18:14.000000000 +0800
@@ -321,7 +321,8 @@
 };
 
 extern struct kset acpi_subsys;
-
+extern int acpi_bus_generate_genetlink_event(struct acpi_device *device,
+						u8 type, int data);
 /*
  * External Functions
  */


--=-VWQkQiUag6eZeYAjMsLE
Content-Disposition: attachment; filename=acpi_genl.tgz
Content-Type: application/x-compressed-tar; name=acpi_genl.tgz
Content-Transfer-Encoding: base64

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


--=-VWQkQiUag6eZeYAjMsLE--
