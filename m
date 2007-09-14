From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [ofa-general] [PATCH 02/11] IB/ipoib: Notify the world before doing
	unregister
Date: Fri, 14 Sep 2007 16:40:21 -0700
Message-ID: <1189813234208-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
	<11898132322950-git-send-email-fubar@us.ibm.com>
Cc: general@lists.openfabrics.org, jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <11898132322950-git-send-email-fubar@us.ibm.com>
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

From: Moni Shoua <monis@voltaire.com>

When the bonding device enslaves IPoIB devices it takes pointers to
functions in the ib_ipoib module. This is fine as long as the ib_ipoib
nodule remains loaded while the references to its functions exist.
So, to help bonding do a cleanup on time, when the IPoIB net device is a
slave of a bonding master, let the master know that the IPoIB device is
about to unregister (but before calling unregister).

Signed-off-by: Moni Shoua <monis@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 894b1dc..97a9661 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -48,6 +48,7 @@
 #include <linux/in.h>
 
 #include <net/dst.h>
+#include <linux/netdevice.h>
 
 MODULE_AUTHOR("Roland Dreier");
 MODULE_DESCRIPTION("IP-over-InfiniBand net driver");
@@ -772,6 +773,18 @@ static void ipoib_timeout(struct net_device *dev)
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
@@ -921,6 +934,7 @@ void ipoib_dev_cleanup(struct net_device *dev)
 
 	/* Delete any child interfaces first */
 	list_for_each_entry_safe(cpriv, tcpriv, &priv->child_intfs, list) {
+		ipoib_slave_detach(cpriv->dev);
 		unregister_netdev(cpriv->dev);
 		ipoib_dev_cleanup(cpriv->dev);
 		free_netdev(cpriv->dev);
@@ -1208,6 +1222,7 @@ static void ipoib_remove_one(struct ib_device *device)
 		ib_unregister_event_handler(&priv->event_handler);
 		flush_scheduled_work();
 
+		ipoib_slave_detach(priv->dev);
 		unregister_netdev(priv->dev);
 		ipoib_dev_cleanup(priv->dev);
 		free_netdev(priv->dev);
-- 
1.5.2-rc2.GIT
