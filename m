From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] bonding: clean up netpoll code
Date: Wed, 1 Dec 2010 02:45:45 -0500
Message-ID: <20101201075043.5741.29172.sendpatchset@localhost.localdomain>
Cc: Jiri Pirko <jpirko@redhat.com>, Neil Horman <nhorman@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Amerigo Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Against net-next-2.6.

This patch unifies the netpoll code in bonding with netpoll code in bridge,
thanks to Herbert that code is much cleaner now.

It also removes the flag IFF_IN_NETPOLL, we don't need it any more since
we have netpoll_tx_running() now.

It passes my basic testings.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Neil Horman <nhorman@redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>


---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0273ad0..0f04cd0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -59,7 +59,6 @@
 #include <linux/uaccess.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
-#include <linux/netpoll.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
 #include <linux/etherdevice.h>
@@ -450,13 +449,9 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 
 	skb->priority = 1;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	if (unlikely(bond->dev->priv_flags & IFF_IN_NETPOLL)) {
-		struct netpoll *np = bond->dev->npinfo->netpoll;
-		slave_dev->npinfo = bond->dev->npinfo;
-		slave_dev->priv_flags |= IFF_IN_NETPOLL;
-		netpoll_send_skb_on_dev(np, skb, slave_dev);
-		slave_dev->priv_flags &= ~IFF_IN_NETPOLL;
-	} else
+	if (unlikely(netpoll_tx_running(slave_dev)))
+		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
+	else
 #endif
 		dev_queue_xmit(skb);
 
@@ -1310,63 +1305,113 @@ static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-/*
- * You must hold read lock on bond->lock before calling this.
- */
-static bool slaves_support_netpoll(struct net_device *bond_dev)
+static inline int slave_enable_netpoll(struct slave *slave)
 {
-	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
-	int i = 0;
-	bool ret = true;
+	struct netpoll *np;
+	int err = 0;
 
-	bond_for_each_slave(bond, slave, i) {
-		if ((slave->dev->priv_flags & IFF_DISABLE_NETPOLL) ||
-		    !slave->dev->netdev_ops->ndo_poll_controller)
-			ret = false;
+	np = kmalloc(sizeof(*np), GFP_KERNEL);
+	err = -ENOMEM;
+	if (!np)
+		goto out;
+
+	np->dev = slave->dev;
+	err = __netpoll_setup(np);
+	if (err) {
+		kfree(np);
+		goto out;
 	}
-	return i != 0 && ret;
+	slave->np = np;
+out:
+	return err;
+}
+static inline void slave_disable_netpoll(struct slave *slave)
+{
+	struct netpoll *np = slave->np;
+
+	if (!np)
+		return;
+
+	slave->np = NULL;
+	synchronize_rcu_bh();
+	__netpoll_cleanup(np);
+	kfree(np);
+}
+static inline bool slave_dev_support_netpoll(struct net_device *slave_dev)
+{
+	if (slave_dev->priv_flags & IFF_DISABLE_NETPOLL)
+		return false;
+	if (!slave_dev->netdev_ops->ndo_poll_controller)
+		return false;
+	return true;
 }
 
 static void bond_poll_controller(struct net_device *bond_dev)
 {
-	struct bonding *bond = netdev_priv(bond_dev);
+}
+
+static void __bond_netpoll_cleanup(struct bonding *bond)
+{
 	struct slave *slave;
 	int i;
 
-	bond_for_each_slave(bond, slave, i) {
-		if (slave->dev && IS_UP(slave->dev))
-			netpoll_poll_dev(slave->dev);
-	}
+	bond_for_each_slave(bond, slave, i)
+		if (slave->dev)
+			slave_disable_netpoll(slave);
 }
-
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+
+	read_lock(&bond->lock);
+	__bond_netpoll_cleanup(bond);
+	read_unlock(&bond->lock);
+}
+
+static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
+{
+	struct bonding *bond = netdev_priv(dev);
 	struct slave *slave;
-	const struct net_device_ops *ops;
-	int i;
+	int i, err = 0;
 
 	read_lock(&bond->lock);
-	bond_dev->npinfo = NULL;
 	bond_for_each_slave(bond, slave, i) {
-		if (slave->dev) {
-			ops = slave->dev->netdev_ops;
-			if (ops->ndo_netpoll_cleanup)
-				ops->ndo_netpoll_cleanup(slave->dev);
-			else
-				slave->dev->npinfo = NULL;
+		if (!slave->dev)
+			continue;
+		err = slave_enable_netpoll(slave);
+		if (err) {
+			__bond_netpoll_cleanup(bond);
+			break;
 		}
 	}
 	read_unlock(&bond->lock);
+	return err;
 }
 
-#else
+static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
+{
+	return bond->dev->npinfo;
+}
 
+#else
+static inline int slave_enable_netpoll(struct slave *slave)
+{
+	return 0;
+}
+static inline void slave_disable_netpoll(struct slave *slave)
+{
+}
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
 {
 }
-
+static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
+{
+	return 0;
+}
+static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
+{
+	return NULL;
+}
 #endif
 
 /*---------------------------------- IOCTL ----------------------------------*/
@@ -1804,17 +1849,18 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	if (slaves_support_netpoll(bond_dev)) {
-		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-		if (bond_dev->npinfo)
-			slave_dev->npinfo = bond_dev->npinfo;
-	} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
-		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		pr_info("New slave device %s does not support netpoll\n",
-			slave_dev->name);
-		pr_info("Disabling netpoll support for %s\n", bond_dev->name);
+	if ((slave_dev->npinfo = bond_netpoll_info(bond))) {
+		if (slave_enable_netpoll(new_slave)) {
+			read_unlock(&bond->lock);
+			pr_info("Error, %s: master_dev is using netpoll, "
+				 "but new slave device does not support netpoll.\n",
+				 bond_dev->name);
+			res = -EBUSY;
+			goto err_close;
+		}
 	}
 #endif
+
 	read_unlock(&bond->lock);
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
@@ -2016,17 +2062,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	netdev_set_master(slave_dev, NULL);
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	read_lock_bh(&bond->lock);
-
-	if (slaves_support_netpoll(bond_dev))
-		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-	read_unlock_bh(&bond->lock);
-	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
-		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
-	else
-		slave_dev->npinfo = NULL;
-#endif
+	slave_disable_netpoll(slave);
 
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
@@ -2061,6 +2097,7 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 
 	ret = bond_release(bond_dev, slave_dev);
 	if ((ret == 0) && (bond->slave_cnt == 0)) {
+		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
 		pr_info("%s: destroying bond %s.\n",
 			bond_dev->name, bond_dev->name);
 		unregister_netdevice(bond_dev);
@@ -2138,6 +2175,8 @@ static int bond_release_all(struct net_device *bond_dev)
 
 		netdev_set_master(slave_dev, NULL);
 
+		slave_disable_netpoll(slave);
+
 		/* close slave before restoring its mac address */
 		dev_close(slave_dev);
 
@@ -4670,6 +4709,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_vlan_rx_add_vid 	= bond_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_setup	= bond_netpoll_setup,
 	.ndo_netpoll_cleanup	= bond_netpoll_cleanup,
 	.ndo_poll_controller	= bond_poll_controller,
 #endif
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ad3ae46..6a5abf0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -21,6 +21,7 @@
 #include <linux/kobject.h>
 #include <linux/cpumask.h>
 #include <linux/in6.h>
+#include <linux/netpoll.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
@@ -137,7 +138,7 @@ static inline void unblock_netpoll_tx(void)
 
 static inline int is_netpoll_tx_blocked(struct net_device *dev)
 {
-	if (unlikely(dev->priv_flags & IFF_IN_NETPOLL))
+	if (unlikely(netpoll_tx_running(dev)))
 		return cpumask_test_cpu(smp_processor_id(), netpoll_block_tx);
 	return 0;
 }
@@ -203,6 +204,9 @@ struct slave {
 	u16    queue_id;
 	struct ad_slave_info ad_info; /* HUGE - better to dynamically alloc */
 	struct tlb_slave_info tlb_info;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll *np;
+#endif
 };
 
 /*
@@ -324,6 +328,23 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
 	return slave->dev->last_rx;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static inline void bond_netpoll_send_skb(const struct slave *slave,
+					 struct sk_buff *skb)
+{
+	struct netpoll *np = slave->np;
+	struct net_device *slave_dev = slave->dev;
+
+	if (np)
+		netpoll_send_skb(np, skb);
+}
+#else
+static inline void bond_netpoll_send_skb(const struct slave *slave,
+					 struct sk_buff *skb)
+{
+}
+#endif
+
 static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
 	struct bonding *bond = netdev_priv(slave->dev->master);
diff --git a/include/linux/if.h b/include/linux/if.h
index 1239599..3bc63e6 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -71,11 +71,10 @@
 					 * release skb->dst
 					 */
 #define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
-#define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
-#define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
-#define IFF_MACVLAN_PORT	0x4000	/* device used as macvlan port */
-#define IFF_BRIDGE_PORT	0x8000		/* device used as bridge port */
-#define IFF_OVS_DATAPATH	0x10000	/* device used as Open vSwitch
+#define IFF_DISABLE_NETPOLL	0x1000	/* disable netpoll at run-time */
+#define IFF_MACVLAN_PORT	0x2000	/* device used as macvlan port */
+#define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
+#define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
 					 * datapath port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ee38acb..8a5c1c9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -314,9 +314,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_tx_queue_stopped(txq)) {
-					dev->priv_flags |= IFF_IN_NETPOLL;
 					status = ops->ndo_start_xmit(skb, dev);
-					dev->priv_flags &= ~IFF_IN_NETPOLL;
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
 				}
