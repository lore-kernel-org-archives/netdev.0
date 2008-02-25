From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] ethtool netlink interface
Date: Mon, 25 Feb 2008 14:04:56 +0100
Message-ID: <20080225130456.GD20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39275 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962AbYBYNEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 08:04:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Before I continue to finish this work I'd like to get a few comments
on my implementation attempt.

The following patch implements the ETHTOOL_SSET and ETHTOOL_GSET
command via netlink. The individual commands are implemented as
separate functions and hooked into a table holding a validate,
set and fill function for each command. Additionaly an entry must
be made in the attribute policy to validate attributes when received.

Each ethtool command bundle is stored as a nested attribute in
the regular link netlink message, therefore, unlike the ioctl
interface, multiple ethtool commands can be issued in the same
message allowing for links to be fully configured with a single
message.

There is one big disadvantage: Due to the nature of ioctl it is
basically not possible to share any code between the ioctl and
neltink implementation therefore it implies duplicating code
unless we want to do the same hack as fib fronted by constructing
netlink messages inside the kernel.

Index: net-2.6.26/include/linux/if_link.h
===================================================================
--- net-2.6.26.orig/include/linux/if_link.h	2008-02-22 14:13:22.000000000 +0100
+++ net-2.6.26/include/linux/if_link.h	2008-02-22 14:40:24.000000000 +0100
@@ -79,6 +79,7 @@
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
+	IFLA_ETHTOOL,
 	__IFLA_MAX
 };
 
Index: net-2.6.26/net/core/ethtool.c
===================================================================
--- net-2.6.26.orig/net/core/ethtool.c	2008-02-22 14:13:22.000000000 +0100
+++ net-2.6.26/net/core/ethtool.c	2008-02-25 13:51:23.000000000 +0100
@@ -18,6 +18,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <asm/uaccess.h>
+#include <net/rtnetlink.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -977,6 +978,136 @@
 	return rc;
 }
 
+static int validate_settings(struct net_device *dev, struct nlattr *attr)
+{
+	if (!dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+static int set_settings(struct net_device *dev, struct nlattr *attr)
+{
+	return dev->ethtool_ops->set_settings(dev, nla_data(attr));
+}
+
+static int fill_settings(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	int err;
+
+	if (!ops->get_settings)
+		return 0;
+
+	if ((err = ops->get_settings(dev, &cmd)) < 0)
+		return err;
+
+	return nla_put(skb, IFLA_ET_SETTINGS, sizeof(cmd), &cmd);
+}
+
+static struct {
+	int (*validate)(struct net_device *, struct nlattr *);
+	int (*exec)(struct net_device *, struct nlattr *);
+	int (*fill)(struct sk_buff *, struct net_device *);
+} nlops[IFLA_ET_MAX+1] = {
+	[IFLA_ET_SETTINGS] = { .validate = validate_settings,
+			       .exec	 = set_settings,
+			       .fill	 = fill_settings, },
+};
+
+static const struct nla_policy ethtool_policy[IFLA_ET_MAX+1] = {
+	[IFLA_ET_SETTINGS]	= { .len = sizeof(struct ethtool_cmd) },
+};
+
+int ethtool_validate_nlattr(struct net_device *dev, struct nlattr *cfg)
+{
+	const struct ethtool_ops *ops;
+	struct nlattr *attr;
+	int err, remaining = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	if (!(ops = dev->ethtool_ops))
+		return -EOPNOTSUPP;
+
+	if ((err = nla_validate_nested(cfg, IFLA_ET_MAX, ethtool_policy)) < 0)
+		goto errout;
+
+	nla_for_each_nested(attr, cfg, remaining) {
+		if (nlops[attr->nla_type].validate) {
+			err = nlops[attr->nla_type].validate(dev, attr);
+			if (err < 0)
+				goto errout;
+		}
+	}
+
+errout:
+	return err;
+}
+
+int ethtool_execute_nlattr(struct net_device *dev, struct nlattr *et_attr)
+{
+	const struct ethtool_ops *ops = dev->ethtool_ops;
+	struct nlattr *attr;
+	unsigned long old_features;
+	int err, remaining = 0;
+
+	if (ops->begin && (err = ops->begin(dev)) < 0)
+		return err;
+
+	old_features = dev->features;
+
+	nla_for_each_nested(attr, et_attr, remaining) {
+		if (nlops[attr->nla_type].exec) {
+			if ((err = nlops[attr->nla_type].exec(dev, attr)) < 0)
+				goto errout;
+		}
+	}
+
+	err = 0;
+errout:
+	if (ops->complete)
+		ops->complete(dev);
+
+	if (old_features != dev->features)
+		netdev_features_change(dev);
+
+	return err;
+}
+
+int ethtool_fill_nlattr(struct sk_buff *skb, struct net_device *dev)
+{
+	struct nlattr *attr;
+	int nfilled = 0, i, err = -EMSGSIZE;
+
+	if (!(attr = nla_nest_start(skb, IFLA_ETHTOOL)))
+		goto errout;
+
+	for (i = 1; i <= IFLA_ET_MAX; i++) {
+		if (nlops[i].fill) {
+			if ((err = nlops[i].fill(skb, dev)) < 0)
+				goto nla_put_failure;
+			nfilled++;
+		}
+	}
+
+	if (nfilled == 0)
+		nla_nest_cancel(skb, attr);
+	else
+		nla_nest_end(skb, attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, attr);
+errout:
+	return err;
+}
+
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_sg);
 EXPORT_SYMBOL(ethtool_op_get_tso);
@@ -990,3 +1121,6 @@
 EXPORT_SYMBOL(ethtool_op_get_ufo);
 EXPORT_SYMBOL(ethtool_op_set_flags);
 EXPORT_SYMBOL(ethtool_op_get_flags);
+EXPORT_SYMBOL(ethtool_validate_nlattr);
+EXPORT_SYMBOL(ethtool_execute_nlattr);
+EXPORT_SYMBOL(ethtool_fill_nlattr);
Index: net-2.6.26/net/core/rtnetlink.c
===================================================================
--- net-2.6.26.orig/net/core/rtnetlink.c	2008-02-22 14:13:22.000000000 +0100
+++ net-2.6.26/net/core/rtnetlink.c	2008-02-22 14:41:33.000000000 +0100
@@ -43,6 +43,7 @@
 
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -657,6 +658,9 @@
 			goto nla_put_failure;
 	}
 
+	if (dev->ethtool_ops && ethtool_fill_nlattr(skb, dev) < 0)
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -700,6 +704,7 @@
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
+	[IFLA_ETHTOOL]		= { .type = NLA_NESTED },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -728,6 +733,8 @@
 
 static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 {
+	int err;
+
 	if (dev) {
 		if (tb[IFLA_ADDRESS] &&
 		    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
@@ -736,6 +743,12 @@
 		if (tb[IFLA_BROADCAST] &&
 		    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
 			return -EINVAL;
+
+		if (tb[IFLA_ETHTOOL]) {
+			err = ethtool_validate_nlattr(dev, tb[IFLA_ETHTOOL]);
+			if (err < 0)
+				return err;
+		}
 	}
 
 	return 0;
@@ -875,6 +888,12 @@
 		}
 	}
 
+	if (tb[IFLA_ETHTOOL]) {
+		if ((err = ethtool_execute_nlattr(dev, tb[IFLA_ETHTOOL])) < 0)
+			goto errout;
+		modified = 1;
+	}
+
 	err = 0;
 
 errout:
Index: net-2.6.26/include/linux/ethtool.h
===================================================================
--- net-2.6.26.orig/include/linux/ethtool.h	2008-02-22 14:13:22.000000000 +0100
+++ net-2.6.26/include/linux/ethtool.h	2008-02-22 14:40:24.000000000 +0100
@@ -274,6 +274,8 @@
 #ifdef __KERNEL__
 
 struct net_device;
+struct nlattr;
+struct sk_buff;
 
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
@@ -290,6 +292,10 @@
 u32 ethtool_op_get_flags(struct net_device *dev);
 int ethtool_op_set_flags(struct net_device *dev, u32 data);
 
+extern int ethtool_validate_nlattr(struct net_device *, struct nlattr *);
+extern int ethtool_execute_nlattr(struct net_device *, struct nlattr *);
+extern int ethtool_fill_nlattr(struct sk_buff *, struct net_device *);
+
 /**
  * &ethtool_ops - Alter and report network device settings
  * get_settings: Get device-specific settings
@@ -527,4 +533,12 @@
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
 
+enum {
+	IFLA_ET_UNSPEC,
+	IFLA_ET_SETTINGS,
+	__IFLA_ET_MAX,
+};
+
+#define IFLA_ET_MAX (__IFLA_ET_MAX - 1)
+
 #endif /* _LINUX_ETHTOOL_H */
