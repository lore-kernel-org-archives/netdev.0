From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/2][NETNS]: The net-subsys IDs generator.
Date: Sat, 12 Apr 2008 13:41:22 +0400
Message-ID: <480083C2.3050007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52430 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918AbYDLJri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:47:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make some per-net generic pointers, we need some way to address
them, i.e. - IDs. This is simple IDA-based IDs generator for pernet
subsystems.

Addressing questions about potential checkpoint/restart problems: 
these IDs are "lite-offsets" within the net structure and are by no 
means supposed to be exported to the userspace.

Since it will be used in the nearest future by devices only (tun,
vlan, tunnels, bridge, etc), I make it resemble the functionality
of register_pernet_device().

The new ids is stored in the *id pointer _before_ calling the init
callback to make this id available in this callback.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/net_namespace.h |    2 ++
 net/core/net_namespace.c    |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

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
index 7b66083..2197d51 100644
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
@@ -330,6 +333,30 @@ int register_pernet_device(struct pernet_operations *ops)
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
+		goto out;
+	}
+	error = register_pernet_operations(&pernet_list, ops);
+	if (error)
+		ida_remove(&net_generic_ids, *id);
+	else if (first_device == &pernet_list)
+		first_device = &ops->list;
+out:
+	mutex_unlock(&net_mutex);
+	return error;
+}
+EXPORT_SYMBOL_GPL(register_pernet_gen_device);
+
 /**
  *      unregister_pernet_device - unregister a network namespace netdevice
  *	@ops: pernet operations structure to manipulate
@@ -348,3 +375,14 @@ void unregister_pernet_device(struct pernet_operations *ops)
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

