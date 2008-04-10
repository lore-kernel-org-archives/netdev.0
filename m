From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/14][NETNS]: Introduce the net-subsys id generator.
Date: Thu, 10 Apr 2008 19:01:09 +0400
Message-ID: <47FE2BB5.4070708@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53319 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755182AbYDJOhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:37:48 -0400
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make some per-net generic pointers, we need some way to
address them, i.e. - IDs. This is simple IDA-based IDs
generator for pernet subsystems. They will be used in the
next patches.

Since it will be used by devices only (tun and vlan), I make
it resemble the register_pernet_device functionality.

The new ids is stored in the *id pointer _before_ calling the
init callback to make this id available in this callback.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 0ab62ed..6971fdb 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -181,6 +181,8 @@ extern int register_pernet_subsys(struct pernet_operations *);
 extern void unregister_pernet_subsys(struct pernet_operations *);
 extern int register_pernet_device(struct pernet_operations *);
 extern void unregister_pernet_device(struct pernet_operations *);
+extern int register_pernet_gen_device(int *id, struct pernet_operations *);
+extern void unregister_pernet_gen_device(int id, struct pernet_operations *);
 
 struct ctl_path;
 struct ctl_table;
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 7b66083..7ef3bac 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -5,6 +5,7 @@
 #include <linux/list.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
+#include <linux/idr.h>
 #include <net/net_namespace.h>
 
 /*
@@ -253,6 +254,8 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
 }
 #endif
 
+static DEFINE_IDA(net_generic_ids);
+
 /**
  *      register_pernet_subsys - register a network namespace subsystem
  *	@ops:  pernet operations structure for the subsystem
@@ -330,6 +333,28 @@ int register_pernet_device(struct pernet_operations *ops)
 }
 EXPORT_SYMBOL_GPL(register_pernet_device);
 
+int register_pernet_gen_device(int *id, struct pernet_operations *ops)
+{
+	int error;
+	mutex_lock(&net_mutex);
+again:
+	error = ida_get_new_above(&net_generic_ids, 1, id);
+	if (error) {
+		if (error == -EAGAIN) {
+			ida_pre_get(&net_generic_ids, GFP_KERNEL);
+			goto again;
+		}
+	}
+	error = register_pernet_operations(first_device, ops);
+	if (error)
+		ida_remove(&net_generic_ids, *id);
+	else if (first_device == &pernet_list)
+		first_device = &ops->list;
+	mutex_unlock(&net_mutex);
+	return error;
+}
+EXPORT_SYMBOL_GPL(register_pernet_gen_device);
+
 /**
  *      unregister_pernet_device - unregister a network namespace netdevice
  *	@ops: pernet operations structure to manipulate
@@ -348,3 +373,14 @@ void unregister_pernet_device(struct pernet_operations *ops)
 	mutex_unlock(&net_mutex);
 }
 EXPORT_SYMBOL_GPL(unregister_pernet_device);
+
+void unregister_pernet_gen_device(int id, struct pernet_operations *ops)
+{
+	mutex_lock(&net_mutex);
+	if (&ops->list == first_device)
+		first_device = first_device->next;
+	unregister_pernet_operations(ops);
+	ida_remove(&net_generic_ids, id);
+	mutex_unlock(&net_mutex);
+}
+EXPORT_SYMBOL_GPL(unregister_pernet_gen_device);
-- 
1.5.3.4

