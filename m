From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V4 2/10] IB/ipoib: Notify the world before
	doing unregister
Date: Mon, 20 Aug 2007 18:43:43 +0300
Message-ID: <46C9B6AF.5030402@voltaire.com>
References: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com,  davem@davemloft.net,  fubar@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46C9B474.5020202@voltaire.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

When the bonding device enslaves IPoIB devices it takes pointers to
functions in the ib_ipoib module. This is fine as long as the ib_ipoib
nodule remains loaded while the references to its functions exist.
So, to help bonding do a cleanup on time, when the IPoIB net device is a 
slave of a bonding master, let the master know that the IPoIB device is
about to unregister (but before calling unregister).

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+)

Index: net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c
===================================================================
--- net-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-08-20 14:29:29.522209580 +0300
+++ net-2.6/drivers/infiniband/ulp/ipoib/ipoib_main.c	2007-08-20 14:43:03.432162133 +0300
@@ -48,6 +48,7 @@
 #include <linux/in.h>
 
 #include <net/dst.h>
+#include <linux/netdevice.h>
 
 MODULE_AUTHOR("Roland Dreier");
 MODULE_DESCRIPTION("IP-over-InfiniBand net driver");
@@ -772,6 +773,18 @@ static void ipoib_timeout(struct net_dev
 	/* XXX reset QP, etc. */
 }
 
+static int ipoib_slave_detach(struct net_device *dev)
+{
+	int ret = 0;
+	if (dev->flags & IFF_SLAVE) {
+		dev->priv_flags |= IFF_SLAVE_DETACH;
+		rtnl_lock();
+		ret = call_netdevice_notifiers(NETDEV_CHANGE, dev);
+		rtnl_unlock();
+	}
+	return ret;
+}
+
 static int ipoib_hard_header(struct sk_buff *skb,
 			     struct net_device *dev,
 			     unsigned short type,
@@ -921,6 +934,7 @@ void ipoib_dev_cleanup(struct net_device
 
 	/* Delete any child interfaces first */
 	list_for_each_entry_safe(cpriv, tcpriv, &priv->child_intfs, list) {
+		ipoib_slave_detach(cpriv->dev);
 		unregister_netdev(cpriv->dev);
 		ipoib_dev_cleanup(cpriv->dev);
 		free_netdev(cpriv->dev);
@@ -1208,6 +1222,7 @@ static void ipoib_remove_one(struct ib_d
 		ib_unregister_event_handler(&priv->event_handler);
 		flush_scheduled_work();
 
+		ipoib_slave_detach(priv->dev);
 		unregister_netdev(priv->dev);
 		ipoib_dev_cleanup(priv->dev);
 		free_netdev(priv->dev);
