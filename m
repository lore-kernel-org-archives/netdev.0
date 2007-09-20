From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V5 2/11] IB/ipoib: Notify the world before doing unregister
Date: Thu, 20 Sep 2007 16:40:28 +0300
Message-ID: <46F2784C.9070806@voltaire.com>
References: <46F27692.3070404@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:15312 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754456AbXITNka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 09:40:30 -0400
In-Reply-To: <46F27692.3070404@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the bonding device enslaves IPoIB devices it takes pointers to
functions in the ib_ipoib module. This is fine as long as the ib_ipoib
nodule remains loaded while the references to its functions exist.
So, to help bonding do a cleanup on time, when the IPoIB net device is a 
slave of a bonding master, let the master know that the IPoIB device is
about to unregister (but before calling unregister).

Signed-off-by: Moni Shoua <monis at voltaire.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h      |    7 +++++++
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    3 +++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c |    1 +
 3 files changed, 11 insertions(+)

Index: net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c
===================================================================
--- net-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-09-20 08:35:34.000000000 +0200
+++ net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-09-20 14:20:16.495147879 +0200
@@ -48,6 +48,7 @@
 #include <linux/in.h>
 
 #include <net/dst.h>
+#include <linux/netdevice.h>
 
 MODULE_AUTHOR("Roland Dreier");
 MODULE_DESCRIPTION("IP-over-InfiniBand net driver");
@@ -921,6 +922,7 @@ void ipoib_dev_cleanup(struct net_device
 
 	/* Delete any child interfaces first */
 	list_for_each_entry_safe(cpriv, tcpriv, &priv->child_intfs, list) {
+		ipoib_slave_detach(cpriv->dev);
 		unregister_netdev(cpriv->dev);
 		ipoib_dev_cleanup(cpriv->dev);
 		free_netdev(cpriv->dev);
@@ -1208,6 +1210,7 @@ static void ipoib_remove_one(struct ib_d
 		ib_unregister_event_handler(&priv->event_handler);
 		flush_scheduled_work();
 
+		ipoib_slave_detach(priv->dev);
 		unregister_netdev(priv->dev);
 		ipoib_dev_cleanup(priv->dev);
 		free_netdev(priv->dev);
Index: net-2.6/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
===================================================================
--- net-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_vlan.c	2007-09-20 09:26:11.000000000 +0200
+++ net-2.6/drivers/infiniband/ulp/ipoib/ipoib_vlan.c	2007-09-20 09:27:20.182709679 +0200
@@ -157,6 +157,7 @@ int ipoib_vlan_delete(struct net_device 
 	mutex_lock(&ppriv->vlan_mutex);
 	list_for_each_entry_safe(priv, tpriv, &ppriv->child_intfs, list) {
 		if (priv->pkey == pkey) {
+			ipoib_slave_detach(priv->dev);
 			unregister_netdev(priv->dev);
 			ipoib_dev_cleanup(priv->dev);
 			list_del(&priv->list);
Index: net-2.6/drivers/infiniband/ulp/ipoib/ipoib.h
===================================================================
--- net-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib.h	2007-09-20 12:18:56.000000000 +0200
+++ net-2.6/drivers/infiniband/ulp/ipoib/ipoib.h	2007-09-20 14:21:47.385972207 +0200
@@ -570,6 +570,13 @@ static inline void ipoib_cm_handle_rx_wc
 
 #endif
 
+static inline void ipoib_slave_detach(struct net_device *dev)
+{
+	rtnl_lock();
+	netdev_slave_detach(dev);
+	rtnl_unlock();
+}
+
 #ifdef CONFIG_INFINIBAND_IPOIB_DEBUG
 void ipoib_create_debug_files(struct net_device *dev);
 void ipoib_delete_debug_files(struct net_device *dev);

