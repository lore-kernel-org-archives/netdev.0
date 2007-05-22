From: Zhang Rui <rui.zhang@intel.com>
Subject: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 22 May 2007 17:47:31 +0800
Message-ID: <1179827251.7707.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lenb@kernel.org, netdev@vger.kernel.org
To: linux-acpi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16646 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963AbXEVJsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 05:48:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhang Rui <rui.zhang@intel.com>

Export ACPI events via netlink.
A netlink message is broadcasted when an ACPI event is generated.

Note: The behaviour of how ACPI event works nowadays is not changed.
	Netlink is used to export ACPI event instead of /proc/acpi/event someday,
	but not now.
	This patch only adds the function of sending netlink messages
	when an ACPI event is generated.
	Following is an example of how to receive ACPI event messages.

#include <linux/socket.h>
#include <linux/netlink.h>
#include "stdio.h"

#define NETLINK_ACPI_EVENT	20
#define SOCK_RAW		3

struct acpi_event{
	char device_class[20];
	char bus_id[15];
	unsigned int type;
	unsigned int data;
};

struct sockaddr_nl src_addr, dest_addr;
int sock_fd;
struct msghdr msg;
struct iovec iov;


int main (void){
	int i = 10;
	int result;
	struct acpi_event event;

	sock_fd = socket(PF_NETLINK, SOCK_RAW, NETLINK_ACPI_EVENT);
	if (sock_fd == -1) {
		printf("Socket faied!\n");
		return 0;
	}

	src_addr.nl_family = AF_NETLINK;
	src_addr.nl_pid = getpid();

	src_addr.nl_groups = 1;

	result = bind(sock_fd, (struct sockaddr*)&src_addr, sizeof(src_addr));
	if (result) {
		printf("Bind faied! %d.\n", result);
		return result;
	}

	iov.iov_base = (void *)&event;
	iov.iov_len = sizeof(struct acpi_event);

	msg.msg_name = (void *)&dest_addr;
	msg.msg_namelen = sizeof(dest_addr);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;

	while(i > 0) {
		printf("Wait...\n");
		result = recvmsg(sock_fd, &msg, 0);
		if (result == -1) {
			printf("Rui: recvmsg failed, error is %d\n", result);
			return result;
		}
		printf("%20s %15s %08x %08x\n",
			event.device_class, event.bus_id, event.type, event.data);
		i--;
	}

	close(sock_fd);
	return 0;
}

Signed-off-by: Zhang Rui <rui.zhang@intel.com>
---
 drivers/acpi/bus.c      |   42 ++++++++++++++++++++++++++++++++++++++++++
 drivers/acpi/event.c    |   25 +++++++++++++++++++++++++
 include/acpi/acpi_bus.h |    4 +++-
 include/linux/netlink.h |    1 +
 4 files changed, 71 insertions(+), 1 deletion(-)

Index: linux-2.6.22-rc1/drivers/acpi/bus.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/acpi/bus.c	2007-05-21 10:18:58.000000000 +0800
+++ linux-2.6.22-rc1/drivers/acpi/bus.c	2007-05-21 15:38:06.000000000 +0800
@@ -37,6 +37,7 @@
 #endif
 #include <acpi/acpi_bus.h>
 #include <acpi/acpi_drivers.h>
+#include <linux/netlink.h>
 
 #define _COMPONENT		ACPI_BUS_COMPONENT
 ACPI_MODULE_NAME("bus");
@@ -275,6 +276,43 @@
 /* --------------------------------------------------------------------------
                                 Event Management
    -------------------------------------------------------------------------- */
+#ifdef CONFIG_NET
+struct acpi_bus_netlink_event {
+	acpi_device_class device_class;
+	char bus_id[15];
+	u32 type;
+	u32 data;
+};
+
+static int acpi_bus_generate_netlink_event(struct acpi_device *device,
+						u8 type, int data)
+{
+	struct sk_buff *skb = NULL;
+	struct acpi_bus_netlink_event *event = NULL;
+
+	skb = alloc_skb(sizeof(struct acpi_bus_event), GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	event = (struct acpi_bus_netlink_event *)
+			skb_put(skb, sizeof(struct acpi_bus_netlink_event));
+	strcpy(event->device_class, device->pnp.device_class);
+	strcpy(event->bus_id, device->dev.bus_id);
+	event->type = type;
+	event->data = data;
+
+	NETLINK_CB(skb).dst_group = 1;
+
+	netlink_broadcast(acpi_event_sock, skb, 0, 1, GFP_ATOMIC);
+	return 0;
+}
+#else
+static int acpi_bus_generate_netlink_event(struct acpi_device *device,
+						u8 type, int data)
+{
+	return 0;
+}
+#endif
 
 static DEFINE_SPINLOCK(acpi_bus_event_lock);
 
@@ -292,6 +330,10 @@
 	if (!device)
 		return -EINVAL;
 
+	if (acpi_bus_generate_netlink_event(device, type, data))
+		printk(KERN_WARNING PREFIX
+			"Failed to generate a netlink message for ACPI event!\n");
+
 	/* drop event on the floor if no one's listening */
 	if (!event_is_open)
 		return 0;
Index: linux-2.6.22-rc1/drivers/acpi/event.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/acpi/event.c	2007-05-16 16:12:46.000000000 +0800
+++ linux-2.6.22-rc1/drivers/acpi/event.c	2007-05-21 15:38:32.000000000 +0800
@@ -11,6 +11,7 @@
 #include <linux/init.h>
 #include <linux/poll.h>
 #include <acpi/acpi_drivers.h>
+#include <linux/netlink.h>
 
 #define _COMPONENT		ACPI_SYSTEM_COMPONENT
 ACPI_MODULE_NAME("event");
@@ -105,6 +106,24 @@
 	.release = acpi_system_close_event,
 	.poll = acpi_system_poll_event,
 };
+#ifdef CONFIG_NET
+struct sock* acpi_event_sock;
+static int acpi_event_netlink_init(void)
+{
+	acpi_event_sock = netlink_kernel_create(NETLINK_ACPI_EVENT, 1, NULL,
+						NULL, THIS_MODULE);
+
+	if (!acpi_event_sock)
+		return -ENODEV;
+
+	return 0;
+}
+#else
+static int acpi_event_netlink_init(void)
+{
+	return -ENODEV;
+}
+#endif
 
 static int __init acpi_event_init(void)
 {
@@ -115,6 +134,12 @@
 	if (acpi_disabled)
 		return 0;
 
+	/* create netlink for acpi event */
+	error = acpi_event_netlink_init();
+	if (error)
+		printk(KERN_WARNING PREFIX
+		       "Failed to create netlink for ACPI event\n");
+
 	/* 'event' [R] */
 	entry = create_proc_entry("event", S_IRUSR, acpi_root_dir);
 	if (entry)
Index: linux-2.6.22-rc1/include/linux/netlink.h
===================================================================
--- linux-2.6.22-rc1.orig/include/linux/netlink.h	2007-05-21 10:19:00.000000000 +0800
+++ linux-2.6.22-rc1/include/linux/netlink.h	2007-05-21 15:26:14.000000000 +0800
@@ -24,6 +24,7 @@
 /* leave room for NETLINK_DM (DM Events) */
 #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
 #define NETLINK_ECRYPTFS	19
+#define NETLINK_ACPI_EVENT	20	/* acpi event notifications */
 
 #define MAX_LINKS 32		
 
Index: linux-2.6.22-rc1/include/acpi/acpi_bus.h
===================================================================
--- linux-2.6.22-rc1.orig/include/acpi/acpi_bus.h	2007-05-21 10:19:00.000000000 +0800
+++ linux-2.6.22-rc1/include/acpi/acpi_bus.h	2007-05-21 15:34:36.000000000 +0800
@@ -321,7 +321,9 @@
 };
 
 extern struct kset acpi_subsys;
-
+#ifdef CONFIG_NET
+extern struct sock* acpi_event_sock;
+#endif
 /*
  * External Functions
  */
