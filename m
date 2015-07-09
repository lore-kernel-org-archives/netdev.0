From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v5 1/4] net core: Add protodown support.
Date: Thu,  9 Jul 2015 15:35:27 -0700
Message-ID: <1436481330-4599-2-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34371 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbbGIWfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:35:39 -0400
Received: by pabvl15 with SMTP id vl15so157048095pab.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 15:35:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch introduces the IF_PROTOF_DOWN flag via proto_flags that can be
used by user space applications to notify switch drivers that errors have
been detected on the device.

The switch driver can react to protodown notification by doing a phys down
on the associated switch port.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 include/linux/netdevice.h |   13 +++++++++++++
 include/uapi/linux/if.h   |    6 ++++++
 net/core/dev.c            |   20 ++++++++++++++++++++
 net/core/net-sysfs.c      |   14 ++++++++++++++
 4 files changed, 53 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e20979d..99ebb01 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1041,6 +1041,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	TX queue.
  * int (*ndo_get_iflink)(const struct net_device *dev);
  *	Called to get the iflink value of this device.
+ * void (*ndo_change_proto_flags)(struct net_device *dev,
+ *				  unsigned int proto_flags);
+ *	This function is used to pass protocol port state information
+ *	to the switch driver.
+ *
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1211,6 +1216,8 @@ struct net_device_ops {
 						      int queue_index,
 						      u32 maxrate);
 	int			(*ndo_get_iflink)(const struct net_device *dev);
+	int			(*ndo_change_proto_flags)(struct net_device *dev,
+							  unsigned int proto_flags);
 };
 
 /**
@@ -1502,6 +1509,10 @@ enum netdev_priv_flags {
  *
  *	@qdisc_tx_busylock:	XXX: need comments on this one
  *
+ *	@proto_flags:	protocol port state information can be sent to the
+ *			switch driver and used to set the phys state of the
+ *			switch port.
+ *
  *	FIXME: cleanup struct net_device such that network protocol info
  *	moves out.
  */
@@ -1762,6 +1773,7 @@ struct net_device {
 #endif
 	struct phy_device *phydev;
 	struct lock_class_key *qdisc_tx_busylock;
+	unsigned int proto_flags;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -2982,6 +2994,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_item_id *ppid);
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
+int dev_change_proto_flags(struct net_device *dev, unsigned int proto_flags);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 9cf2394..8d60fe7 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -156,6 +156,12 @@ enum {
 	IF_LINK_MODE_DORMANT,	/* limit upward transition to dormant */
 };
 
+/* proto_flags - port state information can be passed to the switch driver and
+ * used to determine the phys state of the switch port */
+enum {
+	IF_PROTOF_DOWN		= 1<<0	/* set switch port phys state down */
+};
+
 /*
  *	Device mapping structure. I'd just gone off and designed a 
  *	beautiful scheme using only loadable modules with arguments
diff --git a/net/core/dev.c b/net/core/dev.c
index 6778a99..87571c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6076,6 +6076,26 @@ int dev_get_phys_port_name(struct net_device *dev,
 EXPORT_SYMBOL(dev_get_phys_port_name);
 
 /**
+ *	dev_change_proto_flags - update protocol port state information
+ *	@dev: device
+ *	@proto_flags: new value
+ *
+ *	This info can be used by switch drivers to set the phys state of the
+ *	port.
+ */
+int dev_change_proto_flags(struct net_device *dev, unsigned int proto_flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (dev->proto_flags == proto_flags)
+		return 0;
+	if (!ops->ndo_change_proto_flags)
+		return -EOPNOTSUPP;
+	return ops->ndo_change_proto_flags(dev, proto_flags);
+}
+EXPORT_SYMBOL(dev_change_proto_flags);
+
+/**
  *	dev_new_index	-	allocate an ifindex
  *	@net: the applicable net namespace
  *
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 18b34d7..06f355e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -404,6 +404,19 @@ static ssize_t group_store(struct device *dev, struct device_attribute *attr,
 NETDEVICE_SHOW(group, fmt_dec);
 static DEVICE_ATTR(netdev_group, S_IRUGO | S_IWUSR, group_show, group_store);
 
+static int change_proto_flags(struct net_device *dev, unsigned long proto_flags)
+{
+	return dev_change_proto_flags(dev, (unsigned int)proto_flags);
+}
+
+static ssize_t proto_flags_store(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_proto_flags);
+}
+NETDEVICE_SHOW_RW(proto_flags, fmt_hex);
+
 static ssize_t phys_port_id_show(struct device *dev,
 				 struct device_attribute *attr, char *buf)
 {
@@ -501,6 +514,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_phys_port_id.attr,
 	&dev_attr_phys_port_name.attr,
 	&dev_attr_phys_switch_id.attr,
+	&dev_attr_proto_flags.attr,
 	NULL,
 };
 ATTRIBUTE_GROUPS(net_class);
-- 
1.7.10.4
