From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Wed, 22 Oct 2014 17:29:06 +0200
Message-ID: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58861 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037AbaJVP3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 11:29:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal and netdev vport remain part of openvswitch.ko. Encap
vports including vxlan, gre, and geneve can be built as separate
modules and are loaded on demand. Modules can be unloaded after use.
Datapath ports keep a reference to the vport module during their
lifetime.

Allows to remove the error prone maintenance of the global list
vport_ops_list.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/Kconfig              |  18 +++----
 net/openvswitch/Makefile             |  14 ++---
 net/openvswitch/datapath.c           |  16 +++++-
 net/openvswitch/vport-geneve.c       |  23 +++++++-
 net/openvswitch/vport-gre.c          |  23 +++++++-
 net/openvswitch/vport-internal_dev.c |  17 +++++-
 net/openvswitch/vport-netdev.c       |  14 ++++-
 net/openvswitch/vport-netdev.h       |   3 ++
 net/openvswitch/vport-vxlan.c        |  23 +++++++-
 net/openvswitch/vport.c              | 102 ++++++++++++++++++++++++-----------
 net/openvswitch/vport.h              |  14 +++--
 11 files changed, 199 insertions(+), 68 deletions(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index ba3bb82..2a9673e 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -29,11 +29,11 @@ config OPENVSWITCH
 	  If unsure, say N.
 
 config OPENVSWITCH_GRE
-	bool "Open vSwitch GRE tunneling support"
+	tristate "Open vSwitch GRE tunneling support"
 	depends on INET
 	depends on OPENVSWITCH
-	depends on NET_IPGRE_DEMUX && !(OPENVSWITCH=y && NET_IPGRE_DEMUX=m)
-	default y
+	depends on NET_IPGRE_DEMUX
+	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create GRE
 	  vport.
@@ -43,11 +43,11 @@ config OPENVSWITCH_GRE
 	  If unsure, say Y.
 
 config OPENVSWITCH_VXLAN
-	bool "Open vSwitch VXLAN tunneling support"
+	tristate "Open vSwitch VXLAN tunneling support"
 	depends on INET
 	depends on OPENVSWITCH
-	depends on VXLAN && !(OPENVSWITCH=y && VXLAN=m)
-	default y
+	depends on VXLAN
+	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create vxlan vport.
 
@@ -56,11 +56,11 @@ config OPENVSWITCH_VXLAN
 	  If unsure, say Y.
 
 config OPENVSWITCH_GENEVE
-	bool "Open vSwitch Geneve tunneling support"
+	tristate "Open vSwitch Geneve tunneling support"
 	depends on INET
 	depends on OPENVSWITCH
-	depends on GENEVE && !(OPENVSWITCH=y && GENEVE=m)
-	default y
+	depends on GENEVE
+	default OPENVSWITCH
 	---help---
 	  If you say Y here, then the Open vSwitch will be able create geneve vport.
 
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 9a33a27..91b9478 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -15,14 +15,6 @@ openvswitch-y := \
 	vport-internal_dev.o \
 	vport-netdev.o
 
-ifneq ($(CONFIG_OPENVSWITCH_GENEVE),)
-openvswitch-y += vport-geneve.o
-endif
-
-ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
-openvswitch-y += vport-vxlan.o
-endif
-
-ifneq ($(CONFIG_OPENVSWITCH_GRE),)
-openvswitch-y += vport-gre.o
-endif
+obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
+obj-$(CONFIG_OPENVSWITCH_VXLAN)	+= vport-vxlan.o
+obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e6d7255..aecddb9 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -59,6 +59,7 @@
 #include "vport-netdev.h"
 
 int ovs_net_id __read_mostly;
+EXPORT_SYMBOL(ovs_net_id);
 
 static struct genl_family dp_packet_genl_family;
 static struct genl_family dp_flow_genl_family;
@@ -1764,6 +1765,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		return -ENOMEM;
 
 	ovs_lock();
+restart:
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
@@ -1795,8 +1797,11 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	vport = new_vport(&parms);
 	err = PTR_ERR(vport);
-	if (IS_ERR(vport))
+	if (IS_ERR(vport)) {
+		if (err == -EAGAIN)
+			goto restart;
 		goto exit_unlock_free;
+	}
 
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
@@ -2112,12 +2117,18 @@ static int __init dp_init(void)
 	if (err)
 		goto error_netns_exit;
 
+	err = ovs_netdev_init();
+	if (err)
+		goto error_unreg_notifier;
+
 	err = dp_register_genl();
 	if (err < 0)
-		goto error_unreg_notifier;
+		goto error_unreg_netdev;
 
 	return 0;
 
+error_unreg_netdev:
+	ovs_netdev_exit();
 error_unreg_notifier:
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 error_netns_exit:
@@ -2137,6 +2148,7 @@ error:
 static void dp_cleanup(void)
 {
 	dp_unregister_genl(ARRAY_SIZE(dp_genl_families));
+	ovs_netdev_exit();
 	unregister_netdevice_notifier(&ovs_dp_device_notifier);
 	unregister_pernet_device(&ovs_net_ops);
 	rcu_barrier();
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 106a9d8..70c9765 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -17,6 +17,7 @@
 #include <linux/rculist.h>
 #include <linux/udp.h>
 #include <linux/if_vlan.h>
+#include <linux/module.h>
 
 #include <net/geneve.h>
 #include <net/icmp.h>
@@ -28,6 +29,8 @@
 #include "datapath.h"
 #include "vport.h"
 
+static struct vport_ops ovs_geneve_vport_ops;
+
 /**
  * struct geneve_port - Keeps track of open UDP ports
  * @gs: The socket created for this port number.
@@ -225,11 +228,29 @@ static const char *geneve_get_name(const struct vport *vport)
 	return geneve_port->name;
 }
 
-const struct vport_ops ovs_geneve_vport_ops = {
+static struct vport_ops ovs_geneve_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GENEVE,
 	.create		= geneve_tnl_create,
 	.destroy	= geneve_tnl_destroy,
 	.get_name	= geneve_get_name,
 	.get_options	= geneve_get_options,
 	.send		= geneve_tnl_send,
+	.owner          = THIS_MODULE,
 };
+
+static int __init ovs_geneve_tnl_init(void)
+{
+	return ovs_vport_ops_register(&ovs_geneve_vport_ops);
+}
+
+static void __exit ovs_geneve_tnl_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_geneve_vport_ops);
+}
+
+module_init(ovs_geneve_tnl_init);
+module_exit(ovs_geneve_tnl_exit);
+
+MODULE_DESCRIPTION("OVS: Geneve swiching port");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("vport-type-5");
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 108b82d..00270b6 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -29,6 +29,7 @@
 #include <linux/jhash.h>
 #include <linux/list.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/workqueue.h>
 #include <linux/rculist.h>
 #include <net/route.h>
@@ -45,6 +46,8 @@
 #include "datapath.h"
 #include "vport.h"
 
+static struct vport_ops ovs_gre_vport_ops;
+
 /* Returns the least-significant 32 bits of a __be64. */
 static __be32 be64_get_low32(__be64 x)
 {
@@ -281,10 +284,28 @@ static void gre_tnl_destroy(struct vport *vport)
 	gre_exit();
 }
 
-const struct vport_ops ovs_gre_vport_ops = {
+static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
 	.destroy	= gre_tnl_destroy,
 	.get_name	= gre_get_name,
 	.send		= gre_tnl_send,
+	.owner		= THIS_MODULE,
 };
+
+static int __init ovs_gre_tnl_init(void)
+{
+	return ovs_vport_ops_register(&ovs_gre_vport_ops);
+}
+
+static void __exit ovs_gre_tnl_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_gre_vport_ops);
+}
+
+module_init(ovs_gre_tnl_init);
+module_exit(ovs_gre_tnl_exit);
+
+MODULE_DESCRIPTION("OVS: GRE switching port");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("vport-type-3");
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 8451612..10dc07e 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -36,6 +36,8 @@ struct internal_dev {
 	struct vport *vport;
 };
 
+static struct vport_ops ovs_internal_vport_ops;
+
 static struct internal_dev *internal_dev_priv(struct net_device *netdev)
 {
 	return netdev_priv(netdev);
@@ -238,7 +240,7 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	return len;
 }
 
-const struct vport_ops ovs_internal_vport_ops = {
+static struct vport_ops ovs_internal_vport_ops = {
 	.type		= OVS_VPORT_TYPE_INTERNAL,
 	.create		= internal_dev_create,
 	.destroy	= internal_dev_destroy,
@@ -261,10 +263,21 @@ struct vport *ovs_internal_dev_get_vport(struct net_device *netdev)
 
 int ovs_internal_dev_rtnl_link_register(void)
 {
-	return rtnl_link_register(&internal_dev_link_ops);
+	int err;
+
+	err = rtnl_link_register(&internal_dev_link_ops);
+	if (err < 0)
+		return err;
+
+	err = ovs_vport_ops_register(&ovs_internal_vport_ops);
+	if (err < 0)
+		rtnl_link_unregister(&internal_dev_link_ops);
+
+	return err;
 }
 
 void ovs_internal_dev_rtnl_link_unregister(void)
 {
+	ovs_vport_ops_unregister(&ovs_internal_vport_ops);
 	rtnl_link_unregister(&internal_dev_link_ops);
 }
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index d21f77d..877ee74 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -33,6 +33,8 @@
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
+static struct vport_ops ovs_netdev_vport_ops;
+
 /* Must be called with rcu_read_lock. */
 static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 {
@@ -224,10 +226,20 @@ struct vport *ovs_netdev_get_vport(struct net_device *dev)
 		return NULL;
 }
 
-const struct vport_ops ovs_netdev_vport_ops = {
+static struct vport_ops ovs_netdev_vport_ops = {
 	.type		= OVS_VPORT_TYPE_NETDEV,
 	.create		= netdev_create,
 	.destroy	= netdev_destroy,
 	.get_name	= ovs_netdev_get_name,
 	.send		= netdev_send,
 };
+
+int __init ovs_netdev_init(void)
+{
+	return ovs_vport_ops_register(&ovs_netdev_vport_ops);
+}
+
+void ovs_netdev_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_netdev_vport_ops);
+}
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 8df01c11..6f7038e 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -41,4 +41,7 @@ netdev_vport_priv(const struct vport *vport)
 const char *ovs_netdev_get_name(const struct vport *);
 void ovs_netdev_detach_dev(struct vport *);
 
+int __init ovs_netdev_init(void);
+void ovs_netdev_exit(void);
+
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 2735e01..965e750 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -24,6 +24,7 @@
 #include <linux/net.h>
 #include <linux/rculist.h>
 #include <linux/udp.h>
+#include <linux/module.h>
 
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -50,6 +51,8 @@ struct vxlan_port {
 	char name[IFNAMSIZ];
 };
 
+static struct vport_ops ovs_vxlan_vport_ops;
+
 static inline struct vxlan_port *vxlan_vport(const struct vport *vport)
 {
 	return vport_priv(vport);
@@ -192,11 +195,29 @@ static const char *vxlan_get_name(const struct vport *vport)
 	return vxlan_port->name;
 }
 
-const struct vport_ops ovs_vxlan_vport_ops = {
+static struct vport_ops ovs_vxlan_vport_ops = {
 	.type		= OVS_VPORT_TYPE_VXLAN,
 	.create		= vxlan_tnl_create,
 	.destroy	= vxlan_tnl_destroy,
 	.get_name	= vxlan_get_name,
 	.get_options	= vxlan_get_options,
 	.send		= vxlan_tnl_send,
+	.owner		= THIS_MODULE,
 };
+
+static int __init ovs_vxlan_tnl_init(void)
+{
+	return ovs_vport_ops_register(&ovs_vxlan_vport_ops);
+}
+
+static void __exit ovs_vxlan_tnl_exit(void)
+{
+	ovs_vport_ops_unregister(&ovs_vxlan_vport_ops);
+}
+
+module_init(ovs_vxlan_tnl_init);
+module_exit(ovs_vxlan_tnl_exit);
+
+MODULE_DESCRIPTION("OVS: VXLAN switching port");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("vport-type-4");
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6015802..8168ef0 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -28,6 +28,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
 #include <net/net_namespace.h>
+#include <linux/module.h>
 
 #include "datapath.h"
 #include "vport.h"
@@ -36,22 +37,7 @@
 static void ovs_vport_record_error(struct vport *,
 				   enum vport_err_type err_type);
 
-/* List of statically compiled vport implementations.  Don't forget to also
- * add yours to the list at the bottom of vport.h. */
-static const struct vport_ops *vport_ops_list[] = {
-	&ovs_netdev_vport_ops,
-	&ovs_internal_vport_ops,
-
-#ifdef CONFIG_OPENVSWITCH_GRE
-	&ovs_gre_vport_ops,
-#endif
-#ifdef CONFIG_OPENVSWITCH_VXLAN
-	&ovs_vxlan_vport_ops,
-#endif
-#ifdef CONFIG_OPENVSWITCH_GENEVE
-	&ovs_geneve_vport_ops,
-#endif
-};
+static LIST_HEAD(vport_ops_list);
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
 static struct hlist_head *dev_table;
@@ -88,6 +74,32 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
 	return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
 }
 
+int ovs_vport_ops_register(struct vport_ops *ops)
+{
+	int err = -EEXIST;
+	struct vport_ops *o;
+
+	ovs_lock();
+	list_for_each_entry(o, &vport_ops_list, list)
+		if (ops->type == o->type)
+			goto errout;
+
+	list_add_tail(&ops->list, &vport_ops_list);
+	err = 0;
+errout:
+	ovs_unlock();
+	return err;
+}
+EXPORT_SYMBOL(ovs_vport_ops_register);
+
+void ovs_vport_ops_unregister(struct vport_ops *ops)
+{
+	ovs_lock();
+	list_del(&ops->list);
+	ovs_unlock();
+}
+EXPORT_SYMBOL(ovs_vport_ops_unregister);
+
 /**
  *	ovs_vport_locate - find a port that has already been created
  *
@@ -153,6 +165,7 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 
 	return vport;
 }
+EXPORT_SYMBOL(ovs_vport_alloc);
 
 /**
  *	ovs_vport_free - uninitialize and free vport
@@ -173,6 +186,18 @@ void ovs_vport_free(struct vport *vport)
 	free_percpu(vport->percpu_stats);
 	kfree(vport);
 }
+EXPORT_SYMBOL(ovs_vport_free);
+
+static struct vport_ops *ovs_vport_lookup(const struct vport_parms *parms)
+{
+	struct vport_ops *ops;
+
+	list_for_each_entry(ops, &vport_ops_list, list)
+		if (ops->type == parms->type)
+			return ops;
+
+	return NULL;
+}
 
 /**
  *	ovs_vport_add - add vport device (for kernel callers)
@@ -184,31 +209,40 @@ void ovs_vport_free(struct vport *vport)
  */
 struct vport *ovs_vport_add(const struct vport_parms *parms)
 {
+	struct vport_ops *ops;
 	struct vport *vport;
-	int err = 0;
-	int i;
 
-	for (i = 0; i < ARRAY_SIZE(vport_ops_list); i++) {
-		if (vport_ops_list[i]->type == parms->type) {
-			struct hlist_head *bucket;
+	ops = ovs_vport_lookup(parms);
+	if (ops) {
+		struct hlist_head *bucket;
 
-			vport = vport_ops_list[i]->create(parms);
-			if (IS_ERR(vport)) {
-				err = PTR_ERR(vport);
-				goto out;
-			}
+		if (!try_module_get(ops->owner))
+			return ERR_PTR(-EAFNOSUPPORT);
 
-			bucket = hash_bucket(ovs_dp_get_net(vport->dp),
-					     vport->ops->get_name(vport));
-			hlist_add_head_rcu(&vport->hash_node, bucket);
+		vport = ops->create(parms);
+		if (IS_ERR(vport)) {
+			module_put(ops->owner);
 			return vport;
 		}
+
+		bucket = hash_bucket(ovs_dp_get_net(vport->dp),
+				     vport->ops->get_name(vport));
+		hlist_add_head_rcu(&vport->hash_node, bucket);
+		return vport;
 	}
 
-	err = -EAFNOSUPPORT;
+	/* Unlock to attempt module load and return -EAGAIN if load
+	 * was successful as we need to restart the port addition
+	 * workflow.
+	 */
+	ovs_unlock();
+	request_module("vport-type-%d", parms->type);
+	ovs_lock();
 
-out:
-	return ERR_PTR(err);
+	if (!ovs_vport_lookup(parms))
+		return ERR_PTR(-EAFNOSUPPORT);
+	else
+		return ERR_PTR(-EAGAIN);
 }
 
 /**
@@ -242,6 +276,8 @@ void ovs_vport_del(struct vport *vport)
 	hlist_del_rcu(&vport->hash_node);
 
 	vport->ops->destroy(vport);
+
+	module_put(vport->ops->owner);
 }
 
 /**
@@ -457,6 +493,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	}
 	ovs_dp_process_packet(skb, &key);
 }
+EXPORT_SYMBOL(ovs_vport_receive);
 
 /**
  *	ovs_vport_send - send a packet on a device
@@ -535,3 +572,4 @@ void ovs_vport_deferred_free(struct vport *vport)
 
 	call_rcu(&vport->rcu, free_vport_rcu);
 }
+EXPORT_SYMBOL(ovs_vport_deferred_free);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 8942125..e41c3fa 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -161,6 +161,9 @@ struct vport_ops {
 	const char *(*get_name)(const struct vport *);
 
 	int (*send)(struct vport *, struct sk_buff *);
+
+	struct module *owner;
+	struct list_head list;
 };
 
 enum vport_err_type {
@@ -209,14 +212,6 @@ static inline struct vport *vport_from_priv(void *priv)
 void ovs_vport_receive(struct vport *, struct sk_buff *,
 		       struct ovs_tunnel_info *);
 
-/* List of statically compiled vport implementations.  Don't forget to also
- * add yours to the list at the top of vport.c. */
-extern const struct vport_ops ovs_netdev_vport_ops;
-extern const struct vport_ops ovs_internal_vport_ops;
-extern const struct vport_ops ovs_gre_vport_ops;
-extern const struct vport_ops ovs_vxlan_vport_ops;
-extern const struct vport_ops ovs_geneve_vport_ops;
-
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
 {
@@ -224,4 +219,7 @@ static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
 }
 
+int ovs_vport_ops_register(struct vport_ops *ops);
+void ovs_vport_ops_unregister(struct vport_ops *ops);
+
 #endif /* vport.h */
-- 
1.9.3
