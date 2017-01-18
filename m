From: Sainath Grandhi <sainath.grandhi@intel.com>
Subject: [PATCHv2 7/7] IPVTAP: IP-VLAN based tap driver
Date: Tue, 17 Jan 2017 16:03:06 -0800
Message-ID: <1484697786-50323-8-git-send-email-sainath.grandhi@intel.com>
References: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org, sainath.grandhi@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484697786-50323-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a tap character device driver that is based on the
IP-VLAN network interface, called ipvtap. An ipvtap device can be created
in the same way as an ipvlan device, using 'type ipvtap', and then accessed
using the tap user space interface.

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 drivers/net/Kconfig              |  13 +++
 drivers/net/Makefile             |   1 +
 drivers/net/ipvlan/Makefile      |   1 +
 drivers/net/ipvlan/ipvlan.h      |   7 ++
 drivers/net/ipvlan/ipvlan_core.c |   5 +-
 drivers/net/ipvlan/ipvlan_main.c |  27 +++--
 drivers/net/ipvlan/ipvtap.c      | 238 +++++++++++++++++++++++++++++++++++++++
 7 files changed, 278 insertions(+), 14 deletions(-)
 create mode 100644 drivers/net/ipvlan/ipvtap.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1c88437..d07b5f5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -166,6 +166,19 @@ config IPVLAN
       To compile this driver as a module, choose M here: the module
       will be called ipvlan.
 
+config IPVTAP
+	tristate "IP-VLAN based tap driver"
+	depends on IPVLAN
+	depends on INET
+	depends on TAP
+	---help---
+	  This adds a specialized tap character device driver that is based
+	  on the IP-VLAN network interface, called ipvtap. An ipvtap device
+	  can be added in the same way as a ipvlan device, using 'type
+	  ipvtap', and then be accessed through the tap user space interface.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipvtap.
 
 config VXLAN
        tristate "Virtual eXtensible Local Area Network (VXLAN)"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7dd86ca..98ed4d9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -7,6 +7,7 @@
 #
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_IPVLAN) += ipvlan/
+obj-$(CONFIG_IPVTAP) += ipvlan/
 obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_IFB) += ifb.o
diff --git a/drivers/net/ipvlan/Makefile b/drivers/net/ipvlan/Makefile
index df79910..8a2c64d 100644
--- a/drivers/net/ipvlan/Makefile
+++ b/drivers/net/ipvlan/Makefile
@@ -3,5 +3,6 @@
 #
 
 obj-$(CONFIG_IPVLAN) += ipvlan.o
+obj-$(CONFIG_IPVTAP) += ipvtap.o
 
 ipvlan-objs := ipvlan_core.o ipvlan_main.o
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index dbfbb33..4362d88 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -133,4 +133,11 @@ struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
 			      u16 proto);
 unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
 			     const struct nf_hook_state *state);
+void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
+		     unsigned int len, bool success, bool mcast);
+int ipvlan_link_new(struct net *src_net, struct net_device *dev,
+		    struct nlattr *tb[], struct nlattr *data[]);
+void ipvlan_link_delete(struct net_device *dev, struct list_head *head);
+void ipvlan_link_setup(struct net_device *dev);
+int ipvlan_link_register(struct rtnl_link_ops *ops);
 #endif /* __IPVLAN_H */
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 83ce74a..9af16ab 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -16,8 +16,8 @@ void ipvlan_init_secret(void)
 	net_get_random_once(&ipvlan_jhash_secret, sizeof(ipvlan_jhash_secret));
 }
 
-static void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
-			    unsigned int len, bool success, bool mcast)
+void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
+		     unsigned int len, bool success, bool mcast)
 {
 	if (!ipvlan)
 		return;
@@ -36,6 +36,7 @@ static void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
 		this_cpu_inc(ipvlan->pcpu_stats->rx_errs);
 	}
 }
+EXPORT_SYMBOL_GPL(ipvlan_count_rx);
 
 static u8 ipvlan_get_v6_hash(const void *iaddr)
 {
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 8b0f993..ed750e2 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -494,8 +494,8 @@ static int ipvlan_nl_fillinfo(struct sk_buff *skb,
 	return ret;
 }
 
-static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+int ipvlan_link_new(struct net *src_net, struct net_device *dev,
+		    struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_port *port;
@@ -567,8 +567,9 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 		ipvlan_port_destroy(phy_dev);
 	return err;
 }
+EXPORT_SYMBOL_GPL(ipvlan_link_new);
 
-static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
+void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_addr *addr, *next;
@@ -583,8 +584,9 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
 }
+EXPORT_SYMBOL_GPL(ipvlan_link_delete);
 
-static void ipvlan_link_setup(struct net_device *dev)
+void ipvlan_link_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
@@ -595,6 +597,7 @@ static void ipvlan_link_setup(struct net_device *dev)
 	dev->header_ops = &ipvlan_header_ops;
 	dev->ethtool_ops = &ipvlan_ethtool_ops;
 }
+EXPORT_SYMBOL_GPL(ipvlan_link_setup);
 
 static const struct nla_policy ipvlan_nl_policy[IFLA_IPVLAN_MAX + 1] =
 {
@@ -605,22 +608,22 @@ static struct rtnl_link_ops ipvlan_link_ops = {
 	.kind		= "ipvlan",
 	.priv_size	= sizeof(struct ipvl_dev),
 
-	.get_size	= ipvlan_nl_getsize,
-	.policy		= ipvlan_nl_policy,
-	.validate	= ipvlan_nl_validate,
-	.fill_info	= ipvlan_nl_fillinfo,
-	.changelink	= ipvlan_nl_changelink,
-	.maxtype	= IFLA_IPVLAN_MAX,
-
 	.setup		= ipvlan_link_setup,
 	.newlink	= ipvlan_link_new,
 	.dellink	= ipvlan_link_delete,
 };
 
-static int ipvlan_link_register(struct rtnl_link_ops *ops)
+int ipvlan_link_register(struct rtnl_link_ops *ops)
 {
+	ops->get_size	= ipvlan_nl_getsize;
+	ops->policy	= ipvlan_nl_policy;
+	ops->validate	= ipvlan_nl_validate;
+	ops->fill_info	= ipvlan_nl_fillinfo;
+	ops->changelink = ipvlan_nl_changelink;
+	ops->maxtype	= IFLA_IPVLAN_MAX;
 	return rtnl_link_register(ops);
 }
+EXPORT_SYMBOL_GPL(ipvlan_link_register);
 
 static int ipvlan_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
diff --git a/drivers/net/ipvlan/ipvtap.c b/drivers/net/ipvlan/ipvtap.c
new file mode 100644
index 0000000..54e9893
--- /dev/null
+++ b/drivers/net/ipvlan/ipvtap.c
@@ -0,0 +1,238 @@
+#include <linux/etherdevice.h>
+#include "ipvlan.h"
+#include <linux/if_vlan.h>
+#include <linux/if_tap.h>
+#include <linux/interrupt.h>
+#include <linux/nsproxy.h>
+#include <linux/compat.h>
+#include <linux/if_tun.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/cache.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/wait.h>
+#include <linux/cdev.h>
+#include <linux/idr.h>
+#include <linux/fs.h>
+#include <linux/uio.h>
+
+#include <net/net_namespace.h>
+#include <net/rtnetlink.h>
+#include <net/sock.h>
+#include <linux/virtio_net.h>
+
+#define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
+		      NETIF_F_TSO6 | NETIF_F_UFO)
+
+static dev_t ipvtap_major;
+static struct cdev ipvtap_cdev;
+
+static const void *ipvtap_net_namespace(struct device *d)
+{
+	struct net_device *dev = to_net_dev(d->parent);
+	return dev_net(dev);
+}
+
+static struct class ipvtap_class = {
+	 .name = "ipvtap",
+	 .owner = THIS_MODULE,
+	 .ns_type = &net_ns_type_operations,
+	 .namespace = ipvtap_net_namespace,
+};
+
+struct ipvtap_dev {
+	struct ipvl_dev vlan;
+	struct tap_dev	  tap;
+};
+
+static void ipvtap_count_tx_dropped(struct tap_dev *tap)
+{
+	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct ipvtap_dev, tap);
+
+	this_cpu_inc(vlan->pcpu_stats->tx_drps);
+}
+
+static void ipvtap_count_rx_dropped(struct tap_dev *tap)
+{
+	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct ipvtap_dev, tap);
+
+	ipvlan_count_rx(vlan, 0, 0, 0);
+}
+
+static void ipvtap_update_features(struct tap_dev *tap,
+				   netdev_features_t features)
+{
+	struct ipvl_dev *vlan = (struct ipvl_dev *)container_of(tap, struct ipvtap_dev, tap);
+
+	vlan->sfeatures = features;
+	netdev_update_features(vlan->dev);
+}
+
+static int ipvtap_newlink(struct net *src_net,
+			  struct net_device *dev,
+			  struct nlattr *tb[],
+			  struct nlattr *data[])
+{
+	struct ipvtap_dev *vlantap = netdev_priv(dev);
+	int err;
+
+	INIT_LIST_HEAD(&vlantap->tap.queue_list);
+
+	/* Since macvlan supports all offloads by default, make
+	 * tap support all offloads also.
+	 */
+	vlantap->tap.tap_features = TUN_OFFLOADS;
+	vlantap->tap.count_tx_dropped = ipvtap_count_tx_dropped;
+	vlantap->tap.update_features =	ipvtap_update_features;
+	vlantap->tap.count_rx_dropped = ipvtap_count_rx_dropped;
+
+	err = netdev_rx_handler_register(dev, tap_handle_frame, &vlantap->tap);
+	if (err)
+		return err;
+
+	/* Don't put anything that may fail after macvlan_common_newlink
+	 * because we can't undo what it does.
+	 */
+	err =  ipvlan_link_new(src_net, dev, tb, data);
+	if (err) {
+		netdev_rx_handler_unregister(dev);
+		return err;
+	}
+
+	vlantap->tap.dev = vlantap->vlan.dev;
+
+	return err;
+}
+
+static void ipvtap_dellink(struct net_device *dev,
+			   struct list_head *head)
+{
+	struct ipvtap_dev *vlan = netdev_priv(dev);
+
+	netdev_rx_handler_unregister(dev);
+	tap_del_queues(&vlan->tap);
+	ipvlan_link_delete(dev, head);
+}
+
+static void ipvtap_setup(struct net_device *dev)
+{
+	ipvlan_link_setup(dev);
+	dev->tx_queue_len = TUN_READQ_SIZE;
+	dev->priv_flags &= ~IFF_NO_QUEUE;
+}
+
+static struct rtnl_link_ops ipvtap_link_ops __read_mostly = {
+	.kind		= "ipvtap",
+	.setup		= ipvtap_setup,
+	.newlink	= ipvtap_newlink,
+	.dellink	= ipvtap_dellink,
+	.priv_size	= sizeof(struct ipvtap_dev),
+};
+
+static int ipvtap_device_event(struct notifier_block *unused,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct ipvtap_dev *vlantap;
+	struct device *classdev;
+	dev_t devt;
+	int err;
+	char tap_name[IFNAMSIZ];
+
+	if (dev->rtnl_link_ops != &ipvtap_link_ops)
+		return NOTIFY_DONE;
+
+	snprintf(tap_name, IFNAMSIZ, "tap%d", dev->ifindex);
+	vlantap = netdev_priv(dev);
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		/* Create the device node here after the network device has
+		 * been registered but before register_netdevice has
+		 * finished running.
+		 */
+		err = tap_get_minor(ipvtap_major, &vlantap->tap);
+		if (err)
+			return notifier_from_errno(err);
+
+		devt = MKDEV(MAJOR(ipvtap_major), vlantap->tap.minor);
+		classdev = device_create(&ipvtap_class, &dev->dev, devt,
+					 dev, tap_name);
+		if (IS_ERR(classdev)) {
+			tap_free_minor(ipvtap_major, &vlantap->tap);
+			return notifier_from_errno(PTR_ERR(classdev));
+		}
+		err = sysfs_create_link(&dev->dev.kobj, &classdev->kobj,
+					tap_name);
+		if (err)
+			return notifier_from_errno(err);
+		break;
+	case NETDEV_UNREGISTER:
+		/* vlan->minor == 0 if NETDEV_REGISTER above failed */
+		if (vlantap->tap.minor == 0)
+			break;
+		sysfs_remove_link(&dev->dev.kobj, tap_name);
+		devt = MKDEV(MAJOR(ipvtap_major), vlantap->tap.minor);
+		device_destroy(&ipvtap_class, devt);
+		tap_free_minor(ipvtap_major, &vlantap->tap);
+		break;
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		if (tap_queue_resize(&vlantap->tap))
+			return NOTIFY_BAD;
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ipvtap_notifier_block __read_mostly = {
+	.notifier_call	= ipvtap_device_event,
+};
+
+static int ipvtap_init(void)
+{
+	int err;
+
+	err = tap_create_cdev(&ipvtap_cdev, &ipvtap_major, "ipvtap");
+
+	if (err)
+		goto out1;
+
+	err = class_register(&ipvtap_class);
+	if (err)
+		goto out2;
+
+	err = register_netdevice_notifier(&ipvtap_notifier_block);
+	if (err)
+		goto out3;
+
+	err = ipvlan_link_register(&ipvtap_link_ops);
+	if (err)
+		goto out4;
+
+	return 0;
+
+out4:
+	unregister_netdevice_notifier(&ipvtap_notifier_block);
+out3:
+	class_unregister(&ipvtap_class);
+out2:
+	cdev_del(&ipvtap_cdev);
+out1:
+	return err;
+}
+module_init(ipvtap_init);
+
+static void ipvtap_exit(void)
+{
+	rtnl_link_unregister(&ipvtap_link_ops);
+	unregister_netdevice_notifier(&ipvtap_notifier_block);
+	class_unregister(&ipvtap_class);
+	tap_destroy_cdev(ipvtap_major, &ipvtap_cdev);
+}
+module_exit(ipvtap_exit);
+MODULE_ALIAS_RTNL_LINK("ipvtap");
+MODULE_AUTHOR("Sainath Grandhi <sainath.grandhi@intel.com>");
+MODULE_LICENSE("GPL");
-- 
2.7.4
