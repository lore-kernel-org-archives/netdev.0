From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 8/9] net/bonding: Destroy bonding master when last slave is gone
Date: Tue,  9 Oct 2007 19:43:43 -0700
Message-ID: <11919842281401-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
 <11919842263810-git-send-email-fubar@us.ibm.com>
 <1191984226411-git-send-email-fubar@us.ibm.com>
 <11919842273755-git-send-email-fubar@us.ibm.com>
 <11919842272176-git-send-email-fubar@us.ibm.com>
 <11919842281663-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:48704 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbXJJCnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:51 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9A2hnQB018539
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hnAd421612
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:49 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hmXC002125
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:49 -0600
In-Reply-To: <11919842281663-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

When bonding enslaves non Ethernet devices it takes pointers to functions
in the module that owns the slaves. In this case it becomes unsafe
to keep the bonding master registered after last slave was unenslaved
because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
ensures that these functions be used anymore.

Signed-off-by: Moni Shoua <monis at voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |   38 ++++++++++++++++++++++++++++++++++++++
 drivers/net/bonding/bond_sysfs.c |    9 +++++----
 drivers/net/bonding/bonding.h    |    3 +++
 3 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19fd351..0e198dd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1257,6 +1257,8 @@ static int bond_compute_features(struct bonding *bond)
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
+	struct bonding *bond = bond_dev->priv;
+
 	bond_dev->neigh_setup           = slave_dev->neigh_setup;
 
 	bond_dev->type		    = slave_dev->type;
@@ -1265,6 +1267,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 
 	memcpy(bond_dev->broadcast, slave_dev->broadcast,
 		slave_dev->addr_len);
+	bond->setup_by_slave = 1;
 }
 
 /* enslave device <slave> to bond device <master> */
@@ -1828,6 +1831,35 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -3325,6 +3357,11 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 		 * ... Or is it this?
 		 */
 		break;
+	case NETDEV_GOING_DOWN:
+		dprintk("slave %s is going down\n", slave_dev->name);
+		if (bond->setup_by_slave)
+			bond_release_and_destroy(bond_dev, slave_dev);
+		break;
 	case NETDEV_CHANGEMTU:
 		/*
 		 * TODO: Should slaves be allowed to
@@ -4298,6 +4335,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
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
@@ -164,9 +164,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
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
@@ -363,7 +361,10 @@ static ssize_t bonding_store_slaves(struct device *d,
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
@@ -295,6 +296,8 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
+void bond_destroy(struct bonding *bond);
+int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 void bond_deinit(struct net_device *bond_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
-- 
1.5.3.1

