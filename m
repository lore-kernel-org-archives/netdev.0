From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 9/9] bonding: initialization rework
Date: Fri, 12 Jun 2009 22:02:52 -0700
Message-ID: <20090613050422.305329705@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49231 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698AbZFMFGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:15 -0400
Content-Disposition: inline; filename=bond_setup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to rework how bonding devices are initialized to make it more
amenable to creating bonding devices via netlink.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/bonding/bond_main.c |   67 +++++++++++++++++-----------------------
 1 file changed, 30 insertions(+), 37 deletions(-)

--- a/drivers/net/bonding/bond_main.c	2009-06-12 21:46:35.170615781 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 21:46:37.135624224 -0700
@@ -210,6 +210,7 @@ struct bond_parm_tbl ad_select_tbl[] = {
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
+static int bond_init(struct net_device *bond_dev);
 static void bond_deinit(struct net_device *bond_dev);
 
 /*---------------------------- General routines -----------------------------*/
@@ -4518,6 +4519,7 @@ static const struct ethtool_ops bond_eth
 };
 
 static const struct net_device_ops bond_netdev_ops = {
+	.ndo_init		= bond_init,
 	.ndo_uninit		= bond_uninit,
 	.ndo_open		= bond_open,
 	.ndo_stop		= bond_close,
@@ -4533,38 +4535,22 @@ static const struct net_device_ops bond_
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
 };
 
-/*
- * Does not allocate but creates a /proc entry.
- * Allowed to fail.
- */
-static int bond_init(struct net_device *bond_dev)
+static void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	pr_debug("Begin bond_init for %s\n", bond_dev->name);
-
 	/* initialize rwlocks */
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
 
 	bond->params = bonding_defaults;
 
-	bond->wq = create_singlethread_workqueue(bond_dev->name);
-	if (!bond->wq)
-		return -ENOMEM;
-
 	/* Initialize pointers */
-	bond->first_slave = NULL;
-	bond->curr_active_slave = NULL;
-	bond->current_arp_slave = NULL;
-	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
-	bond->send_grat_arp = 0;
-	bond->send_unsol_na = 0;
-	bond->setup_by_slave = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
+	ether_setup(bond_dev);
 	bond_dev->netdev_ops = &bond_netdev_ops;
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
 	bond_set_mode_ops(bond, bond->params.mode);
@@ -4575,6 +4561,8 @@ static int bond_init(struct net_device *
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
 	bond_dev->priv_flags |= IFF_BONDING;
+	bond_dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
+
 	if (bond->params.arp_interval)
 		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
 
@@ -4599,10 +4587,6 @@ static int bond_init(struct net_device *
 			       NETIF_F_HW_VLAN_RX |
 			       NETIF_F_HW_VLAN_FILTER);
 
-	bond_create_proc_entry(bond);
-	list_add_tail(&bond->bond_list, &bond_dev_list);
-
-	return 0;
 }
 
 static void bond_work_cancel_all(struct bonding *bond)
@@ -5056,6 +5040,29 @@ static void bond_set_lockdep_class(struc
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
 }
 
+/*
+ * Called from registration process
+ */
+static int bond_init(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	pr_debug("Begin bond_init for %s\n", bond_dev->name);
+
+	bond->wq = create_singlethread_workqueue(bond_dev->name);
+	if (!bond->wq)
+		return -ENOMEM;
+
+	bond_set_lockdep_class(bond_dev);
+
+	netif_carrier_off(bond_dev);
+
+	bond_create_proc_entry(bond);
+	list_add_tail(&bond->bond_list, &bond_dev_list);
+
+	return 0;
+}
+
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -5077,7 +5084,7 @@ int bond_create(const char *name)
 	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
-				ether_setup);
+				bond_setup);
 	if (!bond_dev) {
 		pr_err(DRV_NAME ": %s: eek! can't alloc netdev!\n",
 		       name);
@@ -5085,26 +5092,12 @@ int bond_create(const char *name)
 		goto out_rtnl;
 	}
 
-	bond_dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 	if (!name) {
 		res = dev_alloc_name(bond_dev, "bond%d");
 		if (res < 0)
 			goto out_netdev;
 	}
 
-	/* bond_init() must be called after dev_alloc_name() (for the
-	 * /proc files), but before register_netdevice(), because we
-	 * need to set function pointers.
-	 */
-
-	res = bond_init(bond_dev);
-	if (res < 0)
-		goto out_netdev;
-
-	bond_set_lockdep_class(bond_dev);
-
-	netif_carrier_off(bond_dev);
-
 	res = register_netdevice(bond_dev);
 	if (res < 0)
 		goto out_bond;

-- 

