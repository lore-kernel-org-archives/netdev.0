From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH] IB/ipoib: Add more rtnl_link_ops callbacks
Date: Fri, 28 Sep 2012 00:02:20 +0200
Message-ID: <1348783340-13481-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, kaber@trash.net,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:60362 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754140Ab2I0WCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:02:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the rtnl_link_ops changelink and fill_info callbacks, through 
which the admin can now set/get the driver mode, etc policies. 
Maintain the proprietary sysfs entries only for legacy childs.

For child devices, set dev->iflink to point to the parent 
device ifindex, such that user space tools can now correctly 
show the uplink relation as done for vlan, macvlan, etc 
devices. Pointed out by Patrick McHardy <kaber@trash.net>

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h         |    3 +
 drivers/infiniband/ulp/ipoib/ipoib_cm.c      |   34 ++++++++++----
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   16 +++++--
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |   60 +++++++++++++++++++++++++-
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |   24 ++++++----
 include/linux/if_link.h                      |    7 +++
 6 files changed, 118 insertions(+), 26 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index 381f51b..8956f6f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -520,6 +520,9 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 int  __init ipoib_netlink_init(void);
 void __exit ipoib_netlink_fini(void);
 
+void ipoib_set_umcast(struct net_device *ndev, int umcast_val);
+int  ipoib_set_mode(struct net_device *dev, const char *buf);
+
 void ipoib_setup(struct net_device *dev);
 
 void ipoib_pkey_poll(struct work_struct *work);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 24683fd..ef6d5a3 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1448,15 +1448,10 @@ static ssize_t show_mode(struct device *d, struct device_attribute *attr,
 		return sprintf(buf, "datagram\n");
 }
 
-static ssize_t set_mode(struct device *d, struct device_attribute *attr,
-			const char *buf, size_t count)
+int ipoib_set_mode(struct net_device *dev, const char *buf)
 {
-	struct net_device *dev = to_net_dev(d);
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	if (!rtnl_trylock())
-		return restart_syscall();
-
 	/* flush paths if we switch modes so that connections are restarted */
 	if (IPOIB_CM_SUPPORTED(dev->dev_addr) && !strcmp(buf, "connected\n")) {
 		set_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
@@ -1467,7 +1462,8 @@ static ssize_t set_mode(struct device *d, struct device_attribute *attr,
 		priv->tx_wr.send_flags &= ~IB_SEND_IP_CSUM;
 
 		ipoib_flush_paths(dev);
-		return count;
+		rtnl_lock();
+		return 0;
 	}
 
 	if (!strcmp(buf, "datagram\n")) {
@@ -1476,14 +1472,32 @@ static ssize_t set_mode(struct device *d, struct device_attribute *attr,
 		dev_set_mtu(dev, min(priv->mcast_mtu, dev->mtu));
 		rtnl_unlock();
 		ipoib_flush_paths(dev);
-
-		return count;
+		rtnl_lock();
+		return 0;
 	}
-	rtnl_unlock();
 
 	return -EINVAL;
 }
 
+static ssize_t set_mode(struct device *d, struct device_attribute *attr,
+			const char *buf, size_t count)
+{
+	struct net_device *dev = to_net_dev(d);
+	int ret;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	ret = ipoib_set_mode(dev, buf);
+	
+	rtnl_unlock();
+
+	if (!ret)
+		return count;
+
+	return ret;
+}
+
 static DEVICE_ATTR(mode, S_IWUSR | S_IRUGO, show_mode, set_mode);
 
 int ipoib_cm_add_mode_attr(struct net_device *dev)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index b3e9709..6c5c771 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1386,12 +1386,9 @@ static ssize_t show_umcast(struct device *dev,
 	return sprintf(buf, "%d\n", test_bit(IPOIB_FLAG_UMCAST, &priv->flags));
 }
 
-static ssize_t set_umcast(struct device *dev,
-			  struct device_attribute *attr,
-			  const char *buf, size_t count)
+void ipoib_set_umcast(struct net_device *ndev, int umcast_val)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(to_net_dev(dev));
-	unsigned long umcast_val = simple_strtoul(buf, NULL, 0);
+	struct ipoib_dev_priv *priv = netdev_priv(ndev);
 
 	if (umcast_val > 0) {
 		set_bit(IPOIB_FLAG_UMCAST, &priv->flags);
@@ -1399,6 +1396,15 @@ static ssize_t set_umcast(struct device *dev,
 				"by userspace\n");
 	} else
 		clear_bit(IPOIB_FLAG_UMCAST, &priv->flags);
+}
+
+static ssize_t set_umcast(struct device *dev,
+			  struct device_attribute *attr,
+			  const char *buf, size_t count)
+{
+	unsigned long umcast_val = simple_strtoul(buf, NULL, 0);
+	
+	ipoib_set_umcast(to_net_dev(dev), umcast_val);
 
 	return count;
 }
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index a7dc5ea..42f6756 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -37,8 +37,60 @@
 
 static const struct nla_policy ipoib_policy[IFLA_IPOIB_MAX + 1] = {
 	[IFLA_IPOIB_PKEY]	= { .type = NLA_U16 },
+	[IFLA_IPOIB_MODE]	= { .type = NLA_U16 },
+	[IFLA_IPOIB_UMCAST]	= { .type = NLA_U16 },
 };
 
+static int ipoib_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	u16 val;
+
+	if (nla_put_u16(skb, IFLA_IPOIB_PKEY, priv->pkey))
+		goto nla_put_failure;
+
+	val = test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
+	if (nla_put_u16(skb, IFLA_IPOIB_MODE, val))
+		goto nla_put_failure;
+
+	val = test_bit(IPOIB_FLAG_UMCAST, &priv->flags);
+	if (nla_put_u16(skb, IFLA_IPOIB_UMCAST, val))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int ipoib_changelink(struct net_device *dev,
+			    struct nlattr *tb[], struct nlattr *data[])
+{
+	u16 mode, umcast;
+	int ret = 0;
+
+	if (data[IFLA_IPOIB_MODE]) {
+		mode  = nla_get_u16(data[IFLA_IPOIB_MODE]);
+		if (mode == IPOIB_MODE_DATAGRAM)
+			ret = ipoib_set_mode(dev, "datagram\n");
+		else if (mode == IPOIB_MODE_CONNECTED)
+			ret = ipoib_set_mode(dev, "connected\n");
+		else 
+			ret = -EINVAL;
+
+		if (ret < 0)
+			goto out_err;
+	}
+
+	if (data[IFLA_IPOIB_UMCAST]) { 
+		umcast = nla_get_u16(data[IFLA_IPOIB_UMCAST]);
+		ipoib_set_umcast(dev, umcast);
+	}
+	
+out_err:
+	return ret;
+}
+
 static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 			       struct nlattr *tb[], struct nlattr *data[])
 {
@@ -69,6 +121,8 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 
 	err = __ipoib_vlan_add(ppriv, netdev_priv(dev), child_pkey, IPOIB_RTNL_CHILD);
 
+	if (!err && data)
+		err = ipoib_changelink(dev, tb, data);
 	return err;
 }
 
@@ -87,7 +141,9 @@ static void ipoib_unregister_child_dev(struct net_device *dev, struct list_head
 
 static size_t ipoib_get_size(const struct net_device *dev)
 {
-	return nla_total_size(2);	/* IFLA_IPOIB_PKEY */
+	return nla_total_size(2) +	/* IFLA_IPOIB_PKEY   */
+		nla_total_size(2) +	/* IFLA_IPOIB_MODE   */
+		nla_total_size(2);	/* IFLA_IPOIB_UMCAST */
 }
 
 static struct rtnl_link_ops ipoib_link_ops __read_mostly = {
@@ -97,8 +153,10 @@ static struct rtnl_link_ops ipoib_link_ops __read_mostly = {
 	.priv_size	= sizeof(struct ipoib_dev_priv),
 	.setup		= ipoib_setup,
 	.newlink	= ipoib_new_child_link,
+	.changelink	= ipoib_changelink,
 	.dellink	= ipoib_unregister_child_dev,
 	.get_size	= ipoib_get_size,
+	.fill_info	= ipoib_fill_info,
 };
 
 int __init ipoib_netlink_init(void)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index 238bbf9..8292554 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -88,17 +88,21 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 
 	ipoib_create_debug_files(priv->dev);
 
-	if (ipoib_cm_add_mode_attr(priv->dev))
-		goto sysfs_failed;
-	if (ipoib_add_pkey_attr(priv->dev))
-		goto sysfs_failed;
-	if (ipoib_add_umcast_attr(priv->dev))
-		goto sysfs_failed;
-
-	if (device_create_file(&priv->dev->dev, &dev_attr_parent))
-		goto sysfs_failed;
+	/* RTNL childs don't need proprietary sysfs entries */
+	if (type == IPOIB_LEGACY_CHILD) {
+		if (ipoib_cm_add_mode_attr(priv->dev))
+			goto sysfs_failed;
+		if (ipoib_add_pkey_attr(priv->dev))
+			goto sysfs_failed;
+		if (ipoib_add_umcast_attr(priv->dev))
+			goto sysfs_failed;
+
+		if (device_create_file(&priv->dev->dev, &dev_attr_parent))
+			goto sysfs_failed;
+	}
 
-	priv->child_type = type;
+	priv->child_type  = type;
+	priv->dev->iflink = ppriv->dev->ifindex;
 	list_add_tail(&priv->list, &ppriv->child_intfs);
 
 	return 0;
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 24c0dd0..4491177 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -404,9 +404,16 @@ struct ifla_port_vsi {
 enum {
 	IFLA_IPOIB_UNSPEC,
 	IFLA_IPOIB_PKEY,
+	IFLA_IPOIB_MODE,
+	IFLA_IPOIB_UMCAST,
 	__IFLA_IPOIB_MAX
 };
 
+enum {
+	IPOIB_MODE_DATAGRAM  = 0, /* using unreliable datagram QPs */
+	IPOIB_MODE_CONNECTED = 1, /* using connected QPs */
+};
+
 #define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
 
 #endif /* _LINUX_IF_LINK_H */
-- 
1.7.1
