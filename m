From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] net: core: decouple ifalias get/set from rtnl lock
Date: Fri, 29 Sep 2017 13:21:50 +0200
Message-ID: <20170929112150.7424-1-fw@strlen.de>
Cc: edumazet@google.com, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45248 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751667AbdI2LVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 07:21:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device alias can be set by either rtnetlink (rtnl is held) or sysfs.

rtnetlink hold the rtnl mutex, sysfs acquires it for this purpose.
Add an extra mutex for it plus a seqcount to get a consistent snapshot
of the alias buffer.

This allows the sysfs path to not take rtnl and would later allow
to not hold it when dumping ifalias.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h |  3 +-
 net/core/dev.c            | 70 +++++++++++++++++++++++++++++++++++++++--------
 net/core/net-sysfs.c      | 14 ++++------
 net/core/rtnetlink.c      | 13 +++++++--
 4 files changed, 77 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..0bcedb498f6f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1632,7 +1632,7 @@ enum netdev_priv_flags {
 struct net_device {
 	char			name[IFNAMSIZ];
 	struct hlist_node	name_hlist;
-	char 			*ifalias;
+	char			__rcu *ifalias;
 	/*
 	 *	I/O specific fields
 	 *	FIXME: Merge these and struct ifmap into one
@@ -3275,6 +3275,7 @@ void __dev_notify_flags(struct net_device *, unsigned int old_flags,
 			unsigned int gchanges);
 int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
+int dev_get_alias(const struct net_device *, char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int __dev_set_mtu(struct net_device *, int);
 int dev_set_mtu(struct net_device *, int);
diff --git a/net/core/dev.c b/net/core/dev.c
index e350c768d4b5..a7ac2902d702 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -188,6 +188,9 @@ static struct napi_struct *napi_by_id(unsigned int napi_id);
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+static DEFINE_MUTEX(ifalias_mutex);
+static seqcount_t ifalias_rename_seq;
+
 /* protects napi_hash addition/deletion and napi_gen_id */
 static DEFINE_SPINLOCK(napi_hash_lock);
 
@@ -1265,29 +1268,72 @@ int dev_change_name(struct net_device *dev, const char *newname)
  */
 int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 {
-	char *new_ifalias;
-
-	ASSERT_RTNL();
+	char *new_ifalias, *old_ifalias;
 
 	if (len >= IFALIASZ)
 		return -EINVAL;
 
+	mutex_lock(&ifalias_mutex);
+
+	old_ifalias = rcu_dereference_protected(dev->ifalias,
+						mutex_is_locked(&ifalias_mutex));
 	if (!len) {
-		kfree(dev->ifalias);
-		dev->ifalias = NULL;
-		return 0;
+		RCU_INIT_POINTER(dev->ifalias, NULL);
+		goto out;
 	}
 
-	new_ifalias = krealloc(dev->ifalias, len + 1, GFP_KERNEL);
-	if (!new_ifalias)
+	new_ifalias = __krealloc(old_ifalias, len + 1, GFP_KERNEL);
+	if (!new_ifalias) {
+		mutex_unlock(&ifalias_mutex);
 		return -ENOMEM;
-	dev->ifalias = new_ifalias;
-	memcpy(dev->ifalias, alias, len);
-	dev->ifalias[len] = 0;
+	}
 
+	if (new_ifalias == old_ifalias) {
+		write_seqcount_begin(&ifalias_rename_seq);
+		memcpy(new_ifalias, alias, len);
+		new_ifalias[len] = 0;
+		write_seqcount_end(&ifalias_rename_seq);
+		mutex_unlock(&ifalias_mutex);
+		return len;
+	}
+
+	memcpy(new_ifalias, alias, len);
+	new_ifalias[len] = 0;
+
+	rcu_assign_pointer(dev->ifalias, new_ifalias);
+out:
+	mutex_unlock(&ifalias_mutex);
+	if (old_ifalias) {
+		synchronize_net();
+		kfree(old_ifalias);
+	}
 	return len;
 }
 
+int dev_get_alias(const struct net_device *dev, char *alias, size_t len)
+{
+	unsigned int seq;
+	int ret;
+
+	for (;;) {
+		const char *name;
+
+		ret = 0;
+		rcu_read_lock();
+		name = rcu_dereference(dev->ifalias);
+		seq = raw_seqcount_begin(&ifalias_rename_seq);
+		if (name)
+			ret = snprintf(alias, len, "%s", name);
+		rcu_read_unlock();
+
+		if (!read_seqcount_retry(&ifalias_rename_seq, seq))
+			break;
+
+		cond_resched();
+	}
+
+	return ret;
+}
 
 /**
  *	netdev_features_change - device changes features
@@ -8770,6 +8816,8 @@ static int __init net_dev_init(void)
 				       NULL, dev_cpu_dead);
 	WARN_ON(rc < 0);
 	rc = 0;
+
+	seqcount_init(&ifalias_rename_seq);
 out:
 	return rc;
 }
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 927a6dcbad96..3d85119d3104 100644
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
@@ -1488,7 +1484,7 @@ static void netdev_release(struct device *d)
 
 	BUG_ON(dev->reg_state != NETREG_RELEASED);
 
-	kfree(dev->ifalias);
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
2.13.5
