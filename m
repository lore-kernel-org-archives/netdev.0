From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 3/4] net: VSI: Add virtual station interface support
Date: Wed, 11 Sep 2013 11:47:19 -0700
Message-ID: <20130911184718.26914.98366.stgit@nitbit.x32>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, john.ronciak@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:56021 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab3IKSri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:47:38 -0400
Received: by mail-oa0-f49.google.com with SMTP id i7so9783735oag.36
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:47:37 -0700 (PDT)
In-Reply-To: <20130911184441.26914.10336.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a new device type VSI (virtual station
interface) this device type exposes additional net devices complete
with queues and a MAC/VLAN pair to the host OS that are logically
stacked on top of a switching/routing component with the physical
link acting as the downlink to the peer switch.

The hardware on receive path will forward packets to the new VSI
net device using the forwarding database (FDB) already exposed via
the ndo ops ndo_fdb_{add|del|dump}. On transmit the hardware may
use either a VEB or VEPA. In the VEB case traffic may be "switched"
between VSI net devices by the hardware and in VEPA case all traffic
is sent to the adjacent switch. The hardware _should_ expose this
functionality via the ndo_bridge_{set|get}link ndo operations.

This net device should be functionally analogous to an offloaded
macvlan device with the ebridge component offloaded into hardware.

Also notice that for now the ixgbe implementation accompanying this
patch set only supports L2 forwarding the fdb interfaces could push
L3/L4 forwarding to the hardware for more advanced usages including
vxlan and other tunnel schemes.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/Kconfig       |    9 +++
 drivers/net/Makefile      |    1 
 drivers/net/vsi.c         |  124 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h |   27 ++++++++++
 include/uapi/linux/if.h   |    1 
 5 files changed, 162 insertions(+)
 create mode 100644 drivers/net/vsi.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b45b240..19be0fb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -362,4 +362,13 @@ config VMXNET3
 
 source "drivers/net/hyperv/Kconfig"
 
+config VSI
+	tristate "Virtual Station Interfaces (VSI)"
+	help
+	  This supports chip sets with embedded switching components
+	  and allows creating additional net devices that are
+	  logically slaves of a master net device typically the net
+	  device associated with the physical function. For these
+	  child devices switching occurs in the hardware component.
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..3ef1d66 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
 obj-$(CONFIG_NLMON) += nlmon.o
+obj-$(CONFIG_VSI) += vsi.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/vsi.c b/drivers/net/vsi.c
new file mode 100644
index 0000000..e9d39da
--- /dev/null
+++ b/drivers/net/vsi.c
@@ -0,0 +1,124 @@
+/*
+ * VSI - Virtual Sstation Interface
+ * Copyright(c) 2013 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * John Fastabend <john.r.fastabend@intel.com>
+ */
+#include <linux/module.h>
+#include <net/rtnetlink.h>
+#include <linux/etherdevice.h>
+
+size_t vsi_priv_size(struct net *src_net, struct nlattr *tb[])
+{
+	struct net_device *dev;
+	size_t size = 0;
+
+	if (!tb[IFLA_LINK])
+		return 0;
+
+	dev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	if (!dev)
+		return -ENODEV;
+
+	if (dev->netdev_ops->ndo_vsi_size)
+		size = dev->netdev_ops->ndo_vsi_size(dev);
+	return size;
+}
+
+static int vsi_newlink(struct net *src_net, struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_device *lower;
+	int err;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+
+	lower = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	if (!lower)
+		return -ENODEV;
+
+	if (!tb[IFLA_MTU])
+		dev->mtu = lower->mtu;
+	else if (lower->mtu > dev->mtu)
+		return -EINVAL;
+
+	dev->priv_flags |= IFF_VSI_PORT;
+	err = lower->netdev_ops->ndo_vsi_add(lower, dev);
+	if (err < 0)
+		return err;
+
+	err = netdev_upper_dev_link(lower, dev);
+	if (err)
+		goto destroy_port;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto upper_dev_unlink;
+
+	netif_stacked_transfer_operstate(lower, dev);
+	return 0;
+upper_dev_unlink:
+	netdev_upper_dev_unlink(lower, dev);
+destroy_port:
+	if (lower->netdev_ops->ndo_vsi_del)
+		lower->netdev_ops->ndo_vsi_del(dev);
+	return err;
+}
+
+void vsi_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net_device *lower;
+	struct list_head *iter;
+
+	netdev_for_each_lower_dev_rcu(dev, lower, iter) {
+		if (lower->netdev_ops->ndo_vsi_del)
+			lower->netdev_ops->ndo_vsi_del(dev);
+		netdev_upper_dev_unlink(lower, dev);
+	}
+
+	unregister_netdevice_queue(dev, head);
+}
+
+static struct rtnl_link_ops vsi_link_ops __read_mostly = {
+	.kind		= "vsi",
+	.priv_size	= vsi_priv_size,
+	.setup		= ether_setup,
+	.newlink	= vsi_newlink,
+	.dellink	= vsi_dellink,
+};
+
+static int __init vsi_init_module(void)
+{
+	return rtnl_link_register(&vsi_link_ops);
+}
+
+static void __exit vsi_cleanup_module(void)
+{
+	rtnl_link_unregister(&vsi_link_ops);
+}
+
+module_init(vsi_init_module);
+module_exit(vsi_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("John Fastabend <john.r.fastabend@intel.com>");
+MODULE_DESCRIPTION("Virutal Station Interfaces (VSI)");
+MODULE_ALIAS_RTNL_LINK("vsi");
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4d24b38..9817745 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -961,6 +961,24 @@ struct netdev_phys_port_id {
  *	Called by vxlan to notify the driver about a UDP port and socket
  *	address family that vxlan is not listening to anymore. The operation
  *	is protected by the vxlan_net->sock_lock.
+ *
+ * int (*ndo_vsi_add)(struct net_device *lower, struct net_device *dev)
+ *	Called by the virtual station interface (VSI) link type to add a new
+ *	net device 'dev' to an embedded switch where the embedded switch
+ *	management net device is identified by 'lower'. This should return
+ *	0 on success or may return negative error codes. Error codes should
+ *	be used here to signify resource constraints, unsupportable attributes,
+ *	or any other condition which caused the creation to fail.
+ * void (*ndo_vsi_del)(struct net_device *dev)
+ *	Called by the virtual station interface (VSI) link type to remove the
+ *	net device 'dev' from an embedded switch. Drivers may not fail this
+ *	command.
+ * size_t (*ndo_vsi_size)(struct net_device *dev)
+ *	Called by the virtual station interface (VSI) link type to add the
+ *	required private size to a VSI interface that is being created. If
+ *	this routine is not implemented size_t 0 is used. The 'dev' argument
+ *	indicates the embedded switch management interface where the new
+ *	net devices is being attached.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1097,6 +1115,10 @@ struct net_device_ops {
 	void			(*ndo_del_vxlan_port)(struct  net_device *dev,
 						      sa_family_t sa_family,
 						      __u16 port);
+	int			(*ndo_vsi_add)(struct net_device *lower,
+					       struct net_device *dev);
+	void			(*ndo_vsi_del)(struct net_device *dev);
+	size_t			(*ndo_vsi_size)(struct net_device *dev);
 };
 
 /*
@@ -2967,6 +2989,11 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
+static inline bool netif_is_vsi_port(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_VSI_PORT;
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..9b8d6a0 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,7 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
+#define IFF_VSI_PORT 0x200000		/* Virtual Station Interface port */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
