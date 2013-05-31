From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next 5/6] bonding: Convert hw addr handling to sync/unsync, support ucast addresses
Date: Thu, 30 May 2013 17:55:43 -0700
Message-ID: <1369961744-21460-6-git-send-email-fubar@us.ibm.com>
References: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:59825 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab3EaA4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:56:05 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 30 May 2013 18:56:04 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id F1CB1C90058
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:56:00 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4V0u13839059650
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 20:56:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4V0u0tr012374
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 21:56:01 -0300
In-Reply-To: <1369961744-21460-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patch converts bonding to use the dev_uc/mc_sync and
dev_uc/mc_sync_multiple functions for updating the hardware addresses
of bonding slaves.

	The existing functions to add or remove addresses are removed,
and their functionality is replaced with calls to dev_mc_sync or
dev_mc_sync_multiple, depending upon the bonding mode.

	Calls to dev_uc_sync and dev_uc_sync_multiple are also added,
so that unicast addresses added to a bond will be properly synced with
its slaves.

	Various functions are renamed to better reflect the new
situation, and relevant comments are updated.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Cc: Vlad Yasevich <vyasevic@redhat.com> 

---
 drivers/net/bonding/bond_main.c | 164 ++++++++++------------------------------
 drivers/net/bonding/bonding.h   |   1 -
 2 files changed, 39 insertions(+), 126 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f4489d6..92e085f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -706,45 +706,6 @@ static int bond_set_allmulti(struct bonding *bond, int inc)
 	return err;
 }
 
-/*
- * Add a Multicast address to slaves
- * according to mode
- */
-static void bond_mc_add(struct bonding *bond, void *addr)
-{
-	if (USES_PRIMARY(bond->params.mode)) {
-		/* write lock already acquired */
-		if (bond->curr_active_slave)
-			dev_mc_add(bond->curr_active_slave->dev, addr);
-	} else {
-		struct slave *slave;
-		int i;
-
-		bond_for_each_slave(bond, slave, i)
-			dev_mc_add(slave->dev, addr);
-	}
-}
-
-/*
- * Remove a multicast address from slave
- * according to mode
- */
-static void bond_mc_del(struct bonding *bond, void *addr)
-{
-	if (USES_PRIMARY(bond->params.mode)) {
-		/* write lock already acquired */
-		if (bond->curr_active_slave)
-			dev_mc_del(bond->curr_active_slave->dev, addr);
-	} else {
-		struct slave *slave;
-		int i;
-		bond_for_each_slave(bond, slave, i) {
-			dev_mc_del(slave->dev, addr);
-		}
-	}
-}
-
-
 static void __bond_resend_igmp_join_requests(struct net_device *dev)
 {
 	struct in_device *in_dev;
@@ -803,17 +764,15 @@ static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
 	bond_resend_igmp_join_requests(bond);
 }
 
-/*
- * flush all members of flush->mc_list from device dev->mc_list
+/* Flush bond's hardware addresses from slave
  */
-static void bond_mc_list_flush(struct net_device *bond_dev,
+static void bond_hw_addr_flush(struct net_device *bond_dev,
 			       struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct netdev_hw_addr *ha;
 
-	netdev_for_each_mc_addr(ha, bond_dev)
-		dev_mc_del(slave_dev, ha->addr);
+	dev_uc_unsync(slave_dev, bond_dev);
+	dev_mc_unsync(slave_dev, bond_dev);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* del lacpdu mc addr from mc list */
@@ -825,22 +784,14 @@ static void bond_mc_list_flush(struct net_device *bond_dev,
 
 /*--------------------------- Active slave change ---------------------------*/
 
-/*
- * Update the mc list and multicast-related flags for the new and
- * old active slaves (if any) according to the multicast mode, and
- * promiscuous flags unconditionally.
+/* Update the hardware address list and promisc/allmulti for the new and
+ * old active slaves (if any).  Modes that are !USES_PRIMARY keep all
+ * slaves up date at all times; only the USES_PRIMARY modes need to call
+ * this function to swap these settings during a failover.
  */
-static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
-			 struct slave *old_active)
+static void bond_hw_addr_swap(struct bonding *bond, struct slave *new_active,
+			      struct slave *old_active)
 {
-	struct netdev_hw_addr *ha;
-
-	if (!USES_PRIMARY(bond->params.mode))
-		/* nothing to do -  mc list is already up-to-date on
-		 * all slaves
-		 */
-		return;
-
 	if (old_active) {
 		if (bond->dev->flags & IFF_PROMISC)
 			dev_set_promiscuity(old_active->dev, -1);
@@ -848,10 +799,7 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(old_active->dev, -1);
 
-		netif_addr_lock_bh(bond->dev);
-		netdev_for_each_mc_addr(ha, bond->dev)
-			dev_mc_del(old_active->dev, ha->addr);
-		netif_addr_unlock_bh(bond->dev);
+		bond_hw_addr_flush(bond->dev, old_active->dev);
 	}
 
 	if (new_active) {
@@ -863,8 +811,8 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 			dev_set_allmulti(new_active->dev, 1);
 
 		netif_addr_lock_bh(bond->dev);
-		netdev_for_each_mc_addr(ha, bond->dev)
-			dev_mc_add(new_active->dev, ha->addr);
+		dev_uc_sync(new_active->dev, bond->dev);
+		dev_mc_sync(new_active->dev, bond->dev);
 		netif_addr_unlock_bh(bond->dev);
 	}
 }
@@ -1083,7 +1031,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	}
 
 	if (USES_PRIMARY(bond->params.mode))
-		bond_mc_swap(bond, new_active, old_active);
+		bond_hw_addr_swap(bond, new_active, old_active);
 
 	if (bond_is_lb(bond)) {
 		bond_alb_handle_active_change(bond, new_active);
@@ -1526,7 +1474,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct slave *new_slave = NULL;
-	struct netdev_hw_addr *ha;
 	struct sockaddr addr;
 	int link_reporting;
 	int res = 0;
@@ -1706,10 +1653,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			goto err_close;
 	}
 
-	/* If the mode USES_PRIMARY, then the new slave gets the
-	 * master's promisc (and mc) settings only if it becomes the
-	 * curr_active_slave, and that is taken care of later when calling
-	 * bond_change_active()
+	/* If the mode USES_PRIMARY, then the following is handled by
+	 * bond_change_active_slave().
 	 */
 	if (!USES_PRIMARY(bond->params.mode)) {
 		/* set promiscuity level to new slave */
@@ -1727,9 +1672,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 
 		netif_addr_lock_bh(bond_dev);
-		/* upload master's mc_list to new slave */
-		netdev_for_each_mc_addr(ha, bond_dev)
-			dev_mc_add(slave_dev, ha->addr);
+
+		dev_mc_sync_multiple(slave_dev, bond_dev);
+		dev_uc_sync_multiple(slave_dev, bond_dev);
+
 		netif_addr_unlock_bh(bond_dev);
 	}
 
@@ -1908,11 +1854,9 @@ err_dest_symlinks:
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
 err_detach:
-	if (!USES_PRIMARY(bond->params.mode)) {
-		netif_addr_lock_bh(bond_dev);
-		bond_mc_list_flush(bond_dev, slave_dev);
-		netif_addr_unlock_bh(bond_dev);
-	}
+	if (!USES_PRIMARY(bond->params.mode))
+		bond_hw_addr_flush(bond_dev, slave_dev);
+
 	bond_del_vlans_from_slave(bond, slave_dev);
 	write_lock_bh(&bond->lock);
 	bond_detach_slave(bond, new_slave);
@@ -2107,9 +2051,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	bond_del_vlans_from_slave(bond, slave_dev);
 
-	/* If the mode USES_PRIMARY, then we should only remove its
-	 * promisc and mc settings if it was the curr_active_slave, but that was
-	 * already taken care of above when we detached the slave
+	/* If the mode USES_PRIMARY, then this cases was handled above by
+	 * bond_change_active_slave(..., NULL)
 	 */
 	if (!USES_PRIMARY(bond->params.mode)) {
 		/* unset promiscuity level from slave */
@@ -2120,10 +2063,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		if (bond_dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(slave_dev, -1);
 
-		/* flush master's mc_list from slave */
-		netif_addr_lock_bh(bond_dev);
-		bond_mc_list_flush(bond_dev, slave_dev);
-		netif_addr_unlock_bh(bond_dev);
+		bond_hw_addr_flush(bond_dev, slave_dev);
 	}
 
 	bond_upper_dev_unlink(bond_dev, slave_dev);
@@ -3660,19 +3600,6 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	return res;
 }
 
-static bool bond_addr_in_mc_list(unsigned char *addr,
-				 struct netdev_hw_addr_list *list,
-				 int addrlen)
-{
-	struct netdev_hw_addr *ha;
-
-	netdev_hw_addr_list_for_each(ha, list)
-		if (!memcmp(ha->addr, addr, addrlen))
-			return true;
-
-	return false;
-}
-
 static void bond_change_rx_flags(struct net_device *bond_dev, int change)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3686,35 +3613,25 @@ static void bond_change_rx_flags(struct net_device *bond_dev, int change)
 				  bond_dev->flags & IFF_ALLMULTI ? 1 : -1);
 }
 
-static void bond_set_multicast_list(struct net_device *bond_dev)
+static void bond_set_rx_mode(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct netdev_hw_addr *ha;
-	bool found;
+	struct slave *slave;
+	int i;
 
 	read_lock(&bond->lock);
 
-	/* looking for addresses to add to slaves' mc list */
-	netdev_for_each_mc_addr(ha, bond_dev) {
-		found = bond_addr_in_mc_list(ha->addr, &bond->mc_list,
-					     bond_dev->addr_len);
-		if (!found)
-			bond_mc_add(bond, ha->addr);
-	}
-
-	/* looking for addresses to delete from slaves' list */
-	netdev_hw_addr_list_for_each(ha, &bond->mc_list) {
-		found = bond_addr_in_mc_list(ha->addr, &bond_dev->mc,
-					     bond_dev->addr_len);
-		if (!found)
-			bond_mc_del(bond, ha->addr);
+	if (USES_PRIMARY(bond->params.mode) && bond->curr_active_slave) {
+		slave = bond->curr_active_slave;
+		dev_uc_sync(slave->dev, bond_dev);
+		dev_mc_sync(slave->dev, bond_dev);
+	} else {
+		bond_for_each_slave(bond, slave, i) {
+			dev_uc_sync_multiple(slave->dev, bond_dev);
+			dev_mc_sync_multiple(slave->dev, bond_dev);
+		}
 	}
 
-	/* save master's multicast list */
-	__hw_addr_flush(&bond->mc_list);
-	__hw_addr_add_multiple(&bond->mc_list, &bond_dev->mc,
-			       bond_dev->addr_len, NETDEV_HW_ADDR_T_MULTICAST);
-
 	read_unlock(&bond->lock);
 }
 
@@ -4321,7 +4238,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_get_stats64	= bond_get_stats,
 	.ndo_do_ioctl		= bond_do_ioctl,
 	.ndo_change_rx_flags	= bond_change_rx_flags,
-	.ndo_set_rx_mode	= bond_set_multicast_list,
+	.ndo_set_rx_mode	= bond_set_rx_mode,
 	.ndo_change_mtu		= bond_change_mtu,
 	.ndo_set_mac_address	= bond_set_mac_address,
 	.ndo_neigh_setup	= bond_neigh_setup,
@@ -4426,8 +4343,6 @@ static void bond_uninit(struct net_device *bond_dev)
 
 	bond_debug_unregister(bond);
 
-	__hw_addr_flush(&bond->mc_list);
-
 	list_for_each_entry_safe(vlan, tmp, &bond->vlan_list, vlan_list) {
 		list_del(&vlan->vlan_list);
 		kfree(vlan);
@@ -4838,7 +4753,6 @@ static int bond_init(struct net_device *bond_dev)
 		bond->dev_addr_from_first = true;
 	}
 
-	__hw_addr_init(&bond->mc_list);
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 2baec24..b38609b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -231,7 +231,6 @@ struct bonding {
 	char     proc_file_name[IFNAMSIZ];
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
-	struct   netdev_hw_addr_list mc_list;
 	int      (*xmit_hash_policy)(struct sk_buff *, int);
 	u16      rr_tx_counter;
 	struct   ad_bond_info ad_info;
-- 
1.8.1.4
