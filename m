From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/1][RFC]Handle uevent per namespace
Date: Mon, 24 Nov 2008 11:50:34 +0100
Message-ID: <492A86FA.5080804@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060705040705090005000706"
Cc: Linux Containers <containers@lists.osdl.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:32872 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbYKXKul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 05:50:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060705040705090005000706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------060705040705090005000706
Content-Type: text/x-diff;
 name="make-kobject-uevent-per-namespace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="make-kobject-uevent-per-namespace.patch"

Subject: Handle uevent per namespace
From: Daniel Lezcano <dlezcano@fr.ibm.com>

At present when a network device is destroyed, inside a network
namespace, and this device has the same name as one network device
belonging to the initial network namespace (eg. eth0), the udev daemon
will disable the interface in the initial network namespace.

IMHO, udev should not receive this event. The uevents should be per
namespace or at least do not send events when not for the initial
network namespace.

The following patch is a RFC for making uevent namespace aware. I don't
know this part of the kernel code, so I am pretty sure t is not the 
right way to do that :) 

I tried to avoid, in the kobject code, to follow up the fields to 
net_device because that will add adherence between the generic kobject
code and the other kernel subsystem.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/linux/kobject.h     |    5 +++++
 include/net/net_namespace.h |    3 +++
 lib/kobject.c               |    4 ++++
 lib/kobject_uevent.c        |   30 ++++++++++++++++++++++--------
 net/core/net-sysfs.c        |    1 +
 5 files changed, 35 insertions(+), 8 deletions(-)

Index: net-next-2.6/include/linux/kobject.h
===================================================================
--- net-next-2.6.orig/include/linux/kobject.h
+++ net-next-2.6/include/linux/kobject.h
@@ -56,6 +56,8 @@ enum kobject_action {
 	KOBJ_MAX
 };
 
+struct net;
+
 struct kobject {
 	const char		*name;
 	struct list_head	entry;
@@ -63,6 +65,9 @@ struct kobject {
 	struct kset		*kset;
 	struct kobj_type	*ktype;
 	struct sysfs_dirent	*sd;
+#ifdef CONFIG_NET
+	struct net              *net;
+#endif
 	struct kref		kref;
 	unsigned int state_initialized:1;
 	unsigned int state_in_sysfs:1;
Index: net-next-2.6/include/net/net_namespace.h
===================================================================
--- net-next-2.6.orig/include/net/net_namespace.h
+++ net-next-2.6/include/net/net_namespace.h
@@ -75,6 +75,9 @@ struct net {
 #endif
 #endif
 	struct net_generic	*gen;
+#ifdef CONFIG_HOTPLUG
+	struct sock             *uevent_sock;
+#endif
 };
 
 
Index: net-next-2.6/lib/kobject.c
===================================================================
--- net-next-2.6.orig/lib/kobject.c
+++ net-next-2.6/lib/kobject.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/stat.h>
 #include <linux/slab.h>
+#include <net/net_namespace.h>
 
 /*
  * populate_dir - populate directory with attributes.
@@ -148,6 +149,9 @@ static void kobject_init_internal(struct
 		return;
 	kref_init(&kobj->kref);
 	INIT_LIST_HEAD(&kobj->entry);
+#ifdef CONFIG_NET
+	kobj->net = &init_net;
+#endif
 	kobj->state_in_sysfs = 0;
 	kobj->state_add_uevent_sent = 0;
 	kobj->state_remove_uevent_sent = 0;
Index: net-next-2.6/lib/kobject_uevent.c
===================================================================
--- net-next-2.6.orig/lib/kobject_uevent.c
+++ net-next-2.6/lib/kobject_uevent.c
@@ -28,9 +28,6 @@
 u64 uevent_seqnum;
 char uevent_helper[UEVENT_HELPER_PATH_LEN] = CONFIG_UEVENT_HELPER_PATH;
 static DEFINE_SPINLOCK(sequence_lock);
-#if defined(CONFIG_NET)
-static struct sock *uevent_sock;
-#endif
 
 /* the strings here must match the enum in include/linux/kobject.h */
 static const char *kobject_actions[] = {
@@ -203,7 +200,7 @@ int kobject_uevent_env(struct kobject *k
 
 #if defined(CONFIG_NET)
 	/* send netlink message */
-	if (uevent_sock) {
+	if (kobj->net->uevent_sock) {
 		struct sk_buff *skb;
 		size_t len;
 
@@ -225,7 +222,8 @@ int kobject_uevent_env(struct kobject *k
 			}
 
 			NETLINK_CB(skb).dst_group = 1;
-			netlink_broadcast(uevent_sock, skb, 0, 1, GFP_KERNEL);
+			netlink_broadcast(kobj->net->uevent_sock,
+					  skb, 0, 1, GFP_KERNEL);
 		}
 	}
 #endif
@@ -307,11 +305,11 @@ int add_uevent_var(struct kobj_uevent_en
 EXPORT_SYMBOL_GPL(add_uevent_var);
 
 #if defined(CONFIG_NET)
-static int __init kobject_uevent_init(void)
+static int kobject_uevent_net_init(struct net *net)
 {
-	uevent_sock = netlink_kernel_create(&init_net, NETLINK_KOBJECT_UEVENT,
+	net->uevent_sock = netlink_kernel_create(net, NETLINK_KOBJECT_UEVENT,
 					    1, NULL, NULL, THIS_MODULE);
-	if (!uevent_sock) {
+	if (!net->uevent_sock) {
 		printk(KERN_ERR
 		       "kobject_uevent: unable to create netlink socket!\n");
 		return -ENODEV;
@@ -320,5 +318,21 @@ static int __init kobject_uevent_init(vo
 	return 0;
 }
 
+static void kobject_uevent_net_exit(struct net *net)
+{
+	netlink_kernel_release(net->uevent_sock);
+}
+
+static struct pernet_operations kobject_uevent_net_ops = {
+	.init = kobject_uevent_net_init,
+	.exit = kobject_uevent_net_exit,
+};
+
+
+static int __init kobject_uevent_init(void)
+{
+	return register_pernet_subsys(&kobject_uevent_net_ops);
+}
+
 postcore_initcall(kobject_uevent_init);
 #endif
Index: net-next-2.6/net/core/net-sysfs.c
===================================================================
--- net-next-2.6.orig/net/core/net-sysfs.c
+++ net-next-2.6/net/core/net-sysfs.c
@@ -491,6 +491,7 @@ int netdev_register_kobject(struct net_d
 	dev->class = &net_class;
 	dev->platform_data = net;
 	dev->groups = groups;
+	dev->kobj.net = dev_net(net);
 
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
 	dev_set_name(dev, net->name);

--------------060705040705090005000706--
