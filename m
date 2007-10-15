From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH V7 8/8] net/bonding: Destroy bonding master when last slave
 is gone
Date: Mon, 15 Oct 2007 18:14:43 +0200
Message-ID: <471391F3.5020209@voltaire.com>
References: <47138EB7.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: Moni Shoua <monisonlists@gmail.com>, jgarzik@pobox.com,
	fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:43399 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759152AbXJOQOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:14:46 -0400
In-Reply-To: <47138EB7.40703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When bonding enslaves non Ethernet devices it takes pointers to functions
in the module that owns the slaves. In this case it becomes unsafe
to keep the bonding master registered after last slave was unenslaved
because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
ensures that these functions be used anymore.

Signed-off-by: Moni Shoua <monis at voltaire.com>
---
 drivers/net/bonding/bond_main.c  |   37 ++++++++++++++++++++++++++++++++++++-
 drivers/net/bonding/bond_sysfs.c |    9 +++++----
 drivers/net/bonding/bonding.h    |    3 +++
 3 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c017042..23edf18 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1257,6 +1257,7 @@ static int bond_compute_features(struct 
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
+	struct bonding *bond = bond_dev->priv;
 	bond_dev->neigh_setup       = slave_dev->neigh_setup;
 
 	bond_dev->type		    = slave_dev->type;
@@ -1266,6 +1267,7 @@ static void bond_setup_by_slave(struct n
 
 	memcpy(bond_dev->broadcast, slave_dev->broadcast,
 		slave_dev->addr_len);
+	bond->setup_by_slave = 1;
 }
 
 /* enslave device <slave> to bond device <master> */
@@ -1829,6 +1831,35 @@ int bond_release(struct net_device *bond
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
+		printk(KERN_INFO DRV_NAME ": %s: destroying bond %s.\n",
+		       bond_dev->name, bond_dev->name);
+		bond_destroy(bond);
+	}
+	return ret;
+}
+
+/*
  * This function releases all slaves.
  */
 static int bond_release_all(struct net_device *bond_dev)
@@ -3311,7 +3342,10 @@ static int bond_slave_netdev_event(unsig
 	switch (event) {
 	case NETDEV_UNREGISTER:
 		if (bond_dev) {
-			bond_release(bond_dev, slave_dev);
+			if (bond->setup_by_slave)
+				bond_release_and_destroy(bond_dev, slave_dev);
+			else
+				bond_release(bond_dev, slave_dev);
 		}
 		break;
 	case NETDEV_CHANGE:
@@ -4299,6 +4333,7 @@ static int bond_init(struct net_device *
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
 	bond->send_grat_arp = 0;
+	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 583c568..b5d2a13 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -164,9 +164,7 @@ static ssize_t bonding_store_bonds(struc
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				bond_deinit(bond->dev);
-		        	bond_destroy_sysfs_entry(bond);
-				unregister_netdevice(bond->dev);
+				bond_destroy(bond);
 				rtnl_unlock();
 				goto out;
 			}
@@ -363,7 +361,10 @@ static ssize_t bonding_store_slaves(stru
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
 			rtnl_lock();
-			res = bond_release(bond->dev, dev);
+			if (bond->setup_by_slave)
+				res = bond_release_and_destroy(bond->dev, dev);
+			else
+				res = bond_release(bond->dev, dev);
 			rtnl_unlock();
 			if (res) {
 				ret = res;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e0e06a8..85e579b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
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

