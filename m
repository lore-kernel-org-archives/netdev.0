From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 1/2] IB/ipoib: Add rtnl_link_ops support
Date: Thu, 23 Aug 2012 15:15:18 +0300
Message-ID: <1345724119-32110-2-git-send-email-ogerlitz@mellanox.com>
References: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:34505 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752031Ab2HWMsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 08:48:02 -0400
In-Reply-To: <1345724119-32110-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add rtnl_link_ops to IPoIB, with the first usage being child device
create/delete through them. Childs devices are now either legacy ones,
created/deleted through the ipoib sysfs entries, or RTNL ones.

Adding support for RTNL childs involved refactoring of ipoib_vlan_add
which is now used by both the sysfs and the link_ops code.

Also, added ndo_uninit entry to support calling unregister_netdevice_queue
from the rtnl dellink entry. This required removal of calls to
ipoib_dev_cleanup from the driver in flows which use unregister_netdevice,
since the networking core will invoke ipoib_uninit which does exactly that.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 Documentation/infiniband/ipoib.txt           |    3 +
 drivers/infiniband/ulp/ipoib/Makefile        |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib.h         |   13 +++
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   25 ++++-
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |  122 ++++++++++++++++++++++++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |  102 ++++++++++++----------
 6 files changed, 217 insertions(+), 51 deletions(-)
 create mode 100644 drivers/infiniband/ulp/ipoib/ipoib_netlink.c

diff --git a/Documentation/infiniband/ipoib.txt b/Documentation/infiniband/ipoib.txt
index 64eeb55..f2cfe26 100644
--- a/Documentation/infiniband/ipoib.txt
+++ b/Documentation/infiniband/ipoib.txt
@@ -24,6 +24,9 @@ Partitions and P_Keys
   The P_Key for any interface is given by the "pkey" file, and the
   main interface for a subinterface is in "parent."
 
+  Child interface create/delete can also be done using IPoIB's
+  rtnl_link_ops, where childs created using either way behave the same.
+
 Datagram vs Connected modes
 
   The IPoIB driver supports two modes of operation: datagram and
diff --git a/drivers/infiniband/ulp/ipoib/Makefile b/drivers/infiniband/ulp/ipoib/Makefile
index 3090100..e5430dd 100644
--- a/drivers/infiniband/ulp/ipoib/Makefile
+++ b/drivers/infiniband/ulp/ipoib/Makefile
@@ -5,7 +5,8 @@ ib_ipoib-y					:= ipoib_main.o \
 						   ipoib_multicast.o \
 						   ipoib_verbs.o \
 						   ipoib_vlan.o \
-						   ipoib_ethtool.o
+						   ipoib_ethtool.o \
+						   ipoib_netlink.o
 ib_ipoib-$(CONFIG_INFINIBAND_IPOIB_CM)		+= ipoib_cm.o
 ib_ipoib-$(CONFIG_INFINIBAND_IPOIB_DEBUG)	+= ipoib_fs.o
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index ca43901..381f51b 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -104,6 +104,10 @@ enum {
 
 	MAX_SEND_CQE		  = 16,
 	IPOIB_CM_COPYBREAK	  = 256,
+
+	IPOIB_NON_CHILD		  = 0,
+	IPOIB_LEGACY_CHILD	  = 1,
+	IPOIB_RTNL_CHILD	  = 2,
 };
 
 #define	IPOIB_OP_RECV   (1ul << 31)
@@ -350,6 +354,7 @@ struct ipoib_dev_priv {
 	struct net_device *parent;
 	struct list_head child_intfs;
 	struct list_head list;
+	int    child_type;
 
 #ifdef CONFIG_INFINIBAND_IPOIB_CM
 	struct ipoib_cm_dev_priv cm;
@@ -509,6 +514,14 @@ void ipoib_event(struct ib_event_handler *handler,
 int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey);
 int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey);
 
+int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
+		     u16 pkey, int child_type);
+
+int  __init ipoib_netlink_init(void);
+void __exit ipoib_netlink_fini(void);
+
+void ipoib_setup(struct net_device *dev);
+
 void ipoib_pkey_poll(struct work_struct *work);
 int ipoib_pkey_dev_delay_open(struct net_device *dev);
 void ipoib_drain_cq(struct net_device *dev);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 3e2085a..b3e9709 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -173,6 +173,11 @@ static int ipoib_stop(struct net_device *dev)
 	return 0;
 }
 
+static void ipoib_uninit(struct net_device *dev)
+{
+	ipoib_dev_cleanup(dev);
+}
+
 static netdev_features_t ipoib_fix_features(struct net_device *dev, netdev_features_t features)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
@@ -1262,6 +1267,9 @@ out:
 void ipoib_dev_cleanup(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev), *cpriv, *tcpriv;
+	LIST_HEAD(head);
+
+	ASSERT_RTNL();
 
 	ipoib_delete_debug_files(dev);
 
@@ -1270,10 +1278,9 @@ void ipoib_dev_cleanup(struct net_device *dev)
 		/* Stop GC on child */
 		set_bit(IPOIB_STOP_NEIGH_GC, &cpriv->flags);
 		cancel_delayed_work(&cpriv->neigh_reap_task);
-		unregister_netdev(cpriv->dev);
-		ipoib_dev_cleanup(cpriv->dev);
-		free_netdev(cpriv->dev);
+		unregister_netdevice_queue(cpriv->dev, &head);
 	}
+	unregister_netdevice_many(&head);
 
 	ipoib_ib_dev_cleanup(dev);
 
@@ -1291,6 +1298,7 @@ static const struct header_ops ipoib_header_ops = {
 };
 
 static const struct net_device_ops ipoib_netdev_ops = {
+	.ndo_uninit		 = ipoib_uninit,
 	.ndo_open		 = ipoib_open,
 	.ndo_stop		 = ipoib_stop,
 	.ndo_change_mtu		 = ipoib_change_mtu,
@@ -1300,7 +1308,7 @@ static const struct net_device_ops ipoib_netdev_ops = {
 	.ndo_set_rx_mode	 = ipoib_set_mcast_list,
 };
 
-static void ipoib_setup(struct net_device *dev)
+void ipoib_setup(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
@@ -1662,7 +1670,6 @@ static void ipoib_remove_one(struct ib_device *device)
 		flush_workqueue(ipoib_workqueue);
 
 		unregister_netdev(priv->dev);
-		ipoib_dev_cleanup(priv->dev);
 		free_netdev(priv->dev);
 	}
 
@@ -1714,8 +1721,15 @@ static int __init ipoib_init_module(void)
 	if (ret)
 		goto err_sa;
 
+	ret = ipoib_netlink_init();
+	if (ret)
+		goto err_client;
+
 	return 0;
 
+err_client:
+	ib_unregister_client(&ipoib_client);
+
 err_sa:
 	ib_sa_unregister_client(&ipoib_sa_client);
 	destroy_workqueue(ipoib_workqueue);
@@ -1728,6 +1742,7 @@ err_fs:
 
 static void __exit ipoib_cleanup_module(void)
 {
+	ipoib_netlink_fini();
 	ib_unregister_client(&ipoib_client);
 	ib_sa_unregister_client(&ipoib_sa_client);
 	ipoib_unregister_debugfs();
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
new file mode 100644
index 0000000..18d6ac9
--- /dev/null
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -0,0 +1,122 @@
+/*
+ * Copyright (c) 2012 Mellanox Technologies. -  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/module.h>
+#include <net/rtnetlink.h>
+#include "ipoib.h"
+
+enum {
+	IFLA_IPOIB_UNSPEC,
+	IFLA_IPOIB_CHILD_PKEY,
+	__IFLA_IPOIB_MAX
+};
+
+#define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
+
+static const struct nla_policy ipoib_policy[IFLA_IPOIB_MAX + 1] = {
+	[IFLA_IPOIB_CHILD_PKEY]		= { .type = NLA_U16 },
+};
+
+static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
+			       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_device *pdev;
+	struct ipoib_dev_priv *ppriv;
+	u16 child_pkey;
+	int err;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+
+	pdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	if (!pdev)
+		return -ENODEV;
+
+	ppriv = netdev_priv(pdev);
+
+	if (test_bit(IPOIB_FLAG_SUBINTERFACE, &ppriv->flags)) {
+		ipoib_warn(ppriv, "child creation disallowed for child devices\n");
+		return -EINVAL;
+	}
+
+	if (!data || !data[IFLA_IPOIB_CHILD_PKEY]) {
+		ipoib_dbg(ppriv, "no pkey specified, using parent pkey\n");
+		child_pkey  = ppriv->pkey;
+	} else
+		child_pkey  = nla_get_u16(data[IFLA_IPOIB_CHILD_PKEY]);
+
+	err = __ipoib_vlan_add(ppriv, netdev_priv(dev), child_pkey, IPOIB_RTNL_CHILD);
+
+	return err;
+}
+
+static void ipoib_unregister_child_dev(struct net_device *dev, struct list_head *head)
+{
+	struct ipoib_dev_priv *priv, *ppriv;
+
+	priv = netdev_priv(dev);
+	ppriv = netdev_priv(priv->parent);
+
+	mutex_lock(&ppriv->vlan_mutex);
+	unregister_netdevice_queue(dev, head);
+	list_del(&priv->list);
+	mutex_unlock(&ppriv->vlan_mutex);
+}
+
+static size_t ipoib_get_size(const struct net_device *dev)
+{
+	return nla_total_size(2);	/* IFLA_IPOIB_CHILD_PKEY */
+}
+
+static struct rtnl_link_ops ipoib_link_ops __read_mostly = {
+	.kind		= "ipoib",
+	.maxtype	= IFLA_IPOIB_MAX,
+	.policy		= ipoib_policy,
+	.priv_size	= sizeof(struct ipoib_dev_priv),
+	.setup		= ipoib_setup,
+	.newlink	= ipoib_new_child_link,
+	.dellink	= ipoib_unregister_child_dev,
+	.get_size	= ipoib_get_size,
+};
+
+int __init ipoib_netlink_init(void)
+{
+	return rtnl_link_register(&ipoib_link_ops);
+}
+
+void __exit ipoib_netlink_fini(void)
+{
+	rtnl_link_unregister(&ipoib_link_ops);
+}
+
+MODULE_ALIAS_RTNL_LINK("ipoib");
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index d7e9740..238bbf9 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -49,47 +49,11 @@ static ssize_t show_parent(struct device *d, struct device_attribute *attr,
 }
 static DEVICE_ATTR(parent, S_IRUGO, show_parent, NULL);
 
-int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
+int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
+		     u16 pkey, int type)
 {
-	struct ipoib_dev_priv *ppriv, *priv;
-	char intf_name[IFNAMSIZ];
 	int result;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	ppriv = netdev_priv(pdev);
-
-	if (!rtnl_trylock())
-		return restart_syscall();
-	mutex_lock(&ppriv->vlan_mutex);
-
-	/*
-	 * First ensure this isn't a duplicate. We check the parent device and
-	 * then all of the child interfaces to make sure the Pkey doesn't match.
-	 */
-	if (ppriv->pkey == pkey) {
-		result = -ENOTUNIQ;
-		priv = NULL;
-		goto err;
-	}
-
-	list_for_each_entry(priv, &ppriv->child_intfs, list) {
-		if (priv->pkey == pkey) {
-			result = -ENOTUNIQ;
-			priv = NULL;
-			goto err;
-		}
-	}
-
-	snprintf(intf_name, sizeof intf_name, "%s.%04x",
-		 ppriv->dev->name, pkey);
-	priv = ipoib_intf_alloc(intf_name);
-	if (!priv) {
-		result = -ENOMEM;
-		goto err;
-	}
-
 	priv->max_ib_mtu = ppriv->max_ib_mtu;
 	/* MTU will be reset when mcast join happens */
 	priv->dev->mtu   = IPOIB_UD_MTU(priv->max_ib_mtu);
@@ -134,14 +98,13 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	if (device_create_file(&priv->dev->dev, &dev_attr_parent))
 		goto sysfs_failed;
 
+	priv->child_type = type;
 	list_add_tail(&priv->list, &ppriv->child_intfs);
 
-	mutex_unlock(&ppriv->vlan_mutex);
-	rtnl_unlock();
-
 	return 0;
 
 sysfs_failed:
+	result = -ENOMEM;
 	ipoib_delete_debug_files(priv->dev);
 	unregister_netdevice(priv->dev);
 
@@ -149,11 +112,60 @@ register_failed:
 	ipoib_dev_cleanup(priv->dev);
 
 err:
+	return result;
+}
+
+int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
+{
+	struct ipoib_dev_priv *ppriv, *priv;
+	char intf_name[IFNAMSIZ];
+	struct ipoib_dev_priv *tpriv;
+	int result;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	ppriv = netdev_priv(pdev);
+
+	snprintf(intf_name, sizeof intf_name, "%s.%04x",
+		 ppriv->dev->name, pkey);
+	priv = ipoib_intf_alloc(intf_name);
+	if (!priv)
+		return -ENOMEM;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	mutex_lock(&ppriv->vlan_mutex);
+
+	/*
+	 * First ensure this isn't a duplicate. We check the parent device and
+	 * then all of the legacy child interfaces to make sure the Pkey
+	 * doesn't match.
+	 */
+	if (ppriv->pkey == pkey) {
+		result = -ENOTUNIQ;
+		goto out;
+	}
+
+	list_for_each_entry(tpriv, &ppriv->child_intfs, list) {
+		if (tpriv->pkey == pkey &&
+		    tpriv->child_type == IPOIB_LEGACY_CHILD) {
+			result = -ENOTUNIQ;
+			goto out;
+		}
+	}
+
+	result = __ipoib_vlan_add(ppriv, priv, pkey, IPOIB_LEGACY_CHILD);
+
+out:
 	mutex_unlock(&ppriv->vlan_mutex);
-	rtnl_unlock();
-	if (priv)
+
+	if (result)
 		free_netdev(priv->dev);
 
+	rtnl_unlock();
+
 	return result;
 }
 
@@ -171,9 +183,9 @@ int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
 		return restart_syscall();
 	mutex_lock(&ppriv->vlan_mutex);
 	list_for_each_entry_safe(priv, tpriv, &ppriv->child_intfs, list) {
-		if (priv->pkey == pkey) {
+		if (priv->pkey == pkey &&
+		    priv->child_type == IPOIB_LEGACY_CHILD) {
 			unregister_netdevice(priv->dev);
-			ipoib_dev_cleanup(priv->dev);
 			list_del(&priv->list);
 			dev = priv->dev;
 			break;
-- 
1.7.1
