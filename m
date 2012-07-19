From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues
 (VMDQ)
Date: Thu, 19 Jul 2012 08:42:58 +0200
Message-ID: <20120719064258.GA1665@minipsycho.orion>
References: <20120718220544.22619.97136.stgit@i40e.jf1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: or.gerlitz@gmail.com, davem@davemloft.net, roland@kernel.org,
	netdev@vger.kernel.org, ali@mellanox.com, sean.hefty@intel.com,
	shlomop@mellanox.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:38912 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab2GSGnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 02:43:03 -0400
Received: by wgbdr13 with SMTP id dr13so2080149wgb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 23:43:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120718220544.22619.97136.stgit@i40e.jf1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 19, 2012 at 12:05:44AM CEST, john.r.fastabend@intel.com wrote:
>This adds support to allow virtual net devices to be created. These
>devices can be managed independtly of the physical function but
>use the same physical link.
>
>This is analagous to an offloaded macvlan device. The primary
>advantage to VMDQ net devices over virtual functions is they can
>be added and removed dynamically as needed.
>
>Sending this for Or Gerlitz to take a peak at and see if this
>could be used for his ipoib bits. Its not pretty as is and
>likely needs some work its just an idea at this point use at
>your own risk I believe it compiles.
>---
>
> drivers/net/Kconfig       |    7 ++
> drivers/net/Makefile      |    1 
> drivers/net/vmdq.c        |  130 +++++++++++++++++++++++++++++++++++++++++++++
> include/linux/netdevice.h |    6 ++
> include/net/rtnetlink.h   |    2 +
> net/core/rtnetlink.c      |   10 +++
> 6 files changed, 155 insertions(+), 1 deletions(-)
> create mode 100644 drivers/net/vmdq.c
>
>diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>index 0c2bd80..f28d951 100644
>--- a/drivers/net/Kconfig
>+++ b/drivers/net/Kconfig
>@@ -337,6 +337,13 @@ config VMXNET3
> 	  To compile this driver as a module, choose M here: the
> 	  module will be called vmxnet3.
> 
>+config VMDQ 
>+	tristate "Support Embedded bridge devices and child devices"
>+	help
>+	  This supports chipsets with embedded switching components and
>+	  allows us to create more net_devices that are logically slaves
>+	  of a master net device.
>+
> source "drivers/net/hyperv/Kconfig"
> 
> endif # NETDEVICES
>diff --git a/drivers/net/Makefile b/drivers/net/Makefile
>index 3d375ca..1eb5605 100644
>--- a/drivers/net/Makefile
>+++ b/drivers/net/Makefile
>@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_TEAM) += team/
> obj-$(CONFIG_TUN) += tun.o
> obj-$(CONFIG_VETH) += veth.o
> obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
>+obj-$(CONFIG_VMDQ) += vmdq.o
> 
> #
> # Networking Drivers
>diff --git a/drivers/net/vmdq.c b/drivers/net/vmdq.c
>new file mode 100644
>index 0000000..9acc429
>--- /dev/null
>+++ b/drivers/net/vmdq.c
>@@ -0,0 +1,130 @@
>+/*******************************************************************************
>+
>+  vmdq - Support virtual machine device queues (VMDQ)
>+  Copyright(c) 2012 Intel Corporation.
>+
>+  This program is free software; you can redistribute it and/or modify it
>+  under the terms and conditions of the GNU General Public License,
>+  version 2, as published by the Free Software Foundation.
>+
>+  This program is distributed in the hope it will be useful, but WITHOUT
>+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
>+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
>+  more details.
>+
>+  You should have received a copy of the GNU General Public License along with
>+  this program; if not, write to the Free Software Foundation, Inc.,
>+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
>+
>+  The full GNU General Public License is included in this distribution in
>+  the file called "COPYING".
>+
>+  Contact Information:
>+  John Fastabend <john.r.fastabend@intel.com>
>+
>+*******************************************************************************/
>+
>+#include <linux/module.h>
>+#include <net/rtnetlink.h>
>+#include <linux/etherdevice.h>
>+
>+static int vmdq_newlink(struct net *src_net, struct net_device *dev,
>+		       struct nlattr *tb[], struct nlattr *data[])
>+{
>+	struct net_device *lowerdev;
>+	int err = -EOPNOTSUPP;
>+
>+	if (!tb[IFLA_LINK])
>+		return -EINVAL;
>+
>+	lowerdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
>+	if (!lowerdev)
>+		return -ENODEV;
>+
>+	if (!tb[IFLA_MTU])
>+		dev->mtu = lowerdev->mtu;
>+	else if (dev->mtu > lowerdev->mtu)
>+		return -EINVAL;
>+
>+	if (lowerdev->netdev_ops->ndo_add_vmdq)
>+		err = lowerdev->netdev_ops->ndo_add_vmdq(lowerdev, dev);
>+
>+	if (err < 0)
>+		return err;
>+
>+	err = register_netdevice(dev);
>+	if (err < 0)
>+		lowerdev->netdev_ops->ndo_del_vmdq(lowerdev, dev);
>+	else
>+		netif_stacked_transfer_operstate(lowerdev, dev);
>+
>+	return err;
>+}
>+
>+void vmdq_dellink(struct net_device *dev, struct list_head *head)
>+{
>+	struct net_device *lowerdev = __dev_get_by_index(dev_net(dev), dev->iflink);
>+
>+	if (lowerdev && lowerdev->netdev_ops->ndo_del_vmdq)
>+		lowerdev->netdev_ops->ndo_del_vmdq(lowerdev, dev);		
>+}
>+
>+static void vmdq_setup(struct net_device *dev)
>+{
>+	ether_setup(dev);
>+}
>+
>+size_t vmdq_getpriv_size(struct net *src_net, struct nlattr *tb[])
>+{
>+	struct net_device *lowerdev;
>+
>+	if (!tb[IFLA_LINK])
>+		return -EINVAL;
>+
>+	lowerdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
>+	if (!lowerdev)
>+		return -ENODEV;
>+
>+	return sizeof(netdev_priv(lowerdev));
>+}

Why exactly do you need to have the priv of same size as lowerdev? I do
not see you use that anywhere...
	
>+
>+int vmdq_get_tx_queues(struct net *net, struct nlattr *tb[])
>+{
>+	struct net_device *lowerdev;
>+
>+	if (!tb[IFLA_LINK])
>+		return -EINVAL;
>+
>+	lowerdev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
>+	if (!lowerdev)
>+		return -ENODEV;
>+
>+	return lowerdev->num_tx_queues;
>+}
>+
>+static struct rtnl_link_ops vmdq_link_ops __read_mostly = {
>+	.kind		= "vmdq",
>+	.setup		= vmdq_setup,
>+	.newlink	= vmdq_newlink,
>+	.dellink	= vmdq_dellink,
>+	.get_priv_size	= vmdq_getpriv_size,
>+	.get_tx_queues	= vmdq_get_tx_queues,
>+};
>+
>+static int __init vmdq_init_module(void)
>+{
>+	return rtnl_link_register(&vmdq_link_ops);
>+}
>+
>+static void __exit vmdq_cleanup_module(void)
>+{
>+	rtnl_link_unregister(&vmdq_link_ops);
>+}
>+
>+module_init(vmdq_init_module);
>+module_exit(vmdq_cleanup_module);
>+
>+MODULE_LICENSE("GPL");
>+MODULE_AUTHOR("John Fastabend <john.r.fastabend@intel.com>");
>+MODULE_DESCRIPTION("Driver for embedded switch chipsets");
>+MODULE_ALIAS_RTNL_LINK("vmdq");
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index ab0251d..d879c4d 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -972,6 +972,12 @@ struct net_device_ops {
> 						   struct nlattr *port[]);
> 	int			(*ndo_get_vf_port)(struct net_device *dev,
> 						   int vf, struct sk_buff *skb);
>+
>+	int			(*ndo_add_vmdq)(struct net_device *lowerdev,
>+						struct net_device *dev);
>+	int			(*ndo_del_vmdq)(struct net_device *lowerdev,
>+						struct net_device *dev);
>+
> 	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
> #if IS_ENABLED(CONFIG_FCOE)
> 	int			(*ndo_fcoe_enable)(struct net_device *dev);
>diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
>index bbcfd09..e9f903c 100644
>--- a/include/net/rtnetlink.h
>+++ b/include/net/rtnetlink.h
>@@ -79,6 +79,8 @@ struct rtnl_link_ops {
> 					       const struct net_device *dev);
> 	int			(*get_tx_queues)(struct net *net,
> 						 struct nlattr *tb[]);
>+	size_t			(*get_priv_size)(struct net *net,
>+						 struct nlattr *tb[]);
> };
> 
> extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index 2b325c3..2e33b9a 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -1627,6 +1627,7 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
> 	int err;
> 	struct net_device *dev;
> 	unsigned int num_queues = 1;
>+	size_t priv_size = ops->priv_size;
> 
> 	if (ops->get_tx_queues) {
> 		err = ops->get_tx_queues(src_net, tb);
>@@ -1635,8 +1636,15 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
> 		num_queues = err;
> 	}
> 
>+	if (ops->get_priv_size) {
>+		err = ops->get_priv_size(src_net, tb);
>+		if (err < 0)
>+			goto err;
>+		priv_size = err;
>+	}
>+
> 	err = -ENOMEM;
>-	dev = alloc_netdev_mq(ops->priv_size, ifname, ops->setup, num_queues);
>+	dev = alloc_netdev_mq(priv_size, ifname, ops->setup, num_queues);
> 	if (!dev)
> 		goto err;
> 
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
