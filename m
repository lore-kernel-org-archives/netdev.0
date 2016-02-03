From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/6] Introduce devlink infrastructure
Date: Wed,  3 Feb 2016 11:47:57 +0100
Message-ID: <1454496482-13961-2-git-send-email-jiri@resnulli.us>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34597 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbcBCKsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:48:07 -0500
Received: by mail-wm0-f65.google.com with SMTP id p63so6756897wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:48:06 -0800 (PST)
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce devlink infrastructure for drivers to register and expose to
userspace via generic Netlink interface.

There are two basic objects defined:
devlink - one instance for every "parent device", for example switch ASIC
devlink port - one instance for every physical port of the device.

This initial portion implements basic get/dump of objects to userspace.
Also, hardware message monitoring and port type setting is implemented.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 MAINTAINERS                  |   8 +
 include/net/devlink.h        | 152 ++++++++
 include/uapi/linux/devlink.h |  83 +++++
 net/Kconfig                  |   7 +
 net/core/Makefile            |   1 +
 net/core/devlink.c           | 856 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1107 insertions(+)
 create mode 100644 include/net/devlink.h
 create mode 100644 include/uapi/linux/devlink.h
 create mode 100644 net/core/devlink.c

diff --git a/MAINTAINERS b/MAINTAINERS
index f678c37..c4efa8d7 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3501,6 +3501,14 @@ F:	include/linux/device-mapper.h
 F:	include/linux/dm-*.h
 F:	include/uapi/linux/dm-*.h
 
+DEVLINK
+M:	Jiri Pirko <jiri@mellanox.com>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	net/core/devlink.c
+F:	include/net/devlink.h
+F:	include/uapi/linux/devlink.h
+
 DIALOG SEMICONDUCTOR DRIVERS
 M:	Support Opensource <support.opensource@diasemi.com>
 W:	http://www.dialog-semiconductor.com/products
diff --git a/include/net/devlink.h b/include/net/devlink.h
new file mode 100644
index 0000000..a7888e2
--- /dev/null
+++ b/include/net/devlink.h
@@ -0,0 +1,152 @@
+/*
+ * include/net/devlink.h - Network physical device Netlink interface
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef _NET_DEVLINK_H_
+#define _NET_DEVLINK_H_
+
+#include <linux/device.h>
+#include <linux/slab.h>
+#include <linux/gfp.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <net/net_namespace.h>
+#include <uapi/linux/devlink.h>
+
+struct devlink_ops;
+
+struct devlink {
+	struct list_head list;
+	struct list_head port_list;
+	int index;
+	const struct devlink_ops *ops;
+	struct device dev;
+	possible_net_t _net;
+	char priv[0] __aligned(NETDEV_ALIGN);
+};
+
+struct devlink_port {
+	struct list_head list;
+	struct devlink *devlink;
+	unsigned index;
+	enum devlink_port_type type;
+	enum devlink_port_type desired_type;
+	void *type_dev;
+};
+
+struct devlink_ops {
+	size_t priv_size;
+	int (*port_type_set)(struct devlink_port *devlink_port,
+			     enum devlink_port_type port_type);
+};
+
+static inline void *devlink_priv(struct devlink *devlink)
+{
+	BUG_ON(!devlink);
+	return &devlink->priv;
+}
+
+static inline struct devlink *priv_to_devlink(void *priv)
+{
+	BUG_ON(!priv);
+	return container_of(priv, struct devlink, priv);
+}
+
+static inline struct device *devlink_dev(struct devlink *devlink)
+{
+	return &devlink->dev;
+}
+
+static inline void set_devlink_dev(struct devlink *devlink, struct device *dev)
+{
+	devlink->dev.parent = dev;
+}
+
+static inline const char *devlink_name(const struct devlink *devlink)
+{
+	return dev_name(&devlink->dev);
+}
+
+struct ib_device;
+
+#if IS_ENABLED(CONFIG_NET_DEVLINK)
+
+struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size);
+int devlink_register(struct devlink *devlink);
+void devlink_unregister(struct devlink *devlink);
+void devlink_free(struct devlink *devlink);
+void devlink_hwmsg_notify(struct devlink *devlink,
+			  const char *buf, size_t buf_len,
+			  enum devlink_hwmsg_type type,
+			  enum devlink_hwmsg_dir dir,
+			  gfp_t gfp_mask);
+int devlink_port_register(struct devlink *devlink,
+			  struct devlink_port *devlink_port,
+			  unsigned int port_index);
+void devlink_port_unregister(struct devlink_port *devlink_port);
+void devlink_port_type_eth_set(struct devlink_port *devlink_port,
+			       struct net_device *netdev);
+void devlink_port_type_ib_set(struct devlink_port *devlink_port,
+			      struct ib_device *ibdev);
+void devlink_port_type_clear(struct devlink_port *devlink_port);
+
+#else
+
+static inline struct devlink *devlink_alloc(const struct devlink_ops *ops,
+					    size_t priv_size)
+{
+	return kzalloc(sizeof(*devlink) + priv_size, GFP_KERNEL);
+}
+
+static inline int devlink_register(struct devlink *devlink)
+{
+	return 0;
+}
+
+static inline void devlink_unregister(struct devlink *devlink)
+{
+}
+
+static inline void devlink_free(struct devlink *devlink)
+{
+	kfree(devlink);
+}
+
+static inline void devlink_hwmsg_notify(struct devlink *devlink,
+					const char *buf, size_t buf_len,
+					enum devlink_hwmsg_type type,
+					enum devlink_hwmsg_dir dir,
+					gfp_t gfp_mask)
+{
+}
+
+static inline int devlink_port_register(struct devlink *devlink,
+					struct devlink_port *devlink_port,
+					unsigned int port_index)
+{
+	return 0;
+}
+
+static inline void devlink_port_type_eth_set(struct devlink_port *devlink_port,
+					     struct net_device *netdev)
+{
+}
+
+static inline void devlink_port_type_ib_set(struct devlink_port *devlink_port,
+					    struct ib_device *ibdev)
+{
+}
+
+static inline void devlink_port_type_clear(struct devlink_port *devlink_port)
+{
+}
+
+#endif
+
+#endif /* _NET_DEVLINK_H_ */
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
new file mode 100644
index 0000000..1d9f999
--- /dev/null
+++ b/include/uapi/linux/devlink.h
@@ -0,0 +1,83 @@
+/*
+ * include/uapi/linux/devlink.h - Network physical device Netlink interface
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_DEVLINK_H_
+#define _UAPI_LINUX_DEVLINK_H_
+
+#define DEVLINK_GENL_NAME "devlink"
+#define DEVLINK_GENL_VERSION 0x1
+#define DEVLINK_GENL_MCGRP_CONFIG_NAME "config"
+#define DEVLINK_GENL_MCGRP_HWMSG_NAME "hwmsg"
+
+enum devlink_command {
+	/* don't change the order or add anything between, this is ABI! */
+	DEVLINK_CMD_UNSPEC,
+
+	DEVLINK_CMD_GET,		/* can dump */
+	DEVLINK_CMD_SET,
+	DEVLINK_CMD_NEW,
+	DEVLINK_CMD_DEL,
+
+	DEVLINK_CMD_HWMSG_NEW,
+
+	DEVLINK_CMD_PORT_GET,		/* can dump */
+	DEVLINK_CMD_PORT_SET,
+	DEVLINK_CMD_PORT_NEW,
+	DEVLINK_CMD_PORT_DEL,
+
+	/* add new commands above here */
+
+	__DEVLINK_CMD_MAX,
+	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
+};
+
+enum devlink_hwmsg_type {
+	DEVLINK_HWMSG_TYPE_TMP, /* temporary, until first message type is introduced */
+};
+
+enum devlink_hwmsg_dir {
+	DEVLINK_HWMSG_DIR_TO_HW,
+	DEVLINK_HWMSG_DIR_FROM_HW,
+};
+
+enum devlink_port_type {
+	DEVLINK_PORT_TYPE_NOTSET,
+	DEVLINK_PORT_TYPE_AUTO,
+	DEVLINK_PORT_TYPE_ETH,
+	DEVLINK_PORT_TYPE_IB,
+};
+
+enum devlink_attr {
+	/* don't change the order or add anything between, this is ABI! */
+	DEVLINK_ATTR_UNSPEC,
+
+	DEVLINK_ATTR_INDEX,			/* u32 */
+#define DEVLINK_ATTR_NAME_MAX_LEN 32
+	DEVLINK_ATTR_NAME,			/* string */
+	DEVLINK_ATTR_BUS_NAME,			/* string */
+	DEVLINK_ATTR_DEV_NAME,			/* string */
+	DEVLINK_ATTR_HWMSG_PAYLOAD,		/* data */
+	DEVLINK_ATTR_HWMSG_TYPE,		/* u32 */
+	DEVLINK_ATTR_HWMSG_DIR,			/* u8 */
+	DEVLINK_ATTR_PORT_INDEX,		/* u32 */
+	DEVLINK_ATTR_PORT_TYPE,			/* u16 */
+	DEVLINK_ATTR_PORT_DESIRED_TYPE,		/* u16 */
+	DEVLINK_ATTR_PORT_NETDEV_IFINDEX,	/* u32 */
+	DEVLINK_ATTR_PORT_NETDEV_NAME,		/* string */
+	DEVLINK_ATTR_PORT_IBDEV_NAME,		/* string */
+
+	/* add new attributes above here, update the policy in devlink.c */
+
+	__DEVLINK_ATTR_MAX,
+	DEVLINK_ATTR_MAX = __DEVLINK_ATTR_MAX - 1
+};
+
+#endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index 1743546..7e29ced 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -392,6 +392,13 @@ config LWTUNNEL
 	  weight tunnel endpoint. Tunnel encapsulation parameters are stored
 	  with light weight tunnel state associated with fib routes.
 
+config NET_DEVLINK
+	tristate "Network physical/parent device Netlink interface"
+	help
+	  Network physical/parent device Netlink interface provides
+	  infrastructure to support access to physical chip-wide config and
+	  monitoring.
+
 endif   # if NET
 
 # Used by archs to tell that they support BPF_JIT
diff --git a/net/core/Makefile b/net/core/Makefile
index 0b835de..1f200bf 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
 obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
+obj-$(CONFIG_NET_DEVLINK) += devlink.o
diff --git a/net/core/devlink.c b/net/core/devlink.c
new file mode 100644
index 0000000..da01de5
--- /dev/null
+++ b/net/core/devlink.c
@@ -0,0 +1,856 @@
+/*
+ * net/core/devlink.c - Network physical/parent device Netlink interface
+ *
+ * Heavily inspired by net/wireless/
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/gfp.h>
+#include <linux/device.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/sysfs.h>
+#include <linux/bitops.h>
+#include <rdma/ib_verbs.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <net/rtnetlink.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+#include <net/devlink.h>
+
+static LIST_HEAD(devlink_list);
+static DEFINE_MUTEX(devlink_mutex); /* protects devlink and port lists */
+
+static struct net *devlink_net(const struct devlink *devlink)
+{
+	return read_pnet(&devlink->_net);
+}
+
+static void devlink_net_set(struct devlink *devlink, struct net *net)
+{
+	write_pnet(&devlink->_net, net);
+}
+
+static bool devlink_name_exists(struct net *net, const char *name)
+{
+	struct devlink *devlink;
+
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (strcmp(devlink_name(devlink), name) == 0 &&
+		    net_eq(devlink_net(devlink), net))
+			return true;
+	}
+	return false;
+}
+
+static struct devlink *devlink_get_by_index(struct net *net, int index)
+{
+	struct devlink *devlink;
+
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (devlink->index == index &&
+		    net_eq(devlink_net(devlink), net))
+			return devlink;
+	}
+	return NULL;
+}
+
+static struct devlink *devlink_get_from_attrs(struct net *net,
+					      struct nlattr **attrs)
+{
+	if (attrs[DEVLINK_ATTR_INDEX]) {
+		u32 index = nla_get_u32(attrs[DEVLINK_ATTR_INDEX]);
+		struct devlink *devlink;
+
+		devlink = devlink_get_by_index(net, index);
+		if (!devlink)
+			return ERR_PTR(-ENODEV);
+		return devlink;
+	}
+	return ERR_PTR(-EINVAL);
+}
+
+static struct devlink *devlink_get_from_info(struct genl_info *info)
+{
+	return devlink_get_from_attrs(genl_info_net(info), info->attrs);
+}
+
+static struct devlink_port *devlink_port_get_by_index(struct devlink *devlink,
+						      int port_index)
+{
+	struct devlink_port *devlink_port;
+
+	list_for_each_entry(devlink_port, &devlink->port_list, list) {
+		if (devlink_port->index == port_index)
+			return devlink_port;
+	}
+	return NULL;
+}
+
+static bool devlink_port_index_exists(struct devlink *devlink, int port_index)
+{
+	return devlink_port_get_by_index(devlink, port_index);
+}
+
+static struct devlink_port *devlink_port_get_from_attrs(struct devlink *devlink,
+							struct nlattr **attrs)
+{
+	if (attrs[DEVLINK_ATTR_PORT_INDEX]) {
+		u32 port_index = nla_get_u32(attrs[DEVLINK_ATTR_PORT_INDEX]);
+		struct devlink_port *devlink_port;
+
+		devlink_port = devlink_port_get_by_index(devlink, port_index);
+		if (!devlink_port)
+			return ERR_PTR(-ENODEV);
+		return devlink_port;
+	}
+	return ERR_PTR(-EINVAL);
+}
+
+static struct devlink_port *devlink_port_get_from_info(struct devlink *devlink,
+						       struct genl_info *info)
+{
+	return devlink_port_get_from_attrs(devlink, info->attrs);
+}
+
+#define DEVLINK_NL_FLAG_NEED_PORT	BIT(0)
+
+static int devlink_nl_pre_doit(const struct genl_ops *ops,
+			       struct sk_buff *skb, struct genl_info *info)
+{
+	struct devlink *devlink;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	devlink = devlink_get_from_info(info);
+	if (IS_ERR(devlink)) {
+		err = PTR_ERR(devlink);
+		goto err_out;
+	}
+	info->user_ptr[0] = devlink;
+	if (ops->internal_flags & DEVLINK_NL_FLAG_NEED_PORT) {
+		struct devlink_port *devlink_port;
+
+		devlink_port = devlink_port_get_from_info(devlink, info);
+		if (IS_ERR(devlink_port)) {
+			err = PTR_ERR(devlink_port);
+			goto err_out;
+		}
+		info->user_ptr[1] = devlink_port;
+	}
+	return 0;
+
+err_out:
+	mutex_unlock(&devlink_mutex);
+	return err;
+}
+
+static void devlink_nl_post_doit(const struct genl_ops *ops,
+				 struct sk_buff *skb, struct genl_info *info)
+{
+	mutex_unlock(&devlink_mutex);
+}
+
+static struct genl_family devlink_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.name		= DEVLINK_GENL_NAME,
+	.version	= DEVLINK_GENL_VERSION,
+	.maxattr	= DEVLINK_ATTR_MAX,
+	.netnsok	= true,
+	.pre_doit	= devlink_nl_pre_doit,
+	.post_doit	= devlink_nl_post_doit,
+};
+
+enum devlink_multicast_groups {
+	DEVLINK_MCGRP_CONFIG,
+	DEVLINK_MCGRP_HWMSG,
+};
+
+static const struct genl_multicast_group devlink_nl_mcgrps[] = {
+	[DEVLINK_MCGRP_CONFIG] = { .name = DEVLINK_GENL_MCGRP_CONFIG_NAME },
+	[DEVLINK_MCGRP_HWMSG] = { .name = DEVLINK_GENL_MCGRP_HWMSG_NAME },
+};
+
+static int devlink_nl_fill(struct sk_buff *msg, struct devlink *devlink,
+			   enum devlink_command cmd, u32 portid,
+			   u32 seq, int flags)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(msg, DEVLINK_ATTR_INDEX, devlink->index))
+		goto nla_put_failure;
+	if (nla_put_string(msg, DEVLINK_ATTR_NAME, devlink_name(devlink)))
+		goto nla_put_failure;
+
+	if (devlink->dev.parent) {
+		struct device *dev = devlink->dev.parent;
+
+		if (nla_put_string(msg, DEVLINK_ATTR_BUS_NAME, dev->bus->name))
+			goto nla_put_failure;
+		if (nla_put_string(msg, DEVLINK_ATTR_DEV_NAME, dev_name(dev)))
+			goto nla_put_failure;
+	}
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static void devlink_notify(struct devlink *devlink, enum devlink_command cmd)
+{
+	struct sk_buff *msg;
+	int err;
+
+	WARN_ON(cmd != DEVLINK_CMD_NEW && cmd != DEVLINK_CMD_DEL);
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return;
+
+	err = devlink_nl_fill(msg, devlink, cmd, 0, 0, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return;
+	}
+
+	genlmsg_multicast_netns(&devlink_nl_family, devlink_net(devlink),
+				msg, 0, DEVLINK_MCGRP_CONFIG, GFP_KERNEL);
+}
+
+static int devlink_nl_port_fill(struct sk_buff *msg, struct devlink *devlink,
+				struct devlink_port *devlink_port,
+				enum devlink_command cmd, u32 portid,
+				u32 seq, int flags)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(msg, DEVLINK_ATTR_INDEX, devlink->index))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_PORT_INDEX, devlink_port->index))
+		goto nla_put_failure;
+	if (nla_put_u16(msg, DEVLINK_ATTR_PORT_TYPE, devlink_port->type))
+		goto nla_put_failure;
+	if (devlink_port->desired_type != DEVLINK_PORT_TYPE_NOTSET &&
+	    nla_put_u16(msg, DEVLINK_ATTR_PORT_DESIRED_TYPE,
+			devlink_port->desired_type))
+		goto nla_put_failure;
+	if (devlink_port->type == DEVLINK_PORT_TYPE_ETH) {
+		struct net_device *netdev = devlink_port->type_dev;
+
+		if (netdev &&
+		    (nla_put_u32(msg, DEVLINK_ATTR_PORT_NETDEV_IFINDEX,
+				 netdev->ifindex) ||
+		     nla_put_string(msg, DEVLINK_ATTR_PORT_NETDEV_NAME,
+				    netdev->name)))
+			goto nla_put_failure;
+	}
+	if (devlink_port->type == DEVLINK_PORT_TYPE_IB) {
+		struct ib_device *ibdev = devlink_port->type_dev;
+
+		if (ibdev &&
+		    nla_put_string(msg, DEVLINK_ATTR_PORT_IBDEV_NAME,
+				   ibdev->name))
+			goto nla_put_failure;
+	}
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+static void devlink_port_notify(struct devlink_port *devlink_port,
+				enum devlink_command cmd)
+{
+	struct devlink *devlink = devlink_port->devlink;
+	struct sk_buff *msg;
+	int err;
+
+	WARN_ON(cmd != DEVLINK_CMD_PORT_NEW && cmd != DEVLINK_CMD_PORT_DEL);
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return;
+
+	err = devlink_nl_port_fill(msg, devlink, devlink_port, cmd, 0, 0, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return;
+	}
+
+	genlmsg_multicast_netns(&devlink_nl_family, devlink_net(devlink),
+				msg, 0, DEVLINK_MCGRP_CONFIG, GFP_KERNEL);
+}
+
+static int devlink_hwmsg_nl_fill(struct sk_buff *msg, struct devlink *devlink,
+				 const char *buf, size_t buf_len,
+				 enum devlink_hwmsg_type type,
+				 enum devlink_hwmsg_dir dir,
+				 enum devlink_command cmd, u32 portid,
+				 u32 seq, int flags)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &devlink_nl_family, flags, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(msg, DEVLINK_ATTR_INDEX, devlink->index))
+		goto nla_put_failure;
+	if (nla_put(msg, DEVLINK_ATTR_HWMSG_PAYLOAD, buf_len, buf))
+		goto nla_put_failure;
+	if (nla_put_u32(msg, DEVLINK_ATTR_HWMSG_TYPE, type))
+		goto nla_put_failure;
+	if (nla_put_u8(msg, DEVLINK_ATTR_HWMSG_DIR, dir))
+		goto nla_put_failure;
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ *	devlink_hwmsg_notify - Send HW message notification via netlink
+ *
+ *	@devlink: devlink
+ *	@buf: HW message
+ *	@buf_len: message length
+ *	@type: message type
+ *	@dir: direction of message flow
+ *	@gfp_mask: alloc mask
+ */
+void devlink_hwmsg_notify(struct devlink *devlink,
+			  const char *buf, size_t buf_len,
+			  enum devlink_hwmsg_type type,
+			  enum devlink_hwmsg_dir dir,
+			  gfp_t gfp_mask)
+{
+	struct sk_buff *msg;
+	int err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, gfp_mask);
+	if (!msg)
+		return;
+
+	err = devlink_hwmsg_nl_fill(msg, devlink, buf, buf_len, type, dir,
+				    DEVLINK_CMD_HWMSG_NEW, 0, 0, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return;
+	}
+
+	genlmsg_multicast_netns(&devlink_nl_family, devlink_net(devlink),
+				msg, 0, DEVLINK_MCGRP_HWMSG, GFP_KERNEL);
+}
+EXPORT_SYMBOL_GPL(devlink_hwmsg_notify);
+
+static int devlink_nl_cmd_get_doit(struct sk_buff *skb, struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct sk_buff *msg;
+	int err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_fill(msg, devlink, DEVLINK_CMD_NEW,
+			      info->snd_portid, info->snd_seq, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int devlink_nl_cmd_get_dumpit(struct sk_buff *msg,
+				     struct netlink_callback *cb)
+{
+	struct devlink *devlink;
+	int start = cb->args[0];
+	int idx = 0;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)))
+			continue;
+		if (idx < start) {
+			idx++;
+			continue;
+		}
+		err = devlink_nl_fill(msg, devlink, DEVLINK_CMD_NEW,
+				      NETLINK_CB(cb->skb).portid,
+				      cb->nlh->nlmsg_seq, NLM_F_MULTI);
+		if (err)
+			goto out;
+		idx++;
+	}
+out:
+	mutex_unlock(&devlink_mutex);
+
+	cb->args[0] = idx;
+	return msg->len;
+}
+
+static int devlink_rename(struct devlink *devlink, const char *newname)
+{
+	int err;
+
+	if (strcmp(newname, devlink_name(devlink)) == 0)
+		return 0;
+	if (devlink_name_exists(devlink_net(devlink), newname))
+		return -EINVAL;
+	if (!dev_valid_name(newname))
+		return -EINVAL;
+	err = device_rename(&devlink->dev, newname);
+	if (err)
+		return err;
+	devlink_notify(devlink, DEVLINK_CMD_NEW);
+	return 0;
+}
+
+static int devlink_nl_cmd_set_doit(struct sk_buff *skb, struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	int err;
+
+	if (info->attrs[DEVLINK_ATTR_NAME]) {
+		err = devlink_rename(devlink,
+				     nla_data(info->attrs[DEVLINK_ATTR_NAME]));
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int devlink_nl_cmd_port_get_doit(struct sk_buff *skb,
+					struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_port *devlink_port = info->user_ptr[1];
+	struct sk_buff *msg;
+	int err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	err = devlink_nl_port_fill(msg, devlink, devlink_port,
+				   DEVLINK_CMD_PORT_NEW,
+				   info->snd_portid, info->snd_seq, 0);
+	if (err) {
+		nlmsg_free(msg);
+		return err;
+	}
+
+	return genlmsg_reply(msg, info);
+}
+
+static int devlink_nl_cmd_port_get_dumpit(struct sk_buff *msg,
+					  struct netlink_callback *cb)
+{
+	struct devlink *devlink;
+	struct devlink_port *devlink_port;
+	int start = cb->args[0];
+	int idx = 0;
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	list_for_each_entry(devlink, &devlink_list, list) {
+		if (!net_eq(devlink_net(devlink), sock_net(msg->sk)))
+			continue;
+		list_for_each_entry(devlink_port, &devlink->port_list, list) {
+			if (idx < start) {
+				idx++;
+				continue;
+			}
+			err = devlink_nl_port_fill(msg, devlink, devlink_port,
+						   DEVLINK_CMD_NEW,
+						   NETLINK_CB(cb->skb).portid,
+						   cb->nlh->nlmsg_seq,
+						   NLM_F_MULTI);
+			if (err)
+				goto out;
+			idx++;
+		}
+	}
+out:
+	mutex_unlock(&devlink_mutex);
+
+	cb->args[0] = idx;
+	return msg->len;
+}
+
+static int devlink_port_type_set(struct devlink *devlink,
+				 struct devlink_port *devlink_port,
+				 enum devlink_port_type port_type)
+
+{
+	int err;
+
+	if (devlink->ops && devlink->ops->port_type_set) {
+		if (port_type == DEVLINK_PORT_TYPE_NOTSET)
+			return -EINVAL;
+		err = devlink->ops->port_type_set(devlink_port, port_type);
+		if (err)
+			return err;
+		devlink_port->desired_type = port_type;
+		devlink_port_notify(devlink_port, DEVLINK_CMD_PORT_NEW);
+		return 0;
+	}
+	return -EOPNOTSUPP;
+}
+
+static int devlink_nl_cmd_port_set_doit(struct sk_buff *skb,
+					struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_port *devlink_port = info->user_ptr[1];
+	int err;
+
+	if (info->attrs[DEVLINK_ATTR_PORT_TYPE]) {
+		enum devlink_port_type port_type;
+
+		port_type = nla_get_u16(info->attrs[DEVLINK_ATTR_PORT_TYPE]);
+		err = devlink_port_type_set(devlink, devlink_port, port_type);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
+	[DEVLINK_ATTR_INDEX] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_NAME] = { .type = NLA_NUL_STRING,
+				.len = DEVLINK_ATTR_NAME_MAX_LEN },
+	[DEVLINK_ATTR_PORT_INDEX] = { .type = NLA_U32 },
+	[DEVLINK_ATTR_PORT_TYPE] = { .type = NLA_U16 },
+};
+
+static const struct genl_ops devlink_nl_ops[] = {
+	{
+		.cmd = DEVLINK_CMD_GET,
+		.doit = devlink_nl_cmd_get_doit,
+		.dumpit = devlink_nl_cmd_get_dumpit,
+		.policy = devlink_nl_policy,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = DEVLINK_CMD_SET,
+		.doit = devlink_nl_cmd_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = DEVLINK_CMD_PORT_GET,
+		.doit = devlink_nl_cmd_port_get_doit,
+		.dumpit = devlink_nl_cmd_port_get_dumpit,
+		.policy = devlink_nl_policy,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT,
+		/* can be retrieved by unprivileged users */
+	},
+	{
+		.cmd = DEVLINK_CMD_PORT_SET,
+		.doit = devlink_nl_cmd_port_set_doit,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_PORT,
+	},
+};
+
+static struct class devlink_class;
+
+/**
+ *	devlink_alloc - Allocate new devlink instance resources
+ *
+ *	@ops: ops
+ *	@priv_size: size of user private data
+ *
+ *	Allocate new devlink instance resources, including devlink index
+ *	and name.
+ */
+struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
+{
+	static atomic_t dev_counter = ATOMIC_INIT(0);
+	struct devlink *devlink;
+
+	devlink = kzalloc(sizeof(*devlink) + priv_size, GFP_KERNEL);
+	if (!devlink)
+		return NULL;
+	devlink->ops = ops;
+	devlink_net_set(devlink, &init_net);
+
+different_name:
+	devlink->index = atomic_inc_return(&dev_counter);
+	if (devlink->index < 0) {
+		/* wrapped */
+		atomic_dec(&dev_counter);
+		kfree(devlink);
+		return NULL;
+	}
+	/* atomic_inc_return makes it start at 1, make it start at 0 */
+	devlink->index--;
+
+	dev_set_name(&devlink->dev, DEVLINK_GENL_NAME "%d", devlink->index);
+	if (devlink_name_exists(devlink_net(devlink), devlink_name(devlink)))
+		goto different_name;
+
+	INIT_LIST_HEAD(&devlink->port_list);
+	device_initialize(&devlink->dev);
+	devlink->dev.class = &devlink_class;
+	devlink->dev.platform_data = devlink;
+	return devlink;
+}
+EXPORT_SYMBOL_GPL(devlink_alloc);
+
+/**
+ *	devlink_register - Register devlink instance
+ *
+ *	@devlink: devlink
+ */
+int devlink_register(struct devlink *devlink)
+{
+	int err;
+
+	mutex_lock(&devlink_mutex);
+	err = device_add(&devlink->dev);
+	if (err)
+		goto unlock;
+	list_add_tail(&devlink->list, &devlink_list);
+	devlink_notify(devlink, DEVLINK_CMD_NEW);
+unlock:
+	mutex_unlock(&devlink_mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(devlink_register);
+
+/**
+ *	devlink_unregister - Unregister devlink instance
+ *
+ *	@devlink: devlink
+ */
+void devlink_unregister(struct devlink *devlink)
+{
+	mutex_lock(&devlink_mutex);
+	devlink_notify(devlink, DEVLINK_CMD_DEL);
+	list_del(&devlink->list);
+	device_del(&devlink->dev);
+	mutex_unlock(&devlink_mutex);
+}
+EXPORT_SYMBOL_GPL(devlink_unregister);
+
+/**
+ *	devlink_free - Free devlink instance resources
+ *
+ *	@devlink: devlink
+ */
+void devlink_free(struct devlink *devlink)
+{
+	put_device(&devlink->dev);
+}
+EXPORT_SYMBOL_GPL(devlink_free);
+
+/**
+ *	devlink_port_register - Register devlink port
+ *
+ *	@devlink: devlink
+ *	@devlink_port: devlink port
+ *	@port_index
+ *
+ *	Register devlink port with provided port index. User can use
+ *	any indexing, even hw-related one. devlink_port structure
+ *	is convenient to be embedded inside user driver private structure.
+ */
+int devlink_port_register(struct devlink *devlink,
+			  struct devlink_port *devlink_port,
+			  unsigned int port_index)
+{
+	mutex_lock(&devlink_mutex);
+	if (devlink_port_index_exists(devlink, port_index)) {
+		mutex_unlock(&devlink_mutex);
+		return -EEXIST;
+	}
+	devlink_port->devlink = devlink;
+	devlink_port->index = port_index;
+	devlink_port->type = DEVLINK_PORT_TYPE_NOTSET;
+	list_add_tail(&devlink_port->list, &devlink->port_list);
+	mutex_unlock(&devlink_mutex);
+	devlink_port_notify(devlink_port, DEVLINK_CMD_PORT_NEW);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devlink_port_register);
+
+/**
+ *	devlink_port_unregister - Unregister devlink port
+ *
+ *	@devlink_port: devlink port
+ */
+void devlink_port_unregister(struct devlink_port *devlink_port)
+{
+	devlink_port_notify(devlink_port, DEVLINK_CMD_PORT_DEL);
+	mutex_lock(&devlink_mutex);
+	list_del(&devlink_port->list);
+	mutex_unlock(&devlink_mutex);
+}
+EXPORT_SYMBOL_GPL(devlink_port_unregister);
+
+static void __devlink_port_type_set(struct devlink_port *devlink_port,
+				    enum devlink_port_type type,
+				    void *type_dev)
+{
+	devlink_port->type = type;
+	devlink_port->type_dev = type_dev;
+	devlink_port_notify(devlink_port, DEVLINK_CMD_PORT_NEW);
+}
+
+/**
+ *	devlink_port_type_eth_set - Set port type to Ethernet
+ *
+ *	@devlink_port: devlink port
+ *	@netdev: related netdevice
+ */
+void devlink_port_type_eth_set(struct devlink_port *devlink_port,
+			       struct net_device *netdev)
+{
+	return __devlink_port_type_set(devlink_port,
+				       DEVLINK_PORT_TYPE_ETH, netdev);
+}
+EXPORT_SYMBOL_GPL(devlink_port_type_eth_set);
+
+/**
+ *	devlink_port_type_ib_set - Set port type to InfiniBand
+ *
+ *	@devlink_port: devlink port
+ *	@ibdev: related IB device
+ */
+void devlink_port_type_ib_set(struct devlink_port *devlink_port,
+			      struct ib_device *ibdev)
+{
+	return __devlink_port_type_set(devlink_port,
+				       DEVLINK_PORT_TYPE_IB, ibdev);
+}
+EXPORT_SYMBOL_GPL(devlink_port_type_ib_set);
+
+/**
+ *	devlink_port_type_clear - Clear port type
+ *
+ *	@devlink_port: devlink port
+ */
+void devlink_port_type_clear(struct devlink_port *devlink_port)
+{
+	return __devlink_port_type_set(devlink_port,
+				       DEVLINK_PORT_TYPE_NOTSET, NULL);
+}
+EXPORT_SYMBOL_GPL(devlink_port_type_clear);
+
+static void __devlink_free(struct devlink *devlink)
+{
+	kfree(devlink);
+}
+
+static struct devlink *dev_to_devlink(struct device *dev)
+{
+	return container_of(dev, struct devlink, dev);
+}
+
+static ssize_t index_show(struct device *dev,
+			  struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%d\n", dev_to_devlink(dev)->index);
+}
+static DEVICE_ATTR_RO(index);
+
+static ssize_t name_show(struct device *dev,
+			 struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%s\n", dev_name(dev));
+}
+static DEVICE_ATTR_RO(name);
+
+static struct attribute *devlink_attrs[] = {
+	&dev_attr_index.attr,
+	&dev_attr_name.attr,
+	NULL,
+};
+ATTRIBUTE_GROUPS(devlink);
+
+static void devlink_dev_release(struct device *dev)
+{
+	__devlink_free(dev_to_devlink(dev));
+}
+
+static const void *devlink_namespace(struct device *dev)
+{
+	return devlink_net(dev_to_devlink(dev));
+}
+
+static struct class devlink_class = {
+	.name = DEVLINK_GENL_NAME,
+	.owner = THIS_MODULE,
+	.dev_release = devlink_dev_release,
+	.dev_groups = devlink_groups,
+	.ns_type = &net_ns_type_operations,
+	.namespace = devlink_namespace,
+};
+
+static int __init devlink_module_init(void)
+{
+	int err;
+
+	err = class_register(&devlink_class);
+	if (err)
+		return err;
+	err = genl_register_family_with_ops_groups(&devlink_nl_family,
+						   devlink_nl_ops,
+						   devlink_nl_mcgrps);
+	if (err)
+		goto err_genl_register;
+	return 0;
+
+err_genl_register:
+	class_unregister(&devlink_class);
+	return err;
+}
+
+static void __exit devlink_module_exit(void)
+{
+	genl_unregister_family(&devlink_nl_family);
+	class_unregister(&devlink_class);
+}
+
+module_init(devlink_module_init);
+module_exit(devlink_module_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Jiri Pirko <jiri@mellanox.com>");
+MODULE_DESCRIPTION("Network physical device Netlink interface");
+MODULE_ALIAS_GENL_FAMILY(DEVLINK_GENL_NAME);
-- 
1.9.3
