From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V4 10/10] net/bonding: Destroy bonding master when last slave
 is gone
Date: Mon, 20 Aug 2007 18:58:37 +0300
Message-ID: <46C9BA2D.7060204@voltaire.com>
References: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com, davem@davemloft.net, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:32509 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759612AbXHTP6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 11:58:39 -0400
In-Reply-To: <46C9B474.5020202@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When bonding enslaves non Ethernet devices it takes pointers to functions 
in the module that owns the slaves. In this case it becomes unsafe
to keep the bonding master registered after last slave was unenslaved 
because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
ensures that these functions be used anymore.

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_main.c |   45 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/bonding/bonding.h   |    3 ++
 2 files changed, 47 insertions(+), 1 deletion(-)

Index: net-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- net-2.6.orig/drivers/net/bonding/bond_main.c	2007-08-20 14:43:17.123702132 +0300
+++ net-2.6/drivers/net/bonding/bond_main.c	2007-08-20 14:43:17.850571535 +0300
@@ -1256,6 +1256,7 @@ static int bond_compute_features(struct 
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
+	struct bonding *bond = bond_dev->priv;
 	bond_dev->hard_header	        = slave_dev->hard_header;
 	bond_dev->rebuild_header        = slave_dev->rebuild_header;
 	bond_dev->hard_header_cache	= slave_dev->hard_header_cache;
@@ -1270,6 +1271,7 @@ static void bond_setup_by_slave(struct n
 
 	memcpy(bond_dev->broadcast, slave_dev->broadcast,
 		slave_dev->addr_len);
+	bond->setup_by_slave = 1;
 }
 
 /* enslave device <slave> to bond device <master> */
@@ -1838,6 +1840,35 @@ int bond_release(struct net_device *bond
 }
 
 /*
+* Destroy a bonding device.
+* Must be under rtnl_lock when this function is called.
+*/
+void bond_destroy(struct bonding *bond)
+{
+	bond_deinit(bond->dev);
+	bond_destroy_sysfs_entry(bond);
+	unregister_netdevice(bond->dev);
+}
+
+/*
+* First release a slave and than destroy the bond if no more slaves iare left.
+* Must be under rtnl_lock when this function is called.
+*/
+int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+	int ret;
+
+	ret = bond_release(bond_dev, slave_dev);
+	if ((ret == 0) && (bond->slave_cnt == 0)) {
+		printk(KERN_INFO DRV_NAME " %s: destroying bond for.\n",
+					bond_dev->name);
+		bond_destroy(bond);
+	}
+	return ret;
+}
+
+/*
  * This function releases all slaves.
  */
 static int bond_release_all(struct net_device *bond_dev)
@@ -3322,7 +3353,11 @@ static int bond_slave_netdev_event(unsig
 	switch (event) {
 	case NETDEV_UNREGISTER:
 		if (bond_dev) {
-			bond_release(bond_dev, slave_dev);
+			dprintk("slave %s unregisters\n", slave_dev->name);
+			if (bond->setup_by_slave)
+				bond_release_and_destroy(bond_dev, slave_dev);
+			else
+				bond_release(bond_dev, slave_dev);
 		}
 		break;
 	case NETDEV_CHANGE:
@@ -3331,6 +3366,13 @@ static int bond_slave_netdev_event(unsig
 		 * sets up a hierarchical bond, then rmmod's
 		 * one of the slave bonding devices?
 		 */
+		if (slave_dev->priv_flags & IFF_SLAVE_DETACH) {
+			dprintk("slave %s detaching\n", slave_dev->name);
+			if (bond->setup_by_slave)
+				bond_release_and_destroy(bond_dev, slave_dev);
+			else
+				bond_release(bond_dev, slave_dev);
+		}
 		break;
 	case NETDEV_DOWN:
 		/*
@@ -4311,6 +4353,7 @@ static int bond_init(struct net_device *
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
 	bond->send_grat_arp = 0;
+	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
Index: net-2.6/drivers/net/bonding/bonding.h
===================================================================
--- net-2.6.orig/drivers/net/bonding/bonding.h	2007-08-20 14:43:17.123702132 +0300
+++ net-2.6/drivers/net/bonding/bonding.h	2007-08-20 14:47:52.845180870 +0300
@@ -188,6 +188,7 @@ struct bonding {
 	s8       kill_timers;
 	s8       do_set_mac_addr;
 	s8	 send_grat_arp;
+	s8	 setup_by_slave;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
@@ -295,6 +296,8 @@ static inline void bond_unset_master_alb
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
+void bond_destroy(struct bonding *bond);
+int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_deinit(struct net_device *bond_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);

