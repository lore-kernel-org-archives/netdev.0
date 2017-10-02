From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v3 net-next] net: core: decouple ifalias get/set from rtnl lock
Date: Mon,  2 Oct 2017 23:50:05 +0200
Message-ID: <20171002215005.10417-1-fw@strlen.de>
Cc: edumazet@google.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43874 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751214AbdJBVtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 17:49:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device alias can be set by either rtnetlink (rtnl is held) or sysfs.

rtnetlink hold the rtnl mutex, sysfs acquires it for this purpose.
Add an extra mutex for it and use rcu to protect concurrent accesses.

This allows the sysfs path to not take rtnl and would later allow
to not hold it when dumping ifalias.

Based on suggestion from Eric Dumazet.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v2:
  - use rcu_swap_protected
 Change since v1:
  - don't use a sequence lock, instead use kmalloc+kfree_rcu
  - add comment for dev_get_alias
  - add comment why we use kfree and not kfree_rcu
  to free dev->alias during netdevice destruction

 include/linux/netdevice.h |  8 +++++++-
 net/core/dev.c            | 52 +++++++++++++++++++++++++++++++++++------------
 net/core/net-sysfs.c      | 17 ++++++++--------
 net/core/rtnetlink.c      | 13 ++++++++++--
 4 files changed, 65 insertions(+), 25 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e1d6ef130611..d04424cfffba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -826,6 +826,11 @@ struct xfrmdev_ops {
 };
 #endif
 
+struct dev_ifalias {
+	struct rcu_head rcuhead;
+	char ifalias[];
+};
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1632,7 +1637,7 @@ enum netdev_priv_flags {
 struct net_device {
 	char			name[IFNAMSIZ];
 	struct hlist_node	name_hlist;
-	char 			*ifalias;
+	struct dev_ifalias	__rcu *ifalias;
 	/*
 	 *	I/O specific fields
 	 *	FIXME: Merge these and struct ifmap into one
@@ -3275,6 +3280,7 @@ void __dev_notify_flags(struct net_device *, unsigned int old_flags,
 			unsigned int gchanges);
 int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
+int dev_get_alias(const struct net_device *, char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int __dev_set_mtu(struct net_device *, int);
 int dev_set_mtu(struct net_device *, int);
diff --git a/net/core/dev.c b/net/core/dev.c
index e350c768d4b5..1770097cfd86 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -188,6 +188,8 @@ static struct napi_struct *napi_by_id(unsigned int napi_id);
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+static DEFINE_MUTEX(ifalias_mutex);
+
 /* protects napi_hash addition/deletion and napi_gen_id */
 static DEFINE_SPINLOCK(napi_hash_lock);
 
@@ -1265,29 +1267,53 @@ int dev_change_name(struct net_device *dev, const char *newname)
  */
 int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 {
-	char *new_ifalias;
-
-	ASSERT_RTNL();
+	struct dev_ifalias *new_alias = NULL;
 
 	if (len >= IFALIASZ)
 		return -EINVAL;
 
-	if (!len) {
-		kfree(dev->ifalias);
-		dev->ifalias = NULL;
-		return 0;
+	if (len) {
+		new_alias = kmalloc(sizeof(*new_alias) + len + 1, GFP_KERNEL);
+		if (!new_alias)
+			return -ENOMEM;
+
+		memcpy(new_alias->ifalias, alias, len);
+		new_alias->ifalias[len] = 0;
 	}
 
-	new_ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
-	if (!new_ifalias)
-		return -ENOMEM;
-	dev->ifalias = new_ifalias;
-	memcpy(dev->ifalias, alias, len);
-	dev->ifalias[len] = 0;
+	mutex_lock(&ifalias_mutex);
+	rcu_swap_protected(dev->ifalias, new_alias,
+			   mutex_is_locked(&ifalias_mutex));
+	mutex_unlock(&ifalias_mutex);
+
+	if (new_alias)
+		kfree_rcu(new_alias, rcuhead);
 
 	return len;
 }
 
+/**
+ *	dev_get_alias - get ifalias of a device
+ *	@dev: device
+ *	@alias: buffer to store name of ifalias
+ *	@len: size of buffer
+ *
+ *	get ifalias for a device.  Caller must make sure dev cannot go
+ *	away,  e.g. rcu read lock or own a reference count to device.
+ */
+int dev_get_alias(const struct net_device *dev, char *name, size_t len)
+{
+	const struct dev_ifalias *alias;
+	int ret = 0;
+
+	rcu_read_lock();
+	alias = rcu_dereference(dev->ifalias);
+	if (alias)
+		ret = snprintf(name, len, "%s", alias->ifalias);
+	rcu_read_unlock();
+
+	return ret;
+}
 
 /**
  *	netdev_features_change - device changes features
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 927a6dcbad96..51d5836d8fb9 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -391,10 +391,7 @@ static ssize_t ifalias_store(struct device *dev, struct device_attribute *attr,
 	if (len >  0 && buf[len - 1] == '\n')
 		--count;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
 	ret = dev_set_alias(netdev, buf, count);
-	rtnl_unlock();
 
 	return ret < 0 ? ret : len;
 }
@@ -403,13 +400,12 @@ static ssize_t ifalias_show(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
 	const struct net_device *netdev = to_net_dev(dev);
+	char tmp[IFALIASZ];
 	ssize_t ret = 0;
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-	if (netdev->ifalias)
-		ret = sprintf(buf, "%s\n", netdev->ifalias);
-	rtnl_unlock();
+	ret = dev_get_alias(netdev, tmp, sizeof(tmp));
+	if (ret > 0)
+		ret = sprintf(buf, "%s\n", tmp);
 	return ret;
 }
 static DEVICE_ATTR_RW(ifalias);
@@ -1488,7 +1484,10 @@ static void netdev_release(struct device *d)
 
 	BUG_ON(dev->reg_state != NETREG_RELEASED);
 
-	kfree(dev->ifalias);
+	/* no need to wait for rcu grace period:
+	 * device is dead and about to be freed.
+	 */
+	kfree(rcu_access_pointer(dev->ifalias));
 	netdev_freemem(dev);
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e6955da0d58d..3961f87cdc76 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1366,6 +1366,16 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
 	return nla_put_u32(skb, IFLA_LINK, ifindex);
 }
 
+static noinline_for_stack int nla_put_ifalias(struct sk_buff *skb,
+					      struct net_device *dev)
+{
+	char buf[IFALIASZ];
+	int ret;
+
+	ret = dev_get_alias(dev, buf, sizeof(buf));
+	return ret > 0 ? nla_put_string(skb, IFLA_IFALIAS, buf) : 0;
+}
+
 static int rtnl_fill_link_netnsid(struct sk_buff *skb,
 				  const struct net_device *dev)
 {
@@ -1425,8 +1435,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
-	    (dev->ifalias &&
-	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
+	    nla_put_ifalias(skb, dev) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
 			atomic_read(&dev->carrier_changes)) ||
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
-- 
2.13.6
