From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 3/3] bonding: fix bond_release_all inconsistencies
Date: Mon, 18 Feb 2013 18:59:04 +0100
Message-ID: <1361210344-14907-3-git-send-email-nikolay@redhat.com>
References: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6499 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756462Ab3BRSBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 13:01:45 -0500
In-Reply-To: <1361210344-14907-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following inconsistencies in bond_release_all:
- IFF_BONDING flag is not stripped from slaves
- MTU is not restored
- no netdev notifiers are sent
Instead of trying to keep bond_release and bond_release_all in sync
I think we can re-use bond_release as the environment for calling it
is correct (RTNL is held). I have been running tests for the past
week and they came out successful. The only way for bond_release to fail
is for the slave to be attached in a different bond or to not be a slave
but that cannot happen as RTNL is held and no slave manipulations can be
achieved.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 106 ++--------------------------------------
 1 file changed, 5 insertions(+), 101 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 94c1534..fcfc880 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2140,113 +2140,17 @@ static int  bond_release_and_destroy(struct net_device *bond_dev,
 /*
  * This function releases all slaves.
  */
-static int bond_release_all(struct net_device *bond_dev)
+static void bond_release_all(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct slave *slave;
-	struct net_device *slave_dev;
-	struct sockaddr addr;
-
-	write_lock_bh(&bond->lock);
-
-	netif_carrier_off(bond_dev);
 
 	if (bond->slave_cnt == 0)
-		goto out;
-
-	bond->current_arp_slave = NULL;
-	bond->primary_slave = NULL;
-	bond_change_active_slave(bond, NULL);
-
-	while ((slave = bond->first_slave) != NULL) {
-		/* Inform AD package of unbinding of slave
-		 * before slave is detached from the list.
-		 */
-		if (bond->params.mode == BOND_MODE_8023AD)
-			bond_3ad_unbind_slave(slave);
-
-		slave_dev = slave->dev;
-		bond_detach_slave(bond, slave);
-
-		/* now that the slave is detached, unlock and perform
-		 * all the undo steps that should not be called from
-		 * within a lock.
-		 */
-		write_unlock_bh(&bond->lock);
-
-		/* unregister rx_handler early so bond_handle_frame wouldn't
-		 * be called for this slave anymore.
-		 */
-		netdev_rx_handler_unregister(slave_dev);
-		synchronize_net();
-
-		if (bond_is_lb(bond)) {
-			/* must be called only after the slave
-			 * has been detached from the list
-			 */
-			bond_alb_deinit_slave(bond, slave);
-		}
-
-		bond_destroy_slave_symlinks(bond_dev, slave_dev);
-		bond_del_vlans_from_slave(bond, slave_dev);
-
-		/* If the mode USES_PRIMARY, then we should only remove its
-		 * promisc and mc settings if it was the curr_active_slave, but that was
-		 * already taken care of above when we detached the slave
-		 */
-		if (!USES_PRIMARY(bond->params.mode)) {
-			/* unset promiscuity level from slave */
-			if (bond_dev->flags & IFF_PROMISC)
-				dev_set_promiscuity(slave_dev, -1);
-
-			/* unset allmulti level from slave */
-			if (bond_dev->flags & IFF_ALLMULTI)
-				dev_set_allmulti(slave_dev, -1);
-
-			/* flush master's mc_list from slave */
-			netif_addr_lock_bh(bond_dev);
-			bond_mc_list_flush(bond_dev, slave_dev);
-			netif_addr_unlock_bh(bond_dev);
-		}
-
-		bond_upper_dev_unlink(bond_dev, slave_dev);
-
-		slave_disable_netpoll(slave);
-
-		/* close slave before restoring its mac address */
-		dev_close(slave_dev);
-
-		if (!bond->params.fail_over_mac) {
-			/* restore original ("permanent") mac address*/
-			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-			addr.sa_family = slave_dev->type;
-			dev_set_mac_address(slave_dev, &addr);
-		}
-
-		kfree(slave);
-
-		/* re-acquire the lock before getting the next slave */
-		write_lock_bh(&bond->lock);
-	}
-
-	eth_hw_addr_random(bond_dev);
-	bond->dev_addr_from_first = true;
-
-	if (bond_vlan_used(bond)) {
-		pr_warning("%s: Warning: clearing HW address of %s while it still has VLANs.\n",
-			   bond_dev->name, bond_dev->name);
-		pr_warning("%s: When re-adding slaves, make sure the bond's HW address matches its VLANs'.\n",
-			   bond_dev->name);
-	}
-
+		return;
+	while (bond->first_slave != NULL)
+		bond_release(bond_dev, bond->first_slave->dev);
 	pr_info("%s: released all slaves\n", bond_dev->name);
 
-out:
-	write_unlock_bh(&bond->lock);
-
-	bond_compute_features(bond);
-
-	return 0;
+	return;
 }
 
 /*
-- 
1.7.11.7
