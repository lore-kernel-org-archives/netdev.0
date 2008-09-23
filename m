From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: network device name ifalias support
Date: Mon, 22 Sep 2008 17:43:46 -0700
Message-ID: <20080922174346.2ad15d26@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44209 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496AbYIWAns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 20:43:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add support for keeping an additional character alias associated with
an network interface. This is useful for maintaining the SNMP ifAlias value
which is a user defined value. Routers use this to hold information like which
circuit or line it is connected to. It is just an arbitrary text label
on the network device.

There are two exposed interfaces with this patch, the value can be read/written
either via netlink or sysfs.

This could be maintained just by the snmp daemon, but it is more generally
useful for other management tools, and the kernel is good place to act as
an agreed upon interface to store it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Note: this is not IP alias which is something completely different.


--- a/include/linux/if.h	2008-09-22 11:54:10.000000000 -0700
+++ b/include/linux/if.h	2008-09-22 16:22:24.000000000 -0700
@@ -24,6 +24,7 @@
 #include <linux/compiler.h>		/* for "__user" et al           */
 
 #define	IFNAMSIZ	16
+#define	IFALIASZ	256
 #include <linux/hdlc/ioctl.h>
 
 /* Standard interface flags (netdevice->flags). */
--- a/include/linux/if_link.h	2008-09-22 11:50:28.000000000 -0700
+++ b/include/linux/if_link.h	2008-09-22 11:54:32.000000000 -0700
@@ -79,6 +79,7 @@ enum
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
+	IFLA_IFALIAS,
 	__IFLA_MAX
 };
 
--- a/include/linux/netdevice.h	2008-09-22 11:46:10.000000000 -0700
+++ b/include/linux/netdevice.h	2008-09-22 16:04:24.000000000 -0700
@@ -471,6 +471,8 @@ struct net_device
 	char			name[IFNAMSIZ];
 	/* device name hash chain */
 	struct hlist_node	name_hlist;
+	/* snmp alias */
+	char 			*ifalias;
 
 	/*
 	 *	I/O specific fields
@@ -1224,6 +1226,7 @@ extern int		dev_ethtool(struct net *net,
 extern unsigned		dev_get_flags(const struct net_device *);
 extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_change_name(struct net_device *, char *);
+extern int		dev_set_alias(struct net_device *, const char *, size_t);
 extern int		dev_change_net_namespace(struct net_device *,
 						 struct net *, const char *);
 extern int		dev_set_mtu(struct net_device *, int);
--- a/net/core/dev.c	2008-09-22 11:58:17.000000000 -0700
+++ b/net/core/dev.c	2008-09-22 17:26:57.000000000 -0700
@@ -954,6 +954,29 @@ rollback:
 }
 
 /**
+ *	dev_set_alias - change ifalias of a device
+ *	@dev: device
+ *	@alias: name up to IFALIASZ
+ *
+ *	Set ifalias for a device,
+ */
+int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
+{
+	ASSERT_RTNL();
+
+	if (len >= IFALIASZ)
+		return -EINVAL;
+
+	dev->ifalias = krealloc(dev->ifalias, len+1, GFP_KERNEL);
+	if (!dev->ifalias)
+		return -ENOMEM;
+
+	strlcpy(dev->ifalias, alias, len+1);
+	return len;
+}
+
+
+/**
  *	netdev_features_change - device changes features
  *	@dev: device to cause notification
  *
--- a/net/core/net-sysfs.c	2008-09-22 12:03:34.000000000 -0700
+++ b/net/core/net-sysfs.c	2008-09-22 17:27:14.000000000 -0700
@@ -209,9 +209,44 @@ static ssize_t store_tx_queue_len(struct
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
+static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t len)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	size_t count = len;
+	ssize_t ret;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	/* ignore trailing newline */
+	if (len >  0 && buf[len - 1] == '\n')
+		--count;
+
+	rtnl_lock();
+	ret = dev_set_alias(netdev, buf, count);
+	rtnl_unlock();
+
+	return ret < 0 ? ret : len;
+}
+
+static ssize_t show_ifalias(struct device *dev,
+			    struct device_attribute *attr, char *buf)
+{
+	const struct net_device *netdev = to_net_dev(dev);
+	ssize_t ret = 0;
+
+	rtnl_lock();
+	if (netdev->ifalias)
+		ret = sprintf(buf, "%s\n", netdev->ifalias);
+	rtnl_unlock();
+	return ret;
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
+	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
 	__ATTR(features, S_IRUGO, show_features, NULL),
@@ -418,6 +453,7 @@ static void netdev_release(struct device
 
 	BUG_ON(dev->reg_state != NETREG_RELEASED);
 
+	kfree(dev->ifalias);
 	kfree((char *)dev - dev->padded);
 }
 
--- a/net/core/rtnetlink.c	2008-09-22 11:48:30.000000000 -0700
+++ b/net/core/rtnetlink.c	2008-09-22 16:23:56.000000000 -0700
@@ -586,6 +586,7 @@ static inline size_t if_nlmsg_size(const
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
+	       + nla_total_size(IFALIASZ) /* IFLA_IFALIAS */
 	       + nla_total_size(IFNAMSIZ) /* IFLA_QDISC */
 	       + nla_total_size(sizeof(struct rtnl_link_ifmap))
 	       + nla_total_size(sizeof(struct rtnl_link_stats))
@@ -640,6 +641,9 @@ static int rtnl_fill_ifinfo(struct sk_bu
 	if (txq->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, txq->qdisc_sleeping->ops->id);
 
+	if (dev->ifalias)
+		NLA_PUT_STRING(skb, IFLA_IFALIAS, dev->ifalias);
+
 	if (1) {
 		struct rtnl_link_ifmap map = {
 			.mem_start   = dev->mem_start,
@@ -713,6 +717,7 @@ const struct nla_policy ifla_policy[IFLA
 	[IFLA_LINKMODE]		= { .type = NLA_U8 },
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
+	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -853,6 +858,14 @@ static int do_setlink(struct net_device 
 		modified = 1;
 	}
 
+	if (tb[IFLA_IFALIAS]) {
+		err = dev_set_alias(dev, nla_data(tb[IFLA_IFALIAS]),
+				    nla_len(tb[IFLA_IFALIAS]));
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+
 	if (tb[IFLA_BROADCAST]) {
 		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
 		send_addr_notify = 1;
