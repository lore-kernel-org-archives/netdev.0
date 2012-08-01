From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 01/12] IB/ipoib: Add rtnl_link_ops support
Date: Wed,  1 Aug 2012 20:09:24 +0300
Message-ID: <1343840975-3252-2-git-send-email-ogerlitz@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:48666 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752711Ab2HARKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 13:10:04 -0400
In-Reply-To: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add rtnl_link_ops to IPoIB, with the first usage being child device
create/delete through them. For that end, did little refactoring
of the ipoib_vlan_add/delete code which is now used by both the
sysfs and the rtnl_link_ops code.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 Documentation/infiniband/ipoib.txt           |    3 +
 drivers/infiniband/ulp/ipoib/Makefile        |    3 +-
 drivers/infiniband/ulp/ipoib/ipoib.h         |    8 ++
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   10 ++-
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |  110 ++++++++++++++++++++++++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c    |   80 ++++++++++++-------
 6 files changed, 181 insertions(+), 33 deletions(-)
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
index 86df632..adcfa66 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -493,6 +493,14 @@ void ipoib_event(struct ib_event_handler *handler,
 int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey);
 int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey);
 
+int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv, u16 pkey);
+struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey);
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
index bbee4b2..637980b 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -995,7 +995,7 @@ static const struct net_device_ops ipoib_netdev_ops = {
 	.ndo_neigh_setup	 = ipoib_neigh_setup_dev,
 };
 
-static void ipoib_setup(struct net_device *dev)
+void ipoib_setup(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
@@ -1402,8 +1402,15 @@ static int __init ipoib_init_module(void)
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
@@ -1416,6 +1423,7 @@ err_fs:
 
 static void __exit ipoib_cleanup_module(void)
 {
+	ipoib_netlink_fini();
 	ib_unregister_client(&ipoib_client);
 	ib_sa_unregister_client(&ipoib_sa_client);
 	ipoib_unregister_debugfs();
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
new file mode 100644
index 0000000..2b8905e
--- /dev/null
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -0,0 +1,110 @@
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
+	ppriv = netdev_priv(pdev);
+
+	if (!data || !data[IFLA_IPOIB_CHILD_PKEY]) {
+		ipoib_warn(ppriv, "no pkey specified, failing request\n");
+		return -EINVAL;
+	} else
+		child_pkey  = nla_get_u16(data[IFLA_IPOIB_CHILD_PKEY]);
+
+	err = __ipoib_vlan_add(ppriv, netdev_priv(dev), child_pkey);
+
+	return err;
+}
+
+static void ipoib_unregister_child_dev(struct net_device *dev, struct list_head *head)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+
+	(void)__ipoib_vlan_delete(priv->parent, priv->pkey);
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
index d7e9740..4a9b7e6 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -49,19 +49,13 @@ static ssize_t show_parent(struct device *d, struct device_attribute *attr,
 }
 static DEVICE_ATTR(parent, S_IRUGO, show_parent, NULL);
 
-int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
+
+int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
+		     u16 pkey)
 {
-	struct ipoib_dev_priv *ppriv, *priv;
-	char intf_name[IFNAMSIZ];
 	int result;
+	struct ipoib_dev_priv *tpriv;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	ppriv = netdev_priv(pdev);
-
-	if (!rtnl_trylock())
-		return restart_syscall();
 	mutex_lock(&ppriv->vlan_mutex);
 
 	/*
@@ -70,26 +64,16 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	 */
 	if (ppriv->pkey == pkey) {
 		result = -ENOTUNIQ;
-		priv = NULL;
 		goto err;
 	}
 
-	list_for_each_entry(priv, &ppriv->child_intfs, list) {
-		if (priv->pkey == pkey) {
+	list_for_each_entry(tpriv, &ppriv->child_intfs, list) {
+		if (tpriv->pkey == pkey) {
 			result = -ENOTUNIQ;
-			priv = NULL;
 			goto err;
 		}
 	}
 
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
@@ -137,11 +121,10 @@ int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 	list_add_tail(&priv->list, &ppriv->child_intfs);
 
 	mutex_unlock(&ppriv->vlan_mutex);
-	rtnl_unlock();
-
 	return 0;
 
 sysfs_failed:
+	result = -ENOMEM;
 	ipoib_delete_debug_files(priv->dev);
 	unregister_netdevice(priv->dev);
 
@@ -150,25 +133,46 @@ register_failed:
 
 err:
 	mutex_unlock(&ppriv->vlan_mutex);
-	rtnl_unlock();
-	if (priv)
-		free_netdev(priv->dev);
-
 	return result;
 }
 
-int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
+int ipoib_vlan_add(struct net_device *pdev, unsigned short pkey)
 {
-	struct ipoib_dev_priv *ppriv, *priv, *tpriv;
-	struct net_device *dev = NULL;
+	struct ipoib_dev_priv *ppriv, *priv;
+	char intf_name[IFNAMSIZ];
+	int result;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
 	ppriv = netdev_priv(pdev);
 
+	snprintf(intf_name, sizeof intf_name, "%s.%04x",
+		 ppriv->dev->name, pkey);
+	priv = ipoib_intf_alloc(intf_name);
+	if (!priv)
+		return -ENOMEM;
+
 	if (!rtnl_trylock())
 		return restart_syscall();
+
+	result = __ipoib_vlan_add(ppriv, priv, pkey);
+
+	if (result)
+		free_netdev(priv->dev);
+
+	rtnl_unlock();
+
+	return result;
+}
+
+struct net_device * __ipoib_vlan_delete(struct net_device *pdev, u16 pkey)
+{
+	struct ipoib_dev_priv *ppriv, *priv, *tpriv;
+	struct net_device *dev = NULL;
+
+	ppriv = netdev_priv(pdev);
+
 	mutex_lock(&ppriv->vlan_mutex);
 	list_for_each_entry_safe(priv, tpriv, &ppriv->child_intfs, list) {
 		if (priv->pkey == pkey) {
@@ -180,6 +184,20 @@ int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
 		}
 	}
 	mutex_unlock(&ppriv->vlan_mutex);
+
+	return dev;
+}
+
+int ipoib_vlan_delete(struct net_device *pdev, unsigned short pkey)
+{
+	struct net_device *dev;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+	dev = __ipoib_vlan_delete(pdev, pkey);
 	rtnl_unlock();
 
 	if (dev) {
-- 
1.7.1
