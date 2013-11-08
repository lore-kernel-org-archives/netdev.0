From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 9/10] bonding: remvoe unwanted lock for bond enslave
 and release
Date: Fri, 8 Nov 2013 10:08:19 +0800
Message-ID: <527C4793.5060306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:8833 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932465Ab3KHCSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:18:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_change_active_slave() and bond_select_active_slave()
do't need bond lock anymore, so remove the unwanted bond lock
for these two functions.

The bond_select_active_slave() will release and acquire
curr_slave_lock, so the curr_slave_lock need to protect
the function.

In bond enslave and bond release, the bond slave list is also
protected by RTNL, so bond lock is no need to exist, remove
the lock and clean the functions.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 27 ++++++---------------------
 1 file changed, 6 insertions(+), 21 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b48ca55..be163e2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1579,11 +1579,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 	if (USES_PRIMARY(bond->params.mode)) {
-		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
 	}
 
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
@@ -1603,19 +1601,13 @@ err_detach:
 		bond_hw_addr_flush(bond_dev, slave_dev);
 
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
-	write_lock_bh(&bond->lock);
 	if (bond->primary_slave == new_slave)
 		bond->primary_slave = NULL;
 	if (bond->curr_active_slave == new_slave) {
-		bond_change_active_slave(bond, NULL);
-		write_unlock_bh(&bond->lock);
-		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
+		bond_change_active_slave(bond, NULL);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
-	} else {
-		write_unlock_bh(&bond->lock);
 	}
 	slave_disable_netpoll(new_slave);
 
@@ -1680,20 +1672,16 @@ static int __bond_release_one(struct net_device *bond_dev,
 	}
 
 	block_netpoll_tx();
-	write_lock_bh(&bond->lock);
 
 	slave = bond_get_slave_by_dev(bond, slave_dev);
 	if (!slave) {
 		/* not a slave of this bond */
 		pr_info("%s: %s not enslaved\n",
 			bond_dev->name, slave_dev->name);
-		write_unlock_bh(&bond->lock);
 		unblock_netpoll_tx();
 		return -EINVAL;
 	}
 
-	write_unlock_bh(&bond->lock);
-
 	/* release the slave from its bond */
 	bond->slave_cnt--;
 
@@ -1711,6 +1699,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		 */
 		bond_3ad_unbind_slave(slave);
 	}
+	write_unlock_bh(&bond->lock);
 
 	pr_info("%s: releasing %s interface %s\n",
 		bond_dev->name,
@@ -1733,8 +1722,11 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (bond->primary_slave == slave)
 		bond->primary_slave = NULL;
 
-	if (oldcurrent == slave)
+	if (oldcurrent == slave) {
+		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, NULL);
+		write_unlock_bh(&bond->curr_slave_lock);
+	}
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after the slave has been
@@ -1742,9 +1734,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 		 * has been cleared (if our_slave == old_current),
 		 * but before a new active slave is selected.
 		 */
-		write_unlock_bh(&bond->lock);
 		bond_alb_deinit_slave(bond, slave);
-		write_lock_bh(&bond->lock);
 	}
 
 	if (all) {
@@ -1755,15 +1745,11 @@ static int __bond_release_one(struct net_device *bond_dev,
 		 * is no concern that another slave add/remove event
 		 * will interfere.
 		 */
-		write_unlock_bh(&bond->lock);
-		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
 		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
-		write_lock_bh(&bond->lock);
 	}
 
 	if (!bond_has_slaves(bond)) {
@@ -1778,7 +1764,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 		}
 	}
 
-	write_unlock_bh(&bond->lock);
 	unblock_netpoll_tx();
 	synchronize_rcu();
 
-- 
1.8.2.1
