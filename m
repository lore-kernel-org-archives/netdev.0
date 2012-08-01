From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 02/12] IB/ipoib: Add support for clones / multiple childs on the same partition
Date: Wed,  1 Aug 2012 20:09:25 +0300
Message-ID: <1343840975-3252-3-git-send-email-ogerlitz@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:48059 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753374Ab2HARKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:10:00 -0400
In-Reply-To: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow creating "clone" child interfaces which further partition an
IPoIB interface to sub interfaces who either use the same pkey as
their parent or use the same pkey as already created child interface.

Each child now has a child index, which together with the pkey is
used as the identifier of the created network device.

Clone interfaces can only be created using rtnl_link_ops, where the user
is allowed to provide a pkey and index. If no pkey is provided, the
parent pkey is used and if no index is provided an index of zero
is used.

A major use case for clone childs is for virtualization purposes, where
a per VM NIC is desired at the hypervisor level, such as the solution
provided by the newly introduced Ethernet IPoIB driver.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
---
 Documentation/infiniband/ipoib.txt           |   12 ++++++++++++
 drivers/infiniband/ulp/ipoib/ipoib.h         |    7 +++++--
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |   21 +++++++++++++++------
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |   19 +++++++++++--------
 4 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/Documentation/infiniband/ipoib.txt b/Documentation/infiniband/ipoib.txt
index f2cfe26..6ef87bb 100644
--- a/Documentation/infiniband/ipoib.txt
+++ b/Documentation/infiniband/ipoib.txt
@@ -27,6 +27,18 @@ Partitions and P_Keys
   Child interface create/delete can also be done using IPoIB's
   rtnl_link_ops, where childs created using either way behave the same.
 
+Clones
+  Its possible to further partition an IPoIB interfaces, and create
+  "clone" child interfaces which either use the same pkey as their
+  parent, or as an already created child interface. Each child now has
+  a child index, which together with the pkey is used as the identifier
+  of the created network device.
+
+  Clone interfaces can only be created using rtnl_link_ops, where the user
+  is allowed to provide a pkey and index. If no pkey is provided, the
+  parent pkey is used and if no index is provided an index of zero
+  is used.
+
 Datagram vs Connected modes
 
   The IPoIB driver supports two modes of operation: datagram and
diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index adcfa66..0df6668 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -332,6 +332,7 @@ struct ipoib_dev_priv {
 	struct net_device *parent;
 	struct list_head child_intfs;
 	struct list_head list;
+	u16		 child_index;
 
 #ifdef CONFIG_INFINIBAND_IPOIB_CM
 	struct ipoib_cm_dev_priv cm;
@@ -493,8 +494,10 @@ void ipoib_event(struct ib_event_handler *handler,
 int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey);
 int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey);
 
-int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv, u16 pkey);
-struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey);
+int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
+		     u16 pkey, u16 child_index);
+struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey,
+					u16 child_index);
 
 int  __init ipoib_netlink_init(void);
 void __exit ipoib_netlink_fini(void);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index 2b8905e..d902e04 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -38,6 +38,7 @@
 enum {
 	IFLA_IPOIB_UNSPEC,
 	IFLA_IPOIB_CHILD_PKEY,
+	IFLA_IPOIB_CHILD_INDEX,
 	__IFLA_IPOIB_MAX
 };
 
@@ -45,6 +46,7 @@ enum {
 
 static const struct nla_policy ipoib_policy[IFLA_IPOIB_MAX + 1] = {
 	[IFLA_IPOIB_CHILD_PKEY]		= { .type = NLA_U16 },
+	[IFLA_IPOIB_CHILD_INDEX]	= { .type = NLA_U16 },
 };
 
 static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
@@ -52,7 +54,7 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 {
 	struct net_device *pdev;
 	struct ipoib_dev_priv *ppriv;
-	u16 child_pkey;
+	u16 child_pkey, child_index;
 	int err;
 
 	if (!tb[IFLA_LINK])
@@ -64,12 +66,18 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 	ppriv = netdev_priv(pdev);
 
 	if (!data || !data[IFLA_IPOIB_CHILD_PKEY]) {
-		ipoib_warn(ppriv, "no pkey specified, failing request\n");
-		return -EINVAL;
+		ipoib_warn(ppriv, "no pkey specified, using parent pkey\n");
+		child_pkey = ppriv->pkey;
 	} else
 		child_pkey  = nla_get_u16(data[IFLA_IPOIB_CHILD_PKEY]);
 
-	err = __ipoib_vlan_add(ppriv, netdev_priv(dev), child_pkey);
+	if (!data || !data[IFLA_IPOIB_CHILD_INDEX]) {
+		ipoib_warn(ppriv, "no index specified, using 0\n");
+		child_index = 0;
+	} else
+		child_index  = nla_get_u16(data[IFLA_IPOIB_CHILD_INDEX]);
+
+	err = __ipoib_vlan_add(ppriv, netdev_priv(dev), child_pkey, child_index);
 
 	return err;
 }
@@ -78,12 +86,13 @@ static void ipoib_unregister_child_dev(struct net_device *dev, struct list_head
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	(void)__ipoib_vlan_delete(priv->parent, priv->pkey);
+	(void)__ipoib_vlan_delete(priv->parent, priv->pkey, priv->child_index);
 }
 
 static size_t ipoib_get_size(const struct net_device *dev)
 {
-	return nla_total_size(2);	/* IFLA_IPOIB_CHILD_PKEY */
+	return nla_total_size(2) +	/* IFLA_IPOIB_CHILD_PKEY  */
+		nla_total_size(2);	/* IFLA_IPOIB_CHILD_INDEX */
 }
 
 static struct rtnl_link_ops ipoib_link_ops __read_mostly = {
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index 4a9b7e6..5f6e07d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -51,7 +51,7 @@ static DEVICE_ATTR(parent, S_IRUGO, show_parent, NULL);
 
 
 int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
-		     u16 pkey)
+		     u16 pkey, u16 child_index)
 {
 	int result;
 	struct ipoib_dev_priv *tpriv;
@@ -60,15 +60,16 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 
 	/*
 	 * First ensure this isn't a duplicate. We check the parent device and
-	 * then all of the child interfaces to make sure the Pkey doesn't match.
+	 * then all of the child interfaces to make sure the Pkey AND the child
+	 * index don't match.
 	 */
-	if (ppriv->pkey == pkey) {
+	if (ppriv->pkey == pkey && ppriv->child_index == child_index) {
 		result = -ENOTUNIQ;
 		goto err;
 	}
 
 	list_for_each_entry(tpriv, &ppriv->child_intfs, list) {
-		if (tpriv->pkey == pkey) {
+		if (tpriv->pkey == pkey && tpriv->child_index == child_index) {
 			result = -ENOTUNIQ;
 			goto err;
 		}
@@ -85,6 +86,7 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 		goto err;
 
 	priv->pkey = pkey;
+	priv->child_index = child_index;
 
 	memcpy(priv->dev->dev_addr, ppriv->dev->dev_addr, INFINIBAND_ALEN);
 	priv->dev->broadcast[8] = pkey >> 8;
@@ -156,7 +158,7 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	if (!rtnl_trylock())
 		return restart_syscall();
 
-	result = __ipoib_vlan_add(ppriv, priv, pkey);
+	result = __ipoib_vlan_add(ppriv, priv, pkey, 0);
 
 	if (result)
 		free_netdev(priv->dev);
@@ -166,7 +168,8 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	return result;
 }
 
-struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey)
+struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey,
+					u16 child_index)
 {
 	struct ipoib_dev_priv *ppriv, *priv, *tpriv;
 	struct net_device *dev = NULL;
@@ -175,7 +178,7 @@ struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey)
 
 	mutex_lock(&ppriv->vlan_mutex);
 	list_for_each_entry_safe(priv, tpriv, &ppriv->child_intfs, list) {
-		if (priv->pkey == pkey) {
+		if (priv->pkey == pkey && priv->child_index == child_index) {
 			unregister_netdevice(priv->dev);
 			ipoib_dev_cleanup(priv->dev);
 			list_del(&priv->list);
@@ -197,7 +200,7 @@ int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
 
 	if (!rtnl_trylock())
 		return restart_syscall();
-	dev = __ipoib_vlan_delete(pdev, pkey);
+	dev = __ipoib_vlan_delete(pdev, pkey, 0);
 	rtnl_unlock();
 
 	if (dev) {
-- 
1.7.1
