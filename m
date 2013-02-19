From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next v2 3/3] bonding: fix bond_release_all inconsistencies
Date: Mon, 18 Feb 2013 19:12:01 -0800
Message-ID: <29485.1361243521@death.nxdomain>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com> <1361232582-19420-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:48552 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757828Ab3BSDMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 22:12:24 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 18 Feb 2013 20:12:23 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 8E9193E40044
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 20:11:55 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1J3C3FB353692
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 20:12:03 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1J3C2il017568
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 20:12:03 -0700
In-reply-to: <1361232582-19420-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>This patch fixes the following inconsistencies in bond_release_all:
>- IFF_BONDING flag is not stripped from slaves
>- MTU is not restored
>- no netdev notifiers are sent
>Instead of trying to keep bond_release and bond_release_all in sync
>I think we can re-use bond_release as the environment for calling it
>is correct (RTNL is held). I have been running tests for the past
>week and they came out successful. The only way for bond_release to fail
>is for the slave to be attached in a different bond or to not be a slave
>but that cannot happen as RTNL is held and no slave manipulations can be
>achieved.
>
>V2: As suggested bond_release is renamed to __bond_release_one with a
>new parameter "all" introduced so to avoid calling unnecessary code while
>destroying a bond, and a wrapper for it called bond_release is created
>because of ndo_del_link. bond_release_all() is removed.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_main.c | 135 ++++++----------------------------------
> 1 file changed, 18 insertions(+), 117 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 94c1534..e242dd1 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1937,7 +1937,8 @@ err_undo_flags:
> /*
>  * Try to release the slave device <slave> from the bond device <master>
>  * It is legal to access curr_active_slave without a lock because all the function
>- * is write-locked.
>+ * is write-locked. If "all" is true it means that the function is being called
>+ * while destroying a bond interface and all slaves are being released.
>  *
>  * The rules for slave state should be:
>  *   for Active/Backup:
>@@ -1945,7 +1946,9 @@ err_undo_flags:
>  *   for Bonded connections:
>  *     The first up interface should be left on and all others downed.
>  */
>-int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
>+static int __bond_release_one(struct net_device *bond_dev,
>+			      struct net_device *slave_dev,
>+			      bool all)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
> 	struct slave *slave, *oldcurrent;
>@@ -1982,7 +1985,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 	synchronize_net();
> 	write_lock_bh(&bond->lock);
>
>-	if (!bond->params.fail_over_mac) {
>+	if (!all && !bond->params.fail_over_mac) {
> 		if (ether_addr_equal(bond_dev->dev_addr, slave->perm_hwaddr) &&
> 		    bond->slave_cnt > 1)
> 			pr_warning("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
>@@ -2028,7 +2031,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 		write_lock_bh(&bond->lock);
> 	}
>
>-	if (oldcurrent == slave) {
>+	if (all) {
>+		bond->curr_active_slave = NULL;
>+	} else if (oldcurrent == slave) {
> 		/*
> 		 * Note that we hold RTNL over this sequence, so there
> 		 * is no concern that another slave add/remove event
>@@ -2117,6 +2122,12 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
> 	return 0;  /* deletion OK */
> }
>
>+/* A wrapper used because of ndo_del_link */
>+int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
>+{
>+	return __bond_release_one(bond_dev, slave_dev, false);
>+}
>+
> /*
> * First release a slave and then destroy the bond if no more slaves are left.
> * Must be under rtnl_lock when this function is called.
>@@ -2138,118 +2149,6 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
> }
>
> /*
>- * This function releases all slaves.
>- */
>-static int bond_release_all(struct net_device *bond_dev)
>-{
>-	struct bonding *bond = netdev_priv(bond_dev);
>-	struct slave *slave;
>-	struct net_device *slave_dev;
>-	struct sockaddr addr;
>-
>-	write_lock_bh(&bond->lock);
>-
>-	netif_carrier_off(bond_dev);
>-
>-	if (bond->slave_cnt == 0)
>-		goto out;
>-
>-	bond->current_arp_slave = NULL;
>-	bond->primary_slave = NULL;
>-	bond_change_active_slave(bond, NULL);
>-
>-	while ((slave = bond->first_slave) != NULL) {
>-		/* Inform AD package of unbinding of slave
>-		 * before slave is detached from the list.
>-		 */
>-		if (bond->params.mode == BOND_MODE_8023AD)
>-			bond_3ad_unbind_slave(slave);
>-
>-		slave_dev = slave->dev;
>-		bond_detach_slave(bond, slave);
>-
>-		/* now that the slave is detached, unlock and perform
>-		 * all the undo steps that should not be called from
>-		 * within a lock.
>-		 */
>-		write_unlock_bh(&bond->lock);
>-
>-		/* unregister rx_handler early so bond_handle_frame wouldn't
>-		 * be called for this slave anymore.
>-		 */
>-		netdev_rx_handler_unregister(slave_dev);
>-		synchronize_net();
>-
>-		if (bond_is_lb(bond)) {
>-			/* must be called only after the slave
>-			 * has been detached from the list
>-			 */
>-			bond_alb_deinit_slave(bond, slave);
>-		}
>-
>-		bond_destroy_slave_symlinks(bond_dev, slave_dev);
>-		bond_del_vlans_from_slave(bond, slave_dev);
>-
>-		/* If the mode USES_PRIMARY, then we should only remove its
>-		 * promisc and mc settings if it was the curr_active_slave, but that was
>-		 * already taken care of above when we detached the slave
>-		 */
>-		if (!USES_PRIMARY(bond->params.mode)) {
>-			/* unset promiscuity level from slave */
>-			if (bond_dev->flags & IFF_PROMISC)
>-				dev_set_promiscuity(slave_dev, -1);
>-
>-			/* unset allmulti level from slave */
>-			if (bond_dev->flags & IFF_ALLMULTI)
>-				dev_set_allmulti(slave_dev, -1);
>-
>-			/* flush master's mc_list from slave */
>-			netif_addr_lock_bh(bond_dev);
>-			bond_mc_list_flush(bond_dev, slave_dev);
>-			netif_addr_unlock_bh(bond_dev);
>-		}
>-
>-		bond_upper_dev_unlink(bond_dev, slave_dev);
>-
>-		slave_disable_netpoll(slave);
>-
>-		/* close slave before restoring its mac address */
>-		dev_close(slave_dev);
>-
>-		if (!bond->params.fail_over_mac) {
>-			/* restore original ("permanent") mac address*/
>-			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
>-			addr.sa_family = slave_dev->type;
>-			dev_set_mac_address(slave_dev, &addr);
>-		}
>-
>-		kfree(slave);
>-
>-		/* re-acquire the lock before getting the next slave */
>-		write_lock_bh(&bond->lock);
>-	}
>-
>-	eth_hw_addr_random(bond_dev);
>-	bond->dev_addr_from_first = true;
>-
>-	if (bond_vlan_used(bond)) {
>-		pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
>-			   bond_dev->name, bond_dev->name);
>-		pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
>-			   bond_dev->name);
>-	}
>-
>-	pr_info("%s: released all slaves\n", bond_dev->name);
>-
>-out:
>-	write_unlock_bh(&bond->lock);
>-
>-	bond_compute_features(bond);
>-
>-	return 0;
>-}
>-
>-/*
>  * This function changes the active slave to slave <slave_dev>.
>  * It returns -EINVAL in the following cases.
>  *  - <slave_dev> is not found in the list.
>@@ -4440,7 +4339,9 @@ static void bond_uninit(struct net_device *bond_dev)
> 	bond_netpoll_cleanup(bond_dev);
>
> 	/* Release the bonded slaves */
>-	bond_release_all(bond_dev);
>+	while (bond->first_slave != NULL)
>+		__bond_release_one(bond_dev, bond->first_slave->dev, true);
>+	pr_info("%s: released all slaves\n", bond_dev->name);
>
> 	list_del(&bond->bond_list);
>
>-- 
>1.7.11.7
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
