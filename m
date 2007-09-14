From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 10/11] net/bonding: Destroy bonding master when last slave is gone
Date: Fri, 14 Sep 2007 16:40:29 -0700
Message-ID: <11898132492312-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
 <11898132352341-git-send-email-fubar@us.ibm.com>
 <11898132372856-git-send-email-fubar@us.ibm.com>
 <11898132411426-git-send-email-fubar@us.ibm.com>
 <1189813242354-git-send-email-fubar@us.ibm.com>
 <11898132441599-git-send-email-fubar@us.ibm.com>
 <11898132452802-git-send-email-fubar@us.ibm.com>
 <11898132472055-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:45859 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757981AbXINXkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:52 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENepwT032067
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:51 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENepeU641410
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:51 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENeonh008989
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:51 -0400
In-Reply-To: <11898132472055-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

When bonding enslaves non Ethernet devices it takes pointers to functions
in the module that owns the slaves. In this case it becomes unsafe
to keep the bonding master registered after last slave was unenslaved
because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
ensures that these functions be used anymore.

Signed-off-by: Moni Shoua <monis@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   45 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/bonding/bonding.h   |    3 ++
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dfbfb00..77caca3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1256,6 +1256,7 @@ static int bond_compute_features(struct bonding *bond)
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
+	struct bonding *bond = bond_dev->priv;
 	bond_dev->hard_header	        = slave_dev->hard_header;
 	bond_dev->rebuild_header        = slave_dev->rebuild_header;
 	bond_dev->hard_header_cache	= slave_dev->hard_header_cache;
@@ -1270,6 +1271,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 
 	memcpy(bond_dev->broadcast, slave_dev->broadcast,
 		slave_dev->addr_len);
+	bond->setup_by_slave = 1;
 }
 
 /* enslave device <slave> to bond device <master> */
@@ -1838,6 +1840,35 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -3322,7 +3353,11 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
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
@@ -3331,6 +3366,13 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
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
@@ -4311,6 +4353,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
 	bond->send_grat_arp = 0;
+	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b1cdb1f..ed0f587 100644
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
1.5.2-rc2.GIT

