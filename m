From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: [patch net-next RFC v2 6/6] net: introduce dummy switch
Date: Wed, 26 Mar 2014 17:31:12 +0100
Message-ID: <1395851472-10524-7-git-send-email-jiri@resnulli.us>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
 jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Dummy switch implementation using switchdev API

Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
---
 drivers/net/Kconfig          |   7 ++
 drivers/net/Makefile         |   1 +
 drivers/net/dummyswitch.c    | 235 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h |   9 ++
 4 files changed, 252 insertions(+)
 create mode 100644 drivers/net/dummyswitch.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 89402c3..a9629a7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -71,6 +71,13 @@ config DUMMY
 	  To compile this driver as a module, choose M here: the module
 	  will be called dummy.
 
+config NET_DUMMY_SWITCH
+	tristate "Dummy switch net driver support"
+	depends on NET_SWITCHDEV
+	---help---
+	  To compile this driver as a module, choose M here: the module
+	  will be called dummyswitch.
+
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
 	---help---
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..d5d4ce6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -7,6 +7,7 @@
 #
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_DUMMY) += dummy.o
+obj-$(CONFIG_NET_DUMMY_SWITCH) += dummyswitch.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
diff --git a/drivers/net/dummyswitch.c b/drivers/net/dummyswitch.c
new file mode 100644
index 0000000..58c65a9
--- /dev/null
+++ b/drivers/net/dummyswitch.c
@@ -0,0 +1,235 @@
+/*
+ * drivers/net/dummyswitch.c - Dummy switch device
+ * Copyright (c) 2014 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/moduleparam.h>
+#include <linux/etherdevice.h>
+#include <linux/switchdev.h>
+
+#include <net/rtnetlink.h>
+
+/*
+ * Dummy switch
+ */
+
+static void dummysw_uninit(struct net_device *dev)
+{
+	__swdev_unregister(dev);
+}
+
+static netdev_tx_t dummysw_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static int dummysw_flow_insert(struct net_device *dev, struct sw_flow *flow)
+{
+	netdev_dbg(dev, "Flow inserted");
+	return 0;
+}
+static int dummysw_flow_remove(struct net_device *dev, struct sw_flow *flow)
+{
+	netdev_dbg(dev, "Flow removed");
+	return 0;
+}
+
+static const struct net_device_ops dummysw_netdev_ops = {
+	.ndo_uninit		= dummysw_uninit,
+	.ndo_start_xmit		= dummysw_xmit,
+	.ndo_swdev_flow_insert	= dummysw_flow_insert,
+	.ndo_swdev_flow_remove	= dummysw_flow_remove,
+};
+
+static void dummysw_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	/* Initialize the device structure. */
+	dev->netdev_ops = &dummysw_netdev_ops;
+	dev->destructor = free_netdev;
+
+	/* Fill in device structure with ethernet-generic values. */
+	dev->tx_queue_len = 0;
+	dev->flags |= IFF_NOARP;
+	dev->flags &= ~IFF_MULTICAST;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
+	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
+	eth_hw_addr_random(dev);
+}
+
+static int dummysw_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
+static int dummysw_newlink(struct net *src_net, struct net_device *dev,
+			   struct nlattr *tb[], struct nlattr *data[])
+{
+	int err;
+
+	err = register_netdevice(dev);
+	if (err)
+		return err;
+	err = __swdev_register(dev);
+	if (err)
+		goto err_swdev_register;
+	netif_carrier_on(dev);
+	return 0;
+
+err_swdev_register:
+	unregister_netdevice(dev);
+	return err;
+}
+
+static struct rtnl_link_ops dummysw_link_ops __read_mostly = {
+	.kind		= "dummysw",
+	.setup		= dummysw_setup,
+	.validate	= dummysw_validate,
+	.newlink	= dummysw_newlink,
+};
+
+
+/*
+ * Dummy switch port
+ */
+
+static void dummyswport_uninit(struct net_device *dev)
+{
+	__swportdev_unregister(dev);
+}
+
+static netdev_tx_t dummyswport_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops dummyswport_netdev_ops = {
+	.ndo_uninit		= dummyswport_uninit,
+	.ndo_start_xmit		= dummyswport_xmit,
+};
+
+static void dummyswport_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	/* Initialize the device structure. */
+	dev->netdev_ops = &dummyswport_netdev_ops;
+	dev->destructor = free_netdev;
+
+	/* Fill in device structure with ethernet-generic values. */
+	dev->tx_queue_len = 0;
+	dev->flags |= IFF_NOARP;
+	dev->flags &= ~IFF_MULTICAST;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
+	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
+}
+
+static int dummyswport_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS])
+		return -EINVAL;
+	if (!data || !data[IFLA_DUMMYSWPORT_MASTER])
+		return -EINVAL;
+	return 0;
+}
+
+static int dummyswport_newlink(struct net *src_net, struct net_device *dev,
+			       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_device *switch_dev;
+	uint32_t switch_ifindex;
+	int err;
+
+	switch_ifindex = nla_get_u32(data[IFLA_DUMMYSWPORT_MASTER]);
+	switch_dev = __dev_get_by_index(dev_net(dev), switch_ifindex);
+	if (!switch_dev)
+		return -ENODEV;
+	if (!swdev_dev_check(switch_dev))
+		return -EOPNOTSUPP;
+
+	err = register_netdevice(dev);
+	if (err)
+		return err;
+	err = __swportdev_register(dev, switch_dev);
+	if (err)
+		goto err_swportdev_register;
+
+	memcpy(dev->dev_addr, switch_dev->dev_addr, dev->addr_len);
+	dev->addr_assign_type = NET_ADDR_STOLEN;
+	netif_carrier_on(dev);
+
+	return 0;
+
+err_swportdev_register:
+	unregister_netdevice(dev);
+	return err;
+}
+
+static const struct nla_policy dummyswport_policy[IFLA_DUMMYSWPORT_MAX + 1] = {
+	[IFLA_DUMMYSWPORT_MASTER] = { .type = NLA_U32 },
+};
+
+static struct rtnl_link_ops dummyswport_link_ops __read_mostly = {
+	.kind		= "dummyswport",
+	.setup		= dummyswport_setup,
+	.validate	= dummyswport_validate,
+	.newlink	= dummyswport_newlink,
+	.policy		= dummyswport_policy,
+	.maxtype	= IFLA_DUMMYSWPORT_MAX,
+};
+
+
+/*
+ * Module init/exit
+ */
+
+static int __init dummysw_module_init(void)
+{
+	int err;
+
+	err = rtnl_link_register(&dummysw_link_ops);
+	if (err)
+		return err;
+	err = rtnl_link_register(&dummyswport_link_ops);
+	if (err)
+		goto err_rtnl_link_register;
+	return 0;
+
+err_rtnl_link_register:
+	rtnl_link_unregister(&dummysw_link_ops);
+	return err;
+}
+
+static void __exit dummysw_module_exit(void)
+{
+	rtnl_link_unregister(&dummyswport_link_ops);
+	rtnl_link_unregister(&dummysw_link_ops);
+}
+
+module_init(dummysw_module_init);
+module_exit(dummysw_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>");
+MODULE_DESCRIPTION("Dummy switch device");
+MODULE_ALIAS_RTNL_LINK("dummysw");
+MODULE_ALIAS_RTNL_LINK("dummyswport");
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 16410b6..ec14dd3 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -544,4 +544,13 @@ enum {
 
 #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
 
+/* DUMMYSWPORT section */
+enum {
+	IFLA_DUMMYSWPORT_UNSPEC,
+	IFLA_DUMMYSWPORT_MASTER,
+	__IFLA_DUMMYSWPORT_MAX,
+};
+
+#define IFLA_DUMMYSWPORT_MAX (__IFLA_DUMMYSWPORT_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
-- 
1.8.5.3
