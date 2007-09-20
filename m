From: Moni Shoua <monis@voltaire.com>
Subject: [ofa-general] [PATCH V5 1/11] net/core: add a netdev notification
	for slave detach
Date: Thu, 20 Sep 2007 16:39:25 +0300
Message-ID: <46F2780D.5090702@voltaire.com>
References: <46F27692.3070404@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F27692.3070404@voltaire.com>
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

A slave of a bonding master that wants to send a notification before
going down should call netdev_slave_detach(). The handling of this notification
will be done outside the context of unregister_netdevice() which is sometimes
necessary, as with IPoIB slave for example.

Signed-off-by: Moni Shoua <monis at voltaire.com>
---
 include/linux/if.h |    1 +
 net/core/dev.c     |   20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

Index: net-2.6/net/core/dev.c
===================================================================
--- net-2.6.orig/net/core/dev.c	2007-09-20 08:04:47.164051688 +0200
+++ net-2.6/net/core/dev.c	2007-09-20 09:20:21.493060579 +0200
@@ -2588,6 +2588,25 @@ int netdev_set_master(struct net_device 
 	return 0;
 }
 
+/**
+ *	netdev_slave_detach	-	notify that slave is about to detach from master
+ *	@slave: slave device
+ *
+ *	Raise a flag that slave is about to detach from master
+ *	and notify the netdev  chain.
+ *	The caller must hold the rtnl_mutex.
+ */
+
+int netdev_slave_detach(struct net_device *slave)
+{
+	int ret = 0;
+	if (slave->flags & IFF_SLAVE) {
+		slave->priv_flags |= IFF_SLAVE_DETACH;
+		ret = call_netdevice_notifiers(NETDEV_CHANGE, slave);
+	}
+	return ret;
+}
+
 static void __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
@@ -4120,6 +4139,7 @@ EXPORT_SYMBOL(dev_set_mac_address);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);
+EXPORT_SYMBOL(netdev_slave_detach);
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(netif_receive_skb);
 EXPORT_SYMBOL(netif_rx);
Index: net-2.6/include/linux/if.h
===================================================================
--- net-2.6.orig/include/linux/if.h	2007-09-20 08:04:47.164051688 +0200
+++ net-2.6/include/linux/if.h	2007-09-20 08:15:29.577729301 +0200
@@ -61,6 +61,7 @@
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
+#define IFF_SLAVE_DETACH 0x80		/* slave is about to unregister */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
